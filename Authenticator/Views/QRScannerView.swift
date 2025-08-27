import SwiftUI

struct QRScannerView: View {
    let onResult: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var pastedText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text("QR Code Scanner")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Camera scanning is not available on macOS. Please copy the QR code content and paste it below:")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste QR Code Content:")
                        .font(.headline)
                    
                    TextField("otpauth://...", text: $pastedText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                .padding(.horizontal, 40)
                
                HStack(spacing: 16) {
                    Button("Parse QR Code") {
                        handlePastedContent()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Try Sample") {
                        pastedText = "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("QR Code Input")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handlePastedContent() {
        let content = pastedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if QRCodeParser.isValidOTPAuthURL(content) {
            onResult(content)
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = "This does not appear to be a valid authenticator QR code. Please ensure you've copied the complete otpauth:// URL."
            showingAlert = true
        }
    }
}

#Preview {
    QRScannerView { result in
        print("Scanned: \(result)")
    }
}