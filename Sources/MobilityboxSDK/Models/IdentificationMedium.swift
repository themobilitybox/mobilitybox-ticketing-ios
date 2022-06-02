import Foundation

enum MobilityboxIdentificationAttribute {
    case string(value: String)
    case int(value: Int)
    case bool(value: Bool)
    case double(value: Double)
    
    func toString() -> String? {
        switch self {
        case .string(value: let value):
            return value
        case .int(value: let value):
            return "\(value)"
        case .bool(value: let value):
            return "\(value)"
        case .double(value: let value):
            return "\(value)"
        }
    }
    
    enum MobilityboxIdentificationAttributeError:Error {
        case missingValue
    }
}

extension MobilityboxIdentificationAttribute: Codable {
    enum CodingKeys: String, CodingKey {
        case string, bool, int, double, value
    }
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode (Int.self) {
            self = .int(value: int)
            return
        }
        if let string = try? decoder.singleValueContainer ().decode (String.self) {
            self = .string (value: string)
            return
        }
        if let bool = try? decoder.singleValueContainer ().decode (Bool.self) {
            self = .bool (value: bool)
            return
        }
        if let double = try? decoder.singleValueContainer ().decode (Double.self) {
            self = .double (value: double)
            return
        }
        
        throw MobilityboxIdentificationAttributeError.missingValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .string(let value):
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode(value, forKey: .value)
        }
    }
}
