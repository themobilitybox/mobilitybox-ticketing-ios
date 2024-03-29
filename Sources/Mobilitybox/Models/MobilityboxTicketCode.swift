//
//  File.swift
//  
//
//  Created by René Meye on 05.06.22.
//

import Foundation

public class MobilityboxTicketCode: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxTicketCode, rhs: MobilityboxTicketCode) -> Bool {
        lhs.ticketId == rhs.ticketId
    }
    
    public let id: String
    public let ticketId: String
    public var product: MobilityboxProduct?
    
    public init(ticketId: String, product: MobilityboxProduct) {
        self.id = ticketId
        self.ticketId = ticketId
        self.product = product
    }
    
    public init(ticketId: String) {
        self.id = ticketId
        self.ticketId = ticketId
        self.product = nil
    }
    
    public func fetchTicket(onSuccess completion: @escaping (MobilityboxTicket) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/tickets/\(self.ticketId).json")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpMethod = "PATCH"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                if failure != nil {
                    failure!(MobilityboxError.unkown)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if failure != nil {
                    failure!(MobilityboxError.unkown)
                }
                return
            }
            
            if httpResponse.statusCode == 202 {
                if failure != nil {
                    failure!(MobilityboxError.retry_later)
                }
                return
            } else if httpResponse.statusCode == 200 {
                if let data = data {
                    let ticket = try! JSONDecoder().decode(MobilityboxTicket.self, from: data)
                    ticket.createdAt = Date()
                    ticket.wasReactivated = false
                    DispatchQueue.main.async {
                        completion(ticket)
                    }
                }
            } else {
                if failure != nil {
                    failure!(MobilityboxError.unkown)
                }
                return
            }
        })
        task.resume()
    }
}

