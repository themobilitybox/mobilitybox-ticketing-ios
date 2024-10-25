import Foundation

public struct MobilityboxProductCode: Codable, Equatable {
    public static func == (lhs: MobilityboxProductCode, rhs: MobilityboxProductCode) -> Bool {
        lhs.productId == rhs.productId
    }
    
    public var productId: String
    
    public init(productId: String) {
        self.productId = productId
    }
    
    public func fetchProduct(onSuccess completion: @escaping (MobilityboxProduct) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/products/\(self.productId).json")!
        
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
                let product = try! JSONDecoder().decode(MobilityboxProduct.self, from: data)
                DispatchQueue.main.async {
                    completion(product)
                }
            }
        })
        task.resume()
    }
}
