import SwiftUI

struct StatisticsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var animateCharts = false
    @State private var selectedPeriod: StatsPeriod = .month
    
    enum StatsPeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var stats: LaundryStatistics {
        dataManager.getStatistics()
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                        .padding(.top, 20)
                    
                    periodSelector
                    overviewCards
                    washActivityChart
                    categoryBreakdown
                    achievementsSection
                    funFactsSection
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateCharts = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Statistics")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Your laundry activity")
                .font(AppTypography.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(AppTypography.subheadline)
                        .foregroundColor(selectedPeriod == period ? .white : AppTheme.textSecondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? AppTheme.neonCyan : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppTheme.cardBackground)
        )
        .padding(.horizontal, 20)
    }
    
    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                OverviewCard(
                    title: "Total Washes",
                    value: "\(stats.totalWashes)",
                    icon: "washer.fill",
                    color: AppTheme.neonCyan,
                    trend: compareTrend(current: stats.thisMonthWashes, previous: stats.lastMonthWashes)
                )
                .opacity(animateCharts ? 1 : 0)
                .offset(y: animateCharts ? 0 : 20)
                
                OverviewCard(
                    title: "Total Dries",
                    value: "\(stats.totalDries)",
                    icon: "dryer.fill",
                    color: AppTheme.neonOrange,
                    trend: nil
                )
                .opacity(animateCharts ? 1 : 0)
                .offset(y: animateCharts ? 0 : 20)
            }
            
            HStack(spacing: 12) {
                OverviewCard(
                    title: "Items Washed",
                    value: "\(stats.clothesWashed)",
                    icon: "tshirt.fill",
                    color: AppTheme.neonPink,
                    trend: nil
                )
                .opacity(animateCharts ? 1 : 0)
                .offset(y: animateCharts ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: animateCharts)
                
                OverviewCard(
                    title: "Avg/Week",
                    value: String(format: "%.1f", stats.averageWashesPerWeek),
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppTheme.neonGreen,
                    trend: nil
                )
                .opacity(animateCharts ? 1 : 0)
                .offset(y: animateCharts ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.15), value: animateCharts)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func compareTrend(current: Int, previous: Int) -> TrendDirection? {
        if previous == 0 { return nil }
        let diff = current - previous
        if diff > 0 { return .up }
        if diff < 0 { return .down }
        return .neutral
    }
    
    private var washActivityChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wash Activity")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { day in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.neonCyan, AppTheme.neonPurple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: animateCharts ? CGFloat.random(in: 30...120) : 0)
                        
                        Text(dayLabel(day))
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
            .padding(20)
            .glassCard()
            .padding(.horizontal, 20)
        }
    }
    
    private func dayLabel(_ offset: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[offset % 7]
    }
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(categoryData, id: \.0.rawValue) { category, count in
                    CategoryBar(
                        category: category,
                        count: count,
                        maxCount: categoryData.map { $0.1 }.max() ?? 1,
                        animate: animateCharts
                    )
                }
            }
            .padding(20)
            .glassCard()
            .padding(.horizontal, 20)
        }
    }
    
    private var categoryData: [(ClothingCategory, Int)] {
        let grouped = Dictionary(grouping: dataManager.clothingItems, by: { $0.category })
        return ClothingCategory.allCases.map { category in
            (category, grouped[category]?.reduce(0) { $0 + $1.washCount } ?? 0)
        }.filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementBadge(
                        icon: "star.fill",
                        title: "First Wash",
                        isUnlocked: stats.totalWashes > 0,
                        color: AppTheme.neonYellow
                    )
                    
                    AchievementBadge(
                        icon: "flame.fill",
                        title: "10 Washes",
                        isUnlocked: stats.totalWashes >= 10,
                        color: AppTheme.neonOrange
                    )
                    
                    AchievementBadge(
                        icon: "bolt.fill",
                        title: "50 Washes",
                        isUnlocked: stats.totalWashes >= 50,
                        color: AppTheme.neonCyan
                    )
                    
                    AchievementBadge(
                        icon: "crown.fill",
                        title: "100 Washes",
                        isUnlocked: stats.totalWashes >= 100,
                        color: AppTheme.neonPurple
                    )
                    
                    AchievementBadge(
                        icon: "tshirt.fill",
                        title: "10 Items",
                        isUnlocked: dataManager.clothingItems.count >= 10,
                        color: AppTheme.neonPink
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var funFactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fun Facts")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                if let mostWashed = stats.mostWashedCategory {
                    FunFactCard(
                        icon: "trophy.fill",
                        fact: "Most washed: \(mostWashed.rawValue)",
                        color: AppTheme.neonYellow
                    )
                }
                
                FunFactCard(
                    icon: "drop.fill",
                    fact: "Using \(stats.suppliesUsed) types of supplies",
                    color: AppTheme.neonCyan
                )
                
                if stats.thisMonthWashes > stats.lastMonthWashes {
                    FunFactCard(
                        icon: "arrow.up.circle.fill",
                        fact: "Washing more this month!",
                        color: AppTheme.neonGreen
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

enum TrendDirection {
    case up, down, neutral
}

struct OverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: TrendDirection?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trendIcon(trend))
                        .foregroundColor(trendColor(trend))
                }
            }
            
            Text(value)
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
    
    private func trendIcon(_ trend: TrendDirection) -> String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }
    
    private func trendColor(_ trend: TrendDirection) -> Color {
        switch trend {
        case .up: return AppTheme.neonGreen
        case .down: return AppTheme.error
        case .neutral: return AppTheme.textMuted
        }
    }
}

struct CategoryBar: View {
    let category: ClothingCategory
    let count: Int
    let maxCount: Int
    let animate: Bool
    
    var color: Color {
        switch category {
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
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(category.rawValue)
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.cardBackgroundLight)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: animate ? geometry.size.width * CGFloat(count) / CGFloat(maxCount) : 0)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : AppTheme.cardBackgroundLight)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : AppTheme.textMuted)
            }
            .overlay(
                Circle()
                    .stroke(isUnlocked ? color : Color.clear, lineWidth: 2)
            )
            .neonGlow(isUnlocked ? color : .clear, radius: isUnlocked ? 8 : 0)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}

struct FunFactCard: View {
    let icon: String
    let fact: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(fact)
                .font(AppTypography.body)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
        }
        .padding(16)
        .glassCard()
    }
}

#Preview {
    StatisticsView(dataManager: DataManager.shared)
}
