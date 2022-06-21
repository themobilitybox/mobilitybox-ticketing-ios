import Foundation

struct IdentificationMediumProperty: Codable {
    var type: String
    var title: String
    var examples: [String]?
    var options: [String]?
    var format: String?
    var pattern: String?
    var minLength: Int?
    var maxLength: Int?
    
    enum CodingKeys: String, CodingKey {
        case options = "enum"
        
        case type
        case title
        case examples
        case format
        case pattern
        case minLength
        case maxLength
    }
}

struct IdentificaitonMediumDefinition: Codable {
    var type: String
    var title: String
    var required: [String]
    var properties: [String: IdentificationMediumProperty]
}

struct IdentificationMediumOneOf: Codable {
    var type: String
    var required: [String]
    var properties: [String: [String: String]]
}

public struct IdentificationMediumSchema: Codable {
    var id: String?
    var schema: String
    var type: String
    var oneOf: [IdentificationMediumOneOf]
    var definitions: [String: IdentificaitonMediumDefinition]
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case schema = "$schema"
        
        case type
        case oneOf
        case definitions
    }
}
