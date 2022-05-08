import SwiftUI

struct LedgerView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    @FocusState var genesisTxSettingsIsFocused: Bool
    @State private var showingAlert = false
    
    var body: some View {
        //VStack {
            Group {
                List {
                    ForEach(self.model.networks, id: \.self) { txURL in
                        let txName = txURL.deletingPathExtension().lastPathComponent
                        Button(action: { showingAlert = true }) {
                            Text("\(txName)")
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Open pool"),
                                message: Text("open pool \(txName)"),
                                primaryButton: .destructive(Text("Open"), action: {
                                    model.openMainPool(name: txName)
                                }),
                                secondaryButton: .cancel())
                        }
                    }
                }
            }
        //}
    }
}

struct LedgerView_Previews: PreviewProvider {
    static var previews: some View {
        LedgerView()
    }
}
