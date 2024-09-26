import SwiftUI


@available(iOS 14.0, *)
public struct MobilityboxCouponView: View {
    @Binding var coupon: MobilityboxCoupon
    
    public init(coupon: Binding<MobilityboxCoupon>) {
        self._coupon = coupon
    }
    
    
    public var body: some View {
        HStack(spacing: 0) {
            LeftCardView(title: coupon.getTitle(), addedAgoText: coupon.getAddedAgoText(), referenceTag: coupon.getReferenceTag(), environment: coupon.environment) {
                HStack(alignment: .center) {
                    if !coupon.activated {
                        Text(coupon.getDescription()).font(.system(size: 9))
                    } else {
                        Text("Ticket wurde schon aktiviert.").font(.system(size: 12).italic())
                    }
                }
            }
            .background(Color.white)
            .clipShape(CardShape())
            CardSeperator()
                .stroke(Color(UIColor.lightGray), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 7], dashPhase: 0))
                .frame(width: 1)
                .background(Color.white)
                .padding(.vertical, 10)
            RightCardView {
                Text("aktivieren")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(!coupon.activated ? Color.blue : Color(UIColor.lightGray))
                    .foregroundColor(.white)
                    .font(.system(size: 14, design: .rounded).bold())
                    .clipShape(Capsule())
            }
            .background(Color.white)
            .clipShape(CardShape().rotation(Angle(degrees: 180)))
        }
        .compositingGroup()
        .frame(height: 100)
        .foregroundColor(.black.opacity(!coupon.activated ? 1 : 0.5))
        .modifier(CardShadowStyleModifier())
        .disabled(coupon.activated)
        
    }
}
