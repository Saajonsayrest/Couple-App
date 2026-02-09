import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CoupleEntry {
        CoupleEntry(date: Date(), name1: "?", name2: "?", initial1: "?", initial2: "?", days: "—")
    }

    func getSnapshot(in context: Context, completion: @escaping (CoupleEntry) -> ()) {
        let entry = CoupleEntry(date: Date(), name1: "?", name2: "?", initial1: "?", initial2: "?", days: "—")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Read data from UserDefaults (shared with Flutter app)
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.coupleApp")
        
        let name1 = sharedDefaults?.string(forKey: "name1") ?? "Setup"
        let name2 = sharedDefaults?.string(forKey: "name2") ?? "App"
        let initial1 = sharedDefaults?.string(forKey: "initial1") ?? "?"
        let initial2 = sharedDefaults?.string(forKey: "initial2") ?? "?"
        let days = sharedDefaults?.string(forKey: "days") ?? "—"
        
        let entry = CoupleEntry(
            date: Date(),
            name1: name1,
            name2: name2,
            initial1: initial1,
            initial2: initial2,
            days: days
        )
        
        // Update once per day
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct CoupleEntry: TimelineEntry {
    let date: Date
    let name1: String
    let name2: String
    let initial1: String
    let initial2: String
    let days: String
}

struct CoupleWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Background matching Android (solid white with rounded corners)
            Color.white
            
            VStack(spacing: 12) {
                // Avatars Row with Heart
                HStack(spacing: 10) {
                    // Avatar 1 with white border
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 75, height: 75)
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "0DFF6B6B")) // Semi-transparent pink matching Android
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "20FF6B6B"), lineWidth: 1)
                                )
                                .frame(width: 67, height: 67)
                            
                            Text(entry.initial1)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        }
                    }
                    
                    // Heart Icon with line
                    VStack(spacing: 2) {
                        Text("❤️")
                            .font(.system(size: 28))
                        
                        Rectangle()
                            .fill(Color(hex: "1AFF6B6B")) // Semi-transparent pink matching Android
                            .frame(width: 32, height: 3)
                            .cornerRadius(2)
                    }
                    
                    // Avatar 2 with white border
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 75, height: 75)
                        
                        ZStack {
                            Circle()
                                .fill(Color(hex: "0D4ECDC4")) // Semi-transparent teal matching Android
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "204ECDC4"), lineWidth: 1)
                                )
                                .frame(width: 67, height: 67)
                            
                            Text(entry.initial2)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "4ECDC4"))
                        }
                    }
                }
                
                // Names
                Text("\(entry.name1) & \(entry.name2)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .lineLimit(1)
                
                // Counter Area
                VStack(spacing: 4) {
                    // Large Day Counter
                    Text(entry.days)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(Color(hex: "FF6B6B"))
                    
                    // Days Together Pill - matching Android's semi-transparent background
                    Text("Days Together")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "0DFF6B6B")) // Semi-transparent pink matching Android
                        )
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        .cornerRadius(20)
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
        .supportedFamilies([.systemMedium])
    }
}

struct CoupleWidget_Previews: PreviewProvider {
    static var previews: some View {
        CoupleWidgetEntryView(entry: CoupleEntry(date: Date(), name1: "John", name2: "Jane", initial1: "J", initial2: "J", days: "365"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
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
