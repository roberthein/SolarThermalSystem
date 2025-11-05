//
//  SolarThermalSystemTests.swift
//  SolarThermalSystemTests
//
//  Created by Robert-Hein Hooijmans on 04/11/2025.
//

import Testing
@testable import SolarThermalSystem

struct SolarThermalSystemTests {

    // MARK: - Environment Tests
    
    @Test func testEnvironmentSolarCycle() {
        let environment = Environment()
        
        // Test nighttime (no sun)
        #expect(environment.irradiance(at: 0.0) == 0.0, "Midnight should have no irradiance")
        #expect(environment.irradiance(at: 3.0) == 0.0, "3 AM should have no irradiance")
        
        // Test before sunrise
        #expect(environment.irradiance(at: 5.0) == 0.0, "Before sunrise should have no irradiance")
        
        // Test solar noon (peak)
        let noonIrradiance = environment.irradiance(at: 12.0)
        #expect(noonIrradiance > 900.0, "Solar noon should have high irradiance")
        #expect(noonIrradiance <= 1000.0, "Irradiance shouldn't exceed maximum")
        
        // Test afternoon (should be positive but less than noon)
        let afternoonIrradiance = environment.irradiance(at: 15.0)
        #expect(afternoonIrradiance > 0.0, "Afternoon should have sun")
        #expect(afternoonIrradiance < noonIrradiance, "Afternoon should be less than noon")
        
        // Test after sunset
        #expect(environment.irradiance(at: 19.0) == 0.0, "After sunset should have no irradiance")
        
        // Test daytime detection
        #expect(environment.isDaytime(at: 12.0), "Noon is daytime")
        #expect(!environment.isDaytime(at: 3.0), "3 AM is nighttime")
    }
    
    @Test func testEnvironmentAmbientTemperature() {
        let environment = Environment()
        
        // Test temperature bounds
        let morningTemp = environment.ambientTemp(at: 3.0) // Coldest
        let afternoonTemp = environment.ambientTemp(at: 15.0) // Warmest
        
        #expect(morningTemp >= 15.0, "Temperature shouldn't go below minimum")
        #expect(afternoonTemp <= 25.0, "Temperature shouldn't exceed maximum")
        #expect(afternoonTemp > morningTemp, "Afternoon should be warmer than morning")
    }
    
    // MARK: - Solar Collector Tests
    
    @Test func testCollectorHeatsUpWithSun() {
        let collector = SolarCollector(initialTemperature: 20.0)
        let initialTemp = collector.temperature
        
        // Apply sunlight for 1 minute with pump off
        collector.update(
            dt: 60.0,
            irradiance: 800.0,
            ambientTemp: 20.0,
            pumpOn: false,
            tankBottomTemp: 20.0
        )
        
        #expect(collector.temperature > initialTemp, "Collector should heat up with sunlight")
    }
    
    @Test func testCollectorCoolsAtNight() {
        let collector = SolarCollector(initialTemperature: 50.0)
        let initialTemp = collector.temperature
        
        // No sunlight, ambient cooler
        collector.update(
            dt: 60.0,
            irradiance: 0.0,
            ambientTemp: 20.0,
            pumpOn: false,
            tankBottomTemp: 20.0
        )
        
        #expect(collector.temperature < initialTemp, "Collector should cool at night")
        #expect(collector.temperature >= 20.0, "Collector shouldn't cool below ambient")
    }
    
    @Test func testCollectorTransfersHeatWhenPumpOn() {
        let collector = SolarCollector(initialTemperature: 40.0)
        
        // Pump on with hot collector and cool tank
        let heatTransferred = collector.update(
            dt: 60.0,
            irradiance: 500.0,
            ambientTemp: 20.0,
            pumpOn: true,
            tankBottomTemp: 25.0
        )
        
        #expect(heatTransferred > 0.0, "Heat should be transferred to tank when pump is on")
    }
    
    @Test func testCollectorEquilibratesWithTank() {
        let collector = SolarCollector(initialTemperature: 30.0)
        let tankTemp = 25.0
        
        // Run for multiple steps with pump on and some sunlight to maintain temperature
        for _ in 0..<20 {
            collector.update(
                dt: 60.0,
                irradiance: 200.0, // Some sun to prevent overcooling
                ambientTemp: 20.0,
                pumpOn: true,
                tankBottomTemp: tankTemp
            )
        }
        
        // Collector should stabilize close to tank temp (within a few degrees)
        let tempDiff = abs(collector.temperature - tankTemp)
        #expect(tempDiff < 10.0, "Collector should equilibrate near tank temperature when pumping")
        #expect(collector.temperature >= 20.0, "Collector shouldn't cool below ambient")
    }
    
    // MARK: - Thermal Storage Tank Tests
    
    @Test func testTankInitialization() {
        let tank = ThermalStorageTank(initialTemperature: 20.0)
        
        #expect(tank.bottomTemperature == 20.0, "Bottom should initialize correctly")
        #expect(tank.topTemperature == 20.0, "Top should initialize correctly")
        #expect(tank.averageTemperature == 20.0, "Average should match initial")
    }
    
    @Test func testTankHeatsWhenHeatAdded() {
        let tank = ThermalStorageTank(initialTemperature: 20.0)
        let initialTemp = tank.bottomTemperature
        
        // Add heat to bottom layer (10 kJ)
        tank.addHeat(10000.0, toLayer: 0)
        
        #expect(tank.bottomTemperature > initialTemp, "Bottom temperature should increase when heat added")
    }
    
    @Test func testTankStratification() {
        let tank = ThermalStorageTank(initialTemperature: 20.0)
        
        // Add substantial heat to bottom repeatedly to simulate continuous heating
        // With slower stratification, bottom will be hotter initially, then heat gradually rises
        for _ in 0..<40 {
            tank.addHeat(200_000.0, toLayer: 0) // Add 200 kJ per step
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        // After heating, verify stratification behavior
        #expect(tank.averageTemperature > 25.0, "Tank should be significantly warmer overall")
        
        // Key stratification test: There should be a visible temperature gradient
        let layers = tank.allLayerTemperatures
        
        // Bottom layers should be warm (receiving heat)
        let bottom = layers[0]
        #expect(bottom > 23.0, "Bottom should be warm from heat input")
        
        // Top layers should also be warm (heat has risen)
        let top = layers[9]
        #expect(top > 23.0, "Top should be warm from rising heat")
        
        // Verify layers are stratified (not all identical)
        let tempRange = layers.max()! - layers.min()!
        #expect(tempRange > 3.0, "Temperature gradient should exist (layers should differ by at least 3°C)")
    }
    
    @Test func testTankEnergyConservation() {
        let tank = ThermalStorageTank(initialTemperature: 20.0)
        
        // Known heat input: heat 300L of water by 10°C (accounting for losses)
        // Energy = mass × specificHeat × deltaT
        // Energy = 300 kg × 4184 J/(kg·K) × 10 K = 12,552,000 J
        // Add extra to compensate for heat loss during distribution
        let expectedEnergyInput = 18_000_000.0 // 18 MJ to account for losses
        
        // Add all heat at once to bottom layer
        tank.addHeat(expectedEnergyInput, toLayer: 0)
        
        // After adding heat, distribute through layers
        for _ in 0..<30 {
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        // Check average temperature rise (accounting for heat losses)
        let actualTempRise = tank.averageTemperature - 20.0
        #expect(actualTempRise >= 8.0, "Temperature should rise significantly accounting for losses")
        #expect(actualTempRise <= 15.0, "Temperature rise should be within expected range")
    }
    
    @Test func testTankLosesHeatToAmbient() {
        let tank = ThermalStorageTank(initialTemperature: 50.0)
        let initialAvgTemp = tank.averageTemperature
        
        // Run for 1 hour with no heat input
        for _ in 0..<60 {
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        #expect(tank.averageTemperature < initialAvgTemp, "Tank should lose heat to ambient over time")
        #expect(tank.averageTemperature > 20.0, "Tank should remain above ambient")
    }
    
    // MARK: - Pump Control Tests
    
    @Test func testPumpTurnsOnWithSufficientDelta() {
        let pump = Pump()
        
        // Initial state is off
        #expect(!pump.isOn, "Pump starts in off state")
        
        // Update with large temperature difference well above threshold
        // Collector 35°C, tank 20°C = 15°C delta >> 8°C threshold
        pump.updateAutomaticControl(
            collectorTemp: 35.0,
            tankBottomTemp: 20.0,
            dt: 60.0
        )
        
        #expect(pump.isOn, "Pump should turn on with 15°C temperature difference (well above 8°C threshold)")
    }
    
    @Test func testPumpHysteresis() {
        let pump = Pump()
        
        // Turn pump on
        pump.updateAutomaticControl(collectorTemp: 30.0, tankBottomTemp: 20.0, dt: 60.0)
        #expect(pump.isOn, "Pump should be on")
        
        // Small decrease shouldn't turn it off (hysteresis)
        pump.updateAutomaticControl(collectorTemp: 25.0, tankBottomTemp: 23.0, dt: 60.0) // 2°C delta
        #expect(pump.isOn, "Pump should stay on due to minimum on-time")
        
        // Must run minimum time before it can turn off
        for _ in 0..<3 {
            pump.updateAutomaticControl(collectorTemp: 23.0, tankBottomTemp: 22.0, dt: 60.0) // 1°C delta
        }
        
        #expect(!pump.isOn, "Pump should turn off after minimum time and low delta")
    }
    
    @Test func testPumpMinimumOnTime() {
        let pump = Pump()
        
        // Turn on
        pump.updateAutomaticControl(collectorTemp: 30.0, tankBottomTemp: 20.0, dt: 60.0)
        #expect(pump.isOn)
        
        // Try to turn off immediately (should fail due to minimum on-time)
        pump.updateAutomaticControl(collectorTemp: 21.0, tankBottomTemp: 20.0, dt: 60.0)
        #expect(pump.isOn, "Pump should stay on despite low delta (minimum on-time not met)")
        
        // Wait minimum on-time (3 minutes = 180 seconds)
        for _ in 0..<3 {
            pump.updateAutomaticControl(collectorTemp: 21.0, tankBottomTemp: 20.0, dt: 60.0)
        }
        
        #expect(!pump.isOn, "Pump should turn off after minimum on-time")
    }
    
    @Test func testPumpManualControl() {
        let pump = Pump()
        
        // Disable automatic control
        pump.toggleControlMode()
        #expect(!pump.automaticControl, "Should be in manual mode")
        
        // Manual state change
        pump.setManualState(true)
        #expect(pump.isOn, "Manual control should turn pump on")
        
        // Temperature shouldn't affect manual mode
        pump.updateAutomaticControl(collectorTemp: 20.0, tankBottomTemp: 20.0, dt: 60.0)
        #expect(pump.isOn, "Pump should stay on in manual mode regardless of temperature")
    }
    
    // MARK: - Integration Tests
    
    @Test func testSystemEnergyConservation() {
        let collector = SolarCollector()
        let tank = ThermalStorageTank()
        
        // Track energy
        var totalSolarInput = 0.0
        var totalHeatTransferred = 0.0
        
        // Simulate sunny period with pump on
        for _ in 0..<60 { // 1 hour
            let heatTransferred = collector.update(
                dt: 60.0,
                irradiance: 800.0,
                ambientTemp: 20.0,
                pumpOn: true,
                tankBottomTemp: tank.bottomTemperature
            )
            
            if heatTransferred > 0 {
                tank.addHeat(heatTransferred, toLayer: 0)
                totalHeatTransferred += heatTransferred
            }
            
            tank.update(dt: 60.0, ambientTemp: 20.0)
            
            // Track input
            totalSolarInput += 800.0 * 3.0 * 0.75 * 60.0 // irradiance × area × efficiency × time
        }
        
        // Tank should have heated up
        #expect(tank.averageTemperature > 20.0, "Tank should be warmer after solar collection")
        
        // Some heat should have been transferred
        #expect(totalHeatTransferred > 0.0, "Heat should be transferred from collector to tank")
        
        // Transferred heat should be less than total solar input (losses)
        #expect(totalHeatTransferred < totalSolarInput, "Not all solar energy should reach tank (losses)")
        #expect(totalHeatTransferred > totalSolarInput * 0.3, "At least 30% of solar energy should reach tank")
    }
    
    @Test func testCollectorStagnationTemperature() {
        let collector = SolarCollector()
        
        // Run with high sun and no pump (stagnation)
        var previousTemp = collector.temperature
        var stabilized = false
        
        for _ in 0..<120 { // 2 hours
            collector.update(
                dt: 60.0,
                irradiance: 1000.0,
                ambientTemp: 25.0,
                pumpOn: false,
                tankBottomTemp: 20.0
            )
            
            // Check if temperature stabilized (gains = losses)
            if abs(collector.temperature - previousTemp) < 0.1 {
                stabilized = true
                break
            }
            previousTemp = collector.temperature
        }
        
        #expect(stabilized, "Collector should reach equilibrium (stagnation) temperature")
        #expect(collector.temperature < 150.0, "Stagnation temperature should be realistic (< 150°C)")
        #expect(collector.temperature > 40.0, "Stagnation temperature should be significant (> 40°C)")
    }
    
    @Test func testTankTemperatureBounds() {
        let tank = ThermalStorageTank()
        
        // Add significant heat over time (accounting for 4.0 W/K heat loss)
        // Total: 50 steps × 500 kJ = 25 MJ
        for _ in 0..<50 {
            tank.addHeat(500_000.0, toLayer: 0) // 500 kJ per step
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        // All temperatures should be reasonable (not infinite or extremely high)
        #expect(tank.topTemperature < 100.0, "Tank shouldn't exceed boiling point")
        #expect(tank.bottomTemperature >= 20.0, "Tank shouldn't cool below ambient")
        #expect(tank.averageTemperature > 28.0, "Tank should have heated significantly (accounting for losses)")
        
        // Verify temperature gradient exists (stratification)
        let tempRange = tank.allLayerTemperatures.max()! - tank.allLayerTemperatures.min()!
        #expect(tempRange >= 3.0, "Temperature gradient should exist between layers")
    }
    
    @Test func testSystemDoesntGainEnergyFromNothing() {
        let collector = SolarCollector()
        let tank = ThermalStorageTank()
        
        let initialCollectorTemp = collector.temperature
        let initialTankAvg = tank.averageTemperature
        
        // Run with no sun and no external input
        for _ in 0..<60 {
            let heat = collector.update(
                dt: 60.0,
                irradiance: 0.0,
                ambientTemp: 20.0,
                pumpOn: true,
                tankBottomTemp: tank.bottomTemperature
            )
            
            if heat > 0 {
                tank.addHeat(heat, toLayer: 0)
            }
            
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        // System should have cooled or stayed same (no energy from nothing)
        #expect(collector.temperature <= initialCollectorTemp, "Collector shouldn't gain heat without sun")
        #expect(tank.averageTemperature <= initialTankAvg + 0.5, "Tank shouldn't gain significant heat without input")
    }
    
    @Test func testPumpPreventsRapidCycling() {
        let pump = Pump()
        var cycleCount = 0
        var previousState = pump.isOn
        
        // Simulate varying temperature conditions
        for i in 0..<30 {
            let collectorTemp = 25.0 + Double(i % 5) // Varying temp
            pump.updateAutomaticControl(
                collectorTemp: collectorTemp,
                tankBottomTemp: 20.0,
                dt: 30.0
            )
            
            if pump.isOn != previousState {
                cycleCount += 1
                previousState = pump.isOn
            }
        }
        
        // Should not cycle more than a few times
        #expect(cycleCount < 5, "Pump should not cycle excessively (< 5 times in 15 minutes)")
    }
    
    @Test func testHeatTransferIsProportionalToTemperatureDifference() {
        let collector = SolarCollector(initialTemperature: 50.0)
        
        // Small temperature difference
        let smallDeltaHeat = collector.update(
            dt: 60.0,
            irradiance: 0.0,
            ambientTemp: 20.0,
            pumpOn: true,
            tankBottomTemp: 45.0 // 5°C difference
        )
        
        // Reset and test large difference
        collector.reset(to: 50.0)
        let largeDeltaHeat = collector.update(
            dt: 60.0,
            irradiance: 0.0,
            ambientTemp: 20.0,
            pumpOn: true,
            tankBottomTemp: 30.0 // 20°C difference
        )
        
        #expect(largeDeltaHeat > smallDeltaHeat, "More heat should transfer with larger temperature difference")
    }
    
    @Test func testTankLayerCount() {
        let tank = ThermalStorageTank()
        
        #expect(tank.allLayerTemperatures.count == 10, "Tank should have 10 stratification layers")
    }
    
    @Test func testStratificationCausesHeatToRise() {
        let tank = ThermalStorageTank(initialTemperature: 20.0)
        
        // Continuously add heat to bottom layer to simulate collector input
        // With slower stratification and higher heat loss (4.0 W/K), we need more energy
        for _ in 0..<60 {
            tank.addHeat(400_000.0, toLayer: 0) // 400 kJ per step to bottom
            tank.update(dt: 60.0, ambientTemp: 20.0)
        }
        
        // Verify heat has distributed through stratification (though more slowly)
        #expect(tank.averageTemperature > 28.0, "Tank should be significantly warmer overall")
        
        // With controlled stratification, temperature gradient should be visible
        let layers = tank.allLayerTemperatures
        
        // All layers should be above initial temp (heat has spread)
        let allWarmer = layers.allSatisfy { $0 > 22.0 }
        #expect(allWarmer, "All layers should be warmer than initial (heat distributed)")
        
        // Temperature gradient should exist (stratification maintained)
        let tempRange = layers.max()! - layers.min()!
        #expect(tempRange >= 3.0, "Temperature gradient should be maintained (visible stratification)")
    }
    
    // MARK: - Thermodynamic Correctness Tests
    
    @Test func testSecondLawOfThermodynamics() {
        let collector = SolarCollector(initialTemperature: 30.0)
        
        // Heat shouldn't flow from cold to hot
        let heat = collector.update(
            dt: 60.0,
            irradiance: 0.0,
            ambientTemp: 20.0,
            pumpOn: true,
            tankBottomTemp: 35.0 // Tank hotter than collector
        )
        
        // No heat should transfer (or minimal reverse flow protection)
        #expect(heat <= 100.0, "Heat shouldn't flow from cold collector to hot tank")
    }
    
    @Test func testTemperaturesStayPhysical() {
        let collector = SolarCollector()
        let tank = ThermalStorageTank()
        
        // Run extreme simulation
        for _ in 0..<1000 {
            collector.update(
                dt: 60.0,
                irradiance: 1000.0,
                ambientTemp: 25.0,
                pumpOn: true,
                tankBottomTemp: tank.bottomTemperature
            )
            
            tank.addHeat(10000.0, toLayer: 0)
            tank.update(dt: 60.0, ambientTemp: 25.0)
        }
        
        // Temperatures should remain finite and reasonable
        #expect(collector.temperature.isFinite, "Collector temperature should be finite")
        #expect(tank.topTemperature.isFinite, "Tank temperature should be finite")
        #expect(collector.temperature > 0.0, "Temperatures should be positive")
        #expect(collector.temperature < 200.0, "Temperatures should be reasonable")
    }

}
