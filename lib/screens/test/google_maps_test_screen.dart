import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Maps Test Screen
/// 
/// Bu ekran Google Maps kurulumunun doğru yapıldığını test eder:
/// 1. .env dosyasının yüklendiğini
/// 2. API key'lerin okunabildiğini
/// 3. Paketlerin doğru kurulduğunu
class GoogleMapsTestScreen extends StatelessWidget {
  const GoogleMapsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(
              Icons.map,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Google Maps Kurulum Testi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              'API key\'lerin doğru yüklendiğini kontrol edin:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Test Results
            _buildTestItem(
              title: 'Android API Key',
              value: dotenv.env['GOOGLE_MAPS_ANDROID_API_KEY'],
              icon: Icons.android,
            ),
            
            const SizedBox(height: 16),
            
            _buildTestItem(
              title: 'iOS API Key',
              value: dotenv.env['GOOGLE_MAPS_IOS_API_KEY'],
              icon: Icons.apple,
            ),
            
            const SizedBox(height: 16),
            
            _buildTestItem(
              title: 'Places API Key',
              value: dotenv.env['GOOGLE_MAPS_API_KEY'],
              icon: Icons.place,
            ),
            
            const Spacer(),
            
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _allKeysLoaded() ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _allKeysLoaded() ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _allKeysLoaded() ? Icons.check_circle : Icons.error,
                    color: _allKeysLoaded() ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _allKeysLoaded()
                          ? '✅ Tüm API key\'ler başarıyla yüklendi!'
                          : '❌ Bazı API key\'ler eksik. .env dosyasını kontrol edin.',
                      style: TextStyle(
                        color: _allKeysLoaded() ? Colors.green.shade900 : Colors.red.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info
            const Text(
              '💡 İpucu: Key\'lerin tam değerleri gösterilmiyor (güvenlik için). '
              'Sadece ilk 10 karakter görünür.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem({
    required String title,
    required String? value,
    required IconData icon,
  }) {
    final isLoaded = value != null && value.isNotEmpty;
    final displayValue = isLoaded 
        ? '${value.substring(0, value.length > 10 ? 10 : value.length)}...'
        : 'YÜKLENEMEDİ';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoaded ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isLoaded ? Colors.green : Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isLoaded ? Icons.check_circle : Icons.cancel,
            color: isLoaded ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  bool _allKeysLoaded() {
    return dotenv.env['GOOGLE_MAPS_ANDROID_API_KEY'] != null &&
        dotenv.env['GOOGLE_MAPS_IOS_API_KEY'] != null &&
        dotenv.env['GOOGLE_MAPS_API_KEY'] != null;
  }
}