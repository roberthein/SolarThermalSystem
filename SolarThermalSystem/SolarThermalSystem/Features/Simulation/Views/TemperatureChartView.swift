import SwiftUI
import Charts

/// Temperature chart visualization showing system temperatures over time.
/// Displays collector, tank top, tank bottom, and ambient temperatures with solar irradiance.
struct TemperatureChartView: View {
    @ObservedObject var viewModel: SimulationViewModel
    
    var body: some View {
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
                        .symbolSize(60)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.tankBottomTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.cold)
                        .symbolSize(60)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.tankTopTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.medium)
                        .symbolSize(60)
                    }
                    
                    ForEach(viewModel.temperatureData) { point in
                        PointMark(
                            x: .value("Time", point.timeInHours),
                            y: .value("Temperature", point.collectorTemp)
                        )
                        .foregroundStyle(AppStyling.Temperature.hot)
                        .symbolSize(60)
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
        .background(AppStyling.Background.secondary)
    }
    
    private func chartLegendItem(color: Color, label: String, temp: Double) -> some View {
        VStack(alignment: .leading, spacing: AppStyling.Spacing.xs) {
            HStack(spacing: AppStyling.Spacing.xs) {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppStyling.Typography.subheadline)
                        .foregroundColor(AppStyling.Text.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    Text(String(format: "%.1f°C", temp))
                        .font(AppStyling.Typography.valueCaption)
                        .foregroundColor(AppStyling.Text.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

#Preview {
    TemperatureChartView(viewModel: SimulationViewModel())
        .preferredColorScheme(.dark)
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
}

