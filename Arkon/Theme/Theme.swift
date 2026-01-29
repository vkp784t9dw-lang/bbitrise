import SwiftUI

struct AppTheme {
    static let background = Color(hex: "0A0E1A")
    static let cardBackground = Color(hex: "141B2D")
    static let cardBackgroundLight = Color(hex: "1A2340")
    
    static let neonCyan = Color(hex: "00F5FF")
    static let neonPink = Color(hex: "FF2E97")
    static let neonPurple = Color(hex: "B14EFF")
    static let neonGreen = Color(hex: "39FF14")
    static let neonOrange = Color(hex: "FF6B35")
    static let neonYellow = Color(hex: "FFE135")
    
    static let primary = neonCyan
    static let secondary = neonPink
    static let success = neonGreen
    static let warning = neonOrange
    static let error = Color(hex: "FF4757")
    
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8B9DC3")
    static let textMuted = Color(hex: "5A6A8A")
    
    static let primaryGradient = LinearGradient(
        colors: [neonCyan, neonPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let pinkGradient = LinearGradient(
        colors: [neonPink, neonPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenGradient = LinearGradient(
        colors: [neonGreen.opacity(0.8), neonCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0A0E1A"), Color(hex: "0F1629"), Color(hex: "0A0E1A")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [cardBackground, cardBackgroundLight.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let washerGradient = LinearGradient(
        colors: [Color(hex: "00B4DB"), Color(hex: "0083B0")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let dryerGradient = LinearGradient(
        colors: [neonOrange, Color(hex: "FF8C42")],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.cardBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

struct NeonGlow: ViewModifier {
    var color: Color
    var radius: CGFloat = 10
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

struct PulsingAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 1.0 : 0.85)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
    
    func neonGlow(_ color: Color, radius: CGFloat = 10) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
    
    func pulsing() -> some View {
        modifier(PulsingAnimation())
    }
}

struct NeonButtonStyle: ButtonStyle {
    var color: Color = AppTheme.primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(color, lineWidth: 2)
                    )
            )
            .shadow(color: color.opacity(0.5), radius: configuration.isPressed ? 5 : 15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct GradientButtonStyle: ButtonStyle {
    var gradient: LinearGradient = AppTheme.primaryGradient
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(gradient)
            )
            .shadow(color: AppTheme.primary.opacity(0.4), radius: configuration.isPressed ? 5 : 15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    static let timerLarge = Font.system(size: 72, weight: .light, design: .monospaced)
    static let timerMedium = Font.system(size: 48, weight: .light, design: .monospaced)
}
