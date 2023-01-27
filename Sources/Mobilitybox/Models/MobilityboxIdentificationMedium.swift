import Foundation

public struct MobilityboxIdentificationMedium: Codable {
    let identification_medium_json: String
    
    public init(identification_medium_json: String){
        self.identification_medium_json = identification_medium_json
    }
    
    public func getIdentificationMedium() -> MobilityboxJSONValue? {
        if let decodedData = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: self.identification_medium_json.data(using: .utf8)!) {
            return decodedData
        } else {
            return nil
        }
    }
}
