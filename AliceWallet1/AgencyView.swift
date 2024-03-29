import SwiftUI

struct AgencyView: View {
    
    @EnvironmentObject var model: VcxModel
    
    var body: some View {
        VStack {
            if self.model.agencyProvisioned {
                createAgencyClientForMainWalletButton()
            } else {
                provisionCloudAgentButton()
            }
        }
    }
    
    func provisionCloudAgentButton() -> some View {
        return Button(action: model.provisionCloudAgent) {
            Image(systemName:"person.fill.questionmark")
            Text("Provision Cloud Agent")
        }.buttonStyle(.bordered)
    }
    
    func createAgencyClientForMainWalletButton() -> some View {
        return Button(action: model.createAgencyClientForMainWallet) {
            Image(systemName:"shareplay.slash")
            Text("Create Agency Client")
        }.buttonStyle(.bordered)
    }
}
