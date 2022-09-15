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

    let vcx: VcxAdaptor
    let walletId = "MyWallet"
    let walletKey = "MySecretPassword"
    
    @Published var networks: [URL] = []
    
    @Published var walletKeyDerivationFunction = "ARGON2I_MOD"

    @Published var ledgerGenesisURL = "http://test.bcovrin.vonx.io/genesis"
    @Published var genesisTransaction = UserDefaults.standard.string(forKey:"GenesisTransaction") ??  ""
    
    @Published var agencyEndpoint = "https://ariesvcx.agency.staging.absa.id"
    @Published var agencyDid = "VsKV7grR1BUE29mG2Fm2kX"
    @Published var agencyVerkey = "Hezce2UWMZ3wUhVkh2LfKSs8nDzWwzs2Win7EzNN3YaR"

    @Published var remoteToSdkDid = "" // pairwise DID of this client's agent in the agency. aka, remote_to_sdk_did
    @Published var remoteToSdkVerkey = "" // verkey of this client's agent in the agency. aka, remote_to_sdk_verkey
    @Published var sdkToRemoteDid = "" // pairwise DID of this client used to communicate with it's agent in the agency. aka, sdk_to_remote_did
    @Published var sdkToRemoteVerkey = "" // verkey of this client used to commnicate with it's agent in the agency. aka, sdk_to_remote_verkey
    @Published var inviteDetails = ""
    @Published var connections: [String:(
        handle:NSNumber,
        status:ConnectionStatus,
        inviteDetails:JSON,
        selected:Bool)] = [:]
    @Published var message = ""
    @Published var credentials: [NSNumber:NSNumber] = [:]
    
    init() {
        self.vcx = VcxAdaptor()
        self.checkWalletExists()
        self.loadNetworks()
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
                if name == walletId { walletExists = true }
            }
        }
    }
    
    func resetWallet() {
        self.vcx.resetWallet()
        self.checkWalletExists()
    }
    
    func createWallet() {
        let config = JSON([
            "wallet_name": walletId,
            "wallet_key": walletKey,
            "wallet_key_derivation": self.walletKeyDerivationFunction
        ]).rawString([.encoding:String.Encoding.utf8])!
        print("create wallet. config=", config)
        self.vcx.createWallet(config:config, completion:{ error in
            if error != nil && error!._code > 0 {
                print("create wallet failed: ", error!.localizedDescription)
            } else {
                print("create wallet success.")
                self.checkWalletExists()
            }
        })
    }
    
    func openWallet() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason:"지갑을 열겠습니다.") {
            [weak self] (res, err) in
            DispatchQueue.main.async {
                print("confirmed you are you.")
            }
        }
        let config = JSON([
            "wallet_name": walletId,
            "wallet_key": walletKey,
            "wallet_key_derivation": self.walletKeyDerivationFunction
        ]).rawString([.encoding:String.Encoding.utf8])!
        print("open wallet. config=", config)
        self.vcx.openMainWallet(config:config, completion:{ error, handle in
            if error != nil && error!._code > 0 {
                print("open wallet failed. handle=\(handle), error=\(error!.localizedDescription)")
            } else {
                print("open wallet success. handle=\(handle)")
                self.walletOpened = true
            }
        })
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
        let config = """
        {
            "agency_endpoint": "\(agencyEndpoint)",
            "agency_did": "\(agencyDid)",
            "agency_verkey": "\(agencyVerkey)"
        }
        """
        print("provision cloud agent. config=", config)
        self.vcx.vcxProvisionCloudAgent(config: config, completion: { error, result in
            if error != nil && error!._code > 0 {
                print("provision cloud agent failed. error=", error!.localizedDescription)
            } else {
                print("provision cloud agent successed.")
                let json = try! JSON(data: result!.data(using: .utf8)!)
                self.remoteToSdkDid    = json["remote_to_sdk_did"].string!
                self.remoteToSdkVerkey = json["remote_to_sdk_verkey"].string!
                self.sdkToRemoteDid    = json["sdk_to_remote_did"].string!
                self.sdkToRemoteVerkey = json["sdk_to_remote_verkey"].string!
                print("json=\(json)")
                
                self.agencyProvisioned = true
            }
        })
    }
    
    func createAgencyClientForMainWallet() {
        let config = """
        {
            "agency_endpoint": "\(agencyEndpoint)",
            "agency_did": "\(agencyDid)",
            "agency_verkey": "\(agencyVerkey)",
            "remote_to_sdk_did": "\(remoteToSdkDid)",
            "remote_to_sdk_verkey": "\(remoteToSdkVerkey)",
            "sdk_to_remote_did": "\(sdkToRemoteDid)",
            "sdk_to_remote_verkey": "\(sdkToRemoteVerkey)"
        }
        """
        self.vcx.vcxCreateAgencyClient(forMainWallet: config, completion: { error in
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
