import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraPreviewView(viewModel: cameraViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                ZStack{
                    Rectangle()
                        .frame(height: UIScreen.main.bounds.height * 0.15)
                        .foregroundColor(.black)
//                    TakePictureButton()
                }
                
            }.ignoresSafeArea()
        }
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}
#Preview {
    ContentView()
}

