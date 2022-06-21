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
    
    init(id: String, product: MobilityboxOrderedProduct, ticket: MobilityboxTicketDetails){
        self.id = id
        self.product = product
        self.ticket = ticket
    }
    
    public let id: String
    public let product: MobilityboxOrderedProduct
    public let ticket: MobilityboxTicketDetails
}

struct MobilityboxTicketFetchDecoder: Codable {
    let id: String
    let product: MobilityboxOrderedProduct
    let ticket: MobilityboxTicketDetails
    let area: MobilityboxTicketArea
    let valid_from: String
    let valid_until: String
    let ticket_created_at: String
    
    public func ticketObject() -> MobilityboxTicket {
        
        return MobilityboxTicket(id: id, product: product, ticket: ticket)
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

public struct MobilityboxTicketArea: Codable {
    public let id: String
    public let properties: MobilityboxTicketAreaProperties
}

public struct MobilityboxTicketAreaProperties: Codable {
    public let city_name: String
    public let local_zone_name: String
    public let geojson: MobilityboxJSONValue
}
