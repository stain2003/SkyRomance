ScriptName ORomanceScript Extends Quest

import PO3_SKSEFunctions

OUIScript property OUI auto

actor property playerref auto

AssociationType property Spouse Auto
AssociationType Courting


FavorJarlsMakeFriendsScript FavorJarlsMakeFriends

Faction JarlFaction 

int InteractKey

ovirginityscript ovirgintiy

ORomanceOStimScript property bridge auto

faction FavorJobsBeggarFaction


;marriage
faction PotientialMarriage
Faction Property PlayerMarriedFaction auto
Faction Property VanillaSpouseFaction auto
Faction MarriageAskedFaction
Faction MarriageCourtFaction
Quest RelationshipMarriage
Quest RelationshipMarriageFin
Topic property MarriageAccept auto ;set by property
Topic property MarriageMara auto
Topic property MarriageCourt auto
Quest RelationshipMarriageBreakUp

ReferenceAlias property PlayerLoveInterest auto

;orc-specific 
race OrcRace
faction OrcFriendFaction

;crimefactions
Faction Property CrimeFactionEastmarch auto ;winterhold
Faction Property CrimeFactionFalkreath auto ;falkreath
Faction Property CrimeFactionHaafingar auto ;solitude
Faction Property CrimeFactionHjaalmarch auto ;morthal
Faction Property CrimeFactionOrcs auto ;orcs
Faction Property CrimeFactionPale auto ;dawnstar
Faction Property CrimeFactionReach auto ;markarth
Faction Property CrimeFactionRift auto ;riften
Faction Property CrimeFactionWhiterun auto ;whiterun
Faction Property CrimeFactionWinterhold auto ;riften

faction Property jobInnServer auto
faction Property MarkarthTempleofDibellaFaction auto

Faction property ORSpouseMerchantFaction Auto

MiscObject  Property Gold Auto

Faction FollowerFaction

;Dialogue 
topic property hello auto
topic property goodbye auto
topic property howmuch Auto
topic property accept auto 
topic property CoinWheels auto 
topic property Convinced auto 
topic property nah auto 
topic property price auto 
topic property whatThe auto

sound property success auto
sound property fail auto

faction property dialogueFaction auto

bool Property DoCacheRebuilds auto


bool debugbuild = false


GlobalVariable property ORDifficulty Auto
GlobalVariable property ORSexuality auto
GlobalVariable property ORKey auto
GlobalVariable property ORColorblind auto 
GlobalVariable property ORUseStationaryMode auto
GlobalVariable property ORLeft auto
GlobalVariable property ORRight auto
GlobalVariable property ORAlwaysAllowNakadashi auto 

int Function GetDifficultyDiff()
	return ORDifficulty.GetValueInt() as int
endfunction

bool Function EnableSexuality()
	return (ORSexuality.GetValueInt() == 1)
endfunction

bool Function GetColorblindMode()
	return (ORColorblind.GetValueInt() == 1)
endfunction

Int Function GetLeftKey()
	return ORLeft.GetValueInt() as int
endfunction

Int Function GetRightKey()
	return ORRight.GetValueInt() as int
endfunction

bool Function AlwaysAllowNakadashi()
	return (ORAlwaysAllowNakadashi.GetValueInt() == 1)
endfunction

Event OnInit()
	Utility.wait(2)
	oui = (self as quest) as OUIScript
	SetLookupKeys()
	oui.Startup()

	if Game.GetModByName("OStim.esp") != 255
		bridge = (self as quest) as oromanceostimscript
		bridge.startup()

		if bridge.ostim.GetAPIVersion() < 25
			debug.MessageBox("Your OStim version is out of date. ORomance requires a newer version.")
			return
		endif
	endif

	Docacherebuilds = true

	oui.ShowLoadingIcon()

	playerref = game.GetPlayer()

	interactkey = 37

	followerfaction = Game.GetFormFromFile(0x05C84E, "Skyrim.esm") as faction
	Gold = Game.GetFormFromFile(0x00000F, "Skyrim.esm") as MiscObject
	Spouse = Game.GetFormFromFile(0x0142CA, "Skyrim.esm") as AssociationType
	Courting = Game.GetFormFromFile(0x01EE23, "Skyrim.esm") as AssociationType

	JarlFaction = Game.GetFormFromFile(0x050920, "Skyrim.esm") as faction

	favorjarlsmakefriends = Game.GetFormFromFile(0x087E24, "Skyrim.esm") as FavorJarlsMakeFriendsScript

	RelationshipMarriage = Game.GetFormFromFile(0x074793, "Skyrim.esm") as quest
	RelationshipMarriageBreakUp = Game.GetFormFromFile(0x07431B, "Skyrim.esm") as quest
	RelationshipMarriageFin = Game.GetFormFromFile(0x021382, "Skyrim.esm") as quest
	PotientialMarriage = Game.GetFormFromFile(0x019809, "Skyrim.esm") as faction
	MarriageAskedFaction = Game.GetFormFromFile(0x0FF7F3, "Skyrim.esm") as faction
	MarriageCourtFaction = Game.GetFormFromFile(0x07431A, "Skyrim.esm") as faction

	if Game.GetModByName("OVirginity.esp") != 255
		ovirgintiy = game.GetFormFromFile(0x000800, "OVirginity.esp") as ovirginityscript
	endif
	FavorJobsBeggarFaction = game.GetFormFromFile(0x060028, "Skyrim.esm") as faction

	;LoveInterestSpouse = RelationshipMarriageFin.GetAliasById(0) as ReferenceAlias
	;PlayerLoveInterest = RelationshipMarriage.GetAliasById(0) as ReferenceAlias
	
	OrcRace = game.GetFormFromFile(0x013747, "Skyrim.esm") as race
	OrcFriendFaction = game.GetFormFromFile(0x024029, "Skyrim.esm") as faction

	success = game.GetFormFromFile(0x004E19, "ORomance.esp") as sound
	fail = game.GetFormFromFile(0x004E1A, "ORomance.esp") as sound

	RegisterForSingleUpdate(1)


	onload()


	oui.HideLoadingIcon()
	if debugbuild
		return 
	endif

	;oui.ShowInstalled()
	RegisterForModEvent("OR_inst", "ShowInstalled")
	int me = ModEvent.Create("OR_inst")
	ModEvent.send(me)


EndEvent

bool function IsPlayerMarried()
	return PlayerLoveInterest.GetActorRef() != none
endfunction

bool Function isOrcFriend(actor npc)
	return (npc.isinfaction(OrcFriendFaction)) || (npc.getrace() == OrcRace)
endfunction

bool Function isORMarriageLocked()
	return (game.GetFormFromFile(0x0F62,"ORomancePlus.esp") as GlobalVariable).GetValueInt() == 1
EndFunction

bool Function isVanillaMarriageLocked()
	ReferenceAlias loveInterest = RelationshipMarriage.getAlias(0) as ReferenceAlias
	Actor npc = loveInterest.getReference() as Actor
	return npc.isInFaction(MarriageCourtFaction) || RelationshipMarriageBreakUp.isRunning()
EndFunction

function StoreNPCDataBool(actor npc, string keys, bool value) Global
	int store 
	if value 
		store = 1
	else 
		store = 0
	endif
	StorageUtil.SetIntValue(npc as form, keys, store)
	;console("Set value " + store + " for key " + keys)
EndFunction

Bool function GetNPCDataBool(actor npc, string keys) Global
	int value = StorageUtil.GetIntValue(npc, keys, -1)
	bool ret = (value == 1)
	;console("got value " + value + " for key " + keys)
	return ret
EndFunction

Function Marry(actor npc)

	String output = ""
	ConsoleUtil.SetSelectedReference(npc)
	
	;Not Vanilla marriage, so you've already started marriage quest
	if (RelationshipMarriage.isStopped())
		debug.notification("doing non-Vanilla marriage")
		ORomanceSpouseHouseScript ORomanceSpouseHouseTracker = game.GetFormFromFile(0x00082C, "ORomancePlus.esp") as ORomanceSpouseHouseScript
		if (game.GetFormFromFile(0x0A09,"ORomancePlus.esp") as GlobalVariable).GetValueInt() == ORomanceSpouseHouseTracker.getSpouseLimit()
			;hit max limit of ORomance Plus additional marriages
			debug.notification("You can't have any more spouses!")
			SayTopic(npc, nah)
			return
		endif
		npc.AddToFaction(PotientialMarriage)


		while (output != "Talking >> 0.00")
			ConsoleUtil.ExecuteCommand("isTalking")
			output = ConsoleUtil.ReadMessage()
			Utility.wait(0.5)
		endwhile
		saytopic(npc, game.GetFormFromFile(0x000800, "ORomancePlus.esp") as topic)
	else
		;vanilla
		RelationshipMarriage.SetStage(10)
		npc.AddToFaction(PotientialMarriage)
		npc.AddToFaction(VanillaSpouseFaction)
		while (output != "Talking >> 0.00")
			ConsoleUtil.ExecuteCommand("isTalking")
			output = ConsoleUtil.ReadMessage()
			Utility.wait(0.5)
		endwhile
		npc.say(marriageaccept) ;this sets the stage to 20

		setPlayerPartner(npc, true)
	endif
	
endfunction

int function GetPlayerGold()
	return playerref.GetItemCount(gold)
endfunction	

int function GetNPCSV(actor npc)
	Debug.Trace("Getting SV for " + npc.GetDisplayName())
	int npcSV = GetBaseValue(npc)
	Debug.Trace("Base Value: " + npcSV)
	npcsv += GetCustomValue(npc)
	Debug.Trace("Custom Value added: " + npcSV)
	int RelationshipRank = npc.GetRelationshipRank(playerref)

	int prude = getPrudishnessStat(npc)

	if prude > 80
		int npcCount = GetNearbyNPCCount()
		if npcCount > 2
			npcsv += (10 + (prude - 80))
		elseif npccount < 1
			npcSV -= 5
		endif 
	endif 
	debug.trace("Prude checked: " + npcSV)
	int monog = getMonogamyDesireStat(npc) ;1- 100
	if IsMarried(npc) 
		if monog < 25
			if monog < 6
				npcsv -= 10
			else 
				npcSV += 25
			endif 
		else 
			if monog > 90
				npcSV += 275
			else 
				npcSV += 175 
			endif
		endif

	elseif isWidowed(npc)
		if monog > 90
			npcSV += 135
		else
			npcSV += 35
		endif

	elseif HasGFBF(npc)
		if monog < 25
			if monog < 6
				npcsv -= 10
			else 
				npcSV += 15
			endif 
		else 
			if monog > 90
				npcSV += 175
			else 
				npcSV += 60
			endif
		endif
	EndIf
	Debug.Trace("Marriage checked: " + npcSV)
	if relationshiprank == 1
		npcSV -= 50
	elseif relationshiprank == 2
		npcSV -=75
	elseif relationshiprank == 3
		npcSV -=100
	elseif relationshiprank == 4
		npcSV -=150	
	elseif relationshiprank < 0
		npcsv += 100
	endif 
	Debug.Trace("Relationship Rank checked: " + npcSV)
		If (FavorJarlsMakeFriends.WhiterunImpGetOutofJail > 0 || FavorJarlsMakeFriends.WhiterunSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionWhiterun)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.EastmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.EastmarchSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionEastmarch)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.FalkreathImpGetOutofJail > 0 || FavorJarlsMakeFriends.FalkreathSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionFalkreath)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.HaafingarImpGetOutofJail > 0 || FavorJarlsMakeFriends.HaafingarSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionHaafingar)
				npcsv -= 20
			endif
	
		EndIf
		If (FavorJarlsMakeFriends.HjaalmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.HjaalmarchSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionHjaalmarch)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.PaleImpGetOutofJail > 0 || FavorJarlsMakeFriends.PaleSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionPale)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.ReachImpGetOutofJail > 0 || FavorJarlsMakeFriends.ReachSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionReach)
			npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.WinterholdImpGetOutofJail > 0 || FavorJarlsMakeFriends.WinterholdSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionWinterhold)
				npcsv -= 20
			endif
		EndIf
		If (FavorJarlsMakeFriends.RiftImpGetOutofJail > 0 || FavorJarlsMakeFriends.RiftSonsGetOutofJail > 0)
			if npc.IsInFaction(CrimeFactionRift)
				npcsv -= 20
			endif
		EndIf
		Debug.Trace("Jarl's friend checked: " + npcSV)
		npcsv -= (getloveStat(npc) * 3) as int
		npcsv += (gethateStat(npc) * 3) as int
		Debug.Trace("Love and Hate checked: " + npcSV)
		int dislike = getdislikeStat(npc) as Int

		if (dislike >= 1) && (dislike <= 2)
			npcsv -= 15
		else 
			npcsv += (dislike  * 3)
		endif 
		Debug.Trace("Dislike checked: " + npcSV)
		int sexuality = GetSexuality(npc)

		bool femalePlayer = getGender(playerref)

		bool npcGender = getGender(npc)

		if npcGender
			if femalePlayer ; female on female
				if sexuality == bi 
					; nothing 
				elseif sexuality == hetero 
					npcsv += 250
				elseif sexuality == gay
					npcsv -= 50
				endif 
			else ; male on female
				if sexuality == bi 
					
				elseif sexuality == hetero 
					
				elseif sexuality == gay
					npcsv += 250
				endif 
			endif 
		else ; male
			if femalePlayer ; male on female
				if sexuality == bi 
					
				elseif sexuality == hetero 
					
				elseif sexuality == gay
					npcsv += 250
				endif 
			else  ; male on male
				if sexuality == bi 
					
				elseif sexuality == hetero 
					npcsv += 250
				elseif sexuality == gay
					npcsv -= 50
				endif 
			endif 
		endif 
		Debug.Trace("Sexuality checked: " + npcSV)
	if (npc.GetRace() == orcrace )
		if isOrcFriend(playerref)
			npcsv -= 25
		else 
			npcsv += 75
		endif 
	endif 

	int FactionAffity = (GetAffinityForNPCFaction(npc)) * GetExternalInt(SkyRomance, GVSRFactionAffinity)
	int QuestFavor = (GetQuestFavorStat(npc)) * GetExternalInt(SkyRomance, GVSRQuestFavor)
	int GiftFavor = (GetGiftFavorStat(npc)) * GetExternalInt(SkyRomance, GVSRGiftFavorMultiplier)
	
	Debug.Trace("+FactionAffinity: " + FactionAffity)
	Debug.Trace("+QuestFavor: " + QuestFavor)
	Debug.Trace("+GiftFavor: " + giftFavor)

	npcsv -= FactionAffity + questfavor + giftfavor

	Debug.Trace("Final SV: " + npcSV)

	return npcSV

EndFunction

bool function PlayerHasPsychicPerk(actor npc)
	if (GetSpeechStat(playerref) > 49) || isPlayerPartner(npc) 
		return true
	else 
		return false
	endif  
endfunction

bool function TryInquire(actor npc)
	float like = getlikeStat(npc)
	int love = getloveStat(npc) as int 

	if (love >= 1) || (like >= 1) || (npc.GetRelationshipRank(playerref) >= 1)
		return true 
	else 

		return GetPlayerSV() > getPrudishnessStat(npc)
	endif 
	
endfunction 

string Function getPronoun(actor npc)
	string pronoun
	bool npcGender
	if bridge != None
		npcGender = bridge.ostim.AppearsFemale(npc)
	else
		npcGender = npc.getActorBase().GetSex()
	endif

	if npcGender
		pronoun = "she"
	else 
		pronoun = "he"
	endif
	return pronoun
endfunction

Function InquireRelationshipStatus(actor npc)
	string name = npc.GetDisplayName()
	string pronoun = getPronoun(npc)

	int monog = getMonogamyDesireStat(npc) ;1- 100

	string status
	if isPlayerPartner(npc)
		status = name + " says " + pronoun + " belongs to you"
		if npc.GetBaseObject().GetName() == "Serana" || npc.GetBaseObject().GetName() == "Frea"
			saytopic(npc, game.getFormFromFile(0x000827,"ORomancePlus.esp") as topic )
		endif
	elseif isWidowed(npc)
		status = name + " says " + pronoun + " is widowed"
	elseif IsMarried(npc)
		if monog < 6
			status = name + " says " + pronoun + " is in a terrible marriage"
		elseif monog > 6 && monog < 34
			status = name + " says " + pronoun + " is tired of their marriage"
		else
			status = name + " says " + pronoun + " is married"
		endif

		if IsFamiliarWithPlayer(npc)
			status = status + GetSpouseString(npc)
		endif 
	elseif HasGFBF(npc)
		if monog < 6
			status = name + " says " + pronoun + " is in a bad relationship"
		else 
			status = name + " says " + pronoun + " is in a relationship"
		endif

		if IsFamiliarWithPlayer(npc)
			status = status + GetPartnerString(npc)
		endif 
	else 
		status = name + " says " + pronoun + " is single"
	endif 

	debug.Notification(status)
endfunction

bool Function getGender(actor npc)
	bool npcGender
	if bridge != None
		npcGender = bridge.ostim.AppearsFemale(npc)
	else
		npcGender = npc.getActorBase().getSex()
	endif
	return npcGender
EndFunction

Function InquireSexuality(actor npc)
	string name = npc.GetDisplayName()
	string pronoun = getPronoun(npc)

	int sexuality = GetSexuality(npc)

	if sexuality == bi
		debug.Notification(name + " says " + pronoun + " is attracted to men and women")
	else
		if getGender(npc)
			if Sexuality == hetero
				debug.Notification(name + " says " + pronoun + " is attracted to men")
			elseif sexuality == gay
				debug.Notification(name + " says " + pronoun + " is attracted to women")
			endif
		else 
			if Sexuality == hetero
				debug.Notification(name + " says " + pronoun + " is attracted to women")
			elseif sexuality == gay
				debug.Notification(name + " says " + pronoun + " is attracted to men")
			endif
		endif
	endif 
endfunction

Function InquireSexualExperience(actor npc)
	string name = npc.GetDisplayName()
	string pronoun = getPronoun(npc)

	int sexDesireStat = getSexDesireStat(npc)
	int monog = getMonogamyDesireStat(npc) ;1- 100
	int prude = getPrudishnessStat(npc)

	if monog > 94
		debug.Notification(name + " says " + pronoun + " will not have sex before marriage")
	elseif (prude > 80)
		debug.Notification(name + " says talking about your sexual history is disgusting")
	elseif isvirgin(npc)
		debug.Notification(name + " says " + pronoun + " is a virgin")
	elseif (sexdesirestat > 85) ;&& (prude < 50)
		debug.Notification(name + " says " + pronoun + " lives for sex")
	elseif (sexdesirestat < 16)
		debug.Notification(name + " says " + pronoun + " has little interest in sex")
	elseif (monog - sexDesireStat) > 20
		debug.Notification(name + " says " + pronoun + " is far more interested in love than sex")
	else 
		debug.Notification(name + " says " + pronoun + " has some experience")
	endif 

endfunction

;time of day  | is prostitute | like stat (half effective) | is married | sex desire stat | is virgin
int function GetSeductionSV(actor npc)
	int npcsv = GetNPCSV(npc)

	int timeOfDay = GetTimeOfDay() ; 0 - day | 1 - morning/dusk | 2 - Night

	if timeOfDay == 0
		npcsv += 10
	ElseIf timeOfDay == 2
		npcsv -= 10
	EndIf


	if IsProstitute(npc)
		npcsv += 75
	EndIf

	npcsv -= (getlikeStat(npc) / 2) as int

	if !IsMarried(npc) 
		int monog = getMonogamyDesireStat(npc) ;1- 100

		if monog < 50
			npcsv += (monog - 50)
		elseif monog > 94
			if isPlayerPartner(npc)
				debug.Notification(npc.GetDisplayName() + " will not have sex before marriage")
			endif 
			return 999
		else 
			if !isPlayerPartner(npc)
				npcsv += ((monog - 50) * 2)
			else 
				npcsv += ((monog - 50))
			endif 
		endif 
	EndIf

	int sexDesireStat = getSexDesireStat(npc)

	npcsv -= (sexDesireStat - 50)

	float TimeSinceLastSeductionAttempt = Utility.GetCurrentGameTime() - getLastSeduceTime(npc)

	if sexDesireStat > 95

	elseif TimeSinceLastSeductionAttempt < 0.15
		;console("Adding 130")
		npcsv += 130
	elseif TimeSinceLastSeductionAttempt < 1
		npcsv += ( (100 - sexDesireStat) * ((1 - TimeSinceLastSeductionAttempt) * 3)  ) as int
		;console("Adding " + ( (100 - sexDesireStat) * ((1 - TimeSinceLastSeductionAttempt) * 3)  ) as int)
	endif 


	if IsVirgin(npc)
		npcsv += 35
	endif 

	if IsPlayerSpouse(npc) ;&& !(TimeSinceLastSeductionAttempt < 0.1)
		npcsv = -100
	endif


	;console("NPC seduction SV: " + npcsv)
	

	return npcsv

endFunction

bool Function TrySeduce(actor npc)
	int playerSV = GetPlayerSV()
	int npcsv = GetSeductionSV(npc)
	if (game.GetFormFromFile(0x0F48,"ORomancePlus.esp") as GlobalVariable).GetValueInt() == 1
		debug.Notification("PlayerSV: " + playersv + " vs. NpcSV:"+npcsv)
	EndIf
		

	return (playerSV > npcSV)

EndFunction

int Function GetKissSV(actor npc)
	int npcSV = GetNPCSV(npc)

	float like = getlikeStat(npc)

	int prude = getPrudishnessStat(npc)

	if prude > 30
	    if (like < 1) && (npc.GetRelationshipRank(playerref) < 1)
		    npcsv += 50
	    endif 
    endif


	if IsProstitute(npc)
		npcsv += 75
	EndIf

	npcsv -= (like) as int

	int monog = getMonogamyDesireStat(npc) ;1- 100
	if !IsMarried(npc)

		if monog < 50
			npcSV -= (monog - 50)
		else
			npcSV += (monog - 50)
		endif 

		npcSV -= 20

		
	else 
		 

		 if monog > 50
		 	npcsv += (monog * 2)
		 else 
		 	npcsv += monog
		 endif 
	EndIf

	float TimeSinceKiss = Utility.GetCurrentGameTime() - getLastKissTime(npc)

	if TimeSinceKiss < 0.5
		npcsv += ( (100 - monog) * ((1 - TimeSinceKiss) * 2)  ) as int
	endif 

	if isPlayerPartner(npc)
		npcsv -= 30
	endif 

	if IsPlayerSpouse(npc)
		npcsv = -100
	endif

	;console("NPC kiss SV: " + npcsv)
	return npcSV
EndFunction 

bool Function TryKiss(actor npc)
	
	int playerSV = GetPlayerSV()
	int npcSV = GetKissSV(npc)
	;console("PlayerSV: " + playersv)
	if (game.GetFormFromFile(0x0F48,"ORomancePlus.esp") as GlobalVariable).GetValueInt() == 1
		debug.Notification("PlayerSV: " + playersv + " vs. NpcSV:"+npcsv)
	EndIf
	

	return (playerSV > npcSV)

EndFunction

; is prostitute | like stat | is married
int function GetAskOutSV(actor npc)

	int npcSV = GetNPCSV(npc)
	int prude = getPrudishnessStat(npc)


	if IsProstitute(npc)
		npcsv += 65
	EndIf

	float like = getlikeStat(npc)

	npcsv -= (like) as int


	if prude > 30
		;console(like)
		;console(npc.GetRelationshipRank(playerref))
	    if (like < 1) && (npc.GetRelationshipRank(playerref) < 1)
		    npcsv += 50
	    endif 
    endif

	if !IsMarried(npc)
		int monog = getMonogamyDesireStat(npc) ;1- 100

		npcSV -= ((monog - 50) * 1.25) as int
	else 
		 int monog = getMonogamyDesireStat(npc) ;1- 100

		 if monog > 50
		 	npcsv += (monog * 2)
		 else 
		 	npcsv += monog
		 endif 
	EndIf

	;console("NPC ask out SV: " + npcsv)

	return npcsv
endfunction 

bool Function TryAskOut(actor npc)
	int playerSV = GetPlayerSV()
	int npcsv = GetAskOutSV(npc)

	;console("PlayerSV: " + playersv)

	return (playerSV > npcSV)

EndFunction

int Function GetMarrySV(actor npc)
	int npcSV = GetNPCSV(npc)


	int prude = getPrudishnessStat(npc)


	if !isPlayerPartner(npc)
		npcsv += 100
	endif

	int love = getloveStat(npc) as int 

	if love < 16
		npcsv += ((15 - love) * 10)
	endif

	if !IsMarried(npc)
		int monog = getMonogamyDesireStat(npc) ;1- 100

		npcSV -= (monog - 50)

		npcSV -= (monog * 0.3) as int
	else 
		 npcSV += 300
	EndIf

	if HasGFBF(npc)
		npcSV += 50
	endif 

	npcsv += 125

	;console("NPC propose SV: " + npcsv)

	return npcsv
endfunction 

bool Function TryPropose(actor npc)
	int playerSV = GetPlayerSV()
	int npcSV = GetMarrySV(npc)


	;console("PlayerSV: " + playersv)
	

	return (playerSV > npcSV)

EndFunction

bool function IsFamiliarWithPlayer(actor npc)
	return (getlikeStat(npc) > 3) || (getloveStat(npc) > 2) || (npc.GetRelationshipRank(playerref) > 0)

endfunction


function CatchPlayerCheating(actor npc)
	If bridge.ostim.IsActorInvolved(npc) ; cheating bug fix
		return 
	endif 
	int monog = getMonogamyDesireStat(npc)
	if monog < 16 || playerref.hasPerk((Game.GetFormFromFile(0x000F32, "oromanceplus.esp") as perk))
		return 
	endif 
	int dislike = getdislikeStat(npc) as int

	if dislike > 18
		return 
	endif 

	oui.FireSuccessIncidcator(1)

	increasedislikestat(npc, Utility.Randomint(20, 29))
	increasehatestat(npc,  Utility.Randomint(4, 10))

	if Utility.RandomInt(0,100) <= 50
		if Utility.RandomInt(0,100) <= 50
			npc.StartCombat(playerref)
		else 
			npc.startcombat(bridge.ostim.getsexpartner(playerref))
		endif 


	endif 
	bridge.ostim.EndAnimation(false)
	Utility.Wait(2)

	int breakupChance = 30 + monog 

	if Utility.RandomInt(0,100) <= (breakupChance)
		BreakUpOrDivorce(npc)
		debug.Notification(npc.GetDisplayName() + " has broken up with you!")
	endif 

	debug.Notification(npc.GetDisplayName() + " has caught you cheating!")

endfunction 

function onload()
	;console("ORomance loading...")
	InteractKey = ORKey.GetValueInt() 
	RegisterForKey(InteractKey)
	if debugbuild
		RegisterForKey(184) ;ralt
	endif

	if bridge != None
		bridge.onload()
	endif
	oui.OnLoad()
EndFunction


bool Function MenuOpen() global
	return (Utility.IsInMenuMode() || UI.IsMenuOpen("console")) || UI.IsMenuOpen("Crafting Menu") || UI.IsMenuOpen("Dialogue Menu")
EndFunction

Event onKeyDown(int keyn)
	if bridge != None
		If MenuOpen() || oui.uiopen || (bridge.ostim.AnimationRunning() && bridge.ostim.isplayerinvolved())
			Return
		EndIf
	else
		If MenuOpen() || oui.uiopen
			Return
		EndIf
	endif

	If keyn == InteractKey
		actor target = game.GetCurrentCrosshairRef() as actor 

		if target 
			if  target.IsInCombat() || target.isChild() || target.isdead() || !(target.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC")))
				return 
			endif
			if isPlayerPartner(target) && (getlikeStat(target) < 1) 
				if Utility.RandomInt(0,100) <= 25
					Debug.Notification(target.GetDisplayName() + " wants a kiss!")
					kiss(target)
					return 
				endif
			endif 
			SeedIfNeeded(target)
			oui.EnterDialogueWith(target)
			if debugbuild
				Displaystats(target)
				;console("Player SV: " + GetPlayerSV())
			endif 
		endif 
	elseif keyn == 184
		test()
	EndIf
EndEvent

string property isSeededKey auto

string property BaseStatKey auto 
string property CustomStatKey auto

string property SexDesireKey Auto ; how much the NPC desires sex
string property PrudishnessKey Auto ; How open the NPC is to discussing sex
string property MonogamyDesireKey auto ; how committed the npc is to a single relationship 

string property SexualityKey auto

string property LoveKey Auto
string property LikeKey Auto
string property DislikeKey Auto
string property HateKey Auto

string property LikeLastAccessKey auto
string property DisLikeLastAccessKey auto
string property LastSeduceTimeKey auto
string property LastKissTimeKey auto


string property IsPlayerPartnerKey Auto

string property ProstitutionCostKey Auto




Function SetLookupKeys()
	SexDesireKey = "or_k_sexdesire"
	PrudishnessKey = "or_k_prudishness"
	MonogamyDesireKey = "or_k_monogamy"
	isSeededKey = "or_k_seeded"

	loveKey = "or_k_love"
	likeKey = "or_k_li"
	dislikeKey = "or_k_di"
	hateKey = "or_k_hate"

	LikeLastAccessKey = "or_k_li_last"
	DisLikeLastAccessKey = "or_k_di_last"

	LastSeduceTimeKey = "or_k_last_seduce"
	LastKissTimeKey = "or_k_last_kiss"

	BaseStatKey = "or_k_base"
	CustomStatKey = "or_k_customSV"

	IsPlayerPartnerKey = "or_k_part"

	ProstitutionCostKey = "or_k_cost"

	sexualitykey = "or_k_sexu"

EndFunction

int function GetSpeechStat(actor act)
	return act.GetActorValue("speechcraft") as int
EndFunction

int Function GetPlayerSV()
	;low - 19 (level 5 player with 23 speech)
	;medium - 78 (level 21 player with 45 speech)
	;high - 157 (level 33 player with 85 speech, one thane and one house)
	;Endgame - 220 (level 46 player with 100 speech, 3 houses and 4 thaneships)

	int speech = GetSpeechStat(playerref) - 15
	int playerLevel = playerref.Getlevel()
	int playerThaneCount = 0 
	int slayedAlduinStat = 0
	int isHarbingerStat = 0
	int hasAgentOfDibella = 0
	int propertyOwned = Game.QueryStat("Houses Owned")

	if (Quest.getQuest("MQ305").IsCompleted())
		slayedAlduinStat = 10
	EndIf
	if ( Quest.getQuest("C06").IsCompleted())
		isHarbingerStat = 3 
	EndIf
	;agent of dibella
	if ( Quest.getQuest("T01").IsCompleted())
		hasAgentOfDibella = 20
	EndIf
	;----- Thanes -----
	If (FavorJarlsMakeFriends.WhiterunImpGetOutofJail > 0 || FavorJarlsMakeFriends.WhiterunSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.EastmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.EastmarchSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.FalkreathImpGetOutofJail > 0 || FavorJarlsMakeFriends.FalkreathSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.HaafingarImpGetOutofJail > 0 || FavorJarlsMakeFriends.HaafingarSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.HjaalmarchImpGetOutofJail > 0 || FavorJarlsMakeFriends.HjaalmarchSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.PaleImpGetOutofJail > 0 || FavorJarlsMakeFriends.PaleSonsGetOutofJail > 0)
		playerThaneCount += 1	
	EndIf
	If (FavorJarlsMakeFriends.ReachImpGetOutofJail > 0 || FavorJarlsMakeFriends.ReachSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.WinterholdImpGetOutofJail > 0 || FavorJarlsMakeFriends.WinterholdSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf
	If (FavorJarlsMakeFriends.RiftImpGetOutofJail > 0 || FavorJarlsMakeFriends.RiftSonsGetOutofJail > 0)
		playerThaneCount += 1
	EndIf

	int charisma = speech + hasAgentofDibella
	int attractiveness = playerlevel
	int wealth = propertyOwned
	int fame = playerThaneCount + slayedAlduinStat + isHarbingerStat



	;apply multipliers
	charisma = (charisma * 1.2) as int
	attractiveness = (playerlevel) * 2
	fame = fame * 5
	wealth = wealth * 2

	float finalMult = 1

	int sv_total = (((charisma + attractiveness + fame + wealth) * finalMult) + GetDifficultyDiff()) as int
	Perk haremPerk = (Game.GetFormFromFile(0x000F32, "ORomancePlus.esp") as perk)
	GlobalVariable OREnableHaremPerk = (game.GetFormFromFile(0x0F4A,"ORomancePlus.esp") as GlobalVariable)
	if !playerref.hasPerk(haremPerk)
		if sv_total > 250
			if (OREnableHaremPerk.GetValueInt() == 1)
				playerref.addperk(haremPerk)
				playerref.addspell(Game.GetFormFromFile(0x000F33, "ORomancePlus.esp") as spell)
				debug.messagebox("Your charisma, fame, wealth, and attractiveness lets you now get away with cheating on your partners. They won't break up with you if caught cheating now. You're just too lovable!")
			endIf
		endif
	else
		if OREnableHaremPerk.GetValueInt() == 0
			playerref.removeperk(haremPerk)
			playerref.removespell(Game.GetFormFromFile(0x000F33, "ORomancePlus.esp") as spell)
		endif
	endif
	return sv_total
EndFunction

Function SeedIfNeeded(actor npc)
	if !isSeeded(npc)
		SeedStats(npc)
	EndIf
EndFunction

int hetero = 0
int bi = 1
int gay = 2

Function SeedStats(actor npc, bool reseed = false)
	Keyword sexDesire_Low = game.GetFormFromFile(0x000F3A, "ORomancePlus.esp") as Keyword
	Keyword sexDesire_Medium = game.GetFormFromFile(0x000F3B, "ORomancePlus.esp") as Keyword
	Keyword sexDesire_High = game.GetFormFromFile(0x000F3C, "ORomancePlus.esp") as Keyword

	Keyword Prudishness_Low = game.GetFormFromFile(0x000F3D, "ORomancePlus.esp") as Keyword
	Keyword Prudishness_Medium = game.GetFormFromFile(0x000F3E, "ORomancePlus.esp") as Keyword
	Keyword Prudishness_High = game.GetFormFromFile(0x000F3F, "ORomancePlus.esp") as Keyword

	Keyword MonogamyDesire_Low = game.GetFormFromFile(0x000F40, "ORomancePlus.esp") as Keyword
	Keyword MonogamyDesire_Medium = game.GetFormFromFile(0x000F41, "ORomancePlus.esp") as Keyword
	Keyword MonogamyDesire_High = game.GetFormFromFile(0x000F42, "ORomancePlus.esp") as Keyword

	Keyword oromance_hetero = game.GetFormFromFile(0x000F43, "ORomancePlus.esp") as Keyword
	Keyword oromance_homosexual = game.GetFormFromFile(0x000F44, "ORomancePlus.esp") as Keyword
	Keyword oromance_bisexual = game.GetFormFromFile(0x000F45, "ORomancePlus.esp") as Keyword

	if reseed
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,sexDesire_Low)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,sexDesire_Medium)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,sexDesire_High)

		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,Prudishness_Low)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,Prudishness_Medium)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,Prudishness_High)

		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,MonogamyDesire_Low)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,MonogamyDesire_Medium)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,MonogamyDesire_High)

		
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,oromance_hetero)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,oromance_homosexual)
		PO3_SKSEFunctions.RemoveKeywordFromRef(npc,oromance_bisexual)

	endif

	StorageUtil.SetIntValue(npc, BaseStatKey, createBaseValue(npc))
	StorageUtil.SetIntValue(npc, CustomStatKey, 0)
	if npc.HasKeyword(sexDesire_Low)
		StorageUtil.SetIntValue(npc, SexDesireKey, Utility.RandomInt(1, 33))
	Elseif npc.hasKeyword(sexDesire_Medium)
		StorageUtil.SetIntValue(npc, SexDesireKey, Utility.RandomInt(34, 66))
	Elseif npc.hasKeyword(sexDesire_High)
		StorageUtil.SetIntValue(npc, SexDesireKey, Utility.RandomInt(67, 100))
	Else
		int randomSexDesire = Utility.RandomInt(1, 100)
		StorageUtil.SetIntValue(npc, SexDesireKey, randomSexDesire)
		if randomSexDesire <34
			PO3_SKSEFunctions.AddKeywordToRef(npc, sexDesire_Low)
		ElseIf randomSexDesire >33 && randomSexDesire < 67
			PO3_SKSEFunctions.AddKeywordToRef(npc, sexDesire_Medium)
		Else
			PO3_SKSEFunctions.AddKeywordToRef(npc, sexDesire_High)
		endif
	endif

	if npc.HasKeyword(Prudishness_Low)
		StorageUtil.SetIntValue(npc, PrudishnessKey, Utility.RandomInt(1, 33))
	Elseif npc.hasKeyword(Prudishness_Medium)
		StorageUtil.SetIntValue(npc, PrudishnessKey, Utility.RandomInt(34, 66))
	Elseif npc.hasKeyword(Prudishness_High)
		StorageUtil.SetIntValue(npc, PrudishnessKey, Utility.RandomInt(67, 100))
	Else
		int randomPrudishness = Utility.RandomInt(1, 100)
		StorageUtil.SetIntValue(npc, PrudishnessKey, randomPrudishness)
		if randomPrudishness <34
			PO3_SKSEFunctions.AddKeywordToRef(npc, Prudishness_Low)
		ElseIf randomPrudishness >33 && randomPrudishness < 67
			PO3_SKSEFunctions.AddKeywordToRef(npc, Prudishness_Medium)
		Else
			PO3_SKSEFunctions.AddKeywordToRef(npc, Prudishness_High)
		endif
	endif

	if npc.HasKeyword(MonogamyDesire_Low)
		StorageUtil.SetIntValue(npc, MonogamyDesireKey, Utility.RandomInt(1, 15))
	Elseif npc.hasKeyword(MonogamyDesire_Medium)
		StorageUtil.SetIntValue(npc, MonogamyDesireKey, Utility.RandomInt(16, 66))
	Elseif npc.hasKeyword(MonogamyDesire_High)
		StorageUtil.SetIntValue(npc, MonogamyDesireKey, Utility.RandomInt(67, 100))
	Else
		int randomMonogamyDesire = Utility.RandomInt(1, 100)
		StorageUtil.SetIntValue(npc, MonogamyDesireKey, randomMonogamyDesire)
		if randomMonogamyDesire <16
			PO3_SKSEFunctions.AddKeywordToRef(npc, MonogamyDesire_Low)
		ElseIf randomMonogamyDesire >15 && randomMonogamyDesire < 67
			PO3_SKSEFunctions.AddKeywordToRef(npc, MonogamyDesire_Medium)
		Else
			PO3_SKSEFunctions.AddKeywordToRef(npc, MonogamyDesire_High)
		endif
	endif


	StorageUtil.SetFloatValue(npc as form, lovekey, 0.0)
	StorageUtil.SetFloatValue(npc as form, likekey, 0.0)
	StorageUtil.SetFloatValue(npc as form, dislikekey, 0.0)
	StorageUtil.SetFloatValue(npc as form, hatekey, 0.0)

	float time =  Utility.GetCurrentGameTime()

	StorageUtil.SetFloatValue(npc as form, LikeLastAccessKey, time)
	StorageUtil.SetFloatValue(npc as form, DisLikeLastAccessKey, time)

	StorageUtil.SetFloatValue(npc as form, LastSeduceTimeKey, 0)
	StorageUtil.SetFloatValue(npc as form, LastKissTimeKey, 0)

	StoreNPCDataBool(npc, IsPlayerPartnerKey, false)

	if npc.HasKeyword(oromance_hetero)
		StorageUtil.SetIntValue(npc, SexualityKey, 0)
	Elseif npc.hasKeyword(oromance_homosexual)
		StorageUtil.SetIntValue(npc, SexualityKey, 2)
	Elseif npc.hasKeyword(oromance_bisexual)
		StorageUtil.SetIntValue(npc, SexualityKey, 1)
	else
		int num = Utility.RandomInt(1, 100)
		int sexuality ; 0 - straight  / 1 bisexual / 2 - gay
		if getGender(npc)
			if num < 91
				sexuality = hetero
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_hetero)
			elseif num < 96
				sexuality = bi 
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_bisexual)
			else 
				sexuality = gay 
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_homosexual)
			endif
		else 
			if num < 78
				sexuality = hetero
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_hetero)
			elseif num < 97
				sexuality = bi 
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_bisexual)
			else 
				sexuality = gay
				PO3_SKSEFunctions.AddKeywordToRef(npc, oromance_homosexual)
			endif
		endif 
		StorageUtil.SetIntValue(npc, SexualityKey, sexuality)
	endif

	int mult = 10
	if npc.IsInFaction(FavorJobsBeggarFaction)
		mult = 1
	endif 
	int cost = GetBaseValue(npc) * mult
	cost -= (getSexDesireStat(npc) - 50) * mult
	if cost < 1
		cost = 1
	endif

	StorageUtil.SetIntValue(npc, ProstitutionCostKey, cost)

	;calculation
	if Game.GetModByName("OVirginity.esp") != 255
		ovirgintiy.calculateVirginity(npc)
	else
		bool virginityNum = (Utility.RandomInt(0,100) <= 5 )
		StorageUtil.SetIntValue(npc as form, "IsVirginKey", virginityNum as Int )
	endif

	StoreNPCDataBool(npc, isSeededKey, true)
EndFunction

bool function isSeeded(actor npc)
	return GetNPCDataBool(npc, isSeededKey)
EndFunction

float function canGiveMeal(actor npc)
	float diff = Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(npc, "or_k_last_meal", -1.0)
	return diff
EndFunction

function setGaveMealTime(actor npc)
	StorageUtil.SetFloatValue(npc as form, "or_k_last_meal", Utility.GetCurrentGameTime())
EndFunction

bool function Givemeal(actor npc)
	float diff = canGiveMeal(npc)
	if diff >= 1
		debug.SendAnimationEvent(npc, "idlegive")
		Game.GetPlayer().AddItem(game.GetFormFromFile(0x0CD614, "skyrim.esm") as potion)
		if npc.GetBaseObject().GetName() == "Serana"
			saytopic(npc, game.getFormFromFile(0x00080E,"ORomancePlus.esp") as topic)
		else
			saytopic(npc, game.GetFormFromFile(0x000818, "ORomancePlus.esp") as topic)
		endif
		setGaveMealTime(npc)
		return true
	Else
		debug.notification("come back in " + (diff * 24 as int) + " hours for a meal!")
		return false
	endif
EndFunction

float function getStoreMoneyDiff(actor npc)
	float diff = Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(npc, "or_k_last_store_money", -1.0)
	return diff
EndFunction

function giveStoreMoney(actor npc)
	float diff = getStoreMoneyDiff(npc)
	int goldAmount = ((diff) as int) * 100
	debug.SendAnimationEvent(npc, "idlegive")
	Game.GetPlayer().AddItem(gold, goldAmount)
	saytopic(npc, game.getFormFromFile(0x000FE1, "ORomancePlus.esp") as topic)
	StorageUtil.SetFloatValue(npc as form, "or_k_last_store_money", Utility.GetCurrentGameTime())
EndFunction

bool function isPlayerPartner(actor npc)
	return GetNPCDataBool(npc, IsPlayerPartnerKey)
EndFunction

bool function setPlayerPartner(actor npc, bool partner)
	if partner 
		StoreNPCDataBool(npc, IsPlayerPartnerKey, true)
		npc.SetRelationshipRank(playerref, 4)
		playerref.SetRelationshipRank(npc, 4)
		increaselovestat(npc, 3)
	else
		StoreNPCDataBool(npc, IsPlayerPartnerKey, false)
	EndIf
EndFunction

int function GetSexuality(actor npc, bool true_value = false)
	if !EnableSexuality() && !true_value
		return bi 
	endif 
	return StorageUtil.GetIntValue(npc, SexualityKey ,-1)
endfunction

function StoreSexuality(actor npc, int val)
	StorageUtil.SetIntValue(npc, SexualityKey, val)
endfunction

function BreakUpOrDivorce(actor npc)
	npc.RemoveFromFaction(MarriageCourtFaction) ;de-couples away from the breakup quests
	if IsPlayerSpouse(npc)
		npc.RemoveFromFaction(PlayerMarriedFaction)
		npc.RemoveFromFaction(MarriageAskedFaction) ;marriageAskedFaction
		
		debug.notification("You have divorced "+npc.GetDisplayName())

		if (isPlayerVanillaSpouse(npc))
			npc.RemoveFromFaction(VanillaSpouseFaction)
			RelationshipMarriage.reset()
			Quest relationshipmarriagewedding = Quest.getQuest("relationshipmarriagewedding")
			relationshipmarriagewedding.reset()
			RelationshipMarriageFin.Reset()
		else
			;OR spouse
			;check which spouse alias the actor is
			ORomanceSpouseHouseScript ORomanceSpouseHouseTracker = game.GetFormFromFile(0x00082C, "ORomancePlus.esp") as ORomanceSpouseHouseScript
			int spouseAliasIndex = ORomanceSpouseHouseTracker.getSpouseAliasIndexFromActor(npc)
			if spouseAliasIndex != -1
				ORomanceSpouseHouseTracker.getSpouseAliasFromIndex(spouseAliasIndex).clear()
				ORomanceSpouseHouseTracker.clearSpouseHomesFromId(spouseAliasIndex + 1)
				npc.RemoveFromFaction(ORSpouseMerchantFaction)
				int or_spouses = (game.GetFormFromFile(0x0A09,"ORomancePlus.esp") as GlobalVariable).GetValueInt()
				(game.GetFormFromFile(0x0A09,"ORomancePlus.esp") as GlobalVariable).SetValueInt(or_spouses - 1)
			endif



		endif
		increasehatestat(npc, 5)
		Form ring = game.GetFormFromFile(0x0C5809, "skyrim.esm")
		npc.removeitem(ring)
	else
		ReferenceAlias spouse_alias
		;ORomance Marriage quest is currently active and the npc you want to breakup with is the LoveInterest
		if isORMarriageLocked()
			Quest RelationshipMarriage_OR = Quest.getQuest("RelationshipMarriage_OR")
			spouse_alias = RelationshipMarriage_OR.getAlias(0) as ReferenceAlias
			if npc == spouse_alias.getReference()
				Quest relationshipmarriagewedding_OR = Quest.getQuest("relationshipmarriagewedding_OR")
				RelationshipMarriage_OR.reset()
				relationshipmarriagewedding_OR.reset()
				;unlock OR Marriage semaphore
				(game.GetFormFromFile(0x0F62,"ORomancePlus.esp") as GlobalVariable).SetValueInt(0)
			endif	
		elseif (RelationshipMarriage.isRunning())
			spouse_alias = RelationshipMarriage.getAlias(0) as ReferenceAlias
			if npc == spouse_alias.getReference()
				Quest relationshipmarriagewedding = Quest.getQuest("relationshipmarriagewedding")
				relationshipmarriagewedding.reset()
				RelationshipMarriage.reset()
			endif
		endif

		increasehatestat(npc, 2)
		debug.notification("You have broken up with "+npc.GetDisplayName())
	endif


	setplayerpartner(npc, false) 
	getdislikeStat(npc)
	setdislikestat(npc, 30)
	increaselovestat(npc, -10)
	npc.SetRelationshipRank(playerref, -2)
	playerref.SetRelationshipRank(npc, -2)
	SayTopic(npc, whatthe)
	oui.FireSuccessIncidcator(2)
endfunction 

int function getPrositutionCost(actor npc)
	return StorageUtil.GetIntValue(npc, ProstitutionCostKey, -1)
EndFunction

function setProstitutionCost(actor npc, int cost)
	StorageUtil.SetIntValue(npc, ProstitutionCostKey, cost)
EndFunction

int function getSexDesireStat(actor npc)
	return StorageUtil.GetIntValue(npc, sexdesirekey, -1)
EndFunction

int function getPrudishnessStat(actor npc)
	return StorageUtil.GetIntValue(npc, Prudishnesskey, -1)
EndFunction

int function getMonogamyDesireStat(actor npc)
	return StorageUtil.GetIntValue(npc, Monogamydesirekey, -1)
EndFunction

function increaselovestat(actor npc, float val)
	int curr = getloveStat(npc) as int
	if curr >= 30
		return 
	endif 

	setlovestat(npc, val + curr)
EndFunction

function setlovestat(actor npc, float val)
	if val < 0
		val = 0
	endif 
	StorageUtil.SetFloatValue(npc as form, lovekey, val)
EndFunction 

function setlikestat(actor npc, float val)
	if val > 30
		val = 30
	endif
	StorageUtil.SetFloatValue(npc as form, likekey, val)
EndFunction 

float function getloveStat(actor npc)
	return StorageUtil.GetFloatValue(npc, lovekey, -1.0)
EndFunction

float function getLastSeduceTime(actor npc)
	return StorageUtil.GetFloatValue(npc, LastSeduceTimeKey, -1.0)
EndFunction

function setLastSeduceTime(actor npc)
	StorageUtil.SetFloatValue(npc as form, LastSeduceTimeKey, Utility.GetCurrentGameTime())
EndFunction

float function getLastKissTime(actor npc)
	return StorageUtil.GetFloatValue(npc, LastKissTimeKey, -1.0) 
EndFunction

function setLastKissTime(actor npc)
	StorageUtil.SetFloatValue(npc as form, LastKissTimeKey, Utility.GetCurrentGameTime())
EndFunction

float function getlikeStat(actor npc)
	float lastCalcTime = StorageUtil.GetFloatValue(npc, LikeLastAccessKey, -1.0)
	float like = StorageUtil.GetFloatValue(npc, likekey, -1.0)
	float currTime = Utility.GetCurrentGameTime()
	float diff = currtime - lastCalcTime

	like -= (diff * 3) ; deteriorate 3/day

	if like < 0
		like = 0
	endif 

	StorageUtil.SetFloatValue(npc as form, LikeLastAccessKey, currtime)
	StorageUtil.SetFloatValue(npc as form, likekey, like)
	return like
EndFunction

function increaselikestat(actor npc, float val)
	float curr = getlikeStat(npc)
	if curr >= 30
		return 
	endif 

	setlikestat(npc, val + curr)
EndFunction

float function getdislikeStat(actor npc)
	float lastCalcTime = StorageUtil.GetFloatValue(npc, disLikeLastAccessKey, -1.0)
	float dislike = StorageUtil.GetFloatValue(npc, dislikekey, -1.0)
	float currTime = Utility.GetCurrentGameTime()
	float diff = currtime - lastCalcTime

	dislike -= (diff * 3) ; deteriorate 3/day

	if dislike < 0
		dislike = 0
	endif 

	StorageUtil.SetFloatValue(npc as form, disLikeLastAccessKey, currtime)
	StorageUtil.SetFloatValue(npc as form, dislikekey, dislike)
	return dislike
EndFunction

function increasedislikestat(actor npc, float val)
	float curr = getdislikeStat(npc)
	if curr >= 30
		return 
	endif 

	setdislikestat(npc, val + curr)
EndFunction

function setdislikestat(actor npc, float val)
	StorageUtil.SetFloatValue(npc as form, DislikeKey, val)
EndFunction 

float function gethateStat(actor npc)
	return StorageUtil.GetFloatValue(npc, hatekey, -1.0)
EndFunction

function increasehatestat(actor npc, float val)
	int curr = gethateStat(npc) as int
	
	if curr >= 30
		return 
	endif 

	curr = (val + curr) as int

	sethatestat(npc, val + curr)


	if !isPlayerPartner(npc)
		int rel = npc.GetRelationshipRank(playerref)
		if rel > -2
			if curr > 9
				npc.SetRelationshipRank(playerref, -2)
				playerref.SetRelationshipRank(npc, -2)
			endif 
		endif 
	endif 

	if (curr > 19) && isPlayerPartner(npc)
		if Utility.RandomInt(0,100) <= 50
			BreakUpOrDivorce(npc)
		endif 
	endif 
EndFunction

function sethatestat(actor npc, float val)
	if val < 0
		val = 0
	endif 
	StorageUtil.SetFloatValue(npc as form, HateKey, val)
EndFunction 

int function GetBaseValue(actor npc)
	return StorageUtil.GetIntValue(npc, BaseStatKey, -1)
EndFunction

int function GetCustomValue(actor npc)
	return StorageUtil.GetIntValue(npc, CustomStatKey, -1)
EndFunction

bool Function IsMarried(actor npc)
	if isPlayerSpouse(npc)
		return true
	;check if isWidowed
	elseif isWidowed(npc)
		return false
	elseif npc.HasAssociation(Spouse)
		return true
	else
		return false
	endif
endFunction

bool Function IsWidowed(actor npc)
	if isPlayerSpouse(npc)
		return false
	endif
	actorbase[] spouses = GetSpouses(npc)
	int i = 0
	int l = spouses.Length
	if l == 0
		return false
	endif
	while i < l 
		if spouses[i].getDeadCount() >= 1
			return true 
		endif 

		i += 1
	endwhile

	return false 
EndFunction

bool Function IsGFBFDead(actor npc)
	actorbase[] partners = GetPartners(npc)
	int i = 0
	int l = partners.Length
	while i < l 
		if partners[i].getDeadCount() >= 1
			return true 
		endif 

		i += 1
	endwhile

	return false 
EndFunction


ActorBase[] Function GetSpouses(actor npc)
	ActorBase[] spouses = LookupRelationshipPartners(npc, spouse)

	return spouses
EndFunction

actorBase[] Function GetPartners(actor npc)
	ActorBase[] partners = LookupRelationshipPartners(npc, Courting)
	return partners
EndFunction


Actorbase[] function LookupRelationshipPartners(Actor npc, AssociationType rel)
	return PO3_SKSEFunctions.GetRelationships(npc.getActorBase(), rel)
EndFunction

string function GetPartnerString(actor npc)
	string ret = " with "
	int i = 1
	int l

	actorbase[] partners = GetPartners(npc)
	ret = ret + partners[0].getName()
	l = partners.Length
	while i < l 
		ret = ret + ", " + (partners[i]).getName()

		i += 1
	endwhile

	return ret
endfunction

string function GetSpouseString(actor npc)
	string ret = " to "
	int i = 1
	actorbase[] spouses = GetSpouses(npc)
	ret = ret + (spouses[0]).getName()
	int l = spouses.Length
	while i < l 
		ret = ret + ", " + (spouses[i]).getName()

		i += 1
	endwhile

	return ret
endfunction

bool Function IsSpouseNearby(actor npc)
		actor[] nearby = MiscUtil.ScanCellNPCs(npc, radius = 0.0)

		int i = 0
		int l = nearby.length 

		while i < l
			if IsNPCSpouse(nearby[i], npc) || IsNPCGFBF(nearby[i], npc)
				return True
			endif 

			i += 1
		endwhile

		return false
endfunction

bool function IsNPCSpouse(actor npc, actor otherNPC)
	return npc.HasAssociation(spouse, othernpc)
endfunction 

bool Function HasGFBF(actor npc)
	if npc.HasAssociation(Courting)
		return !IsGFBFDead(npc)
	else 
		return false
	endif 
EndFunction

bool function IsNPCGFBF(actor npc, actor otherNPC)
	return npc.HasAssociation(Courting, othernpc)
endfunction 

bool Function IsPlayerSpouse(actor npc)
	return npc.isInFaction(PlayerMarriedFaction) 
EndFunction

bool Function isPlayerVanillaSpouse(actor npc)
	return npc.isInFaction(VanillaSpouseFaction)
EndFunction

bool Function isMarriageQuestActive()
	return RelationshipMarriage.getstage() >= 20
endFunction

bool Function IsVirgin(actor npc)
	if Game.GetModByName("OVirginity.esp") != 255
		return ( StorageUtil.GetIntValue(npc, "IsVirgin", -1) as bool )
	else
		return ovirgintiy.isVirgin(npc)
	endif
EndFunction

bool Function IsProstitute(actor npc)
	if Game.getModByName("OVirginity.esp") != 255
		return  npc.IsInFaction(jobInnServer) || npc.IsInFaction(FavorJobsBeggarFaction) || npc.IsInFaction(MarkarthTempleofDibellaFaction)
	else
		return ovirgintiy.isProstitute(npc)
	endif
EndFunction

int Function createBaseValue(actor npc)
	int value = 0

	actorbase npcBase = npc.GetActorBase()

	bool unique = npcBase.isunique()
	bool protected = npcBase.IsProtected()
	bool essential = npcBase.IsEssential()

	bool isJarl = npc.IsInFaction(JarlFaction)

	bool isGuard = npc.IsGuard()

	if unique
		value += (100) as int

		if protected
			value += (15) as int
		EndIf

		if essential
			value += (20) as int
		EndIf

		if isJarl
			value += 50
		EndIf

		value += Utility.RandomInt(-15, 15)
	else 
		value += Utility.RandomInt(60, 140)

		if isGuard
			value += 30
		EndIf
	EndIf

	


	return value

EndFunction

function DisplayStats(actor npc)
	console("-------------------------------")
	console("Stats for: " + npc.GetDisplayName())

	console("Base SV: " + GetBaseValue(npc))
	console("Custom SV mod:" + GetCustomValue(npc))

	console("Sex desire: " + getSexDesireStat(npc))
	console("Prudishness: " + getPrudishnessStat(npc))
	console("Monogamy desire: " + getMonogamyDesireStat(npc))
	
	console("Love stat: " + getLoveStat(npc))
	console("Like stat: " + getLikeStat(npc))
	console("Disike stat: " + getDislikeStat(npc))
	console("Hate stat: " + getHateStat(npc))

	console("Last seduce time: " + getLastSeduceTime(npc))
	console("Last kiss time: " + getLastKissTime(npc))

	console("Married: " + IsMarried(npc))
	console("Jarl: " + npc.IsInFaction(JarlFaction))
	string sexu
	int sexint = GetSexuality(npc)
	if sexint == hetero 
		sexu = "Heterosexual"
	elseif sexint == bi 
		sexu = "Bisexual"
	else 
		sexu = "Gay"
	endif 

	console("Sexuality: " + sexu)

	console("Virgin: " + IsVirgin(npc))
	console("Prostitute: " + IsProstitute(npc))
	console("Prostitution price: " + getPrositutionCost(npc))
	console("Player partner: " + isPlayerPartner(npc))

	console("-------------------------------")
EndFunction



int Function GetTimeOfDay() global ; 0 - day | 1 - morning/dusk | 2 - Night
	float hour = GetCurrentHourOfDay()

	if (hour < 4) || (hour > 20 ) ; 8:01 to 3:59. night
		return 2
	elseif ((hour >= 18) && (hour <= 20))  || ((hour >= 4) && (hour <= 6)) ; morning/dusk
		return 1
	Else
		return 0
	endif
		
EndFunction

float Function GetCurrentHourOfDay() global
 
	float Time = Utility.GetCurrentGameTime()
	Time -= Math.Floor(Time) ; Remove "previous in-game days passed" bit
	Time *= 24 ; Convert from fraction of a day to number of hours
	Return Time
 
EndFunction

function TryApology(actor npc)

	int successChance
	int criticalFailChance

	if getHateStat(npc) < 10
		criticalFailChance = 10
	else 
		criticalFailChance = 100
	endif 

	successChance = 50
	StorageUtil.SetFloatValue(npc as form, "or_k_last_apology", Utility.GetCurrentGameTime())
	if Utility.RandomInt(0,100) <= successChance
		oui.FireSuccessIncidcator(0)
		increasedislikestat(npc, -3)
		if getdislikeStat(npc) < 20
			sayTopic(npc, (Game.GetFormFromFile(0x000F4B, "ORomancePlus.esp") as topic))
			debug.notification(npc.GetDisplayName() + " has accepted your apology and decided to let bygones be bygones!")
			oui.showpage(1)
		endif 
	Else
		
		if Utility.RandomInt(0,100) <= (criticalFailChance)
			oui.FireSuccessIncidcator(2)
			increasedislikestat(npc, 1)
			sayTopic(npc, Game.GetFormFromFile(0x000F4E, "ORomancePlus.esp") as topic)
			debug.notification(npc.GetDisplayName() + " is pissed!")
		else 
			oui.FireSuccessIncidcator(1)
			sayTopic(npc,  Game.GetFormFromFile(0x000F51, "ORomancePlus.esp") as topic)
			debug.notification(npc.GetDisplayName() + " rejects your apology.")
		endif 
		;oui.exitdialogue(0)
	endif


endfunction

bool function IsOkToEjaculateInside(actor npc)
	if IsPlayerSpouse(npc)
		return True
	elseif isplayerpartner(npc)
		if (getMonogamyDesireStat(npc) > 15) || (getSexDesireStat(npc) > 75)
			return true 
		endif 
	else 
		if (getMonogamyDesireStat(npc) > 71) || (getSexDesireStat(npc) > 85)
			return true 
		endif 
	endif
	return false
endfunction

int function GetNearbyNPCCount()
	return (miscutil.ScanCellNPCs(playerref, 640)).length - 2
EndFunction

int function gift(actor npc)
	if canGiveGift(npc)
		return npc.ShowGiftMenu(true, apFilterList = None,  abShowStolenItems = true, abUseFavorPoints = true)
	else
		debug.notification(npc.GetDisplayName() +" won't accept another gift. Try again tomorrow.")
		oui.FireSuccessIncidcator(1)
	endif
EndFunction

bool function canCompliment(actor npc)
	float diff = Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(npc, "or_k_last_compliment", -1.0)
	if diff > 1
		return true
	else
		return false
	endif
EndFunction

function compliment(actor npc)
	int playerSpeech = GetSpeechStat(playerref)

	if playerSpeech < getSpeechStat(npc)
		increasedislikestat(npc, Utility.RandomInt(1, 3))
		StorageUtil.SetFloatValue(npc as form, "or_k_last_compliment", Utility.GetCurrentGameTime())
		oui.FireSuccessIncidcator(1)
		return
	endif
	int like = ( playerSpeech/ 3.33) as Int
	int currLike = getlikestat(npc) as Int ; current like stat

	StorageUtil.SetFloatValue(npc as form, "or_k_last_compliment", Utility.GetCurrentGameTime())

	oui.FireSuccessIncidcator(0)
	increaselikestat(npc, like)
	Topic thankyou =  Game.GetFormFromFile(0x006E6C, "ORomance.esp") as topic
	SayTopic(npc, thankyou)
EndFunction

function insult(actor npc) ; todo make hate stat lower rel rank
	int currDis = getdislikeStat(npc) as int 

	if currDis > 5
		increasehatestat(npc, Utility.RandomInt(1, 2))
	endif

	if Utility.RandomInt(0,100) <=25
		SayTopic(npc, whatthe)
	endif 
	increasedislikestat(npc, Utility.RandomInt(1, 3))
	oui.FireSuccessIncidcator(1)
endfunction

Function kiss(actor npc)
	if IsMarried(npc) || HasGFBF(npc)
		if IsSpouseNearby(npc)
			debug.Notification(npc.GetDisplayName() + " wants to kiss but their partner is nearby")
			return 
		endif 
	endif
	int playerGender = playerref.getActorBase().getSex()
	int npcGender = npc.GetActorBase().getSex()
	if playerGender == 0 && npcGender == 1
		bridge.startscene(playerref, npc, true)
	elseif playerGender == 1 && npcGender == 0
		bridge.startscene(npc, playerref, true)
	else
		;non-straight, randomize dom/sub
		if Utility.RandomInt(0,100) <= 50
			bridge.startscene(playerref, npc, true)
		else
			bridge.startscene(npc, playerref, true)
		endif
	endif
	setLastKissTime(npc)

	int like = 15
	int monog = getMonogamyDesireStat(npc)
	like = (((monog as float) / 100) * like) as int
	int currLike = getlikestat(npc) as Int
	int targetLike

	if IsPlayerSpouse(npc)
		targetLike = 20
		increaselovestat(npc, 1)
	elseif isPlayerPartner(npc)
		targetLike = 15
		if Utility.RandomInt(0,100) <= 50
			increaselovestat(npc, 1)
		endif 
	
	else 
		targetLike = 10
	endif 

	if (like + currLike) > targetLike
		like = targetLike - currLike
	endif 

	increaselikestat(npc, like)

EndFunction

bool function canApologize(actor npc)
	float diff = Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(npc, "or_k_last_apology", -1.0)
	if diff > 1
		return true
	else
		return false
	endif
endFunction
bool function canGiveGift(actor npc)
	float diff = Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(npc, "or_k_last_gift", -1.0)
	if diff > 1
		return true
	else
		return false
	endif
EndFunction

function ProcessGift(actor npc, int value, bool apology=false) 
	if value == 0
		return 
	endif 
	debug.SendAnimationEvent(npc, "idletake")
	StorageUtil.SetFloatValue(npc as form, "or_k_last_gift", Utility.GetCurrentGameTime())
	SR_ProcessGift(npc, value)

	if apology
		float dislike = (value / 100) * -1
		float Lastdislike = getdislikeStat(npc)
		increasedislikestat(npc, dislike)
		oui.FireSuccessIncidcator(0)
		if getdislikeStat(npc) < 20
			oui.showpage(1)
		endif 
	Else
		float like = 1 + (value / 100)
		float LastLike = getlikeStat(npc)
		increaselikestat(npc, like)
		Topic thankyou =  Game.GetFormFromFile(0x006E6C, "ORomance.esp") as topic
		SayTopic(npc, thankyou)
		oui.FireSuccessIncidcator(0) 
endif
EndFunction

actor[] Function CheckForFollowers()
	actor[] nearby = MiscUtil.ScanCellNPCsByFaction(followerfaction, playerref, radius = 0.0,  minRank = 0,  maxRank = 127,  IgnoreDead = true)
	;console(nearby.length)

	return nearby
EndFunction


Event OnUpdate() ;todo test across saves
	actor[] followers = CheckForFollowers()

	if followers.length > 0
		int i = 0
		int l = followers.length 

		while i < l
			oui.FireSuccessIncidcator(0)
			SeedIfNeeded(followers[i])
			increaselovestat(followers[i], 1)

			i += 1
		endwhile 

	else 
		;console("no followers")
	endif

	;RegisterForSingleUpdate(5)
	RegisterForSingleUpdate(1200) ; 20 minutes
EndEvent

function SayTopic(actor npc, topic ztopic)
	npc.AddToFaction(dialoguefaction)
	npc.say(ztopic)
	Utility.wait(0.1)
	npc.RemoveFromFaction(dialoguefaction)
endfunction

function test()
	console("Running test code")

	;none
EndFunction

function console(string in)
	if !debugbuild
		return
	endif 
	OsexIntegrationMain.Console(in)
EndFunction

;------------------------------Skyromance---------------------
string Property FactionFameKey = "SRK_FactionFame" Auto
string Property QuestFavorKey = "SRK_QuestFavor" Auto
string Property GiftFavorKey = "SRK_GiftFavor" Auto

string property GivenGiftsLog = "Data/SkyRomance/Log/GivenGiftsLog.json" auto
string property NPCFavorGiftPath = "Data/SkyRomance/NPCFavorGift.json" auto

string SkyRomance = "SkyRomance.esp"

SkyRomanceInitQuestScript SkyRomanceScript

int GVSRDebugEnabled = 0x00EFF8
int GVSRGiftFavorMultiplier = 0x00EFF9
int GVSRFactionAffinity = 0x00EFFA
int GVSRQuestFavor = 0x00EFFB

import StringUtil

int Function GetAffinityForNPCFaction(actor NPC)
	debug.Trace("Getting faction affinity for " + NPC.getdisplayName())
	Faction[] FactionList = NPC.GetFactions(0, 127)
	int len = FactionList.Length
	int i = 0
	int TotalAffinity = 0
	while i < len
		If (FactionList[i])
			TotalAffinity += StorageUtil.GetIntValue(FactionList[i], FactionFameKey)
		EndIf
		i += 1
	EndWhile
	return TotalAffinity
EndFunction

int Function GetQuestFavorStat(actor NPC)
	return StorageUtil.GetIntValue(NPC, QuestFavorKey)
EndFunction

int Function GetGiftFavorStat(actor NPC)
	return StorageUtil.GetIntValue(NPC, GiftFavorKey)
EndFunction

Function SR_ProcessGift(Actor NPC, float TotalValue)
	;Get map: 1. Given gifts 2. Npc favor gift keywords
	int GivenGiftLog = JValue.readFromFile(GivenGiftsLog)
	string[] GiftEditID = JMap.allKeysPArray(GivenGiftLog)

	int NPCFavorMap = JValue.readFromFile(NPCFavorGiftPath)
	string NPCFavorString = JMap.getStr(NPCFavorMap, NPC.GetDisplayName())
	string[] NPCFavorList = Split(NPCFavorString, "|")
	Debug.Trace(NPC.GetDisplayName() + "'s Favor string: " + NPCFavorString)

	;Make a map for Npc's favor gift type/keyword
	Debug.Trace("Now making a map to store " + NPC.GetDisplayName() + "'s favor keywords of gifts!")
	int FavorKeywordMap = JMap.object()
	int j = 0
	int jLen = NPCFavorList.Length
	int FavorValue
	while (j < jLen)
		string CurString = NPCFavorList[j]
		Debug.trace("Current string: " + CurString)
		If (Substring(CurString, 0, 1) != "-" && Substring(CurString, 0, 1) != "+")
			JMap.Setint(FavorKeywordMap, CurString, FavorValue)
			debug.trace("Favor keyword added: " + CurString + ": " + FavorValue + " ! ")
		Else
			FavorValue = Substring(CurString, 1, GetLength(CurString) - 1) as int
			if (Substring(CurString, 0, 1) == "-")
				FavorValue = -FavorValue
			Endif
			Debug.Trace("Favor value changed to: " + FavorValue)
		EndIf
		j += 1
	Endwhile
	;End of making map

	;Loop through all gifts, fore each type of gift, get npc's favors, and find if any of them in current 
	int Len = GiftEditID.Length
	int i = 0
	int GiftFavorToAdd
	While (i < Len)
		;Current gift
		Debug.Trace("Current gift: " + GiftEditID[i])
		string CurGift = GiftEditID[i]
		Form CurGiftForm = SkyRomanceMiscFunction.GetFormByEditorID(CurGift)
		Keyword[] GiftKeywords = CurGiftForm.GetKeywords()

		int k = 0
		int keywordLen = GiftKeywords.Length
		While (k < keywordLen)
			Debug.Trace("Searching for keyword in NPC's interest list: " + GiftKeywords[k].GetString())
			;Current keyword
			string CurKeyword = GiftKeywords[k].GetString()
			if (JMap.hasKey(FavorKeywordMap, CurKeyword))
				;If this keyword is in NPC's favor list
				;Calculate favor multiplier
				;float CurFavorMult = JMap.getFlt(FavorKeywordMap, CurKeyword) * Jmap.getInt(GivenGiftLog, CurGift) * GetExternalFloat("SkyRomance.esp", 0x00EFF9)/10 ;Favor mult * count * 0.05(default)
				;FinalMult = FinalMult + CurFavorMult
				int CurKeywordFavorValue = JMap.getInt(FavorKeywordMap, CurKeyword) * JMap.getInt(GivenGiftLog, CurGift)
				GiftFavorToAdd += curkeywordfavorvalue
				;Debug.Trace("Keyword: " + CurKeyword + " Found! " + "Favor multiplier increased by: " + CurFavorMult + " ! " + "\nFavor Multiplier: " + GetExternalFloat("SkyRomance.esp", 0x00EFF9)/10)
				;k = keywordLen
			Endif
			k += 1
		EndWhile
		i += 1
	EndWhile

	;Set gift favor sv for NPC
	GiftFavorToAdd = (GiftFavorToAdd * (TotalValue / 100)) as int
	StorageUtil.setIntValue(NPC, GiftFavorKey, GetGiftFavorStat(NPC) + GiftFavorToAdd)
	Debug.Trace("Gift favor added: " + GiftFavorToAdd + " ! ")
EndFunction

float Function GetExternalFloat(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValue()
endfunction

int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt()
endfunction

bool Function GetExternalBool(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() == 1
endfunction