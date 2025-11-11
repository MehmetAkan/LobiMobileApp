import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lobi_application/providers/location_provider.dart';

class LocationTestScreen extends ConsumerStatefulWidget {
  const LocationTestScreen({super.key});

  @override
  ConsumerState<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends ConsumerState<LocationTestScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(placeSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Testi'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Arama input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Yer ara... (örn: Antalya Üni)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                ref.read(placeSearchProvider.notifier).searchPlaces(
                      query: query,
                    );
              },
            ),
          ),

          // Sonuçlar
          Expanded(
            child: searchResults.when(
              data: (predictions) {
                if (predictions.isEmpty) {
                  return const Center(
                    child: Text('Bir yer arayın...'),
                  );
                }

                return ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(prediction.mainText),
                      subtitle: Text(prediction.secondaryText),
                      onTap: () async {
                        // Detayları al
                        final notifier = ref.read(placeSearchProvider.notifier);
                        final location = await notifier.selectPlace(
                          prediction.placeId,
                        );

                        if (location != null && mounted) {
                          // Seçili konumu kaydet
                          ref.read(selectedLocationProvider.notifier).state =
                              location;

                          // Sonucu göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('✅ Konum seçildi:'),
                                  Text(location.placeName),
                                  Text('📍 ${location.detailAddress}'),
                                  Text(
                                      '🗺️ ${location.latitude}, ${location.longitude}'),
                                ],
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Hata: $e'),
              ),
            ),
          ),

          // Seçili konum
          Consumer(
            builder: (context, ref, child) {
              final selected = ref.watch(selectedLocationProvider);

              if (selected == null) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Seçili Konum:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('📍 ${selected.placeName}'),
                    Text('🏘️ ${selected.detailAddress}'),
                    Text('🗺️ ${selected.latitude}, ${selected.longitude}'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}