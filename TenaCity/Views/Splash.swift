import SwiftUI

struct Splash: View {
    @State private var isActive = false

    var body: some View {
        VStack{
            ZStack {
                ForEach(0..<4) { index in
                    AnimatedHouse(index: index)
                }
                
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isActive = true
                    }
                }
                .fullScreenCover(isPresented: $isActive, content: {
                    TenaCityRoot()
                })
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            
            HStack {
                // Applying a gradient to "Tena"
                Text("Tena")
                    .font(.custom("AvenirNext-DemiBold", size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.2)]), startPoint: .leading, endPoint: .trailing)
                    )
                    .mask(Text("Tena")
                        .font(.custom("AvenirNext-DemiBold", size: 50))
                        .fontWeight(.bold)
                    )
                
                Text("City")
                    .font(.custom("AvenirNext-DemiBold", size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
        }
    }
}

struct AnimatedHouse: View {
    let index: Int
    @State private var isAnimating = false
    let randomXOffset: CGFloat
    let randomYOffset: CGFloat
    
    init(index: Int) {
        self.index = index
        self.randomXOffset = CGFloat.random(in: -200...200)
        self.randomYOffset = CGFloat.random(in: -200...200)
    }
    
    var body: some View {
        Image("TenaCityLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: isAnimating ? 300 : 0, height: isAnimating ? 300 : 0)
            .opacity(isAnimating ? 1 : 0)
            .offset(x: isAnimating ? 0 : randomXOffset, y: isAnimating ? 0 : randomYOffset)
            .animation(.easeInOut(duration: 2))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                    withAnimation {
                        self.isAnimating = true
                    }
                }
            }
    }
}


           

