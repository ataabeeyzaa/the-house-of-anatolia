# KNOWN ISSUES & TODO — The House of Anatolia

> **2026-05-08 güncel** — site canlıda, GitHub Actions auto-deploy aktif. 4 PR mergede tamam (#1, #2, #3, #4).

---

## P0 — Yayın için kritik (kullanıcı yapacak)

### 1. Eski Netlify Token Revoke
- https://app.netlify.com/user/applications#personal-access-tokens
- Authorized applications → "Netlify CLI" → Revoke access
- Yeni "Production CI/CD" token zaten GitHub Secrets'ta aktif

### 2. Yasal Sayfa Placeholder'ları (12 yer)
- `gizlilik.html`: 5 placeholder
- `kullanim.html`: 7 placeholder
- Doldurulacak: `[ŞİRKET ADI]`, `[VERGİ NO]`, `[MERSİS NO]`, `[ADRES]`, `[TELEFON]`, `[E-POSTA]`
- ⚠️ **KVKK uyumu için şirket kurulmadan tamamlanamaz** — şirket kuruluş resmi bilgileri lazım
- Avukat / KVKK danışmanı önerilir (~3000-8000 TL)

### 3. Telefon Numarası (placeholder hala canlıda)
- `index.html` (footer + contact section) + `product.html` (talep formu intro)
- Şu an: `+90 (5XX) XXX XX XX`
- Gerçek numara gelince find/replace ile güncellenir

### 4. Domain Alma
- `thehouseofanatolia.com` (Cloudflare Registrar ~$10/yıl)
- DNS Netlify'a yönlendirilir → HTTPS otomatik (Let's Encrypt)
- Alındığında ben şu yerleri güncellerim: `robots.txt`, `sitemap.xml`, `index.html` ve `product.html` JSON-LD canonical (~10 yer find/replace)

### 5. Email Routing
- Cloudflare Email Routing (ücretsiz forwarding)
- `info@thehouseofanatolia.com` → Beyza/ortak Gmail
- Veya Google Workspace ($6/ay/kullanıcı, gerçek mailbox)

### 6. Admin User Oluştur (Supabase)
- Authentication → Users → Add user (Auto Confirm İŞARETLİ)
- SQL Editor'da:
  ```sql
  insert into public.admins (user_id, email, full_name)
  select u.id, u.email, 'Tam İsim'
  from auth.users u
  where u.email = 'admin@example.com'
    and not exists (select 1 from public.admins a where a.user_id = u.id);
  ```
- ⚠️ `full_name` kolonu NOT NULL — atlama!

---

## P1 — Önemli ama acil değil

### EN İçerikleri
- Tüm tablolarda `name_en`, `description_en` vb. kolonlar boş
- Admin panelden TR/EN tab'ları kullanarak doldurulmalı
- Şu an EN kullanıcı boş alanlar için TR fallback görür (kasıtlı)

### Marquee Admin Entegrasyonu (yeni)
Şu an `marquee_1-5` i18n dict'te statik (5 yakında ürün hard-coded).
İstersen ekleme:
1. Supabase'de `marquee_items` tablosu yarat (`label_tr, label_en, sort_order, is_active`)
2. Default 5 row insert (mevcut yakındalar)
3. RLS policy: anon read, admin CRUD
4. Frontend: `loadMarqueeItems()` fetch + render (i18n dict yerine)
5. Admin'de yeni "Şerit" sekmesi + CRUD UI (loadMarqueeItems + render + save + delete)

### Newsletter Gönderim
- Şu an: aboneler `newsletter_subscribers`'a kaydediliyor, gönderim yok
- Plan A (50+ abone): CSV indir → Brevo/Mailchimp ücretsiz hesap
- Plan B: Resend ($20/ay) + Supabase Edge Function + admin "Bülten Yaz" UI

### Performance
- Mevcut: index.html ~200KB, product.html ~80KB, admin.html ~165KB, products.html ~12KB
- Görsel yok (statik HTML)
- Yapılabilir: HTML/CSS/JS minify (Netlify otomatik), font subsetting (Cormorant büyük)

### Domain Alındığında URL Güncellemeleri
- robots.txt: Sitemap URL
- sitemap.xml: tüm `<loc>` ve `hreflang` URL'leri
- index.html JSON-LD: Organization + WebSite URL
- product.html JSON-LD: Product + BreadcrumbList URL + canonical
- products.html JSON-LD: CollectionPage URL + canonical

---

## P2 — Cleanup (opsiyonel)

### Dead Code (CSS)
- `.future-pill`, `.future-list` rules — HTML'den silindi (PR #4) ama CSS rules kaldı
- `.gold-accent` (slogan'da JS dinamik kullanım var, koru)
- Eski cert / about-grid asymmetric / hero-grid/lines/dots/mountains rules silindi (PR #1)

### Dead i18n Keys
- ✅ `pill_1-4`, `hero_est`, `hero_stat1-3`, `gi_eyebrow/title/paragraph1-2`, `cert_*`, `about_meta_*`, `nav_gi` (PR #1 ve #4'te silindi)

### Dead DB Tablo
- `package_options` tablosu — UI hiç kullanmıyor, eski talep kayıtlarındaki FK için duruyor
- Drop yapılırsa eski request'lerdeki package_option_id NULL olmalı

### Diğer
- `supabase_schema_v2_fixed.sql` — referans dosya, repo'da kalabilir (yeniden migration için faydalı)

---

## Sınırlamalar

### Frontend
1. **Build step yok** — kasıtlı, basit deploy. Karmaşık component reuse zor.
2. **Admin panel TEK SAYFA** — 4500 satır. Yönetimi zor. SPA refactor değer.
3. **i18n manuel** — her yeni metin için `data-i18n` ekle + dict'e gir
4. **Marquee items statik** — admin entegrasyonu eklenmeli (P1)

### Backend (Supabase)
1. **Free tier** — 500 MB DB, 1 GB storage, 50K MAU, yeterli
2. **Realtime kapalı** — gerek yok
3. **Edge Functions yok** — newsletter SMTP veya web hooks için lazım olacak
4. **Backup manuel** — auto-backup 7 gün retention

### Hosting (Netlify)
1. **Free tier** — 100GB bandwidth/ay, 300 build dakika/ay, yeterli
2. **GitHub Actions deploy** — Netlify'ın native Git integration yerine custom workflow
3. **Custom domain** — alındığında 5 dk'lık config

### Dış Bağımlılıklar
1. **FormSubmit.co** — ücretsiz, üst limit 50/ay, unreliable olabilir
2. **esm.sh CDN** — Supabase JS client buradan
3. **Google Fonts** — DSGVO/KVKK gri alan, ileride self-host yapılabilir

---

## Bilinen Bug'lar

### Frontend
1. **Custom cursor mobil-touch** — bazen touch device'da kısa süreliğine gözükebilir
2. **TR/EN switch + scroll position** — kasıtlı, sayfa başına dönmüyor
3. **Page loader long network** — 3G'de 5+ saniye gözükür

### Backend
1. **Rate limit tuning** — Newsletter 3/email/5dk biraz cömert
2. **Audit log boyutu** — şu an temiz, 6 ay sonra cleanup gerekebilir

### Admin Panel
1. **Drag-and-drop sort_order yok** — manuel sıralama
2. **Toplu işlem yok** (bulk delete vb.)
3. **Image preview lightbox yok**

---

## Test Edilmemiş Senaryolar

1. iOS Safari (custom cursor + sparkle render)
2. Eski Android Chrome (<80) (i18n)
3. Slow 3G (loader)
4. JavaScript kapalı
5. Çoklu sekmeden simultaneous form submit (rate limit)
6. Çok büyük image upload (5 MB sınır)
7. Print stylesheet (`@media print` yok)
8. Marquee + sparkle birlikte performance

---

## Çözülen / Kapalı (referans)

### PR #1 — SEO + Cleanup + A11y
- ✅ robots.txt + sitemap.xml + JSON-LD (Organization + WebSite + Product + BreadcrumbList)
- ✅ product.html title fix
- ✅ Dead code: paket CRUD JS + dead CSS + 24 dead i18n key
- ✅ Skip-to-main link + `<main id="main-content">` (WCAG 2.4.1)
- ✅ Lighthouse: A11y 98 / SEO 92 / Best Practices 96 / Agentic 100

### PR #2 — Sparkle iter 1 + contact + footer
- ✅ Sparkle yan-drift → minik statik dots map arkasında
- ✅ Contact card border + radius + bg gradient
- ✅ Footer grid balanced + h4 sektör-tarzı

### PR #3 — Sparkle removal + Products sayfası
- ✅ Sparkle TAMAMEN kaldırıldı
- ✅ Yeni products.html (Supabase fetch + i18n + JSON-LD)
- ✅ Navbar + footer linkleri
- ✅ sitemap.xml products URL

### PR #4 — Sparkle re-add + Map section + Contact
- ✅ Sparkle GERİ — haritanın ARKASINA (z-index:0), DİKEY yukarı (rotate yok)
- ✅ Future-pill kaldırıldı
- ✅ Eyebrow çift çizgi (KEŞFET iki yanda altın çizgi)
- ✅ city_note kısa GI tanımı
- ✅ Marquee strip (5 yakında ürün, kayan şerit)
- ✅ Contact horizontal 2-col
- ✅ Section padding 110 → 80px
- ✅ products.html is_active=true filter + intro paragraf kaldırıldı

### Önceki sohbet (Phase 0)
- ✅ Site lokalden GitHub'a + Netlify auto-CI/CD
- ✅ Mobile slogan overflow düzeltme
- ✅ Tipografi (Inter → Plus Jakarta Sans)
- ✅ Cinematic hero kaldırıldı (product.html)
- ✅ Asset klasörü repo'ya
- ✅ Token rotation
- ✅ Footer 4-sütun + brand logo
- ✅ EST badge / KÜNYE / sertifika rozeti / stats bar (kullanıcı reddetti)
- ✅ Atmospheric layer (SVG noise overlay)
- ✅ Custom scrollbar + hover refinements
- ✅ Plus Jakarta font features (ligatures, kerning, smoothing)
- ✅ 18 plugin + Supabase MCP + chrome-devtools-mcp
