Scriptname SkyRomanceInitQuestScript extends Quest

import SkyRomanceMiscFunction
import PapyrusUtil
import StringUtil

;Script Linker
ORomanceScript ORomance

;MCM property
int Property DebugKeyA = 35 Auto
int Property DebugKeyB = 34 Auto

bool isAreaCheckerTimerStart = false
float UpdateInterval = 5.0

;Quest Function Related
Quest RecentQuest
int RecentFailedQuest
int RecentCompletedQuest
string property ObjectiveMapPath = "Data/SkyRomance/ObjectiveMap.json" auto
string property QuestMapPath = "Data/SkyRomance/QuestMap.json" auto



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

;------------------------------------------------On Objective Update Deleagtor-----------------------------------------------
Event OnQuestObjectiveStateChangedGlobal(Quest akQuest, string displayText, int oldState, int newState, int objectiveIndex, alias[] ojbectiveAliases)
	;Dormant = 0;Displayed = 1;Completed = 2;CompletedDisplayed = 3;Failed = 4;FailedDisplayed = 5
	debug.trace("Quest objective changed: " + objectiveIndex + "/" + displayText + "\n" + "newState: " + newState + " | oldState: " + oldState)

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
	else
		;Deprecated
	EndIf
	;Send objective completed event
	If (newState == 3 && oldState != 3)
		SendModEvent("SRQuestObjectiveUpdated", akQuest.GetID(), objectiveIndex)
	EndIf
	
	;debug.trace(akQuest.GetID() + displayText + " [" + objectiveIndex + "] " + " completed")
EndEvent


;---------------------------------------------On Quest Update Event----------------------------------------------------------
Event OnQuestCompletedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	;_args: EditorID
	;_argc: FormID
	Debug.Notification("Mod Event:\n" + _args + ": is completed")
	int QuestMap = JValue.readFromFile("Data/SkyRomance/QuestMap.json")
	String RelationShipChangelist = JMap.getStr(QuestMap, _args)
	If (RelationShipChangelist != "")
		UpdateNPCSVOnQuestCompleted(RelationShipChangelist)
	Else
		Debug.MessageBox("Invalid change list! \nOr can't find target QuestID in QuestMap.json")
	Endif
Endevent

Event OnQuestFailedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	Debug.Notification("Mod Event:\n" + _args + ": is failed")
	;TODO: same as QuestCompletedEvent
EndEvent

Event OnQuestObjectiveUpdatedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	Debug.trace("Objective completed: " + _args + "/" + _argc as int)

	int Index = _argc as int
	int ObjectiveMap = JValue.readFromFile("Data/SkyRomance/ObjectiveMap.json")
	If (ObjectiveMap != 0)
		String Objective = _args + "/" + Index
		String RelationShipChangelist = JMap.getStr(ObjectiveMap, Objective)
		If (RelationShipChangelist != "")
			UpdateNPCSVOnQuestCompleted(RelationShipChangelist)
		Else
			Debug.Notification("Invalid change list! \nOr can't find objective in QuestMap.json:\n" + Objective)
		Endif
	else
		Debug.Notification("Can't find: " + "Data/SkyRomance/ObjectiveMap.json")
	EndIF
EndEvent


;-----------------------------------------------Key Pressed Event------------------------------------------------------------
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
			If (TestingPrint())
				Debug.MessageBox("not null")
			Else
				Debug.MessageBox("null")
			EndIf
			
		EndIf
	EndIf

	If KeyPress == DebugKeyB
		string DebugString = "+1|CrimeFactionWhiterun|Ysolda|-1|Nazeem|+2|Uthgerd|DLC1Serana|"
		UpdateNPCSVOnQuestCompleted(DebugString)
	Endif
EndEvent





;---------------------------------------------------------Timer Event------------------------------------------------------
Event OnTimer(int aiTimerID)
	if aiTimerID == 0
		;Debug.Notification("Timer ticked" + ": " + RealtimeUtil.GetRealTime())
		Debug.Trace("Timer ticked" + ": ")
		DbFormTimer.StartTimer(self, UpdateInterval, 0)
	Endif
EndEvent







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
EndFunction

Function SR_UnRegisterEvent()
	DbSkseEvents.UnregisterFormForGlobalEvent_All("OnQuestObjectiveStateChangedGlobal", self)
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
	string outputstring = "Quest Objective Completed! NPC's SV has changed:\n"
	float SVOffset
	while iter < StrNum
		String CurString = SplitedStrings[iter]
		String FirstChar = substring(CurString, 0, 1)

		If (FirstChar != "+" && FirstChar != "-") ;Check to see if current string is EditorID or int value
			Actor CurNPC = GetFormByEditorID(CurString + "REF") as Actor
			If (CurNPC) ;look for npcs entry
				float LastLikeSV = ORomance.getlikeStat(CurNPC)
				float LastDislikeSV = ORomance.getdislikeStat(CurNPC)
				If (SVOffset > 0)
					ORomance.increaselikestat(CurNPC, SVOffset)
				Else
					ORomance.increasedislikestat(CurNPC, SVOffset * -1)
				EndIf
				;Output string used for debugging
				outputstring = outputstring + CurNPC.GetDisplayName() + ":\n" + "Current Like: " + ORomance.getlikeStat(CurNPC) + " | " + "Last Like: " +  LastLikeSV + "\n"
				outputstring = outputstring +  "Current Dislike: " + ORomance.getdislikeStat(CurNPC) + " | " + "Last Dislike: " +  LastDislikeSV + "\n"
			else
				Faction CurFaction = GetFormByEditorID(CurString) as Faction
				If (CurFaction) ;look for faction entry
					;Debug.MessageBox("Found faction entry: " + CurFaction.GetName())
					UpdateFactionSV(CurFaction, SVOffset as int)
					outputstring = outputstring + CurFaction.GetName() + ": " + SVOffset + "\n"
				else
					Debug.Notification("Invalid entry " + CurString)
				endif
			endif
		else;Update SVOffset
			String Value = Substring(CurString, 1, GetLength(CurString) - 1)
			SVOffset = Value as float
			If (FirstChar == "-")
				SVOffset = -SVOffset
			EndIf
		EndIf
		iter += 1
	EndWhile
	debug.Trace(outputstring)
	debug.MessageBox(outputstring)
	;QuestLog = PushString(QuestLog, "Teststringgejwiewew")
EndFunction

Function UpdateFactionSV(Faction inFaction, int FameToIncrease)
	If (inFaction == ORomance.CrimeFactionWhiterun)
		;Debug.MessageBox("WhiterunFaction Fame Increased by " + FameToIncrease + " !")
		ORomance.TFWhiterun.SetValueInt(ORomance.TFWhiterun.GetValueInt() + FameToIncrease)
		((self as quest) as ORomanceScript).TFWhiterun.SetValueInt(50)
	EndIf
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
