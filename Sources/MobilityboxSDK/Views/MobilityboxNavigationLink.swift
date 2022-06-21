import SwiftUI

@available(iOS 14.0, *)
public struct MobilityboxNavigationLink<Content: View>: View {
    @ViewBuilder var navigationDestination: () -> Content
    
    public init(@ViewBuilder navigationDestination: @escaping () -> Content) {
        self.navigationDestination = navigationDestination
    }
    
    
    public var body: some View {
        NavigationLink(destination: navigationDestination()){
            EmptyView()
        }
    }
}

