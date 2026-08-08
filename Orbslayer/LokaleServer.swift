import Foundation
import Network

/// Een piepklein webservertje binnen de app, alleen op de loopback van dit
/// toestel. Het serveert de bestanden die met de app meegeleverd zijn, dus het
/// spel opent ook zonder internet. Meer dan GET kan het niet, en dat hoeft ook
/// niet: er is één pagina.
final class LokaleServer {
  private var luisteraar: NWListener?
  private let rij = DispatchQueue(label: "pushbattle.server")

  /// Start op een vrije poort en geeft die terug. Geeft nil als het niet lukt.
  func start() -> UInt16? {
    if let poort = luisteraar?.port?.rawValue { return poort }
    let instelling = NWParameters.tcp
    instelling.allowLocalEndpointReuse = true
    instelling.requiredInterfaceType = .loopback
    guard let l = try? NWListener(using: instelling, on: .any) else { return nil }

    let wachten = DispatchSemaphore(value: 0)
    l.stateUpdateHandler = { staat in
      if case .ready = staat { wachten.signal() }
      if case .failed = staat { wachten.signal() }
    }
    l.newConnectionHandler = { [weak self] verbinding in self?.behandel(verbinding) }
    l.start(queue: rij)
    _ = wachten.wait(timeout: .now() + 5)

    guard let poort = l.port?.rawValue, poort > 0 else { return nil }
    luisteraar = l
    return poort
  }

  private func behandel(_ verbinding: NWConnection) {
    verbinding.start(queue: rij)
    verbinding.receive(minimumIncompleteLength: 1, maximumLength: 16 * 1024) { data, _, _, _ in
      let vraag = String(data: data ?? Data(), encoding: .utf8) ?? ""
      let antwoord = Self.antwoord(op: Self.padUit(vraag))
      verbinding.send(content: antwoord, completion: .contentProcessed { _ in
        verbinding.cancel()
      })
    }
  }

  /// "GET /manifest.json HTTP/1.1" → "/manifest.json"
  private static func padUit(_ vraag: String) -> String {
    let eerste = vraag.components(separatedBy: "\r\n").first ?? ""
    let stukken = eerste.components(separatedBy: " ")
    guard stukken.count >= 2, stukken[0] == "GET" else { return "/" }
    return stukken[1]
  }

  private static func antwoord(op pad: String) -> Data {
    guard let (inhoud, soort) = bestand(pad) else {
      let tekst = "niet gevonden"
      var kop = "HTTP/1.1 404 Not Found\r\n"
      kop += "Content-Type: text/plain; charset=utf-8\r\n"
      kop += "Content-Length: \(tekst.utf8.count)\r\n"
      kop += "Connection: close\r\n\r\n"
      return Data(kop.utf8) + Data(tekst.utf8)
    }
    var kop = "HTTP/1.1 200 OK\r\n"
    kop += "Content-Type: \(soort)\r\n"
    kop += "Content-Length: \(inhoud.count)\r\n"
    // Alles staat in de app zelf, dus bewaren in een cache heeft geen zin.
    kop += "Cache-Control: no-store\r\n"
    kop += "Connection: close\r\n\r\n"
    return Data(kop.utf8) + inhoud
  }

  /// Zoekt het bestand in de app op. De naam is genoeg: Xcode legt de
  /// meegeleverde bestanden plat neer, dus mappen doen er niet toe.
  private static func bestand(_ pad: String) -> (Data, String)? {
    var naam = pad.components(separatedBy: "?")[0].components(separatedBy: "#")[0]
    if naam.hasPrefix("/") { naam.removeFirst() }
    if naam.isEmpty || naam.hasSuffix("/") { naam += "index.html" }
    guard let laatste = naam.components(separatedBy: "/").last, !laatste.isEmpty else { return nil }

    let delen = laatste.components(separatedBy: ".")
    let staart = delen.count > 1 ? delen[delen.count - 1] : "html"
    let kaal = delen.count > 1 ? delen.dropLast().joined(separator: ".") : laatste

    guard let url = Bundle.main.url(forResource: kaal, withExtension: staart),
          let data = try? Data(contentsOf: url) else { return nil }
    return (data, soortVan(staart))
  }

  private static func soortVan(_ staart: String) -> String {
    switch staart.lowercased() {
    case "html", "htm":     return "text/html; charset=utf-8"
    case "js":              return "text/javascript; charset=utf-8"
    case "css":             return "text/css; charset=utf-8"
    case "json":            return "application/json; charset=utf-8"
    case "webmanifest":     return "application/manifest+json; charset=utf-8"
    case "svg":             return "image/svg+xml"
    case "png":             return "image/png"
    case "jpg", "jpeg":     return "image/jpeg"
    case "webp":            return "image/webp"
    case "ico":             return "image/x-icon"
    case "wav":             return "audio/wav"
    case "m4a":             return "audio/mp4"
    case "mp3":             return "audio/mpeg"
    case "txt":             return "text/plain; charset=utf-8"
    default:                return "application/octet-stream"
    }
  }
}
