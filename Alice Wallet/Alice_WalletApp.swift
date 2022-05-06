import SwiftUI

@main
struct Alice_WalletApp: App {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            if VcxAdaptor.shared.whenMainWalletOpened() {
                ContentView(model:model)
            } else {
                WalletView(model:model)
            }
        }
    }
}
