import SwiftUI

/// Centralized haptics management for consistent tactile feedback throughout the app.
/// Provides semantic haptic feedback for different types of user interactions with prepared generators for minimal latency.
class HapticsManager {
    
    // MARK: - Prepared Generators
    
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Initialization
    
    /// Prepares all feedback generators on app startup to minimize latency during use.
    /// Call this once when the app launches to ensure haptics are ready.
    static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact for subtle interactions like page switches
    static func light() {
        lightImpact.impactOccurred()
        // Re-prepare for next use
        lightImpact.prepare()
    }
    
    /// Medium impact for standard interactions like button taps
    static func medium() {
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }
    
    /// Heavy impact for significant actions like reset
    static func heavy() {
        heavyImpact.impactOccurred()
        heavyImpact.prepare()
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback for toggle switches and pickers
    static func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification for positive state changes
    static func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
    
    /// Warning notification for cautionary actions
    static func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }
    
    /// Error notification for failed actions
    static func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
}

