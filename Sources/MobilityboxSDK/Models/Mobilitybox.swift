import Foundation

@available(iOS 13.0, *)
public struct MobilityboxCouponCode: Codable {
    public var couponCode: String
    
    public init(couponCode: String) {
        self.couponCode = couponCode
    }
    
    public func fetchCoupon(completion: @escaping (MobilityboxCoupon) -> ()) {
        if  let savedCoupon = self.loadCoupon() {
            print("used saved Coupon")
            completion(savedCoupon)
        } else {
            print("fetch coupon")
            let url = URL(string: "https://api-integration.themobilitybox.com/v2/ticketing/coupons/\(self.couponCode).json")!
            
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
                        self.saveCoupon(coupon: coupon)
                        completion(coupon)
                    }
                }
            })
            task.resume()
        }
    }
    
    func loadCoupon() -> MobilityboxCoupon? {
        if let data = UserDefaults.standard.data(forKey: self.couponCode) {
            if let decodedCoupon = try? JSONDecoder().decode(MobilityboxCoupon.self, from: data) {
                return decodedCoupon
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func saveCoupon(coupon: MobilityboxCoupon) {
        if let encodedCoupon = try? JSONEncoder().encode(coupon) {
            UserDefaults.standard.set(encodedCoupon, forKey: self.couponCode)
        }
    }
}


@available(iOS 13.0, *)
public struct MobilityboxProduct: Codable, Identifiable {
    public var id: String
    public var local_ticket_name: String
    public var local_validity_description: String
    public var ticket_type: String
    public var customer_type: String
    public var price_in_cents: Int
    public var currency: String
    public var validity_in_minutes: Int
    public var area_id: String
    public var identification_medium_schema: IdentificationMediumSchema
}



struct IdentificationMediumProperty: Codable {
    var type: String
    var title: String
    var examples: [String]?
    var options: [String]?
    var format: String?
    var pattern: String?
    var minLength: Int?
    var maxLength: Int?
    
    enum CodingKeys: String, CodingKey {
            case options = "enum"
            
            case type
            case title
            case examples
            case format
            case pattern
            case minLength
            case maxLength
        }
}

struct IdentificaitonMediumDefinition: Codable {
    var type: String
    var title: String
    var required: [String]
    var properties: [String: IdentificationMediumProperty]
}

struct IdentificationMediumOneOf: Codable {
    var type: String
    var required: [String]
    var properties: [String: [String: String]]
}

public struct IdentificationMediumSchema: Codable {
    var id: String?
    var schema: String
    var type: String
    var oneOf: [IdentificationMediumOneOf]
    var definitions: [String: IdentificaitonMediumDefinition]
    
    enum CodingKeys: String, CodingKey {
            case id = "$id"
            case schema = "$schema"
            
            case type
            case oneOf
            case definitions
        }
}

public struct MobilityboxPassenger: Codable {
    let identification_medium_json: String
}

@available(iOS 13.0, *)
public class MobilityboxCoupon: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxCoupon, rhs: MobilityboxCoupon) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    public var product: MobilityboxProduct
    public var activated: Bool
    
    
    public init(id: String, product: MobilityboxProduct, activated: Bool = false) {
        self.id = id
        self.product = product
        self.activated = activated
    }
    
    func activate(passenger: MobilityboxPassenger, completion: @escaping (MobilityboxTicket) -> ()) {
        let url = URL(string: "https://api-integration.themobilitybox.com/v2/ticketing/coupons/\(self.id)/activate.json")!
        let body = passenger.identification_medium_json
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
                    let ticket = MobilityboxTicket(ticketId: ticketId, couponCode: self.id, product: self.product)
                    completion(ticket)
                }
            }
        })
        task.resume()
    }
    
    public func getCouponCode() -> String {
        return self.id
    }
}

@available(iOS 13.0, *)
public class MobilityboxTicket: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxTicket, rhs: MobilityboxTicket) -> Bool {
        lhs.ticketId == rhs.ticketId
    }
    
    public let id: String
    public let couponCode: String?
    public let ticketId: String
    public var ticketData: JSONValue?
    public var product: MobilityboxProduct?
    
    public init(ticketId: String, couponCode: String, product: MobilityboxProduct) {
        self.id = ticketId
        self.ticketId = ticketId
        self.couponCode = couponCode
        self.product = product
    }
}
