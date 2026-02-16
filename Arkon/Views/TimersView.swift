import SwiftUI

struct TimersView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedTimer: CycleType = .wash
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                timerTabSelector
                    .padding(.top, 20)
                
                TabView(selection: $selectedTimer) {
                    WasherTimerView(dataManager: dataManager)
                        .tag(CycleType.wash)
                    
                    DryerTimerView(dataManager: dataManager)
                        .tag(CycleType.dry)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
    
    private var timerTabSelector: some View {
        HStack(spacing: 0) {
            TimerTabButton(
                title: "Washer",
                icon: "washer.fill",
                isSelected: selectedTimer == .wash,
                isActive: dataManager.washerTimer.isRunning,
                activeColor: AppTheme.neonCyan
            ) {
                withAnimation(.spring()) {
                    selectedTimer = .wash
                }
            }
            
            TimerTabButton(
                title: "Dryer",
                icon: "dryer.fill",
                isSelected: selectedTimer == .dry,
                isActive: dataManager.dryerTimer.isRunning,
                activeColor: AppTheme.neonOrange
            ) {
                withAnimation(.spring()) {
                    selectedTimer = .dry
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.cardBackground)
        )
        .padding(.horizontal, 20)
    }
}

struct TimerTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(AppTypography.headline)
                
                if isActive {
                    Circle()
                        .fill(activeColor)
                        .frame(width: 8, height: 8)
                        .neonGlow(activeColor, radius: 5)
                }
            }
            .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? (isActive ? activeColor : AppTheme.cardBackgroundLight) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimersView(dataManager: DataManager.shared)
}
