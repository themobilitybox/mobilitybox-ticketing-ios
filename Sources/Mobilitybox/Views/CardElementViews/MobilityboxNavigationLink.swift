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
    @State var defaultShowDestinationView: Bool = false
    var showDestinationView: Binding<Bool>? = nil

    public init(linkType: MobilityboxNavigationLinkType = .push, showDestinationView: Binding<Bool>? = nil, @ViewBuilder navigationOrigin: @escaping () -> OriginContent, @ViewBuilder navigationDestination: @escaping () -> DestinationContent) {
        self.linkType = linkType
        self.navigationOrigin = navigationOrigin
        self.navigationDestination = navigationDestination
        self.showDestinationView = showDestinationView
    }

    public var body: some View {
        let resolvedBindingShowDestinationView = showDestinationView ?? $defaultShowDestinationView
        return MobilityboxNavigationLinkInner(linkType: self.linkType, showDestinationView: resolvedBindingShowDestinationView, navigationOrigin: self.navigationOrigin, navigationDestination: self.navigationDestination)
    }

    public struct DependentMobilityboxNavigationLink: View {
        let linkType: MobilityboxNavigationLinkType
        @ViewBuilder var navigationOrigin: () -> OriginContent
        @ViewBuilder var navigationDestination: () -> DestinationContent
        @Binding var showDestinationView: Bool

        public var body: some View {
            MobilityboxNavigationLinkInner(linkType: linkType, showDestinationView: $showDestinationView, navigationOrigin: navigationOrigin, navigationDestination: navigationDestination)
        }
    }

    public struct IndependentMobilityboxNavigationLink: View {
        let linkType: MobilityboxNavigationLinkType
        @ViewBuilder var navigationOrigin: () -> OriginContent
        @ViewBuilder var navigationDestination: () -> DestinationContent
        @State var showDestinationView = false

        public var body: some View {
            MobilityboxNavigationLinkInner(linkType: linkType, showDestinationView: $showDestinationView, navigationOrigin: navigationOrigin, navigationDestination: navigationDestination)
        }
    }
}


@available(iOS 14.0, *)
public struct MobilityboxNavigationLinkInner<OriginContent: View, DestinationContent: View>: View {
    let linkType: MobilityboxNavigationLinkType
    @ViewBuilder var navigationOrigin: () -> OriginContent
    @ViewBuilder var navigationDestination: () -> DestinationContent
    @Binding var showDestinationView: Bool
    
    public init(linkType: MobilityboxNavigationLinkType = .push, showDestinationView: Binding<Bool>, @ViewBuilder navigationOrigin: @escaping () -> OriginContent, @ViewBuilder navigationDestination: @escaping () -> DestinationContent) {
        self.linkType = linkType
        self.navigationOrigin = navigationOrigin
        self.navigationDestination = navigationDestination
        self._showDestinationView = showDestinationView
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
                NavigationLink(isActive: $showDestinationView) {
                    navigationDestination()
                } label: {
                    EmptyView()
                }
                .opacity(0.0)
                .buttonStyle(PlainButtonStyle())
                navigationOrigin()
            }
        } else {
            NavigationLink(isActive: $showDestinationView) {
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
