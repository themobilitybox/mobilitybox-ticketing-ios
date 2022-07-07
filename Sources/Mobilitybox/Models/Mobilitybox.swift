import Foundation

public class MobilityboxAPI: Codable {
    public static let shared = MobilityboxAPI()
    
    public struct Config {
        var apiURL: String
        var renderEngineURL: String
        
        public init(apiURL: String, renderEngineURL: String) {
            self.apiURL = apiURL
            self.renderEngineURL = renderEngineURL
        }
    }
    
    private static var config: Config?
    
    public let apiURL: String
    public let renderEngineURL: String
    
    public class func setup(_ config: Config){
        MobilityboxAPI.config = config
    }
    
    private init() {
        if let config = try? MobilityboxAPI.config {
            self.apiURL = config.apiURL
            self.renderEngineURL = config.renderEngineURL
        } else {
            self.apiURL = "https://api-integration.themobilitybox.com/v2"
            self.renderEngineURL = "https://ticket-rendering-engine-integration.themobilitybox.com"
        }
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
