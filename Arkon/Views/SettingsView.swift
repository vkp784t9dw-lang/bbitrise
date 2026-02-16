import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var reminderDays = 7
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                        .padding(.top, 20)
                    
                    quickLinksSection
                    notificationsSection
                    remindersSection
                    dataSection
                    aboutSection
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetData()
            }
        } message: {
            Text("All your data will be deleted. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Settings and information")
                .font(AppTypography.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var quickLinksSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                QuickLinkCard(
                    title: "Statistics",
                    icon: "chart.bar.fill",
                    color: AppTheme.neonCyan
                ) {
                }
                
                QuickLinkCard(
                    title: "History",
                    icon: "clock.fill",
                    color: AppTheme.neonPurple
                ) {
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Notifications")
            
            VStack(spacing: 0) {
                if !notificationManager.isAuthorized {
                    Button(action: {
                        notificationManager.requestAuthorization()
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppTheme.warning.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "bell.badge")
                                    .foregroundColor(AppTheme.warning)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enable Notifications")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("Tap to allow notifications")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppTheme.warning)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .background(AppTheme.textMuted.opacity(0.2))
                }
                
                SettingsToggle(
                    title: "Timer Notifications",
                    subtitle: "Get notified when cycle ends",
                    icon: "bell.fill",
                    color: AppTheme.neonPink,
                    isOn: $dataManager.notificationsEnabled
                )
                .disabled(!notificationManager.isAuthorized)
                .opacity(notificationManager.isAuthorized ? 1 : 0.5)
                
                Divider()
                    .background(AppTheme.textMuted.opacity(0.2))
                
                SettingsToggle(
                    title: "Vibration",
                    subtitle: "Haptic feedback on actions",
                    icon: "iphone.radiowaves.left.and.right",
                    color: AppTheme.neonOrange,
                    isOn: $dataManager.vibrationEnabled
                )
            }
            .glassCard(cornerRadius: 16)
            .padding(.horizontal, 20)
        }
    }
    
    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Wash Reminders")
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remind to wash after")
                            .font(AppTypography.body)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("If item hasn't been washed")
                            .font(AppTypography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $reminderDays) {
                        Text("3 days").tag(3)
                        Text("5 days").tag(5)
                        Text("7 days").tag(7)
                        Text("14 days").tag(14)
                        Text("30 days").tag(30)
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.neonCyan)
                }
            }
            .padding(16)
            .glassCard(cornerRadius: 16)
            .padding(.horizontal, 20)
        }
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Data")
            
            VStack(spacing: 0) {
                SettingsRow(
                    title: "Reset Data",
                    subtitle: "Delete all data",
                    icon: "trash.fill",
                    color: AppTheme.error
                ) {
                    showingResetAlert = true
                }
            }
            .glassCard(cornerRadius: 16)
            .padding(.horizontal, 20)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About")
            
            VStack(spacing: 0) {
                SettingsRow(
                    title: "About LaundryMate",
                    subtitle: "App information",
                    icon: "info.circle.fill",
                    color: AppTheme.neonCyan
                ) {
                    showingAbout = true
                }
                
                Divider()
                    .background(AppTheme.textMuted.opacity(0.2))
                
                SettingsRow(
                    title: "Rate App",
                    subtitle: "Leave a review on App Store",
                    icon: "star.fill",
                    color: AppTheme.neonYellow
                ) {
                    requestAppReview()
                }
            }
            .glassCard(cornerRadius: 16)
            .padding(.horizontal, 20)
        }
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func resetData() {
        UserDefaults.standard.removeObject(forKey: "clothingItems")
        UserDefaults.standard.removeObject(forKey: "supplies")
        UserDefaults.standard.removeObject(forKey: "washCycles")
        
        dataManager.clothingItems.removeAll()
        dataManager.supplies.removeAll()
        dataManager.washCycles.removeAll()
        
        dataManager.resetWasherTimer()
        dataManager.resetDryerTimer()
    }
}

struct QuickLinkCard: View {
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
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppTheme.neonCyan)
        }
        .padding(16)
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTypography.body)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.neonCyan, AppTheme.neonPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "washer.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                            .neonGlow(AppTheme.neonCyan, radius: 15)
                            
                            Text("LaundryMate")
                                .font(AppTypography.title)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Your laundry assistant")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, 40)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Features")
                                .font(AppTypography.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            FeatureRow(icon: "timer", title: "Timers", description: "For washer and dryer")
                            FeatureRow(icon: "drop.fill", title: "Supplies", description: "Track laundry supplies")
                            FeatureRow(icon: "tshirt.fill", title: "Wardrobe", description: "Track clothes and washes")
                            FeatureRow(icon: "chart.bar.fill", title: "Statistics", description: "View your activity")
                        }
                        .padding(20)
                        .glassCard()
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.neonCyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.neonCyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

#Preview {
    SettingsView(dataManager: DataManager.shared)
}
