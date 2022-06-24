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
    public let couponId: String?
    public let ticketId: String
    public var product: MobilityboxProduct?
    let mobilityboxAPI: MobilityboxAPI
    var fetch_counter = 0
    
    public init(ticketId: String, couponId: String, product: MobilityboxProduct) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponId = couponId
        self.product = product
        self.mobilityboxAPI = MobilityboxAPI()
    }
    
    public init(ticketId: String, couponId: String, product: MobilityboxProduct, mobilityboxAPI: MobilityboxAPI) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponId = couponId
        self.product = product
        self.mobilityboxAPI = mobilityboxAPI
    }
    
    public init(ticketId: String) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponId = nil
        self.product = nil
        self.mobilityboxAPI = MobilityboxAPI()
    }
    
    public init(ticketId: String, mobilityboxAPI: MobilityboxAPI) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponId = nil
        self.product = nil
        self.mobilityboxAPI = mobilityboxAPI
    }
    
    public func fetchTicket(completion: @escaping (MobilityboxTicket) -> ()) {
        self.fetch_counter += 1
        if self.fetch_counter > 5 {
            print("canceling ticket fetch (too many retries)")
            self.fetch_counter = 0
            return
        }
        
        print("fetch ticket - try count: \(self.fetch_counter)")
        
        let url = URL(string: "\(mobilityboxAPI.apiURL)/ticketing/tickets/\(self.ticketId).json")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpMethod = "PATCH"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error fetching ticket: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error with HTTP Connection: \(String(describing: response))")
                return
            }
            
            if httpResponse.statusCode == 202 {
                // Retry:
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.async {
                        Timer.scheduledTimer(withTimeInterval: TimeInterval(2.0), repeats: false){_ in
                            print("Ticket not available ... retry")
                            self.fetchTicket(completion: completion)
                        }
                    }
                } else {}
                return
            } else if httpResponse.statusCode == 200 {
                if let data = data {
                    let ticket = try! JSONDecoder().decode(MobilityboxTicket.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(ticket)
                    }
                }
            } else {
                print("Fetching Ticket returend an unknown status code: \(String(describing: response))")
                return
            }
            self.fetch_counter = 0
        })
        task.resume()
    }
}

