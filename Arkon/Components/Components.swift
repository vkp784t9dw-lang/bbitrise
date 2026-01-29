import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                Circle()
                    .fill(AppTheme.neonCyan.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: animateGradient ? geometry.size.width * 0.6 : geometry.size.width * 0.2,
                        y: animateGradient ? geometry.size.height * 0.1 : geometry.size.height * 0.3
                    )
                
                Circle()
                    .fill(AppTheme.neonPink.opacity(0.12))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(
                        x: animateGradient ? geometry.size.width * 0.1 : geometry.size.width * 0.5,
                        y: animateGradient ? geometry.size.height * 0.7 : geometry.size.height * 0.5
                    )
                
                Circle()
                    .fill(AppTheme.neonPurple.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: animateGradient ? geometry.size.width * 0.7 : geometry.size.width * 0.3,
                        y: animateGradient ? geometry.size.height * 0.4 : geometry.size.height * 0.8
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .neonGlow(color, radius: 5)
                
                Spacer()
            }
            
            Text(value)
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

struct TimerRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 12
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .neonGlow(color, radius: 8)
            
            Circle()
                .fill(Color.white)
                .frame(width: lineWidth, height: lineWidth)
                .offset(y: -100)
                .rotationEffect(.degrees(animatedProgress * 360 - 90))
                .shadow(color: color, radius: 5)
                .opacity(animatedProgress > 0 ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.linear(duration: 0.3)) {
                animatedProgress = newValue
            }
        }
    }
}

struct MiniTimerCard: View {
    let timer: TimerState
    let icon: String
    let title: String
    let gradient: LinearGradient
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(gradient.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(timer.isRunning && isPulsing ? 1.1 : 1.0)
                    
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                if timer.isRunning {
                    Text(timer.formattedTime)
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                } else {
                    Text(title)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                if timer.isRunning {
                    ProgressView(value: timer.progress)
                        .tint(AppTheme.neonCyan)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .glassCard()
        }
        .buttonStyle(.plain)
        .onAppear {
            if timer.isRunning {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
    }
}

struct SupplyCard: View {
    let supply: Supply
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(supply.type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: supply.type.icon)
                        .font(.title2)
                        .foregroundColor(supply.type.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(supply.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(supply.type.rawValue)
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(supply.remainingPercent))%")
                        .font(AppTypography.headline)
                        .foregroundColor(supply.isLow ? AppTheme.warning : AppTheme.textPrimary)
                    
                    ProgressView(value: supply.remainingPercent / 100)
                        .tint(supply.isLow ? AppTheme.warning : supply.type.color)
                        .frame(width: 60)
                }
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

struct ClothingCard: View {
    let item: ClothingItem
    let onTap: () -> Void
    let onWash: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: item.imageSymbol)
                        .font(.title2)
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 8) {
                        Text(item.category.rawValue)
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        if let days = item.daysSinceWash {
                            Text("• \(days)d ago")
                                .font(AppTypography.caption)
                                .foregroundColor(days > 7 ? AppTheme.warning : AppTheme.textMuted)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onWash) {
                    Image(systemName: "bubbles.and.sparkles")
                        .font(.title2)
                        .foregroundColor(AppTheme.neonCyan)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(AppTheme.neonCyan.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
    
    private var categoryColor: Color {
        switch item.category {
        case .tops: return AppTheme.neonCyan
        case .bottoms: return AppTheme.neonPurple
        case .outerwear: return AppTheme.neonPink
        case .underwear: return AppTheme.neonOrange
        case .sportswear: return AppTheme.neonGreen
        case .accessories: return AppTheme.neonYellow
        case .bedding: return AppTheme.neonPurple
        case .towels: return AppTheme.neonCyan
        }
    }
}

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String = "All"
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.title3)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textMuted)
            
            Text(title)
                .font(AppTypography.title2)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(message)
                .font(AppTypography.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                }
                .buttonStyle(NeonButtonStyle())
                .padding(.top, 10)
            }
        }
        .padding(40)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs: [(icon: String, title: String)] = [
        ("house.fill", "Home"),
        ("washer.fill", "Timers"),
        ("drop.fill", "Supplies"),
        ("tshirt.fill", "Wardrobe"),
        ("gearshape.fill", "More")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    icon: tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(AppTheme.cardBackground)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textMuted)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .neonGlow(isSelected ? AppTheme.primary : .clear, radius: isSelected ? 8 : 0)
                
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct WashProgramButton: View {
    let program: WashProgram
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: program.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppTheme.neonCyan)
                
                Text(program.name)
                    .font(AppTypography.caption)
                    .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                
                Text(formatDuration(program.duration))
                    .font(AppTypography.footnote)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textMuted)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.neonCyan : AppTheme.cardBackgroundLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppTheme.neonCyan : Color.clear, lineWidth: 2)
                    )
            )
            .neonGlow(isSelected ? AppTheme.neonCyan : .clear, radius: isSelected ? 10 : 0)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}

struct DryProgramButton: View {
    let program: DryProgram
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: program.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : AppTheme.neonOrange)
                
                Text(program.name)
                    .font(AppTypography.caption)
                    .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                
                Text(formatDuration(program.duration))
                    .font(AppTypography.footnote)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppTheme.textMuted)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.neonOrange : AppTheme.cardBackgroundLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppTheme.neonOrange : Color.clear, lineWidth: 2)
                    )
            )
            .neonGlow(isSelected ? AppTheme.neonOrange : .clear, radius: isSelected ? 10 : 0)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}
