import SwiftUI

#Preview {
    AnimatedPatternsView()
}

struct AnimatedPatternsView: View {
    @State private var waterSpotsOffset: CGFloat = 0
    @State private var heatWavesOffset: CGFloat = 0
    @State private var waterFlowOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Water Spots - Used in pipes
            Rectangle()
                .fill(.waterSpots(
                    foregroundColor: .white.opacity(0.3),
                    backgroundColor: .blue,
                    radius: 2,
                    angle: .degrees(0),
                    offset: CGSize(width: 0, height: waterSpotsOffset),
                    patternSize: CGSize(width: 15, height: 25)
                ))
                .overlay(
                    Text("Water Spots (Pipes)")
                        .font(.headline)
                        .foregroundColor(.white)
                )

            // Heat Waves - Used in solar collector
            Rectangle()
                .fill(.heatWaves(
                    colors: [.orange, .red, .pink, .red],
                    width: 10,
                    angle: .degrees(90),
                    offset: CGSize(width: heatWavesOffset, height: 0),
                    patternSize: CGSize(width: 100, height: 40)
                ))
                .overlay(
                    Text("Heat Waves (Collector)")
                        .font(.headline)
                        .foregroundColor(.white)
                )

            // Water Flow - Used in storage tank
            Rectangle()
                .fill(.waterFlow(
                    colors: [.cyan, .blue.opacity(0.8), .cyan.opacity(0.6), .blue],
                    width: 15,
                    angle: .degrees(90),
                    offset: CGSize(width: waterFlowOffset / sqrt(2), height: waterFlowOffset / sqrt(2))
                ))
                .overlay(
                    Text("Water Flow (Tank)")
                        .font(.headline)
                        .foregroundColor(.white)
                )
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                waterSpotsOffset = 25
            }

            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                heatWavesOffset = 40
            }

            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                waterFlowOffset = 40
            }
        }
    }
}

// Unfortunately, we can't implement the `ShapeStyle` protocol ourselves, so we
// wrap these in an `AnyShapeStyle` to hide the shader implementation details.
//
// See Pattern.metal for notes on the individual patterns.
extension ShapeStyle where Self == AnyShapeStyle {
    static func waterSpots(foregroundColor: Color = .primary, backgroundColor: Color = .accentColor, radius: Double = 8, angle: Angle = .zero, offset: CGSize = .zero, patternSize: CGSize? = nil) -> Self {
        let d = radius * 3 * sqrt(2)
        let size = patternSize ?? CGSize(width: d, height: d)

        return AnyShapeStyle(ShaderLibrary.default.waterSpots(
            .boundingRect,
            .float(radius),
            .float(angle.radians),
            .float2(offset),
            .float2(size),
            .color(foregroundColor),
            .color(backgroundColor)
        ))
    }

    static func waterFlow(colors: [Color], width: CGFloat = 10, angle: Angle = .zero, offset: CGSize = .zero) -> Self {
        AnyShapeStyle(ShaderLibrary.default.waterFlow(
            .boundingRect,
            .float(width),
            .float(angle.radians),
            .float2(offset),
            .colorArray(colors)
        ))
    }

    static func heatWaves(colors: [Color], width: CGFloat = 10, angle: Angle = .zero, offset: CGSize = .zero, patternSize: CGSize? = nil) -> Self {
        AnyShapeStyle(ShaderLibrary.default.heatWaves(
            .boundingRect,
            .float(width),
            .float(angle.radians),
            .float2(offset),
            .float2(patternSize ?? CGSize(width: width * 10, height: 4 * width)),
            .colorArray(colors)
        ))
    }
}
