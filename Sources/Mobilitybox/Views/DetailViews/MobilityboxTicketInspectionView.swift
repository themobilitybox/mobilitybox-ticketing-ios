import SwiftUI
import WebKit
import UniformTypeIdentifiers

@available(iOS 14.0, *)
struct TicketWebView: UIViewRepresentable {
    @State var ticket: MobilityboxTicket
    
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil // TODO: Remove me
    
    func makeCoordinator() -> TicketWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.limitsNavigationsToAppBoundDomains = false
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        
        let engineString = Mobilitybox.renderingEngine.engineString
        
        if engineString != nil {
            view.loadHTMLString(engineString!, baseURL: URL(string: "about:blank"))
        } else {
            print("no offline engine")
        }
        
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
            if let encodedTicket = try? String(data: JSONEncoder().encode(parent.ticket), encoding: String.Encoding.utf8) {
                webView.evaluateJavaScript("window.renderTicket(\(encodedTicket))")
                parent.loadStatusChanged?(false, nil)
            }
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

@available(iOS 14.0.0, *)
public struct MobilityboxTicketInspectionView: View {
    var ticket: MobilityboxTicket
    
    public init(ticket: MobilityboxTicket) {
        self.ticket = ticket
    }
    
    public var body: some View {
        TicketWebView(ticket: ticket)
    }
}
