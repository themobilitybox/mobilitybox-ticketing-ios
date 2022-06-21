import SwiftUI
import WebKit
import UniformTypeIdentifiers

@available(iOS 13.0, macOS 11.0, *)
struct TicketWebView: UIViewRepresentable {
    @State var ticket: MobilityboxTicket
    @State var offlineMode: Bool
//    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil // TODO: Remove me
    
    func makeCoordinator() -> TicketWebView.Coordinator {
        Coordinator(self)
    }
    
    @available(iOS 14.0, *)
    func loadWebArchive(data: String, view: WKWebView){
        guard let webArchive = Data(base64Encoded: data),
              let mimeType = UTType.webArchive.preferredMIMEType,
              let baseUrl = URL(string: "about:blank") else { return }
        view.load(webArchive, mimeType: mimeType, characterEncodingName: "utf-8", baseURL: baseUrl)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        if #available(iOS 14.0, *) {
            webConfiguration.limitsNavigationsToAppBoundDomains = false
        }
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        

        if offlineMode {
            print("Load offline engine…")
            if let data = UserDefaults.standard.string(forKey: "offline_engine") {
                puts("Found Offline Engine Conetent: \(data)")
                if #available(iOS 14.0, *) {
                    loadWebArchive(data: data, view: view)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                print("No offline engine found")
            }
        }else{
            let engine_url = URL(string: "https://ticket-rendering-engine-integration.themobilitybox.com/engine/1")!
            view.load(URLRequest(url: engine_url))
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
        
        @available(iOS 14.0, *)
        func saveWebArchive(view: WKWebView) {
            view.createWebArchiveData { result in
                do {
                    let data = try result.get()
                    UserDefaults.standard.set(data.base64EncodedString(), forKey: "offline_engine")
                } catch {
                    print("Encountered error: \(error)")
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let encodedTicket = try? String(data: JSONEncoder().encode(parent.ticket), encoding: String.Encoding.utf8) {
                print("Rendering Ticket: '\(encodedTicket)'")
                print("window.renderTicket(\(encodedTicket))")
                webView.evaluateJavaScript("window.renderTicket(\(encodedTicket))")
                parent.loadStatusChanged?(false, nil)
                print("Creating web archive")
                if #available(iOS 14.0, *) {
                    saveWebArchive(view: webView)
                } else {
                    print("4")
                    // Fallback on earlier versions
                }
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

@available(iOS 13.0, *)
struct OfflineTicketWebView: UIViewRepresentable {
    @State var ticket: MobilityboxTicket
//    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    func makeCoordinator() -> OfflineTicketWebView.OfflineCoordinator {
        OfflineCoordinator(self)
    }
    
    @available(iOS 14.0, *)
    func loadWebArchive(data: String, view: WKWebView){
        guard let webArchive = Data(base64Encoded: data),
              let mimeType = UTType.webArchive.preferredMIMEType,
              let baseUrl = URL(string: "about:blank") else { return }
        view.load(webArchive, mimeType: mimeType, characterEncodingName: "utf-8", baseURL: baseUrl)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        if #available(iOS 14.0, *) {
            webConfiguration.limitsNavigationsToAppBoundDomains = false
        }
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        
        
//        let engine_url = URL(string: "https://ticket-rendering-engine-alpha.themobilitybox.com/engine/1")!
//        let engine_url = URL(string: "https://webdbg.com/test/appcache/")!
//        view.load(URLRequest(url: engine_url))
        
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    
    class OfflineCoordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: OfflineTicketWebView
        
        init(_ parent: OfflineTicketWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let encodedTicket = try? String(data: JSONEncoder().encode(parent.ticket), encoding: String.Encoding.utf8) {
                print("Rendering Ticket: '\(encodedTicket)'")
                print("window.renderTicket(\(encodedTicket))")
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
public struct MobilityboxTicketView: View {
    var ticket: MobilityboxTicket

    public var body: some View {
        TabView() {
            TicketWebView(ticket: ticket, offlineMode: false)
                .tabItem {
                    Label("Online", systemImage: "square.and.arrow.down")
                }.tag("Online")
            TicketWebView(ticket: ticket, offlineMode: true)
                .tabItem {
                    Label("Offline", systemImage: "square.and.arrow.up")
                }.tag("Offline")
        }
    }
    
    public init(ticket: MobilityboxTicket) {
        self.ticket = ticket
    }
}
