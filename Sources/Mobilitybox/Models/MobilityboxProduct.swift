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
    
    public func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? " Erwachsener" : ((customer_type == "child" ? " Kind" : "")))
        let ticket_type_string = (ticket_type == "single" ? "Einzelticket" : ((ticket_type == "day" ? "Tagesticket" : "")))
        return "\(ticket_type_string)\(customer_type_string)"
    }
    
    public func getDescription() -> String {
        let validity_time_string = (validity_in_minutes > 90 ? "\(validity_in_minutes / 60) Stunden" : "\(validity_in_minutes) Minuten")
        return "Dieses Ticket ist nach dem Entwerten \(validity_time_string) gültig."
    }
}
public struct MobilityboxOrderedProduct: Codable {
    public var id: String
    public var area_id: String
    public var currency: String
    public var ticket_type: String
    public var customer_type: String
    public var price_in_cents: Int
    public var local_ticket_name: String
    public var validity_in_minutes: Int
    public var local_validity_description: String

    func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? " Erwachsener" : ((customer_type == "child" ? " Kind" : "")))
        let ticket_type_string = (ticket_type == "single" ? "Einzelticket" : ((ticket_type == "day" ? "Tagesticket" : "")))
        return "\(ticket_type_string)\(customer_type_string)"
    }
}
