import Foundation

public struct MobilityboxAPI: Codable {
    public var apiURL: String = "https://api-integration.themobilitybox.com/v2"
    public var renderEngineURL: String = "https://ticket-rendering-engine-integration.themobilitybox.com"
    
    public init() {}
    
    public init(apiURL: String) {
        self.apiURL = apiURL
    }
    
    public init(apiURL: String, renderEngineURL: String) {
        self.apiURL = apiURL
        self.renderEngineURL = renderEngineURL
    }
}


struct MobilityboxFormatter {

    static let shortDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "dd. MMMM, HH:mm"
        return formatter
    }()
    
    static let isoDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

}
