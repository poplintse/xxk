import Foundation

enum AppVersionInfo {
    static var displayString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let buildDate = (try? Bundle.main.bundleURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .now
        return displayString(version: version, build: build, date: buildDate)
    }

    static func displayString(version: String, build: String, date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "MMddHHmm"
        return "v\(version) build \(build)（\(formatter.string(from: date))）"
    }
}
