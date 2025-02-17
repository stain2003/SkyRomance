Scriptname MainPlayerEffectScript extends activemagiceffect  

import SkyRomanceMiscFunction

Event OnPlayerLoadGame()
    RegisterForMenu("BarterMenu")
EndEvent

Event OnMenuOpen(string menuName)
    If (menuName == "BarterMenu")
        Debug.MessageBox(SKSEGetBarterNPC().GetDisplayName())
    EndIf
endEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
EndEvent