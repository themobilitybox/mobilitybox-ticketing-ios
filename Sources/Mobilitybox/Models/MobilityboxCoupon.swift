import Foundation

public class MobilityboxCoupon: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxCoupon, rhs: MobilityboxCoupon) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    public let original_coupon_id: String?
    public let restored_coupon_id: String?
    public var product: MobilityboxProduct
    public var area: MobilityboxArea
    public var activated: Bool
    public var subscription: MobilityboxSubscription?
    public var environment: String
    public var createdAt: Date? = Date()
    
    public init(id: String, original_coupon_id: String? = nil, restored_coupon_id: String? = nil, product: MobilityboxProduct, area: MobilityboxArea, activated: Bool = false, environment: String, createdAt: Date? = nil) {
        self.id = id
        self.original_coupon_id = original_coupon_id
        self.restored_coupon_id = restored_coupon_id
        self.product = product
        self.area = area
        self.activated = activated
        self.environment = environment
        self.createdAt = createdAt
    }
    
    public func activate(identificationMedium: MobilityboxIdentificationMedium, activationStartDateTime: Date? = nil, completion: @escaping (MobilityboxTicketCode) -> ()) {
        
        var body = identificationMedium.getIdentificationMedium()?.dictionary
        if body != nil {
            if activationStartDateTime != nil && self.original_coupon_id == nil {
                let activation_start_datetime = MobilityboxFormatter.isoDateTime.string(from: activationStartDateTime!)
                body!["activation_start_datetime"] = MobilityboxJSONValue.string(activation_start_datetime)
            }
            
            if let bodyJson = try? JSONEncoder().encode(body) {
                activateCall(body: String(data: bodyJson, encoding: .utf8)!, completion: completion)
            }
        }
    }
    
    public func reactivate(reactivation_key: String, completion: @escaping (MobilityboxTicketCode) -> ()) {
        let body: [String: String] = ["reactivation_key": reactivation_key]
        if let bodyJson = try? JSONEncoder().encode(body) {
            activateCall(body: String(data: bodyJson, encoding: .utf8)!, completion: completion)
        }
    }
    
    func activateCall(body: String, completion: @escaping (MobilityboxTicketCode) -> ()) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/coupons/\(self.id)/activate.json")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with activating coupon: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the activating coupon response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
                let couponActivateResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                DispatchQueue.main.async {
                    let ticketId = couponActivateResponse!["ticket_id"] as! String
                    let ticket = MobilityboxTicketCode(ticketId: ticketId, product: self.product)
                    completion(ticket)
                }
            }
        })
        task.resume()
    }
    
    public func update(onSuccess completion: @escaping () -> Void, onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/coupons/\(self.id).json")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                failure?(MobilityboxError.unkown)
                return
            }
            
            if let data = data {
                let updatedCoupon = try! JSONDecoder().decode(MobilityboxCoupon.self, from: data)
                DispatchQueue.main.async {
                    self.product = updatedCoupon.product
                    self.area = updatedCoupon.area
                    self.activated = updatedCoupon.activated
                    self.environment = updatedCoupon.environment
                    completion()
                }
            }
        })
        task.resume()
    }
    
    public func getTitle() -> String {
        return "\(area.properties.city_name) - \(product.getTitle())"
    }
    
    func getDescription() -> String {
        return "\(product.getDescription()) In der folgenden Tarifzone: \(area.properties.local_zone_name)"
    }
    
    func getAddedAgoText() -> String? {
        if (self.createdAt == nil) {
            return nil
        }
          
        let currentDate = Date()
        let delta = currentDate - self.createdAt!
        
        return MobilityboxFormatter.timeInterval.string(from: delta)!
    }
}


extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
