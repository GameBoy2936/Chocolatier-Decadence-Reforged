--[[---------------------------------------------------------------------------
	Chocolatier Three Port Data: Travel Routes
	Copyright (c) 2008 Big Splash Games, LLC. All Rights Reserved.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- BAGHDAD
baghdad:DefineRoute { bali }
baghdad:DefineRoute { belize, via=zurich }
baghdad:DefineRoute { bogota, via=zurich }
baghdad:DefineRoute { capetown }
baghdad:DefineRoute { douala }
baghdad:DefineRoute { falklands, via=capetown }
baghdad:DefineRoute { gobidesert }
baghdad:DefineRoute { havana, via=zurich }
baghdad:DefineRoute { kona, via=toronto }
baghdad:DefineRoute { lasvegas, via=zurich }
baghdad:DefineRoute { lima, via=capetown }
baghdad:DefineRoute { mahajanga }
baghdad:DefineRoute { reykjavik }
baghdad:DefineRoute { sanfrancisco, via=zurich }
baghdad:DefineRoute { tangiers }
baghdad:DefineRoute { tokyo }
baghdad:DefineRoute { toronto }
baghdad:DefineRoute { uluru }
baghdad:DefineRoute { wellington }
baghdad:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- BALI
bali:DefineRoute { belize, via=capetown }
bali:DefineRoute { bogota, via=capetown }
bali:DefineRoute { capetown }
bali:DefineRoute { douala }
bali:DefineRoute { falklands, via=capetown }
bali:DefineRoute { gobidesert }
bali:DefineRoute { havana, via=capetown }
bali:DefineRoute { kona, via=capetown }
bali:DefineRoute { lasvegas, via=capetown }
bali:DefineRoute { lima, via=capetown }
bali:DefineRoute { mahajanga }
bali:DefineRoute { reykjavik, via=capetown }
bali:DefineRoute { sanfrancisco, via=capetown }
bali:DefineRoute { tangiers }
bali:DefineRoute { tokyo }
bali:DefineRoute { toronto, via=zurich }
bali:DefineRoute { uluru }
bali:DefineRoute { wellington }
bali:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- BELIZE
belize:DefineRoute { bogota }
belize:DefineRoute { capetown }
belize:DefineRoute { douala }
belize:DefineRoute { falklands }
belize:DefineRoute { gobidesert, via=zurich }
belize:DefineRoute { havana }
belize:DefineRoute { kona }
belize:DefineRoute { lasvegas }
belize:DefineRoute { lima }
belize:DefineRoute { mahajanga }
belize:DefineRoute { reykjavik }
belize:DefineRoute { sanfrancisco }
belize:DefineRoute { tangiers }
belize:DefineRoute { tokyo, via=zurich }
belize:DefineRoute { toronto }
belize:DefineRoute { uluru, via=capetown }
belize:DefineRoute { wellington, via=capetown }
belize:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- BOGOTA
bogota:DefineRoute { capetown }
bogota:DefineRoute { douala }
bogota:DefineRoute { falklands }
bogota:DefineRoute { gobidesert, via=zurich }
bogota:DefineRoute { havana }
bogota:DefineRoute { kona }
bogota:DefineRoute { lasvegas }
bogota:DefineRoute { lima }
bogota:DefineRoute { mahajanga }
bogota:DefineRoute { reykjavik }
bogota:DefineRoute { sanfrancisco }
bogota:DefineRoute { tangiers }
bogota:DefineRoute { tokyo, via=zurich }
bogota:DefineRoute { toronto }
bogota:DefineRoute { uluru, via=capetown }
bogota:DefineRoute { wellington, via=capetown }
bogota:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- CAPETOWN
capetown:DefineRoute { douala }
capetown:DefineRoute { falklands }
capetown:DefineRoute { gobidesert }
capetown:DefineRoute { havana }
capetown:DefineRoute { kona, via=bogota }
capetown:DefineRoute { lasvegas }
capetown:DefineRoute { lima }
capetown:DefineRoute { mahajanga }
capetown:DefineRoute { reykjavik }
capetown:DefineRoute { sanfrancisco }
capetown:DefineRoute { tangiers }
capetown:DefineRoute { tokyo }
capetown:DefineRoute { toronto }
capetown:DefineRoute { uluru }
capetown:DefineRoute { wellington }
capetown:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- DOUALA
douala:DefineRoute { falklands }
douala:DefineRoute { gobidesert }
douala:DefineRoute { havana }
douala:DefineRoute { kona, via=bogota }
douala:DefineRoute { lasvegas }
douala:DefineRoute { lima }
douala:DefineRoute { mahajanga }
douala:DefineRoute { reykjavik }
douala:DefineRoute { sanfrancisco }
douala:DefineRoute { tangiers }
douala:DefineRoute { tokyo }
douala:DefineRoute { toronto }
douala:DefineRoute { uluru }
douala:DefineRoute { wellington }
douala:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- FALKLANDS
falklands:DefineRoute { gobidesert, via=capetown }
falklands:DefineRoute { havana }
falklands:DefineRoute { kona, via=lima }
falklands:DefineRoute { lasvegas }
falklands:DefineRoute { lima }
falklands:DefineRoute { mahajanga, via=capetown }
falklands:DefineRoute { reykjavik, via=bogota }
falklands:DefineRoute { sanfrancisco }
falklands:DefineRoute { tangiers, via=capetown }
falklands:DefineRoute { tokyo, via=capetown }
falklands:DefineRoute { toronto, via=bogota }
falklands:DefineRoute { uluru, via=capetown }
falklands:DefineRoute { wellington, via=capetown }
falklands:DefineRoute { zurich, via=bogota }

-------------------------------------------------------------------------------
-- GOBIDESERT
gobidesert:DefineRoute { havana, via=zurich }
gobidesert:DefineRoute { kona, via=zurich }
gobidesert:DefineRoute { lasvegas, via=zurich }
gobidesert:DefineRoute { lima, via=douala }
gobidesert:DefineRoute { mahajanga }
gobidesert:DefineRoute { reykjavik, via=zurich }
gobidesert:DefineRoute { sanfrancisco, via=zurich }
gobidesert:DefineRoute { tangiers }
gobidesert:DefineRoute { tokyo }
gobidesert:DefineRoute { toronto, via=zurich }
gobidesert:DefineRoute { uluru }
gobidesert:DefineRoute { wellington }
gobidesert:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- HAVANA
havana:DefineRoute { kona }
havana:DefineRoute { lasvegas }
havana:DefineRoute { lima }
havana:DefineRoute { mahajanga }
havana:DefineRoute { reykjavik }
havana:DefineRoute { sanfrancisco }
havana:DefineRoute { tangiers }
havana:DefineRoute { tokyo, via=zurich }
havana:DefineRoute { toronto }
havana:DefineRoute { uluru, via=capetown }
havana:DefineRoute { wellington, via=capetown }
havana:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- KONA
kona:DefineRoute { lasvegas }
kona:DefineRoute { lima }
kona:DefineRoute { mahajanga, via=bogota }
kona:DefineRoute { reykjavik, via=toronto }
kona:DefineRoute { sanfrancisco }
kona:DefineRoute { tangiers, via=sanfrancisco }
kona:DefineRoute { tokyo, via=sanfrancisco }
kona:DefineRoute { toronto }
kona:DefineRoute { uluru, via=capetown }
kona:DefineRoute { wellington, via=capetown }
kona:DefineRoute { zurich, via=toronto }

-------------------------------------------------------------------------------
-- LASVEGAS
lasvegas:DefineRoute { lima }
lasvegas:DefineRoute { mahajanga }
lasvegas:DefineRoute { reykjavik }
lasvegas:DefineRoute { sanfrancisco }
lasvegas:DefineRoute { tangiers }
lasvegas:DefineRoute { tokyo, via=zurich }
lasvegas:DefineRoute { toronto }
lasvegas:DefineRoute { uluru, via=capetown }
lasvegas:DefineRoute { wellington, via=capetown }
lasvegas:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- LIMA
lima:DefineRoute { mahajanga }
lima:DefineRoute { reykjavik }
lima:DefineRoute { sanfrancisco }
lima:DefineRoute { tangiers }
lima:DefineRoute { tokyo, via=zurich }
lima:DefineRoute { toronto }
lima:DefineRoute { uluru, via=capetown }
lima:DefineRoute { wellington, via=capetown }
lima:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- MAHAJANGA (NEW)
mahajanga:DefineRoute { reykjavik }
mahajanga:DefineRoute { sanfrancisco }
mahajanga:DefineRoute { tangiers }
mahajanga:DefineRoute { tokyo }
mahajanga:DefineRoute { toronto }
mahajanga:DefineRoute { uluru }
mahajanga:DefineRoute { wellington }
mahajanga:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- REYKJAVIK
reykjavik:DefineRoute { sanfrancisco }
reykjavik:DefineRoute { tangiers }
reykjavik:DefineRoute { tokyo, via=zurich }
reykjavik:DefineRoute { toronto }
reykjavik:DefineRoute { uluru, via=capetown }
reykjavik:DefineRoute { wellington, via=capetown }
reykjavik:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- SANFRANCISCO
sanfrancisco:DefineRoute { tangiers }
sanfrancisco:DefineRoute { tokyo, via=zurich }
sanfrancisco:DefineRoute { toronto }
sanfrancisco:DefineRoute { uluru, via=capetown }
sanfrancisco:DefineRoute { wellington, via=capetown }
sanfrancisco:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- TANGIERS
tangiers:DefineRoute { tokyo }
tangiers:DefineRoute { toronto }
tangiers:DefineRoute { uluru }
tangiers:DefineRoute { wellington }
tangiers:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- TOKYO
tokyo:DefineRoute { toronto, via=zurich }
tokyo:DefineRoute { uluru }
tokyo:DefineRoute { wellington }
tokyo:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- TORONTO
toronto:DefineRoute { uluru, via=capetown }
toronto:DefineRoute { wellington, via=capetown }
toronto:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- ULURU
uluru:DefineRoute { wellington }
uluru:DefineRoute { zurich }

-------------------------------------------------------------------------------
-- WELLINGTON
wellington:DefineRoute { zurich }