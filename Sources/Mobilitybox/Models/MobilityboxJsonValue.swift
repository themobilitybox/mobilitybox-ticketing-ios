import Foundation

public indirect enum MobilityboxJSONValue: Decodable {
    case double(Double)
    case string(String)
    case bool(Bool)
    case dictionary([String: MobilityboxJSONValue])
    case array([MobilityboxJSONValue])
    case `nil`

    public init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        if let value = try? singleValueContainer.decode(Bool.self) {
            self = .bool(value)
            return
        } else if let value = try? singleValueContainer.decode(String.self) {
            self = .string(value)
            return
        } else if let value = try? singleValueContainer.decode(Double.self) {
            self = .double(value)
            return
        } else if let value = try? singleValueContainer.decode([String: MobilityboxJSONValue].self) {
            self = .dictionary(value)
            return
        } else if let value = try? singleValueContainer.decode([MobilityboxJSONValue].self) {
            self = .array(value)
            return
        } else if singleValueContainer.decodeNil() {
            self = .nil
            return
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not find reasonable type to map to JSONValue"))
    }
}


extension MobilityboxJSONValue {
    public var string: String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    public var double: Double? {
        switch self {
        case .double(let value):
            return value
        default:
            return nil
        }
    }
    public var bool: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }
    public var dictionary: [String: MobilityboxJSONValue]? {
        switch self {
        case .dictionary(let value):
            return value
        default:
            return nil
        }
    }
    public var array: [MobilityboxJSONValue]? {
        switch self {
        case .array(let value):
            return value
        default:
            return nil
        }
    }
    public var isNil: Bool {
        switch self {
        case .nil:
            return true
        default:
            return false
        }
    }
}

extension MobilityboxJSONValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try? container.encode(value as String)
        case .double(let value):
            try? container.encode(value as Double)
        case .bool(let value):
            try? container.encode(value as Bool)
        case .dictionary(let value):
            try? container.encode(value as Dictionary)
        case .array(let value):
            try? container.encode(value as Array)
        case .nil:
            try? container.encodeNil()
        }
    }
}
