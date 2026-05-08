# DESIGN SYSTEM — The House of Anatolia

> **Aesthetic direction:** "Editorial Heritage — Anatolian terroir meets refined modernism"
> **2026-05-08 güncel (PR #7 sonrası)** — frontend-design skill ilkeleri uygulanmıştır

---

## Renk Paleti

```css
:root {
  /* Zemin — koyu */
  --bg:         #0a0807;
  --bg-soft:    #120e0c;
  --panel:      #15110e;
  --panel-soft: #1c1612;

  /* Krem (cream) tonları */
  --cream:   #efe9dd;
  --cream-2: #e5ddd0;
  --text:    #f4eee6;
  --muted:   #c2b4a4;

  /* Çizgiler */
  --line: rgba(255,255,255,.08);

  /* Altın aksanlar — TEK accent rengi */
  --gold:      #d2a12f;
  --gold-soft: #f0d28a;
  --warm:      #8a5225;

  /* Easing — Apple/Aesop favorisi */
  --ease: cubic-bezier(0.16, 1, 0.3, 1);
  --max:  1320px;
}
```

### KESİN KURAL — Renk Disiplini
**Sadece koyu + altın + krem tonları kullanılır.** Mavi, yeşil, kırmızı, mor — hiçbiri yok. Tek vurgu rengi: altın. AI-cliché purple gradient'ler YASAK.

---

## Tipografi

### Fontlar
```css
--font-display: 'Cormorant Garamond', serif;       /* Başlıklar, italic accents */
--font-body:    'Plus Jakarta Sans', sans-serif;   /* Body, UI, modern */
```

**YASAK:** Inter, Roboto, Arial, Space Grotesk, system-ui. Generic AI slop.

### Google Fonts URL
```html
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
```

### Font Features
```css
body {
  font-feature-settings: "ss01","cv11";  /* Plus Jakarta alternates */
  -webkit-font-smoothing: antialiased;
}
h1, h2, h3, .title {
  font-feature-settings: "liga","dlig","kern";  /* Cormorant ligatures */
  letter-spacing: -.005em;
  text-wrap: balance;
}
```

### Hiyerarşi
```css
/* Display H1 — slogan */
font-family: 'Cormorant Garamond', serif;
font-size: clamp(46px, 7vw, 96px);
font-weight: 300-500;

/* H2 — section başlıkları */
font-size: clamp(36px, 4.5vw, 56px);

/* Italic gold accent (slogan vurgusu) */
font-style: italic; color: var(--gold-soft); font-weight: 400;

/* Eyebrow / kicker */
font-size: 0.7rem;
letter-spacing: 0.22em;
text-transform: uppercase;
color: var(--gold-soft);

/* Footer h4 — sektör-tarzı sober */
font-family: 'Plus Jakarta Sans';
font-size: 0.74rem;
font-weight: 600;
letter-spacing: 0.28em;
text-transform: uppercase;
color: var(--gold-soft);

/* Body */
font-family: 'Plus Jakarta Sans', sans-serif;
font-size: 1rem;
line-height: 1.85;
color: rgba(244, 238, 230, .68);
```

---

## Atmospheric & Motion

### SVG Film Grain (body::after)
```css
body::after {
  position: fixed; inset: 0;
  pointer-events: none; z-index: 1;
  opacity: 0.035; mix-blend-mode: overlay;
  background-image: url("data:image/svg+xml;utf8,<svg ...fractalNoise...>");
}
@media (prefers-reduced-motion: reduce) { body::after { display: none } }
```

### Gold Sparkle Particles — KALDIRILDI (PR #6)
- index.html'de tüm sparkle CSS+HTML+JS silindi (kullanıcı net karar)
- Yasaklar listesinde tüm varyantlar (üstünde/etrafında/arkasında — bkz. aşağı)
- product.html `.hero-blossom-layer` mini-blossom safran çiçeği için kapsayıcı, KORUNUR

### Marquee Strip (TV altyazısı tarzı kayan şerit)
```css
.marquee-strip{
  overflow:hidden;
  background:linear-gradient(180deg, rgba(18,13,10,.85), rgba(13,9,7,.95));
  border-top:1px solid rgba(210,161,47,.16);
  border-bottom:1px solid rgba(210,161,47,.16);
  padding:14px 0;
  backdrop-filter:blur(10px);
}
.marquee-track{
  display:flex; gap:48px;
  width:max-content;
  animation: marqueeScroll 38s linear infinite;
}
.marquee-item{
  display:inline-flex; align-items:center; gap:14px;
  color:var(--muted); font-size:.92rem;
  letter-spacing:.06em; white-space:nowrap;
  flex-shrink:0;
}
.marquee-item::before{ content:'✦'; color:var(--gold); }
@keyframes marqueeScroll{
  0%   {transform:translateX(0)}
  100% {transform:translateX(-50%)}
}
@media (prefers-reduced-motion: reduce){ .marquee-track{animation:none} }
```
- Map section ile about-section arasında, full-width
- 5 item × 2 (duplicate seamless loop)
- i18n: `marquee_1-5` keys

### Eyebrow (iki yanda altın çizgi)
```css
.eyebrow{
  display:flex; align-items:center; gap:12px;
  color:var(--gold-soft);
  text-transform:uppercase; letter-spacing:.18em;
  font-size:.76rem;
}
.eyebrow::before, .eyebrow::after{
  content:''; width:38px; height:1px;
  background:rgba(210,161,47,.72);
}
```

### Custom Scrollbar
```css
* { scrollbar-width: thin; scrollbar-color: rgba(210,161,47,.45) rgba(20,15,10,.4); }
*::-webkit-scrollbar { width: 9px; }
*::-webkit-scrollbar-thumb { background: gold gradient; }
```

### ::selection
```css
::selection { background: rgba(210,161,47,.28); color: var(--cream) }
```

### Hover/Focus Surprise
```css
/* Nav links — orta noktadan çift yönlü altın underline */
.nav-links a::before {
  position: absolute; left: 50%; right: 50%; bottom: -6px;
  height: 1px; background: var(--gold);
  transition: left .45s var(--ease), right .45s var(--ease);
}
.nav-links a:hover::before { left: 0; right: 0 }

/* Form input focus-visible — altın 3px glow ring */
input:focus-visible { box-shadow: 0 0 0 3px rgba(210,161,47,.18); }

/* Reveal animation */
.reveal { opacity: 0; transform: translateY(28px); transition: 1s var(--ease); }
.reveal.in-view { opacity: 1; transform: none }
```

---

## Spacing & Layout

### Container
```css
.container { width: min(calc(100% - 48px), 1320px); margin: 0 auto }
```

### Section Padding (GÜNCEL — daraltıldı)
```css
.section { padding: 80px 0 }              /* önceden 110px */
@media (max-width: 980px) { .section { padding: 60px 0 } }
@media (max-width: 480px) { .section { padding: 48px 0 } }
```

### Grid'ler
- **Eşit ikili (1fr 1fr)** — anasayfa about-card grid
- **3'lü (repeat(3, 1fr))** — usage-grid + product.html alt contact (PR #7)
- **4'lü footer (1.8fr 1fr 1fr 1.4fr)** — logo + contact wider
- **Contact card (1.05fr 1fr)** — sol info kart yığını + sağ newsletter card (PR #6+#7 sade — başlık/intro yok)
- **Products grid auto-fit minmax(220px, 1fr)** — küçük kart vitrini (PR #7)

### Skip-link CSS
```css
.skip-link{
  position:absolute; left:-9999px; top:8px; z-index:1000;
  padding:10px 18px;
  background:var(--gold); color:#24170a;
  text-transform:uppercase; letter-spacing:.08em;
  font-size:.78rem; font-weight:600;
}
.skip-link:focus, .skip-link:focus-visible{
  left:8px;
  outline:2px solid var(--gold-soft); outline-offset:2px;
}
```

---

## Beğenilen Component'ler

### Italic Gold Accent (slogan vurgusu)
```html
<h1>Lezzetin <em>Kökenine</em> Yolculuk</h1>
```
i18n marker syntax: `*X*` → `<em class="gold-accent">X</em>` (JS parse).

### Section Divider (◆)
```html
<div class="container">
  <div class="section-divider" aria-hidden="true">
    <span class="diamond">◆</span>
  </div>
</div>
```

### Footer Brand Logo
```html
<a href="#home" class="footer-brand-logo">
  <img src="assets/logo_house_of_anatolia_transparent.png">
</a>
```
64px height, drop-shadow, hover translateY(-2px).

### Product Card (products.html)
```html
<a href="product.html?slug=..." class="product-card">
  <div class="product-card-image"><img ...></div>
  <div class="product-card-body">
    <div class="product-card-region">KARABÜK</div>
    <h3 class="product-card-name">Safranbolu Safranı</h3>
    <p class="product-card-meta">...</p>
    <div class="product-card-foot">
      <span class="product-card-status live">YAYINDA</span>
      <span class="product-card-arrow">→</span>
    </div>
  </div>
</a>
```
Hover: `translateY(-4px)` + altın border + box-shadow + image scale(1.06).

---

## PR #7 yeni component'ler

### Hamburger menü (Aesop pattern)
- Navbar yatay nav-links kaldırıldı; sadece logo + `.nav-toggle` (☰) + lang switcher
- `.nav-overlay` fullscreen, `radial-gradient(circle at 30% 0%, rgba(151,90,24,.20))` + `linear-gradient(180deg, rgba(8,6,5,.98), rgba(15,11,9,.98))` + `backdrop-filter:blur(18px)`
- Açılış animasyonu: 450ms cubic-bezier fade + content `translateY(14px → 0)` 550ms
- Hamburger ikonu `is-open` state'te X'e dönüşür (3 line → 2 rotated)
- Body scroll lock: `body.nav-open { overflow:hidden }`
- Eyebrow + Cormorant clamp(1.6,2.8vw,2rem) link tipografi
- Lang switcher overlay'in altında ana switcher ile sync (aynı `.lang-switcher` class)

### Ürünler grid (anasayfa)
- `auto-fit minmax(220px, 1fr)` — küçük cards
- 16/10 aspect-ratio görsel + `object-fit:cover`
- Hover: gold border + `translateY(-3px)` + `image scale(1.05)`

### product.html alt contact 3 yatay kart
- `repeat(3, 1fr) gap:18px` — info-card pattern
- 40×40 yuvarlak gold-soft glow ikon
- Mobile <760 dikey, <540 sıkışık padding/font

## Yasaklar

1. ❌ **Inter, Roboto, Arial, system-ui, Space Grotesk** — generic AI slop
2. ❌ **Purple gradients** (özellikle white background üstünde)
3. ❌ **Predictable layouts** (cookie-cutter Bootstrap)
4. ❌ **3-sütun yan yana dikey label/value** (kart yığını OK ama yan yana 3 sütun değil)
5. ❌ **Stats bar 1/1/1 sayım kartları** ("ucuz duruyor")
6. ❌ **KÜNYE bilgi kartları** (kullanıcı reddetti)
7. ❌ **Sertifika rozeti** (kullanıcı reddetti)
8. ❌ **Cinematic dağ silüetleri** (kullanıcı reddetti)
9. ❌ **Sparkle / gold-sim parçacıklar — TÜM VARYANTLAR** (haritanın üzerinde, etrafında, ARKASINDA — hiçbir konumda kabul edilmiyor; PR #6'da tamamen kaldırıldı, geri getirme YASAK)
10. ❌ **Border-radius bombardımanı** — köşe %0 veya max 24px (contact-card için)
11. ❌ **Drop shadow abartısı** — sadece var(--shadow) veya gold glow
12. ❌ **Emoji ikonlar** — yerine SVG (Heroicons outline tarzı) veya `✦ ❋ ※`
13. ❌ **Auto-play video / ses**
14. ❌ **Stock fotoğraf hissi**
15. ❌ **Newsletter formunu birden çok yerde duplicate gösterme** (PR #6: footer'dan kaldırılıp contact'a taşındı, tek konum)

---

## Olmazsa Olmaz

1. ✓ **Boşluk hakimiyeti** — section padding 60-80px
2. ✓ **Tek easing** — `cubic-bezier(0.16, 1, 0.3, 1)`
3. ✓ **İnce çizgiler** — 1px gold border/divider
4. ✓ **İtalik altın vurgular** — başlıklarda 1 kelime
5. ✓ **Atmospheric depth** — film grain noise + radial gradients (sparkle KALDIRILDI — PR #6)
6. ✓ **Eyebrow iki yanda altın çizgi** (::before + ::after)
7. ✓ **Mobile-first** — clamp() fluid type, no overflow
8. ✓ **prefers-reduced-motion saygısı**
9. ✓ **Touch-friendly** — 44px+ targets
10. ✓ **Skip-to-main link** (WCAG 2.4.1)

---

## Stil Referansları

- **Aesop** — typography hierarchy, sober footers (asymmetric grid'i kullanıcı reddetti)
- **Hermès Maison** — editorial yön, gold accents (cinematic hero reddedildi)
- **Le Labo** — typography-first, brutal minimalism
- **Mariage Frères** — heritage, editorial detayları

**Özetle:** "Boş ama dolu" — az element, ama her element premium hissi versin.
