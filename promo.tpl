<!doctype html>
<html lang="nl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Push Battle — push-up spel dat je herhalingen telt</title>
<meta name="theme-color" content="#000000">
<link rel="apple-touch-icon" href="__ICOON180__">
<link rel="icon" href="__ICOON180__">

<meta name="description" content="Gratis push-up spel dat je herhalingen telt met de camera. Vecht je door __AANTAL_ARENAS__ arena's, duelleer offline of live tegen een echte speler, of bouw een clicker-imperium. Werkt in elke browser.">
<meta name="keywords" content="push-up spel, pushup game, push up teller, push-ups tellen, workout game, fitness spel, thuis trainen, camera teller, krachttraining">
<meta name="author" content="Push Battle">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://pushbattle.netlify.app/">

<meta property="og:type" content="website">
<meta property="og:site_name" content="Push Battle">
<meta property="og:title" content="Push Battle — push-ups tellen als gevecht">
<meta property="og:description" content="Zet je telefoon voor je neer en push. De camera telt je herhalingen en elke push-up is een klap tegen het monster voor je.">
<meta property="og:image" content="https://pushbattle.netlify.app/icon-512.png">
<meta property="og:url" content="https://pushbattle.netlify.app/">
<meta property="og:locale" content="nl_NL">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Push Battle — push-ups tellen als gevecht">
<meta name="twitter:description" content="Zet je telefoon voor je neer en push. De camera telt je herhalingen en elke push-up is een klap tegen het monster voor je.">
<meta name="twitter:image" content="https://pushbattle.netlify.app/icon-512.png">

<style>
  * { box-sizing: border-box; }
  body {
    margin: 0; background: #000; color: #fff;
    font-family: ui-rounded, "SF Pro Rounded", -apple-system, system-ui, sans-serif;
  }
  a { color: inherit; }
  .kader { max-width: 1060px; margin: 0 auto; padding: 0 24px; }

  header { display: flex; align-items: center; justify-content: space-between; padding: 18px 0; }
  .merk { display: flex; align-items: center; gap: 12px; font-weight: 900; letter-spacing: 4px; font-size: 17px; }
  .merk img { width: 40px; height: 40px; border-radius: 22%; }
  .taalRij { display: flex; gap: 6px; }
  .taalKnop { background: rgba(255,255,255,.08); border: 0; border-radius: 99px; color: rgba(255,255,255,.75);
              font: inherit; font-size: 12px; font-weight: 800; padding: 9px 13px; cursor: pointer; }
  .taalKnop.aan { background: #ffc740; color: #000; }

  .hero { display: flex; align-items: center; gap: 48px; padding: 40px 0 70px; flex-wrap: wrap; }
  .heroTekst { flex: 1 1 420px; }
  h1 { font-size: clamp(38px, 6vw, 62px); font-weight: 900; line-height: 1.05; margin: 0 0 18px; }
  h1 em { font-style: normal; color: #ffc740; }
  .sub { font-size: 18px; line-height: 1.55; color: rgba(255,255,255,.65); max-width: 30rem; margin: 0 0 30px; }
  .grotKnop { display: inline-block; padding: 17px 34px; border: 0; border-radius: 99px; text-decoration: none;
              font: inherit; font-size: 19px; font-weight: 900; letter-spacing: 2px; color: #000;
              background: linear-gradient(180deg, #ffc740, #ff7326); cursor: pointer; }
  .grotKnop:hover { filter: brightness(1.08); }
  .badge { display: block; margin-top: 16px; font-size: 14px; font-weight: 700; color: rgba(255,255,255,.45); }

  /* Telefoonmockup met een stilstaand startscherm, opgebouwd uit de echte spelonderdelen. */
  .telefoon { flex: 0 0 auto; width: 290px; border: 3px solid #26262a; border-radius: 44px; padding: 12px;
              background: #0a0a0c; box-shadow: 0 30px 80px rgba(255,150,40,.14); margin: 0 auto; }
  .scherm { border-radius: 32px; overflow: hidden; background: radial-gradient(ellipse at 50% 30%, rgba(70,160,50,.28), #000 70%);
            padding: 26px 18px 20px; display: flex; flex-direction: column; align-items: center; text-align: center; }
  .mTitel { font-size: 17px; font-weight: 900; letter-spacing: 4px; text-shadow: 0 0 18px rgba(160,255,120,.8); }
  .mArena { font-size: 9px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.45); margin-top: 10px; }
  .mNaam { font-size: 16px; font-weight: 900; margin-top: 2px; }
  .mMonster { width: 170px; height: 170px; margin: 14px 0 8px; filter: drop-shadow(0 0 22px rgba(120,230,80,.55)); }
  .mVijand { font-size: 14px; font-weight: 800; }
  .mHp { font-size: 11px; color: rgba(255,255,255,.45); margin-bottom: 16px; }
  .mKnop { width: 100%; padding: 12px 0; border-radius: 99px; font-size: 14px; font-weight: 900; letter-spacing: 3px;
           color: #000; background: linear-gradient(180deg, #ffc740, #ff7326); }

  h2 { font-size: clamp(26px, 4vw, 38px); font-weight: 900; margin: 0 0 26px; }
  h2::first-letter { text-transform: uppercase; }
  section { padding: 34px 0; }

  .hoeRij { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
  .kaart { background: #131316; border-radius: 24px; padding: 26px; }
  .kaart svg { height: 92px; display: block; margin-bottom: 14px; }
  .kaart h3 { font-size: 19px; font-weight: 900; margin: 0 0 8px; }
  .kaart p { font-size: 15px; line-height: 1.5; color: rgba(255,255,255,.6); margin: 0; }
  .stapNr { display: inline-grid; place-items: center; width: 30px; height: 30px; border-radius: 50%;
            background: #ffc740; color: #000; font-weight: 900; font-size: 15px; margin-bottom: 12px; }

  .modiRij { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; }
  .modiRij svg { height: 64px; }

  .wereldStrook { display: flex; gap: 22px; overflow-x: auto; padding: 10px 2px 18px; scrollbar-width: none; }
  .wereldStrook::-webkit-scrollbar { display: none; }
  .wereld { flex: 0 0 auto; text-align: center; width: 92px; }
  .wereld svg { width: 72px; height: 72px; }
  .wereld div { font-size: 11px; font-weight: 700; color: rgba(255,255,255,.5); margin-top: 6px; }
  .sectieSub { font-size: 16px; line-height: 1.55; color: rgba(255,255,255,.6); max-width: 36rem; margin: -10px 0 24px; }

  .privacy { background: #131316; border-radius: 28px; padding: 34px; display: flex; gap: 26px; align-items: center; flex-wrap: wrap; }
  .privacy svg { flex: 0 0 74px; height: 74px; }
  .privacy h2 { margin-bottom: 8px; }
  .privacy p { margin: 0; font-size: 16px; line-height: 1.55; color: rgba(255,255,255,.6); max-width: 42rem; }

  .slot { text-align: center; padding: 60px 0 30px; }
  footer { display: flex; justify-content: space-between; gap: 14px; flex-wrap: wrap; padding: 26px 0 34px;
           font-size: 13px; color: rgba(255,255,255,.4); border-top: 1px solid rgba(255,255,255,.08); }
  footer a { color: rgba(255,255,255,.6); }
</style>
</head>
<body>

<div class="kader">
  <header>
    <div class="merk"><img src="__ICOON180__" alt=""> PUSH BATTLE</div>
    <div class="taalRij" id="taalRij"></div>
  </header>

  <div class="hero">
    <div class="heroTekst">
      <h1 id="heroKop"></h1>
      <p class="sub" data-t="hero_sub"></p>
      <a class="grotKnop" href="speel/" data-t="cta_speel"></a>
      <span class="badge" data-t="cta_appstore"></span>
    </div>
    <div class="telefoon"><div class="scherm" id="mockup"></div></div>
  </div>

  <section>
    <h2 data-t="hoe_kop"></h2>
    <div class="hoeRij" id="hoeRij"></div>
  </section>

  <section>
    <h2 data-t="modi_kop"></h2>
    <div class="modiRij" id="modiRij"></div>
  </section>

  <section>
    <h2 data-t="werelden_kop"></h2>
    <p class="sectieSub" data-t="werelden_tekst"></p>
    <div class="wereldStrook" id="wereldStrook"></div>
  </section>

  <section>
    <div class="privacy">
      <svg viewBox="0 0 100 100"><path fill="#ffc740" d="M50 6L88 20V52C88 74 72 88 50 96C28 88 12 74 12 52V20Z"/><path fill="#000" d="M35 48L45 58L66 34L72 40L45 70L29 54Z"/></svg>
      <div>
        <h2 data-t="privacy_kop"></h2>
        <p data-t="privacy_tekst"></p>
      </div>
    </div>
  </section>

  <div class="slot">
    <a class="grotKnop" href="speel/" data-t="cta_speel"></a>
    <span class="badge" data-t="voet_gratis"></span>
  </div>

  <footer>
    <span>© Push Battle</span>
    <a href="privacy.html" data-t="voet_privacy"></a>
  </footer>
</div>

<script>
const TEKSTEN = __PROMO_TEKSTEN__;
const ARENAS = __ARENAS__;
const MODE_ICONEN = __MODEICONEN__;
const TALEN = ['nl', 'en', 'fr'];

let TAAL = localStorage.getItem('orbslayer.taal');
if (!TALEN.includes(TAAL)) {
  const sys = (navigator.language || 'en').slice(0, 2).toLowerCase();
  TAAL = TALEN.includes(sys) ? sys : 'en';
}

function t(sleutel) {
  const rij = TEKSTEN[sleutel];
  return rij ? rij[TALEN.indexOf(TAAL)] : sleutel;
}

function kleur(rgb) {
  return `rgb(${rgb.map(v => Math.round(v * 255)).join(',')})`;
}

function icoonSvg(pad, vul, maat = 100) {
  return `<svg viewBox="0 0 ${maat} ${maat}"><path d="${pad}" fill="${vul}"/></svg>`;
}

/* De kop krijgt het laatste woord in goud. */
function teken() {
  document.documentElement.lang = TAAL;
  const kop = t('hero_kop').split(' ');
  const laatste = kop.pop();
  document.getElementById('heroKop').innerHTML =
    kop.join(' ') + ' <em>' + laatste + '</em>';

  document.querySelectorAll('[data-t]').forEach(el => { el.textContent = t(el.dataset.t); });

  document.getElementById('taalRij').innerHTML = TALEN.map(l =>
    `<button class="taalKnop ${l === TAAL ? 'aan' : ''}" data-l="${l}">${l.toUpperCase()}</button>`).join('');

  /* Mockup: het startscherm van arena 1, stilgezet. */
  const a = ARENAS[0];
  document.getElementById('mockup').innerHTML = `
    <div class="mTitel">PUSH BATTLE</div>
    <div class="mArena">ARENA 1 · ${a.race[TAAL].toUpperCase()}</div>
    <div class="mNaam" style="color:${kleur(a.rgb)}">${a.name[TAAL]}</div>
    <div class="mMonster">${icoonSvg(a.icon, kleur(a.rgb))}</div>
    <div class="mVijand">${a.minion[TAAL]}</div>
    <div class="mHp">5 HP</div>
    <div class="mKnop">${TAAL === 'fr' ? 'COMBATTRE' : TAAL === 'en' ? 'FIGHT' : 'VECHTEN'}</div>`;

  const goud = '#ffc740', dim = 'rgba(255,255,255,.22)';
  const stappen = [
    [`<svg viewBox="0 0 200 110" fill="none">
        <rect x="24" y="10" width="38" height="74" rx="7" fill="none" stroke="${goud}" stroke-width="4"/>
        <circle cx="43" cy="20" r="2.5" fill="${goud}"/>
        <path d="M78 86h108" stroke="${dim}" stroke-width="5" stroke-linecap="round"/>
        <circle cx="92" cy="60" r="10" fill="${goud}"/>
        <path d="M102 64l44 12" stroke="${goud}" stroke-width="13" stroke-linecap="round"/>
        <path d="M104 68v18M146 76l16 10" stroke="${goud}" stroke-width="9" stroke-linecap="round"/>
      </svg>`, 'hoe1_kop', 'hoe1_tekst'],
    [`<svg viewBox="0 0 200 110" fill="none">
        <rect x="92" y="8" width="16" height="94" rx="8" fill="rgba(255,255,255,.08)"/>
        <rect x="92" y="56" width="16" height="46" rx="8" fill="${goud}" opacity=".35"/>
        <circle cx="100" cy="64" r="14" fill="${goud}"/>
        <path d="M100 30v-14m0 0l-7 8m7-8l7 8" stroke="${goud}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
        <path d="M130 34h30M130 96h30" stroke="${dim}" stroke-width="3" stroke-linecap="round"/>
      </svg>`, 'hoe2_kop', 'hoe2_tekst'],
    [icoonSvg(ARENAS[0].icon, kleur(ARENAS[0].rgb)), 'hoe3_kop', 'hoe3_tekst'],
  ];
  document.getElementById('hoeRij').innerHTML = stappen.map(([svg, kopS, tekst], i) => `
    <div class="kaart"><span class="stapNr">${i + 1}</span>${svg}
      <h3>${t(kopS)}</h3><p>${t(tekst)}</p></div>`).join('');

  const modi = [
    ['arena', 'modus_arena_kop', 'modus_arena'],
    ['duel', 'modus_duel_kop', 'modus_duel'],
    ['online', 'modus_online_kop', 'modus_online'],
    ['klik', 'modus_clicker_kop', 'modus_clicker'],
  ];
  document.getElementById('modiRij').innerHTML = modi.map(([icoon, kopM, tekst]) => `
    <div class="kaart">${icoonSvg(MODE_ICONEN[icoon], goud)}
      <h3>${t(kopM)}</h3><p>${t(tekst)}</p></div>`).join('');

  document.getElementById('wereldStrook').innerHTML = ARENAS.map(w => `
    <div class="wereld">${icoonSvg(w.icon, kleur(w.rgb))}<div>${w.name[TAAL]}</div></div>`).join('');
}

document.getElementById('taalRij').addEventListener('click', e => {
  const l = e.target.dataset?.l;
  if (!l) return;
  TAAL = l;
  localStorage.setItem('orbslayer.taal', l);
  teken();
});

teken();
</script>
</body>
</html>
