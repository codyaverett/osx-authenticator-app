import SwiftUI

struct ContentView: View {
    @EnvironmentObject var totpService: TOTPService
    @State private var showingAddAccount = false
    @State private var searchText = ""
    
    var filteredAccounts: [Account] {
        if searchText.isEmpty {
            return totpService.accounts
        } else {
            return totpService.accounts.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView(showingAddAccount: $showingAddAccount, searchText: $searchText)
                
                if totpService.accounts.isEmpty {
                    EmptyStateView(showingAddAccount: $showingAddAccount)
                } else {
                    AccountListView(accounts: filteredAccounts)
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 480, idealWidth: 520, minHeight: 600, idealHeight: 700)
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
    }
}

struct HeaderView: View {
    @Binding var showingAddAccount: Bool
    @Binding var searchText: String
    @EnvironmentObject var totpService: TOTPService
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundStyle(.linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("Authenticator")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text("\(totpService.accounts.count) account\(totpService.accounts.count == 1 ? "" : "s")")
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showingAddAccount = true
                }) {
                    Label("Add Account", systemImage: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            if !totpService.accounts.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search accounts...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
        }
        .background(.ultraThinMaterial)
    }
}

struct EmptyStateView: View {
    @Binding var showingAddAccount: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.linearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.shield")
                    .font(.system(size: 56))
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            
            VStack(spacing: 12) {
                Text("Welcome to Authenticator")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Keep your accounts secure with two-factor authentication")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    showingAddAccount = true
                }) {
                    Label("Add Your First Account", systemImage: "plus.circle.fill")
                        .frame(width: 220)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("Import from Google Authenticator or add manually")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .environmentObject(TOTPService())
        .environmentObject(TOTPGenerator())
}