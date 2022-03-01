import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some View {
        TabView {
            WalletView(model:model)
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Wallet")
                }
            LedgerView(model:model)
                .tabItem {
                    Image(systemName: "globe")
                    Text("Ledger")
                }
            AgencyView(model:model)
                .tabItem {
                    Image(systemName: "link.icloud")
                    Text("Agency")
                }
            ConnectionsView(model:model)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Connections")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model:ViewModel())
    }
}
