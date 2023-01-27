import Foundation

public class Mobilitybox: Codable {
    public static let api = MobilityboxAPI.shared
    public static let renderingEngine = MobilityboxTicketRenderingEngine.shared
    public static let identificationViewEngine = MobilityboxIdentificationViewEngine.shared
    
    private init() { }
    
    public class func setup (apiConfig: MobilityboxAPI.Config? = nil) {
        MobilityboxAPI.setup(apiConfig)
        MobilityboxTicketRenderingEngine.setup()
        MobilityboxIdentificationViewEngine.setup()
    }
}

public class MobilityboxAPI: Codable {
    public static let shared = MobilityboxAPI()
    
    public struct Config {
        var apiURL: String
        
        public init(apiURL: String) {
            self.apiURL = apiURL
        }
    }
    
    private static var config: Config?
    
    public let apiURL: String
    
    public class func setup(_ config: Config? = nil){
        if config != nil {
            MobilityboxAPI.config = config
        }
    }
    
    private init() {
        if MobilityboxAPI.config != nil {
            self.apiURL = MobilityboxAPI.config!.apiURL
        } else {
            self.apiURL = "https://api.themobilitybox.com/v3"
        }
    }
}

public enum MobilityboxError: Error {
    case unkown, retry_later
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
    
    static let timeInterval: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute]
        
        return formatter
    }()

}
