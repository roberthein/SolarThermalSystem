import Foundation

/// Models a thermal storage tank with vertical stratification where hot water naturally rises to the top.
/// Uses multiple layers to simulate temperature gradients and thermal buoyancy effects.
class ThermalStorageTank {
    let numberOfLayers: Int = 10
    let volume: Double = 300.0
    let waterDensity: Double = 1.0
    let specificHeat: Double = 4184.0
    let heatLossCoefficient: Double = 4.0
    let mixingCoefficient: Double = 0.04
    
    private(set) var layerTemperatures: [Double]
    private var massPerLayer: Double
    
    init(initialTemperature: Double = 20.0) {
        self.layerTemperatures = Array(repeating: initialTemperature, count: numberOfLayers)
        self.massPerLayer = (volume * waterDensity) / Double(numberOfLayers)
    }
    
    func addHeat(_ heat: Double, toLayer layerIndex: Int) {
        guard layerIndex >= 0 && layerIndex < numberOfLayers else { return }
        let deltaTemp = heat / (massPerLayer * specificHeat)
        layerTemperatures[layerIndex] += deltaTemp
    }
    
    func update(dt: TimeInterval, ambientTemp: Double) {
        applyHeatLosses(dt: dt, ambientTemp: ambientTemp)
        applyStratification(dt: dt)
    }
    
    var bottomTemperature: Double {
        return layerTemperatures.first ?? 20.0
    }
    
    var topTemperature: Double {
        return layerTemperatures.last ?? 20.0
    }
    
    var averageTemperature: Double {
        return layerTemperatures.reduce(0, +) / Double(numberOfLayers)
    }
    
    var allLayerTemperatures: [Double] {
        return layerTemperatures
    }
    
    func temperature(atHeight fraction: Double) -> Double {
        let clampedFraction = max(0, min(1, fraction))
        let layerIndex = Int(clampedFraction * Double(numberOfLayers - 1))
        return layerTemperatures[layerIndex]
    }
    
    func reset(to temperature: Double = 20.0) {
        layerTemperatures = Array(repeating: temperature, count: numberOfLayers)
    }
    
    func thermalEnergy(aboveAmbient ambientTemp: Double) -> Double {
        let totalMass = volume * waterDensity
        let avgTemp = averageTemperature
        let energyAboveAmbient = totalMass * specificHeat * (avgTemp - ambientTemp)
        return max(0, energyAboveAmbient)
    }
    
    /// Simulates heat loss to ambient with increased losses at top and bottom surfaces
    private func applyHeatLosses(dt: TimeInterval, ambientTemp: Double) {
        for i in 0..<numberOfLayers {
            let tempDifference = layerTemperatures[i] - ambientTemp
            var layerLossFactor = 1.0
            
            if i == numberOfLayers - 1 {
                layerLossFactor = 1.5
            } else if i == 0 {
                layerLossFactor = 0.8
            }
            
            let heatLossRate = heatLossCoefficient * layerLossFactor * tempDifference / Double(numberOfLayers)
            let heatLoss = heatLossRate * dt
            let deltaTemp = heatLoss / (massPerLayer * specificHeat)
            layerTemperatures[i] -= deltaTemp
            layerTemperatures[i] = max(layerTemperatures[i], ambientTemp)
        }
    }
    
    /// Simulates natural convection where hot water rises through buoyancy.
    /// Uses controlled heat transfer to maintain realistic temperature gradients.
    private func applyStratification(dt: TimeInterval) {
        for _ in 0..<5 {
            for i in 0..<(numberOfLayers - 1) {
                let lowerTemp = layerTemperatures[i]
                let upperTemp = layerTemperatures[i + 1]
                
                if lowerTemp > upperTemp {
                    let tempDifference = lowerTemp - upperTemp
                    let transferAmount = tempDifference * mixingCoefficient * 3.0
                    layerTemperatures[i] -= transferAmount
                    layerTemperatures[i + 1] += transferAmount
                }
            }
        }
    }
}

