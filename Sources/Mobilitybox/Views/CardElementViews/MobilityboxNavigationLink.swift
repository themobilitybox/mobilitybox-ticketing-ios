import SwiftUI

public struct MobilityboxNavigationLinkType {
    public static var modal = MobilityboxNavigationLinkType(type: "modal")
    public static var push = MobilityboxNavigationLinkType(type: "push")
    public static var listPush = MobilityboxNavigationLinkType(type: "listPush")
    
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
                .sheet(isPresented: $showDestinationView, content: {
                    MobilityboxNavigationView(navigationDestination: navigationDestination, showView: $showDestinationView)
                })
                .onTapGesture {
                    self.showDestinationView.toggle()
                }
        } else if linkType.type == "listPush" {
            ZStack(alignment: .leading) {
                NavigationLink {
                    navigationDestination()
                } label: {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                navigationOrigin()
            }
        } else {
            NavigationLink {
                navigationDestination()
            } label: {
                navigationOrigin()
            }
        }
        
    }
}

@available(iOS 14.0, *)
public struct MobilityboxNavigationView<Content: View>: View {
    @ViewBuilder var navigationDestination: () -> Content
    @Binding var showView: Bool
    
    public init(@ViewBuilder navigationDestination: @escaping () -> Content, showView: Binding<Bool>) {
        self.navigationDestination = navigationDestination
        self._showView = showView
    }
    
    public var body: some View {
        NavigationView {
            navigationDestination()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.showView.toggle()
                        } label: {
                            Label("", systemImage: "xmark")
                        }
                    }
                }
        }
    }
}
