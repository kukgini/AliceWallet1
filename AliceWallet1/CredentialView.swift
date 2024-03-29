import SwiftUI

struct CredentialView: View {
    
    @EnvironmentObject var model: VcxModel
    
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
    
    func updateStatusButton() -> some View {
        return Button(action: model.credentialsStatusUpdate) {
            Image(systemName:"arrow.2.circlepath.circle.fill")
        }.buttonStyle(.bordered)
    }

    func credentialItemList() -> some View {
        return VStack {
            ForEach(Array(self.model.credentials.keys), id: \.self) { id in
                credentialItemView(id:id)
            }
        }
    }

    func credentialItemView(id:NSNumber) -> some View {
        return HStack {

        }
    }
}

struct CredentialView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialView()
    }
}
