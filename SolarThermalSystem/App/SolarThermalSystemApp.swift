import SwiftUI

@main
struct SolarThermalSystemApp: App {
    
    init() {
        // Prepare haptic feedback generators on app startup for minimal latency
        HapticsManager.prepare()
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark)
        }
    }
}
