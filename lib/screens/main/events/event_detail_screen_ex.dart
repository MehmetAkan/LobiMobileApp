import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';

/// EventDetailScreen Kullanım Kılavuzu
/// 
/// Bu dosya, EventDetailScreen'i OpenContainer ile nasıl kullanacağınızı gösterir.
/// 
/// NOT: Bu dosya sadece örnek amaçlıdır, projeye dahil edilmeyecektir.

class EventDetailUsageExample extends StatelessWidget {
  const EventDetailUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail Örnek')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ============================================================
          // ÖRNEK 1: OpenContainer ile animasyonlu geçiş
          // ============================================================
          _buildOpenContainerExample(),

          const SizedBox(height: 40),

          // ============================================================
          // ÖRNEK 2: Normal Navigator.push ile geçiş
          // ============================================================
          _buildNormalNavigationExample(context),
        ],
      ),
    );
  }

  /// OpenContainer ile animasyonlu geçiş
  /// Kart tıklandığında büyüyerek açılır
  Widget _buildOpenContainerExample() {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, action) {
        // Açılacak sayfa - EventDetailScreen
        return EventDetailScreen(
          testEventData: {
            'id': 'test-1',
            'title': 'Flutter Workshop',
            'coverPhotoUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
            'organizerName': 'Ahmet Yılmaz',
            'organizerPhotoUrl': 'https://i.pravatar.cc/150?img=12',
            'startDate': DateTime.now().add(const Duration(days: 2, hours: 5)),
            'endDate': DateTime.now().add(const Duration(days: 2, hours: 8)),
            'locationName': 'Bilge Adam Teknoloji',
            'locationAddress': 'Maslak, Sarıyer / İstanbul',
            'description': 'Flutter ve Firebase ile mobil uygulama geliştirme workshop\'u.',
          },
        );
      },
      closedBuilder: (context, action) {
        // Kapalı durum - Event kartı
        return EventCardVertical(
          imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
          title: 'Flutter Workshop',
          date: '17:00',
          location: 'Bilge Adam Teknoloji',
          attendeeCount: 42,
          isLiked: false,
          onTap: () {}, // OpenContainer otomatik açacak
          onLikeTap: () {},
        );
      },
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Normal Navigator.push ile geçiş
  /// Standart modal açılış animasyonu
  Widget _buildNormalNavigationExample(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              testEventData: {
                'id': 'test-2',
                'title': 'React Native Eğitimi',
                'coverPhotoUrl': 'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=800',
                'organizerName': 'Ayşe Demir',
                'organizerPhotoUrl': 'https://i.pravatar.cc/150?img=5',
                'startDate': DateTime.now().add(const Duration(days: 5, hours: 3)),
                'endDate': DateTime.now().add(const Duration(days: 5, hours: 6)),
                'locationName': 'Startup Hub',
                'locationAddress': 'Levent, Beşiktaş / İstanbul',
                'description': 'React Native ile cross-platform mobil uygulama geliştirme.',
              },
            ),
            fullscreenDialog: true,
          ),
        );
      },
      child: const Text('Normal Navigator ile Aç'),
    );
  }
}

/// ============================================================
/// KULLANIM ÖRNEKLERİ - Farklı Senaryolar
/// ============================================================

// ────────────────────────────────────────────────────────────
// 1. EventCardVertical içinde kullanım
// ────────────────────────────────────────────────────────────
/* 
OpenContainer(
  transitionDuration: const Duration(milliseconds: 500),
  transitionType: ContainerTransitionType.fade,
  openBuilder: (context, action) => EventDetailScreen(
    testEventData: eventData,
  ),
  closedBuilder: (context, action) => EventCardVertical(
    imageUrl: event.imageUrl,
    title: event.title,
    date: event.time, // Saat bilgisi (örn: "17:00")
    location: event.location,
    attendeeCount: event.attendeeCount,
    isLiked: event.isLiked,
    onTap: () {}, // OpenContainer otomatik açacak
    onLikeTap: () {},
  ),
);
*/

// ────────────────────────────────────────────────────────────
// 2. EventCardHorizontal içinde kullanım
// ────────────────────────────────────────────────────────────
/*
OpenContainer(
  transitionDuration: const Duration(milliseconds: 500),
  transitionType: ContainerTransitionType.fadeThrough,
  openBuilder: (context, action) => EventDetailScreen(
    testEventData: eventData,
  ),
  closedBuilder: (context, action) => EventCardHorizontal(
    imageUrl: event.imageUrl,
    title: event.title,
    date: event.date, // Tarih bilgisi
    location: event.location,
    attendeeCount: event.attendeeCount,
    isLiked: event.isLiked,
    onTap: () {}, // OpenContainer otomatik açacak
    onLikeTap: () {},
  ),
);
*/

// ────────────────────────────────────────────────────────────
// 3. Liste içinde kullanım (GroupedEventList gibi)
// ────────────────────────────────────────────────────────────
/*
ListView.builder(
  itemCount: events.length,
  itemBuilder: (context, index) {
    final event = events[index];
    
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, action) => EventDetailScreen(
        testEventData: {
          'id': event.id,
          'title': event.title,
          'coverPhotoUrl': event.imageUrl,
          'organizerName': event.organizerName,
          'organizerPhotoUrl': event.organizerPhotoUrl,
          'startDate': event.startDate,
          'endDate': event.endDate,
          'locationName': event.locationName,
          'locationAddress': event.locationAddress,
          'description': event.description,
        },
      ),
      closedBuilder: (context, action) => EventCardVertical(
        imageUrl: event.imageUrl,
        title: event.title,
        date: event.time,
        location: event.location,
        attendeeCount: event.attendeeCount,
        isLiked: event.isLiked,
        onTap: () {},
        onLikeTap: () {},
      ),
    );
  },
);
*/

// ────────────────────────────────────────────────────────────
// 4. Test verisi ile kullanım
// ────────────────────────────────────────────────────────────
/*
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EventDetailScreen(
      testEventData: {
        'id': 'test-event-1',
        'title': 'Test Etkinliği',
        'coverPhotoUrl': 'https://example.com/image.jpg',
        'organizerName': 'Test Organizatör',
        'organizerPhotoUrl': 'https://example.com/avatar.jpg',
        'startDate': DateTime.now().add(Duration(days: 1)),
        'endDate': DateTime.now().add(Duration(days: 1, hours: 3)),
        'locationName': 'Test Mekan',
        'locationAddress': 'Test Adres',
        'description': 'Test açıklama metni...',
      },
    ),
  ),
);
*/

/// ============================================================
/// GEREKLİ PAKET
/// ============================================================
/// pubspec.yaml dosyasına eklenecek:
/// 
/// dependencies:
///   animations: ^2.0.11
/// ============================================================