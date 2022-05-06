import SwiftUI

@main
struct Alice_WalletApp: App {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            if model.walletOpened {
                ContentView(model:model)
            } else {
                OnboardingFlowView(model:model)
            }
        }
    }
}
