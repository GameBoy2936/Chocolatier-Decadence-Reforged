--[[---------------------------------------------------------------------------
	Chocolatier: Decadence by Design Reforged
	Catalogue History physical-document viewer
	Copyright (c) 2026 Michael Lane.
--]]---------------------------------------------------------------------------

local documents = require("ui/catalogue_history_documents")

local function Localized(id, fallback)
	local value = GetString(id)
	if value == "#####" then return fallback end
	return value
end

local requestedKey = nil
if gDialogTable then requestedKey = gDialogTable.articleKey end
requestedKey = requestedKey or gHistoryDocumentViewerKey

local document = requestedKey and documents[requestedKey] or nil
if not document then
	DebugOut("ERROR", "History document viewer opened without valid document metadata.", { article = requestedKey })
	CloseWindow()
	return
end

gHistoryDocumentViewerKey = requestedKey

-- The facsimile is deliberately presented without a popup frame, nameplate,
-- hint panel or scroll controls. It simply fades in over the Catalogue, with
-- one localized exit button beneath it. The readable transcript stays in the
-- Catalogue detail pane behind this modal at all times.
local scale = document.viewerScale or 0.34
local image_w = (document.pixelWidth or 1) * scale
local image_h = (document.pixelHeight or 1) * scale
local viewer_h = image_h + 54

MakeDialog {
	Window {
		x = 1000, y = kCenter,
		name = "history_document_viewer",
		w = image_w, h = viewer_h,

		Bitmap {
			x = 0, y = 0,
			image = document.image,
			scale = scale,
		},

		SetStyle(C3ButtonStyle),
		Button {
			x = kCenter, y = image_h + 9,
			name = "history_document_close",
			label = "#" .. Localized("catalogue_history_document_close", "Close"),
			default = true,
			cancel = true,
			command = function() FadeCloseWindow("history_document_viewer", "ok") end,
		},
	},
}

CenterFadeIn("history_document_viewer")
