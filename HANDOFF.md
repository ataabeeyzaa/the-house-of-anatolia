# HANDOFF — The House of Anatolia

> **2026-05-08 güncel** — projenin tam haritası, yeni Claude Code sohbetine geçişte gerekli tüm bağlam.

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
├── index.html                       ← Anasayfa: navbar, slogan, harita (sparkle arkada), KEŞFET, marquee strip, hakkımızda, contact yatay 2-col, footer
├── product.html                     ← Ürün detay + talep formu (Supabase + FormSubmit)
├── products.html                    ← Ürünler vitrini (YENİ — Supabase fetch is_active=true filter)
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
- **Sparkle (gold sim) — haritanın ARKASINDA, dikey yukarı uçar**
- **KEŞFET eyebrow'un iki yanında altın çizgi**
- **Map'in altında kayan şerit** (yakında ürünler)
- Mini-blossom safran çiçeği (product.html)
- **Contact horizontal 2-col card**

### Reddettiği
- Stats bar 1/1/1 sayım kartları → "ucuz duruyor"
- KÜNYE bilgi kartı → "ucuz duruyor"
- Sertifika rozeti (TPMK) → "ucuz duruyor"
- EST 2026 — ANATOLIA badge
- 3-sütun dikey adres/telefon/eposta
- Cinematic hero (büyük dağ silüetleri)
- Map'in ÜZERİNDE uçuşan parlak şeyler

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
- 4 PR mergede tamamlandı (#1, #2, #3, #4)

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
- Atmospheric depth: SVG noise overlay, radial gradients, sparkle particles (haritanın ARKASINDA)
- Motion polish: reveal animations, hover surprises, marquee strip kayan şerit
- Mobile-first: 375 → 480 → 820 → 980 → 1180 → 1600px
- prefers-reduced-motion saygısı
- "No AI slop": Inter, Roboto, Arial, Space Grotesk YASAK. Generic gradients YASAK. Predictable layouts YASAK.

Detay: DESIGN_SYSTEM.md
