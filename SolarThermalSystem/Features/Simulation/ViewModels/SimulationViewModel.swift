import Foundation
import SwiftUI
import Combine
import UIKit

/// Orchestrates the solar thermal system simulation and exposes state to SwiftUI views.
/// Updates simulation at 10 Hz with configurable speed multiplier for time acceleration.
class SimulationViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var currentTimeInHours: Double = 6.0
    @Published var temperatureData: [TemperatureDataPoint] = []
    @Published var collectorTemperature: Double = 20.0
    @Published var tankTopTemperature: Double = 20.0
    @Published var tankBottomTemperature: Double = 20.0
    @Published var tankAverageTemperature: Double = 20.0
    @Published var tankLayerTemperatures: [Double] = []
    @Published var ambientTemperature: Double = 20.0
    @Published var solarIrradiance: Double = 0.0
    @Published var pumpIsOn: Bool = false
    @Published var pumpAutomaticControl: Bool = true
    @Published var energyCollected: Double = 0.0
    @Published var speedMultiplier: Double = 60.0
    
    private let environment = EnvironmentalConditions()
    private let collector = SolarCollector()
    private let tank = ThermalStorageTank()
    private let pump = Pump()
    private let updateInterval: TimeInterval = 0.1
    private var timer: Timer?
    private var cumulativeEnergyJoules: Double = 0.0
    private var previousPumpState: Bool = false
    
    init() {
        tankLayerTemperatures = tank.allLayerTemperatures
        updatePublishedProperties()
        recordDataPoint()
    }
    
    func startSimulation() {
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateSimulation()
        }
    }
    
    func pauseSimulation() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetSimulation() {
        pauseSimulation()
        currentTimeInHours = 6.0
        temperatureData.removeAll()
        cumulativeEnergyJoules = 0.0
        energyCollected = 0.0
        collector.reset()
        tank.reset()
        pump.reset()
        updatePublishedProperties()
        recordDataPoint()
    }
    
    func togglePump() {
        guard !pump.automaticControl else { return }
        pump.isOn.toggle()
        pumpIsOn = pump.isOn
    }
    
    func togglePumpControlMode() {
        pump.toggleControlMode()
        pumpAutomaticControl = pump.automaticControl
    }
    
    func setSpeed(_ multiplier: Double) {
        speedMultiplier = max(1.0, min(multiplier, 1000.0))
    }
    
    /// Main simulation loop: updates environment, pump control, heat transfer, and time advancement.
    /// Runs at 10 Hz with time scaled by speedMultiplier for accelerated simulation.
    private func updateSimulation() {
        let simulatedTimeElapsed = speedMultiplier * updateInterval
        let irradiance = environment.irradiance(at: currentTimeInHours)
        let ambientTemp = environment.ambientTemp(at: currentTimeInHours)
        
        if pump.automaticControl {
            let previousState = pump.isOn
            pump.updateAutomaticControl(
                collectorTemp: collector.temperature,
                tankBottomTemp: tank.bottomTemperature,
                dt: simulatedTimeElapsed
            )
            
            // Trigger haptic feedback when pump state changes automatically
            if previousState != pump.isOn {
                DispatchQueue.main.async {
                    HapticsManager.light()
                }
            }
        }
        
        let heatToTank = collector.update(
            dt: simulatedTimeElapsed,
            irradiance: irradiance,
            ambientTemp: ambientTemp,
            pumpOn: pump.isOn,
            tankBottomTemp: tank.bottomTemperature
        )
        
        if pump.isOn && heatToTank > 0 {
            tank.addHeat(heatToTank, toLayer: 0)
            cumulativeEnergyJoules += heatToTank
        }
        
        tank.update(dt: simulatedTimeElapsed, ambientTemp: ambientTemp)
        currentTimeInHours += simulatedTimeElapsed / 3600.0
        
        if currentTimeInHours >= 24.0 {
            currentTimeInHours = currentTimeInHours.truncatingRemainder(dividingBy: 24.0)
        }
        
        updatePublishedProperties()
        
        let timeSinceLastDataPoint = temperatureData.last.map { currentTimeInHours - $0.timeInHours } ?? 1.0
        if abs(timeSinceLastDataPoint) >= 0.1 || temperatureData.isEmpty {
            recordDataPoint()
        }
        
        if temperatureData.count > 500 {
            temperatureData.removeFirst()
        }
    }
    
    private func updatePublishedProperties() {
        collectorTemperature = collector.temperature
        tankTopTemperature = tank.topTemperature
        tankBottomTemperature = tank.bottomTemperature
        tankAverageTemperature = tank.averageTemperature
        tankLayerTemperatures = tank.allLayerTemperatures
        ambientTemperature = environment.ambientTemp(at: currentTimeInHours)
        solarIrradiance = environment.irradiance(at: currentTimeInHours)
        pumpIsOn = pump.isOn
        pumpAutomaticControl = pump.automaticControl
        energyCollected = cumulativeEnergyJoules / 3_600_000.0
    }
    
    private func recordDataPoint() {
        let dataPoint = TemperatureDataPoint(
            timeInHours: currentTimeInHours,
            collectorTemp: collector.temperature,
            tankTopTemp: tank.topTemperature,
            tankBottomTemp: tank.bottomTemperature,
            ambientTemp: environment.ambientTemp(at: currentTimeInHours),
            solarIrradiance: environment.irradiance(at: currentTimeInHours)
        )
        temperatureData.append(dataPoint)
    }
    
    func formattedTime() -> String {
        let totalSeconds = currentTimeInHours * 3600.0
        let hours = Int(totalSeconds / 3600)
        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

