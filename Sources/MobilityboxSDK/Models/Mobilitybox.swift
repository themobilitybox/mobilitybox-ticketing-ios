import Foundation

public struct MobilityboxAPI: Codable {
    public var apiURL: String = "https://api-integration.themobilitybox.com/v2"
    public var renderEngineURL: String = "https://ticket-rendering-engine-integration.themobilitybox.com"
    
    public init() {}
    
    public init(apiURL: String) {
        self.apiURL = apiURL
    }
}
