import SwiftUI

struct FlipDigitView: View {
    let value: String
    let font: Font = .system(size: 48, weight: .bold, design: .monospaced)
    
    @State private var previous: String
    @State private var progress: Double = 0 // 0→1 flip progress
    @State private var isFlipping = false // Track flip state
    
    private let halfHeight: CGFloat = 40
    private let cornerRadius: CGFloat = 4
    private let animationDuration: Double = 0.3
    
    init(value: String) {
        self.value = value
        self._previous = State(initialValue: value)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // Static bottom half of the new digit
            DigitHalf(value: value, isTop: false, halfHeight: halfHeight, cornerRadius: cornerRadius)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .zIndex(0)
            
            // Static top half (shows previous during first half, new during second)
            DigitHalf(value: progress < 0.5 ? previous : value, isTop: true, halfHeight: halfHeight, cornerRadius: cornerRadius)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: -1)
                .zIndex(1)
            
            // Flipping flap (either top half falling or bottom half rising)
            Group {
                if progress < 0.5 {
                    // Top flap falling
                    DigitHalf(value: previous, isTop: true, halfHeight: halfHeight, cornerRadius: cornerRadius)
                        .rotation3DEffect(
                            .degrees(-progress * 180),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .init(x: 0.5, y: 1), // Explicitly center anchor
                            anchorZ: 0,
                            perspective: 0.25 // Reduced perspective to minimize shift
                        )
                        .clipped() // Prevent rendering outside bounds
                        .shadow(color: .black.opacity(0.4 * (1 - progress)), radius: 4, x: 0, y: 2)
                } else {
                    // Bottom flap rising
                    DigitHalf(value: value, isTop: false, halfHeight: halfHeight, cornerRadius: cornerRadius)
                        .rotation3DEffect(
                            .degrees((1 - progress) * 180),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .init(x: 0.5, y: 0), // Explicitly center anchor
                            anchorZ: 0,
                            perspective: 0.25
                        )
                        .clipped() // Prevent rendering outside bounds
                        .shadow(color: .black.opacity(0.4 * progress), radius: 4, x: 0, y: -2)
                }
            }
            .zIndex(2)
        }
        .frame(width: 60, height: halfHeight * 2, alignment: .center)
        .clipped() // Ensure entire view stays within bounds
        .onChange(of: value) { newValue in
            guard newValue != previous, !isFlipping else { return }
            isFlipping = true
            withAnimation(.spring(response: animationDuration, dampingFraction: 0.9, blendDuration: 0.05)) {
                progress = 1
            }
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                previous = newValue
                progress = 0
                isFlipping = false
                // Optional: Trigger sound effect here
                // playSound("flip_click")
            }
        }
    }
}

private struct DigitHalf: View {
    let value: String
    let isTop: Bool
    let halfHeight: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            // Card background
            RoundedRectangle(cornerRadius: isTop ? cornerRadius : 0)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: isTop ? cornerRadius : 0)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Digit text
            Text(value)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .alignmentGuide(.top) { _ in isTop ? 0 : -.infinity }
                .alignmentGuide(.bottom) { _ in isTop ? .infinity : 0 }
        }
        .frame(width: 60, height: halfHeight, alignment: .center)
        .clipShape(
            Rectangle()
                .size(width: 60, height: halfHeight)
                .offset(y: isTop ? -halfHeight / 2 : halfHeight / 2)
        )
    }
}

// Enhanced Preview with dynamic testing
struct FlipDigitView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var number = 0
        var body: some View {
            VStack {
                FlipDigitView(value: "\(number)")
                HStack {
                    Button("Previous") {
                        number = (number - 1 + 10) % 10
                    }
                    Button("Next") {
                        number = (number + 1) % 10
                    }
                }
                .padding()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
