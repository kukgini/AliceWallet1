import SwiftUI

struct LedgerView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    @FocusState var genesisTxSettingsIsFocused: Bool
    
    var body: some View {
        ScrollView() {
            VStack {
                Group {
                    genesisTxSettings()
                    openMainPoolButton()
                }
            }
            Spacer()
        }
    }
    
    fileprivate func genesisTxSettings() -> some View {
        TextEditor(text: $model.genesisTransaction)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 500, maxHeight: 500)
            .border(Color.gray)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.default)
            .focused($genesisTxSettingsIsFocused)
    }
    
    fileprivate func openMainPoolButton() -> some View {
        return Button(action: {
            self.genesisTxSettingsIsFocused = false
            model.openMainPool()
        }) {
            Text("Open Main Pool")
        }.buttonStyle(.bordered)
    }
}

struct LedgerView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerView()
    }
}
