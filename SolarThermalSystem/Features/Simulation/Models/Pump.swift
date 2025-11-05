import Foundation

/// Models circulation pump with automatic differential temperature control and hysteresis.
/// Prevents short-cycling by enforcing minimum on/off times.
class Pump {
    var isOn: Bool = false
    var automaticControl: Bool = true
    
    let turnOnDelta: Double = 8.0
    let turnOffDelta: Double = 2.0
    let minimumOnTime: TimeInterval = 180.0
    let minimumOffTime: TimeInterval = 120.0
    
    private var timeInCurrentState: TimeInterval = 1000.0
    
    /// Automatic control based on collector-tank temperature difference with hysteresis.
    /// Hysteresis (different on/off thresholds) prevents rapid cycling around a single setpoint.
    func updateAutomaticControl(collectorTemp: Double, tankBottomTemp: Double, dt: TimeInterval) {
        guard automaticControl else { return }
        
        let tempDifference = collectorTemp - tankBottomTemp
        timeInCurrentState += dt
        
        if !isOn {
            if tempDifference >= turnOnDelta && timeInCurrentState >= minimumOffTime {
                isOn = true
                timeInCurrentState = 0.0
            }
        } else {
            if tempDifference <= turnOffDelta && timeInCurrentState >= minimumOnTime {
                isOn = false
                timeInCurrentState = 0.0
            }
        }
    }
    
    func setManualState(_ state: Bool) {
        if !automaticControl {
            isOn = state
        }
    }
    
    func toggleControlMode() {
        automaticControl.toggle()
    }
    
    func reset() {
        isOn = false
        automaticControl = true
        timeInCurrentState = 1000.0
    }
}

