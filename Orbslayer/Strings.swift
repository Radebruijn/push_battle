// Automatisch gegenereerd door taal.py — bewerk taal.json, niet dit bestand.

import Foundation

enum Lang: String, Codable, CaseIterable {
    case nl, en, fr

    var label: String {
        switch self {
        case .nl: return "Nederlands"
        case .en: return "English"
        case .fr: return "Français"
        }
    }

    var short: String { rawValue.uppercased() }

    /// De taal van het toestel, als we die ondersteunen.
    static var systemDefault: Lang {
        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? "nl"
        return Lang(rawValue: String(code)) ?? .en
    }
}

/// Sleutels van alle interfaceteksten.
enum Tk: String {
    case fight
    case up_next
    case reset_progress
    case reset_title
    case reset_msg
    case reset_confirm
    case cancel
    case stat_streak
    case stat_pushups
    case stat_kills
    case stat_arenas
    case quests_titel
    case quests_vandaag
    case quests_week
    case quest_af
    case quest_reps25
    case quest_kills3
    case quest_boss1
    case quest_combo1
    case quest_duel1
    case quest_snel20
    case quest_wreps300
    case quest_wboss5
    case quest_wduel5
    case quest_wkills40
    case trofee_titel
    case trofee_leeg
    case arena_n
    case arena_n_race
    case boss
    case boss_named
    case unknown_arena
    case unknown_race
    case locked_known
    case locked_unknown
    case reps_n
    case combo_n
    case crit_n
    case xp_gain
    case boss_defeated
    case level_up
    case boss_incoming
    case hp_of
    case hp_short
    case xp_of
    case level_n
    case rank_level
    case rank_1
    case rank_2
    case rank_3
    case rank_4
    case rank_5
    case rank_6
    case rank_7
    case rank_8
    case cal_step
    case cal_title_up
    case cal_title_down
    case cal_text_up
    case cal_text_down
    case cal_capture
    case cal_no_face
    case cal_skip
    case cal_again
    case cal_too_small
    case bar_up
    case bar_down
    case cam_start
    case cam_stop
    case cam_starting
    case cam_permission
    case cam_loading
    case cam_failed
    case cam_searching
    case cam_no_face
    case cam_height
    case cam_off_label
    case cam_denied
    case cam_no_access
    case cam_needs_https
    case cam_model_failed
    case cam_settings
    case cam_none
    case hint_tap
    case hint_camera
    case hint_searching
    case hint_sim
    case language
    case menu_modes
    case mode_arena
    case mode_arena_sub
    case mode_duel
    case mode_duel_sub
    case difficulty
    case duel_start
    case duel_you
    case duel_ai
    case duel_ready
    case duel_go
    case duel_win
    case duel_lose
    case duel_score
    case duel_again
    case duel_to_menu
    case duel_seconds
    case duel_best
    case duel_none_yet
    case duel_won_count
    case duel_warn_100
    case duel_reward
    case duel_consolation
    case duel_intro
    case band_1
    case band_2
    case band_3
    case band_4
    case band_5
    case band_6
    case band_7
    case band_8
    case cam_needed
    case settings
    case depth
    case depth_value
    case depth_hint
    case calibrate_now
    case close
    case account
    case sign_in
    case sign_up
    case sign_out
    case email
    case password
    case not_signed_in
    case signed_in_as
    case synced
    case syncing
    case sync_failed
    case check_email
    case auth_failed
    case stats_title
    case stat_duels
    case stat_level
    case stat_arena_now
    case pw_rules
    case pw_capital
    case pw_digit
    case pw_symbol
    case pw_length
    case account_made
    case email_taken
    case email_invalid
    case signup_failed
    case cam_ask_title
    case cam_ask_text
    case cam_ask_device
    case cam_allow
    case cam_without
    case cam_denied_help
    case tip_skip
    case tip_menu
    case tip_setup
    case tip_bar
    case tip_calib
    case tip_duel
    case tip_account
    case tip_boss
    case tip_combo
    case tour_skip
    case tour_next
    case tour_back
    case tour_start
    case tour_step
    case tour1_kop
    case tour1_tekst
    case tour2_kop
    case tour2_tekst
    case tour3_kop
    case tour3_tekst
    case tour4_kop
    case tour4_tekst
    case tour5_kop
    case tour5_tekst
    case tour6_kop
    case tour6_tekst
    case tour_again
    case loading
    case loading_slow
    case signing_in
    case signing_up
    case loading_saved
    case loading_camera
    case loading_model
    case leaderboard
    case lb_loading
    case lb_empty
    case lb_failed
    case lb_you
    case lb_need_account
    case name_label
    case name_hint
    case name_save
    case name_saved
    case name_private
    case name_local
    case mode_online
    case mode_online_sub
    case ol_sub
    case ol_need_account
    case ol_open_account
    case ol_name_label
    case ol_record
    case ol_players
    case ol_find
    case ol_friend
    case ol_make_code
    case ol_code
    case ol_join
    case ol_joining
    case ol_searching
    case ol_waiting_friend
    case ol_code_share
    case ol_nobody
    case ol_bad_code
    case ol_offline
    case ol_versus
    case ol_give_up
    case ol_win_by_leave
    case ol_draw
    case ol_player_1
    case mode_klik
    case mode_klik_sub
    case klik_kop
    case klik_per_sec
    case klik_per_rep
    case klik_helpers
    case klik_upgrades
    case klik_winkel
    case klik_crates
    case inv_titel
    case inv_sec_titels
    case inv_sec_iconen
    case inv_sec_kleuren
    case krat_hout
    case krat_hout_uit
    case krat_zilver
    case krat_zilver_uit
    case krat_goud
    case krat_goud_uit
    case graad_1
    case graad_2
    case graad_3
    case buit_nieuw
    case buit_dubbel
    case cos_vroegevogel
    case cos_doorzetter
    case cos_vloerveger
    case cos_nachtuil
    case cos_orkenschrik
    case cos_bossenjager
    case cos_ijzerenborst
    case cos_combokoning
    case cos_demachine
    case cos_onverwoestbaar
    case cos_goud
    case cos_gras
    case cos_lucht
    case cos_roze
    case cos_paars
    case cos_vuur
    case cos_bloed
    case cos_ijs
    case klik_leeg_helpers
    case klik_leeg_upgrades
    case klik_weg
    case klik_uitleg
    case klik_bezit
    case klik_gekocht
    case klik_actief
    case klik_gouden
    case klik_gouden_woede
    case klik_gouden_buit
    case up_helper
    case up_helper_uit
    case up_rep
    case up_rep_uit
    case koop_xp2
    case koop_xp2_uit
    case koop_punt2
    case koop_punt2_uit
    case koop_woede
    case koop_woede_uit
    case koop_voer
    case koop_voer_uit
    case koop_voer_rest
    case klik_te_duur
    case klik_per_uur
    case klik_train
    case klik_train_stop
    case klik_train_uitleg
    case klik_bezig
    case klik_slot
    case klik_slot_uit
    case up_helper_uit2
    case up_rep_uit2
    case tech_warm
    case tech_adem
    case tech_houding
    case tech_ritme
    case tech_grip
    case tech_coach
    case klik_geeft
    case klik_samen
    case klik_nieuw
    case helper_maat
    case helper_maat_uit
    case helper_groep
    case helper_groep_uit
    case helper_zaal
    case helper_zaal_uit
    case helper_school
    case helper_school_uit
    case helper_club
    case helper_club_uit
    case helper_stadion
    case helper_stadion_uit
    case helper_buurt
    case helper_buurt_uit
    case helper_stad
    case helper_stad_uit
    case helper_provincie
    case helper_provincie_uit
    case helper_land
    case helper_land_uit
    case helper_werelddeel
    case helper_werelddeel_uit
    case helper_wereld
    case helper_wereld_uit
    case foto_label
    case foto_kies
    case foto_weg
    case foto_hint
    case foto_prive
    case foto_lokaal
    case foto_klaar
    case foto_fout
    case foto_bezig
    case naam_geweigerd
    case meld_knop
    case meld_klaar
    case meld_verborgen
    case meld_account
    case meld_fout
    case foto_regels
    case les1
    case les2
    case les3
    case les_knop
    case les_skip
    case geluid_label
    case muziek_label
    case geluid_uit
    case geluid_uitleg
    case muziek_uitleg
    case menu_meer
    case quest_stand
    case sign_out_zeker
    case les4
    case les5
    case les6
    case les7
    case les8
    case les9
    case trofee_nog
}

enum Strings {
    private static let table: [String: [String]] = [
        "fight": ["VECHTEN", "FIGHT", "COMBATTRE"],
        "up_next": ["HIERNA", "UP NEXT", "LA SUITE"],
        "reset_progress": ["Voortgang wissen", "Reset progress", "Effacer la progression"],
        "reset_title": ["Alles wissen?", "Erase everything?", "Tout effacer ?"],
        "reset_msg": ["Je level, XP, streak en alle kills gaan verloren. Dit kan niet ongedaan gemaakt worden.", "Your level, XP, streak and every kill will be lost. This cannot be undone.", "Ton niveau, ton XP, ta série et toutes tes victimes seront perdus. C'est irréversible."],
        "reset_confirm": ["Wissen", "Erase", "Effacer"],
        "cancel": ["Annuleren", "Cancel", "Annuler"],
        "stat_streak": ["dagen streak", "day streak", "jours de suite"],
        "stat_pushups": ["push-ups", "push-ups", "pompes"],
        "stat_kills": ["kills", "kills", "victimes"],
        "stat_arenas": ["arena's uit", "arenas cleared", "arènes finies"],
        "quests_titel": ["Opdrachten", "Quests", "Missions"],
        "quests_vandaag": ["Vandaag", "Today", "Aujourd'hui"],
        "quests_week": ["Deze week", "This week", "Cette semaine"],
        "quest_af": ["Opdracht volbracht: {0}", "Quest complete: {0}", "Mission accomplie : {0}"],
        "quest_reps25": ["Doe {0} push-ups", "Do {0} push-ups", "Fais {0} pompes"],
        "quest_kills3": ["Versla {0} vijanden", "Defeat {0} enemies", "Bats {0} ennemis"],
        "quest_boss1": ["Versla een boss", "Defeat a boss", "Bats un boss"],
        "quest_combo1": ["Maak een combo van 10", "Build a 10-rep combo", "Fais un combo de 10"],
        "quest_duel1": ["Win een duel", "Win a duel", "Gagne un duel"],
        "quest_snel20": ["Doe {0} push-ups binnen 60 seconden", "Do {0} push-ups within 60 seconds", "Fais {0} pompes en 60 secondes"],
        "quest_wreps300": ["Doe {0} push-ups deze week", "Do {0} push-ups this week", "Fais {0} pompes cette semaine"],
        "quest_wboss5": ["Versla {0} bosses deze week", "Defeat {0} bosses this week", "Bats {0} boss cette semaine"],
        "quest_wduel5": ["Win {0} duels deze week", "Win {0} duels this week", "Gagne {0} duels cette semaine"],
        "quest_wkills40": ["Versla {0} vijanden deze week", "Defeat {0} enemies this week", "Bats {0} ennemis cette semaine"],
        "trofee_titel": ["Trofeeënkast", "Trophy cabinet", "Vitrine à trophées"],
        "trofee_leeg": ["Versla je eerste boss en zijn kop hangt hier.", "Defeat your first boss and its head will hang here.", "Bats ton premier boss et sa tête sera accrochée ici."],
        "arena_n": ["ARENA {0}", "ARENA {0}", "ARÈNE {0}"],
        "arena_n_race": ["ARENA {0} · {1}", "ARENA {0} · {1}", "ARÈNE {0} · {1}"],
        "boss": ["BOSS", "BOSS", "BOSS"],
        "boss_named": ["BOSS · {0}", "BOSS · {0}", "BOSS · {0}"],
        "unknown_arena": ["???", "???", "???"],
        "unknown_race": ["onbekend", "unknown", "inconnu"],
        "locked_known": ["{0} opent zich na arena {1}.", "{0} opens after arena {1}.", "{0} s'ouvre après l'arène {1}."],
        "locked_unknown": ["Deze arena onthult zich later.", "This arena reveals itself later.", "Cette arène se révélera plus tard."],
        "reps_n": ["{0} reps", "{0} reps", "{0} reps"],
        "combo_n": ["COMBO ×{0}", "COMBO ×{0}", "COMBO ×{0}"],
        "crit_n": ["CRIT ×{0}", "CRIT ×{0}", "CRIT ×{0}"],
        "xp_gain": ["+{0} XP", "+{0} XP", "+{0} XP"],
        "boss_defeated": ["BOSS VERSLAGEN", "BOSS DEFEATED", "BOSS VAINCU"],
        "level_up": ["LEVEL {0}", "LEVEL {0}", "NIVEAU {0}"],
        "boss_incoming": ["⚠︎ BOSS NADERT", "⚠︎ BOSS INCOMING", "⚠︎ BOSS APPROCHE"],
        "hp_of": ["{0} / {1} HP", "{0} / {1} HP", "{0} / {1} PV"],
        "hp_short": ["{0} HP", "{0} HP", "{0} PV"],
        "xp_of": ["{0} / {1} XP", "{0} / {1} XP", "{0} / {1} XP"],
        "level_n": ["Level {0}", "Level {0}", "Niveau {0}"],
        "rank_level": ["{0} · Level {1}", "{0} · Level {1}", "{0} · Niveau {1}"],
        "rank_1": ["Rekruut", "Recruit", "Recrue"],
        "rank_2": ["Vuistvechter", "Brawler", "Bagarreur"],
        "rank_3": ["Orbjager", "Orb Hunter", "Chasseur d'Orbes"],
        "rank_4": ["Slachter", "Butcher", "Boucher"],
        "rank_5": ["Orbslayer", "Orbslayer", "Orbslayer"],
        "rank_6": ["Bossbreker", "Bossbreaker", "Brise-Boss"],
        "rank_7": ["Legende", "Legend", "Légende"],
        "rank_8": ["Onsterfelijke", "Immortal", "Immortel"],
        "cal_step": ["STAP {0} VAN 2", "STEP {0} OF 2", "ÉTAPE {0} SUR 2"],
        "cal_title_up": ["Strek je armen", "Straighten your arms", "Tends les bras"],
        "cal_title_down": ["Zak naar de grond", "Lower to the floor", "Descends au sol"],
        "cal_text_up": ["Ga in plankhouding met gestrekte armen. Dit wordt je bovenste stand.", "Get into a plank with your arms straight. This becomes your top position.", "Mets-toi en planche, bras tendus. Ce sera ta position haute."],
        "cal_text_down": ["Zak tot je borst bijna de grond raakt en houd vast. Dit wordt je onderste stand.", "Lower until your chest almost touches the floor and hold. This becomes your bottom position.", "Descends jusqu'à ce que ta poitrine frôle le sol et tiens. Ce sera ta position basse."],
        "cal_capture": ["Vastleggen", "Capture", "Enregistrer"],
        "cal_no_face": ["Hoofd niet zichtbaar", "Head not visible", "Tête non visible"],
        "cal_skip": ["Overslaan", "Skip", "Passer"],
        "cal_again": ["Opnieuw kalibreren", "Recalibrate", "Recalibrer"],
        "cal_too_small": ["Te weinig verschil tussen boven en beneden — standaardwaarden aangehouden.", "Too little difference between top and bottom — keeping the defaults.", "Trop peu d'écart entre le haut et le bas — valeurs par défaut conservées."],
        "bar_up": ["boven", "top", "haut"],
        "bar_down": ["beneden", "bottom", "bas"],
        "cam_start": ["📷 Camera aanzetten", "📷 Turn on camera", "📷 Activer la caméra"],
        "cam_stop": ["📷 Camera uit", "📷 Camera off", "📷 Caméra éteinte"],
        "cam_starting": ["camera starten…", "starting camera…", "démarrage caméra…"],
        "cam_permission": ["toestemming vragen", "asking permission", "demande d'autorisation"],
        "cam_loading": ["model laden…", "loading model…", "chargement du modèle…"],
        "cam_failed": ["mislukt", "failed", "échec"],
        "cam_searching": ["zoekt je hoofd", "looking for your head", "recherche de ta tête"],
        "cam_no_face": ["geen hoofd in beeld", "no head in view", "aucune tête visible"],
        "cam_height": ["hoogte {0}%", "height {0}%", "hauteur {0}%"],
        "cam_off_label": ["camera uit", "camera off", "caméra éteinte"],
        "cam_denied": ["Camera geweigerd. Werkt niet in de Browser-pane van de app —<br>open deze pagina in Safari of Chrome.", "Camera denied. This does not work in the app's Browser pane —<br>open this page in Safari or Chrome.", "Caméra refusée. Cela ne marche pas dans le volet Navigateur de l'app —<br>ouvre cette page dans Safari ou Chrome."],
        "cam_no_access": ["Geen toegang tot de camera: {0}", "No access to the camera: {0}", "Pas d'accès à la caméra : {0}"],
        "cam_needs_https": ["Camera werkt alleen via localhost of https, niet via een IP-adres.", "The camera only works over localhost or https, not over an IP address.", "La caméra ne fonctionne que via localhost ou https, pas via une adresse IP."],
        "cam_model_failed": ["Model laden mislukt (internet nodig): {0}", "Failed to load the model (internet required): {0}", "Échec du chargement du modèle (internet requis) : {0}"],
        "cam_settings": ["Geen toegang tot de camera. Zet die aan in Instellingen.", "No access to the camera. Enable it in Settings.", "Pas d'accès à la caméra. Active-la dans Réglages."],
        "cam_none": ["Geen camera gevonden op dit toestel.", "No camera found on this device.", "Aucune caméra trouvée sur cet appareil."],
        "hint_tap": ["Tik ergens op het scherm = één push-up", "Tap anywhere on the screen = one push-up", "Touche l'écran = une pompe"],
        "hint_camera": ["Doe een push-up — je hele hoofd wordt gevolgd", "Do a push-up — your whole head is tracked", "Fais une pompe — toute ta tête est suivie"],
        "hint_searching": ["Zoekt je hoofd… zorg dat je recht voor de camera ligt", "Looking for your head… make sure you are facing the camera", "Recherche de ta tête… place-toi face à la caméra"],
        "hint_sim": ["Simulator: tik op het scherm voor een rep", "Simulator: tap the screen for a rep", "Simulateur : touche l'écran pour une répétition"],
        "language": ["Taal", "Language", "Langue"],
        "menu_modes": ["Spelmodus", "Game mode", "Mode de jeu"],
        "mode_arena": ["Arena", "Arena", "Arène"],
        "mode_arena_sub": ["Eindeloze arena's, minions en bosses", "Endless arenas, minions and bosses", "Arènes sans fin, sbires et boss"],
        "mode_duel": ["Duel", "Duel", "Duel"],
        "mode_duel_sub": ["60 seconden tegen een tegenstander", "60 seconds against an opponent", "60 secondes contre un adversaire"],
        "difficulty": ["Moeilijkheid", "Difficulty", "Difficulté"],
        "duel_start": ["START", "START", "DÉPART"],
        "duel_you": ["JIJ", "YOU", "TOI"],
        "duel_ai": ["TEGENSTANDER", "OPPONENT", "ADVERSAIRE"],
        "duel_ready": ["KLAAR?", "READY?", "PRÊT ?"],
        "duel_go": ["GO!", "GO!", "PARTEZ !"],
        "duel_win": ["GEWONNEN", "YOU WIN", "GAGNÉ"],
        "duel_lose": ["VERLOREN", "YOU LOSE", "PERDU"],
        "duel_score": ["{0} tegen {1}", "{0} to {1}", "{0} contre {1}"],
        "duel_again": ["Nog een keer", "Go again", "Encore une fois"],
        "duel_to_menu": ["Naar het menu", "Back to menu", "Retour au menu"],
        "duel_seconds": ["{0}s", "{0}s", "{0} s"],
        "duel_best": ["Beste op dit niveau: {0}", "Best at this level: {0}", "Record à ce niveau : {0}"],
        "duel_none_yet": ["nog geen poging", "no attempt yet", "aucune tentative"],
        "duel_won_count": ["duels gewonnen", "duels won", "duels gagnés"],
        "duel_warn_100": ["100% is bijna onmogelijk.", "100% is nearly impossible.", "100 % est presque impossible."],
        "duel_reward": ["+{0} XP", "+{0} XP", "+{0} XP"],
        "duel_consolation": ["Verloren — maar {0} XP voor de moeite.", "Lost — but {0} XP for the effort.", "Perdu — mais {0} XP pour l'effort."],
        "duel_intro": ["Hou hem bij.", "Keep up with him.", "Suis son rythme."],
        "band_1": ["Warmlopen", "Warm-up", "Échauffement"],
        "band_2": ["Makkelijk", "Easy", "Facile"],
        "band_3": ["Stevig", "Solid", "Solide"],
        "band_4": ["Pittig", "Tough", "Costaud"],
        "band_5": ["Zwaar", "Heavy", "Lourd"],
        "band_6": ["Brutaal", "Brutal", "Brutal"],
        "band_7": ["Meedogenloos", "Merciless", "Impitoyable"],
        "band_8": ["Onmogelijk", "Impossible", "Impossible"],
        "cam_needed": ["Zet de camera aan zodat je push-ups geteld worden.", "Turn on the camera so your push-ups get counted.", "Active la caméra pour que tes pompes soient comptées."],
        "settings": ["Instellingen", "Settings", "Réglages"],
        "depth": ["Diepte", "Depth", "Profondeur"],
        "depth_value": ["{0}% van je bereik", "{0}% of your range", "{0}% de ton amplitude"],
        "depth_hint": ["Hoe ver je moet zakken voordat een push-up telt. Hoger is strenger.", "How far you must lower before a push-up counts. Higher is stricter.", "Jusqu'où tu dois descendre pour qu'une pompe compte. Plus haut, plus strict."],
        "calibrate_now": ["Kalibreren", "Calibrate", "Calibrer"],
        "close": ["Sluiten", "Close", "Fermer"],
        "account": ["Account", "Account", "Compte"],
        "sign_in": ["Inloggen", "Sign in", "Se connecter"],
        "sign_up": ["Account maken", "Create account", "Créer un compte"],
        "sign_out": ["Uitloggen", "Sign out", "Se déconnecter"],
        "email": ["E-mailadres", "Email", "E-mail"],
        "password": ["Wachtwoord", "Password", "Mot de passe"],
        "not_signed_in": ["Je speelt zonder account. Je voortgang staat alleen op dit apparaat.", "You are playing without an account. Your progress stays on this device only.", "Tu joues sans compte. Ta progression reste uniquement sur cet appareil."],
        "signed_in_as": ["Ingelogd als {0}", "Signed in as {0}", "Connecté en tant que {0}"],
        "synced": ["Voortgang wordt bewaard", "Progress is being saved", "Progression sauvegardée"],
        "syncing": ["Bezig met opslaan…", "Saving…", "Enregistrement…"],
        "sync_failed": ["Opslaan mislukt — je voortgang staat nog op dit apparaat.", "Saving failed — your progress is still on this device.", "Échec de l'enregistrement — ta progression reste sur cet appareil."],
        "check_email": ["Kijk in je mail en klik op de bevestigingslink. Daarna kun je inloggen.", "Check your email and click the confirmation link. Then you can sign in.", "Vérifie tes mails et clique sur le lien de confirmation. Ensuite tu peux te connecter."],
        "auth_failed": ["Inloggen mislukt: {0}", "Sign-in failed: {0}", "Échec de la connexion : {0}"],
        "stats_title": ["Jouw cijfers", "Your numbers", "Tes chiffres"],
        "stat_duels": ["duels gewonnen", "duels won", "duels gagnés"],
        "stat_level": ["level", "level", "niveau"],
        "stat_arena_now": ["arena", "arena", "arène"],
        "pw_rules": ["Je wachtwoord moet:", "Your password must:", "Ton mot de passe doit :"],
        "pw_capital": ["met een hoofdletter beginnen", "start with a capital letter", "commencer par une majuscule"],
        "pw_digit": ["een cijfer bevatten", "contain a number", "contenir un chiffre"],
        "pw_symbol": ["een leesteken bevatten", "contain a punctuation mark", "contenir un signe de ponctuation"],
        "pw_length": ["langer zijn dan 6 tekens", "be longer than 6 characters", "faire plus de 6 caractères"],
        "account_made": ["Account gemaakt. Je bent ingelogd.", "Account created. You are signed in.", "Compte créé. Tu es connecté."],
        "email_taken": ["Dit e-mailadres heeft al een account. Gebruik inloggen.", "This email already has an account. Use sign in instead.", "Cette adresse a déjà un compte. Utilise la connexion."],
        "email_invalid": ["Dat lijkt geen geldig e-mailadres.", "That does not look like a valid email address.", "Cette adresse e-mail ne semble pas valide."],
        "signup_failed": ["Account maken mislukt: {0}", "Could not create account: {0}", "Échec de la création du compte : {0}"],
        "cam_ask_title": ["Camera gebruiken", "Use the camera", "Utiliser la caméra"],
        "cam_ask_text": ["We tellen je push-ups met de camera van dit apparaat. Het beeld wordt alleen op je toestel bekeken en gaat nergens heen — er wordt niets opgeslagen of verstuurd.", "We count your push-ups with this device's camera. The video is only looked at on your device and goes nowhere — nothing is stored or sent.", "Nous comptons tes pompes avec la caméra de cet appareil. La vidéo est analysée uniquement sur ton appareil et n'est ni enregistrée ni envoyée."],
        "cam_ask_device": ["Elk nieuw apparaat vraagt dit opnieuw.", "Every new device asks this again.", "Chaque nouvel appareil redemande."],
        "cam_allow": ["Camera toestaan", "Allow camera", "Autoriser la caméra"],
        "cam_without": ["Zonder camera spelen", "Play without camera", "Jouer sans caméra"],
        "cam_denied_help": ["Je hebt de camera geweigerd. Sta hem alsnog toe bij de instellingen van deze site in je browser.", "You denied the camera. Allow it for this site in your browser settings.", "Tu as refusé la caméra. Autorise-la pour ce site dans les réglages de ton navigateur."],
        "tip_skip": ["Uitleg overslaan", "Skip the tips", "Passer les explications"],
        "tip_menu": ["Dit is je thuisbasis. Onderaan begin je een gevecht; linksboven kies je een andere spelmodus.", "This is your home base. Start a fight at the bottom; pick another game mode top left.", "Voici ta base. Lance un combat en bas ; choisis un autre mode en haut à gauche."],
        "tip_setup": ["Zet je telefoon rechtop voor je op de grond, zodat de camera je van de voorkant ziet.", "Stand your phone upright in front of you on the floor, so the camera sees you from the front.", "Pose ton téléphone debout devant toi, pour que la caméra te voie de face."],
        "tip_bar": ["De balk rechts is jouw hoogte. Ga onder het onderste streepje en weer boven het bovenste: dat is één push-up.", "The bar on the right is your height. Go below the bottom mark and back above the top one: that is one push-up.", "La barre à droite indique ta hauteur. Descends sous le repère bas puis remonte au-dessus du haut : c'est une pompe."],
        "tip_calib": ["Kalibreren leert je bereik kennen: één keer met gestrekte armen, één keer laag. Daarna telt hij pas goed.", "Calibrating learns your range: once with straight arms, once down low. Only then does it count properly.", "Le calibrage mesure ton amplitude : une fois bras tendus, une fois en bas. C'est ce qui rend le comptage juste."],
        "tip_duel": ["Zestig seconden tegen een tegenstander. Kies zelf hoe zwaar; winnen levert veel meer XP op.", "Sixty seconds against an opponent. You choose how hard; winning earns far more XP.", "Soixante secondes contre un adversaire. Tu choisis la difficulté ; gagner rapporte bien plus d'XP."],
        "tip_account": ["Zonder account blijft je voortgang op dit apparaat. Log in en hij gaat mee naar je telefoon en laptop.", "Without an account your progress stays on this device. Sign in and it follows you to your phone and laptop.", "Sans compte, ta progression reste sur cet appareil. Connecte-toi et elle te suit partout."],
        "tip_boss": ["Een boss moet je in één keer neerhalen. Ga je terug naar het menu, dan staat hij weer op volle kracht.", "A boss must go down in one session. Return to the menu and it is back at full strength.", "Un boss doit tomber en une seule fois. Si tu retournes au menu, il revient au complet."],
        "tip_combo": ["Tien herhalingen achter elkaar en je slaat dubbel zo hard. Blijf doorgaan.", "Ten reps in a row and you hit twice as hard. Keep going.", "Dix répétitions d'affilée et tu frappes deux fois plus fort. Continue."],
        "tour_skip": ["Overslaan", "Skip", "Passer"],
        "tour_next": ["Volgende", "Next", "Suivant"],
        "tour_back": ["Vorige", "Back", "Précédent"],
        "tour_start": ["Beginnen", "Start playing", "Commencer"],
        "tour_step": ["{0} van {1}", "{0} of {1}", "{0} sur {1}"],
        "tour1_kop": ["Welkom", "Welcome", "Bienvenue"],
        "tour1_tekst": ["Push Battle maakt van push-ups een gevecht. Elke herhaling die je doet is een klap tegen het monster voor je.", "Push Battle turns push-ups into a fight. Every rep you do is a hit against the monster in front of you.", "Push Battle transforme les pompes en combat. Chaque répétition frappe le monstre devant toi."],
        "tour2_kop": ["Positie van je telefoon", "Position your phone", "Position de ton téléphone"],
        "tour2_tekst": ["Zet je telefoon rechtop voor je op de grond, zodat de camera je van de voorkant ziet. Tijdens het trainen hoef je niets aan te raken.", "Place your phone upright on the floor in front of you, so the camera sees you from the front. You never have to touch it while training.", "Pose ton téléphone debout au sol devant toi, pour que la caméra te voie de face. Tu n'as rien à toucher pendant l'entraînement."],
        "tour3_kop": ["Zo wordt geteld", "How counting works", "Comment ça compte"],
        "tour3_tekst": ["De balk rechts is de hoogte van je hoofd. Zak onder het onderste streepje en kom weer boven het bovenste: dat is één push-up.", "The bar on the right is the height of your head. Drop below the bottom mark and come back above the top one: that is one push-up.", "La barre à droite indique la hauteur de ta tête. Descends sous le repère bas puis remonte au-dessus du haut : c'est une pompe."],
        "tour4_kop": ["Eerst kalibreren", "Calibrate first", "D'abord le calibrage"],
        "tour4_tekst": ["Eén keer met gestrekte armen, één keer laag bij de grond. Zo weet het spel wat jouw bereik is en telt het eerlijk mee.", "Once with your arms straight, once down near the floor. That is how the game learns your range and counts fairly.", "Une fois bras tendus, une fois près du sol. Le jeu apprend ainsi ton amplitude et compte justement."],
        "tour5_kop": ["Vier manieren om te spelen", "Four ways to play", "Quatre façons de jouer"],
        "tour5_tekst": ["In de arena vecht je je door eenentwintig werelden. In het duel neem je het zestig seconden op tegen een tegenstander, online tegen een echte speler, en in de clicker bouw je met je push-ups een imperium.", "In the arena you fight through twenty-one worlds. In the duel you race an opponent for sixty seconds, online you race a real player, and in the clicker you build an empire out of your push-ups.", "Dans l'arène tu traverses vingt et un mondes. En duel tu affrontes un adversaire pendant soixante secondes, en ligne un vrai joueur, et dans le clicker tu bâtis un empire avec tes pompes."],
        "tour6_kop": ["Bewaar je voortgang", "Keep your progress", "Garde ta progression"],
        "tour6_tekst": ["Zonder account blijft alles op dit apparaat staan. Log in met de knop rechtsboven en je voortgang gaat mee naar je telefoon en je laptop.", "Without an account everything stays on this device. Sign in with the button top right and your progress follows you to your phone and laptop.", "Sans compte, tout reste sur cet appareil. Connecte-toi avec le bouton en haut à droite et ta progression te suit partout."],
        "tour_again": ["Rondleiding opnieuw", "Show the tour again", "Revoir la visite"],
        "loading": ["Even geduld…", "One moment…", "Un instant…"],
        "loading_slow": ["Dit kan even duren op een trage verbinding.", "This can take a while on a slow connection.", "Cela peut prendre du temps avec une connexion lente."],
        "signing_in": ["Inloggen…", "Signing in…", "Connexion…"],
        "signing_up": ["Account maken…", "Creating your account…", "Création du compte…"],
        "loading_saved": ["Je voortgang ophalen…", "Fetching your progress…", "Récupération de ta progression…"],
        "loading_camera": ["De camera wordt gestart…", "Starting the camera…", "Démarrage de la caméra…"],
        "loading_model": ["De herkenning wordt geladen…", "Loading the tracker…", "Chargement du suivi…"],
        "leaderboard": ["Klassement", "Leaderboard", "Classement"],
        "lb_loading": ["Klassement ophalen…", "Loading the leaderboard…", "Chargement du classement…"],
        "lb_empty": ["Nog niemand heeft push-ups gedaan. Wees de eerste.", "Nobody has done any push-ups yet. Be the first.", "Personne n'a encore fait de pompes. Sois le premier."],
        "lb_failed": ["Klassement ophalen mislukt.", "Could not load the leaderboard.", "Échec du chargement du classement."],
        "lb_you": ["jij", "you", "toi"],
        "lb_need_account": ["Maak een account om in het klassement te komen.", "Create an account to appear on the leaderboard.", "Crée un compte pour apparaître au classement."],
        "name_label": ["Je naam", "Your name", "Ton nom"],
        "name_hint": ["Kies een naam", "Pick a name", "Choisis un nom"],
        "name_save": ["Naam opslaan", "Save name", "Enregistrer le nom"],
        "name_saved": ["Naam opgeslagen.", "Name saved.", "Nom enregistré."],
        "name_private": ["Je e-mailadres komt nooit in het klassement.", "Your email never appears on the leaderboard.", "Ton e-mail n'apparaît jamais au classement."],
        "name_local": ["Maak een account om met deze naam in het klassement te komen.", "Create an account to appear under this name on the leaderboard.", "Crée un compte pour apparaître sous ce nom au classement."],
        "mode_online": ["Online", "Online", "En ligne"],
        "mode_online_sub": ["Zestig seconden tegen een echte speler", "Sixty seconds against a real player", "Soixante secondes contre un vrai joueur"],
        "ol_sub": ["Zestig seconden tegen iemand die nu ook aan het spelen is. Wie de meeste push-ups doet, wint.", "Sixty seconds against someone who is playing right now. Most push-ups wins.", "Soixante secondes contre quelqu'un qui joue en ce moment. Le plus de pompes l'emporte."],
        "ol_need_account": ["Online speel je op naam, dus hiervoor heb je een account nodig.", "Online play uses your name, so you need an account for this.", "En ligne, tu joues sous ton nom : il te faut donc un compte."],
        "ol_open_account": ["Account openen", "Open account", "Ouvrir le compte"],
        "ol_name_label": ["Je naam", "Your name", "Ton nom"],
        "ol_record": ["{0} gewonnen · {1} verloren", "{0} won · {1} lost", "{0} gagnés · {1} perdus"],
        "ol_players": ["{0} spelers actief", "{0} players active", "{0} joueurs actifs"],
        "ol_find": ["ZOEK TEGENSTANDER", "FIND OPPONENT", "CHERCHER UN ADVERSAIRE"],
        "ol_friend": ["Tegen een vriend spelen", "Play against a friend", "Jouer contre un ami"],
        "ol_make_code": ["Maak een code", "Create a code", "Créer un code"],
        "ol_code": ["Code", "Code", "Code"],
        "ol_join": ["Meedoen", "Join", "Rejoindre"],
        "ol_joining": ["Meedoen…", "Joining…", "On te connecte…"],
        "ol_searching": ["Zoeken naar een tegenstander…", "Looking for an opponent…", "Recherche d'un adversaire…"],
        "ol_waiting_friend": ["Wachten op je vriend", "Waiting for your friend", "En attente de ton ami"],
        "ol_code_share": ["Geef deze code door. Zodra je vriend hem invult, beginnen jullie samen.", "Share this code. As soon as your friend enters it, you start together.", "Donne ce code à ton ami : dès qu'il le saisit, vous commencez ensemble."],
        "ol_nobody": ["Nu even niemand te vinden. Probeer het zo nog eens, of speel met een code tegen een vriend.", "Nobody around right now. Try again in a bit, or use a code to play a friend.", "Personne pour l'instant. Réessaie tout à l'heure, ou joue contre un ami avec un code."],
        "ol_bad_code": ["Die code doet het niet. Misschien is hij verlopen of al gebruikt.", "That code doesn't work. It may have expired or been used already.", "Ce code ne marche pas. Il a peut-être expiré ou déjà servi."],
        "ol_offline": ["Geen verbinding met de andere speler.", "No connection to the other player.", "Pas de connexion avec l'autre joueur."],
        "ol_versus": ["tegen {0}", "against {0}", "contre {0}"],
        "ol_give_up": ["Opgeven", "Give up", "Abandonner"],
        "ol_win_by_leave": ["GEWONNEN", "YOU WIN", "GAGNÉ"],
        "ol_draw": ["GELIJKSPEL", "A DRAW", "ÉGALITÉ"],
        "ol_player_1": ["{0} speler actief", "{0} player active", "{0} joueur actif"],
        "mode_klik": ["Clicker", "Clicker", "Clicker"],
        "mode_klik_sub": ["Je push-ups blijven doortellen", "Your push-ups keep counting", "Tes pompes continuent de compter"],
        "klik_kop": ["push-ups", "push-ups", "pompes"],
        "klik_per_sec": ["{0} per seconde", "{0} per second", "{0} par seconde"],
        "klik_per_rep": ["{0} per push-up", "{0} per push-up", "{0} par pompe"],
        "klik_helpers": ["Helpers", "Helpers", "Aides"],
        "klik_upgrades": ["Upgrades", "Upgrades", "Améliorations"],
        "klik_winkel": ["Winkel", "Shop", "Boutique"],
        "klik_crates": ["Crates", "Crates", "Caisses"],
        "inv_titel": ["Inventaris", "Inventory", "Inventaire"],
        "inv_sec_titels": ["Titels", "Titles", "Titres"],
        "inv_sec_iconen": ["Iconen", "Icons", "Icônes"],
        "inv_sec_kleuren": ["Naamkleuren", "Name colors", "Couleurs de nom"],
        "krat_hout": ["Houten krat", "Wooden crate", "Caisse en bois"],
        "krat_hout_uit": ["Meestal iets gewoons, soms iets zeldzaams.", "Usually something common, sometimes rare.", "Souvent un objet commun, parfois rare."],
        "krat_zilver": ["Zilveren krat", "Silver crate", "Caisse en argent"],
        "krat_zilver_uit": ["Goede kans op iets zeldzaams.", "A good chance of something rare.", "Bonne chance d'objet rare."],
        "krat_goud": ["Gouden krat", "Golden crate", "Caisse en or"],
        "krat_goud_uit": ["Grote kans op zeldzaam of episch.", "A big chance of rare or epic.", "Grande chance de rare ou épique."],
        "graad_1": ["Gewoon", "Common", "Commun"],
        "graad_2": ["Zeldzaam", "Rare", "Rare"],
        "graad_3": ["Episch", "Epic", "Épique"],
        "buit_nieuw": ["NIEUW", "NEW", "NOUVEAU"],
        "buit_dubbel": ["Dubbel — je krijgt {0} push-ups terug", "Duplicate — you get {0} push-ups back", "Doublon — tu récupères {0} pompes"],
        "cos_vroegevogel": ["De Vroege Vogel", "The Early Bird", "Le Lève-Tôt"],
        "cos_doorzetter": ["De Doorzetter", "The Grinder", "Le Persévérant"],
        "cos_vloerveger": ["De Vloerveger", "The Floor Sweeper", "Le Balayeur"],
        "cos_nachtuil": ["De Nachtuil", "The Night Owl", "Le Noctambule"],
        "cos_orkenschrik": ["Orkenschrik", "Orc's Bane", "Terreur des Orcs"],
        "cos_bossenjager": ["Bossenjager", "Boss Hunter", "Chasseur de Boss"],
        "cos_ijzerenborst": ["IJzeren Borst", "Iron Chest", "Torse de Fer"],
        "cos_combokoning": ["Combokoning", "Combo King", "Roi du Combo"],
        "cos_demachine": ["De Machine", "The Machine", "La Machine"],
        "cos_onverwoestbaar": ["De Onverwoestbare", "The Unbreakable", "L'Indestructible"],
        "cos_goud": ["Goud", "Gold", "Or"],
        "cos_gras": ["Gras", "Grass", "Herbe"],
        "cos_lucht": ["Lucht", "Sky", "Ciel"],
        "cos_roze": ["Roze", "Pink", "Rose"],
        "cos_paars": ["Paars", "Purple", "Violet"],
        "cos_vuur": ["Vuur", "Fire", "Feu"],
        "cos_bloed": ["Bloed", "Blood", "Sang"],
        "cos_ijs": ["IJs", "Ice", "Glace"],
        "klik_leeg_helpers": ["Doe push-ups. Bij vijfentwintig kun je je eerste helper kopen.", "Do push-ups. At twenty-five you can buy your first helper.", "Fais des pompes. À vingt-cinq, tu peux acheter ta première aide."],
        "klik_leeg_upgrades": ["Nog niets te verbeteren. Koop eerst helpers, of blijf tikken.", "Nothing to improve yet. Buy helpers first, or keep tapping.", "Rien à améliorer pour l'instant. Achète des aides ou continue à taper."],
        "klik_weg": ["Terwijl je weg was: +{0}", "While you were gone: +{0}", "Pendant ton absence : +{0}"],
        "klik_uitleg": ["Alleen echte push-ups tellen. Die uit de arena, het duel en online tellen hier ook mee.", "Only real push-ups count. The ones from the arena, the duel and online count here too.", "Seules les vraies pompes comptent. Celles de l'arène, du duel et du jeu en ligne comptent aussi ici."],
        "klik_bezit": ["je hebt er {0}", "you own {0}", "tu en as {0}"],
        "klik_gekocht": ["Gekocht!", "Bought!", "Acheté !"],
        "klik_actief": ["{0} · nog {1}", "{0} · {1} left", "{0} · encore {1}"],
        "klik_gouden": ["Gouden push-up!", "Golden push-up!", "Pompe en or !"],
        "klik_gouden_woede": ["Woede! Zeven keer zoveel, {0} seconden lang.", "Frenzy! Seven times as much for {0} seconds.", "Fureur ! Sept fois plus pendant {0} secondes."],
        "klik_gouden_buit": ["+{0} push-ups in één klap.", "+{0} push-ups all at once.", "+{0} pompes d'un coup."],
        "up_helper": ["{0} verdubbelen", "Double {0}", "Doubler {0}"],
        "up_helper_uit": ["{0} levert twee keer zoveel op.", "{0} pays out twice as much.", "{0} rapporte deux fois plus."],
        "up_rep": ["Meer kracht", "More strength", "Plus de force"],
        "up_rep_uit": ["Elke echte push-up levert twee keer zoveel op.", "Every real push-up pays out twice as much.", "Chaque vraie pompe rapporte deux fois plus."],
        "koop_xp2": ["Dubbele XP", "Double XP", "XP double"],
        "koop_xp2_uit": ["Dertig minuten lang twee keer zoveel XP in de arena, het duel en online.", "For thirty minutes, double XP in the arena, the duel and online.", "Pendant trente minutes, deux fois plus d'XP en arène, en duel et en ligne."],
        "koop_punt2": ["Dubbele push-ups", "Double push-ups", "Pompes doubles"],
        "koop_punt2_uit": ["Tien minuten lang levert alles twee keer zoveel op.", "For ten minutes everything pays out twice as much.", "Pendant dix minutes, tout rapporte deux fois plus."],
        "koop_woede": ["Sprint", "Sprint", "Sprint"],
        "koop_woede_uit": ["Eén minuut lang telt elke push-up zeven keer. Ga liggen.", "For one minute every push-up counts seven times. Get down.", "Pendant une minute, chaque pompe compte sept fois. Au sol."],
        "koop_voer": ["Eiwitreep", "Protein bar", "Barre protéinée"],
        "koop_voer_uit": ["Je volgende {0} echte push-ups leveren vijf keer zoveel op.", "Your next {0} real push-ups pay out five times as much.", "Tes {0} prochaines vraies pompes rapportent cinq fois plus."],
        "koop_voer_rest": ["nog {0} push-ups", "{0} push-ups left", "encore {0} pompes"],
        "klik_te_duur": ["Nog niet genoeg push-ups.", "Not enough push-ups yet.", "Pas encore assez de pompes."],
        "klik_per_uur": ["{0} per uur", "{0} per hour", "{0} par heure"],
        "klik_train": ["Trainen", "Train", "S'entraîner"],
        "klik_train_stop": ["Stoppen", "Stop", "Arrêter"],
        "klik_train_uitleg": ["Tik op de knop, ga liggen, en de camera telt elke push-up.", "Tap the button, get down, and the camera counts every push-up.", "Tape sur le bouton, mets-toi au sol, la caméra compte chaque pompe."],
        "klik_bezig": ["Bezig met trainen", "Training", "Entraînement en cours"],
        "klik_slot": ["???", "???", "???"],
        "klik_slot_uit": ["Je ziet wat dit is zodra je er genoeg voor hebt.", "You will see what this is once you can afford it.", "Tu verras ce que c'est dès que tu pourras te le payer."],
        "up_helper_uit2": ["{0} gaat van {1} naar {2}.", "{0} goes from {1} to {2}.", "{0} passe de {1} à {2}."],
        "up_rep_uit2": ["Elke push-up gaat van {0} naar {1}.", "Every push-up goes from {0} to {1}.", "Chaque pompe passe de {0} à {1}."],
        "tech_warm": ["Warming-up", "Warm-up", "Échauffement"],
        "tech_adem": ["Ademhaling", "Breathing", "Respiration"],
        "tech_houding": ["Houding", "Posture", "Posture"],
        "tech_ritme": ["Vast ritme", "Steady rhythm", "Rythme régulier"],
        "tech_grip": ["Grip", "Grip", "Prise"],
        "tech_coach": ["Coach", "Coach", "Coach"],
        "klik_geeft": ["Levert {0} op.", "Pays out {0}.", "Rapporte {0}."],
        "klik_samen": ["samen {0}", "{0} together", "{0} au total"],
        "klik_nieuw": ["De clicker is opnieuw begonnen: de balans is helemaal omgegooid.", "The clicker has started over: the balance has been completely reworked.", "Le clicker repart de zéro : l'équilibrage a été entièrement revu."],
        "helper_maat": ["Trainingsmaatje", "Training partner", "Partenaire d'entraînement"],
        "helper_maat_uit": ["Iemand die met je meedoet.", "Someone who joins in.", "Quelqu'un qui s'entraîne avec toi."],
        "helper_groep": ["Trainingsgroep", "Training group", "Groupe d'entraînement"],
        "helper_groep_uit": ["Een vaste groep die elke week afspreekt.", "A regular group that meets every week.", "Un groupe qui se retrouve chaque semaine."],
        "helper_zaal": ["Sportzaal", "Sports hall", "Salle de sport"],
        "helper_zaal_uit": ["Matten op de vloer en ruimte genoeg.", "Mats on the floor and room to spare.", "Des tapis au sol et de la place."],
        "helper_school": ["Sportschool", "Gym", "Salle de musculation"],
        "helper_school_uit": ["Vierentwintig uur open, nooit leeg.", "Open around the clock, never empty.", "Ouverte jour et nuit, jamais vide."],
        "helper_club": ["Sportvereniging", "Sports club", "Club sportif"],
        "helper_club_uit": ["Alle leden doen mee.", "Every member joins in.", "Tous les membres s'y mettent."],
        "helper_stadion": ["Stadion", "Stadium", "Stade"],
        "helper_stadion_uit": ["Uitverkocht. Iedereen ligt op de grond.", "Sold out. Everyone is on the floor.", "Complet. Tout le monde est au sol."],
        "helper_buurt": ["De hele buurt", "The whole neighbourhood", "Tout le quartier"],
        "helper_buurt_uit": ["Van de ene straat tot de andere.", "From one street to the next.", "D'une rue à l'autre."],
        "helper_stad": ["De hele stad", "The whole city", "Toute la ville"],
        "helper_stad_uit": ["Overal wordt er hardop geteld.", "All over town people are counting out loud.", "Partout, on compte à voix haute."],
        "helper_provincie": ["De hele provincie", "The whole region", "Toute la région"],
        "helper_provincie_uit": ["Elk dorp doet mee.", "Every village joins in.", "Chaque village participe."],
        "helper_land": ["Het hele land", "The whole country", "Tout le pays"],
        "helper_land_uit": ["Van de kust tot de grens.", "From the coast to the border.", "De la côte à la frontière."],
        "helper_werelddeel": ["Het hele werelddeel", "The whole continent", "Tout le continent"],
        "helper_werelddeel_uit": ["Miljoenen mensen tegelijk.", "Millions of people at once.", "Des millions de personnes à la fois."],
        "helper_wereld": ["De hele wereld", "The whole world", "Le monde entier"],
        "helper_wereld_uit": ["Iedereen, overal, op hetzelfde moment.", "Everyone, everywhere, at the same time.", "Tout le monde, partout, en même temps."],
        "foto_label": ["Je foto", "Your photo", "Ta photo"],
        "foto_kies": ["Foto kiezen", "Choose photo", "Choisir une photo"],
        "foto_weg": ["Foto weghalen", "Remove photo", "Retirer la photo"],
        "foto_hint": ["Tik op de cirkel om een foto te kiezen of er een te maken. Plakken werkt ook.", "Tap the circle to choose or take a photo. Pasting works too.", "Touche le cercle pour choisir ou prendre une photo. Le collage marche aussi."],
        "foto_prive": ["Iedereen met een account ziet je foto in het klassement.", "Everyone with an account sees your photo in the leaderboard.", "Toute personne ayant un compte voit ta photo au classement."],
        "foto_lokaal": ["Zonder account blijft je foto op dit apparaat.", "Without an account your photo stays on this device.", "Sans compte, ta photo reste sur cet appareil."],
        "foto_klaar": ["Foto opgeslagen.", "Photo saved.", "Photo enregistrée."],
        "foto_fout": ["Dat plaatje lukte niet. Probeer een andere foto.", "That image did not work. Try another photo.", "Cette image n'a pas fonctionné. Essaie une autre photo."],
        "foto_bezig": ["Foto verkleinen…", "Resizing photo…", "Réduction de la photo…"],
        "naam_geweigerd": ["Die naam kan niet. Kies er een zonder scheldwoorden.", "That name is not allowed. Pick one without slurs.", "Ce nom n'est pas autorisé. Choisis-en un sans insultes."],
        "meld_knop": ["Deze speler melden", "Report this player", "Signaler ce joueur"],
        "meld_klaar": ["Gemeld. Bij drie meldingen verdwijnt de foto uit het klassement.", "Reported. After three reports the photo disappears from the leaderboard.", "Signalé. Après trois signalements, la photo disparaît du classement."],
        "meld_verborgen": ["Gemeld. Deze foto is nu voor iedereen verborgen.", "Reported. This photo is now hidden for everyone.", "Signalé. Cette photo est maintenant masquée pour tout le monde."],
        "meld_account": ["Log in om iemand te kunnen melden.", "Sign in to report someone.", "Connecte-toi pour signaler quelqu'un."],
        "meld_fout": ["Melden lukte niet.", "Reporting failed.", "Le signalement a échoué."],
        "foto_regels": ["Geen naaktbeelden of aanstootgevende foto's.", "No nudity or offensive pictures.", "Pas de nudité ni d'images offensantes."],
        "les1": ["Dit is je arena. Tik op VECHTEN om het gevecht te openen.", "This is your arena. Tap FIGHT to open the battle.", "Voici ton arène. Touche COMBATTRE pour ouvrir le combat."],
        "les2": ["Elke push-up is een klap tegen het monster. Ga liggen en doe er één!", "Every push-up is a hit against the monster. Get down and do one!", "Chaque pompe frappe le monstre. Mets-toi en position et fais-en une !"],
        "les3": ["Deze stippen zijn de vijanden van deze arena; elke tiende is een boss. Versla nu je eerste ork — nog een paar push-ups en hij ligt om!", "These dots are this arena's enemies; every tenth is a boss. Now defeat your first orc — a few more push-ups and it's down!", "Ces points sont les ennemis de cette arène ; chaque dixième est un boss. Bats ton premier orc — encore quelques pompes et il tombe !"],
        "les_knop": ["Begrepen", "Got it", "Compris"],
        "les_skip": ["Overslaan", "Skip", "Passer"],
        "geluid_label": ["Geluid", "Sound", "Son"],
        "muziek_label": ["Muziek", "Music", "Musique"],
        "geluid_uit": ["uit", "off", "coupé"],
        "geluid_uitleg": ["De tonen bij elke push-up en de klikjes in de menu's.", "The tone on every push-up and the clicks in the menus.", "Le son de chaque pompe et les clics dans les menus."],
        "muziek_uitleg": ["Een rustige lus op de achtergrond.", "A calm loop in the background.", "Une boucle tranquille en fond."],
        "menu_meer": ["Meer", "More", "Plus"],
        "quest_stand": ["{0} van {1}", "{0} of {1}", "{0} sur {1}"],
        "sign_out_zeker": ["Zeker weten? Tik nog een keer.", "Are you sure? Tap once more.", "Tu es sûr ? Touche encore une fois."],
        "les4": ["Goed gedaan! Klaar met trainen? Met deze knop sluit je het gevecht. Tik erop.", "Well done! Finished training? This button closes the fight. Tap it.", "Bien joué ! Fini l'entraînement ? Ce bouton ferme le combat. Touche-le."],
        "les5": ["Hier zitten de spelmodi. Open het menu.", "The game modes live here. Open the menu.", "Les modes de jeu sont ici. Ouvre le menu."],
        "les6": ["Duel: zestig seconden tegen een tegenstander. Jij kiest vooraf hoe zwaar hij is.", "Duel: sixty seconds against an opponent. You choose beforehand how tough it is.", "Duel : soixante secondes contre un adversaire. Tu choisis sa force à l'avance."],
        "les7": ["Online: zestig seconden tegen een echt mens. Hiervoor heb je een account nodig.", "Online: sixty seconds against a real person. You need an account for this.", "En ligne : soixante secondes contre une vraie personne. Il te faut un compte."],
        "les8": ["De clicker: elke echte push-up is een munt. Koop er helpers, techniek en crates van.", "The clicker: every real push-up is a coin. Spend them on helpers, technique and crates.", "Le clicker : chaque vraie pompe est une pièce. Achète des aides, de la technique et des caisses."],
        "les9": ["En dit zijn je opdrachten: elke dag drie en elke week twee, met XP en push-ups als beloning. Dat is alles — trainen maar!", "And these are your quests: three a day and two a week, with XP and push-ups as rewards. That's everything — get training!", "Et voici tes missions : trois par jour et deux par semaine, avec XP et pompes en récompense. C'est tout — à toi de jouer !"],
        "trofee_nog": ["nog niet", "not yet", "pas encore"],
    ]

    /// Haalt een tekst op en vult {0}, {1}, … met de meegegeven waarden.
    static func text(_ key: Tk, _ lang: Lang, _ args: [String] = []) -> String {
        guard let row = table[key.rawValue] else { return key.rawValue }
        let index = Lang.allCases.firstIndex(of: lang) ?? 0
        var result = index < row.count ? row[index] : row[0]
        for (i, arg) in args.enumerated() {
            result = result.replacingOccurrences(of: "{\(i)}", with: arg)
        }
        return result
    }
}
