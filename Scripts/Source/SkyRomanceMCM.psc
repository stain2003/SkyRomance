Scriptname SkyRomanceMCM extends SKI_ConfigBase  

string SkyRomance = "SkyRomance.esp"
int MCM_DebugKeyA
int MCM_DebugKeyB
int MCM_DebugEnable
int MCM_GiftFavorMultiplier
int MCM_FactionAffinity
int MCM_QuestFavor
float SR_EditUpdateInterval = 0.0

int GVSRDebugEnabled = 0x00EFF8
int GVSRGiftFavorMultiplier = 0x00EFF9
int GVSRFactionAffinity = 0x00EFFA
int GVSRQuestFavor = 0x00EFFB

SkyRomanceInitQuestScript SkyromanceQuest

Event OnConfigInit()

    ModName = "SkyRomance"
    Pages = new string[1]
    Pages[0] = "Debug"
	SkyromanceQuest = ((self as quest) as SkyRomanceInitQuestScript)

EndEvent

Event OnPageReset(string a_page)
    SetCursorPosition(0)
	;Debugger
    MCM_DebugKeyA = AddKeyMapOption("Debug Key A", ((self as quest) as SkyRomanceInitQuestScript).DebugKeyA, OPTION_FLAG_WITH_UNMAP)
    MCM_DebugKeyB = AddKeyMapOption("Debug Key B", ((self as quest) as SkyRomanceInitQuestScript).DebugKeyB, OPTION_FLAG_WITH_UNMAP)
    SR_EditUpdateInterval = AddSliderOption("Update Interval", ((self as quest) as SkyRomanceInitQuestScript).GetUpdateInterval())
	MCM_DebugEnable = AddToggleOption("Enable Debug", GetExternalBool(SkyRomance, GVSRDebugEnabled))

	;Multiplier
	MCM_QuestFavor = AddSliderOption("Quest Favor Multiplier", GetExternalInt(SkyRomance, GVSRQuestFavor))
	MCM_FactionAffinity = AddSliderOption("Faction Affinity Multiplier", GetExternalInt(SkyRomance, GVSRFactionAffinity))
	MCM_GiftFavorMultiplier = AddSliderOption("Qift Favor Multiplier", GetExternalInt(SkyRomance, GVSRGiftFavorMultiplier))
EndEvent

Event OnOptionSelect(Int Option)
	If (Option == MCM_DebugEnable)
		SetExternalBool(SkyRomance, GVSRDebugEnabled, !GetExternalBool(SkyRomance, GVSRDebugEnabled))
		SetToggleOptionValue(MCM_DebugEnable, GetExternalBool(SkyRomance, GVSRDebugEnabled))
	EndIf
EndEvent

Event OnOptionKeyMapChange(int a_option, int a_keyCode, string conflictControl, string conflictName)
	bool continue = true
	if a_option == MCM_DebugKeyA
		If(conflictControl != "")
			WarningWhenKeyMapConfict(conflictName, conflictControl)
		EndIf

		If(continue)
			SetKeyMapOptionValue(MCM_DebugKeyA, a_keyCode, false)
			;Update hotkey on main script side 
			((self as quest) as SkyRomanceInitQuestScript).SR_RegisterForKey(((self as quest) as SkyRomanceInitQuestScript).DebugKeyA, a_keyCode)
			((self as quest) as SkyRomanceInitQuestScript).DebugKeyA = a_keyCode
		endif
	Endif

	if a_option == MCM_DebugKeyB
		If(conflictControl != "")
			continue = WarningWhenKeyMapConfict(conflictName, conflictControl)
		EndIf

		If(continue)
			SetKeyMapOptionValue(MCM_DebugKeyB, a_keyCode, false)
			((self as quest) as SkyRomanceInitQuestScript).SR_RegisterForKey(((self as quest) as SkyRomanceInitQuestScript).DebugKeyB, a_keyCode)
			((self as quest) as SkyRomanceInitQuestScript).DebugKeyB = a_keyCode
		endif
	EndiF
EndEvent

Event OnOptionSliderOpen(int option)
	If (option == SR_EditUpdateInterval)
		SetSliderDialogRange(1.0, 120.0)
		SetSliderDialogDefaultValue(20.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogStartValue(((self as quest) as SkyRomanceInitQuestScript).GetUpdateInterval())
		;SetSliderOptionValue(option, ((self as quest) as SkyRomanceInitQuestScript).GetUpdateInterval())

	ElseIf (option == MCM_QuestFavor)
		SetSliderDialogRange(1, 10)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogInterval(1)
		SetSliderDialogStartValue(GetExternalInt(SkyRomance, GVSRQuestFavor))

	ElseIf (option == MCM_FactionAffinity)
		SetSliderDialogRange(1, 10)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogInterval(1)
		SetSliderDialogStartValue(GetExternalInt(SkyRomance, GVSRFactionAffinity))

	ElseIf (option == MCM_GiftFavorMultiplier)
		SetSliderDialogRange(1, 10)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogInterval(1)
		SetSliderDialogStartValue(GetExternalInt(SkyRomance, GVSRGiftFavorMultiplier))
	EndIf
EndEvent

event OnOptionSliderAccept(int a_option, float a_value)
	bool continue = true
	if a_option == SR_EditUpdateInterval
		((self as quest) as SkyRomanceInitQuestScript).SetUpdateInterval(a_value) ;Call setter in quest script
		SetSliderOptionValue(a_option, a_value)	;Update slider value on current page

	ElseIf (a_option == MCM_QuestFavor)
		SetExternalInt(SkyRomance, GVSRQuestFavor, a_value)
		SetSliderOptionValue(a_option, a_value)

	ElseIf (a_option == MCM_FactionAffinity)
		SetExternalInt(SkyRomance, GVSRFactionAffinity, a_value)
		SetSliderOptionValue(a_option, a_value)

	ElseIf (a_option == MCM_GiftFavorMultiplier)
		SetExternalInt(SkyRomance, GVSRGiftFavorMultiplier, a_value)
		SetSliderOptionValue(a_option, a_value)
	endif
EndEvent

bool Function WarningWhenKeyMapConfict(string conflictName, string conflictControl)
	String mssg
	If(conflictName != "")
		mssg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
	Else
		mssg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
	EndIf

	return ShowMessage(mssg, true, "$Yes", "$No")
EndFunction

;Setter
Function SetExternalBool(string modesp, int id, bool val)
	int set = 0
	if val
		set = 1
	endif 
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(set)
endfunction

Function SetExternalFloat(string modesp, int id, float val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValue(val)
endfunction

Function SetExternalInt(string modesp, int id, float val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(val as int)
endfunction

bool Function GetExternalBool(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() == 1
endfunction

float Function GetExternalFloat(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValue()
endfunction

int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt()
endfunction

