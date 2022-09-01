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
                    Text("Inspect")
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
        HStack(spacing: 0) {
            LeftCardView(title: ticket.getTitle()) {
                HStack(alignment: .center) {
                    if ticket.isValid() {
                        Text("valid until:").font(.system(size: 9))
                        Text(
                            MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: ticket.valid_until)!)
                        ).font(.system(size: 12).bold())
                    } else {
                        Text("Ticket is expired.").font(.system(size: 12).italic())
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
                Text("inspect")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ticket.isValid() ? Color(red: 0, green: 154/255, blue: 34/255) : Color(UIColor.lightGray))
                    .foregroundColor(.white)
                    .font(.system(size: 14).bold())
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
