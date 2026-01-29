import SwiftUI

struct WardrobeView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddClothing = false
    @State private var selectedItem: ClothingItem?
    @State private var showingDetail = false
    @State private var searchText = ""
    @State private var selectedCategory: ClothingCategory? = nil
    @State private var sortOption: SortOption = .lastWashed
    @State private var animateCards = false
    
    enum SortOption: String, CaseIterable {
        case lastWashed = "Last Washed"
        case name = "Name"
        case washCount = "Wash Count"
    }
    
    var filteredItems: [ClothingItem] {
        var items = dataManager.clothingItems
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .lastWashed:
            items.sort { ($0.daysSinceWash ?? 999) > ($1.daysSinceWash ?? 999) }
        case .name:
            items.sort { $0.name < $1.name }
        case .washCount:
            items.sort { $0.washCount > $1.washCount }
        }
        
        return items
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
                
                HStack {
                    categoryFilter
                    Spacer()
                    sortPicker
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                if filteredItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "tshirt",
                        title: "Wardrobe Empty",
                        message: "Add clothes to track their wash cycles",
                        buttonTitle: "Add Item",
                        action: { showingAddClothing = true }
                    )
                    Spacer()
                } else {
                    clothingList
                }
            }
        }
        .sheet(isPresented: $showingAddClothing) {
            AddClothingView(dataManager: dataManager)
        }
        .sheet(isPresented: $showingDetail) {
            if let item = selectedItem {
                ClothingDetailView(dataManager: dataManager, item: item)
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
                Text("Wardrobe")
                    .font(AppTypography.title)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("\(dataManager.clothingItems.count) items tracked")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Button(action: { showingAddClothing = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.neonPink)
                    .neonGlow(AppTheme.neonPink, radius: 8)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.textMuted)
            
            TextField("Search items...", text: $searchText)
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
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: AppTheme.primary
                ) {
                    withAnimation { selectedCategory = nil }
                }
                
                ForEach(ClothingCategory.allCases, id: \.self) { category in
                    FilterPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: categoryColor(for: category)
                    ) {
                        withAnimation { selectedCategory = category }
                    }
                }
            }
        }
    }
    
    private var sortPicker: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: { sortOption = option }) {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                Text(sortOption.rawValue)
            }
            .font(AppTypography.caption)
            .foregroundColor(AppTheme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppTheme.cardBackground)
            )
        }
    }
    
    private var clothingList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    ClothingListCard(item: item) {
                        selectedItem = item
                        showingDetail = true
                    } onWash: {
                        withAnimation {
                            dataManager.markAsWashed(item)
                        }
                    }
                    .opacity(animateCards ? 1 : 0)
                    .offset(x: animateCards ? 0 : 50)
                    .animation(.spring().delay(Double(index) * 0.03), value: animateCards)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
    }
    
    private func categoryColor(for category: ClothingCategory) -> Color {
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
}

struct ClothingListCard: View {
    let item: ClothingItem
    let onTap: () -> Void
    let onWash: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: item.imageSymbol)
                        .font(.title2)
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(AppTypography.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 8) {
                        Label(item.category.rawValue, systemImage: item.category.icon)
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        if item.washCount > 0 {
                            Text("• \(item.washCount) washes")
                                .font(AppTypography.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    
                    if let days = item.daysSinceWash {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(daysColor(days))
                                .frame(width: 8, height: 8)
                            
                            Text(daysText(days))
                                .font(AppTypography.caption)
                                .foregroundColor(daysColor(days))
                        }
                    } else {
                        Text("Never washed")
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                
                Spacer()
                
                Button(action: onWash) {
                    VStack(spacing: 4) {
                        Image(systemName: "bubbles.and.sparkles")
                            .font(.title2)
                            .foregroundColor(AppTheme.neonCyan)
                        
                        Text("Wash")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.neonCyan.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .glassCard(cornerRadius: 18)
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
    
    private func daysColor(_ days: Int) -> Color {
        if days <= 3 {
            return AppTheme.neonGreen
        } else if days <= 7 {
            return AppTheme.neonYellow
        } else if days <= 14 {
            return AppTheme.neonOrange
        } else {
            return AppTheme.error
        }
    }
    
    private func daysText(_ days: Int) -> String {
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Yesterday"
        } else {
            return "\(days) days ago"
        }
    }
}

#Preview {
    WardrobeView(dataManager: DataManager.shared)
}
