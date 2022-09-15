import Foundation
import SwiftyJSON
import vcx
import SwiftUI
import Alamofire

class MockModel : ObservableObject {

    @Published var wallets: [String] = ["Wallet1","Wallet2"]
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
    
    @Published var walletOpened = false
    @Published var poolOpened = false
    @Published var agencyProvisioned = false
    @Published var agencyClientCreated = false
    
    func onboardingCompleted() -> Bool {
        return false
    }
    

    
}
