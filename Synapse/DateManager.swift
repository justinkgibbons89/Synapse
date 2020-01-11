import Foundation

class DateManager {
    
    //MARK: Configuration
    internal static let standardFormat = "E, d MMM yyyy HH:mm:ss Z"
    internal static let locale = Locale(identifier: "en_US_POSIX")
    
    //MARK: Parsing
    static func parse(_ rawDate: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = standardFormat
        formatter.locale = locale
        guard let result = formatter.date(from: rawDate) else {
            throw DateError.unidentifiableFormat(rawDate)
        }
        return result
    }
}

enum DateError: Error {
	case unidentifiableFormat(String)
}
