Scriptname SkyRomanceInitQuestScript extends Quest

import SkyRomanceMiscFunction
import PapyrusUtil
import StringUtil

;Script Linker
ORomanceScript ORomance

;MCM property
int Property DebugKeyA = 35 Auto
int Property DebugKeyB = 34 Auto
bool Property DebugEnable = false Auto

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
	;Map validation
	Debug.Notification("Mod Event:\n" + _args + ": is completed")
	int QuestMap = JValue.readFromFile("Data/SkyRomance/QuestMap.json")
	if (QuestMap == 0)
		debug.Notification("Invalid QuestMap.Json!!!")
		return
	Endif

	;ReadString
	String RelationShipChangelist = JMap.getStr(QuestMap, _args)
	If (RelationShipChangelist != "")
		UpdateAffinityOnQuestCompleted(RelationShipChangelist)
	Else
		Debug.Notification("Invalid Quest EditorID! \nOr can't find target QuestID in QuestMap.json")
	Endif
Endevent

Event OnQuestFailedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	Debug.Notification("Mod Event:\n" + _args + ": is failed")
	;TODO: same as QuestCompletedEvent
EndEvent

Event OnQuestObjectiveUpdatedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	;_args: EditorID
	;_argc: Completed objective
	;Map validation
	int Index = _argc as int
	int ObjectiveMap = JValue.readFromFile("Data/SkyRomance/ObjectiveMap.json")
	if (ObjectiveMap == 0)
		Debug.Notification("Can't find: " + "Data/SkyRomance/ObjectiveMap.json")
		return
	Endif

	;Reading objective update string
	String Objective = _args + "/" + Index
	String RelationShipChangelist = JMap.getStr(ObjectiveMap, Objective)
	If (RelationShipChangelist != "")
		UpdateAffinityOnQuestCompleted(RelationShipChangelist)
	Else
		Debug.Notification("Invalid Quest objective EditorID! \nOr can't find objective in QuestMap.json:\n" + Objective)
	Endif
EndEvent


;-----------------------------------------------Key Pressed Event------------------------------------------------------------
Event OnKeyDown(int KeyPress)

	if KeyPress == DebugKeyA
		;Debug NPC's stat
		actor Target = game.GetCurrentCrosshairRef() as actor
		If (target)
			if  (target.IsInCombat() || OUtils.IsChild(target) || target.isdead() || !(target.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))))
				return 
			endif
			;Debug.MessageBox(Target.GetDisplayName() + "'s SV: " + ORomance.GetNPCSV(Target) + "\nMarrySV: " + ORomance.GetMarrySV(Target) + "\nSeductionSV: " + ORomance.GetSeductionSV(Target) + "\nKissSV: " + ORomance.GetKissSV(Target) + "\nFaction Fame: " + ORomance.GetAffinityForNPCFaction(Target))
			Debug.messagebox("SV: " + oromance.GetNPCSV(target) + "\nQuestFavor: " + oromance.GetQuestFavorStat(Target) + "\nFactionAffinity: " + oromance.GetAffinityForNPCFaction(target) + "\nLikeStat: " + oromance.getlikeStat(target))
		else
			Debug.Notification("invalid target")
		Endif
	EndIf

	If KeyPress == DebugKeyB
		string DebugString = "+2|CrimeFactionWhiterun|+1|Ysolda|-1|Nazeem|+2|Faendal|DLC1Serana|"
		UpdateAffinityOnQuestCompleted(DebugString)
		; debug.MessageBox(GetFactionFame(GetFormByEditorID("CrimeFactionWhiterun") as Faction))
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

Function UpdateAffinityOnQuestCompleted(String inputString)
	;This function is used to update Npc's QuestFavor stat and FactionAffinity stat towards Player
	string[] SplitedStrings = Split(inputString, "|")
	int StrNum = SplitedStrings.Length
	int iter = 0
	string outputstring = "Quest Objective Completed! NPC's SV has changed:"
	float SVOffset
	while iter < StrNum
		String CurString = SplitedStrings[iter]
		Form curForm = GetFormByEditorID(CurString)

		If (curForm) ;Check to see if current string is EditorID or int value
			Actor CurNPC = GetFormByEditorID(CurString + "REF") as Actor
			Faction CurFaction = GetFormByEditorID(CurString) as Faction

			If (CurNPC) 
				;look for npcs entry
				
				IncreaseQuestFavor(CurNPC, SVOffset)
				ORomance.increasedislikestat(CurNPC, SVOffset * -1)
				; If (SVOffset > 0)
				; Else
				; EndIf

			elseif (CurFaction)
				;look for faction entry
				IncreaseFactionFame(CurFaction, SVOffset as int)
			Else
				Debug.Notification("This editorID is not what we look for: " + CurString)
				Debug.trace("This editorID is not what we look for: " + CurString)
			endif
			outputstring = outputstring + "\n" + CurString + ": " + SVOffset
		else
			;Update SVOffset
			SVOffset = Substring(CurString, 1, GetLength(CurString) - 1) as float
			if (SVOffset == 0)
				Debug.Notification("Invalid editorID entry" + CurString)
				Debug.trace("Invalid editorID entry" + CurString)
			Endif
			
			String FirstChar = substring(CurString, 0, 1)
			If (FirstChar == "-")
				SVOffset = -SVOffset
			EndIf
		EndIf
		iter += 1
	EndWhile
	debug.Trace(outputstring)
	debug.messagebox(outputstring)
EndFunction

;-----------Set and get value from StorageUtil--------------------
string Property FactionFameKey = "SRK_FactionFame" Auto
string Property QuestFavorKey = "SRK_QuestFavor" Auto

Function IncreaseFactionFame(Faction inFaction, int FameToIncrease)
	int CurVal = StorageUtil.GetIntValue(inFaction as Form, FactionFameKey)
	StorageUtil.SetIntValue(inFaction as Form, FactionFameKey, curVal + FameToIncrease)

	Debug.notification("Fame of " + inFaction.GetName() + " increased by " + FameToIncrease)
EndFunction

Function IncreaseQuestFavor(Actor NPC, float invalue)
	;This function will increase Npc's QuestFavor value for a permenant impact, also like stat for a tempory 'buff'.
	float curVal = oromance.GetQuestFavorStat(NPC)
	StorageUtil.SetFloatValue(NPC, QuestFavorKey, curVal + inValue)
	oromance.increaselikestat(NPC, inValue)
Endfunction

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
