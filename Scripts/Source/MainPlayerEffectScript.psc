Scriptname MainPlayerEffectScript extends activemagiceffect  

SkyRomanceInitQuestScript Main

import SkyRomanceMiscFunction

Event OnPlayerLoadGame()

    RegisterForMenu("BarterMenu")
    Main = game.GetFormFromFile(0x000001, "SkyRomance.esp") as SkyRomanceInitQuestScript
    
EndEvent

Event OnMenuOpen(string menuName)
    If (menuName == "BarterMenu")
        ;Debug.MessageBox(SKSEGetBarterNPC().GetDisplayName())
        ;Debug.MessageBox(main.PrintNPCFavor(SKSEGetBarterNPC()))
        Main.AmplifyBarteningByAffinity(SKSEGetBarterNPC())
    EndIf
endEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
EndEvent