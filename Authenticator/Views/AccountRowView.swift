import SwiftUI

struct AccountRowView: View {
    let account: Account
    @EnvironmentObject var totpService: TOTPService
    @EnvironmentObject var totpGenerator: TOTPGenerator
    @State private var currentCode: TOTPCode?
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(account.username)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let code = currentCode {
                    HStack(spacing: 8) {
                        Text(formattedCode(code.code))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .foregroundColor(code.isExpiringSoon ? .red : .primary)
                        
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.declareTypes([.string], owner: nil)
                            pasteboard.setString(code.code, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Copy code")
                    }
                    
                    ProgressView(value: code.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: code.isExpiringSoon ? .red : .accentColor))
                        .frame(width: 100)
                        .scaleEffect(x: 1, y: 0.5)
                } else {
                    Text("Generating...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .onAppear {
            updateCode()
        }
        .onReceive(totpGenerator.$codes) { _ in
            updateCode()
        }
    }
    
    private func updateCode() {
        currentCode = totpService.getCurrentCode(for: account)
    }
    
    private func formattedCode(_ code: String) -> String {
        let index = code.index(code.startIndex, offsetBy: 3)
        let firstPart = String(code[..<index])
        let secondPart = String(code[index...])
        return "\(firstPart) \(secondPart)"
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(Account.sampleAccounts) { account in
            AccountRowView(account: account)
                .background(Color(NSColor.controlBackgroundColor))
        }
    }
    .environmentObject(TOTPService())
    .environmentObject(TOTPGenerator())
    .padding()
    .frame(width: 400)
}