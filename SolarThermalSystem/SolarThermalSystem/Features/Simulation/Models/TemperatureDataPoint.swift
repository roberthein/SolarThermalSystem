import Foundation

/// Data point snapshot for graphing system temperatures and conditions over time
struct TemperatureDataPoint: Identifiable {
    let id = UUID()
    let timeInHours: Double
    let collectorTemp: Double
    let tankTopTemp: Double
    let tankBottomTemp: Double
    let ambientTemp: Double
    let solarIrradiance: Double
}


