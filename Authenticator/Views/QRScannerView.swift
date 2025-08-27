import SwiftUI

struct QRScannerView: View {
    let onResult: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var pastedText = ""
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderSection
            
            ScrollView {
                VStack(spacing: 32) {
                    IllustrationSection
                    InstructionsSection
                    InputSection
                    ActionSection
                }
                .padding(32)
            }
        }
        .frame(width: 640, height: 580)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var HeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Import QR Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Transfer your 2FA accounts from Google Authenticator")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
    }
    
    private var IllustrationSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 140)
            
            HStack(spacing: 32) {
                Image(systemName: "qrcode")
                    .font(.system(size: 56))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
    }
    
    private var InstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("How to import:", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(number: "1", text: "Open Google Authenticator on your device")
                InstructionRow(number: "2", text: "Tap the menu (⋮) and select \"Transfer accounts\"")
                InstructionRow(number: "3", text: "Choose \"Export accounts\" and select the accounts")
                InstructionRow(number: "4", text: "A QR code will appear - tap and hold to copy its content")
                InstructionRow(number: "5", text: "Paste the copied URL below (starts with otpauth://)")
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var InputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("QR Code Content", systemImage: "text.badge.plus")
                .font(.headline)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $pastedText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor.opacity(pastedText.isEmpty ? 0 : 0.5), lineWidth: 1)
                    )
                
                if pastedText.isEmpty {
                    Text("Paste the otpauth:// URL here...")
                        .foregroundColor(.secondary)
                        .padding(12)
                        .allowsHitTesting(false)
                }
            }
            
            Text("The URL should start with 'otpauth://totp/' or 'otpauth-migration://'")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var ActionSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                pastedText = "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"
            }) {
                Label("Use Sample", systemImage: "doc.text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button(action: {
                handlePastedContent()
            }) {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Import Account", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
        }
    }
    
    private func handlePastedContent() {
        let content = pastedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        withAnimation {
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isProcessing = false
            }
            
            if QRCodeParser.isValidOTPAuthURL(content) {
                onResult(content)
                presentationMode.wrappedValue.dismiss()
            } else {
                alertMessage = "Invalid QR code content. Please ensure you've copied the complete otpauth:// URL from Google Authenticator."
                showingAlert = true
            }
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text(number)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.accentColor)
            }
            
            Text(text)
                .font(.callout)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    QRScannerView { result in
        print("Imported: \(result)")
    }
}