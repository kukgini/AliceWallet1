import SwiftUI

@main
struct Alice_WalletApp: App {
    
    let model: VcxModel = VcxModel()
    
    var body: some Scene {
        WindowGroup {
            if model.onboardingCompleted() {
                ContentView().environmentObject(model)
            } else {
                OnboardingFlowView().environmentObject(model)
            }
        }
    }
}
