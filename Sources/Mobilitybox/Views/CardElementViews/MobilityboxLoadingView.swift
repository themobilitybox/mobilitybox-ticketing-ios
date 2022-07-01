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
        HStack(spacing: 0) {
            LeftCardView(title: "Loading Ticket Name") {
                Text("Loading Description. Lorem ipsum dolor sit amet, consetetur sadipscing elitr.").font(.system(size: 9))
            }
            .background(Color.white)
            .clipShape(CardShape())
            CardSeperator()
                .stroke(Color(UIColor.lightGray), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 7], dashPhase: 0))
                .frame(width: 1)
                .background(Color.white)
                .padding(.vertical, 10)
            RightCardView {
                Button("loading") {}
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray)
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
        .foregroundColor(.black)
        .modifier(CardShadowStyleModifier())
        .redacted(reason: .placeholder)
        .disabled(true)
    }
}
