Scriptname SkyRomanceInitQuestScript extends Quest

import SkyRomanceMiscFunction
import PapyrusUtil
import StringUtil

ORomanceScript ORomance
int Property DebugKeyA = 35 Auto
int Property DebugKeyB = 34 Auto

bool isAreaCheckerTimerStart = false
float UpdateInterval = 5.0

;Quest listener
Quest RecentQuest
int RecentFailedQuest
int RecentCompletedQuest

Event Oninit()
	Debug.Notification("SkyRomance is initializing")

	;Linking reference
	ORomance = game.GetFormFromFile(0x000800, "ORomance.esp") as ORomanceScript

	;Register Events
	SR_InitEvents()
	SR_InitKeys()

	;More init logic

EndEvent

event OnLoadGameGlobal()

	SR_InitEvents()
	SR_InitKeys()
	DbFormTimer.CancelTimer(self, 0)
	;DbFormTimer.StartTimer(self, UpdateInterval, 0)

	Debug.Notification("Game loaded")
EndEvent

Event OnDeathGlobal(Actor Victim, Actor Killer)
	Debug.MessageBox("Attacker = " + Killer.getDisplayName() + "\nTarget = " + Victim.GetDisplayName())
EndEvent

Event OnQuestObjectiveStateChangedGlobal(Quest akQuest, string displayText, int oldState, int newState, int objectiveIndex, alias[] ojbectiveAliases)
	;Dormant = 0,
	;Displayed = 1,
	;Completed = 2,
	;CompletedDisplayed = 3,
	;Failed = 4,
	;FailedDisplayed = 5
	RecentQuest = akQuest

	If RecentQuest.IsStopped()	;Send quest completed/failed event
		int QuestID = akQuest.GetFormID()
		If newstate == 2 || newstate == 3
			If (RecentCompletedQuest != QuestID)
				;Send quest completed event
				SendModEvent("SRQuestCompleted", akQuest.GetID(), akQuest.GetFormID() as float)
				RecentCompletedQuest = QuestID
			EndIf
		Else
			If (RecentFailedQuest != QuestID)
				;Send quest failed
				;RecentFailedQuest is used to check to prevent multiple call upon a quest failed!
				SendModEvent("SRQuestFailed", akQuest.GetID())
				RecentFailedQuest = QuestID
			EndIf
		endif
	else	;Send objective update event
		If (newState == 2 || newstate == 3)
			SendModEvent("SRQuestObjectiveUpdated", displayText, objectiveIndex)
		EndIf
	EndIf
	
	;debug.trace(akQuest.GetID() + displayText + " [" + objectiveIndex + "] " + " completed")
EndEvent

Event OnQuestCompletedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	;_args: EditorID
	;_argc: FormID
	
Endevent

Event OnQuestFailedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	Debug.MessageBox("Mod Event:\n" + _args + ": is failed")
	;TODO: same as QuestCompletedEvent
EndEvent

Event OnQuestObjectiveUpdatedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	debug.trace(RecentQuest.GetID() + _args + " [" + _argc as int + "] " + " completed")
EndEvent

Event OnKeyDown(int KeyPress)

	if KeyPress == DebugKeyA
		Debug.Trace("Debug key pressed")

		;Debug NPC's stat
		actor Target = game.GetCurrentCrosshairRef() as actor
		If (target)
			if  (target.IsInCombat() || OUtils.IsChild(target) || target.isdead() || !(target.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))))
				return 
			endif
			Debug.MessageBox(Target.GetDisplayName() + "'s SV: " + ORomance.GetNPCSV(Target) + "\nMarrySV: " + ORomance.GetMarrySV(Target) + "\nSeductionSV: " + ORomance.GetSeductionSV(Target) + "\nKissSV: " + ORomance.GetKissSV(Target))
		Else
			;QuestList = JValue.readFromFile("Data/QuestFilter.Json")
			;Debug.MessageBox(GetQuestFilter(JMap.getStr(QuestList, "DB01Misc"), 2))
			;Debug.MessageBox("RecentActiveQuest:/n" + RecentQuest.GetID())
		EndIf
	EndIf

	If KeyPress == DebugKeyB
		string DebugString = "+1|Adariana|Ysolda|-1|Nazzem|+2|Uthgerd|"
		UpdateNPCSVOnQuestCompleted(DebugString)
	Endif
EndEvent

Event OnTimer(int aiTimerID)
	if aiTimerID == 0
		;Debug.Notification("Timer ticked" + ": " + RealtimeUtil.GetRealTime())
		Debug.Trace("Timer ticked" + ": ")
		DbFormTimer.StartTimer(self, UpdateInterval, 0)
	Endif
EndEvent

;
;--------------------------------------------------------Function------------------------------------------------------------------
;
;------------Begin Register---------------------------------------
Function SR_InitEvents()
	SR_UnRegisterEvent()
	SR_RegisterEvent()
	SR_RegisterModEvents()
EndFunction

Function SR_RegisterEvent()
	DbSkseEvents.RegisterFormForGlobalEvent("OnQuestObjectiveStateChangedGlobal", self)
    DbSkseEvents.RegisterFormForGlobalEvent("OnDeathGlobal", self, game.getplayer(), 1)
EndFunction

Function SR_UnRegisterEvent()
	DbSkseEvents.UnregisterFormForGlobalEvent_All("OnQuestObjectiveStateChangedGlobal", self)
	DbSkseEvents.UnRegisterFormForGlobalEvent("OnDeathGlobal", self)
EndFunction

Function SR_RegisterModEvents()
	RegisterForModEvent("SRQuestCompleted", "OnQuestCompletedEvent")
	RegisterForModEvent("SRQuestFailed", "OnQuestFailedEvent")
	RegisterForModEvent("SRQuestObjectiveUpdated", "OnQuestObjectiveUpdatedEvent")
EndFunction

Function SR_InitKeys()
	SR_UnRegisterForKeys()
	SR_RegisterForKeys()
EndFunction

Function SR_RegisterForKeys()
	RegisterForKey(DebugKeyA)
	RegisterForKey(DebugKeyB)
EndFunction

Function SR_UnRegisterForKeys()
	UnregisterForAllKeys()
EndFunction

Function SR_RegisterForKey(int oldkeyCode, int a_keyCode)
	UnregisterForKey(oldkeyCode)
	RegisterForKey(a_keyCode)
	Debug.Trace("Register for new key" + a_keyCode)
EndFunction

Function UpdateNPCSVOnQuestCompleted(String inputString)
	string[] SplitedStrings = Split(inputString, "|")
	int StrNum = SplitedStrings.Length
	int iter = 0
	string outputstring
	int SVOffset
	while iter < StrNum
		String CurString = SplitedStrings[iter]
		String FirstChar = substring(CurString, 0, 1)

		If (FirstChar != "+" && FirstChar != "-");Get current NPC's editorID
			Actor CurNPC = GetNPCByEditorID(CurString)
			If (CurNPC)
				If (SVOffset > 0)
					ORomance.setlikestat(CurNPC, ORomance.getlikeStat(CurNPC) + SVOffset)
					;Output string used for debugging
					outputstring = outputstring + CurNPC.GetName() + ": " + SVOffset + "\n"
				Else
					ORomance.setdislikestat(CurNPC, ORomance.getdislikeStat(CurNPC) + SVOffset)
				EndIf
			EndIf
		else;Update SVOffset
			String Value = Substring(CurString, 1, GetLength(CurString) - 1)
			SVOffset = Value as int
			;Negate value
			If (FirstChar == "-")
				SVOffset = -SVOffset
			EndIf
		EndIf
		iter += 1
	EndWhile
	debug.Trace(outputstring)
	;debug.MessageBox(outputstring)
	;QuestLog = PushString(QuestLog, "Teststringgejwiewew")
EndFunction



;---------End Register-----------------------------------------

;---------Begin MCM Setter & Caller----------------
Function SetUpdateInterval(float inTimerInterval)
	Debug.Trace("Timer interval changed to " + inTimerInterval + " .")
	UpdateInterval = inTimerInterval
EndFunction

float Function GetUpdateInterval()
	return UpdateInterval
EndFunction
;---------End MCM Setter & Caller----------------
