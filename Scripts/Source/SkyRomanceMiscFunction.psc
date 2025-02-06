Scriptname SkyRomanceMiscFunction  Hidden

import StringUtil

;Deprecated, no longer used
String Function GetQuestFilter(String Filters, int Level) Global
    String OutputString = ""
    int IterCount = 0
    int BeginSymbolLoc = 0
    int EndSymboloc = 0
    int FoundSymbol = 0
    int sLength = GetLength(Filters)

    while IterCount < sLength
        ;Find "/"
        String Char = GetNthChar(Filters, IterCount)
        if (Char == "/")
            FoundSymbol += 1

            if (FoundSymbol >= Level)
                ;Output string
                EndSymboloc = IterCount
                ;Beware of if BeginSymbol is found, so we should move 1 index forward from "/" as begin loc
                ; If (BeginSymbolLoc != 0)
                ;     BeginSymbolLoc += 1
                ; EndIf

                Debug.trace("Begin symbol: " + GetNthChar(Filters, BeginSymbolLoc) + " | end symbol : " + GetNthChar(Filters, EndSymboloc))
                Debug.trace("Output string: " + Substring(Filters, BeginSymbolLoc, EndSymboloc - BeginSymbolLoc))
                return Substring(Filters, BeginSymbolLoc, EndSymboloc - BeginSymbolLoc)
            else
                ;Update begin symbol to found "/", unless it is the end char
                If (IterCount != sLength - 1)
                    BeginSymbolLoc = IterCount + 1
                    Debug.trace("Found possible begin '/' on " + BeginSymbolLoc)
                EndIf
            endif
        Endif
        ;Iterate
        IterCount += 1

    EndWhile
    ;if can't find enough "/", output 
    Debug.Trace("Can't find enough '/', outputing last level filter")
    return Substring(Filters, BeginSymbolLoc, sLength - 1 - BeginSymbolLoc)
EndFunction

Form Function GetFormByEditorID(string refEditorID) Global native

Function TestingPrint() Global native

Function SKSEGetNPCInventory(Actor TargetNPC) Global native

Function GetAddedItems(Actor TargetNPC) Global native

float Function IntLeanearRemap(int value, int input_min, int input_max, int output_min, int output_max) Global

    if(value > input_max)
        value = input_max
    ElseIf(value < input_min)
        value = input_min
    Endif
 
    float Out = value * ((output_max - output_min) / (input_max - input_min) as float)  + output_min
    return Out

EndFunction