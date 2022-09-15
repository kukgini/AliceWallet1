import SwiftUI

struct ConnectionsView: View {
    
    @EnvironmentObject var model: VcxModel
    @FocusState var invitationSettingsIsFocused: Bool
    @FocusState var messageEditorIsFocused: Bool
    
    var body: some View {
        VStack {
            ScrollView() {
                Group {
                    invitationSettings()
                    receiveInvitationButton()
                    updateStatusButton()
                    connectionItemList()
                    messageEditor()
                }
            }
            Spacer()
        }
    }
    
    fileprivate func invitationSettings() -> some View {
        return Group {
            TextEditor(text: $model.inviteDetails)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                .border(Color.gray)
                .textFieldStyle(.roundedBorder)
                .focused($invitationSettingsIsFocused)
        }
    }
    
    fileprivate func receiveInvitationButton() -> some View {
        return Button(action: {
            self.invitationSettingsIsFocused = false
            model.receiveInvitation()
        }) {
            Image(systemName:"qrcode.viewfinder")
        }.buttonStyle(.bordered)
    }
    
    fileprivate func updateStatusButton() -> some View {
        return Button(action: model.connectionStatusUpdate) {
            Image(systemName:"arrow.2.circlepath.circle.fill")
        }.buttonStyle(.bordered)
    }
    
    fileprivate func connectionItemList() -> some View {
        return VStack {
            ForEach(Array(self.model.connections.keys), id: \.self) { id in
                connectionItemView(id:id)
            }
        }
    }
    
    fileprivate func connectionItemView(id:String) -> some View {
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
    
    fileprivate func messageEditor() -> some View {
        return Group {
            TextEditor(text: $model.message)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                .border(Color.gray)
                .textFieldStyle(.roundedBorder)
                .focused($messageEditorIsFocused)
        }
    }
}
