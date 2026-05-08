# ARCHITECTURE — The House of Anatolia

> **Teknik mimari (2026-05-08 güncel)**: stack, deploy pipeline, plugin envanteri, veritabanı şeması ve veri akışları.

---

## 🏗️ Teknoloji Stack'i

```
Frontend:    Vanilla HTML + CSS + ES Modules (build step yok)
Tipografi:   Plus Jakarta Sans (body) + Cormorant Garamond (display)
             Google Fonts CDN, swap display

Backend:     Supabase (PostgreSQL + Auth + Storage + RLS)
             URL: https://owcgcyvgibyawxfxwlbn.supabase.co

Hosting:     Netlify (Production CDN, edge cached)
             URL: https://house-of-anatolia.netlify.app

CI/CD:       GitHub Actions (.github/workflows/deploy.yml)
             Her main branch push → otomatik Netlify deploy
             Build süresi ~1.5 dakika

Repo:        github.com/ataabeeyzaa/the-house-of-anatolia (private)

CDN:         https://esm.sh/@supabase/supabase-js@2 (Supabase client)
             https://fonts.googleapis.com (fonts)
```

**Karar:** Build step yok çünkü vitrin sitesi. Tüm CSS+JS HTML içinde inline. Performance edge cached + minify Netlify'dan otomatik.

---

## 🚀 Deploy Pipeline

```
Lokal → git push origin main → GitHub Actions tetikleniyor →
  └─ npx netlify-cli@latest deploy --prod (NETLIFY_AUTH_TOKEN secret ile)
      └─ Netlify CDN edge → site canlıda
```

### GitHub Secrets (kayıtlı)
- `NETLIFY_AUTH_TOKEN` — Production CI/CD token (1 yıl, 2027-05-08'e kadar geçerli)
- `NETLIFY_SITE_ID` — `6353f35a-2af2-4c3d-872e-438e4368dc35`

### Manual Deploy (gerekirse)
```bash
npx netlify-cli deploy --prod --dir . --auth $TOKEN --site $SITE_ID
```

---

## 🔌 Plugin / MCP Envanteri

**Toplam: 18 Claude Code plugin + 2 MCP server**

### Marketplaces (3 adet)
1. `claude-code-plugins` (anthropics/claude-code) — 4 plugin
2. `claude-plugins-official` (anthropics/claude-plugins-official) — 12 plugin
3. `superpowers-marketplace` (obra/superpowers-marketplace) — 2 plugin

### Plugin Listesi
| Plugin | Kaynak | Kullanım |
|---|---|---|
| frontend-design | claude-code-plugins | UI/UX redesign skills |
| code-review | claude-code-plugins | Code review workflow |
| feature-dev | claude-code-plugins | Feature development planning |
| security-guidance | claude-code-plugins | Security best practices |
| superpowers (5.1.0) | superpowers-marketplace | TDD, debugging, brainstorming |
| claude-session-driver | superpowers-marketplace | Session management |
| chrome-devtools-mcp | claude-plugins-official | Real Chrome browser automation |
| claude-code-setup | claude-plugins-official | Setup helpers |
| claude-md-management | claude-plugins-official | CLAUDE.md tooling |
| code-simplifier | claude-plugins-official | Code refactoring |
| context7 | claude-plugins-official | Library docs (MCP) |
| csharp-lsp | claude-plugins-official | C# LSP (bu projede gerekli değil) |
| playwright | claude-plugins-official | E2E testing (MCP) |
| pr-review-toolkit | claude-plugins-official | PR review |
| pyright-lsp | claude-plugins-official | Python LSP |
| serena | claude-plugins-official | Code analysis |
| skill-creator | claude-plugins-official | Custom skill creation |
| supabase | claude-plugins-official | Supabase plugin |

### MCP Servers (config: `~/.claude.json`)
1. **supabase** — read-only mode, `--project-ref=owcgcyvgibyawxfxwlbn`
2. **chrome-devtools-mcp** — browser automation tools (yeni session'da aktif)

---

## 📂 Dosya Yapısı (detay)

| Dosya | Boyut yaklaşık | İçerik |
|---|---|---|
| `index.html` | ~2700 satır, 200 KB | Ana sayfa: navbar, hero, harita, hakkımızda, iletişim, footer + Supabase data layer + i18n + sparkle effect |
| `product.html` | ~1700 satır, 80 KB | Ürün detay + talep formu (Supabase + FormSubmit dual) |
| `admin.html` | ~4800 satır, 168 KB | Tek-sayfa admin paneli + paket dead code |
| `gizlilik.html` | ~360 satır | KVKK skeleton, 5 placeholder |
| `kullanim.html` | ~225 satır | Terms skeleton, 7 placeholder |
| `cerez.html` | ~210 satır | Cookie policy (placeholder yok) |
| `supabase_schema_v2_fixed.sql` | ~55 KB | Referans şema (DB'de çalıştırılan ilk versiyondan) |
| `assets/` | 18 dosya, 3.4 MB | Logo, safran görselleri, galeri |
| `.github/workflows/deploy.yml` | 25 satır | Auto-deploy workflow |
| `.claude/launch.json` | 9 satır | Preview server config |

---

## 🗄️ Veritabanı Şeması (değişmedi, 14 tablo)

`cities`, `products`, `product_parts`, `usage_steps`, `gallery_images`,
`product_options`, `package_options` (artık UI'da kullanılmıyor),
`weight_options`, `homepage_sections`, `site_settings`,
`requests` (talepler, honeypot+rate limit+sanitize trigger),
`admins` (full_name kolonu NOT NULL — yeni admin eklerken dikkat!),
`admin_audit_log`, `newsletter_subscribers`, `page_views`.

### `admins` tablosu — DİKKAT
```
id          uuid (gen_random_uuid)
user_id     uuid → auth.users.id (FK, nullable)
full_name   text NOT NULL  ← **yeni admin eklerken zorunlu**
email       text NOT NULL
role        text DEFAULT 'admin'
is_active   boolean DEFAULT true
created_at  timestamptz DEFAULT now()
updated_at  timestamptz
```

### Yeni admin ekleme SQL
```sql
insert into public.admins (user_id, email, full_name)
select u.id, u.email, 'Tam İsim'
from auth.users u
where u.email = 'email@example.com'
  and not exists (select 1 from public.admins a where a.user_id = u.id);
```

Detay: HANDOFF.md eski sürümlerinde + admins tablosunda zaten kayıtlı (Beyza Ata + The House of Anatolia)

---

## 🔄 Veri Akışları

### Talep Formu (product.html)
1. Form submit → Supabase `requests` tablosuna INSERT
2. **payload:** product_id, city_id, product_option_id, weight_option_id, full_name, email, phone, message, vb.
3. ⚠️ **package_option_id artık gönderilmiyor** (paket seçimi kaldırıldı)
4. Honeypot (`website` field) DB trigger ile reddediliyor
5. Rate limit: 3/email/dakika
6. Paralelde FormSubmit.co'ya da gönderilir (mail fallback)

### Newsletter (footer)
1. Form submit → `newsletter_subscribers` INSERT
2. Lowercase + null IP/UA (sanitize trigger)
3. Rate limit: 3/email/5dk

### Admin Login
1. Supabase Auth signInWithPassword
2. `is_admin()` RPC çağrılır (admins tablosunda user_id eşleşiyor mu)
3. Idle timeout 15dk, brute force lockout 5×

### Page Tracking
1. requestIdleCallback ile sayfa yüklendiğinde `page_views` INSERT
2. 30 dakika sessionStorage dedup
3. Device type (mobile/tablet/desktop), referrer (sadece hostname)
4. **IP saklanmıyor** (KVKK uyum)

---

## 🎨 Frontend Mimarisi (yeni)

### Tipografi
```css
--font-serif: 'Cormorant Garamond', serif;       /* Display, italic accents */
--font-sans:  'Plus Jakarta Sans', sans-serif;   /* Body */
font-feature-settings: "ss01","cv11","liga","dlig","kern";
```

### Atmospheric Layer
```css
body::after {
  position: fixed; inset: 0;
  background: SVG fractalNoise (data URL);
  opacity: 0.035;
  mix-blend-mode: overlay;
}
```

### Sparkle Effect (gold sim)
```js
// Map alanında periyodik random spawn
// 3px altın nokta + 4-yön ışın saçılması (pseudo elements)
// scale 0→1.3→1→0.4 + rotate 0→135deg + drift -18px
// Spawn 350ms aralıkla, her sparkle 1.6-3.8s yaşıyor
```

### Custom Scrollbar
```css
* { scrollbar-width: thin; scrollbar-color: gold/dark; }
*::-webkit-scrollbar-thumb { gold gradient; }
```

### Mobile Breakpoints
- `<480px` — extra small (font sizes, container 16px padding, navbar 64px)
- `<640px` — small (footer 1-col stack, contact list dikey)
- `<760px` — medium (about narrative paragraf scaling)
- `<980px` — tablet (asymmetric grids → 1fr, map-branding static)
- `<1180px` — large tablet (about-grid → 1fr)
- `<1600px` — ultra-wide (container padding 80px)

---

## 🔐 Güvenlik (değişmedi)

- RLS tüm tablolarda aktif
- Anon key public ama RLS koruması
- Honeypot + sanitize trigger + rate limit
- SECURITY DEFINER fonksiyonlar `set search_path = public`
- IP saklanmıyor (KVKK)
- Storage SVG yasak (XSS)

---

## 🧪 Test Stratejisi

**Manuel:**
- Form submit (gerçek email)
- Newsletter signup
- Admin login + CRUD
- TR/EN switch
- Mobile responsive (DevTools + gerçek telefon)
- Custom cursor desktop, touch device

**Yeni session'da otomatik:**
- `chrome-devtools-mcp` ile gerçek Chrome browser test
- `playwright` plugin ile E2E
