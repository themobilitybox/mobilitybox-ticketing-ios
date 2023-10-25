import Foundation

public struct MobilityboxTariffSettings: Codable {
    let tariff_settings_json: String
    
    public init(tariff_settings_json: String){
        self.tariff_settings_json = tariff_settings_json
    }
    
    public func getTariffSettings() -> MobilityboxJSONValue? {
        if let decodedData = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: self.tariff_settings_json.data(using: .utf8)!) {
            return decodedData
        } else {
            return nil
        }
    }
}
