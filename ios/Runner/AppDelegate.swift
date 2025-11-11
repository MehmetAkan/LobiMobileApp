import Flutter
import UIKit
import GoogleMaps  // 🗺️ EKLENDI

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 🗺️ Google Maps API Key - EKLENDI
    // ⚠️ BURAYA .env DOSYASINDAKI iOS KEY'İ YAPIŞTIRACAKSINIZ
    GMSServices.provideAPIKey("AIzaSyCz4eqLYEtEYbHjwd8rcRZVJmL0AHiPtNc")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}