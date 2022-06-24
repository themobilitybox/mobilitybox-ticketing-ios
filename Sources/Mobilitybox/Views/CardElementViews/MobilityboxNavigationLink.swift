import SwiftUI

public struct MobilityboxNavigationLinkType {
    public static var modal = MobilityboxNavigationLinkType(type: "modal")
    public static var push = MobilityboxNavigationLinkType(type: "push")
    
    public var type: String
}


@available(iOS 14.0, *)
public struct MobilityboxNavigationLink<OriginContent: View, DestinationContent: View>: View {
    let linkType: MobilityboxNavigationLinkType
    @ViewBuilder var navigationOrigin: () -> OriginContent
    @ViewBuilder var navigationDestination: () -> DestinationContent
    @State var showDestinationView = false

    
    public init(linkType: MobilityboxNavigationLinkType = .push, @ViewBuilder navigationOrigin: @escaping () -> OriginContent, @ViewBuilder navigationDestination: @escaping () -> DestinationContent) {
        self.linkType = linkType
        self.navigationOrigin = navigationOrigin
        self.navigationDestination = navigationDestination
    }
    
    
    public var body: some View {
        if linkType.type == "modal" {
            navigationOrigin()
                .sheet(isPresented: $showDestinationView) {
                    MobilityboxNavigationView(navigationDestination: navigationDestination)
                }
                .onTapGesture {
                    showDestinationView.toggle()
                }
        } else {
            ZStack {
                NavigationLink {
                    navigationDestination()
                } label: {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                navigationOrigin()
            }
        }
        
    }
}

@available(iOS 14.0, *)
public struct MobilityboxNavigationView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @ViewBuilder var navigationDestination: () -> Content
    
    public init(@ViewBuilder navigationDestination: @escaping () -> Content) {
        self.navigationDestination = navigationDestination
    }
    
    public var body: some View {
        NavigationView {
            navigationDestination()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("", systemImage: "xmark")
                        }
                    }
                }
        }
    }
}
