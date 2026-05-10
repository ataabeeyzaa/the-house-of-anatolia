# HANDOFF — The House of Anatolia

> **2026-05-10 güncel (PR #17 sonrası)** — projenin tam haritası, yeni Claude Code sohbetine geçişte gerekli tüm bağlam.

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
| **Production** (custom domain) | **https://thehouseofanatolia.com** |
| Anasayfa | https://thehouseofanatolia.com/ |
| Ürünler vitrini | https://thehouseofanatolia.com/products.html |
| Ürün detayı | /product.html?slug=karabuk-safrani |
| Admin paneli (Cloudflare Access korumalı) | /admin.html |
| Yasal sayfalar | /gizlilik.html, /kullanim.html, /cerez.html |
| robots.txt | /robots.txt |
| sitemap.xml | /sitemap.xml |
| GitHub repo (**PUBLIC**) | https://github.com/ataabeeyzaa/the-house-of-anatolia |
| Supabase project | https://supabase.com/dashboard/project/owcgcyvgibyawxfxwlbn |
| Cloudflare Zero Trust | https://one.dash.cloudflare.com → Access → Applications → Admin Panel |

**Hosting:** GitHub Pages (sınırsız bandwidth/build, ücretsiz). **Netlify SİLİNDİ** (PR #11+#14'te taşındık — credit limit + private repo contributor sorunu).

---

## Dosya Yapısı

```
/
├── index.html                       ← Anasayfa: navbar [☰ logo] [4 yatay link] [TR EN] + hamburger overlay + harita (sparkle YOK) + marquee dinamik (Supabase fetch + statik fallback) + hakkımızda + contact 2-col (3 info kart sol + newsletter card sağ, başlık yok) + footer 4-col
├── product.html                     ← Ürün detay + galeri (gallery_images dinamik kayan şerit) + talep formu (Supabase + FormSubmit) — mini-blossom safran çiçeği KORUNUR — navbar hamburger + Haritaya Dön/Teklif Al butonları
├── products.html                    ← Ürünler vitrini (auto-fill 240px sabit küçük kart grid, tek ürün de küçük ortalanır)
├── admin.html                       ← Admin panel (paket CRUD silindi, ürün/şehir/galeri/Şerit CRUD aktif) — Cloudflare Access korumalı
├── gizlilik.html, kullanim.html, cerez.html  ← Yasal sayfalar (placeholder dolacak)
├── robots.txt                       ← SEO crawl rules (admin disallow)
├── sitemap.xml                      ← 6 URL + TR/EN hreflang (thehouseofanatolia.com)
├── CNAME                            ← thehouseofanatolia.com (GitHub Pages custom domain)
├── .nojekyll                        ← GitHub Pages Jekyll bypass (vanilla HTML site)
├── supabase_schema_v2_fixed.sql     ← İlk şema (referans)
├── supabase_migrations/
│   ├── 2026-05-08-marquee-items.sql       ← Tablo + RLS + 5 default row
│   ├── 2026-05-09-marquee-grants.sql      ← anon/authenticated GRANT
│   └── 2026-05-09-marquee-sort-renumber.sql  ← (opsiyonel) 10/20/30 → 1/2/3
├── assets/                          ← 18 dosya, 3.4 MB
├── .claude/launch.json              ← Claude Code preview config
├── .claude/mockups/                 ← 6 frontend-design concept (gitignore'da)

DOKÜMANTASYON:
├── HANDOFF.md           ← Bu dosya
├── ARCHITECTURE.md      ← Stack, deploy (GitHub Pages + Cloudflare), plugin envanteri, DB şema
├── DESIGN_SYSTEM.md     ← Renk + tipografi + pattern'ler + yasaklar
├── KNOWN_ISSUES.md      ← Kalan işler, sınırlamalar
├── FIRST_PROMPT.md      ← Yeni Claude Code sohbeti için ilk prompt
└── docs/superpowers/specs/  ← brainstorming spec'leri (PR'lar öncesi onay dokümanı)
```

**Silinen dosyalar:** `.github/workflows/deploy.yml` (PR #11) — Netlify GitHub Actions deploy artık yok, GitHub Pages direkt main branch'a bakar.

---

## Backend — Supabase

**URL:** `https://owcgcyvgibyawxfxwlbn.supabase.co`
**Anon Key:** HTML'lerde tanımlı (public, RLS korumalı)
**15 tablo + Storage bucket** `product-assets` (5MB, SVG yasak)

Yeni tablo (PR #7-9): `marquee_items` (label_tr, label_en, sort_order, is_active) — 3 SQL migration kullanıcı tarafından çalıştırıldı.

Detay: ARCHITECTURE.md

---

## Hosting + DNS + Auth Stack

**Layer 1 — Hosting:** GitHub Pages
- Repo `ataabeeyzaa/the-house-of-anatolia` main branch → otomatik deploy (~1-2 dk)
- `.nojekyll` ile Jekyll bypass (vanilla HTML)
- `CNAME` dosyası → custom domain

**Layer 2 — DNS:** Cloudflare
- A records (apex `@`) → 185.199.108.153, .109.153, .110.153, .111.153 (GitHub Pages IPs)
- CNAME `www` → ataabeeyzaa.github.io
- Proxy: Turuncu bulut aktif (Cloudflare Access için şart)

**Layer 3 — TLS:** Let's Encrypt (GitHub Pages otomatik)
- HTTPS otomatik provision, HTTP → HTTPS redirect aktif

**Layer 4 — Admin Auth (Cloudflare Zero Trust Access):**
- Application: "Admin Panel" — domain `thehouseofanatolia.com`, path `/admin.html`
- Policy: "Admin Only" — Allow + Email selector: `thehouseofanatoliaco@gmail.com`, `beyzata37@gmail.com`
- Identity Provider: One-time PIN (email)
- Session duration: 24 saat
- **Sonuç:** rastgele biri admin.html açtığında HTML bile görmez, Cloudflare PIN ekranına gider; sadece allowed email'ler PIN onayı sonrası sayfayı yükleyebilir

**Layer 5 — Admin App Auth (Supabase):**
- supabase.auth.signInWithPassword (email + şifre)
- `admins` tablosu RLS — auth.uid() admins.user_id ile eşleşmeli + is_active=true
- 30dk idle logout, brute-force rate limit (3 deneme/sn)

---

## Yapılanlar (kronolojik)

### Phase 0 — Altyapı (önceki sohbet)
- GitHub private repo + Netlify deploy + GitHub Actions CI/CD
- 18 plugin + Supabase MCP + chrome-devtools-mcp
- Inter → Plus Jakarta Sans + Cormorant Garamond
- Reddedilen denemeler temizlendi (KÜNYE, cert-badge, stats bar, EST badge, cinematic hero)
- Atmospheric layer (SVG noise) + custom scrollbar + hover refinements

### Phase 1 — PR #1 (SEO + Cleanup + A11y)
- robots.txt + sitemap.xml + JSON-LD + canonical + product.html title fix
- Dead code temizliği (~360 satır)
- Skip-to-main link (WCAG 2.4.1)
- Lighthouse: **A11y 98 / SEO 92 / Best Practices 96 / Agentic 100**

### Phase 2 — PR #2 (Sparkle iter 1 + contact + footer)
- Sparkle yan-drift → statik dots; contact card border + radius

### Phase 3 — PR #3 (Sparkle removal + Products sayfası)
- Sparkle TAMAMEN kaldırıldı (kullanıcı net karar)
- Yeni `products.html` Supabase fetch

### Phase 4 — PR #4 (Sparkle re-add iter + Map section + Contact)
- Sparkle harita arkasına geri eklendi (sonra PR #6'da yine kaldırıldı)
- Marquee strip eklendi (statik 5 ürün)
- Contact card horizontal 2-col

### Phase 5 — PR #6 (Sparkle FİNAL removal + Contact rebuild + Footer newsletter taşıma)
- Sparkle TÜM VARYANTLAR kaldırıldı + yasaklar listesine
- Contact 2-col layout: SOL (eyebrow + title + intro + 3 info kart) + SAĞ (newsletter card)
- Footer newsletter contact'a taşındı; footer-grid 4-col aynen kaldı

### Phase 6 — PR #7 (Hamburger + Ürünler section + Marquee admin + product refresh)
- Hamburger menü Aesop pattern (yatay nav kaldırıldı, fullscreen overlay)
- Anasayfa Ürünler section (sonra PR #8'de tamamen kaldırıldı)
- Marquee `marquee_items` tablo + admin "Şerit" sekmesi CRUD
- product.html: "Karabük'ün" → "Safranbolu'nun" GI cümleleri

### Phase 7 — PR #8 (UI revize + Galeri render + Marquee permission fix)
- **Navbar restore:** yatay nav linkleri (Ana Sayfa / Hakkımızda / Ürünler / İletişim) GERİ; hamburger ☰ EN SOLA, lang sağda
- Anasayfa Ürünler section TAMAMEN kaldırıldı (kullanıcı isteği)
- products.html küçük kare grid (auto-fill 240px sabit)
- Marquee permission migration v2 (anon/authenticated GRANT'ler)
- product.html galeri statik HTML kaldırıldı, dinamik gallery_images render

### Phase 8 — PR #9 (Marquee infinite + admin sort + mobil + boşluk)
- Marquee min kopya formülü `Math.ceil(10/data.length)` × 2 → 1 item bile sürekli akar
- Admin Şerit sort_order default = max+1 (1, 2, 3 ardışık)
- Marquee → about arası ◆ silindi
- Mobile product.html hero padding küçültüldü + html overflow-x:hidden

### Phase 9 — PR #10 (Çoklu UI fix + DB-bağ + email + domain notu)
- Map section "KEŞFET" eyebrow kaldırıldı
- city_note başına "Coğrafi işaret:" prefix
- About → contact arası ◆ silindi
- E-posta tüm yerlerde: `info@...` → **`thehouseofanatoliaco@gmail.com`**
- Adres tüm yerlerde: `Safranbolu, Karabük / Türkiye` → **`Türkiye`**
- Page tracking URL validation (file://, data:, /C:/ filtreleri)
- Admin "Gelen Teklif" → Sil butonu (confirmAction + audit log)
- product.html navbar hamburger + overlay (BU SAYFADA + ÜRÜNLER kategorileri)
- loadHomepageAbout: anasayfa #about title/subtitle/content homepage_sections'tan override

### Phase 10 — PR #11-13 (Hosting hazırlık + deploy trigger)
- PR #11: `.github/workflows/deploy.yml` SİLİNDİ (Netlify GitHub Actions yok artık)
- PR #12, #13: deploy trigger commits (.gitignore temp file pattern'leri)

### Phase 11 — PR #14 (GitHub Pages migration — Netlify → GitHub Pages)
- **Hosting taşındı:** Netlify credit limit + private repo contributor sorunu nedeniyle GitHub Pages'e
- CNAME dosyası: `thehouseofanatolia.com`
- .nojekyll dosyası
- Tüm URL'ler `house-of-anatolia.netlify.app` → `thehouseofanatolia.com`:
  - HTML JSON-LD (Organization + WebSite + Product + BreadcrumbList + canonical + og/twitter)
  - robots.txt (Sitemap URL)
  - sitemap.xml (6 URL + hreflang)
  - 3 MD docs

### Phase 12 — PR #15 (Security hardening — defensive .gitignore)
- Repo public yapıldıktan sonra defensive savunma katmanı
- `.env`, `.env.*`, `*.env` ignore (Supabase service_role + DB şifreleri için tipik konum)
- `*.pem`, `*.key`, `*.p12`, `*.pfx` (sertifika)
- `id_rsa*`, `id_dsa*` (SSH keys)
- `secrets.json/yml`, `service-account*.json` (cloud auth)
- Git history taraması: 0 hit (service_role, postgres://, DATABASE_PASSWORD, nfp_)

### Phase 13 — PR #16 + PR #17 (Cloudflare Access + client gate revert)
- PR #16: client-side admin gate eklendi (URL ?giris param check) — sonra revert
- PR #17: gate revert — Cloudflare Access dış katmanı yeterli, gate Cloudflare PIN sonrası akışı bozuyordu
- **Cloudflare Zero Trust Access** aktif: admin.html erişimi sadece allowed email'lere PIN onayı sonrası

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
- **Map'in altında kayan şerit** (marquee dinamik — Supabase fetch, kullanıcı admin'den yönetir)
- Mini-blossom safran çiçeği (product.html — dokunulmaz)
- **Contact 3 info kart sol + newsletter card sağ (sade — başlık/intro yok)** (PR #6+#7+#8)
- **Hamburger menü ☰ EN SOLDA + yatay 4 nav link** (PR #8) — tıklayınca fullscreen overlay (SAYFALAR + ÜRÜNLER + yasal linkler)
- **Coğrafi işaret tanımı** map section altında prefix ile (PR #10)

### Reddettiği
- Stats bar 1/1/1 sayım kartları → "ucuz duruyor"
- KÜNYE bilgi kartı → "ucuz duruyor"
- Sertifika rozeti (TPMK) → "ucuz duruyor"
- EST 2026 — ANATOLIA badge
- 3-sütun yan yana dikey adres/telefon/eposta (kart yığını OK ama yan yana 3 sütun değil)
- Cinematic hero (büyük dağ silüetleri)
- **Sparkle / gold-sim parçacıklar — TÜM VARYANTLAR** (üstünde, etrafında, ARKASINDA — hiçbir konumda kabul edilmiyor; PR #6'da tamamen kaldırıldı)
- KEŞFET eyebrow (PR #10'da kaldırıldı, eyebrow çift altın çizgi pattern'i başka yerlerde devam)
- Anasayfa Ürünler section (PR #8'de tamamen kaldırıldı; ürünler /products.html ayrı sayfada)
- Anasayfa contact section'da başlık/intro (PR #8'de sadeleştirildi, sadece 3 kart kaldı)

### Karar Verilmiş Kararlar (değiştirme!)
- Site alacak kişi için yapılıyor (Beyza geliştirici, ortak içerik girer)
- E-ticaret niyeti var ama **şirket kurulmadan satış olmaz** — şu an "talep formlu vitrin"
- Bilingual TR + EN
- Custom cursor: KORUNACAK (desktop pointer:fine, mobil yok)
- Slug `karabuk-safrani` DEĞİŞMEYECEK
- Renk palette: koyu + altın + krem (başka renk YASAK)
- Inter / Roboto / Arial / system fonts YASAK
- Force push YASAK (`--force`, `--force-with-lease` kullanma)
- `--no-verify` YASAK
- Push öncesi `git fetch origin main && git rebase origin/main` istisnasız
- **REPO PUBLIC** — credential, secret, .env asla commit etme
- **Supabase Service Role Key ASLA isteme** (anon key + RLS yeter)
- **Netlify token gibi credential KULLANICIDAN İSTEME** — sohbete yapıştırırsa derhal revoke ettirme talimatı
- E-posta: `thehouseofanatoliaco@gmail.com` (her yerde, info@... eski)
- Adres: `Türkiye` (sadeleştirilmiş, eski "Safranbolu, Karabük / Türkiye" değil)

---

## Kalan İşler (özet)

### P0 (kullanıcı yapacak — yayın öncesi kritik)
- [ ] Telefon numarası gerçek olsun (+90 5XX XXX XX XX placeholder, footer + contact + product)
- [ ] Yasal sayfa placeholder'ları (12+ yer: ŞİRKET ADI, VERGİ NO, MERSİS, ADRES, TEL — KVKK için şirket kurulması gerekli)
- [ ] Admin user oluşturma (Supabase Auth → admins tablosu — full_name NOT NULL)
- [ ] Anasayfa hikayemiz (about) içeriğini admin'den düzenle (PR #10 yeni özellik)
- [ ] Vision row'unu admin "Ana Sayfa Bölümleri"nden sil (anasayfada gösterilmiyor)

### P1 (sonradan)
- [ ] EN içerikleri admin panelden doldur (`name_en`, `description_en` vb.)
- [ ] Newsletter SMTP (50+ abone — Brevo/Resend entegrasyonu)
- [ ] Performance: image lazy loading audit, font subsetting (Cormorant büyük)
- [ ] Lighthouse re-audit (PR #10-17 sonrası ölçülmedi)

### P2 (cleanup)
- [ ] CSS dead code: `.future-pill`, `.future-list`, `.contact-footer-col`, `.contact-centered`
- [ ] DB'de `package_options` tablosu (UI kullanmıyor)
- [ ] eski `index_supabase.html` referansları (varsa)

Detay: KNOWN_ISSUES.md

---

## Geliştirme Akışı

### Local Test
- `.claude/launch.json` ile Claude Preview otomatik açılıyor (port 8080 ana repo, port 8081 worktree)
- Mobil viewport: `preview_resize preset:mobile` (375x812)

### Git Workflow
- Her main push → **GitHub Pages otomatik deploy** (~1-2 dk; build minute limiti yok)
- Branch (`claude/...`) → `gh pr create` → review → `gh pr merge --rebase --delete-branch`
- Worktree main check-out'lu olduğu için `gh pr merge` lokal switch yapamaz: `gh api -X PUT repos/.../pulls/N/merge -f merge_method=rebase` kullan
- **Push öncesi:** `git fetch origin main && git rebase origin/main`
- Force push + `--no-verify` YASAK
- 17 PR mergede tamamlandı

### gh CLI
- Path: `"/c/Program Files/GitHub CLI/gh.exe"` (Bash'ten çağırmak için tam path gerekli, PATH'da yok)

---

## Domain & Şirket Durumu

| Konu | Durum |
|---|---|
| Domain | ✅ thehouseofanatolia.com — Cloudflare Registrar (ücretsiz transfer/renewal Cloudflare yıllık) |
| HTTPS | ✅ Let's Encrypt (GitHub Pages otomatik) |
| Cloudflare proxy | ✅ Aktif (turuncu bulut) — Zero Trust için şart |
| Cloudflare Access | ✅ Admin Panel app + Admin Only policy aktif (2 email allowed) |
| Şirket | ❌ Kurulmadı |
| Sanal POS | ❌ Yok |
| KVKK | ⚠️ Skeleton hazır, şirket kurulmadan tamamlanamaz |

---

## Erişim Bilgileri (kullanıcı tarafında)

- **GitHub:** ataabeeyzaa
- **Email (admin + Cloudflare):** thehouseofanatoliaco@gmail.com (ortak hesap)
- **Email (Beyza):** beyzata37@gmail.com (Cloudflare Access ikinci allowed)
- **Supabase:** GitHub login (Beyza)
- **Cloudflare:** beyzata37 hesabı
- **Eski Netlify hesabı:** kapatılabilir (artık kullanılmıyor)

---

## Aesthetic Direction

**"Editorial Heritage — Anatolian terroir meets refined modernism"**

- Bold color discipline: koyu zemin + altın + krem — hiçbir başka renk yok
- Typography: Cormorant Garamond display + Plus Jakarta Sans body
- Atmospheric depth: SVG noise overlay, radial gradients (sparkle KALDIRILDI — PR #6)
- Motion polish: reveal animations, hover surprises, marquee strip kayan şerit
- Mobile-first: 375 → 480 → 540 → 760 → 980 → 1180 → 1600px
- prefers-reduced-motion saygısı
- "No AI slop": Inter, Roboto, Arial, Space Grotesk YASAK. Generic gradients YASAK. Predictable layouts YASAK.

Detay: DESIGN_SYSTEM.md
