import SwiftUI
import WebKit
import UIKit

/* Het spel in een WKWebView.

   Waarom een eigen webservertje en niet gewoon het bestand openen? Twee
   redenen, allebei hard:

   - De camera. getUserMedia werkt alleen in een 'veilige context'. Een
     file://-adres of een eigen schema is dat niet, http://127.0.0.1 wél. Zonder
     server telt de camera dus geen enkele push-up.
   - De opslag. Op file:// weigert WebKit localStorage en IndexedDB, en daar
     staat alles in: je voortgang, je instellingen, je eigen muziek.

   De server luistert alleen op de loopback van het toestel zelf, op een poort
   die iOS uitdeelt. Er komt niets naar buiten en er kan niets naar binnen.
*/
struct SpelScherm: UIViewRepresentable {
  func makeCoordinator() -> Baas { Baas() }

  func makeUIView(context: Context) -> WKWebView {
    let instelling = WKWebViewConfiguration()
    // Video en geluid mogen meteen spelen; anders moet je overal eerst tikken.
    instelling.allowsInlineMediaPlayback = true
    instelling.mediaTypesRequiringUserActionForPlayback = []

    // De pagina mag de telefoon laten trillen bij elke getelde push-up.
    instelling.userContentController.add(context.coordinator, name: "telefoon")

    let web = WKWebView(frame: .zero, configuration: instelling)
    web.uiDelegate = context.coordinator
    web.navigationDelegate = context.coordinator
    web.isOpaque = false
    web.backgroundColor = .black
    web.scrollView.backgroundColor = .black
    web.scrollView.bounces = false
    web.scrollView.showsVerticalScrollIndicator = false
    web.scrollView.contentInsetAdjustmentBehavior = .never
    web.allowsBackForwardNavigationGestures = false

    context.coordinator.open(in: web)
    return web
  }

  func updateUIView(_ web: WKWebView, context: Context) {}

  final class Baas: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private let server = LokaleServer()
    private let tik = UIImpactFeedbackGenerator(style: .medium)
    private let klap = UIImpactFeedbackGenerator(style: .heavy)

    func open(in web: WKWebView) {
      guard let poort = server.start(),
            let adres = URL(string: "http://127.0.0.1:\(poort)/") else {
        web.loadHTMLString(Self.foutpagina, baseURL: nil)
        return
      }
      web.load(URLRequest(url: adres))
    }

    /// Trillen bij een push-up. Een gewone herhaling is een tik, een kill of
    /// een verslagen boss een klap; dat voelt in je handen als een treffer.
    func userContentController(_ baas: WKUserContentController,
                               didReceive bericht: WKScriptMessage) {
      guard bericht.name == "telefoon" else { return }
      switch bericht.body as? String {
      case "rep":  tik.prepare();  tik.impactOccurred(intensity: 0.7)
      case "kill": klap.prepare(); klap.impactOccurred()
      default:     break
      }
    }

    /// De pagina vraagt om de camera. De echte vraag heeft iOS dan al gesteld
    /// met de tekst uit de projectinstellingen; hier zeggen we alleen dat deze
    /// pagina hem mag gebruiken.
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
      decisionHandler(.grant)
    }

    /// Een link naar buiten (de privacypagina bijvoorbeeld) hoort in Safari,
    /// niet in het spel.
    func webView(_ webView: WKWebView,
                 decidePolicyFor actie: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      if let url = actie.request.url,
         let gastheer = url.host,
         gastheer != "127.0.0.1",
         actie.navigationType == .linkActivated {
        UIApplication.shared.open(url)
        decisionHandler(.cancel)
        return
      }
      decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail: WKNavigation!, withError fout: Error) {
      webView.loadHTMLString(Self.foutpagina, baseURL: nil)
    }

    static let foutpagina = """
      <html><body style="background:#05060a;color:#fff;font:16px -apple-system;
      display:flex;align-items:center;justify-content:center;height:100vh;
      text-align:center;padding:30px">
      <p>Het spel kon niet worden geopend.<br>Sluit de app helemaal af en probeer opnieuw.</p>
      </body></html>
      """
  }
}
