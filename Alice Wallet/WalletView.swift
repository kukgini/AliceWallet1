import SwiftUI
import SwiftyJSON

struct WalletView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()

    var body: some View {
        ScrollView() {
            VStack {
                Group {
                    walletSettings()
                }
                Group {
                    createWalletButton()
                    openMainWalletButton()
                }
            }
            Spacer()
        }
    }
    
    fileprivate func createWalletButton() -> some View {
        return Button(action: model.createWallet) {
            Text("Create Wallet")
        }.buttonStyle(.bordered)
    }
    
    fileprivate func openMainWalletButton() -> some View {
        return Button(action: model.openMainWallet) {
            Text("Open Main Wallet")
        }.buttonStyle(.bordered)
    }

    fileprivate func walletSettings() -> some View {
        return Group {
            TextField("Wallet Name", text:$model.walletName).textFieldStyle(.roundedBorder)
            TextField("Wallet Key", text:$model.walletKey).textFieldStyle(.roundedBorder)
            TextField("Wallet Key Derivation Function", text:$model.walletKeyDerivationFunction).textFieldStyle(.roundedBorder)
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView(model: ViewModel())
    }
}
