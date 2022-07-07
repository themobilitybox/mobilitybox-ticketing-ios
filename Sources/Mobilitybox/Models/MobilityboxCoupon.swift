import Foundation

public struct MobilityboxCouponCode: Codable, Equatable {
    public static func == (lhs: MobilityboxCouponCode, rhs: MobilityboxCouponCode) -> Bool {
        lhs.couponId == rhs.couponId
    }
    
    public var couponId: String
    
    public init(couponId: String) {
        self.couponId = couponId
    }
    
    public func fetchCoupon(completion: @escaping (MobilityboxCoupon) -> ()) {
        print("fetch coupon")
        let url = URL(string: "\(MobilityboxAPI.shared.apiURL)/ticketing/coupons/\(self.couponId).json")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching coupon: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the fetching coupon response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
                let coupon = try! JSONDecoder().decode(MobilityboxCoupon.self, from: data)
                DispatchQueue.main.async {
                    completion(coupon)
                }
            }
        })
        task.resume()
    }
}


public class MobilityboxCoupon: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxCoupon, rhs: MobilityboxCoupon) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    public var product: MobilityboxProduct
    public var area: MobilityboxArea
    public var activated: Bool
    
    public init(id: String, product: MobilityboxProduct, area: MobilityboxArea, activated: Bool = false) {
        self.id = id
        self.product = product
        self.area = area
        self.activated = activated
    }
    
    public func activate(identificationMedium: MobilityboxIdentificationMedium, completion: @escaping (MobilityboxTicketCode) -> ()) {
        let url = URL(string: "\(MobilityboxAPI.shared.apiURL)/ticketing/coupons/\(self.id)/activate.json")!
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
    
    func getTitle() -> String {
        return "\(area.properties.city_name) - \(product.getTitle())"
    }
    
    func getDescription() -> String {
        return "\(product.getDescription()) In the following Zone: \(area.properties.local_zone_name)"
    }
}
