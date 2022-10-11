import SwiftUI



@available(iOS 14.0, *)
public struct MobilityboxTicketView: View {
    @Binding var ticket: MobilityboxTicket
    
    public init(ticket: Binding<MobilityboxTicket>) {
        self._ticket = ticket
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            LeftCardView(title: ticket.getTitle(), environment: ticket.environment) {
                HStack(alignment: .center) {
                    if ticket.isValid() {
                        Text("gültig bis:").font(.system(size: 9))
                        Text(
                            "\(MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: ticket.valid_until)!)) Uhr"
                        ).font(.system(size: 12).bold())
                    } else {
                        Text("Ticket ist abgelaufen.").font(.system(size: 12).italic())
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
                Text("anzeigen")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ticket.isValid() ? Color(red: 0, green: 154/255, blue: 34/255) : Color(UIColor.lightGray))
                    .foregroundColor(.white)
                    .font(.system(size: 14, design: .rounded).bold())
                    .clipShape(Capsule())
            }
            .background(Color.white)
            .clipShape(CardShape().rotation(Angle(degrees: 180)))
            
        }
        .compositingGroup()
        .frame(height: 100)
        .foregroundColor(.black.opacity(ticket.isValid() ? 1 : 0.5))
        .modifier(CardShadowStyleModifier())
        .disabled(!ticket.isValid())
    }
}
