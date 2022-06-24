import SwiftUI

@available(iOS 14.0, *)
struct BottomTicketView: View {
    @Binding var ticket: MobilityboxTicket
    
    init(ticket: Binding<MobilityboxTicket>) {
        self._ticket = ticket
    }
    
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "chevron.right.2")
                    Text("Show")
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
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }
}


@available(iOS 14.0, *)
public struct MobilityboxTicketView: View {
    @Binding var ticket: MobilityboxTicket
    
    public init(ticket: Binding<MobilityboxTicket>) {
        self._ticket = ticket
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCardView(title: ticket.getTitle(), description: ticket.getDescription())
                .background(Color.white)
                .clipShape(CardShape())
                .modifier(CardShadowStyleModifier())
            CardSeperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomTicketView(ticket: $ticket)
                .background(Color.white)
                .clipShape(CardShape().rotation(Angle(degrees: 180)))
                .modifier(CardShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
    }
}
