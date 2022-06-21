import Foundation
import SwiftUI
import WebKit

@available(iOS 14.0, macOS 11.0, *)
struct IdentificationFormWebView: UIViewRepresentable {
    @Binding var coupon: MobilityboxCoupon
    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicket) -> Void)
    
    func makeCoordinator() -> IdentificationFormWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        
        let activateSourceJs = """
            document.getElementById('submit_activate_button').addEventListener('click', function(){
                const identification_medium = window.getIdentificationMedium()
                window.webkit.messageHandlers.activateCouponListener.postMessage(identification_medium);
            })
        """
        let activateScript = WKUserScript(source: activateSourceJs, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        
        let closeIdentificationFormSourceJs = """
            document.getElementById('close_identification_form_button').addEventListener('click', function(){
                window.webkit.messageHandlers.closeIdentificationFormListener.postMessage("close");
            })
        """
        let closeIdentificationFormScript = WKUserScript(source: closeIdentificationFormSourceJs, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        webConfiguration.userContentController.addUserScript(activateScript)
        webConfiguration.userContentController.addUserScript(closeIdentificationFormScript)
        webConfiguration.userContentController.add(context.coordinator, name: "activateCouponListener")
        webConfiguration.userContentController.add(context.coordinator, name: "closeIdentificationFormListener")
        
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = context.coordinator
        
        let projectBundle:Bundle = Bundle.module
        let identificationMediumFormHtmlFile = projectBundle.url(forResource: "Templates/identification_medium_form_template", withExtension: "html")
        
        view.loadFileURL(identificationMediumFormHtmlFile!,
                         allowingReadAccessTo: identificationMediumFormHtmlFile!)
        
        return view
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: IdentificationFormWebView
        
        init(_ parent: IdentificationFormWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let json = try? JSONEncoder().encode(parent.coupon.product.identification_medium_schema) {
                let theJSONText = String(data: json, encoding: .utf8)!
                webView.evaluateJavaScript("window.loadIdentificationForms(\(theJSONText))")
            }
            
            parent.loadStatusChanged?(false, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
        
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "activateCouponListener", let messageBody = message.body as? String {
                print("activate")
                let passenger = MobilityboxPassenger(identification_medium_json: messageBody)
                parent.coupon.activate(passenger: passenger) { ticket in
                    self.parent.activateCouponCallback(self.parent.coupon, ticket)
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
            if message.name == "closeIdentificationFormListener", let messageBody = message.body as? String {
                if messageBody == "close" {
                    parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print(message)
        }
    }
    
}

@available(iOS 14.0, macOS 11.0, *)
public struct MobilityboxIdentificationView: View {
    @Binding var coupon: MobilityboxCoupon
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicket) -> Void)
    
    public init(coupon: Binding<MobilityboxCoupon>, activateCouponCallback: @escaping ((MobilityboxCoupon, MobilityboxTicket) -> Void)) {
        self._coupon = coupon
        self.activateCouponCallback = activateCouponCallback
    }
    
    public var body: some View {
        IdentificationFormWebView(coupon: $coupon, presentationMode: presentationMode, activateCouponCallback: activateCouponCallback)
    }
}

