import SwiftUI

@available(iOS 14.0, *)
struct LeftCardView<Content: View>: View {
    var title: String
    var addedAgoText: String?
    var environment: String
    @ViewBuilder var content: () -> Content
    
    public init(title: String, addedAgoText: String? = nil, environment: String = "live", @ViewBuilder content: @escaping (() -> Content)) {
        self.title = title
        self.addedAgoText = addedAgoText
        self.content = content
        self.environment = environment
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 5) {
                    Text(title).font(.system(size: 16, design: .rounded).bold())
                    content()
                    if (addedAgoText != nil) {
                        HStack {
                            Spacer()
                            Text("hinzugefügt vor: \(addedAgoText ?? "")")
                                .font(.system(size: 9))
                                .italic()
                                .foregroundColor(Color(UIColor.gray))
                        }.padding(.horizontal, 5)
                    }
                }
                .padding(.horizontal, 10)
                Spacer()
            }
            .frame(height: 100)
            .background(Color.white)
            ZStack {
                Rectangle()
                    .foregroundColor(.orange)
                Text("TEST")
                    .foregroundColor(.white)
                    .font(Font.system(size: 8, weight: .bold, design: .rounded))
            }
            .frame(width: 100, height: 16)
            .rotationEffect(Angle(degrees: -45.0), anchor: .center)
            .offset(x: -32, y: 8)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 1, y: 1)
            .opacity(environment == "test" ? 1 : 0)
        }
    }
}

@available(iOS 14.0, *)
struct RightCardView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    public init(@ViewBuilder content: @escaping (() -> Content)) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Image(packageResource: "fake_barcode", ofType: "gif")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .opacity(0.25)
            content()
        }
        .frame(width: 100, height: 100, alignment: .center)
        .background(Color.white)
    }
}

@available(iOS 14.0, *)
struct CardSeperator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.size.height ))
        path.closeSubpath()
        return path
    }
}


@available(iOS 14.0, *)
struct CardShadowStyleModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.25) : Color.black.opacity(0.25), radius: 5, x: 2, y: 2)
    }
}


@available(iOS 14.0, *)
struct CardShape: Shape {
    func path(in rect: CGRect) -> Path {
        let arcRadius: CGFloat = 25
        let smallArcRadius:CGFloat = 10
        var path = Path()
        path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + arcRadius))
        
        path.addCurve(to: CGPoint(x: rect.origin.x + arcRadius, y: rect.origin.y), control1: CGPoint(x: rect.origin.x, y: rect.origin.y), control2: CGPoint(x: rect.origin.x, y: rect.origin.y))
        path.addLine(to:  CGPoint(x: rect.size.width - arcRadius, y: rect.origin.y))
        
        path.addArc(center: CGPoint(x: rect.size.width , y: rect.origin.y), radius: smallArcRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90) , clockwise: true)
        path.addLine(to:  CGPoint(x: rect.size.width, y: rect.size.height - smallArcRadius))
        
        path.addArc(center: CGPoint(x: rect.size.width , y: rect.size.height), radius: smallArcRadius, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180) , clockwise: true)
        path.addLine(to:  CGPoint(x: rect.origin.x + arcRadius, y: rect.size.height))
        
        path.addCurve(to: CGPoint(x: rect.origin.x, y: rect.size.height - arcRadius), control1: CGPoint(x: rect.origin.x, y: rect.size.height), control2: CGPoint(x: rect.origin.x, y: rect.size.height))
        path.closeSubpath()
        return path
    }
}


@available(iOS 14.0, *)
public struct MobilityboxCardView: View {
    var coupon: Binding<MobilityboxCoupon>?
    var ticket: Binding<MobilityboxTicket>?
    
    public init(coupon: Binding<MobilityboxCoupon>? = nil, ticket: Binding<MobilityboxTicket>? = nil) {
        self.coupon = coupon
        self.ticket = ticket
    }
    
    public var body: some View {
        if coupon != nil {
            MobilityboxCouponView(coupon: coupon!)
        } else if ticket != nil {
            MobilityboxTicketView(ticket: ticket!)
        } else {
            MobilityboxLoadingView()
        }
    }
}

@available(iOS 14.0, *)
extension Image {
    init(packageResource name: String, ofType type: String) {
#if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
#elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
#else
        self.init(name)
#endif
    }
}
