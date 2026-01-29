import SwiftUI

struct DryerTimerView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedProgram: DryProgram? = DryProgram.presets.first
    @State private var customMinutes: Int = 45
    @State private var showingCustomTime = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    headerView
                    timerDisplay
                    controlButtons
                    
                    if !dataManager.dryerTimer.isRunning {
                        programSelection
                    }
                    
                    if showingCustomTime && !dataManager.dryerTimer.isRunning {
                        customTimeSelector
                    }
                    
                    if !dataManager.dryerTimer.isRunning {
                        dryingTips
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "dryer.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.neonOrange)
                .neonGlow(AppTheme.neonOrange, radius: 10)
            
            Text("Dryer")
                .font(AppTypography.title)
                .foregroundColor(AppTheme.textPrimary)
            
            if dataManager.dryerTimer.isRunning {
                Text("Drying in progress...")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppTheme.neonOrange)
            } else {
                Text("Select a mode")
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
                    AngularGradient(
                        colors: [
                            AppTheme.neonOrange.opacity(0.3),
                            AppTheme.neonYellow.opacity(0.2),
                            AppTheme.neonOrange.opacity(0.3),
                            AppTheme.neonYellow.opacity(0.2),
                            AppTheme.neonOrange.opacity(0.3)
                        ],
                        center: .center
                    ),
                    lineWidth: 25
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(rotationAngle))
            
            TimerRing(
                progress: dataManager.dryerTimer.progress,
                color: AppTheme.neonOrange,
                lineWidth: 14
            )
            .frame(width: 240, height: 240)
            
            VStack(spacing: 8) {
                if dataManager.dryerTimer.isRunning || dataManager.dryerTimer.remainingSeconds > 0 {
                    Text(dataManager.dryerTimer.formattedTime)
                        .font(AppTypography.timerLarge)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                    
                    if dataManager.dryerTimer.isRunning {
                        HeatAnimation()
                            .frame(width: 80, height: 40)
                    }
                } else if let program = selectedProgram {
                    Text(formatDuration(program.duration))
                        .font(AppTypography.timerMedium)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: program.icon)
                        Text(program.name)
                    }
                    .font(AppTypography.headline)
                    .foregroundColor(AppTheme.neonOrange)
                } else {
                    Text(formatDuration(customMinutes * 60))
                        .font(AppTypography.timerMedium)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(20)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            if dataManager.dryerTimer.isRunning {
                Button(action: { dataManager.stopDryerTimer() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                }
                .buttonStyle(NeonButtonStyle(color: AppTheme.error))
                
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppTheme.neonOrange)
                    Text("Running")
                        .foregroundColor(AppTheme.neonOrange)
                }
                .font(AppTypography.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(AppTheme.neonOrange.opacity(0.2))
                )
                .pulsing()
            } else {
                if dataManager.dryerTimer.remainingSeconds > 0 {
                    Button(action: { dataManager.resetDryerTimer() }) {
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
                .buttonStyle(GradientButtonStyle(gradient: AppTheme.dryerGradient))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var programSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Drying Modes")
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
                    .foregroundColor(showingCustomTime ? AppTheme.neonOrange : AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DryProgram.presets) { program in
                        DryProgramButton(
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
    
    private var dryingTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Tips")
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TipCard(
                        icon: "thermometer.sun",
                        title: "Don't Over-Dry",
                        text: "Slightly damp clothes are easier to iron"
                    )
                    
                    TipCard(
                        icon: "hanger",
                        title: "Shake It Out",
                        text: "Shake clothes before drying"
                    )
                    
                    TipCard(
                        icon: "tshirt",
                        title: "Sort Fabrics",
                        text: "Dry similar fabrics together"
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func startTimer() {
        let seconds: Int
        if let program = selectedProgram {
            seconds = program.duration
        } else {
            seconds = customMinutes * 60
        }
        
        guard seconds > 0 else { return }
        dataManager.startDryerTimer(seconds: seconds)
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

struct HeatAnimation: View {
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundColor(index % 2 == 0 ? AppTheme.neonOrange : AppTheme.neonYellow)
                    .offset(y: animate ? -5 : 5)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.neonOrange)
                
                Spacer()
            }
            
            Text(title)
                .font(AppTypography.headline)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(text)
                .font(AppTypography.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(width: 160)
        .glassCard(cornerRadius: 16)
    }
}

#Preview {
    DryerTimerView(dataManager: DataManager.shared)
}
