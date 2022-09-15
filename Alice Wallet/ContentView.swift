import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ConnectionsView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Connections")
                }
            CredentialView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Credentials")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
