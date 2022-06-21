import Foundation

public struct MobilityboxProduct: Codable, Identifiable {
    public var id: String
    public var local_ticket_name: String
    public var local_validity_description: String
    public var ticket_type: String
    public var customer_type: String
    public var price_in_cents: Int
    public var currency: String
    public var validity_in_minutes: Int
    public var area_id: String
    public var identification_medium_schema: IdentificationMediumSchema
}
public struct MobilityboxOrderedProduct: Codable {
    public var id: String
    public var area_id: String
    public var local_ticket_name: String
    public var local_validity_description: String
    public var ticket_type: String
    public var customer_type: String
    public var price_in_cents: Int
    public var currency: String
    public var validity_in_minutes: Int
}
