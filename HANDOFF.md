# HANDOFF — The House of Anatolia

> Bu doküman projenin **2026-05-08 itibarıyla güncel durumunu** ve yeni Claude Code sohbetine geçişte gerekli tüm bağlamı içerir.

---

## 📋 Proje Özeti

**Marka:** The House of Anatolia
**Slogan (TR):** Lezzetin *Kökenine* Yolculuk
**Slogan (EN):** A Journey to the *Roots* of Taste
**Konsept:** Türkiye'nin coğrafi işaretli (GI) ürünlerini üreticisinden tüketiciye ulaştıran vitrin sitesi.
**Şu anki ürün:** Safranbolu Safranı (Karabük) — slug: `karabuk-safrani` (URL stabilitesi için değişmedi)
**Diller:** TR (varsayılan) + EN
**Estetik:** Editorial Heritage — refined modernism (Aesop / Hermès / Le Labo benzeri)

---

## 🌐 Canlı Site

| Bileşen | URL / Adres |
|---|---|
| **Production site** | https://house-of-anatolia.netlify.app |
| **Ürün sayfası** | /product.html?slug=karabuk-safrani |
| **Admin paneli** | /admin.html |
| **Yasal sayfalar** | /gizlilik.html, /kullanim.html, /cerez.html |
| **GitHub repo (private)** | https://github.com/ataabeeyzaa/the-house-of-anatolia |
| **Netlify dashboard** | https://app.netlify.com/projects/house-of-anatolia |
| **Supabase project** | https://supabase.com/dashboard/project/owcgcyvgibyawxfxwlbn |

---

## 🗂️ Dosya Yapısı

```
/
├── index.html                       ← Ana sayfa (eski: index_supabase.html, rename edildi)
├── product.html                     ← Ürün detay + talep formu
├── admin.html                       ← Admin panel (eski: admin_yeni_urun_duzeltilmis_v2.html)
├── gizlilik.html                    ← KVKK skeleton (placeholder dolacak)
├── kullanim.html                    ← Terms skeleton (placeholder dolacak)
├── cerez.html                       ← Cookie policy
├── supabase_schema_v2_fixed.sql     ← İlk şema (referans)
├── assets/                          ← 18 dosya (logo, safran görselleri, galeri)
│   ├── logo_house_of_anatolia_transparent.png
│   ├── safran-cicegi.png, safran_iplik.png, safran_soganli.png, vb.
│   └── resim1-6.jpg (galeri)
├── .github/workflows/deploy.yml     ← GitHub Actions auto-deploy (her push'ta Netlify)
├── .claude/launch.json              ← Claude Code preview server config
├── .gitignore                       ← .netlify, .claude, OS junk

DOKÜMANTASYON:
├── HANDOFF.md                       ← Bu dosya (ana belge)
├── ARCHITECTURE.md                  ← Teknik mimari, DB şema, akışlar
├── DESIGN_SYSTEM.md                 ← Renkler, fontlar, tasarım rehberi
├── KNOWN_ISSUES.md                  ← Yapılmamış işler, sınırlamalar
└── FIRST_PROMPT.md                  ← Yeni Claude Code sohbeti için ilk prompt
```

---

## 🔌 Backend — Supabase (değişmedi)

**URL:** `https://owcgcyvgibyawxfxwlbn.supabase.co`
**Anon Key:** HTML dosyalarında tanımlı, RLS koruması aktif
**14 tablo + Storage bucket** `product-assets` (5MB limit, SVG yasak)

Detay: ARCHITECTURE.md

---

## ✅ Yapılanlar — 20 Commit Geçmişi

### Altyapı
1. GitHub repo (private) kuruldu, gh CLI ile auth
2. Netlify deploy yapıldı (`house-of-anatolia.netlify.app`)
3. **GitHub Actions auto-deploy** workflow kuruldu (her push'ta Netlify'a deploy)
4. `index_supabase.html` → `index.html`, `admin_..._v2.html` → `admin.html` rename
5. Duplicate dosyalar silindi
6. `assets/` klasörü repo'ya commit edildi (18 dosya, 3.4 MB)
7. **Supabase MCP server** kuruldu (read-only, `~/.claude.json`'da)
8. **18 plugin** yüklendi (frontend-design, superpowers, chrome-devtools-mcp, playwright, context7, vb.)
9. Token rotation: yeni Netlify Production CI/CD token, eski Supabase token revoke edildi

### Tasarım — index.html
1. Cinematic hero (dağ silüetli) **product.html'den kaldırıldı**
2. Slogan'a italic gold accent: "Lezzetin *Kökenine* Yolculuk"
3. **Tipografi yenilendi:** Inter → **Plus Jakarta Sans** (tüm 6 HTML)
4. Cormorant Garamond display fontu korundu (italic ligature aktif)
5. Map section sadeleştirildi: gi-definition kaldırıldı, "discover-block" wrapper'da kompakt
6. Hakkımızda: asymmetric grid + KÜNYE kartı **denendi → kullanıcı reddetti → kaldırıldı**
7. Coğrafi İşaret rozet section **denendi → kullanıcı reddetti → kaldırıldı**
8. Hero stats bar (1 ürün/1 yöre/1 GI) **denendi → kullanıcı reddetti → kaldırıldı**
9. EST 2026 — ANATOLIA badge **denendi → kullanıcı reddetti → kaldırıldı**
10. **Contact section** yeniden tasarım: minimal centered card + key-value list (eski 3-sütun çirkindi)
11. **Footer 4-sütun yapı:** Brand (logo görseli) / Sayfalar / Yasal / İletişim
12. **Atmospheric layer:** SVG noise overlay (film grain, %3.5 opacity)
13. **Custom scrollbar:** thin gold gradient
14. **Hover refinements:** nav underline expand-collapse, focus rings, link transitions
15. **Mobile responsive:** slogan harita üstüne binmiyor, footer kompakt, <480px breakpoint
16. **Gold sparkle "sim" effect:** map alanında periyodik altın parlayan noktalar (✦)
17. **Paket Seçimi tamamen kaldırıldı** (product.html form + admin.html panel)

---

## 🎯 Kullanıcı Tercihleri (ÖNEMLİ — değiştirme!)

### İletişim Tarzı
- **Türkçe**, kısa, doğrudan
- "Salak mısın" gibi sert tepkiler frustrasyon ifadesi — **defensiveness yapma**, somut cevap ver, kanıtla
- Detaylı teknik açıklama ister ama **uzatma**

### Beğendiği
- Plus Jakarta Sans + Cormorant Garamond combo
- İtalik gold accent (zarif vurgu)
- Koyu zemin + altın aksanlar
- İnce çizgiler, boşluk hakimiyeti
- **Gold sparkle "sim" efekti** (map alanında parlayan noktalar)
- Mini-blossom safran çiçeği — product.html'de aktif

### Reddettiği
- Stats bar 1/1/1 sayım kartları → "ucuz duruyor"
- KÜNYE bilgi kartı (sticky aside) → "ucuz duruyor"
- Sertifika rozeti (TPMK) → "ucuz duruyor"
- EST 2026 — ANATOLIA badge
- 3-sütun dikey adres/telefon/eposta layout
- Cinematic hero (büyük dağ silüetleri)

### Karar Verilmiş Kararlar (değiştirme!)
- Site **alacak kişi için** yapılıyor (Beyza geliştirici, ortak içerik girer)
- E-ticaret niyeti var ama **şirket kurulmadan satış olmaz**
- Şu an "talep formlu vitrin" modeli
- Bilingual: TR + EN
- Custom cursor: KORUNACAK
- Slug `karabuk-safrani` DEĞİŞMEYECEK (URL stability)
- Renk palette değişmeyecek (koyu + altın + krem)

---

## ❌ Kalan İşler

### 🔴 Yayın Öncesi (kullanıcı yapacak)
- [ ] **Eski Netlify token revoke** (Authorized applications → Netlify CLI)
- [ ] **Yasal sayfa placeholder'ları** (12 yer): `[ŞİRKET ADI]`, `[VERGİ NO]`, `[MERSİS NO]`, `[ADRES]`, `[TELEFON]`, `[E-POSTA]`
- [ ] **Telefon numarası gerçek olsun** (index/product/footer'daki `+90 (5XX) XXX XX XX`)
- [ ] **Domain alma** (`thehouseofanatolia.com` Cloudflare ~$10/yıl)
- [ ] **Email Routing** Cloudflare ile `info@thehouseofanatolia.com` aktif
- [ ] **Admin user oluştur** Supabase Authentication → Users + SQL ile `admins` tablosuna ekle (full_name kolonu zorunlu)

### 🟡 Sonradan
- [ ] EN içerikleri admin panelden doldur
- [ ] SEO eklentileri: robots.txt, sitemap.xml, schema.org JSON-LD
- [ ] Google Search Console verification
- [ ] Newsletter SMTP (50+ abone olunca Resend + Edge Function)
- [ ] Performance: image lazy loading, font subsetting

### 🟢 Cleanup
- [ ] Admin.html'de paket CRUD JS dead code (~228 satır): `loadPackageOptions`, `renderPackageEditor`, `savePackageEdit`
- [ ] DB'de `package_options` tablosu (UI hiç kullanmıyor)
- [ ] CSS dead code: `.hero-grid`, `.hero-lines`, `.hero-dots`, `.hero-mountains` (eski cinematic hero stilleri)
- [ ] CSS dead code: `.gold-accent`, `.about-grid`, `.cert-badge`, `.hero-stats` (kaldırılmış elementlerin CSS'i)

---

## 🛠️ Geliştirme Akışı

### Local Test (Claude Preview)
- `.claude/launch.json` Python http.server 8080 ile config'lenmiş
- `preview_start anatolia` ile başlat
- Mobil viewport: `preview_resize preset:mobile` (375x812)
- Inspect/screenshot/console toolu mevcut

### Git Workflow
- Her push otomatik Netlify deploy (~1.5 dk)
- GitHub Actions: `.github/workflows/deploy.yml`
- Branch: `main` (master'dan rename edildi)
- **Push öncesi:** `git fetch origin main && git rebase origin/main`

### Önemli Komutlar
```bash
# Plugin/MCP listele
npx @anthropic-ai/claude-code plugin list
npx @anthropic-ai/claude-code mcp list

# Lokal preview
python -m http.server 8080
# veya .claude/launch.json üzerinden

# Test commit + push (auto-deploy tetikler)
git add -A && git commit -m "..." && git push
```

---

## 📞 Domain ve Şirket Durumu

| Konu | Durum |
|---|---|
| Domain alındı mı? | ❌ `thehouseofanatolia.com` müsait, alınmadı |
| Şirket kuruldu mu? | ❌ Kurulmadı |
| Sanal POS | ❌ Yok |
| Gıda işletme kayıt | ❌ Yok |
| KVKK gizlilik politikası | ⚠️ Skeleton hazır, şirket kurulmadan tamamlanamaz |

---

## 🔑 Erişim Bilgileri (Kullanıcı tarafında)

- **GitHub:** ataabeeyzaa
- **Netlify:** beyzata37@gmail.com
- **Supabase:** GitHub login (Beyza)
- **Email:** beyzata37@gmail.com (kişisel)
- **Ortak hesap (admin):** thehouseofanatoliaco@gmail.com

---

## 🎨 Aesthetic Direction

**"Editorial Heritage — Anatolian terroir meets refined modernism"**

- **Bold color discipline:** koyu zemin + altın + krem, hiçbir başka renk yok
- **Typography hierarchy:** Cormorant Garamond display + Plus Jakarta Sans body
- **Atmospheric depth:** SVG noise overlay, multi-layer radial gradients, gold sparkle particles
- **Motion polish:** reveal animations, hover surprises (gold underline expand)
- **Mobile-first:** 375px → 480px → 980px → desktop, hiçbir overflow yok
- **No AI slop:** Inter, Roboto, Arial yasak. Generic gradients yasak. Predictable layouts yasak.

Detay: DESIGN_SYSTEM.md
