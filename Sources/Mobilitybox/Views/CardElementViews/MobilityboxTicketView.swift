import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
struct BottomTicketView<Content: View>: View {
    @Binding var ticket: MobilityboxTicket
    var navigationLink: () -> Content?
    
    init(ticket: Binding<MobilityboxTicket>, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self._ticket = ticket
        self.navigationLink = navigationLink
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "chevron.right.2")
                    Text("show Ticket")
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .padding(.horizontal, 10)
                    Image(systemName: "chevron.left.2")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 25)
                .foregroundColor(Color.white)
                .background(Color(red: 0, green: 154/255, blue: 34/255))
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
public struct MobilityboxTicketView<Content: View>: View {
    @Binding var ticket: MobilityboxTicket
    var navigationLink: () -> Content?
    
    public init(ticket: Binding<MobilityboxTicket>, @ViewBuilder navigationLink: @escaping () -> Content? = { nil }) {
        self._ticket = ticket
        self.navigationLink = navigationLink
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCardView(title: ticket.product.local_ticket_name, description: ticket.product.local_validity_description)
                .background(Color.white)
                .clipShape(CardShape())
                .modifier(CardShadowStyleModifier())
            CardSeperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomTicketView(ticket: $ticket, navigationLink: navigationLink)
                .background(Color.white)
                .clipShape(CardShape().rotation(Angle(degrees: 180)))
                .modifier(CardShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
    }
}
