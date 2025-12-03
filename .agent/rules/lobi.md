---
trigger: always_on
---

# Lobi – Etkinlik ve Topluluk Mobil Uygulaması

Lobi, etkinlikleri keşfetmek, oluşturmak ve yönetmek için modern bir mobil uygulamadır.
Uygulama, gerçek bir ürün gibi ölçeklenebilir: temiz mimari, Supabase arka ucu, tema sistemi ve özellik tabanlı yapı.

---

## 1. Proje Özeti

### Lobi Nedir?

Lobi, kullanıcıların şunları yapabileceği bir mobil uygulamadır:

- Güvenli bir arka uç (Supabase) ile kaydolma/giriş yapma.
- Kendi etkinliklerini oluşturma ve yönetme.
- Çevrelerindeki etkinlikleri keşfetme (planlanmış).
- Etkinliklere katılma, kaydetme ve güncellemeleri takip etme (planlanmış).

Amaç, yalnızca bir demo uygulaması değil, **üretim düzeyinde bir etkinlik ve topluluk platformu** oluşturmaktır.


Proje yazılırken dikkat edilmesi gerekenler, yapıya saygı duyulmalıdır. Proje büyecektir. Profesyonel bir şekilde ilerlenmelidir. Büyük projeler örnek alınmalıdır.
Çözümler, servis dosyaları ileriye dönük yazılmalıdır.

Projedeki tablolar ve kolanları;

-> profiles

[
  {
    "column_name": "user_id"
  },
  {
    "column_name": "first_name"
  },
  {
    "column_name": "last_name"
  },
  {
    "column_name": "birth_date"
  },
  {
    "column_name": "created_at"
  },
  {
    "column_name": "updated_at"
  },
  {
    "column_name": "avatar_url"
  },
  {
    "column_name": "bio"
  },
  {
    "column_name": "instagram"
  },
  {
    "column_name": "twitter"
  },
  {
    "column_name": "youtube"
  },
  {
    "column_name": "tiktok"
  },
  {
    "column_name": "website"
  },
  {
    "column_name": "phone"
  },
  {
    "column_name": "fcm_token"
  },
  {
    "column_name": "notification_enabled"
  },
  {
    "column_name": "username"
  },
  {
    "column_name": "linkedin"
  }
]

-> events
[
  {
    "column_name": "id"
  },
  {
    "column_name": "title"
  },
  {
    "column_name": "description"
  },
  {
    "column_name": "cover_image_url"
  },
  {
    "column_name": "share_slug"
  },
  {
    "column_name": "start_date"
  },
  {
    "column_name": "end_date"
  },
  {
    "column_name": "location_name"
  },
  {
    "column_name": "location_address"
  },
  {
    "column_name": "location_lat"
  },
  {
    "column_name": "location_lng"
  },
  {
    "column_name": "location_place_id"
  },
  {
    "column_name": "city"
  },
  {
    "column_name": "district"
  },
  {
    "column_name": "country"
  },
  {
    "column_name": "is_public"
  },
  {
    "column_name": "requires_approval"
  },
  {
    "column_name": "max_participants"
  },
  {
    "column_name": "category_id"
  },
  {
    "column_name": "organizer_id"
  },
  {
    "column_name": "participant_count"
  },
  {
    "column_name": "popularity_score"
  },
  {
    "column_name": "score_updated_at"
  },
  {
    "column_name": "status"
  },
  {
    "column_name": "is_cancelled"
  },
  {
    "column_name": "cancelled_at"
  },
  {
    "column_name": "cancellation_reason"
  },
  {
    "column_name": "created_at"
  },
  {
    "column_name": "updated_at"
  },
  {
    "column_name": "view_count"
  }
]


-> event_categories
[
  {
    "column_name": "id"
  },
  {
    "column_name": "name"
  },
  {
    "column_name": "display_order"
  },
  {
    "column_name": "is_active"
  },
  {
    "column_name": "created_at"
  },
  {
    "column_name": "icon_name"
  }
]

-> event_images

[
  {
    "column_name": "id"
  },
  {
    "column_name": "url"
  },
  {
    "column_name": "category_id"
  },
  {
    "column_name": "tags"
  },
  {
    "column_name": "is_featured"
  },
  {
    "column_name": "created_at"
  },
  {
    "column_name": "updated_at"
  }
]

-> event_invitations

[
  {
    "column_name": "id"
  },
  {
    "column_name": "event_id"
  },
  {
    "column_name": "invited_email"
  },
  {
    "column_name": "invited_user_id"
  },
  {
    "column_name": "status"
  },
  {
    "column_name": "invitation_token"
  },
  {
    "column_name": "invited_at"
  },
  {
    "column_name": "responded_at"
  },
  {
    "column_name": "expires_at"
  }
]

-> event_participants

[
  {
    "column_name": "id"
  },
  {
    "column_name": "event_id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "status"
  },
  {
    "column_name": "joined_at"
  },
  {
    "column_name": "approved_at"
  },
  {
    "column_name": "rejected_at"
  },
  {
    "column_name": "cancelled_at"
  },
  {
    "column_name": "cancellation_reason"
  },
  {
    "column_name": "attended_at"
  },
  {
    "column_name": "verification_code"
  }
]

-> event_views

[
  {
    "column_name": "event_id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "first_viewed_at"
  }
]

-> notifications

[
  {
    "column_name": "id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "event_id"
  },
  {
    "column_name": "type"
  },
  {
    "column_name": "title"
  },
  {
    "column_name": "body"
  },
  {
    "column_name": "is_read"
  },
  {
    "column_name": "sent_at"
  },
  {
    "column_name": "delivered_at"
  },
  {
    "column_name": "data"
  },
  {
    "column_name": "created_at"
  }
]

-> support_messages

[
  {
    "column_name": "id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "message"
  },
  {
    "column_name": "created_at"
  }
]


-> user_favorite_categories
[
  {
    "column_name": "id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "category_id"
  },
  {
    "column_name": "created_at"
  }
]

->user_interests

[
  {
    "column_name": "id"
  },
  {
    "column_name": "user_id"
  },
  {
    "column_name": "category_id"
  },
  {
    "column_name": "source"
  },
  {
    "column_name": "created_at"
  }
]