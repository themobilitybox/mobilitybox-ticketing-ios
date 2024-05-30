//
//  File.swift
//  
//
//  Created by René Meye on 05.06.22.
//

import Foundation
import PassKit

public class MobilityboxTicket: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxTicket, rhs: MobilityboxTicket) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: String
    public var coupon_id: String
    public var coupon_reactivation_key: String?
    public var product: MobilityboxOrderedProduct
    public var ticket: MobilityboxTicketDetails
    public var area: MobilityboxTicketArea
    public var valid_from: String
    public var valid_until: String
    public var ticket_created_at: String
    public var sold_at: String
    public var environment: String
    public var createdAt: Date? = Date()
    var wasReactivated: Bool? = false
    
    public func getTitle() -> String {
        return "\(area.properties.city_name) - \(product.getTitle())"
    }
    
    public func validity() -> MobilityboxTicketValidity {
        if MobilityboxFormatter.isoDateTime.date(from: self.valid_until)! < Date() {
            return .expired
        } else if MobilityboxFormatter.isoDateTime.date(from: self.valid_from)! > Date() {
            return .future
        } else {
            return .valid
        }
    }
    
    func getAddedAgoText() -> String? {
        if (self.createdAt == nil) {
            return nil
        }
        
        let currentDate = Date()
        let delta = currentDate - self.createdAt!
        
        return MobilityboxFormatter.timeInterval.string(from: delta)!
    }
    
    public func reactivate(onSuccess completion: @escaping ((MobilityboxTicketCode) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        if self.product.is_subscription && self.coupon_reactivation_key != nil && !self.wasReactivated! {
            self.fetchCouponAndReactivate(onSuccess: completion, onFailure: failure)
        } else {
            DispatchQueue.main.async { failure?(.not_reactivatable) }
        }
    }
    
    public func getPKPass(onSuccess completion: @escaping ((PKPass) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        self.getAvailableRenderingOptions { availableRenderingOptions in
            if (availableRenderingOptions.contains("apple_wallet")) {
                self.fetchPKPass(onSuccess: completion, onFailure: failure)
            } else {
                if (failure != nil) {
                    failure!(.pkpass_not_possible)
                }
            }
        } onFailure: { error in
            if (failure != nil) {
                failure!(.pkpass_not_possible)
            }
        }
    }
    
    public func getAvailableRenderingOptions(onSuccess completion: @escaping (([String]) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        if (self.ticket.meta.available_rendering_options != nil) {
            completion(self.ticket.meta.available_rendering_options!)
        } else {
            fetchAvailableRenderingOptions(onSuccess: completion, onFailure: failure)
        }
    }
    
    func fetchAvailableRenderingOptions(onSuccess completion: @escaping (([String]) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/tickets/\(self.id)/available_rendering_options.json")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                if (failure != nil) {
                    failure!(.unkown)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                if (failure != nil) {
                    failure!(.unkown)
                }
                return
            }
            if let data = data {
                let availableRenderingOptions = try! JSONDecoder().decode([String]?.self, from: data)
                DispatchQueue.main.async {
                    completion(availableRenderingOptions ?? [])
                }
            } else {
                if (failure != nil) {
                    failure!(.unkown)
                }
            }
        })
        task.resume()
    }
    
    func fetchCouponAndReactivate(onSuccess completion: @escaping ((MobilityboxTicketCode) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        MobilityboxCouponCode(couponId: self.coupon_id).fetchCoupon { fetchedCoupon in
            if (fetchedCoupon.subscription != nil && fetchedCoupon.subscription!.coupon_reactivatable) {
                self.reactivateFetchedCoupon(fetchedCoupon: fetchedCoupon, onSuccess: completion, onFailure: failure)
            } else {
                DispatchQueue.main.async { failure?(.not_reactivatable) }
            }
        } onFailure: { mobilityboxError in
            DispatchQueue.main.async { failure?(mobilityboxError) }
        }
    }
    
    func reactivateFetchedCoupon(fetchedCoupon: MobilityboxCoupon, onSuccess completion: @escaping ((MobilityboxTicketCode) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        fetchedCoupon.reactivate(reactivation_key: self.coupon_reactivation_key!) { fetchedTicketCode in
            print("Reactivated Ticket id: \(fetchedTicketCode.ticketId)")
            DispatchQueue.main.async {
                completion(fetchedTicketCode)
                self.wasReactivated = true
            }
        } onFailure: { mobilityboxError in
            DispatchQueue.main.async { failure?(mobilityboxError) }
        }
    }
    
    func fetchPKPass(onSuccess completion: @escaping ((PKPass) -> Void), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/passes/apple_wallet/\(self.id).pkpass")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                if (failure != nil) {
                    failure!(.pkpass_not_available)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                if (failure != nil) {
                    failure!(.pkpass_not_available)
                }
                return
            }
            
            if let data = data {
                let pkpass = try! PKPass(data: data)
                DispatchQueue.main.async {
                    completion(pkpass)
                }
            } else {
                if (failure != nil) {
                    failure!(.pkpass_not_available)
                }
            }
        })
        task.resume()
    }
    
    
}

public enum MobilityboxTicketValidity {
    case valid, expired, future
}

public struct MobilityboxTicketDetails: Codable {
    public let meta: MobilityboxTicketMetaDetails
    public let properties: MobilityboxJSONValue?
}

public struct MobilityboxTicketMetaDetails: Codable {
    public let version: String?
    public let template: String
    public let requires_engine: String
    public let available_rendering_options: [String]?
}
