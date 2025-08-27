import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var totpService: TOTPService
    @State private var selectedAccount: Account?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(totpService.accounts) { account in
                    AccountRowView(account: account)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedAccount?.id == account.id ? Color.accentColor.opacity(0.1) : Color.clear)
                        )
                        .onTapGesture {
                            selectedAccount = account
                        }
                        .contextMenu {
                            Button("Copy Code") {
                                if let code = totpService.getCurrentCode(for: account) {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.declareTypes([.string], owner: nil)
                                    pasteboard.setString(code.code, forType: .string)
                                }
                            }
                            
                            Button("Refresh Code") {
                                _ = totpService.refreshCode(for: account)
                            }
                            
                            Divider()
                            
                            Button("Delete Account", role: .destructive) {
                                _ = totpService.deleteAccount(account)
                            }
                        }
                }
            }
            .padding()
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
        .frame(width: 400, height: 500)
}