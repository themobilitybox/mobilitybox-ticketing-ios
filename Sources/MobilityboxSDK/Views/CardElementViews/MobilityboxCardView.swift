import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct TopCardView: View {
    var title: String
    var description: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(title).font(Font.title3.bold())
                Text(description).font(.system(size: 10))
                    .padding(.vertical, 1)
                    .padding(.horizontal, 20)
            }
            Spacer()
        }
        .padding(.vertical, 25)
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct BottomCardView<Content: View>: View {
    var buttonView: () -> Content?
    var navigationLink: () -> Content?
    
    init(@ViewBuilder buttonView: @escaping () -> Content? = { nil }, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self.buttonView = buttonView
        self.navigationLink = navigationLink
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                buttonView()
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
struct CardSeperator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.origin.y ))
        path.closeSubpath()
        return path
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct CardShadowStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.25), radius: 5, x: 2, y: 2)
    }
}

@available(iOS 14.0, macOS 11.0, *)
struct CardShape: Shape {
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
public struct MobilityboxCardView<Content: View>: View {
    var coupon: Binding<MobilityboxCoupon>?
    var ticket: Binding<MobilityboxTicket>?
    var navigationLink: () -> Content?
    
    
    public init(coupon: Binding<MobilityboxCoupon>? = nil, ticket: Binding<MobilityboxTicket>? = nil, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self.coupon = coupon
        self.ticket = ticket
        self.navigationLink = navigationLink
    }
    
    public var body: some View {
        if coupon != nil {
            MobilityboxCouponView(coupon: coupon!, navigationLink: navigationLink)
        } else if ticket != nil {
            MobilityboxTicketView(ticket: ticket!, navigationLink: navigationLink)
        } else {
            MobilityboxLoadingView()
        }
    }
}
