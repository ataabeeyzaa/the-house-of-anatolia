# KNOWN ISSUES & TODO — The House of Anatolia

> **Yapılmamış işler, mevcut sınırlamalar, dikkat edilmesi gerekenler.**

---

## 🚨 Yapılmadıklar (Öncelik Sırasıyla)

### 🔴 P0 — Kritik (yayın öncesi mutlaka)

#### 1. Tasarım Yenileme — Hâlâ "Ucuz Duruyor"
**Durum:** Kullanıcı sitenin tasarımını "ucuz" buldu. Premium hero denemesi yapıldı, "çok yoğun" diyerek geri aldı.

**Yapılacak:**
- Daha sade premium hero (10 partikül, no marquee, no big text gibi seçenekleri test)
- Hakkımızda bölümü Aesop tarzı asymmetric grid
- Coğrafi İşaret bölümü (sertifika rozeti tarzı — CSS hazır, HTML eklenmedi)
- Footer yenileme

**Öneriler için DESIGN_SYSTEM.md'ye bak.**

#### 2. Ürün Adı SQL'i Çalıştırılmadı
**Durum:** "Karabük Safranı" hâlâ DB'de. "Safranbolu Safranı" olmalı.

**Çalıştırılacak SQL:**
```sql
UPDATE public.products SET
  name = 'Safranbolu Safranı',
  hero_title = 'Safranbolu Safranı',
  hero_badge = 'Safranbolu • Coğrafi İşaretli Ürün',
  meta_description = 'Safranbolu safranı için coğrafi işaretli ürün tanıtım ve teklif sayfası.'
WHERE slug = 'karabuk-safrani';
```

**ÖNEMLI:** Slug `karabuk-safrani` kalır (URL stability).

#### 3. EN İçerikleri Boş
**Durum:** Tüm tablolarda `name_en`, `description_en` vb. kolonlar var ama doldurulmadı.

**Yapılacak:** Admin panelde her ürün/bölüm için EN tab'ından İngilizce içerik gir. Boş bırakılırsa frontend TR'ye düşer (kasıtlı fallback).

#### 4. Yasal Sayfalardaki Placeholderlar
**Durum:** `gizlilik.html`, `kullanim.html`, `cerez.html` dosyalarında placeholderlar var:
- `[ŞİRKET ADI]`
- `[VERGİ NO]`
- `[MERSİS NO]`
- `[ADRES]`
- `[TELEFON]`
- `[E-POSTA]`

**Yapılacak:** Şirket kurulduktan sonra gerçek bilgilerle değiştir.

---

### 🟡 P1 — Önemli (yakın gelecek)

#### 5. Domain Alımı
**Durum:** `thehouseofanatolia.com` müsait ama alınmadı.

**Yapılacak:**
- Cloudflare Registrar'dan al (~$10/yıl)
- DNS ayarlarını Netlify'a yönlendir
- Yasal sayfalardaki domain referanslarını gerçek domain'e güncelle

#### 6. Hosting Deploy
**Durum:** Site lokal, deploy yok.

**Plan:**
- Netlify (drag-drop kolay)
- Site klasörünü zip'le veya doğrudan yükle
- `index_supabase.html` → `index.html` olarak yeniden adlandır
- `admin_yeni_urun_duzeltilmis_v2.html` → `admin.html` olarak yeniden adlandır
- Custom domain bağlama
- HTTPS otomatik

#### 7. Email Adresi Aktif Değil
**Durum:** Site `info@thehouseofanatolia.com` kullanıyor ama bu adres henüz çalışmıyor.

**Yapılacak:** Domain alındıktan sonra Google Workspace veya Cloudflare Email Routing ile aktif et. Yoksa form maillerini almazsın.

---

### 🟢 P2 — Nice to have

#### 8. Newsletter Gönderim Altyapısı
**Durum:** Aboneler birikiyor (RLS güvenli) ama gönderim sistemi yok. Karar: 50+ aboneye ulaşınca yapacak.

**Plan A (şimdi):** CSV indir → Brevo veya Mailchimp ücretsiz hesap → bülten gönder
**Plan B (50+ abone):** Resend API + Supabase Edge Function + admin panele "Bülten Yaz" UI

#### 9. SEO Optimizasyonları
**Eksik:**
- `robots.txt`
- `sitemap.xml`
- Schema.org JSON-LD (Product, Organization, FAQ)
- Google Search Console verification
- Bing Webmaster Tools
- Open Graph image (1200x630 jpeg)

**Mevcut:**
- Meta description ✅
- OG basic ✅
- Twitter Card ✅
- hreflang ✅
- Canonical URLs ✅

#### 10. Performance
**Şu an:**
- index_supabase.html: 173 KB (büyük ama kabul edilir)
- product.html: 84 KB
- admin: 168 KB (admin için sorun değil)
- Görsel yok (sorun değil şimdilik)

**Yapılabilir:**
- HTML/CSS/JS minify (Netlify otomatik)
- Critical CSS inline (zaten inline)
- Font subsetting (Cormorant Garamond büyük)
- Lazy loading (görsel eklendiğinde)

#### 11. Analytics Events
**Şu an:** Sadece page view tracking var.

**Eklenebilir:**
- Form submit event
- Newsletter signup event
- Lang switch event
- Map city click event
- Product page hero click

Bunlar `page_views` tablosuna ek bir `event_type` kolonu ile eklenebilir.

#### 12. A11y (Accessibility)
**Mevcut:**
- Alt text'ler ✅
- Aria labels ✅ (lang switcher, map tooltip)
- Semantic HTML ✅
- Keyboard navigation ✅ (Tab/Enter)
- prefers-reduced-motion ✅

**Eksik:**
- Screen reader testleri yapılmadı
- Color contrast WCAG AA tam doğrulanmadı (bazı muted text'ler kıt olabilir)
- Skip-to-main link yok
- Aria-live for form status messages eksik olabilir

---

## ⚠️ Mevcut Sınırlamalar

### Frontend
1. **Build step yok** — Tek HTML, vanilla JS. Bu kasıtlı (basit deploy) ama karmaşık component'leri zorlaştırır.
2. **Admin panel TEK SAYFA** — 4810 satır. Yönetimi zor. İleride ayrı bir SPA'ya çevrilebilir.
3. **Lightbox vanilla JS** — Bazı edge case'lerde takılabilir (çoklu galeri).
4. **i18n manuel** — Her yeni metin için `data-i18n` ekle + dict'e gir. Otomasyon yok.

### Backend (Supabase)
1. **Free tier** — 500 MB DB, 1 GB storage, 50K MAU. Şu an yeterli, büyürse Pro'ya ($25/ay) geç.
2. **Realtime aktif değil** — Anlık veriye gerek yok şimdilik.
3. **Edge Functions yok** — Newsletter SMTP veya web hooks için lazım olacak.
4. **Backup manuel** — Supabase otomatik backup'lar 7 gün, yeterli.

### Dış Bağımlılıklar
1. **FormSubmit.co** — Ücretsiz, tablodan okuyup mail atar. Ama unreliable olabilir, üst limit var (50/ay free).
2. **esm.sh CDN** — Supabase JS client buradan geliyor. CDN düşerse site çalışmaz. Self-host alternatifi var ama ihtiyaç yok şimdilik.
3. **Google Fonts** — DSGVO/KVKK gri alanı (Almanya'da problem oldu birkaç dava). İleride self-host yap.

### Güvenlik Sınırlamaları
1. **Anon Key public** — Bu normal, RLS koruması var. Ama tablolardaki politikalar çok kritik.
2. **Brute force koruma localStorage'da** — Kullanıcı silebilir. Server-side rate limit Supabase'de yok şimdilik.
3. **Honeypot bypass mümkün** — Sofistike botlar geçer. reCAPTCHA eklenebilir (ama UX kötü).
4. **CORS** — Tüm origin'ler open. Domain alınınca whitelist yapılabilir.

---

## 🐛 Bilinen Bug'lar

### Frontend
1. **Custom cursor mobil-touch** — Bazen touch device'da kısa süreliğine gözükebilir (touchstart sonrası gizleniyor zaten).
2. **TR/EN switch + scroll position** — Dil değiştirildiğinde sayfa başına dönmüyor (kasıtlı), ama `data-i18n-slogan` ile büyük metin değişiminde hafif sıçrama.
3. **Map tooltip Z-index** — Modal açıldığında tooltip altta kalıyor (rare).
4. **Page loader long network** — 3G'de sayfa yüklenirken loader 5+ saniye gözükür.

### Backend
1. **Rate limit tuning** — Newsletter için 3/email/5dk biraz cömert. 1/email/dk daha güvenli.
2. **Audit log boyutu** — Şu an temiz ama 6 ay sonra büyür. Cron ile eski kayıt silme gerek.

### Admin Panel
1. **Drag-and-drop sort_order yok** — Manuel sıralama var, drag ile değil.
2. **Toplu işlem yok** — Bulk delete, bulk update vb. henüz yok.
3. **Image preview lightbox yok** — Yüklenen görselleri büyük boyut görmek için yok.

---

## 📋 Test Edilmemiş Senaryolar

1. **iOS Safari** — Test edilmedi, custom cursor problem olabilir.
2. **Eski Android (Chrome <80)** — i18n script çalışır mı belirsiz.
3. **IE11** — Hiç desteklenmiyor (kasıtlı), ama belki crash etmemeli.
4. **Slow 3G** — Loader uzun gözükebilir.
5. **JavaScript kapalı** — Site büyük ölçüde çalışmaz (Supabase JS gerekli).
6. **Çoklu sekmeden simultaneous form submit** — Rate limit'e takılır mı?
7. **Çok büyük image upload (4-5 MB)** — Storage limit 5 MB, ama UI feedback eksik olabilir.
8. **DB connection drop** — Supabase düşerse retry mekanizması yok.
9. **Browser back button** — SPA olmadığı için sorun yok normalde.
10. **Print stylesheet** — `@media print` yok, yazdırma korkunç olur.

---

## 💡 İyileştirme Önerileri

### Kısa Vade
1. Tasarım yenileme (priority)
2. SQL'leri çalıştırma
3. Domain + hosting
4. EN içerikleri doldurma

### Orta Vade
1. SEO eklentileri
2. Schema.org markup
3. PWA (offline page)
4. Image optimization (lazy + WebP)
5. Better mobile UX (sticky CTA)

### Uzun Vade
1. E-ticaret altyapısı
2. SMTP newsletter
3. Multi-language genişlet (DE, FR)
4. Headless CMS'e migrate (Strapi, Sanity)
5. Server-side rendering (Next.js'e port)
6. Advanced analytics (funnel, retention)
7. Customer accounts (favorites, order history)

---

## 🚦 Risk Listesi

| Risk | Olasılık | Etki | Mitigation |
|---|---|---|---|
| Supabase Free tier'ı aşma | Düşük | Orta | Pro'ya geç ($25/ay) |
| Spam form submission | Orta | Düşük | Rate limit + honeypot var, reCAPTCHA eklenebilir |
| KVKK denetimi | Düşük | Yüksek | Sayfalar hazır, IP saklanmıyor, OK |
| Domain alınamadan launch | Olası | Yüksek | Önce domain, sonra deploy |
| Görselsiz launch | Yüksek | Orta | Kabul edildi, sonradan eklenecek |
| Anon Key leakage | N/A | N/A | Public zaten, RLS koruması yeterli |
| Admin email leak | Düşük | Yüksek | Strong password + 2FA önerilir |

---

## 🆘 Acil Müdahale Senaryoları

### "Site çöktü"
1. Supabase status check: https://status.supabase.com
2. Browser console: Hata var mı?
3. CDN check: esm.sh çalışıyor mu?
4. DNS: domain aktif mi?

### "Form mail gelmiyor"
1. Supabase'de `requests` tablosunu kontrol et — kayıt geliyor mu?
2. FormSubmit.co console: aktivasyon onaylandı mı?
3. Spam klasörü kontrol

### "Spam selivori başladı"
1. Rate limit trigger'ı sertleştir (3/dk → 1/dk)
2. reCAPTCHA ekle (Google reCAPTCHA v3)
3. Belirli IP block (Cloudflare WAF)

### "DB doluyor"
1. `page_views` eski kayıt sil:
   ```sql
   DELETE FROM page_views WHERE created_at < now() - interval '90 days';
   ```
2. `audit_log` eski kayıt sil:
   ```sql
   DELETE FROM admin_audit_log WHERE created_at < now() - interval '180 days';
   ```

### "Admin parolasını kaybettim"
1. Supabase Dashboard → Auth → Users
2. Kullanıcıyı bul → "Reset password" mail gönder
3. Veya yeni kullanıcı oluştur, eskisini sil
