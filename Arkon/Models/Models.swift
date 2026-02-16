import Foundation
import SwiftUI

struct ClothingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: ClothingCategory
    var color: String
    var lastWashed: Date?
    var washCount: Int
    var notes: String
    var imageSymbol: String
    
    init(id: UUID = UUID(), name: String, category: ClothingCategory, color: String, lastWashed: Date? = nil, washCount: Int = 0, notes: String = "", imageSymbol: String = "tshirt") {
        self.id = id
        self.name = name
        self.category = category
        self.color = color
        self.lastWashed = lastWashed
        self.washCount = washCount
        self.notes = notes
        self.imageSymbol = imageSymbol
    }
    
    var daysSinceWash: Int? {
        guard let lastWashed = lastWashed else { return nil }
        return Calendar.current.dateComponents([.day], from: lastWashed, to: Date()).day
    }
}

enum ClothingCategory: String, Codable, CaseIterable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case outerwear = "Outerwear"
    case underwear = "Underwear"
    case sportswear = "Sportswear"
    case accessories = "Accessories"
    case bedding = "Bedding"
    case towels = "Towels"
    
    var icon: String {
        switch self {
        case .tops: return "tshirt"
        case .bottoms: return "figure.stand"
        case .outerwear: return "cloud.snow"
        case .underwear: return "heart"
        case .sportswear: return "figure.run"
        case .accessories: return "bag"
        case .bedding: return "bed.double"
        case .towels: return "humidity"
        }
    }
}

struct Supply: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: SupplyType
    var remainingPercent: Double
    var purchaseDate: Date
    var notes: String
    
    init(id: UUID = UUID(), name: String, type: SupplyType, remainingPercent: Double = 100, purchaseDate: Date = Date(), notes: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.remainingPercent = remainingPercent
        self.purchaseDate = purchaseDate
        self.notes = notes
    }
    
    var isLow: Bool {
        remainingPercent < 25
    }
}

enum SupplyType: String, Codable, CaseIterable {
    case detergent = "Detergent"
    case liquidDetergent = "Liquid Detergent"
    case conditioner = "Fabric Softener"
    case stainRemover = "Stain Remover"
    case bleach = "Bleach"
    case capsules = "Pods"
    case dryerSheets = "Dryer Sheets"
    
    var icon: String {
        switch self {
        case .detergent: return "sparkles"
        case .liquidDetergent: return "drop.fill"
        case .conditioner: return "wind"
        case .stainRemover: return "wand.and.stars"
        case .bleach: return "sun.max.fill"
        case .capsules: return "capsule"
        case .dryerSheets: return "doc.plaintext"
        }
    }
    
    var color: Color {
        switch self {
        case .detergent: return .cyan
        case .liquidDetergent: return .blue
        case .conditioner: return .pink
        case .stainRemover: return .orange
        case .bleach: return .yellow
        case .capsules: return .purple
        case .dryerSheets: return .mint
        }
    }
}

struct WashCycle: Identifiable, Codable {
    let id: UUID
    var date: Date
    var duration: TimeInterval
    var temperature: WashTemperature
    var items: [UUID]
    var suppliesUsed: [UUID]
    var type: CycleType
    var notes: String
    
    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval = 3600, temperature: WashTemperature = .warm, items: [UUID] = [], suppliesUsed: [UUID] = [], type: CycleType = .wash, notes: String = "") {
        self.id = id
        self.date = date
        self.duration = duration
        self.temperature = temperature
        self.items = items
        self.suppliesUsed = suppliesUsed
        self.type = type
        self.notes = notes
    }
}

enum WashTemperature: String, Codable, CaseIterable {
    case cold = "Cold"
    case warm = "Warm"
    case hot = "Hot"
    
    var icon: String {
        switch self {
        case .cold: return "snowflake"
        case .warm: return "thermometer.medium"
        case .hot: return "flame"
        }
    }
    
    var degrees: String {
        switch self {
        case .cold: return "68°F"
        case .warm: return "104°F"
        case .hot: return "140°F"
        }
    }
}

enum CycleType: String, Codable, CaseIterable {
    case wash = "Wash"
    case dry = "Dry"
    
    var icon: String {
        switch self {
        case .wash: return "washer"
        case .dry: return "dryer"
        }
    }
}

struct TimerState: Codable {
    var isRunning: Bool
    var remainingSeconds: Int
    var totalSeconds: Int
    var startTime: Date?
    var type: CycleType
    
    init(isRunning: Bool = false, remainingSeconds: Int = 0, totalSeconds: Int = 3600, startTime: Date? = nil, type: CycleType = .wash) {
        self.isRunning = isRunning
        self.remainingSeconds = remainingSeconds
        self.totalSeconds = totalSeconds
        self.startTime = startTime
        self.type = type
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    var formattedTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct WashProgram: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let temperature: WashTemperature
    let icon: String
    
    static let presets: [WashProgram] = [
        WashProgram(name: "Quick", duration: 900, temperature: .cold, icon: "hare"),
        WashProgram(name: "Cotton", duration: 5400, temperature: .hot, icon: "leaf"),
        WashProgram(name: "Synthetic", duration: 3600, temperature: .warm, icon: "sparkle"),
        WashProgram(name: "Delicate", duration: 2700, temperature: .cold, icon: "hands.sparkles"),
        WashProgram(name: "Wool", duration: 2400, temperature: .cold, icon: "cloud"),
        WashProgram(name: "Intensive", duration: 7200, temperature: .hot, icon: "bolt"),
    ]
}

struct DryProgram: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let icon: String
    
    static let presets: [DryProgram] = [
        DryProgram(name: "Quick", duration: 1800, icon: "hare"),
        DryProgram(name: "Cotton", duration: 3600, icon: "leaf"),
        DryProgram(name: "Synthetic", duration: 2700, icon: "sparkle"),
        DryProgram(name: "Delicate", duration: 2400, icon: "hands.sparkles"),
        DryProgram(name: "Towels", duration: 4500, icon: "humidity"),
        DryProgram(name: "Refresh", duration: 900, icon: "wind"),
    ]
}

struct LaundryStatistics {
    var totalWashes: Int
    var totalDries: Int
    var clothesWashed: Int
    var suppliesUsed: Int
    var mostWashedCategory: ClothingCategory?
    var averageWashesPerWeek: Double
    var thisMonthWashes: Int
    var lastMonthWashes: Int
}
