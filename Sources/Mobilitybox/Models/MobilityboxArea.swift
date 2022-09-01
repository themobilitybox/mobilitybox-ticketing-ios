import Foundation

public struct MobilityboxArea: Codable {
    public let id: String
    public var type: String?
    public var properties: MobilityboxAreaProperties
    public var geometry: MobilityboxAreaGeometry
}

public struct MobilityboxAreaProperties: Codable {
    public var city_name: String
    public var local_zone_name: String
}

public struct MobilityboxAreaGeometry: Codable {
    public var type: String
    public var coordinates: MobilityboxJSONValue
}

public struct MobilityboxTicketArea: Codable {
    public let id: String
    public var type: String?
    public var properties: MobilityboxTicketAreaProperties
    public let geojson: MobilityboxJSONValue
}

public struct MobilityboxTicketAreaProperties: Codable {
    public let city_name: String
    public let local_zone_name: String
}
