# ARCHITECTURE — The House of Anatolia

> **Teknik mimari, veritabanı şeması, dosya yapısı ve veri akışları.**

---

## 🏗️ Teknoloji Stack'i

```
Frontend:  Vanilla HTML + CSS + JavaScript (ES Modules)
           Supabase JS Client (esm.sh CDN)
           Google Fonts (Cormorant Garamond + Inter)

Backend:   Supabase (PostgreSQL + Auth + Storage + RLS)

Deploy:    Henüz yapılmadı (Netlify planı)

CDN:       https://esm.sh/@supabase/supabase-js@2

Build:     YOK — Tüm kod tek HTML dosyasında, build step yok
```

**Karar:** Next.js / React kullanılmadı çünkü site **vitrin niteliğinde** ve build-step gerektirmeyen bir yaklaşım daha uygun. Tüm ağırlık Supabase'de.

---

## 📂 Dosya Yapısı (Detaylı)

### `index_supabase.html` (~2478 satır, 173 KB)
Ana sayfa. İçerdikleri:
- HTML: navbar, hero (sade), map-section, hakkımızda, GI tanımı, iletişim, footer
- CSS: tüm stiller `<style>` içinde (~1200 satır)
- JS: 2 ayrı `<script type="module">` bloğu
  1. UX layer (loader, cursor, scroll reveal, smooth scroll)
  2. Supabase data layer + i18n + map interaction + page view tracker

### `product.html` (~1783 satır, 84 KB)
Ürün detay sayfası. İçerdikleri:
- Hero (ürün adı, hero badge, hero subtitle)
- Ürün bölümleri (parts) — kart layout
- Galeri (lightbox)
- Kullanım adımları
- Talep formu (Supabase + FormSubmit dual)
- 2 script bloğu (i18n + form + galeri logic)

### `admin_yeni_urun_duzeltilmis_v2.html` (~4810 satır, 168 KB)
Admin paneli. **TEK SAYFA** — login + dashboard + tüm CRUD'lar aynı dosyada.
Kategoriler:
- Auth: login, logout, brute force, idle timeout
- City CRUD (TR/EN tabs)
- Product CRUD (TR/EN tabs, 6 EN alanı)
- Product sub-content: parts, usage_steps, gallery, options, packages, weights (hepsi TR/EN tabs)
- Site settings + homepage_sections
- Requests (read-only, status update)
- Newsletter subscribers (read + toggle + delete + CSV export)
- Page views analytics (4 stat + 30 günlük chart + breakdowns)
- Audit log (otomatik, her action'da)

### `gizlilik.html`, `kullanim.html`, `cerez.html`
Yasal sayfalar. Static HTML, koyu lüks tasarım.
Placeholder'lar: `[ŞİRKET ADI]`, `[VERGİ NO]`, `[MERSİS NO]`, `[ADRES]`, `[TELEFON]`
`<meta name="robots" content="noindex">` — Google'a indekslenmesin.

### `supabase_schema_v2_fixed.sql`
İlk DB şeması. **Referans dosya** — şu an aktif değil. Tüm yapı zaten Supabase'de.

---

## 🗄️ Veritabanı Şeması

### `cities`
```sql
id uuid PK
name text NOT NULL
name_en text
plate_code text NOT NULL
svg_id text NOT NULL  -- TR06, TR34 gibi (haritadaki path id)
sort_order int
is_active bool         -- Hover gösterilir mi?
is_clickable bool      -- Ürün sayfasına gider mi?
created_at, updated_at timestamptz
```

### `products`
```sql
id uuid PK
city_id uuid FK → cities.id
slug text UNIQUE NOT NULL  -- 'karabuk-safrani'
name text NOT NULL
name_en text
short_name text
short_name_en text
hero_badge text
hero_badge_en text
hero_title text NOT NULL
hero_title_en text
hero_subtitle text
hero_subtitle_en text
hero_left_text text
hero_right_text text
mini_image text         -- Harita üzeri tooltip görseli
hero_image text         -- Ürün sayfası ana görsel
parts_main_image text   -- Bölümler ana görseli
meta_description text   -- SEO
meta_description_en text
is_active bool
sort_order int
created_at, updated_at
```

### `product_parts`
```sql
id uuid PK
product_id uuid FK
title text NOT NULL
title_en text
subtitle text
subtitle_en text
description text NOT NULL
description_en text
image text
sort_order int
is_active bool
```

### `usage_steps`
```sql
id uuid PK
product_id uuid FK
title text NOT NULL
title_en text
description text NOT NULL
description_en text
sort_order int
is_active bool
```

### `gallery_images`
```sql
id uuid PK
product_id uuid FK
image text NOT NULL
caption text
caption_en text
sort_order int
is_active bool
```

### `product_options`
```sql
id uuid PK
product_id uuid FK
name text NOT NULL
name_en text
description text
description_en text
image text
sort_order int
is_active bool
```

### `package_options`
```sql
id uuid PK
product_id uuid FK
name text NOT NULL
name_en text
description text
description_en text
image text
sort_order int
is_active bool
```

### `weight_options`
```sql
id uuid PK
product_id uuid FK
label text NOT NULL  -- "1 gr", "5 gr", "1 kg"
label_en text
sort_order int
is_active bool
```

### `homepage_sections`
```sql
id uuid PK
section_key text UNIQUE  -- 'about', 'vision', 'contact'
title, title_en text
subtitle, subtitle_en text
content, content_en text
image text
button_text, button_text_en text
button_link text
sort_order int
is_active bool
```

### `site_settings`
```sql
id uuid PK
setting_key text UNIQUE
setting_value text
description text
```

### `requests` (talep formundan gelenler)
```sql
id uuid PK
product_id uuid FK
name text NOT NULL
email text NOT NULL
phone text
company text
country text
city text
quantity int
package_option_id uuid FK
weight_option_id uuid FK
product_option_id uuid FK
message text
website text                -- HONEYPOT (bot doldurur)
status text DEFAULT 'new'   -- 'new', 'in_progress', 'replied', 'archived'
metadata jsonb              -- IP/UA artık TRIGGER ile null'lanıyor
created_at timestamptz

-- Güvenlik:
TRIGGER sanitize_request_metadata: ip/UA'yı null'lar, status='new', honeypot doluysa hata
TRIGGER rate_limit: aynı email'den 3'ten fazla talep/dakika engelli
RLS: anonim INSERT (validation ile), admin SELECT/UPDATE
```

### `admins`
```sql
id uuid PK = auth.users.id
email text UNIQUE
created_at, updated_at
```

### `admin_audit_log`
```sql
id uuid PK
admin_id uuid FK → admins.id
action text          -- 'create', 'update', 'delete', 'login', vb.
table_name text
record_id text
record_summary text
metadata jsonb
created_at timestamptz
```

### `newsletter_subscribers`
```sql
id uuid PK
email text NOT NULL  -- UNIQUE on lower(email) where is_active=true
language text        -- 'tr' or 'en'
source text          -- 'footer', 'product_page', vb.
is_active bool DEFAULT true
unsubscribed_at timestamptz
created_at timestamptz

-- Güvenlik:
TRIGGER sanitize: lowercase email, force null IP/UA
TRIGGER rate_limit: 3/email/5dk
RLS: anyone INSERT (regex validation), admin SELECT/UPDATE/DELETE
GRANT: insert anon+authenticated, select+update+delete authenticated
```

### `page_views`
```sql
id uuid PK
page_path text NOT NULL  -- '/' veya '/product/karabuk-safrani'
page_title text
language text             -- 'tr' or 'en'
referrer text             -- SADECE DOMAIN (privacy)
device_type text          -- 'mobile', 'tablet', 'desktop'
-- IP YOK (KVKK)
created_at timestamptz

-- Güvenlik:
TRIGGER sanitize: max-length kontrolü, default values, force created_at=now()
RLS: anyone INSERT (validation), admin SELECT/DELETE
GRANT: insert anon+authenticated, select+delete authenticated
INDEX: created_at DESC, page_path, language
```

---

## 🔄 Veri Akışları

### A) Sayfa açılışı (index)
```
1. HTML yüklenir
2. Page loader gösterilir
3. <script module> çalışır:
   a. Supabase client init
   b. i18n init (URL ?lang= → localStorage → browser → 'tr')
   c. Şehir verileri çekilir (cities → SVG path'lerine eşlenir)
   d. Aktif ürünler çekilir (products + cities join)
   e. Map tooltip data hazırlanır
4. Page loader fade-out
5. Hero animasyonları başlar
6. Page view tracker (idle callback) → page_views.insert
```

### B) Ürün talebi (product.html form submit)
```
1. Kullanıcı formu doldurur
2. Honeypot ('website' alanı) boş mu? → değilse JS'de stop
3. Validate (zorunlu alanlar, email regex)
4. Supabase.from('requests').insert(...)
   → DB trigger:
     - sanitize_metadata (IP/UA null)
     - rate_limit check (3/dk/email)
     - validate honeypot (website=='' olmalı)
   → INSERT başarılı veya hata
5. Paralel: FormSubmit.co'ya da gönderilir (fallback mail)
6. Success modal göster
```

### C) Newsletter signup (footer)
```
1. Kullanıcı email yazar, submit
2. JS validate (regex)
3. Supabase.from('newsletter_subscribers').insert({email, language, source: 'footer'})
   → DB trigger:
     - sanitize: lowercase, force null IP/UA
     - rate_limit: 3/email/5dk
   → Conflict (zaten kayıtlı) durumunda 23505 → "Bu email zaten abone"
4. Success message
```

### D) Admin login
```
1. Brute force check (localStorage'da count) → 5+ ise lockout
2. Supabase.auth.signInWithPassword
3. Session token alınır
4. is_admin() RPC çağrılır → true ise dashboard, değilse logout
5. Idle timer başlar (15dk)
6. Audit log: action='login'
```

### E) Page view tracking
```
1. requestIdleCallback (sayfa yüklemeyi bloklamaz)
2. sessionStorage check (30dk dedup)
3. Device type detection (UA regex)
4. Referrer parse (sadece hostname)
5. Supabase.from('page_views').insert(...)
6. Hata = silently swallow
```

---

## 🌍 i18n Sistemi

### Mimari
```javascript
window.HA_I18N = {
  current: 'tr' | 'en',
  dict: { tr: {...}, en: {...} },
  apply: function() { ... }, // Tüm data-i18n elementlerini günceller
  toggle: function() { ... }
}
```

### Kullanım
```html
<h1 data-i18n="hero_title">Lezzetin Kökenine Yolculuk</h1>
<input placeholder="ara" data-i18n="search_placeholder" data-i18n-attr="placeholder">
```

### Dil Tespiti Sırası
1. URL query param: `?lang=en`
2. localStorage: `ha_lang`
3. Browser: `navigator.language` (`tr-TR` ise tr)
4. Default: `tr`

### Veritabanı Fallback
EN kolonu null veya boş ise TR gösterilir. Kasıtlı.

---

## 🔐 Güvenlik Katmanları

### Supabase Tarafı
1. **RLS herkes için aktif** — anon ve authenticated rolleri için ayrı politikalar
2. **Public INSERT** sadece şu tablolarda: `requests`, `newsletter_subscribers`, `page_views`
3. **SELECT/UPDATE/DELETE** çoğunlukla `is_admin()` fonksiyonuyla kısıtlı
4. **SECURITY DEFINER fonksiyonlar** `set search_path = public` ile sertleştirilmiş (privilege escalation önleme)
5. **Sanitize trigger'ları** her INSERT'te:
   - IP/UA null'lanır
   - Length kontrolü
   - Bot tespit (honeypot)
   - Rate limit
   - `created_at` client'tan kabul edilmez

### Frontend Tarafı
1. **Anon Key public** ama RLS koruması var
2. **escapeHtml** her dynamic HTML insert'inde
3. **Honeypot field** form'larda
4. **Admin panelde:**
   - Brute force protection
   - Idle timeout
   - Custom modal'lar (window.confirm yerine — XSS güvenliği)
5. **Storage bucket:** SVG yüklenmiyor (XSS riski)

### Network
- Tüm istekler HTTPS
- Supabase'e doğrudan, proxy yok
- Anahtarlar HTML'de görünür ama anon key zaten public olabilir

---

## 🎨 Frontend Mimarisi

### Custom Cursor
```javascript
.ha-cursor — body üstünde sabit, mix-blend-mode:difference
JS lerp (linear interpolation) ile mouse takibi
Sadece interaktif öğelerin üstündeyken büyür
Touch device'larda gizlidir
```

### Page Loader
```javascript
.page-loader — sayfa açılışı sırasında gold ring
DOMContentLoaded + 800ms delay → fade out
```

### Scroll Reveal
```javascript
.reveal sınıfı + IntersectionObserver
threshold: 0.15
.reveal.in-view → opacity 0→1, translateY 30→0
.delay-1, .delay-2, .delay-3 sınıflarıyla cascading
```

### Smooth Scroll
```javascript
Tüm a[href^="#"] linkleri JS ile preventDefault + scrollTo({ behavior: 'smooth' })
```

---

## 🔧 Genişletme Noktaları

### Yeni Ürün Ekleme
Admin panelden tamamen yapılabilir. Slug uyarısı:
- `karabuk-safrani` → değişmez (URL stability)
- Yeni ürün → admin manuel slug girer (kebab-case)
- Slug çakışması: DB UNIQUE constraint hatası verir

### Yeni Tablo Ekleme
1. SQL hazırla (RLS, trigger, grant)
2. Kullanıcıya ver, çalıştırsın
3. Frontend'e Supabase query ekle
4. Admin paneline CRUD UI ekle (TR/EN tabs gerekirse)

### Yeni Dil Ekleme
1. DB kolonları: `_de`, `_fr` gibi (mevcut pattern)
2. i18n dict'e dil ekle
3. Admin panele yeni tab eklemek için `langTabsHtml()` fonksiyonunu güncelle

### SMTP'ye Geçiş (Newsletter)
- Resend.com hesabı + DKIM/SPF kayıtları
- Supabase Edge Function: tüm aktif aboneleri çek + Resend API çağır
- Admin panelde "Bülten Yaz" UI

---

## 🧪 Test Stratejisi

Şu an **otomatik test yok**. Manuel test:
1. Form submit (gerçek email ile)
2. Newsletter signup (yeni email)
3. Admin login + her CRUD
4. TR/EN switch (her sayfada)
5. Mobile responsive (DevTools)
6. `prefers-reduced-motion` (animasyonlar duruyor mu?)
7. Slow network (Chrome DevTools throttle)

### Ileride Test Eklemek
- Playwright (e2e)
- Vitest + Testing Library (component test — ama component yok şu an)
- pgTAP (Supabase trigger testleri)
