import Foundation
import web3swift
import BigInt

public class Web3Manager: ObservableObject {
    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var currentAddress: String?
    
    private var web3Instance: web3?
    
    public init() {}
    
    public func connect(endpoint: String) async throws {
        guard let url = URL(string: endpoint) else {
            throw Web3Error.invalidEndpoint
        }
        
        let provider = Web3HttpProvider(url: url)
        web3Instance = web3(provider: provider)
        
        isConnected = web3Instance != nil
    }
    
    public func getBalance(for address: String) async throws -> BigUInt {
        guard let web3 = web3Instance else {
            throw Web3Error.notConnected
        }
        
        return try await web3.eth.getBalance(address: EthereumAddress(address)!)
    }
}

public enum Web3Error: Error {
    case invalidEndpoint
    case notConnected
    case invalidAddress
    case transactionFailed
}
