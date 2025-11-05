import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = SimulationViewModel()
    @State private var showChart = false
    @State private var isFloatingPanelPresented = true

    var body: some View {
        ZStack {
            AppStyling.Background.primary
                .ignoresSafeArea()

            mainVisualization
        }
        .overlay(alignment: .bottomLeading) {
            Color.clear.frame(width: 1, height: 1)
                .floatingPanel(minimumCornerRadius: 50, padding: 25, background: AnyShapeStyle(.background), isPresented: $isFloatingPanelPresented, isPersistent: true) {
                    controlPanel
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .presentationDetents([.height(140), .fraction(0.6)])
                        .presentationBackgroundInteraction(.enabled)
                }
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.keyboard)
    }
    
    private var mainVisualization: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { showChart = false }) {
                    Text("Schematic")
                        .font(AppStyling.Typography.headline)
                        .foregroundColor(showChart ? AppStyling.Text.secondary : AppStyling.Text.primary)
                        .padding(.horizontal, AppStyling.Spacing.md)
                        .padding(.vertical, AppStyling.Spacing.sm)
                        .background(showChart ? Color.clear : AppStyling.Background.card)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                }
                
                Button(action: { showChart = true }) {
                    Text("Chart")
                        .font(AppStyling.Typography.headline)
                        .foregroundColor(showChart ? AppStyling.Text.primary : AppStyling.Text.secondary)
                        .padding(.horizontal, AppStyling.Spacing.md)
                        .padding(.vertical, AppStyling.Spacing.sm)
                        .background(showChart ? AppStyling.Background.card : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                }
                
                Spacer()
            }
            .padding(AppStyling.Spacing.md)
            
            if showChart {
                chartView
            } else {
                SchematicView(viewModel: viewModel)
            }
        }
        .background(AppStyling.Background.secondary)
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
        .background(AppStyling.Background.secondary)
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
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
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
                        .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.sm, style: .continuous))
                }
            }
            
            VStack(alignment: .leading, spacing: AppStyling.Spacing.xs) {
                Text("Speed: \(Int(viewModel.speedMultiplier))x")
                    .font(AppStyling.Typography.caption)
                    .foregroundColor(AppStyling.Text.secondary)
                
                Slider(value: Binding(
                    get: { viewModel.speedMultiplier },
                    set: { viewModel.setSpeed($0) }
                ), in: 1...1000, step: 1)
                    .tint(AppStyling.Accent.primary)
            }
        }
        .padding(AppStyling.Spacing.md)
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
        .padding(AppStyling.Spacing.md)
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
        .padding(AppStyling.Spacing.md)
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
        .padding(AppStyling.Spacing.md)
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
    
    private var chartView: some View {
        VStack(spacing: 0) {
            Text("Temperature vs Time")
                .font(AppStyling.Typography.title2)
                .foregroundColor(AppStyling.Text.primary)
                .padding(AppStyling.Spacing.md)
            
            if viewModel.temperatureData.isEmpty {
                VStack {
                    Spacer()
                    Text("Start simulation to see data")
                        .font(AppStyling.Typography.title)
                        .foregroundColor(AppStyling.Text.secondary)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(viewModel.temperatureData) { point in
                        AreaMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Irradiance", point.solarIrradiance / 10.0)
                        )
                        .foregroundStyle(Color.white.opacity(0.2))
                        .interpolationMethod(.linear)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.ambientTemp)
                        )
                        .foregroundStyle(Color.gray)
                        .symbolSize(80)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.tankBottomTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.cold)
                        .symbolSize(120)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.tankTopTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.medium)
                        .symbolSize(120)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.collectorTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.hot)
                        .symbolSize(120)
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(AppStyling.Background.tertiary.opacity(0.3))
                }
                .chartXScale(domain: 0...24)
                .chartXAxis {
                    AxisMarks(values: .stride(by: 2)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(AppStyling.Text.tertiary.opacity(0.3))
                        AxisValueLabel {
                            if let hour = value.as(Int.self) {
                                Text("\(hour):00")
                                    .font(AppStyling.Typography.valueCaption)
                                    .foregroundColor(AppStyling.Text.secondary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(AppStyling.Text.tertiary.opacity(0.3))
                        AxisValueLabel {
                            if let temp = value.as(Double.self) {
                                Text("\(Int(temp))°C")
                                    .font(AppStyling.Typography.valueCaption)
                                    .foregroundColor(AppStyling.Text.secondary)
                            }
                        }
                    }
                }
                .padding(AppStyling.Spacing.md)
                
                VStack(spacing: AppStyling.Spacing.sm) {
                    Text("Temperature Legend")
                        .font(AppStyling.Typography.headline)
                        .foregroundColor(AppStyling.Text.primary)
                    
                    HStack(spacing: AppStyling.Spacing.xl) {
                        chartLegendItem(
                            color: AppStyling.Temperature.hot,
                            label: "Collector",
                            temp: viewModel.collectorTemperature
                        )
                        chartLegendItem(
                            color: AppStyling.Temperature.medium,
                            label: "Tank Top",
                            temp: viewModel.tankTopTemperature
                        )
                        chartLegendItem(
                            color: AppStyling.Temperature.cold,
                            label: "Tank Bottom",
                            temp: viewModel.tankBottomTemperature
                        )
                        chartLegendItem(
                            color: Color.gray,
                            label: "Ambient",
                            temp: viewModel.ambientTemperature
                        )
                    }
                }
                .padding(AppStyling.Spacing.md)
            }
        }
        .background(AppStyling.Background.primary)
    }
    
    private func chartLegendItem(color: Color, label: String, temp: Double) -> some View {
        VStack(alignment: .leading, spacing: AppStyling.Spacing.xs) {
            HStack(spacing: AppStyling.Spacing.sm) {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppStyling.Typography.subheadline)
                        .foregroundColor(AppStyling.Text.primary)
                    
                    Text(String(format: "%.1f°C", temp))
                        .font(AppStyling.Typography.valueCaption)
                        .foregroundColor(AppStyling.Text.secondary)
                        .monospacedDigit()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

