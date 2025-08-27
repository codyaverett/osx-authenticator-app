import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.example.authenticator"
    private let accessGroup = "com.example.authenticator"
    
    private init() {}
    
    func save(account: Account) -> Bool {
        let accountData = account.secretKey.data(using: .utf8) ?? Data()
        let metadataData = encodeMetadata(account: account)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account.id.uuidString,
            kSecValueData as String: accountData,
            kSecAttrGeneric as String: metadataData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            return update(account: account)
        }
        
        return status == errSecSuccess
    }
    
    func load(id: UUID) -> Account? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id.uuidString,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let item = result as? [String: Any],
              let secretData = item[kSecValueData as String] as? Data,
              let secretKey = String(data: secretData, encoding: .utf8),
              let metadataData = item[kSecAttrGeneric as String] as? Data,
              let metadata = decodeMetadata(data: metadataData) else {
            return nil
        }
        
        return Account(
            serviceName: metadata.serviceName,
            username: metadata.username,
            secretKey: secretKey,
            issuer: metadata.issuer,
            algorithm: metadata.algorithm,
            digits: metadata.digits,
            period: metadata.period
        )
    }
    
    func loadAll() -> [Account] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        
        var accounts: [Account] = []
        
        for item in items {
            guard let secretData = item[kSecValueData as String] as? Data,
                  let secretKey = String(data: secretData, encoding: .utf8),
                  let metadataData = item[kSecAttrGeneric as String] as? Data,
                  let metadata = decodeMetadata(data: metadataData) else {
                continue
            }
            
            let account = Account(
                serviceName: metadata.serviceName,
                username: metadata.username,
                secretKey: secretKey,
                issuer: metadata.issuer,
                algorithm: metadata.algorithm,
                digits: metadata.digits,
                period: metadata.period
            )
            
            accounts.append(account)
        }
        
        return accounts.sorted { $0.displayName < $1.displayName }
    }
    
    func delete(id: UUID) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id.uuidString
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    private func update(account: Account) -> Bool {
        let accountData = account.secretKey.data(using: .utf8) ?? Data()
        let metadataData = encodeMetadata(account: account)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account.id.uuidString
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: accountData,
            kSecAttrGeneric as String: metadataData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        return status == errSecSuccess
    }
    
    private func encodeMetadata(account: Account) -> Data {
        let metadata = AccountMetadata(
            serviceName: account.serviceName,
            username: account.username,
            issuer: account.issuer,
            algorithm: account.algorithm,
            digits: account.digits,
            period: account.period,
            createdAt: account.createdAt
        )
        
        return (try? JSONEncoder().encode(metadata)) ?? Data()
    }
    
    private func decodeMetadata(data: Data) -> AccountMetadata? {
        return try? JSONDecoder().decode(AccountMetadata.self, from: data)
    }
}

private struct AccountMetadata: Codable {
    let serviceName: String
    let username: String
    let issuer: String?
    let algorithm: TOTPAlgorithm
    let digits: Int
    let period: Int
    let createdAt: Date
}