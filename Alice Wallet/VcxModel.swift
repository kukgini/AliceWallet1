import Foundation
import LocalAuthentication
import SwiftyJSON
import vcx
import SwiftUI
import Alamofire

public enum ConnectionStatus: NSNumber {
    case initialized = 1
    case request_sent = 2
    case offer_received = 3
    case accepted = 4
    
    func description() -> String {
        switch self {
        case .initialized:
            return "Initialzied"
        case .request_sent:
            return "Request Sent"
        case .offer_received:
            return "Offer Received"
        case .accepted:
            return "Accepted"
        }
    }
    
    func color() -> Color {
        switch self {
        case .initialized:
            return Color.white
        case .request_sent:
            return Color.yellow
        case .offer_received:
            return Color.blue
        case .accepted:
            return Color.green
        }
    }
    
    func icon() -> String {
        switch self {
        case .initialized:
            return "icloud"
        case .request_sent:
            return "icloud"
        case .offer_received:
            return "icloud"
        case .accepted:
            return "link.icloud.fill"
        }
    }
}

public enum CredentialStatus: NSNumber {
    case initialized = 1
    case request_sent = 2
    case offer_received = 3
    case accepted = 4
    
    func description() -> String {
        switch self {
        case .initialized:
            return "Initialzied"
        case .request_sent:
            return "Request Sent"
        case .offer_received:
            return "Offer Received"
        case .accepted:
            return "Accepted"
        }
    }
    
    func color() -> Color {
        switch self {
        case .initialized:
            return Color.white
        case .request_sent:
            return Color.yellow
        case .offer_received:
            return Color.blue
        case .accepted:
            return Color.green
        }
    }
    
    func icon() -> String {
        switch self {
        case .initialized:
            return "icloud"
        case .request_sent:
            return "icloud"
        case .offer_received:
            return "icloud"
        case .accepted:
            return "link.icloud.fill"
        }
    }
}

class VcxModel : ObservableObject {

    static let walletId = "MyWallet"
    static let walletKey = "MySecretPassword"
    static let walletKeyDerivationFunction = "ARGON2I_MOD"
    
    let vcx: VcxAdaptor
    let walletConfig: String
    
    @Published var networks: [URL] = []

    let agencyConfig = JSON([
        "agency_endpoint": "https://ariesvcx.agency.staging.absa.id",
        "agency_did": "VsKV7grR1BUE29mG2Fm2kX",
        "agency_verkey": "Hezce2UWMZ3wUhVkh2LfKSs8nDzWwzs2Win7EzNN3YaR"
    ])
    var agencyClientConfig: JSON?
    
    @Published var inviteDetails = ""
    @Published var connections: [String:(
        handle:NSNumber,
        status:ConnectionStatus,
        inviteDetails:JSON,
        selected:Bool)] = [:]
    @Published var message = ""
    @Published var credentials: [NSNumber:NSNumber] = [:]
    
    init() {
        self.walletConfig = JSON([
            "wallet_name": VcxModel.walletId,
            "wallet_key": VcxModel.walletKey,
            "wallet_key_derivation": VcxModel.walletKeyDerivationFunction
        ]).rawString([.encoding:String.Encoding.utf8])!
        self.vcx = VcxAdaptor()
        self.checkWalletExists()
        self.loadNetworks()
        self.agencyClientConfig = JSON(UserDefaults.standard.string(forKey:"agencyClientConfig"))
        if let _ = self.agencyClientConfig {
            agencyProvisioned = true
        }
    }
    
    @Published var walletExists = false
    @Published var walletOpened = false
    @Published var poolOpened = false
    @Published var agencyProvisioned = false
    @Published var agencyClientCreated = false
    
    func onboardingCompleted() -> Bool {
        return walletOpened && poolOpened && agencyProvisioned && agencyClientCreated
    }
    
    func checkWalletExists() {
        if let urls = vcx.getWallets() {
            for url in urls {
                let name = url.lastPathComponent
                if name == VcxModel.walletId { walletExists = true }
            }
        }
    }
    
    func resetWallet() {
        self.vcx.removeAllWallets()
        self.createWallet()
        self.checkWalletExists()
    }
    
    func createWallet() {
        print("create wallet. config=", self.walletConfig)
        self.vcx.createWallet(config:self.walletConfig, completion:{ error in
            if error != nil && error!._code > 0 {
                print("create wallet failed: ", error!.localizedDescription)
            } else {
                print("create wallet success.")
            }
        })
    }
    
    func openWallet() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason:"지갑을 열겠습니다.") {
            [weak self] (res, err) in
            DispatchQueue.main.async {
                print("wallet open approved.")
                print("open wallet. config=", self!.walletConfig)
                self!.vcx.openMainWallet(config:self!.walletConfig, completion:{ error, handle in
                    if error != nil && error!._code > 0 {
                        print("open wallet failed. handle=\(handle!), error=\(error!.localizedDescription)")
                    } else {
                        print("open wallet success. handle=\(handle!)")
                        self!.walletOpened = true
                    }
                })
            }
        }
    }
    
    func loadNetworks() {
        self.networks = self.vcx.listNetworkTxURLs()
        print("networks:")
        for (index, url) in self.networks.enumerated() {
            let networkName = url.lastPathComponent
            print("\t* [\(index)] \(networkName)")
        }
    }
    
    func openMainPool(name:String) {
        let url = Bundle.main.url(forResource:"Networks/\(name)", withExtension: "json")!
        let config = """
        {
            "genesis_path": "\(url.path)",
            "pool_name": "\(name)"
        }
        """
        print("open main pool. config=\n", config)
        self.vcx.vcxOpenMainPool(config:config, completion:{ error in
            if error != nil && error!._code > 0 {
                print("open main pool failed. error=", error!.localizedDescription)
            } else {
                print("open main pool successed.")
                self.poolOpened = true
            }
        })
    }

    func provisionCloudAgent() {
        print("provision cloud agent. config=\(self.agencyConfig)")
        self.vcx.vcxProvisionCloudAgent(config: self.agencyConfig.rawString()!, completion: { error, result in
            if error != nil && error!._code > 0 {
                print("provision cloud agent failed. error=", error!.localizedDescription)
            } else {
                print("provision cloud agent successed.")
                var newAgencyClientConfig = try! JSON(data: result!.data(using: .utf8)!)
                try! newAgencyClientConfig.merge(with: self.agencyConfig)
                print("agency client=\(newAgencyClientConfig)")
                
                UserDefaults.standard.set(newAgencyClientConfig.rawString(), forKey: "agencyClientConfig")
                self.agencyProvisioned = true
            }
        })
    }
    
    func createAgencyClientForMainWallet() {
        print("create agency client for main wallet. config=\(self.agencyClientConfig)")
        self.vcx.vcxCreateAgencyClient(forMainWallet: self.agencyClientConfig!.rawString(), completion: { error in
            if error != nil && error!._code > 0 {
                print("provision cloud agent failed. error=", error!.localizedDescription)
            } else {
                print("provision cloud agent successed.")
                self.agencyClientCreated = true
            }
        })
    }
    
    func getConnectionHandle(id:String) -> NSNumber {
        return self.connections[id]!.handle
    }
    
    func receiveInvitation() {
        // url encoded invitation 형식일 경우 ?c_i= 이후의 값을 base64 인코딩 하면 json invitation 이 나옴
        let json = try! JSON(data: inviteDetails.data(using: .utf8)!)
        let id = json["@id"].string!
        print("receive invitation. id=\(id), detail=\(inviteDetails)")
        self.connectionCreate(id:id,invitateDetails:json)
    }
    
    func connectionNextStep(id:String) {
        let c = self.connections[id]!
        print("connection handle=\(c.handle) id=\(id) status=\(c.status.rawValue.description)")
        switch c.status {
        case .initialized:
            print("connection next step is connect.")
            connectionConnect(id: id)
        case .request_sent:
            print("waiting to be accepted")
        case .offer_received:
            print("waiting to be accepted")
        case .accepted:
            print("waiting to be accepted")
        }
        self.connectionStatusUpdate()
    }
    
    func connectionCreate(id:String,invitateDetails:JSON) {
        print("connection create. id=\(id), inviteDetails=\(invitateDetails)")
        self.vcx.connectionCreate(
            withInvite: id,
            inviteDetails: inviteDetails,
            completion: { error, handle in
                if error != nil && error!._code > 0 {
                    print("connection create failed. error=", error!.localizedDescription)
                } else {
                    print("connection create successed. handle=", handle!)
                    self.connections[id] = (
                        handle:handle!,
                        status:ConnectionStatus.initialized,
                        inviteDetails:invitateDetails,
                        selected: false
                    )
                }
        })
    }
    
    func connectionConnect(id:String) {
        let c = connections[id]!
        let connectionType = "{\"use_public_did\":false}"
        print("connection connect. id=\(id), handle=\(c.handle), connectionType=\(connectionType)")
        self.vcx.connectionConnect(
            withHandle:c.handle,
            connectionType:connectionType,
            completion: { error in
                if error != nil && error!._code > 0 {
                    print("connection connect failed. error=", error!.localizedDescription)
                } else {
                    print("connection connect successed.")
                }
            }
        )
    }
    
    func connectionStatusGet(id:String) {
        let c = connections[id]!
        self.vcx.connectionGetState(
            withHandle: c.handle,
            completion: { error, status in
                if error != nil && error!._code > 0 {
                    print("connection create failed. error=\(error!.localizedDescription)")
                } else {
                    print("connection create successed. id=\(id), handle=\(c.handle), status=\(status!)")
                    self.connections[id] = (
                        handle: c.handle,
                        status: ConnectionStatus(rawValue:status!)!,
                        inviteDetails: c.inviteDetails,
                        selected: c.selected
                    )
                }
            }
        )
    }
    
    func connectionStatusUpdate() {
        for (id, c) in connections {
            print("connection status update. id=\(id), handle=\(c.handle), statue=\(c.status)")
            self.vcx.connectionUpdateState(
                withHandle:c.handle,
                completion: {error, status in
                    if error != nil && error!._code > 0 {
                        print("connection status update failed. error=", error!.localizedDescription)
                    } else {
                        print("connection status update successed. status=", status!)
                        self.connections[id] = (
                            handle:c.handle,
                            status:ConnectionStatus(rawValue:status!)!,
                            inviteDetails: c.inviteDetails,
                            selected: false
                        )
                    }
            })
        }
    }
    
    func credentialsStatusUpdate() {
        self.connectionStatusUpdate()
        for (id, c) in connections {
            self.vcx.credentialGetOffers(
                withHandle:c.handle,
                completion:{error, offers in
                    if error != nil && error!._code > 0 {
                        print("get credential offers for connection id=\(id) failed. error=", error!.localizedDescription)
                    } else {
                        print("get credential offers for connection id=\(id) successed.")
                        let offer = offers?.dropFirst().dropLast()
                        self.vcx.credentialCreateWithOffer(
                            sourceId:id,
                            offer:String(offer!),
                            completion: { error, credentialHandle in
                                if error != nil && error!._code > 0 {
                                    print("create credential with offer failed. error=", error!.localizedDescription)
                                } else {
                                    print("create credential with offer successed. credentialHandle=", credentialHandle!)
                                    self.credentials[credentialHandle!] = c.handle
                                    self.vcx.credentialSendRequest(
                                        credentialHandle: credentialHandle!,
                                        connectionHandle: c.handle,
                                        completion: { error in
                                            if error != nil && error!._code > 0 {
                                                print("credential request failed. error=", error!.localizedDescription)
                                            } else {
                                                print("credential request successed.")
                                            }
                                        }
                                    )
                                }
                            }
                        )
                    }
                }
            )
        }
        for (credentialHandle, connectionHandle) in credentials {
            self.vcx.credentialUpdateStateV2(
                credentialHandle: credentialHandle,
                connectionHandle: connectionHandle,
                completion: { error, status in
                    if error != nil && error!._code > 0 {
                        print("credential update state failed. error=", error!.localizedDescription)
                    } else {
                        print("credential update state successed. credentialHandle=\(credentialHandle) connectionHandle=\(connectionHandle) statue=\(status!)")
                        if status! == CredentialStatus.accepted.rawValue {
                            self.vcx.getCredential(
                                credentialHandle: credentialHandle,
                                completion: { error, credential in
                                    if error != nil && error!._code > 0 {
                                        print("get credential failed. error=", error!.localizedDescription)
                                    } else {
                                        print("get credential successed. credential=\(credential!)")
                                    }
                                }
                            )
                        }
                    }
                }
            )
        }
    }
    
    func connectionToggleSelection(id:String) {
        let c = self.connections[id]!
        self.connections[id] = (
            handle: c.handle,
            status: c.status,
            inviteDetails: c.inviteDetails,
            selected: !c.selected
        )
    }
    
    func connectionIsSelected(id:String) -> Bool {
        return self.connections[id]!.selected
    }
    
    func connectionSendMessage(id:String) {
        let c = self.connections[id]!
        print("connection send message. id=\(id), handle=\(c.handle), statue=\(c.status)")
        self.vcx.connectionSendBasicMessage(
            withHandle:c.handle,
            message: self.message,
            options: "",
            completion: {error, status in
                if error != nil && error!._code > 0 {
                    print("connection send message failed. error=", error!.localizedDescription)
                } else {
                    print("connection send message successed. status=", status!)
                }
        })
    }
    
    func credentialGetOffers(id:String) {
        let c = self.connections[id]!
        print("credential get offers in connection. id=\(id)")
        self.vcx.credentialGetOffers(
            withHandle:c.handle,
            completion: {error, offers in
                if error != nil && error!._code > 0 {
                    print("credential get offers failed. error=", error!.localizedDescription)
                } else {
                    for offer in offers! {
                        print("connection=\(id) offer=\(offer)")
                    }
                }
        })
    }
    
}
