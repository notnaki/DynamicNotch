import SwiftUI

public struct SlideText: View {
    @Binding var text: String
    var frameWidth: CGFloat
    
    var fontSize: CGFloat = 17
    var fontWeight: FontWeight = .regular
    var animationDuration: Double = 1
    var delay: Double = 0
    
    public init(text: Binding<String>, frameWidth: CGFloat, fontSize: CGFloat = 17, fontWeight: FontWeight = .regular, animationDuration: Double = 5, delay: Double = 0) {
        self._text = text
        self.frameWidth = frameWidth
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.animationDuration = animationDuration
        self.delay = delay
    }
    
    @State private var startAnimation: Bool = false
    @State private var textWidth: CGFloat = 0
    
    public var body: some View {
        GeometryReader { geometry in
            Group {
                Text(text)
                    .font(.system(size: fontSize))
                    .fontWeight(fontWeight.swiftFontWeight)
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .onAppear {
                                    textWidth = textGeometry.size.width
                                }
                                .onChange(of: text) { newText in
                                    // Update text width when the text changes
                                    DispatchQueue.main.async {
                                        textWidth = textGeometry.size.width
                                        if textWidth > frameWidth {
                                            startAnimation = true
                                        } else {
                                            startAnimation = false
                                        }
                                    }
                                }
                        }
                    )
            }
            .fixedSize()
            .frame(width: frameWidth, alignment: startAnimation ? .trailing : .leading)
            .clipped()
            .onAppear {
                if textWidth > frameWidth {
                    startAnimation = true
                }
            }
            .animation(
                textWidth > frameWidth
                    ? Animation.linear(duration: animationDuration).delay(delay).repeatForever(autoreverses: true)
                    : nil,
                value: startAnimation
            )
        }.frame(height: fontSize)
    }
}

public enum FontWeight {
    case light
    case regular
    case medium
    case bold
    case heavy
    case black
    
    var swiftFontWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}
