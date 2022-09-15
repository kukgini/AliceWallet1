import SwiftUI
import SwiftyJSON
import UIKit

// TextInput 가능한 Alert 을 띄우기 위해서 참고한 자료
// https://www.objc.io/blog/2020/04/21/swiftui-alert-with-textfield/

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: nil, preferredStyle: .alert)
        addTextField { $0.placeholder = alert.placeholder }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            alert.action(nil)
        })
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlert
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    
    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}

public struct TextAlert {
    public var title: String
    public var placeholder: String = ""
    public var accept: String = "OK"
    public var cancel: String = "Cancel"
    public var action: (String?) -> ()
}

extension View {
    public func openWalletPromptUI(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert:alert, content: self)
    }
    public func createWalletPromptUI(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert:alert, content: self)
    }
}

struct WalletView: View {
    
    @EnvironmentObject var model: VcxModel
    @State private var showOpenWalletPromptUI = false
    @State private var showCreateWalletPromptUI = false
    
    var body: some View {
        List {
            ForEach(self.model.wallets, id: \.self) { walletName in
                Button(action: { showOpenWalletPromptUI = true }) {
                    Text("\(walletName)")
                }
                .openWalletPromptUI(
                    isPresented:$showOpenWalletPromptUI,
                    TextAlert(title:"Open wallet", action:{ walletKey in self.model.openWallet(name:walletName, key:walletKey!)})
                )
            }
            Button(action: { showCreateWalletPromptUI = true }) {
                Text("Create Wallet")
            }.createWalletPromptUI(
                isPresented: $showCreateWalletPromptUI,
                TextAlert(title:"Create wallet", action:{
                    walletName in
                    self.model.createWallet(name:walletName!,key:"1234")
                    self.model.openWallet(name:walletName!, key:"1234")
                }))
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView().environmentObject(MockModel())
    }
}
