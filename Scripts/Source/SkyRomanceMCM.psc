Scriptname SkyRomanceMCM extends SKI_ConfigBase  

int MCM_DebugKeyA = 0
int MCM_DebugKeyB = 0
float SR_EditUpdateInterval = 0.0

SkyRomanceInitQuestScript SkyromanceQuest

Event OnConfigInit()

    ModName = "SkyRomance"
    Pages = new string[1]
    Pages[0] = "Debug"
	SkyromanceQuest = ((self as quest) as SkyRomanceInitQuestScript)

EndEvent

Event OnPageReset(string a_page)
    SetCursorPosition(0)
    MCM_DebugKeyA = AddKeyMapOption("Debug Key A", ((self as quest) as SkyRomanceInitQuestScript).DebugKeyA, OPTION_FLAG_WITH_UNMAP)
    MCM_DebugKeyB = AddKeyMapOption("Debug Key B", ((self as quest) as SkyRomanceInitQuestScript).DebugKeyB, OPTION_FLAG_WITH_UNMAP)
    SR_EditUpdateInterval = AddSliderOption("Update Interval", ((self as quest) as SkyRomanceInitQuestScript).GetUpdateInterval())
    ;AddEmptyOption()
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

	EndIf
EndEvent

event OnOptionSliderAccept(int a_option, float a_value)
	bool continue = true
	if a_option == SR_EditUpdateInterval
		((self as quest) as SkyRomanceInitQuestScript).SetUpdateInterval(a_value) ;Call setter in quest script
		SetSliderOptionValue(a_option, a_value)	;Update slider value on current page
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