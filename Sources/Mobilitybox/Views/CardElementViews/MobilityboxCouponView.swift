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
        HStack(spacing: 0) {
            LeftCardView(title: coupon.getTitle()) {
                HStack(alignment: .center) {
                    if !coupon.activated {
                        Text(coupon.getDescription()).font(.system(size: 9))
                    } else {
                        Text("Coupon was already activated.").font(.system(size: 12).italic())
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
                Button("activate") {}
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(!coupon.activated ? Color.blue : Color(UIColor.lightGray))
                    .foregroundColor(.white)
                    .font(.system(size: 14).bold())
                    .clipShape(Capsule())
            }
            .background(Color.white)
            .clipShape(CardShape().rotation(Angle(degrees: 180)))
            
        }
        .compositingGroup()
        .frame(height: 100)
        .padding(.vertical, 10)
        .foregroundColor(.black.opacity(!coupon.activated ? 1 : 0.5))
        .modifier(CardShadowStyleModifier())
        .disabled(coupon.activated)
        
    }
}
