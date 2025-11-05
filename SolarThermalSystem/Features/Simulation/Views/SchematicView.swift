import SwiftUI

/// Visual schematic representation of the solar thermal system with animated components.
/// Grid layout with collector on top and storage tank on bottom, designed to scale across device sizes.
struct SchematicView: View {
    @ObservedObject var viewModel: SimulationViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let headerHeight: CGFloat = 60
            let bottomPanelHeight: CGFloat = 140
            let totalSpacing: CGFloat = AppStyling.Spacing.md * 2
            let padding: CGFloat = AppStyling.Spacing.sm * 2
            let availableHeight = max(300, geometry.size.height - headerHeight - bottomPanelHeight - totalSpacing - padding)
            
            let pipeHeight: CGFloat = 120
            let collectorHeight = max(100, (availableHeight - pipeHeight) * 0.45)
            let tankHeight = max(100, (availableHeight - pipeHeight) * 0.55)
            
            ZStack {
                AppStyling.Background.primary
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
    }
    
    private func collectorRow(height: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text("Solar Collector")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
            
            collectorPanel
                .frame(maxWidth: .infinity, maxHeight: height)
                .aspectRatio(1.5, contentMode: .fit)
        }
    }
    
    private func pipingRow(height: CGFloat) -> some View {
        let pipeHeight = height - 30
        let pumpSize = min(height - 10, 90.0)
        
        return VStack(spacing: 4) {
            Text("Circulation")
                .font(AppStyling.Typography.caption)
                .foregroundColor(AppStyling.Text.secondary)
            
            HStack(spacing: AppStyling.Spacing.lg) {
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Supply")
                        .font(AppStyling.Typography.valueCaption)
                        .foregroundColor(AppStyling.Text.tertiary)
                    
                    pipeSegment(temperature: viewModel.collectorTemperature, isFlowing: viewModel.pumpIsOn)
                        .frame(width: 30, height: pipeHeight)
                }
                
                Spacer()
                
                pumpIndicator
                    .frame(width: pumpSize, height: pumpSize)
                
                Spacer()
                
                VStack(spacing: 2) {
                    pipeSegment(temperature: viewModel.tankBottomTemperature, isFlowing: viewModel.pumpIsOn)
                        .frame(width: 30, height: pipeHeight)
                    
                    Text("Return")
                        .font(AppStyling.Typography.valueCaption)
                        .foregroundColor(AppStyling.Text.tertiary)
                }
                
                Spacer()
            }
        }
    }
    
    private func tankRow(height: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text("Storage Tank")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
            
            storageTank
                .frame(maxWidth: .infinity, maxHeight: height)
                .aspectRatio(1.5, contentMode: .fit)
        }
    }
    
    private func pipeSegment(temperature: Double, isFlowing: Bool) -> some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppStyling.Temperature.color(for: temperature))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(AppStyling.Temperature.color(for: temperature).opacity(0.5), lineWidth: 2)
                    )
                
                if isFlowing {
                    VStack(spacing: geometry.size.height / 6) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 6, height: 6)
                                .modifier(VerticalFlowAnimationModifier(delay: Double(index) * 0.5, pipeHeight: geometry.size.height))
                        }
                    }
                }
            }
        }
    }
    
    private var pumpIndicator: some View {
        ZStack {
            Circle()
                .fill(AppStyling.Background.card)
                .shadow(color: .black.opacity(0.3), radius: 8)
            
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
            
            VStack(spacing: 4) {
                Text(viewModel.pumpIsOn ? "ON" : "OFF")
                    .font(AppStyling.Typography.headline)
                    .foregroundColor(viewModel.pumpIsOn ? AppStyling.Accent.success : AppStyling.Text.tertiary)
                
                Text(viewModel.pumpAutomaticControl ? "Auto" : "Manual")
                    .font(AppStyling.Typography.valueCaption)
                    .foregroundColor(AppStyling.Text.secondary)
            }
        }
    }
    
    private var collectorPanel: some View {
        VStack(spacing: 0) {
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
            
            HStack(spacing: AppStyling.Spacing.lg) {
                VStack(alignment: .leading, spacing: AppStyling.Spacing.xs) {
                    Text("Area")
                        .font(AppStyling.Typography.caption)
                        .foregroundColor(AppStyling.Text.tertiary)
                    Text("3.0 m²")
                        .font(AppStyling.Typography.value)
                        .foregroundColor(AppStyling.Text.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppStyling.Spacing.xs) {
                    Text("Efficiency")
                        .font(AppStyling.Typography.caption)
                        .foregroundColor(AppStyling.Text.tertiary)
                    Text("75%")
                        .font(AppStyling.Typography.value)
                        .foregroundColor(AppStyling.Text.secondary)
                }
            }
            .padding(AppStyling.Spacing.md)
            .background(AppStyling.Background.card.opacity(0.5))
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
                            .fill(AppStyling.Temperature.color(for: layerTemp))
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
                .padding(.horizontal, 8)

                VStack {
                    Spacer()
                    Text("\(300)L")
                        .font(AppStyling.Typography.caption)
                        .foregroundColor(AppStyling.Text.tertiary)
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
            .shadow(color: .black.opacity(0.2), radius: 2)
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


