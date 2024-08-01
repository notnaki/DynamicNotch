import SwiftUI

struct PlayingWave: View {
    @Binding var isPlaying: Bool

    @State private var heights: [CGFloat] = Array(repeating: 1.5, count: 6) // Default height to 1.5 px
    @State private var delays: [Double] = Array(repeating: 0, count: 6)
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<6) { index in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1.5, height: heights[index])
                        .clipShape(RoundedRectangle(cornerRadius: 90))
                        .position(x: geometry.size.width / 2, y: (geometry.size.height - heights[index]) / 2 + heights[index] / 2)
                        .animation(
                            isPlaying ? Animation.easeInOut(duration: randomDuration()).repeatForever(autoreverses: true).delay(delays[index]) : .default,
                            value: heights
                        )
                        .onAppear {
                            if isPlaying {
                                startAnimating(index: index)
                            }
                        }
                }
                .frame(width: 1.5, height: 20) // Provide enough height for the animation
            }
        }
        .padding()
        .onChange(of: isPlaying) { newValue in
            if newValue {
                startAllAnimations()
            } else {
                stopAllAnimations()
            }
        }
    }

    private func randomDuration() -> Double {
        // Adjust min and max duration as needed
        return Double.random(in: 0.3...0.7)
    }

    private func startAnimating(index: Int) {
        let baseHeight: CGFloat = 1
        let maxHeight: CGFloat = 20
        delays[index] = Double.random(in: 0...0.5) // Randomize delay between 0 and 0.5 seconds
        
        // Set initial heights before starting animation
        heights[index] = CGFloat.random(in: baseHeight...maxHeight)
        
        withAnimation(Animation.easeInOut(duration: randomDuration()).repeatForever(autoreverses: true).delay(delays[index])) {
            heights[index] = CGFloat.random(in: baseHeight...maxHeight)
        }
    }
    
    private func startAllAnimations() {
        for index in 0..<6 {
            startAnimating(index: index)
        }
    }
    
    private func stopAllAnimations() {
        // Reset heights to 1.5 px and stop animations
        heights = Array(repeating: 1.5, count: 6)
    }
}
