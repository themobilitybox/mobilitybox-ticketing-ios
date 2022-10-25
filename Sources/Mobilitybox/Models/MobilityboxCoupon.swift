import Foundation

public class MobilityboxCoupon: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxCoupon, rhs: MobilityboxCoupon) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    public var product: MobilityboxProduct
    public var area: MobilityboxArea
    public var activated: Bool
    public var environment: String
    public var createdAt: Date? = Date()
    
    public init(id: String, product: MobilityboxProduct, area: MobilityboxArea, activated: Bool = false, environment: String, createdAt: Date? = nil) {
        self.id = id
        self.product = product
        self.area = area
        self.activated = activated
        self.environment = environment
        self.createdAt = createdAt
    }
    
    public func activate(identificationMedium: MobilityboxIdentificationMedium, completion: @escaping (MobilityboxTicketCode) -> ()) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/coupons/\(self.id)/activate.json")!
        let body = identificationMedium.identification_medium_json
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
                    let ticket = MobilityboxTicketCode(ticketId: ticketId, couponId: self.id, product: self.product)
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
