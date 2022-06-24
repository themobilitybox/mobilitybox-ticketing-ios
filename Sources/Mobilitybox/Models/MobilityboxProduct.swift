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
    
    func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? "Adult " : ((customer_type == "child" ? "Child " : "")))
        let ticket_type_string = (ticket_type == "single" ? "Single " : ((ticket_type == "day" ? "Day " : "")))
        return "\(customer_type_string)\(ticket_type_string)Ticket"
    }
    
    func getDescription() -> String {
        let validity_time_string = (validity_in_minutes > 90 ? "\(validity_in_minutes / 60) hours" : "\(validity_in_minutes) minutes")
        return "This Ticket is valid for \(validity_time_string)."
    }
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
    
    func getTitle() -> String {
        let customer_type_string = (customer_type == "adult" ? "Adult " : ((customer_type == "child" ? "Child " : "")))
        let ticket_type_string = (ticket_type == "single" ? "Single " : ((ticket_type == "day" ? "Day " : "")))
        return "\(customer_type_string)\(ticket_type_string)Ticket"
    }
}
