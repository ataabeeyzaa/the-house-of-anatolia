# KNOWN ISSUES & TODO — The House of Anatolia

> **2026-05-08 güncel** — site canlıda, GitHub Actions auto-deploy aktif. Aşağıdakiler kalan işler.

---

## 🔴 P0 — Yayın için kritik (kullanıcı yapacak)

### 1. Eski Netlify Token Revoke
- https://app.netlify.com/user/applications#personal-access-tokens
- **Authorized applications** altındaki **"Netlify CLI"** → Options → Revoke access
- Yeni "Production CI/CD" token zaten GitHub Secrets'ta aktif

### 2. Yasal Sayfa Placeholder'ları (12 yer)
- `gizlilik.html`: 5 placeholder
- `kullanim.html`: 7 placeholder
- Doldurulacak: `[ŞİRKET ADI]`, `[VERGİ NO]`, `[MERSİS NO]`, `[ADRES]`, `[TELEFON]`, `[E-POSTA]`
- ⚠️ **KVKK uyumu için şirket kurulmadan tamamlanamaz** — şirket kuruluş resmi bilgileri lazım
- Avukat / KVKK danışmanı önerilir (~3000-8000 TL)

### 3. Telefon Numarası
- `index.html` (footer iletişim sütunu) + `product.html` (talep formu intro) + `index.html` (contact section)
- Şu an placeholder: `+90 (5XX) XXX XX XX`
- Gerçek numara gelince find/replace ile güncellenir

### 4. Domain Alma
- `thehouseofanatolia.com` (Cloudflare Registrar ~$10/yıl, en ucuz)
- DNS Netlify'a yönlendirilir: Netlify Dashboard → Domain management → Add custom domain
- HTTPS otomatik (Let's Encrypt)

### 5. Email Routing
- Cloudflare Email Routing (ücretsiz forwarding)
- `info@thehouseofanatolia.com` → Beyza/ortak Gmail'ine forward
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

## 🟡 P1 — Önemli ama acil değil

### EN İçerikleri
- Tüm tablolarda `name_en`, `description_en` vb. kolonlar boş
- Admin panelden TR/EN tab'ları kullanarak doldurulmalı
- Şu an EN kullanıcı boş alanlar için TR fallback görür (kasıtlı)

### SEO Optimizasyonları
- ❌ `robots.txt`
- ❌ `sitemap.xml`
- ❌ Schema.org JSON-LD (Product, Organization, FAQ)
- ❌ Google Search Console verification
- ❌ Bing Webmaster Tools
- ✅ Meta description, OG, Twitter Card, hreflang, canonical (mevcut)

### Newsletter Gönderim
- Şu an: aboneler `newsletter_subscribers`'a kaydediliyor, gönderim yok
- Plan A (50+ abone): CSV indir → Brevo veya Mailchimp ücretsiz hesap
- Plan B (sonra): Resend ($20/ay) + Supabase Edge Function + admin panelde "Bülten Yaz" UI

### Performance
- Mevcut: index.html ~200KB, product.html ~80KB, admin.html ~168KB
- Görsel yok (statik HTML)
- Yapılabilir: HTML/CSS/JS minify (Netlify otomatik), font subsetting (Cormorant Garamond büyük)

### A11y (Accessibility)
- Alt text'ler ✓
- Aria labels ✓ (lang switcher, map tooltip)
- Semantic HTML ✓
- Keyboard navigation ✓
- prefers-reduced-motion ✓
- Eksik: screen reader testleri, skip-to-main link, color contrast WCAG AA tam doğrulama

---

## 🟢 P2 — Cleanup (opsiyonel)

### Dead Code (CSS)
Kaldırılmış HTML elementlerinin CSS'i hâlâ duruyor:
- `.hero-grid`, `.hero-lines`, `.hero-dots`, `.hero-mountains` (eski cinematic hero)
- `.gold-accent`, `.about-grid`, `.about-aside`, `.about-card-info`, `.about-meta` (KÜNYE kart)
- `.cert-badge`, `.cert-eyebrow`, `.cert-title`, `.cert-meta` (sertifika rozeti)
- `.hero-stats`, `.hero-stat`, `.est-badge` (stats bar + EST badge)

### Dead Code (JS)
- `admin.html`'de paket CRUD fonksiyonları (~228 satır):
  - `loadPackageOptions()`
  - `renderPackageEditor()`
  - `savePackageEdit()`
- UI çağrısı yok, kullanıcıya görünmüyor, ama dosya boyutunda yer kaplıyor

### Dead i18n Keys
- `hero_est`, `hero_stat1-3`, `gi_eyebrow`, `gi_title`, `gi_paragraph1-2`
- `cert_*`, `about_meta_*`
- `nav_gi` (footer #gi link kaldırıldı)

### Dead DB Tablo
- `package_options` tablosu — UI hiç kullanmıyor, eski talep kayıtlarındaki FK için duruyor

### Diğer
- `supabase_schema_v2_fixed.sql` — referans dosya, repo'da gereksiz olabilir (ileride sil)

---

## ⚠️ Sınırlamalar

### Frontend
1. **Build step yok** — kasıtlı, basit deploy. Karmaşık component'leri zorlaştırır.
2. **Admin panel TEK SAYFA** — 4800 satır. Yönetimi zor. SPA refactor'a değer.
3. **Lightbox vanilla JS** — bazı edge case'lerde takılabilir
4. **i18n manuel** — her yeni metin için `data-i18n` ekle + dict'e gir

### Backend (Supabase)
1. **Free tier** — 500 MB DB, 1 GB storage, 50K MAU, yeterli
2. **Realtime aktif değil** — gerek yok
3. **Edge Functions yok** — newsletter SMTP veya web hooks için lazım olacak
4. **Backup manuel** — auto-backup 7 gün retention

### Hosting (Netlify)
1. **Free tier** — 100GB bandwidth/ay, 300 build dakika/ay, yeterli
2. **GitHub Actions deploy** — Netlify'ın native Git integration yerine custom workflow
3. **Custom domain** — alındığında 5 dk'lık config, HTTPS otomatik

### Dış Bağımlılıklar
1. **FormSubmit.co** — ücretsiz, üst limit 50/ay, unreliable olabilir
2. **esm.sh CDN** — Supabase JS client buradan geliyor
3. **Google Fonts** — DSGVO/KVKK gri alan, ileride self-host yapılabilir

---

## 🐛 Bilinen Bug'lar

### Frontend
1. **Custom cursor mobil-touch** — bazen touch device'da kısa süreliğine gözükebilir (touchstart sonrası gizleniyor zaten)
2. **TR/EN switch + scroll position** — kasıtlı, sayfa başına dönmüyor
3. **Page loader long network** — 3G'de 5+ saniye gözükür
4. **Mobile slogan overflow -4px** — `transform:translateX(-50%)` reset sonrası 99→4px düştü, görsel olarak fark edilmez

### Backend
1. **Rate limit tuning** — Newsletter 3/email/5dk biraz cömert
2. **Audit log boyutu** — şu an temiz, 6 ay sonra cleanup gerekebilir

### Admin Panel
1. **Drag-and-drop sort_order yok** — manuel sıralama
2. **Toplu işlem yok** (bulk delete, vb.)
3. **Image preview lightbox yok**

---

## 📋 Test Edilmemiş Senaryolar

1. iOS Safari (custom cursor)
2. Eski Android Chrome (<80) (i18n)
3. Slow 3G (loader)
4. JavaScript kapalı (büyük ölçüde çalışmaz)
5. Çoklu sekmeden simultaneous form submit (rate limit)
6. Çok büyük image upload (5 MB sınır)
7. Browser back button (SPA değil, sorun yok)
8. Print stylesheet (`@media print` yok)

---

## 🔄 Çözülen / Kapalı (referans)

- ✅ Site lokalden GitHub'a pushlandı
- ✅ Netlify deploy + auto-CI/CD
- ✅ Mobile slogan overflow (-99 → -4px)
- ✅ Footer height mobile (1012 → 800px → 580 desktop)
- ✅ Tipografi (Inter → Plus Jakarta Sans)
- ✅ Cinematic hero kaldırıldı (product.html)
- ✅ Asset klasörü repo'ya eklendi
- ✅ Rename: index_supabase → index, admin..._v2 → admin
- ✅ Duplicate dosyalar silindi
- ✅ Token rotation (Netlify Production CI/CD yeni, eski revoke pending)
- ✅ Sparkle effect ("uçan sim")
- ✅ Footer 4-sütun yenilendi + brand logo
- ✅ Contact section redesign (3-col → minimal list)
- ✅ KEŞFET sadeleştirme (gi-definition kaldırıldı)
- ✅ Paket Seçimi tamamen kaldırıldı
- ✅ EST badge / KÜNYE / sertifika rozeti / stats bar kaldırıldı (kullanıcı reddetti)
- ✅ Atmospheric layer (SVG noise overlay)
- ✅ Custom scrollbar + hover refinements
- ✅ Plus Jakarta Sans font features (ligatures, kerning, smoothing)
- ✅ 18 plugin yüklü + Supabase MCP
