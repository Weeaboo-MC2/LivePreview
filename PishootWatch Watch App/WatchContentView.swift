import SwiftUI

struct WatchContentView: View {
    @StateObject private var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        VStack {
            if let previewImageData = connectivityManager.previewImage, 
                let previewImage = UIImage(data: previewImageData) {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Waiting for preview...")
            }
        }
        .onAppear {
            connectivityManager.session?.activate()
        }
    }
}
