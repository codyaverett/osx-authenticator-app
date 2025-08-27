import Foundation

struct Account: Identifiable, Codable {
    let id = UUID()
    let serviceName: String
    let username: String
    let secretKey: String
    let issuer: String?
    let algorithm: TOTPAlgorithm
    let digits: Int
    let period: Int
    let createdAt: Date
    
    init(serviceName: String, username: String, secretKey: String, issuer: String? = nil, algorithm: TOTPAlgorithm = .sha1, digits: Int = 6, period: Int = 30) {
        self.serviceName = serviceName
        self.username = username
        self.secretKey = secretKey
        self.issuer = issuer
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.createdAt = Date()
    }
    
    var displayName: String {
        if let issuer = issuer, !issuer.isEmpty {
            return "\(issuer) (\(username))"
        }
        return "\(serviceName) (\(username))"
    }
}

enum TOTPAlgorithm: String, CaseIterable, Codable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"
    
    var displayName: String {
        switch self {
        case .sha1:
            return "SHA-1"
        case .sha256:
            return "SHA-256"
        case .sha512:
            return "SHA-512"
        }
    }
}

extension Account {
    static let sampleAccounts = [
        Account(serviceName: "Google", username: "john@gmail.com", secretKey: "JBSWY3DPEHPK3PXP", issuer: "Google"),
        Account(serviceName: "GitHub", username: "johndoe", secretKey: "HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ", issuer: "GitHub"),
        Account(serviceName: "Microsoft", username: "john@outlook.com", secretKey: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", issuer: "Microsoft")
    ]
}