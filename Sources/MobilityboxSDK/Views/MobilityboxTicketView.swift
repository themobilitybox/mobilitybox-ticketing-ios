import SwiftUI
import WebKit

@available(iOS 14.0, macOS 11.0, *)
struct TicketWebView: UIViewRepresentable {
    @State var ticket: MobilityboxTicket
    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    func makeCoordinator() -> TicketWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.limitsNavigationsToAppBoundDomains = true
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        
        let engine_url = URL(string: "https://ticket-rendering-engine-integration.themobilitybox.com/engine/1")!
        view.load(URLRequest(url: engine_url))
        
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: TicketWebView
        
        init(_ parent: TicketWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let theJSONData = try? JSONSerialization.data(
                withJSONObject: parent.ticket.ticketData as Any,
                options: [])
            let theJSONText = String(data: theJSONData ?? Data("".utf8),
                                     encoding: .utf8)
            webView.evaluateJavaScript("window.renderTicket(\(theJSONText!))")
            parent.loadStatusChanged?(false, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
        
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print(message.name)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print(message)
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct MobilityboxTicketView: View {
    var ticket: MobilityboxTicket
    @State var title: String = ""
    @State var error: Error? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    public var body: some View {
        TicketWebView(ticket: ticket, presentationMode: presentationMode)
            .navigationTitle("Ticket")
        
    }
}
