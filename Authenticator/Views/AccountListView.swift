import SwiftUI

struct AccountListView: View {
    let accounts: [Account]
    @EnvironmentObject var totpService: TOTPService
    @State private var selectedAccount: Account?
    @State private var accountToDelete: Account?
    @State private var showingDeleteAlert = false
    
    init(accounts: [Account]? = nil) {
        self.accounts = accounts ?? []
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(accounts.isEmpty ? totpService.accounts : accounts) { account in
                    AccountRowView(account: account)
                        .contextMenu {
                            Button(action: {
                                if let code = totpService.getCurrentCode(for: account) {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.declareTypes([.string], owner: nil)
                                    pasteboard.setString(code.code, forType: .string)
                                }
                            }) {
                                Label("Copy Code", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: {
                                _ = totpService.refreshCode(for: account)
                            }) {
                                Label("Refresh Code", systemImage: "arrow.clockwise")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                accountToDelete = account
                                showingDeleteAlert = true
                            }) {
                                Label("Delete Account", systemImage: "trash")
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .padding(24)
            .padding(.top, 8)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                accountToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let account = accountToDelete {
                    withAnimation(.spring(response: 0.4)) {
                        _ = totpService.deleteAccount(account)
                    }
                    accountToDelete = nil
                }
            }
        } message: {
            if let account = accountToDelete {
                Text("Are you sure you want to delete the account for \(account.displayName)? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    AccountListView()
        .environmentObject({
            let service = TOTPService()
            for account in Account.sampleAccounts {
                _ = service.addAccount(account)
            }
            return service
        }())
        .environmentObject(TOTPGenerator())
        .frame(width: 500, height: 600)
}