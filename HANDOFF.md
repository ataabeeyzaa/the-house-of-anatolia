# HANDOFF — The House of Anatolia

> **Bu doküman, projenin Claude (chat) tarafında geliştirilmiş halini Claude Code'a devretmek için hazırlanmıştır. Tüm geçmiş kararlar, mevcut durum ve yapılması gerekenler buradadır.**

---

## 📋 Proje Özeti

**Marka:** The House of Anatolia
**Slogan (TR):** Lezzetin Kökenine Yolculuk
**Slogan (EN):** A Journey to the Roots of Taste
**Konsept:** Türkiye'nin coğrafi işaretli (GI) ürünlerini, üretildikleri topraktan doğrudan tüketiciye ulaştıran bir vitrin sitesi.
**Şu anki ürün:** Safranbolu Safranı (Karabük) — slug: `karabuk-safrani` (URL stabilitesi için değişmedi)
**Gelecek ürünler:** Kastamonu sarımsağı, Antep fıstığı, Trabzon hamsisi, Maraş dondurması, vb.
**Hedef kitle:** Türkiye + global, B2C + B2B
**Diller:** TR (varsayılan) + EN
**Estetik:** Sade-lüks (Aesop / Hermès / Le Labo havası)

---

## 🎨 Tasarım Kararları (DESIGN_SYSTEM.md'de detaylı)

- **Ana renk:** Altın `#d2a12f` + krem `#efe9dd` üzerinde koyu zemin `#0a0807`
- **Font (başlıklar):** Cormorant Garamond (italic varyantı vurgular için)
- **Font (gövde):** Inter
- **Aesthetic:** Geniş boşluklar, yumuşak animasyonlar, ince çizgiler (0.5-1px gold), büyük tipografi
- **Easing:** Her geçişte `cubic-bezier(0.16, 1, 0.3, 1)` (luxury markaların favorisi)

---

## 🗂️ Dosya Yapısı

```
/
├── index_supabase.html          ← Ana sayfa (i18n, hero, harita, hakkımızda, iletişim, footer)
├── product.html                  ← Ürün detay sayfası + talep formu
├── admin_yeni_urun_duzeltilmis_v2.html  ← Admin panel (TÜM CMS işleri)
├── gizlilik.html                 ← KVKK + Privacy Policy
├── kullanim.html                 ← Terms + Mesafeli Satış skeleton
├── cerez.html                    ← Cookie Policy
├── supabase_schema_v2_fixed.sql  ← İlk SQL şeması (referans)
└── assets/                       ← Logo, ürün görselleri
    ├── logo_house_of_anatolia_transparent.png
    ├── safran-cicegi.png
    ├── safran_iplik.png
    └── ...

DOKÜMANTASYON (bu dosyalar):
├── HANDOFF.md                    ← Bu dosya (ana belge)
├── ARCHITECTURE.md               ← Teknik mimari, DB şema, akışlar
├── DESIGN_SYSTEM.md              ← Renkler, fontlar, tasarım rehberi
└── KNOWN_ISSUES.md               ← Yapılmamış işler, sınırlamalar
```

---

## 🔌 Backend — Supabase

### URL ve Anahtar
```
URL: https://owcgcyvgibyawxfxwlbn.supabase.co
Anon Key: HTML dosyalarının içinde tanımlı (RLS ile korumalı)
```

### Tablolar (toplam 14)
- `cities` — Türkiye illeri (svg_id, name, name_en, plate_code, is_active, is_clickable)
- `products` — Ürünler (slug, name, name_en, hero_*, meta_*, vb. — 6 EN alanı)
- `product_parts` — Ürün bölümleri (iplik/çiçek/soğan, 3 EN alanı)
- `usage_steps` — Kullanım adımları (2 EN alanı)
- `gallery_images` — Galeri görselleri (caption, caption_en)
- `product_options` — Form ürün türü seçenekleri (name, name_en, description, description_en)
- `package_options` — Form paket seçenekleri (name, name_en, description, description_en)
- `weight_options` — Form gramaj seçenekleri (label, label_en)
- `homepage_sections` — Anasayfa bölümleri (4 EN alanı)
- `site_settings` — Genel ayarlar
- `requests` — Talep formundan gelen müşteri istekleri (honeypot + rate limit + sanitize trigger)
- `admins` — Admin kullanıcıları
- `admin_audit_log` — Admin işlemleri kaydı
- `newsletter_subscribers` — Bülten aboneleri (rate limit, RLS, sanitize)
- `page_views` — KVKK uyumlu anonim ziyaret kayıtları (IP saklanmaz)

### Storage
- Bucket: `product-assets`
- 5MB limit, MIME whitelist (SVG hariç — XSS riski)

### Güvenlik
- Tüm tablolarda **Row Level Security (RLS)** aktif
- `requests` tablosunda **honeypot kolonu** + sanitize trigger + rate limit (3/dk/email)
- `newsletter_subscribers`: rate limit 3/email/5dk + lowercase normalize
- `page_views`: anyone INSERT (validation ile), admin SELECT/DELETE
- Admin panelde **brute force koruma** (5 deneme / 15dk lockout)
- Admin panelde **idle timeout** (15dk + 60s warning)
- Tüm SECURITY DEFINER fonksiyonları `set search_path = public` ile sertleştirilmiş

---

## ✅ Mevcut Durum — Yapılanlar

### Sayfalar
- ✅ `index_supabase.html` — TR/EN i18n switcher, harita, hakkımızda hikayesi (5 paragraf + drop cap), GI tanımı, iletişim, footer (newsletter formu dahil)
- ✅ `product.html` — Ürün detay, talep formu (Supabase'e kayıt + FormSubmit fallback), galeri, custom gramaj seçimi
- ✅ `admin_*.html` — Tam CMS panel
- ✅ Yasal sayfalar (3 dosya) — placeholderlar [ŞİRKET ADI], [VERGİ NO] vs.

### Admin Panel Özellikleri
- ✅ Login + brute force koruma + idle timeout
- ✅ Şehir CRUD
- ✅ Ürün CRUD (ana ürün)
- ✅ Ürün alt-içerikleri: parts, usage_steps, gallery, options, packages, weights
- ✅ Anasayfa bölümleri yönetimi
- ✅ Site ayarları
- ✅ Talep listesi + detay görünümü
- ✅ Bülten aboneleri (toggle aktif/pasif, sil, e-posta arama, **CSV indirme**)
- ✅ Ziyaret istatistikleri (4 stat kartı + 30 günlük çubuk grafik + top sayfalar + dil/cihaz/referrer breakdown)
- ✅ **TR/EN tab sistemi** — 8 editör formunda EN inputları (city, product, parts, usage, gallery, option, package, weight, homepage_section)
- ✅ Audit log her işlemde

### Frontend Özellikleri
- ✅ TR/EN i18n sistemi (`window.HA_I18N`, localStorage, browser lang detect, `?lang=` URL param)
- ✅ Page loader (gold ring)
- ✅ Custom cursor (sadece interaktif öğelerde, mix-blend-mode:difference)
- ✅ Scroll reveal IntersectionObserver
- ✅ Smooth scroll
- ✅ `prefers-reduced-motion` saygısı
- ✅ Newsletter form Supabase entegrasyonu
- ✅ Page view tracker (KVKK uyumlu, 30dk dedup, requestIdleCallback)

### SQL'ler — Çalıştırıldı (Supabase'de aktif)
- ✅ Storage bucket güvenlik sertleştirmesi
- ✅ `requests` honeypot + sanitize + rate limit
- ✅ 22 EN kolonu eklendi (9 tabloda)
- ✅ `newsletter_subscribers` tablosu + permissions
- ✅ `page_views` tablosu + permissions

### SQL'ler — Çalıştırılmadı (BEKLİYOR)
- ❌ **Ürün adı güncellemesi** — `Karabük Safranı` → `Safranbolu Safranı`
  ```sql
  update public.products set
    name = 'Safranbolu Safranı',
    hero_title = 'Safranbolu Safranı',
    hero_badge = 'Safranbolu • Coğrafi İşaretli Ürün',
    meta_description = 'Safranbolu safranı için coğrafi işaretli ürün tanıtım ve teklif sayfası.'
  where slug = 'karabuk-safrani';
  ```
- ❌ **EN ürün bilgileri** — Admin panelden EN inputları doldurmak

---

## ❌ Yapılmadıklar / Sıradaki İşler (öncelik sırasıyla)

### 1. 🎨 Tasarım Yenileme (en kritik — kullanıcı buna takılı)
Kullanıcı sitenin "ucuz durduğunu" söylüyor. Yüklediği `safran_hero_premium.html` referansı bu projeyle aynı klasörde değil ama **tarz açıklaması** aşağıda. Kullanıcı **fotoğraf eklemeden** premium görünüm istiyor — generative luxury yaklaşımı.

**Premium hero denemesi yapıldı, kullanıcı "çok yoğun" buldu, geri alındı.** Bir sonraki deneme **daha sade** olmalı:
- Daha az partikül (10-15)
- Marquee'yi kaldır veya çok küçült
- Big text "ANADOLU" çok soluk olmalı (.03 opacity)
- Sloganı **2 satır** yap, 3 değil
- Stats bar opsiyonel (kullanıcı emin değil)

**Asıl bölümler hâlâ yenilenmedi:**
- Hakkımızda — Aesop tarzı asymmetric grid
- Coğrafi İşaret — Sertifika rozeti tarzı (CSS hazır, HTML eklenmedi)
- İletişim — Premium form
- Footer — Daha rafine

### 2. 🌐 Domain ve Hosting
- Domain henüz alınmadı (`thehouseofanatolia.com` müsait, Cloudflare'dan alınacak — kullanıcının kararı)
- Hosting: Netlify önerildi (drag-drop, ücretsiz, otomatik HTTPS)
- Domain alındığında: `thehouseofanatolia.com` placeholderlarını gerçek domain'e çevir (yasal sayfalarda)

### 3. 📧 Newsletter Gönderim Sistemi
Şu an aboneler **toplanıyor** ama gönderim yok. Karar: **CSV → Brevo/Mailchimp** (manuel). 50+ aboneye ulaşınca:
- Resend ($20/ay) + Supabase Edge Function ile site içine entegre
- Admin panelde "Bülten Yaz" sayfası

### 4. 🛒 E-ticaret Altyapısı (uzak gelecek)
Şu an site "talep formlu vitrin" — direkt satış yok. Şirket kurulduğunda:
- iyzico / PayTR sanal POS entegrasyonu
- Sepet + checkout sayfası
- Sipariş yönetimi (admin panelde)
- KEP, e-fatura, e-arşiv mükellefiyeti
- Mesafeli Satış Sözleşmesi tamamlanması

### 5. 🔍 SEO İyileştirmeleri
- ✅ Mevcut: meta description, OG, Twitter Card, hreflang
- ❌ Eksik: schema.org Product/Organization JSON-LD, sitemap.xml, robots.txt, Google Search Console verification

---

## 🚨 Önemli Bilgiler / Tuzaklar

### 1. Slug Korunması
`karabuk-safrani` slug'ı **DEĞIŞTIRILMEMELİ**. Ürün adı "Safranbolu Safranı" olsa da slug aynı kalır (URL'lerin bozulmaması için). Bu kasıtlı bir karar.

### 2. Email Adresi
Sitedeki tüm e-postalar `info@thehouseofanatolia.com`. Domain alındıktan sonra bu adres gerçekten kurulmalı (yoksa form mailleri gitmez).

### 3. FormSubmit + Supabase Çift Hattı
`product.html` formu **hem** Supabase'e kayıt yapıyor **hem de** FormSubmit.co'ya mail atıyor. İkincisi emergency yedek. Kullanıcı domain alınca SMTP'ye geçiş yapabilir.

### 4. Honeypot
Form'da `name="website"` gizli alan var. Bot doldurur, gerçek kullanıcı dolduramaz. DB trigger bu alan doluysa kaydı reddeder.

### 5. Custom Gramaj
Form'da gramaj seçenekleri var ama "Diğer" seçilince number input açılır (1-100000 gr). Mesaja `[Özel gramaj talebi: X gram]` olarak yazılır.

### 6. Admin Login Güvenliği
- 5 yanlış deneme = 15dk lockout
- 15dk inaktivite = 60s warning + logout
- Tüm action'lar audit log'a yazılır
- City silme: kelime yazma onayı ister

### 7. KVKK Uyumu
- IP **hiçbir yerde** saklanmıyor (page_views, requests, newsletter_subscribers — hepsi sanitize trigger ile null'lanıyor)
- Sanitize trigger `created_at`'ı bile client'tan kabul etmiyor (`new.created_at = now()`)
- Tüm form'larda gizlilik politikası linki var

### 8. i18n Fallback
EN kolonu boşsa frontend otomatik TR'ye düşer. Bu **kasıtlı** — admin panel her ürünün EN halini doldurmaya zorlamasın diye.

### 9. Loglama
Console'a hiçbir uyarı/hata yazılmıyor (production'a hazır). Hata olursa silently swallow ediliyor (özellikle page_views tracker).

### 10. Page View Dedup
30 dk içinde aynı tarayıcı/sekme tekrar açılırsa sayılmaz (sessionStorage ile). 31. dakikada tekrar sayılır.

---

## 🔑 Kullanıcı Bilgileri ve Tercihler

### İletişim Tarzı
- Türkçe, samimi ("kanka")
- Hızlı sonuç ister, derin teknik detaya girmez
- "Test ettim" der ama bazen test etmez (bu yüzden major değişikliklerde **kullanıcının test etmesi için açık zaman bırak**)
- Görsel olmadığı için "tasarım ucuz" hissini yaşıyor (haklı)
- Domain ve şirket konuları hakkında **belirsizlik** yaşıyor

### Karar Verilmiş Kararlar (değiştirme!)
- ✅ Site **alacak kişi için** yapılıyor (kullanıcının kendi sitesi değil)
- ✅ E-ticaret **niyeti var** ama **şirket kurulmadan satış olmaz** (vergi suçu)
- ✅ Şu an "talep formlu vitrin" modeli
- ✅ Newsletter: CSV → Brevo (yıllarca yetecek)
- ✅ Analytics: Self-built Supabase (Plausible/GA4 değil — KVKK için temiz)
- ✅ Bilingual: TR + EN
- ✅ Custom cursor: KORUNACAK
- ✅ Cinematic hero denemesi: REDDETTI (büyük dağ silüeti, parçacıklar yoğun gelmiş)

### Beğendiği Tarz
- Aesop, Hermès, Le Labo, Mariage Frères
- Kullanıcının yüklediği `safran_hero_premium.html` (extracts: gold particles, marquee, big faded text, EST 2024 badge, divider lines, italic gold accents)
- Aşağıdaki gibi unsurlar **çekici geliyor**:
  - Italic altın vurgular (`<em>` style)
  - Çok ince altın çizgiler (1px gold)
  - Büyük serif başlıklar (Cormorant)
  - Boşluk hakimiyeti
  - Marquee yatay kayan yazı (HASAT 2024 ✦ COĞRAFI İŞARETLİ ✦)
  - Sertifika tarzı rozet/numaralandırma

### Beğenmediği
- Çok fazla animasyon
- Yoğun parçacık efektleri
- Dağ SVG'si gibi büyük arka plan elemanları
- 3 satır slogan (2 satır iyi)

---

## 📞 Domain ve Şirket Durumu

- ❌ Domain alınmadı (`thehouseofanatolia.com` müsait, kullanıcı erteledi)
- ❌ Şirket kurulmadı
- ❌ Sanal POS yok
- ❌ Gıda işletme kayıt belgesi yok (yurt içi gıda satışı için zorunlu)
- ✅ Site canlıya **kişi adına** çıkabilir (talep formu modunda)

**Site canlıya alınmadan önce:**
1. Yasal sayfalardaki `[ŞİRKET ADI]`, `[VERGİ NO]`, `[MERSİS NO]`, `[ADRES]`, `[TELEFON]` placeholderları doldurulmalı
2. Domain alınmalı
3. Hosting'e yüklenmeli

---

## 🛠️ Geliştirme Akışı (Claude Code için)

### Lokal Test
1. Dosyaları bir klasöre koy
2. `python3 -m http.server 8000` veya `npx serve .` ile localhost'ta aç
3. Tarayıcıda `http://localhost:8000/index_supabase.html`

### Dosya Düzenleme Sırası (önerilen)
1. **Önce backup al** — her büyük değişiklikten önce dosyayı yedekle
2. **Syntax check** — JS değişiklikleri sonrası `node -e "new Function(...)"` ile sadece JS bloklarını kontrol et
3. **Manuel test** — tarayıcıda aç, console'da hata var mı bak
4. **i18n kontrolü** — Yeni metin eklediysen hem TR hem EN için anahtar koy

### Supabase Bağlantısı
Hiçbir dosyada API key'i değiştirme. Anon key zaten içeride. Service role key **asla** kullanma.

### SQL Çalıştırma
Yeni tablo / kolon / policy gerekirse:
1. SQL'i hazırla (security definer + search_path = public)
2. Kullanıcıya ver, SQL Editor'da çalıştırsın
3. Doğrulama sorgusu ekle (`select count(*) ...`)

---

## 🎯 Claude Code'a İlk Görev Önerileri

Kullanıcı sana ne demek isterse onu yap, ama **eğer karar veremezse**:

### Öncelik 1: Tasarımı Sakin Premium Yap
Mevcut hero **boş ve sade**. Şu eklemeleri yap (yumuşak, abartmadan):
- 8-10 partikül (35 değil)
- Çok soluk (.03) "ANADOLU" arka yazı
- Marquee'yi sadece **alta** ve **küçük** yaz
- Stats bar **ekleme** (kullanıcı emin değil)
- Italic altın vurgular ekle (slogan'da "Kökenine" italic gold)
- Hero altına **küçük bir badge** koy: "EST 2024 — ANATOLIA"

### Öncelik 2: Hakkımızda Bölümünü Yenile
Şu an düz metin. Aesop tarzı **asymmetric grid** yap:
- Sol 60% — büyük italic başlık + 5 paragraf
- Sağ 40% — sticky info card (kuruluş yılı, üretici sayısı, vb.)
- Drop cap ilk paragrafa korunsun

### Öncelik 3: Coğrafi İşaret Bölümü
Yeni bir bölüm ekle (harita ile hakkımızda arası). **Sertifika tarzı rozet:**
- Sol: "Coğrafi İşaret Nedir?" başlık + tanım
- Sağ: Çerçeveli rozet — "TESCİL NO: 234" + "Safranbolu Safranı" + "Türk Patent ve Marka Kurumu" + tarih

### Öncelik 4: Footer Yenile
Mevcut footer 3 sütun. Şuna evrilt:
- Üst: Newsletter signup (tek satır, geniş)
- Orta: 4 sütun (Brand, Sayfalar, Yasal, İletişim)
- Alt: Copyright + sosyal medya ikonları (Instagram, vb.)

---

## ❓ Belirsizlikler

Bunları kullanıcıya sor:
1. **EST 2024** mü kalsın yoksa marka **ne zaman** kuruldu? Bu yıl mı?
2. Stats bar (200+ üretici, 81 il, 1200+ ürün) **doğru rakamlar mı** yoksa abartı mı?
3. Newsletter altyapısı **şimdi mi** yoksa 50+ abone olunca mı?
4. Domain ne zaman alınacak? (Hosting hazırlığını bilmek için)

---

## 📝 Son Not

Bu projede **kullanıcı tasarımcı değil**. Net direktifler vermek yerine "şuna benzer" deyip referans atıyor. **Sen bir öneriyle başla, mock-up yap, kullanıcıdan onay al, sonra implemente et.** Direkt büyük değişiklik yapma — küçük adımlarla ilerle.

**İyi şanslar! 🌿**
