import Foundation

public enum TransactionError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}

public struct CardTransaction: Codable {
    let cardNumber: String
    let amount: Double
    let currency: String
    let merchantId: String
    let timestamp: String
}

public struct TransactionStatus: Codable {
    let status: String
    let transactionHash: String?
    let blockNumber: Int?
    let confirmations: Int?
    let error: String?
    let lastUpdated: TimeInterval
}

public class TransactionBridgeService {
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL = URL(string: "http://localhost:5000")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func initiateTransaction(_ transaction: CardTransaction) async throws -> String {
        let url = baseURL.appendingPathComponent("/api/bridge/transactions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode([
            "cardTransaction": transaction,
            "targetChain": "polygon"
        ])
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TransactionError.apiError("Invalid response")
        }
        
        struct Response: Codable {
            let success: Bool
            let data: TransactionData
            
            struct TransactionData: Codable {
                let transactionId: String
            }
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.data.transactionId
    }
    
    public func getTransactionStatus(id: String) async throws -> TransactionStatus {
        let url = baseURL.appendingPathComponent("/api/bridge/transactions/\(id)")
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TransactionError.apiError("Invalid response")
        }
        
        struct Response: Codable {
            let success: Bool
            let data: TransactionStatus
        }
        
        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.data
    }
}
