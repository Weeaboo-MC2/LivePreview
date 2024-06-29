import Foundation
import WatchConnectivity
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    
    @Published var session: WCSession?
    #if os(iOS)
    @Published var previewImage: UIImage?
    #elseif os(watchOS)
    @Published var previewImage: Data?
    #endif
    
    private var lastSentTime: Date = Date()
    private let minTimeBetweenUpdates: TimeInterval = 0.1
    private var currentQuality: CGFloat = 0.01
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    #if os(iOS)
    func sendPreviewToWatch(_ image: UIImage) {
        guard let session = session, session.isReachable else { return }
        
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastSentTime) >= minTimeBetweenUpdates else { return }
        
        lastSentTime = currentTime
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let resizedImage = self.resizeImage(image, to: CGSize(width: 150, height: 150)),
               let imageData = resizedImage.jpegData(compressionQuality: self.currentQuality) {
                let message = ["previewImage": imageData]
                session.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending preview to watch: \(error.localizedDescription)")
                    
//                    if (error as NSError).domain == WCErrorDomain,
//                       (error as NSError).code == 7012 { // 7012 is the code for payloadTooLarge
//                        DispatchQueue.main.async {
//                            self.currentQuality *= 0.1 // Reduce quality by 90%
//                            self.sendPreviewToWatch(image) // Retry with lower quality
//                        }
//                    }
                }
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let imageData = message["previewImage"] as? Data {
                #if os(iOS)
                self.previewImage = UIImage(data: imageData)
                #elseif os(watchOS)
                self.previewImage = imageData
                #endif
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        WCSession.default.activate()
    }
    #endif
}
