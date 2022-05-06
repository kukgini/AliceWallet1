import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some View {
        TabView {
            ConnectionsView(model:model)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Connections")
                }
            CredentialView(model:model)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Credentials")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model:ViewModel())
    }
}
