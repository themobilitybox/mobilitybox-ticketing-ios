import Foundation
import SwiftUI
import WebKit

@available(iOS 14.0, *)
public struct MobilityboxIdentificationFormWebView: UIViewRepresentable {
    @Binding var coupon: MobilityboxCoupon
    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    var activationStartDateTime: Binding<Date>? = nil
    @Binding var showLoadingSpinner: Bool
    @Binding var showActivationFailedAlert: Bool
    var couponActivationRunning = false
    
    public init(coupon: Binding<MobilityboxCoupon>, presentationMode: Binding<PresentationMode>, activateCouponCallback: @escaping (MobilityboxCoupon, MobilityboxTicketCode) -> Void, activationStartDateTime: Binding<Date>? = nil, showLoadingSpinner: Binding<Bool>, showActivationFailedAlert: Binding<Bool>) {
        self._coupon = coupon
        self.presentationMode = presentationMode
        self.activateCouponCallback = activateCouponCallback
        self.activationStartDateTime = activationStartDateTime
        self._showLoadingSpinner = showLoadingSpinner
        self._showActivationFailedAlert = showActivationFailedAlert
    }
    
    public func makeCoordinator() -> MobilityboxIdentificationFormWebView.Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
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
    
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    public func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    public mutating func setCouponActivateRunning(state: Bool) {
        self.couponActivationRunning = state
    }
    
    
    public class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: MobilityboxIdentificationFormWebView
        
        public init(_ parent: MobilityboxIdentificationFormWebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let identificationMediumSchemaJson = try? JSONEncoder().encode(parent.coupon.product.identification_medium_schema)
            let tariffSettingsSchemaJson = try? JSONEncoder().encode(parent.coupon.product.tariff_settings_schema)
            
            if identificationMediumSchemaJson != nil || tariffSettingsSchemaJson != nil {
                let identificationMediumSchemaJsonString = identificationMediumSchemaJson != nil ? String(data: identificationMediumSchemaJson!, encoding: .utf8)! : "null"
                let tariffSettingsSchemaJsonString = identificationMediumSchemaJson != nil ? String(data: tariffSettingsSchemaJson!, encoding: .utf8)! : "null"
                
                
                
                webView.evaluateJavaScript("window.renderIdentificationView(\(identificationMediumSchemaJsonString), \(tariffSettingsSchemaJsonString))")
                
                let activateSourceJs = """
                    document.getElementById('submit_activate_button').addEventListener('click', function(){
                        const identification_medium = window.getIdentificationMedium()
                        const tariff_settings = window.getTariffSettings()
                
                        window.webkit.messageHandlers.activateCouponListener.postMessage(JSON.stringify({"identification_medium": identification_medium, "tariff_settings": tariff_settings}));
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
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let url = navigationAction.request.url
            
            if url != nil && url?.absoluteString != "about:blank" {
                decisionHandler(.cancel)
                UIApplication.shared.open(url!)
            } else {
                decisionHandler(.allow)
            }
        }
        
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "activateCouponListener", let messageBodyString = message.body as? String {
                print("activate")
                if !self.parent.couponActivationRunning {
                    self.parent.showLoadingSpinner = true
                    self.parent.setCouponActivateRunning(state: true)
                    let messageBody = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: messageBodyString.data(using: .utf8)!)
                    
                    var identificationMedium: MobilityboxIdentificationMedium? = nil
                    var tariffSettings: MobilityboxTariffSettings? = nil
                    
                    if let identificationMediumJson = messageBody?.dictionary?["identification_medium"] {
                        if identificationMediumJson.string != nil {
                            identificationMedium = MobilityboxIdentificationMedium(identification_medium_json: identificationMediumJson.string!)
                        }
                        
                    }
                        
                    if let tariffSettingsJson = messageBody?.dictionary?["tariff_settings"] {
                        if tariffSettingsJson.string != nil {
                            tariffSettings = MobilityboxTariffSettings(tariff_settings_json: tariffSettingsJson.string!)
                        }
                    }
                    
                    
                    if identificationMedium != nil {
                        self.parent.coupon.activate(identificationMedium: identificationMedium!, tariffSettings: tariffSettings, activationStartDateTime: self.parent.activationStartDateTime?.wrappedValue) { ticketCode in
                            self.parent.activateCouponCallback(self.parent.coupon, ticketCode)
                            self.parent.presentationMode.wrappedValue.dismiss()
                            self.parent.setCouponActivateRunning(state: false)
                        } onFailure: { mobilityboxError in
                            print("Identification View: failed to activate coupon")
                            self.parent.setCouponActivateRunning(state: false)
                            self.parent.showLoadingSpinner = false
                            self.parent.showActivationFailedAlert = true
                        }
                    } else if tariffSettings != nil {
                        print("update Tariff Settings")
                    }
                }
            }
            if message.name == "closeIdentificationFormListener", let messageBody = message.body as? String {
                if messageBody == "close" {
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
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
    @State var showActivationFailedAlert: Bool = false
    
    public init(coupon: Binding<MobilityboxCoupon>, activateCouponCallback: @escaping ((MobilityboxCoupon, MobilityboxTicketCode) -> Void), activationStartDateTime: Binding<Date>? = nil) {
        self._coupon = coupon
        self.activateCouponCallback = activateCouponCallback
        self.activationStartDateTime = activationStartDateTime
    }
    
    
    public var body: some View {
        ZStack {
            MobilityboxIdentificationFormWebView(coupon: $coupon, presentationMode: presentationMode, activateCouponCallback: activateCouponCallback, activationStartDateTime: activationStartDateTime, showLoadingSpinner: $showLoadingSpinner, showActivationFailedAlert: $showActivationFailedAlert)
                .alert(isPresented: $showActivationFailedAlert) {
                    Alert(title: Text("Hinweis"), message: Text("Die Aktivierung des Tickets wurde wegen eines Fehlers abgebrochen. Bitte versuchen Sie es erneut."), dismissButton: .default(Text("OK")))
                }
            if showLoadingSpinner {
                ZStack {
                    Color.white.opacity(0.5).edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            }
        }
    }
}

