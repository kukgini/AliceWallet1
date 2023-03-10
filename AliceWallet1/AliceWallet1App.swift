import SwiftUI

@main
struct AliceWallet1App: App {
    @ObservedObject var model: VcxModel = VcxModel()
    
    var body: some Scene {
        WindowGroup {
            if self.model.onboardingCompleted() {
                ContentView().environmentObject(model)
            } else {
                OnboardingView().environmentObject(model)
            }
        }
    }

}
