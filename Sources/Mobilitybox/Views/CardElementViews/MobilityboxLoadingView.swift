import SwiftUI

@available(iOS 14.0, *)
struct BottomLoadingView: View {
    
    var body: some View {
        HStack(spacing: 50) {
            Spacer()
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Loading")
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .padding(.horizontal, 10)
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 25)
                .foregroundColor(Color.white)
                .background(Color.gray)
                .cornerRadius(40)
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }
}

@available(iOS 14.0, *)
public struct MobilityboxLoadingView: View {
    
    public init(){}
    
    public var body: some View {
        VStack(spacing: 0) {
            TopCardView(title: "This is a loading Ticket Name", description: "Loading Description. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.")
                .background(Color.white)
                .clipShape(CardShape())
                .modifier(CardShadowStyleModifier())
            CardSeperator()
                .stroke(Color (UIColor.label), style: StrokeStyle(lineWidth: 1,dash: [4,8], dashPhase: 4))
                .frame(height: 0.5)
                .padding(.horizontal)
            BottomLoadingView()
                .background(Color.white)
                .clipShape(CardShape().rotation(Angle(degrees: 180)))
                .modifier(CardShadowStyleModifier())
            
        }.padding(.vertical, 10)
            .foregroundColor(.black)
            .redacted(reason: .placeholder)
    }
}
