# DESIGN SYSTEM — The House of Anatolia

> **Tasarım kararları, renk paleti, tipografi, animasyon prensipleri, component örnekleri.**

---

## 🎨 Renk Paleti

### CSS Değişkenleri (`:root`)
```css
:root {
  /* Zemin */
  --bg: #0a0807;          /* Ana koyu zemin (yumuşak siyah-kahve) */
  --bg-soft: #120e0c;     /* Hafif daha açık zemin (kart arka planları) */
  --panel: #15110e;       /* Panel/kart zemini */
  --panel-soft: #1c1612;  /* Hafif vurgulu panel */

  /* Krem (cream) tonları */
  --cream: #efe9dd;       /* Ana açık ton (text, butonlar) */
  --cream-2: #e5ddd0;     /* Yumuşak krem */
  --text: #f4eee6;        /* Ana metin rengi */
  --muted: #c2b4a4;       /* Soluk metin */

  /* Çizgiler */
  --line: rgba(255,255,255,.08);

  /* Altın aksanlar */
  --gold: #d2a12f;        /* Ana altın */
  --gold-soft: #f0d28a;   /* Açık altın (italic vurgular) */

  /* Sıcak */
  --warm: #8a5225;        /* Toprak rengi (rare use) */

  /* Ekstra (premium hero için, opsiyonel) */
  --gold-light: #E8C76A;  /* Daha açık altın (italic accent) */
  --gold-pale: #FAF3E0;   /* Çok açık altın (background tint) */

  /* Diğer */
  --shadow: 0 30px 80px rgba(0,0,0,.38);
  --radius: 30px;
  --max: 1320px;
  --ease: cubic-bezier(0.16, 1, 0.3, 1);  /* Luxury easing */
}
```

### Yardımcı Tonlar
- **Hover gold:** `rgba(210, 161, 47, 0.16)` — altın'ın %16 transparan hali
- **Gold border:** `rgba(210, 161, 47, 0.25)` — görünür ama yumuşak
- **Gold glow:** `0 0 24px rgba(210, 161, 47, 0.18)` — light source efekti
- **Cream subtle:** `rgba(244, 238, 230, 0.62)` — desc text

### Renk Kullanım Kuralları
| Element | Renk |
|---|---|
| Body bg | `--bg` üzerine `radial-gradient`'ler |
| Başlıklar (h1-h2) | `--cream` |
| Başlık vurgu (italic span) | `--gold-soft` veya `--gold-light` |
| Body text | `rgba(244, 238, 230, .65-.85)` |
| Linkler | `--gold` (hover'da underline) |
| Butonlar (primary) | `bg: var(--gold)`, `color: #1a1208` |
| Butonlar (ghost) | `transparent + 1px var(--gold) border` |
| Input bg | `rgba(255,255,255,.04)` |
| Input border | `rgba(255,255,255,.08)` (focus'ta gold) |
| Eyebrow / kicker | `--gold-soft`, uppercase, letter-spacing .22em |

---

## 📝 Tipografi

### Fontlar
```css
--font-serif: 'Cormorant Garamond', serif;  /* Başlıklar */
--font-sans: 'Inter', sans-serif;            /* Body */
--font-jost: 'Jost', sans-serif;             /* Premium variants (opsiyonel) */
```

Google Fonts URL:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Hiyerarşi
```css
/* Hero başlık */
font-family: 'Cormorant Garamond', serif;
font-size: clamp(46px, 7vw, 96px);
font-weight: 300;
line-height: 1.04;
letter-spacing: -0.005em;

/* Italic vurgu (slogan'da "Kökenine") */
font-style: italic;
color: var(--gold-soft);
font-weight: 400;

/* H2 — bölüm başlıkları */
font-family: 'Cormorant Garamond', serif;
font-size: clamp(36px, 4.5vw, 56px);
font-weight: 300;
line-height: 1.1;

/* H3 — alt başlıklar */
font-family: 'Cormorant Garamond', serif;
font-size: clamp(24px, 2.4vw, 32px);
font-weight: 400;

/* Body */
font-family: 'Inter', sans-serif;
font-size: 1rem;
line-height: 1.85;
color: rgba(244, 238, 230, .68);

/* Eyebrow / kicker (üst etiket) */
font-size: 0.7rem;
letter-spacing: 0.22em;
text-transform: uppercase;
color: var(--gold-soft);

/* Buton metni */
font-size: 0.78rem;
font-weight: 600;
letter-spacing: 0.15em;
text-transform: uppercase;

/* Caption / küçük metin */
font-size: 0.82rem;
color: rgba(244, 238, 230, .5);
```

---

## 📐 Spacing & Layout

### Container
```css
.container {
  max-width: var(--max); /* 1320px */
  margin: 0 auto;
  padding: 0 60px;
}

/* Mobile */
@media (max-width: 980px) {
  .container { padding: 0 28px; }
}
```

### Section Padding
```css
.section { padding: 120px 0; }

/* Compact */
.section-sm { padding: 80px 0; }

/* Mobile */
@media (max-width: 980px) {
  .section { padding: 80px 0; }
  .section-sm { padding: 50px 0; }
}
```

### Grid'ler
```css
/* Asymmetric (Hakkımızda — Aesop tarzı) */
.grid-asym { grid-template-columns: 1.2fr 0.8fr; gap: 80px; }

/* Eşit ikili */
.grid-2 { grid-template-columns: 1fr 1fr; gap: 60px; }

/* 3'lü */
.grid-3 { grid-template-columns: repeat(3, 1fr); gap: 40px; }
```

---

## 🎬 Animasyon Prensipleri

### Easing
**TEK EASING KULLANIYORUZ:** `cubic-bezier(0.16, 1, 0.3, 1)`
Bu Apple, Aesop, Stripe gibi premium markaların favorisi. Yumuşak, biraz "ease-out cubic"'ten daha rafine.

### Duration
- **Micro interactions** (hover): 0.25-0.35s
- **Reveal animations**: 0.8-1s
- **Page transitions**: 0.6-0.8s
- **Slow ambient** (parçacıklar): 8-20s

### Animasyon Tipleri
```css
/* Slide-up (en yaygın) */
@keyframes slideUp {
  from { opacity: 0; transform: translateY(28px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Expand line (altın çizgi açılışı) */
@keyframes expand {
  from { width: 0; }
  to { width: 60px; }
}

/* Float-up (parçacıklar) */
@keyframes floatUp {
  0% { transform: translateY(0); opacity: 0; }
  10% { opacity: 0.7; }
  90% { opacity: 0.3; }
  100% { transform: translateY(-110vh); opacity: 0; }
}

/* Fade scale (büyük arka yazı) */
@keyframes fadeScale {
  from { opacity: 0; transform: translate(-50%,-50%) scale(1.08); }
  to { opacity: 1; transform: translate(-50%,-50%) scale(1); }
}
```

### prefers-reduced-motion Saygısı
**HER zaman uygula:**
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

JS tarafında:
```javascript
if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
// Animasyon kodunu çalıştırma
```

---

## 🔘 Component Örnekleri

### Eyebrow (üst etiket)
```html
<div class="eyebrow">
  <span class="eyebrow-line"></span>
  <span>HİKÂYEMİZ</span>
</div>
```
```css
.eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 14px;
  font-size: 0.7rem;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--gold-soft);
}
.eyebrow-line {
  width: 32px;
  height: 1px;
  background: var(--gold);
}
```

### Divider (altın çizgi)
```html
<div class="divider"></div>
```
```css
.divider {
  width: 60px;
  height: 1px;
  background: var(--gold);
  margin: 36px 0;
}
```

### Italic Gold Accent (slogan vurgusu)
```html
<h1>Lezzetin <em>Kökenine</em> Yolculuk</h1>
```
```css
h1 em {
  font-style: italic;
  color: var(--gold-soft);
  font-weight: 400; /* normal weight, daha rafine */
}
```

### Primary Button
```html
<a href="#" class="btn btn-primary"><span>Ürünleri Keşfet</span></a>
```
```css
.btn {
  display: inline-flex;
  align-items: center;
  padding: 16px 32px;
  font-size: 0.78rem;
  font-weight: 600;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.35s var(--ease);
  border: 1px solid;
}
.btn-primary {
  background: var(--gold);
  color: #1a1208;
  border-color: var(--gold);
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(210,161,47,.35);
}
```

### Ghost Button
```css
.btn-ghost {
  background: transparent;
  color: rgba(244,238,230,.75);
  border-color: rgba(244,238,230,.2);
}
.btn-ghost:hover {
  border-color: var(--gold-soft);
  color: var(--gold-soft);
}
```

### Card
```html
<article class="card">
  <span class="card-no">01</span>
  <h3>Başlık</h3>
  <p>Açıklama metni</p>
</article>
```
```css
.card {
  background: var(--panel);
  border: 1px solid var(--line);
  padding: 36px 32px;
  transition: all 0.35s var(--ease);
}
.card:hover {
  border-color: rgba(210,161,47,.25);
  transform: translateY(-4px);
  box-shadow: var(--shadow);
}
.card-no {
  display: inline-grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(210,161,47,.1);
  border: 1px solid rgba(210,161,47,.22);
  color: var(--gold-soft);
  font-size: 0.84rem;
  margin-bottom: 16px;
}
```

### Marquee (yatay kayan yazı)
```html
<div class="marquee">
  <div class="marquee-track">
    <span class="marquee-item">SAFRANBOLU SAFRANI</span>
    <span class="marquee-dot">✦</span>
    <!-- ... 2x tekrar (sürekli akış için) -->
  </div>
</div>
```
```css
.marquee {
  overflow: hidden;
  border-top: 1px solid rgba(210,161,47,.15);
  border-bottom: 1px solid rgba(210,161,47,.15);
  padding: 14px 0;
}
.marquee-track {
  display: flex;
  gap: 60px;
  animation: marquee 30s linear infinite;
  white-space: nowrap;
  width: max-content;
}
@keyframes marquee {
  from { transform: translateX(0); }
  to { transform: translateX(-50%); }
}
.marquee-item {
  font-size: 0.72rem;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: rgba(210,161,47,.55);
}
.marquee-dot {
  color: var(--gold);
}
```

### Stats Bar (altın arka plan)
```html
<section class="stats-bar">
  <div class="stat-item">
    <div class="stat-num">200+</div>
    <div class="stat-label">Üretici Ortağı</div>
  </div>
  <!-- ... -->
</section>
```
```css
.stats-bar {
  background: linear-gradient(180deg, var(--gold) 0%, #c08f1f 100%);
  padding: 32px 48px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}
.stat-num {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2.4rem;
  color: #1a1208;
}
.stat-label {
  font-size: 0.68rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: rgba(26,18,8,.72);
  font-weight: 600;
}
```

### Certificate Badge (Coğrafi İşaret rozeti)
```html
<div class="cert-badge">
  <div class="cert-header">
    <span class="cert-label">TESCİL NO</span>
    <span class="cert-no">№ 234</span>
  </div>
  <h3 class="cert-title">Safranbolu Safranı</h3>
  <p class="cert-sub">Türk Patent ve Marka Kurumu</p>
  <div class="cert-stats">
    <div class="cert-stat">
      <div class="cert-stat-num">2014</div>
      <div class="cert-stat-lbl">Tescil Yılı</div>
    </div>
    <div class="cert-stat">
      <div class="cert-stat-num">600+</div>
      <div class="cert-stat-lbl">Yıllık Üretim</div>
    </div>
  </div>
</div>
```
```css
.cert-badge {
  background: linear-gradient(180deg, rgba(210,161,47,.08), rgba(210,161,47,.02));
  border: 1px solid rgba(210,161,47,.25);
  padding: 50px 40px;
  position: relative;
}
.cert-badge::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: linear-gradient(90deg, transparent, var(--gold), transparent);
}
```

---

## 🚫 Yapılmaması Gerekenler

1. ❌ **Çoklu rengi karıştırma** — Sadece altın + krem + koyu kahve. Mavi, yeşil, kırmızı YOK.
2. ❌ **Border-radius bombardımanı** — Köşeler %0 veya max 4px. Yuvarlak yok.
3. ❌ **Drop shadow abartısı** — Sadece `var(--shadow)` veya gold glow.
4. ❌ **3'ten fazla font ağırlığı** — 300, 400, 600, 700 yeter.
5. ❌ **Emoji ikonlar** — Yerine inline SVG veya `✦` `❋` `※` gibi typo karakterler.
6. ❌ **Otomatik döngü ile slider** — kullanıcı kontrolü kaybolur, lüks değil.
7. ❌ **Auto-play video / ses** — kötü UX.
8. ❌ **Stock fotoğraf hissi veren görseller** — yoksa hiç görsel olmasın daha iyi.
9. ❌ **Linear gradient backgrounds** (renkli) — gold'tan koyuya gradient OK, başka kombinasyon yok.
10. ❌ **`text-shadow`** — düz renk, lüks markada gölgeli yazı yok.

---

## ✅ Yapılması Gerekenler

1. ✅ **Boşluk hakimiyeti** — bir bölüm en az 80px alt-üst padding
2. ✅ **Tek easing** — cubic-bezier(0.16, 1, 0.3, 1) her yerde
3. ✅ **İnce çizgiler** — 1px gold border, 1px gold divider
4. ✅ **Italic altın vurgular** — başlıklarda tek bir kelime
5. ✅ **Asimetrik grid'ler** — 1.2fr 0.8fr gibi (tam ortada bölme yapma)
6. ✅ **Number + label combo** — büyük serif rakam + küçük caps label
7. ✅ **Marquee discreet** — yavaş akış, düşük opacity
8. ✅ **Section labels** — her bölümde "01 — HİKÂYE" gibi numaralı kicker
9. ✅ **Hover effect: subtle** — translateY(-2px) + shadow gold
10. ✅ **Mobile first thinking** — `clamp(46px, 7vw, 96px)` gibi fluid type

---

## 🎯 Stil Referansları

Kullanıcının beğendiği siteler:
- **Aesop** — https://www.aesop.com (asymmetric grids, italic accents, prose-heavy)
- **Hermès Maison** — https://www.maison.hermes.com (cinematic hero, white space)
- **Le Labo** — https://www.lelabo.com (typography-first, brutal minimalism)
- **Mariage Frères** — https://www.mariagefreres.com (heritage, certifications)

Özetle: **"Boş ama dolu"** — az element, ama her element premium hissi versin.
