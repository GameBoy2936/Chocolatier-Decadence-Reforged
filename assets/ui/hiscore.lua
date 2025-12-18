-- Look to submit a new high score
Player:LogScore()

HeaderFont = { standardFont, 70, BlueColor }
TableInfoFont = { standardFont, 30, BlackColor }
EligibleFont = { standardFont, 18, BlackColor }
EligibleAsteriskFont = { standardFont, 12, BlackColor }
ConnectingToServerFont = { standardFont, 18, BlackColor }
TableHeaderFont = { standardFont, 30, BlackColor }
ScoreInfoFont = { standardFont, 18, BlackColor }
ScoreFont = { standardFont, 18, BlackColor }
PlayerInfoFont = { standardFont, 14, BlackColor }
RankFont = { standardFont, 26, BlackColor }

LeftButtonGraphics = {
	"hiscore/arrowleft_up",
	"hiscore/arrowleft_down",
	"hiscore/arrowleft_over"
};

kScoreRowSpace = 32
kRowY = 95
kLeftX = 5
kNumberX = kLeftX + 37
kNameX = 57
kInfoX = kNameX + 10
kScoreX = 470
kP1X = kNumberX + 1

kNameW = 400
kNameH = 21

eLocalView=0
eRequestingCategories=1
eRequestingScores=2
eSubmitting=3
eGlobalView=4
eError=5

function UpdateButtons()
	local state = GetState();
	local localHS = IsEnabled(kHiscoreLocalOnly);
	local anonHS = IsEnabled(kHiscoreAnonymous);
	local fullHS = (not localHS) and (not anonHS);

	EnableWindow("view",false);
	EnableWindow("viewlocal",false);
	EnableWindow("submit",false);
	EnableWindow("categoryleft",false);
	EnableWindow("categoryright",false);
	
	if (state==eLocalView) then
		local eligibleScore;

		if fullHS then
			EnableWindow("moreinfo",true);
		else 
			EnableWindow("moreinfo",false);
		end
		
		if not localHS then
			EnableWindow("view",true);

			if (ScoreAvailable()) then
				EnableWindow("submit",true);
			end
		end
	elseif (state == eGlobalView) then
		EnableWindow("viewlocal",true);
		EnableWindow("categoryleft",true);
		EnableWindow("categoryright",true);
	elseif (state == eError) then
		EnableWindow("viewlocal",true);
	end

end


MakeDialog
{
	-- Name the modal dialog
	Window
	{
		x=1000,y=9,name="hiscorescreen",fit=true,
		Bitmap
		{
			x=0,y=13,image="image/popup_back_highscores",
			HiscoreWindow
			{
				x=0,y=0,h=kMax,w=kMax,
				Text { x=17,y=35,w=455,h=40, name="local", label="#"..GetString"localhighscores", font=TableHeaderFont, flags=kVAlignCenter+kHAlignCenter },
				Text { x=17,y=35,w=455,h=40, name="global", label="#"..GetString"globalhighscores", font=TableHeaderFont, flags=kVAlignCenter+kHAlignCenter },

				Text   { y=kRowY,name="1",label="1.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY,name="p1_1",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY,name="name1",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY,name="score1",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+18,name="info1",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(1*kScoreRowSpace),name="2",label="2.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(1*kScoreRowSpace),name="p1_2",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(1*kScoreRowSpace),name="name2",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(1*kScoreRowSpace),name="score2",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(1*kScoreRowSpace)+18,name="info2",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(2*kScoreRowSpace),name="3",label="3.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(2*kScoreRowSpace),name="p1_3",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(2*kScoreRowSpace),name="name3",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(2*kScoreRowSpace),name="score3",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(2*kScoreRowSpace)+18,name="info3",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(3*kScoreRowSpace),name="4",label="4.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(3*kScoreRowSpace),name="p1_4",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(3*kScoreRowSpace),name="name4",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(3*kScoreRowSpace),name="score4",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(3*kScoreRowSpace)+18,name="info4",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(4*kScoreRowSpace),name="5",label="5.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(4*kScoreRowSpace),name="p1_5",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(4*kScoreRowSpace),name="name5",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(4*kScoreRowSpace),name="score5",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(4*kScoreRowSpace)+18,name="info5",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(5*kScoreRowSpace),name="6",label="6.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(5*kScoreRowSpace),name="p1_6",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(5*kScoreRowSpace),name="name6",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(5*kScoreRowSpace),name="score6",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(5*kScoreRowSpace)+18,name="info6",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(6*kScoreRowSpace),name="7",label="7.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(6*kScoreRowSpace),name="p1_7",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(6*kScoreRowSpace),name="name7",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(6*kScoreRowSpace),name="score7",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(6*kScoreRowSpace)+18,name="info7",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(7*kScoreRowSpace),name="8",label="8.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(7*kScoreRowSpace),name="p1_8",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(7*kScoreRowSpace),name="name8",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(7*kScoreRowSpace),name="score8",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(7*kScoreRowSpace)+18,name="info8",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(8*kScoreRowSpace),name="9",label="9.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(8*kScoreRowSpace),name="p1_9",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(8*kScoreRowSpace),name="name9",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(8*kScoreRowSpace),name="score9",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(8*kScoreRowSpace)+18,name="info9",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },

				Text   { y=kRowY+(9*kScoreRowSpace),name="10",label="10.",	x=kLeftX,w=kNumberX,h=20, font=ScoreFont, flags=kHAlignRight+kVAlignTop, },
				Bitmap { y=kRowY+(9*kScoreRowSpace),name="p1_10",			x=kP1X, image="hiscore/p1icon", },
				Text   { y=kRowY+(9*kScoreRowSpace),name="name10",			font = ScoreFont, x=kNameX,w=kNameW,h=kNameH, flags = kHAlignLeft + kVAlignTop, label="name" },
				Text   { y=kRowY+(9*kScoreRowSpace),name="score10",			font=ScoreFont, x=0,w=kScoreX,h=kMax, flags = kHAlignRight + kVAlignTop, label ="#"..GetString"12345" },
				Text   { y=kRowY+(9*kScoreRowSpace)+18,name="info10",		font=PlayerInfoFont, x=kInfoX,w=kScoreX,h=kMax, flags = kHAlignLeft + kVAlignTop, label ="#"..GetString"#More info goes here" },


--[[
				Bitmap
				{
					x = 70,
					y = 150,
					image="hiscore/global-hs-bb_large",
					name="leftpanel",

					Text
					{
						font = TableHeaderFont,
						name = "topplayers",
						x=0,y=10,w=kMax,h=kMax,
						flags = kHAlignCenter + kVAlignTop,
						label="#"..GetString"topplayers"
					};
				};
]]--

				Window
				{
					x=477,y=0,w=kMax,h=kMax, name="rightpanelsmall",

					Text { x=20,y=75,w=249,h=kMax, name="yourrankglobalinfo", label="#"..GetString"globalhighscoreinfo", font=ScoreInfoFont, flags=kVAlignTop+kHAlignCenter },
					Text { x=20,y=155,w=249,h=kMax, name="yourrank", label="#"..GetString"yourrank", font=RankFont, flags=kVAlignTop+kHAlignCenter },
					Text { x=20,y=195,w=249,h=kMax, name="congratulations", label="#"..GetString"congratshighscore", font=RankFont, flags=kVAlignTop+kHAlignCenter },
					Text { x=20,y=195,w=249,h=kMax, name="dnq", label="#"..GetString"scorednq", font=RankFont, flags=kVAlignTop+kHAlignCenter },
				},

				Window
				{
					x=477,y=0,w=kMax,h=kMax, name="rightpanel",
					
					Text { x=0,y=25,w=289,h=40, name="globalinfoheader", label="#"..GetString"globalhighscores", font=TableHeaderFont, flags=kVAlignCenter+kHAlignCenter },
					Text { x=20,y=75,w=249,h=kMax, name="info", label="#"..GetString"globalhighscoreinfo", font=ScoreInfoFont, flags=kVAlignTop+kHAlignCenter },
					Text { x=20,y=155,w=249,h=kMax, name="eligible", label="#"..GetString"eligible", font=EligibleFont, flags=kVAlignTop+kHAlignCenter },

					SetStyle(C3ButtonStyle),
					Button { x=kCenter, y=210, name="moreinfo", label="#"..GetString"moreinfo", command = function() DoModal("ui/hiscoreinfo.lua") end },
					Button { x=kCenter, y=250, name="submit", label="#"..GetString"submit",
						command =
							function()
								vars = loadstring(GetLuaServerSubmitSetupVars(false))
								vars()
								val = DoModal("ui/serversubmit.lua")
								if (val == 'qualified')	 then
									SubmissionDone(true)
								elseif (val == 'success') then
									SubmissionDone(false)
								else
									-- nothing
								end
							end
					},
						
					Text { font = ConnectingToServerFont, name = "server", x=20,y=210,w=249,h=80, flags = kHAlignCenter + kVAlignCenter, label = "connectingtoserver" },
					Text { font = ConnectingToServerFont, name = "error", x=20,y=210,w=249,h=80, flags = kHAlignCenter + kVAlignCenter, },
				},


				Text { font = ScoreFont, name = "category", x=141,y=66,w=208,h=40, flags = kHAlignCenter + kVAlignTop, },
				SetStyle(C3ButtonStyle),
				Button { graphics = LeftButtonGraphics, name="categoryleft", x=138,y=60, scale = 0.6 },
				Button { graphics = LeftButtonGraphics, name="categoryright", x=308,y=60, scale = 0.6, hflip=true, },


				Button
				{
					graphics = LeftButtonGraphics,
					rotate=true,
					name="scrollup",
					x=425,
					y=65,
					scale = 0.4
				};

				Button
				{
					graphics = LeftButtonGraphics,
					rotate=true,
					hflip=true,
					name="scrolldown",
					x=425,
					y=415,
					scale = 0.4
				};

				SetStyle(LongButtonStyle),
				Button
				{
					align=kHAlignRight, -- Position this button at its right edge
					x=731,				-- With above align, position the right edge
					y=kMax-56-65,
					name="viewlocal",
					label="viewlocal",
					scale=1.1
				};
				Button
				{
					align=kHAlignRight, -- Position this button at its right edge
					x=731,				-- With above align, position the right edge
					y=kMax-56-65,
					name="view",
					label="viewglobal",
					scale=1.1
				};


			}
		},
		Bitmap { image="image/popup_nameplate", x=223,y=0,
			Text { x=34,y=10,w=270,h=38, label="#"..GetString"highscoreheader", font=nameplateFont, flags=kVAlignCenter+kHAlignCenter },
		},
		
		SetStyle(C3RoundButtonStyle),
		Button { x=704,y=426, name="ok", label="ok", default=true, cancel=true, command=function() FadeCloseWindow("hiscorescreen", "ok") end },
	}
}

CenterFadeIn("hiscorescreen")