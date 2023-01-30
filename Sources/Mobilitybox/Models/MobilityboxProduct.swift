import Foundation

public struct MobilityboxProduct: Codable, Identifiable {
    public var id: String
    public var recommended_successor_is: String?
    public var recommended_successor_of: String?
    public var local_ticket_name: String
    public var local_validity_description: String
    public var ticket_type: String
    public var customer_type: String
    public var price_in_cents: Int
    public var currency: String
    public var duration_definition: String
    public var duration_in_minutes: Int?
    public var validity_in_minutes: Int?
    public var area_id: String
    public var is_subscription: Bool
    public var identification_medium_schema: IdentificationMediumSchema
    
    public func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? " Erwachsener" : ((customer_type == "child" ? " Kind" : "")))
        let ticket_type_string = (ticket_type == "single" ? "Einzelticket" : ((ticket_type == "day" ? "Tagesticket" : "")))
        return "\(ticket_type_string)\(customer_type_string)"
    }
    
    public func getDescription() -> String {
        switch duration_definition {
        case "duration_in_minutes":
            if duration_in_minutes != nil {
                let validity_time_string = (duration_in_minutes! > 90 ? "\(duration_in_minutes! / 60) Stunden" : "\(duration_in_minutes!) Minuten")
                return "Dieses Ticket ist nach dem Aktivieren \(validity_time_string) gültig."
            } else {
                return ""
            }
        default:
            return ""
        }
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
    public var duration_definition: String
    public var duration_in_minutes: Int?
    public var validity_in_minutes: Int?
    public var local_validity_description: String
    public var is_subscription: Bool

    func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? " Erwachsener" : ((customer_type == "child" ? " Kind" : "")))
        let ticket_type_string = (ticket_type == "single" ? "Einzelticket" : ((ticket_type == "day" ? "Tagesticket" : "")))
        return "\(ticket_type_string)\(customer_type_string)"
    }
}
