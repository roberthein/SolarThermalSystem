import SwiftUI
import Charts

/// Main dashboard view for the solar thermal system simulation.
/// Displays system visualization, control panel, and temperature charts.
struct DashboardView: View {
    @StateObject private var viewModel = SimulationViewModel()
    @State private var currentPage: ViewPage = .schematic
    @State private var scrollPosition: ViewPage? = .schematic
    @State private var isFloatingPanelPresented = true
    
    enum ViewPage: Int, Hashable {
        case schematic = 0
        case chart = 1
    }

    var body: some View {
        ZStack {
            AppStyling.Background.primary
                .ignoresSafeArea()

            mainVisualization
        }
        .floatingPanel(minimumCornerRadius: 50, padding: 25, background: AnyShapeStyle(AppStyling.Background.tertiary), isPresented: $isFloatingPanelPresented, isPersistent: true) {
            controlPanel
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .presentationDetents([.height(140), .fraction(0.6)])
                .presentationBackgroundInteraction(.enabled)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard)
    }
    
    private var mainVisualization: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(.smooth(duration: 0.3)) {
                            currentPage = .schematic
                        }
                    }) {
                        Text("Schematic")
                            .font(AppStyling.Typography.headline)
                            .foregroundColor(currentPage == .chart ? AppStyling.Text.secondary : AppStyling.Text.primary)
                            .padding(.horizontal, AppStyling.Spacing.md)
                            .padding(.vertical, AppStyling.Spacing.sm)
                            .background(currentPage == .chart ? Color.clear : AppStyling.Background.card)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                    }
                    
                    Button(action: {
                        withAnimation(.smooth(duration: 0.3)) {
                            currentPage = .chart
                        }
                    }) {
                        Text("Chart")
                            .font(AppStyling.Typography.headline)
                            .foregroundColor(currentPage == .chart ? AppStyling.Text.primary : AppStyling.Text.secondary)
                            .padding(.horizontal, AppStyling.Spacing.md)
                            .padding(.vertical, AppStyling.Spacing.sm)
                            .background(currentPage == .chart ? AppStyling.Background.card : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                    }
                    
                    Spacer()
                    
                    sunIndicator
                }
                .padding(AppStyling.Spacing.md)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        SchematicView(viewModel: viewModel)
                            .frame(width: geometry.size.width)
                            .id(ViewPage.schematic)
                            .containerRelativeFrame(.horizontal)
                        
                        TemperatureChartView(viewModel: viewModel)
                            .frame(width: geometry.size.width)
                            .id(ViewPage.chart)
                            .containerRelativeFrame(.horizontal)
                            .padding(.bottom, AppStyling.Spacing.xxxl)
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollPosition)
                .scrollTargetBehavior(.paging)
                .onChange(of: scrollPosition) { _, newPosition in
                    // Update button highlight when user scrolls manually
                    if let newPosition = newPosition {
                        currentPage = newPosition
                    }
                }
                .onChange(of: currentPage) { _, newPage in
                    // Animate to page when button is tapped
                    withAnimation(.smooth(duration: 0.3)) {
                        scrollPosition = newPage
                    }
                }
            }
            .background(AppStyling.Background.secondary)
        }
    }
    
    private var controlPanel: some View {
        ScrollView {
            VStack(spacing: AppStyling.Spacing.lg) {
                timeDisplaySection
                simulationControlsSection
                systemStatusSection
                pumpControlsSection
                energyStatsSection
                Spacer()
            }
            .padding(AppStyling.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .background(AppStyling.Background.tertiary)
    }
    
    private var timeDisplaySection: some View {
        VStack(spacing: AppStyling.Spacing.sm) {
            HStack(spacing: AppStyling.Spacing.md) {
                Image(systemName: viewModel.solarIrradiance > 0 ? "sun.max.fill" : "moon.stars.fill")
                    .font(AppStyling.Icons.large)
                    .foregroundColor(viewModel.solarIrradiance > 0 ? AppStyling.Solar.sun : AppStyling.Accent.primary)
                
                Text(viewModel.formattedTime())
                    .font(AppStyling.Typography.clockDisplay)
                    .foregroundColor(AppStyling.Text.primary)
                    .monospacedDigit()
            }
            
            Text("Time of Day")
                .font(AppStyling.Typography.caption)
                .foregroundColor(AppStyling.Text.secondary)
        }
        .padding(AppStyling.Spacing.md)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var simulationControlsSection: some View {
        VStack(spacing: AppStyling.Spacing.md) {
            HStack(spacing: AppStyling.Spacing.md) {
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pauseSimulation()
                    } else {
                        viewModel.startSimulation()
                    }
                }) {
                    Label(viewModel.isRunning ? "Pause" : "Start", 
                          systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(AppStyling.Typography.buttonLabel)
                        .symbolVariant(.fill)
                        .frame(maxWidth: .infinity)
                        .padding(AppStyling.Spacing.md)
                        .background(viewModel.isRunning ? AppStyling.Accent.warning : AppStyling.Accent.success)
                        .foregroundColor(AppStyling.Text.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.xl, style: .continuous))
                }
                
                Button(action: {
                    viewModel.resetSimulation()
                }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(AppStyling.Typography.buttonLabel)
                        .symbolVariant(.fill)
                        .frame(maxWidth: .infinity)
                        .padding(AppStyling.Spacing.md)
                        .background(AppStyling.Temperature.cold)
                        .foregroundColor(AppStyling.Text.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.xl, style: .continuous))
                }
            }

            VStack(alignment: .leading, spacing: AppStyling.Spacing.xs) {
                Text("Speed: \(Int(viewModel.speedMultiplier))x")
                    .font(AppStyling.Typography.caption)
                    .foregroundColor(AppStyling.Text.secondary)

                Slider(
                    value: Binding(
                        get: { viewModel.speedMultiplier },
                        set: { viewModel.setSpeed($0) }
                    ),
                    in: 1...1000,
                    step: 1
                )
                .tint(AppStyling.Accent.primary)
            }
        }
        .padding(AppStyling.Spacing.lg)
        .cardStyle()
    }
    
    private var systemStatusSection: some View {
        VStack(spacing: AppStyling.Spacing.md) {
            Text("System Status")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            statusRow(icon: "sun.max", 
                     label: "Solar", 
                     value: String(format: "%.0f W/m²", viewModel.solarIrradiance),
                     color: AppStyling.Solar.sun)
            
            statusRow(icon: "thermometer", 
                     label: "Ambient", 
                     value: String(format: "%.1f °C", viewModel.ambientTemperature),
                     color: AppStyling.Accent.primary)
            
            Divider()
                .background(AppStyling.Text.tertiary)
            
            statusRow(icon: "squares.below.rectangle", 
                     label: "Collector", 
                     value: String(format: "%.1f °C", viewModel.collectorTemperature),
                     color: AppStyling.Temperature.color(for: viewModel.collectorTemperature))
            
            statusRow(icon: "drop.fill", 
                     label: "Tank Top", 
                     value: String(format: "%.1f °C", viewModel.tankTopTemperature),
                     color: AppStyling.Temperature.color(for: viewModel.tankTopTemperature))
            
            statusRow(icon: "drop", 
                     label: "Tank Bottom", 
                     value: String(format: "%.1f °C", viewModel.tankBottomTemperature),
                     color: AppStyling.Temperature.color(for: viewModel.tankBottomTemperature))
            
            statusRow(icon: "gauge", 
                     label: "Tank Avg", 
                     value: String(format: "%.1f °C", viewModel.tankAverageTemperature),
                     color: AppStyling.Temperature.color(for: viewModel.tankAverageTemperature))
        }
        .padding(AppStyling.Spacing.lg)
        .cardStyle()
    }
    
    private var pumpControlsSection: some View {
        VStack(spacing: AppStyling.Spacing.md) {
            HStack {
                Text("Pump Control")
                    .font(AppStyling.Typography.headline)
                    .foregroundColor(AppStyling.Text.primary)
                
                Spacer()
                
                Image(systemName: viewModel.pumpIsOn ? "circle.fill" : "circle")
                    .font(AppStyling.Icons.medium)
                    .foregroundColor(viewModel.pumpIsOn ? AppStyling.Accent.success : AppStyling.Text.tertiary)
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.pumpAutomaticControl },
                set: { _ in viewModel.togglePumpControlMode() }
            )) {
                HStack(spacing: AppStyling.Spacing.sm) {
                    Image(systemName: "gearshape.2")
                        .font(AppStyling.Icons.medium)
                    Text("Automatic")
                        .font(AppStyling.Typography.body)
                }
                .foregroundColor(AppStyling.Text.primary)
            }
            .tint(AppStyling.Accent.primary)
            
            if !viewModel.pumpAutomaticControl {
                Button(action: {
                    viewModel.togglePump()
                }) {
                    Label(viewModel.pumpIsOn ? "Turn OFF" : "Turn ON",
                          systemImage: viewModel.pumpIsOn ? "stop.fill" : "play.fill")
                        .font(AppStyling.Typography.buttonLabel)
                        .symbolVariant(.fill)
                        .frame(maxWidth: .infinity)
                        .padding(AppStyling.Spacing.md)
                        .background(viewModel.pumpIsOn ? AppStyling.Accent.danger : AppStyling.Accent.success)
                        .foregroundColor(AppStyling.Text.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                }
            } else {
                Text("Automatic control based on ΔT")
                    .font(AppStyling.Typography.caption)
                    .foregroundColor(AppStyling.Text.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(AppStyling.Spacing.lg)
        .cardStyle()
    }
    
    private var energyStatsSection: some View {
        VStack(spacing: AppStyling.Spacing.sm) {
            Text("Energy Collected")
                .font(AppStyling.Typography.headline)
                .foregroundColor(AppStyling.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(String(format: "%.2f kWh", viewModel.energyCollected))
                .font(AppStyling.Typography.energyValue)
                .foregroundColor(AppStyling.Accent.success)
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppStyling.Spacing.lg)
        .cardStyle()
    }
    
    private func statusRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: AppStyling.Spacing.sm) {
            Image(systemName: icon)
                .font(AppStyling.Icons.small)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(AppStyling.Typography.subheadline)
                .foregroundColor(AppStyling.Text.secondary)
            
            Spacer()
            
            Text(value)
                .font(AppStyling.Typography.value)
                .foregroundColor(AppStyling.Text.primary)
                .monospacedDigit()
        }
    }
    
    private var sunIndicator: some View {
        HStack(spacing: AppStyling.Spacing.sm) {
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
                                startRadius: 10,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                }
                
                Image(systemName: viewModel.solarIrradiance > 0 ? "sun.max.fill" : "moon.stars.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(viewModel.solarIrradiance > 0 ? AppStyling.Solar.sun : AppStyling.Accent.primary)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f", viewModel.solarIrradiance))
                    .font(AppStyling.Typography.value)
                    .foregroundColor(AppStyling.Text.primary)
                    .monospacedDigit()
                
                Text("W/m²")
                    .font(AppStyling.Typography.valueCaption)
                    .foregroundColor(AppStyling.Text.secondary)
            }
        }
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}

