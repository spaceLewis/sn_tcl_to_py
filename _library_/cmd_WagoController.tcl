# Description  : High-level Commands for communicate with Wago IO's
#
# Filename     : cmd_WagoController.tcl
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 090704 pfeig file created
# 300514 ockeg timeout for all wc_checkAnalog functions
# 160414 serio revert diff calculation in check procedures
# 130315 serio extend timeout to ms for wc_checkAnalog procedures

global COMPUTERNAME
global Control_Wago

# globale Merker für die gesetzten Digital-IO Bit's

array set DigiData {
    1  0
    2  0
    3  0
    4  0
    5  0
    6  0
    7  0
    8  0
    9  0
    10 0
    11 0
    12 0
    13 0
    14 0
    15 0
    16 0
    17 0
    18 0
    19 0
    20 0
    21 0
    22 0
    23 0
    24 0
    25 0
    26 0
    27 0
    28 0
    29 0
    30 0
    31 0
    32 0
    33 0
    34 0
    35 0
    36 0
    37 0
    38 0
    39 0
    40 0
    41 0
    42 0
    43 0
    44 0
    45 0
}

#--------------------------------------------------------------------------------------
# test Active 1 oder 2 Ausgang auf einen best Pegel
# Level=H oder L bezeichnet den Bitzustand in IO.IOACT
# ACHTUNG: Ausgang Active2 ist low aktiv!
# return: aktueller Pegel L oder H
proc wc_Test_Active {Active_Nr CPD_Nr Level } {

    set ix [wc_Get_Active $Active_Nr $CPD_Nr]
    set Level [string toupper $Level]
    if { $ix == $Level } {
	TlPrint "Ausgang Active$Active_Nr von Geraet $CPD_Nr: $Level"
    } else {
	TlError "Ausgang Active$Active_Nr von Geraet $CPD_Nr: Soll=$Level, Ist=$ix"
    }
    return $ix

} ;# wc_Test_Active

#----------------------------------------------------------------
# Geräteausgang LOx auf einen best Pegel testen
# return: aktueller Pegel L oder H
# LOx Nummer des zu prüfenden Ausgangs
proc wc_Check_DQx { DevNr DQx Level {TTId ""}} {

    #   if {[GetDevFeat "BusPBdev"]} {
    doWaitMs 5
    #   }

    set TTId [Format_TTId $TTId]

    #check if selected output is available for device type
    if {[GetDevFeat "Altivar"]} {
	if {$DQx > 3} {
	    TlError "Output DQ$DQx not available for device $DevNr"
	    return "X"
	}
    } else {
	TlError "proc wc_Check_DQx not yet implemented for this device"
	return "X"
    }

    #now check outputs of device (inputs of wago) in dependency of device type
    if {[GetDevFeat "Altivar"]} {
	switch -exact $DevNr {
	    1 {
		set ix [expr [wc_GetDigital 2] >> [expr 0 + $DQx] ] }
	    2 {
		set ix [expr [wc_GetDigital 2] >> [expr 4 + $DQx] ] }
	    default {
		TlError "Physical outputs not checkable for device $DevNr"
		return "X"
	    }
	}
    }

    switch -regexp $Level {
	"[Hh]"  {
	    if { [expr $ix & 0x01] } {
		TlPrint "Output DQ$DQx of device $DevNr is High"
	    } else {
		TlError "$TTId Output DQ$DQx of device $DevNr is Low"
		ShowStatus
	    }
	}
	"[Ll]"  {
	    if { [expr $ix & 0x01] } {
		TlError "$TTId Output DQ$DQx of device $DevNr is High"
		ShowStatus
	    } else {
		TlPrint "Output DQ$DQx of device $DevNr is Low"
	    }
	}
	default {
	    TlError "wc_Check_DQx: wrong parameter: <$Level>"
	    return "X"
	}
    }

    if { [expr $ix & 0x01] } {
	return "H"
    } else {
	return "L"
    }

} ;# wc_Check_DQx

#----------------------------------------------------------------
# Check break output of device DevNr
# return: actuel state L or H
proc wc_Check_BrakeOut { DevNr Level } {

    #now check outputs of device (inputs of wago) in dependency of device type
    switch -regexp $Level {
	"[Hh]"  {
	    if { [expr $ix & 0x01] } {
		TlPrint "Brake out of device $DevNr is High"
	    } else {
		TlError "Brake out of device $DevNr is Low"
	    }
	}
	"[Ll]"  {
	    if { [expr $ix & 0x01] } {
		TlError "Brake out of device $DevNr is High"
	    } else {
		TlPrint "Brake out of device $DevNr is Low"
	    }
	}
	default {
	    TlError "wc_Check_BrakeOut: wrong parameter: <$Level>"
	    return "X"
	}
    }

    if { [expr $ix & 0x01] } {
	return "H"
    } else {
	return "L"
    }

} ;# wc_Check_DQx

#--------------------------------------------------------------------------------------
# test NoFault Ausgang auf einen best Pegel
# Level=H oder L bezeichnet den Pegel am Ausgang
# return: aktueller Pegel L oder H
proc wc_Test_NoFault { DevNr Level } {

    set ix [wc_Get_NoFault $DevNr]
    set Level [string toupper $Level]
    if { $ix == $Level } {
	TlPrint "Ausgang NoFault von Geraet $DevNr: $Level"
    } else {
	TlError "Ausgang NoFault von Geraet $DevNr: Soll=$Level, Ist=$ix"
    }
    return $ix

} ;# wc_Test_NoFault

#--------------------------------------------------------------------------------------
proc wc_Set_REF { DevNr Level } {

    TlPrint "Set input REF $Level for Dev$DevNr"
    #Unterscheidung erforderlich, da Device3 fest verdrahtete IOs hat
    set offSet 2
    switch -exact $DevNr {
	1 -
	2 {wc_SetDigital [expr $DevNr + $offSet] 0x02 $Level}
	3 {TlPrint "--> Limit switches hard wired for Dev$DevNr"}
	4 {wc_SetDigital [expr $DevNr + 8] 0x02 $Level}
    }
}

#--------------------------------------------------------------------------------------
proc wc_Set_LIMN { DevNr Level } {

    TlPrint "Set input LIMN $Level for Dev$DevNr"
    #Unterscheidung erforderlich, da Device3 fest verdrahtete IOs hat
    set offSet 2
    switch -exact $DevNr {
	1 -
	2 {wc_SetDigital [expr $DevNr + $offSet] 0x08 $Level}
	3 {TlPrint "--> Limit switches hard wired for Dev$DevNr"}
	4 {wc_SetDigital [expr $DevNr + 8] 0x08 $Level}
    }

}

#--------------------------------------------------------------------------------------
proc wc_Set_LIMP { DevNr Level } {

    TlPrint "Set input LIMP $Level for Dev$DevNr"
    #Unterscheidung erforderlich, da Device3 fest verdrahtete IOs hat
    set offSet 2
    switch -exact $DevNr {
	1 -
	2 {wc_SetDigital [expr $DevNr + $offSet] 0x04 $Level}
	3 {TlPrint "--> Limit switches hard wired for Dev$DevNr"}
	4 {wc_SetDigital [expr $DevNr + 8] 0x04 $Level}
    }
}

#--------------------------------------------------------------------------------------
proc wc_Set_FAULT_RESET { DevNr Level } {

    TlPrint "Set input FaultReset $Level for Dev$DevNr"
    #Unterscheidung erforderlich, da Device3 fest verdrahtete IOs hat

    switch -exact $DevNr {
	1 -
	2 {wc_SetDigital [expr $DevNr + 2] 0x02 $Level}
	3 {TlPrint "--> Input FaultReset not wired for Dev$DevNr"}
	4 {wc_SetDigital [expr $DevNr + 8] 0x02 $Level}
    }
}

#--------------------------------------------------------------------------------------
proc wc_Set_ENABLE { DevNr Level } {

    TlPrint "Set input ENABLE $Level"

    setDI 0 $Level
}

#--------------------------------------------------------------------------------------
proc wc_Set_HALT { DevNr Level } {

    TlPrint "Set input !Halt $Level for Dev$DevNr"
    #Unterscheidung erforderlich, da Device3 fest verdrahtete IOs hat

    # set output in correlating to default usage!
    switch -exact $DevNr {
	1 -
	2 {wc_SetDigital [expr $DevNr + 2] 0x20 $Level}
	3 -
	4 {wc_SetDigital [expr $DevNr + 8] 0x20 $Level}
	12 {TlError "--> IOs hard wired for Dev$DevNr"}
    }

}

#--------------------------------------------------------------------------------------
proc wc_Set_EndSW { DevNr Level } {

    wc_Set_LIMN $DevNr $Level
    wc_Set_LIMP $DevNr $Level
    #wc_Set_HALT $DevNr $Level
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set STO inputs for Kala device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 141112 pfeig proc created
# 210322 ASY   added devices handling from Shanghai
#
#END----------------------------------------------------------------
proc wc_SetSTO { Level } {
    global ActDev

	#deactivation STO inputs management for Safety firmware
	if {![GetDevFeat "FW_CIPSFTY"]} {
	    wc_SetSTOex $ActDev $Level
	} else {
	    TlPrint "/+/+/+/+/+/+/+/+/+/+//////++++/++/+++/++/++"
	    TlPrint " STO A and STO B Activation Management is not possible in test tower After adding CIP Safety Module.This will be managed by Safety PLC System using Safety Fieldbus and Safety Assembly"
	    TlPrint "/+/+/+/+/+/+/+/+/+/+//////++++/++/+++/++/++"}

    }

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set STO input channel for Kala device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 271114 serio proc created
#
#END----------------------------------------------------------------

proc wc_SetSTO_Channel { Channel Level } {
    global ActDev

    wc_SetSTO_Channelex $ActDev $Channel $Level

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set STO inputs for Kala device
# extended version: switch STO signals for a selectable device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 141112 pfeig proc created
# 040215 serio/grola Workaround for Com option board towers
# 060215 serio exception for PACY_COM_ETHERCAT
# 150415 serio add PACY_COM_DEVICENET
# 210322 ASY   added devices from shanghai
# 090522 ASY   added an exception for NERA tower with disconnection board
# 250124 ASY   update the handling of STO for GEN2Towers
#
#END----------------------------------------------------------------
proc wc_SetSTOex { DevNr Level } {
    global sePLC
    TlPrint "Set STO A and B = $Level for Dev$DevNr"
    if { ![GetSysFeat "Gen2Tower"] } {
	if { [GetDevFeat "Nera"] || [GetDevFeat "Opal"] || [GetDevFeat "Altivar"] } {
	 if {[GetSysFeat "EAETower1"]} {
          switch -regexp $DevNr {
        	 3 {
        	      wc_SetDigital_EAE 304 7 $Level           ;# Connect P24 supply
        	   }
		 4 {
		      wc_SetDigital_EAE 304 8 $Level           ;# Connect P24 supply
		   }
     	      
        	   default {TlError "Device $ActDev not defined in proc setP24Supply"}
       
          }  ;
		  } else {
	    switch -exact $DevNr {

		1  {
		    if { [GetSysFeat "PACY_APP_NERA" ] } {
			wc_SetDigital 7 0x01 $Level
		    } elseif {[GetSysFeat "PACY_SFTY_OPAL" ] } {
			wc_SetDigital 5 0x03 $Level
		    } else {
			wc_SetDigital 7 0x03 $Level
		    }
		}
		2 {if { [GetSysFeat "PACY_APP_NERA" ] } {
			wc_SetDigital 7 0x04 $Level
		    } else {
			wc_SetDigital 7 0x0C $Level
		    }
		}

		3  { wc_SetDigital 7 0xC0 $Level }
		21  { wc_SetDigital 5 0x03 $Level }
		23  { wc_SetDigital 5  0x0C $Level }
		default { TlError "proc wc_SetSTO not defined for current device" }
	    }
      }

	}  elseif { [GetDevFeat "Fortis"] } {
	    switch -exact $DevNr {
		1 -
		8 { wc_SetDigital 5 0x03 $Level }
		2 -
		9 { wc_SetDigital 5 0x0C $Level }
		3 { wc_SetDigital 5 0x30 $Level }
		5 -
		15 {
		    if { [GetSysFeat "PACY_COM_ETHERCAT"] || [GetSysFeat "PACY_COM_DEVICENET"] || [GetSysFeat "PACY_COM_CANOPEN"]} {
			wc_SetDigital 11 0xC0 $Level
		    } elseif { [GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] } {
			wc_SetDigital 11 0x03 $Level
		    } else {
			wc_SetDigital 8 0x03 $Level
		    }

		}
		default { TlError "proc wc_SetSTO not defined for current device" }
	    }
	} elseif {[GetDevFeat "MVK"] } {
	    switch -exact $DevNr {
		1 { wc_SetDigital 5 0x03 $Level }
		2 { wc_SetDigital 5 0x0C $Level }
		3 { wc_SetDigital 5 0x30 $Level }
		5 - 6 {
		    if { [GetSysFeat "PACY_COM_ETHERCAT"] || [GetSysFeat "PACY_COM_DEVICENET"] || [GetSysFeat "PACY_COM_CANOPEN"]} {
			wc_SetDigital 11 0xC0 $Level
		    } elseif { [GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] } {
			wc_SetDigital 11 0x03 $Level
		    } else {
			wc_SetDigital 8 0x03 $Level
		    }

		}
		default { TlError "proc wc_SetSTO not defined for current device" }
	    }

	} else {
	    TlError "proc wc_SetSTO not defined for current dev feature"
	}

    } else {
	set Level [regexp \[1hH\] $Level ]	;# Recreate a 0/1 value from the possible inputs
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + 2] 0x0003  [expr $Level * 0x0003 ] ;# write the proper bit of the word either to 0 or to 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set STO input channel for Kala device
# extended version: switch STO signal for a selectable device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 271114 serio proc created
# 110215 serio add case for Com Tower with Fortis
#
#END----------------------------------------------------------------
proc wc_SetSTO_Channelex { DevNr Channel Level } {

    set Channel [string toupper $Channel]

    if {$Channel == "A" || $Channel == "B"} {

	TlPrint "Set STO $Channel = $Level for Dev$DevNr"

    } else {

	TlError "proc wc_SetSTO_Channel not defined for channel : $Channel"
	return
    }

    if { [GetDevFeat "Nera"] || [GetDevFeat "Altivar"] } {
	switch -exact $DevNr {
	    1 {
		if {$Channel == "A" } {
		    wc_SetDigital 7 0x01 $Level
		} else {
		    wc_SetDigital 7 0x02 $Level
		}
	    }
	    3 {
		if {$Channel == "A" } {
		    wc_SetDigital 7 0x40 $Level
		} else {
		    wc_SetDigital 7 0x80 $Level
		}

	    }
	    default { TlError "proc wc_SetSTO_Channel not defined for device : $DevNr" }
	}

    }  elseif { [GetDevFeat "Opal"] } {
	switch -exact $DevNr {
	    1 {
		if {$Channel == "A" } {
		    wc_SetDigital 7 0x01 $Level
		} else {
		    wc_SetDigital 7 0x02 $Level
		}
	    }
	    2 {
		if {$Channel == "A" } {
		    wc_SetDigital 7 0x4 $Level
		} else {
		    wc_SetDigital 7 0x8 $Level
		}

	    }
	    default { TlError "proc wc_SetSTO_Channel not defined for device : $DevNr" }
	}

    }  elseif {[GetDevFeat "Fortis"] } {
	switch -exact $DevNr {
	    1 {

		if {$Channel == "A" } {
		    wc_SetDigital 5 0x01 $Level
		} else {
		    wc_SetDigital 5 0x02 $Level
		}
	    }
	    2 {

		if {$Channel == "A" } {
		    wc_SetDigital 5 0x04 $Level
		} else {
		    wc_SetDigital 5 0x08 $Level
		}
	    }
	    3 {
		if {$Channel == "A" } {

		    wc_SetDigital 5 0x10 $Level
		} else {
		    wc_SetDigital 5 0x20 $Level
		}
	    }
	    5 {
		if {$Channel == "A" } {
		    if { [GetSysFeat "PACY_COM_PROFIBUS"] } {
			wc_SetDigital 8 0x01 $Level
		    } elseif {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"]} {
			wc_SetDigital 11 0x01 $Level
		    } else {
			# PACY_COM_ETHERCAT PACY_COM_CANOPEN PACY_COM_DEVICENET
			wc_SetDigital 11 0x40 $Level
		    }

		} else {
		    if { [GetSysFeat "PACY_COM_PROFIBUS"] } {
			wc_SetDigital 8 0x02 $Level
		    } elseif {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"]} {
			wc_SetDigital 11 0x02 $Level
		    } else {
			# PACY_COM_ETHERCAT  PACY_COM_CANOPEN PACY_COM_DEVICENET
			wc_SetDigital 11 0x80 $Level
		    }
		}

	    }

	    default { TlError "proc wc_SetSTO_Channel not defined for current device" }
	}

    } else {
	TlError "proc wc_SetSTO_Channel not defined for current dev feature"
    }
}

#--------------------------------------------------------------------------------------
#
# set STO_A and STO_B in a time controlled style
# the time is controlled inside the wago controller, for accurateness reason
#
# Timer starts as soon as $Time gets > 0 ($Time in ms)
#
# when Timer is startet but has not timed out:
#     STO_A = $PWRRA_Before
#     STO_B = $PWRRB_Before
#
# when timer has timed out:
#     STO_A = $PWRRA_After
#     STO_B = $PWRRB_After
#
# example:
#     wc_DelaySTO 1100 0 1 1 1    ;# set STO_A to low, after 1.1 sec set STO_A high again (leave STO_B always high)
#
# Timer is reset and STO_A and B set to default (high) as soon wc_InitComm_Wago is called
#
#--------------------------------------------------------------------------------------
proc wc_DelaySTO { Time PWRRA_Before PWRRB_Before PWRRA_After PWRRB_After} {

    global Data_Out_Offset Control_Wago ActDev

    TlPrint "Open STOA/B for $Time ms via Wago"

    set Control_Wago [expr 3 * 2]

    #Zeit wird in High und Low-Byte unterteilt --> byteweises senden
    set Time_HIGH [expr $Time >> 8]
    set Time_LOW [expr $Time % 256]

    #Bitmuster vor und nach Ablauf der Zeit erzeugen
    set Mode_Data [expr $PWRRA_Before + $PWRRB_Before * 2 + $PWRRA_After * 4 + $PWRRB_After * 8]

    #Zeitdauer an Wago übermitteln
    WagoDigiWrite [expr $Data_Out_Offset + 2] 2 [list $Time_LOW $Time_HIGH]
    doWaitMsSilent 10
    #Bitmuster und Unterbrechungsbefehl an Wago übergeben
    WagoDigiWrite [expr $Data_Out_Offset + 1] 1 $Mode_Data
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago

}

#--------------------------------------------------------------------------------------
#DOC----------------------------------------------------------------
#
# Starten ein kontinuierliches toggeln am Eingang DI0 des Gerätes1 (N1).
# wc_InitComm_Wago beendet das toggeln.
#
# Genauigkeit des Signals = Time -0ms/+5 ms
#
#END----------------------------------------------------------------
proc wc_ToggleOutput { Time } {
    global Data_Out_Offset Control_Wago

    set Control_Wago [expr 6 * 2]

    TlPrint ""
    TlPrint "Toggle DI0 of Device1 with $Time ms pulse width"

    #Zeit wird in High und Low-Byte unterteilt --> byteweises senden
    set Time_HIGH [expr $Time >> 8]
    set Time_LOW [expr $Time % 256]

    #Transmit time
    WagoDigiWrite [expr $Data_Out_Offset + 2] 2 [list $Time_LOW $Time_HIGH]
    doWaitMsSilent 10
    #Start toggle
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago

}

#--------------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Resets all the outputs of the tower
## WHEN  | WHO  | WHAT
# -----| -----| -----
# ????/??/?? | XXX | proc created
# i2023/11/21| ASY | update to handle MVKTower1
#
proc wc_ResetDigiOuts {} {
    global Data_Out_Offset  ActDev COMPUTERNAME
    global sePLC SystemFeatureList
    if {![GetSysFeat "Gen2Tower"]} {

	switch -regexp  $SystemFeatureList {
	    
	    "PACY_APP_NERA" {
		set maxIndex 10
	    }
		
	    "MVKTower1" - 
	    "PACY_APP_OPAL" -
	    "PACY_COM_CANOPEN" -
	    "PACY_COM_DEVICENET" -
	    "PACY_COM_ETHERCAT" - 
	    "PACY_COM_PROFIBUS" -
	    "PACY_COM_PROFINET" { 
		set maxIndex 16
	    }
	    
	    "PACY_APP_FORTIS" -
	    "PACY_SFTY_OPAL" -
	    "PACY_SFTY_FORTIS" {
		set maxIndex 18
	    } 
	    default { 
		TlError "Tower not supported"
		return -1
	    }
	}
	#Condition for MVKTower1 that has a specific hardware. 
	#First module of the STB need a 16bits word to reset all the outputs.
	if {[GetSysFeat "MVKTower1"]} {
		wc_SetDigital 0 65535 L
	}

	for {set i 1 } { $i <= $maxIndex} {incr i} {
	    wc_SetDigital $i 255 l
	}

    } else {
	TlPrint "Gen2Tower"
	wc_TCP_WriteWord [expr $sePLC(towerStructureOffset) + $sePLC(towerAuto)] 1
	doWaitMs 250
	wc_TCP_WriteWord [expr $sePLC(towerStructureOffset) + $sePLC(towerAuto)] 0
    }

}

#--------------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Resets all the Inputs of the tower
## WHEN  | WHO  | WHAT
#  28/06/24 EDM   creation 
#  26/08/24 EDM   Update to take struct offset in consideration

proc wc_ResetInputs {} {
    global ActDev DevType
    global sePLC 
    
    wc_TCP_WriteWord [expr ($ActDev - 1) * $sePLC(structureSize) + $sePLC(ResetIO_offset)] 1
    doWaitMs 250
    wc_TCP_WriteWord [expr ($ActDev - 1) * $sePLC(structureSize) + $sePLC(ResetIO_offset)] 0
}

#--------------------------------------------------------------------------------------
proc wc_SetBPOpen { On } {

    if {$On == "ON"} {
	wc_SetDigital 4 64 H

    } else {
	wc_SetDigital 4 64 L

    }

}

#--------------------------------------------------------------------------------------
proc wc_SwitchPB { Time PB_Before PB_After} {

    global PB_WAGO833 Data_Out_Offset Control_Wago

    set Control_Wago [expr 4 * 2]

    TlPrint "Unterbrechung von Siemens PB fuer $Time ms durch Wago gestartet"

    #Zeit wird in High und Low-Byte unterteilt --> byteweises senden
    set Time_HIGH [expr $Time >> 8]
    set Time_LOW [expr $Time % 256]

    #Bitmuster vor und nach Ablauf der Zeit erzeugen
    set Mode_Data [expr $PB_Before + $PB_After * 2]

    #Zeitdauer an Wago übermitteln
    WagoDigiWrite [expr $Data_Out_Offset + 2] 2 [list $Time_LOW $Time_HIGH]
    doWaitMsSilent 10
    #Bitmuster und Unterbrechungsbefehl an Wago übergeben
    WagoDigiWrite [expr $Data_Out_Offset + 1] 1 $Mode_Data
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago
    #doWaitMsSilent 10
    #WagoDigiWrite $Data_Out_Offset 1 0

}

#DESCRIPTION
#
# ----------HISTORY----------
# WANN   WER   WAS
# 111203 pfeig proc erstellt
# 150205 pfeig forcen erstellt
# 300807 pfeig Anpassung an BLP14
# 300807 pfeig Anpassung an BLP14
# 111213 ockeg adapted for Nera: channel 1..4, Mode "voltage" or "current"
# 200214 serio added case with IO modul
# 140414 serio modified filter for channels limitation
# 020215 serio modify chann limitation
# 050215 serio/grola correct limitation for Tower2
# 060215 serio correct limitation for Tower5
# 140415 serio modification for Nera/Beidou on PACY_COM_DEVICENET
# 150415 serio modification for Fortis on PACY_COM_DEVICENET
#
#END----------------------------------------------------------------
proc wc_SetAnalog { Chan Value {Mode "voltage"}} {
    global Ana_Out_offset

    if { ($Chan < 1) || ($Chan > 14) } {
	TlError "Wago Analog Out for channel $Chan physically not available"
	return
    }

    switch $Mode {
	"voltage" {
	    if { ($Value < -10000) || ($Value > 10000) } {
		TlError "invalid voltage 0..10000 mV allowed"
		return
	    }
	    set HexValue [expr round (32767 / 10000.0 * $Value) & 0xFFFF]
	}
	"current" {
	    if { ($Value < 0) || ($Value > 20000) } {
		TlError "invalid current 0..20000 uA allowed"
		return
	    }
	    set HexValue [expr round (32767 / 20000.0 * $Value) & 0x7FFF]
	}
	default {
	    TlError "Mode $Mode not defined"
	    return
	}
    }

    set Offset [expr $Ana_Out_offset + ($Chan -1) * 2]
    set Data1  [expr ($HexValue >> 8) & 0xFF]
    set Data2  [expr ($HexValue     ) & 0xFF]

    #TlPrint "WagoWrite Offset: $Offset   Data: 0x%02X 0x%02X" $Data1 $Data2
    WagoSpecialWrite $Offset 2 [list $Data2 $Data1]

    if {[GetSysFeat "PACY_COM_DEVICENET"]} {
	#delay time for IO module
	doWaitMsSilent 11
    }

}

#DESCRIPTION
#
# ----------HISTORY----------
# WANN   WER   WAS
# 111203 pfeig proc erstellt
# 150205 pfeig forcen erstellt
# 300807 pfeig Anpassung an BLP14
#
#END----------------------------------------------------------------
proc wc_SetAnalogOpal { Chan Value {Mode "voltage"}} {
    wc_SetAnalog $Chan $Value $Mode
}

#DESCRIPTION
#
# ----------HISTORY----------
# WANN   WER   WAS
# 111203 pfeig proc erstellt
# 150205 pfeig forcen erstellt
# 300807 pfeig Anpassung an BLP14
# 120214 serio extended chan numbers
# 020215 serio adapt to com option board tower modifications
# 100215 serio correct previous modifications
# 140415 serio modification for Nera/Beidou on PACY_COM_DEVICENET
#
#END----------------------------------------------------------------
proc wc_GetAnalog { Chan {Mode "voltage"}} {
    global Ana_In_offset

    if {[GetSysFeat "PACY_COM_DEVICENET"] || [GetSysFeat "PACY_COM_PROFIBUS"] || [GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] || [GetSysFeat "PACY_COM_ETHERCAT"] || [GetSysFeat "PACY_COM_CANOPEN"]} {
	set voltcuroffset 8

    } else {
	set voltcuroffset 4
    }

    switch $Mode {
	"current" {

	    if { ($Chan > 4) | ($Chan < 1) } {
		TlError "Analog output channel physically not available"
		return
	    }

	    set Offset [expr $Ana_In_offset + ($Chan -1) * 2]
	}
	"voltage" {

	    if { ($Chan > 6) | ($Chan < 1) } {
		TlError "Analog output channel physically not available"
		return
	    }

	    set Offset [expr $Ana_In_offset + $voltcuroffset + ($Chan -1) * 2]
	}
	default {
	    TlError "Mode $Mode not defined"
	    return 0
	}
    }

    # WagoDigiWrite Byteoffset Len Data1 Data2 ...
    #TlPrint "Offset: $Offset Data1: 0x%04X  Data2: 0x%04X" $Data1 $Data2
    set data [WagoSpecialRead $Offset 2]
    set value 0x[format "%02X%02X" [lindex $data 1] [lindex $data 0]]
    return [expr $value ]

}

proc wc_GetAnalogOutVolt {Chan {print "0"}} {

    set value [expr [wc_GetAnalog $Chan "voltage"] & 0xFFF8]      ;#mask, lower 3 bits are status

    #calculate voltage value out of raw read value
    if {$value > 32761} {
	set voltage [expr round(($value.0 - 0xFFFF) / 0x8000  * 10000.0) /  1000.0]
    } else {
	set voltage [expr round(($value.0) / 0x8000  * 10000.0) /  1000.0]
    }

    if {$print} {
	TlPrint "Analog output $Chan voltage $voltage"
    }
    return $voltage

}

proc wc_GetAnalogOutCurr {Chan {print "0"}} {

    set value [expr [wc_GetAnalog $Chan "current"] & 0xFFF8]      ;#mask, lower 3 bits are status

    #calculate voltage value out of raw read value
    set current [expr round(($value.0) / 0x8000  * 20000.0) /  1000.0]

    if {$print} {
	TlPrint "Analog output $Chan current $current"
    }
    return $current

}

#-----------------------------------------------------------------------
# Set digital inputs from IO module of device to Level
#-----------------------------------------------------------------------
proc wc_SelectAnaOutType {{type "OFF"} {restart 1}} {
    global ActDev

    switch $type {
	"Voltage" {
	    TlWrite IOM.AOTYPE 1
	}
	"Current" {
	    TlWrite IOM.AOTYPE 2
	}
	default {
	    TlWrite IOM.AOTYPE 0
	}
    }
    wc_SwitchAnaOut $type

    if {$restart} {
	doStoreEEPROM
	DeviceFastOffOn $ActDev
    }

};#wc_SelectAnaOutType

proc wc_SwitchAnaOut {{type "OFF"}} {
    global ActDev

    #select correct channel for switching interface
    if {[GetDevFeat "BusPBdev"] && $ActDev == 4} {
	set digiChannel 15
    } elseif {![GetDevFeat "BusPBdev"] && $ActDev == 2} {
	set digiChannel 13
    } else {
	TlError "Device $ActDev has no IO module"
	return
    }

    if {$type == "Current"} {
	wc_SetDigital $digiChannel 0x80 "H"
    } else {
	wc_SetDigital $digiChannel 0x80 "L"
    }
}

#short circuit on analog outputs of IO module
proc wc_ShortCircuit_AnaOut {anaOutx Level} {

    set Level [string toupper $Level]
    TlPrint "Short circuit on analog output $anaOutx $Level"

    set digiChannel 12
    if {$Level == "ON"} {
	set Level "H"
    } elseif {$Level == "OFF"} {
	set Level "L"
    }

    switch $anaOutx {
	1 {wc_SetDigital $digiChannel 0x40 $Level}
	2 {wc_SetDigital $digiChannel 0x80 $Level}
	default {TlError "Analog output $anaOutx is not available"}
    }

}

proc wc_checkAnalogOutVoltage {channel targetValue tolerance {timeout 0} {TTId ""} } {
    # timeout in sec

    set TTId [Format_TTId $TTId]
    set timeout   [expr int ($timeout * 1000)]
    set starttime [clock clicks -milliseconds]
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $starttime]

	set actualValue [wc_GetAnalogOutVolt $channel]
	if {[expr abs($targetValue - $actualValue)] <= $tolerance} {
	    TlPrint "Analog output voltage <V> ok: EXP=%0.3f ACT=%0.3f TOL=%0.3f DIFF=%0.3f TIME=%dms" \
		$targetValue $actualValue $tolerance [expr $actualValue-$targetValue] $waittime
	    return 1
	} else {
	    if { $waittime > $timeout } {
		TlError "$TTId Analog output voltage <V> wrong: EXP=%0.3f ACT=%0.3f TOL=%0.3f DIFF=%0.3f TIMEOUT=%dms" \
		    $targetValue $actualValue $tolerance [expr $actualValue-$targetValue] $waittime
		return 0
	    }
	}
    }

}

proc wc_checkAnalogOutCurrent {channel targetValue tolerance {timeout 0} {TTId ""} } {
    # timeout in sec

    set TTId [Format_TTId $TTId]
    set timeout   [expr int ($timeout * 1000)]
    set starttime [clock clicks -milliseconds]
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $starttime]

	set actualValue [wc_GetAnalogOutCurr $channel]

	if {[expr abs($targetValue - $actualValue)] <= $tolerance} {
	    TlPrint "Analog output current <mA> ok: EXP=%0.3f ACT=%0.3f TOL=%0.3f DIFF=%0.3f TIME=%dms" \
		$targetValue $actualValue $tolerance [expr $actualValue-$targetValue] $waittime
	    return 1
	} else {
	    if { $waittime > $timeout } {
		TlError "$TTId Analog output current <mA> wrong: EXP=%0.3f ACT=%0.3f TOL=%0.3f DIFF=%0.3f TIME=%dms" \
		    $targetValue $actualValue $tolerance [expr $actualValue-$targetValue] $waittime
		return 0
	    }
	}
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# set or reset only one bit without modifying others
# example: wc_SetDigital 1 16 H (set CPD 1 on)
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080104 pfeig proc created
# 060905 pfeig modified for Variable Modulconfig at Wago Cont.
# 200315 serio detailed exit criteria
# 260315 serio extend use of digital outputs in switch case
# 150415 serio adapt PACY_COM_DEVICENET case
#
#
#END----------------------------------------------------------------
proc wc_SetDigital { Chan Value Level {ioMask 0 }} {
    global PB_WAGO833
    global DigiData Merker_Offset
    global DigiOut_Offset  Data_Out_Offset PD_Mapping_Out_Offset
    global COMPUTERNAME

    if {![GetSysFeat "MVKTower1"] && ![GetSysFeat "MVKTower2"] } {

	if { ![GetDevFeat "BusSys"] } {
	    return
	}
	if { ($Value > 255) | ($Value < 0) } {
	    TlError "wc_SetDigital: Overflow: Value 8 Bit"
	    return
	}
	#check maximum output channel depending on wago system in test tower

	if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] ||[GetSysFeat "PACY_SFTY_OPAL"] || [GetSysFeat "PACY_COM_PROFIBUS"] || [GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] || [GetSysFeat "PACY_COM_ETHERCAT"] || [GetSysFeat "PACY_COM_CANOPEN"]} {

	    if {$Chan > 18} {
		TlError "Digital output channel $Chan of Wago system not available"
		return
	    }

	} elseif {[GetSysFeat "PACY_COM_DEVICENET"] } {

	    if {$Chan > 16} {
		TlError "Digital output channel $Chan of Wago system not available"
		return
	    }

	} else {

	    if {$Chan > 10} {
		TlError "Digital output channel $Chan of Wago system not available"
		return
	    }

	}

	#no Offset-moving , because of controlling from
	#Wago Ethernet-Controller
	switch -exact $Chan {
	    1 -
	    3 -
	    5 -
	    7 -
	    9 -
	    11 -
	    13 -
	    15 -
	    17 {

		set Offset [expr $DigiOut_Offset + $Chan ]
		set DigiData($Chan) [wc_TCP_ReadOutputByte $Offset]
		set DigiData([expr $Chan + 1]) [wc_TCP_ReadOutputByte [expr $Offset + 1]]
	    }
	    2 -
	    4 -
	    6 -
	    8 -
	    10 -
	    12 -
	    14 -
	    16 -
	    18 {

		set Offset [expr $DigiOut_Offset + $Chan]
		set DigiData($Chan) [wc_TCP_ReadOutputByte $Offset]
		set DigiData([expr $Chan - 1]) [wc_TCP_ReadOutputByte [expr $Offset - 1]]

	    }

	    default {
		TlError "wc_SetDigital: Overflow: channel $Chan is undeclared"
		return
	    }
	}

	#TlPrint "Set digital port %d, Bit 0x%04X to value: %s" $Chan $Value $Level
	# for security because of possible buffer overflow we use only one byte
	set Value [expr (($Value ) & 0xFF) ]

	switch -regexp $Level {
	    "[Hh]" {   ;# High setzen
		set DigiData($Chan)  [expr $DigiData($Chan)  | $Value]
	    }

	    "[Ll]" {   ;# Low setzen ( ~ invertiert)
		set DigiData($Chan)  [expr $DigiData($Chan)  & ~$Value]
	    }

	    default {
		TlError "wc_SetDigital: wrong 3rd parameter: <$Level>"
		return
	    }
	}

	switch -exact $Chan {
	    1 -
	    3 -
	    5 -
	    7 -
	    9 -
	    11 -
	    13 -
	    15 -
	    17 {
		wc_TCP_WriteWord [expr 0x3000 + $Offset / 2] [expr $DigiData($Chan) + 0x100 * $DigiData([expr $Chan + 1])]
	    }
	    2 -
	    4 -
	    6 -
	    8 -
	    10 -
	    12 -
	    14 -
	    16 -
	    18 {
		wc_TCP_WriteWord [expr 0x3000 + ($Offset - 1) / 2] [expr $DigiData([expr $Chan - 1]) + 0x100 * $DigiData($Chan)]
	    }
	    default {
		TlError "wc_SetDigital: Overflow: channel $Chan is undeclared"
		return
	    }
	}

	doWaitMsSilent 20
    } else {
	set CurrValue [wc_TCP_ReadWord $Chan 1 ]

	switch -regexp $Level {
	    "[Hh]" {   ;# High setzen
		set DigiData($Chan)  [expr $CurrValue  | $Value]
	    }

	    "[Ll]" {   ;# Low setzen ( ~ invertiert)
		set DigiData($Chan)  [expr $CurrValue  & ~$Value]
	    }

	    default {
		TlError "wc_SetDigital: wrong 3rd parameter: <$Level>"
		return
	    }
	}

	wc_TCP_WriteWord $Chan $DigiData($Chan)

    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# set or reset only one bit without modifying others
# example: wc_SetDigital 1 16 H (set CPD 1 on)
#
# ----------HISTORY----------
# WHEN   	WHO   	WHAT
# 11/05/21	RKA	Creation
#
#
#END----------------------------------------------------------------
proc wc_SetDigital_EAE { Register Index Level } {
	
   global DigiData
   global DigiOut_Offset


    global ActDev
    set PLC_Bit1 10
    switch -regexp $ActDev {							;#regarding the device selection
        1 - 2 - 3 - 4 - 5 {									;#Device 1
    	set Result [wc_TCP_ReadWord $Register 1]			;# read the current state of PLC register
		TlPrint "\nResult = $Result"
    	set Mask [ expr round(pow(2,$Index))]				;# create a Mask regarding the selected Bits
	    TlPrint "\nMask = $Mask"
	set IntVar [expr ($Result & $Mask)]
		TlPrint "\nIntVar = $IntVar"

        switch -regexp $Level {
           "[Hh1]" {   
              set Level 1
           }
        
           "[Ll0]" {  
	      set Level 0
           }
        
           default {
              TlError "wc_SetDigital: wrong 3rd parameter: <$Level>"
              return
           }
        }

	if {$Level==1 && $IntVar==0} {					;# set the appropriate bit to switch on.
    	    wc_TCP_WriteWord $Register [expr ($Result+ $Mask)]
		    TlPrint "\nONE"
    	    return 1
    	}
    	if {$Level==0 && $IntVar==$Mask} {				;# set the appropriate bit to switch off.
    	    wc_TCP_WriteWord $Register [expr ($Result- $Mask)]
		TlPrint "\nTWO"
		return 1
    	}
        }
    }
    doWaitMsSilent 20

}

#--------------------------------------------------------------------------------------
proc wc_GetDigital { Chan {Len 1}} {
    global PB_WAGO833 DigiIn_Offset

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 121203 pfeig proc erstellt
    # 101105 pfeig mit Offset erweitert und Länge
    # 130607 ockeg erweitert um Kanal 3 bei IclaNT Testturm
    #
    #END----------------------------------------------------------------

    set max_Chan 8

    if { ($Chan > $max_Chan) | ($Chan < 1) } {
	TlError "wc_GetDigital: Channel overflow "
	return 0
    }

    set Offset [expr $Chan + $DigiIn_Offset]

    set Data [WagoDigiRead $Offset $Len]

    return [lindex $Data 0]

}

#--------------------------------------------------------------------------------------
proc wc_StartTimer1 {} {
    global PB_WAGO833 Timer1Out_Offsett
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Startet einen Timer im Wagocontroller
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 160905 pfeig proc erstellt
    #
    #END----------------------------------------------------------------

    # WagoDigiWrite Byteoffset Len Data1 Data2 ...
    # Achtung: Byte werte sind Vertauscht ( Motorolaformat Big Endian)
    WagoDigiWrite $Timer1Out_Offsett 2 [list 1 0]

}

#--------------------------------------------------------------------------------------
proc wc_StopTimer1 {} {
    global PB_WAGO833 Timer1Out_Offsett
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Stopt einen Timer im Wagocontroller
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 160905 pfeig proc erstellt
    #
    #END----------------------------------------------------------------

    # WagoDigiWrite Byteoffset Len Data1 Data2 ...
    # Achtung: Byte werte sind Vertauscht ( Motorolaformat Big Endian)
    WagoDigiWrite $Timer1Out_Offsett 2 [list 0 0]

}

#--------------------------------------------------------------------------------------
proc wc_GetTimer1 {} {
    global PB_WAGO833 Timer1In_Offsett
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Holt die abgelaufene Zeit ab in ms
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 160905 pfeig proc erstellt
    #
    #END----------------------------------------------------------------

    # WagoDigiRead [ByteOffset ByteAnzahl]
    # Achtung: Byte werte sind Vertauscht ( Motorolaformat Big Endian)
    set Data [WagoDigiRead $Timer1In_Offsett 2]
    set Time [expr [lindex $Data 0] + 256 * [lindex $Data 1]]
    # puts $Time
    return $Time
}

#--------------------------------------------------------------------------------------
proc wc_SwitchMotEncoder {DevNr Level} {
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Trennt oder verbindet den Motor-Encoder des angegebenen Gerätes
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 190506 rothf proc erstellt
    #
    #END----------------------------------------------------------------

    TlPrint "Setze Verbindung des Motor-Encoders von Geraet Nr.: $DevNr auf: $Level"
    set IoMask  0x80

    switch $DevNr {
	"1" {
	    if {$Level == "ON"} {
		wc_SetDigital 4 0x80  "L" $IoMask ;
	    } elseif {$Level == "OFF"} {
		wc_SetDigital 4 0x80  "H" $IoMask ;
	    }
	}
	default  {
	    TlError "Unzulaessige Geraete Nr $DevNr"
	    return
	}
    }
};#wc_SwitchMotEncoder

#--------------------------------------------------------------------------------------
proc wc_SwitchMotEncoderIndexPulse {DevNr Level} {
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Trennt oder verbindet den Indexpuls des Motor-Encoder des angegebenen Gerätes
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 310506 rothf proc erstellt
    #
    #END----------------------------------------------------------------

    TlPrint "Setze Indexpuls des Motor-Encoders von Geraet Nr.: $DevNr auf: $Level"
    set IoMask  0x20

    switch $DevNr {
	"1" {
	    if {$Level == "ON"} {
		wc_SetDigital 4 0x20  "L" $IoMask ;
	    } elseif {$Level == "OFF"} {
		wc_SetDigital 4 0x20  "H" $IoMask ;
	    }
	}
	default  {
	    TlError "Unzulaessige Geraete Nr $DevNr"
	    return
	}
    }
};#wc_SwitchMotEncoderIndexPulse

#--------------------------------------------------------------------------------------
proc wc_SwitchMotEncoderTemp {DevNr Level} {
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Trennt oder verbindet die Temperaturleitung des Motor-Encoder des angegebenen Gerätes
    #
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 300506 rothf proc erstellt
    #
    #END----------------------------------------------------------------

    TlPrint "Setze !TEMP des Motor-Encoders von Geraet Nr.: $DevNr auf: $Level"
    set IoMask  0x10

    switch $DevNr {
	"1" {
	    if {$Level == "ON"} {
		wc_SetDigital 4 0x10  "L" $IoMask ;
	    } elseif {$Level == "OFF"} {
		wc_SetDigital 4 0x10  "H" $IoMask ;
	    }
	}
	default  {
	    TlError "Unzulaessige Geraete Nr $DevNr"
	    return
	}
    }
};#wc_SwitchMotEncoderTemp

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 301015 pfeig file created
#
# Attention Wago Docu wrong: not 1 statusbyte but 2 !!!
#
#END----------------------------------------------------------------
proc wc_GetFreqCount { {range 3 } } {
    global Wago_Type Enc_In_Offset1  Enc_Out_Offset1

    global ActDev

    #          WagoDigiRead       ByteOffset    ByteCount
    set Data [WagoSpecialRead  $Enc_Out_Offset1     6 ]
    TlPrint "Data: $Data"

    set Frequency   [expr {(([lindex $Data 5] << 24 ) + ([lindex $Data 4] << 16) + ([lindex $Data 3] << 8 ) + [lindex $Data 2])  }]
    if { int ( $Frequency ) == -1 } {
	TlPrint "!!! *** Frequency: NOT VALID *** !!!"
	set Frequency 0
    } else {
	TlPrint "Frequency: $Frequency"
    }

    return $Frequency

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 301015 pfeig file created
#
#
#
#END----------------------------------------------------------------
proc wc_SetFreqCount { {range 3 } } {
    global Wago_Type
    global ActDev

    # WagoDigiWrite ByteOffset Len Data0 Data1 ...

    WagoSpecialWrite 12 1 $range

    doWaitMsSilent 100

    set Data [WagoSpecialRead 12 2 ]
    #   TlPrint "Data: $Data"

    set Statusbyte  [lindex $Data 0]

    TlPrint "FreqCount Status: $Statusbyte"

    return $Statusbyte

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# ----------HISTORY----------
# WANN   WER   WAS
# 210306 grana erstellt
#
# Achtung Wago Doku falsch: nicht ein Steuerbyte sondern 2 !!!
#
#END----------------------------------------------------------------
proc wc_GetEncoder { {Enc 1 } {Waittime 0} } {
    global PB_WAGO833
    global Wago_Type
    global ActDev
    global Enc_In_Offset1 Enc_In_Offset2

    if {$Waittime > 0} {
	doWaitMs $Waittime
    }

    set Len            8   ;# ByteAnzahl
    switch $Enc {
	"1" {set Enc_In_Offset $Enc_In_Offset1}
	"2" {set Enc_In_Offset $Enc_In_Offset2}
    } ;# switch Enc

    #      WagoDigiRead ByteOffset  ByteAnzahl
    set Data [WagoSpecialRead $Enc_In_Offset $Len ]
    # TlPrint "Data: $Data"

    #Prozessabbild ist für Ethernet und Profibus Controller unterschiedlich aufgebaut
    switch -exact $Wago_Type {
	"Ethernet" {
	    set EncoderPos   [expr {([lindex $Data 7] << 24 ) + ([lindex $Data 6] << 16) + ([lindex $Data 3] << 8 ) + [lindex $Data 2]}]
	}
	"Profibus" {
	    # Achtung: Byte werte sind Vertauscht ( Motorolaformat Big Endian)
	    set EncoderPos   [expr {( [lindex $Data 1] << 8 ) + [lindex $Data 2]}]
	}
    }
    TlPrint "Wago_Encoder$Enc    ext. Pos     %d"  $EncoderPos

    return $EncoderPos
} ;# GetEncoder

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# ----------HISTORY----------
# WANN   WER   WAS
# 210306 grana erstellt
# 081106 pfeig portierbarkeit verbesser (VarExist)
# todo: Übertragungsroutine ckecken und Initialisierung überprüfen
# Encoder möglichst nicht auf 0 initialisiseren da manchmal nur 2 von 4 Bytes auf FF schalten
# und damit der Encoder nicht auf -1 sondern auf -65535 springt.
# Achtung Wago Doku falsch: nicht ein Steuerbyte sondern 2 !!!
# oder Übertragungsroutine ist fehlerhaft ???
#END----------------------------------------------------------------
proc wc_SetEncoder { {Enc 1} {Encoder_Value 0} } {
    global PB_WAGO833
    global Enc_Out_Offset1  Enc_Out_Offset2
    global Enc_In_Offset1  Enc_In_Offset2

    set Len            3   ;# ByteAnzahl
    set Enc_In_Offset  0
    set Enc_Out_Offset 0
    switch $Enc {
	"1" { set Enc_In_Offset  $Enc_In_Offset1
	    set Enc_Out_Offset $Enc_Out_Offset1
	}
	"2" { set Enc_In_Offset  $Enc_In_Offset2
	    set Enc_Out_Offset $Enc_Out_Offset2
	}
    } ;# switch Enc

    # Sicherstellen das CNT_SET auf 0
    set Data_0 0x00                                       ;# CNT_SET zuruecksetzen
    WagoSpecialWrite $Enc_Out_Offset 1 $Data_0

    set Data_0 0x04                                       ;# CNT_SET setzen
    set Data_1 [expr (($Encoder_Value    )&0xff)]
    set Data_2 [expr (($Encoder_Value>>8 )&0xff)]
    set Data_3 [expr (($Encoder_Value>>16)&0xff)]
    set Data_4 [expr (($Encoder_Value>>24)&0xff)]

    #TlPrint "Data_1 $Data_1"
    #TlPrint "Data_2 $Data_2"
    #TlPrint "Data_3 $Data_3"
    #TlPrint "Data_4 $Data_4"

    # WagoDigiWrite ByteOffset Len Data0 Data1 ...
    #TlPrint "--->"

    # Achtung Wago Doku falsch: nicht ein Steuerbyte sondern 2 !!!

    WagoSpecialWrite [expr $Enc_Out_Offset + 2] 6 [list $Data_1 $Data_2 0 0 $Data_3 $Data_4]
    #   WagoSpecialWrite [expr $Enc_Out_Offset + 1] 10 [list 1 2 3 4 5 6 7 8 9 10]
    #TlPrint "--->"
    WagoSpecialWrite $Enc_Out_Offset 1 $Data_0

    doWaitMsSilent 100
    # CNTSET_ACK abfragen das ein Wert gesetzt wurde
    set Data [WagoSpecialRead $Enc_In_Offset 3 ]
    set Statusbyte  [lindex $Data 0]
    if { ($Statusbyte & 0x04) != 0x04 } {
	TlError "Encoder_Wert nicht gesetzt. Statusbyte 0x%02x"  $Statusbyte
    }

    set Data_0 0x00                                       ;# CNT_SET zuruecksetzen
    WagoSpecialWrite $Enc_Out_Offset 1 $Data_0

    return $Statusbyte

} ;# SetEncoder

#--------------------------------------------------------------------------------------
proc wc_VerifyPosEncoder { Pos_Value  Enc_Value_Start  {Enc_Value_Stop 0} } {
    global PB_WAGO833

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Encoderposition wird berechnet und mit dem Soll-Stand verglichen
    # Wenn Enc_Value_Stop = 0 wird die aktuelle Position vom zusaetzlichen Encoder gelesen
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 210306 grana erstellt
    #
    #
    #END----------------------------------------------------------------
    global  Value_Stop Diff_Enc_Pos Enc_Faktor

    #wc_GetEncoder
    if {$Enc_Value_Stop == 0 } {
	    set Enc_Value_Stop [wc_GetEncoder 1 500]
	}
    set Value_Stop  $Enc_Value_Stop

    TlPrint "Positionierweg      %6s" $Pos_Value
    TlPrint "ext. Enc_Value_Start %5s" $Enc_Value_Start
    TlPrint "ext. Enc_Value_Stop  %5s" $Enc_Value_Stop

    # Sollposition berechnen
    #   if {$Pos_Value >= 0} {
    #      # Motor dreht positiv, ext. Encoder negativ
    #      if { [expr abs($Enc_Value_Start) > abs($Enc_Value_Stop)] | (abs($Pos_Value) > 65535) } {
    #         set Enc_Overflow   [expr (int((abs($Pos_Value)/ $Enc_Faktor) / 65536)) * 65536]                      ;# Achtung 0 bis 65535
    #         set Enc_Ist  [expr 65535 - ((abs($Pos_Value) / abs($Enc_Faktor)) - $Enc_Overflow) ]
    #      } else {
    #         set Enc_Ist  [expr 65535 - ($Pos_Value / $Enc_Faktor)]
    #      }
    #   } else {
    #      # Motor dreht negativ, ext. Encoder positiv
    #      if { [expr abs($Enc_Value_Stop) > abs($Enc_Value_Start)] | (abs($Pos_Value) > 65535) } {
    #         set Enc_Overflow   [expr (int((abs($Pos_Value)/ $Enc_Faktor) / 65536)) * 65536]                      ;# Achtung 0 bis 65535
    #         set Enc_Ist  [expr (abs($Pos_Value) / $Enc_Faktor) - $Enc_Overflow ]
    #      } else {
    #         set Enc_Ist  [expr $Pos_Value / $Enc_Faktor]
    #      }
    #   }

    set Enc_Ist  [expr $Pos_Value / $Enc_Faktor]

    doReadObject MONC.PACTUSR 0 1
    TlPrint "errechnete Sollposition $Enc_Ist"

    set Enc_Value_Diff  [expr abs($Enc_Value_Stop) - abs($Enc_Value_Start)]
    TlPrint "Enc_Value_Diff $Enc_Value_Diff bei Encoderaufloesung Motor 4096 / Ext.Encoder [expr 4096 / $Enc_Faktor] "

    set Diff_Enc_Pos [expr abs($Enc_Value_Stop) - abs($Enc_Ist)]

    TlPrint "Abweichung errechnete Sollposition zur Encoderposition = $Diff_Enc_Pos"

    return $Diff_Enc_Pos

} ;# VerifyPosEncoder

#--------------------------------------------------------------------------------------
proc wc_SetEncoderLatchC { {Enc 1} {MapPZD 1} {EN_LATC 1}} {
    global PB_WAGO833
    global Enc_Out_Offset1 Enc_Out_Offset2

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 241106 grana erstellt
    #
    # MapPZD:  Bit1  Bit0
    #           0      0      Zaehlerwert
    #           0      1      Latchwert
    #           1      0      Vel in incr/ms
    #           1      1      Setzwert
    #
    #END----------------------------------------------------------------

    set Len  6   ;# ByteAnzahl
    switch $Enc {
	"1"  {set Enc_Out_Offset $Enc_Out_Offset1}
	"2"  {set Enc_Out_Offset $Enc_Out_Offset2}
    } ;# switch Enc

    set Data_0 0x00                          ;# CaptureMode ruecksetzen
    WagoDigiWrite $Enc_Out_Offset 1 $Data_0

    # Sicherstellen das EN_LATC auf 0 und MapPZD setzen
    set Data_0 $EN_LATC                      ;# CaptureMode Latch C setzen
    set Data_1 0
    set Data_2 0
    set Data_3 $MapPZD                       ;# MapPZD auf Latchwert

    WagoSpecialWrite   [expr $Enc_Out_Offset + 4]      1 $Data_3
    WagoSpecialWrite   [expr $Enc_Out_Offset + 2]      2 [list $Data_1 $Data_2]
    WagoSpecialWrite         $Enc_Out_Offset           1 $Data_0

} ;# wc_SetEncoderLatchC

#--------------------------------------------------------------------------------------
proc wc_GetEncoderLatchC { {Enc 1} {NoPrint 0}} {
    global PB_WAGO833
    global Enc_Out_Offset1 Enc_Out_Offset2
    global Enc_In_Offset1 Enc_In_Offset2

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 241106 grana erstellt
    #
    #
    #END----------------------------------------------------------------

    set Len  6   ;# ByteAnzahl

    switch $Enc {
	"1" { set Enc_In_Offset  $Enc_In_Offset1
	    set Enc_Out_Offset $Enc_Out_Offset1
	}
	"2" { set Enc_In_Offset  $Enc_In_Offset2
	    set Enc_Out_Offset $Enc_Out_Offset2
	}
    } ;# switch Enc

    # lesen aller Eingangsdaten
    set Data [WagoSpecialRead $Enc_In_Offset $Len ]

    # Achtung: Byte werte sind Vertauscht ( Motorolaformat Big Endian)
    set Value_Latch [expr {( [lindex $Data 3] << 8 ) + [lindex $Data 2]}]
    if {!$NoPrint} {
	TlPrint "ext. EncoderPos     %6d"  $Value_Latch
    }

    #   TlPrint "Data0 [lindex $Data 0]"
    #   TlPrint "Data3 [lindex $Data 3]"

    # EN_LATC muss für neue Messung getoggelt werden
    if {([lindex $Data 0] & 0x01) == 1} {
	# EN_LATC ruecksetzen
	WagoSpecialWrite    [expr $Enc_Out_Offset + 4]      1  1
	WagoSpecialWrite    [expr $Enc_Out_Offset + 2]      2  [list 0 0]
	WagoSpecialWrite          $Enc_Out_Offset           1  0

	doWaitMs 200
	# EN_LATC für neue Messung setzen
	WagoSpecialWrite    [expr $Enc_Out_Offset + 4]      1  1
	WagoSpecialWrite    [expr $Enc_Out_Offset + 2]      2  [list 0 0]
	WagoSpecialWrite          $Enc_Out_Offset           1  1

    }

    return $Value_Latch

} ;# wc_GetEncoderLatchC

#--------------------------------------------------------------------------------------
proc wc_InitComm_Encoder { {EncNumber 1} } {
    global PB_WAGO833
    global Data_Out_Offset
    global Enc_Acc
    global IncEncClamp_Resolution Control_Wago

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Übermittelt die Auflösung des Inkrementalencoders von Gerät 1 und die
    # Datenbreite der Verwendeten Encoder-Klemme an den Wago-Controller
    #     ACHTUNG! --> Die Geschwindigkeitserfassung funktioniert erst nach der Initialiasierung
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 120706 rothf proc erstellt
    #
    #END----------------------------------------------------------------

    TlPrint "Encoder an Wago initialisieren"

    switch $EncNumber {
	1 {set offset 0}
	2 {set offset 2}
    }

    #   #Encoder-Genauigkeit wird in High und Low-Byte unterteilt --> byteweises senden
    #   set EncoderAccuracy_HIGH [expr $Enc_Acc >> 8]
    #   set EncoderAccuracy_LOW [expr $Enc_Acc % 256]
    #   set Control_Wago 0                                 ;#Steuerwort
    #
    #   TlPrint "EncoderAccuracy_HIGH: $EncoderAccuracy_HIGH"
    #   TlPrint "EncoderAccuracy_LOW: $EncoderAccuracy_LOW"
    #
    #   WagoDigiWrite [expr $Data_Out_Offset + 4] 2 [list $EncoderAccuracy_LOW $EncoderAccuracy_HIGH]
    #   WagoDigiWrite [expr $Data_Out_Offset + 2] 1 $IncEncClamp_Resolution
    #   WagoDigiWrite $Data_Out_Offset 1 $Control_Wago

    WagoSpecialWrite $Data_Out_Offset 1 2

};#wc_InitComm_Encoder

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#Rücksetzen der Verbindung mit dem Wago-Controller
#
# ----------HISTORY----------
# WANN   WER   WAS
# 280706 rothf proc erstellt
#
#END----------------------------------------------------------------
proc wc_InitComm_Wago {} {
    global PB_WAGO833
    global Data_Out_Offset
    global Control_Wago

    set Control_Wago 0                                 ;#Steuerwort

    TlPrint "Init communication with Wago"

    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago
    WagoDigiWrite [expr $Data_Out_Offset + 1] 11 [list 0 0 0 0 0 0 0 0 0 0 0]
    doWaitMsSilent 200

};#wc_InitComm_Wago

#--------------------------------------------------------------------------------------
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Liest die aktuelle Geschwindigkeit von Gerät 1, die vom WAGO-Controller
# ermittelt wurde aus.
#
# WICHTIG! -> zuvor muss "wc_InitComm_Encoder" ausgeführt werden
#
# ----------HISTORY----------
# WANN   WER   WAS
# 130706 rothf proc erstellt
# 050712 rothf proc changed, now the processed value in wago PLC will be read out
#
#END----------------------------------------------------------------
proc wc_GetSpeed_Encoder { {EncType "ABI"} {EncNumber 1} {print 0} } {
    global PB_WAGO833
    global Data_In_Offset
    global Data_Out_Offset
    global Control_Wago
    global Enc_In_Offset1 Enc_In_Offset2
    global Enc_Out_Offset1 Enc_Out_Offset2

    switch $EncType {
	"SSI" {
	    switch $EncNumber {
		1 {set offset 4}
		2 {set offset 6}
	    }
	}
	"ABI" {
	    switch $EncNumber {
		1 {set offset 0}
		2 {set offset 2}
	    }
	}
    }

    set speedList [WagoSpecialRead [expr $Data_In_Offset + $offset] 2]
    set speed [expr [lindex $speedList 0] + [lindex $speedList 1] * 256]
    if {$print} {
	TlPrint "Read out speed from $EncType Encoder $EncNumber ($speed rpm)"
    }

    return $speed

}

#--------------------------------------------------------------------------------------
proc wc_GetPos_Encoder { } {
    global PB_WAGO833
    global Data_In_Offset Data_Out_Offset Control_Wago

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Liest die aktuelle Position von Gerät 1, die vom WAGO-Controller
    # ermittelt wurde aus.
    #
    # WICHTIG! -> zuvor muss "wc_InitComm_Encoder" ausgeführt werden
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 130706 rothf proc erstellt
    #
    #END----------------------------------------------------------------
    TlPrint "Positionserfassung ueber externen Encoder an Geraet 1"

    set Control_Wago [expr 2 * 2]
    #Position über Steuerwort anfordern
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago

    doWaitMsSilent 100

    set liste [WagoDigiRead [expr $Data_In_Offset + 4] 4]
    TlPrint $liste

    set ActPos  0.0

    if {[expr [lindex $liste 3] >= 128]} {
	set wert [expr [lindex $liste 3] - 128]
	TlPrint "wert: $wert"
	set liste [lreplace $liste 3 3]
	lappend liste $wert
	set sign 1
    } else {
	set sign -1
    }
    TlPrint $liste
    TlPrint "sign: $sign"

    set ActPos [expr $ActPos + [lindex $liste 0] + 256 * [lindex $liste 1]+ 65536 * [lindex $liste 2]+ 16777216 * [lindex $liste 3]]
    set ActPos [expr $ActPos * $sign]

    TlPrint "Ermittelte Position von Geraet 1: $ActPos "
    return [expr round($ActPos)]

}

#--------------------------------------------------------------------------------------
proc wc_SetPos_Encoder0 { } {
    global PB_WAGO833
    global Data_In_Offset Data_Out_Offset Control_Wago

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Setzt den erweiterten Zähler auf Null
    #
    # WICHTIG! -> zuvor muss "wc_InitComm_Encoder" ausgeführt werden
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 130706 rothf proc erstellt
    #
    #END----------------------------------------------------------------
    TlPrint "Positionserfassung ueber externen Encoder auf Null setzen"

    set Control_Wago 0

    #Kurzzeitig Positionierung anfordern -->Null-Initialisierung
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago
    TlPrint "Control an WAGO: 0 "

    #Encoder initialisieren für Positionserfassung
    wc_SetEncoder

    doWaitMs 1000
    set Control_Wago [expr 2 * 2]
    WagoDigiWrite $Data_Out_Offset 1 $Control_Wago
    TlPrint "Control an WAGO: 2 "

    doWaitMs 1000
    checkPACTEncoder 0 5
}

#--------------------------------------------------------------------------------------
proc wc_Jog {DevNr command {speed "SLOW"}} {

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
    # Manuellfahrt über HW-IO's
    #
    #
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 271006 rothf proc erstellt
    #
    #END----------------------------------------------------------------

    TlError "adaption to Servo3 needed (setDI instead of wc_Set_LIMx)"
    switch -regexp $command {
	"NEG" {
	    #TlPrint "Manuellfahrt Positiv"
	    wc_Set_LIMN $DevNr "L"
	    wc_Set_REF $DevNr "H"
	}
	"POS" {
	    #TlPrint "Manuellfahrt Negativ"
	    wc_Set_REF $DevNr "L"
	    wc_Set_LIMN $DevNr "H"
	}
	"STOP" {
	    TlPrint "Manuellfahrt beenden"
	    wc_Set_REF $DevNr "L"
	    wc_Set_LIMN $DevNr "L"
	    return
	}
	default {TlError "Uebergabewert: command ungueltig"}
    }

    switch -regexp $speed {
	"FAST" {
	    #TlPrint "   - schnell"
	    wc_Set_HALT $DevNr "H"
	}
	"SLOW" {
	    #TlPrint "   - langsam"
	    wc_Set_HALT $DevNr "L"
	}
	default {TlError "Uebergabewert: speed ungueltig"}
    }

    TlPrint "Manuellfahrt $command, $speed"
}

#--------------------------------------------------------------------------------------
proc wc_Set_WP_DIR {mode} {
    #Zu- bzw. Wegschalten des Richtungssinals

    switch -regexp $mode {
	"ON"    {
	    #WICHTIG: Zuerst Pulsesignal von Eingang CCW wegnehmen,
	    #dann DIR aufschalten
	    wc_Set_Pulse_CCW "OFF"
	    doWaitMs 200
	    TlPrint "Richtung-Signale von WP verbinden"
	    wc_SetDigital 5 0x0004 "L"
	}
	"OFF" {
	    TlPrint "Richtung-Signale von WP trennen"
	    wc_SetDigital 5 0x0004 "H"
	}
	default {
	    TlError "Falscher Parameter an 'wc_Set_WP_DIR'"
	}
    }
}

#--------------------------------------------------------------------------------------
proc wc_Set_Pulse_CW {mode} {
    #Zu- bzw. Wegschalten des Pulssignals

    switch -regexp $mode {
	"ON"    {
	    TlPrint "Pulse-Signale auf CW-Eingang schalten"
	    wc_SetDigital 5 0x0010 "L"
	}
	"OFF" {
	    TlPrint "Pulse-Signale von CW-Eingang entfernen"
	    wc_SetDigital 5 0x0010 "H"
	}
	default {
	    TlError "Falscher Parameter an 'wc_Set_Pulse_CW'"
	}
    }
}

#--------------------------------------------------------------------------------------
proc wc_Set_Pulse_CCW {mode} {
    #Zu- bzw. Wegschalten des Pulssignals

    switch -regexp $mode {
	"ON"    {
	    #WICHTIG: Zuerst Richtungssignal von Eingang CCW wegnehmen,
	    #dann Pulse aufschalten
	    # Richtungssignal muss anschließend wieder manuell aufgeschalten werden
	    wc_Set_WP_DIR "OFF"
	    doWaitMs 200
	    TlPrint "Pulse-Signale auf CCW-Eingang schalten"
	    wc_SetDigital 5 0x0008 "H"

	}
	"OFF" {
	    TlPrint "Pulse-Signale von CCW-Eingang entfernen"
	    wc_SetDigital 5 0x0008 "L"
	}
	default {
	    TlError "Falscher Parameter an 'wc_Set_Pulse_CCW'"      }
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Servo3 on or off, set only the wago output and nothing else
#
# ----------HISTORY----------
# WHEN   WHO    WHAT
# 250408 rothf  created
# 230115 serio  adapted for Fortis
#
#END----------------------------------------------------------------
proc wc_Servo3OnOff { DevNr Level } {

    ##If the ServoDrive is switched on allow access to Tcl_Debugger to Read ServoDrive Paramaters
    global Debugger_StopParaRead 
    global ActDev DevAdr sePLC
    if {"$Level" == "L"} {set Debugger_StopParaRead 1}
    ##If the ServoDrive is switched on allow access to Tcl_Debugger to Read ServoDrive Paramaters

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
    } else {
	set value 0
    }
if { ![GetSysFeat "Gen2Tower"] } {
    switch $DevNr {
	"11" {
	    if {[GetDevFeat "Fortis"]} {
		wc_SetDigital 2 0x10 $Level         ;# Switch on logic (24VDC) and power supply
	    } else {
		if {[GetDevFeat "FortisHW"]} {

		    wc_SetDigital 2 0x10 $Level         ;# Switch on logic (24VDC) and power supply
		} else {
		    wc_SetDigital 1 0x08 $Level         ;# Switch on logic (24VDC) and power supply

		}
		;# for OPAL test tower Servo3 device is only load,
		;# therefore no separate switch on of power and control.
	    }

	}
	"12" {
	    if {[GetDevFeat "Fortis"]} {
		wc_SetDigital 2 0x20 $Level         ;# Switch on logic (24VDC) and power supply
	    } else {
		if {[GetDevFeat "FortisHW"]} {

		    wc_SetDigital 2 0x20 $Level         ;# Switch on logic (24VDC) and power supply
		} else {
		    wc_SetDigital 1 0x80 $Level         ;# Switch on logic (24VDC) and power supply
		}

		;# for OPAL test tower Servo3 device is only load,
		;# therefore no separate switch on of power and control.
	    }
	}
	"13" {
	    if {[GetDevFeat "Fortis"]} {
		wc_SetDigital 2 0x40 $Level         ;# Switch on logic (24VDC) and power supply
	    } else {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
	"31" {
	    if {[GetDevFeat "Fortis"]} {
		wc_SetDigital 2 0x10 $Level         ;# Switch on logic (24VDC) and power supply
	    } else {
		if {[GetDevFeat "FortisHW"]} {

		    wc_SetDigital 2 0x10 $Level         ;# Switch on logic (24VDC) and power supply
		} else {
		    wc_SetDigital 1 0x08 $Level         ;# Switch on logic (24VDC) and power supply

		}
		;# for OPAL test tower Servo3 device is only load,
		;# therefore no separate switch on of power and control.
	    }

	}
	"33" {
	    if {[GetDevFeat "Fortis"]} {
		wc_SetDigital 2 0x20 $Level         ;# Switch on logic (24VDC) and power supply
	    } else {
		if {[GetDevFeat "FortisHW"]} {

		    wc_SetDigital 2 0x20 $Level         ;# Switch on logic (24VDC) and power supply
		} else {
		    wc_SetDigital 1 0x80 $Level         ;# Switch on logic (24VDC) and power supply
		}

		;# for OPAL test tower Servo3 device is only load,
		;# therefore no separate switch on of power and control.
	    }
	}

	default  {
	    TlError "Unexpected device No. $DevNr"
	    return 0
	}
    }
} else { 
	se_TCP_writeWordMask [expr  $sePLC(towerStructureOffset) +  $sePLC(LoadOffset) ] [expr round(pow(2,[expr $DevAdr($ActDev,LoadIndex) - 1]))]  [expr round(pow(2,[expr $DevAdr($ActDev,LoadIndex) - 1])) * $value] ;# write the proper bit of the word either to 0 or to 1	
}

    return 1

} ;# wc_Servo3OnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Altivar
#
# ----------HISTORY----------
# WANN   WER    WAS
# 160710 rothf  proc created
# 290713 cordc  update for NERA
# 130622 savra	update for gen2tower
#
#END----------------------------------------------------------------
proc wc_OpalOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
    } else {
	set value 0
    }

    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "1" {
		wc_SetDigital 1 0x07 $Level         ;# Power on Device N1
		set Dev_On(1) $value
	    }
	    "2" {
		wc_SetDigital 1 0x70 $Level         ;# Power on Device N3
		set Dev_On(2) $value
	    }
      "3" - "4" {
	 if {[GetSysFeat "EAETower1"]} {
		if {$DevNr == 3} {
			set index 3
			wc_SetDigital_EAE 303 $index $value
			# Power on motor for Device 3
			wc_SetDigital_EAE 303 13 $value
		} elseif {$DevNr == 4} {
			set index 4
			wc_SetDigital_EAE 303 $index $value
			# Power on motor for Device 3
			wc_SetDigital_EAE 303 14 $value
		}
		
	 }	 
	 set Dev_On(index) $value
      }
	    "21" {
		wc_SetDigital 1 0x07 $Level         ;# Power on Device N1
		set Dev_On(21) $value
	    }
	    "23" {
		wc_SetDigital 1 0x70 $Level         ;# Power on Device N3
		set Dev_On(23) $value
	    }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    return 1

} ;# wc_OpalOnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Kala
#
# ----------HISTORY----------
# WHEN   WHO    WHAT
# 110215 serio  proc created
#
#END----------------------------------------------------------------
proc wc_KalaOnOff { DevNr Level } {

    if {[GetDevFeat "Nera"]} {

	wc_NeraOnOff $DevNr $Level

    } elseif {[GetDevFeat "Beidou"]} {

	wc_BeidouOnOff $DevNr $Level

    } elseif {[GetDevFeat "Fortis"] || [GetDevFeat "Opal"]} {

	wc_FortisOnOff $DevNr $Level

    } else {

	TlError "Project not supported"
	return 0

    }

} ;# wc_KalaOnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Kala Nera
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 050813 todet proc created from wc_OpalOnOff
# 221121 mpere updated the power off mechanism for NERA to save time
# 130324 ASY   added devices 12 & 13 
# 050424 YGH   removed devices 12 & 13 
#
#END----------------------------------------------------------------
proc wc_NeraOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
      "1" {
	 TlPrint "switch Nera device $DevNr $status"
	 if {[GetSysFeat "EAETower1"]} {
		wc_SetDigital_EAE 303 1 $value
		 doWaitMs 1000
		# Power on motor
		wc_SetDigital_EAE 303 11 $value
	 } else { 
		 wc_SetDigital 1 0x70 $Level
	 }
	 set Dev_On(2) $value
      }
	    "2" {
		TlPrint "switch Nera device $DevNr $status"
		wc_SetDigital 1 0x070 $Level
		set Dev_On(2) $value
	    }
	    "3" {
		TlPrint "switch Nera device $DevNr $status"
		wc_SetDigital 9 0x07 $Level
		set Dev_On(3) $value
	    }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    if { $Level == "L" } {

	doWaitForOff 60

    } else {

	doWaitForModState ">=0" 60

    }

    return 1

}

# Doxygen Tag:
##Function description : low level function to turn on and off an ATS product 
# WHEN  | WHO  | WHAT
# -----| -----| -----
#2024/03/13 | ASY | proc created
#2024/04/05 | YGH | Replaced "Nera" in TlPrint by "ATS"
# \n
# Function to be called from a higher level 
#
proc wc_ATSOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "11" {
		TlPrint "switch ATS device $DevNr $status"
	 if {[GetSysFeat "EAETower1"]} {
		wc_SetDigital_EAE 303 6 $value
	 }
		set Dev_On(11) $value
	    }
	    "14" {
		TlPrint "switch ATS device $DevNr $status"
	 if {[GetSysFeat "EAETower1"]} {
		wc_SetDigital_EAE 303 9 $value
	 }
		set Dev_On(14) $value
	    }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    if { $Level == "L" } {

	doWaitForOff 60

    } else {

	doWaitForModState ">=0" 60

    }

    return 1

}
#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Kala Fortis
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 050813 pfeig proc created from wc_NeraOnOff
# 040215 serio/grola Workaround for Com option board towers
# 150415 serio add PACY_COM_DEVICENET case
# 130622 savra update for Gen2Tower
# 050424 YGH   added devices 12 & 13 
#
#END----------------------------------------------------------------
proc wc_FortisOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "1" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		wc_SetDigital 1 0x07 $Level
		set Dev_On(1) $value
	    }
	    "8" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		wc_SetDigital 1 0x07 $Level
		set Dev_On(1) $value
	    }
	    "21" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		wc_SetDigital 1 0x07 $Level
		set Dev_On(1) $value
		}
	    "2" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
	 if {[GetSysFeat "EAETower1"]} {
		wc_SetDigital_EAE 303 2 $value
		 # Power on motor for Device 2
		 wc_SetDigital_EAE 303 12 $value
	 } else {
		wc_SetDigital 1 0x70 $Level
		 }
		set Dev_On(2) $value
	    }
	    "23" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		wc_SetDigital 1 0x70 $Level
		set Dev_On(2) $value
	    }
	    "9" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		wc_SetDigital 1 0x70 $Level
		set Dev_On(2) $value
	    }
	    "3" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}         
		wc_SetDigital 2 0x07 $Level
		set Dev_On(3) $value
	    }
	    "5" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		if {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] } {
		    wc_SetDigital 11 0x1C $Level
		} elseif {[GetSysFeat "PACY_COM_DEVICENET"] } {
		    wc_SetDigital 12 0x70 $Level
		} elseif {[GetSysFeat "PACY_COM_CANOPEN"] } {
		    wc_SetDigital 11 0x07 $Level
		} else {
		    wc_SetDigital 8 0x1C $Level
		}
		set Dev_On(5) $value
	    }
	    "15" {
		if { [ GetDevFeat "ShadowOffer"] } {   
			TlPrint "switch ShadowOffer device $DevNr $status"
		} else {
			TlPrint "switch Fortis device $DevNr $status"	
		}
		if {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"] } {
		    wc_SetDigital 11 0x1C $Level
		} elseif {[GetSysFeat "PACY_COM_DEVICENET"] } {
		    wc_SetDigital 12 0x70 $Level
		} elseif {[GetSysFeat "PACY_COM_CANOPEN"] } {
		    wc_SetDigital 11 0x07 $Level
		} else {
		    wc_SetDigital 8 0x1C $Level
		}
		set Dev_On(5) $value
	    }
	    "12" {
		TlPrint "switch Fortis device $DevNr $status"
		if {[GetSysFeat "EAETower1"]} {
		       wc_SetDigital_EAE 303 7 $value
		}
		set Dev_On(12) $value
	    }
	    "13" {
		TlPrint "switch Fortis device $DevNr $status"
		if {[GetSysFeat "EAETower1"]} {
		       wc_SetDigital_EAE 303 8 $value
		}
		set Dev_On(13) $value
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    return 1

}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on ATV320
#
# ----------HISTORY----------
# WANN       | WER |  WAS
# 2023/08/10 | MLT | proc created from wc_BeidouOnOff
#
#END----------------------------------------------------------------
proc wc_ATV320OnOff { DevNr Level } {
    global Dev_On

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }

    switch $DevNr {
	"4" {
	    TlPrint "switch ATV320 device $DevNr $status"
	    wc_SetDigital 9 0x38 $Level
	    set Dev_On(4) $value
	}
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return 0
	}
    }

    return 1

} ;# wc_ATV320OnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on ATV310
#
# ----------HISTORY----------
# WANN   WER    WAS
# 090819 Alan proc created from wc_BeidouOnOff
#
#END----------------------------------------------------------------
proc wc_ATV310OnOff { DevNr Level } {
    global Dev_On

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }

    switch $DevNr {
	"1" {
	    TlPrint "switch ATV310 device $DevNr $status"
	    wc_SetDigital 9 0x38 $Level
	    set Dev_On(1) $value
	}
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return 0
	}
    }

    return 1

} ;# wc_ATV310OnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Kala MVK
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 160217 cordc proc created
# 130622 savra update for Gen2Tower
#
#END----------------------------------------------------------------
proc wc_MVKOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
	#      ModTlWrite SIMC 1
	#      doWaitMs 4000
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "1" {
		if {[GetSysFeat "MVKTower1"] || [GetSysFeat "MVKTower2"]} {
		    TlPrint "switch MVK device $DevNr $status"
		    wc_SetDigital 3 0xC $Level
		    set Dev_On(1) $value
		} else {
		    TlPrint "switch MVK device $DevNr $status"
		    wc_SetDigital 1 0x07 $Level
		    set Dev_On(1) $value
		}
	    }
	    "2" {
		TlPrint "switch MVK device $DevNr $status"
		wc_SetDigital 1 0x70 $Level
		set Dev_On(2) $value
	    }

	    "3" {
		TlPrint "switch MVK device $DevNr $status"
		wc_SetDigital 2 0x07 $Level
		set Dev_On(3) $value
	    }
	    "5" {

		if {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"]} {
		    wc_SetDigital 9 0x80 $Level           ;#Connect P24 supply
		} elseif {[GetSysFeat "PACY_COM_CANOPEN"]} {
		    wc_SetDigital 11 0x08 $Level           ;#Connect P24 supply
		} elseif {[GetSysFeat "PACY_COM_DEVICENET"]} {
		    wc_SetDigital 12 0x80 $Level           ;#Connect P24 supply
		} else {
		    wc_SetDigital 8 0x20 $Level           ;#Connect P24 supply
		}

		set Dev_On(5) $value
	    }
	    "6" {

		if {[GetSysFeat "PACY_APP_OPAL"] || [GetSysFeat "PACY_COM_PROFINET"]} {
		    wc_SetDigital 9 0x80 $Level           ;#Connect P24 supply
		} elseif {[GetSysFeat "PACY_COM_CANOPEN"]} {
		    wc_SetDigital 11 0x08 $Level           ;#Connect P24 supply
		} elseif {[GetSysFeat "PACY_COM_DEVICENET"]} {
		    wc_SetDigital 12 0x80 $Level           ;#Connect P24 supply
		} else {
		    wc_SetDigital 8 0x20 $Level           ;#Connect P24 supply
		}

		set Dev_On(5) $value
	    }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0xFF00 [expr $value << 8]
	set Dev_On($DevNr) $value
    }

    return 1

}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Kala Beidou
#
# ----------HISTORY----------
# WANN   WER    WAS
# 050813 todet proc created from wc_NeraOnOff
# 130622 savra update for Gen2Tower
#
#END----------------------------------------------------------------
proc wc_BeidouOnOff { DevNr Level } {
    global Dev_On

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
	set status "on"
    } else {
	set value 0
	set status "off"
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "4" {
		TlPrint "switch Beidou device $DevNr $status"
		wc_SetDigital 9 0x38 $Level
		set Dev_On(4) $value
	    }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    return 1

} ;# wc_BeidouOnOff


#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch resistor on DC-Bus of the drive to discharge it
#
# ----------HISTORY----------
# WANN   WER    WAS
# 230913 todet proc created
#
#END----------------------------------------------------------------
proc wc_DCDischarge { DevNr } {
    global Dev_On

    if {![GetDevFeat "DCDischarge"]} {return 0}

    if {$Dev_On($DevNr)} {
	TlError "Device is still switched on!!!"
	return 0
    }

    TlPrint "Wait 3 sec before discharge"
    doWaitMs 3000

    TlPrint "Discharge DC-Bus over Resistor"
    switch $DevNr {
	"3" {
	    wc_SetDigital 8 0x40 h
	}
	"4" {
	    wc_SetDigital 8 0x80 h
	}
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return 0
	}
    }

    TlPrint "Disconnect Resistor"
    doWaitMs 1500
    wc_SetDigital 8 0xC0 l

    return 1

} ;# wc_DCDischarge

#DOC----------------------------------------------------------------
#DESCRIPTION
# switches on the 5V supply via modbus cable
# for configuration transfer (in the box)
#
# ----------HISTORY----------
# WANN   WER   WAS
# 091021 rothf erstellt
#
#END----------------------------------------------------------------
proc wc_SwitchOn5VSupply {Level} {

    set Level [string toupper $Level]
    TlPrint "Switch 5V power supply $Level"
    set channel 10
    set mask    0x20
    if {$Level == "ON"} {
	wc_SetDigital $channel $mask "H"
	doWaitForModDeviceAnswer 5
    } elseif {$Level == "OFF"} {
	wc_SetDigital $channel $mask "L"
    }
}

#-------------------------------------------------------------------------
#Hier wird zwischen den beiden Ethernet- und Profibus-Controller
#Varianten umgeschaltet
#-------------------------------------------------------------------------

#DOC----------------------------------------------------------------
#DESCRIPTION
#Zwischenschicht zur Unterscheidung zwischen verschiedenen im
#Einsatz befindlichen Wago-Controllern: Schreibbefehl
#
# ----------HISTORY----------
# WANN   WER    WAS
# 250408 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc WagoDigiWrite {Offset Length Data} {
    global PB_WAGO833
    global Wago_Type

    if {$Wago_Type == "Ethernet"} {
	wc_TCP_WriteByte $Offset $Length $Data
    } elseif {$Wago_Type == "Profibus"} {
	set rc [catch {eval pbWagoIo833Write $PB_WAGO833 $Offset $Length [join $Data " "]} Msg]
	if {$rc != 0} {
	    TlPrint "Fehlermeldung pbWagoIo833Write: %s" $Msg
	    # TlPrint "ErrorInfo: $errorInfo"
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#Zwischenschicht zur Unterscheidung zwischen verschiedenen im
#Einsatz befindlichen Wago-Controllern: Lesebefehl
#
# ----------HISTORY----------
# WANN   WER    WAS
# 250408 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc WagoDigiRead {Offset Len} {
    global PB_WAGO833
    global Wago_Type

    if {$Wago_Type == "Ethernet"} {
	set Data [wc_TCP_ReadByte $Offset $Len]
    } elseif {$Wago_Type == "Profibus"} {
	set Data [pbWagoIo833Read $PB_WAGO833 $Offset $Len ]
    }
    return $Data
}

proc WagoSpecialWrite {Offset Len Data} {
    #Offset in Byte (Kompatibilität mit Profibus Controller)
    global PB_WAGO833
    global Wago_Type

    doWaitMsSilent 10
    if {$Wago_Type == "Ethernet"} {

	set Data_Pointer 0            ;#zeigt auf das nächste zu schreibende Datum

	#Wenn Modulowert != Null, dann ist es eine ungerade Byteadresse --> erstes Byte schreiben
	#zuvor muss der Status des Wortes ausgelesen werden, um das Low-Byte nicht zu verändern
	if {[expr $Offset % 2 ] != 0} {
	    set Word_Offset [expr round( $Offset / 2 )]
	    set value_act [wc_TCP_ReadOutputWord $Word_Offset 1]            ;#alten Wert auslesen
	    set value_new [expr ($value_act & 0x00FF) + ( [lindex $Data $Data_Pointer] << 8)]   ;#neuen Wert berechnen
	    wc_TCP_WriteWord $Word_Offset $value_new
	    #TlPrint "1: Offset: $Offset; Word_Offset: $Word_Offset; Len: $Len; value_new: $value_new"
	    set Offset [expr $Offset + 1]            ;#Offset um eins erhöhen --> jetzt gerade
	    set Len [expr $Len - 1]                  ;#Länge um eins erniedrigen
	    set Data_Pointer [expr $Data_Pointer + 1]

	}

	#jetzt alle kompletten Worte schreiben
	while {$Len >= 2} {
	    set Word_Offset [expr $Offset / 2]
	    #set value_new [expr [lindex $Data [expr $Data_Pointer + 1]] + ([lindex $Data $Data_Pointer] << 8) ]
	    set value_new [expr [lindex $Data $Data_Pointer] + ([lindex $Data [expr $Data_Pointer + 1]] << 8) ]
	    wc_TCP_WriteWord $Word_Offset $value_new
	    #TlPrint "2: Offset: $Offset; Word_Offset: $Word_Offset; Len: $Len; value_new: $value_new"
	    set Offset [expr $Offset + 2]
	    set Len [expr $Len - 2]
	    set Data_Pointer [expr $Data_Pointer + 2]
	}

	#wenn nun noch ein Byte übrig bleibt, dann auch noch schreiben
	if {$Len == 1} {
	    set Word_Offset [expr $Offset / 2]
	    set value_act [wc_TCP_ReadOutputWord $Word_Offset 1]            ;#alten Wert auslesen
	    set value_new [expr ($value_act & 0xFF00) + [lindex $Data $Data_Pointer] ]   ;#neuen Wert berechnen
	    wc_TCP_WriteWord $Word_Offset $value_new
	    #TlPrint "3: Offset: $Offset; Word_Offset: $Word_Offset; Len: $Len; value_new: $value_new"
	    set Offset [expr $Offset + 1]
	    set Len [expr $Len - 1]
	    set Data_Pointer [expr $Data_Pointer + 1]
	}

	#Reihenfolge der Werte umkopieren
	for {set i [llength $Data]} {$i >= 0} {incr i -1} {
	    append temp_Data [lindex $Data $i]
	}
	set Data $temp_Data

	#wenn jetzt noch nicht alle ausgelesen sind, dann lief irgendwas schief
	if {$Len > 0} {
	    TlError "Word write error to Wago Ethernet Controller"
	}

    } elseif {$Wago_Type == "Profibus"} {
	eval [subst {pbWagoIo833Write $PB_WAGO833 $Offset $Len $Data}]
    }
    #return $Data

}

proc WagoSpecialRead {Offset Len} {
    #Offset in Byte (Kompatibilität mit Profibus Controller)
    global PB_WAGO833
    global Wago_Type

    if {$Wago_Type == "Ethernet"} {

	#Wenn Modulowert != Null, dann ist es eine ungerade Byteadresse --> erstes Byte auslesen
	if {[expr $Offset % 2 ] != 0} {
	    set Word_Offset [expr round( $Offset / 2 )]
	    lappend Data [expr ([wc_TCP_ReadWord $Word_Offset 1] & 0xFF00) >> 8 ]
	    set Offset [expr $Offset + 1]            ;#Offset um eins erhöhen --> jetzt gerade
	    set Len [expr $Len - 1]                  ;#Länge um eins erniedrigen
	    #TlPrint "Data1: $Data"
	}

	#jetzt alle kompletten Worte auslesen
	while {$Len >= 2} {
	    set Word_Offset [expr $Offset / 2]
	    set rc [expr [wc_TCP_ReadWord $Word_Offset 1] & 0xFFFF]
	    lappend Data [expr $rc & 0xFF] [expr ($rc & 0xFF00) >> 8]
	    set Offset [expr $Offset + 2]
	    set Len [expr $Len - 2]
	    #TlPrint "Data2: $Data"
	}

	#wenn nun noch ein Byte übrig bleibt, dann auch noch auslesen
	if {$Len == 1} {
	    set Word_Offset [expr $Offset / 2]
	    lappend Data [expr [wc_TCP_ReadWord $Word_Offset 1] & 0x00FF]
	    set Offset [expr $Offset + 1]
	    set Len [expr $Len - 1]
	    #TlPrint "Data3: $Data"
	}

	#      #Reihenfolge der Werte umkopieren
	#      for {set i [llength $Data]} {$i >= 0} {incr i -1} {
	#         lappend temp_Data [lindex $Data $i]
	#      }
	#      set Data $temp_Data

	#      TlPrint "Data: $Data"

	#wenn jetzt noch nicht alle ausgelesen sind, dann lief irgendwas schief
	if {$Len > 0} {
	    TlError "Fehler beim auslesen eines Wortes vom Wago Ethernet Controller"
	}

    } elseif {$Wago_Type == "Profibus"} {
	set Data [eval [ subst {pbWagoIo833Read $PB_WAGO833 $Offset $Len }]]
    }
    return $Data

}

#-------------------------------------------------------------------------
#Grundlegende Schreib-Lesebefehle für die Wago 841/842 Ethernet-Controller
#-------------------------------------------------------------------------

#DOC----------------------------------------------------------------
#DESCRIPTION
# Schreiben eines Bits auf einen Wago-Ethernet-Controller (Modbus FC 0x05)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  Beschreibung
#
#  FC    BitAdresse     Wert (FF00=High; 0000=Low)
#  05    xxxx           xxxx
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 301107 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_WriteSingleBit {Bit_Number Level} {
    global Wago_IPAddress

    switch -regexp $Level {
	"[Hh]" {
	    set Level "FF00"
	}
	"[Ll]" {
	    set Level "0000"
	}
	default {
	    TlError "Level $Level not defined!"
	}
    }
    append send_string "05" [format %04X $Bit_Number] $Level
    mb2Direct $Wago_IPAddress $send_string
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Schreiben eines Ausgangs-Bytes auf einen Wago-Ethernet-Controller (Modbus FC 0x0F)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  --> FC 0x0F ist normalerweise Schreiben mehrer Bits, wird aber hier
#  zum Schreiben eines Bytes umfunktioniert
#  Beschreibung
#
#  FC    BitAdresse  BitCount ByteCount  Wert
#  10    xxxx           0008      01      xxxx
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 031207 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_WriteByte {Byte_Number Length value } {
    global Wago_IPAddress

    set Bit_Offset [expr $Byte_Number * 8]
    set Bit_Amount [expr $Length * 8]

    for {set i 0} {$i < $Length} {incr i} {
	append value_temp [format %02x [lindex $value $i]]
    }
    #TlPrint "value_temp: $value_temp"

    append send_string "0F" [format %04X $Bit_Offset] [format %04X $Bit_Amount] [format %02X $Length] $value_temp "00"
    mb2Direct $Wago_IPAddress $send_string
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Schreiben eines Ausgangs-Wortes auf einen Wago-Ethernet-Controller (Modbus FC 0x06)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  Beschreibung
#
#  FC    WordAdresse     Wert
#  06    xxxx           xxxx
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 031207 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_WriteWord {Word_Number value } {
    global Wago_IPAddress

    append send_string "06" [format %04X $Word_Number] [format %04X $value]
    mb2Direct $Wago_IPAddress $send_string
    #TlPrint "value: $value"
    #TlPrint "mb2Direct $Wago_IPAddress $send_string"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Schreiben eines Bits auf einen Wago-Ethernet-Controller (Modbus FC 0x05)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  Beschreibung
#
#  FC    BitAdresse     Wert (FF00=High; 0000=Low)
#  05    xxxx           xxxx
#
# ----------HISTORY----------
# WANN   WER    WAS
# 301107 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadOutputBit {Bit_Number} {
    global Wago_IPAddress

    append send_string "01" [format %04X [expr $Bit_Number + 0x200]] "0001"
    #mb2Direct $Wago_IPAddress $send_string
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & 0x0001]
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Lesen eines Eingangs-Bits von einem Wago-Ethernet-Controller (Modbus FC 0x01)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#
#  Beschreibung
#
#  FC    BitAdresse     Anzahl
#  01    xxxx           0001
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 031207 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadSingleBit {Bit_Number} {
    global Wago_IPAddress

    append send_string "01" [format %04X $Bit_Number] "0001"
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & 0x0001]
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Lesen eines Ausgangs-Bits von einem Wago-Ethernet-Controller (Modbus FC 0x01)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#   FC 0x01 liest normalerweise nur die Eingänge, allerdings werden
#  bei den Ethernet-Controllern die Ausgänge ab Adresse 0x200 gespiegelt
#
#  Beschreibung
#
#  FC    BitAdresse  Anzahl
#  01    xxxx         0001
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 250408 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadOutputBit {Bit_Number} {
    global Wago_IPAddress

    append send_string "01" [format %04X [expr $Bit_Number + 0x200]] "0001"
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & 0x0001]
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Lesen eines Eingangs-Bytes von einem Wago-Ethernet-Controller (Modbus FC 0x02)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  --> FC 0x02 ist normalerweise Lesen mehrer Bits, wird aber hier
#  zum Lesen eines Bytes umfunktioniert
#  Beschreibung
#
#  FC    BitAdresse  Anzahl
#  10    xxxx         0008
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 031207 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadByte {Byte_Number Length} {
    global Wago_IPAddress

    #TlPrint ""
    set Bit_Offset [expr $Byte_Number * 8]
    #TlPrint "Bit_Offset: $Bit_Offset"
    set Bit_Length [expr $Length * 8]
    #TlPrint "Bit_Length: $Bit_Length"
    set Bit_Mask [expr round(pow(2, $Bit_Length) - 1)]
    #TlPrint "Bit_Mask: $Bit_Mask"

    append send_string "02" [format %04X $Bit_Offset] [format %04X $Bit_Length]
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & $Bit_Mask]

    #TlPrint "value: $value"
    #TlPrint ""
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Lesen eines Ausgangs-Bytes von einem Wago-Ethernet-Controller (Modbus FC 0x02)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#   FC 0x02 liest normalerweise nur die Eingänge, allerdings werden
#  bei den Ethernet-Controllern die Ausgänge ab Adresse 0x200 gespiegelt
#
#  Beschreibung
#
#  FC    BitAdresse  Anzahl
#  02    xxxx         0008
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 250408 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadOutputByte {Byte_Number} {
    global Wago_IPAddress

    set Bit_Offset [expr $Byte_Number * 8 + 0x200]

    append send_string "02" [format %04X $Bit_Offset] "0008"
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & 0x00FF]
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Lesen eines Eingangs-Wortes von einem Wago-Ethernet-Controller (Modbus FC 0x03)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#  Beschreibung
#
#  FC    WordAdresse   Anzahl
#  03    xxxx           xxxx
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 031207 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadWord {Word_Number Length} {
    #Length in Word
    global Wago_IPAddress

    set Bit_Mask [expr round(pow(2, $Length * 16) - 1)]
    #TlPrint "Bit_Mask: $Bit_Mask"
    append send_string "03" [format %04X $Word_Number] [format %04X $Length]
    #TlPrint "send_string: $send_string"
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & $Bit_Mask]
    #TlPrint "value: %X " $value
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Lesen eines Eingangs-Wortes von einem Wago-Ethernet-Controller (Modbus FC 0x03)
#  (Zuvor Modbus-TCP Schnittstelle öffnen --> "mb2Open TCP")
#
#   FC 0x03 liest normalerweise nur die Eingänge, allerdings werden
#  bei den Ethernet-Controllern die Ausgänge ab Adresse 0x200 gespiegelt
#
#  Beschreibung
#
#  FC    WordAdresse   Anzahl
#  03    xxxx           xxxx
#
#
# ----------HISTORY----------
# WANN   WER    WAS
# 170608 rothf  proc erstellt
#
#END----------------------------------------------------------------
proc wc_TCP_ReadOutputWord {Word_Number Length} {
    #Length in Word
    global Wago_IPAddress

    set Word_Address [expr $Word_Number + 0x0200]
    set Bit_Mask [expr round(pow(2, $Length * 16) - 1)]
    append send_string "03" [format %04X $Word_Address] [format %04X $Length]
    set value [expr 0x[mb2Direct $Wago_IPAddress $send_string] & $Bit_Mask]
    return $value
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#END----------------------------------------------------------------
proc wc_GetEncoderSSI {  } {
    global PB_WAGO833
    global Wago_Type
    global ActDev
    global Enc_In_Offset1 Enc_In_Offset3

    #set EncSSI_Offset1 $Enc_In_Offset3

    set EncSSI_Offset1 $Enc_In_Offset1

    set Len            4    ;# ByteAnzahl

    set Enc_In_Offset $EncSSI_Offset1

    #         WagoDigiRead     ByteOffset  ByteAnzahl
    set Data [WagoSpecialRead $Enc_In_Offset $Len ]

    #Prozessabbild ist für Ethernet
    switch -exact $Wago_Type {
	"Ethernet" {
	    set EncoderPos  [expr {([lindex $Data 3] << 24) + ([lindex $Data 2] << 16) + ([lindex $Data 1] << 8) + ([lindex $Data 0])}]
	}
    }

    # Encoder liefert 25 Bit. Für pos/neg Positionsbereich muss auf 32 Bit erweitert werden
    # => Wenn bit 25 gesetzt Bits 26-32 mit 1 auffüllen
    if {[expr $EncoderPos & 0x1000000]} {
	set EncoderPos [expr $EncoderPos | 0xFE000000]
    }

    TlPrint "Wago_EncoderSSI    ext. Pos  $EncoderPos    %d"  $EncoderPos

    return $EncoderPos
} ;# GetEncoder

#DOC----------------------------------------------------------------
#DESCRIPTION
# Switch off and on Modicon PLC
#
# ----------HISTORY----------
# WANN   WER    WAS
# 091214 todet  proc created
#
#END----------------------------------------------------------------
proc wc_ModiconOffOn { Level } {

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
    } else {
	set value 0
    }

   if {[GetSysFeat "EAETower1"]} {
	   
	TlPrint "switch PLC M580"
	wc_SetDigital_EAE 304 2 $value 	    ;# Power ON PLC5 M580
	   
	} elseif {![GetSysFeat "ModiconPLC"]} {
		
	TlError "Modicon not available"
	return 0
		
	} else {

    wc_SetDigital 8 0x20 $Level         ;# Power on Device N3

	}

	
    return 1

} ;# wc_ModiconOffOn
