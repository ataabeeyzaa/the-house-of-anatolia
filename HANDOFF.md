# HANDOFF — The House of Anatolia

> **2026-05-08 güncel (PR #7 sonrası)** — projenin tam haritası, yeni Claude Code sohbetine geçişte gerekli tüm bağlam.

---

## Proje Özeti

**Marka:** The House of Anatolia
**Slogan (TR):** Lezzetin *Kökenine* Yolculuk
**Slogan (EN):** A Journey to the *Roots* of Taste
**Konsept:** Türkiye'nin coğrafi işaretli (GI) ürünlerini üreticisinden tüketiciye ulaştıran vitrin sitesi.
**Şu anki ürün:** Safranbolu Safranı (Karabük) — slug: `karabuk-safrani` (URL stability — değişmedi)
**Diller:** TR (varsayılan) + EN
**Estetik:** Editorial Heritage — refined modernism (Aesop / Hermès / Le Labo benzeri)

---

## Canlı Site

| Bileşen | URL |
|---|---|
| Production | https://house-of-anatolia.netlify.app |
| Anasayfa | https://house-of-anatolia.netlify.app/ |
| **Ürünler** (yeni) | https://house-of-anatolia.netlify.app/products.html |
| Ürün detayı | /product.html?slug=karabuk-safrani |
| Admin paneli | /admin.html |
| Yasal sayfalar | /gizlilik.html, /kullanim.html, /cerez.html |
| robots.txt | /robots.txt |
| sitemap.xml | /sitemap.xml |
| GitHub repo (private) | https://github.com/ataabeeyzaa/the-house-of-anatolia |
| Netlify dashboard | https://app.netlify.com/projects/house-of-anatolia |
| Supabase project | https://supabase.com/dashboard/project/owcgcyvgibyawxfxwlbn |

---

## Dosya Yapısı

```
/
├── index.html                       ← Anasayfa: navbar, slogan, harita (sparkle YOK), KEŞFET, marquee strip, hakkımızda, contact 2-col (3 info kart + newsletter card), footer 4-col (newsletter contact'a taşındı)
├── product.html                     ← Ürün detay + talep formu (Supabase + FormSubmit) — mini-blossom safran çiçeği KORUNUR
├── products.html                    ← Ürünler vitrini (Supabase fetch is_active=true filter)
├── admin.html                       ← Admin panel (paket CRUD silindi, ürün/şehir/galeri CRUD aktif)
├── gizlilik.html, kullanim.html, cerez.html  ← Yasal sayfalar (placeholder dolacak)
├── robots.txt                       ← SEO crawl rules (admin disallow)
├── sitemap.xml                      ← 6 URL + TR/EN hreflang
├── supabase_schema_v2_fixed.sql     ← İlk şema (referans)
├── assets/                          ← 18 dosya, 3.4 MB
├── .github/workflows/deploy.yml     ← GitHub Actions auto-deploy
├── .claude/launch.json              ← Claude Code preview config
├── .claude/mockups/                 ← 6 frontend-design concept (gitignore'da)

DOKÜMANTASYON:
├── HANDOFF.md           ← Bu dosya
├── ARCHITECTURE.md      ← Stack, deploy, plugin envanteri, DB şema
├── DESIGN_SYSTEM.md     ← Renk + tipografi + pattern'ler + yasaklar
├── KNOWN_ISSUES.md      ← Kalan işler, sınırlamalar
└── FIRST_PROMPT.md      ← Yeni Claude Code sohbeti için ilk prompt
```

---

## Backend — Supabase

**URL:** `https://owcgcyvgibyawxfxwlbn.supabase.co`
**Anon Key:** HTML'lerde tanımlı (public, RLS korumalı)
**14 tablo + Storage bucket** `product-assets` (5MB, SVG yasak)
Detay: ARCHITECTURE.md

---

## Yapılanlar (kronolojik)

### Phase 0 — Altyapı (önceki sohbet)
- GitHub private repo + Netlify deploy + GitHub Actions CI/CD
- 18 plugin + Supabase MCP + chrome-devtools-mcp
- Inter → Plus Jakarta Sans + Cormorant Garamond
- Reddedilen denemeler temizlendi (KÜNYE, cert-badge, stats bar, EST badge, cinematic hero)
- Atmospheric layer (SVG noise) + custom scrollbar + hover refinements

### Phase 1 — PR #1 (SEO + Cleanup + A11y)
- **SEO altyapısı:** robots.txt + sitemap.xml + JSON-LD (Organization, WebSite, Product, BreadcrumbList) + canonical + product.html title fix ("Ürün Detayı" → "Safranbolu Safranı — The House of Anatolia")
- **Dead code temizliği (~360 satır):** admin.html paket CRUD JS + .package-edit-panel CSS + index.html cert-* / asymmetric about-grid / hero-grid/lines/dots/mountains + 24 dead i18n key × 2 dil
- **A11y skip-to-main:** index/product/admin'e `<a class="skip-link">` + `id="main-content"` (WCAG 2.4.1)
- Lighthouse: **A11y 98 / SEO 92 / Best Practices 96 / Agentic 100**

### Phase 2 — PR #2 (Sparkle iter 1 + contact + footer)
- Sparkle yan-drift (translateX) → minik statik dots map arkasında (z-index:0)
- Contact card border + radius + bg gradient
- Footer grid 1.4/1/1/1.2 → 1.8/1/1/1.4
- Footer h4 Cormorant 1.3rem → Plus Jakarta 0.74rem uppercase

### Phase 3 — PR #3 (Sparkle removal + Products sayfası)
- Sparkle TAMAMEN kaldırıldı (kullanıcı isteği — harita üzerinde de altında da kalmasın)
- Yeni `products.html` (~280 satır): Supabase fetch + TR/EN i18n + JSON-LD CollectionPage + hreflang + mobile responsive + skip-to-main
- Navbar `nav_products` link href `#home` → `products.html`, text "Ürün Haritası" → "Ürünler"
- Footer Sayfalar listesine "Ürünler" eklendi
- sitemap.xml'e `/products.html` URL eklendi

### Phase 4 — PR #4 (Sparkle re-add + Map section + Contact)
- **Sparkle GERİ EKLENDİ ama harita ARKASINDA:** `.hero-blossom-layer{z-index:0}`, `.map-wrap > svg{z-index:1}` — opak il alanlarında görünmez, transparent kenarlarda görünür. `@keyframes sparkle-twinkle` rotate kaldırıldı, **DİKEY yukarı translateY -36px** (yana hareket yok).
- **Map section yenilendi:**
  - 4 future-pill HTML + `pill_1-4` i18n keys silindi
  - `.eyebrow::after` eklendi → "KEŞFET" iki yanında altın çizgi
  - city_note kısaltıldı: "Bir ürünün belirli bir yöreye özgü olduğunun resmi belgesidir — başka yerde aynı kalitede üretilemez."
  - **Yeni `.marquee-strip`** — TV altyazısı tarzı kayan şerit (5 yakında ürün: Kastamonu Sarımsağı, Antep Fıstığı, Trabzon Hamsisi, Maraş Dondurması, Edirne Ciğeri) — 38s linear infinite, ✦ ayraçlı, `i18n marquee_1-5` (TR + EN)
- **Contact card horizontal 2-sütun:** `max-width: 640 → 1020px`, `grid-template-columns:1fr 1.1fr`, sol başlık+intro / sağ liste, mobile (<820px) fallback
- **Section spacing:** `.section padding 110px → 80px` (sayfa daha kompakt)
- **products.html:** `loadProducts` query'e `.eq("is_active", true)` filter + intro paragraf kaldırıldı

### Phase 5 — PR #6 (Sparkle removal + Contact rebuild + Footer newsletter taşıma)
- **Sparkle TAMAMEN KALDIRILDI** (kullanıcı net karar): index.html'de CSS (`.hero-blossom-layer`, `.gold-sparkle`, `::before/::after`, `@keyframes sparkle-twinkle`, prefers-reduced-motion) + HTML (`<div class="hero-blossom-layer">`) + JS (sparkleEffect IIFE — spawn loop + initial burst).
- **Contact section 2-col yeni layout:**
  - SOL: eyebrow "İLETİŞİM" çift altın çizgi + H2 "Bizimle iletişime geçin." + intro + 3 dikey info card (E-POSTA / ADRES / TELEFON) — her kart: SVG ikon (mail/map-pin/phone Heroicons outline) + label/value flex layout, panel-soft bg, 18px radius, gold hover border
  - SAĞ: `.contact-newsletter-card` — radial gold glow gradient, 22px radius, "Bültenimize Katılın" başlık + intro + pill input + ABONE OL pill button
- **Footer newsletter contact'a taşındı:** `.footer-top` + `.footer-newsletter` HTML/CSS tamamen kaldırıldı. Form id `newsletter-form` + status id `newsletter-status` aynen korundu (JS handler dokunulmadı). Footer-grid 4-col layout (brand, sayfalar, yasal, iletişim) aynen korundu.
- **i18n duplicate fix:** TR `contact_title` 2 defa tanımlanmıştı ("iletişime geçin" + "bağlantıya geçin"); ikincisi silindi, "iletişime geçin" geçerli.
- **product.html dokunulmadı** — `.hero-blossom-layer` mini-blossom safran çiçeği için kullanılan kapsayıcı, mini-blossom KORUNUR.

### Phase 6 — PR #7 (Hamburger + Ürünler section + Marquee admin + product refresh)
- **Anasayfa contact sadeleştirildi:** SOL kolondan eyebrow + H2 + intro paragraf KALDIRILDI. Sadece 3 info kart (E-POSTA / ADRES / TELEFON) kaldı. SAĞ newsletter card aynen.
- **Anasayfa "Ürünler" section eklendi:** about ile contact arasına. Küçük kart vitrini (auto-fit minmax 220px); Supabase products fetch is_active=true, limit 8; "Tümünü Gör →" linki `/products.html`'e. CSS scoped under `.products-section` (16/10 aspect-ratio görseller, hover gold border + image scale).
- **Hamburger menü (Aesop pattern):** Yatay nav-links kaldırıldı (`.nav-center` HTML'de yok). Sağ üstte hamburger button (`.nav-toggle`) + lang switcher kaldı. Click → fullscreen `.nav-overlay` açılır (radial gold glow + blur backdrop). Overlay içinde:
  - SAYFALAR (Ana Sayfa / Hakkımızda / İletişim)
  - ÜRÜNLER (Tüm Ürünler + Supabase fetch dinamik liste — şu an Sarımsak + Safran)
  - Yasal linkler (gizlilik / kullanım / cerez) + lang switcher
  - ESC + backdrop click + `[data-nav-close]` ile kapanır, body scroll lock.
- **product.html "Karabük'ün" → "Safranbolu'nun":** TR + EN tüm GI attribution cümlelerinde (meta description, og/twitter, JSON-LD, kicker, hero-subtitle). Karabük il/adres bilgisi olarak korundu. **NOT:** hero_subtitle Supabase products tablosundan da geliyor — kullanıcı admin'den düzenlemeli.
- **product.html alt contact:** mevcut tipografik 3 sütun → anasayfa `.contact-info-card` stilinde 3 yatay kart (SVG ikon + label/value). Mobile <760 dikey, <540 sıkışık.
- **Marquee dinamik (Supabase + statik fallback):** Yeni `marquee_items` tablo (label_tr / label_en / sort_order / is_active) + RLS. `loadMarqueeItems()` async fetch, sonuç varsa `.marquee-track`'i hot swap; tablo yoksa veya boşsa mevcut 10 statik HTML item ile i18n keys fallback. Migration: `supabase_migrations/2026-05-08-marquee-items.sql` (kullanıcı SQL Editor'dan çalıştırır).
- **Admin "Şerit" sekmesi:** dashboard'a yeni card. CRUD UI: tablo (TR / EN / Sıra / Aktif / [Düzenle] [Pasifleştir] [Sil]) + yeni ekle / edit form. Tablo yoksa migration uyarısı.

### Kullanıcının PR #7 sonrası yapması gerekenler

1. **Supabase migration çalıştır:** Dashboard → SQL Editor → new query → `supabase_migrations/2026-05-08-marquee-items.sql` paste → Run. Sonra admin "Şerit" sekmesi fonksiyonel olur ve canlı marquee dinamik veriden render eder.
2. **Safran ürünü hero_subtitle güncelle:** admin → Ürünler → Safranbolu Safranı düzenle → "Hero altyazı" alanı şu an "Karabük'ün coğrafi işaretli en zarif değeri" olabilir → "Safranbolu'nun coğrafi işaretli en zarif değeri" yap → kaydet. (HTML default güncellendi ama DB değer override eder.)

---

## Kullanıcı Tercihleri (ÖNEMLİ — değiştirme!)

### İletişim Tarzı
- **Türkçe**, kısa, doğrudan
- "Salak mısın" gibi sert tepkiler frustrasyon ifadesi → defensiveness yapma, somut cevap ver, kanıtla (curl + grep ile doğrulama)
- Detaylı teknik açıklama ister ama uzatma

### Beğendiği
- Plus Jakarta Sans + Cormorant Garamond combo
- İtalik gold accent (slogan vurgusu)
- Koyu zemin + altın aksanlar
- İnce çizgiler, boşluk hakimiyeti
- **KEŞFET eyebrow'un iki yanında altın çizgi**
- **Map'in altında kayan şerit** (yakında ürünler)
- Mini-blossom safran çiçeği (product.html — dokunulmaz)
- **Contact 3 info kart sol + newsletter card sağ (PR #6+#7 — başlık/intro yok, sade)**
- **Anasayfa Ürünler section küçük kartlı vitrin** (PR #7)
- **Hamburger menü (sağ üstte ☰), Aesop pattern fullscreen overlay** (PR #7)

### Reddettiği
- Stats bar 1/1/1 sayım kartları → "ucuz duruyor"
- KÜNYE bilgi kartı → "ucuz duruyor"
- Sertifika rozeti (TPMK) → "ucuz duruyor"
- EST 2026 — ANATOLIA badge
- 3-sütun yan yana dikey adres/telefon/eposta (kart yığını OK ama yan yana 3 sütun değil)
- Cinematic hero (büyük dağ silüetleri)
- **Sparkle / gold-sim parçacıklar — TÜM VARYANTLAR** (haritanın üzerinde, etrafında, ARKASINDA — hiçbir konumda kabul edilmiyor; PR #6'da tamamen kaldırıldı)

### Karar Verilmiş Kararlar (değiştirme!)
- Site alacak kişi için yapılıyor (Beyza geliştirici, ortak içerik girer)
- E-ticaret niyeti var ama **şirket kurulmadan satış olmaz** — şu an "talep formlu vitrin"
- Bilingual TR + EN
- Custom cursor: KORUNACAK
- Slug `karabuk-safrani` DEĞİŞMEYECEK
- Renk palette: koyu + altın + krem (başka renk YASAK)
- Inter / Roboto / Arial / system fonts YASAK
- Force push YASAK (`--force`, `--force-with-lease` kullanma)
- `--no-verify` YASAK
- Push öncesi `git fetch origin main && git rebase origin/main` istisnasız

---

## Kalan İşler (özet)

### P0 (kullanıcı yapacak — yayın öncesi kritik)
- [ ] Eski Netlify token revoke
- [ ] Yasal sayfa placeholder'ları (12 yer: ŞİRKET ADI, VERGİ NO, MERSİS, ADRES, TEL, EPOSTA)
- [ ] Telefon numarası gerçek olsun (+90 5XX XXX XX XX placeholder)
- [ ] Domain alma (`thehouseofanatolia.com` ~$10/yıl)
- [ ] Email Routing (Cloudflare)
- [ ] Admin user oluştur (Supabase Auth + admins tablosu — full_name NOT NULL)

### P1 (sonradan)
- [ ] EN içerikleri admin panelden doldur
- [ ] **Marquee admin entegrasyonu** (Supabase `marquee_items` tablosu + admin CRUD UI — şu an statik)
- [ ] Newsletter SMTP (50+ abone)
- [ ] Performance: image lazy loading, font subsetting

### P2 (cleanup)
- [ ] CSS dead code: `.future-pill`, `.future-list` (HTML'den silindi ama CSS rule'ları kaldı)
- [ ] DB'de `package_options` tablosu (UI kullanmıyor)

Detay: KNOWN_ISSUES.md

---

## Geliştirme Akışı

### Local Test
- `.claude/launch.json` ile Claude Preview otomatik açılıyor
- Mobil viewport: `preview_resize preset:mobile` (375x812)

### Git Workflow
- Her main push → otomatik Netlify deploy (~1.5 dk)
- Branch (`claude/...`) → `gh pr create` → review → `gh pr merge --rebase --delete-branch`
- **Push öncesi:** `git fetch origin main && git rebase origin/main`
- Force push + `--no-verify` YASAK
- 7 PR mergede tamamlandı (#1, #2, #3, #4, #5 docs refresh, #6 sparkle removal + contact rebuild + footer newsletter taşıma, #7 hamburger + ürünler section + marquee admin + product refresh)

---

## Domain & Şirket Durumu

| Konu | Durum |
|---|---|
| Domain | ❌ thehouseofanatolia.com müsait, alınmadı |
| Şirket | ❌ Kurulmadı |
| Sanal POS | ❌ Yok |
| KVKK | ⚠️ Skeleton hazır, şirket kurulmadan tamamlanamaz |

---

## Erişim Bilgileri (kullanıcı tarafında)

- **GitHub:** ataabeeyzaa
- **Netlify:** beyzata37@gmail.com
- **Supabase:** GitHub login (Beyza)
- **Email:** beyzata37@gmail.com (kişisel)
- **Ortak hesap (admin):** thehouseofanatoliaco@gmail.com

---

## Aesthetic Direction

**"Editorial Heritage — Anatolian terroir meets refined modernism"**

- Bold color discipline: koyu zemin + altın + krem — hiçbir başka renk yok
- Typography: Cormorant Garamond display + Plus Jakarta Sans body
- Atmospheric depth: SVG noise overlay, radial gradients (sparkle KALDIRILDI — PR #6)
- Motion polish: reveal animations, hover surprises, marquee strip kayan şerit
- Mobile-first: 375 → 480 → 820 → 980 → 1180 → 1600px
- prefers-reduced-motion saygısı
- "No AI slop": Inter, Roboto, Arial, Space Grotesk YASAK. Generic gradients YASAK. Predictable layouts YASAK.

Detay: DESIGN_SYSTEM.md
