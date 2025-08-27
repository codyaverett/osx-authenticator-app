import SwiftUI

struct ContentView: View {
    @EnvironmentObject var totpService: TOTPService
    @State private var showingAddAccount = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView(showingAddAccount: $showingAddAccount)
                
                if totpService.accounts.isEmpty {
                    EmptyStateView()
                } else {
                    AccountListView()
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
    }
}

struct HeaderView: View {
    @Binding var showingAddAccount: Bool
    
    var body: some View {
        HStack {
            Text("Authenticator")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                showingAddAccount = true
            }) {
                Label("Add Account", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Accounts Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add your first 2FA account by scanning a QR code or entering details manually.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(TOTPService())
        .environmentObject(TOTPGenerator())
}