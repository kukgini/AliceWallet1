import Foundation
import Combine
import vcx

class VcxAdaptor {
    
    static let shared = VcxAdaptor()
    static let config = """
            {
                "num_thread": 0
            }
        """
    
    var vcx: ConnectMeVcx?
    
    private init () {
        print("init VCX logger.")
        VcxLogger.setDefault(nil)
        print("create VCX wrapper instance.")
        self.vcx = ConnectMeVcx()
        _ = self.vcxInitThreadpool(config:VcxAdaptor.config)
    }

    func listWalletURLs() -> [URL] {
        let fileManager = FileManager.default
        var url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        url.appendPathComponent(".indy_client/wallet")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        var result = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil);
        if result == nil {
            result = [URL]()
        }
        return result!;
    }
    
    func createWallet(config:String, completion:((Error?) -> Void)?) {
        self.vcx!.createWallet(config, completion:completion)
    }
    
    func listNetworkTxURLs() -> [URL] {
        return Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Networks")!
    }
    
    func openMainWallet(config:String, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.openMainWallet(config, completion:completion)
    }

    func vcxInitThreadpool(config:String) -> Int {
        print("init threadpool=", config)
        return Int(self.vcx!.vcxInitThreadpool(config))
    }

    func vcxOpenMainPool(config:String, completion:((Error?) -> Void)?) {
        self.vcx!.vcxOpenMainPool(config, completion:completion)
    }
    
    func vcxProvisionCloudAgent(config:String, completion:((Error?,String?) -> Void)?) {
        self.vcx!.vcxProvisionCloudAgent(config, completion:completion)
    }
    
    func vcxCreateAgencyClient(forMainWallet:String!, completion:((Error?) -> Void)?) {
        self.vcx!.vcxCreateAgencyClient(forMainWallet:forMainWallet, completion:completion)
    }
    
    func connectionCreate(withInvite:String!, inviteDetails:String!, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.connectionCreate(withInvite:withInvite, inviteDetails:inviteDetails, completion:completion)
    }
    
    func connectionConnect(withHandle:NSNumber!, connectionType:String!, completion:((Error?) -> Void)?) {
        self.vcx!.connectionConnect(withHandle, connectionType:connectionType, completion:completion)
    }
    
    func connectionGetState(withHandle:NSNumber!, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.connectionGetState(withHandle, completion:completion)
    }
    
    func connectionUpdateState(withHandle:NSNumber!, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.connectionUpdateState(withHandle, completion:completion)
    }
    
    func connectionSerialize(withHandle:NSNumber!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.connectionSerialize(withHandle, completion:completion)
    }
    
    func connectionDeserialize(serializedConnection:String!, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.connectionDeserialize(serializedConnection, completion:completion)
    }
    
    func connectionRelease(withHandle:NSNumber!) {
        self.vcx!.connectionRelease(withHandle)
    }
    
    func connectionGetPwDid(withHandle:NSNumber!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.connectionGetPwDid(withHandle, completion:completion)
    }
    
    func connectionGetTheirPwDid(withHandle:NSNumber!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.connectionGetTheirPwDid(withHandle, completion:completion)
    }
    
    func connectionSendBasicMessage(withHandle:NSNumber!, message:String!, options:String!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.connectionSendMessage(withHandle, withMessage:message, withSendMessageOptions:options, withCompletion:completion)
    }
    
    func credentialGetOffers(withHandle:NSNumber!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.credentialGetOffers(withHandle, completion:completion)
    }
    
    func credentialCreateWithOffer(sourceId:String, offer:String, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.credentialCreate(withOffer:sourceId, offer:offer, completion:completion)
    }
    
    func credentialSendRequest(credentialHandle:NSNumber!, connectionHandle:NSNumber!, completion:((Error?) -> Void)?) {
        self.vcx!.credentialSendRequest(credentialHandle, connectionHandle:connectionHandle, paymentHandle:0, completion:completion);
    }
    
    func credentialUpdateStateV2(credentialHandle:NSNumber!, connectionHandle:NSNumber!, completion:((Error?,NSNumber?) -> Void)?) {
        self.vcx!.credentialUpdateStateV2(credentialHandle, connectionHandle:connectionHandle, completion:completion)
    }
    
    func getCredential(credentialHandle:NSNumber!, completion:((Error?,String?) -> Void)?) {
        self.vcx!.getCredential(credentialHandle, completion:completion)
    }
}
