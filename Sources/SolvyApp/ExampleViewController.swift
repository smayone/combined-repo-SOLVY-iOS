import UIKit
import SwiftUI
import SolvyCore

public class ExampleViewController: UIViewController {
    private let service = TransactionBridgeService()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let button = UIButton(type: .system)
        button.setTitle("Test Transaction", for: .normal)
        button.addTarget(self, action: #selector(testTransaction), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func testTransaction() {
        let testTransaction = CardTransaction(
            cardNumber: "4111111111111111",
            amount: 10.00,
            currency: "USD",
            merchantId: "TEST-MERCHANT-001",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        Task {
            do {
                let transactionId = try await service.initiateTransaction(testTransaction)
                await MainActor.run {
                    showTransactionStatus(for: transactionId)
                }
            } catch {
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    private func showTransactionStatus(for transactionId: String) {
        let statusView = TransactionStatusView(transactionId: transactionId)
        let hostingController = UIHostingController(rootView: statusView)
        present(hostingController, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
