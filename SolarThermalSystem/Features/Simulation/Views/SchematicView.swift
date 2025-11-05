import SwiftUI

/// Visual schematic representation of the solar thermal system with animated components.
/// Shows sun, collector, piping with flow animation, and stratified storage tank.
struct SchematicView: View {
    @ObservedObject var viewModel: SimulationViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppStyling.Background.primary
                    .ignoresSafeArea()
                
                VStack(spacing: AppStyling.Spacing.xl) {
                    sunIndicator
                        .frame(height: geometry.size.height * 0.15)
                    
                    HStack(alignment: .top, spacing: AppStyling.Spacing.xl) {
                        Spacer()
                        collectorPanel
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.45)
                        Spacer()
                        pipingSystem
                            .frame(width: geometry.size.width * 0.12, height: geometry.size.height * 0.45)
                        Spacer()
                        storageTank
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.45)
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(AppStyling.Spacing.xl)
            }
        }
    }
    
    private var sunIndicator: some View {
        VStack(spacing: AppStyling.Spacing.sm) {
            ZStack {
                if viewModel.solarIrradiance > 0 {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppStyling.Solar.sunGlow.opacity(viewModel.solarIrradiance / 2000.0),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                }
                
                Image(systemName: viewModel.solarIrradiance > 0 ? "sun.max.fill" : "moon.stars.fill")
                    .font(AppStyling.Icons.extraLarge)
                    .foregroundColor(viewModel.solarIrradiance > 0 ? AppStyling.Solar.sun : AppStyling.Accent.primary)
            }
            
            Text(String(format: "%.0f W/m²", viewModel.solarIrradiance))
                .font(AppStyling.Typography.value)
                .foregroundColor(AppStyling.Text.secondary)
                .monospacedDigit()
        }
    }
    
    private var collectorPanel: some View {
        VStack(spacing: AppStyling.Spacing.md) {
            Text("Solar Collector")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
            
            ZStack {
                RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppStyling.Temperature.color(for: viewModel.collectorTemperature),
                                AppStyling.Temperature.color(for: viewModel.collectorTemperature).opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous)
                            .stroke(AppStyling.Temperature.color(for: viewModel.collectorTemperature).opacity(0.5), lineWidth: 4)
                    )
                
                VStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.black.opacity(0.2))
                                    .frame(height: 8)
                            }
                        }
                    }
                }
                .padding(AppStyling.Spacing.lg)
                
                VStack {
                    Spacer()
                    temperatureLabel(viewModel.collectorTemperature)
                        .padding(AppStyling.Spacing.md)
                }
            }
        }
    }
    
    private var pipingSystem: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - 110
            let pipeHeight = max(50, availableHeight / 2)
            
            VStack(spacing: 0) {
                VStack(spacing: AppStyling.Spacing.sm) {
                    Text("To Tank")
                        .font(AppStyling.Typography.caption)
                        .foregroundColor(AppStyling.Text.tertiary)
                    
                    pipe(temperature: viewModel.collectorTemperature, flowRate: viewModel.pumpIsOn ? 1.0 : 0.0, height: pipeHeight)
                }
                
                pumpIndicator
                    .padding(.vertical, AppStyling.Spacing.sm)
                
                VStack(spacing: AppStyling.Spacing.sm) {
                    pipe(temperature: viewModel.tankBottomTemperature, flowRate: viewModel.pumpIsOn ? 1.0 : 0.0, height: pipeHeight)
                    
                    Text("To Collector")
                        .font(AppStyling.Typography.caption)
                        .foregroundColor(AppStyling.Text.tertiary)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    /// Renders a pipe with temperature-based coloring and optional flow animation
    private func pipe(temperature: Double, flowRate: Double, height: CGFloat) -> some View {
        let safeHeight = max(10, height.isFinite ? height : 50)
        
        return GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppStyling.Temperature.color(for: temperature))
                    .frame(width: 24, height: safeHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(AppStyling.Temperature.color(for: temperature).opacity(0.5), lineWidth: 4)
                    )
                    .frame(maxWidth: .infinity)
                
                if flowRate > 0 && safeHeight > 20 {
                    flowAnimation(pipeHeight: safeHeight)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: safeHeight)
        }
        .frame(height: safeHeight)
    }
    
    /// Animated circles moving through pipe to visualize fluid flow
    private func flowAnimation(pipeHeight: CGFloat) -> some View {
        let safeHeight = max(20, pipeHeight)
        
        return ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 6, height: 6)
                    .modifier(FlowAnimationModifier(delay: Double(index) * 0.4, pipeHeight: safeHeight))
            }
        }
        .frame(width: 24, height: safeHeight)
    }
    
    private var pumpIndicator: some View {
        ZStack {
            Circle()
                .fill(AppStyling.Background.card)
                .frame(width: 50, height: 50)

            Group {
                if viewModel.pumpIsOn {
                    Circle()
                        .stroke(AppStyling.Text.tertiary, lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .scaleEffect(1.05)
                        .overlay {
                            Circle()
                                .fill(AppStyling.Accent.success)
                                .scaleEffect(0.5)
                        }

                    PulsingRing()
                } else {
                    Circle()
                        .stroke(AppStyling.Text.tertiary, lineWidth: 4)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
    
    private var storageTank: some View {
        VStack(spacing: AppStyling.Spacing.md) {
            Text("Storage Tank")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppStyling.CornerRadius.xl, style: .continuous)
                        .fill(AppStyling.Background.tertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyling.CornerRadius.xl, style: .continuous)
                                .stroke(AppStyling.Text.tertiary.opacity(0.3), lineWidth: 4)
                        )
                    
                    VStack(spacing: 0) {
                        ForEach(viewModel.tankLayerTemperatures.indices.reversed(), id: \.self) { index in
                            let layerTemp = viewModel.tankLayerTemperatures[index]
                            
                            Rectangle()
                                .fill(AppStyling.Temperature.color(for: layerTemp))
                                .frame(height: geometry.size.height / CGFloat(viewModel.tankLayerTemperatures.count))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous))
                    .padding(12)

                    VStack {
                        temperatureLabel(viewModel.tankTopTemperature)
                            .padding(AppStyling.Spacing.md)

                        Spacer()
                        
                        temperatureLabel(viewModel.tankBottomTemperature)
                            .padding(AppStyling.Spacing.md)
                    }
                    .frame(maxWidth: .infinity)

                    VStack {
                        Spacer()
                        Text("\(300)L")
                            .font(AppStyling.Typography.caption)
                            .foregroundColor(AppStyling.Text.tertiary)
                            .padding(AppStyling.Spacing.sm)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func temperatureLabel(_ temperature: Double) -> some View {
        Text(String(format: "%.1f°C", temperature))
            .font(AppStyling.Typography.value)
            .foregroundColor(AppStyling.Text.primary)
            .monospacedDigit()
            .padding(.horizontal, AppStyling.Spacing.md)
            .padding(.vertical, AppStyling.Spacing.sm)
            .background(AppStyling.Background.card.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 4)
    }
}

struct PulsingRing: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .stroke(AppStyling.Text.tertiary, lineWidth: 4)
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    scale = 1.5
                    opacity = 0.0
                }
            }
    }
}

struct FlowAnimationModifier: ViewModifier {
    let delay: Double
    let pipeHeight: CGFloat
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                offset = -pipeHeight / 2 + 6
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    offset = pipeHeight / 2 - 6
                }
            }
    }
}

#Preview {
    SchematicView(viewModel: SimulationViewModel())
        .preferredColorScheme(.dark)
}

