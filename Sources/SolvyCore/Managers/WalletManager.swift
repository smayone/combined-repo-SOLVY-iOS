import Foundation
import Security
import web3swift

public class WalletManager: ObservableObject {
    @Published public private(set) var isWalletCreated: Bool = false
    @Published public private(set) var walletAddress: String?
    
    private let keychain = KeychainWrapper.standard
    private let walletKey = "com.solvy.wallet"
    
    public init() {
        loadExistingWallet()
    }
    
    private func loadExistingWallet() {
        if let address = keychain.string(forKey: walletKey) {
            walletAddress = address
            isWalletCreated = true
        }
    }
    
    public func createWallet(password: String) throws -> String {
        let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128)!
        let keystore = try BIP32Keystore(
            mnemonics: mnemonics,
            password: password,
            prefixPath: "m/44'/60'/0'/0"
        )!
        
        guard let address = keystore.addresses?.first?.address else {
            throw WalletError.walletCreationFailed
        }
        
        keychain.set(address, forKey: walletKey)
        walletAddress = address
        isWalletCreated = true
        
        return mnemonics
    }
}

public enum WalletError: Error {
    case walletCreationFailed
    case walletImportFailed
    case walletNotFound
    case invalidMnemonic
}
