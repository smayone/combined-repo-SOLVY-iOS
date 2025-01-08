import SwiftUI
import SolvyCore

struct WalletView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var web3Manager: Web3Manager
    @State private var balance: String = "0.00"
    @State private var isLoading = false
    @State private var showingWizard = false
    @State private var currentStep = 0

    private let steps = [
        WizardStep(
            title: "Welcome to Web3",
            description: "Let's help you get started with your digital wallet - it's easier than you think!",
            content: "A digital wallet is like your regular wallet, but for the digital world. It helps you:\n\n• Securely store and manage your digital assets\n• Make instant payments without traditional banking delays\n• Access exclusive Web3 features and benefits"
        ),
        WizardStep(
            title: "Choose Your Wallet",
            description: "Select the wallet that works best for you.",
            content: "MetaMask is our recommended wallet for beginners. It's the most popular and user-friendly option."
        ),
        WizardStep(
            title: "Connect Your Wallet",
            description: "Follow these simple steps to connect your wallet.",
            content: "1. Install MetaMask from the App Store\n2. Create or import your wallet\n3. Return to SOLVY and tap 'Connect Now'"
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if walletManager.isConnected {
                        connectedView
                    } else {
                        notConnectedView
                    }
                }
                .padding()
            }
            .navigationTitle("Wallet")
            .sheet(isPresented: $showingWizard) {
                wizardView
            }
        }
    }

    private var connectedView: some View {
        VStack(spacing: 20) {
            // Balance Card
            balanceCard

            // Quick Actions
            quickActions
        }
    }

    private var notConnectedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Connect Your Wallet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Start your Web3 journey with SOLVY")
                .foregroundColor(.secondary)

            Button {
                showingWizard = true
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("$\(balance)")
                .font(.system(size: 36, weight: .bold))

            if isLoading {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var quickActions: some View {
        HStack(spacing: 20) {
            ActionButton(title: "Send", systemImage: "arrow.up.right") {
                // Implementation for send action
            }

            ActionButton(title: "Receive", systemImage: "arrow.down.left") {
                // Implementation for receive action
            }

            ActionButton(title: "Swap", systemImage: "arrow.2.circlepath") {
                // Implementation for swap action
            }
        }
    }

    private var wizardView: some View {
        NavigationView {
            VStack {
                TabView(selection: $currentStep) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        WizardStepView(step: steps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }

                    Spacer()

                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    } else {
                        Button("Connect Now") {
                            Task {
                                await walletManager.connect()
                                showingWizard = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Setup Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        showingWizard = false
                    }
                }
            }
        }
    }

    private func refreshBalance() {
        isLoading = true
        // Implement balance refresh logic here
        isLoading = false
    }
}

struct WizardStep {
    let title: String
    let description: String
    let content: String
}

struct WizardStepView: View {
    let step: WizardStep

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(step.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(step.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(step.content)
                    .padding(.top)
            }
            .padding()
        }
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    WalletView()
        .environmentObject(WalletManager())
        .environmentObject(Web3Manager())
}