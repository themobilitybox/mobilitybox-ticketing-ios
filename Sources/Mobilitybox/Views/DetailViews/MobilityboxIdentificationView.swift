import Foundation
import SwiftUI
@preconcurrency import WebKit

@available(iOS 14.0, *)
public struct MobilityboxIdentificationFormWebView: UIViewRepresentable {
    @Binding var coupon: MobilityboxCoupon
    @Binding var product: MobilityboxProduct
    var presentationMode: Binding<PresentationMode>
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    var activationStartDateTime: Binding<Date>? = nil
    var ticket: Binding<MobilityboxTicket>? = nil
    @Binding var showLoadingSpinner: Bool
    @Binding var showActivationFailedAlert: Bool
    @Binding var activationFailedError: MobilityboxError
    var couponActivationRunning = false
    
    public init(coupon: Binding<MobilityboxCoupon>, product: Binding<MobilityboxProduct>? = nil, presentationMode: Binding<PresentationMode>, activateCouponCallback: @escaping (MobilityboxCoupon, MobilityboxTicketCode) -> Void, activationStartDateTime: Binding<Date>? = nil, ticket: Binding<MobilityboxTicket>? = nil, showLoadingSpinner: Binding<Bool>, showActivationFailedAlert: Binding<Bool>, activationFailedError: Binding<MobilityboxError>) {
        self._coupon = coupon
        self._product = product ?? coupon.product
        self.presentationMode = presentationMode
        self.activateCouponCallback = activateCouponCallback
        self.activationStartDateTime = activationStartDateTime
        self.ticket = ticket
        self._showLoadingSpinner = showLoadingSpinner
        self._showActivationFailedAlert = showActivationFailedAlert
        self._activationFailedError = activationFailedError
    }
    
    public func makeCoordinator() -> MobilityboxIdentificationFormWebView.Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        context.coordinator.checkToInstantlyActivateCoupon()
           
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
        
        public func checkToInstantlyActivateCoupon() {
            if (self.parent.coupon.isRestoredCoupon()) {
                DispatchQueue.main.async {
                    self.parent.showLoadingSpinner = true
                    self.parent.setCouponActivateRunning(state: true)
                }
                
                self.parent.coupon.activateCall(body: "{}") { ticketCode in
                    DispatchQueue.main.async {
                        self.parent.activateCouponCallback(self.parent.coupon, ticketCode)
                        self.parent.presentationMode.wrappedValue.dismiss()
                        self.parent.setCouponActivateRunning(state: false)
                    }
                } onFailure: { mobilityboxError in
                    DispatchQueue.main.async {
                        self.parent.setCouponActivateRunning(state: false)
                        self.parent.showLoadingSpinner = false
                    }
                }
            }
        }
        
        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let identificationMediumSchemaJson = try? JSONEncoder().encode(parent.product.identification_medium_schema)
            let tariffSettingsSchemaJson = try? JSONEncoder().encode(parent.product.tariff_settings_schema)
            
            if identificationMediumSchemaJson != nil || tariffSettingsSchemaJson != nil {
                let identificationMediumSchemaJsonString = identificationMediumSchemaJson != nil ? String(data: identificationMediumSchemaJson!, encoding: .utf8)! : "null"
                let tariffSettingsSchemaJsonString = tariffSettingsSchemaJson != nil ? String(data: tariffSettingsSchemaJson!, encoding: .utf8)! : "null"
                var identificationMediumJsonString = "null"
                if (parent.ticket != nil) {
                    if let properties = parent.ticket?.wrappedValue.ticket.properties {
                        let identificationMediumJson = try? JSONEncoder().encode(properties.dictionary?["identification_medium"])
                        identificationMediumJsonString = identificationMediumJson != nil ? String(data: identificationMediumJson!, encoding: .utf8)! : "null"
                    }
                }
                
                webView.evaluateJavaScript("window.renderIdentificationView(\(identificationMediumSchemaJsonString), \(tariffSettingsSchemaJsonString), \(identificationMediumJsonString))")
     
                
                let activateSourceJs = """
                    document.getElementById('submit_activate_button').addEventListener('click', function(){
                        const identification_medium = window.getIdentificationMedium()
                        var tariff_settings = null
                
                        if (window.getTariffSettings != undefined) {
                            tariff_settings = window.getTariffSettings()
                        }
                
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
                        if (self.parent.ticket?.coupon_reactivation_key != nil) {
                            self.parent.coupon.reactivate(reactivation_key: self.parent.ticket!.wrappedValue.coupon_reactivation_key!, identificationMedium: identificationMedium, tariffSettings: tariffSettings) { ticketCode in
                                self.parent.activateCouponCallback(self.parent.coupon, ticketCode)
                                self.parent.presentationMode.wrappedValue.dismiss()
                                self.parent.setCouponActivateRunning(state: false)
                            } onFailure: { mobilityboxError in
                                print("Identification View: failed to activate coupon")
                                self.parent.setCouponActivateRunning(state: false)
                                self.parent.showLoadingSpinner = false
                                self.parent.activationFailedError = mobilityboxError ?? .unkown
                                self.parent.showActivationFailedAlert = true
                            }
                        } else {
                            self.parent.coupon.activate(identificationMedium: identificationMedium!, tariffSettings: tariffSettings, activationStartDateTime: self.parent.activationStartDateTime?.wrappedValue) { ticketCode in
                                self.parent.activateCouponCallback(self.parent.coupon, ticketCode)
                                self.parent.presentationMode.wrappedValue.dismiss()
                                self.parent.setCouponActivateRunning(state: false)
                            } onFailure: { mobilityboxError in
                                print("Identification View: failed to activate coupon")
                                self.parent.setCouponActivateRunning(state: false)
                                self.parent.showLoadingSpinner = false
                                self.parent.activationFailedError = mobilityboxError ?? .unkown
                                self.parent.showActivationFailedAlert = true
                            }
                        }
                    } else if tariffSettings != nil {
                        print("update Tariff Settings")
                    } else {
                        self.parent.setCouponActivateRunning(state: false)
                        self.parent.showLoadingSpinner = false
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
    @State var product: MobilityboxProduct
    @State var dataIsReady: Bool = false
    var activationStartDateTime: Binding<Date>?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    @State var showLoadingSpinner: Bool = false
    @State var showActivationFailedAlert: Bool = false
    @State var activationFailedError: MobilityboxError = .unkown
    var ticket: Binding<MobilityboxTicket>?
    
    public init(coupon: Binding<MobilityboxCoupon>, activateCouponCallback: @escaping ((MobilityboxCoupon, MobilityboxTicketCode) -> Void), activationStartDateTime: Binding<Date>? = nil, ticket: Binding<MobilityboxTicket>? = nil) {
        self._coupon = coupon
        self.product = coupon.product.wrappedValue
        self.activateCouponCallback = activateCouponCallback
        self.activationStartDateTime = activationStartDateTime
        self.ticket = ticket
    }
    
    func activationAlertText() -> String {
        return switch self.activationFailedError {
        case .before_earliest_activation_start_datetime:
            if self.coupon.earliest_activation_start_datetime != nil {
                "Das Ticket ist erst ab dem \(MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: self.coupon.earliest_activation_start_datetime!)!)) Uhr nutzbar."
            } else {
                "Das Ticket ist erst ab nächsten Monat nutzbar."
            }
        case .coupon_activation_expired:
            if self.coupon.earliest_activation_start_datetime != nil {
                "Das Ticket war nur noch bis zum \(MobilityboxFormatter.shortDateAndTime.string(from: MobilityboxFormatter.isoDateTime.date(from: self.coupon.earliest_activation_start_datetime!)!)) Uhr nutzbar."
            } else {
                "Das Ticket kann nicht mehr benutzt werden."
            }
        default:
            "Die Aktivierung des Tickets konnte aufgrund eines Fehlers nicht abgeschlossen werden. Bitte versuchen Sie es erneut."
        }
    }
    
    func checkToFetchNewProduct() {
        if (ticket != nil) {
            if let cycle = coupon.subscription?.subscription_cycles?.reversed().first(where: { cycle in
                return cycle.ordered && !cycle.coupon_activated && cycle.product_id != nil
            }) {
                MobilityboxProductCode(productId: cycle.product_id!).fetchProduct { fetchedProduct in
                    self.product = fetchedProduct
                    self.dataIsReady = true
                } onFailure: { error in
                    // TODO: handle error
                    self.dataIsReady = true
                }

            } else {
                // TODO: handle not found cycle
                self.dataIsReady = true
            }
        } else {
            self.dataIsReady = true
        }
    }
    
    
    public var body: some View {
        ZStack {
            if (self.dataIsReady) {
                MobilityboxIdentificationFormWebView(coupon: $coupon, product: $product, presentationMode: presentationMode, activateCouponCallback: activateCouponCallback, activationStartDateTime: activationStartDateTime, ticket: ticket, showLoadingSpinner: $showLoadingSpinner, showActivationFailedAlert: $showActivationFailedAlert, activationFailedError: $activationFailedError)
                    .alert(isPresented: $showActivationFailedAlert) {
                        Alert(title: Text("Hinweis"), message: Text(self.activationAlertText()), dismissButton: .default(Text("OK")))
                    }
                if showLoadingSpinner {
                    ZStack {
                        Color.white.opacity(0.5).edgesIgnoringSafeArea(.all)
                        ProgressView()
                    }
                }
            } else {
                ProgressView()
            }
        }.onAppear {
            self.checkToFetchNewProduct()
        }
    }
}

