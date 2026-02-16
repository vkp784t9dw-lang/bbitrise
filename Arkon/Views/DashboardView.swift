import SwiftUI

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var selectedTab: Int
    
    @State private var showingAddClothing = false
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : -20)
                    
                    if dataManager.washerTimer.isRunning || dataManager.dryerTimer.isRunning {
                        activeTimersSection
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    
                    quickStatsSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                    
                    if !dataManager.lowSupplies.isEmpty {
                        lowSuppliesSection
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    
                    recentClothesSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                    
                    quickActionsSection
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingAddClothing) {
            AddClothingView(dataManager: dataManager)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greeting)
                .font(AppTypography.title2)
                .foregroundColor(AppTheme.textSecondary)
            
            Text("LaundryMate")
                .font(AppTypography.largeTitle)
                .foregroundColor(AppTheme.textPrimary)
                .neonGlow(AppTheme.neonCyan, radius: 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning ☀️"
        case 12..<17: return "Good Afternoon 🌤️"
        case 17..<22: return "Good Evening 🌙"
        default: return "Good Night ✨"
        }
    }
    
    private var activeTimersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Active Timers")
            
            HStack(spacing: 12) {
                if dataManager.washerTimer.isRunning {
                    ActiveTimerBanner(
                        timer: dataManager.washerTimer,
                        title: "Washing",
                        icon: "washer.fill",
                        gradient: AppTheme.washerGradient
                    )
                }
                
                if dataManager.dryerTimer.isRunning {
                    ActiveTimerBanner(
                        timer: dataManager.dryerTimer,
                        title: "Drying",
                        icon: "dryer.fill",
                        gradient: AppTheme.dryerGradient
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Statistics")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatusCard(
                    title: "Total Washes",
                    value: "\(dataManager.getStatistics().totalWashes)",
                    icon: "washer.fill",
                    color: AppTheme.neonCyan,
                    subtitle: "all time"
                )
                
                StatusCard(
                    title: "This Month",
                    value: "\(dataManager.getStatistics().thisMonthWashes)",
                    icon: "calendar",
                    color: AppTheme.neonPurple,
                    subtitle: "wash cycles"
                )
                
                StatusCard(
                    title: "Wardrobe Items",
                    value: "\(dataManager.clothingItems.count)",
                    icon: "tshirt.fill",
                    color: AppTheme.neonPink,
                    subtitle: "tracked"
                )
                
                StatusCard(
                    title: "Supplies",
                    value: "\(dataManager.supplies.count)",
                    icon: "drop.fill",
                    color: AppTheme.neonGreen,
                    subtitle: "\(dataManager.lowSupplies.count) running low"
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var lowSuppliesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "⚠️ Running Low", action: { selectedTab = 2 })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dataManager.lowSupplies) { supply in
                        LowSupplyBadge(supply: supply)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var recentClothesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Need Washing", action: { selectedTab = 3 })
            
            VStack(spacing: 12) {
                ForEach(clothesNeedingWash.prefix(3)) { item in
                    ClothingCard(
                        item: item,
                        onTap: { },
                        onWash: { dataManager.markAsWashed(item) }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            if clothesNeedingWash.isEmpty {
                Text("All items are freshly washed 🎉")
                    .font(AppTypography.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }
    
    private var clothesNeedingWash: [ClothingItem] {
        dataManager.clothingItems
            .filter { ($0.daysSinceWash ?? 0) > 5 }
            .sorted { ($0.daysSinceWash ?? 0) > ($1.daysSinceWash ?? 0) }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Quick Actions")
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Wash",
                    icon: "washer.fill",
                    color: AppTheme.neonCyan
                ) {
                    selectedTab = 1
                }
                
                QuickActionButton(
                    title: "Dry",
                    icon: "dryer.fill",
                    color: AppTheme.neonOrange
                ) {
                    selectedTab = 1
                }
                
                QuickActionButton(
                    title: "Add",
                    icon: "plus.circle.fill",
                    color: AppTheme.neonPink
                ) {
                    showingAddClothing = true
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ActiveTimerBanner: View {
    let timer: TimerState
    let title: String
    let icon: String
    let gradient: LinearGradient
    
    @State private var isPulsing = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .scaleEffect(isPulsing ? 1.15 : 1.0)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(timer.formattedTime)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            Spacer()
            
            CircularProgressView(progress: timer.progress)
                .frame(width: 50, height: 50)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gradient)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(AppTypography.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct LowSupplyBadge: View {
    let supply: Supply
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: supply.type.icon)
                .foregroundColor(AppTheme.warning)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(supply.name)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text("\(Int(supply.remainingPercent))%")
                    .font(AppTypography.footnote)
                    .foregroundColor(AppTheme.warning)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(AppTheme.warning.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.warning.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView(dataManager: DataManager.shared, selectedTab: .constant(0))
}
