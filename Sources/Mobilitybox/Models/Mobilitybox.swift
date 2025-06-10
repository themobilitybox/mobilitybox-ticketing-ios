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
            self.apiURL = "https://api.themobilitybox.com/v8"
        }
    }
}

public enum MobilityboxError: Error {
    case unkown, retry_later, not_reactivatable, identification_medium_not_valid, tariff_settings_not_valid, coupon_expired, pkpass_not_possible, pkpass_not_available, before_earliest_activation_start_datetime, coupon_activation_expired, coupon_activation_activatable_until_expired
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
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let timeInterval: DateComponentsFormatter = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "de")
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.day, .hour, .minute]
        
        return formatter
    }()

}
