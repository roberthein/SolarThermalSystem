import Foundation

/// Models a solar thermal collector with realistic heat absorption, losses, and transfer physics.
/// Absorbs solar energy, loses heat to ambient, and transfers heat to storage tank when pump operates.
class SolarCollector {
    let area: Double = 3.0
    let efficiency: Double = 0.75
    let heatLossCoefficient: Double = 8.0
    let thermalCapacity: Double = 15000.0
    let pumpHeatTransferCoefficient: Double = 150.0
    
    private(set) var temperature: Double = 20.0
    
    init(initialTemperature: Double = 20.0) {
        self.temperature = initialTemperature
    }
    
    /// Updates collector temperature based on solar gain, heat losses, and heat transfer to tank.
    /// Limits heat transfer rate to prevent unrealistic temperature swings.
    @discardableResult
    func update(dt: TimeInterval, irradiance: Double, ambientTemp: Double, pumpOn: Bool, tankBottomTemp: Double) -> Double {
        let solarGain = irradiance * area * efficiency
        let heatLoss = heatLossCoefficient * area * (temperature - ambientTemp)
        
        var heatToTank: Double = 0.0
        
        if pumpOn {
            let tempDifference = temperature - tankBottomTemp
            
            if tempDifference > 0 {
                let heatTransferRate = pumpHeatTransferCoefficient * tempDifference
                heatToTank = heatTransferRate * dt
                
                let maxTransferable = thermalCapacity * tempDifference * 0.2
                heatToTank = min(heatToTank, maxTransferable)
                
                let availableEnergy = thermalCapacity * (temperature - tankBottomTemp)
                heatToTank = min(heatToTank, availableEnergy * 0.3)
            }
        }
        
        let netEnergy = (solarGain - heatLoss) * dt - heatToTank
        let deltaTemp = netEnergy / thermalCapacity
        temperature += deltaTemp
        temperature = max(temperature, ambientTemp)
        
        return heatToTank
    }
    
    func reset(to temperature: Double = 20.0) {
        self.temperature = temperature
    }
}

