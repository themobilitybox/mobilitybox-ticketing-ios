import Foundation

public class MobilityboxCoupon: Identifiable, Codable, Equatable {
    public static func == (lhs: MobilityboxCoupon, rhs: MobilityboxCoupon) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    public var original_coupon_id: String?
    public var restored_coupon_id: String?
    public var product: MobilityboxProduct
    public var area: MobilityboxArea
    public var activated: Bool
    public var subscription: MobilityboxSubscription?
    public var environment: String
    public var createdAt: Date? = Date()
    public var tariff_settings_valid: Bool?
    public var tariff_settings: [String: MobilityboxJSONValue]?
    public var earliest_activation_start_datetime: String?
    public var latest_activation_start_datetime: String?
    public var activatable_until: String?
    
    public init(id: String, original_coupon_id: String? = nil, restored_coupon_id: String? = nil, product: MobilityboxProduct, area: MobilityboxArea, activated: Bool = false, environment: String, createdAt: Date? = nil, tariff_settings_valid: Bool? = nil, tariff_settings: [String: MobilityboxJSONValue]? = nil, earliest_activation_start_datetime: String? = nil, latest_activation_start_datetime: String? = nil, activatable_until: String? = nil) {
        self.id = id
        self.original_coupon_id = original_coupon_id
        self.restored_coupon_id = restored_coupon_id
        self.product = product
        self.area = area
        self.activated = activated
        self.environment = environment
        self.createdAt = createdAt
        self.tariff_settings_valid = tariff_settings_valid
        self.tariff_settings = tariff_settings
        self.earliest_activation_start_datetime = earliest_activation_start_datetime
        self.latest_activation_start_datetime = latest_activation_start_datetime
        self.activatable_until = activatable_until
    }
    
    public func activate(identificationMedium: MobilityboxIdentificationMedium, tariffSettings: MobilityboxTariffSettings? = nil, activationStartDateTime: Date? = nil, onSuccess completion: @escaping (MobilityboxTicketCode) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        
        var body: [String: MobilityboxJSONValue] = [:]
        let identificationMediumData = identificationMedium.getIdentificationMedium()
        
        if identificationMediumData != nil && identificationMediumData!.dictionary != nil && identificationMediumData!.dictionary!["identification_medium"] != nil {
            body["identification_medium"] = identificationMediumData!.dictionary!["identification_medium"]
            
            if activationStartDateTime != nil && self.original_coupon_id == nil {
                let activation_start_datetime = MobilityboxFormatter.isoDateTime.string(from: activationStartDateTime!)
                body["activation_start_datetime"] = MobilityboxJSONValue.string(activation_start_datetime)
            }
            
            if tariffSettings != nil {
                let tariffSettingsData = tariffSettings!.getTariffSettings()
                if tariffSettingsData != nil && tariffSettingsData!.dictionary != nil && tariffSettingsData!.dictionary!["tariff_settings"] != nil {
                    body["tariff_settings"] = tariffSettingsData!.dictionary!["tariff_settings"]
                }
            }
            
            
            if let bodyJson = try? JSONEncoder().encode(body) {
                activateCall(body: String(data: bodyJson, encoding: .utf8)!, onSuccess: completion, onFailure: failure)
            }
        }
    }
    
    public func reactivate(reactivation_key: String, identificationMedium: MobilityboxIdentificationMedium? = nil, tariffSettings: MobilityboxTariffSettings? = nil, onSuccess completion: @escaping (MobilityboxTicketCode) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        var body: [String: MobilityboxJSONValue] = [:]
        
        if let decodedData = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "\"\(reactivation_key)\"".data(using: .utf8)!) {
            body["reactivation_key"] = decodedData
        } else {
            body["reactivation_key"] = nil
        }
        
        
        if (identificationMedium != nil) {
            let identificationMediumData = identificationMedium!.getIdentificationMedium()
            
            if identificationMediumData != nil && identificationMediumData!.dictionary != nil && identificationMediumData!.dictionary!["identification_medium"] != nil {
                body["identification_medium"] = identificationMediumData!.dictionary!["identification_medium"]
            }
        }
                    
                    
        if (tariffSettings != nil) {
            let tariffSettingsData = tariffSettings!.getTariffSettings()
            if tariffSettingsData != nil && tariffSettingsData!.dictionary != nil && tariffSettingsData!.dictionary!["tariff_settings"] != nil {
                body["tariff_settings"] = tariffSettingsData!.dictionary!["tariff_settings"]
            }
        }
                    
        
        if let bodyJson = try? JSONEncoder().encode(body) {
            activateCall(body: String(data: bodyJson, encoding: .utf8)!, onSuccess: completion, onFailure: failure)
        }
    }
    
    func activateCall(body: String, onSuccess completion: @escaping (MobilityboxTicketCode) -> (), onFailure failure: ((MobilityboxError?) -> Void)? = nil) {
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/coupons/\(self.id)/activate.json")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = Data(body.utf8)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with activating coupon: \(error)")
                DispatchQueue.main.async {
                    failure?(MobilityboxError.unkown)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("Error with the activating coupon response, unexpected status code: \(httpResponse.statusCode)")
                } else {
                    print("Error with the activating coupon response, unexpected status code: \(String(describing: response))")
                }
                
                
                if let data = data {
                    let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print("Error Response: \(String(describing: errorResponse))")
                    
                    if errorResponse != nil && errorResponse!["message"] != nil && errorResponse!["message"] as! String == "The current subscription cycle was not ordered yet" {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.coupon_expired)
                        }
                    } else if errorResponse != nil && errorResponse!["message"] != nil && (errorResponse!["message"] as! String).hasPrefix("identification_medium:") {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.identification_medium_not_valid)
                        }
                    } else if errorResponse != nil && errorResponse!["message"] != nil && (errorResponse!["message"] as! String).hasPrefix("tariff_settings:") {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.tariff_settings_not_valid)
                        }
                    } else if errorResponse != nil && errorResponse!["message"] != nil && (errorResponse!["message"] as! String).hasPrefix("Ticket cannot be activated yet") {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.before_earliest_activation_start_datetime)
                        }
                    } else if errorResponse != nil && errorResponse!["message"] != nil && (errorResponse!["message"] as! String).hasPrefix("Ticket cannot be activated anymore. It must be activated within 3 days of order.") {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.coupon_activation_activatable_until_expired)
                        }
                    } else if errorResponse != nil && errorResponse!["message"] != nil && (errorResponse!["message"] as! String).hasPrefix("Ticket cannot be activated anymore") {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.coupon_activation_expired)
                        }
                    } else {
                        DispatchQueue.main.async {
                            failure?(MobilityboxError.unkown)
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        failure?(MobilityboxError.unkown)
                    }
                }

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
                    self.original_coupon_id = updatedCoupon.original_coupon_id
                    self.restored_coupon_id = updatedCoupon.restored_coupon_id
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
        return product.local_ticket_name
    }
    
    public func getDescription() -> String {
        return "\(product.getDescription()) In der folgenden Tarifzone: \(area.properties.local_zone_name)"
    }
    
    public func isRestoredCoupon() -> Bool {
        return self.original_coupon_id != nil
    }
    
    func getAddedAgoText() -> String? {
        if (self.createdAt == nil) {
            return nil
        }
          
        let currentDate = Date()
        let delta = currentDate - self.createdAt!
        
        return MobilityboxFormatter.timeInterval.string(from: delta)!
    }
    
    public func getReferenceTag() -> String? {
        return "C-\(self.id.suffix(6).uppercased())"
    }
}


extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
