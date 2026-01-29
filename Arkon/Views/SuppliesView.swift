import SwiftUI

struct SuppliesView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddSupply = false
    @State private var selectedSupply: Supply?
    @State private var showingEditSheet = false
    @State private var searchText = ""
    @State private var selectedFilter: SupplyType? = nil
    @State private var animateCards = false
    
    var filteredSupplies: [Supply] {
        var supplies = dataManager.supplies
        
        if let filter = selectedFilter {
            supplies = supplies.filter { $0.type == filter }
        }
        
        if !searchText.isEmpty {
            supplies = supplies.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return supplies.sorted { $0.remainingPercent < $1.remainingPercent }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 20)
                
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                filterPills
                    .padding(.top, 12)
                
                if filteredSupplies.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "drop.triangle",
                        title: "No Supplies",
                        message: "Add laundry supplies to track their usage",
                        buttonTitle: "Add",
                        action: { showingAddSupply = true }
                    )
                    Spacer()
                } else {
                    suppliesGrid
                }
            }
        }
        .sheet(isPresented: $showingAddSupply) {
            AddSupplyView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let supply = selectedSupply {
                EditSupplyView(dataManager: dataManager, supply: supply)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Laundry Supplies")
                    .font(AppTypography.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("\(dataManager.supplies.count) items • \(dataManager.lowSupplies.count) running low")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Button(action: { showingAddSupply = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.neonGreen)
                    .neonGlow(AppTheme.neonGreen, radius: 8)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textMuted)
            
            TextField("Search supplies...", text: $searchText)
                .font(AppTypography.body)
                .foregroundColor(AppTheme.textPrimary)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.textMuted.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(
                    title: "All",
                    isSelected: selectedFilter == nil,
                    color: AppTheme.primary
                ) {
                    withAnimation { selectedFilter = nil }
                }
                
                ForEach(SupplyType.allCases, id: \.self) { type in
                    FilterPill(
                        title: type.rawValue,
                        icon: type.icon,
                        isSelected: selectedFilter == type,
                        color: type.color
                    ) {
                        withAnimation { selectedFilter = type }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var suppliesGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredSupplies.enumerated()), id: \.element.id) { index, supply in
                    SupplyDetailCard(supply: supply) {
                        selectedSupply = supply
                        showingEditSheet = true
                    } onUse: { amount in
                        dataManager.useSupply(supply, amount: amount)
                    } onDelete: {
                        withAnimation {
                            dataManager.deleteSupply(supply)
                        }
                    }
                    .opacity(animateCards ? 1 : 0)
                    .offset(x: animateCards ? 0 : 50)
                    .animation(.spring().delay(Double(index) * 0.05), value: animateCards)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }
}

struct FilterPill: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(AppTypography.caption)
            }
            .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : AppTheme.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SupplyDetailCard: View {
    let supply: Supply
    let onEdit: () -> Void
    let onUse: (Double) -> Void
    let onDelete: () -> Void
    
    @State private var showingActions = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(supply.type.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: supply.type.icon)
                        .font(.title2)
                        .foregroundColor(supply.type.color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(supply.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(supply.type.rawValue)
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.cardBackgroundLight)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * supply.remainingPercent / 100)
                        }
                    }
                    .frame(height: 6)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(supply.remainingPercent))%")
                        .font(AppTypography.title2)
                        .foregroundColor(progressColor)
                    
                    if supply.isLow {
                        Text("Low!")
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.warning)
                    }
                }
                
                Button(action: { withAnimation(.spring()) { showingActions.toggle() } }) {
                    Image(systemName: showingActions ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppTheme.textMuted)
                        .padding(8)
                }
            }
            .padding(16)
            
            if showingActions {
                Divider()
                    .background(AppTheme.textMuted.opacity(0.2))
                
                HStack(spacing: 12) {
                    ActionButton(title: "-10%", color: AppTheme.neonOrange) {
                        onUse(10)
                    }
                    
                    ActionButton(title: "-25%", color: AppTheme.neonOrange) {
                        onUse(25)
                    }
                    
                    Spacer()
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppTheme.neonCyan)
                            .padding(10)
                            .background(Circle().fill(AppTheme.neonCyan.opacity(0.2)))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(AppTheme.error)
                            .padding(10)
                            .background(Circle().fill(AppTheme.error.opacity(0.2)))
                    }
                }
                .padding(16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .glassCard(cornerRadius: 18)
    }
    
    private var progressColor: Color {
        if supply.remainingPercent < 15 {
            return AppTheme.error
        } else if supply.remainingPercent < 30 {
            return AppTheme.warning
        } else {
            return supply.type.color
        }
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SuppliesView(dataManager: DataManager.shared)
}
