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
    @State private var showAdvanced = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderSection
            
            ScrollView {
                VStack(spacing: 24) {
                    MethodPickerSection
                    
                    if selectedTab == 0 {
                        ManualEntrySection
                    } else {
                        QRImportSection
                    }
                }
                .padding(24)
            }
            
            FooterSection
        }
        .frame(width: 580, height: 680)
        .background(Color(NSColor.windowBackgroundColor))
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
    
    private var HeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add New Account")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Set up two-factor authentication for a new service")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .background(.ultraThinMaterial)
    }
    
    private var FooterSection: some View {
        HStack {
            Spacer()
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button("Add Account") {
                addAccount()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!isFormValid)
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
    
    private var MethodPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Setup Method")
                .font(.headline)
            
            HStack(spacing: 12) {
                MethodCard(
                    title: "Manual Entry",
                    icon: "keyboard",
                    isSelected: selectedTab == 0
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 0
                    }
                }
                
                MethodCard(
                    title: "Import QR Code",
                    icon: "qrcode",
                    isSelected: selectedTab == 1
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = 1
                    }
                }
            }
        }
    }
    
    private var ManualEntrySection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                FormField(
                    label: "Service Name",
                    placeholder: "e.g., GitHub",
                    text: $serviceName,
                    icon: "building.2"
                )
                
                FormField(
                    label: "Username / Email",
                    placeholder: "e.g., john@example.com",
                    text: $username,
                    icon: "person.circle"
                )
                
                FormField(
                    label: "Secret Key",
                    placeholder: "e.g., JBSWY3DPEHPK3PXP",
                    text: $secretKey,
                    icon: "key.fill",
                    isSecure: true
                )
                
                FormField(
                    label: "Issuer (Optional)",
                    placeholder: "e.g., Google",
                    text: $issuer,
                    icon: "tag"
                )
            }
            
            DisclosureGroup(isExpanded: $showAdvanced) {
                VStack(spacing: 16) {
                    HStack {
                        Label("Algorithm", systemImage: "lock.shield")
                            .frame(width: 120, alignment: .leading)
                        
                        Picker("", selection: $algorithm) {
                            ForEach(TOTPAlgorithm.allCases, id: \.self) { algo in
                                Text(algo.displayName).tag(algo)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Label("Code Length", systemImage: "number.circle")
                            .frame(width: 120, alignment: .leading)
                        
                        Picker("", selection: $digits) {
                            Text("6 digits").tag(6)
                            Text("8 digits").tag(8)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    
                    HStack {
                        Label("Period", systemImage: "clock")
                            .frame(width: 120, alignment: .leading)
                        
                        TextField("30", value: $period, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        
                        Text("seconds")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 12)
            } label: {
                Label("Advanced Settings", systemImage: showAdvanced ? "chevron.down" : "chevron.right")
                    .foregroundColor(.accentColor)
                    .font(.callout.weight(.medium))
            }
            .padding(.top, 8)
        }
    }
    
    private var QRImportSection: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(height: 200)
                
                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    
                    Text("Import from QR Code")
                        .font(.headline)
                    
                    Text("Copy the QR code content from Google Authenticator")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Open QR Input") {
                        showingScanner = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            if !serviceName.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Imported Account", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Service:")
                                    .foregroundColor(.secondary)
                                Text(serviceName)
                                    .fontWeight(.medium)
                            }
                            HStack {
                                Text("Username:")
                                    .foregroundColor(.secondary)
                                Text(username)
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
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

struct MethodCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.callout.weight(.medium))
                .foregroundColor(.secondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview {
    AddAccountView()
        .environmentObject(TOTPService())
}