import SwiftUI

/// Visual schematic representation of the solar thermal system with animated components.
/// Grid layout with collector on top and storage tank on bottom, designed to scale across device sizes.
struct SchematicView: View {
    @ObservedObject var viewModel: SimulationViewModel
    @State private var waterSpotsOffset: CGFloat = 0
    @State private var heatWavesOffset: CGFloat = 0
    @State private var waterFlowOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let headerHeight: CGFloat = 60
            let bottomPanelHeight: CGFloat = 140
            let totalSpacing: CGFloat = AppStyling.Spacing.md * 2
            let padding: CGFloat = AppStyling.Spacing.sm * 2
            let availableHeight = max(300, geometry.size.height - headerHeight - bottomPanelHeight - totalSpacing - padding)
            
            let pipeHeight: CGFloat = 120
            let collectorHeight = max(100, (availableHeight - pipeHeight) * 0.5)
            let tankHeight = max(100, (availableHeight - pipeHeight) * 0.5)
            
            ZStack {
                AppStyling.Background.secondary
                    .ignoresSafeArea()
                
                VStack(spacing: AppStyling.Spacing.md) {
                    collectorRow(height: collectorHeight)
                    
                    pipingRow(height: pipeHeight)
                    
                    tankRow(height: tankHeight)
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, AppStyling.Spacing.md)
                .padding(.vertical, AppStyling.Spacing.sm)
            }
        }
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
    
    private func collectorRow(height: CGFloat) -> some View {
        collectorPanel
            .frame(maxWidth: .infinity, maxHeight: height)
            .aspectRatio(1.5, contentMode: .fit)
    }
    
    private func pipingRow(height: CGFloat) -> some View {
        let pipeHeight = height - 30
        let pumpSize = min(height - 10, 90.0)
        
        return HStack(spacing: AppStyling.Spacing.lg) {
            Spacer()

            VStack(spacing: 2) {
                Text(Image(systemName: "chevron.down"))
                    .font(AppStyling.Icons.medium)
                    .foregroundColor(AppStyling.Text.tertiary)

                pipeSegment(temperature: viewModel.collectorTemperature, isSupply: true, isFlowing: viewModel.pumpIsOn)
                    .frame(width: 30, height: pipeHeight)
            }

            Spacer()

            pumpIndicator
                .frame(width: pumpSize, height: pumpSize)

            Spacer()

            VStack(spacing: 2) {
                pipeSegment(temperature: viewModel.tankBottomTemperature, isSupply: false, isFlowing: viewModel.pumpIsOn)
                    .frame(width: 30, height: pipeHeight)

                Text(Image(systemName: "chevron.up"))
                    .font(AppStyling.Icons.medium)
                    .foregroundColor(AppStyling.Text.tertiary)
            }

            Spacer()
        }
    }
    
    private func tankRow(height: CGFloat) -> some View {
        storageTank
            .frame(maxWidth: .infinity, maxHeight: height)
            .aspectRatio(1.5, contentMode: .fit)
    }
    
    private func pipeSegment(temperature: Double, isSupply: Bool, isFlowing: Bool) -> some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppStyling.Temperature.color(for: temperature))
                    .fill(
                        .waterSpots(
                            foregroundColor: AppStyling.Temperature.color(for: temperature, addWhite: isFlowing ? 0.2 : nil),
                            backgroundColor: AppStyling.Temperature.color(for: temperature),
                            radius: 2,
                            angle: .degrees(0),
                            offset: CGSize(width: 0, height: isSupply ? -waterSpotsOffset : waterSpotsOffset),
                            patternSize: CGSize(width: 15, height: 25)
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(AppStyling.Temperature.color(for: temperature).opacity(0.5), lineWidth: 2)
                    )
            }
        }
    }
    
    private var pumpIndicator: some View {
        ZStack {
            Circle()
                .fill(AppStyling.Background.card)
            
            Group {
                if viewModel.pumpIsOn {
                    Circle()
                        .stroke(AppStyling.Text.tertiary, lineWidth: 4)
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
                }
            }
            
            Text(viewModel.pumpIsOn ? "ON" : "OFF")
                .font(AppStyling.Typography.headline)
                .foregroundColor(viewModel.pumpIsOn ? AppStyling.Accent.success : AppStyling.Text.tertiary)
        }
    }
    
    private var collectorPanel: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous)
                    .fill(.heatWaves(
                        colors: [
                            AppStyling.Temperature.color(for: viewModel.collectorTemperature, addWhite: viewModel.isRunning ? 0.05 : nil),
                            AppStyling.Temperature.color(for: viewModel.collectorTemperature),
                            AppStyling.Temperature.color(for: viewModel.collectorTemperature, addWhite: viewModel.isRunning ? 0.01 : nil),
                            AppStyling.Temperature.color(for: viewModel.collectorTemperature)
                        ],
                        width: 10,
                        angle: .degrees(90),
                        offset: CGSize(width: heatWavesOffset, height: 0),
                        patternSize: CGSize(width: 100, height: 40)
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous)
                            .stroke(AppStyling.Temperature.color(for: viewModel.collectorTemperature).opacity(1), lineWidth: 4)
                    )
                
                VStack {
                    Spacer()
                    temperatureLabel(viewModel.collectorTemperature)
                        .padding(AppStyling.Spacing.md)
                }

                VStack {
                    Spacer()
                    Text("Solar Collector - 3.0 m²")
                        .font(AppStyling.Typography.headline)
                        .foregroundColor(AppStyling.Text.primary)
                    HStack(spacing: AppStyling.Spacing.xs) {
                        Text("Efficiency")
                            .font(AppStyling.Typography.caption)
                            .foregroundColor(AppStyling.Text.tertiary)
                        Text("75%")
                            .font(AppStyling.Typography.value)
                            .foregroundColor(AppStyling.Text.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous))
    }
    
    private var storageTank: some View {
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
                            .fill(.waterFlow(
                                colors: [
                                    AppStyling.Temperature.color(for: layerTemp, addWhite: viewModel.isRunning && viewModel.pumpIsOn ? 0.05 : nil),
                                    AppStyling.Temperature.color(for: layerTemp),
                                    AppStyling.Temperature.color(for: layerTemp, addWhite: viewModel.isRunning && viewModel.pumpIsOn ? 0.01 : nil),
                                    AppStyling.Temperature.color(for: layerTemp)
                                ],
                                width: 7.5,
                                angle: .degrees(90),
                                offset: CGSize(width: -waterFlowOffset / sqrt(2), height: waterFlowOffset / sqrt(2))
                            ))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.lg, style: .continuous))
                .padding(12)

                VStack {
                    temperatureLabel(viewModel.tankTopTemperature)
                        .padding(8)

                    Spacer()
                    
                    temperatureLabel(viewModel.tankBottomTemperature)
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppStyling.Spacing.md)

                VStack {
                    Spacer()
                    Text("Storage Tank - \(300)L")
                        .font(AppStyling.Typography.headline)
                        .foregroundColor(AppStyling.Text.primary)
                    HStack(spacing: AppStyling.Spacing.xs) {
                        Text("Heat Loss")
                            .font(AppStyling.Typography.caption)
                            .foregroundColor(AppStyling.Text.tertiary)
                        Text("4.0 W/K")
                            .font(AppStyling.Typography.value)
                            .foregroundColor(AppStyling.Text.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.xl, style: .continuous))
    }
    
    private func temperatureLabel(_ temperature: Double) -> some View {
        Text(String(format: "%.1f°C", temperature))
            .font(AppStyling.Typography.valueSmall)
            .foregroundColor(AppStyling.Text.primary)
            .monospacedDigit()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppStyling.Background.card.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
    }
}

struct PulsingRing: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .stroke(AppStyling.Text.tertiary, lineWidth: 4)
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

struct VerticalFlowAnimationModifier: ViewModifier {
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

#Preview("Schematic View") {
    SchematicView(viewModel: SimulationViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Dashboard") {
    DashboardView()
        .preferredColorScheme(.dark)
}


