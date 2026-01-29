import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    DashboardView(dataManager: dataManager, selectedTab: $selectedTab)
                case 1:
                    TimersView(dataManager: dataManager)
                case 2:
                    SuppliesView(dataManager: dataManager)
                case 3:
                    WardrobeView(dataManager: dataManager)
                case 4:
                    MoreView(dataManager: dataManager)
                default:
                    DashboardView(dataManager: dataManager, selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
