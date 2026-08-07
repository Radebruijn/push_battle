<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
<title>Push Battle — push-up spel dat je herhalingen telt</title>
<meta name="theme-color" content="#000000">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Push Battle">
<link rel="manifest" href="/manifest.json">
<!-- Het icoon staat er als data-URI in, zodat de pagina één bestand blijft. -->
<link rel="apple-touch-icon" href="__ICOON180__">
<link rel="icon" href="__ICOON180__">

<!-- Voor zoekmachines en voor het voorbeeldkaartje als je de link deelt. -->
<meta name="description" content="Gratis push-up spel dat je herhalingen telt met de camera. Vecht je door __AANTAL_ARENAS__ arena's, of neem het zestig seconden op tegen een tegenstander — offline of live tegen een echte speler. Werkt in elke browser, op je telefoon en je laptop.">
<meta name="keywords" content="push-up spel, pushup game, push up teller, push-ups tellen, workout game, fitness spel, thuis trainen, camera teller, krachttraining">
<meta name="author" content="Push Battle">
<meta name="robots" content="index, follow">
<link rel="canonical" href="./">

<meta property="og:type" content="website">
<meta property="og:site_name" content="Push Battle">
<meta property="og:title" content="Push Battle — push-ups tellen als gevecht">
<meta property="og:description" content="Zet je telefoon naast je neer en push. De camera telt je herhalingen en elke push-up is een klap tegen het monster voor je.">
<meta property="og:image" content="https://pushbattle.netlify.app/icon-512.png">
<meta property="og:locale" content="nl_NL">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Push Battle — push-ups tellen als gevecht">
<meta name="twitter:description" content="Zet je telefoon naast je neer en push. De camera telt je herhalingen en elke push-up is een klap tegen het monster voor je.">
<meta name="twitter:image" content="https://pushbattle.netlify.app/icon-512.png">

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "VideoGame",
  "name": "Push Battle",
  "alternateName": "Push-up spel",
  "description": "Push-up spel dat je herhalingen telt met de camera. Vecht je door __AANTAL_ARENAS__ arena's, of neem het zestig seconden op tegen een tegenstander — alleen of online tegen een echte speler.",
  "genre": ["Fitness", "Casual"],
  "gamePlatform": ["Web browser", "iOS", "Android"],
  "applicationCategory": "GameApplication",
  "operatingSystem": "Elke browser",
  "inLanguage": ["nl", "en", "fr"],
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "EUR" }
}
</script>
<!--KOP-EINDE-->
<style>
  * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  body {
    margin: 0; background: #000; color: #fff; overflow: hidden;
    font-family: ui-rounded, "SF Pro Rounded", -apple-system, system-ui, sans-serif;
    height: 100dvh; user-select: none; cursor: pointer;
  }
  #aura { position: fixed; inset: 0; pointer-events: none; transition: background 1s; }
  #stage { position: relative; height: 100dvh; display: flex; flex-direction: column; padding: 14px 0 18px; }

  .top { padding: 0 18px 0 34px; }
  .toprow { display: flex; align-items: center; justify-content: space-between; }
  .streak { font-size: 14px; font-weight: 800; color: #ff7326; }
  .arena-label { text-align: center; line-height: 1.25; }
  .arena-name { font-size: 12px; font-weight: 900; letter-spacing: 2px; }
  .arena-num { font-size: 9px; font-weight: 700; letter-spacing: 1.5px; color: rgba(255,255,255,.55); }
  .reps { font-size: 14px; font-weight: 800; color: rgba(255,255,255,.55); }
  .pips { display: flex; gap: 5px; margin-top: 10px; }
  .pip { flex: 1; height: 4px; border-radius: 3px; background: rgba(255,255,255,.12); transition: background .3s; }

  .middle { flex: 1; display: flex; align-items: center; justify-content: center; }
  .arenaCol { flex: 1; min-width: 0; padding-left: 10px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 14px; }
  .enemy-name { font-size: 20px; font-weight: 800; text-align: center; }
  .enemy-name.boss { font-size: 25px; }
  .boss-tag { font-size: 11px; font-weight: 900; letter-spacing: 4px; color: #f2263a; margin-bottom: 2px; }
  .race { font-size: 12px; color: rgba(255,255,255,.55); }

  #orbwrap { position: relative; width: 320px; height: 320px; display: grid; place-items: center; }
  #glow { position: absolute; width: 320px; height: 320px; border-radius: 50%; filter: blur(14px); }
  #enemySvg { position: relative; transition: width .3s, height .3s; will-change: transform; overflow: visible; }
  #bossRing { position: absolute; border-radius: 50%; border: 2px dashed rgba(242,38,58,.45);
              animation: draai 24s linear infinite; display: none; }
  @keyframes draai { to { transform: rotate(360deg); } }
  .dmg {
    position: absolute; font-weight: 900; pointer-events: none;
    animation: rise 1.05s ease-out forwards;
  }
  @keyframes rise {
    0%   { transform: translateY(0) scale(.4); opacity: 1; }
    25%  { transform: translateY(-40px) scale(1.05); opacity: 1; }
    100% { transform: translateY(-135px) scale(1); opacity: 0; }
  }

  .hpwrap { width: min(66vw, 340px); }
  .hpbar { height: 12px; border-radius: 99px; background: rgba(255,255,255,.1); overflow: hidden; }
  .hpfill { height: 100%; border-radius: 99px; transition: width .25s cubic-bezier(.2,.9,.3,1.2); }
  .hptext { text-align: center; font-size: 13px; font-weight: 600; color: rgba(255,255,255,.55); margin-top: 6px; }

  .bottom { text-align: center; padding: 0 20px 26px; min-height: 40px; }
  #cambalk { position: fixed; left: 0; right: 0; bottom: 0; z-index: 9; display: none;
             text-align: center; padding: 0 20px 22px;
             background: linear-gradient(to top, #000 55%, transparent); }
  #cambalk.aan { display: block; }
  .combo { font-size: 18px; font-weight: 900; color: rgba(255,255,255,.8); }
  .combo.crit { font-size: 24px; color: #ffc740; text-shadow: 0 0 16px rgba(255,199,64,.8); }
  .hint { font-size: 12px; color: rgba(255,255,255,.45); margin-top: 8px; }

  /* neusbalk rechts */
  .nosebar { width: 74px; flex: none; height: 62vh; position: relative; margin-right: 6px; }
  .track { position: absolute; left: 50%; transform: translateX(-50%); bottom: 0; width: 14px; height: 100%;
           border-radius: 99px; background: rgba(255,255,255,.07); overflow: hidden; }
  .trackfill { position: absolute; bottom: 0; width: 100%; border-radius: 99px;
               background: linear-gradient(to bottom, rgba(140,56,255,.7), rgba(242,38,58,.5)); }
  .knob { position: absolute; left: 50%; width: 26px; height: 26px; border-radius: 50%;
          border: 1.5px solid rgba(255,255,255,.7); transform: translate(-50%, 50%);
          transition: bottom .12s cubic-bezier(.3,1.4,.5,1), background .12s; }
  .mark { position: absolute; right: 0; display: flex; align-items: center; gap: 4px; transform: translateY(50%); }
  .mark span { font-size: 9px; font-weight: 700; color: rgba(255,255,255,.5); }
  .mark i { display: block; width: 22px; height: 2px; background: rgba(255,255,255,.3); }

  #banner {
    position: fixed; inset: 0; display: grid; place-items: center; pointer-events: none;
    font-size: 34px; font-weight: 900; color: #ffc740; text-align: center; white-space: pre-line;
    text-shadow: 0 0 20px rgba(255,199,64,.7); opacity: 0; transition: opacity .25s; line-height: 1.15;
  }
  #intro {
    position: fixed; inset: 0; display: grid; place-items: center; pointer-events: none;
    background: rgba(0,0,0,.85); opacity: 0; transition: opacity .5s; text-align: center;
  }
  #intro .num { font-size: 12px; font-weight: 900; letter-spacing: 5px; color: rgba(255,255,255,.55); }
  #intro .nm { font-size: 34px; font-weight: 900; margin: 12px 0; }
  #intro .rule { width: 90px; height: 1px; margin: 0 auto 14px; }
  #intro .rc { font-size: 14px; font-weight: 700; letter-spacing: 3px; }
  #intro .it { font-size: 14px; font-style: italic; color: rgba(255,255,255,.55); margin-top: 10px; padding: 0 40px; }

  #flash { position: fixed; inset: 0; background: #fff; opacity: 0; pointer-events: none; transition: opacity .12s; }
  #reset { position: fixed; left: 50%; transform: translateX(-50%); bottom: 22px; background: none; border: 0;
           color: rgba(255,255,255,.28); font: inherit; font-size: 11px; cursor: pointer; z-index: 5; }
  .xpStrip { display: flex; align-items: center; gap: 8px; margin-top: 9px; }
  .xpNiveau { width: 20px; height: 20px; flex: none; border-radius: 50%; background: #ffc740;
              color: #000; font-size: 11px; font-weight: 900; display: grid; place-items: center; }
  .xpSpoor { flex: 1; height: 6px; border-radius: 99px; background: rgba(255,255,255,.1); overflow: hidden; }
  .xpVul { height: 100%; border-radius: 99px; transition: width .35s cubic-bezier(.2,.9,.3,1.2); }
  .xpTekst { font-size: 10px; font-weight: 600; color: rgba(255,255,255,.5); flex: none; }
  .taalRij { display: flex; gap: 8px; justify-content: center; margin-top: 10px; }
  .taalKnop { background: rgba(255,255,255,.08); border: 0; border-radius: 99px; color: rgba(255,255,255,.5);
              font: inherit; font-size: 13px; font-weight: 900; padding: 8px 16px; cursor: pointer; }
  .taalKnop.aan { background: #ffc740; color: #000; }

  /* menu */
  /* Het menu vult precies het scherm; niets valt eronder weg. */
  #menu { position: fixed; inset: 0; z-index: 8; overflow: hidden; background: #000;
          display: flex; flex-direction: column; padding: 10px 0 16px; }
  #menu.uit { display: none; }
  .menuVak { position: relative; display: flex; flex-direction: column;
             flex: 1; min-height: 0; }
  #menu.uit { display: none; }
  #stage.uit { display: none; }
  #menuAura { position: fixed; inset: 0; pointer-events: none; }
  .mTitel { font-size: 27px; font-weight: 900; letter-spacing: 5px; text-align: center;
             margin: 0; }
  .mRang { font-size: 13px; font-weight: 700; color: #ffc740; text-align: center; margin-top: 3px; }
  .mXp { width: min(72vw, 320px); margin: 9px auto 0; }
  .mXpBar { height: 8px; border-radius: 99px; background: rgba(255,255,255,.1); overflow: hidden; }
  .mXpVul { height: 100%; border-radius: 99px; }
  .mXpTekst { font-size: 11px; color: rgba(255,255,255,.45); text-align: center; margin-top: 5px; }

  .mKaart { text-align: center; padding: 0 20px; flex: 1; min-height: 0;
            display: flex; flex-direction: column; justify-content: center; gap: 2px;
            position: relative; }
  /* Je tegenstander is tegelijk de deur naar je pad: tik erop. */
  #mIcoon { cursor: pointer; }
  .mPadTip { position: absolute; right: 14px; top: 0; display: flex; align-items: center;
             gap: 5px; font-size: 11px; font-weight: 900; padding: 5px 10px; border-radius: 99px;
             background: rgba(255,199,64,.16); color: #ffc740; pointer-events: none; }
  .mPadTip[hidden] { display: none; }
  .mArenaLabel { font-size: 10px; font-weight: 900; letter-spacing: 2.5px; color: rgba(255,255,255,.5); }
  .mArenaNaam { font-size: 22px; font-weight: 900; margin-top: 4px; }
  .mIcoon { flex: 1; min-height: 0; width: 100%; margin: 6px auto; overflow: visible; }
  .mVijand { font-size: 18px; font-weight: 700; margin-top: 6px; }
  .mHp { font-size: 13px; color: rgba(255,255,255,.5); margin-top: 3px; }
  .mPips { display: flex; gap: 5px; justify-content: center; margin-top: 8px; }
  .mPips i { width: 7px; height: 7px; border-radius: 50%; display: block; }

  .mKop { font-size: 10px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5);
          padding: 0 20px; margin: 10px 0 8px; }
  /* Opdrachten staan linksonder, vlak boven de strook met wat er komt. */
  .mOnder { display: flex; padding: 0 20px; margin-top: 6px; }
  .mQuest { display: flex; align-items: center; gap: 7px; padding: 6px 12px; border-radius: 99px;
            border: 1px solid rgba(255,255,255,.12); background: rgba(255,255,255,.05);
            color: rgba(255,255,255,.8); font: inherit; font-size: 12px; font-weight: 800;
            cursor: pointer; }
  .mQuest i { font-style: normal; font-size: 10px; font-weight: 900; padding: 2px 7px;
              border-radius: 99px; background: rgba(255,199,64,.2); color: #ffc740; }
  .mQuest i.af { background: rgba(74,222,128,.2); color: #4ade80; }
  .mQuest i:empty { display: none; }
  .mRij { display: flex; gap: 12px; overflow-x: auto; padding: 0 20px 6px;
          scrollbar-width: none; }
  .mRij::-webkit-scrollbar { display: none; }
  .mSlot { flex: none; width: 84px; padding: 9px 0; border-radius: 16px;
           background: rgba(255,255,255,.04); text-align: center; border: 0; color: inherit;
           font: inherit; cursor: pointer; }
  .mVak { width: 52px; height: 52px; margin: 0 auto; border-radius: 14px;
          background: rgba(255,255,255,.05); display: grid; place-items: center; }
  .mVak svg { width: 34px; height: 34px; }
  .mVak span { font-size: 28px; font-weight: 900; color: rgba(255,255,255,.4); }
  .mSlotNaam { font-size: 10px; font-weight: 700; margin-top: 6px; height: 24px;
               display: flex; align-items: center; justify-content: center; padding: 0 4px; }
  .mSlotRas { font-size: 9px; color: rgba(255,255,255,.45); }
  .mSlotSlot { font-size: 9px; color: rgba(255,255,255,.35); margin-top: 4px; }
  .mSlot.mHier { outline: 1px solid rgba(255,199,64,.7); background: rgba(255,199,64,.08); }
  .mSlot.mVoorhoede { outline: 1px solid rgba(255,255,255,.25); }
  .mSlot.mVoorhoede .mSlotSlot { color: #ffc740; }


  #vechten { display: block; width: calc(100% - 48px); margin: 14px auto 0; padding: 15px 0;
             border: 0; border-radius: 99px; font: inherit; font-size: 20px; font-weight: 900;
             letter-spacing: 3px; color: #000; cursor: pointer;
             background: linear-gradient(180deg, #ffc740, #ff7326);
             box-shadow: 0 0 22px rgba(255,115,38,.45); }
  #terug { position: fixed; left: 8px; top: 8px; z-index: 6; background: none; border: 0;
           color: rgba(255,255,255,.5); font: inherit; font-size: 20px; cursor: pointer; }
  /* Leesbaar voor zoekmachines en schermlezers, maar niet in beeld. */
  .zoekbaar { position: absolute; width: 1px; height: 1px; overflow: hidden;
              clip: rect(0 0 0 0); clip-path: inset(50%); white-space: nowrap; }

  /* De rondleiding neemt het hele scherm over: alleen 'overslaan' rechtsboven
     en de knop onderaan reageren. */
  #rondleiding { position: fixed; inset: 0; z-index: 20; background: #000; display: none;
                 flex-direction: column; padding: 18px 22px 26px; }
  #rondleiding.aan { display: flex; }
  #rlTaal { position: absolute; left: 14px; top: 14px; z-index: 2; gap: 6px; margin: 0; }
  #rlTaal .taalKnop { font-size: 12px; padding: 9px 13px; }
  #rlOver { position: absolute; right: 14px; top: 14px; z-index: 2; background: rgba(255,255,255,.08);
            border: 0; border-radius: 99px; color: rgba(255,255,255,.75); font: inherit;
            font-size: 14px; font-weight: 700; padding: 9px 18px; cursor: pointer; }
  .rlVak { flex: 1; min-height: 0; display: flex; flex-direction: column;
           align-items: center; justify-content: center; text-align: center; gap: 2px; }
  .rlBeeld { flex: 1; min-height: 0; width: 100%; display: grid; place-items: center;
             margin-bottom: 14px; }
  .rlBeeld svg, .rlBeeld img { max-height: 100%; max-width: 76%; }
  .rlBeeld img { border-radius: 22%; }
  .rlStap { font-size: 11px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.4); }
  .rlKop { font-size: 27px; font-weight: 900; margin: 6px 0 0; }
  .rlTekst { font-size: 15px; line-height: 1.5; color: rgba(255,255,255,.62);
             margin: 12px 0 0; max-width: 24rem; }
  .rlVoet { flex: none; margin-top: 22px; }
  .rlBolletjes { display: flex; gap: 7px; justify-content: center; margin-bottom: 18px; }
  .rlBolletjes i { width: 7px; height: 7px; border-radius: 50%; display: block;
                   background: rgba(255,255,255,.2); transition: background .2s, width .2s; }
  .rlBolletjes i.nu { background: #ffc740; width: 20px; border-radius: 99px; }
  .rlKnoppen { display: flex; gap: 12px; }
  .rlKnoppen .grotKnop { margin-top: 26px; min-width: 0; flex: 1.6; }
  #rlTerug { display: none; flex: 1; background: rgba(255,255,255,.1); color: rgba(255,255,255,.85);
             font-size: 15px; letter-spacing: 1px; }
  #rlTerug.aan { display: block; }

  #tip { position: fixed; left: 12px; right: 12px; bottom: 14px; z-index: 15;
         background: rgba(20,20,22,.97); border: 1px solid rgba(255,199,64,.35);
         border-radius: 18px; padding: 15px 17px 12px; opacity: 0; transform: translateY(14px);
         transition: opacity .25s, transform .25s; pointer-events: none; }
  #tip.aan { opacity: 1; transform: none; pointer-events: auto; }
  .tipTekst { font-size: 14px; line-height: 1.45; color: #eee; }
  .tipOver { display: block; margin-top: 8px; margin-left: auto; background: none; border: 0;
             color: rgba(255,255,255,.45); font: inherit; font-size: 12px; cursor: pointer; }
  #tip::after { content: ''; position: absolute; left: 17px; right: 17px; bottom: 0; height: 2px;
                background: #ffc740; transform-origin: left; animation: tipBalk 2.6s linear forwards; }
  @keyframes tipBalk { from { transform: scaleX(1); } to { transform: scaleX(0); } }
  @media (prefers-reduced-motion: reduce) {
    #tip::after { animation: none; }
    #tip { transition: none; }
  }

  #melding { position: fixed; left: 14px; right: 14px; bottom: 96px;
             background: rgba(18,18,20,.98); border: 1px solid rgba(255,255,255,.18);
             padding: 14px 18px; border-radius: 16px; box-shadow: 0 8px 30px rgba(0,0,0,.6);
             font-size: 14px; font-weight: 600; line-height: 1.4; color: #fff;
             z-index: 16; opacity: 0; transition: opacity .25s;
             pointer-events: none; text-align: center; }

  /* burgermenu en spelmodi */
  /* De bovenbalk: menu links, je oefening in het midden, jij rechts. Alles
     wat met jou te maken heeft hangt aan je foto, alles wat met spelen te
     maken heeft aan het menu. */
  .mBalk { display: flex; align-items: center; gap: 8px; padding: 0 12px 5px; }
  .mBalk .sportKiezer { flex: 1; min-width: 0; padding: 0; }
  .mBalk2 { display: flex; justify-content: space-between; padding: 0 12px 4px; }
  .hoekKnop { width: 50px; height: 32px; border-radius: 12px; cursor: pointer; font-size: 16px;
              border: 1px solid rgba(255,255,255,.1); background: rgba(255,255,255,.05);
              color: rgba(255,255,255,.75); line-height: 1; }
  /* De drie oefeningen bovenaan. Elke knop is een eigen wereld: eigen
     voortgang, eigen klassement, eigen opdrachten. */
  .sportKiezer { display: flex; gap: 6px; padding: 0 12px 10px; }
  .sportKnop { flex: 1; padding: 9px 0; border-radius: 12px; cursor: pointer;
               border: 1px solid rgba(255,255,255,.1); background: rgba(255,255,255,.05);
               color: rgba(255,255,255,.55); font: inherit; font-size: 12px;
               font-weight: 800; letter-spacing: 1px; }
  .sportKnop.aan { background: rgba(255,199,64,.16); border-color: rgba(255,199,64,.5);
                   color: #ffc740; }
  #burger, #accountKnop {
    flex: none; background: rgba(255,255,255,.07); border: 0; border-radius: 14px;
    color: rgba(255,255,255,.85); line-height: 1; cursor: pointer; width: 50px; height: 46px; }
  #burger { font-size: 30px; }
  /* Heb je een foto, dan is de knop je foto: rond en van rand tot rand. */
  #accountKnop { font-size: 22px; position: relative; overflow: hidden; padding: 0; }
  #accountKnop.foto { border-radius: 50%; width: 46px; }
  #accountKnop img { width: 100%; height: 100%; border-radius: 50%; object-fit: cover;
                     display: block; }
  /* eigen foto */
  .fotoRond { border-radius: 50%; object-fit: cover; display: block;
              background: rgba(255,255,255,.08); }
  #accProfiel { display: flex; gap: 14px; align-items: flex-start; margin-bottom: 6px; }
  #accProfiel #accFotoKnop { width: 88px; height: 88px; flex: none; margin: 0; }
  .profielRechts { flex: 1; min-width: 0; }
  .profielRechts .naamRij { margin-top: 6px; }
  .profielRechts .instelLabel { text-align: left; }
  #accFotoKnop { width: 104px; height: 104px; border-radius: 50%; padding: 0; cursor: pointer;
                 border: 2px dashed rgba(255,255,255,.22); background: rgba(255,255,255,.05);
                 overflow: hidden; display: grid; place-items: center; margin: 0 auto 10px; }
  #accFotoKnop.heeft { border-style: solid; border-color: rgba(255,199,64,.55); }
  #accFotoKnop img, #accFotoKnop svg { width: 100%; height: 100%; }
  #accFotoKnop .plus { font-size: 34px; color: rgba(255,255,255,.45); line-height: 1; }
  .fotoRij { display: flex; gap: 16px; margin-top: 4px; }
  .fotoRij .tekstKnop { margin: 0; }
  .fotoHint { font-size: 12px; color: rgba(255,255,255,.4); line-height: 1.45;
              margin: 8px 0 16px; }
  #accountKnop.aan::after { content: ''; position: absolute; right: 7px; top: 7px;
    width: 8px; height: 8px; border-radius: 50%; background: #4ade80; }
  #tandwiel { font-size: 24px; }
  /* Laadscherm: bovenop alles, zodat duidelijk is dat er iets gebeurt. */
  #laden { position: fixed; inset: 0; z-index: 25; background: rgba(0,0,0,.92); display: none;
           place-items: center; text-align: center; padding: 30px; }
  #laden.aan { display: grid; }
  .ladenRing { width: 54px; height: 54px; margin: 0 auto 22px; border-radius: 50%;
               border: 4px solid rgba(255,255,255,.14); border-top-color: #ffc740;
               animation: draaiRing 900ms linear infinite; }
  @keyframes draaiRing { to { transform: rotate(360deg); } }
  .ladenTekst { font-size: 17px; font-weight: 700; }
  .ladenTraag { font-size: 13px; color: rgba(255,255,255,.45); margin-top: 10px;
                min-height: 18px; max-width: 20rem; line-height: 1.4; }
  @media (prefers-reduced-motion: reduce) {
    .ladenRing { animation-duration: 2.4s; }
  }

  #cameraVraag { position: fixed; inset: 0; z-index: 14; background: #000; display: none;
                 place-items: center; text-align: center; padding: 28px; }
  #cameraVraag.aan { display: grid; }
  .cvIcoon { font-size: 54px; margin-bottom: 10px; }
  #cameraVraag h2 { font-size: 26px; font-weight: 900; margin: 0 0 12px; }
  #cameraVraag p { font-size: 15px; line-height: 1.5; color: rgba(255,255,255,.6);
                   margin: 0 0 14px; max-width: 380px; }
  #cameraVraag .cvApparaat { font-size: 13px; color: rgba(255,255,255,.4); margin-bottom: 22px; }
  #cameraVraag .grotKnop { max-width: 340px; margin-left: auto; margin-right: auto; }

  #klassement { position: fixed; inset: 0; z-index: 12; background: #05060a;
                display: none; padding: 30px 18px; overflow-y: auto; }
  #klassement.aan { display: block; }
  #klassement h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px;
                   color: rgba(255,255,255,.5); margin: 0 0 18px; text-align: center; }
  .lbLijst { display: flex; flex-direction: column; gap: 8px; margin-bottom: 18px; }
  .lbRij { display: flex; align-items: center; gap: 12px; width: 100%; text-align: left;
           background: rgba(255,255,255,.05); border: 1px solid transparent; border-radius: 14px;
           padding: 11px 13px; color: inherit; font: inherit; cursor: pointer; }
  .lbRij.jij { border-color: rgba(255,199,64,.55); background: rgba(255,199,64,.09); }
  .lbPlek { width: 24px; flex: none; font-size: 14px; font-weight: 900;
            color: rgba(255,255,255,.4); font-variant-numeric: tabular-nums; }
  .lbBadge { width: 34px; height: 34px; flex: none; }
  .lbNaam { flex: 1; min-width: 0; font-size: 15px; font-weight: 700;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .lbNaam small { display: block; font-size: 11px; font-weight: 500; color: rgba(255,255,255,.45); }
  .lbLevel { font-size: 19px; font-weight: 900; font-variant-numeric: tabular-nums; }
  /* het rangteken staat links van het levelnummer, ook als je een foto hebt */
  .lbNiveau { flex: none; display: flex; align-items: center; gap: 7px; }
  .lbNiveau .lbBadge { width: 22px; height: 22px; }
  .lbMelding { text-align: center; color: rgba(255,255,255,.5); font-size: 14px;
               line-height: 1.5; padding: 30px 10px; }

  #speler { position: fixed; inset: 0; z-index: 13; background: rgba(0,0,0,.94);
            display: none; place-items: center; padding: 24px; }
  #speler.aan { display: grid; }
  .spelerKaart { width: 100%; max-width: 22rem; text-align: center; }
  .spelerBadge { width: 74px; height: 74px; margin: 0 auto 14px; }
  .spelerNaam { font-size: 24px; font-weight: 900; }
  .spelerRang { font-size: 14px; font-weight: 700; margin: 4px 0 20px;
                display: flex; align-items: center; justify-content: center; gap: 8px; }
  .spelerRang .lbBadge { width: 20px; height: 20px; flex: none; }

  #quests { position: fixed; inset: 0; z-index: 12; background: #05060a; display: none;
            padding: 30px 22px; overflow-y: auto; }
  #quests.aan { display: block; }
  #quests h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px;
               color: rgba(255,255,255,.5); margin: 0 0 6px; text-align: center; }
  .qHaal { flex: none; padding: 7px 14px; border-radius: 99px; border: 0; cursor: pointer;
           background: linear-gradient(180deg, #ffc740, #ff9426); color: #000;
           font: inherit; font-size: 12px; font-weight: 900; }
  .qKop { font-size: 11px; font-weight: 800; letter-spacing: 2px;
          color: rgba(255,255,255,.5); margin: 18px 2px 8px; }
  .qRij { position: relative; background: rgba(255,255,255,.05); border-radius: 14px;
          padding: 12px 14px 14px; margin-bottom: 8px; }
  .qRij.af { opacity: .55; }
  .qTekst b { font-size: 14px; font-weight: 700; display: block; padding-right: 64px; }
  .qTekst small { font-size: 11px; color: #ffc740; }
  .qStand { position: absolute; right: 14px; top: 14px; font-size: 13px; font-weight: 800;
            color: rgba(255,255,255,.6); font-variant-numeric: tabular-nums; }
  .qRij.af .qStand { color: #7dde7d; }
  .qBalk { height: 4px; border-radius: 2px; background: rgba(255,255,255,.1);
           margin-top: 8px; overflow: hidden; }
  .qBalk i { display: block; height: 100%;
             background: linear-gradient(to right, #ffc740, #ff9d2e); }

  #inventaris { position: fixed; inset: 0; z-index: 14; background: #05060a; display: none;
                padding: 30px 22px; overflow-y: auto; }
  #inventaris.aan { display: block; }
  #inventaris h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px;
                   color: rgba(255,255,255,.5); margin: 0 0 6px; text-align: center; }
  .invRooster { display: grid; grid-template-columns: repeat(auto-fill, minmax(74px, 1fr)); gap: 8px; }
  .invVak { background: rgba(255,255,255,.05); border-radius: 12px; padding: 8px 4px 6px;
            text-align: center; border: 1px solid transparent; color: inherit; font: inherit;
            cursor: pointer; }
  .invVak.aan { border-color: rgba(255,199,64,.7); background: rgba(255,199,64,.08); }
  .invVak.dicht { opacity: .5; cursor: default; }
  .invBeeld { height: 40px; display: grid; place-items: center; }
  .invBeeld b { font-size: 22px; color: rgba(255,255,255,.35); }
  .invVak span { display: block; font-size: 9px; margin-top: 3px; overflow: hidden;
                 text-overflow: ellipsis; white-space: nowrap; }
  .invDot { display: inline-block; border-radius: 50%; }
  .invT { font-weight: 900; color: #ffc740; line-height: 1; }
  /* De les ligt onder de cameravraag (14), zodat die gewoon werkt. Het
     camerabeeldje (normaal 12) gaat tijdens de les achter het grijs, anders
     hangt je eigen hoofd voor de uitleg. */
  body.lesAan #cam { z-index: 9; }
  body.lesAan #modes { z-index: 9; }
  #les { position: fixed; inset: 0; z-index: 10; display: none; pointer-events: none; }
  #les.aan { display: block; }
  .lesBlok { position: fixed; background: rgba(0,0,0,.78); pointer-events: auto; }
  .lesBubbel { position: fixed; left: 50%; transform: translateX(-50%);
               width: min(92%, 380px); background: #15161a;
               border: 1px solid rgba(255,199,64,.4); border-radius: 16px;
               padding: 16px 18px; text-align: center; pointer-events: auto; }
  #lesTekst { font-size: 14px; line-height: 1.5; }
  #lesKnop { margin-top: 12px; }
  #lesSkip { margin-top: 4px; }
  /* De rollende band bij het openen van een krat */
  #rol { position: fixed; inset: 0; z-index: 29; background: rgba(0,0,0,.88);
         display: none; place-items: center; align-content: center; }
  #rol.aan { display: grid; }
  .rolTitel { font-size: 12px; font-weight: 900; letter-spacing: 3px;
              color: rgba(255,255,255,.5); text-align: center; margin-bottom: 16px; }
  .rolVenster { position: relative; width: min(92vw, 460px); height: 92px;
                overflow: hidden; border-radius: 16px;
                background: linear-gradient(90deg, #0d0d10, #191a20 50%, #0d0d10);
                border: 1px solid rgba(255,255,255,.1); }
  .rolBand { position: absolute; left: 0; top: 8px; display: flex; gap: 10px; will-change: transform; }
  .rolVak { flex: none; width: 66px; height: 76px; border-radius: 12px;
            background: rgba(255,255,255,.05); border: 2px solid rgba(255,255,255,.1);
            display: grid; place-items: center; }
  .rolWijzer { position: absolute; left: 50%; top: 0; bottom: 0; width: 3px;
               margin-left: -1.5px; background: #ffc740;
               box-shadow: 0 0 14px rgba(255,199,64,.9); }

  /* Wereldboss */
  #wb { position: fixed; inset: 0; z-index: 12; background: #08080a; display: none;
        flex-direction: column; align-items: center; padding: 24px 18px 118px; overflow-y: auto; }
  #wb.aan { display: flex; }
  #wb h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5);
           margin: 6px 0 14px; }
  #wbVak { width: 100%; max-width: 420px; display: flex; flex-direction: column;
           align-items: center; flex: 1; min-height: 0; }
  .wbBeeld svg { width: 190px; height: 190px; }
  .wbBalk { width: 100%; height: 16px; border-radius: 99px; background: rgba(255,255,255,.08);
            overflow: hidden; }
  .wbBalk i { display: block; height: 100%; border-radius: 99px;
              background: linear-gradient(90deg, #f2263a, #ff9426); transition: width .3s; }
  .wbHp { font-size: 20px; font-weight: 900; font-variant-numeric: tabular-nums; margin-top: 8px; }
  .wbMee { font-size: 12px; color: rgba(255,255,255,.5); }
  .wbJij { font-size: 14px; font-weight: 800; color: #ffc740; margin-top: 6px; }
  #wbBalkVak { flex: 1; min-height: 0; display: flex; align-items: center; }
  #wbBalkVak .nosebar { height: 100%; max-height: 30vh; margin: 8px 0 0; }
  /* Knoppen boven het klassement om te kiezen waarop gesorteerd wordt */
  .lbSoorten { display: flex; gap: 6px; margin-bottom: 14px; flex-wrap: wrap;
               justify-content: center; }
  .lbSoort { padding: 7px 12px; border-radius: 99px; cursor: pointer; font: inherit;
             font-size: 12px; font-weight: 800; border: 1px solid rgba(255,255,255,.1);
             background: rgba(255,255,255,.05); color: rgba(255,255,255,.55); }
  .lbSoort.aan { background: rgba(255,199,64,.16); border-color: rgba(255,199,64,.5);
                 color: #ffc740; }

  /* Op de maat */
  #mzKies { position: fixed; inset: 0; z-index: 12; background: rgba(0,0,0,.96);
            display: none; padding: 30px 20px; overflow-y: auto; }
  #mzKies.aan { display: block; }
  #mzKies h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; text-align: center;
               color: rgba(255,255,255,.5); margin: 0 0 18px; padding: 8px 46px 0; }
  .mzRij { display: flex; align-items: center; gap: 12px; width: 100%; text-align: left;
           background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
           border-radius: 16px; padding: 14px 16px; margin-bottom: 10px; color: inherit;
           font: inherit; cursor: pointer; }
  .mzRij b { display: block; font-size: 16px; font-weight: 900; }
  .mzRij small { display: block; font-size: 11px; color: rgba(255,255,255,.45); margin-top: 3px; }
  .mzRij .mzBest { flex: none; font-size: 12px; font-weight: 800; color: #ffc740; }
  #mz { position: fixed; inset: 0; z-index: 12; background: #08080a; display: none;
        flex-direction: column; align-items: center; padding: 22px 16px 118px; }
  #mz.aan { display: flex; }
  .mzKop { text-align: center; }
  .mzNaam { font-size: 13px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.55); }
  .mzTeller { font-size: 44px; font-weight: 900; font-variant-numeric: tabular-nums; }
  .mzRingVak { position: relative; width: 220px; height: 220px; display: grid;
               place-items: center; margin: 10px 0; }
  .mzDoel { position: absolute; width: 96px; height: 96px; border-radius: 50%;
            border: 3px solid rgba(255,199,64,.75); }
  .mzRing { position: absolute; width: 96px; height: 96px; border-radius: 50%;
            border: 5px solid #58b6ff; will-change: transform; }
  .mzOordeel { position: absolute; font-size: 20px; font-weight: 900; opacity: 0;
               transition: opacity .25s; }
  .mzBalk { width: min(90%, 360px); height: 8px; border-radius: 99px;
            background: rgba(255,255,255,.08); overflow: hidden; }
  .mzBalk i { display: block; height: 100%; border-radius: 99px; background: #ffc740; width: 0; }
  .mzScore { font-size: 13px; color: rgba(255,255,255,.5); margin-top: 10px; }
  #mzBalkVak { flex: 1; min-height: 0; display: flex; align-items: center; }
  #mzBalkVak .nosebar { height: 100%; max-height: 34vh; margin: 0; }
  #mzUit { position: fixed; inset: 0; z-index: 13; display: none; place-items: center;
           background: rgba(0,0,0,.93); text-align: center; padding: 24px; }
  #mzUit.aan { display: grid; }
  #mzUit .kop { font-size: 36px; font-weight: 900; }
  #mzUit .score { font-size: 18px; font-weight: 700; margin-top: 10px; }
  #mzUit .beloning { font-size: 24px; font-weight: 900; color: #ffc740; margin-top: 12px; }

  /* Het seizoenspad */
  #pad { position: fixed; inset: 0; z-index: 13; background: #05060a;
         display: none; padding: 30px 20px 16px; flex-direction: column; }
  #pad.aan { display: flex; }
  #pad h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; text-align: center;
            color: rgba(255,255,255,.5); margin: 0 0 16px; padding: 8px 46px 0; }
  .padBalk { height: 12px; border-radius: 99px; background: rgba(255,255,255,.08);
             overflow: hidden; }
  .padBalk i { display: block; height: 100%; border-radius: 99px;
               background: linear-gradient(90deg, #ffc740, #ff7326); }
  .padBalkTekst { text-align: center; font-size: 13px; font-weight: 800; margin-top: 8px; }
  .padRest { text-align: center; font-size: 12px; color: rgba(255,255,255,.45); margin-bottom: 16px; }
  /* Het pad loopt langs je arena's: per arena een blokje met vier vakjes,
     drie kleine en de boss. Verticaal, want de reeks houdt nooit op. */
  #padLijst { overflow-y: auto; flex: 1; min-height: 0; padding: 0 2px 10px; position: relative; }
  .padArena { border-radius: 16px; padding: 10px 10px 12px; margin-bottom: 10px;
              background: rgba(255,255,255,.035); border: 1px solid rgba(255,255,255,.07); }
  .padArena.nu { border-color: rgba(255,199,64,.45); background: rgba(255,199,64,.06); }
  .padArena.later { opacity: .5; }
  .padArenaKop { display: flex; align-items: center; gap: 9px; margin-bottom: 9px; }
  .padArenaIcoon { width: 30px; height: 30px; flex: none; }
  .padArenaKop span { display: flex; flex-direction: column; line-height: 1.25;
                      font-size: 13px; font-weight: 700; min-width: 0; }
  .padArenaKop b { font-size: 10px; font-weight: 900; letter-spacing: 1.5px;
                   color: rgba(255,255,255,.4); }
  .padVakken { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 6px; }
  .padVak { display: flex; flex-direction: column; align-items: center; gap: 3px;
            padding: 8px 4px 9px; border-radius: 12px; background: rgba(255,255,255,.04);
            border: 1px solid rgba(255,255,255,.07); opacity: .6; }
  .padVak.open { opacity: 1; border-color: rgba(255,199,64,.4); }
  .padVak.gehaald { opacity: .85; border-color: rgba(74,222,128,.3); }
  .padVak.boss { background: rgba(242,38,58,.07); }
  .padVakKop { font-size: 8px; font-weight: 900; letter-spacing: 0;
               color: rgba(255,255,255,.4); text-transform: uppercase; text-align: center;
               white-space: nowrap; }
  .padVak.boss .padVakKop { color: #f2263a; }
  .padBeeld { font-size: 19px; line-height: 1; color: #ffc740; }
  .padGetal { font-size: 17px; font-weight: 900; line-height: 1; color: #ffc740; }
  .padEenheid { font-size: 9px; font-weight: 700; color: rgba(255,255,255,.6); }
  .padKrat { font-size: 9px; font-weight: 800; text-align: center; line-height: 1.2; }
  .padHaal { margin-top: 2px; padding: 5px 12px; border-radius: 99px; border: 0; cursor: pointer;
             background: linear-gradient(180deg, #ffc740, #ff9426); color: #000;
             font: inherit; font-size: 11px; font-weight: 900; }
  .padStaat { margin-top: 2px; font-size: 9px; color: rgba(255,255,255,.45); text-align: center; }
  .padStaat.af { color: #4ade80; font-weight: 800; }
  .padAlles { display: block; margin: 0 auto 10px; padding: 8px 20px; border-radius: 99px;
              border: 1px solid rgba(255,199,64,.5); background: rgba(255,199,64,.12);
              color: #ffc740; font: inherit; font-size: 12px; font-weight: 900; cursor: pointer; }
  .padAlles[hidden] { display: none; }
  .padUitleg { font-size: 12px; color: rgba(255,255,255,.45); line-height: 1.5;
               margin-top: 16px; }

  /* Het kansenscherm achter het vraagteken op een krat */
  #kansen { position: fixed; inset: 0; z-index: 31; background: rgba(0,0,0,.96);
            display: none; padding: 30px 22px; overflow-y: auto; }
  #kansen.aan { display: block; }
  #kansen h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; text-align: center;
               color: rgba(255,255,255,.5); margin: 0 0 18px; padding: 8px 46px 0; }
  .kansBlok { margin-bottom: 20px; }
  .kansKop { display: flex; justify-content: space-between; align-items: baseline;
             font-size: 14px; font-weight: 900; margin-bottom: 8px; }
  .kansBalk { height: 8px; border-radius: 99px; background: rgba(255,255,255,.08);
              overflow: hidden; margin-bottom: 10px; }
  .kansBalk i { display: block; height: 100%; border-radius: 99px; }
  .kansRooster { display: grid; grid-template-columns: repeat(auto-fill, minmax(78px, 1fr));
                 gap: 8px; }
  .kansVak { background: rgba(255,255,255,.05); border-radius: 12px; padding: 10px 4px;
             text-align: center; }
  .kansVak.heb { outline: 2px solid rgba(255,199,64,.5); }
  .kansVak span { display: block; font-size: 9px; color: rgba(255,255,255,.5); margin-top: 4px; }
  .kansVoet { font-size: 12px; color: rgba(255,255,255,.45); line-height: 1.5; margin-top: 6px; }

  #buit { position: fixed; inset: 0; z-index: 30; background: rgba(0,0,0,.8);
          display: none; place-items: center; }
  #buit.aan { display: grid; }
  .buitKaart { background: #15161a; border-radius: 20px; padding: 28px 40px;
               text-align: center; max-width: 82%; }
  .buitGraad { font-size: 11px; font-weight: 900; letter-spacing: 2px; }
  .buitBeeld { margin: 14px 0 10px; display: grid; place-items: center; }
  .buitNaam { font-size: 20px; font-weight: 900; }
  .buitStatus { margin-top: 8px; font-size: 12px; color: rgba(255,255,255,.6); }
  .buitStatus b { color: #7dde7d; letter-spacing: 2px; }

  #account { position: fixed; inset: 0; z-index: 12; background: #05060a; display: none;
             padding: 30px 22px; overflow-y: auto; }
  #account.aan { display: block; }
  #account h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5);
                margin: 0 0 14px; text-align: center; }
  .accStatus { font-size: 13px; color: rgba(255,255,255,.6); text-align: center;
               line-height: 1.45; margin-bottom: 20px; }
  .accSportKop { text-align: left; margin: 4px 0 8px; }
  .accSportRij { padding: 0 0 12px; }
  .accCijfers { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 22px; }
  .accCijfer { background: rgba(255,255,255,.05); border-radius: 14px; padding: 12px 6px; text-align: center; }
  .accCijfer b { display: block; font-size: 22px; font-weight: 900; font-variant-numeric: tabular-nums; }
  .accCijfer span { font-size: 10px; color: rgba(255,255,255,.5); }
  .trofeeKop { margin: 16px 2px 8px; font-size: 11px; font-weight: 800;
               letter-spacing: 2px; color: rgba(255,255,255,.5); }
  /* Geen maximumhoogte: de kast loopt gewoon door, het scherm zelf scrolt. */
  .trofeeKast { display: grid; grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
                gap: 8px; }
  .trofee { background: rgba(255,255,255,.05); border-radius: 12px;
            padding: 8px 4px 6px; text-align: center; }
  .trofee svg { width: 38px; height: 38px; display: block; margin: 0 auto; }
  .trofee span { font-size: 9px; color: rgba(255,255,255,.55); display: block;
                 margin-top: 3px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .trofee.dicht { opacity: .4; }
  .trofee.dicht b { display: block; font-size: 26px; font-weight: 900; line-height: 38px;
                    color: rgba(255,255,255,.5); }
  .trofeeLeeg { grid-column: 1 / -1; font-size: 12px; color: rgba(255,255,255,.4); }
  #accNaam { margin-bottom: 22px; }
  #accNaam .instelLabel { text-align: left; margin-bottom: 8px; }
  .naamRij { display: flex; gap: 8px; }
  .naamRij input { flex: 1; min-width: 0; margin-bottom: 0 !important; }
  #naamOpslaan { flex: none; border: 0; border-radius: 14px; font: inherit; font-size: 14px;
                 font-weight: 800; padding: 0 18px; cursor: pointer;
                 background: #ffc740; color: #000; }
  #naamOpslaan:disabled { background: rgba(255,255,255,.08); color: rgba(255,255,255,.35);
                          cursor: default; }
  #accNaam input, #accProfiel input, #accFormulier input { width: 100%; margin-bottom: 10px; padding: 14px 16px; border-radius: 14px;
    border: 1px solid rgba(255,255,255,.15); background: rgba(255,255,255,.06); color: #fff;
    font: inherit; font-size: 16px; }
  #accFormulier input::placeholder, #accProfiel input::placeholder { color: rgba(255,255,255,.35); }
  .pwEisen { font-size: 12px; line-height: 1.6; margin: 2px 0 8px; color: rgba(255,255,255,.45); }
  .pwEisen .kop { font-weight: 700; color: rgba(255,255,255,.6); }
  .pwEisen div { display: flex; gap: 7px; align-items: baseline; }
  .pwEisen .goed { color: #4ade80; }
  .pwEisen .teken { width: 12px; flex: none; }
  .accPrive { font-size: 11px; color: rgba(255,255,255,.4); margin-top: 2px; }
  /* De inventaris hoort bij je spullen, niet bij het afsluiten; hij staat
     daarom boven bij je cijfers en is een echte knop. */
  .accKnopBreed { display: block; width: 100%; margin: 2px 0 24px; padding: 13px 0;
                  border-radius: 14px; border: 1px solid rgba(255,255,255,.14);
                  background: rgba(255,255,255,.06); color: #fff; font: inherit;
                  font-size: 15px; font-weight: 800; cursor: pointer; }
  /* Sluiten is een kruisje rechtsboven en blijft in beeld terwijl je scrolt.
     Uitloggen staat daardoor alleen onderaan, ver van alles vandaan. */
  .sluitKruis { position: fixed; right: 12px; top: 12px; z-index: 4;
                width: 44px; height: 44px; border-radius: 50%; cursor: pointer;
                border: 1px solid rgba(255,255,255,.14); background: rgba(18,18,22,.92);
                color: rgba(255,255,255,.8); font-size: 19px; line-height: 1; }
  .sluitKruis:active { background: rgba(255,255,255,.14); }
  .uitlogVak { display: flex; justify-content: center; margin-top: 54px; padding: 26px 0 12px;
               border-top: 1px solid rgba(255,255,255,.08); }
  .uitlogKnop { padding: 11px 28px; border-radius: 99px; cursor: pointer; font: inherit;
                font-size: 14px; font-weight: 800; letter-spacing: .5px;
                border: 1px solid rgba(242,38,58,.4); background: rgba(242,38,58,.08);
                color: #ff6b7d; }
  .uitlogKnop.zeker { border-color: #f2263a; background: rgba(242,38,58,.18); color: #fff; }
  .accMelding { font-size: 13px; text-align: center; min-height: 34px; line-height: 1.4;
                color: #ffc740; padding: 6px 0; font-weight: 600; }

  #instel { position: fixed; inset: 0; z-index: 12; background: #05060a; display: none;
            padding: 60px 22px; }
  #instel.aan { display: block; }
  #instel h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5);
               margin: 0 0 22px; text-align: center; }
  .instelLabel { font-size: 11px; font-weight: 900; letter-spacing: 3px;
                 color: rgba(255,255,255,.5); text-align: center; }
  .instelWaarde { font-size: 20px; font-weight: 900; text-align: center; color: #ffc740; margin-top: 6px; }
  .instelUitleg { font-size: 12px; color: rgba(255,255,255,.45); text-align: center;
                  margin-top: 8px; line-height: 1.45; }
  #diepte, #geluid, #muziek { width: 100%; margin: 16px 0 0; accent-color: #ffc740; height: 30px; }

  #modes { position: fixed; inset: 0; z-index: 12; background: #05060a; display: none;
           padding: 60px 20px; }
  #modes.aan { display: block; }
  #modes h2 { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5);
              margin: 0 0 16px; text-align: center; }
  .modeKaart { display: flex; align-items: center; gap: 16px; width: 100%; text-align: left;
               background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.1);
               border-radius: 18px; padding: 18px; margin-bottom: 12px; color: inherit;
               font: inherit; cursor: pointer; }
  .modeIcoon { width: 46px; height: 46px; flex: none; }
  .modeTekst { min-width: 0; }
  .modeKaart.aan { border-color: #ffc740; background: rgba(255,199,64,.1); }
  .modeKaart b { display: block; font-size: 19px; font-weight: 900; }
  .modeKaart span { font-size: 13px; color: rgba(255,255,255,.5); }
  /* duel */
  #duel { position: fixed; inset: 0; z-index: 7; background: #000; display: none;
          flex-direction: column; padding: 20px 0 24px; }
  #duel.aan { display: flex; }
  .duelKop { text-align: center; padding: 0 20px; }
  .duelTitel { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.5); }
  .duelKlok { font-size: 62px; font-weight: 900; font-variant-numeric: tabular-nums; margin-top: 4px; }
  .duelKlok.krap { color: #f2263a; }
  .duelVak { flex: 1; display: flex; align-items: center; }
  .duelKolom { flex: 1; min-width: 0; padding: 0 20px; }
  .racer { margin-bottom: 26px; }
  .racerKop { display: flex; justify-content: space-between; align-items: baseline; }
  .racerNaam { font-size: 13px; font-weight: 900; letter-spacing: 2px; }
  .racerTal { font-size: 34px; font-weight: 900; font-variant-numeric: tabular-nums; }
  .racerSpoor { height: 14px; border-radius: 99px; background: rgba(255,255,255,.09);
                overflow: hidden; margin-top: 6px; }
  .racerVul { height: 100%; border-radius: 99px; transition: width .2s; }
  .duelDoel { font-size: 11px; color: rgba(255,255,255,.4); margin-top: 5px; }

  #duelSetup { position: fixed; inset: 0; z-index: 11; background: #000; display: none;
               flex-direction: column; justify-content: center; padding: 30px 24px; }
  #duelSetup.aan { display: flex; }
  #duelSetup h2 { font-size: 26px; font-weight: 900; text-align: center; margin: 0 0 6px; }
  #duelSetup p { font-size: 14px; color: rgba(255,255,255,.5); text-align: center; margin: 0 0 26px; }
  .schuifWaarde { font-size: 66px; font-weight: 900; text-align: center; line-height: 1; }
  .schuifLabel { font-size: 11px; font-weight: 900; letter-spacing: 3px; text-align: center;
                 color: rgba(255,255,255,.5); margin-bottom: 10px; }
  #niveau { width: 100%; margin: 18px 0 6px; accent-color: #ffc740; height: 30px; }
  .duelInfo { text-align: center; font-size: 15px; font-weight: 700; margin-top: 6px; }
  .duelWaarschuwing { text-align: center; font-size: 12px; color: #f2263a; margin-top: 8px; min-height: 16px; }
  .duelBeste { text-align: center; font-size: 12px; color: rgba(255,255,255,.4); margin-top: 4px; }
  .grotKnop { display: block; width: 100%; margin-top: 26px; padding: 17px 0; border: 0;
              border-radius: 99px; font: inherit; font-size: 20px; font-weight: 900; letter-spacing: 3px;
              color: #000; cursor: pointer; background: linear-gradient(180deg, #ffc740, #ff7326); }
  .tekstKnop { display: block; margin: 14px auto 0; background: none; border: 0; font: inherit;
               font-size: 14px; color: rgba(255,255,255,.45); cursor: pointer; }

  #duelAftel { position: fixed; inset: 0; z-index: 13; display: none; place-items: center;
               background: rgba(0,0,0,.9); font-size: 92px; font-weight: 900; color: #ffc740; }
  #duelAftel.aan { display: grid; }
  #duelUit { position: fixed; inset: 0; z-index: 13; display: none; place-items: center;
             background: rgba(0,0,0,.93); text-align: center; padding: 24px; }
  #duelUit.aan { display: grid; }
  #duelUit .kop { font-size: 40px; font-weight: 900; }
  #duelUit .score { font-size: 18px; font-weight: 700; margin-top: 10px; }
  #duelUit .beloning { font-size: 26px; font-weight: 900; color: #ffc740; margin-top: 14px; }

  /* online duel: dezelfde opbouw als het duel, maar tegen een echt mens.
     De tegenstander is groen in plaats van paars, zodat je in één oogopslag
     ziet dat er iemand anders meekijkt. */
  #olLobby { position: fixed; inset: 0; z-index: 11; background: #000; display: none;
             flex-direction: column; justify-content: center; padding: 30px 24px; overflow-y: auto; }
  #olLobby.aan { display: flex; }
  #olLobby h2 { font-size: 26px; font-weight: 900; text-align: center; margin: 0 0 6px; }
  .olSub { font-size: 14px; color: rgba(255,255,255,.5); text-align: center;
           margin: 0 0 20px; line-height: 1.45; }
  .olStatus { text-align: center; font-size: 13px; color: rgba(255,255,255,.5);
              min-height: 18px; margin-top: 14px; }
  .olNaamKop { font-size: 11px; font-weight: 900; letter-spacing: 3px;
               color: rgba(255,255,255,.5); margin-bottom: 8px; }
  .olVriend { border-top: 1px solid rgba(255,255,255,.1); margin-top: 22px;
              padding-top: 16px; display: none; }
  .olVriend.aan { display: block; }
  .olRij { display: flex; gap: 8px; margin-top: 10px; }
  .olRij input { flex: 1; min-width: 0; padding: 13px 16px; border-radius: 14px;
                 border: 1px solid rgba(255,255,255,.15); background: rgba(255,255,255,.06);
                 color: #fff; font: inherit; font-size: 16px; }
  #olCode { text-transform: uppercase; letter-spacing: 8px; text-align: center; font-weight: 900; }
  .olKnop { flex: none; border: 0; border-radius: 14px; font: inherit; font-size: 14px;
            font-weight: 800; padding: 0 20px; background: #ffc740; color: #000; cursor: pointer; }
  .olKnop.rustig { width: 100%; padding: 14px 0; background: rgba(255,255,255,.1); color: #fff; }

  #olWacht { position: fixed; inset: 0; z-index: 13; background: rgba(0,0,0,.95); display: none;
             place-items: center; text-align: center; padding: 30px; }
  #olWacht.aan { display: grid; }
  .olWachtTekst { font-size: 18px; font-weight: 700; }
  .olCodeGroot { font-size: 52px; font-weight: 900; letter-spacing: 10px; color: #ffc740;
                 margin: 14px 0 4px; min-height: 10px; }
  .olWachtSub { font-size: 13px; color: rgba(255,255,255,.45); line-height: 1.5;
                max-width: 21rem; margin: 8px auto 0; }

  /* onderaan extra ruimte: daar staat de camerabalk overheen */
  #odu { position: fixed; inset: 0; z-index: 7; background: #000; display: none;
         flex-direction: column; padding: 20px 0 118px; }
  #odu.aan { display: flex; }
  #oduUit { position: fixed; inset: 0; z-index: 13; display: none; place-items: center;
            background: rgba(0,0,0,.93); text-align: center; padding: 24px; }
  #oduUit.aan { display: grid; }
  #oduUit .kop { font-size: 40px; font-weight: 900; }
  #oduUit .score { font-size: 18px; font-weight: 700; margin-top: 10px; }
  #oduUit .beloning { font-size: 26px; font-weight: 900; color: #ffc740; margin-top: 14px; }

  /* clicker */
  #klik { position: fixed; inset: 0; z-index: 11; background: #08080a; display: none;
          flex-direction: column; }
  #klik.aan { display: flex; }
  .klikKop { flex: none; text-align: center; padding: 14px 58px 8px; position: relative; }
  .klikSaldo { font-size: 40px; font-weight: 900; font-variant-numeric: tabular-nums; line-height: 1.1; }
  .klikEenheid { font-size: 11px; font-weight: 900; letter-spacing: 3px;
                 color: rgba(255,255,255,.45); }
  .klikTempo { font-size: 13px; color: #ffc740; font-weight: 700; margin-top: 4px; min-height: 18px; }
  .klikBoosts { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; margin-top: 6px; }
  .klikBoost { font-size: 11px; font-weight: 800; padding: 4px 10px; border-radius: 99px;
               background: rgba(255,199,64,.15); color: #ffc740; }
  .klikBoost.woede { background: rgba(242,38,58,.2); color: #ff6b7d; }

  .klikVak { flex: none; display: grid; place-items: center; padding: 6px 0 2px; position: relative; }
  #klikKnop { width: 150px; height: 150px; border-radius: 50%; border: 0; cursor: pointer;
              background: radial-gradient(circle at 50% 35%, #ffd873, #ff7326 70%, #b8460f);
              box-shadow: 0 10px 30px rgba(255,140,40,.35); padding: 22px;
              -webkit-tap-highlight-color: transparent; touch-action: manipulation; }
  #klikKnop:active { transform: scale(.94); box-shadow: 0 4px 14px rgba(255,140,40,.3); }
  #klikKnop svg { width: 100%; height: 100%; display: block; fill: #2a1200; }
  @media (prefers-reduced-motion: reduce) { #klikKnop:active { transform: none; } }
  .klikPluim { position: absolute; font-size: 20px; font-weight: 900; color: #ffc740;
               pointer-events: none; animation: klikOp 900ms ease-out forwards; text-shadow: 0 0 10px rgba(255,199,64,.6); }
  @keyframes klikOp { to { transform: translateY(-70px); opacity: 0; } }
  .klikTrainTekst { font-size: 13px; font-weight: 900; letter-spacing: 2px; color: #ffc740;
                    margin-top: 10px; }
  .klikTik { font-size: 12px; color: rgba(255,255,255,.4); text-align: center; margin: 6px auto 0;
             line-height: 1.5; max-width: 26rem; padding: 0 16px; }
  #klikBalkVak { display: none; }
  #klik.trainen #klikBalkVak { display: flex; flex: 1; min-height: 0;
                               align-items: center; justify-content: center; }
  #klik.trainen #klikBalkVak .nosebar { height: 100%; max-height: 40vh; margin: 8px 0 0; }
  #klik.trainen .klikTabs, #klik.trainen .klikLijst { display: none; }
  .klikItem.dicht b { color: rgba(255,255,255,.45); letter-spacing: 4px; }
  .klikItem.dicht small { font-style: italic; }

  .klikTabs { flex: none; display: flex; gap: 6px; padding: 10px 12px 8px; }
  .klikTab { flex: 1; background: rgba(255,255,255,.06); border: 0; border-radius: 12px;
             color: rgba(255,255,255,.55); font: inherit; font-size: 13px; font-weight: 800;
             padding: 10px 0; cursor: pointer; }
  .klikTab.aan { background: rgba(255,199,64,.16); color: #ffc740; }
  .klikLijst { flex: 1; overflow-y: auto; padding: 0 12px 20px;
               -webkit-overflow-scrolling: touch; }
  /* Het vraagteken zit in de bovenhoek; de prijs schuift eronder, zodat ze
     elkaar niet raken. */
  .kratVraag { position: absolute; right: 10px; top: 10px; width: 26px; height: 26px;
               border-radius: 50%; display: grid; place-items: center; cursor: pointer;
               background: rgba(255,255,255,.12); color: rgba(255,255,255,.8);
               font-size: 14px; font-weight: 900; line-height: 1; }
  .klikItem.metVraag { padding-top: 16px; padding-bottom: 14px; }
  .klikItem.metVraag .klikPrijs { align-self: flex-end; padding-top: 22px; }
  .klikItem { position: relative; display: flex; align-items: center; gap: 12px; width: 100%; text-align: left;
              background: rgba(255,255,255,.05); border: 1px solid rgba(255,255,255,.07);
              border-radius: 14px; padding: 12px 14px; margin-bottom: 8px; color: inherit;
              font: inherit; cursor: pointer; opacity: .45; }
  .klikItem.kan { opacity: 1; border-color: rgba(255,199,64,.35); }
  .klikItem b { display: block; font-size: 15px; font-weight: 900; }
  .klikItem small { display: block; font-size: 11px; color: rgba(255,255,255,.45);
                    line-height: 1.35; margin-top: 2px; }
  .klikItemTekst { flex: 1; min-width: 0; }
  .klikPrijs { flex: none; text-align: right; }
  .klikPrijs b { font-size: 15px; font-weight: 900; color: #ffc740; }
  .klikPrijs small { font-size: 10px; color: rgba(255,255,255,.4); }
  .klikMelding { font-size: 13px; color: rgba(255,255,255,.45); text-align: center;
                 line-height: 1.5; padding: 20px 10px; }
  #gouden { position: absolute; width: 74px; height: 74px; border: 0; padding: 10px;
            border-radius: 50%; cursor: pointer; display: none; z-index: 3;
            background: radial-gradient(circle at 40% 30%, #fff3c4, #ffc740 60%, #d98800);
            box-shadow: 0 0 26px rgba(255,199,64,.75); animation: goudPols 1s ease-in-out infinite; }
  #gouden.aan { display: block; }
  #gouden svg { width: 100%; height: 100%; fill: #4a2c00; }
  @keyframes goudPols { 50% { transform: scale(1.12); } }
  @media (prefers-reduced-motion: reduce) { #gouden { animation: none; } }

  /* camera */
  #camBtn { margin-top: 10px; background: rgba(255,255,255,.1); border: 1px solid rgba(255,255,255,.2);
            color: #fff; font: inherit; font-size: 13px; font-weight: 700; padding: 9px 18px;
            border-radius: 99px; cursor: pointer; }
  #camBtn.on { background: rgba(56,200,90,.18); border-color: rgba(56,200,90,.5); color: #6ee88a; }
  #calBtn { display: none; margin: 10px 0 0 8px; background: none; border: 0; color: rgba(255,255,255,.5);
            font: inherit; font-size: 13px; cursor: pointer; }
  #calBtn.on { display: inline-block; }
  #cam { position: fixed; left: 10px; top: 84px; width: 120px; z-index: 12; display: none; }
  #cam.on { display: block; }
  #video { width: 120px; border-radius: 10px; transform: scaleX(-1); display: block;
           border: 1px solid rgba(255,255,255,.2); background: #111; }
  #dot { position: absolute; left: 0; top: 0; width: 120px; pointer-events: none; transform: scaleX(-1); }
  #camState { font-size: 9px; color: rgba(255,255,255,.5); margin-top: 3px; text-align: center; }

  #calib { position: fixed; inset: 0; background: rgba(0,0,0,.93); z-index: 10; display: none;
           place-items: center; text-align: center; }
  #calib.on { display: grid; }
  .cnum { font-size: 12px; font-weight: 900; letter-spacing: 3px; color: rgba(255,255,255,.55); }
  .ctitle { font-size: 28px; font-weight: 800; margin: 14px 0 12px; }
  .ctext { font-size: 15px; color: rgba(255,255,255,.55); padding: 0 32px; max-width: 420px; margin: 0 auto; }
  .ccount { font-size: 68px; font-weight: 900; color: #ffc740; min-height: 10px; }
  .cbtn { margin-top: 18px; background: #ffc740; border: 0; color: #000; font: inherit; font-size: 17px;
          font-weight: 800; padding: 13px 34px; border-radius: 99px; cursor: pointer; }
  .cbtn:disabled { background: #555; color: #999; cursor: default; }
  .cskip { display: block; margin: 14px auto 0; background: none; border: 0; color: rgba(255,255,255,.45);
           font: inherit; font-size: 14px; cursor: pointer; }
  #fatal { position: fixed; inset: 0; background: #140505; color: #ffb4b4; z-index: 99; display: none;
           padding: 30px; font-size: 14px; line-height: 1.5; overflow: auto; }
  #fatal.on { display: block; }
  #fatal b { color: #fff; font-size: 17px; display: block; margin-bottom: 10px; }
</style>

<div id="menu">
  <div id="menuAura"></div>
  <div class="menuVak">
    <div class="mBalk">
      <button id="burger" aria-label="menu">☰</button>
      <div class="sportKiezer" id="sportKiezer"></div>
      <button id="accountKnop" aria-label="account">👤</button>
    </div>
    <div class="mBalk2">
      <button class="hoekKnop" id="klassementKnop" aria-label="klassement">🏆</button>
      <button class="hoekKnop" id="tandwiel" aria-label="instellingen">⚙</button>
    </div>
    <h1 class="mTitel">PUSH BATTLE</h1>
    <div class="mRang" id="mRang"></div>
    <div class="mXp">
      <div class="mXpBar"><div class="mXpVul" id="mXpVul"></div></div>
      <div class="mXpTekst" id="mXpTekst"></div>
    </div>

    <div class="mKaart">
      <div class="mPadTip" id="mPadTip" hidden>🎖️ <span id="mPadTipTal"></span></div>
      <div class="mArenaLabel" id="mArenaLabel"></div>
      <div class="mArenaNaam" id="mArenaNaam"></div>
      <svg class="mIcoon" id="mIcoon" viewBox="0 0 100 100" role="button"></svg>
      <div class="mVijand" id="mVijand"></div>
      <div class="mHp" id="mHp"></div>
      <div class="mPips" id="mPips"></div>
    </div>

    <div class="mOnder">
      <button class="mQuest" id="questKnop">📜 <span id="extraQuests"></span><i id="questBadge"></i></button>
    </div>
    <div class="mKop">HIERNA</div>
    <div class="mRij" id="mRij"></div>

    <button id="vechten">VECHTEN</button>
  </div>
</div>

<div id="aura"></div>
<div id="stage" class="uit">
  <button id="terug">‹</button>
  <div class="top">
    <div class="toprow">
      <div class="streak">🔥 <span id="streak">0</span></div>
      <div class="arena-label">
        <div class="arena-name" id="arenaName"></div>
        <div class="arena-num" id="arenaNum"></div>
      </div>
      <div class="reps" id="reps">0</div>
    </div>
    <div class="xpStrip">
      <div class="xpNiveau" id="xpNiveau">1</div>
      <div class="xpSpoor"><div class="xpVul" id="xpVul"></div></div>
      <div class="xpTekst" id="xpTekst"></div>
    </div>
    <div class="pips" id="pips"></div>
  </div>

  <div class="middle">
    <div class="arenaCol">
      <div>
        <div class="boss-tag" id="bossTag" style="display:none">BOSS</div>
        <div class="enemy-name" id="enemyName"></div>
        <div class="race" id="raceLine"></div>
      </div>
      <div id="orbwrap">
        <div id="glow"></div>
        <div id="bossRing"></div>
        <svg id="enemySvg" viewBox="0 0 100 100"></svg>
      </div>
      <div class="hpwrap">
        <div class="hpbar"><div class="hpfill" id="hpfill"></div></div>
        <div class="hptext" id="hptext"></div>
      </div>
    </div>
    <div class="nosebar" id="nosebar">
      <div class="track"><div class="trackfill" id="trackfill"></div></div>
      <div class="mark" id="markUp"><span>boven</span><i></i></div>
      <div class="mark" id="markDown"><span>beneden</span><i></i></div>
      <div class="knob" id="knob"></div>
    </div>
  </div>

  <div class="bottom">
    <div class="combo" id="combo"></div>
  </div>
</div>

<div id="cambalk">
  <div class="hint" id="hint"></div>
  <button id="camBtn"></button>
  <button id="calBtn"></button>
</div>

<div id="cam">
  <video id="video" playsinline muted autoplay></video>
  <canvas id="dot"></canvas>
  <div id="camState">camera uit</div>
</div>

<div id="calib">
  <div>
    <div class="cnum" id="calStep">STAP 1 VAN 2</div>
    <div class="ctitle" id="calTitle">Strek je armen</div>
    <div class="ctext" id="calText">Ga in plankhouding met gestrekte armen. Dit wordt je bovenste stand.</div>
    <div class="ccount" id="calCount"></div>
    <button class="cbtn" id="calGo">Vastleggen</button>
    <button class="cskip" id="calSkip">Annuleren</button>
  </div>
</div>

<div id="banner"></div>
<div id="intro">
  <div>
    <div class="num" id="introNum"></div>
    <div class="nm" id="introName"></div>
    <div class="rule" id="introRule"></div>
    <div class="rc" id="introRace"></div>
    <div class="it" id="introText"></div>
  </div>
</div>
<div id="modes">
  <button class="sluitKruis" id="modesDicht" aria-label="sluiten">✕</button>
  <h2 id="modesKop"></h2>
  <button class="modeKaart" id="modeArena">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>
  <button class="modeKaart" id="modeDuel">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>
  <button class="modeKaart" id="modeOnline">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>
  <button class="modeKaart" id="modeBoss">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>
  <button class="modeKaart" id="modeMuziek">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>
  <button class="modeKaart" id="modeKlik">
    <svg class="modeIcoon" viewBox="0 0 100 100"><path/></svg>
    <div class="modeTekst"><b></b><span></span></div>
  </button>

</div>

<div id="klassement">
  <button class="sluitKruis" id="lbDicht" aria-label="sluiten">✕</button>
  <h2 id="klassementKop"></h2>
  <div class="lbSoorten" id="lbSoorten"></div>
  <div class="lbLijst" id="lbLijst"></div>
</div>

<div id="speler">
  <button class="sluitKruis" id="spelerDicht" aria-label="sluiten">✕</button>
  <div class="spelerKaart">
    <div class="spelerBadge" id="spelerBadge"></div>
    <div class="spelerNaam" id="spelerNaam"></div>
    <div class="spelerRang" id="spelerRang"></div>
    <div class="accCijfers" id="spelerCijfers"></div>
    <button class="tekstKnop" id="spelerMeld"></button>
  </div>
</div>

<div id="quests">
  <button class="sluitKruis" id="questsDicht" aria-label="sluiten">✕</button>
  <h2 id="questsKop"></h2>
  <div id="questsLijst"></div>
</div>

<div id="inventaris">
  <button class="sluitKruis" id="invDicht" aria-label="sluiten">✕</button>
  <h2 id="invKop"></h2>
  <div id="invLijst"></div>
  <div class="trofeeKop" id="trofeeKop"></div>
  <div class="trofeeKast" id="trofeeKast"></div>
</div>

<div id="buit">
  <div class="buitKaart" id="buitKaart"></div>
</div>

<div id="rol">
  <div class="rolTitel" id="rolTitel"></div>
  <div class="rolVenster" id="rolVenster">
    <div class="rolBand" id="rolBand"></div>
    <div class="rolWijzer"></div>
  </div>
</div>

<div id="wb">
  <button class="sluitKruis" id="wbDicht" aria-label="sluiten">✕</button>
  <h2 id="wbKop"></h2>
  <div id="wbGeenAccount">
    <p class="olSub" id="wbAccountTekst"></p>
    <button class="grotKnop" id="wbNaarAccount"></button>
  </div>
  <div id="wbVak">
    <div class="wbBeeld"><svg viewBox="0 0 100 100" id="wbSvg"></svg></div>
    <div class="wbBalk"><i id="wbVul"></i></div>
    <div class="wbHp" id="wbHp"></div>
    <div class="wbMee" id="wbMee"></div>
    <div class="wbJij" id="wbJij"></div>
    <div id="wbBalkVak"></div>
    <div class="padUitleg" id="wbUitleg"></div>
  </div>
</div>

<div id="mzKies">
  <button class="sluitKruis" id="mzKiesDicht" aria-label="sluiten">✕</button>
  <h2 id="mzKiesKop"></h2>
  <div id="mzLijst"></div>
  <div class="padUitleg" id="mzKiesUitleg"></div>
</div>

<div id="mz">
  <div class="mzKop">
    <div class="mzNaam" id="mzNaam"></div>
    <div class="mzTeller" id="mzTeller"></div>
  </div>
  <div class="mzRingVak">
    <div class="mzDoel"></div>
    <div class="mzRing" id="mzRing"></div>
    <div class="mzOordeel" id="mzOordeel"></div>
  </div>
  <div class="mzBalk"><i id="mzVul"></i></div>
  <div class="mzScore" id="mzScore"></div>
  <div id="mzBalkVak"></div>
  <button class="tekstKnop" id="mzStop"></button>
</div>

<div id="mzUit">
  <div>
    <div class="kop" id="mzUitKop"></div>
    <div class="score" id="mzUitScore"></div>
    <div class="beloning" id="mzUitLoon"></div>
    <button class="grotKnop" id="mzNogmaals" style="margin-top:26px"></button>
    <button class="tekstKnop" id="mzNaarMenu"></button>
  </div>
</div>

<div id="pad">
  <button class="sluitKruis" id="padDicht" aria-label="sluiten">✕</button>
  <h2 id="padKop"></h2>
  <div class="padBalk"><i id="padVul"></i></div>
  <div class="padBalkTekst" id="padBalkTekst"></div>
  <div class="padRest" id="padRest"></div>
  <button class="padAlles" id="padAlles"></button>
  <div id="padLijst"></div>
  <div class="padUitleg" id="padUitleg"></div>
</div>

<div id="kansen">
  <button class="sluitKruis" id="kansenDicht" aria-label="sluiten">✕</button>
  <h2 id="kansenKop"></h2>
  <div id="kansenLijst"></div>
</div>

<div id="les">
  <div class="lesBlok" id="lesBoven"></div>
  <div class="lesBlok" id="lesOnder"></div>
  <div class="lesBlok" id="lesLinks"></div>
  <div class="lesBlok" id="lesRechts"></div>
  <div class="lesBlok" id="lesMidden" style="background:transparent"></div>
  <div class="lesBubbel" id="lesBubbel">
    <div id="lesTekst"></div>
    <button class="grotKnop" id="lesKnop"></button>
    <button class="tekstKnop" id="lesSkip"></button>
  </div>
</div>

<div id="account">
  <button class="sluitKruis" id="accDicht" aria-label="sluiten">✕</button>
  <h2 id="accountKop"></h2>
  <div class="accStatus" id="accStatus"></div>

  <div id="accProfiel">
    <button id="accFotoKnop" aria-label="foto"><span class="plus">+</span></button>
    <div class="profielRechts">
      <div class="instelLabel" id="naamLabel"></div>
      <div class="naamRij">
        <input type="text" id="naamVeld" maxlength="24" autocomplete="nickname"
               enterkeyhint="done" spellcheck="false">
        <button id="naamOpslaan"></button>
      </div>
      <div class="fotoRij">
        <button class="tekstKnop" id="fotoKies"></button>
        <button class="tekstKnop" id="fotoWeg"></button>
      </div>
    </div>
  </div>
  <div class="fotoHint" id="fotoHint"></div>
  <input type="file" id="fotoInvoer" accept="image/*" hidden>

  <div id="accNaam">
    <div class="instelLabel" id="naamLabel2" hidden></div>

    <div class="accPrive" id="naamPrive"></div>
  </div>

  <div class="instelLabel accSportKop" id="accSportKop"></div>
  <div class="sportKiezer accSportRij" id="accSportRij"></div>
  <div class="accCijfers" id="accCijfers"></div>
  <button class="accKnopBreed" id="invOpen"></button>

  <div id="accFormulier">
    <input type="email" id="accEmail" autocomplete="email" inputmode="email">
    <input type="password" id="accWachtwoord" autocomplete="current-password">
    <div class="pwEisen" id="pwEisen"></div>
    <div class="accMelding" id="accMelding"></div>
    <button class="grotKnop" id="accInloggen"></button>
    <button class="tekstKnop" id="accRegistreren"></button>
  </div>
  <div class="uitlogVak" id="uitlogVak">
    <button class="uitlogKnop" id="accUitloggen"></button>
  </div>
</div>

<div id="laden">
  <div class="ladenVak">
    <div class="ladenRing"></div>
    <div class="ladenTekst" id="ladenTekst"></div>
    <div class="ladenTraag" id="ladenTraag"></div>
  </div>
</div>

<div id="cameraVraag">
  <div>
    <div class="cvIcoon">📷</div>
    <h2 id="cvTitel"></h2>
    <p id="cvTekst"></p>
    <p class="cvApparaat" id="cvApparaat"></p>
    <button class="grotKnop" id="cvToestaan"></button>
    <button class="tekstKnop" id="cvZonder"></button>
  </div>
</div>

<div id="instel">
  <button class="sluitKruis" id="instelDicht" aria-label="sluiten">✕</button>
  <h2 id="instelKop"></h2>
  <div class="instelLabel" id="diepteLabel"></div>
  <div class="instelWaarde" id="diepteWaarde"></div>
  <input type="range" id="diepte" min="30" max="85" value="60">
  <div class="instelUitleg" id="diepteUitleg"></div>
  <div class="instelLabel" id="houdLabel" style="margin-top:24px"></div>
  <div class="sportKiezer accSportRij" id="houdRij"></div>
  <div class="instelUitleg" id="houdUitleg"></div>
  <div class="instelLabel" id="geluidLabel" style="margin-top:26px"></div>
  <div class="instelWaarde" id="geluidWaarde"></div>
  <input type="range" id="geluid" min="0" max="100" value="70">
  <div class="instelUitleg" id="geluidUitleg"></div>
  <div class="instelLabel" id="muziekLabel" style="margin-top:22px"></div>
  <div class="instelWaarde" id="muziekWaarde"></div>
  <input type="range" id="muziek" min="0" max="100" value="35">
  <div class="instelUitleg" id="muziekUitleg"></div>
  <div class="instelLabel" id="taalLabel" style="margin-top:26px"></div>
  <div class="taalRij" id="taalRij"></div>
  <button class="grotKnop" id="kalibreerKnop" style="margin-top:30px"></button>
  <div class="instelUitleg" id="kalibreerUitleg"></div>
  <button class="tekstKnop" id="rondleidingKnop"></button>
</div>

<div id="duelSetup">
  <h2 id="duelSetupTitel"></h2>
  <p id="duelSetupSub"></p>
  <div class="schuifLabel" id="niveauLabel"></div>
  <div class="schuifWaarde" id="niveauWaarde">50%</div>
  <input type="range" id="niveau" min="1" max="100" value="50">
  <div class="duelInfo" id="duelDoelTekst"></div>
  <div class="duelWaarschuwing" id="duelWaarschuwing"></div>
  <div class="duelBeste" id="duelBeste"></div>
  <button class="grotKnop" id="duelStart"></button>
  <button class="tekstKnop" id="duelTerug"></button>
</div>

<div id="duel">
  <div class="duelKop">
    <div class="duelTitel" id="duelNiveauTitel"></div>
    <div class="duelKlok" id="duelKlok">60</div>
  </div>
  <div class="duelVak">
    <div class="duelKolom">
      <div class="racer">
        <div class="racerKop">
          <span class="racerNaam" id="racerJijNaam" style="color:#ffc740"></span>
          <span class="racerTal" id="racerJijTal">0</span>
        </div>
        <div class="racerSpoor"><div class="racerVul" id="racerJijVul"
             style="background:linear-gradient(90deg,#ffc740,#ff7326)"></div></div>
      </div>
      <div class="racer">
        <div class="racerKop">
          <span class="racerNaam" id="racerTegenNaam" style="color:#8c38ff"></span>
          <span class="racerTal" id="racerTegenTal">0</span>
        </div>
        <div class="racerSpoor"><div class="racerVul" id="racerTegenVul"
             style="background:linear-gradient(90deg,#8c38ff,#f2263a)"></div></div>
        <div class="duelDoel" id="racerTegenDoel"></div>
      </div>
    </div>
    <div id="duelBalkVak"></div>
  </div>
</div>

<div id="duelAftel"></div>
<div id="duelUit">
  <div>
    <div class="kop" id="duelUitKop"></div>
    <div class="score" id="duelUitScore"></div>
    <div class="beloning" id="duelUitBeloning"></div>
    <button class="grotKnop" id="duelNogmaals" style="margin-top:26px"></button>
    <button class="tekstKnop" id="duelNaarMenu"></button>
  </div>
</div>

<div id="olLobby">
  <h2 id="olTitel"></h2>
  <p class="olSub" id="olSub"></p>
  <div id="olGeenAccount">
    <p class="olSub" id="olAccountTekst"></p>
    <button class="grotKnop" id="olNaarAccount"></button>
  </div>
  <div id="olVak">
    <div class="olNaamKop" id="olNaamKop"></div>
    <div class="olRij">
      <input type="text" id="olNaamVeld" maxlength="24" autocomplete="nickname" spellcheck="false">
      <button class="olKnop" id="olNaamOk"></button>
    </div>
    <div class="olStatus" id="olStatus"></div>
    <button class="grotKnop" id="olZoek"></button>
    <button class="tekstKnop" id="olVriendKnop"></button>
    <div class="olVriend" id="olVriendVak">
      <button class="olKnop rustig" id="olMaakCode"></button>
      <div class="olRij">
        <input type="text" id="olCode" maxlength="4" autocomplete="off" spellcheck="false">
        <button class="olKnop" id="olDoeMee"></button>
      </div>
    </div>
  </div>
  <button class="tekstKnop" id="olTerug"></button>
</div>

<div id="olWacht">
  <div>
    <div class="ladenRing"></div>
    <div class="olWachtTekst" id="olWachtTekst"></div>
    <div class="olCodeGroot" id="olWachtCode"></div>
    <div class="olWachtSub" id="olWachtSub"></div>
    <button class="tekstKnop" id="olAnnuleer"></button>
  </div>
</div>

<div id="odu">
  <div class="duelKop">
    <div class="duelTitel" id="oduTitel"></div>
    <div class="duelKlok" id="oduKlok">60</div>
  </div>
  <div class="duelVak">
    <div class="duelKolom">
      <div class="racer">
        <div class="racerKop">
          <span class="racerNaam" id="oduJijNaam" style="color:#ffc740"></span>
          <span class="racerTal" id="oduJijTal">0</span>
        </div>
        <div class="racerSpoor"><div class="racerVul" id="oduJijVul"
             style="background:linear-gradient(90deg,#ffc740,#ff7326)"></div></div>
      </div>
      <div class="racer">
        <div class="racerKop">
          <span class="racerNaam" id="oduTegenNaam" style="color:#4ade80"></span>
          <span class="racerTal" id="oduTegenTal">0</span>
        </div>
        <div class="racerSpoor"><div class="racerVul" id="oduTegenVul"
             style="background:linear-gradient(90deg,#4ade80,#16a34a)"></div></div>
      </div>
    </div>
    <div id="oduBalkVak"></div>
  </div>
  <button class="tekstKnop" id="oduOpgeven"></button>
</div>

<div id="oduUit">
  <div>
    <div class="kop" id="oduUitKop"></div>
    <div class="score" id="oduUitScore"></div>
    <div class="beloning" id="oduUitBeloning"></div>
    <button class="grotKnop" id="oduNogmaals" style="margin-top:26px"></button>
    <button class="tekstKnop" id="oduNaarMenu"></button>
  </div>
</div>

<div id="klik">
  <div class="klikKop">
    <button class="sluitKruis" id="klikTerug" aria-label="sluiten">✕</button>
    <div class="klikSaldo" id="klikSaldo">0</div>
    <div class="klikEenheid" id="klikEenheid"></div>
    <div class="klikTempo" id="klikTempo"></div>
    <div class="klikBoosts" id="klikBoosts"></div>
  </div>
  <div class="klikVak">
    <button id="klikKnop" aria-label="push-up">
      <svg viewBox="0 0 100 100"><path id="klikKnopPad"/></svg>
    </button>
    <div class="klikTrainTekst" id="klikTrainTekst"></div>
  </div>
  <button id="gouden" aria-label="gouden push-up">
    <svg viewBox="0 0 100 100"><path id="goudenPad"/></svg>
  </button>
  <div class="klikTik" id="klikTik"></div>
  <div id="klikBalkVak"></div>
  <div class="klikTabs">
    <button class="klikTab aan" id="tabHelpers" data-tab="helpers"></button>
    <button class="klikTab" id="tabUpgrades" data-tab="upgrades"></button>
    <button class="klikTab" id="tabWinkel" data-tab="winkel"></button>
  </div>
  <div class="klikLijst" id="klikLijst"></div>
</div>

<div id="flash"></div>
<div class="zoekbaar">
  <h2>Push-up spel met camera-teller</h2>
  <p>
    Push Battle telt je push-ups met de camera van je telefoon of laptop. Je zet
    je toestel rechtop naast je neer, en elke volledige herhaling is een aanval
    op het monster voor je. Er zijn __AANTAL_ARENAS__ arena's met steeds sterkere
    vijanden, een duel van zestig seconden waarin je het tegen een tegenstander
    opneemt, en een online modus waarin je live tegen een echte speler racet —
    tegen een willekeurige tegenstander of tegen een vriend met een code. In de
    clicker bouw je met dezelfde push-ups een imperium van helpers dat vanzelf
    doortelt. Gratis, zonder installatie, in het Nederlands, Engels en Frans.
  </p>
</div>

<div id="melding"></div>
<div id="rondleiding">
  <div class="taalRij" id="rlTaal"></div>
  <button id="rlOver"></button>
  <div class="rlVak">
    <div class="rlBeeld" id="rlBeeld"></div>
    <div class="rlStap" id="rlStap"></div>
    <h2 class="rlKop" id="rlKop"></h2>
    <p class="rlTekst" id="rlTekst"></p>
  </div>
  <div class="rlVoet">
    <div class="rlBolletjes" id="rlBolletjes"></div>
    <div class="rlKnoppen">
      <button class="grotKnop" id="rlTerug"></button>
      <button class="grotKnop" id="rlVolgende"></button>
    </div>
  </div>
</div>

<div id="tip">
  <div class="tipTekst" id="tipTekst"></div>
  <button class="tipOver" id="tipOver"></button>
</div>
<div id="fatal"></div>
<button id="reset">voortgang wissen</button>


<script>
window.addEventListener('error', ev => {
  const f = document.getElementById('fatal');
  if (!f) return;
  const sjabloon = typeof ARENAS === 'undefined';
  f.className = 'on';
  f.innerHTML = '<b>Er ging iets mis bij het laden</b>' + (sjabloon
    ? 'Je hebt het sjabloonbestand geopend in plaats van het spel.<br><br>' +
      'Open <b>http://localhost:8765/proefversie.html</b> in Safari of Chrome.'
    : String(ev.message) + '<br><br>' + (ev.filename || '') + ' regel ' + (ev.lineno || '?'));
});
</script>
<script>
const ARENAS = __ARENAS__;
const TEKSTEN = __TEKSTEN__;
const MODE_ICONEN = __MODEICONEN__;
const ARENA_ART = __ARENAART__;

/* Elk monster bestaat uit lagen met een kleurrol. De rollen krijgen hier hun
   echte kleur: het lijf in de kleur van de arena, met een donkere en een
   lichtere variant erbij, en vaste kleuren voor stof, ogen en mond. Om elke
   laag komt een donkere lijn — dat maakt de stripstijl. */
const KLEUR_STOF = '#8a8578', KLEUR_BROEK = '#3f4a5a';
const KLEUR_WIT = '#f0eee4', KLEUR_ZWART = '#1a1a22', KLEUR_LIJN = '#15151c';

function rolKleur(rol, c, hoofd) {
  if (rol === 'lijf') return hoofd;
  if (rol === 'diep') return rgbCss(c.map(v => v * 0.6));
  if (rol === 'licht') return rgbCss(c.map(v => Math.min(1, v * 1.2 + 0.14)));
  if (rol === 'kleding') return KLEUR_STOF;
  if (rol === 'broek') return KLEUR_BROEK;
  if (rol === 'wit') return KLEUR_WIT;
  return KLEUR_ZWART;
}

/// De binnenkant van een <svg> voor één monster. Zonder tekening valt hij
/// terug op het oude silhouet in één kleur.
function monsterPaden(a, hoofd) {
  const lagen = ARENA_ART[a.race.nl];
  if (!lagen) return `<path d="${a.icon}" fill="${hoofd}"/>`;
  return lagen.map(([d, rol]) =>
    `<path d="${d}" fill="${rolKleur(rol, a.rgb, hoofd)}" stroke="${KLEUR_LIJN}"` +
    ` stroke-width="${rol === 'wit' || rol === 'zwart' ? 1.6 : 2.8}"` +
    ` stroke-linejoin="round"/>`).join('');
}
const RANG_ICONEN = __RANGICONEN__;
const TALEN = ['nl', 'en', 'fr'];

let TAAL = localStorage.getItem('orbslayer.taal');
if (!TALEN.includes(TAAL)) {
  const stel = (navigator.language || 'en').slice(0, 2).toLowerCase();
  TAAL = TALEN.includes(stel) ? stel : 'en';
}

/// De naam van de oefening waar je nu in zit, enkelvoud en meervoud, per taal.
/// Alle teksten zijn geschreven met 'push-up' erin; zit je in een andere
/// wereld, dan wordt dat woord overal vervangen. Zo hoeft geen enkele zin
/// drie keer te bestaan.
var SPORT = 'pushup';
const OEFENWOORD = {
  pushup: { nl: ['push-up', 'push-ups'], en: ['push-up', 'push-ups'], fr: ['pompe', 'pompes'] },
  situp:  { nl: ['sit-up', 'sit-ups'],   en: ['sit-up', 'sit-ups'],   fr: ['abdo', 'abdos'] },
  squat:  { nl: ['squat', 'squats'],     en: ['squat', 'squats'],     fr: ['squat', 'squats'] },
};

/// De naam van een oefening, zonder woordwissel — anders zou 'Push-ups' in de
/// sit-upwereld ineens 'Sit-ups' heten op elke knop.
const sportNaam = sp => (TEKSTEN['sport_' + sp] || [])[TALEN.indexOf(TAAL)] || sp;

function oefenWoorden(tekst) {
  if (SPORT === 'pushup' || !tekst) return tekst;
  const nu = OEFENWOORD[SPORT][TAAL] || OEFENWOORD[SPORT].en;
  const oud = OEFENWOORD.pushup[TAAL] || OEFENWOORD.pushup.en;
  const wissel = (t, van, naar) => t.replace(new RegExp(van, 'gi'),
    m => (m[0] === m[0].toUpperCase() ? naar[0].toUpperCase() + naar.slice(1) : naar));
  return wissel(wissel(tekst, oud[1], nu[1]), oud[0], nu[0]);
}

/// Haalt een tekst op en vult {0}, {1}, … met de meegegeven waarden.
function t(sleutel, ...args) {
  const rij = TEKSTEN[sleutel];
  if (!rij) return sleutel;
  let uit = rij[TALEN.indexOf(TAAL)] ?? rij[0];
  args.forEach((a, i) => { uit = uit.replaceAll('{' + i + '}', a); });
  return oefenWoorden(uit);
}
/// Arenatekst in de gekozen taal (name/race/minion/boss/intro zijn {nl,en,fr}).
const tt = veld => (typeof veld === 'string' ? veld : (veld[TAAL] ?? veld.en));
/// Vijanden heten naar wat ze zijn: een Ork, een Zombie, een Skelet.
const vijandNaam = () => {
  const a = arenaAt(idxNu());
  return tt(enemy.boss ? a.boss : a.minion);
};

function zetTaal(nieuw) {
  TAAL = nieuw;
  localStorage.setItem('orbslayer.taal', nieuw);
  spawn();                 // bossnaam hangt aan de taal
  vertaalVast();
  render();
  renderMenu();
  document.querySelectorAll('.taalKnop').forEach(k =>
    k.classList.toggle('aan', k.dataset.taal === nieuw));
}

/// Teksten die niet elke frame opnieuw getekend worden.
function vertaalVast() {
  $('markUp').querySelector('span').textContent = t('bar_up');
  $('markDown').querySelector('span').textContent = t('bar_down');
  $('camBtn').textContent = cameraOn ? t('cam_stop') : t('cam_start');
  $('calBtn').textContent = t('cal_again');
  $('reset').textContent = t('reset_progress');
  $('vechten').textContent = t('fight');
  document.querySelector('.mKop').textContent = t('up_next');
  if ($('instel').classList.contains('aan')) toonInstellingen();
  if ($('account').classList.contains('aan')) renderAccount();
  if ($('cameraVraag').classList.contains('aan')) toonCameraVraag();
  tekenSportKiezer();
  if ($('olLobby').classList.contains('aan')) tekenLobby();
  if ($('klik').classList.contains('aan')) { vertaalKlik(); tekenKlik(); tekenKlikLijst(true); }
  if ($('rondleiding').classList.contains('aan')) tekenRondleiding();
  if ($('klassement').classList.contains('aan')) tekenKlassement();
  if ($('laden').classList.contains('aan') && $('ladenTraag').textContent) {
    $('ladenTraag').textContent = t('loading_slow');
  }
  if (!cameraOn) $('hint').textContent = t('hint_tap');
  if (!cameraOn) $('camState').textContent = t('cam_off_label');
}

// Zelfde formules als in GameStore.swift
const minionHP = a => 5 + Math.floor((a - 1) * 1.5);
const bossHP   = a => minionHP(a) * 5;
const minionXP = a => 15 + (a - 1) * 5;
const bossXP   = a => minionXP(a) * 5;
const xpNeeded = l => 100 + (l - 1) * 75;
const COMBO_WINDOW = 3000, CRIT_COMBO = 10;

const roman = n => { let t=[[10,'X'],[9,'IX'],[5,'V'],[4,'IV'],[1,'I']], r='', x=n;
  for (const [v,s] of t) while (x>=v) { r+=s; x-=v; } return r; };

function arenaAt(index) {
  const i = Math.max(0, index - 1), a = ARENAS[i % ARENAS.length], cycle = Math.floor(i / ARENAS.length);
  if (!cycle) return a;
  const suffix = ' ' + roman(cycle + 1);
  const plus = o => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, v + suffix]));
  return { ...a, name: plus(a.name), boss: plus(a.boss) };
}

const DEFAULTS = { totalReps:0, totalKills:0, bossKills:0, totalXP:0, arenaIndex:1, killsThisArena:0,
                   savedMinionHP:null, streak:0, lastKillDay:null,
                   duelsWon:0, duelBest:{}, duelLevel:50, onlineWon:0 };
/* ---------------------------------------------------------------
   Drie oefeningen, drie werelden. Push-ups, sit-ups en squats hebben elk
   hun eigen voortgang, klassement, opdrachten en clicker; er gaat niets van
   de een naar de ander. In de opslag staat daarom niet één profiel maar een
   kastje met drie laden, plus je naam die je overal houdt.
---------------------------------------------------------------- */
const SPORTEN = ['pushup', 'situp', 'squat'];

function leesOpslag() {
  let d = {};
  try { d = JSON.parse(localStorage.getItem('orbslayer.proto') || '{}') || {}; } catch (e) { d = {}; }
  if (!d.werelden) {
    // Wie al speelde had één plat profiel; dat waren push-ups.
    const oud = Object.keys(d).length ? d : null;
    d = { actief: 'pushup', naam: (oud && oud.naam) || '', werelden: { pushup: oud || {} } };
  }
  d.werelden = d.werelden || {};
  SPORTEN.forEach(sp => { d.werelden[sp] = d.werelden[sp] || {}; });
  if (!SPORTEN.includes(d.actief)) d.actief = 'pushup';
  d.naam = d.naam || '';
  return d;
}

let ALLES = leesOpslag();
SPORT = ALLES.actief;
let P = { ...DEFAULTS, ...ALLES.werelden[SPORT] };


let enemy, combo = 0, lastRep = 0, sessionReps = 0;
/// Terugbezoek aan een al veroverde arena: je vecht daar echt (XP en kills
/// tellen), maar je voorste voortgang blijft staan en de trofee kreeg je al.
/// Bewust niet opgeslagen: de pagina verversen zet je terug bij de voorhoede.
let bezoek = null, bezoekKills = 0, bezoekHP = null, mRijStand = '';
const idxNu = () => bezoek ?? P.arenaIndex;
const killsNu = () => bezoek !== null ? bezoekKills : P.killsThisArena;

const $ = id => document.getElementById(id);
const rgbCss = (c, a=1) => `rgba(${Math.round(c[0]*255)},${Math.round(c[1]*255)},${Math.round(c[2]*255)},${a})`;
// verloopt van arenakleur (vol) naar bloedrood (bijna dood), net als Theme.orbColor
const orbCss = (c, f, a=1) => {
  const t = [0.95, 0.15, 0.22], m = c.map((v,i) => t[i] + (v - t[i]) * Math.max(0, Math.min(1, f)));
  return rgbCss(m, a);
};

function spawn() {
  if (killsNu() >= 9) {
    const hp = bossHP(idxNu());
    enemy = { max: hp, hp, boss: true };
  } else {
    const max = minionHP(idxNu());
    // Boss-voortgang wordt nooit bewaard; minions wel.
    const hp = Math.min((bezoek !== null ? bezoekHP : P.savedMinionHP) ?? max, max);
    enemy = { max, hp: Math.max(1, hp), boss: false };
  }
}

/// Zet de huidige wereld terug in het kastje en schrijf het geheel weg.
function bewaarAlles() {
  ALLES.actief = SPORT;
  ALLES.werelden[SPORT] = P;
  localStorage.setItem('orbslayer.proto', JSON.stringify(ALLES));
}

function save() {
  if (bezoek === null) P.savedMinionHP = (!enemy.boss && enemy.hp < enemy.max) ? enemy.hp : null;
  else bezoekHP = (!enemy.boss && enemy.hp < enemy.max) ? enemy.hp : null;
  bewaarAlles();
  if (typeof duwVoortgang === 'function') duwVoortgang();
}

const playerLevel = () => { let xp = P.totalXP, l = 1; while (xp >= xpNeeded(l)) { xp -= xpNeeded(l); l++; } return l; };
const levelProg  = () => { let xp = P.totalXP, l = 1; while (xp >= xpNeeded(l)) { xp -= xpNeeded(l); l++; }
                           return [xp, xpNeeded(l)]; };
const dayKey = d => new Date(d).toDateString();
/// Markeert vandaag als trainingsdag en verlengt de streak.
function tikStreak() {
  const vandaag = dayKey(Date.now());
  if (P.lastKillDay && dayKey(P.lastKillDay) === vandaag) return;
  P.streak = (P.lastKillDay && dayKey(P.lastKillDay) === dayKey(Date.now() - 864e5))
    ? P.streak + 1 : 1;
  P.lastKillDay = Date.now();
}

function effStreak() {
  if (!P.lastKillDay) return 0;
  const last = dayKey(P.lastKillDay), today = dayKey(Date.now());
  const yest = dayKey(Date.now() - 864e5);
  return (last === today || last === yest) ? P.streak : 0;
}
function streakMult() { const s = effStreak();
  return s >= 30 ? 1.5 : s >= 14 ? 1.35 : s >= 7 ? 1.25 : s >= 3 ? 1.1 : 1; }

/* ---------------- dag- en weekopdrachten ----------------
   Elke dag drie opdrachten en elke week twee. De datum bepaalt de keuze,
   dus iedereen heeft dezelfde. Voortgang loopt vanzelf mee met wat je toch
   al doet; de beloning — XP en soms push-ups voor de clicker — wordt
   automatisch uitgekeerd met een melding. */
const QUEST_DAG = [
  { id: 'reps25', doel: 25, xp: 60,  klik: 25 },
  { id: 'kills3', doel: 3,  xp: 50,  klik: 0 },
  { id: 'boss1',  doel: 1,  xp: 80,  klik: 40 },
  { id: 'combo1', doel: 1,  xp: 60,  klik: 0 },
  { id: 'duel1',  doel: 1,  xp: 80,  klik: 30 },
  { id: 'snel20', doel: 20, xp: 100, klik: 50 },
  { id: 'lied1',  doel: 1,  xp: 90,  klik: 40 },
  { id: 'wbslag50', doel: 50, xp: 90, klik: 40 },
];
const QUEST_WEEK = [
  { id: 'wreps300', doel: 300, xp: 500, klik: 300 },
  { id: 'wboss5',   doel: 5,   xp: 400, klik: 150 },
  { id: 'wduel5',   doel: 5,   xp: 400, klik: 200 },
  { id: 'wkills40', doel: 40,  xp: 350, klik: 150 },
  { id: 'wlied3',   doel: 3,   xp: 450, klik: 200 },
  { id: 'wwb250',   doel: 250, xp: 500, klik: 250 },
];
/// Welke teller elke opdracht bijhoudt.
const QUEST_TELLER = {
  reps25: 'reps', kills3: 'kills', boss1: 'boss', combo1: 'combo',
  duel1: 'duel', snel20: 'snel', lied1: 'lied', wbslag50: 'wbslag',
  wreps300: 'reps', wboss5: 'boss', wduel5: 'duel', wkills40: 'kills',
  wlied3: 'lied', wwb250: 'wbslag',
};
const dagNr = () => Math.floor(Date.now() / 864e5);
const weekNr = () => Math.floor((dagNr() + 3) / 7);   // weken beginnen op maandag
/// Deterministisch husselen: hetzelfde zaad geeft iedereen dezelfde keuze.
function questKeuze(pool, zaad, n) {
  const lijst = [...pool];
  let s = (zaad * 2654435761) % 4294967296;
  for (let i = lijst.length - 1; i > 0; i--) {
    s = (s * 1664525 + 1013904223) % 4294967296;
    const j = s % (i + 1);
    [lijst[i], lijst[j]] = [lijst[j], lijst[i]];
  }
  return lijst.slice(0, n);
}
const dagQuests = () => questKeuze(QUEST_DAG, dagNr(), 3);
const weekQuests = () => questKeuze(QUEST_WEEK, weekNr() + 7919, 2);

/// Voortgang staat in het profiel en synct dus mee met je account.
function questStaat() {
  if (!P.quests || typeof P.quests !== 'object') P.quests = {};
  const q = P.quests;
  if (q.dag !== dagNr()) { q.dag = dagNr(); q.dagTel = {}; q.dagKlaar = []; }
  if (q.week !== weekNr()) { q.week = weekNr(); q.weekTel = {}; q.weekKlaar = []; }
  q.dagTel = q.dagTel || {}; q.dagKlaar = q.dagKlaar || [];
  q.weekTel = q.weekTel || {}; q.weekKlaar = q.weekKlaar || [];
  return q;
}

let repMomenten = [];   // voor de snelheidsopdracht, alleen deze sessie

/// Eén ingang voor alles wat een opdracht vooruit helpt.
function questTel(teller, n = 1) {
  const q = questStaat();
  q.dagTel[teller] = (q.dagTel[teller] || 0) + n;
  q.weekTel[teller] = (q.weekTel[teller] || 0) + n;
  questCheck();
}

/// Elke push-up telt mee, en de snelheidsteller is een hoogste stand:
/// hoeveel deed je er binnen één minuut.
function questRep() {
  const nu = Date.now();
  repMomenten.push(nu);
  repMomenten = repMomenten.filter(m => nu - m <= 60000);
  const q = questStaat();
  if (repMomenten.length > (q.dagTel.snel || 0)) q.dagTel.snel = repMomenten.length;
  questTel('reps');
}

/// Welke opdrachten je gehaald hebt maar nog niet opgehaald.
function questTeHalen() {
  const q = questStaat();
  q.dagOp = q.dagOp || [];
  q.weekOp = q.weekOp || [];
  return dagQuests().filter(x => q.dagKlaar.includes(x.id) && !q.dagOp.includes(x.id)).length
       + weekQuests().filter(x => q.weekKlaar.includes(x.id) && !q.weekOp.includes(x.id)).length;
}

/// Eén opdracht uitbetalen.
function questOphalen(id, week) {
  const q = questStaat();
  const lijst = week ? weekQuests() : dagQuests();
  const klaar = week ? q.weekKlaar : q.dagKlaar;
  const op = week ? (q.weekOp = q.weekOp || []) : (q.dagOp = q.dagOp || []);
  const quest = lijst.find(x => x.id === id);
  if (!quest || !klaar.includes(id) || op.includes(id)) return;
  op.push(id);
  P.totalXP += quest.xp;
  if (quest.klik) klikVerdien(quest.klik);
  bpNakijken();
  save();
  geluidWin();
  let tekst = '+' + quest.xp + ' XP';
  if (quest.klik) tekst += ' · +' + quest.klik + ' ' + t('stat_pushups');
  melding(tekst, 3000);
  renderQuests();
  menuKnoppenBij();
}

function questCheck() {
  const q = questStaat();
  [[dagQuests(), q.dagTel, q.dagKlaar], [weekQuests(), q.weekTel, q.weekKlaar]]
    .forEach(([lijst, tel, klaar]) => lijst.forEach(quest => {
      if (klaar.includes(quest.id)) return;
      if ((tel[QUEST_TELLER[quest.id]] || 0) < quest.doel) return;
      // Gehaald, maar nog niet uitbetaald: dat doe je zelf op het scherm.
      klaar.push(quest.id);
      melding(t('quest_af', t('quest_' + quest.id, quest.doel)), 4000);
    }));
  if ($('quests').classList.contains('aan')) renderQuests();
}

function renderQuests() {
  const q = questStaat();
  $('questsKop').textContent = t('quests_titel').toUpperCase();
  q.dagOp = q.dagOp || []; q.weekOp = q.weekOp || [];
  const blok = (kop, lijst, tel, klaar, op, week) => {
    let html = `<div class="qKop">${ontsmet(kop)}</div>`;
    lijst.forEach(quest => {
      const af = klaar.includes(quest.id), gehaald = op.includes(quest.id);
      const stand = Math.min(tel[QUEST_TELLER[quest.id]] || 0, quest.doel);
      const loon = '+' + quest.xp + ' XP'
        + (quest.klik ? ' · +' + quest.klik + ' ' + t('stat_pushups') : '');
      const rechts = gehaald ? `<div class="qStand">✓</div>`
        : af ? `<button class="qHaal" data-quest="${quest.id}" data-week="${week ? 1 : 0}">` +
               `${ontsmet(t('claim'))}</button>`
        : `<div class="qStand">${stand} / ${quest.doel}</div>`;
      html += `<div class="qRij${gehaald ? ' af' : ''}">` +
        `<div class="qTekst"><b>${ontsmet(t('quest_' + quest.id, quest.doel))}</b>` +
        `<small>${ontsmet(loon)}</small></div>` + rechts +
        `<div class="qBalk"><i style="width:${af ? 100 : Math.round(stand / quest.doel * 100)}%"></i></div>` +
        `</div>`;
    });
    return html;
  };
  $('questsLijst').innerHTML =
    blok(t('quests_vandaag'), dagQuests(), q.dagTel, q.dagKlaar, q.dagOp, false) +
    blok(t('quests_week'), weekQuests(), q.weekTel, q.weekKlaar, q.weekOp, true);
  $('questsLijst').querySelectorAll('.qHaal').forEach(knop => {
    knop.onclick = e => {
      e.stopPropagation();
      questOphalen(knop.dataset.quest, knop.dataset.week === '1');
    };
  });
  $('questsDicht').title = t('close');
}

function render() {
  const arena = arenaAt(idxNu()), c = arena.rgb, f = enemy.hp / enemy.max;

  $('aura').style.background = enemy.boss
    ? 'radial-gradient(circle at 50% 45%, rgba(242,38,58,.22), transparent 62%)'
    : `radial-gradient(circle at 50% 45%, ${rgbCss(c, .10)}, transparent 62%)`;

  $('arenaName').textContent = tt(arena.name).toUpperCase();
  $('arenaName').style.color = rgbCss(c);
  $('arenaNum').textContent = t('arena_n', idxNu());
  $('streak').textContent = effStreak();
  $('reps').textContent = t('reps_n', sessionReps);

  $('pips').innerHTML = '';
  for (let i = 0; i < 10; i++) {
    const p = document.createElement('div');
    p.className = 'pip';
    p.style.background = i === 9
      ? (enemy.boss ? '#f2263a' : 'rgba(242,38,58,.35)')
      : (i < killsNu() ? rgbCss(c) : 'rgba(255,255,255,.12)');
    $('pips').appendChild(p);
  }

  $('bossTag').style.display = enemy.boss ? 'block' : 'none';
  $('enemyName').textContent = vijandNaam();
  $('enemyName').className = 'enemy-name' + (enemy.boss ? ' boss' : '');
  $('raceLine').textContent = enemy.boss ? '' : tt(arena.race);

  const size = enemy.boss ? 300 : 235, col = orbCss(c, f);
  const svg = $('enemySvg');
  svg.style.width = svg.style.height = size + 'px';
  svg.innerHTML = monsterPaden(arena, col);
  // Geen gloed meer om het monster: de tekening moet het zelf doen.
  $('glow').style.background = `radial-gradient(circle, ${rgbCss(c, .12)}, transparent 70%)`;
  $('glow').style.width = $('glow').style.height = (size * 1.5) + 'px';
  $('bossRing').style.display = enemy.boss ? 'block' : 'none';
  $('bossRing').style.width = $('bossRing').style.height = (size * 1.25) + 'px';

  $('hpfill').style.width = (f * 100) + '%';
  $('hpfill').style.background = `linear-gradient(to right, #f2263a, ${col})`;
  $('hptext').textContent = t('hp_of', enemy.hp, enemy.max);

  const cb = $('combo');
  cb.textContent = combo > 1 ? t(combo >= CRIT_COMBO ? 'crit_n' : 'combo_n', combo) : '';
  cb.className = 'combo' + (combo >= CRIT_COMBO ? ' crit' : '');

  const [cur, need] = levelProg();
  $('xpNiveau').textContent = playerLevel();
  $('xpVul').style.width = (cur / need * 100) + '%';
  $('xpVul').style.background = `linear-gradient(to right, ${rgbCss(c)}, #ffc740)`;
  $('xpTekst').textContent = t('xp_of', cur, need);
}

// Kalibratie: gezichtshoogte bij gestrekte armen (top) en onderin (bottom).
/// De ijking hoort bij de oefening: liggend voor push-ups en sit-ups, staand
/// voor squats. Elke wereld onthoudt zijn eigen boven en beneden, dus je ijkt
/// drie keer — maar ook maar één keer per oefening.
(function verhuisOudeIjking() {
  // Wie al geijkt had voor er drie oefeningen waren: dat waren push-ups.
  const oud = localStorage.getItem('orbslayer.cal');
  if (!oud) return;
  if (!localStorage.getItem('orbslayer.cal.pushup')) {
    localStorage.setItem('orbslayer.cal.pushup', oud);
  }
  localStorage.removeItem('orbslayer.cal');
})();

const isGeijkt = sp => !!localStorage.getItem('orbslayer.cal.' + (sp || SPORT));
const leesCal = () => JSON.parse(localStorage.getItem('orbslayer.cal.' + SPORT) || 'null')
                      || { top: 0.75, bottom: 0.25 };
let CAL = leesCal();
/// Hoeveel van je gekalibreerde bereik je moet afleggen voordat een push-up
/// telt. 0.6 komt overeen met de oude vaste drempels van 80% naar 20%.
let DIEPTE = parseFloat(localStorage.getItem('orbslayer.diepte'));
if (!(DIEPTE >= 0.3 && DIEPTE <= 0.85)) DIEPTE = 0.6;

let UP = 0.8, DOWN = 0.2;
function updateMarks() {
  const range = CAL.top - CAL.bottom;
  const rand = (1 - DIEPTE) / 2;
  UP = CAL.bottom + range * (1 - rand);
  DOWN = CAL.bottom + range * rand;
  $('markUp').style.bottom = (UP * 100) + '%';
  $('markDown').style.bottom = (DOWN * 100) + '%';
}
updateMarks();
function setNose(v, down) {
  $('trackfill').style.height = (v * 100) + '%';
  $('knob').style.bottom = (v * 100) + '%';
  $('knob').style.background = down ? '#f2263a' : '#ffc740';
  $('knob').style.boxShadow = `0 0 10px ${down ? 'rgba(242,38,58,.9)' : 'rgba(255,199,64,.9)'}`;
}
setNose(0.9, false);
function animateNose() {
  setNose(0.12, true);
  setTimeout(() => setNose(0.9, false), 170);
}

function shake(strength) {
  const orb = $('enemySvg');
  orb.animate(
    [{ transform: 'scale(.9)' }, { transform: 'scale(1.04)' }, { transform: 'scale(1)' }],
    { duration: 260, easing: 'ease-out' }
  );
  document.getElementById('stage').animate(
    [{ transform: 'translateX(0)' }, { transform: `translateX(${strength}px)` },
     { transform: `translateX(${-strength}px)` }, { transform: 'translateX(0)' }],
    { duration: 180 }
  );
}

function showBanner(text) {
  const b = $('banner');
  b.textContent = text; b.style.opacity = 1;
  clearTimeout(b._t);
  b._t = setTimeout(() => b.style.opacity = 0, 1500);
}

function showIntro(arena, index) {
  const c = arena.rgb;
  $('introNum').textContent = t('arena_n', index);
  $('introName').textContent = tt(arena.name);
  $('introName').style.color = rgbCss(c);
  $('introName').style.textShadow = `0 0 24px ${rgbCss(c, .8)}`;
  $('introRule').style.background = rgbCss(c, .6);
  $('introRace').textContent = tt(arena.race).toUpperCase();
  $('introText').textContent = tt(arena.intro);
  $('intro').style.background =
    `radial-gradient(circle at 50% 50%, ${rgbCss(c, .3)}, transparent 60%), rgba(0,0,0,.85)`;
  $('intro').style.opacity = 1;
  setTimeout(() => $('intro').style.opacity = 0, 3000);
}

function rep() {
  const now = Date.now();
  combo = (now - lastRep <= COMBO_WINDOW) ? combo + 1 : 1;
  lastRep = now;
  const crit = combo >= CRIT_COMBO, dmg = crit ? 2 : 1;
  if (crit) tip('combo');
  if (combo === CRIT_COMBO) questTel('combo');
  if (lesStap === 2) lesVolgende();

  P.totalReps++; sessionReps++;
  klikRepBonus();
  enemy.hp = Math.max(0, enemy.hp - dmg);

  animateNose();
  shake(crit ? 12 : 6);
  if (navigator.vibrate) navigator.vibrate(crit ? 25 : 10);

  const d = document.createElement('div');
  d.className = 'dmg';
  d.textContent = '-' + dmg;
  d.style.fontSize = crit ? '54px' : '36px';
  d.style.color = crit ? '#ffc740' : '#f2263a';
  d.style.textShadow = `0 0 12px ${crit ? 'rgba(255,199,64,.8)' : 'rgba(242,38,58,.8)'}`;
  d.style.left = (150 + (Math.random() * 120 - 60)) + 'px';
  d.style.top = '120px';
  $('orbwrap').appendChild(d);
  setTimeout(() => d.remove(), 1100);

  if (enemy.hp === 0) {
    const wasBoss = enemy.boss, before = playerLevel();

    tikStreak();

    const gained = Math.floor((wasBoss ? bossXP(idxNu()) : minionXP(idxNu()))
                              * streakMult() * xpMaal());
    P.totalXP += gained; P.totalKills++;
    questTel('kills');
    if (wasBoss) questTel('boss');
    if (lesStap === 3) lesVolgende();

    let entered = null;
    if (wasBoss) {
      if (bezoek !== null) {
        // Herbezoek: de trofee en de arenavoortgang kreeg je de eerste keer
        // al. Je schuift gewoon door naar de volgende oude bekende, en bij
        // de voorhoede aangekomen vecht je weer echt vooruit.
        bezoekKills = 0; bezoekHP = null;
        bezoek = bezoek + 1 >= P.arenaIndex ? null : bezoek + 1;
      } else {
        P.bossKills++; P.arenaIndex++; P.killsThisArena = 0;
      }
      entered = arenaAt(idxNu());
    } else if (bezoek !== null) bezoekKills++;
    else P.killsThisArena++;
    if (bezoek === null) P.savedMinionHP = null; else bezoekHP = null;
    spawn();

    $('flash').style.opacity = .25;
    setTimeout(() => $('flash').style.opacity = 0, 110);

    geluidKill();
    if (wasBoss) geluidWin();
    if (playerLevel() > before) setTimeout(geluidLevel, 260);
    let text = t('xp_gain', gained);
    if (wasBoss) text = t('boss_defeated') + '\n' + text;
    if (playerLevel() > before) text += '\n' + t('level_up', playerLevel());
    if (enemy.boss) text += '\n' + t('boss_incoming');
    showBanner(text);

    if (entered) setTimeout(() => showIntro(entered, idxNu()), 1700);
    bpNakijken();
  }

  save();
  render();
}

/// Eén ingang voor elke push-up, waar hij ook vandaan komt.
/// Eén ingang voor elke push-up. 'echt' is waar als de camera hem gezien heeft;
/// een tik op het scherm is dat niet, en telt in de clicker dus niet mee.
function pushup(echt = false) {
  geluidPush();
  if ($('wb').classList.contains('aan')) { bossRep(); return; }
  if ($('mz').classList.contains('aan')) { muziekRep(); return; }
  if ($('klik').classList.contains('aan')) {
    if (echt) { P.totalReps++; questRep(); klikRepBonus(); save(); }
    return;
  }
  if (olFase === 'bezig') { questRep(); olRep(); return; }
  if (olFase !== 'uit') return;          // lobby, wachten of uitslag: niet tellen
  if (duelFase === 'bezig') { questRep(); duelRep(); return; }
  if ($('menu').classList.contains('uit') && !$('duelSetup').classList.contains('aan')) { questRep(); rep(); }
}

/// Tikken op het scherm telt bewust NIET als push-up: alleen de camera telt.
/// (Vroeger was een tik een testherhaling, maar dan kon je al vechtend
/// valsspelen door op je scherm te rammen.) De spatiebalk blijft werken als
/// testknop op een computer — op een telefoon bestaat die toch niet.
document.addEventListener('keydown', e => {
  if (e.code === 'Space') { e.preventDefault(); pushup(); }
});
$('reset').addEventListener('click', e => {
  e.stopPropagation();
  P = { ...DEFAULTS }; combo = 0; sessionReps = 0;
  localStorage.removeItem('orbslayer.proto');
  spawn(); render();
});

spawn();
render();

/* ---------------------------------------------------------------
   Menu: je huidige arena, de drie die eraan komen, en daarna
   vraagtekens. Vooruitkijken mag, erheen springen niet.
---------------------------------------------------------------- */
const VOORUIT = 3, RAADSELS = 15;

/// De camerabalk hoort alleen bij een gevecht of een duel. In het menu zou hij
/// over de Vechten-knop vallen, dus daar blijft hij weg.
function camBalkBijwerken() {
  const inGevecht = !$('stage').classList.contains('uit');
  const inDuel = $('duel').classList.contains('aan') || $('duelSetup').classList.contains('aan');
  const inOnline = $('odu').classList.contains('aan') || $('mz').classList.contains('aan')
                || $('wb').classList.contains('aan');
  $('cambalk').classList.toggle('aan', inGevecht || inDuel || inOnline);
}

/// Overstappen naar een andere oefening: de huidige wereld gaat het kastje in,
/// de nieuwe komt eruit. Er wordt niets omgerekend of meegenomen.
function wisselSport(nieuweSport) {
  if (!SPORTEN.includes(nieuweSport) || nieuweSport === SPORT) return;
  bewaarAlles();
  SPORT = nieuweSport;
  ALLES.actief = SPORT;
  P = { ...DEFAULTS, ...ALLES.werelden[SPORT] };
  bezoek = null; bezoekKills = 0; bezoekHP = null;
  combo = 0; sessionReps = 0;
  CAL = leesCal();
  updateMarks();
  autoLaag = autoHoog = null; autoRijp = 0; autoGemeld = false;
  houdingOk = true; houdingSlecht = houdingGoed = 0;
  if (cameraOn && !isGeijkt()) melding(t('cal_nodig'), 5000);
  spawn();
  bewaarAlles();
  if (typeof duwVoortgang === 'function') duwVoortgang();
  vertaalVast();
  tekenSportKiezer();
  render();
  renderMenu();
  melding(t('sport_gewisseld', sportNaam(SPORT)), 3000);
}

/// De drie knoppen bovenaan het menu.
function tekenSportKiezer() {
  const rij = $('sportKiezer');
  rij.innerHTML = '';
  SPORTEN.forEach(sp => {
    const knop = document.createElement('button');
    knop.className = 'sportKnop' + (sp === SPORT ? ' aan' : '');
    knop.textContent = sportNaam(sp);
    knop.onclick = e => { e.stopPropagation(); wisselSport(sp); };
    rij.appendChild(knop);
  });
}

function toonMenu() {
  $('menu').classList.remove('uit');
  $('stage').classList.add('uit');
  $('cambalk').classList.remove('aan');
  if (cameraOn) stopCamera();
  renderMenu();
  if (lesStap === 4) lesVolgende();
}

function toonGevecht() {
  $('menu').classList.add('uit');
  $('stage').classList.remove('uit');
  $('cambalk').classList.add('aan');
  sessionReps = 0;
  render();
  startCameraIndienNodig();
  if (enemy.boss) tip('boss');
  if (lesStap === 1) lesVolgende();
}

/// Toestemming wordt per apparaat onthouden, nooit via je account. Log je op
/// een nieuwe telefoon in, dan vraagt die dus opnieuw om de camera.
const APPARAAT_SLEUTEL = 'orbslayer.cameraGevraagd';
const apparaatVroegAl = () => localStorage.getItem(APPARAAT_SLEUTEL) === 'ja';

/// Bij het begin van een sessie zetten we de camera zelf aan. Is dit apparaat
/// nog nooit iets gevraagd, dan komt eerst het uitlegscherm — dat is ook nodig
/// omdat browsers op de telefoon de camera alleen openen na een echte tik.
async function startCameraIndienNodig() {
  if (cameraOn || !window.isSecureContext) return;
  // Nog nooit iets gevraagd op dit toestel: eerst uitleggen.
  if (!apparaatVroegAl()) { toonCameraVraag(); return; }
  // Browsers op de telefoon openen de camera alleen na een echte tik. Lukt het
  // automatisch niet, dan zetten we het uitlegscherm neer als tikdoel.
  const gelukt = await startCamera();
  if (!gelukt) toonCameraVraag();
}

function toonCameraVraag() {
  $('cvTitel').textContent = t('cam_ask_title');
  $('cvTekst').textContent = t('cam_ask_text');
  $('cvApparaat').textContent = t('cam_ask_device');
  $('cvToestaan').textContent = t('cam_allow');
  $('cvZonder').textContent = t('cam_without');
  $('cameraVraag').classList.add('aan');
}

/// Onthoudt of we na het toestaan meteen door moeten naar het kalibreren.
let naVraagKalibreren = false;

$('cvToestaan').addEventListener('click', async e => {
  e.stopPropagation();
  $('cvToestaan').disabled = true;
  const gelukt = await startCamera();   // in de tik zelf, anders weigert Safari
  $('cvToestaan').disabled = false;
  if (!gelukt) return;                  // scherm blijft staan, melding is zichtbaar
  $('cameraVraag').classList.remove('aan');
  localStorage.setItem(APPARAAT_SLEUTEL, 'ja');
  camBalkBijwerken();
  if (naVraagKalibreren) { naVraagKalibreren = false; startCalibration(); return; }
  if (naVraagTrainen) { naVraagTrainen = false; klikTrainAan(); }
});

$('cvZonder').addEventListener('click', e => {
  e.stopPropagation();
  naVraagKalibreren = false;
  $('cameraVraag').classList.remove('aan');
  camBalkBijwerken();
  $('hint').textContent = t('hint_tap');
});

/* ---------------------------------------------------------------
   Geluid. Alles wordt hier ter plekke gemaakt met de Web Audio API — geen
   bestanden, want de pagina moet één bestand blijven. Een push-up geeft een
   toon die oploopt zolang je in ritme blijft, knoppen geven een klikje, en op
   de achtergrond kan een rustige lus meelopen. Allebei apart regelbaar bij de
   instellingen; op nul staat alles stil.
---------------------------------------------------------------- */
let audio = null, muziekLus = null, muziekStap = 0, laatsteToon = 0, toonTrap = 0;
let volEffect = Math.min(100, Math.max(0, +(localStorage.getItem('orbslayer.geluid') ?? 70)));
let volMuziek = Math.min(100, Math.max(0, +(localStorage.getItem('orbslayer.muziek') ?? 30)));

/// Browsers laten geluid pas toe na een echte aanraking; daarom wordt de
/// audio pas bij de eerste tik wakker gemaakt.
function audioAan() {
  try {
    if (!audio) {
      const Bouw = window.AudioContext || window.webkitAudioContext;
      if (!Bouw) return null;
      audio = new Bouw();
    }
    if (audio.state === 'suspended') audio.resume();
    return audio;
  } catch (e) { return null; }
}

/// Eén korte toon met een zachte in- en uitloop, zodat het niet klikt.
function toon(hz, duur = 0.12, golf = 'triangle', luid = 1, wacht = 0) {
  const ac = audioAan();
  if (!ac || volEffect <= 0) return;
  const t0 = ac.currentTime + wacht;
  const bron = ac.createOscillator(), knop = ac.createGain();
  bron.type = golf;
  bron.frequency.setValueAtTime(hz, t0);
  const top = 0.16 * luid * (volEffect / 100);
  knop.gain.setValueAtTime(0.0001, t0);
  knop.gain.exponentialRampToValueAtTime(top, t0 + 0.01);
  knop.gain.exponentialRampToValueAtTime(0.0001, t0 + duur);
  bron.connect(knop).connect(ac.destination);
  bron.start(t0);
  bron.stop(t0 + duur + 0.03);
}

/// De ladder waarlangs de push-uptoon omhoog kruipt zolang je doorgaat.
const TOONLADDER = [294, 330, 370, 392, 440, 494, 554, 587, 659, 740];
function geluidPush() {
  const nu = Date.now();
  toonTrap = (nu - laatsteToon <= COMBO_WINDOW) ? Math.min(toonTrap + 1, TOONLADDER.length - 1) : 0;
  laatsteToon = nu;
  toon(TOONLADDER[toonTrap], 0.13, 'triangle', 1);
}
const geluidTik = () => toon(760, 0.045, 'square', 0.3);
const geluidKill = () => [523, 659, 784].forEach((hz, i) => toon(hz, 0.15, 'triangle', 0.85, i * 0.06));
const geluidWin = () => [523, 659, 784, 1047].forEach((hz, i) => toon(hz, 0.22, 'triangle', 1, i * 0.08));
const geluidVerlies = () => [330, 262, 196].forEach((hz, i) => toon(hz, 0.28, 'sawtooth', 0.5, i * 0.1));
const geluidLevel = () => [659, 784, 988, 1319].forEach((hz, i) => toon(hz, 0.26, 'sine', 1, i * 0.07));

/// Een trage lus in mineur: bas eronder, af en toe een noot erboven.
const MUZIEK_BAS = [110, 110, 98, 98, 87, 87, 98, 98];
const MUZIEK_TOP = [0, 330, 0, 392, 0, 294, 0, 440, 0, 330, 0, 262, 0, 392, 0, 0];
function muziekTik() {
  const ac = audioAan();
  if (!ac || volMuziek <= 0) return;
  const t0 = ac.currentTime;
  const luid = volMuziek / 100;
  const speel = (hz, duur, golf, sterkte) => {
    const bron = ac.createOscillator(), knop = ac.createGain(), zeef = ac.createBiquadFilter();
    zeef.type = 'lowpass';
    zeef.frequency.setValueAtTime(900, t0);
    bron.type = golf;
    bron.frequency.setValueAtTime(hz, t0);
    knop.gain.setValueAtTime(0.0001, t0);
    knop.gain.exponentialRampToValueAtTime(sterkte * luid, t0 + 0.08);
    knop.gain.exponentialRampToValueAtTime(0.0001, t0 + duur);
    bron.connect(zeef).connect(knop).connect(ac.destination);
    bron.start(t0);
    bron.stop(t0 + duur + 0.05);
  };
  if (muziekStap % 2 === 0) speel(MUZIEK_BAS[(muziekStap / 2) % MUZIEK_BAS.length], 0.9, 'triangle', 0.05);
  const boven = MUZIEK_TOP[muziekStap % MUZIEK_TOP.length];
  if (boven) speel(boven, 1.1, 'sine', 0.028);
  muziekStap++;
}

function muziekBij() {
  clearInterval(muziekLus);
  muziekLus = null;
  if (volMuziek > 0 && !document.hidden) muziekLus = setInterval(muziekTik, 460);
}
document.addEventListener('visibilitychange', muziekBij);

// Elke knop in het spel geeft hetzelfde klikje; zo klinkt overal hetzelfde.
document.addEventListener('click', e => {
  if (e.target.closest('button')) geluidTik();
}, true);
// De eerste aanraking maakt de audio wakker en start zo nodig de muziek.
['pointerdown', 'keydown'].forEach(soort =>
  window.addEventListener(soort, () => { audioAan(); muziekBij(); }, { once: true }));

function melding(tekst, duur = 1900) {
  const el = $('melding');
  el.textContent = tekst;
  el.style.opacity = 1;
  clearTimeout(el._t);
  el._t = setTimeout(() => el.style.opacity = 0, duur);
}

function renderMenu() {
  const arena = arenaAt(idxNu()), c = arena.rgb, f = enemy.hp / enemy.max;
  menuKnoppenBij();
  $('menuAura').style.background =
    `radial-gradient(circle at 50% 0%, ${rgbCss(c, .18)}, transparent 60%)`;
  document.querySelector('.mTitel').style.textShadow = `0 0 22px ${rgbCss(c, .8)}`;

  $('mRang').textContent = t('rank_level', spelerTitel(), playerLevel());
  const [cur, need] = levelProg();
  $('mXpVul').style.width = (cur / need * 100) + '%';
  $('mXpVul').style.background = `linear-gradient(to right, ${rgbCss(c)}, #ffc740)`;
  $('mXpTekst').textContent = t('xp_of', cur, need);

  $('mArenaLabel').textContent = t('arena_n_race', idxNu(), tt(arena.race).toUpperCase());
  $('mArenaNaam').textContent = tt(arena.name);
  $('mArenaNaam').style.color = rgbCss(c);
  $('mIcoon').innerHTML = monsterPaden(arena, orbCss(c, f));
  $('mIcoon').style.filter = 'none';
  $('mVijand').textContent = enemy.boss ? t('boss_named', vijandNaam()) : vijandNaam();
  $('mVijand').style.color = enemy.boss ? '#f2263a' : '#fff';
  $('mHp').textContent = t('hp_short', enemy.hp);

  $('mPips').innerHTML = '';
  for (let i = 0; i < 10; i++) {
    const el = document.createElement('i');
    el.style.background = i < killsNu() ? rgbCss(c)
      : (i === 9 ? 'rgba(242,38,58,.5)' : 'rgba(255,255,255,.15)');
    $('mPips').appendChild(el);
  }

  $('mRij').innerHTML = '';
  // Alles wat je al veroverd hebt blijft in de strook staan: scroll terug en
  // tik erop om die arena opnieuw te bevechten. De trofee kreeg je al.
  let scrollDoel = null;
  for (let i = 1; i < P.arenaIndex; i++) {
    const a = arenaAt(i);
    const knop = document.createElement('button');
    knop.className = 'mSlot' + (bezoek === i ? ' mHier' : '');
    knop.innerHTML =
      `<div class="mVak"><svg viewBox="0 0 100 100">${monsterPaden(a, rgbCss(a.rgb, .85))}</svg></div>` +
      `<div class="mSlotNaam" style="color:rgba(255,255,255,.75)">${tt(a.name)}</div>` +
      `<div class="mSlotRas">${tt(a.race)}</div>` +
      `<div class="mSlotSlot">✓</div>`;
    knop.onclick = e => { e.stopPropagation(); startBezoek(i); };
    if (bezoek === i) scrollDoel = knop;
    $('mRij').appendChild(knop);
  }
  // Tijdens een terugbezoek staat de voorhoede zelf ook in de strook, zodat je
  // er met één tik weer naartoe kunt.
  if (bezoek !== null) {
    const a = arenaAt(P.arenaIndex);
    const knop = document.createElement('button');
    knop.className = 'mSlot mVoorhoede';
    knop.innerHTML =
      `<div class="mVak"><svg viewBox="0 0 100 100">${monsterPaden(a, rgbCss(a.rgb, .85))}</svg></div>` +
      `<div class="mSlotNaam" style="color:rgba(255,255,255,.9)">${tt(a.name)}</div>` +
      `<div class="mSlotRas">${tt(a.race)}</div>` +
      `<div class="mSlotSlot">▶</div>`;
    knop.onclick = e => { e.stopPropagation(); terugVoorhoede(); };
    $('mRij').appendChild(knop);
  }
  for (let n = 1; n <= VOORUIT + RAADSELS; n++) {
    const index = P.arenaIndex + n;
    const zichtbaar = n <= VOORUIT;
    const a = zichtbaar ? arenaAt(index) : null;
    const knop = document.createElement('button');
    knop.className = 'mSlot';
    knop.innerHTML =
      `<div class="mVak">` +
      (a ? `<svg viewBox="0 0 100 100">${monsterPaden(a, rgbCss(a.rgb, .5))}</svg>`
         : `<span>?</span>`) +
      `</div>` +
      `<div class="mSlotNaam" style="color:${a ? 'rgba(255,255,255,.75)' : 'rgba(255,255,255,.4)'}">` +
      `${a ? tt(a.name) : t('unknown_arena')}</div>` +
      `<div class="mSlotRas">${a ? tt(a.race) : t('unknown_race')}</div>` +
      `<div class="mSlotSlot">🔒</div>`;
    knop.onclick = e => {
      e.stopPropagation();
      melding(a ? t('locked_known', tt(a.name), index - 1) : t('locked_unknown'));
    };
    $('mRij').appendChild(knop);
  }

  // Zet de strook op de goede plek: bij de arena waar je nu bent. Alleen als
  // de situatie veranderd is, zodat zelf scrollen niet steeds terugspringt.
  const stand = P.arenaIndex + ':' + bezoek;
  if (stand !== mRijStand) {
    mRijStand = stand;
    const doel = scrollDoel || $('mRij').children[Math.max(0, P.arenaIndex - 1)];
    if (doel) requestAnimationFrame(() =>
      $('mRij').scrollLeft = Math.max(0, doel.offsetLeft - $('mRij').offsetLeft - 12));
  }
}

/// Terug naar een oude arena: gewoon vechten, maar zonder nieuwe trofee.
function startBezoek(i) {
  if (i === bezoek) return;
  bezoek = i; bezoekKills = 0; bezoekHP = null;
  spawn();
  renderMenu();
  showIntro(arenaAt(i), i);
}

function terugVoorhoede() {
  bezoek = null; bezoekHP = null;
  spawn();
  renderMenu();
}

function spelerTitel() {
  const l = playerLevel();
  const n = l < 3 ? 1 : l < 5 ? 2 : l < 8 ? 3 : l < 12 ? 4
          : l < 16 ? 5 : l < 20 ? 6 : l < 30 ? 7 : 8;
  return t('rank_' + n);
}

function bouwTaalKnoppen(vak) {
  vak.innerHTML = '';
  for (const code of TALEN) {
    const k = document.createElement('button');
    k.className = 'taalKnop' + (code === TAAL ? ' aan' : '');
    k.dataset.taal = code;
    k.textContent = code.toUpperCase();
    k.onclick = e => { e.stopPropagation(); zetTaal(code); };
    vak.appendChild(k);
  }
}

function bouwTaalRij() {
  bouwTaalKnoppen($('taalRij'));
  bouwTaalKnoppen($('rlTaal'));
}

$('vechten').addEventListener('click', e => { e.stopPropagation(); toonGevecht(); });
$('terug').addEventListener('click', e => { e.stopPropagation(); toonMenu(); });

setInterval(() => { if (combo && Date.now() - lastRep > COMBO_WINDOW) { combo = 0; render(); } }, 400);

/* ---------------------------------------------------------------
   Hoofdtracking via de camera.
   Hetzelfde principe als HeadTracker.swift: een houdingsmodel geeft
   losse punten voor neus, ogen en oren. We middelen alles wat het van
   je hoofd ziet, dus ook je oren en achterhoofd. Daardoor blijf je
   gevolgd als je onderin een push-up naar de grond kijkt — juist dan
   is je gezicht niet meer te zien, maar je oor wel.
---------------------------------------------------------------- */
/// De punten van het houdingsmodel die bij je hoofd horen. MoveNet zet ze
/// altijd vooraan, dus als de namen ooit anders heten vallen we terug op de
/// eerste vijf punten.
const HOOFDPUNTEN = ['nose', 'left_eye', 'right_eye', 'left_ear', 'right_ear'];

/* Terugval zonder download: silhouet-tracking.
   Sommige omgevingen laten geen externe bestanden laden, en dan is er geen
   houdingsmodel. We vergelijken het beeld dan met een langzaam meelopende
   achtergrond en pakken de bovenste rij die duidelijk afwijkt. Vanaf de zijkant
   is dat de bovenkant van je hoofd of je schouders — precies wat we willen
   volgen, en het werkt ook als je naar de grond kijkt. */
const RASTER_B = 80, RASTER_H = 60;
const VERSCHIL_DREMPEL = 26;
let achtergrond = null;
let werkCtx = null;

function silhouetHoogte(bron) {
  if (!werkCtx) {
    const c = document.createElement('canvas');
    c.width = RASTER_B; c.height = RASTER_H;
    werkCtx = c.getContext('2d', { willReadFrequently: true });
  }
  werkCtx.drawImage(bron, 0, 0, RASTER_B, RASTER_H);
  const d = werkCtx.getImageData(0, 0, RASTER_B, RASTER_H).data;
  const luma = new Float32Array(RASTER_B * RASTER_H);
  for (let i = 0, p = 0; i < d.length; i += 4, p++) {
    luma[p] = 0.299 * d[i] + 0.587 * d[i + 1] + 0.114 * d[i + 2];
  }
  if (!achtergrond) { achtergrond = luma.slice(); return null; }

  let bovensteRij = -1;
  const nodig = Math.max(3, Math.round(RASTER_B * 0.06));
  for (let y = 0; y < RASTER_H && bovensteRij < 0; y++) {
    let anders = 0;
    for (let x = 0; x < RASTER_B; x++) {
      if (Math.abs(luma[y * RASTER_B + x] - achtergrond[y * RASTER_B + x]) > VERSCHIL_DREMPEL) {
        anders++;
      }
    }
    if (anders >= nodig) bovensteRij = y;
  }
  // De achtergrond loopt heel langzaam mee, zodat veranderend licht niet stoort.
  for (let p = 0; p < luma.length; p++) {
    achtergrond[p] = achtergrond[p] * 0.995 + luma[p] * 0.005;
  }
  if (bovensteRij < 0) return null;
  return 1 - bovensteRij / (RASTER_H - 1);
}

/* ---------------------------------------------------------------
   Meekijken met je houding.

   Het houdingsmodel geeft niet alleen je hoofd terug maar ook je schouders,
   heupen en knieën. Daarmee kunnen we zien of je écht in de goede houding
   ligt of staat. Wie rechtop zit en alleen met zijn hoofd knikt, heeft een
   rechtopstaande romp — en dat telt dus niet.

   Tegelijk ijkt hij zichzelf: zolang je houding klopt onthoudt hij hoe hoog
   en hoe laag je hoofd komt, en daar worden de drempels vanzelf op gezet.
   Je hoeft dus niets meer in te stellen.
---------------------------------------------------------------- */
const punt = (kp, naam) => kp.find(k => k.name === naam && (k.score ?? 1) > 0.3) || null;
const eenVan = (kp, a, b) => punt(kp, a) || punt(kp, b);

let houdingOk = true, houdingSlecht = 0, houdingGoed = 0;
/// Sommige opstellingen krijgen je romp niet in beeld; dan kun je het
/// meekijken uitzetten. Standaard staat het aan.
let houdingAan = localStorage.getItem('orbslayer.houding') !== 'uit';
let autoLaag = null, autoHoog = null, autoRijp = 0, autoGemeld = false;

/// Klopt de houding een beetje? Bewust grofmazig: hij grijpt alleen in als
/// hij het zeker weet, want een controle die te streng is telt je goede
/// herhalingen niet meer mee. Ziet hij weinig, dan gaat hij ervan uit dat
/// het klopt — liever een keer te veel geteld dan een sessie voor niets.
function houdingKlopt(keypoints) {
  if (!keypoints || !keypoints.length) return null;
  const schouder = eenVan(keypoints, 'left_shoulder', 'right_shoulder');
  const arm = eenVan(keypoints, 'left_elbow', 'right_elbow')
           || eenVan(keypoints, 'left_wrist', 'right_wrist');
  const heup = eenVan(keypoints, 'left_hip', 'right_hip');

  // Zien we je schouder en je arm, dan ben je met je bovenlichaam bezig en
  // is dat genoeg bewijs. De rest hoeft niet in beeld.
  if (SPORT !== 'squat' && schouder && arm) return true;

  // Alleen als romp én heup goed zichtbaar zijn durven we iets af te keuren.
  if (!schouder || !heup) return true;
  const dx = Math.abs(schouder.x - heup.x), dy = Math.abs(schouder.y - heup.y);
  if (SPORT === 'squat') {
    // Plat op de grond is geen squat; alle andere houdingen laten we door.
    return !(dx > dy * 1.8);
  }
  // Kaarsrecht overeind is geen push-up of sit-up; twijfelgevallen tellen wel.
  return !(dy > dx * 1.8);
}

/// Zolang de houding klopt, onthoudt hij hoe hoog en hoe laag je komt en zet
/// hij de drempels daar vanzelf op.
function zelfIjken(waarde) {
  if (autoLaag === null) { autoLaag = autoHoog = waarde; return; }
  // Uitschieters pakken we meteen, terugkruipen gaat langzaam — zo blijft de
  // ijking meelopen als je een stukje verschuift.
  autoLaag += (waarde - autoLaag) * (waarde < autoLaag ? 0.4 : 0.006);
  autoHoog += (waarde - autoHoog) * (waarde > autoHoog ? 0.4 : 0.006);
  if (autoHoog - autoLaag < 0.10) { autoRijp = 0; return; }
  if (++autoRijp < 25) return;
  CAL = { top: autoHoog, bottom: autoLaag };
  localStorage.setItem('orbslayer.cal.' + SPORT, JSON.stringify(CAL));
  updateMarks();
  if (!autoGemeld) { autoGemeld = true; melding(t('houd_geijkt'), 4000); }
}

function hoofdPunten(keypoints) {
  if (!keypoints || !keypoints.length) return null;
  const genoeg = k => (k.score ?? 1) > 0.3;
  const opNaam = keypoints.filter(k => HOOFDPUNTEN.includes(k.name) && genoeg(k));
  if (opNaam.length) return opNaam;
  if (keypoints.some(k => HOOFDPUNTEN.includes(k.name))) return null;  // wel namen, maar te zwak
  return keypoints.slice(0, 5).filter(genoeg);
}
let cameraOn = false, model = null, stream = null, volgWijze = 'model';
let smoothed = null, wentDown = false, lastCamRep = 0, missed = 0, seesFace = false;
const MIN_REP_MS = 450;

const loadScript = src => new Promise((ok, fail) => {
  const s = document.createElement('script');
  s.src = src; s.onload = ok; s.onerror = () => fail(new Error('kon niet laden: ' + src));
  document.head.appendChild(s);
});

function camState(text) { $('camState').textContent = text; }

/* Laadscherm: laat zien dát er iets gebeurt, met na een paar tellen een
   geruststelling voor trage verbindingen. */
let traagTimer = null;

function bezig(tekst) {
  $('ladenTekst').textContent = tekst || t('loading');
  $('ladenTraag').textContent = '';
  $('laden').classList.add('aan');
  clearTimeout(traagTimer);
  traagTimer = setTimeout(() => { $('ladenTraag').textContent = t('loading_slow'); }, 4000);
}

function klaar() {
  clearTimeout(traagTimer);
  $('laden').classList.remove('aan');
}

/// Meldt een cameraprobleem op een plek die altijd zichtbaar is. De regel
/// onder in beeld staat er niet in het menu, dus daar zou je het missen.
function cameraFout(bericht) {
  $('hint').innerHTML = bericht;
  // Een camerafout moet je rustig kunnen lezen, dus die blijft langer staan.
  melding(bericht.replace(/<[^>]+>/g, ' '), 6000);
}

/// Geeft terug of de camera daadwerkelijk draait.
async function startCamera() {
  if (!window.isSecureContext) {
    cameraFout(t('cam_needs_https'));
    return false;
  }
  $('camBtn').disabled = true;
  $('camBtn').textContent = t('cam_starting');
  camState(t('cam_permission'));
  bezig(t('loading_camera'));

  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'user', width: { ideal: 640 } }, audio: false
    });
    $('video').srcObject = stream;
    await $('video').play();
    // Pas nu het venster tonen: anders flitst er een leeg kadertje voorbij
    // als de toestemming geweigerd wordt.
    $('cam').classList.add('on');
  } catch (e) {
    klaar();
    localStorage.removeItem(APPARAAT_SLEUTEL);   // opnieuw vragen bij de volgende poging
    cameraFout(e.name === 'NotAllowedError' ? t('cam_denied_help') : t('cam_no_access', e.message));
    $('camBtn').disabled = false;
    $('camBtn').textContent = t('cam_start');
    $('cam').classList.remove('on');
    return false;
  }

  camState(t('cam_loading'));
  bezig(t('loading_model'));
  try {
    if (!window.poseDetection) {
      await loadScript('https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@4.22.0/dist/tf.min.js');
      await loadScript('https://cdn.jsdelivr.net/npm/@tensorflow-models/pose-detection@2.1.3/dist/pose-detection.min.js');
    }
    model = await poseDetection.createDetector(
      poseDetection.SupportedModels.MoveNet,
      { modelType: poseDetection.movenet.modelType.SINGLEPOSE_LIGHTNING }
    );
    volgWijze = 'model';
  } catch (e) {
    // Geen model beschikbaar (bijvoorbeeld omdat downloads geblokkeerd zijn):
    // dan volgen we je silhouet, wat zonder enige download werkt.
    model = null;
    volgWijze = 'silhouet';
    achtergrond = null;
  }

  cameraOn = true;
  $('camBtn').disabled = false;
  $('camBtn').classList.add('on');
  $('camBtn').textContent = t('cam_stop');
  $('hint').textContent = t('hint_camera');
  $('calBtn').classList.add('on');
  klaar();
  camState(t('cam_searching'));
  requestAnimationFrame(trackLoop);

  if (!isGeijkt()) startCalibration();
  return true;
}

function stopCamera() {
  cameraOn = false;
  if (stream) stream.getTracks().forEach(t => t.stop());
  stream = null; smoothed = null; wentDown = false; seesFace = false;
  $('cam').classList.remove('on');
  $('camBtn').classList.remove('on');
  $('camBtn').textContent = t('cam_start');
  $('calBtn').classList.remove('on');
  $('hint').textContent = t('hint_tap');
  setNose(0.9, false);
}

async function trackLoop() {
  if (!cameraOn) return;
  const v = $('video');
  if (v.videoWidth) {
    let height = null, punten = null, alles = null;
    try {
      if (volgWijze === 'model') {
        const poses = await model.estimatePoses(v, { maxPoses: 1, flipHorizontal: false });
        alles = poses[0]?.keypoints || null;
        const kp = hoofdPunten(alles);
        if (kp && kp.length) {
          punten = kp;
          // Het midden van alles wat we van je hoofd zien: neus, ogen, oren.
          const midY = kp.reduce((som, k) => som + k.y, 0) / kp.length;
          height = 1 - midY / v.videoHeight;     // 0 = onderkant beeld, 1 = boven
        }
      } else {
        height = silhouetHoogte(v);
      }
    } catch (e) { /* een enkel mislukt frame slaan we over */ }
    handleFace(height, punten, alles);
  }
  requestAnimationFrame(trackLoop);
}

function handleFace(height, punten, alles) {
  const c = $('dot'), v = $('video');
  c.width = v.videoWidth || 120; c.height = v.videoHeight || 90;
  c.style.height = (c.height / c.width * 120) + 'px';
  const g = c.getContext('2d');
  g.clearRect(0, 0, c.width, c.height);

  if (height === null) {
    if (++missed > 15) { seesFace = false; camState(t('cam_no_face')); }
    return;
  }
  missed = 0; seesFace = true;

  // Zelfde demping als in de Swift-versie.
  smoothed = smoothed === null ? height : smoothed * 0.6 + height * 0.4;
  const value = smoothed;

  if (!punten && volgWijze === 'silhouet') {
    const kleur = value <= DOWN ? '#f2263a' : '#ffc740';
    const lijn = (1 - value) * c.height;
    g.strokeStyle = kleur; g.lineWidth = Math.max(3, c.width * 0.01);
    g.beginPath(); g.moveTo(0, lijn); g.lineTo(c.width, lijn); g.stroke();
  }
  if (punten) {
    const kleur = value <= DOWN ? '#f2263a' : '#ffc740';
    g.fillStyle = kleur;
    for (const k of punten) {
      g.beginPath();
      g.arc(k.x, k.y, Math.max(3, c.width * 0.012), 0, 7);
      g.fill();
    }
    // de hoogte die we daadwerkelijk volgen
    const midY = punten.reduce((som, k) => som + k.y, 0) / punten.length;
    g.strokeStyle = kleur; g.lineWidth = Math.max(3, c.width * 0.01);
    g.beginPath(); g.moveTo(0, midY); g.lineTo(c.width, midY); g.stroke();
  }

  if (calStep > 0) { calValue = value; setNose(value, false); camState(t('cam_searching')); return; }

  // Meekijken met de houding. Zonder model (silhouet) kan dat niet, dan
  // vertrouwen we op de ijking zoals vroeger.
  if (alles && houdingAan) {
    const klopt = houdingKlopt(alles);
    if (klopt === false) { houdingSlecht++; houdingGoed = 0; }
    else if (klopt === true) { houdingGoed++; houdingSlecht = 0; }
    if (houdingSlecht > 30) houdingOk = false;   // ruim een seconde echt fout
    if (houdingGoed > 3) houdingOk = true;
    if (houdingOk) zelfIjken(value);
  }

  setNose(value, value <= DOWN);
  camState(houdingOk ? t('cam_height', Math.round(value * 100)) : t('houd_goed'));
  if (!houdingOk && houdingAan) {
    $('hint').textContent = t('houd_fout_' + SPORT);
    wentDown = false;
    return;
  }

  if (value <= DOWN) {
    wentDown = true;
  } else if (value >= UP && wentDown) {
    wentDown = false;
    const now = Date.now();
    if (now - lastCamRep >= MIN_REP_MS) { lastCamRep = now; pushup(true); }
  }
}

$('camBtn').addEventListener('click', async e => {
  e.stopPropagation();
  if (cameraOn) { stopCamera(); return; }
  await startCamera();
  if (cameraOn) localStorage.setItem(APPARAAT_SLEUTEL, 'ja');
});
$('calBtn').addEventListener('click', e => { e.stopPropagation(); startCalibration(); });

/* Kalibratie in twee stappen, net als CalibrationView.swift */
let calStep = 0, calValue = 0.5, calTop = null, calTimer = null;

/// Boven en beneden betekenen per oefening iets anders; de meting blijft
/// hetzelfde (de hoogte van je hoofd), alleen de uitleg verschilt.
function calTekst(stap) {
  const sleutel = 'cal_' + (stap === 0 ? 'boven' : 'beneden') + '_' + SPORT;
  return TEKSTEN[sleutel] ? (TEKSTEN[sleutel][TALEN.indexOf(TAAL)] || '') : '';
}

function startCalibration() {
  if (!cameraOn) { $('hint').textContent = t('cam_start'); return; }
  calStep = 1; calTop = null;
  $('calStep').textContent = t('cal_step', 1);
  $('calTitle').textContent = calTekst(0) || t('cal_title_up');
  $('calText').textContent = t('cal_text_up');
  $('calCount').textContent = '';
  $('calib').classList.add('on');
}

function calCapture() {
  if (calStep === 1) {
    calTop = calValue;
    calStep = 2;
    $('calStep').textContent = t('cal_step', 2);
    $('calTitle').textContent = calTekst(1) || t('cal_title_down');
    $('calText').textContent = t('cal_text_down');
    $('calCount').textContent = '';
  } else {
    const bottom = calValue;
    if (calTop - bottom > 0.05) {
      CAL = { top: calTop, bottom };
      localStorage.setItem('orbslayer.cal.' + SPORT, JSON.stringify(CAL));
      updateMarks();
    } else {
      melding(t('cal_too_small'), 5000);
    }
    calStep = 0;
    $('calib').classList.remove('on');
    camBalkBijwerken();
  }
}

$('calGo').addEventListener('click', e => {
  e.stopPropagation();
  let n = 3;
  $('calCount').textContent = n;
  $('calGo').disabled = true;
  clearInterval(calTimer);
  calTimer = setInterval(() => {
    n--;
    $('calCount').textContent = n > 0 ? n : '';
    if (n <= 0) { clearInterval(calTimer); $('calGo').disabled = false; calCapture(); }
  }, 1000);
});
$('calSkip').addEventListener('click', e => {
  e.stopPropagation();
  clearInterval(calTimer); $('calGo').disabled = false; calStep = 0;
  $('calib').classList.remove('on');
  camBalkBijwerken();
});

/* ---------------------------------------------------------------
   Duel: 60 seconden tegen een tegenstander die zijn doel gelijkmatig over
   de minuut verdeelt. Het niveau (1–100%) bepaalt hoeveel hij in die minuut
   doet en hoeveel XP een overwinning waard is. Bij 100% moet je er
   honderd doen in één minuut — vandaar dat vrijwel niemand dat wint.
---------------------------------------------------------------- */
const DUEL_SECONDEN = 60;

/// Hoeveel push-ups je tegenstander haalt. Onderaan mild, bovenaan meedogenloos.
const doelBasis = n => Math.round(4 + Math.pow(n / 100, 1.35) * 96);
/// Hoeveel het per poging mag schelen, zodat hetzelfde percentage niet elke
/// keer exact hetzelfde duel oplevert.
const doelSpreiding = n => Math.min(4, Math.max(1, Math.round(doelBasis(n) * 0.06)));
/// Trekt het doel voor één duel: de basis plus of min de spreiding.
function trekDoel(n) {
  const s = doelSpreiding(n);
  return Math.max(1, doelBasis(n) + Math.round((Math.random() * 2 - 1) * s));
}

/// Acht moeilijkheidsbanden met een eigen woord en kleur.
const BAND_KLEUR = ['#4ade80', '#a3e635', '#facc15', '#ffc740',
                    '#ff9426', '#ff7326', '#f2263a', '#b00d1c'];
const bandNummer = n => n <= 15 ? 1 : n <= 30 ? 2 : n <= 45 ? 3 : n <= 60 ? 4
                      : n <= 75 ? 5 : n <= 88 ? 6 : n <= 97 ? 7 : 8;
const bandWoord = n => t('band_' + bandNummer(n));
const bandKleur = n => BAND_KLEUR[bandNummer(n) - 1];
/// XP bij winst; stijgt sneller dan het niveau zelf.
const duelWinstXP = n => Math.round(20 + Math.pow(n / 100, 1.5) * 480);
/// Verliezen levert een schamele troostprijs op.
const duelVerliesXP = n => Math.max(1, Math.round(duelWinstXP(n) * 0.06));

let duelFase = 'uit';        // uit | aftellen | bezig | klaar
let duelNiveau = 50, duelStart = 0, duelJij = 0, duelTegen = 0, duelTimer = null, duelDoel = 0;

function toonModi() {
  $('modes').classList.add('aan');
  $('modesKop').textContent = t('menu_modes');
  if (lesStap === 5) lesVolgende();
  const vul = (id, icoon, titel, sub, actief) => {
    const k = $(id);
    k.querySelector('path').setAttribute('d', icoon);
    k.querySelector('path').setAttribute('fill', actief ? '#ffc740' : 'rgba(255,255,255,.55)');
    k.querySelector('b').textContent = titel;
    k.querySelector('span').textContent = sub;
    k.classList.toggle('aan', actief);
  };
  vul('modeArena', MODE_ICONEN.arena, t('mode_arena'), t('mode_arena_sub'), true);
  vul('modeDuel', MODE_ICONEN.duel, t('mode_duel'), t('mode_duel_sub'), false);
  vul('modeOnline', MODE_ICONEN.online, t('mode_online'), t('mode_online_sub'), false);
  vul('modeBoss', MODE_ICONEN.boss, t('mode_boss'), t('mode_boss_sub'), false);
  vul('modeMuziek', MODE_ICONEN.muziek, t('mode_muziek'), t('mode_muziek_sub'), false);
  vul('modeKlik', MODE_ICONEN.klik, t('mode_klik'), t('mode_klik_sub'), false);
  $('modesDicht').title = t('close');
}

/// De knoppen om het speelveld heen: opdrachten linksonder en het lintje op
/// je tegenstander. Allebei laten ze alleen zien hoeveel er klaarligt.
function menuKnoppenBij() {
  $('extraQuests').textContent = t('quests_titel');
  const q = questStaat(), dag = dagQuests();
  const af = dag.filter(x => q.dagKlaar.includes(x.id)).length;
  const teHalen = questTeHalen();
  $('questBadge').textContent = teHalen ? teHalen : af + '/' + dag.length;
  $('questBadge').classList.toggle('af', teHalen > 0);
  const padOp = bpTeHalen();
  $('mPadTip').hidden = !padOp;
  $('mPadTipTal').textContent = padOp;
}

function toonDuelSetup() {
  $('modes').classList.remove('aan');
  $('menu').classList.add('uit');
  $('stage').classList.add('uit');
  $('duel').classList.remove('aan');
  $('duelSetup').classList.add('aan');
  $('cambalk').classList.add('aan');
  duelFase = 'uit';
  startCameraIndienNodig();
  $('duelSetupTitel').textContent = t('mode_duel');
  $('duelSetupSub').textContent = t('mode_duel_sub');
  $('niveauLabel').textContent = t('difficulty');
  $('duelStart').textContent = t('duel_start');
  $('duelTerug').textContent = t('duel_to_menu');
  $('niveau').value = P.duelLevel ?? 50;
  werkNiveauBij();
}

function werkNiveauBij() {
  duelNiveau = +$('niveau').value;
  P.duelLevel = duelNiveau;
  const kleur = bandKleur(duelNiveau);
  $('niveauWaarde').textContent = duelNiveau + '%';
  $('niveauWaarde').style.color = kleur;
  $('niveau').style.accentColor = kleur;
  $('duelDoelTekst').textContent = bandWoord(duelNiveau);
  $('duelDoelTekst').style.color = kleur;
  $('duelWaarschuwing').textContent = duelNiveau >= 95 ? t('duel_warn_100') : '';
  const beste = P.duelBest?.[duelNiveau];
  $('duelBeste').textContent = t('duel_best', beste ? beste : t('duel_none_yet'));
}

function startDuel() {
  if (!cameraOn && window.isSecureContext) {
    // Zonder camera zou je moeten tikken; even melden dat dat kan.
    melding(t('cam_needed'));
  }
  $('duelSetup').classList.remove('aan');
  $('duel').classList.add('aan');
  $('duelBalkVak').appendChild($('nosebar'));   // de hoogtebalk verhuist mee
  $('cambalk').classList.add('aan');
  duelJij = 0; duelTegen = 0;
  duelDoel = trekDoel(duelNiveau);
  $('duelNiveauTitel').textContent = bandWoord(duelNiveau) + ' · ' + duelNiveau + '%';
  $('duelNiveauTitel').style.color = bandKleur(duelNiveau);
  $('racerJijNaam').textContent = t('duel_you');
  $('racerTegenNaam').textContent = t('duel_ai');
  $('racerTegenDoel').textContent = t('duel_intro');
  tekenDuel();

  duelFase = 'aftellen';
  let n = 3;
  $('duelAftel').classList.add('aan');
  $('duelAftel').textContent = n;
  const aftel = setInterval(() => {
    n--;
    if (n > 0) { $('duelAftel').textContent = n; return; }
    clearInterval(aftel);
    $('duelAftel').textContent = t('duel_go');
    setTimeout(() => {
      $('duelAftel').classList.remove('aan');
      duelFase = 'bezig';
      duelStart = Date.now();
      duelTimer = setInterval(duelTik, 100);
    }, 500);
  }, 1000);
}

function duelTik() {
  const verstreken = (Date.now() - duelStart) / 1000;
  const over = Math.max(0, DUEL_SECONDEN - verstreken);
  // De tegenstander verdeelt zijn doel gelijkmatig over de minuut.
  duelTegen = Math.min(duelDoel, Math.floor(duelDoel * verstreken / DUEL_SECONDEN));
  $('duelKlok').textContent = Math.ceil(over);
  $('duelKlok').classList.toggle('krap', over <= 10);
  tekenDuel();
  if (over <= 0) eindigDuel();
}

function duelRep() {
  duelJij++;
  P.totalReps++;
  klikRepBonus();
  if (navigator.vibrate) navigator.vibrate(10);
  animateNose();
  tekenDuel();
  save();
}

function tekenDuel() {
  const schaal = Math.max(duelDoel, duelJij, 1);
  $('racerJijTal').textContent = duelJij;
  $('racerTegenTal').textContent = duelTegen;
  $('racerJijVul').style.width = (duelJij / schaal * 100) + '%';
  $('racerTegenVul').style.width = (duelTegen / schaal * 100) + '%';
}

function eindigDuel() {
  clearInterval(duelTimer);
  duelFase = 'klaar';
  const doel = duelDoel;
  const gewonnen = duelJij >= doel;
  const xp = (gewonnen ? duelWinstXP(duelNiveau) : duelVerliesXP(duelNiveau)) * xpMaal();

  P.totalXP += xp;
  bpNakijken();
  if (gewonnen) { P.duelsWon = (P.duelsWon || 0) + 1; tikStreak(); questTel('duel'); }
  P.duelBest = P.duelBest || {};
  if (duelJij > (P.duelBest[duelNiveau] || 0)) P.duelBest[duelNiveau] = duelJij;
  save();

  (gewonnen ? geluidWin : geluidVerlies)();
  $('duelUitKop').textContent = gewonnen ? t('duel_win') : t('duel_lose');
  $('duelUitKop').style.color = gewonnen ? '#ffc740' : '#f2263a';
  $('duelUitScore').textContent = t('duel_score', duelJij, doel);
  $('duelUitBeloning').textContent = gewonnen ? t('duel_reward', xp) : t('duel_consolation', xp);
  $('duelNogmaals').textContent = t('duel_again');
  $('duelNaarMenu').textContent = t('duel_to_menu');
  $('duelUit').classList.add('aan');
  if (navigator.vibrate) navigator.vibrate(gewonnen ? [30, 60, 30] : 20);
}

function verlaatDuel() {
  clearInterval(duelTimer);
  duelFase = 'uit';
  $('cambalk').classList.remove('aan');
  $('duelUit').classList.remove('aan');
  $('duel').classList.remove('aan');
  $('duelSetup').classList.remove('aan');
  $('stage').querySelector('.middle').appendChild($('nosebar'));  // balk terug
  toonMenu();
}

/* Instellingen: hoe diep je moet zakken, en opnieuw kalibreren. */
function toonInstellingen() {
  $('instel').classList.add('aan');
  $('instelKop').textContent = t('settings');
  $('taalLabel').textContent = t('language').toUpperCase();
  $('diepteLabel').textContent = t('depth').toUpperCase();
  $('diepteUitleg').textContent = t('depth_hint');
  $('kalibreerKnop').textContent = t('cal_voor', sportNaam(SPORT));
  $('kalibreerUitleg').textContent = isGeijkt() ? '' : t('cal_nodig');
  $('rondleidingKnop').textContent = t('tour_again');
  $('instelDicht').title = t('close');
  $('houdLabel').textContent = t('houd_label').toUpperCase();
  $('houdUitleg').textContent = t('houd_uitleg');
  $('houdRij').innerHTML = '';
  [[true, 'houd_aan'], [false, 'houd_uit']].forEach(([aan, sleutel]) => {
    const knop = document.createElement('button');
    knop.className = 'sportKnop' + (houdingAan === aan ? ' aan' : '');
    knop.textContent = t(sleutel);
    knop.onclick = e => {
      e.stopPropagation();
      houdingAan = aan;
      localStorage.setItem('orbslayer.houding', aan ? 'aan' : 'uit');
      if (!aan) houdingOk = true;
      toonInstellingen();
    };
    $('houdRij').appendChild(knop);
  });
  $('geluidLabel').textContent = t('geluid_label').toUpperCase();
  $('muziekLabel').textContent = t('muziek_label').toUpperCase();
  $('geluidUitleg').textContent = t('geluid_uitleg');
  $('muziekUitleg').textContent = t('muziek_uitleg');
  $('geluid').value = volEffect;
  $('muziek').value = volMuziek;
  werkGeluidBij();
  $('diepte').value = Math.round(DIEPTE * 100);
  werkDiepteBij();
}

function werkDiepteBij() {
  DIEPTE = +$('diepte').value / 100;
  localStorage.setItem('orbslayer.diepte', DIEPTE);
  $('diepteWaarde').textContent = t('depth_value', Math.round(DIEPTE * 100));
  updateMarks();
}

$('tandwiel').addEventListener('click', e => { e.stopPropagation(); toonInstellingen(); });
/// De schuiven voor geluid en muziek. Op nul is het echt stil.
function werkGeluidBij() {
  volEffect = +$('geluid').value;
  volMuziek = +$('muziek').value;
  localStorage.setItem('orbslayer.geluid', volEffect);
  localStorage.setItem('orbslayer.muziek', volMuziek);
  $('geluidWaarde').textContent = volEffect ? volEffect + '%' : t('geluid_uit');
  $('muziekWaarde').textContent = volMuziek ? volMuziek + '%' : t('geluid_uit');
  muziekBij();
}
$('geluid').addEventListener('input', () => { werkGeluidBij(); });
$('geluid').addEventListener('change', () => toon(660, 0.12, 'triangle', 1));
$('muziek').addEventListener('input', werkGeluidBij);
$('diepte').addEventListener('input', werkDiepteBij);
$('instelDicht').addEventListener('click', e => {
  e.stopPropagation(); $('instel').classList.remove('aan');
});
$('rondleidingKnop').addEventListener('click', e => {
  e.stopPropagation();
  $('instel').classList.remove('aan');
  toonMenu();
  lesStart();
});

$('kalibreerKnop').addEventListener('click', async e => {
  e.stopPropagation();
  $('instel').classList.remove('aan');
  if (cameraOn) { startCalibration(); return; }
  // Kalibreren kan alleen met beeld. Heeft dit toestel nog niets toegestaan,
  // dan eerst uitleggen; daarna kalibreren we vanzelf verder.
  if (!apparaatVroegAl()) { naVraagKalibreren = true; toonCameraVraag(); return; }
  if (await startCamera()) startCalibration();
  else { naVraagKalibreren = true; toonCameraVraag(); }
});

$('burger').addEventListener('click', e => { e.stopPropagation(); toonModi(); });
$('modesDicht').addEventListener('click', e => { e.stopPropagation(); $('modes').classList.remove('aan'); });
$('modeArena').addEventListener('click', e => {
  e.stopPropagation(); $('modes').classList.remove('aan'); toonMenu();
});
$('modeDuel').addEventListener('click', e => { e.stopPropagation(); toonDuelSetup(); });
$('niveau').addEventListener('input', werkNiveauBij);
$('duelStart').addEventListener('click', e => { e.stopPropagation(); startDuel(); });
$('duelTerug').addEventListener('click', e => { e.stopPropagation(); verlaatDuel(); });
$('duelNogmaals').addEventListener('click', e => {
  e.stopPropagation(); $('duelUit').classList.remove('aan'); toonDuelSetup();
});
$('duelNaarMenu').addEventListener('click', e => { e.stopPropagation(); verlaatDuel(); });

/* ---------------------------------------------------------------
   Account en voortgang bewaren.
   Zonder account blijft alles in deze browser staan. Log je in, dan
   gaat je voortgang mee naar elk apparaat waarop je inlogt.
   We praten rechtstreeks met de server via fetch, zodat de pagina
   één zelfstandig bestand blijft zonder externe bibliotheken.
---------------------------------------------------------------- */
const SB_URL = 'https://lejkofmswjsszihnnals.supabase.co';
const SB_KEY = 'sb_publishable__w9afOjVP_J75i9nWsT5xA_dTHsEiQm';
// De serverfunctie wil een echte JWT als sleutel; dat is de klassieke publieke sleutel.
const SB_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlamtvZm1zd2pzc3ppaG5uYWxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU3MDczOTUsImV4cCI6MjEwMTI4MzM5NX0.BYUgS8rVFwg8EWNjvjFwoBqw3Lo_qPRDMoUrmWa6tnM';

let sessie = JSON.parse(localStorage.getItem('orbslayer.sessie') || 'null');
let duwTimer = null;

const ingelogd = () => !!sessie?.access_token;

function bewaarSessie(nieuw) {
  sessie = nieuw;
  if (nieuw) localStorage.setItem('orbslayer.sessie', JSON.stringify(nieuw));
  else localStorage.removeItem('orbslayer.sessie');
  $('accountKnop').classList.toggle('aan', ingelogd());
}

async function sbVraag(pad, opties = {}, opnieuw = true) {
  const kop = { apikey: SB_KEY, 'Content-Type': 'application/json', ...(opties.headers || {}) };
  if (sessie?.access_token) kop.Authorization = 'Bearer ' + sessie.access_token;
  const antwoord = await fetch(SB_URL + pad, { ...opties, headers: kop });
  // Een verlopen sleutel vernieuwen we één keer stilletjes.
  if (antwoord.status === 401 && opnieuw && sessie?.refresh_token) {
    if (await vernieuwSessie()) return sbVraag(pad, opties, false);
  }
  return antwoord;
}

async function vernieuwSessie() {
  try {
    const a = await fetch(SB_URL + '/auth/v1/token?grant_type=refresh_token', {
      method: 'POST', headers: { apikey: SB_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: sessie.refresh_token }),
    });
    if (!a.ok) { bewaarSessie(null); return false; }
    const d = await a.json();
    bewaarSessie({ access_token: d.access_token, refresh_token: d.refresh_token,
                   email: d.user?.email ?? sessie.email, id: d.user?.id ?? sessie.id });
    return true;
  } catch (e) { return false; }
}

/// De vier eisen aan een wachtwoord. Dezelfde controle draait op de server.
const WACHTWOORD_EISEN = [
  { sleutel: 'pw_capital', test: w => /^[A-Z]/.test(w) },
  { sleutel: 'pw_digit',   test: w => /[0-9]/.test(w) },
  { sleutel: 'pw_symbol',  test: w => /[^A-Za-z0-9]/.test(w) },
  { sleutel: 'pw_length',  test: w => w.length > 6 },
];

const wachtwoordGoed = w => WACHTWOORD_EISEN.every(e => e.test(w));

function toonWachtwoordEisen() {
  const w = $('accWachtwoord').value;
  $('pwEisen').innerHTML = `<div class="kop">${t('pw_rules')}</div>` +
    WACHTWOORD_EISEN.map(e => {
      const goed = e.test(w);
      return `<div class="${goed ? 'goed' : ''}">` +
             `<span class="teken">${goed ? '✓' : '·'}</span><span>${t(e.sleutel)}</span></div>`;
    }).join('');
}

/// Aanmelden loopt via onze eigen serverfunctie, die het account meteen
/// bruikbaar maakt. De ingebouwde aanmeldroute van Supabase stuurt een
/// bevestigingsmail en loopt daardoor snel tegen een maillimiet aan.
async function registreer(email, wachtwoord) {
  const a = await fetch(SB_URL + '/functions/v1/aanmelden', {
    method: 'POST',
    headers: { apikey: SB_ANON, Authorization: 'Bearer ' + SB_ANON,
               'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: wachtwoord }),
  });
  const d = await a.json().catch(() => ({}));
  if (!a.ok) {
    if (d.fout === 'bestaat') throw new Error(t('email_taken'));
    if (d.fout === 'email') throw new Error(t('email_invalid'));
    if (d.fout === 'wachtwoord') throw new Error(t('pw_rules'));
    throw new Error(d.bericht || a.status);
  }
  // Meteen inloggen met hetzelfde wachtwoord.
  await logIn(email, wachtwoord);
  return 'ingelogd';
}

async function logIn(email, wachtwoord) {
  const a = await fetch(SB_URL + '/auth/v1/token?grant_type=password', {
    method: 'POST', headers: { apikey: SB_KEY, 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: wachtwoord }),
  });
  const d = await a.json();
  if (!a.ok) throw new Error(d.msg || d.error_description || d.message || a.status);
  bewaarSessie({ access_token: d.access_token, refresh_token: d.refresh_token,
                 email: d.user?.email ?? email, id: d.user?.id });
}

function logUit() {
  bewaarSessie(null);
  renderAccount();
}

/// Haalt de voortgang van de server en houdt de verste vooruitgang aan,
/// zodat je nooit iets kwijtraakt door in te loggen.
/// Voegt de voortgang van de server samen met die van dit apparaat. Per
/// oefening wint de verste stand, zodat je nooit iets kwijtraakt door in te
/// loggen. Een profiel van vóór de drie werelden is één platte push-upwereld.
function voegServerSamen(server) {
  const van = server.werelden
    ? server
    : { naam: server.naam || '', werelden: { pushup: server } };
  if (!ALLES.naam && van.naam) ALLES.naam = van.naam;
  SPORTEN.forEach(sp => {
    const ginds = van.werelden[sp];
    if (!ginds) return;
    const hier = ALLES.werelden[sp] || {};
    if ((ginds.totalReps ?? 0) > (hier.totalReps ?? 0)) ALLES.werelden[sp] = ginds;
  });
  P = { ...DEFAULTS, ...ALLES.werelden[SPORT] };
  bewaarAlles();
  spawn();
}

async function haalVoortgangOp() {
  if (!ingelogd()) return;
  const a = await sbVraag('/rest/v1/progress?select=profile,foto&user_id=eq.' + sessie.id);
  if (!a.ok) return;
  const rijen = await a.json();
  const opServer = rijen[0]?.profile;
  // De foto van de server wint; heeft de server er geen en dit apparaat wel,
  // dan sturen we die van hier alsnog op.
  if (fotoOk(rijen[0]?.foto)) { mijnFoto = rijen[0].foto; localStorage.setItem('orbslayer.foto', mijnFoto); tekenFoto(); }
  else if (fotoOk(mijnFoto)) await zetFoto(mijnFoto);
  if (opServer) voegServerSamen(opServer);
  await duwVoortgang(true);
}

async function duwVoortgang(meteen = false) {
  if (!ingelogd()) return;
  clearTimeout(duwTimer);
  if (!meteen) {
    duwTimer = setTimeout(() => duwVoortgang(true), 2000);
    return;
  }
  // Alle drie de werelden gaan mee. Stuurden we alleen de huidige, dan bleven
  // de klassementen van de andere twee voor altijd leeg.
  ALLES.actief = SPORT;
  ALLES.werelden[SPORT] = P;
  try {
    await sbVraag('/rest/v1/progress', {
      method: 'POST',
      headers: { Prefer: 'resolution=merge-duplicates' },
      body: JSON.stringify([{ user_id: sessie.id, profile: ALLES,
                              updated_at: new Date().toISOString() }]),
    });
  } catch (e) { /* offline: het staat nog gewoon in deze browser */ }
}

function toonAccount() {
  accSport = SPORT;
  $('account').classList.add('aan');
  renderAccount();
}

let uitlogTimer = null;

/// Welke oefening je op het accountscherm bekijkt. Dat hoeft niet de wereld
/// te zijn waarin je speelt: je kunt gewoon even bij je squats kijken.
let accSport = SPORT;

const wereldVan = sp => (sp === SPORT ? P : { ...DEFAULTS, ...(ALLES.werelden[sp] || {}) });

/// Streak van een wereld die niet de huidige hoeft te zijn.
function streakVan(w) {
  if (!w.lastKillDay) return 0;
  const laatst = dayKey(w.lastKillDay);
  return (laatst === dayKey(Date.now()) || laatst === dayKey(Date.now() - 864e5))
    ? (w.streak || 0) : 0;
}

function renderAccount() {
  $('accountKop').textContent = t('account').toUpperCase();
  $('accStatus').textContent = ingelogd()
    ? t('signed_in_as', sessie.email) + ' · ' + t('synced')
    : t('not_signed_in');

  // Drie tabbladen: elke oefening heeft zijn eigen cijfers en die staan los.
  if (!SPORTEN.includes(accSport)) accSport = SPORT;
  $('accSportKop').textContent = t('acc_kies_sport');
  $('accSportRij').innerHTML = '';
  SPORTEN.forEach(sp => {
    const knop = document.createElement('button');
    knop.className = 'sportKnop' + (sp === accSport ? ' aan' : '');
    knop.textContent = sportNaam(sp);
    knop.onclick = e => { e.stopPropagation(); accSport = sp; renderAccount(); };
    $('accSportRij').appendChild(knop);
  });

  const w = wereldVan(accSport);
  $('accCijfers').innerHTML = [
    [w.totalReps || 0, sportNaam(accSport).toLowerCase()],
    [w.bossKills || 0, t('stat_arenas')],
    [(w.duelsWon || 0) + (w.onlineWon || 0), t('stat_duels')],
    [streakVan(w), t('stat_streak')],
    [levelVanXp(w.totalXP || 0), t('stat_level')],
    [w.totalXP || 0, 'XP'],
  ].map(([g, l]) => `<div class="accCijfer"><b>${g}</b><span>${l}</span></div>`).join('');

  $('invOpen').textContent = t('inv_titel');

  tekenFoto();
  $('naamLabel').textContent = t('name_label').toUpperCase();
  $('naamVeld').placeholder = t('name_hint');
  $('naamVeld').value = ALLES.naam || '';
  $('naamPrive').textContent = ingelogd() ? t('name_private') : t('name_local');
  $('naamOpslaan').textContent = t('name_save');
  werkNaamKnopBij();
  $('accFormulier').style.display = ingelogd() ? 'none' : 'block';
  $('uitlogVak').style.display = ingelogd() ? 'flex' : 'none';
  $('accEmail').placeholder = t('email');
  $('accWachtwoord').placeholder = t('password');
  $('accInloggen').textContent = t('sign_in');
  toonWachtwoordEisen();
  $('accRegistreren').textContent = t('sign_up');
  $('accUitloggen').classList.remove('zeker');
  clearTimeout(uitlogTimer);
  $('accUitloggen').textContent = t('sign_out');
  $('accDicht').title = t('close');
}

function accMelding(tekst, fout = false) {
  $('accMelding').textContent = tekst;
  $('accMelding').style.color = fout ? '#f2263a' : '#ffc740';
}

$('accountKnop').addEventListener('click', e => { e.stopPropagation(); toonAccount(); });
$('questKnop').addEventListener('click', e => {
  e.stopPropagation(); $('quests').classList.add('aan'); renderQuests();
});
$('questsDicht').addEventListener('click', e => {
  e.stopPropagation(); $('quests').classList.remove('aan');
});
$('invDicht').addEventListener('click', e => {
  e.stopPropagation(); $('inventaris').classList.remove('aan');
});
$('invOpen').addEventListener('click', e => {
  e.stopPropagation(); $('inventaris').classList.add('aan'); renderInventaris();
});
$('mIcoon').addEventListener('click', e => { e.stopPropagation(); toonPad(); });
$('padDicht').addEventListener('click', e => {
  e.stopPropagation(); $('pad').classList.remove('aan');
});
$('kansenDicht').addEventListener('click', e => {
  e.stopPropagation(); $('kansen').classList.remove('aan');
});
$('buit').addEventListener('click', e => {
  e.stopPropagation(); $('buit').classList.remove('aan');
});
$('lesKnop').addEventListener('click', e => { e.stopPropagation(); lesVolgende(); });
$('lesSkip').addEventListener('click', e => { e.stopPropagation(); lesKlaar(); });
$('accDicht').addEventListener('click', e => {
  e.stopPropagation(); $('account').classList.remove('aan');
});
/// Uitloggen vraagt om een tweede tik. Eén misklik mag je nooit je account
/// kosten, en een apart venster is voor zoiets kleins te veel.
$('accUitloggen').addEventListener('click', e => {
  e.stopPropagation();
  const knop = $('accUitloggen');
  if (knop.classList.contains('zeker')) {
    clearTimeout(uitlogTimer);
    knop.classList.remove('zeker');
    logUit();
    return;
  }
  knop.classList.add('zeker');
  knop.textContent = t('sign_out_zeker');
  clearTimeout(uitlogTimer);
  uitlogTimer = setTimeout(() => {
    knop.classList.remove('zeker');
    knop.textContent = t('sign_out');
  }, 4000);
});

$('accInloggen').addEventListener('click', async e => {
  e.stopPropagation();
  accMelding('');
  try {
    bezig(t('signing_in'));
    await logIn($('accEmail').value.trim(), $('accWachtwoord').value);
    $('ladenTekst').textContent = t('loading_saved');
    await haalVoortgangOp();
    klaar();
    render(); renderMenu(); renderAccount();
  } catch (err) { klaar(); accMelding(t('auth_failed', err.message), true); }
});

$('accWachtwoord').addEventListener('input', toonWachtwoordEisen);

$('accRegistreren').addEventListener('click', async e => {
  e.stopPropagation();
  const wachtwoord = $('accWachtwoord').value;
  if (!wachtwoordGoed(wachtwoord)) {
    toonWachtwoordEisen();
    accMelding(t('pw_rules'), true);
    return;
  }
  accMelding('');
  try {
    bezig(t('signing_up'));
    await registreer($('accEmail').value.trim(), wachtwoord);
    await duwVoortgang(true);
    klaar();
    accMelding(t('account_made'));
    render(); renderMenu(); renderAccount();
  } catch (err) { klaar(); accMelding(t('signup_failed', err.message), true); }
});

/* ---------------------------------------------------------------
   Uitleg bij wat je voor het eerst tegenkomt.
   Elke tip verschijnt een keer, blijft een paar tellen staan en
   verdwijnt vanzelf. Met 'Uitleg overslaan' zet je ze allemaal uit.
   Wat je al gezien hebt onthouden we per apparaat.
---------------------------------------------------------------- */
const TIP_DUUR = 2600;
let gezien = new Set(JSON.parse(localStorage.getItem('orbslayer.tips') || '[]'));
let tipsUit = localStorage.getItem('orbslayer.tipsUit') === 'ja';
let tipRij = [], tipTimer = null, tipLoopt = false;

function tip(sleutel) {
  if (tipsUit || gezien.has(sleutel) || tipRij.includes(sleutel)) return;
  tipRij.push(sleutel);
  if (!tipLoopt) volgendeTip();
}

function volgendeTip() {
  const sleutel = tipRij.shift();
  if (!sleutel) { tipLoopt = false; return; }
  tipLoopt = true;

  gezien.add(sleutel);
  localStorage.setItem('orbslayer.tips', JSON.stringify([...gezien]));

  $('tipTekst').textContent = t('tip_' + sleutel);
  $('tipOver').textContent = t('tip_skip');
  $('tip').classList.add('aan');

  clearTimeout(tipTimer);
  tipTimer = setTimeout(sluitTip, TIP_DUUR);
}

function sluitTip() {
  clearTimeout(tipTimer);
  $('tip').classList.remove('aan');
  setTimeout(volgendeTip, 260);
}

$('tip').addEventListener('click', e => {
  if (e.target.id === 'tipOver') return;
  e.stopPropagation();
  sluitTip();
});

$('tipOver').addEventListener('click', e => {
  e.stopPropagation();
  tipsUit = true;
  localStorage.setItem('orbslayer.tipsUit', 'ja');
  tipRij = [];
  $('tip').classList.remove('aan');
});

/* ---------------------------------------------------------------
   Rondleiding bij de eerste keer openen.
   Neemt het hele scherm over zodat er niets anders kan gebeuren;
   alleen 'overslaan' rechtsboven en de knop onderaan reageren.
   Je krijgt hem alleen als je zonder account speelt: wie inlogt heeft
   het spel al eens gezien.
---------------------------------------------------------------- */
const RONDLEIDING_STAPPEN = 6;

/// Kleine tekeningen bij de stappen, opgebouwd uit vormen die het spel al kent.
function rlBeeld(stap) {
  const goud = '#ffc740', dim = 'rgba(255,255,255,.22)';
  if (stap === 1) {
    return `<img src="${document.querySelector('link[rel="apple-touch-icon"]').href}" alt="">`;
  }
  if (stap === 2) {
    // Telefoon rechtop naast iemand die op de grond ligt.
    return `<svg viewBox="0 0 200 120" fill="none">
      <rect x="14" y="20" width="40" height="76" rx="7" fill="none" stroke="${goud}" stroke-width="4"/>
      <circle cx="34" cy="30" r="2.5" fill="${goud}"/>
      <rect x="20" y="38" width="28" height="50" rx="3" fill="${goud}" opacity=".22"/>
      <path d="M78 92h108" stroke="${dim}" stroke-width="5" stroke-linecap="round"/>
      <circle cx="92" cy="66" r="10" fill="${goud}"/>
      <path d="M102 70l44 12" stroke="${goud}" stroke-width="13" stroke-linecap="round"/>
      <path d="M104 74v18M146 82l16 10" stroke="${goud}" stroke-width="9" stroke-linecap="round"/>
      <path d="M60 58h14M60 58l6-5M60 58l6 5" stroke="${goud}" stroke-width="3" stroke-linecap="round"/>
    </svg>`;
  }
  if (stap === 3 || stap === 4) {
    // De hoogtebalk met de twee drempels.
    const bol = stap === 3 ? 26 : 96;
    return `<svg viewBox="0 0 200 150" fill="none">
      <rect x="92" y="14" width="16" height="122" rx="8" fill="rgba(255,255,255,.08)"/>
      <rect x="92" y="${bol}" width="16" height="${136 - bol}" rx="8" fill="${goud}" opacity=".35"/>
      <path d="M120 34h30M120 116h30" stroke="${dim}" stroke-width="3" stroke-linecap="round"/>
      <text x="156" y="38" fill="rgba(255,255,255,.45)" font-size="11" font-family="sans-serif">${t('bar_up')}</text>
      <text x="156" y="120" fill="rgba(255,255,255,.45)" font-size="11" font-family="sans-serif">${t('bar_down')}</text>
      <circle cx="100" cy="${bol + 8}" r="15" fill="${goud}"/>
      <path d="M56 ${bol + 8}h-22" stroke="${goud}" stroke-width="3" stroke-linecap="round"/>
      <path d="M40 ${bol + 2}l-6 6 6 6" stroke="${goud}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>`;
  }
  if (stap === 5) {
    // De vier spelmodi twee-bij-twee, in de volgorde waarin de tekst ze noemt.
    const modi = ['arena', 'duel', 'online', 'klik'];
    return `<svg viewBox="0 0 240 240" fill="none">${modi.map((m, i) =>
      `<path d="${MODE_ICONEN[m]}" fill="${goud}" transform="translate(${10 + (i % 2) * 120},${10 + Math.floor(i / 2) * 120})"/>`
    ).join('')}</svg>`;
  }
  return `<svg viewBox="0 0 120 120" fill="none">
    <circle cx="60" cy="44" r="19" fill="${goud}"/>
    <path d="M24 104c0-20 16-30 36-30s36 10 36 30" fill="${goud}" opacity=".8"/>
    <circle cx="92" cy="30" r="13" fill="#4ade80"/>
    <path d="M86 30l4 4 8-9" stroke="#000" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`;
}

let rlStap = 1;

/// We onthouden de rondleiding in sessionStorage, niet in localStorage: die
/// hoort bij dit ene tabblad. Open je een nieuw tabblad of een andere browser,
/// dan ben je voor het spel een nieuwe speler en krijg je hem opnieuw.
/// Binnen hetzelfde tabblad herhaalt hij zich niet, ook niet na verversen.
function rondleidingNodig() {
  return !ingelogd() && sessionStorage.getItem('orbslayer.rondleiding') !== 'klaar';
}

/* ---------------- de interactieve les ----------------
   Vervangt de oude dia-rondleiding: alles wordt grijs behalve het ene ding
   dat je nú moet doen. Stap 1: op Vechten drukken. Stap 2: je eerste
   push-up (of tik) — zo leer je de invoer. Stap 3: hoe de arena werkt,
   met een Begrepen-knop. Dat is de hele tutorial. */
let lesStap = 0, lesTimer = null;
/// 'dood' legt een onzichtbaar blok over het gat: je ziet het doel oplichten
/// maar kunt het niet indrukken — voor uitlegstappen met een Begrepen-knop.
/// 'bij' draait één keer bij binnenkomst van de stap.
const LES_STAPPEN = [
  { doel: 'vechten',    tekst: 'les1' },                 // klik op Vechten
  { doel: 'orbwrap',    tekst: 'les2' },                 // je eerste push-up
  { doel: 'pips',       tekst: 'les3' },                 // versla je eerste ork
  { doel: 'terug',      tekst: 'les4' },                 // zo sluit je het gevecht
  { doel: 'burger',     tekst: 'les5' },                 // open de spelmodi
  { doel: 'modeDuel',   tekst: 'les6', knop: true, dood: true },
  { doel: 'modeOnline', tekst: 'les7', knop: true, dood: true },
  { doel: 'modeKlik',   tekst: 'les8', knop: true, dood: true },
  { doel: 'questKnop',  tekst: 'les9', knop: true, dood: true,
    bij: () => $('modes').classList.remove('aan') },
  { doel: 'sportKiezer', tekst: 'les10', knop: true, dood: true },
  { doel: 'mIcoon',     tekst: 'les11', knop: true, dood: true },
];

function lesStart() {
  lesStap = 1;
  document.body.classList.add('lesAan');
  $('les').classList.add('aan');
  tekenLes();
  clearInterval(lesTimer);
  // Het doel kan meebewegen (schermwissel, draaien): blijf het gat volgen.
  lesTimer = setInterval(lesPlaats, 250);
}

function tekenLes() {
  const stap = LES_STAPPEN[lesStap - 1];
  stap.bij?.();
  $('lesTekst').textContent = t(stap.tekst);
  $('lesKnop').style.display = stap.knop ? 'block' : 'none';
  $('lesKnop').textContent = t('les_knop');
  $('lesSkip').textContent = t('les_skip');
  lesPlaats();
}

/// Vier grijze blokken rondom het doel: de rest van het scherm is dood,
/// alleen het gat blijft echt aanraakbaar.
function lesPlaats() {
  if (!lesStap) return;
  const doel = $(LES_STAPPEN[lesStap - 1].doel);
  const r = doel ? doel.getBoundingClientRect()
                 : { left: 0, top: 0, right: 0, bottom: 0 };
  const pad = 10;
  const x1 = Math.max(0, r.left - pad), y1 = Math.max(0, r.top - pad);
  const x2 = Math.min(innerWidth, r.right + pad), y2 = Math.min(innerHeight, r.bottom + pad);
  const zet = (id, css) => Object.assign($(id).style, css);
  zet('lesBoven',  { left: 0, top: 0, width: '100%', height: y1 + 'px' });
  zet('lesOnder',  { left: 0, top: y2 + 'px', width: '100%',
                     height: Math.max(0, innerHeight - y2) + 'px' });
  zet('lesLinks',  { left: 0, top: y1 + 'px', width: x1 + 'px', height: (y2 - y1) + 'px' });
  zet('lesRechts', { left: x2 + 'px', top: y1 + 'px',
                     width: Math.max(0, innerWidth - x2) + 'px', height: (y2 - y1) + 'px' });
  // Bij uitlegstappen ligt er een onzichtbaar blok óver het gat: kijken mag,
  // aanraken niet — anders start je midden in de les per ongeluk een duel.
  zet('lesMidden', LES_STAPPEN[lesStap - 1].dood
    ? { display: 'block', left: x1 + 'px', top: y1 + 'px',
        width: (x2 - x1) + 'px', height: (y2 - y1) + 'px' }
    : { display: 'none' });
  // De tekst komt boven of onder het gat, waar de meeste ruimte is.
  const bubbel = $('lesBubbel');
  if (y1 > innerHeight - y2) {
    bubbel.style.top = ''; bubbel.style.bottom = (innerHeight - y1 + 12) + 'px';
  } else {
    bubbel.style.bottom = ''; bubbel.style.top = (y2 + 12) + 'px';
  }
}

function lesVolgende() {
  if (lesStap >= LES_STAPPEN.length) { lesKlaar(); return; }
  lesStap++;
  tekenLes();
}

function lesKlaar() {
  lesStap = 0;
  clearInterval(lesTimer);
  document.body.classList.remove('lesAan');
  $('les').classList.remove('aan');
  sessionStorage.setItem('orbslayer.rondleiding', 'klaar');
}

function toonRondleiding() {
  rlStap = 1;
  $('rondleiding').classList.add('aan');
  tekenRondleiding();
}

function tekenRondleiding() {
  $('rlOver').textContent = t('tour_skip');
  $('rlStap').textContent = t('tour_step', rlStap, RONDLEIDING_STAPPEN);
  $('rlKop').textContent = t('tour' + rlStap + '_kop');
  $('rlTekst').textContent = t('tour' + rlStap + '_tekst');
  $('rlBeeld').innerHTML = rlBeeld(rlStap);
  $('rlVolgende').textContent = rlStap < RONDLEIDING_STAPPEN ? t('tour_next') : t('tour_start');
  $('rlTerug').textContent = t('tour_back');
  $('rlTerug').classList.toggle('aan', rlStap > 1);
  $('rlBolletjes').innerHTML = Array.from({length: RONDLEIDING_STAPPEN},
    (_, i) => `<i class="${i + 1 === rlStap ? 'nu' : ''}"></i>`).join('');
}

function sluitRondleiding() {
  sessionStorage.setItem('orbslayer.rondleiding', 'klaar');
  $('rondleiding').classList.remove('aan');
}

$('rlVolgende').addEventListener('click', e => {
  e.stopPropagation();
  if (rlStap < RONDLEIDING_STAPPEN) { rlStap++; tekenRondleiding(); }
  else sluitRondleiding();
});

$('rlTerug').addEventListener('click', e => {
  e.stopPropagation();
  if (rlStap > 1) { rlStap--; tekenRondleiding(); }
});

$('rlOver').addEventListener('click', e => { e.stopPropagation(); sluitRondleiding(); });

// Tikken op de rondleiding zelf doet niets: je moet de knoppen gebruiken.
$('rondleiding').addEventListener('pointerdown', e => e.stopPropagation());

/* ---------------------------------------------------------------
   Klassement: iedereen met een account, hoogste level eerst.
   De server geeft alleen spelgegevens terug — nooit e-mailadressen.
   Tik op een speler om zijn cijfers te zien.
---------------------------------------------------------------- */

/* ---------------------------------------------------------------
   Je eigen foto. Hij wordt op dit apparaat verkleind tot een vierkantje
   van 128 pixels en als tekst bij je account bewaard — in een eigen kolom,
   niet in je voortgang, want die wordt tijdens het spelen om de paar
   seconden weggeschreven en daar hoort geen plaatje bij.
---------------------------------------------------------------- */
const FOTO_MAAT = 128, FOTO_MAX = 30000;
let mijnFoto = localStorage.getItem('orbslayer.foto') || '';

/// Streng: alleen een echt plaatje in tekstvorm mag het scherm op. Foto's van
/// andere spelers komen tenslotte van buiten.
const fotoOk = f => typeof f === 'string' && f.length <= 40000 &&
                    /^data:image\/(png|jpe?g|webp);base64,[A-Za-z0-9+/=]+$/.test(f);

/// Snijdt het midden eruit, verkleint, en verlaagt de kwaliteit tot het
/// plaatje klein genoeg is om mee te reizen.
async function maakFoto(bron) {
  const beeld = await createImageBitmap(bron);
  const vlak = document.createElement('canvas');
  vlak.width = vlak.height = FOTO_MAAT;
  const zijde = Math.min(beeld.width, beeld.height);
  vlak.getContext('2d').drawImage(
    beeld, (beeld.width - zijde) / 2, (beeld.height - zijde) / 2, zijde, zijde,
    0, 0, FOTO_MAAT, FOTO_MAAT);
  let kwaliteit = 0.72, uit = vlak.toDataURL('image/jpeg', kwaliteit);
  while (uit.length > FOTO_MAX && kwaliteit > 0.3) {
    kwaliteit -= 0.12;
    uit = vlak.toDataURL('image/jpeg', kwaliteit);
  }
  if (!fotoOk(uit)) throw new Error('te groot');
  return uit;
}

async function zetFoto(nieuw) {
  mijnFoto = nieuw || '';
  if (mijnFoto) localStorage.setItem('orbslayer.foto', mijnFoto);
  else localStorage.removeItem('orbslayer.foto');
  tekenFoto();
  if (!ingelogd()) return;
  try {
    await sbVraag('/rest/v1/progress', {
      method: 'POST',
      headers: { Prefer: 'resolution=merge-duplicates' },
      body: JSON.stringify([{ user_id: sessie.id, foto: mijnFoto || null }]),
    });
  } catch (e) { /* offline: hij staat in elk geval op dit apparaat */ }
}

/// Een rond fotootje, of het rangteken als iemand nog geen foto heeft.
/* ---------------- crates, cosmetica en de inventaris ----------------
   Crates koop je met push-ups uit de clicker. Erin zitten titels, monster-
   koppen als icoon en naamkleuren — puur om te laten zien, in het klassement
   en op je spelerskaart. Dubbel getrokken = een deel van je push-ups terug.
   Andermans keuzes komen als kale id's uit de server en worden alleen
   gerenderd als ze in COSMETICA voorkomen. */
/* Drie kratten, elk voor één soort. Zo weet je waarvoor je betaalt: een
   koppenkrat geeft altijd een kop, een kleurenkrat altijd een kleur. Welke
   graad je krijgt is wél gokken, en die kansen staan op het vraagteken. */
const KRAT_SOORTEN = [
  { soort: 'icoon', basis: 50 },
  { soort: 'titel', basis: 45 },
  { soort: 'kleur', basis: 45 },
];
/// Hout is goedkoop en meestal gewoon, goud is duur en vaak episch.
const KRAT_KWALITEIT = [
  { id: 'hout',   maal: 1,   kans: [72, 24, 4] },
  { id: 'zilver', maal: 2.2, kans: [45, 42, 13] },
  { id: 'goud',   maal: 4.5, kans: [18, 45, 37] },
];
const KRATTEN = [];
KRAT_SOORTEN.forEach(srt => KRAT_KWALITEIT.forEach(kw => KRATTEN.push({
  id: kw.id + '_' + srt.soort,
  soort: srt.soort,
  kwaliteit: kw.id,
  prijs: Math.round(srt.basis * kw.maal),
  kans: kw.kans,
})));
const COSMETICA = [
  // titels
  { id: 'vroegevogel',    soort: 'titel', graad: 1 },
  { id: 'doorzetter',     soort: 'titel', graad: 1 },
  { id: 'vloerveger',     soort: 'titel', graad: 1 },
  { id: 'nachtuil',       soort: 'titel', graad: 1 },
  { id: 'orkenschrik',    soort: 'titel', graad: 2 },
  { id: 'bossenjager',    soort: 'titel', graad: 2 },
  { id: 'ijzerenborst',   soort: 'titel', graad: 2 },
  { id: 'combokoning',    soort: 'titel', graad: 2 },
  { id: 'demachine',      soort: 'titel', graad: 3 },
  { id: 'onverwoestbaar', soort: 'titel', graad: 3 },
  { id: 'koudestart',     soort: 'titel', graad: 1 },
  { id: 'dagploeg',       soort: 'titel', graad: 1 },
  { id: 'vloerheld',      soort: 'titel', graad: 1 },
  { id: 'ademmeester',    soort: 'titel', graad: 2 },
  { id: 'staalvreter',    soort: 'titel', graad: 2 },
  { id: 'bergbeklimmer',  soort: 'titel', graad: 2 },
  { id: 'zwaartekracht',  soort: 'titel', graad: 3 },
  { id: 'laatstelans',    soort: 'titel', graad: 3 },
  // monsterkoppen als icoon (arena-nummer bepaalt kop en kleur)
  { id: 'kop1', soort: 'icoon', graad: 1, arena: 1 },
  { id: 'kop2', soort: 'icoon', graad: 1, arena: 2 },
  { id: 'kop3', soort: 'icoon', graad: 1, arena: 3 },
  { id: 'kop4', soort: 'icoon', graad: 2, arena: 4 },
  { id: 'kop5', soort: 'icoon', graad: 2, arena: 5 },
  { id: 'kop6', soort: 'icoon', graad: 2, arena: 6 },
  { id: 'kop7', soort: 'icoon', graad: 3, arena: 7 },
  { id: 'kop8', soort: 'icoon', graad: 3, arena: 8 },
  { id: 'kop9', soort: 'icoon', graad: 3, arena: 9 },
  { id: 'kop10', soort: 'icoon', graad: 1, arena: 10 },
  { id: 'kop11', soort: 'icoon', graad: 1, arena: 11 },
  { id: 'kop12', soort: 'icoon', graad: 2, arena: 12 },
  { id: 'kop13', soort: 'icoon', graad: 2, arena: 13 },
  { id: 'kop14', soort: 'icoon', graad: 2, arena: 14 },
  { id: 'kop15', soort: 'icoon', graad: 3, arena: 15 },
  { id: 'kop16', soort: 'icoon', graad: 3, arena: 16 },
  { id: 'kop17', soort: 'icoon', graad: 3, arena: 17 },
  // naamkleuren
  { id: 'goud',  soort: 'kleur', graad: 1, hex: '#ffc740' },
  { id: 'gras',  soort: 'kleur', graad: 1, hex: '#63e063' },
  { id: 'lucht', soort: 'kleur', graad: 1, hex: '#58b6ff' },
  { id: 'roze',  soort: 'kleur', graad: 2, hex: '#ff7ad9' },
  { id: 'paars', soort: 'kleur', graad: 2, hex: '#b06dff' },
  { id: 'vuur',  soort: 'kleur', graad: 2, hex: '#ff9d2e' },
  { id: 'bloed', soort: 'kleur', graad: 3, hex: '#f2263a' },
  { id: 'ijs',   soort: 'kleur', graad: 3, hex: '#35f0d0' },
  { id: 'mint',      soort: 'kleur', graad: 1, hex: '#4fe0b0' },
  { id: 'zand',      soort: 'kleur', graad: 1, hex: '#e6c88a' },
  { id: 'staal',     soort: 'kleur', graad: 1, hex: '#9fb4c9' },
  { id: 'koraal',    soort: 'kleur', graad: 2, hex: '#ff7f6b' },
  { id: 'limoen',    soort: 'kleur', graad: 2, hex: '#b6ff3a' },
  { id: 'indigo',    soort: 'kleur', graad: 2, hex: '#6b7bff' },
  { id: 'magenta',   soort: 'kleur', graad: 3, hex: '#ff3ad0' },
  { id: 'zonnevuur', soort: 'kleur', graad: 3, hex: '#ffd23a' },
];
const COS_GRAADKLEUR = ['#c8cdd2', '#58b6ff', '#b06dff'];
const cosVind = id => COSMETICA.find(c => c.id === id) || null;
const kleurHex = id => { const c = id && cosVind(id); return c && c.soort === 'kleur' ? c.hex : null; };
/// Titel van een speler, alleen als het een bestaand id is.
const titelNaam = id => { const c = id && cosVind(id); return c && c.soort === 'titel' ? t('cos_' + id) : null; };

function spullen() {
  if (!Array.isArray(P.spullen)) P.spullen = [];
  if (!P.getooid || typeof P.getooid !== 'object') P.getooid = {};
  return P.spullen;
}
/// Wat je nu draagt van een soort — alleen geldig als je het ook echt bezit.
function getooid(soort) {
  spullen();
  const id = P.getooid[soort];
  const c = id && cosVind(id);
  return c && c.soort === soort && P.spullen.includes(id) ? id : null;
}

function cosNaam(c) {
  return c.soort === 'icoon' ? tt(arenaAt(c.arena).race) : t('cos_' + c.id);
}
function cosVisual(c, maat = 40) {
  if (c.soort === 'icoon') {
    const a = arenaAt(c.arena);
    return `<svg viewBox="0 0 100 100" style="width:${maat}px;height:${maat}px">` +
           monsterPaden(a, rgbCss(a.rgb)) + `</svg>`;
  }
  if (c.soort === 'kleur') {
    const d = Math.round(maat * 0.7);
    return `<span class="invDot" style="width:${d}px;height:${d}px;background:${c.hex}"></span>`;
  }
  return `<span class="invT" style="font-size:${Math.round(maat * 0.55)}px">❝</span>`;
}

/// Alles wat in deze krat kan zitten, met graad.
const kratPool = (krat, graad) =>
  COSMETICA.filter(c => c.soort === krat.soort && (!graad || c.graad === graad));

/// De trekking: eerst de graad, dan een stuk uit die graad van deze soort.
function kratBuit(krat) {
  const lot = Math.random() * 100;
  let graad = 1, som = 0;
  for (let i = 0; i < 3; i++) { som += krat.kans[i]; if (lot < som) { graad = i + 1; break; } }
  let pool = kratPool(krat, graad);
  if (!pool.length) pool = kratPool(krat);
  const item = pool[Math.floor(Math.random() * pool.length)];
  let terug = 0;
  if (spullen().includes(item.id)) {
    terug = Math.ceil(krat.prijs * 0.4);
    klikVerdien(terug);
  } else spullen().push(item.id);
  save();
  rolNaarBuit(krat, item, terug);
}

/* De rol: een lange band met van alles uit deze krat schuift voorbij en remt
   af op jouw stuk. Puur show — het lot is al getrokken voor de band begint. */
const ROL_VAKKEN = 44, ROL_WINNAAR = 38;

function rolNaarBuit(krat, item, terug) {
  const pool = kratPool(krat);
  const band = $('rolBand');
  const vakken = [];
  for (let i = 0; i < ROL_VAKKEN; i++) {
    const c = i === ROL_WINNAAR ? item : pool[Math.floor(Math.random() * pool.length)];
    vakken.push(`<div class="rolVak" style="border-color:${COS_GRAADKLEUR[c.graad - 1]}44">` +
                `${cosVisual(c, 46)}</div>`);
  }
  band.innerHTML = vakken.join('');
  band.style.transition = 'none';
  band.style.transform = 'translateX(0)';
  $('rolTitel').textContent = t('krat_rollen');
  $('rol').classList.add('aan');
  // Even wachten tot de browser de beginstand heeft getekend, anders slaat hij
  // de hele animatie over.
  requestAnimationFrame(() => requestAnimationFrame(() => {
    const vak = band.firstChild ? band.firstChild.getBoundingClientRect().width + 10 : 76;
    const doel = ROL_WINNAAR * vak - ($('rolVenster').clientWidth / 2 - vak / 2)
                 + (Math.random() * 20 - 10);
    band.style.transition = 'transform 3.4s cubic-bezier(.12,.72,.12,1)';
    band.style.transform = `translateX(${-doel}px)`;
    let tik = 0;
    const kloppen = setInterval(() => { toon(520 + (tik++ % 3) * 60, 0.03, 'square', 0.25); }, 110);
    setTimeout(() => {
      clearInterval(kloppen);
      $('rol').classList.remove('aan');
      toonBuit(item, terug);
    }, 3600);
  }));
}

/// Alles wat er in een krat kan zitten, met de kans per graad en wat je er al
/// van hebt. Zo koop je nooit iets waarvan je niet weet wat erin zit.
function toonKansen(id) {
  const kr = KRATTEN.find(k => k.id === id);
  if (!kr) return;
  $('kansenKop').textContent = (t('kans_kop') + ' · ' + t('krat_' + kr.id)).toUpperCase();
  let html = '';
  [1, 2, 3].forEach(graad => {
    const pool = kratPool(kr, graad);
    if (!pool.length) return;
    const kleur = COS_GRAADKLEUR[graad - 1];
    const heb = pool.filter(c => spullen().includes(c.id)).length;
    html += `<div class="kansBlok">` +
      `<div class="kansKop"><span style="color:${kleur}">${ontsmet(t('graad_' + graad))}</span>` +
      `<span>${ontsmet(t('kans_regel', kr.kans[graad - 1], pool.length))}</span></div>` +
      `<div class="kansBalk"><i style="width:${kr.kans[graad - 1]}%;background:${kleur}"></i></div>` +
      `<div class="kansRooster">` +
      pool.map(c => `<div class="kansVak${spullen().includes(c.id) ? ' heb' : ''}">` +
                    `${cosVisual(c, 34)}<span>${ontsmet(cosNaam(c))}</span></div>`).join('') +
      `</div><div class="kansVoet">${ontsmet(t('kans_bezit', heb, pool.length))}</div></div>`;
  });
  html += `<div class="kansVoet">${ontsmet(t('kans_dubbel', Math.ceil(kr.prijs * 0.4)))}<br>` +
          `${ontsmet(t('krat_apart'))}</div>`;
  $('kansenLijst').innerHTML = html;
  $('kansen').classList.add('aan');
}

function toonBuit(item, terug) {
  const g = COS_GRAADKLEUR[item.graad - 1];
  $('buitKaart').innerHTML =
    `<div class="buitGraad" style="color:${g}">${ontsmet(t('graad_' + item.graad).toUpperCase())}</div>` +
    `<div class="buitBeeld">${cosVisual(item, 64)}</div>` +
    `<div class="buitNaam">${ontsmet(cosNaam(item))}</div>` +
    `<div class="buitStatus">${terug ? ontsmet(t('buit_dubbel', terug)) : `<b>${ontsmet(t('buit_nieuw'))}</b>`}</div>`;
  $('buitKaart').style.boxShadow = `0 0 60px ${g}55`;
  $('buit').classList.add('aan');
}

/* ---------------------------------------------------------------
   Het seizoenspad loopt langs je arena's. Elke arena heeft tien vijanden:
   negen minions en een boss. Na elke derde minion ligt er een kleine
   beloning, en de boss geeft iets meer — maar nooit veel. De bedragen zijn
   met opzet klein: het pad is een lijntje dat meeloopt met waar je bent,
   geen tweede spel. Je opent het door in het menu op je tegenstander te
   tikken. Het pad hoort bij de oefening waarin je speelt.
---------------------------------------------------------------- */
const PAD_MINIONS = 9;            // minions per arena, daarna de boss
const PAD_STAP = 3;               // om de drie minions een beloning

/// Wat een kleine beloning in arena i waard is; groeit rustig mee.
const padKlein = i => 8 + (i - 1) * 4;
/// De boss geeft het drievoudige, en elke vijfde arena een houten krat.
const padKrat = i => i % 5 === 0;

function padLoon(i, n) {
  if (n !== 'b') return { punten: padKlein(i) };
  if (padKrat(i)) return { krat: 'hout_' + KRAT_SOORTEN[(i / 5 - 1) % KRAT_SOORTEN.length].soort };
  return { punten: padKlein(i) * 3 };
}

function padLoonTekst(i, n) {
  const loon = padLoon(i, n);
  return loon.krat ? t('krat_' + loon.krat) : t('bp_loon_punten', getal(loon.punten));
}

/// Heb je dit vakje al verdiend? Een arena die je uit hebt geeft alles; in de
/// arena waar je nu staat tellen je kills mee, en de boss pas als je hem
/// verslagen hebt — dat is precies het moment dat je verder mag.
function padOpen(i, n) {
  if (i < P.arenaIndex) return true;
  if (i > P.arenaIndex) return false;
  return n !== 'b' && P.killsThisArena >= n * PAD_STAP;
}

const padId = (i, n) => i + ':' + n;
const PAD_VAKKEN = [1, 2, 3, 'b'];
const padOpgehaald = () => (Array.isArray(P.padOp) ? P.padOp : (P.padOp = []));

/// Hoeveel er klaarligt. Kijkt niet verder dan de arena waar je nu staat.
function bpTeHalen() {
  let n = 0;
  for (let i = 1; i <= P.arenaIndex; i++)
    PAD_VAKKEN.forEach(v => {
      if (padOpen(i, v) && !padOpgehaald().includes(padId(i, v))) n++;
    });
  return n;
}

/// Alleen kijken of er iets bij is gekomen; ophalen doe je zelf. Draait na
/// elke kill en elke XP, dus hij kijkt alleen naar de arena waar je nu bent.
function bpNakijken(stil) {
  if (!Array.isArray(P.padGehad)) P.padGehad = [];
  for (let i = Math.max(1, P.arenaIndex - 1); i <= P.arenaIndex; i++) {
    PAD_VAKKEN.forEach(v => {
      const id = padId(i, v);
      if (!padOpen(i, v) || P.padGehad.includes(id)) return;
      P.padGehad.push(id);
      if (!stil) { melding(t('bp_gehaald', padLoonTekst(i, v)), 3500); geluidWin(); }
    });
  }
  if ($('pad').classList.contains('aan')) tekenPad();
}

/// Alles tegelijk. De kratten gaan dan zonder rolletje open, anders zit je
/// een minuut lang naar bandjes te kijken; wat erin zat lees je in de melding.
function bpAllesOphalen() {
  let punten = 0;
  const buit = [];
  for (let i = 1; i <= P.arenaIndex; i++) {
    PAD_VAKKEN.forEach(v => {
      const id = padId(i, v);
      if (!padOpen(i, v) || padOpgehaald().includes(id)) return;
      padOpgehaald().push(id);
      const loon = padLoon(i, v);
      if (loon.punten) { punten += loon.punten; return; }
      const krat = KRATTEN.find(k => k.id === loon.krat);
      if (krat) buit.push(kratStil(krat));
    });
  }
  if (punten) klikVerdien(punten);
  save();
  tekenPad();
  menuKnoppenBij();
  geluidWin();
  const stukjes = [];
  if (punten) stukjes.push('+' + getal(punten) + ' ' + t('klik_kop'));
  if (buit.length) stukjes.push(buit.map(c => cosNaam(c)).join(', '));
  if (stukjes.length) melding(stukjes.join(' · '), 5000);
}

/// Een krat openen zonder show: geeft terug wat erin zat.
function kratStil(krat) {
  const lot = Math.random() * 100;
  let graad = 1, som = 0;
  for (let i = 0; i < 3; i++) { som += krat.kans[i]; if (lot < som) { graad = i + 1; break; } }
  let pool = kratPool(krat, graad);
  if (!pool.length) pool = kratPool(krat);
  const item = pool[Math.floor(Math.random() * pool.length)];
  if (spullen().includes(item.id)) klikVerdien(Math.ceil(krat.prijs * 0.4));
  else spullen().push(item.id);
  return item;
}

/// Eén vakje ophalen. Een krat gaat meteen open, met rolletje en al.
function padOphalen(i, n) {
  const id = padId(i, n);
  if (!padOpen(i, n) || padOpgehaald().includes(id)) return;
  padOpgehaald().push(id);
  const loon = padLoon(i, n);
  if (loon.punten) {
    klikVerdien(loon.punten);
    melding('+' + getal(loon.punten) + ' ' + t('klik_kop'), 3000);
    geluidWin();
  }
  save();
  tekenPad();
  menuKnoppenBij();
  if (loon.krat) {
    const krat = KRATTEN.find(k => k.id === loon.krat);
    if (krat) kratBuit(krat);
  }
}

function toonPad() {
  $('pad').classList.add('aan');
  tekenPad();
}

function tekenPad() {
  $('padKop').textContent = t('bp_titel').toUpperCase();
  $('padDicht').title = t('close');
  const kills = P.killsThisArena || 0;
  $('padBalkTekst').textContent = t('bp_voortgang', P.arenaIndex, kills);
  $('padVul').style.width = Math.min(100, kills / (PAD_MINIONS + 1) * 100) + '%';
  const open = bpTeHalen();
  $('padAlles').hidden = open < 2;
  $('padAlles').textContent = t('claim_alles', open);
  $('padRest').textContent = open ? t('bp_open', open) : t('bp_klaar');
  $('padRest').style.color = open ? '#ffc740' : '';
  $('padUitleg').textContent = t('bp_uitleg');

  // Je ziet je eigen arena's plus vier die nog komen; verder heeft geen zin,
  // want de reeks gaat oneindig door.
  let html = '';
  for (let i = 1; i <= P.arenaIndex + 4; i++) {
    const a = arenaAt(i);
    html += `<div class="padArena${i === P.arenaIndex ? ' nu' : ''}` +
      `${i > P.arenaIndex ? ' later' : ''}">` +
      `<div class="padArenaKop">` +
      `<svg class="padArenaIcoon" viewBox="0 0 100 100">` +
      `<path d="${a.icon}" fill="${rgbCss(a.rgb, i <= P.arenaIndex ? .95 : .4)}"/></svg>` +
      `<span><b>${ontsmet(t('arena_n', i))}</b>${ontsmet(tt(a.name))}</span></div>` +
      `<div class="padVakken">`;
    PAD_VAKKEN.forEach(v => {
      const id = padId(i, v);
      const uit = padOpen(i, v), gehaald = padOpgehaald().includes(id), boss = v === 'b';
      const loon = padLoon(i, v);
      const staat = gehaald ? `<span class="padStaat af">${ontsmet(t('claim_klaar'))}</span>`
        : uit ? `<button class="padHaal" data-i="${i}" data-v="${v}">${ontsmet(t('claim'))}</button>`
        : `<span class="padStaat">${ontsmet(
             i > P.arenaIndex ? t('pad_nog_arena')
             : boss ? t('pad_nog_boss')
             : (v * PAD_STAP - kills === 1 ? t('pad_nog_vijand_1')
                : t('pad_nog_vijand', v * PAD_STAP - kills)))}</span>`;
      html += `<div class="padVak${uit ? ' open' : ''}${gehaald ? ' gehaald' : ''}` +
        `${boss ? ' boss' : ''}">` +
        `<span class="padVakKop">${ontsmet(boss ? t('pad_boss_label') : t('pad_klein_label', v))}</span>` +
        (loon.krat
          ? `<span class="padBeeld">▣</span>` +
            `<span class="padKrat">${ontsmet(t('krat_' + loon.krat))}</span>`
          : `<span class="padGetal">${getal(loon.punten)}</span>` +
            `<span class="padEenheid">${ontsmet(t('klik_kop'))}</span>`) +
        staat + '</div>';
    });
    html += '</div></div>';
  }
  $('padLijst').innerHTML = html;
  $('padLijst').querySelectorAll('.padHaal').forEach(k => {
    k.onclick = e => {
      e.stopPropagation();
      padOphalen(+k.dataset.i, k.dataset.v === 'b' ? 'b' : +k.dataset.v);
    };
  });
  // Zet de arena waar je nu bent bovenaan in beeld.
  const nu = $('padLijst').querySelector('.padArena.nu');
  if (nu) $('padLijst').scrollTop = Math.max(0, nu.offsetTop - 8);
}

function renderInventaris() {
  $('invKop').textContent = t('inv_titel').toUpperCase();
  let html = '';
  [['titel', 'inv_sec_titels'], ['icoon', 'inv_sec_iconen'], ['kleur', 'inv_sec_kleuren']]
    .forEach(([soort, kop]) => {
      html += `<div class="qKop">${ontsmet(t(kop))}</div><div class="invRooster">`;
      COSMETICA.filter(c => c.soort === soort).forEach(c => {
        if (spullen().includes(c.id)) {
          const aan = getooid(soort) === c.id;
          html += `<button class="invVak${aan ? ' aan' : ''}" data-id="${c.id}">` +
            `<div class="invBeeld">${cosVisual(c, 34)}</div>` +
            `<span style="color:${COS_GRAADKLEUR[c.graad - 1]}">${ontsmet(cosNaam(c))}</span></button>`;
        } else {
          html += `<button class="invVak dicht"><div class="invBeeld"><b>?</b></div>` +
            `<span>${ontsmet(t('graad_' + c.graad))}</span></button>`;
        }
      });
      html += `</div>`;
    });
  $('invLijst').innerHTML = html;

  // De trofeeënkast hoort bij je spullen: de kop van elke boss die je ooit hebt
  // neergehaald. Arena i is veroverd zodra je voorbij i bent; herbezoeken
  // tellen niet dubbel.
  $('trofeeKop').textContent = t('trofee_titel').toUpperCase();
  // De hele ronde staat er, ook wat er nog komt: wat je hebt met de kop van de
  // boss erop, de rest als vraagteken. Zo zie je waar je naartoe werkt.
  const ronde = Math.ceil(Math.max(1, P.arenaIndex - 1) / ARENAS.length) * ARENAS.length;
  const koppen = [];
  for (let i = 1; i <= Math.max(ARENAS.length, ronde); i++) {
    const a = arenaAt(i);
    koppen.push(i < P.arenaIndex
      ? `<div class="trofee"><svg viewBox="0 0 100 100">${monsterPaden(a, rgbCss(a.rgb))}</svg>` +
        `<span>${ontsmet(tt(a.boss))}</span></div>`
      : `<div class="trofee dicht"><b>?</b><span>${ontsmet(t('trofee_nog'))}</span></div>`);
  }
  $('trofeeKast').innerHTML = koppen.join('');

  $('invDicht').title = t('close');
  // Aantikken = dragen; nog een keer = weer afdoen.
  $('invLijst').querySelectorAll('.invVak[data-id]').forEach(k => k.onclick = e => {
    e.stopPropagation();
    const c = cosVind(k.dataset.id);
    P.getooid[c.soort] = getooid(c.soort) === c.id ? null : c.id;
    save();
    renderInventaris();
  });
}

function avatar(foto, level, maat, icoonId) {
  if (fotoOk(foto)) {
    return `<img class="fotoRond" src="${foto}" alt="" width="${maat}" height="${maat}"` +
      ` style="width:${maat}px;height:${maat}px">`;
  }
  const c = icoonId && cosVind(icoonId);
  if (c && c.soort === 'icoon') {
    const a = arenaAt(c.arena);
    return `<svg class="lbBadge" viewBox="0 0 100 100" style="width:${maat}px;height:${maat}px">` +
           monsterPaden(a, rgbCss(a.rgb)) + `</svg>`;
  }
  return rangTeken(level, maat);
}

/// Zet je eigen foto op de knop rechtsboven en in het accountscherm.
function tekenFoto() {
  const knop = $('accountKnop');
  knop.innerHTML = fotoOk(mijnFoto)
    ? `<img src="${mijnFoto}" alt="">` : '\u{1F464}';
  // Met een foto is de knop je gezicht: rond en zonder rand eromheen.
  knop.classList.toggle('foto', fotoOk(mijnFoto));
  const vak = $('accFotoKnop');
  vak.classList.toggle('heeft', fotoOk(mijnFoto));
  vak.innerHTML = fotoOk(mijnFoto)
    ? `<img class="fotoRond" src="${mijnFoto}" alt="">`
    : '<span class="plus">+</span>';
  $('fotoKies').textContent = t('foto_kies');
  $('fotoWeg').textContent = t('foto_weg');
  $('fotoWeg').style.display = fotoOk(mijnFoto) ? 'block' : 'none';
  $('fotoHint').textContent = t('foto_hint') + ' ' +
    (ingelogd() ? t('foto_prive') + ' ' + t('foto_regels') : t('foto_lokaal'));
}

async function kiesFoto(bron) {
  try {
    bezig(t('foto_bezig'));
    await zetFoto(await maakFoto(bron));
    klaar();
    melding(t('foto_klaar'));
  } catch (e) { klaar(); melding(t('foto_fout'), 3500); }
}

$('accFotoKnop').addEventListener('click', e => { e.stopPropagation(); $('fotoInvoer').click(); });
$('fotoKies').addEventListener('click', e => { e.stopPropagation(); $('fotoInvoer').click(); });
$('fotoWeg').addEventListener('click', e => { e.stopPropagation(); zetFoto(''); });
$('fotoInvoer').addEventListener('change', e => {
  const bestand = e.target.files && e.target.files[0];
  e.target.value = '';
  if (bestand) kiesFoto(bestand);
});
// Plakken werkt ook: kopieer een foto en druk op ctrl+V in het accountscherm.
window.addEventListener('paste', e => {
  if (!$('account').classList.contains('aan')) return;
  const items = [...(e.clipboardData ? e.clipboardData.items : [])];
  const plaatje = items.find(i => i.type && i.type.startsWith('image/'));
  if (!plaatje) return;
  e.preventDefault();
  kiesFoto(plaatje.getAsFile());
});

/// Level uit een XP-totaal, met dezelfde staffel als je eigen level.
function levelVanXp(xp) {
  let over = xp, l = 1;
  while (over >= xpNeeded(l)) { over -= xpNeeded(l); l++; }
  return l;
}

/// Welke van de acht rangen bij een level hoort.
function rangVanLevel(l) {
  return l < 3 ? 1 : l < 5 ? 2 : l < 8 ? 3 : l < 12 ? 4
       : l < 16 ? 5 : l < 20 ? 6 : l < 30 ? 7 : 8;
}

function rangTeken(level, maat = 34) {
  const n = rangVanLevel(level);
  return `<svg class="lbBadge" viewBox="0 0 100 100" style="width:${maat}px;height:${maat}px">
            <path d="${RANG_ICONEN.paths[n - 1]}" fill="${RANG_ICONEN.colors[n - 1]}"/>
          </svg>`;
}

let klassementRijen = [];
/// Waarop het klassement gesorteerd staat. Elk onderdeel heeft zijn eigen
/// lijst: wie het verst is in de arena's is iemand anders dan wie de meeste
/// nummers uitspeelde.
let lbSoort = 'xp';
const LB_SOORTEN = ['xp', 'arena', 'klik', 'muziek', 'boss'];

/// Het getal rechts in de rij hoort bij het gekozen onderdeel.
function lbWaarde(r) {
  if (lbSoort === 'arena') return { groot: r.arena || 1, klein: t('lb_eenheid_arena', r.arena || 1) };
  if (lbSoort === 'klik') return { groot: getal(r.klik || 0), klein: t('klik_kop') };
  if (lbSoort === 'muziek') return { groot: r.liedjes || 0, klein: t('mz_liedjes') };
  if (lbSoort === 'boss') return { groot: getal(r.schade || 0), klein: t('mode_boss') };
  return { groot: levelVanXp(r.xp), klein: t('stat_level') };
}

async function toonKlassement() {
  $('klassement').classList.add('aan');
  $('klassementKop').textContent = t('leaderboard').toUpperCase();
  $('lbDicht').title = t('close');
  $('lbSoorten').innerHTML = '';
  LB_SOORTEN.forEach(srt => {
    const knop = document.createElement('button');
    knop.className = 'lbSoort' + (srt === lbSoort ? ' aan' : '');
    knop.textContent = t('lb_soort_' + srt);
    knop.onclick = e => { e.stopPropagation(); lbSoort = srt; toonKlassement(); };
    $('lbSoorten').appendChild(knop);
  });
  $('lbLijst').innerHTML = `<div class="lbMelding">${t('lb_loading')}</div>`;

  try {
    const a = await fetch(SB_URL + '/rest/v1/rpc/klassement', {
      method: 'POST',
      headers: { apikey: SB_KEY, 'Content-Type': 'application/json',
                 ...(sessie?.access_token ? { Authorization: 'Bearer ' + sessie.access_token } : {}) },
      body: JSON.stringify({ limiet: 50, sport: SPORT, soort: lbSoort }),
    });
    if (!a.ok) throw new Error(a.status);
    klassementRijen = await a.json();
  } catch (e) {
    $('lbLijst').innerHTML = `<div class="lbMelding">${t('lb_failed')}</div>`;
    return;
  }
  tekenKlassement();
}

function tekenKlassement() {
  if (!klassementRijen.length) {
    $('lbLijst').innerHTML = `<div class="lbMelding">${t('lb_empty')}</div>`;
    return;
  }
  $('lbLijst').innerHTML = '';
  klassementRijen.forEach((r, i) => {
    const level = levelVanXp(r.xp);
    const jij = ingelogd() && r.speler === sessie.id;
    const knop = document.createElement('button');
    knop.className = 'lbRij' + (jij ? ' jij' : '');
    const hx = kleurHex(r.kleur), ttl = titelNaam(r.titel);
    knop.innerHTML =
      `<span class="lbPlek">${i + 1}</span>` +
      avatar(r.foto, level, 34, r.icoon) +
      `<span class="lbNaam"><span${hx ? ` style="color:${hx}"` : ''}>${ontsmet(r.naam)}</span>` +
      `${jij ? ` <small>${t('lb_you')}</small>` : ''}` +
      `<small>${ttl ? ontsmet(ttl) + ' · ' : ''}${ontsmet(lbWaarde(r).klein)}</small></span>` +
      `<span class="lbNiveau">${rangTeken(level, 22)}` +
      `<span class="lbLevel" style="color:${RANG_ICONEN.colors[rangVanLevel(level) - 1]}">` +
      `${lbWaarde(r).groot}</span></span>`;
    knop.onclick = e => {
      e.stopPropagation();
      // Je eigen rij brengt je naar je naam, zodat je hem daar kunt wijzigen.
      if (jij) { $('klassement').classList.remove('aan'); toonAccount(); $('naamVeld').focus(); }
      else toonSpeler(r);
    };
    $('lbLijst').appendChild(knop);
  });

  if (!ingelogd()) {
    const uitleg = document.createElement('div');
    uitleg.className = 'lbMelding';
    uitleg.textContent = t('lb_need_account');
    $('lbLijst').appendChild(uitleg);
  }
}

/// Namen komen van andere spelers, dus nooit als HTML invoegen.
function ontsmet(tekst) {
  const d = document.createElement('div');
  d.textContent = tekst ?? '';
  return d.innerHTML;
}

/// Wie er nu op de spelerskaart staat, zodat de meldknop weet om wie het gaat.
let spelerNu = null;

async function meldSpeler() {
  if (!spelerNu) return;
  if (!ingelogd()) { melding(t('meld_account'), 3500); return; }
  try {
    const a = await sbVraag('/rest/v1/rpc/meld_speler', {
      method: 'POST', body: JSON.stringify({ p_doel: spelerNu.speler, p_reden: '' }),
    });
    if (!a.ok) throw new Error(a.status);
    const uit = await a.json();
    melding(uit.verborgen ? t('meld_verborgen') : t('meld_klaar'), 4500);
    $('speler').classList.remove('aan');
  } catch (e) { melding(t('meld_fout'), 3000); }
}

$('spelerMeld').addEventListener('click', e => { e.stopPropagation(); meldSpeler(); });

function toonSpeler(r) {
  spelerNu = r;
  $('spelerMeld').textContent = t('meld_knop');
  $('spelerMeld').style.display = ingelogd() && r.speler !== sessie?.id ? 'block' : 'none';
  const level = levelVanXp(r.xp), n = rangVanLevel(level);
  const hx = kleurHex(r.kleur), ttl = titelNaam(r.titel);
  $('speler').classList.add('aan');
  $('spelerBadge').innerHTML = avatar(r.foto, level, 74, r.icoon);
  $('spelerNaam').textContent = r.naam;
  $('spelerNaam').style.color = hx || '';
  $('spelerRang').innerHTML = rangTeken(level, 20) +
    `<span>${ontsmet((ttl ? ttl + ' · ' : '') + t('rank_level', t('rank_' + n), level))}</span>`;
  $('spelerRang').style.color = RANG_ICONEN.colors[n - 1];
  $('spelerCijfers').innerHTML = [
    [r.reps, t('stat_pushups')],
    [r.kills, t('stat_kills')],
    [r.arenas, t('stat_arenas')],
    [r.duels, t('stat_duels')],
    [r.streak, t('stat_streak')],
    [r.xp, 'XP'],
  ].map(([w, l]) => `<div class="accCijfer"><b>${w}</b><span>${l}</span></div>`).join('');
  $('spelerDicht').title = t('close');
}

$('klassementKnop').addEventListener('click', e => { e.stopPropagation(); toonKlassement(); });
$('lbDicht').addEventListener('click', e => {
  e.stopPropagation(); $('klassement').classList.remove('aan');
});
$('spelerDicht').addEventListener('click', e => {
  e.stopPropagation(); $('speler').classList.remove('aan');
});

/* Je naam in het klassement. Hij hoort bij je voortgang, dus hij reist
   gewoon mee naar je andere apparaten. */
function werkNaamKnopBij() {
  const nieuw = $('naamVeld').value.trim();
  $('naamOpslaan').disabled = nieuw === (ALLES.naam || '');
}

/// De server houdt een lijst met scheldwoorden bij. Hij is er niet om jou te
/// pesten maar om het klassement leefbaar te houden, en hij draait daar zodat
/// niemand er met een aangepaste pagina omheen kan.
async function naamMag(naam) {
  try {
    const a = await fetch(SB_URL + '/rest/v1/rpc/naam_mag', {
      method: 'POST',
      headers: { apikey: SB_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_naam: naam }),
    });
    if (!a.ok) return true;      // server onbereikbaar: hij keurt hem later toch
    return (await a.json()) === true;
  } catch (e) { return true; }
}

async function slaNaamOp() {
  const nieuw = $('naamVeld').value.trim().slice(0, 24);
  if (nieuw === (ALLES.naam || '')) return;
  if (nieuw && !(await naamMag(nieuw))) {
    $('naamVeld').value = ALLES.naam || '';
    werkNaamKnopBij();
    accMelding(t('naam_geweigerd'), true);
    return;
  }
  ALLES.naam = nieuw;
  save();
  duwVoortgang(true);
  werkNaamKnopBij();
  renderAccount();
  accMelding(t('name_saved'));
}

$('naamVeld').addEventListener('input', werkNaamKnopBij);
$('naamVeld').addEventListener('keydown', e => {
  if (e.key === 'Enter') { e.preventDefault(); $('naamVeld').blur(); slaNaamOp(); }
});
$('naamOpslaan').addEventListener('click', e => { e.stopPropagation(); slaNaamOp(); });

/* ---------------------------------------------------------------
   Online: zestig seconden tegen een echt mens.

   Er is geen spelserver die het gevecht draait — de twee browsers wisselen
   elke seconde hun stand uit via de database. Dat is ruim genoeg voor een
   race waarin je hooguit twee push-ups per seconde doet, en het houdt deze
   pagina één bestand zonder extra bibliotheken.

   Wie het eerst zoekt blijft wachten, de tweede pikt hem op. De server
   bepaalt het startmoment en geeft bij elk antwoord zijn eigen klok mee,
   zodat beide spelers op hetzelfde moment beginnen en eindigen — ook als de
   ene telefoon een halve minuut voorloopt.
---------------------------------------------------------------- */
const OL_SECONDEN = 60;   // duur van het duel; de server rekent met hetzelfde getal
const OL_POLL = 900;      // hoe vaak we de stand uitwisselen
const OL_STIL = 15;       // zo lang mag een tegenstander zwijgen voor we hem weg noemen
const OL_ZOEKDUUR = 75;   // zo lang zoeken we naar een willekeurige tegenstander

let olFase = 'uit';       // uit | lobby | wacht | aftellen | bezig | aftikken | klaar
let olId = null, olCode = null, olJij = 0, olTegen = 0, olTegenNaam = '';
let olBegin = 0, olOffset = 0, olPoll = null, olTik = null, olMislukt = 0, olZoekStart = 0;

/// De klok van de server, benaderd met het verschil dat we bij het laatste
/// antwoord gemeten hebben.
const olNu = () => Date.now() + olOffset;
/// Je reps tellen als niveau voor de beloning: honderd in een minuut is het plafond.
const olPeil = () => Math.max(1, Math.min(100, olJij));

async function olRpc(naam, args = {}) {
  const a = await sbVraag('/rest/v1/rpc/' + naam, { method: 'POST', body: JSON.stringify(args) });
  const d = await a.json().catch(() => null);
  if (!a.ok) throw new Error(d?.message || ('HTTP ' + a.status));
  return d;
}
/// Wie je bent voor de anderen: dezelfde naam als in het klassement.
const olIk = () => ({ p_naam: ALLES.naam || '', p_niveau: playerLevel(), p_sport: SPORT });

/* -- het beginscherm -- */

function toonOnline() {
  $('modes').classList.remove('aan');
  $('menu').classList.add('uit');
  $('stage').classList.add('uit');
  $('olLobby').classList.add('aan');
  olFase = 'lobby';
  tekenLobby();
  if (!ingelogd()) return;
  olHallo();
  // De camera hier al vragen: als je straks gekoppeld wordt loopt de klok, en
  // dan wil je niet eerst nog een toestemmingsscherm wegklikken.
  startCameraIndienNodig();
}

function tekenLobby() {
  $('olTitel').textContent = t('mode_online');
  $('olSub').textContent = t('ol_sub');
  $('olAccountTekst').textContent = t('ol_need_account');
  $('olNaarAccount').textContent = t('ol_open_account');
  $('olNaamKop').textContent = t('ol_name_label').toUpperCase();
  $('olNaamVeld').placeholder = t('name_hint');
  $('olNaamVeld').value = ALLES.naam || '';
  $('olNaamOk').textContent = t('name_save');
  $('olZoek').textContent = t('ol_find');
  $('olVriendKnop').textContent = t('ol_friend');
  $('olMaakCode').textContent = t('ol_make_code');
  $('olCode').placeholder = t('ol_code');
  $('olDoeMee').textContent = t('ol_join');
  $('olTerug').textContent = t('duel_to_menu');
  $('olWachtTekst').textContent = t('ol_searching');
  $('olAnnuleer').textContent = t('cancel');
  $('oduOpgeven').textContent = t('ol_give_up');
  $('oduNogmaals').textContent = t('duel_again');
  $('oduNaarMenu').textContent = t('duel_to_menu');

  const aan = ingelogd();
  $('olGeenAccount').style.display = aan ? 'none' : 'block';
  $('olVak').style.display = aan ? 'block' : 'none';
  if (!aan) $('olStatus').textContent = '';
}

/// Meldt je aan bij de server en haalt je balans en het aantal actieve spelers op.
async function olHallo() {
  try {
    const d = await olRpc('hallo', olIk());
    $('olStatus').textContent = t('ol_record', d.gewonnen, d.verloren) + ' · ' +
      t(d.online === 1 ? 'ol_player_1' : 'ol_players', d.online);
  } catch (e) { $('olStatus').textContent = ''; }
}

/// De naam is dezelfde als in het klassement, dus hij reist met je voortgang mee.
function olBewaarNaam() {
  const nieuw = $('olNaamVeld').value.trim().slice(0, 24);
  if (nieuw === (ALLES.naam || '')) return;
  ALLES.naam = nieuw;
  save();
  duwVoortgang(true);
  melding(t('name_saved'));
  olHallo();
}

/* -- zoeken en koppelen -- */

function olNaarWacht(tekst, code = '') {
  $('olLobby').classList.remove('aan');
  $('olWacht').classList.add('aan');
  $('olWachtTekst').textContent = tekst;
  $('olWachtCode').textContent = code;
  $('olWachtSub').textContent = code ? t('ol_code_share') : '';
  $('olAnnuleer').textContent = t('cancel');
  olFase = 'wacht';
}

/// Neemt over wat de server zegt: het tijdverschil, de stand van de ander en
/// het afgesproken startmoment.
function olNeem(d) {
  olId = d.id;
  olCode = d.code;
  olOffset = Date.parse(d.nu) - Date.now();
  olTegen = d.tegen ?? 0;
  if (d.naam_tegen) olTegenNaam = d.naam_tegen;
  olBegin = d.begin_op ? Date.parse(d.begin_op) : 0;
  return d.status;
}

async function olZoekTegenstander() {
  if (!ingelogd()) return;
  olJij = 0; olTegen = 0; olTegenNaam = ''; olMislukt = 0;
  try {
    const d = await olRpc('zoek_duel', olIk());
    const status = olNeem(d);
    // Stond er al iemand te wachten, dan begint het duel meteen.
    if (status === 'bezig') { olNaarAftellen(); return; }
    olZoekStart = Date.now();
    olNaarWacht(t('ol_searching'));
    olStartPollen();
  } catch (e) { melding(olFoutTekst(e)); }
}

async function olMaakCode() {
  if (!ingelogd()) return;
  olJij = 0; olTegen = 0; olTegenNaam = ''; olMislukt = 0;
  try {
    const d = await olRpc('maak_uitnodiging', olIk());
    olNeem(d);
    olZoekStart = 0;                 // een uitnodiging blijft staan tot je hem afbreekt
    olNaarWacht(t('ol_waiting_friend'), d.code);
    olStartPollen();
  } catch (e) { melding(olFoutTekst(e)); }
}

async function olDoeMee() {
  if (!ingelogd()) return;
  const code = $('olCode').value.trim().toUpperCase();
  if (code.length < 4) { melding(t('ol_bad_code')); return; }
  olJij = 0; olTegen = 0; olTegenNaam = ''; olMislukt = 0;
  try {
    bezig(t('ol_joining'));
    const d = await olRpc('doe_mee', { p_code: code, ...olIk() });
    klaar();
    olNeem(d);
    $('olCode').value = '';
    olNaarAftellen();
  } catch (e) {
    klaar();
    melding(/code onbekend/.test(e.message) ? t('ol_bad_code') : olFoutTekst(e));
  }
}

const olFoutTekst = e => /naam|ingelogd/.test(e.message || '') ? t('ol_need_account') : t('ol_offline');

/* -- de race zelf -- */

function olStartPollen() {
  clearInterval(olPoll);
  olPoll = setInterval(olWisselStand, OL_POLL);
}

async function olWisselStand() {
  if (!olId || olFase === 'uit' || olFase === 'klaar') return;
  let d;
  try {
    d = await olRpc('duel_stand', { p_id: olId, p_score: olJij });
    olMislukt = 0;
  } catch (e) {
    // Eén hapering is niets bijzonders; pas na een aantal keer geven we het op.
    if (++olMislukt >= 6) olStopMetFout();
    return;
  }
  const status = olNeem(d);

  if (olFase === 'wacht') {
    if (status === 'bezig') { olNaarAftellen(); return; }
    if (status === 'weg') { olTerugNaarLobby(); return; }
    // Niemand te vinden? Na een tijdje het zoeken staken.
    if (olZoekStart && Date.now() - olZoekStart > OL_ZOEKDUUR * 1000) {
      olAnnuleerWachten(t('ol_nobody'));
    }
    return;
  }
  if (status === 'weg') { olEinde('weg'); return; }
  if (status === 'klaar') { olEinde('tijd'); return; }
  if (olFase === 'bezig' && d.stil > OL_STIL) { olEinde('stil'); return; }
  olTekenRace();
}

function olNaarAftellen() {
  olFase = 'aftellen';
  olJij = 0; olTegen = 0;
  $('olWacht').classList.remove('aan');
  $('olLobby').classList.remove('aan');
  $('odu').classList.add('aan');
  $('oduBalkVak').appendChild($('nosebar'));   // de hoogtebalk verhuist mee
  camBalkBijwerken();
  // Bewust geen camera-vraag meer: die is in het beginscherm al gesteld, en
  // hier loopt de klok al. Wie toen 'zonder camera' koos, tikt gewoon.
  $('oduTitel').textContent = t('ol_versus', olTegenNaam || t('duel_ai'));
  $('oduJijNaam').textContent = t('duel_you');
  $('oduTegenNaam').textContent = (olTegenNaam || t('duel_ai')).toUpperCase();
  $('oduKlok').textContent = OL_SECONDEN;
  olTekenRace();
  olStartPollen();
  clearInterval(olTik);
  olTik = setInterval(olKlokTik, 100);
}

/// Loopt op de klok van de server, zodat beide kanten tegelijk beginnen.
function olKlokTik() {
  if (olFase === 'aftellen') {
    const tot = (olBegin - olNu()) / 1000;
    if (tot > 0) {
      $('duelAftel').classList.add('aan');
      $('duelAftel').textContent = Math.ceil(tot);
      return;
    }
    $('duelAftel').textContent = t('duel_go');
    setTimeout(() => $('duelAftel').classList.remove('aan'), 500);
    olFase = 'bezig';
  }
  if (olFase !== 'bezig') return;
  const over = Math.max(0, OL_SECONDEN - (olNu() - olBegin) / 1000);
  $('oduKlok').textContent = Math.ceil(over);
  $('oduKlok').classList.toggle('krap', over <= 10);
  if (over <= 0) olAfronden();
}

/// De tijd is om: nog één keer je eindstand doorgeven en dan wachten tot de
/// server de uitslag vastzet. Dat duurt een paar tellen, zodat een push-up die
/// net op tijd was nog meetelt.
async function olAfronden() {
  olFase = 'aftikken';
  clearInterval(olTik); olTik = null;
  $('oduKlok').textContent = '0';
  try { await olRpc('duel_stand', { p_id: olId, p_score: olJij }); } catch (e) { /* de polling probeert het opnieuw */ }
  setTimeout(async () => {
    if (olFase !== 'aftikken') return;
    try { olNeem(await olRpc('duel_stand', { p_id: olId, p_score: olJij })); } catch (e) { /* dan maar met wat we hebben */ }
    olEinde('tijd');
  }, 3200);
}

function olRep() {
  olJij++;
  P.totalReps++;
  klikRepBonus();
  if (navigator.vibrate) navigator.vibrate(10);
  animateNose();
  olTekenRace();
  save();
}

function olTekenRace() {
  const schaal = Math.max(olJij, olTegen, 10);
  $('oduJijTal').textContent = olJij;
  $('oduTegenTal').textContent = olTegen;
  $('oduJijVul').style.width = (olJij / schaal * 100) + '%';
  $('oduTegenVul').style.width = (olTegen / schaal * 100) + '%';
}

/* -- afloop -- */

function olEinde(reden) {
  if (olFase === 'klaar' || olFase === 'uit') return;
  olFase = 'klaar';
  clearInterval(olPoll); olPoll = null;
  clearInterval(olTik); olTik = null;
  $('duelAftel').classList.remove('aan');
  olTekenRace();

  const afgehaakt = reden === 'weg' || reden === 'stil';
  const gelijk = !afgehaakt && olJij === olTegen;
  const gewonnen = afgehaakt || olJij > olTegen;
  const xp = (gelijk ? Math.max(1, Math.round(duelWinstXP(olPeil()) * 0.4))
            : gewonnen ? duelWinstXP(olPeil()) : duelVerliesXP(olPeil())) * xpMaal();

  P.totalXP += xp;
  bpNakijken();
  if (gewonnen) { P.onlineWon = (P.onlineWon || 0) + 1; tikStreak(); questTel('duel'); }
  save();

  (gewonnen ? geluidWin : geluidVerlies)();
  $('oduUitKop').textContent = afgehaakt ? t('ol_win_by_leave')
                             : gelijk ? t('ol_draw')
                             : gewonnen ? t('duel_win') : t('duel_lose');
  $('oduUitKop').style.color = gewonnen ? '#ffc740' : gelijk ? '#fff' : '#f2263a';
  $('oduUitScore').textContent = t('duel_score', olJij, olTegen);
  $('oduUitBeloning').textContent = gewonnen || gelijk
    ? t('duel_reward', xp) : t('duel_consolation', xp);
  $('oduNogmaals').textContent = t('duel_again');
  $('oduNaarMenu').textContent = t('duel_to_menu');
  $('oduUit').classList.add('aan');
  if (navigator.vibrate) navigator.vibrate(gewonnen ? [30, 60, 30] : 20);
}

/// Alles opruimen en terug naar het beginscherm van de online modus.
function olTerugNaarLobby() {
  clearInterval(olPoll); olPoll = null;
  clearInterval(olTik); olTik = null;
  olId = null; olCode = null; olBegin = 0;
  $('duelAftel').classList.remove('aan');
  $('oduUit').classList.remove('aan');
  $('odu').classList.remove('aan');
  $('olWacht').classList.remove('aan');
  $('stage').querySelector('.middle').appendChild($('nosebar'));   // balk terug
  camBalkBijwerken();
  $('olLobby').classList.add('aan');
  olFase = 'lobby';
  tekenLobby();
  if (ingelogd()) olHallo();
}

function olNaarMenu() {
  olTerugNaarLobby();
  $('olLobby').classList.remove('aan');
  olFase = 'uit';
  $('olVriendVak').classList.remove('aan');
  toonMenu();
}

/// Wachten afbreken kost niets; het duel bestond nog niet.
async function olAnnuleerWachten(bericht) {
  const id = olId;
  clearInterval(olPoll); olPoll = null;
  olId = null;
  olTerugNaarLobby();
  if (bericht) melding(bericht, 4000);
  if (id) { try { await olRpc('verlaat_duel', { p_id: id }); } catch (e) { /* verloopt vanzelf */ } }
}

/// Middenin weglopen telt als verlies — anders zou je elk verloren duel kunnen
/// wegklikken.
async function olGeefOp() {
  const id = olId;
  olFase = 'klaar';
  clearInterval(olPoll); olPoll = null;
  clearInterval(olTik); olTik = null;
  if (id) { try { await olRpc('verlaat_duel', { p_id: id }); } catch (e) { /* dan boekt de ander het */ } }
  olNaarMenu();
}

function olStopMetFout() {
  const bezigMetDuel = olFase === 'bezig' || olFase === 'aftellen' || olFase === 'aftikken';
  clearInterval(olPoll); olPoll = null;
  clearInterval(olTik); olTik = null;
  olId = null;
  olTerugNaarLobby();
  melding(t('ol_offline'), 4000);
  if (bezigMetDuel) save();
}

$('modeOnline').addEventListener('click', e => { e.stopPropagation(); toonOnline(); });
$('olTerug').addEventListener('click', e => { e.stopPropagation(); olNaarMenu(); });
$('olNaarAccount').addEventListener('click', e => { e.stopPropagation(); toonAccount(); });
$('olNaamOk').addEventListener('click', e => { e.stopPropagation(); olBewaarNaam(); });
$('olNaamVeld').addEventListener('keydown', e => {
  if (e.key === 'Enter') { e.preventDefault(); $('olNaamVeld').blur(); olBewaarNaam(); }
});
$('olZoek').addEventListener('click', e => { e.stopPropagation(); olZoekTegenstander(); });
$('olVriendKnop').addEventListener('click', e => {
  e.stopPropagation(); $('olVriendVak').classList.toggle('aan');
});
$('olMaakCode').addEventListener('click', e => { e.stopPropagation(); olMaakCode(); });
$('olDoeMee').addEventListener('click', e => { e.stopPropagation(); olDoeMee(); });
$('olCode').addEventListener('keydown', e => {
  if (e.key === 'Enter') { e.preventDefault(); $('olCode').blur(); olDoeMee(); }
});
$('olAnnuleer').addEventListener('click', e => { e.stopPropagation(); olAnnuleerWachten(); });
$('oduOpgeven').addEventListener('click', e => { e.stopPropagation(); olGeefOp(); });
$('oduNogmaals').addEventListener('click', e => { e.stopPropagation(); olTerugNaarLobby(); });
$('oduNaarMenu').addEventListener('click', e => { e.stopPropagation(); olNaarMenu(); });

// Wie het tabblad sluit laat geen spookduel achter. 'keepalive' zorgt dat dit
// verzoek de pagina overleeft; sendBeacon kan niet, want dat kan geen
// inloggegevens meesturen. Lukt het toch niet, dan merkt de ander binnen
// vijftien seconden vanzelf dat er niemand meer meedoet.
window.addEventListener('pagehide', () => {
  if (!olId || olFase === 'uit' || olFase === 'klaar' || !sessie?.access_token) return;
  try {
    fetch(SB_URL + '/rest/v1/rpc/verlaat_duel', {
      method: 'POST', keepalive: true,
      headers: { apikey: SB_KEY, Authorization: 'Bearer ' + sessie.access_token,
                 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_id: olId }),
    });
  } catch (e) { /* dan ruimt de server hem later zelf op */ }
});

/* ---------------------------------------------------------------
   Clicker: het spel dat op je push-ups draait.

   Er valt hier niets te tikken. Eén echte push-up is één push-up — de camera
   moet hem zien. Dat kan hier, met de knop in het midden, en het gebeurt
   vanzelf in de arena, het duel en online: die herhalingen betalen hier ook uit.

   Helpers tellen daarna vanzelf door, maar traag: ze zijn uitgedrukt per uur,
   niet per seconde, en de eerste verdient zichzelf pas in een dag terug. Zo
   blijft het een spel dat je met je lijf speelt en niet met je duim.

   Wat te koop is zie je pas als je het kunt betalen. Tot die tijd staat er
   alleen een prijs met een vraagteken erachter — net als de arena's die nog
   op slot staan. Wat je één keer gezien hebt, blijft zichtbaar.
---------------------------------------------------------------- */
const KLIK_VERSIE = 3;         // gaat omhoog als de balans omgegooid wordt
/// Prijzen en opbrengsten. 'uur' is wat één stuk per uur oplevert, en de prijs
/// is dat maal de terugverdientijd: een korte dag bij de eerste helper,
/// oplopend tot een half jaar bij de laatste. Daardoor blijft het spel
/// eindeloos trager worden in plaats van na een week op hol te slaan.
const KLIK_HELPERS = [
  { id: 'maat',       prijs: 15,          uur: 1 },             // 15 uur terugverdienen
  { id: 'groep',      prijs: 180,         uur: 5 },             // 36 uur
  { id: 'zaal',       prijs: 1500,        uur: 20 },            // 75 uur
  { id: 'school',     prijs: 12000,       uur: 80 },            // 150 uur
  { id: 'club',       prijs: 75000,       uur: 300 },           // 250 uur
  { id: 'stadion',    prijs: 530000,      uur: 1200 },          // 440 uur
  { id: 'buurt',      prijs: 3500000,     uur: 5000 },          // 700 uur
  { id: 'stad',       prijs: 21000000,    uur: 20000 },         // 1050 uur
  { id: 'provincie',  prijs: 125000000,   uur: 80000 },         // 1550 uur
  { id: 'land',       prijs: 675000000,   uur: 300000 },        // 2250 uur
  { id: 'werelddeel', prijs: 3700000000,  uur: 1200000 },       // 3100 uur
  { id: 'wereld',     prijs: 22000000000, uur: 5000000 },       // 4400 uur
];
/// Techniek: koopbare verbeteringen die elke echte push-up meer waard maken,
/// zodat trainen naast de helpers altijd blijft lonen. Zelfde opzet als de
/// helpers: verschillende soorten van goedkoop naar duur, elke volgende van
/// dezelfde soort wordt 15% duurder, en alle bonussen vermenigvuldigen met
/// elkaar. De goedkoopste start even duur als de eerste helper.
const KLIK_TECHNIEKEN = [
  { id: 'warm',    prijs: 15,       maal: 1.10 },  // +10% per stuk
  { id: 'adem',    prijs: 250,      maal: 1.12 },  // +12%
  { id: 'houding', prijs: 4000,     maal: 1.15 },  // +15%
  { id: 'ritme',   prijs: 60000,    maal: 1.18 },  // +18%
  { id: 'grip',    prijs: 900000,   maal: 1.22 },  // +22%
  { id: 'coach',   prijs: 12000000, maal: 1.30 },  // +30%
];
const KLIK_TECHNIEK_GROEI = 1.15;
/// Elke volgende van dezelfde soort is een vijfde duurder. Stapelen loont dus
/// maar even; daarna moet je door naar de volgende soort.
const KLIK_GROEI = 1.2;
/// Verdubbelingen komen laat en zijn duur: pas vanaf vijf stuks.
const KLIK_TRAP = [5, 25, 50, 100, 150];
const KLIK_TRAPPRIJS = [15, 100, 600, 4000, 25000];
/// De reeks die je met je lijf verdient: elke trap verdubbelt wat één push-up
/// oplevert. De drempel is het aantal echte herhalingen dat je ooit gedaan hebt.
const REP_TRAP = [50, 150, 400, 1000, 2500, 6000, 15000, 40000, 100000, 250000];
const KLIK_BASIS_REP = 1;      // één push-up is één push-up
const KLIK_OFFLINE_UUR = 12;   // zo lang tellen helpers door terwijl je weg bent
const KLIK_OFFLINE_DEEL = 0.5; // en dan op halve kracht

/// De winkel: dingen die opgaan. De prijs staat in uren productie, met een
/// bodem voor wie nog nauwelijks helpers heeft.
const KLIK_WINKEL = [
  { id: 'xp2',   uren: 3,   bodem: 300, duur: 30 * 60 },
  { id: 'punt2', uren: 1.5, bodem: 120, duur: 10 * 60 },
  { id: 'woede', uren: 5,   bodem: 500, duur: 60 },
  { id: 'voer',  uren: 8,   bodem: 800, reps: 25 },
];
const VOER_MAAL = 5, WOEDE_MAAL = 7;

let klikTab = 'helpers', klikLus = null, klikVorigeLijst = '', klikBewaardOp = 0;
let goudenOp = 0, goudenTot = 0, naVraagTrainen = false;

/// Maakt de opslag aan zodra hij nodig is. Bewust niet in DEFAULTS: die wordt
/// met de spread gekopieerd en dan zouden alle profielen hetzelfde object delen.
/// Alleen een LAGER versienummer betekent opnieuw beginnen (oude balans).
/// Een hoger of gelijk nummer blijft staan: voortgang wissen omdat iemand
/// toevallig een oudere pagina opent zou spelers onterecht leegtrekken.
function klikStaat() {
  if (!P.klik || typeof P.klik !== 'object' || (P.klik.versie || 0) < KLIK_VERSIE) {
    const oud = P.klik && typeof P.klik === 'object';
    P.klik = { versie: KLIK_VERSIE, punten: 0, totaal: 0, helpers: {}, upgrades: [],
               gezien: [], boosts: {}, voer: 0, laatst: Date.now() };
    if (oud) melding(t('klik_nieuw'), 5000);
  }
  P.klik.helpers = P.klik.helpers || {};
  P.klik.upgrades = P.klik.upgrades || [];
  P.klik.gezien = P.klik.gezien || [];
  P.klik.boosts = P.klik.boosts || {};
  // Vroeger was techniek één teller; nu een tellertje per soort.
  if (typeof P.klik.techniek === 'number') P.klik.techniek = { warm: P.klik.techniek };
  P.klik.techniek = P.klik.techniek || {};
  return P.klik;
}

/// Grote getallen leesbaar houden, in de taal van de speler: 1,2 mln / 1.2M.
function getal(n) {
  n = Math.floor(n);
  if (n < 1000) return String(n);
  try {
    return new Intl.NumberFormat(TAAL, { notation: 'compact', maximumFractionDigits: 1 }).format(n);
  } catch (e) { return n.toLocaleString(TAAL); }
}

/// Voluit met puntjes ertussen. Bij het seizoenspad wil je niet '28K' zien
/// maar precies weten hoeveel XP je nog te gaan hebt.
const voluit = n => Math.round(n).toLocaleString(TAAL === 'en' ? 'en-US' : 'nl-NL');
/// Kleine bedragen met twee decimalen, zodat je ziet dat een techniekstap iets
/// doet: 1,01 push-up per push-up moet er niet uitzien als 1.
function getalFijn(n) {
  if (n >= 100 || Number.isInteger(Math.round(n * 100) / 100)) return getal(n);
  return (Math.round(n * 100) / 100).toLocaleString(TAAL);
}
/// Een tempo in de eenheid die er nog leesbaar uitziet: per uur zolang het
/// langzaam gaat, per seconde als het hard begint te lopen.
function tempo(perSec) {
  if (perSec >= 1) return t('klik_per_sec', getal(perSec));
  const peruur = perSec * 3600;
  return t('klik_per_uur', peruur >= 10 ? getal(peruur) : (Math.round(peruur * 10) / 10).toLocaleString(TAAL));
}
/// Seconden als 2:05, want een boost van 30 minuten telt af.
function klokje(s) {
  s = Math.max(0, Math.ceil(s));
  return s < 60 ? s + 's' : Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0');
}

const helperAantal = id => klikStaat().helpers[id] || 0;
const helperPrijs = h => Math.ceil(h.prijs * Math.pow(KLIK_GROEI, helperAantal(h.id)));
/// Hoeveel verdubbelingen je voor deze helper gekocht hebt.
const helperMaal = id => Math.pow(2, klikStaat().upgrades.filter(u => u.startsWith(id + ':')).length);
const helperStuk = h => h.uur / 3600 * helperMaal(h.id);
const helperPerSec = h => helperAantal(h.id) * helperStuk(h);

/// Productie zonder tijdelijke boosts — dit is de maat voor alle prijzen.
function basisPerSec() {
  return KLIK_HELPERS.reduce((som, h) => som + helperPerSec(h), 0);
}
const boostActief = id => (klikStaat().boosts[id] || 0) > Date.now();
/// Dubbele XP werkt overal: in de arena, in het duel en online.
function xpMaal() { return boostActief('xp2') ? 2 : 1; }
const boostRest = id => Math.max(0, ((klikStaat().boosts[id] || 0) - Date.now()) / 1000);
/// Alles wat de opbrengst hier vermenigvuldigt, bij elkaar.
function klikMaal() {
  return (boostActief('punt2') ? 2 : 1) * (boostActief('woede') ? WOEDE_MAAL : 1);
}
const perSeconde = () => basisPerSec() * klikMaal();

const repTrappen = () => klikStaat().upgrades.filter(u => u.startsWith('rep:')).length;
/// Wat één echte push-up oplevert. Begint bij één en verdubbelt met elke trap
/// die je met je lijf verdiend hebt.
const repBasis = trappen => KLIK_BASIS_REP * Math.pow(2, trappen === undefined ? repTrappen() : trappen);
/// De gekochte techniekverbeteringen komen daar als percentages bovenop.
const techniekAantal = id => klikStaat().techniek[id] || 0;
const techniekPrijsVan = tk =>
  Math.ceil(tk.prijs * Math.pow(KLIK_TECHNIEK_GROEI, techniekAantal(tk.id)));
const techniekMaal = () =>
  KLIK_TECHNIEKEN.reduce((m, tk) => m * Math.pow(tk.maal, techniekAantal(tk.id)), 1);
const repWaarde = () => repBasis() * techniekMaal() * (klikStaat().voer > 0 ? VOER_MAAL : 1) * klikMaal();

function klikVerdien(n) {
  const k = klikStaat();
  k.punten += n;
  k.totaal += n;
}

/// Elke echte push-up in het spel betaalt hier uit, waar je ook bent.
function klikRepBonus() {
  const k = klikStaat();
  const winst = repWaarde();
  if (k.voer > 0) k.voer--;
  klikVerdien(winst);
  if ($('klik').classList.contains('aan')) {
    pluim('+' + getalFijn(winst));
    tekenKlik();
  }
  klikBewaar();
}

/// Sparen op de achtergrond hoeft niet elke seconde naar de opslag. En de
/// server hoeft al helemaal niet elke paar tellen een nieuwe stand: die krijgt
/// hem als je iets koopt of het scherm verlaat.
function klikBewaar(meteen = false) {
  klikStaat().laatst = Date.now();
  if (meteen) { klikBewaardOp = Date.now(); save(); return; }
  if (Date.now() - klikBewaardOp < 2000) return;
  klikBewaardOp = Date.now();
  bewaarAlles();
}

/* -- het scherm -- */

function toonKlik() {
  $('modes').classList.remove('aan');
  $('menu').classList.add('uit');
  $('stage').classList.add('uit');
  $('klik').classList.add('aan');
  $('klikKnopPad').setAttribute('d', MODE_ICONEN.plank);
  $('goudenPad').setAttribute('d', MODE_ICONEN.plank);
  klikInhaal();
  vertaalKlik();
  tekenKlik();
  tekenKlikLijst(true);
  clearInterval(klikLus);
  klikLus = setInterval(klikLoop, 100);
  goudenPlan();
}

function verlaatKlik() {
  clearInterval(klikLus); klikLus = null;
  klikTrainUit();
  $('gouden').classList.remove('aan');
  $('klik').classList.remove('aan');
  klikBewaar(true);
  toonMenu();
}

/// Wat je helpers gemaakt hebben terwijl de app dicht was. Op halve kracht en
/// met een dak erop, zodat wegblijven nooit lonender wordt dan trainen.
function klikInhaal() {
  const k = klikStaat();
  const verstreken = Math.min((Date.now() - (k.laatst || Date.now())) / 1000, KLIK_OFFLINE_UUR * 3600);
  k.laatst = Date.now();
  const winst = basisPerSec() * verstreken * KLIK_OFFLINE_DEEL;
  if (winst < 1) return;
  klikVerdien(winst);
  melding(t('klik_weg', getal(winst)), 4000);
}

function vertaalKlik() {
  $('klikEenheid').textContent = t('klik_kop').toUpperCase();
  $('tabHelpers').textContent = t('klik_helpers');
  $('tabUpgrades').textContent = t('klik_upgrades');
  $('tabWinkel').textContent = t('klik_winkel');
}

function tekenKlik() {
  const k = klikStaat();
  $('klikSaldo').textContent = getal(k.punten);
  $('klikTempo').textContent = basisPerSec() > 0 ? tempo(perSeconde()) : '';
  $('klikTik').textContent = cameraOn
    ? t('klik_bezig') + ' · ' + t('klik_per_rep', getalFijn(repWaarde()))
    : t('klik_per_rep', getalFijn(repWaarde())) + ' · ' + t('klik_train_uitleg');
  $('klikTrainTekst').textContent = cameraOn ? t('klik_train_stop') : t('klik_train');

  const strookjes = [];
  KLIK_WINKEL.forEach(w => {
    if (w.duur && boostActief(w.id)) {
      strookjes.push(`<span class="klikBoost${w.id === 'woede' ? ' woede' : ''}">` +
        ontsmet(t('klik_actief', t('koop_' + w.id), klokje(boostRest(w.id)))) + '</span>');
    }
  });
  if (k.voer > 0) {
    strookjes.push(`<span class="klikBoost">${ontsmet(t('koop_voer'))} · ` +
                   `${ontsmet(t('koop_voer_rest', k.voer))}</span>`);
  }
  $('klikBoosts').innerHTML = strookjes.join('');
}

/* -- trainen in de clicker zelf -- */

async function klikTrainAan() {
  if (cameraOn) { klikTrainUit(); return; }
  if (!apparaatVroegAl()) { naVraagTrainen = true; toonCameraVraag(); return; }
  if (!await startCamera()) { naVraagTrainen = true; toonCameraVraag(); return; }
  $('klik').classList.add('trainen');
  $('klikBalkVak').appendChild($('nosebar'));
  tekenKlik();
}

function klikTrainUit() {
  if (cameraOn) stopCamera();
  $('klik').classList.remove('trainen');
  $('stage').querySelector('.middle').appendChild($('nosebar'));
  tekenKlik();
}

/* -- wat er te koop is -- */

/// Verdubbelingen zien er anders hetzelfde uit; het romeinse cijfer erachter
/// laat zien de hoeveelste het is.
const trapNaam = i => i ? ' ' + roman(i + 1) : '';

/// Alles wat er in dit tabblad te koop is, van goedkoop naar duur. Wat je niet
/// kunt betalen blijft een vraagteken tot je er ooit genoeg voor had.
function klikAanbod() {
  const k = klikStaat();
  let rijen = [];
  if (klikTab === 'crates') klikTab = 'winkel';   // dat tabblad bestaat niet meer
  if (klikTab === 'helpers') {
    rijen = KLIK_HELPERS.map(h => ({
      id: 'h:' + h.id,
      titel: t('helper_' + h.id),
      uitleg: t('helper_' + h.id + '_uit') + ' ' + t('klik_geeft', tempo(helperStuk(h))),
      extra: helperAantal(h.id)
        ? t('klik_bezit', helperAantal(h.id)) + ' · ' + t('klik_samen', tempo(helperPerSec(h)))
        : '',
      prijs: helperPrijs(h),
      koop: () => { klikStaat().helpers[h.id] = helperAantal(h.id) + 1; },
    }));
  } else if (klikTab === 'upgrades') {
    KLIK_HELPERS.forEach(h => {
      KLIK_TRAP.forEach((drempel, i) => {
        const id = h.id + ':' + i;
        if (k.upgrades.includes(id) || helperAantal(h.id) < drempel) return;
        // Alleen de eerstvolgende trap tonen: twee tegelijk zouden allebei
        // dezelfde 'van X naar Y' laten zien.
        if (rijen.some(r => r.id.startsWith(h.id + ':'))) return;
        rijen.push({ id, prijs: Math.ceil(h.prijs * KLIK_TRAPPRIJS[i]),
                     titel: t('up_helper', t('helper_' + h.id)) + trapNaam(i),
                     uitleg: t('up_helper_uit2', t('helper_' + h.id),
                              tempo(helperPerSec(h)), tempo(helperPerSec(h) * 2)),
                     extra: '', koop: () => klikStaat().upgrades.push(id) });
      });
    });
    REP_TRAP.forEach((drempel, i) => {
      const id = 'rep:' + i;
      if (k.upgrades.includes(id) || (P.totalReps || 0) < drempel) return;
      if (rijen.some(r => r.id.startsWith('rep:'))) return;
      rijen.push({ id, prijs: Math.ceil(150 * Math.pow(8, i)),
                   titel: t('up_rep') + trapNaam(i),
                   uitleg: t('up_rep_uit2', getal(repBasis(i)), getal(repBasis(i + 1))),
                   extra: '', koop: () => klikStaat().upgrades.push(id) });
    });
    // Techniek is er altijd en raakt nooit op: elke soort maakt je push-up een
    // vast percentage meer waard. Zo blijft zelf trainen lonen naast de helpers.
    KLIK_TECHNIEKEN.forEach(tk => {
      rijen.push({ id: 'tech:' + tk.id, prijs: techniekPrijsVan(tk),
                   titel: t('tech_' + tk.id),
                   uitleg: t('up_rep_uit2',
                            getalFijn(repBasis() * techniekMaal()),
                            getalFijn(repBasis() * techniekMaal() * tk.maal)),
                   extra: techniekAantal(tk.id) ? t('klik_bezit', techniekAantal(tk.id)) : '',
                   koop: () => { klikStaat().techniek[tk.id] = techniekAantal(tk.id) + 1; } });
    });
    rijen.sort((a, b) => a.prijs - b.prijs);
  } else {
    // Eén winkel: bovenin wat je opmaakt, daaronder de kratten per soort.
    rijen = [{ kop: t('winkel_boosts') }];
    KLIK_WINKEL.forEach(w => rijen.push({
      id: 'w:' + w.id,
      titel: t('koop_' + w.id),
      uitleg: w.reps ? t('koop_' + w.id + '_uit', w.reps) : t('koop_' + w.id + '_uit'),
      extra: w.duur && boostActief(w.id) ? klokje(boostRest(w.id)) : '',
      prijs: Math.ceil(Math.max(w.bodem, basisPerSec() * 3600 * w.uren)),
      koop: () => {
        if (w.reps) klikStaat().voer += w.reps;
        else klikStaat().boosts[w.id] = Math.max(Date.now(), klikStaat().boosts[w.id] || 0) + w.duur * 1000;
      },
    }));
    KRAT_SOORTEN.forEach(srt => {
      rijen.push({ kop: t('kratgroep_' + srt.soort) });
      KRATTEN.filter(kr => kr.soort === srt.soort).forEach(kr => rijen.push({
        id: 'kr:' + kr.id,
        titel: t('krat_' + kr.id),
        uitleg: t('krat_' + srt.soort + '_uit'),
        extra: '',
        prijs: kr.prijs,
        vraag: kr.id,
        koop: () => kratBuit(kr),
      }));
    });
  }
  // Zodra je iets kunt betalen, weet je voorgoed wat het is.
  rijen.forEach(rij => {
    if (rij.kop) return;
    if (k.punten >= rij.prijs && !k.gezien.includes(rij.id)) k.gezien.push(rij.id);
    rij.open = k.gezien.includes(rij.id);
  });
  return rijen;
}

function tekenKlikLijst(altijd = false) {
  const aanbod = klikAanbod();
  const vinger = klikTab + '|' + aanbod.map(r => r.id + r.prijs + r.extra + r.open).join(',');
  if (!altijd && vinger === klikVorigeLijst) { klikPrijzenBij(); return; }
  klikVorigeLijst = vinger;

  const lijst = $('klikLijst');
  lijst.innerHTML = '';
  if (!aanbod.length) {
    lijst.innerHTML = `<div class="klikMelding">${ontsmet(
      klikTab === 'helpers' ? t('klik_leeg_helpers') : t('klik_leeg_upgrades'))}</div>`;
    return;
  }
  aanbod.forEach(rij => {
    // Kopjes verdelen de kratten in koppen, titels en kleuren.
    if (rij.kop) {
      const kop = document.createElement('div');
      kop.className = 'qKop';
      kop.textContent = rij.kop;
      lijst.appendChild(kop);
      return;
    }
    const knop = document.createElement('button');
    knop.className = 'klikItem' + (rij.open ? '' : ' dicht') + (rij.vraag ? ' metVraag' : '');
    knop.dataset.prijs = rij.prijs;
    const titel = rij.open ? rij.titel : t('klik_slot');
    const uitleg = rij.open ? rij.uitleg : t('klik_slot_uit');
    knop.innerHTML =
      `<span class="klikItemTekst"><b>${ontsmet(titel)}</b><small>${ontsmet(uitleg)}</small></span>` +
      `<span class="klikPrijs"><b>${getal(rij.prijs)}</b>` +
      (rij.extra ? `<small>${ontsmet(rij.extra)}</small>` : '') + '</span>';
    knop.onclick = e => { e.stopPropagation(); koop(rij); };
    // Het vraagteken in de hoek van een krat opent de kansen.
    if (rij.vraag) {
      const vraag = document.createElement('span');
      vraag.className = 'kratVraag';
      vraag.textContent = '?';
      vraag.onclick = e => { e.stopPropagation(); toonKansen(rij.vraag); };
      knop.appendChild(vraag);
    }
    lijst.appendChild(knop);
  });
  if (klikTab === 'helpers') {
    const uitleg = document.createElement('div');
    uitleg.className = 'klikMelding';
    uitleg.textContent = t('klik_uitleg');
    lijst.appendChild(uitleg);
  }
  klikPrijzenBij();
}

/// Alleen de kleur bijwerken: welke knoppen kun je nú betalen.
function klikPrijzenBij() {
  const saldo = klikStaat().punten;
  $('klikLijst').querySelectorAll('.klikItem').forEach(knop => {
    knop.classList.toggle('kan', saldo >= +knop.dataset.prijs);
  });
}

function koop(rij) {
  const k = klikStaat();
  if (k.punten < rij.prijs) { melding(t('klik_te_duur')); return; }
  k.punten -= rij.prijs;
  rij.koop();
  if (navigator.vibrate) navigator.vibrate(15);
  klikBewaar(true);
  tekenKlik();
  tekenKlikLijst(true);
}

function pluim(tekst) {
  const knop = $('klikKnop').getBoundingClientRect();
  const d = document.createElement('div');
  d.className = 'klikPluim';
  d.textContent = tekst;
  d.style.left = (knop.left + knop.width / 2 + (Math.random() * 60 - 30)) + 'px';
  d.style.top = (knop.top + 30) + 'px';
  document.body.appendChild(d);
  setTimeout(() => d.remove(), 900);
}

function klikLoop() {
  const k = klikStaat();
  const winst = perSeconde() / 10;
  if (winst > 0) { k.punten += winst; k.totaal += winst; }
  k.laatst = Date.now();
  tekenKlik();
  tekenKlikLijst();
  if (Date.now() > goudenOp && !$('gouden').classList.contains('aan')) goudenToon();
  if (goudenTot && Date.now() > goudenTot) verbergGouden();
  if (Date.now() - klikBewaardOp > 5000) klikBewaar();
}

/* -- de gouden push-up -- */

function goudenPlan() {
  goudenOp = Date.now() + (90 + Math.random() * 150) * 1000;
}

function goudenToon() {
  const g = $('gouden');
  g.style.left = (8 + Math.random() * 70) + '%';
  g.style.top = (28 + Math.random() * 46) + '%';
  g.classList.add('aan');
  goudenTot = Date.now() + 12000;
}

function verbergGouden() {
  $('gouden').classList.remove('aan');
  goudenTot = 0;
  goudenPlan();
}

function goudenPak() {
  verbergGouden();
  if (navigator.vibrate) navigator.vibrate([20, 40, 20]);
  if (Math.random() < 0.55) {
    klikStaat().boosts.woede = Date.now() + 30000;
    melding(t('klik_gouden') + ' ' + t('klik_gouden_woede', 30), 4000);
  } else {
    const buit = Math.max(repBasis() * 30, basisPerSec() * 3600 * 2);
    klikVerdien(buit);
    melding(t('klik_gouden') + ' ' + t('klik_gouden_buit', getal(buit)), 4000);
  }
  klikBewaar(true);
  tekenKlik();
}

$('modeKlik').addEventListener('click', e => { e.stopPropagation(); toonKlik(); });
$('klikTerug').addEventListener('click', e => { e.stopPropagation(); verlaatKlik(); });
$('klikKnop').addEventListener('click', e => { e.stopPropagation(); klikTrainAan(); });
$('gouden').addEventListener('click', e => { e.stopPropagation(); goudenPak(); });
document.querySelectorAll('.klikTab').forEach(tab => {
  tab.addEventListener('click', e => {
    e.stopPropagation();
    klikTab = tab.dataset.tab;
    document.querySelectorAll('.klikTab').forEach(x => x.classList.toggle('aan', x === tab));
    tekenKlikLijst(true);
  });
});

/* ---------------------------------------------------------------
   Op de maat: push-ups op het ritme.

   Een ring krimpt naar een doelring toe; op het moment dat hij er precies
   overheen valt hoor je een tik en moet je omlaag zijn. Hoe dichter bij die
   tik, hoe beter het telt. Vijf nummers die steeds sneller gaan; haal je
   zeventig procent, dan staat het nummer op je naam.

   Het tempo is met opzet laag voor muziek maar hoog voor push-ups: twintig
   tot zesendertig herhalingen per minuut is precies een stevig tempo.
---------------------------------------------------------------- */
/* Elk nummer heeft een echte wijs. Eén herhaling duurt één maat, en die maat
   valt uiteen in acht stapjes; op twintig tot zesendertig maten per minuut
   klinkt dat als een nummer van 160 tot 288 achtsten — gewoon muziek dus.
   De noten staan in MIDI-nummers (60 = centrale do); 0 is een rust. De wijs
   is vier maten lang en herhaalt zich, met een bas die eronder meeloopt. */
const LIEDJES = [
  { id: 1, tempo: 20, reps: 18, golf: 'triangle',
    bas: [45, 41, 43, 41],
    wijs: [69, 0, 72, 0, 76, 0, 72, 69,  0, 69, 68, 0, 69, 0, 72, 0,
           76, 0, 79, 0, 76, 72, 69, 0,  68, 0, 69, 0, 69, 0, 0, 0] },
  { id: 2, tempo: 24, reps: 20, golf: 'square',
    bas: [43, 43, 48, 46],
    wijs: [62, 65, 69, 65, 62, 0, 69, 0,  62, 65, 69, 72, 70, 69, 0, 0,
           74, 0, 72, 69, 65, 69, 72, 0,  70, 69, 67, 65, 62, 0, 0, 0] },
  { id: 3, tempo: 28, reps: 22, golf: 'sawtooth',
    bas: [40, 40, 45, 43],
    wijs: [64, 67, 71, 74, 71, 67, 64, 0,  63, 67, 70, 74, 70, 67, 63, 0,
           69, 72, 76, 72, 69, 0, 67, 0,  71, 74, 71, 67, 64, 0, 0, 0] },
  { id: 4, tempo: 32, reps: 24, golf: 'square',
    bas: [50, 48, 46, 45],
    wijs: [74, 0, 74, 76, 77, 76, 74, 72,  72, 0, 72, 74, 76, 74, 72, 70,
           70, 0, 70, 72, 74, 72, 70, 69,  69, 72, 74, 77, 76, 74, 72, 0] },
  { id: 5, tempo: 36, reps: 26, golf: 'sawtooth',
    bas: [38, 38, 43, 41],
    wijs: [74, 77, 81, 77, 74, 77, 81, 84,  83, 81, 79, 77, 74, 77, 79, 81,
           81, 84, 86, 84, 81, 79, 77, 74,  77, 79, 81, 84, 81, 77, 74, 0] },
];

/// MIDI-nummer naar toonhoogte. 69 is de a van 440 hertz.
const nootHz = n => 440 * Math.pow(2, (n - 69) / 12);

/// Zet één maat van het nummer klaar: bas, wijs, klap en een tik op de tel.
/// Alles wordt vooruit ingepland, dus haperende beeldjes storen het ritme niet.
function liedMaat(lied, maat) {
  const ac = audioAan();
  if (!ac) return;
  const t0 = ac.currentTime + 0.02;
  const maatDuur = 60 / lied.tempo;
  const stap = maatDuur / 8;
  const luid = volMuziek / 100;

  const speel = (hz, begin, duur, golf, sterkte, laagdoor) => {
    if (luid <= 0) return;
    const bron = ac.createOscillator(), knop = ac.createGain(), zeef = ac.createBiquadFilter();
    zeef.type = 'lowpass';
    zeef.frequency.setValueAtTime(laagdoor, t0 + begin);
    bron.type = golf;
    bron.frequency.setValueAtTime(hz, t0 + begin);
    knop.gain.setValueAtTime(0.0001, t0 + begin);
    knop.gain.exponentialRampToValueAtTime(sterkte * luid, t0 + begin + 0.015);
    knop.gain.exponentialRampToValueAtTime(0.0001, t0 + begin + duur);
    bron.connect(zeef).connect(knop).connect(ac.destination);
    bron.start(t0 + begin);
    bron.stop(t0 + begin + duur + 0.04);
  };
  const klap = (begin, sterkte) => {
    if (luid <= 0) return;
    const lengte = Math.floor(ac.sampleRate * 0.06);
    const buf = ac.createBuffer(1, lengte, ac.sampleRate);
    const d = buf.getChannelData(0);
    for (let i = 0; i < lengte; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / lengte);
    const bron = ac.createBufferSource(), knop = ac.createGain(), zeef = ac.createBiquadFilter();
    bron.buffer = buf;
    zeef.type = 'highpass';
    zeef.frequency.value = 5000;
    knop.gain.value = sterkte * luid;
    bron.connect(zeef).connect(knop).connect(ac.destination);
    bron.start(t0 + begin);
  };

  // De bas houdt de hele maat aan, met een stootje halverwege.
  const grond = lied.bas[maat % lied.bas.length];
  speel(nootHz(grond), 0, maatDuur * 0.55, 'triangle', 0.10, 700);
  speel(nootHz(grond + 12), stap * 4, maatDuur * 0.35, 'triangle', 0.06, 700);
  // De wijs erboven: acht stapjes uit de vier maten lange melodie.
  for (let i = 0; i < 8; i++) {
    const noot = lied.wijs[((maat % 4) * 8 + i) % lied.wijs.length];
    if (noot) speel(nootHz(noot), i * stap, stap * 0.9, lied.golf, 0.055, 2600);
    if (i % 2 === 1) klap(i * stap, 0.05);
  }
  // En op de tel zelf een duidelijke tik, want daar moet je omlaag zijn.
  toon(660, 0.05, 'square', 0.4);
}
const MZ_HALEN = 70;   // procent op de maat dat een nummer uitspeelt

let mzLied = null, mzFase = 'uit', mzTik = 0, mzTellerLus = null;
let mzGedaan = 0, mzPunten = 0, mzRaak = 0, mzVolgende = 0;

function muziekStaat() {
  if (!P.muziek || typeof P.muziek !== 'object') P.muziek = { liedjes: 0, beste: {} };
  P.muziek.beste = P.muziek.beste || {};
  return P.muziek;
}

function toonMuziek() {
  $('modes').classList.remove('aan');
  $('menu').classList.add('uit');
  $('stage').classList.add('uit');
  $('mzKies').classList.add('aan');
  startCameraIndienNodig();
  tekenMuziekKeuze();
}

function tekenMuziekKeuze() {
  const mz = muziekStaat();
  $('mzKiesKop').textContent = t('mode_muziek').toUpperCase();
  $('mzKiesUitleg').textContent = t('mz_uitleg');
  $('mzLijst').innerHTML = '';
  LIEDJES.forEach(lied => {
    const beste = mz.beste[lied.id] || 0;
    const knop = document.createElement('button');
    knop.className = 'mzRij';
    knop.innerHTML = `<span style="flex:1;min-width:0"><b>${ontsmet(t('mz_lied' + lied.id))}</b>` +
      `<small>${ontsmet(t('mz_tempo', lied.tempo, lied.reps))}</small></span>` +
      `<span class="mzBest">${beste ? ontsmet(t('mz_beste', beste)) : ontsmet(t('mz_nooit'))}</span>`;
    knop.onclick = e => { e.stopPropagation(); startLied(lied); };
    $('mzLijst').appendChild(knop);
  });
}

function startLied(lied) {
  mzLied = lied;
  mzGedaan = 0; mzPunten = 0; mzRaak = 0;
  $('mzKies').classList.remove('aan');
  $('mz').classList.add('aan');
  $('mzBalkVak').appendChild($('nosebar'));
  camBalkBijwerken();
  $('mzNaam').textContent = t('mz_lied' + lied.id);
  $('mzStop').textContent = t('duel_to_menu');
  $('mzTeller').textContent = t('mz_klaarmaken');
  $('mzScore').textContent = '';
  $('mzVul').style.width = '0%';
  mzFase = 'aftellen';
  setTimeout(() => {
    if (mzFase !== 'aftellen') return;
    mzFase = 'bezig';
    mzVolgende = Date.now() + 60000 / lied.tempo;
    mzTik = 0;
    clearInterval(muziekLus); muziekLus = null;   // de menumuziek zwijgt nu even
    liedMaat(lied, 0);
    clearInterval(mzTellerLus);
    mzTellerLus = setInterval(mzLoop, 40);
  }, 2000);
}

/// De ring krimpt naar de tik toe; op de tik zelf klinkt er een klopje.
function mzLoop() {
  if (mzFase !== 'bezig' || !mzLied) return;
  const stap = 60000 / mzLied.tempo;
  const over = mzVolgende - Date.now();
  if (over <= 0) {
    mzVolgende += stap;
    mzTik++;
    liedMaat(mzLied, mzTik);
    // Een tik zonder herhaling telt als gemist.
    if (mzTik > mzGedaan + 1) { mzGedaan++; mzOordeel('mz_mis', '#f2263a'); mzBijwerken(); }
    if (mzGedaan >= mzLied.reps) { eindeLied(); return; }
  }
  const deel = Math.max(0, Math.min(1, over / stap));
  $('mzRing').style.transform = `scale(${1 + deel * 1.1})`;
  $('mzTeller').textContent = Math.max(0, mzLied.reps - mzGedaan);
}

function mzOordeel(sleutel, kleur) {
  const el = $('mzOordeel');
  el.textContent = t(sleutel);
  el.style.color = kleur;
  el.style.opacity = 1;
  clearTimeout(el._t);
  el._t = setTimeout(() => { el.style.opacity = 0; }, 400);
}

function mzBijwerken() {
  $('mzVul').style.width = Math.min(100, mzGedaan / mzLied.reps * 100) + '%';
  const pct = mzGedaan ? Math.round(mzRaak / mzGedaan * 100) : 0;
  $('mzScore').textContent = t('mz_uit_score', pct);
}

/// Eén herhaling tijdens een nummer: hoe dicht zat je bij de tik?
function muziekRep() {
  if (mzFase !== 'bezig' || !mzLied) return;
  const stap = 60000 / mzLied.tempo;
  const afstand = Math.abs(mzVolgende - Date.now());
  const scheef = Math.min(afstand, stap - afstand);
  mzGedaan++;
  P.totalReps++;
  if (scheef < stap * 0.12) { mzRaak++; mzPunten += 3; mzOordeel('mz_perfect', '#4ade80'); toon(920, 0.1, 'triangle', 0.9); }
  else if (scheef < stap * 0.28) { mzRaak++; mzPunten += 2; mzOordeel('mz_goed', '#ffc740'); }
  else { mzOordeel('mz_mis', '#f2263a'); }
  animateNose();
  klikRepBonus();
  mzBijwerken();
  if (mzGedaan >= mzLied.reps) eindeLied();
}

function eindeLied() {
  clearInterval(mzTellerLus); mzTellerLus = null;
  mzFase = 'klaar';
  muziekBij();
  const pct = mzGedaan ? Math.round(mzRaak / mzGedaan * 100) : 0;
  const gehaald = pct >= MZ_HALEN;
  if (gehaald) questTel('lied');
  const mz = muziekStaat();
  const eerder = mz.beste[mzLied.id] || 0;
  if (pct > eerder) mz.beste[mzLied.id] = pct;
  mz.liedjes = LIEDJES.filter(l => (mz.beste[l.id] || 0) >= MZ_HALEN).length;

  const xp = Math.round((30 + mzLied.id * 25) * (gehaald ? 1 : 0.3) * xpMaal());
  P.totalXP += xp;
  bpNakijken();
  if (gehaald) tikStreak();
  klikVerdien(mzPunten * 8);
  save();

  $('mzUitKop').textContent = gehaald ? t('mz_gehaald') : t('mz_uit_titel');
  $('mzUitKop').style.color = gehaald ? '#4ade80' : '#ffc740';
  $('mzUitScore').textContent = t('mz_uit_score', pct) + (gehaald ? '' : ' · ' + t('mz_nietgehaald'));
  $('mzUitLoon').textContent = t('duel_reward', xp);
  $('mzNogmaals').textContent = t('duel_again');
  $('mzNaarMenu').textContent = t('duel_to_menu');
  $('mzUit').classList.add('aan');
  (gehaald ? geluidWin : geluidVerlies)();
}

function verlaatMuziek() {
  clearInterval(mzTellerLus); mzTellerLus = null;
  mzFase = 'uit'; mzLied = null;
  $('mzUit').classList.remove('aan');
  $('mz').classList.remove('aan');
  $('mzKies').classList.remove('aan');
  $('stage').querySelector('.middle').appendChild($('nosebar'));
  camBalkBijwerken();
  muziekBij();
  toonMenu();
}

$('padAlles').addEventListener('click', e => { e.stopPropagation(); bpAllesOphalen(); });
$('modeMuziek').addEventListener('click', e => { e.stopPropagation(); toonMuziek(); });
$('mzKiesDicht').addEventListener('click', e => { e.stopPropagation(); verlaatMuziek(); });
$('mzStop').addEventListener('click', e => { e.stopPropagation(); verlaatMuziek(); });
$('mzNaarMenu').addEventListener('click', e => { e.stopPropagation(); verlaatMuziek(); });
$('mzNogmaals').addEventListener('click', e => {
  e.stopPropagation();
  $('mzUit').classList.remove('aan');
  $('mz').classList.remove('aan');
  $('mzKies').classList.add('aan');
  tekenMuziekKeuze();
});

/* ---------------------------------------------------------------
   De wereldboss: één monster per oefening waar iedereen tegelijk op slaat.

   Zijn kracht staat niet vast maar wordt op de server afgeleid van wie er
   meedoet: aantal actieve spelers × hun gemiddelde dagproductie × vijf dagen.
   Drie spelers die ongeveer honderd per dag doen krijgen dus een boss van
   rond de 1500. Elke klap die je uitdeelt levert jou XP en push-ups op, dus
   je beloning is precies je aandeel in de schade.
---------------------------------------------------------------- */
let wbNu = null, wbLus = null, wbTeSturen = 0, wbBezig = false;
const WB_XP_PER = 2, WB_PUNT_PER = 3;

function toonBoss() {
  $('modes').classList.remove('aan');
  $('menu').classList.add('uit');
  $('stage').classList.add('uit');
  $('wb').classList.add('aan');
  $('wbKop').textContent = t('wb_titel').toUpperCase();
  $('wbAccountTekst').textContent = t('wb_account');
  $('wbNaarAccount').textContent = t('ol_open_account');
  $('wbUitleg').textContent = t('wb_uitleg');
  $('wbDicht').title = t('close');
  const aan = ingelogd();
  $('wbGeenAccount').style.display = aan ? 'none' : 'block';
  $('wbVak').style.display = aan ? 'flex' : 'none';
  if (!aan) return;
  $('wbBalkVak').appendChild($('nosebar'));
  camBalkBijwerken();
  startCameraIndienNodig();
  wbHaal();
  clearInterval(wbLus);
  wbLus = setInterval(wbTikken, 2500);
}

function verlaatBoss() {
  clearInterval(wbLus); wbLus = null;
  wbVersturen(true);
  $('wb').classList.remove('aan');
  $('stage').querySelector('.middle').appendChild($('nosebar'));
  camBalkBijwerken();
  toonMenu();
}

async function wbHaal() {
  try {
    const a = await sbVraag('/rest/v1/rpc/boss_nu', {
      method: 'POST', body: JSON.stringify({ p_sport: SPORT }) });
    if (!a.ok) throw new Error(a.status);
    wbNu = await a.json();
    tekenBoss();
  } catch (e) { melding(t('wb_offline'), 3000); }
}

function tekenBoss() {
  if (!wbNu) return;
  const arena = arenaAt(Math.min(21, 1 + (wbNu.id % 21)));
  $('wbSvg').innerHTML = monsterPaden(arena, rgbCss(arena.rgb));
  $('wbVul').style.width = Math.max(0, wbNu.hp / wbNu.hp_max * 100) + '%';
  $('wbHp').textContent = t('wb_hp', getal(wbNu.hp), getal(wbNu.hp_max));
  $('wbMee').textContent = t('wb_vechters', wbNu.vechters, getal(wbNu.samen));
  $('wbJij').textContent = t('wb_jij', getal(wbNu.jij));
}

/// Eén herhaling = één klap. We sturen ze gebundeld op, anders zou elke
/// push-up een eigen verzoek zijn.
function bossRep() {
  if (!wbNu || !ingelogd()) return;
  P.totalReps++;
  wbTeSturen++;
  wbNu.hp = Math.max(0, wbNu.hp - 1);
  wbNu.jij++; wbNu.samen++;
  P.bossSchade = (P.bossSchade || 0) + 1;
  questTel('wbslag');
  P.totalXP += WB_XP_PER * xpMaal();
  klikVerdien(WB_PUNT_PER);
  bpNakijken();
  animateNose();
  tekenBoss();
  save();
}

function wbTikken() { wbVersturen(false); }

async function wbVersturen(sluiten) {
  if (wbBezig || !wbNu || !ingelogd()) return;
  if (!wbTeSturen) { if (!sluiten) wbHaal(); return; }
  const klap = wbTeSturen;
  wbTeSturen = 0;
  wbBezig = true;
  try {
    const a = await sbVraag('/rest/v1/rpc/boss_sla', {
      method: 'POST', body: JSON.stringify({ p_id: wbNu.id, p_schade: klap }) });
    if (a.ok) {
      const was = wbNu.klaar;
      wbNu = await a.json();
      tekenBoss();
      if (wbNu.klaar && !was) {
        melding(t('wb_dood'), 5000);
        geluidWin();
        setTimeout(() => { wbHaal(); melding(t('wb_nieuw'), 4000); }, 2500);
      }
    } else { wbTeSturen += klap; }
  } catch (e) { wbTeSturen += klap; }
  wbBezig = false;
}

$('modeBoss').addEventListener('click', e => { e.stopPropagation(); toonBoss(); });
$('wbDicht').addEventListener('click', e => { e.stopPropagation(); verlaatBoss(); });
$('wbNaarAccount').addEventListener('click', e => { e.stopPropagation(); toonAccount(); });

// Helemaal onderaan starten, zodat alle variabelen hierboven al bestaan.
bouwTaalRij();
vertaalVast();
spawn();
toonMenu();
$('accountKnop').classList.toggle('aan', ingelogd());
tekenFoto();
if (ingelogd()) {
  bezig(t('loading_saved'));
  haalVoortgangOp().then(() => { klaar(); render(); renderMenu(); });
}
else if (rondleidingNodig()) lesStart();
</script>
