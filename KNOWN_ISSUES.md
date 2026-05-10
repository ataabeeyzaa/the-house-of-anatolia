# KNOWN ISSUES & TODO — The House of Anatolia

> **2026-05-10 güncel (PR #17 sonrası)** — site canlıda, **GitHub Pages otomatik deploy**. 17 PR mergede tamam.
> **Hosting:** Netlify → GitHub Pages (PR #14 taşıma sonrası). **Admin koruması:** Cloudflare Zero Trust Access aktif (PR #16+#17).

---

## P0 — Hâlâ kullanıcının yapması gerekenler

### A. Telefon numarası gerçek olsun
- `+90 (5XX) XXX XX XX` placeholder şu an her yerde
- `index.html` (contact info-card + footer-contact) + `product.html` (alt contact) + yasal sayfalar (gizlilik, kullanim, cerez)
- Find/replace ile bir kerede güncellenir

### B. Yasal sayfa placeholder'ları (12+ yer)
- `gizlilik.html`: 5 placeholder
- `kullanim.html`: 7 placeholder
- Doldurulacak: `[ŞİRKET ADI]`, `[VERGİ DAİRESİ / VERGİ NO]`, `[MERSİS NO]`, `[TİCARET SİCİL NO]`, `[ŞİRKET ADRESİ]`, `[TELEFON]`
- ⚠️ **KVKK uyumu için şirket kurulmadan tamamlanamaz** — şirket kuruluş resmi bilgileri lazım
- Avukat / KVKK danışmanı önerilir (~3000-8000 TL)

### C. Admin user oluştur (Supabase)
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

### D. Anasayfa hikayemiz içeriği admin'den düzenle (PR #10 yeni özellik)
- admin → Ana Sayfa Bölümleri → about row → Düzenle
- "Başlık" → h2'yi override eder (italic gold accent için `*kelime*` syntax)
- "Alt başlık" → first paragraph override
- "İçerik" → newline-delimited paragraflar → mevcut <p>'leri sırayla override eder
- DB row yoksa i18n fallback aynen çalışır

### E. Vision row'unu admin'den sil
- admin → Ana Sayfa Bölümleri → "Vizyonumuz" satırı → Sil
- Anasayfada kullanılmıyor (frontend sadece about row'unu okuyor)

### F. Eski Netlify hesabı kapat (opsiyonel temizlik)
- https://app.netlify.com → site `house-of-anatolia` → Site configuration → Delete site
- Netlify Personal Access Token zaten revoke edildi
- GitHub Secrets'ta NETLIFY_AUTH_TOKEN ve NETLIFY_SITE_ID hâlâ duruyor olabilir — sil (artık kullanılmıyor)

### G. Cloudflare Access ikinci email kontrolü
- Zero Trust → Access → Policies → Admin Only → Edit
- Allowed emails: `thehouseofanatoliaco@gmail.com` (ortak), `beyzata37@gmail.com` (Beyza)
- Beyza'nın e-postasının olması istenmiyorsa kaldır

---

## P1 — Önemli ama acil değil

### EN İçerikleri
- Tüm tablolarda `name_en`, `description_en`, `meta_description_en` vb. kolonlar boş
- Admin panelden TR/EN tab'ları kullanarak doldurulmalı
- Şu an EN kullanıcı boş alanlar için TR fallback görür (kasıtlı)

### Newsletter Gönderim
- Şu an: aboneler `newsletter_subscribers`'a kaydediliyor, gönderim yok
- Plan A (50+ abone): CSV indir → Brevo/Mailchimp ücretsiz hesap
- Plan B: Resend ($20/ay) + Supabase Edge Function + admin "Bülten Yaz" UI

### Performance
- Mevcut: index.html ~210 KB, product.html ~80 KB, admin.html ~175 KB, products.html ~12 KB
- Yapılabilir: HTML/CSS/JS minify (GitHub Pages otomatik değil — manuel build adımı veya minimal koruma), font subsetting (Cormorant büyük), image lazy loading audit

### Lighthouse re-audit
- PR #1 sonrası ölçüldü: A11y 98 / SEO 92 / BP 96 / Agentic 100
- PR #10-17 sonrası tekrar ölçülmedi — yeni hosting + Cloudflare proxy ile değişebilir
- Önerilen: Chrome DevTools Lighthouse paneli mobile + desktop

### Bonus güvenlik (opsiyonel)
- Cloudflare Access **session duration** 24 saat — daha kısa istenirse Application → Edit → Session duration: 8 hours
- CSP header (Content-Security-Policy) — Cloudflare Page Rules veya HTML meta tag ile

---

## P2 — Cleanup (opsiyonel)

### Dead Code (CSS)
- `.future-pill`, `.future-list` rules — HTML'den silindi (PR #4) ama CSS rules kaldı
- `.contact-footer-col`, `.contact-centered` — HTML'de kullanım var mı belirsiz, eski layout artığı olabilir
- `.gold-accent` (slogan'da JS dinamik kullanım var, koru)

### Dead i18n Keys
- ✅ `pill_1-4`, `hero_est`, `hero_stat1-3`, `cert_*`, `about_meta_*`, `nav_gi`, `map_eyebrow` (PR #1, #4, #10'da silindi)

### Dead DB Tablo
- `package_options` tablosu — UI hiç kullanmıyor, eski talep kayıtlarındaki FK için duruyor
- Drop yapılırsa eski request'lerdeki package_option_id NULL olmalı

### Diğer
- `supabase_schema_v2_fixed.sql` — referans dosya, repo'da kalabilir (yeniden migration için faydalı)
- Eski `index_supabase.html` referansları (varsa) — page_views URL filter ile zaten engellenmiş (PR #10)

---

## Sınırlamalar

### Frontend
1. **Build step yok** — kasıtlı, basit deploy. Karmaşık component reuse zor.
2. **Admin panel TEK SAYFA** — 4750+ satır. Yönetimi zor. SPA refactor değer.
3. **i18n manuel** — her yeni metin için `data-i18n` ekle + dict'e gir
4. **Marquee items DB'den** (PR #7-9 sonrası); admin'den yönetiliyor

### Backend (Supabase)
1. **Free tier** — 500 MB DB, 1 GB storage, 50K MAU, yeterli
2. **Realtime kapalı** — gerek yok
3. **Edge Functions yok** — newsletter SMTP veya web hooks için lazım olacak
4. **Backup manuel** — auto-backup 7 gün retention

### Hosting (GitHub Pages — PR #14 sonrası)
1. **Sınırsız bandwidth + build** — public repo için ücretsiz
2. **Custom domain + HTTPS** — otomatik (Let's Encrypt)
3. **Repo public şart** — sadece public repo'da custom domain ücretsiz çalışır
4. **Headers/redirect customization yok** — Netlify _headers / _redirects yok; Cloudflare Page Rules ile yapılır
5. **Server-side rendering yok** — vanilla static; SSR ihtiyacı doğarsa Vercel/Cloudflare Pages düşünülebilir

### Auth (Cloudflare Zero Trust Access)
1. **Free tier** — 50 user limit (yeterli)
2. **Email PIN** — Cloudflare'in mailing system'i (spam'e düşebilir, "noreply@notify.cloudflare.com" filter)
3. **Identity Provider** — One-time PIN default; GitHub OAuth eklenebilir alternatif

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

1. iOS Safari (custom cursor + marquee performance)
2. Eski Android Chrome (<80) (i18n)
3. Slow 3G (loader)
4. JavaScript kapalı
5. Çoklu sekmeden simultaneous form submit (rate limit)
6. Çok büyük image upload (5 MB sınır)
7. Print stylesheet (`@media print` yok)
8. Cloudflare Access PIN gecikmesi senaryoları (mail provider sorunları)

---

## Çözülen / Kapalı (referans)

### PR #1 — SEO + Cleanup + A11y
- ✅ robots.txt + sitemap.xml + JSON-LD + canonical
- ✅ Dead code temizliği + skip-to-main link
- ✅ Lighthouse: A11y 98 / SEO 92 / BP 96 / Agentic 100

### PR #2 — Sparkle iter 1 + contact + footer
- ✅ Sparkle yan-drift → minik statik dots; contact card border + radius

### PR #3 — Sparkle removal + Products sayfası
- ✅ Sparkle TAMAMEN kaldırıldı (sonra geri eklendi PR #4, sonra final removal PR #6)
- ✅ Yeni products.html

### PR #4 — Sparkle re-add + Map section + Contact
- ✅ Sparkle harita arkasına geri (sonra final removal PR #6)
- ✅ Marquee strip + contact horizontal 2-col

### PR #6 — Sparkle FİNAL removal + Contact rebuild + Footer newsletter taşıma
- ✅ Sparkle TÜM VARYANTLAR kaldırıldı + yasaklar listesine eklendi
- ✅ Contact 2-col, footer newsletter contact'a taşındı

### PR #7 — Hamburger + Ürünler section + Marquee admin + product refresh
- ✅ Hamburger Aesop pattern, anasayfa Ürünler section (sonra PR #8'de kaldırıldı), marquee_items tablo + admin CRUD, product.html "Karabük → Safranbolu"

### PR #8 — UI revize + Galeri render + Marquee permission fix
- ✅ Navbar yatay link geri + hamburger EN SOLA
- ✅ Anasayfa Ürünler section komple kaldırıldı
- ✅ products.html küçük kare (auto-fill 240px sabit)
- ✅ Marquee GRANT migration (anon/auth)
- ✅ product.html galeri statik kaldırıldı, dinamik render

### PR #9 — Marquee infinite + admin sort + mobil + boşluk
- ✅ Marquee min kopya formülü `Math.ceil(10/data.length)` — 1 item bile sürekli akar
- ✅ Admin sort_order default = max+1 (1, 2, 3 ardışık)
- ✅ Marquee → about arası ◆ silindi
- ✅ Mobile product.html hero padding küçültüldü

### PR #10 — Çoklu UI fix + DB-bağ + email + adres
- ✅ KEŞFET eyebrow kaldırıldı; "Coğrafi işaret:" prefix eklendi
- ✅ About → contact arası ◆ silindi
- ✅ E-posta tüm yerlerde gmail
- ✅ Adres tüm yerlerde "Türkiye"
- ✅ Page tracking URL validation
- ✅ Admin "Gelen Teklif" Sil butonu
- ✅ product.html navbar hamburger + overlay
- ✅ loadHomepageAbout DB-bağ

### PR #11 — GitHub Actions workflow kaldırıldı
- ✅ `.github/workflows/deploy.yml` silindi (Netlify deploy artık yok)

### PR #14 — GitHub Pages migration
- ✅ Hosting Netlify → GitHub Pages
- ✅ CNAME + .nojekyll dosyaları
- ✅ Tüm URL'ler `house-of-anatolia.netlify.app` → `thehouseofanatolia.com`

### PR #15 — Defensive .gitignore
- ✅ Repo public yapıldıktan sonra security hardening
- ✅ .env, *.pem, *.key, secrets.json, service-account*.json pattern'leri
- ✅ Git history taraması temiz (0 hit hassas string)

### PR #16+#17 — Cloudflare Access entegrasyonu
- ✅ PR #16: client-side admin gate eklendi (URL ?giris param check)
- ✅ PR #17: gate revert — Cloudflare Access dış katmanı yeterli
- ✅ Cloudflare Zero Trust Access aktif (admin.html PIN gate, allowed 2 email)

### Önceki sohbet (Phase 0)
- ✅ Site lokalden GitHub'a + Netlify auto-CI/CD (PR #14'te GitHub Pages'e taşındı)
- ✅ Mobile slogan overflow düzeltme
- ✅ Tipografi (Inter → Plus Jakarta Sans)
- ✅ Cinematic hero kaldırıldı (product.html)
- ✅ Asset klasörü repo'ya
- ✅ Token rotation (artık gereksiz, GitHub Pages token'sız)
- ✅ Footer 4-sütun + brand logo
- ✅ Atmospheric layer (SVG noise overlay)
- ✅ Custom scrollbar + hover refinements
- ✅ Plus Jakarta font features (ligatures, kerning, smoothing)
