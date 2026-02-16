import SwiftUI

struct HistoryView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedFilter: CycleType? = nil
    @State private var animateCards = false
    
    var filteredCycles: [WashCycle] {
        var cycles = dataManager.washCycles
        
        if let filter = selectedFilter {
            cycles = cycles.filter { $0.type == filter }
        }
        
        return cycles.sorted { $0.date > $1.date }
    }
    
    var groupedCycles: [(String, [WashCycle])] {
        let grouped = Dictionary(grouping: filteredCycles) { cycle -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: cycle.date)
        }
        
        return grouped.sorted { first, second in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            guard let date1 = formatter.date(from: first.key),
                  let date2 = formatter.date(from: second.key) else { return false }
            return date1 > date2
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 20)
                
                filterPills
                    .padding(.top, 16)
                
                if filteredCycles.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "No History",
                        message: "Your wash and dry cycles will appear here"
                    )
                    Spacer()
                } else {
                    historyList
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("\(filteredCycles.count) records")
                .font(AppTypography.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var filterPills: some View {
        HStack(spacing: 12) {
            FilterPill(
                title: "All",
                isSelected: selectedFilter == nil,
                color: AppTheme.primary
            ) {
                withAnimation { selectedFilter = nil }
            }
            
            FilterPill(
                title: "Wash",
                icon: "washer.fill",
                isSelected: selectedFilter == .wash,
                color: AppTheme.neonCyan
            ) {
                withAnimation { selectedFilter = .wash }
            }
            
            FilterPill(
                title: "Dry",
                icon: "dryer.fill",
                isSelected: selectedFilter == .dry,
                color: AppTheme.neonOrange
            ) {
                withAnimation { selectedFilter = .dry }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var historyList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 24) {
                ForEach(Array(groupedCycles.enumerated()), id: \.element.0) { index, group in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(group.0)
                                .font(AppTypography.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(group.1.count) cycle(s)")
                                .font(AppTypography.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        
                        ForEach(group.1) { cycle in
                            HistoryCycleCard(cycle: cycle)
                                .opacity(animateCards ? 1 : 0)
                                .offset(x: animateCards ? 0 : 30)
                                .animation(.spring().delay(Double(index) * 0.05), value: animateCards)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 120)
        }
    }
}

struct HistoryCycleCard: View {
    let cycle: WashCycle
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(cycleColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: cycle.type.icon)
                    .font(.title2)
                    .foregroundColor(cycleColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(cycle.type.rawValue)
                    .font(AppTypography.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack(spacing: 12) {
                    Label(timeString, systemImage: "clock")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Label(durationString, systemImage: "timer")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textMuted)
                }
                
                if cycle.type == .wash {
                    HStack(spacing: 4) {
                        Image(systemName: cycle.temperature.icon)
                        Text(cycle.temperature.degrees)
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(cycleColor)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(durationShort)
                    .font(AppTypography.title3)
                    .foregroundColor(AppTheme.textPrimary)
                Text("min")
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private var cycleColor: Color {
        cycle.type == .wash ? AppTheme.neonCyan : AppTheme.neonOrange
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: cycle.date)
    }
    
    private var durationString: String {
        let hours = Int(cycle.duration) / 3600
        let minutes = (Int(cycle.duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    private var durationShort: String {
        let minutes = Int(cycle.duration) / 60
        return "\(minutes)"
    }
}

#Preview {
    HistoryView(dataManager: DataManager.shared)
}
