import SwiftUI

struct CredentialView: View {
    
    @ObservedObject var model: ViewModel = ViewModel()
    
    var body: some View {
        VStack {
            ScrollView() {
                Group {
                    updateStatusButton()
                }
            }
            Spacer()
        }
    }
    
    fileprivate func updateStatusButton() -> some View {
        return Button(action: model.credentialsStatusUpdate) {
            Image(systemName:"arrow.2.circlepath.circle.fill")
        }.buttonStyle(.bordered)
    }

    fileprivate func credentialItemList() -> some View {
        return VStack {
            ForEach(Array(self.model.credentials.keys), id: \.self) { id in
                credentialItemView(id:id)
            }
        }
    }

    fileprivate func credentialItemView(id:String) -> some View {
        return HStack {

        }
    }
}

struct CredentialView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialView()
    }
}
