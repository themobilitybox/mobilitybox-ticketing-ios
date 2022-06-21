import SwiftUI


@available(iOS 14.0, macOS 11.0, *)
struct BottomCouponView<Content: View>: View {
    @Binding var coupon: MobilityboxCoupon
    var navigationLink: () -> Content?
    
    init(coupon: Binding<MobilityboxCoupon>, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self._coupon = coupon
        self.navigationLink = navigationLink
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
                navigationLink()
                    .frame(width: 0)
                    .opacity(0)
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct MobilityboxCouponView<Content: View>: View {
    @Binding var coupon: MobilityboxCoupon
    var navigationLink: () -> Content?
    
    public init(coupon: Binding<MobilityboxCoupon>, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self._coupon = coupon
        self.navigationLink = navigationLink
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCardView(title: coupon.product.local_ticket_name, description: coupon.product.local_validity_description)
                .background(Color.white)
                .clipShape(CardShape())
                .modifier(CardShadowStyleModifier())
            CardSeperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomCouponView(coupon: $coupon, navigationLink: navigationLink)
                .background(Color.white)
                .clipShape(CardShape().rotation(Angle(degrees: 180)))
                .modifier(CardShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
    }
}
