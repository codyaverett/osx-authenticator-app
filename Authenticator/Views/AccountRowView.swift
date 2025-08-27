import SwiftUI

struct AccountRowView: View {
    let account: Account
    @EnvironmentObject var totpService: TOTPService
    @EnvironmentObject var totpGenerator: TOTPGenerator
    @State private var currentCode: TOTPCode?
    @State private var isHovering = false
    @State private var showCopiedFeedback = false
    
    var serviceIcon: String {
        let service = account.serviceName.lowercased()
        if service.contains("google") { return "g.circle.fill" }
        if service.contains("github") { return "chevron.left.forwardslash.chevron.right" }
        if service.contains("microsoft") { return "m.square.fill" }
        if service.contains("apple") { return "apple.logo" }
        if service.contains("facebook") || service.contains("meta") { return "f.circle.fill" }
        if service.contains("twitter") || service.contains("x") { return "x.circle.fill" }
        return "shield.fill"
    }
    
    var serviceColor: Color {
        let service = account.serviceName.lowercased()
        if service.contains("google") { return .blue }
        if service.contains("github") { return .purple }
        if service.contains("microsoft") { return .green }
        if service.contains("apple") { return .primary }
        if service.contains("facebook") || service.contains("meta") { return .blue }
        if service.contains("twitter") || service.contains("x") { return .cyan }
        return .orange
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(serviceColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: serviceIcon)
                    .font(.title2)
                    .foregroundColor(serviceColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.issuer ?? account.serviceName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(account.username)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let code = currentCode {
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 12) {
                        Text(formattedCode(code.code))
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .foregroundColor(code.isExpiringSoon ? .red : .primary)
                            .animation(.easeInOut(duration: 0.3), value: code.isExpiringSoon)
                        
                        Button(action: {
                            copyCode(code.code)
                        }) {
                            ZStack {
                                Image(systemName: showCopiedFeedback ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(showCopiedFeedback ? .green : .secondary)
                                    .symbolRenderingMode(.hierarchical)
                                    .animation(.spring(response: 0.3), value: showCopiedFeedback)
                            }
                        }
                        .buttonStyle(.plain)
                        .help(showCopiedFeedback ? "Copied!" : "Copy code")
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(code.isExpiringSoon ? Color.red : Color.accentColor)
                            .frame(width: 120 * code.progress, height: 6)
                            .animation(.linear(duration: 1), value: code.progress)
                    }
                    .frame(width: 120)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovering ? Color(NSColor.controlBackgroundColor) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovering ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                .animation(.easeInOut(duration: 0.2), value: isHovering)
        )
        .onHover { hovering in
            isHovering = hovering
        }
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
        guard code.count == 6 else { return code }
        let index = code.index(code.startIndex, offsetBy: 3)
        let firstPart = String(code[..<index])
        let secondPart = String(code[index...])
        return "\(firstPart) \(secondPart)"
    }
    
    private func copyCode(_ code: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(code, forType: .string)
        
        withAnimation {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedFeedback = false
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(Account.sampleAccounts) { account in
            AccountRowView(account: account)
        }
    }
    .environmentObject(TOTPService())
    .environmentObject(TOTPGenerator())
    .padding()
    .frame(width: 500)
    .background(Color(NSColor.windowBackgroundColor))
}