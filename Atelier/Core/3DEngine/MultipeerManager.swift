import MultipeerConnectivity
import Observation

@Observable
class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    static let serviceType = "atelier"
    
    #if os(iOS)
    let myPeerID = MCPeerID(displayName: "iPhone-\(UIDevice.current.name)")
    #else
    let myPeerID = MCPeerID(displayName: "Mac-Server")
    #endif
    
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    var isConnected = false
    
    var onFileReceived: ((URL) -> Void)?
    var onDataReceived: ((Data) -> Void)?

    override init() {
        super.init()

        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType)
        self.advertiser.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        self.browser.delegate = self
        
        start()
    }
    
    func start() {
        #if os(iOS)
        advertiser.startAdvertisingPeer()
        #else
        browser.startBrowsingForPeers()
        #endif
    }

    // MARK: - Send data
    
    // For small commands
    func send(msg: String) {
        guard let data = msg.data(using: .utf8), !self.session.connectedPeers.isEmpty else { return }
        try? self.session.send(
            data,
            toPeers: self.session.connectedPeers,
            with: .reliable
        )
    }
    
    // For bigger files
    func sendResource(at url: URL) {
        guard let peer = self.session.connectedPeers.first else { return }
       
        
        self.session.sendResource(at: url, withName: url.lastPathComponent, toPeer: peer) { error in
            if let error = error { print("Error send file: \(error)") }
        }
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task {
            self.isConnected = (state == .connected)
            print("Connection status \(peerID.displayName): \(state.rawValue)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        onDataReceived?(data)
    }

    // Receive file
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL = localURL, error == nil else { return }
        
        onFileReceived?(localURL)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    // MARK: - Browser / Advertiser
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
