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
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.coupleApp")
        
        let name1 = sharedDefaults?.string(forKey: "name1") ?? "Setup"
        let name2 = sharedDefaults?.string(forKey: "name2") ?? "App"
        let initial1 = sharedDefaults?.string(forKey: "initial1") ?? "?"
        let initial2 = sharedDefaults?.string(forKey: "initial2") ?? "?"
        let startDateMillis = sharedDefaults?.object(forKey: "startDate") as? Int ?? 0
        let avatar1Path = sharedDefaults?.string(forKey: "avatar1Path")
        let avatar2Path = sharedDefaults?.string(forKey: "avatar2Path")
        
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
        ZStack {
            // Background matching Android (solid white with rounded corners)
            Color.white
            
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
                                .fill(Color(hex: "0DFF6B6B"))
                        )
                }
                .padding()
            } else {
                // Full Couple Card Layout for Medium Widget
                VStack(spacing: 12) {
                    // Avatars Row with Heart
                    HStack(spacing: 10) {
                        // Avatar 1 with white border
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 75, height: 75)
                            
                            if let avatar1Path = entry.avatar1Path, !avatar1Path.isEmpty,
                               let uiImage = loadImage(from: avatar1Path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 67, height: 67)
                                    .clipShape(Circle())
                            } else {
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
                            
                            if let avatar2Path = entry.avatar2Path, !avatar2Path.isEmpty,
                               let uiImage = loadImage(from: avatar2Path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 67, height: 67)
                                    .clipShape(Circle())
                            } else {
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
        .supportedFamilies([.systemMedium, .systemSmall])
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

// Helper function to load image from file path
func loadImage(from path: String) -> UIImage? {
    let fileManager = FileManager.default
    
    // Try direct path first
    if fileManager.fileExists(atPath: path) {
        return UIImage(contentsOfFile: path)
    }
    
    // Try app group container path
    if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.coupleApp") {
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
