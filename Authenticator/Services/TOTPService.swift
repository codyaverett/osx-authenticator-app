import Foundation

class TOTPService: ObservableObject {
    @Published var accounts: [Account] = []
    
    private let keychainService = KeychainService.shared
    private let totpGenerator = TOTPGenerator()
    
    init() {
        loadAccounts()
    }
    
    func loadAccounts() {
        accounts = keychainService.loadAll()
        
        for account in accounts {
            _ = totpGenerator.generateCode(for: account)
        }
    }
    
    func addAccount(_ account: Account) -> Bool {
        let success = keychainService.save(account: account)
        if success {
            loadAccounts()
        }
        return success
    }
    
    func deleteAccount(_ account: Account) -> Bool {
        let success = keychainService.delete(id: account.id)
        if success {
            loadAccounts()
        }
        return success
    }
    
    func updateAccount(_ account: Account) -> Bool {
        let success = keychainService.save(account: account)
        if success {
            loadAccounts()
        }
        return success
    }
    
    func getCurrentCode(for account: Account) -> TOTPCode? {
        if let existingCode = totpGenerator.getCode(for: account.id),
           existingCode.timeRemaining > 0 {
            return existingCode
        }
        
        return totpGenerator.generateCode(for: account)
    }
    
    func refreshCode(for account: Account) -> TOTPCode? {
        return totpGenerator.generateCode(for: account)
    }
    
    func getTOTPGenerator() -> TOTPGenerator {
        return totpGenerator
    }
}