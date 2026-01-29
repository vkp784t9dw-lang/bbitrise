import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var clothingItems: [ClothingItem] = []
    @Published var supplies: [Supply] = []
    @Published var washCycles: [WashCycle] = []
    @Published var washerTimer: TimerState = TimerState(type: .wash)
    @Published var dryerTimer: TimerState = TimerState(type: .dry)
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    @Published var vibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(vibrationEnabled, forKey: "vibrationEnabled")
        }
    }
    
    private var washerTimerCancellable: AnyCancellable?
    private var dryerTimerCancellable: AnyCancellable?
    
    private let notificationManager = NotificationManager.shared
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        
        loadData()
    }
    
    func addClothingItem(_ item: ClothingItem) {
        clothingItems.append(item)
        saveData()
        if vibrationEnabled {
            notificationManager.vibrateLight()
        }
    }
    
    func updateClothingItem(_ item: ClothingItem) {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems[index] = item
            saveData()
        }
    }
    
    func deleteClothingItem(_ item: ClothingItem) {
        clothingItems.removeAll { $0.id == item.id }
        saveData()
    }
    
    func markAsWashed(_ item: ClothingItem) {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems[index].lastWashed = Date()
            clothingItems[index].washCount += 1
            saveData()
            if vibrationEnabled {
                notificationManager.vibrateSuccess()
            }
        }
    }
    
    func addSupply(_ supply: Supply) {
        supplies.append(supply)
        saveData()
        if vibrationEnabled {
            notificationManager.vibrateLight()
        }
    }
    
    func updateSupply(_ supply: Supply) {
        if let index = supplies.firstIndex(where: { $0.id == supply.id }) {
            supplies[index] = supply
            saveData()
        }
    }
    
    func deleteSupply(_ supply: Supply) {
        supplies.removeAll { $0.id == supply.id }
        saveData()
    }
    
    func useSupply(_ supply: Supply, amount: Double) {
        if let index = supplies.firstIndex(where: { $0.id == supply.id }) {
            supplies[index].remainingPercent = max(0, supplies[index].remainingPercent - amount)
            saveData()
            if vibrationEnabled {
                notificationManager.vibrateLight()
            }
        }
    }
    
    var lowSupplies: [Supply] {
        supplies.filter { $0.isLow }
    }
    
    func addWashCycle(_ cycle: WashCycle) {
        washCycles.insert(cycle, at: 0)
        saveData()
    }
    
    var recentCycles: [WashCycle] {
        Array(washCycles.prefix(10))
    }
    
    @MainActor func startWasherTimer(seconds: Int) {
        washerTimer = TimerState(isRunning: true, remainingSeconds: seconds, totalSeconds: seconds, startTime: Date(), type: .wash)
        
        if notificationsEnabled {
            notificationManager.scheduleWasherNotification(in: seconds)
        }
        
        if vibrationEnabled {
            notificationManager.vibrateMedium()
        }
        
        washerTimerCancellable?.cancel()
        washerTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.washerTimer.isRunning else { return }
                if self.washerTimer.remainingSeconds > 0 {
                    self.washerTimer.remainingSeconds -= 1
                } else {
                    self.completeWasherTimer()
                }
            }
    }
    
    private func completeWasherTimer() {
        washerTimer.isRunning = false
        washerTimerCancellable?.cancel()
        
        addWashCycle(WashCycle(duration: TimeInterval(washerTimer.totalSeconds), type: .wash))
        
        if vibrationEnabled {
            notificationManager.vibrateSuccess()
        }
    }
    
    @MainActor func stopWasherTimer() {
        washerTimer.isRunning = false
        washerTimerCancellable?.cancel()
        
        notificationManager.cancelWasherNotification()
        
        if vibrationEnabled {
            notificationManager.vibrateWarning()
        }
    }
    
    @MainActor func resetWasherTimer() {
        stopWasherTimer()
        washerTimer = TimerState(type: .wash)
    }
    
    @MainActor func startDryerTimer(seconds: Int) {
        dryerTimer = TimerState(isRunning: true, remainingSeconds: seconds, totalSeconds: seconds, startTime: Date(), type: .dry)
        
        if notificationsEnabled {
            notificationManager.scheduleDryerNotification(in: seconds)
        }
        
        if vibrationEnabled {
            notificationManager.vibrateMedium()
        }
        
        dryerTimerCancellable?.cancel()
        dryerTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.dryerTimer.isRunning else { return }
                if self.dryerTimer.remainingSeconds > 0 {
                    self.dryerTimer.remainingSeconds -= 1
                } else {
                    self.completeDryerTimer()
                }
            }
    }
    
    private func completeDryerTimer() {
        dryerTimer.isRunning = false
        dryerTimerCancellable?.cancel()
        
        addWashCycle(WashCycle(duration: TimeInterval(dryerTimer.totalSeconds), type: .dry))
        
        if vibrationEnabled {
            notificationManager.vibrateSuccess()
        }
    }
    
    @MainActor func stopDryerTimer() {
        dryerTimer.isRunning = false
        dryerTimerCancellable?.cancel()
        
        notificationManager.cancelDryerNotification()
        
        if vibrationEnabled {
            notificationManager.vibrateWarning()
        }
    }
    
    @MainActor func resetDryerTimer() {
        stopDryerTimer()
        dryerTimer = TimerState(type: .dry)
    }
    
    func getStatistics() -> LaundryStatistics {
        let washCyclesOnly = washCycles.filter { $0.type == .wash }
        let dryCyclesOnly = washCycles.filter { $0.type == .dry }
        
        let calendar = Calendar.current
        let now = Date()
        let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!
        
        let thisMonthWashes = washCyclesOnly.filter { $0.date >= thisMonthStart }.count
        let lastMonthWashes = washCyclesOnly.filter { $0.date >= lastMonthStart && $0.date < thisMonthStart }.count
        
        let oldestCycle = washCyclesOnly.min(by: { $0.date < $1.date })
        let weeksSinceStart = oldestCycle.map { 
            max(1, calendar.dateComponents([.weekOfYear], from: $0.date, to: now).weekOfYear ?? 1) 
        } ?? 1
        let avgPerWeek = Double(washCyclesOnly.count) / Double(weeksSinceStart)
        
        let categoryCount = Dictionary(grouping: clothingItems, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.washCount } }
        let mostWashed = categoryCount.max(by: { $0.value < $1.value })?.key
        
        return LaundryStatistics(
            totalWashes: washCyclesOnly.count,
            totalDries: dryCyclesOnly.count,
            clothesWashed: clothingItems.reduce(0) { $0 + $1.washCount },
            suppliesUsed: supplies.count,
            mostWashedCategory: mostWashed,
            averageWashesPerWeek: avgPerWeek,
            thisMonthWashes: thisMonthWashes,
            lastMonthWashes: lastMonthWashes
        )
    }
    
    private func saveData() {
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(clothingItems) {
            UserDefaults.standard.set(encoded, forKey: "clothingItems")
        }
        if let encoded = try? encoder.encode(supplies) {
            UserDefaults.standard.set(encoded, forKey: "supplies")
        }
        if let encoded = try? encoder.encode(washCycles) {
            UserDefaults.standard.set(encoded, forKey: "washCycles")
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "clothingItems"),
           let decoded = try? decoder.decode([ClothingItem].self, from: data) {
            clothingItems = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "supplies"),
           let decoded = try? decoder.decode([Supply].self, from: data) {
            supplies = decoded
        }
        if let data = UserDefaults.standard.data(forKey: "washCycles"),
           let decoded = try? decoder.decode([WashCycle].self, from: data) {
            washCycles = decoded
        }
    }
}
