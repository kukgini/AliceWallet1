import SwiftUI

struct LedgerView: View {
    
    @EnvironmentObject var model: VcxModel
    @FocusState var genesisTxSettingsIsFocused: Bool
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            ForEach(self.model.networks, id: \.self) { url in
                let genesisPath = url.deletingPathExtension().lastPathComponent
                HStack {
                    if self.model.poolOpened {
                        Image(systemName:"lock.open")
                        Button(action: { self.model.openMainPool(name: genesisPath) }) {
                            Text("Opened \(genesisPath)")
                        }
                    } else {
                        Image(systemName:"lock")
                        Button(action: { self.model.openMainPool(name: genesisPath) }) {
                            Text("Open \(genesisPath)")
                        }
                    }
                }
            }
        }
    }
}

struct LedgerView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerView()
    }
}
