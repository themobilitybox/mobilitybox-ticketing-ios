//
//  File.swift
//  
//
//  Created by René Meye on 11.06.22.
//

import Foundation

public struct MobilityboxTicketRenderingEngine: Codable {
    public var engineCode: String
    
    public init(engineCode: String) {
        self.engineCode = engineCode
    }
    
    public func updateEngine(completion: @escaping (MobilityboxCoupon) -> ()) {
//        if  let savedCoupon = self.loadCoupon() {
//            print("used saved Coupon")
//            completion(savedCoupon)
//        } else {
//            print("fetch coupon")
//            let url = URL(string: "https://api-alpha.themobilitybox.com/v2/ticketing/coupons/\(self.couponCode).json")!
//            
//            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//                if let error = error {
//                    print("Error with fetching coupon: \(error)")
//                    return
//                }
//                
//                guard let httpResponse = response as? HTTPURLResponse,
//                      (200...299).contains(httpResponse.statusCode) else {
//                    print("Error with the fetching coupon response, unexpected status code: \(String(describing: response))")
//                    return
//                }
//                
//                if let data = data {
//                    let coupon = try! JSONDecoder().decode(MobilityboxCoupon.self, from: data)
//                    
//                    DispatchQueue.main.async {
//                        self.saveCoupon(coupon: coupon)
//                        completion(coupon)
//                    }
//                }
//            })
//            task.resume()
//        }
    }
    
//    @available(iOS 13.0, *)
//    func loadCoupon() -> MobilityboxCoupon? {
//        if let data = UserDefaults.standard.data(forKey: self.couponCode) {
//            if let decodedCoupon = try? JSONDecoder().decode(MobilityboxCoupon.self, from: data) {
//                return decodedCoupon
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }
//    
//    func saveCoupon(coupon: MobilityboxCoupon) {
//        if let encodedCoupon = try? JSONEncoder().encode(coupon) {
//            UserDefaults.standard.set(encodedCoupon, forKey: self.couponCode)
//        }
//    }
}
