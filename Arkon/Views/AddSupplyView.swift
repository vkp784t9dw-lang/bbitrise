import SwiftUI

struct AddSupplyView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedType: SupplyType = .detergent
    @State private var remainingPercent: Double = 100
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        previewCard
                        
                        inputSection(title: "Name") {
                            TextField("Supply name", text: $name)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        inputSection(title: "Type") {
                            typeSelector
                        }
                        
                        inputSection(title: "Remaining: \(Int(remainingPercent))%") {
                            amountSlider
                        }
                        
                        inputSection(title: "Notes") {
                            TextField("Additional info...", text: $notes, axis: .vertical)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(3...6)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        Button(action: saveSupply) {
                            Text("Add Supply")
                        }
                        .buttonStyle(GradientButtonStyle(gradient: AppTheme.greenGradient))
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Supply")
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
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType.color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: selectedType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(selectedType.color)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(name.isEmpty ? "Name" : name)
                    .font(AppTypography.headline)
                    .foregroundColor(name.isEmpty ? AppTheme.textMuted : AppTheme.textPrimary)
                
                Text(selectedType.rawValue)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                
                HStack(spacing: 8) {
                    ProgressView(value: remainingPercent / 100)
                        .tint(selectedType.color)
                    
                    Text("\(Int(remainingPercent))%")
                        .font(AppTypography.caption)
                        .foregroundColor(selectedType.color)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .glassCard()
    }
    
    private var typeSelector: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(SupplyType.allCases, id: \.self) { type in
                Button(action: { 
                    withAnimation(.spring()) {
                        selectedType = type
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.title2)
                            .foregroundColor(selectedType == type ? .white : type.color)
                        
                        Text(type.rawValue)
                            .font(AppTypography.caption)
                            .foregroundColor(selectedType == type ? .white : AppTheme.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedType == type ? type.color : AppTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(type.color.opacity(0.3), lineWidth: selectedType == type ? 0 : 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var amountSlider: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach([25, 50, 75, 100], id: \.self) { percent in
                    Button(action: {
                        withAnimation(.spring()) {
                            remainingPercent = Double(percent)
                        }
                    }) {
                        Text("\(percent)%")
                            .font(AppTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Int(remainingPercent) == percent ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Int(remainingPercent) == percent ? selectedType.color : AppTheme.cardBackground)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: 16) {
                Image(systemName: "drop")
                    .foregroundColor(AppTheme.textMuted)
                
                Slider(value: $remainingPercent, in: 0...100, step: 5)
                    .tint(selectedType.color)
                
                Image(systemName: "drop.fill")
                    .foregroundColor(selectedType.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassCard(cornerRadius: 12)
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
    
    private func saveSupply() {
        let supply = Supply(
            name: name,
            type: selectedType,
            remainingPercent: remainingPercent,
            notes: notes
        )
        dataManager.addSupply(supply)
        dismiss()
    }
}

struct EditSupplyView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let supply: Supply
    
    @State private var name: String
    @State private var selectedType: SupplyType
    @State private var remainingPercent: Double
    @State private var notes: String
    
    init(dataManager: DataManager, supply: Supply) {
        self.dataManager = dataManager
        self.supply = supply
        self._name = State(initialValue: supply.name)
        self._selectedType = State(initialValue: supply.type)
        self._remainingPercent = State(initialValue: supply.remainingPercent)
        self._notes = State(initialValue: supply.notes)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        inputSection(title: "Name") {
                            TextField("Supply name", text: $name)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        inputSection(title: "Remaining: \(Int(remainingPercent))%") {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    ForEach([0, 25, 50, 75, 100], id: \.self) { percent in
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                remainingPercent = Double(percent)
                                            }
                                        }) {
                                            Text("\(percent)%")
                                                .font(AppTypography.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Int(remainingPercent) == percent ? .white : AppTheme.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(Int(remainingPercent) == percent ? selectedType.color : AppTheme.cardBackground)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                HStack(spacing: 16) {
                                    Image(systemName: "drop")
                                        .foregroundColor(AppTheme.textMuted)
                                    
                                    Slider(value: $remainingPercent, in: 0...100, step: 5)
                                        .tint(selectedType.color)
                                    
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(selectedType.color)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .glassCard(cornerRadius: 12)
                            }
                        }
                        
                        inputSection(title: "Notes") {
                            TextField("Additional info...", text: $notes, axis: .vertical)
                                .font(AppTypography.body)
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(3...6)
                                .padding(16)
                                .glassCard(cornerRadius: 12)
                        }
                        
                        Button(action: saveChanges) {
                            Text("Save Changes")
                        }
                        .buttonStyle(GradientButtonStyle(gradient: AppTheme.primaryGradient))
                        .padding(.top, 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Supply")
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
    
    private func inputSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            content()
        }
    }
    
    private func saveChanges() {
        var updatedSupply = supply
        updatedSupply.name = name
        updatedSupply.type = selectedType
        updatedSupply.remainingPercent = remainingPercent
        updatedSupply.notes = notes
        
        dataManager.updateSupply(updatedSupply)
        dismiss()
    }
}

#Preview {
    AddSupplyView(dataManager: DataManager.shared)
}
