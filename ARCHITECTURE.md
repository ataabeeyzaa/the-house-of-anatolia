# ARCHITECTURE — The House of Anatolia

> **2026-05-08 güncel (PR #7 sonrası)** — stack, deploy, plugin envanteri, DB şema, veri akışları.

---

## Teknoloji Stack'i

```
Frontend:    Vanilla HTML + CSS + ES Modules (build step yok)
Tipografi:   Plus Jakarta Sans (body) + Cormorant Garamond (display)
             Google Fonts CDN (display=swap)

Backend:     Supabase (PostgreSQL + Auth + Storage + RLS)
             https://owcgcyvgibyawxfxwlbn.supabase.co

Hosting:     Netlify (CDN edge cached)
             https://house-of-anatolia.netlify.app

CI/CD:       GitHub Actions (.github/workflows/deploy.yml)
             Her main push → otomatik Netlify deploy (~1.5 dk)

Repo:        github.com/ataabeeyzaa/the-house-of-anatolia (private)

CDN:         https://esm.sh/@supabase/supabase-js@2 (Supabase client)
             https://fonts.googleapis.com (fonts)
```

**Karar:** Build step yok — vitrin sitesi, tüm CSS+JS HTML içinde inline. Netlify minify otomatik.

---

## Deploy Pipeline

```
Lokal → git push origin main → GitHub Actions →
  └─ npx netlify-cli deploy --prod (NETLIFY_AUTH_TOKEN secret)
      └─ Netlify CDN edge → canlı (~90-120s)
```

### GitHub Secrets
- `NETLIFY_AUTH_TOKEN` — Production CI/CD (1 yıl, 2027-05-08'e kadar)
- `NETLIFY_SITE_ID` — `6353f35a-2af2-4c3d-872e-438e4368dc35`

---

## Plugin / MCP Envanteri

**18 Claude Code plugin + 2 MCP server**

### Marketplaces
1. `claude-code-plugins` (anthropics/claude-code) — 4 plugin
2. `claude-plugins-official` (anthropics/claude-plugins-official) — 12 plugin
3. `superpowers-marketplace` (obra/superpowers-marketplace) — 2 plugin

### Plugin Listesi (18)
frontend-design, code-review, feature-dev, security-guidance, superpowers, claude-session-driver, chrome-devtools-mcp, claude-code-setup, claude-md-management, code-simplifier, context7, csharp-lsp, playwright, pr-review-toolkit, pyright-lsp, serena, skill-creator, supabase

### MCP Servers
1. **supabase** — read-only mode, `--project-ref=owcgcyvgibyawxfxwlbn`
2. **chrome-devtools-mcp** — browser automation (yeni session'da aktif)

---

## Dosya Yapısı (detay)

| Dosya | Boyut yaklaşık | İçerik |
|---|---|---|
| `index.html` | ~3300 satır, ~210 KB | Anasayfa: minimal navbar (logo + ☰ hamburger + lang) + hamburger overlay menü, hero, harita, KEŞFET, **marquee strip (Supabase fetch + statik fallback)**, hakkımızda, **Ürünler section (Supabase küçük kart vitrini)**, **contact 2-col (3 info kart sol + newsletter card sağ — sade, başlık yok)**, footer 4-col + Supabase data layer + i18n |
| `product.html` | ~1700 satır, 80 KB | Ürün detay + talep formu (Supabase + FormSubmit dual) |
| `products.html` | ~280 satır, ~12 KB | **Yeni** — Ürünler vitrini, Supabase fetch is_active=true, grid layout |
| `admin.html` | ~4750 satır, ~175 KB | Tek-sayfa admin panel (paket CRUD silindi; Şerit/marquee CRUD eklendi PR #7) |
| `gizlilik.html`, `kullanim.html`, `cerez.html` | toplam ~50 KB | Yasal skeletonları (12 placeholder) |
| `robots.txt` | 8 satır | SEO crawl + sitemap referansı + admin disallow |
| `sitemap.xml` | 50 satır | 6 URL + TR/EN hreflang |
| `assets/` | 18 dosya, 3.4 MB | Logo, safran görselleri, galeri |

---

## Veritabanı Şeması (15 tablo)

`cities`, `products`, `product_parts`, `usage_steps`, `gallery_images`, `product_options`, `package_options` (UI kullanmıyor), `weight_options`, `homepage_sections`, `site_settings`, `requests`, `admins`, `admin_audit_log`, `newsletter_subscribers`, `page_views`, **`marquee_items` (PR #7 — anasayfa kayan şerit, kullanıcı SQL Editor'dan migration çalıştırır)**.

### `admins` tablosu — DİKKAT
```sql
id          uuid (gen_random_uuid)
user_id     uuid → auth.users.id (FK)
full_name   text NOT NULL          -- yeni admin eklerken zorunlu
email       text NOT NULL
role        text DEFAULT 'admin'
is_active   boolean DEFAULT true
```

### Yeni admin SQL
```sql
insert into public.admins (user_id, email, full_name)
select u.id, u.email, 'Tam İsim'
from auth.users u
where u.email = 'admin@example.com'
  and not exists (select 1 from public.admins a where a.user_id = u.id);
```

### `products` tablosu — products.html için anahtar
products.html `loadProducts` query'sinde `.eq("is_active", true)` filter ile sadece canlı ürünler gösterilir. Yakında olanlar admin'den `is_active=false` ile eklenince gizli kalır.

Kolonlar: `id, city_id, name, name_en, slug, short_name, mini_image, hero_image, meta_description, is_active, ...`

---

## Veri Akışları

### Talep Formu (product.html)
1. Form submit → `requests` tablosuna INSERT
2. `package_option_id` artık gönderilmiyor (paket seçimi kaldırıldı)
3. Honeypot (`website` field) DB trigger ile reddediliyor
4. Rate limit: 3/email/dakika
5. Paralel FormSubmit.co'ya da gönderilir (mail fallback)

### Newsletter (footer)
1. Form submit → `newsletter_subscribers` INSERT
2. Lowercase + null IP/UA (sanitize trigger)
3. Rate limit: 3/email/5dk

### Admin Login
1. Supabase Auth `signInWithPassword`
2. `is_admin()` RPC çağrılır
3. Idle timeout 15dk, brute force lockout 5×

### Page Tracking
1. requestIdleCallback ile `page_views` INSERT
2. 30 dakika sessionStorage dedup
3. Device type, referrer (sadece hostname), IP saklanmıyor (KVKK)

### Products Page Fetch (yeni)
1. products.html script type=module → Supabase client
2. `.from("products").select(...).eq("is_active", true).order("created_at")`
3. Render: grid card → `product.html?slug=...` link

---

## Frontend Mimarisi (güncel)

### Tipografi
```css
--font-serif: 'Cormorant Garamond', serif;       /* Display, italic */
--font-sans:  'Plus Jakarta Sans', sans-serif;   /* Body */
font-feature-settings: "ss01","cv11","liga","dlig","kern";
```

### Atmospheric Layer (body::after)
```css
body::after {
  position: fixed; inset: 0;
  background: SVG fractalNoise data URL;
  opacity: 0.035;
  mix-blend-mode: overlay;
}
```

### Sparkle Effect — KALDIRILDI (PR #6)
- index.html'de tüm sparkle CSS+HTML+JS silindi (kullanıcı net karar)
- Yasaklar listesinde tüm varyantlar (üstünde/etrafında/arkasında) — bkz. DESIGN_SYSTEM
- product.html'deki `.hero-blossom-layer` rule mini-blossom safran çiçeği için kapsayıcı, KORUNUR

### Hamburger menü (PR #7 — Aesop pattern)
- Navbar yatay nav-links kaldırıldı; sağ üstte `.nav-toggle` button (☰ → X) + lang switcher
- `.nav-overlay` fullscreen, radial gold glow + blur backdrop, 450ms fade-in/out
- Overlay içeriği: SAYFALAR (Ana Sayfa / Hakkımızda / İletişim) + ÜRÜNLER (Tüm Ürünler + Supabase dinamik liste) + yasal linkler + lang switcher
- Body scroll lock (`body.nav-open`); ESC + backdrop click + `[data-nav-close]` link → kapanır
- `.nav-overlay-products-list` languagechange event'inde label_tr/label_en arası swap

### Anasayfa Ürünler section (PR #7)
- `<section id="products">` about ile contact arasına
- `.products-grid auto-fit minmax(220px, 1fr)` küçük kart vitrini
- `.product-card` 18px radius, panel-soft bg, hover gold border + image scale
- Görsel: aspect-ratio 16/10
- Fetch: `loadHomeProducts()` → products is_active=true + cities embed, limit 8
- "Tümünü Gör →" linki `/products.html`'e

### Marquee Strip (PR #7 — dinamik fetch + statik fallback)
- `.marquee-strip` — section'lar arası, full-width
- `.marquee-track` — `display:flex; width:max-content; animation:marqueeScroll 38s linear infinite`
- `@keyframes marqueeScroll` — `translateX 0 → -50%` (sağdan sola)
- Her item ✦ ayraçlı (`.marquee-item::before{content:'✦'}`)
- 5 yakında ürün × 2 (duplicate seamless loop için)
- i18n keys: `marquee_1` … `marquee_5` (TR + EN)
- prefers-reduced-motion saygılı

### Eyebrow (KEŞFET, HİKÂYEMİZ vb.)
- `.eyebrow{display:flex; align-items:center; gap:12px}`
- `.eyebrow::before, .eyebrow::after{content:''; width:38px; height:1px; background:rgba(210,161,47,.72)}` — **iki yanda altın çizgi**

### Contact Card (PR #6 — 2-col: 3 info kart + newsletter)
- `display:grid; grid-template-columns:1.05fr 1fr; gap:64px; align-items:start`
- max-width: var(--max) (1320px container içinde)
- **SOL:** `<div class="contact-info-col">` → `.contact-intro-block` (eyebrow + title + intro) + `<ul class="contact-info-stack">` (3 `.contact-info-card`: SVG ikon + label/value)
- **SAĞ:** `<div class="contact-newsletter-card">` — radial gold glow gradient + form id `newsletter-form` + status `newsletter-status` (Supabase JS handler aynen çalışır, dokunulmadı)
- Mobile (<980px): tek sütun fallback
- Mobile (<540px): newsletter form column-stack, button full-width

### Footer (PR #6 — newsletter taşındı)
- `.footer-top` + `.footer-newsletter` HTML/CSS tamamen silindi
- Footer-grid 4-col layout (1.8fr 1fr 1fr 1.4fr) AYNEN korundu: brand + sayfalar + yasal + iletişim mini
- i18n keys `footer_newsletter_*` korundu (rename gereksiz, sadece konum değişti)

### Custom Scrollbar
```css
* { scrollbar-width: thin; scrollbar-color: rgba(210,161,47,.45) rgba(20,15,10,.4); }
*::-webkit-scrollbar-thumb { gold gradient; }
```

### Mobile Breakpoints
- `<480px` extra small
- `<540px` newsletter form column-stack (button full-width)
- `<640px` small (footer 1fr 1fr → brand col-span)
- `<760px` medium
- `<980px` contact 2-col → 1-col + tablet
- `<1180px` large tablet
- `<1600px` ultra-wide (container padding 80px)

---

## SEO / A11y (PR #1)

### SEO altyapı
- `robots.txt`: sitemap referansı + admin.html disallow
- `sitemap.xml`: 6 URL (anasayfa, ürünler, ürün detay, 3 yasal) + TR/EN hreflang
- index.html JSON-LD: Organization + WebSite (CollectionPage products.html)
- product.html JSON-LD: Product + BreadcrumbList
- canonical + hreflang tüm sayfalarda

### A11y
- Skip-to-main link (3 ana sayfada)
- `<main id="main-content">` wrapper
- WCAG 2.4.1 (Bypass Blocks) uyumlu
- Lighthouse: A11y 98 / SEO 92 / Best Practices 96 / Agentic 100

---

## Güvenlik

- RLS tüm tablolarda aktif
- Anon key public ama RLS koruması
- Honeypot + sanitize trigger + rate limit
- SECURITY DEFINER fonksiyonlar `set search_path = public`
- IP saklanmıyor (KVKK)
- Storage SVG yasak (XSS)

---

## Test Stratejisi

**Manuel:**
- Form submit (gerçek email)
- Newsletter signup (artık contact section'da, footer'da DEĞİL)
- Admin login + CRUD (ürün, şehir, galeri)
- TR/EN switch
- Mobile responsive (DevTools + gerçek telefon)
- Custom cursor desktop, touch device
- Marquee strip kayıyor mu
- products.html sadece is_active=true mı
- Contact 3-card hover gold border + newsletter form submit

**Otomatik (yeni session'da):**
- `chrome-devtools-mcp` ile Chrome browser test (lighthouse_audit, take_screenshot)
- `playwright` plugin ile E2E
- `curl` ile canlı HTML doğrulaması (deploy verify)
