import Foundation

/// Models environmental conditions over a 24-hour cycle including solar irradiance and ambient temperature.
/// Uses sinusoidal functions to simulate realistic daily patterns.
struct EnvironmentalConditions {
    let maxIrradiance: Double = 1000.0
    let sunriseHour: Double = 6.0
    let sunsetHour: Double = 18.0
    let minAmbientTemp: Double = 15.0
    let maxAmbientTemp: Double = 25.0
    
    /// Calculates solar irradiance using a sine curve that peaks at solar noon.
    /// Returns 0 during nighttime hours.
    func irradiance(at timeInHours: Double) -> Double {
        let time = timeInHours.truncatingRemainder(dividingBy: 24.0)
        
        if time < sunriseHour || time > sunsetHour {
            return 0.0
        }
        
        let daylightHours = sunsetHour - sunriseHour
        let hoursSinceSunrise = time - sunriseHour
        let dayProgress = hoursSinceSunrise / daylightHours
        let angle = dayProgress * .pi
        let irradiance = maxIrradiance * sin(angle)
        
        return max(0, irradiance)
    }
    
    /// Calculates ambient temperature using a cosine curve with phase shift.
    /// Temperature is coldest at 3 AM and warmest at 3 PM, simulating thermal lag from solar heating.
    func ambientTemp(at timeInHours: Double) -> Double {
        let time = timeInHours.truncatingRemainder(dividingBy: 24.0)
        let tempMidpoint = (maxAmbientTemp + minAmbientTemp) / 2.0
        let tempAmplitude = (maxAmbientTemp - minAmbientTemp) / 2.0
        let phase = (time - 3.0) / 24.0 * 2.0 * .pi
        let temperature = tempMidpoint - tempAmplitude * cos(phase)
        
        return temperature
    }
    
    func isDaytime(at timeInHours: Double) -> Bool {
        let time = timeInHours.truncatingRemainder(dividingBy: 24.0)
        return time >= sunriseHour && time <= sunsetHour
    }
}


