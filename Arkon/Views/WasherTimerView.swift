import SwiftUI

struct WasherTimerView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedProgram: WashProgram? = WashProgram.presets.first
    @State private var customMinutes: Int = 60
    @State private var showingCustomTime = false
    @State private var animateRing = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    headerView
                    timerDisplay
                    controlButtons
                    
                    if !dataManager.washerTimer.isRunning {
                        programSelection
                    }
                    
                    if showingCustomTime && !dataManager.washerTimer.isRunning {
                        customTimeSelector
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "washer.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.neonCyan)
                .neonGlow(AppTheme.neonCyan, radius: 10)
            
            Text("Washing Machine")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            if dataManager.washerTimer.isRunning {
                Text("Washing in progress...")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.neonCyan)
            } else {
                Text("Select a program")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var timerDisplay: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.neonCyan.opacity(0.1), AppTheme.neonPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 30
                )
                .frame(width: 280, height: 280)
            
            TimerRing(
                progress: dataManager.washerTimer.progress,
                color: AppTheme.neonCyan,
                lineWidth: 14
            )
            .frame(width: 240, height: 240)
            
            VStack(spacing: 8) {
                if dataManager.washerTimer.isRunning || dataManager.washerTimer.remainingSeconds > 0 {
                    Text(dataManager.washerTimer.formattedTime)
                        .font(AppTypography.timerLarge)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                    
                    if dataManager.washerTimer.isRunning {
                        WashingAnimation()
                            .frame(width: 60, height: 30)
                    }
                } else if let program = selectedProgram {
                    Text(formatDuration(program.duration))
                        .font(AppTypography.timerMedium)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: program.temperature.icon)
                        Text(program.temperature.degrees)
                    }
                    .font(AppTypography.headline)
                    .foregroundColor(AppTheme.neonCyan)
                } else {
                    Text(formatDuration(customMinutes * 60))
                        .font(AppTypography.timerMedium)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            if dataManager.washerTimer.isRunning {
                Circle()
                    .fill(AppTheme.neonCyan)
                    .frame(width: 16, height: 16)
                    .offset(y: -120)
                    .rotationEffect(.degrees(animateRing ? 360 : 0))
                    .neonGlow(AppTheme.neonCyan, radius: 8)
            }
        }
        .padding(20)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                animateRing = true
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            if dataManager.washerTimer.isRunning {
                Button(action: { dataManager.stopWasherTimer() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                }
                .buttonStyle(NeonButtonStyle(color: AppTheme.error))
                
                Text("Running")
                    .font(AppTypography.caption)
                    .foregroundColor(AppTheme.neonGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppTheme.neonGreen.opacity(0.2))
                    )
                    .pulsing()
            } else {
                if dataManager.washerTimer.remainingSeconds > 0 {
                    Button(action: { dataManager.resetWasherTimer() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                    }
                    .buttonStyle(NeonButtonStyle(color: AppTheme.textMuted))
                }
                
                Button(action: startTimer) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                }
                .buttonStyle(GradientButtonStyle(gradient: AppTheme.primaryGradient))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var programSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Programs")
                    .font(AppTypography.title3)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.spring()) {
                        showingCustomTime.toggle()
                        if showingCustomTime {
                            selectedProgram = nil
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: showingCustomTime ? "clock.fill" : "clock")
                        Text("Custom")
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(showingCustomTime ? AppTheme.neonPink : AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WashProgram.presets) { program in
                        WashProgramButton(
                            program: program,
                            isSelected: selectedProgram?.id == program.id
                        ) {
                            withAnimation(.spring()) {
                                selectedProgram = program
                                showingCustomTime = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var customTimeSelector: some View {
        VStack(spacing: 20) {
            Text("Set Time")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textSecondary)
            
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Hours")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textMuted)
                    
                    Picker("Hours", selection: Binding(
                        get: { customMinutes / 60 },
                        set: { customMinutes = $0 * 60 + (customMinutes % 60) }
                    )) {
                        ForEach(0..<4) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()
                }
                
                Text(":")
                    .font(AppTypography.timerMedium)
                    .foregroundColor(AppTheme.textMuted)
                
                VStack(spacing: 8) {
                    Text("Minutes")
                        .font(AppTypography.caption)
                        .foregroundColor(AppTheme.textMuted)
                    
                    Picker("Minutes", selection: Binding(
                        get: { customMinutes % 60 },
                        set: { customMinutes = (customMinutes / 60) * 60 + $0 }
                    )) {
                        ForEach(0..<60) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()
                }
            }
            .padding(20)
            .glassCard()
        }
        .padding(.horizontal, 20)
    }
    
    private func startTimer() {
        let seconds: Int
        if let program = selectedProgram {
            seconds = program.duration
        } else {
            seconds = customMinutes * 60
        }
        
        guard seconds > 0 else { return }
        dataManager.startWasherTimer(seconds: seconds)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

struct WashingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(AppTheme.neonCyan)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    WasherTimerView(dataManager: DataManager.shared)
}
