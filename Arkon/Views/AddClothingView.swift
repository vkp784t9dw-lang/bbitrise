import SwiftUI

struct AddClothingView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory: ClothingCategory = .tops
    @State private var color = ""
    @State private var notes = ""
    @State private var selectedIcon = "tshirt"
    
    let availableIcons = [
        "tshirt", "tshirt.fill", "figure.stand", "figure.run", 
        "bag", "bag.fill", "hanger", "bed.double", "bed.double.fill",
        "humidity", "cloud", "sun.max", "sparkles"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        previewCard
                        
                        inputSection(title: "Name") {
                            TextField("e.g. White T-Shirt", text: $name)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        inputSection(title: "Category") {
                            categorySelector
                        }
                        
                        inputSection(title: "Icon") {
                            iconSelector
                        }
                        
                        inputSection(title: "Color") {
                            colorInput
                        }
                        
                        inputSection(title: "Notes") {
                            TextField("Care instructions...", text: $notes, axis: .vertical)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(3...6)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        Button(action: saveClothing) {
                            Text("Add to Wardrobe")
                        }
                        .buttonStyle(GradientButtonStyle(gradient: AppTheme.pinkGradient))
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: selectedIcon)
                    .font(.system(size: 36))
                    .foregroundColor(categoryColor)
            }
            
            Text(name.isEmpty ? "Item Name" : name)
                .font(AppTypography.headline)
                .foregroundColor(name.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
            
            HStack(spacing: 16) {
                Label(selectedCategory.rawValue, systemImage: selectedCategory.icon)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                
                if !color.isEmpty {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(guessColor(color))
                            .frame(width: 12, height: 12)
                        Text(color)
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassCard()
    }
    
    private var categorySelector: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(ClothingCategory.allCases, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedCategory = category
                        selectedIcon = category.icon
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundColor(selectedCategory == category ? .white : categoryColorFor(category))
                        
                        Text(category.rawValue)
                            .font(AppTypography.subheadline)
                            .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedCategory == category ? categoryColorFor(category) : AppTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(categoryColorFor(category).opacity(0.3), lineWidth: selectedCategory == category ? 0 : 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var iconSelector: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(availableIcons, id: \.self) { icon in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedIcon = icon
                    }
                }) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(selectedIcon == icon ? .white : categoryColor)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedIcon == icon ? categoryColor : AppTheme.cardBackground)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
    }
    
    private var colorInput: some View {
        VStack(spacing: 12) {
            TextField("White, Black, Blue...", text: $color)
                .font(AppTypography.body)
                .foregroundColor(AppTheme.textPrimary)
                .padding(16)
                .glassCard(cornerRadius: 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["White", "Black", "Gray", "Blue", "Red", "Green", "Yellow"], id: \.self) { colorName in
                        Button(action: { color = colorName }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(guessColor(colorName))
                                    .frame(width: 16, height: 16)
                                Text(colorName)
                            }
                            .font(AppTypography.caption)
                            .foregroundColor(color == colorName ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(color == colorName ? categoryColor.opacity(0.8) : AppTheme.cardBackground)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            content()
        }
    }
    
    private var categoryColor: Color {
        categoryColorFor(selectedCategory)
    }
    
    private func categoryColorFor(_ category: ClothingCategory) -> Color {
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
    
    private func guessColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "white": return .white
        case "black": return .black
        case "gray", "grey": return .gray
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        case "orange": return .orange
        case "purple": return .purple
        default: return .gray
        }
    }
    
    private func saveClothing() {
        let item = ClothingItem(
            name: name,
            category: selectedCategory,
            color: color,
            notes: notes,
            imageSymbol: selectedIcon
        )
        dataManager.addClothingItem(item)
        dismiss()
    }
}

struct ClothingDetailView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let item: ClothingItem
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroCard
                        statsSection
                        lastWashSection
                        actionsSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppTheme.error)
                    }
                }
            }
            .alert("Delete Item?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteClothingItem(item)
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone")
            }
        }
        .preferredColorScheme(.dark)
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
    
    private var heroCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: item.imageSymbol)
                    .font(.system(size: 44))
                    .foregroundColor(categoryColor)
                    .neonGlow(categoryColor, radius: 10)
            }
            
            Text(item.name)
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack(spacing: 16) {
                Label(item.category.rawValue, systemImage: item.category.icon)
                
                if !item.color.isEmpty {
                    Text("•")
                    Text(item.color)
                }
            }
            .font(AppTypography.subheadline)
            .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .glassCard()
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatBox(
                title: "Total Washes",
                value: "\(item.washCount)",
                icon: "bubbles.and.sparkles",
                color: AppTheme.neonCyan
            )
            
            StatBox(
                title: "Days Ago",
                value: item.daysSinceWash.map { "\($0)" } ?? "-",
                icon: "calendar",
                color: AppTheme.neonPurple
            )
        }
    }
    
    private var lastWashSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Wash")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(categoryColor)
                
                if let lastWashed = item.lastWashed {
                    Text(lastWashed, style: .date)
                        .foregroundColor(AppTheme.textSecondary)
                } else {
                    Text("Never washed")
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
            }
            .font(AppTypography.body)
            .padding(16)
            .glassCard(cornerRadius: 12)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                dataManager.markAsWashed(item)
            }) {
                HStack {
                    Image(systemName: "bubbles.and.sparkles")
                    Text("Mark as Washed")
                }
            }
            .buttonStyle(GradientButtonStyle(gradient: AppTheme.primaryGradient))
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .glassCard()
    }
}

#Preview {
    AddClothingView(dataManager: DataManager.shared)
}
