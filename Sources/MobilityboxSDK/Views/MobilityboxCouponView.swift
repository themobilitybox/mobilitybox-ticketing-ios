import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct TopCouponView: View {
    @Binding var coupon: MobilityboxCoupon
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(coupon.product.local_ticket_name).font(Font.title3.bold())
                Text(coupon.product.local_validity_description ).font(.system(size: 10))
                    .padding(.vertical, 1)
                    .padding(.horizontal, 20)
            }
            Spacer()
        }
        .padding(.vertical, 25)
    }
}


@available(iOS 14.0, macOS 11.0, *)
struct BottomCouponView<Content: View>: View {
    @Binding var coupon: MobilityboxCoupon
    @ViewBuilder var navigationLink: () -> Content
    
    init(coupon: Binding<MobilityboxCoupon>, @ViewBuilder navigationLink: @escaping () -> Content) {
        self._coupon = coupon
        self.navigationLink = navigationLink
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                MobilityboxButtonView(coupon: $coupon)
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
struct Seperator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.origin.y ))
        path.closeSubpath()
        return path
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct ShadowStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 2, y: 4)
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct CouponShape: Shape {
    func path(in rect: CGRect) -> Path {
        let arcRadius: CGFloat = 15
        let smallArcRadius:CGFloat = 10
        var path = Path()
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arcRadius))
        path.addArc(center: CGPoint.zero, radius: arcRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0) , clockwise: true)
        path.addArc(center: CGPoint(x: rect.midX, y: rect.origin.y) , radius: arcRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0) , clockwise: false)
        path.addLine(to:  CGPoint(x: rect.size.width - arcRadius, y: rect.origin.y))
        path.addArc(center: CGPoint(x: rect.size.width , y: rect.origin.y), radius: arcRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90) , clockwise: true)
        path.addLine(to:  CGPoint(x: rect.size.width, y: rect.size.height - smallArcRadius))
        path.addArc(center: CGPoint(x: rect.size.width , y: rect.size.height), radius: smallArcRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180) , clockwise: true)
        path.addLine(to:  CGPoint(x: rect.origin.x + smallArcRadius, y: rect.size.height))
        path.addArc(center: CGPoint(x: rect.origin.x , y: rect.size.height), radius: smallArcRadius, startAngle: Angle(degrees: 360), endAngle: Angle(degrees: 270) , clockwise: true)
        path.closeSubpath()
        return path
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct MobilityboxCouponView<Content: View>: View {
    @Binding var coupon: MobilityboxCoupon
    @ViewBuilder var navigationLink: () -> Content
    
    public init(coupon: Binding<MobilityboxCoupon>, @ViewBuilder navigationLink: @escaping () -> Content) {
        self._coupon = coupon
        self.navigationLink = navigationLink
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCouponView(coupon: $coupon)
                .background(Color.white)
                .clipShape(CouponShape())
                .modifier(ShadowStyleModifier())
            Seperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomCouponView(coupon: $coupon, navigationLink: navigationLink)
                .background(Color.white)
                .clipShape(CouponShape().rotation(Angle(degrees: 180)))
                .modifier(ShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
    }
}

//@available(iOS 14.0, macOS 11.0, *)
//struct MobilityboxCouponView_Previews: PreviewProvider {
//    static var previews: some View {
//        MobilityboxCouponView(ticket: MobilityboxTicket(couponCode: ""))
//    }
//}
