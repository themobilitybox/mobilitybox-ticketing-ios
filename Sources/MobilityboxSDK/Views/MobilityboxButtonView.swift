//
//  SwiftUIView.swift
//  
//
//  Created by Tim Krusch on 02.06.22.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
public struct MobilityboxButtonView: View {
    @Binding var coupon: MobilityboxCoupon
    
    public init(coupon: Binding<MobilityboxCoupon>) {
        self._coupon = coupon
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "chevron.right.2")
            Text("Activate")
                .fontWeight(.semibold)
                .font(.system(size: 18))
                .padding(.horizontal, 10)
            Image(systemName: "chevron.left.2")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 25)
        .foregroundColor(Color.white)
        .background(Color(red: 0, green: 123/255, blue: 1))
        .cornerRadius(40)
        
    }
}
