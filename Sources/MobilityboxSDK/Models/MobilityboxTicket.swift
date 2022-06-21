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
    let product: MobilityboxOrderedProduct
    let ticket: MobilityboxTicketDetails
}

struct MobilityboxTicketFetchDecoder: Codable {
    let id: String
    let product: MobilityboxOrderedProduct
    let ticket: MobilityboxTicketDetails
    
    public func ticketObject() -> MobilityboxTicket {
        return MobilityboxTicket(id: id, product: product, ticket: ticket)
    }
}

struct MobilityboxTicketDetails: Codable {
    public let meta: MobilityboxTicketMetaDetails
    public let properties: JSONValue?
}

struct MobilityboxTicketMetaDetails: Codable {
    public let version: String
    public let template: String
    public let requires_engine: String
}

