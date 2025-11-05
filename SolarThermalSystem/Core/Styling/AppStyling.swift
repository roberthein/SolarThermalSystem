import SwiftUI

/// Centralized design system for the Solar Thermal System app.
/// Provides consistent colors, typography, spacing, and styling across the application.
enum AppStyling {
    
    enum Background {
        static let primary = Color(red: 0.05, green: 0.05, blue: 0.08)
        static let secondary = Color(red: 0.08, green: 0.08, blue: 0.12)
        static let tertiary = Color(red: 0.12, green: 0.12, blue: 0.16)
        static let card = Color(red: 0.10, green: 0.10, blue: 0.14)
    }
    
    /// Temperature visualization colors transitioning from cold (blue) to hot (pink)
    enum Temperature {
        static let cold = Color(red: 0.2, green: 0.4, blue: 1.0)
        static let cool = Color(red: 0.4, green: 0.3, blue: 0.9)
        static let medium = Color(red: 0.6, green: 0.2, blue: 0.8)
        static let warm = Color(red: 0.8, green: 0.2, blue: 0.7)
        static let hot = Color(red: 1.0, green: 0.2, blue: 0.6)
        static let veryHot = Color(red: 1.0, green: 0.3, blue: 0.5)
        
        /// Maps temperature values to colors using interpolation between defined temperature ranges.
        /// Creates smooth color transitions for realistic thermal visualization.
        static func color(for temperature: Double) -> Color {
            switch temperature {
            case ..<15:
                return cold
            case 15..<25:
                return interpolate(from: cold, to: cool, progress: (temperature - 15) / 10)
            case 25..<35:
                return interpolate(from: cool, to: medium, progress: (temperature - 25) / 10)
            case 35..<45:
                return interpolate(from: medium, to: warm, progress: (temperature - 35) / 10)
            case 45..<60:
                return interpolate(from: warm, to: hot, progress: (temperature - 45) / 15)
            default:
                return interpolate(from: hot, to: veryHot, progress: min((temperature - 60) / 20, 1.0))
            }
        }
        
        static var gradient: LinearGradient {
            LinearGradient(
                colors: [cold, cool, medium, warm, hot, veryHot],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        
        /// Linear interpolation between two colors based on progress (0.0 to 1.0)
        private static func interpolate(from: Color, to: Color, progress: Double) -> Color {
            let progress = max(0, min(1, progress))
            let fromRGB = UIColor(from).rgba
            let toRGB = UIColor(to).rgba
            
            let r = fromRGB.red + (toRGB.red - fromRGB.red) * progress
            let g = fromRGB.green + (toRGB.green - fromRGB.green) * progress
            let b = fromRGB.blue + (toRGB.blue - fromRGB.blue) * progress
            let a = fromRGB.alpha + (toRGB.alpha - fromRGB.alpha) * progress
            
            return Color(red: r, green: g, blue: b, opacity: a)
        }
    }
    
    enum Accent {
        static let primary = Color(red: 0.4, green: 0.6, blue: 1.0)
        static let secondary = Color(red: 0.8, green: 0.3, blue: 0.9)
        static let success = Color(red: 0.3, green: 0.8, blue: 0.5)
        static let warning = Color(red: 0.0, green: 0.0, blue: 0.0)
        static let danger = Color(red: 1.0, green: 0.3, blue: 0.3)
    }
    
    enum Text {
        static let primary = Color.white
        static let secondary = Color.white.opacity(0.7)
        static let tertiary = Color.white.opacity(0.5)
    }
    
    enum Solar {
        static let sun = Color(red: 1.0, green: 0.8, blue: 0.2)
        static let sunGlow = Color(red: 1.0, green: 0.7, blue: 0.0)
    }
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let callout = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .semibold, design: .rounded)
        static let caption = Font.system(size: 14, weight: .semibold, design: .rounded)
        static let value = Font.system(size: 17, weight: .regular, design: .default)
        static let valueSmall = Font.system(size: 15, weight: .regular, design: .default)
        static let valueCaption = Font.system(size: 12, weight: .regular, design: .default)
        static let energyValue = Font.system(size: 36, weight: .regular, design: .default)
        static let clockDisplay = Font.system(size: 44, weight: .bold, design: .monospaced)
        static let buttonLabel = Font.system(size: 17, weight: .bold, design: .rounded)
        static let monospacedDigit = Font.system(size: 17, weight: .regular, design: .monospaced)
        static let monospacedBold = Font.system(size: 17, weight: .bold, design: .monospaced)
    }
    
    enum Icons {
        static let weight: Font.Weight = .heavy
        static let small = Font.system(size: 15, weight: .heavy, design: .rounded)
        static let medium = Font.system(size: 20, weight: .heavy, design: .rounded)
        static let large = Font.system(size: 28, weight: .heavy, design: .rounded)
        static let extraLarge = Font.system(size: 50, weight: .heavy, design: .rounded)
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
}

extension UIColor {
    var rgba: (red: Double, green: Double, blue: Double, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppStyling.Background.card)
            .clipShape(RoundedRectangle(cornerRadius: AppStyling.CornerRadius.md, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

