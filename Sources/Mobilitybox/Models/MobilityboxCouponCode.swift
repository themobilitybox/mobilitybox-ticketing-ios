import Foundation

public struct MobilityboxCouponCode: Codable, Equatable {
    public static func == (lhs: MobilityboxCouponCode, rhs: MobilityboxCouponCode) -> Bool {
        lhs.couponId == rhs.couponId
    }
    
    public var couponId: String
    
    public init(couponId: String) {
        self.couponId = couponId
    }
    
    public func fetchCoupon(onSuccess completion: @escaping (MobilityboxCoupon) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/coupons/\(self.couponId).json")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                if failure != nil {
                    failure!(MobilityboxError.unkown)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                if failure != nil {
                    failure!(MobilityboxError.unkown)
                }
                return
            }
            
            if let data = data {
                let coupon = try! JSONDecoder().decode(MobilityboxCoupon.self, from: data)
                coupon.createdAt = Date()
                DispatchQueue.main.async {
                    completion(coupon)
                }
            }
        })
        task.resume()
    }
}
