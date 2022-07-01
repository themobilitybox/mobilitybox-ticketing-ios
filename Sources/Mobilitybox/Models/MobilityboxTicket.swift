//
//  File.swift
//  
//
//  Created by René Meye on 05.06.22.
//

import Foundation

public class MobilityboxTicket: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxTicket, rhs: MobilityboxTicket) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: String
    public let product: MobilityboxOrderedProduct
    public let ticket: MobilityboxTicketDetails
    public let area: MobilityboxTicketArea
    public let valid_from: String
    public let valid_until: String
    public let ticket_created_at: String
    
    
    func getTitle() -> String {
        return "\(area.properties.city_name) - \(product.getTitle())"
    }
    
    func getDescription() -> String {
        let valid_from_formatted = MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: valid_from)!)
        let valid_until_formatted = MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: valid_until)!)
        
        return "valid from:\t\(valid_from_formatted)\nvalid until:\t\(valid_until_formatted)\nin Zone:\t\(area.properties.local_zone_name)"
    }
    
    public func isValid() -> Bool {
        return MobilityboxFormatter.isoDateTime.date(from: valid_until)! >= Date()
    }
}

public struct MobilityboxTicketDetails: Codable {
    public let meta: MobilityboxTicketMetaDetails
    public let properties: MobilityboxJSONValue?
}

public struct MobilityboxTicketMetaDetails: Codable {
    public let version: String?
    public let template: String
    public let requires_engine: String
}
