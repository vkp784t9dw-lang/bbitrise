import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    @State private var targetUrlString: String?
    @State private var configState: ConfigRetrievalState = .pending
    @State private var currentViewState: ApplicationViewState = .initialScreen
    
    
    var body: some View {
        
        ZStack {
            switch currentViewState {
            case .initialScreen:
                SplashScreenView()
                    .preferredColorScheme(.dark)
                   
                
            case .primaryInterface:
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
                    
                
            case .browserContent(let urlString):
                if let validUrl = URL(string: urlString) {
                    BrowserContentView(targetUrl: validUrl.absoluteString)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    Text("Invalid URL")
                }
                
            case .failureMessage(let errorMessage):
                VStack(spacing: 20) {
                    Text("Error")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(errorMessage)
                    Button("Retry") {
                        Task { await fetchConfigurationAndNavigate() }
                    }
                }
                .padding()
            }
        }
        .task {
            await fetchConfigurationAndNavigate()
        }
        .onChange(of: configState, initial: true) { oldValue, newValue in
            if case .completed = newValue, let url = targetUrlString, !url.isEmpty {
                Task {
                    await verifyUrlAndNavigate(targetUrl: url)
                }
            }
        }
        
        
//        ZStack(alignment: .bottom) {
//            Group {
//                switch selectedTab {
//                case 0:
//                    DashboardView(dataManager: dataManager, selectedTab: $selectedTab)
//                case 1:
//                    TimersView(dataManager: dataManager)
//                case 2:
//                    SuppliesView(dataManager: dataManager)
//                case 3:
//                    WardrobeView(dataManager: dataManager)
//                case 4:
//                    MoreView(dataManager: dataManager)
//                default:
//                    DashboardView(dataManager: dataManager, selectedTab: $selectedTab)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            CustomTabBar(selectedTab: $selectedTab)
//        }
//        .ignoresSafeArea(.keyboard)
//        .preferredColorScheme(.dark)
    }
    
    private func fetchConfigurationAndNavigate() async {
        await MainActor.run { currentViewState = .initialScreen }
        
        let (url, state) = await DynamicConfigService.instance.retrieveTargetUrl()
        print("URL: \(url)")
        print("State: \(state)")
        
        await MainActor.run {
            self.targetUrlString = url
            self.configState = state
        }
        
        if url == nil || url?.isEmpty == true {
            navigateToPrimaryInterface()
        }
    }
    
    private func navigateToPrimaryInterface() {
        withAnimation {
            currentViewState = .primaryInterface
        }
    }
    
    private func verifyUrlAndNavigate(targetUrl: String) async {
        guard let url = URL(string: targetUrl) else {
            navigateToPrimaryInterface()
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        urlRequest.timeoutInterval = 10
        
        do {
            let (_, httpResponse) = try await URLSession.shared.data(for: urlRequest)
            
            if let response = httpResponse as? HTTPURLResponse,
               (200...299).contains(response.statusCode) {
                await MainActor.run {
                    currentViewState = .browserContent(targetUrl)
                }
            } else {
                navigateToPrimaryInterface()
            }
        } catch {
            navigateToPrimaryInterface()
        }
    }
}
