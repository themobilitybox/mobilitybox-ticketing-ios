import Foundation
import SwiftUI
import WebKit

@available(iOS 14.0, *)
struct IdentificationFormWebView: UIViewRepresentable {
    @Binding var coupon: MobilityboxCoupon
    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    var activationStartDateTime: Binding<Date>? = nil
    @Binding var showLoadingSpinner: Bool
    var couponActivationRunning = false
    
    func makeCoordinator() -> IdentificationFormWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        webConfiguration.limitsNavigationsToAppBoundDomains = false
        
        webConfiguration.userContentController.add(context.coordinator, name: "activateCouponListener")
        webConfiguration.userContentController.add(context.coordinator, name: "closeIdentificationFormListener")
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        
        let identificationViewEngineString = Mobilitybox.identificationViewEngine.engineString
        
        if identificationViewEngineString != nil {
            view.loadHTMLString(identificationViewEngineString!, baseURL: URL(string: "about:blank"))
        } else {
            print("no offline identification view engine")
        }
        
        return view
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    mutating func setCouponActivateRunning(state: Bool) {
        self.couponActivationRunning = state
    }
    
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: IdentificationFormWebView
        
        init(_ parent: IdentificationFormWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let json = try? JSONEncoder().encode(parent.coupon.product.identification_medium_schema) {
                let theJSONText = String(data: json, encoding: .utf8)!
                webView.evaluateJavaScript("window.renderIdentificationView(\(theJSONText))")
                
                let activateSourceJs = """
                    document.getElementById('submit_activate_button').addEventListener('click', function(){
                        const identification_medium = window.getIdentificationMedium()
                        window.webkit.messageHandlers.activateCouponListener.postMessage(identification_medium);
                    })
                """
                
                let closeIdentificationFormSourceJs = """
                    document.getElementById('close_identification_form_button').addEventListener('click', function(){
                        window.webkit.messageHandlers.closeIdentificationFormListener.postMessage("close");
                    })
                """
                
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(activateSourceJs)
                    webView.evaluateJavaScript(closeIdentificationFormSourceJs)
                }
            }
            
            parent.loadStatusChanged?(false, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let url = navigationAction.request.url
            
            if url != nil && url?.absoluteString != "about:blank" {
                decisionHandler(.cancel)
                UIApplication.shared.open(url!)
            } else {
                decisionHandler(.allow)
            }
        }
        
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "activateCouponListener", let messageBody = message.body as? String {
                print("activate")
                if !self.parent.couponActivationRunning {
                    self.parent.showLoadingSpinner = true
                    self.parent.setCouponActivateRunning(state: true)
                    let identificationMedium = MobilityboxIdentificationMedium(identification_medium_json: messageBody)
                    self.parent.coupon.activate(identificationMedium: identificationMedium, activationStartDateTime: self.parent.activationStartDateTime?.wrappedValue) { ticketCode in
                        self.parent.activateCouponCallback(self.parent.coupon, ticketCode)
                        self.parent.presentationMode.wrappedValue.dismiss()
                        self.parent.setCouponActivateRunning(state: false)
                    }
                }
            }
            if message.name == "closeIdentificationFormListener", let messageBody = message.body as? String {
                if messageBody == "close" {
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print(message)
        }
    }
    
}

@available(iOS 14.0, *)
public struct MobilityboxIdentificationView: View {
    @Binding var coupon: MobilityboxCoupon
    var activationStartDateTime: Binding<Date>?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    @State var showLoadingSpinner: Bool = false
    
    public init(coupon: Binding<MobilityboxCoupon>, activateCouponCallback: @escaping ((MobilityboxCoupon, MobilityboxTicketCode) -> Void), activationStartDateTime: Binding<Date>? = nil) {
        self._coupon = coupon
        self.activateCouponCallback = activateCouponCallback
        self.activationStartDateTime = activationStartDateTime
    }
    
    
    public var body: some View {
        ZStack {
            IdentificationFormWebView(coupon: $coupon, presentationMode: presentationMode, activateCouponCallback: activateCouponCallback, activationStartDateTime: activationStartDateTime, showLoadingSpinner: $showLoadingSpinner)
            if showLoadingSpinner {
                ZStack {
                    Color.white.opacity(0.5).edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            }
        }
    }
}

