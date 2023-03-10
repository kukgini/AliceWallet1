import SwiftUI

struct LedgerView: View {
    
    @EnvironmentObject var model: VcxModel
    
    var body: some View {
        VStack {
            ForEach(self.model.networks, id: \.self) { url in
                let genesisPath = url.deletingPathExtension().lastPathComponent
                HStack {
                    if self.model.poolOpened {
                        Image(systemName:"lock.open")
                        Text("Opened \(genesisPath)")
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
