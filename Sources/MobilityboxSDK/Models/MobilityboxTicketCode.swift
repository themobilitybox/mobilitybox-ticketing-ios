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
    public let couponCode: String?
    public let ticketId: String
    public var product: MobilityboxProduct?
    
    public init(ticketId: String, couponCode: String, product: MobilityboxProduct) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponCode = couponCode
        self.product = product
    }
    
    public func fetchTicket(completion: @escaping (MobilityboxTicket) -> ()) {
        let url = URL(string: "https://api-integration.themobilitybox.com/v2/ticketing/tickets/\(self.ticketId).json")!
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
            
            if httpResponse.statusCode == 404 {
                // Retry:
                if #available(iOS 10.0, *) {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false){_ in
                        print("Ticket not available ... retry")
                        self.fetchTicket(completion: completion)
                    }
                } else {
                    //DO fucking nothing because it sucks // TODO: REMOVE THIS COMMENT
                }
                // FIXME: Try it a maximum of 30 Seconds or so
                return
            } else {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        let api_result = try! JSONDecoder().decode(MobilityboxTicketFetchDecoder.self, from: data)
                        
                        DispatchQueue.main.async {
                            completion(api_result.ticketObject())
                        }
                    }
                } else {
                    print("Fetching Ticket returend an unknown status code: \(String(describing: response))")
                    return
                }
            }
        })
        task.resume()
    }
}

