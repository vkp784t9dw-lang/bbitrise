import SwiftUI


struct SplashScreenView : View {
    var body: some View {
        
        ZStack {
            AnimatedBackground()
            
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        
    }
}
