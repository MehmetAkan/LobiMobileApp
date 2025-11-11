import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 🔒 GÜVENL İ YAKLAŞIM: .env dosyasından API key'i oku
    // GitHub'a push edildiğinde gerçek key görünmeyecek
    
    // 1. .env dosyasının yolunu bul
    if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
       let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) {
      
      // 2. .env içeriğini parse et
      let envLines = envContent.components(separatedBy: .newlines)
      var envDict: [String: String] = [:]
      
      for line in envLines {
        // Boş satırları ve yorumları atla
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty && !trimmed.hasPrefix("#") else { continue }
        
        // KEY=VALUE formatını parse et
        let parts = trimmed.components(separatedBy: "=")
        guard parts.count >= 2 else { continue }
        
        let key = parts[0].trimmingCharacters(in: .whitespaces)
        let value = parts[1...].joined(separator: "=")
          .trimmingCharacters(in: .whitespaces)
          .trimmingCharacters(in: CharacterSet(charactersIn: "\"")) // Tırnak işaretlerini kaldır
        
        envDict[key] = value
      }
      
      // 3. iOS Maps API key'ini al ve GMSServices'a ver
      if let apiKey = envDict["GOOGLE_MAPS_IOS_API_KEY"], !apiKey.isEmpty {
        GMSServices.provideAPIKey(apiKey)
        print("✅ Google Maps API key başarıyla yüklendi")
      } else {
        print("❌ HATA: .env dosyasında GOOGLE_MAPS_IOS_API_KEY bulunamadı!")
      }
    } else {
      print("❌ HATA: .env dosyası bulunamadı!")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}