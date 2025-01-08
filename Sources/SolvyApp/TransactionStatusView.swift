import SwiftUI
import SolvyCore

public struct TransactionStatusView: View {
    @State private var progress: Double = 0
    @State private var status: TransactionStatus?
    @State private var error: Error?
    
    private let transactionId: String
    private let service: TransactionBridgeService
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    public init(transactionId: String, service: TransactionBridgeService = TransactionBridgeService()) {
        self.transactionId = transactionId
        self.service = service
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if let status = status {
                // Status Header
                HStack {
                    Text("Transaction Status")
                        .font(.title2)
                        .bold()
                    
                    statusIcon(for: status.status)
                }
                
                // Progress Bar
                VStack(alignment: .leading) {
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("\(Int(progress))%")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    ProgressView(value: progress, total: 100)
                }
                
                // Details
                VStack(spacing: 12) {
                    detailRow("Status", value: status.status.capitalized)
                    
                    if let blockNumber = status.blockNumber {
                        detailRow("Block Number", value: "\(blockNumber)")
                    }
                    
                    if let confirmations = status.confirmations {
                        detailRow("Confirmations", value: "\(confirmations)")
                    }
                    
                    if let hash = status.transactionHash {
                        Link("View on Explorer", destination: URL(string: "https://polygonscan.com/tx/\(hash)")!)
                    }
                }
                
                if let error = status.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear(perform: fetchStatus)
        .onReceive(timer) { _ in
            fetchStatus()
        }
    }
    
    private func statusIcon(for status: String) -> some View {
        switch status {
        case "completed":
            return Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case "failed":
            return Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        default:
            return Image(systemName: "clock.fill")
                .foregroundColor(.yellow)
        }
    }
    
    private func detailRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
    
    private func fetchStatus() {
        Task {
            do {
                let newStatus = try await service.getTransactionStatus(id: transactionId)
                await MainActor.run {
                    self.status = newStatus
                    updateProgress(for: newStatus)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    private func updateProgress(for status: TransactionStatus) {
        switch status.status {
        case "pending":
            progress = 25
        case "processing":
            progress = Double(50 + min((status.confirmations ?? 0) * 5, 40))
        case "completed":
            progress = 100
        case "failed":
            progress = 100
        default:
            progress = 0
        }
    }
}

#Preview {
    TransactionStatusView(transactionId: "CARD-preview")
}
