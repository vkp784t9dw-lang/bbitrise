import SwiftUI

struct MoreView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedSection: MoreSection = .settings
    
    enum MoreSection: String, CaseIterable {
        case settings = "Settings"
        case statistics = "Statistics"
        case history = "History"
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                sectionPicker
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                TabView(selection: $selectedSection) {
                    SettingsView(dataManager: dataManager)
                        .tag(MoreSection.settings)
                    
                    StatisticsView(dataManager: dataManager)
                        .tag(MoreSection.statistics)
                    
                    HistoryView(dataManager: dataManager)
                        .tag(MoreSection.history)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
    
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(MoreSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedSection = section
                    }
                }) {
                    Text(section.rawValue)
                        .font(AppTypography.subheadline)
                        .foregroundColor(selectedSection == section ? .white : AppTheme.textSecondary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(selectedSection == section ? AppTheme.neonPurple : Color.clear)
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
}

#Preview {
    MoreView(dataManager: DataManager.shared)
}
