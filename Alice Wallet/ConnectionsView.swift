import SwiftUI
import CodeScanner_Rownd

struct ConnectionsView: View {
    
    @EnvironmentObject var model: VcxModel
    @FocusState var invitationSettingsIsFocused: Bool
    @FocusState var messageEditorIsFocused: Bool
    
    @State var isShowingScanner = false
    
    var body: some View {
        VStack {
            ScrollView() {
                Group {
                    HStack{
                        scanQrCodeButton()
                    }
                    invitationSettings()
                    HStack{
                        receiveInvitationButton()
                        updateStatusButton()
                    }

                    connectionItemList()
                    messageEditor()
                }
            }
            Spacer()
        }.sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr],
                            simulatedData: "https://some.endpoint.url?c_i=Base64EncodedInvitationURL==",
                            completion: self.handleQrCodeScan)
        }
    }
    
    func scanQrCodeButton() -> some View {
        return Button(action: {
            isShowingScanner = true
        }) {
            Image(systemName:"qrcode.viewfinder")
        }.buttonStyle(.bordered)
    }
    
    func invitationSettings() -> some View {
        return Group {
            TextEditor(text: $model.invitation.code)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                .border(Color.gray)
                .textFieldStyle(.roundedBorder)
                .focused($invitationSettingsIsFocused)
        }
    }
    
    func receiveInvitationButton() -> some View {
        return Button(action: {
            self.invitationSettingsIsFocused = false
            model.receiveInvitation()
        }) {
            Image(systemName:"arrow.down.to.line")
        }.buttonStyle(.bordered)
    }
    
    func updateStatusButton() -> some View {
        return Button(action: model.connectionStatusUpdate) {
            Image(systemName:"arrow.2.circlepath.circle.fill")
        }.buttonStyle(.bordered)
    }
    
    func connectionItemList() -> some View {
        return VStack {
            ForEach(Array(self.model.connections.keys), id: \.self) { id in
                connectionItemView(id:id)
            }
        }
    }
    
    func connectionItemView(id:String) -> some View {
        return HStack {
            let c = self.model.connections[id]!
            let color: Color = c.status.color()
            let icon: String = c.status.icon()
            Button(action: {model.connectionToggleSelection(id:id)}){
                Image(systemName: icon)
            }.buttonStyle(.bordered)
            Button(action: {model.connectionStatusGet(id:id)}){
                Text("\(id)")
            }.buttonStyle(.bordered)
             .background(color)
             .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30)
            Button(action: {model.connectionNextStep(id:id)}){
                Image(systemName:"phone.fill.arrow.right")
            }.buttonStyle(.bordered)
            Button(action: {
                self.messageEditorIsFocused = false
                model.connectionSendMessage(id:id)
            }){
                Image(systemName:"ellipses.bubble")
            }.buttonStyle(.bordered)
            Button(action: {
                self.messageEditorIsFocused = false
                model.credentialGetOffers(id:id)
            }){
                Image(systemName:"doc.richtext")
            }.buttonStyle(.bordered)
        }
    }
    
    func messageEditor() -> some View {
        return Group {
            TextEditor(text: $model.message)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                .border(Color.gray)
                .textFieldStyle(.roundedBorder)
                .focused($messageEditorIsFocused)
        }
    }
    
    func handleQrCodeScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let code = result.string
            print("scanning done: \(code)")
            model.invitation.code = code
        case .failure(let error):
            print("scanning failed: \(error.localizedDescription)")
        }
    }
}
