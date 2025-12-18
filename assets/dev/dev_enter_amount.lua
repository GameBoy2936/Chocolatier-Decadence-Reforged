--[[---------------------------------------------------------------------------
	Chocolatier Three: Development Menu - Enter Amount
	Copyright (c) 2025 Michael Lane and Google Gemini AI.
--]]---------------------------------------------------------------------------

local promptText = gDialogTable.prompt or "Enter Amount:"
local onOkCallback = gDialogTable.onOk
local initialValue = gDialogTable.initialValue or "0"

-------------------------------------------------------------------------------

local function okFunction()
	local amount = tonumber(GetLabel("entry") or "0")
	if amount and type(onOkCallback) == "function" then
		onOkCallback(amount)
	end
	FadeCloseWindow("dev_enter_amount", "ok")
end

-------------------------------------------------------------------------------

MakeDialog
{
	Bitmap
	{
		name="dev_enter_amount",
		x=1000,y=kCenter,image="image/popup_back_generic_1",
		
		SetStyle(C3DialogBodyStyle),
		Text { x=20,y=42,w=459,h=100, label="#"..promptText, flags=kVAlignCenter+kHAlignCenter },
		
		Bitmap { x=kCenter,y=142, image="image/entername",
			TextEdit { x=0,y=0,w=kMax,h=kMax, name="entry", label=initialValue,
				flags=kVAlignCenter+kHAlignCenter,
				clearinitial=true, enablewindow="ok",
				length=12, ignore=kNumbersOnly },
		},

		SetStyle(C3ButtonStyle),
		Button { x=113,y=237, name="ok", label="ok", command=okFunction, default=true, },
		Button { x=256,y=237, name="cancel", label="cancel", command=function() FadeCloseWindow("dev_enter_amount", nil) end, cancel=true },
	}
}

SetFocus("entry")
CenterFadeIn("dev_enter_amount")