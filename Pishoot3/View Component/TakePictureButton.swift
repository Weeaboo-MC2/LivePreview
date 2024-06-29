import SwiftUI

struct TakePictureButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 65, height: 65)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 75, height: 75)
            }
        }
    }
}
