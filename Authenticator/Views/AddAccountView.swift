import SwiftUI

struct AddAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var totpService: TOTPService
    
    @State private var selectedTab = 0
    @State private var serviceName = ""
    @State private var username = ""
    @State private var secretKey = ""
    @State private var issuer = ""
    @State private var algorithm: TOTPAlgorithm = .sha1
    @State private var digits = 6
    @State private var period = 30
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Input Method", selection: $selectedTab) {
                    Text("Manual Entry").tag(0)
                    Text("QR Code").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    ManualEntryView()
                        .tag(0)
                    
                    QRScannerTabView()
                        .tag(1)
                }
            }
            .navigationTitle("Add Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addAccount()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 500, height: 600)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingScanner) {
            QRScannerView { result in
                handleQRResult(result)
            }
        }
    }
    
    @ViewBuilder
    private func ManualEntryView() -> some View {
        Form {
            Section("Account Details") {
                TextField("Service Name", text: $serviceName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Username/Email", text: $username)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Secret Key", text: $secretKey)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Issuer (Optional)", text: $issuer)
                    .textFieldStyle(.roundedBorder)
            }
            
            Section("Advanced Settings") {
                HStack {
                    Text("Algorithm:")
                    Spacer()
                    Picker("Algorithm", selection: $algorithm) {
                        ForEach(TOTPAlgorithm.allCases, id: \.self) { algo in
                            Text(algo.displayName).tag(algo)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                }
                
                HStack {
                    Text("Digits:")
                    Spacer()
                    Picker("Digits", selection: $digits) {
                        Text("6").tag(6)
                        Text("8").tag(8)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 80)
                }
                
                HStack {
                    Text("Period:")
                    Spacer()
                    TextField("Period", value: $period, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("seconds")
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func QRScannerTabView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Scan QR Code")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Scan a QR code from your authenticator app to automatically import account details.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button("Open Camera") {
                showingScanner = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var isFormValid: Bool {
        !serviceName.isEmpty && !username.isEmpty && !secretKey.isEmpty
    }
    
    private func addAccount() {
        let account = Account(
            serviceName: serviceName,
            username: username,
            secretKey: secretKey.replacingOccurrences(of: " ", with: "").uppercased(),
            issuer: issuer.isEmpty ? nil : issuer,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
        
        if totpService.addAccount(account) {
            presentationMode.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to add account. Please check your secret key."
            showingAlert = true
        }
    }
    
    private func handleQRResult(_ result: String) {
        if let account = QRCodeParser.parseGoogleAuthenticatorURL(result) {
            serviceName = account.serviceName
            username = account.username
            secretKey = account.secretKey
            issuer = account.issuer ?? ""
            algorithm = account.algorithm
            digits = account.digits
            period = account.period
            selectedTab = 0
        } else {
            alertMessage = "Invalid QR code. Please scan a valid authenticator QR code."
            showingAlert = true
        }
        showingScanner = false
    }
}

#Preview {
    AddAccountView()
        .environmentObject(TOTPService())
}