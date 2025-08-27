import Foundation

struct QRCodeParser {
    static func parseGoogleAuthenticatorURL(_ urlString: String) -> Account? {
        guard let url = URL(string: urlString),
              url.scheme == "otpauth",
              url.host == "totp" else {
            return nil
        }
        
        let path = url.path
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        var secret: String?
        var issuer: String?
        var algorithm: TOTPAlgorithm = .sha1
        var digits: Int = 6
        var period: Int = 30
        
        for item in queryItems {
            switch item.name {
            case "secret":
                secret = item.value
            case "issuer":
                issuer = item.value
            case "algorithm":
                if let value = item.value {
                    algorithm = TOTPAlgorithm(rawValue: value) ?? .sha1
                }
            case "digits":
                if let value = item.value, let intValue = Int(value) {
                    digits = intValue
                }
            case "period":
                if let value = item.value, let intValue = Int(value) {
                    period = intValue
                }
            default:
                break
            }
        }
        
        guard let secretKey = secret, !secretKey.isEmpty else {
            return nil
        }
        
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        let label = pathComponents.first ?? ""
        
        var serviceName: String = ""
        var username: String = ""
        
        if label.contains(":") {
            let labelParts = label.components(separatedBy: ":")
            serviceName = labelParts[0]
            username = labelParts.dropFirst().joined(separator: ":")
        } else {
            serviceName = label
            username = label
        }
        
        if serviceName.isEmpty {
            serviceName = issuer ?? "Unknown Service"
        }
        
        if username.isEmpty {
            username = "Unknown User"
        }
        
        return Account(
            serviceName: serviceName,
            username: username,
            secretKey: secretKey,
            issuer: issuer,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
    }
    
    static func parseMultipleAccounts(_ urlString: String) -> [Account] {
        var accounts: [Account] = []
        
        if urlString.hasPrefix("otpauth-migration://") {
            accounts = parseGoogleAuthenticatorMigration(urlString)
        } else if urlString.hasPrefix("otpauth://") {
            if let account = parseGoogleAuthenticatorURL(urlString) {
                accounts.append(account)
            }
        }
        
        return accounts
    }
    
    private static func parseGoogleAuthenticatorMigration(_ urlString: String) -> [Account] {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return []
        }
        
        var accounts: [Account] = []
        
        for item in queryItems {
            if item.name == "data", let encodedData = item.value {
                accounts.append(contentsOf: decodeMigrationData(encodedData))
            }
        }
        
        return accounts
    }
    
    private static func decodeMigrationData(_ encodedData: String) -> [Account] {
        let accounts: [Account] = []
        
        return accounts
    }
    
    static func isValidOTPAuthURL(_ urlString: String) -> Bool {
        return urlString.hasPrefix("otpauth://") || urlString.hasPrefix("otpauth-migration://")
    }
}