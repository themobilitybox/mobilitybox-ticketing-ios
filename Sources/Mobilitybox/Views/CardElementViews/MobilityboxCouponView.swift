import SwiftUI


@available(iOS 14.0, *)
struct BottomCouponView: View {
    @Binding var coupon: MobilityboxCoupon
    
    init(coupon: Binding<MobilityboxCoupon>) {
        self._coupon = coupon
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
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
            Spacer()
        }
        .padding(.vertical, 20)
    }
}

@available(iOS 14.0, *)
public struct MobilityboxCouponView: View {
    @Binding var coupon: MobilityboxCoupon
    
    public init(coupon: Binding<MobilityboxCoupon>) {
        self._coupon = coupon
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCardView(title: coupon.getTitle(), description: coupon.getDescription())
                .background(Color.white)
                .clipShape(CardShape())
                .modifier(CardShadowStyleModifier())
            CardSeperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomCouponView(coupon: $coupon)
                .background(Color.white)
                .clipShape(CardShape().rotation(Angle(degrees: 180)))
                .modifier(CardShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
    }
}
