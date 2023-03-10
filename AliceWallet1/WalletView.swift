import SwiftUI
import SwiftyJSON

struct WalletView: View {
    
    @EnvironmentObject var model: VcxModel

    var body: some View {
        VStack {
            if self.model.walletExists {
                if self.model.walletOpened {
                    HStack {
                        Image(systemName:"lock.open")
                        Text("Wallet Opened")
                    }
                } else {
                    Button(action: { self.model.openWallet() }) {
                        HStack {
                            Image(systemName:"lock")
                            Text("Open Wallet")
                        }
                    }
                }
            } else {
                Button(action: { self.model.resetWallet() }) {
                    Image(systemName:"qrcode.viewfinder")
                    Text("Create Wallet")
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView().environmentObject(MockVcxModel())
    }
}
