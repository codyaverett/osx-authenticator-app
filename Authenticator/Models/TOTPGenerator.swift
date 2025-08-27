import Foundation
import CryptoKit

struct TOTPCode {
    let code: String
    let validUntil: Date
    let timeRemaining: TimeInterval
    
    var progress: Double {
        let totalPeriod: TimeInterval = 30
        return timeRemaining / totalPeriod
    }
    
    var isExpiringSoon: Bool {
        return timeRemaining <= 5
    }
}

class TOTPGenerator: ObservableObject {
    @Published var codes: [UUID: TOTPCode] = [:]
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func generateCode(for account: Account) -> TOTPCode? {
        guard let secretData = base32Decode(account.secretKey) else {
            return nil
        }
        
        let now = Date()
        let timeCounter = UInt64(now.timeIntervalSince1970) / UInt64(account.period)
        
        let code = generateTOTP(
            secret: secretData,
            counter: timeCounter,
            algorithm: account.algorithm,
            digits: account.digits
        )
        
        let currentPeriodStart = timeCounter * UInt64(account.period)
        let nextPeriodStart = (timeCounter + 1) * UInt64(account.period)
        let validUntil = Date(timeIntervalSince1970: TimeInterval(nextPeriodStart))
        let timeRemaining = validUntil.timeIntervalSince(now)
        
        let totpCode = TOTPCode(
            code: code,
            validUntil: validUntil,
            timeRemaining: timeRemaining
        )
        
        codes[account.id] = totpCode
        return totpCode
    }
    
    func getCode(for accountId: UUID) -> TOTPCode? {
        return codes[accountId]
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCodes()
        }
    }
    
    private func updateCodes() {
        let now = Date()
        var updatedCodes: [UUID: TOTPCode] = [:]
        
        for (accountId, code) in codes {
            let timeRemaining = code.validUntil.timeIntervalSince(now)
            
            if timeRemaining > 0 {
                updatedCodes[accountId] = TOTPCode(
                    code: code.code,
                    validUntil: code.validUntil,
                    timeRemaining: timeRemaining
                )
            }
        }
        
        DispatchQueue.main.async {
            self.codes = updatedCodes
        }
    }
    
    private func generateTOTP(secret: Data, counter: UInt64, algorithm: TOTPAlgorithm, digits: Int) -> String {
        let counterData = withUnsafeBytes(of: counter.bigEndian) { Data($0) }
        
        let hmac: Data
        switch algorithm {
        case .sha1:
            hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: SymmetricKey(data: secret)))
        case .sha256:
            hmac = Data(HMAC<SHA256>.authenticationCode(for: counterData, using: SymmetricKey(data: secret)))
        case .sha512:
            hmac = Data(HMAC<SHA512>.authenticationCode(for: counterData, using: SymmetricKey(data: secret)))
        }
        
        let offset = Int(hmac[hmac.count - 1] & 0x0f)
        let truncatedHash = hmac.subdata(in: offset..<offset + 4)
        
        let code = truncatedHash.withUnsafeBytes { bytes in
            let pointer = bytes.bindMemory(to: UInt32.self)
            return UInt32(bigEndian: pointer[0]) & 0x7fffffff
        }
        
        let otp = code % UInt32(pow(10, Double(digits)))
        return String(format: "%0\(digits)d", otp)
    }
    
    private func base32Decode(_ input: String) -> Data? {
        let cleanInput = input.replacingOccurrences(of: " ", with: "").uppercased()
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        
        var bits = ""
        
        for char in cleanInput {
            guard let index = base32Alphabet.firstIndex(of: char) else {
                return nil
            }
            let value = base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
            bits += String(value, radix: 2).leftPadding(toLength: 5, withPad: "0")
        }
        
        var data = Data()
        var index = bits.startIndex
        
        while bits.distance(from: index, to: bits.endIndex) >= 8 {
            let byteEnd = bits.index(index, offsetBy: 8)
            let byteString = String(bits[index..<byteEnd])
            if let byte = UInt8(byteString, radix: 2) {
                data.append(byte)
            }
            index = byteEnd
        }
        
        return data.isEmpty ? nil : data
    }
}

private extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}