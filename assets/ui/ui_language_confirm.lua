--[[---------------------------------------------------------------------------
	Chocolatier Three: Decadence by Design Reforged (Language Confirmation)
	Copyright (c) 2026 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Dialog Arguments
-------------------------------------------------------------------------------

local langCode = gDialogTable.langCode or "en"
local langKey = gDialogTable.langKey or "lang_en"
local langName = gDialogTable.langName or GetString(langKey)
local nativeName = gDialogTable.nativeName or langName
local langFont = gDialogTable.langFont or uiFontName

if not langName or langName == "#####" or langName == langKey then
	langName = nativeName or langCode
end

if not nativeName or nativeName == "#####" then
	nativeName = langName
end

-------------------------------------------------------------------------------
-- Localized Confirmation Copy
-------------------------------------------------------------------------------
-- The current-language question and restart note come from XML, because they
-- should be rendered in the language currently loaded into memory.
--
-- The selected-language question and restart note live here, because the target
-- language's XML is not loaded until the next launch.

local selectedLanguageConfirm =
{
	en		= "Switch language to English?",
	fr		= "Passer la langue en français ?",
	de		= "Sprache auf Deutsch umstellen?",
	nl		= "Taal wijzigen naar Nederlands?",
	it		= "Cambiare lingua in italiano?",
	es_eu	= "¿Cambiar el idioma a español latinoamericano?",
	es_lt	= "¿Cambiar el idioma a español de España?",
	pt_eu	= "Mudar o idioma para português de Portugal?",
	pt_br	= "Mudar o idioma para português do Brasil?",
	ca		= "Canviar l’idioma al català?",
	gl		= "Cambiar o idioma ao galego?",
	eu		= "Hizkuntza euskarara aldatu?",
	ga		= "Athraigh an teanga go Gaeilge?",
	cy		= "Newid yr iaith i’r Gymraeg?",
	mt		= "Tibdel il-lingwa għall-Malti?",
	pl		= "Zmienić język na polski?",
	cz		= "Změnit jazyk na češtinu?",
	sk		= "Zmeniť jazyk na slovenčinu?",
	hu		= "Átváltasz magyar nyelvre?",
	ro		= "Schimbi limba în română?",
	hr		= "Promijeniti jezik na hrvatski?",
	sr		= "Променити језик на српски?",
	sl		= "Spremeniti jezik v slovenščino?",
	bg		= "Да се смени ли езикът на български?",
	mk		= "Да се смени јазикот на македонски?",
	lt		= "Pakeisti kalbą į lietuvių?",
	lv		= "Mainīt valodu uz latviešu?",
	et		= "Kas muuta keel eesti keeleks?",
	da		= "Skift sprog til dansk?",
	is		= "Skipta yfir í íslensku?",
	no		= "Bytte språk til norsk?",
	sv		= "Byta språk till svenska?",
	fi		= "Vaihdetaanko kieleksi suomi?",
	ru		= "Переключить язык на русский?",
	uk		= "Змінити мову на українську?",
	be		= "Пераключыць мову на беларускую?",
	el		= "Αλλαγή γλώσσας στα ελληνικά;",
	tr		= "Dili Türkçe olarak değiştirmek istiyor musun?",
	ka		= "გსურთ ენის ქართულად შეცვლა?",
	hy		= "Փոխե՞լ լեզուն հայերենի։",
	az		= "Dili azərbaycancaya dəyişmək istəyirsiniz?",
	am		= "ቋንቋውን ወደ አማርኛ መቀየር?",
	yo		= "Ṣe o fẹ́ yí èdè padà sí Yorùbá?",
	ig		= "Ị chọrọ ịgbanwe asụsụ gaa n’Igbo?",
	sw		= "Ungependa kubadilisha lugha kuwa Kiswahili?",
	af		= "Verander taal na Afrikaans?",
	zu		= "Shintsha ulimi uye esiZulwini?",
	mg		= "Hanova ny fiteny ho Malagasy?",
	he		= "להחליף את השפה לעברית?",
	ar		= "هل تريد تغيير اللغة إلى العربية؟",
	fa		= "زبان به فارسی تغییر کند؟",
	hi		= "भाषा हिन्दी में बदलें?",
	ur		= "زبان اردو میں تبدیل کریں؟",
	bn		= "ভাষা কি বাংলায় পরিবর্তন করবেন?",
	pa		= "ਕੀ ਭਾਸ਼ਾ ਪੰਜਾਬੀ ਵਿੱਚ ਬਦਲਣੀ ਹੈ?",
	gu		= "ભાષા ગુજરાતી કરવી છે?",
	mr		= "भाषा मराठीत बदलायची?",
	ta		= "மொழியை தமிழாக மாற்றவா?",
	te		= "భాషను తెలుగుకు మార్చాలా?",
	kn		= "ಭಾಷೆಯನ್ನು ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಬೇಕೇ?",
	ml		= "ഭാഷ മലയാളത്തിലേക്ക് മാറ്റണോ?",
	kk		= "Тілді қазақ тіліне ауыстыру керек пе?",
	mn		= "Хэлийг монгол болгож өөрчлөх үү?",
	zhs		= "要将语言切换为简体中文吗？",
	zht		= "要將語言切換為繁體中文嗎？",
	ko		= "언어를 한국어로 변경할까요?",
	ja		= "言語を日本語に変更しますか？",
	th		= "เปลี่ยนภาษาเป็นภาษาไทยหรือไม่?",
	lo		= "ປ່ຽນພາສາເປັນລາວບໍ?",
	vi		= "Chuyển ngôn ngữ sang tiếng Việt?",
	km		= "ប្ដូរភាសាទៅជាខ្មែរឬ?",
	my		= "ဘာသာစကားကို မြန်မာဘာသာသို့ ပြောင်းမလား?",
	id		= "Ubah bahasa ke Bahasa Indonesia?",
	ms		= "Tukar bahasa kepada Bahasa Melayu?",
	tl		= "Palitan ang wika sa Filipino?",
	mi		= "Hurihia te reo ki te reo Māori?",
}

local selectedRestart =
{
	en		= "You will need to restart the game before the new language is fully applied.",
	fr		= "Vous devrez redémarrer le jeu pour appliquer complètement la nouvelle langue.",
	de		= "Du musst das Spiel neu starten, damit die neue Sprache vollständig angewendet wird.",
	nl		= "Je moet het spel opnieuw starten voordat de nieuwe taal volledig wordt toegepast.",
	it		= "Dovrai riavviare il gioco prima che la nuova lingua venga applicata completamente.",
	es_eu	= "Tendrás que reiniciar el juego para aplicar completamente el nuevo idioma.",
	es_lt	= "Tendrás que reiniciar el juego para aplicar completamente el nuevo idioma.",
	pt_eu	= "Terá de reiniciar o jogo antes que o novo idioma seja aplicado por completo.",
	pt_br	= "Você precisará reiniciar o jogo para que o novo idioma seja aplicado por completo.",
	ca		= "Hauràs de reiniciar el joc perquè el nou idioma s’apliqui completament.",
	gl		= "Terás que reiniciar o xogo para que o novo idioma se aplique completamente.",
	eu		= "Jokoa berrabiarazi beharko duzu hizkuntza berria guztiz aplikatzeko.",
	ga		= "Beidh ort an cluiche a atosú sula gcuirfear an teanga nua i bhfeidhm go hiomlán.",
	cy		= "Bydd angen ailgychwyn y gêm cyn i’r iaith newydd gael ei chymhwyso’n llawn.",
	mt		= "Ikollok terġa’ tibda l-logħba biex il-lingwa l-ġdida tapplika kompletament.",
	pl		= "Musisz ponownie uruchomić grę, aby nowy język został w pełni zastosowany.",
	cz		= "Aby se nový jazyk plně použil, bude třeba hru restartovat.",
	sk		= "Hru bude potrebné reštartovať, aby sa nový jazyk úplne použil.",
	hu		= "Az új nyelv teljes alkalmazásához újra kell indítanod a játékot.",
	ro		= "Va trebui să repornești jocul pentru ca noua limbă să fie aplicată complet.",
	hr		= "Morat ćeš ponovno pokrenuti igru kako bi se novi jezik u potpunosti primijenio.",
	sr		= "Мораћете поново да покренете игру да би се нови језик у потпуности применио.",
	sl		= "Igro bo treba znova zagnati, da bo novi jezik v celoti uporabljen.",
	bg		= "Ще трябва да рестартирате играта, за да се приложи напълно новият език.",
	mk		= "Ќе треба повторно да ја стартувате играта за новиот јазик целосно да се примени.",
	lt		= "Reikės paleisti žaidimą iš naujo, kad nauja kalba būtų visiškai pritaikyta.",
	lv		= "Spēle būs jārestartē, lai jaunā valoda tiktu pilnībā lietota.",
	et		= "Uue keele täielikuks rakendamiseks tuleb mäng taaskäivitada.",
	da		= "Du skal genstarte spillet, før det nye sprog anvendes fuldt ud.",
	is		= "Þú þarft að endurræsa leikinn áður en nýja tungumálið virkar að fullu.",
	no		= "Du må starte spillet på nytt før det nye språket brukes fullt ut.",
	sv		= "Du måste starta om spelet innan det nya språket används fullt ut.",
	fi		= "Peli täytyy käynnistää uudelleen, jotta uusi kieli otetaan kokonaan käyttöön.",
	ru		= "Чтобы новый язык полностью применился, нужно перезапустить игру.",
	uk		= "Потрібно перезапустити гру, щоб нова мова застосувалася повністю.",
	be		= "Трэба перазапусціць гульню, каб новая мова ўжылася цалкам.",
	el		= "Θα χρειαστεί να επανεκκινήσεις το παιχνίδι για να εφαρμοστεί πλήρως η νέα γλώσσα.",
	tr		= "Yeni dilin tamamen uygulanması için oyunu yeniden başlatman gerekecek.",
	ka		= "ახალი ენის სრულად გამოსაყენებლად თამაშის ხელახლა გაშვება დაგჭირდებათ.",
	hy		= "Նոր լեզուն ամբողջությամբ կիրառելու համար պետք է վերագործարկեք խաղը։",
	az		= "Yeni dilin tam tətbiq olunması üçün oyunu yenidən başlatmalısınız.",
	am		= "አዲሱ ቋንቋ ሙሉ በሙሉ እንዲተገበር ጨዋታውን እንደገና መጀመር ያስፈልግዎታል።",
	yo		= "O ní láti tún eré náà bẹ̀rẹ̀ kí èdè tuntun lè ṣiṣẹ́ pátápátá.",
	ig		= "Ị ga-amalite egwuregwu ahụ ọzọ ka asụsụ ọhụrụ ahụ wee rụọ ọrụ nke ọma.",
	sw		= "Utahitaji kuanzisha mchezo upya kabla lugha mpya haijatumika kikamilifu.",
	af		= "Jy sal die speletjie moet herbegin voordat die nuwe taal volledig toegepas word.",
	zu		= "Kuzodingeka uqale kabusha umdlalo ukuze ulimi olusha lusetshenziswe ngokuphelele.",
	mg		= "Mila averinao atomboka ny lalao vao mihatra tanteraka ilay fiteny vaovao.",
	he		= "יהיה עליך להפעיל מחדש את המשחק לפני שהשפה החדשה תוחל במלואה.",
	ar		= "ستحتاج إلى إعادة تشغيل اللعبة قبل تطبيق اللغة الجديدة بالكامل.",
	fa		= "برای اعمال کامل زبان جدید باید بازی را دوباره راه‌اندازی کنید.",
	hi		= "नई भाषा पूरी तरह लागू होने से पहले आपको खेल को फिर से शुरू करना होगा.",
	ur		= "نئی زبان مکمل طور پر لاگو ہونے سے پہلے آپ کو گیم دوبارہ شروع کرنا ہوگی۔",
	bn		= "নতুন ভাষা সম্পূর্ণভাবে প্রয়োগ করতে আপনাকে গেমটি পুনরায় চালু করতে হবে।",
	pa		= "ਨਵੀਂ ਭਾਸ਼ਾ ਪੂਰੀ ਤਰ੍ਹਾਂ ਲਾਗੂ ਹੋਣ ਤੋਂ ਪਹਿਲਾਂ ਤੁਹਾਨੂੰ ਗੇਮ ਮੁੜ ਸ਼ੁਰੂ ਕਰਨੀ ਪਵੇਗੀ।",
	gu		= "નવી ભાષા સંપૂર્ણ રીતે લાગુ થાય તે પહેલાં તમારે રમત ફરી શરૂ કરવી પડશે.",
	mr		= "नवीन भाषा पूर्णपणे लागू होण्यासाठी तुम्हाला गेम पुन्हा सुरू करावा लागेल.",
	ta		= "புதிய மொழி முழுமையாக அமலாக விளையாட்டை மறுதொடக்கம் செய்ய வேண்டும்.",
	te		= "కొత్త భాష పూర్తిగా అమలులోకి రావాలంటే ఆటను మళ్లీ ప్రారంభించాలి.",
	kn		= "ಹೊಸ ಭಾಷೆ ಸಂಪೂರ್ಣವಾಗಿ ಅನ್ವಯಿಸಲು ನೀವು ಆಟವನ್ನು ಮರುಪ್ರಾರಂಭಿಸಬೇಕು.",
	ml		= "പുതിയ ഭാഷ പൂർണ്ണമായി പ്രയോഗിക്കാനായി ഗെയിം വീണ്ടും ആരംഭിക്കണം.",
	kk		= "Жаңа тіл толық қолданылуы үшін ойынды қайта іске қосу керек.",
	mn		= "Шинэ хэлийг бүрэн хэрэглэхийн тулд тоглоомыг дахин эхлүүлэх шаардлагатай.",
	zhs		= "你需要重新启动游戏，新的语言才会完全生效。",
	zht		= "你需要重新啟動遊戲，新的語言才會完全生效。",
	ko		= "새 언어를 완전히 적용하려면 게임을 다시 시작해야 합니다.",
	ja		= "新しい言語を完全に適用するには、ゲームを再起動する必要があります。",
	th		= "คุณต้องเริ่มเกมใหม่เพื่อให้ภาษาใหม่มีผลอย่างสมบูรณ์",
	lo		= "ທ່ານຕ້ອງເລີ່ມເກມໃໝ່ເພື່ອໃຫ້ພາສາໃໝ່ມີຜົນຢ່າງສົມບູນ.",
	vi		= "Bạn cần khởi động lại trò chơi để ngôn ngữ mới được áp dụng hoàn toàn.",
	km		= "អ្នកត្រូវចាប់ផ្ដើមហ្គេមឡើងវិញ ដើម្បីឱ្យភាសាថ្មីមានប្រសិទ្ធភាពពេញលេញ។",
	my		= "ဘာသာစကားအသစ် အပြည့်အဝအသုံးပြုနိုင်ရန် ဂိမ်းကို ပြန်လည်စတင်ရန် လိုအပ်သည်။",
	id		= "Kamu perlu memulai ulang game agar bahasa baru diterapkan sepenuhnya.",
	ms		= "Anda perlu memulakan semula permainan supaya bahasa baharu digunakan sepenuhnya.",
	tl		= "Kailangan mong i-restart ang laro bago ganap na mailapat ang bagong wika.",
	mi		= "Me tīmata anō te kēmu kia tino whakamahia te reo hou.",
}

-------------------------------------------------------------------------------
-- Text Helpers
-------------------------------------------------------------------------------

local function SafeGetString(key, fallback)
	local s = GetString(key)
	if not s or s == "#####" or s == key then return fallback end
	return s
end

local currentQuestion = SafeGetString(
	"language_confirm_current",
	"Switch the game language to %s?"
)

local restartNote = SafeGetString(
	"language_confirm_restart",
	"You will need to restart the game before the new language is fully applied."
)

local currentQuestionText = string.format(currentQuestion, langName)
local currentRestartText = restartNote

local selectedQuestionText = selectedLanguageConfirm[langCode] or string.format("Switch language to %s?", nativeName)
local selectedRestartText = selectedRestart[langCode] or restartNote

-------------------------------------------------------------------------------
-- Layout Helpers
-------------------------------------------------------------------------------

local function GetSelectedQuestionFontSize()
	-- Complex scripts need a tiny reduction to avoid clipping in the fixed text box.
	if langCode == "th" or langCode == "lo" or langCode == "km" or langCode == "my" then
		return 20
	end

	if langCode == "hi" or langCode == "ur" or langCode == "bn" or langCode == "pa" or
	   langCode == "gu" or langCode == "mr" or langCode == "ta" or langCode == "te" or
	   langCode == "kn" or langCode == "ml" or langCode == "am" then
		return 20
	end

	if langCode == "ja" or langCode == "zhs" or langCode == "zht" or langCode == "ko" then
		return 19
	end

	return 18
end

local function GetSelectedRestartFontSize()
	if langCode == "th" or langCode == "lo" or langCode == "km" or langCode == "my" then
		return 16
	end

	if langCode == "hi" or langCode == "ur" or langCode == "bn" or langCode == "pa" or
	   langCode == "gu" or langCode == "mr" or langCode == "ta" or langCode == "te" or
	   langCode == "kn" or langCode == "ml" or langCode == "am" then
		return 16
	end

	if langCode == "ja" or langCode == "zhs" or langCode == "zht" or langCode == "ko" then
		return 15
	end

	return 14
end

-------------------------------------------------------------------------------
-- Button Commands
-------------------------------------------------------------------------------

local function ConfirmLanguage()
	DebugOut("UI", string.format("Language confirmation accepted: %s", langCode))
	FadeCloseWindow("language_confirm", "yes")
end

local function CancelLanguage()
	DebugOut("UI", string.format("Language confirmation canceled: %s", langCode))
	FadeCloseWindow("language_confirm", "no")
end

-------------------------------------------------------------------------------
-- UI Construction
-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name = "language_confirm",
		x = 1000, y = kCenter,
		image = "image/popup_back_generic_1",

		SetStyle(C3DialogBodyStyle),

		Text {
			x = 20, y = 30, w = 459, h = 34,
			label = "#" .. GetString("language_confirm"),
			font = { uiFontName, 21, BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		},

		-- Current loaded language block
		Text {
			x = 45, y = 78, w = 410, h = 28,
			label = "#<b>" .. currentQuestionText .. "</b>",
			font = { uiFontName, 18, BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		},

		Text {
			x = 55, y = 98, w = 390, h = 44,
			label = "#" .. currentRestartText,
			font = { uiFontName, 14, BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		},

		-- Selected target language block
		Text {
			x = 45, y = 144, w = 410, h = 32,
			label = "#<b>" .. selectedQuestionText .. "</b>",
			font = { langFont, GetSelectedQuestionFontSize(), BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		},

		Text {
			x = 55, y = 166, w = 390, h = 48,
			label = "#" .. selectedRestartText,
			font = { langFont, GetSelectedRestartFontSize(), BlackColor },
			flags = kVAlignCenter + kHAlignCenter,
		},

		SetStyle(C3ButtonStyle),

		Button {
			x = 83, y = 237, w = 165, h = 50,
			name = "yes",
			label = "#" .. GetString("yes"),
			command = ConfirmLanguage,
			default = true,
			cancel = false,
			
			font = buttonFont,
			flags = kVAlignCenter + kHAlignCenter,
			ty = kCenter - 3,
			tx = kCenter - 1,
			
			graphics = C3ButtonMediumStyle.graphics,
			sound = C3ButtonMediumStyle.sound,
			type = C3ButtonMediumStyle.type,
		},
		
		Button {
			x = 253, y = 237, w = 165, h = 50,
			name = "no",
			label = "#" .. GetString("no"),
			command = CancelLanguage,
			default = false,
			cancel = true,
			
			font = buttonFont,
			flags = kVAlignCenter + kHAlignCenter,
			ty = kCenter - 3,
			tx = kCenter - 1,
			
			graphics = C3ButtonMediumStyle.graphics,
			sound = C3ButtonMediumStyle.sound,
			type = C3ButtonMediumStyle.type,
		},
	}
}

CenterFadeIn("language_confirm")
