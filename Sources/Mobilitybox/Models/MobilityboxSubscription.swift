//
//  MobilityboxSubscription.swift
//  
//
//  Created by Tim Krusch on 26.01.23.
//

import Foundation

public struct MobilityboxSubscription: Codable, Identifiable {
    public var id: String
    public var original_subscription_id: String?
    public var restored_subscription_id: String?
    public var active: Bool
    public var coupon_reactivatable: Bool
    public var subscription_reorderable: Bool?
    public var current_cycle_valid_from: String?
    public var current_cycle_valid_until: String?
    public var ordered_until: String?
    public var current_subscription_cycle: MobilityboxSubscriptionCycle
    public var next_subscription_cycle: MobilityboxSubscriptionCycle?
    public var next_unordered_subscription_cycle: MobilityboxSubscriptionCycle?
    public var subscription_cycles: [MobilityboxSubscriptionCycle]?
}

public struct MobilityboxSubscriptionCycle: Codable, Identifiable {
    public var id: String
    public var product_id: String?
    public var valid_from: String?
    public var valid_until: String?
    public var ordered: Bool
    public var coupon_activated: Bool
}
