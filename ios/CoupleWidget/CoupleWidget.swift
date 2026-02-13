//
//  CoupleWidget.swift
//  CoupleWidget
//
//  Created by Sajon Shrestha on 12/02/2026.
//

import WidgetKit
import SwiftUI

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CoupleEntry {
        CoupleEntry(date: Date(), name1: "?", name2: "?", initial1: "?", initial2: "?", days: "—", avatar1Path: nil, avatar2Path: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CoupleEntry) -> ()) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = createEntry()
        
        // Update at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let midnight = calendar.startOfDay(for: tomorrow)
        
        // Create a timeline that refreshes at midnight
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        
        completion(timeline)
    }
    
    private func createEntry() -> CoupleEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.sajon.coupleApp")
        
        // Force synchronize to ensure we have latest data
        // sharedDefaults?.synchronize() // Removed to prevent blocking
        
        let name1 = sharedDefaults?.string(forKey: "name1") ?? "Setup"
        let name2 = sharedDefaults?.string(forKey: "name2") ?? "App"
        let initial1 = sharedDefaults?.string(forKey: "initial1") ?? "?"
        let initial2 = sharedDefaults?.string(forKey: "initial2") ?? "?"
        let startDateMillis = sharedDefaults?.object(forKey: "startDate") as? Int ?? 0
        let avatar1Path = sharedDefaults?.string(forKey: "avatar1Path")
        let avatar2Path = sharedDefaults?.string(forKey: "avatar2Path")
        
        // Debug logging
        print("Widget - Name1: \(name1), Name2: \(name2)")
        print("Widget - Avatar1Path: \(avatar1Path ?? "nil"), Avatar2Path: \(avatar2Path ?? "nil")")
        print("Widget - StartDate: \(startDateMillis)")
        
        // Calculate days dynamically
        var days = "—"
        if startDateMillis > 0 {
            let startDate = Date(timeIntervalSince1970: TimeInterval(startDateMillis) / 1000)
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            let nowOfDay = calendar.startOfDay(for: Date())
            
            if let diff = calendar.dateComponents([.day], from: startOfDay, to: nowOfDay).day {
                days = "\(diff + 1)"
            }
        }
        
        return CoupleEntry(
            date: Date(),
            name1: name1,
            name2: name2,
            initial1: initial1,
            initial2: initial2,
            days: days,
            avatar1Path: avatar1Path,
            avatar2Path: avatar2Path
        )
    }
}

struct CoupleEntry: TimelineEntry {
    let date: Date
    let name1: String
    let name2: String
    let initial1: String
    let initial2: String
    let days: String
    let avatar1Path: String?
    let avatar2Path: String?
}

struct CoupleWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    Color.white
                }
        } else {
            content
                .background(Color.white)
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
                if family == .systemSmall {
                    // Simplified "Days Together" Layout for 1x1/2x2 Widget
                    VStack(spacing: 8) {
                        Text(entry.days)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("Days Together")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "33FF6B6B"))
                            )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Full Couple Card Layout for Medium Widget
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Avatars Row with Heart
                        HStack(spacing: 0) {
                            Spacer()
                            
                            // Avatar 1 with white border
                            ZStack {
                                // White border circle
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 58, height: 58)
                                
                                if let avatar1Path = entry.avatar1Path, !avatar1Path.isEmpty,
                                   let uiImage = loadImage(from: avatar1Path) {
                                    // User's image
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 52, height: 52)
                                        .clipShape(Circle())
                                } else {
                                    // Fallback: Initial with gradient background
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "33FF6B6B"))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: "60FF6B6B"), lineWidth: 1)
                                            )
                                            .frame(width: 52, height: 52)
                                        
                                        Text(entry.initial1)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(Color(hex: "FF6B6B"))
                                    }
                                }
                            }
                            
                            // Heart Icon with decorative line
                            VStack(spacing: 2) {
                                Text("❤️")
                                    .font(.system(size: 20))
                                
                                Rectangle()
                                    .fill(Color(hex: "50FF6B6B"))
                                    .frame(width: 24, height: 3)
                                    .cornerRadius(1.5)
                            }
                            .padding(.horizontal, 12)
                            
                            // Avatar 2 with white border
                            ZStack {
                                // White border circle
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 58, height: 58)
                                
                                if let avatar2Path = entry.avatar2Path, !avatar2Path.isEmpty,
                                   let uiImage = loadImage(from: avatar2Path) {
                                    // User's image
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 52, height: 52)
                                        .clipShape(Circle())
                                } else {
                                    // Fallback: Initial with gradient background
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "334ECDC4"))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(hex: "604ECDC4"), lineWidth: 1)
                                            )
                                            .frame(width: 52, height: 52)
                                        
                                        Text(entry.initial2)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(Color(hex: "4ECDC4"))
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Spacer().frame(height: 4)
                        
                        // Names - centered
                        Text("\(entry.name1) & \(entry.name2)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer().frame(height: 4)
                        
                        // Counter Area - centered
                        VStack(spacing: 4) {
                            // Large Day Counter
                            Text(entry.days)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            // Days Together Pill
                            Text("Days Together")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "33FF6B6B"))
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                    }

                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .forcedUnredacted()
    }
}

@main
struct CoupleWidget: Widget {
    let kind: String = "CoupleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoupleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Couple Widget")
        .description("Track your days together")
        .supportedFamilies([.systemMedium, .systemSmall, .systemLarge])
    }
}

struct CoupleWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoupleWidgetEntryView(entry: CoupleEntry(date: Date(), name1: "John", name2: "Jane", initial1: "J", initial2: "J", days: "365", avatar1Path: nil, avatar2Path: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            CoupleWidgetEntryView(entry: CoupleEntry(date: Date(), name1: "John", name2: "Jane", initial1: "J", initial2: "J", days: "365", avatar1Path: nil, avatar2Path: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

// Helper modifier to force unredacted content
extension View {
    func forcedUnredacted() -> some View {
        if #available(iOS 14.5, *) {
            return self.unredacted()
        } else {
            return self
        }
    }
}

// Helper function to load image from file path
func loadImage(from path: String) -> UIImage? {
    let fileManager = FileManager.default
    
    // Try direct path first
    if fileManager.fileExists(atPath: path) {
        return UIImage(contentsOfFile: path)
    }
    
    // Try app group container path
    if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.sajon.coupleApp") {
        let fullPath = containerURL.appendingPathComponent(path).path
        if fileManager.fileExists(atPath: fullPath) {
            return UIImage(contentsOfFile: fullPath)
        }
    }
    
    return nil
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
