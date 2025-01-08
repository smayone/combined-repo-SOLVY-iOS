import SwiftUI
import SolvyCore

@main
struct SolvyApp: App {
    @StateObject private var web3Manager = Web3Manager()
    @StateObject private var walletManager = WalletManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(web3Manager)
                .environmentObject(walletManager)
        }
    }
}
