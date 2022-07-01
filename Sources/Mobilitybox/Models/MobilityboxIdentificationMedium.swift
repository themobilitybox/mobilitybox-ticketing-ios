import Foundation

public struct MobilityboxIdentificationMedium: Codable {
    let identification_medium_json: String
    
    public init(identification_medium_json: String){
        self.identification_medium_json = identification_medium_json
    }
}
