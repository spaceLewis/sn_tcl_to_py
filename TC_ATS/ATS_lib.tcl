#tag for doc
## \file ATS_Lib.tcl

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off or switch on the ATS control block with 230V.
#
# ----------HISTORY------------------------------------------------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 061222 ASY	  added the DevNr parameter
#
#END----------------------------------------------------------------
## Function description : Switch on or switch off the 230V AC power supply of control block regarding the selected Level.
#
# \param[in] DevNr: DUT to be supplied.
# \param[in] Level: switch on (H) or switch Off(L).
proc CtrlOnOff { DevNr Level } {
    global ActDev
    set PLC_Register1 1007							;# identify the PLC register to control the right output
    set PLC_Bit1 0
    set PLC_Register2 1007
    set PLC_Bit2 8
    set PLC_Register3 1008
    set PLC_Bit3 0
    switch -regexp $DevNr {							;#regarding the device selection
	1 {									;#Device 1
	    set Result [wc_TCP_ReadWord $PLC_Register1 1]			;# read the current state of PLC register
	    set Mask [ expr round(pow(2,$PLC_Bit1))]				;# create a Mask regarding the selected Bits
	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on.
		TlPrint "Switch On 230V CL1/CL2"
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
		return 1
	    }
	    if {[regexp "\[Ll0\]" $Level]&& $IntVar==$Mask} {				;# set the appropriate bit to switch off.
		TlPrint "Cut Off 230V CL1/CL2"
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
		return 1
	    }
	}
	2 {									;#Device 2
	    set Result [wc_TCP_ReadWord $PLC_Register2 1]			;# read the current state of PLC register
	    set Mask [ expr round(pow(2,$PLC_Bit2))]				;# create a Mask regarding the selected Bits
	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on.
		TlPrint "Switch On 230V CL1/CL2"	
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result+ $Mask)]
		return 1
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask} {				;# set the appropriate bit to switch off.
		TlPrint "Cut Off 230V CL1/CL2"
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result- $Mask)]
		return 1
	    }
	}
	3 {									;#Device 3
	    set Result [wc_TCP_ReadWord $PLC_Register3 1]			;# read the current state of PLC register
	    set Mask [ expr round(pow(2,$PLC_Bit3))]				;# create a Mask regarding the selected Bits
	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on.
		TlPrint "Switch On 230V CL1/CL2"	
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result+ $Mask)]
		return 1
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask} {				;# set the appropriate bit to switch off.
		TlPrint "Cut Off 230V CL1/CL2"
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result- $Mask)]
		return 1
	    }
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch between two line phase.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 151123 Yahya	  Added print message for logs (see Issue #1401)
#
#END----------------------------------------------------------------
## Function description : Switch between two line phase.
#
# \param[in] Level: active (H) or remove (L) phase inversion.
proc PhaseInversion { Level } {
    TlPrint "========= set PhaseInversion to Level $Level ========="
    set PLC_Register 1006						;# identify the PLC register to control the right output
    set PLC_Bit 6
    set Result [wc_TCP_ReadWord $PLC_Register 1]			;# read the current state of PLC register
    set Mask [ expr round(pow(2,$PLC_Bit))]				;# create a Mask regarding the selected Bits
    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to activate phase inversion.
	wc_TCP_WriteWord $PLC_Register [expr ($Result+ $Mask)]
	return 1
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {				;# set the appropriate bit to remove phase inversion.
	wc_TCP_WriteWord $PLC_Register [expr ($Result- $Mask)]
	return 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply the lexium 32 device.
#
# ----------HISTORY------------------------------------------------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Switch on or switch off the lexium32 device use as load machine.
#
# \param[in] Level: switch on (H) or switch Off(L).
proc LoadOnOff { Level } {
    TlPrint "========= LoadOnOff $Level ========="
    set PLC_Register 1006						;# identify the PLC register to control the right output
    set PLC_Bit 7
    set Result [wc_TCP_ReadWord $PLC_Register 1]			;# read the current state of PLC register
    set Mask [ expr round(pow(2,$PLC_Bit))]				;# create a Mask regarding the selected Bits
    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on
	wc_TCP_WriteWord $PLC_Register [expr ($Result+ $Mask)]
	return 1
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {				;# set the appropriate bit to switch off
	wc_TCP_WriteWord $PLC_Register [expr ($Result- $Mask)]
	return 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# loop during timeout until the relay as the expected value
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 070524 Yahya	  Updated error message to print correct value of checked relay (see Issue #2012)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one line phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc doWaitForRelay {Relay Level timeout  {noErrPrint 0} {TTId ""}} {
    global ActDev
    set PLC_Register1 1004										;# identify the PLC register to control the right output
    set PLC_Bit1 7
    set PLC_Register2 1005										;# identify the PLC register to control the right output
    set PLC_Bit2 -1
    set PLC_Register3 1005										;# identify the PLC register to control the right output
    set PLC_Bit3 7
    set  OK 0
    switch  $Relay {
	"R1" {set Rx 1 }
	"R2" {set Rx 2 }
	"R3" {set Rx 3 }
	"DQ1" - "DO1" {set Rx 4 }
	"DQ2" - "DO2" {set Rx 5 }
    }
    switch -regexp $Level {
	"[Hh]"  {set Value [expr 0x01]}
	"[Ll]"  {set Value [expr 0x00]}
    }
    set Begining [clock clicks -milliseconds]
    set TTId [Format_TTId $TTId]
    while {1} {
	after 1   											;# wait 1 mS
	update idletasks
	switch -regexp $ActDev {
	    1 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register1 1] >> [expr $PLC_Bit1 + $Rx] ]
	    }
	    2 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register2 1] >> [expr $PLC_Bit2 + $Rx] ]

	    }
	    3 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register3 1] >> [expr $PLC_Bit3 + $Rx] ]

	    }
	}

	if { $Result == "" } then {
	    TlError "illegal RxFrame received"
	    return 0
	}
	if { [expr $Result & 0x01] == ($Value)} {
	    set  OK 1
	    TlPrint "Relay $Relay ok: TargetValue=ActualValue=0x%08X , (%d) , wait time (%dms) " $Value $Value [expr [clock clicks -milliseconds] - $Begining ]
	    break
	}

	if {[expr (([clock clicks -milliseconds] - $Begining) )  > ($timeout * 1000) ] } {

	    if { $noErrPrint } {
		TlPrint "$TTId doWaitForRelay $Relay : TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d) , wait time (%dms)" $Value $Value [expr $Result & 0x01] [expr $Result & 0x01] [expr [clock clicks -milliseconds] - $Begining ]
	    } else {

		if { $Result == "" } {
		    TlError "$TTId doWaitForRelay $Relay : TargetValue=0x%08X , (%d) ActualValue= $Result , wait time (%dms)" $Value $Value [expr [clock clicks -milliseconds] - $Begining ]
		} else {
		    TlError "$TTId doWaitForRelay $Relay : TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d) , wait time (%dms)" $Value $Value [expr $Result & 0x01] [expr $Result & 0x01] [expr [clock clicks -milliseconds] - $Begining ]
		}
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }
    return $OK
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# loop during timeout until the relay as the expected value and return the wait time
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one line phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc doWaitForRelayWaittime {Relay Level timeout {tolerance 0} {TTId ""}} {
    global ActDev
    set PLC_Register1 1004										;# identify the PLC register to control the right output
    set PLC_Bit1 7
    set PLC_Register2 1005										;# identify the PLC register to control the right output
    set PLC_Bit2 -1
    set PLC_Register3 1005										;# identify the PLC register to control the right output
    set PLC_Bit3 7

    switch  $Relay {
	"R1" {set Rx 1 }
	"R2" {set Rx 2 }
	"R3" {set Rx 3 }
	"DQ1" {set Rx 4 }
	"DQ2" {set Rx 5 }
    }
    switch -regexp $Level {
	"[Hh]"  {set Value [expr 0x01]}
	"[Ll]"  {set Value [expr 0x00]}
    }
    set Begining [clock clicks -milliseconds]
    set TTId [Format_TTId $TTId]
    while {1} {
	after 1   											;# wait 1 mS
	update idletasks
	switch -regexp $ActDev {
	    1 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register1 1] >> [expr $PLC_Bit1 + $Rx] ]
	    }
	    2 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register2 1] >> [expr $PLC_Bit2 + $Rx] ]

	    }
	    3 {
		set Result [expr [wc_TCP_ReadWord $PLC_Register3 1] >> [expr $PLC_Bit3 + $Rx] ]

	    }
	}
	set GotResult [clock clicks -milliseconds]

	if { $Result == "" } then {
	    TlError "illegal RxFrame received"
	    break
	}
	if { [expr $Result & 0x01] == ($Value)} {
	    TlPrint "Relay $Relay ok: TargetValue=ActualValue=0x%08X , (%d) , wait time (%dms) " $Value $Value [expr $GotResult - $Begining ]
	    break
	}

	if {[expr (([clock clicks -milliseconds] - $Begining) )  > ($timeout * 1000) ] } {
	    if { $Result == "" } {
		TlError "$TTId doWaitForRelay $Relay : TargetValue=0x%08X , (%d) ActualValue= $Result , wait time (%dms)" $Value $Value [expr [clock clicks -milliseconds] - $Begining ]
	    } else {
		TlError "$TTId doWaitForRelay $Relay : TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d) , wait time (%dms)" $Value $Value $Result  $Result [expr [clock clicks -milliseconds] - $Begining ]
	    }

	    return
	}
	if {[CheckBreak]} {break}
    }
    return [expr $GotResult - $Begining ]

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# compare the relay status to the expected one
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one line phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc checkRelay {Relay Level {TTId ""}} {

    global ActDev

    set PLC_Register1 1004						;# identify the PLC register to control the right output
    set PLC_Bit1 7
    set PLC_Register2 1005						;# identify the PLC register to control the right output
    set PLC_Bit2 -1
    set PLC_Register3 1005						;# identify the PLC register to control the right output
    set PLC_Bit3 7

    switch $Relay {
	"R1" {set Rx 1 }
	"R2" {set Rx 2 }
	"R3" {set Rx 3 }
	"DQ1" {set Rx 4 }
	"DQ2" {set Rx 5 }
    }

    switch -regexp $ActDev {
	1 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register1 1] >> [expr $PLC_Bit1 + $Rx] ]
	}
	2 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register2 1] >> [expr $PLC_Bit2 + $Rx] ]
	}
	3 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register3 1] >> [expr $PLC_Bit3 + $Rx] ]
	}
    }
    switch -regexp $Level {
	"[Hh1]"  {
	    if { [expr $ix & 0x01] } {
		TlPrint "Output/relay $Relay of device $ActDev is High"
	    } else {
		TlError "$TTId Output/relay $Relay of device $ActDev is Low"
		ShowStatus
	    }
	}
	"[Ll0]"  {
	    if { [expr $ix & 0x01] } {
		TlError "$TTId Output/relay $Relay of device $ActDev is High"
		ShowStatus
	    } else {
		TlPrint "Output/relay $Relay of device $ActDev is Low"
	    }
	}
	default {
	    TlError "Check_Relay: wrong parameter: <$Level>"
	    return "X"
	}
    }
    if { [expr $ix & 0x01] } {
	return "H"
    } else {
	return "L"
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one line phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one line phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc PhaseOnOff {Index Level } {
    TlPrint "========= PhaseOnOff $Index $Level ========="
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 -1
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]

    switch -regexp $Level {
	"[Hh]"  {
	    if { $IntVar==0} {wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]}
	}
	"[Ll]"  {
	    if { $IntVar==$Mask} {wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)] }
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Select the appropriate device for main supply.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one line phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc SelectDUT {Index Level } {
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 7

    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch off or on one phase of bypass.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: phase number.
# \param[in] Level: expected state.
proc BypassPhaseOnOff {Index Level } {
    TlPrint "========= BypassPhaseOnOff $Index $Level ========="
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 10
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply all phases for bypass.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
# 120724 Yahya	  Update to open/close all phases whatever is their initial state (see Issue #2462)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off all line phases of the DUT.
#
# \param[in] Level: expected state.
proc BypassPhaseAllOnOff { Level } {
    TlPrint "========= BypassPhaseAllOnOff $Level ========="
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set Value [expr 0x3800]
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    switch -regexp $Level {
	"[Hh]"  {
	    wc_TCP_WriteWord $PLC_Register1 [expr ($Result | $Value)]
	}
	"[Ll]"  {
	    wc_TCP_WriteWord $PLC_Register1 [expr ($Result & ~$Value)]
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply all line phases of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 061222 ASY      added the DevNr parameter
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off all line phases of the DUT.
#
# \param[in] DevNr: select DUT to supply.
# \param[in] Level: expected state.
proc PhaseAllOnOff { DevNr Level } {
    TlPrint "========= set PhaseAllOnOff of DevNr $DevNr to $Level ========="
    global ActDev

    SelectDUT $DevNr $Level
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set Value [expr 0x07]
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set IntVar [expr ($Result & $Value)]
    switch -regexp $Level {
	"[Hh]"  {
	     # write the value currently present in the PLC OR the 3 bits corresponding to the phases ==> set those 3 bits to high without impact on other bits
	     wc_TCP_WriteWord $PLC_Register1 [expr ($Result | $Value)]
	}
	"[Ll]"  {
	     # write the value currently present in the PLC AND all the bits except those corresponding to the phases ==> keep all the bits to their level except the 3 that will be lowered
	     wc_TCP_WriteWord $PLC_Register1 [expr ($Result & [expr 65535 - $Value])]
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc MotorPhaseOnOff {Index Level } {
    TlPrint "========= MotorPhaseOnOff $Index $Level ========="
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 2
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch on all the motor phase.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 200123 ASY      Update of the values to write
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
# \param[in] checkData: check motor parameter consistency (optional).
# \param[in] State: expected drive state after power on (optional).
# \param[in] timeout: max delay for expected state (optional).
# \param[in] TTTId: Bug tracking reference  (optional).
proc MotorPhaseAllOnOff { Level } {
    TlPrint "========= MotorPhaseAllOnOff $Level ========="
    global ActDev
    set PLC_Register1 1006							;# identify the PLC register to control the right output For phase control
    set Value [expr 56]
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set IntVar [expr ($Result & $Value)]
    switch -regexp $Level {
	"[Hh]"  {
	     # write the value currently present in the PLC OR the 3 bits corresponding to the phases ==> set those 3 bits to high without impact on other bits
	     wc_TCP_WriteWord $PLC_Register1 [expr ($Result | $Value)]
	}
	"[Ll]"  {
	     # write the value currently present in the PLC AND all the bits except those corresponding to the phases ==> keep all the bits to their level except the 3 that will be lowered
	     wc_TCP_WriteWord $PLC_Register1 [expr ($Result & [expr 65535 - $Value])]
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch on the DUT (control + line phases + motor Phase).
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 061222 ASY	  update for the support of DevNr
#
#END----------------------------------------------------------------
## Function description : switch on all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
# \param[in] checkData: check motor parameter consistency (optional).
# \param[in] State: expected drive state after power on (optional).
# \param[in] timeout: max delay for expected state (optional).
# \param[in] TTTId: Bug tracking reference  (optional).
proc DeviceOn {DevNr {checkData 1} {State ">=2"} {timeout 30} {TTId ""}} {
    global DevAdr ActDev
    #memorize the current Device address
    set memActDev $ActDev
    #switch actdev to devNr to support the following modbus communication
    set ActDev $DevNr
    CtrlOnOff $DevNr H
    PhaseAllOnOff $DevNr H
    MotorPhaseAllOnOff H

    if {[GetDevFeat "Board_EthAdvanced"] || [GetDevFeat "BusCAN"]} {
	doWaitForObjectLevel EEPS 0 90 5 0xFFFF "" 1
    } else {
	doWaitForRelay R1 H 8 1
	doWaitForState ">=2" 20
    }
    #restore the previous ActDev
    set ActDev $memActDev
    #  doWaitMs 8000
    #  doWaitForObjectLevel EEPS 0 90 5 0xFFFF "" 1
    #if { [GetDevFeat "Board_EthAdvanced"]} { doWaitForPing $DevAdr($ActDev,OptBrdIP) 25000}
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch off the DUT (control + line phases + motor Phase).
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 061222 ASY	  fixed the DevNr handling 
#
#END----------------------------------------------------------------
## Function description : switch off all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
proc DeviceOff {DevNr {NoInfo 0} } {
    CtrlOnOff $DevNr L
    PhaseAllOnOff $DevNr L
    MotorPhaseAllOnOff L
    doWaitForOff 20
    doWaitMs 1000
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set digital inputs of device to Level.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 030124 ASY	  update to handle several DI simultaneously
#
#END----------------------------------------------------------------
## Function description : Set digital inputs of device to Level.
#
# \param[in] Index: Number of the DI to actuate (either a single number or a list of numbers).
# \param[in] Level: Level to set the DI..
proc setDI { index Level } {
    global ActDev

    if {[llength $index] > 4 } {
	    TlError "No more than 4 inputs handled simultaneously"
	    return 0 
    }
    if {[llength $index] > 1 } {
	    foreach curIndex $index {
		    if { $curIndex > 4 } {
			    TlError "this digital input $index is not available"
			    return 0
		    }
	    }
    }

    TlPrint "====================set DI {$index} to Level $Level"
    set PLC_Register1 1007							;# identify the PLC register to control the right output
    set PLC_Bit1 0
    set PLC_Register2 1007							;# identify the PLC register to control the right output
    set PLC_Bit2 8
    set PLC_Register3 1008							;# identify the PLC register to control the right output
    set PLC_Bit3 0

    set PLC_Register [subst $[subst PLC_Register$ActDev]]			;# get the PLC_Register matching the current device
    set PLC_Bit [subst $[subst PLC_Bit$ActDev]]					;# get the offset of the inputs of the given device

    set currentWordValue [wc_TCP_ReadWord $PLC_Register 1]				;# read the current value of the PLC word

    if {[llength $index] > 1 } {
	    set Mask 0
	    foreach curIndex $index {
		    set Mask [expr $Mask + round(pow(2,$curIndex + $PLC_Bit))]	;# calculate the corresponding mask for each input
	    }
    } else {
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit)]))]
    }
    # if Level is to be set to High put all the bits in the value word to high  
    set value [expr [regexp "\[Hh1\]" $Level] * 0xFFFF] 
    #calculate the new value to write
    #new value is equal to : ValueToWrite AND Mask OR CurrentValue AND NOT Mask
    #use XOR with 0xFFFF to get the NOT(MASK)
    set newWordValue [ expr $value & $Mask | [expr $Mask ^ 0xFFFF] & $currentWordValue]
    wc_TCP_WriteWord $PLC_Register $newWordValue
    return 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set digital inputs of device to Level.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 251122 ASY	  updated the proc to get it to work. STO channel input removed.
#
#END----------------------------------------------------------------
## Function description : Set digital inputs of device to Level.
#
# \param[in] Level: expected state.
proc setSTO { Level } {
    global ActDev
    TlPrint "========= set STO to Level $Level ========="
    set index 1 								;# only 1 STO input for ATS490
    set PLC_Register1 1007							;# identify the PLC register to control the right output
    set PLC_Bit1 4
    set PLC_Register2 1007							;# identify the PLC register to control the right output
    set PLC_Bit2 12
    set PLC_Register3 1008							;# identify the PLC register to control the right output
    set PLC_Bit3 4
    switch -regexp $ActDev {
	1 {
	    set Result [wc_TCP_ReadWord $PLC_Register1 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit1)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
	    }
	}
	2 {
	    set Result [wc_TCP_ReadWord $PLC_Register2 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit2)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result- $Mask)]
	    }
	}
	3 {
	    set Result [wc_TCP_ReadWord $PLC_Register3 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit3)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result- $Mask)]
	    }
	}
    }
    return 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set the Mode used with ATLAS Analog Inputs (voltage, current, PT100, PTC)
# 
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 270123 ASY      proc created
#
#END----------------------------------------------------------------
## Function description : Set the connection mode used for ATLAS analog inputs 
# \param[in] Mode: Desired connection mode.
#
 
proc setAIMode { Mode } {

	switch -nocase $Mode {
	
		"Voltage" {
		    selectAI1CurrentMode L
		    selectAI1VoltageMode H
		    selectAI1PT100Mode L
		    selectAI1PTCMode L
		}
		"Current" {
		    selectAI1CurrentMode H
		    selectAI1VoltageMode L
		    selectAI1PT100Mode L
		    selectAI1PTCMode L
		}
	
		"PT100" {
		    selectAI1CurrentMode L
		    selectAI1VoltageMode L
		    selectAI1PT100Mode H
		    selectAI1PTCMode L
		}
		"PTC" {
		    selectAI1CurrentMode L
		    selectAI1VoltageMode L
		    selectAI1PT100Mode L
		    selectAI1PTCMode H
		}
		"none" {
		    selectAI1CurrentMode L
		    selectAI1VoltageMode L
		    selectAI1PT100Mode L
		    selectAI1PTCMode L
		}
		default {
			TlError "setAIMode : mode $Mode not available"
			return -1
		}
	}	
	TlPrint "Switch analog input mode to : $Mode"
	return 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Supply the product with 24Vdc
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 251122 ASY	  proc created
# 
#END----------------------------------------------------------------
## Function description : Set digital inputs of device to Level.
#
# \param[in] Level: expected state.
proc setP24Supply {Level} {
    global ActDev
    TlPrint "========= set 24Vdc supply to Level $Level ========="
    set index 1 								
    set PLC_Register1 1007							;# identify the PLC register to control the right output
    set PLC_Bit1 5
    set PLC_Register2 1007							;# identify the PLC register to control the right output
    set PLC_Bit2 13
    set PLC_Register3 1008							;# identify the PLC register to control the right output
    set PLC_Bit3 5
    switch -regexp $ActDev {
	1 {
	    set Result [wc_TCP_ReadWord $PLC_Register1 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit1)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
	    }
	}
	2 {
	    set Result [wc_TCP_ReadWord $PLC_Register2 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit2)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register2 [expr ($Result- $Mask)]
	    }
	}
	3 {
	    set Result [wc_TCP_ReadWord $PLC_Register3 1]
	    set Mask [ expr round(pow(2,[ expr ($index + $PLC_Bit3)]))]

	    set IntVar [expr ($Result & $Mask)]
	    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result+ $Mask)]
	    }
	    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
		wc_TCP_WriteWord $PLC_Register3 [expr ($Result- $Mask)]
	    }
	}
    }
    return 1
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set digital inputs of device to Level.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 270123 ASY      Update of the proc with setAIMode and made the Mode parameter optional with default value Voltage
# 100323 ASY	  reorder call to the functions
#
#END----------------------------------------------------------------
## Function description : Set digital inputs of device to Level.
#
# \param[in] Index: AI number.
# \param[in] Value: expected value.
proc setAI { TargetValue {Mode "Voltage"} } {
    #Set the analog inputs mode to the desired Mode
    if {[setAIMode $Mode] == 1 } { ;# if the setting to the mode succeeded then write the value to the analog output of the PLC
	    switch -nocase $Mode {
		"Voltage" {
		    set PLC_Register1 1111
		    wc_TCP_WriteWord $PLC_Register1 $TargetValue
 	 	    TlPrint "setAI to $TargetValue mV" 
		}
		"Current" {
		    set PLC_Register1 1112
		    wc_TCP_WriteWord $PLC_Register1 $TargetValue
		    TlPrint "setAI to $TargetValue ([expr $TargetValue / 10000.0 * 20.0] mA)" 
		}
		default {
			TlError "setAI : mode $Mode not available"
			return -1
		}
	    }
    } else { ;# if the setting to mode didn't succeed then do not throw another error. Function setAIMode already raised one.
	    return -1

    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
## FUNCTION NOT TO BE USED IN SCRIPT 
# Switch the connection to the analog input of the DUT to the PLC's current output
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Switch the connection to the analog input of the DUT to the PLC's current output
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc selectAI1CurrentMode {Level } {
    TlPrint "========= selectAI1CurrentMode $Level ========="
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 11
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
## FUNCTION NOT TO BE USED IN SCRIPT 
# Switch the connection to the analog input of the DUT to the PLC's voltage output
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Switch the connection to the analog input of the DUT to the PLC's voltage output
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc selectAI1VoltageMode {Level } {
    TlPrint "========= selectAI1VoltageMode $Level ========="
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 12
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
## FUNCTION NOT TO BE USED IN SCRIPT 
# Switch the connection to the analog input of the DUT to the PT100 sensor
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Switch the connection to the analog input of the DUT to the PT100 sensor
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc selectAI1PT100Mode {Level } {
    TlPrint "========= selectAI1PT100Mode $Level ========="
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 13
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
	doWaitMs 1000
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
## FUNCTION NOT TO BE USED IN SCRIPT 
# Switch the connection to the analog input of the DUT to the PTC sensor
# 
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : # Switch the connection to the analog input of the DUT to the PTC sensor
##
# \param[in] Level: expected state.
proc selectAI1PTCMode {Level } {
    TlPrint "========= selectAI1PTCMode $Level ========="
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 14
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
	doWaitMs 1000
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc ActiveThermResistor {Level } {
    TlPrint "====================ActiveThermResistor $Level"
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 10
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc setOCThermResistor {Level } {
    TlPrint "====================setOCThermResistor $Level"
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 9
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc setCCThermResistor {Level } {
    TlPrint "====================setCCThermResistor $Level"
    global ActDev
    set PLC_Register1 1008							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 8
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc selectAQ1CurrentMode {Level } {
    TlPrint "========= selectAQ1CurrentMode $Level ========="
    global ActDev
    set PLC_Register1 1009							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 0
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Drive the FAN to speed up the cool down
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 190922 ASY      proc created
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Drive the FAN to speed up the cooldown
#
# \param[in] Level: expected state.
proc setFAN {Level } {
    TlPrint "========= setFAN $Level ========="
    global ActDev
    set PLC_Register1 1009							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 1
    set Index 3
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Toggles the active modbus port. Either bottom or HMI/Open Style
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 030523 ASY    proc created
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : Toggles the active modbus port. Either bottom or HMI/Open Style
#
# \param[in] Level: expected state.
proc toggleModbusPort {Level } {
    TlPrint "========= toggleModbusPort $Level ========="
    global ActDev
    set PLC_Register1 1009							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 1
    set Index 6
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply one motor phase of the DUT.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 020724 Yahya	  Added print message for logs (see Issue #2415)
#
#END----------------------------------------------------------------
## Function description : switch on or switch off one motor phase of the DUT.
#
# \param[in] Index: line phase number.
# \param[in] Level: expected state.
proc selectAQ1VoltageMode {Level } {
    TlPrint "========= selectAQ1VoltageMode $Level ========="
    global ActDev
    set PLC_Register1 1009							;# identify the PLC register to control the right output For phase control
    set PLC_Bit1 1
    set Index 0
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    set Mask [ expr round(pow(2,[ expr $PLC_Bit1 + $Index]))]

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result+ $Mask)]
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {
	wc_TCP_WriteWord $PLC_Register1 [expr ($Result- $Mask)]
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch off the DUT (control + line phases + motor Phase).
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
# 260123 ASY      update of the tolerance handling mechanism
#
#END----------------------------------------------------------------
## Function description : switch off all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
proc checkAQTol {Index TargetValue {Tolerance 0} {Mode "Voltage"} } {
    switch -nocase $Mode {
	"Voltage" {
	    selectAQ1VoltageMode H
	    selectAQ1CurrentMode L
	    set PLC_Register1 1101
	}
	"Current" {
	    selectAQ1VoltageMode L
	    selectAQ1CurrentMode H
	    set PLC_Register1 1102
	}
	default { 
		TlPrint "Mode ($Mode) not supported "
		return 0xFFFF
	}
    }
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    #Handling the negative values that are sent as 0xFFFF - value
    if {$Result > 0x7FFF} {
	set Result [expr (0xFFFF - $Result) * - 1]
    }
    if {[ expr abs( $Result - $TargetValue)] <= $Tolerance} {
	TlPrint "AQ$Index ok: TargetValue= $TargetValue,  ActualValue=[format %04s $Result] , Tolerance=$Tolerance " 
	return $Result
    } else {
	TlError "AQ$Index : TargetValue=0x%04X , (%d) ActualValue=0x%04X , (%d), Tolerance=0x%04X , (%d)" $TargetValue $TargetValue $Result  $Result $Tolerance $Tolerance
	return 0xFFFF
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch off the DUT (control + line phases + motor Phase).
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch off all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
proc doWaitForAQTol {Index TargetValue timeout {Tolerance 0} {Mode "Voltage"} } {
    switch $Mode {
	"Voltage" {
	    selectAQ1VoltageMode H
	    selectAQ1CurrentMode L
	    set PLC_Register1 1101
	}
	"Current" {
	    selectAQ1VoltageMode L
	    selectAQ1CurrentMode H
	    set PLC_Register1 1102
	}
    }
    set Begining [clock clicks -milliseconds]
    while {1} {
	after 1   ;# wait 1 mS
	update idletasks
	set Result [wc_TCP_ReadWord $PLC_Register1 1]
	if { $Result == "" } then {
	    TlError "illegal RxFrame received"
	    return 0
	}
	if {[ expr abs( $Result - $TargetValue)] <= $Tolerance} {
	    TlPrint "AQ$Index ok: TargetValue=ActualValue=0x%08X , (%d) , wait time (%dms) " $TargetValue $TargetValue [expr [clock clicks -milliseconds] - $Begining ]
	    break
	}
	if {[expr (([clock clicks -milliseconds] - $Begining) )  > ($timeout * 1000) ] } {
	    if { $Result == "" } {
		TlError "doWaitForAQTol AQ1: TargetValue=0x%08X , (%d) ActualValue= $Result , wait time (%dms)" $TargetValue $TargetValue [expr [clock clicks -milliseconds] - $Begining ]
	    } else {
		TlError "doWaitForAQTol AQ1: TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d) , wait time (%dms)" $TargetValue $TargetValue $Result  $Result [expr [clock clicks -milliseconds] - $Begining ]
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }
    return $Result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# switch off the DUT (control + line phases + motor Phase).
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : switch off all line phases, motor phases and control block power supply of the DUT.
#
# \param[in] DevNr: device reference.
proc checkTemperatureTol {TargetValue {Tolerance 0} } {
    set PLC_Register1 1103
    set Result [wc_TCP_ReadWord $PLC_Register1 1]
    if {[ expr abs( $Result - $TargetValue)] <= $Tolerance} {
	TlPrint "Temperature ok: TargetValue=ActualValue=0x%08X , (%d) " $TargetValue $TargetValue
	return $Result
    } else {
	TlError "Temperature : TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d)" $TargetValue $TargetValue $Result  $Result
	return 0
    }
}

proc getTemperature { } {
    set PLC_Register1 1103
    set Result [wc_TCP_ReadWord $PLC_Register1 1]

    return $Result

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply the lexium 32 device.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : the PLC switch on  or switch off the 230V AC power supply of control block regarding the selected Level.
#
# \param[in] Level: expected state of the control block.
proc ProfinetNetworkDisconnection { Level } {
    set PLC_Register 1009						;# identify the PLC register to control the right output
    set PLC_Bit 3

    set Result [wc_TCP_ReadWord $PLC_Register 1]			;# read the current state of PLC register
    set Mask [ expr round(pow(2,$PLC_Bit))]				;# create a Mask regarding the selected Bits

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on the Control block
	wc_TCP_WriteWord $PLC_Register [expr ($Result+ $Mask)]
	return 1
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {				;# set the appropriate bit to switch off the Control block
	wc_TCP_WriteWord $PLC_Register [expr ($Result- $Mask)]
	return 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Supply the lexium 32 device.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 011220 cordc    review PLC register
#
#END----------------------------------------------------------------
## Function description : the PLC switch on  or switch off the 230V AC power supply of control block regarding the selected Level.
#
# \param[in] Level: expected state of the control block.
proc EthernetNetworkDisconnection { Level } {
    set PLC_Register 1009							;# identify the PLC register to control the right output
    set PLC_Bit 2

    set Result [wc_TCP_ReadWord $PLC_Register 1]			;# read the current state of PLC register
    set Mask [ expr round(pow(2,$PLC_Bit))]				;# create a Mask regarding the selected Bits

    set IntVar [expr ($Result & $Mask)]
    if {[regexp "\[Hh1\]" $Level] && $IntVar==0} {					;# set the appropriate bit to switch on the Control block
	TlPrint "Disconnect Ethernet network"
	wc_TCP_WriteWord $PLC_Register [expr ($Result+ $Mask)]
	return 1
    }
    if {[regexp "\[Ll0\]" $Level] && $IntVar==$Mask } {				;# set the appropriate bit to switch off the Control block
	TlPrint "Connect Ethernet network"
	wc_TCP_WriteWord $PLC_Register [expr ($Result- $Mask)]
	return 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# create table of parameters from *.sim file.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ReadParaFile_ATS { FileName } {

    global theATVParaNameTable theATVParaIndexTable theATVenumListTable theATVenumValueTable theATVenumNameTable

    #Package to use Excel
    package require tcom

    set i 0
    # Set the path to your excel file.
    set excelFilePath "$FileName"

    #create a link to excel application
    set excelApp [::tcom::ref createobject Excel.Application]
    set workbooks [$excelApp Workbooks]

    # open the Interface HW SW workbooks
    set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
    set worksheets [$workbook Worksheets]
    set worksheet [$worksheets Item [expr 1]]

    #Check the name of selected worksheet
    if { [$worksheet Name]=="Feuil1" } {

	set cells [$worksheet Cells]
	set loopCpt 0
	set Column_list {2}

	foreach Column $Column_list {

	    # Read all the values in column CX
	    set rowCount 1

	    set columnCount $Column
	    set end 0
	    while { $end == 0 } {

		set celluleValue [ string toupper [[$cells Item $rowCount [ expr $columnCount]] Value]]
		if { $celluleValue == ""} {
		    set end 1
		    continue
		}
		set nameParam  $celluleValue
		set adrParam [ expr round([[$cells Item $rowCount [expr $columnCount+6]] Value])]
		set theATVParaNameTable($nameParam) $adrParam
		set theATVParaIndexTable($adrParam) $nameParam
		#TlPrint " $nameParam | $adrParam "

		incr rowCount
		incr i
	    }
	    incr loopCpt
	}
    }
    $workbook Save
    $workbook Close
    $excelApp Quit
};#ExportMVKRef

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVGetObject {Object} {
    global DevAdr ActDev
    set MBAdr $DevAdr($ActDev,MOD)
    set TxFrame [format "%02X33040808000000040001%06X"             $MBAdr $Object]
    #TlPrint "TX: $TxFrame"
    set RxFrame [mbDirect $TxFrame 1]

    #TlPrint "RX: $RxFrame"
    set HexaLength "0x[string range $RxFrame 28 29]"
    set  actualLength [expr $HexaLength]
    set HexaValue "[string range $RxFrame 30 [expr (30+2*$actualLength)] ]"
    return "$HexaValue"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the status of all leds
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVGetLEDstatus { } {

    set LEDstatus [ATVGetObject 0x402]

    set HexaLed "0x[string range $LEDstatus 0 1]"
    set  QuantityLed [expr $HexaLed]
    set lStatus {}
    set lColor {}
    #TlPrint "$QuantityLed"
    for {set a 0} {$a < $QuantityLed} {incr a} {
	TlPrint "LED ID : 0x[string range $LEDstatus [ expr 1+((6*$a)+1)] [ expr 2+((6*$a)+1)]] COLOR ID : 0x[string range $LEDstatus [ expr 3+((6*$a)+1)] [ expr 4+((6*$a)+1)]] STATUS : 0x[string range $LEDstatus [ expr 5+((6*$a)+1)] [ expr 6+((6*$a)+1)]] "
	lappend lStatus [string range $LEDstatus [ expr 5+((6*$a)+1)] [ expr 6+((6*$a)+1)]]
	lappend lColor [string range $LEDstatus [ expr 3+((6*$a)+1)] [ expr 4+((6*$a)+1)]]
    }
    lappend lreturn $lStatus
    lappend lreturn $lColor
    return $lreturn
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the statu of warning led
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 240221 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATVGetLEDWarningstatus { ID  } {

    set LEDstatus [ATVGetObject 0x402]

    set HexaLed "0x[string range $LEDstatus 0 1]"
    set  QuantityLed [expr $HexaLed]
    #TlPrint "$QuantityLed"
    #coclor : 3 red, 1 green    status :02 flashing 01 fix
    set a 1
    TlPrint "LED ID : 0x[string range $LEDstatus [ expr 1+((6*$a)+1)] [ expr 2+((6*$a)+1)]] COLOR ID : 0x[string range $LEDstatus [ expr 3+((6*$a)+1)] [ expr 4+((6*$a)+1)]] STATUS : 0x[string range $LEDstatus [ expr 5+((6*$a)+1)] [ expr 6+((6*$a)+1)]] "
    switch $ID {

	"color" {
	    set result 0x[string range $LEDstatus [ expr 3+((6*$a)+1)] [ expr 4+((6*$a)+1)]]
	}

	"status" {
	    set result  0x[string range $LEDstatus [ expr 5+((6*$a)+1)] [ expr 6+((6*$a)+1)]]
	}
	default {
	    TlError "no $ID"
	}
    }
    return $result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doStoreEEPROM { {keypadchannel 0} } {

	TlPrint "--------------------------------------------------------"
	TlPrint "doStoreEEPROM {} - Save configuration data to EEPROM"
	doWaitForEEPROMFinished 10 0 "" $keypadchannel;# mintime 1 sec still valid for CMI=2, even in CS05

	ModTlWrite CMI 2           ;# Bit1 = 1 : Memorize current configuration in EEPROM

	doWaitForEEPROMStarted 1 0 $keypadchannel
	doWaitForEEPROMFinished 50 1 "" $keypadchannel;# mintime 1 sec still valid for CMI=2, even in CS05

	TlPrint "-end----------------------------------------------------"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
# 251122 ASY	  Added the writting of IP Parameters for ATS490
# 160623 Yahya	  Cleaned up the proc from unnecessary operations
# 310124 Yahya	  Added setting of STO input to 24V for ATS490 (see Issue #1642)
# 260424 Yahya	  Added FAN deactivation and Bypass opening (see Issue #2039)
#
#
#END----------------------------------------------------------------
proc doSetDefaults { {reboot 1} {state 0} {FullInit 0} } {
    global ActDev DevAdr DevAdr_Orig DevID
    global theSerialBaud ActInterface

    if { $reboot } {
	TlPrint "Reset factory settings, with reboot, final state=$state"
    } else {
	TlPrint "Reset factory settings, no reboot, final state=$state"
    }

    set FBInterface $ActInterface

    # use Tl commands with MOD
    doSetCmdInterface "MOD"
	
    #Switch to Modbus port 1 (fieldbus port)
    toggleModbusPort L
	
    #Deactivate 24V supply
    setP24Supply L

    #Deactivate the heating bloc's FAN
    setFAN L
	
    #Open the bypass contactor on the tower
    BypassPhaseAllOnOff L
	
    if {[GetDevFeat "OPTIM"]} {
	setSTO H
    }
	
    DeviceOn $ActDev

    set ActAdr $DevAdr_Orig($ActDev,MOD)
    TlPrint "Change modbus address of device $ActDev from $ActAdr to broadcast 0xF8"
    set DevAdr($ActDev,MOD) 0xF8        ;#will be restored in below

    # print out error memory before factory reset, otherwise information may be lost
    doDisplayErrorMemory

    # reset inputs of actual device
    doResetDeviceInputs $ActDev

    # do razi=512 or factory setting
    if {$FullInit} {
	TlWrite MODE .TP
	TlWrite RAZI 512
	doRP ;#Restart the softstarter
    }
    doFactorySetting
    doStoreEEPROM

    if {[GetDevFeat "Board_EthAdvanced"]} {
	doWaitForObjectStable EEPS 0 30 5000
    }

    if { $reboot } {
	DeviceOff $ActDev 1
	DeviceOn $ActDev
    }

    TlPrint "Check if the drive is in root mode. If yes go back to operational mode"
    exitRootMode

    # Write original communication's and motor parameter in device and store in EEPROM
    WriteAdr $ActAdr MOD
	
    #Write product application number
    writeAppName $DevID($ActDev,ModelName)

    #Write the IP parameters if the device is an ATS490
    if { [GetDevFeat "OPTIM"] } {
	writeIpBas $DevAdr($ActDev,DefaultIPAddr_emb) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1
    }
    doStoreEEPROM
    doRP ;#Restart the softstarter
    set DevAdr($ActDev,MOD) $ActAdr
    TlPrint "Actual internal Modbus address: $DevAdr($ActDev,MOD)"

    #Check if an ethernet option card is present :
    if {[GetDevFeat "Board_EthAdvanced"]} {
	doWaitForObjectStable EEPS 0 30 5000
	setIPParameters
    }

    if {[GetDevFeat "Board_EthAdvanced"] || [GetDevFeat "BusCAN"]} {
	#TODO : Workaround in order to Write CHCF to Std if an Option board is present
	if {[TlRead O1CT] != 0} {TlWrite CHCF .STD}
	# Return in previous interface
	doSetCmdInterface $FBInterface
    }
	
}  ;# doSetDefaults

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doReset { {Status 2} } {

    global ActDev DevAdr
    global glb_AccessExcl

    TlPrint "--------------------------------------------------------"
    TlPrint "doReset {} - Reset Device"

    TlWrite RP 1
    doWaitMs 10000                           ;#Wait that drive is off
    doWaitForState $Status 10                     ;#Wait for ready state

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ShowStatus { {broadcast 0} } {
    global DevAdr ActDev glb_Error
    global ShowStatusOnline
    global ShowStatusCounter
    global ShowStatusTime INFM_COUNTER

    if {$ShowStatusOnline} {
	TlError "******************recursion error in ShowStatus***************************"

	set ShowStatusOnline 0
	return 0
	#if {[bp "Debugger at ShowStatus"]} {
	#   return 0
	#}
    } else {
	set ShowStatusOnline 1
    }

    #-----------------------------------------------------------------------------
    # this section is used to limit the ammount of ShowStatus displays
    # ShowStatus will not be shown, if it was already displayed more than twice in the last 10 seconds

    if {![info exists ShowStatusCounter]} {
	set ShowStatusCounter 0
    }
    if {![info exists ShowStatusTime]} {
	set ShowStatusTime 0
    }

    if {(([clock clicks -milliseconds] - $ShowStatusTime) < 8000) && ( $ShowStatusCounter > 2)} {
	TlPrint ""
	TlPrint "+++ ShowStatus +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	TlPrint "ShowStatus is not executed because of too many calls during this procedure"
	TlPrint "ShowStatusCounter: $ShowStatusCounter"
	TlPrint "ShowStatusTime: [expr [clock clicks -milliseconds] - $ShowStatusTime]ms"
	TlPrint "+++ End of ShowStatus ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	TlPrint ""
	set ShowStatusOnline 0
	return
    }

    incr ShowStatusCounter
    set ShowStatusTime [clock clicks -milliseconds]

    #-----------------------------------------------------------------------------

    if { $broadcast } {
	set OrigAdr $DevAdr($ActDev,MOD)
	TlPrint "Change Modbus address to Broadcast 0xF8"
	set DevAdr($ActDev,MOD) 0xF8
    }

    TlPrint "=== ShowStatus ================================"
    #if {$glb_Error} {
    #   return
    #}
    #Only cancel if HERE the first ModTlRead turns out, not before!
    set glb_Error 0
    set eta [ModTlRead ETA 1]
    if {$glb_Error || $eta == ""} { return }

    #fault info
    #doPrintFaultInfo
    if {[CheckBreak]} {return}

    doPrintStatus
    if {[CheckBreak]} {return}

    #doPrintModules
    if {[CheckBreak]} {return}

    doPrintComPara
    if {[CheckBreak]} {return}

    doPrintIO
    if {[CheckBreak]} {return}

    doDisplayErrorMemory

    if { $broadcast } {
	TlPrint "Change modbus address back to $OrigAdr"
	set DevAdr($ActDev,MOD) $OrigAdr
    }
    TlPrint "===End of ShowStatus========================="

    set ShowStatusOnline 0
};#ShowStatus

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Display of info drive state, reference and command channels
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doPrintStatus { } {
    TlPrint "----------- Status --------------------"
    set ptst [Enum_Name PTST [ModTlRead PTST 1] ]
    set chcf [Enum_Name CHCF [ModTlRead CHCF 1] ]
    set cd1  [Enum_Name CD1  [ModTlRead CD1  1] ]
    #set tcc  [Enum_Name TCC  [ModTlRead TCC  1] ]
    TlPrint " PTST (Product state).................. %s" $ptst
    TlPrint " CHCF  CD1.................. %s  %s" $chcf  $cd1

    set CMDLFRlist [ModTlReadBlock CMD1 19 1] ;#CMD1->5, LFR1->5
    TlPrint " CMD1 CMD2 CMD3 CMD5 CMDA.......... 0x{%04X %04X %04X %04X %04X }" \
	[lindex $CMDLFRlist 0] [lindex $CMDLFRlist 1] [lindex $CMDLFRlist 2] [lindex $CMDLFRlist 4] [lindex $CMDLFRlist 8]
    TlPrint " LFR1 LFR2 LFR3 LFR5 LFRA..........    %4d %4d %4d %4d %4d" \
	[lindex $CMDLFRlist 10] [lindex $CMDLFRlist 11] [lindex $CMDLFRlist 12] [lindex $CMDLFRlist 14] [lindex $CMDLFRlist 18]
    #    set SFlist [ModTlReadBlock SF00 8 1] ;#SF00 -> SF07
    #    TlPrint " SF00 SF02 SF03 SF04 SF07.......... 0x{%04X %04X %04X %04X %04X }" \
    #	[lindex $SFlist 0] [lindex $SFlist 2] [lindex $SFlist 3] [lindex $SFlist 4] [lindex $SFlist 7]
    #    TlPrint " SAF1 .............................    %4d" [ModTlRead SAF1 1]

    set hmis [ModTlRead HMIS 1]
    TlPrint " Drive state..(HMIS)............... %d (%s)" $hmis [Enum_Name HMIS $hmis]
    set eta [ModTlRead ETA 1]
    TlPrint " Status word..(ETA)................ 0x%04X (%s)" $eta [getETAStateName $eta]
    set lft [ModTlRead LFT 1]
    TlPrint " Last Fault..(LFT)................. 0x%04X (%s)" $lft [Enum_Name LFT $lft]
    if { [GetDevFeat "OPTIM"] } {
	TlPrint " Safety fault register 1..(SAF1)................ 0x%04X" [ModTlRead SAF1 1]
	TlPrint " Safety fault subregister 0..(SF00)................ 0x%04X" [ModTlRead SF00 1]
	TlPrint " Safety fault subregister 2..(SF02)................ 0x%04X" [ModTlRead SF02 1]
	TlPrint " Safety fault subregister 3..(SF03)................ 0x%04X" [ModTlRead SF03 1]
	TlPrint " Safety fault subregister 4..(SF04)................ 0x%04X" [ModTlRead SF04 1]
	TlPrint " Safety fault subregister 7..(SF07)................ 0x%04X" [ModTlRead SF07 1]
	TlPrint " Safety fault subregister 31..(SF31)................ 0x%04X" [ModTlRead SF31 1]
	TlPrint " Safety fault subregister 32..(SF32)................ 0x%04X" [ModTlRead SF32 1]
	TlPrint " Safety fault subregister 34..(SF34)................ 0x%04X" [ModTlRead SF34 1]
    }
    set ocr [ModTlRead OCR 1]
    set lcr [ModTlRead LCR 1]
    set ltr [ModTlRead S_LTR 1]
    TlPrint " RMS Motor current as % of nominal current..(OCR)............... $ocr"
    TlPrint " RMS Motor current..(LCR)............... $lcr"
    TlPrint " Motor torque..(LTR)............... $ltr"
    #set wert [ModTlRead ERRD 1]
    #TlPrint " CiA402 fault code..(ERRD)......... 0x%04X"  $wert
    # set crc [ModTlRead CRC 1]
    #TlPrint " Active reference channel..(CRC)... 0x%04X (%s)" $crc [GetCDFRchannel $crc]
    set ccc [ModTlRead CCC 1]
    TlPrint " Active command channel..(CCC)..... 0x%04X (%s)" $ccc [GetCDFRchannel $ccc]
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Display of info from modules and option boards
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doPrintModules { } {
    global glb_Error

    if { [GetDevFeat "Card_EthBasic"]  || [GetDevFeat "Card_AdvEmbedded"]} {
	set c6ct [ModTlRead "C6CT"]
	TlPrint "----------- Card_EthBasic (CT=$c6ct)-----------"
	#also print versions, to check if module is correctly identified
	set c6sv [ModTlRead "C6SV"]
	if {$glb_Error || $c6sv == ""} { return }
	set c6sb [ModTlRead "C6SB"]
	if {$glb_Error || $c6sb == ""} { return }
	TlPrint " Card 6 Version (C6SV) Build (C6SB) 0x%04X 0x%04X" $c6sv $c6sb
	set ethf [ModTlRead "ETHF"]
	TlPrint " Fault   (ETHF)..... %d" $ethf
	set EthBasList [ModTlReadBlock IM00 13 1] ;#IM00,IC01->4,IM01->4,IG01->4
	set im00 [lindex $EthBasList 0]
	TlPrint " Mode    (IM00)..... %d (%s)" $im00 [Enum_Name IM00 $im00]
	TlPrint " Adr     (IC0x)..... %d.%d.%d.%d" [lindex $EthBasList 1] [lindex $EthBasList 2 ]  [lindex $EthBasList 3 ]  [lindex $EthBasList 4 ]
	TlPrint " Gate    (IG0x)..... %d.%d.%d.%d" [lindex $EthBasList 9] [lindex $EthBasList 10]  [lindex $EthBasList 11]  [lindex $EthBasList 12]
	TlPrint " Mask    (IM0x)..... %d.%d.%d.%d" [lindex $EthBasList 5] [lindex $EthBasList 6 ]  [lindex $EthBasList 7 ]  [lindex $EthBasList 8 ]
    }

    #Info about option board 1
    set o1ct [ModTlRead "O1CT"]
    if { $o1ct != 0 } {
	TlPrint "----------- Option board 1 (CT=%s) ------------" [Enum_Name O1CT $o1ct]
	#also print versions, to check if module is correctly identified
	set o1sv [ModTlRead "O1SV"]
	if {$glb_Error || $o1sv == ""} { return }
	set o1sb [ModTlRead "O1SB"]
	if {$glb_Error || $o1sb == ""} { return }
	TlPrint " Version (O1SV) Build (O1SB) 0x%04X 0x%04X" $o1sv $o1sb
	set ilf1 [ModTlRead "ILF1"]
	TlPrint " Fault   (ILF1)..... %d" $ilf1
	switch $o1ct {
	    15 {     ;# Profibus
		TlPrint " Adr     (ADRC)..... %d"      [ModTlRead ADRC]
		TlPrint " Baud    (BDR)...... %d (%s)" [ModTlRead BDR]  [Enum_Name BDR  [ModTlRead BDR]]
	    }
	    17 {     ;# CAN
		TlPrint " Adr     (ADCO)..... %d"      [ModTlRead ADCO]
		TlPrint " Baud    (BDCO)..... %d (%s)" [ModTlRead BDCO] [Enum_Name BDCO [ModTlRead BDCO]]
	    }
	    18 {     ;# DeviceNet
		TlPrint " Adr     (ADRC)..... %d"      [ModTlRead ADRC]
		TlPrint " Baud    (BDR)...... %d (%s)" [ModTlRead BDR]  [Enum_Name BDR  [ModTlRead BDR]]
		TlPrint " Assembl (CIOA)..... %d (%s)" [ModTlRead CIOA] [Enum_Name CIOA [ModTlRead CIOA]]
	    }
	    35 -
	    37 {
		;# ECAT PN
		set ECATPNlist [ModTlReadBlock IPM 14 1] ;#IPM,IPA1->4,IPS1->4,IPT1->4
		set ipm  [lindex $ECATPNlist 0]
		TlPrint " Mode    (IPM)...... %d (%s)" $ipm [Enum_Name IPM $ipm]
		# parameter removed in CS7 B25
		TlPrint " Adr     (IPAx)..... %d.%d.%d.%d" [lindex $ECATPNlist 2 ] [lindex $ECATPNlist 3 ] [lindex $ECATPNlist 4 ] [lindex $ECATPNlist 5 ]
		TlPrint " Gate    (IPTx)..... %d.%d.%d.%d" [lindex $ECATPNlist 10] [lindex $ECATPNlist 11] [lindex $ECATPNlist 12] [lindex $ECATPNlist 13]
		TlPrint " Mask    (IPSx)..... %d.%d.%d.%d" [lindex $ECATPNlist 6 ] [lindex $ECATPNlist 7 ] [lindex $ECATPNlist 8 ] [lindex $ECATPNlist 9 ]
	    }
	    135 {
		;# EIP
		set EIPlist [ModTlReadBlock IM10 13 1]
		set ipm  [lindex $EIPlist 0]
		TlPrint " Mode    (IM10)..... %d (%s)" $ipm [Enum_Name IM10 $ipm]
		TlPrint " Adr     (IC1x)..... %d.%d.%d.%d" [lindex $EIPlist 1] [lindex $EIPlist 2 ] [lindex $EIPlist 3 ] [lindex $EIPlist 4 ]
		TlPrint " Gate    (IG1x)..... %d.%d.%d.%d" [lindex $EIPlist 9] [lindex $EIPlist 10] [lindex $EIPlist 11] [lindex $EIPlist 12]
		TlPrint " Mask    (IM1x)..... %d.%d.%d.%d" [lindex $EIPlist 5] [lindex $EIPlist 6 ] [lindex $EIPlist 7 ] [lindex $EIPlist 8 ]
	    }
	}
    }
};#doPrintModules

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Display of In- Outputs DINGET and DOUTGET
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doPrintIO { } {
    TlPrint "----------- IO Status -----------------"
    set IOlist [ModTlReadBlock IL1I 12 1] ;#IL1I,IL1R,OL1I,OL1R

    TlPrint " LO physical/real: %04X %04X" [lindex $IOlist 10] [lindex $IOlist 11]
    TlPrint " LI physical/real: %04X %04X" [lindex $IOlist 0 ] [lindex $IOlist 1 ]

    set AIOlist [ModTlReadBlock AI1I 25 1] ;#AIxI,AIxR,AIxC x= 1 to 5

    TlPrint " AI1 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 0] [lindex $AIOlist 10] [lindex $AIOlist 20]
    #   TlPrint " AI2 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 1] [lindex $AIOlist 11] [lindex $AIOlist 21]
    #   TlPrint " AI3 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 2] [lindex $AIOlist 12] [lindex $AIOlist 22]
    #   TlPrint " AI4 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 3] [lindex $AIOlist 13] [lindex $AIOlist 23]
    #   TlPrint " AI5 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 4] [lindex $AIOlist 14] [lindex $AIOlist 24]

};#doPrintIO

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doPrintComPara { } {
    TlPrint "----------- Com Parameters ------------"
    set ModComList [ModTlReadBlock ADD 6 1] ;#ADD,TBR,TFO,TTO,TWO

    set add                [lindex $ModComList 0]
    set tbr [Enum_Name TBR [lindex $ModComList 2]]
    set tfo [Enum_Name TFO [lindex $ModComList 3]]
    set tto [expr          [lindex $ModComList 4]/ 10.0]
    set two [Enum_Name TWO [lindex $ModComList 5]]
    TlPrint " Modbus: ADD=%d, TBR=%s, TFO=%s, TWO=%s, TTO=%.1f s" $add $tbr $tfo $two $tto
};#doPrintComPara

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc doDisplayErrorMemory {} {

    TlPrint "--------------------------------------------------------"

    TlPrint "doDisplayErrorMemory {} - Error memory"
    TlPrint " Fault  Status eStatus Command Time actChan drvTh TJ "
    set List1 [ModTlReadBlock DP0 100 1]   ;#Object list: DPx,EPx,IPx,CMPx,RTPx,CRPx (index:0->9)
    set List2 [ModTlReadBlock TSP0 40 1]   ;#Object list: TDPx,TJPx (index:0->9)
    set List3 [ModTlReadBlock DPA 100 1]   ;#Object list: DPx,EPx,IPx,CMPx,RTPx,CRPx (index:A->F)
    set List4 [ModTlReadBlock TSPA 40 1]   ;#Object list: TDPx,TJPx (index:A->F)

    for { set i 0} { $i <= 15} { incr i } {
	#List1+2
	if {$i<=9 } {
	    set flt        [lindex $List1 [expr $i+0 ]]  ;#DPx
	    set sts        [lindex $List1 [expr $i+10]]  ;#EPx
	    set eSts       [lindex $List1 [expr $i+20]]  ;#IPx
	    set cmd        [lindex $List1 [expr $i+30]]  ;#CMPx
	    set opTime     [lindex $List1 [expr $i+60]]  ;#RTPx
	    set actChan    [lindex $List1 [expr $i+90]]  ;#CRPx
	    set drvTherm   [lindex $List2 [expr $i+10]]  ;#TDPx
	    set tj         [lindex $List2 [expr $i+20]]  ;#TJPx
	} else {
	    #List3+4
	    set j [expr $i-10]

	    set flt        [lindex $List3 [expr $j+0 ]]  ;#DPx
	    set sts        [lindex $List3 [expr $j+10]]  ;#EPx
	    set eSts       [lindex $List3 [expr $j+20]]  ;#IPx
	    set cmd        [lindex $List3 [expr $j+30]]  ;#CMPx
	    set opTime     [lindex $List3 [expr $j+60]]  ;#RTPx
	    set actChan    [lindex $List3 [expr $j+90]]  ;#CRPx
	    set drvTherm   [lindex $List4 [expr $j+10]]  ;#TDPx
	    set tj         [lindex $List4 [expr $j+20]]  ;#TJPx
	};#endif

	if { $flt  == "" } { set flt  0 }
	if { $sts  == "" } { set sts  0 }
	if { $eSts == "" } { set eSts 0 }
	if { $cmd  == "" } { set cmd  0 }

	set flt    [expr $flt  & 0x0000FFFF]   ;# is only WORD
	set sts    [expr $sts  & 0x0000FFFF]   ;# is only WORD
	set eSts   [expr $eSts & 0x0000FFFF]   ;# is only WORD
	set cmd    [expr $cmd  & 0x0000FFFF]   ;# is only WORD

	set rc [catch  {TlPrint " 0x%04X 0x%04X 0x%04X  0x%04X %4d %7d %5d %2d" $flt $sts $eSts $cmd $opTime $actChan $drvTherm $tj}]
	if {$rc != 0} {
	    TlError "Some arguments to display are empty: not possible to format and display"
	};#endif
    };#endfor

    TlPrint "-end----------------------------------------------------"

};#doDisplayErrorMemory

#DOC----------------------------------------------------------------
#DESCRIPTION
#  print DP0..DPF
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  170820 cordc   created
#
#END----------------------------------------------------------------
proc doDisplayFaultRecord {} {

    TlPrint "----------- Fault record --------------"

    for { set i 0} { $i <= 15} { incr i } {
	set x [format "%X" $i]
	set ActFlt         [ModTlRead DP$x 1]
	set ActFltName     [Enum_Name DP$x $ActFlt]
	set ActFltParam    [Param_Index $ActFltName 1]
	set ActFltLongname [GetListEntryLFT $ActFlt]
	if { $i == 0 } {
	    TlPrint " DP0 = $ActFltLongname (actual fault)"
	} elseif { $i == 1 } {
	    TlPrint " DP$x = $ActFltLongname (last fault)"
	} elseif { $i == 15 } {
	    TlPrint " DP$x = $ActFltLongname (oldest)"
	} else {
	    TlPrint " DP$x = $ActFltLongname"
	}
    }

} ;#doDisplayFaultRecord

#DOC----------------------------------------------------------------
#DESCRIPTION
#  print DP0..DPF
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  170820 cordc   created
#
#END----------------------------------------------------------------
proc doResetDeviceInputs { {device ""} } {

    global ActDev theDevList

    TlPrint "--------------------------------------------------------"
    TlPrint "doResetDeviceInputs {} -  Reset all inputs of wago controller"

    set InitialActDev $ActDev

    if { $device == "" } {
	#all devices
	set DevList  $theDevList
    } else {
	#just one device
	set DevList [list $device]
    }

    if {[GetSysFeat "Fortis"]} {
	Reset_Inputs_Fortis $DevList
    } elseif { [GetSysFeat "Nera"] || [GetSysFeat "Beidou"]} {
	Reset_Inputs_Nera_Beidou $DevList
    } elseif { [GetSysFeat "Opal"]} {
	Reset_Inputs_Opal $DevList
    } elseif { [GetSysFeat "ATS48P"] || [GetSysFeat "OPTIM"] || [GetSysFeat "BASIC"]} {
	Reset_Inputs_ATS $DevList
    } else {
	TlError "Unexpected System Feature in: doResetDeviceInputs "
    }

    set ActDev $InitialActDev     ;#Reset right value for active device
    TlPrint "-end----------------------------------------------------"
} ;# doResetDeviceInputs

#DOC----------------------------------------------------------------
#DESCRIPTION
#  print DP0..DPF
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  170820 cordc   created
#
#END----------------------------------------------------------------
proc Reset_Inputs_ATS { theDevList } {
    global ActDev
    #Reset inputs according to each device
    foreach j  $theDevList {
	set ActDev $j
	switch -exact $ActDev {
	    1 -
	    2 -
	    3 {
		for {set i 1} {$i < 5} {incr i} {
		    setDI $i "L"   ;#Reset logical input
		}
	    }
	    default {TlError "Wrong input"}
	}
    }
} ;#Reset_Inputs_ATS

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVGetTime { {TimeFormat 0} } {
    set Frame "0044"
    set RxFrame [FC43SendReceive 0x0F $Frame]

    set HexaValueYear  "0x[string range $RxFrame 8 9]"
    set  actualValueYear [expr $HexaValueYear]
    set HexaValueMonth  "0x[string range $RxFrame 10 11]"
    set  actualValueMonth [expr $HexaValueMonth]
    set HexaValueDay  "0x[string range $RxFrame 12 13]"
    set  actualValueDay [expr $HexaValueDay & 0x001F ]

    set HexaValueHour  "0x[string range $RxFrame 14 15]"
    set  actualValueHour [expr $HexaValueHour]
    set HexaValueMinute "0x[string range $RxFrame 16 17]"
    set  actualValueMinute [expr $HexaValueMinute]
    set HexaValueMs "0x[string range $RxFrame 18 21]"
    set  actualValueMs [expr $HexaValueMs]

    set result [format "%02d/%02d/%02d %02d:%02d:%02d:%03d" $actualValueDay $actualValueMonth $actualValueYear \
	$actualValueHour $actualValueMinute [expr $actualValueMs / 1000] [expr $actualValueMs % 1000]]
    TlPrint "Read time from device: $result"

    if { $TimeFormat == 0  } {
	return $result
    } else {
	set result1 [format "%04d/%02d/%02d %02d:%02d"   [expr $actualValueYear +2000] $actualValueMonth $actualValueDay \
	    $actualValueHour $actualValueMinute ]
	return $result1
    }

};#ATVGetTime

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVSetTime {Year Month Day Hour Minute Ms } {
    TlPrint "Write time to device: [format "%02d/%02d/%02d %02d:%02d:%02d:%03d" $Day $Month $Year $Hour $Minute \
   [expr $Ms / 1000] [expr $Ms % 1000]]"

    set Frame [format "0000%02X%02X%02X%02X%02X%04X" $Year $Month $Day $Hour $Minute $Ms]
    FC43SendReceive 0x10 $Frame
};#ATVSetTime

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVSetTimeAbort {Year Month Day Hour Minute Ms } {
    TlPrint "Write time to device: [format "%02d/%02d/%02d %02d:%02d:%02d:%03d" $Day $Month $Year $Hour $Minute \
   [expr $Ms / 1000] [expr $Ms % 1000]]"

    set Frame [format "0000%02X%02X%02X%02X%02X%04X" $Year $Month $Day $Hour $Minute $Ms]

    proc FC43SendReceiveAbort {MEItype Data} {
	global DevAdr ActDev theDebugFlagObj

	set FC 0x2B

	set Header  [format "%02X%02X%02X" $DevAdr($ActDev,MOD) $FC $MEItype]
	set TxFrame [format "%s%s" $Header $Data]

	if {$theDebugFlagObj} {
	    set RxFrame [string range [TlSend $TxFrame] 2 end]
	} else {
	    set RxFrame [string range [TlSendSilent $TxFrame] 2 end]
	}

	set RxFC 0x[string range $RxFrame 0 1]
	set RxMEItype 0x[string range $RxFrame 2 3]

	if {$RxFC != $FC} {
	    TlPrint "Wrong FC received: $RxFC (right : $FC)"
	    return $RxFrame
	} else  {
	    TlError "no Abort for FC, but result =$RxFrame"
	}

	if {$RxMEItype != $MEItype} {
	    TlPrint "Wrong MEI type received: $RxMEItype (right: $MEItype)"
	    return $RxFrame
	} else  {
	    TlError "no Abort for MEItype, but result =$RxFrame"
	}

	return $RxFrame
    };#FC43SendReceiveAbort

    FC43SendReceiveAbort 0x10 $Frame
};#ATVSetTimeAbort

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 170820 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVSetTimeActual {} {
    scan [clock format [clock seconds] -format %y] "%u" "Year"
    scan [clock format [clock seconds] -format %m] "%u" "Month"
    scan [clock format [clock seconds] -format %d] "%u" "Day"
    scan [clock format [clock seconds] -format %H] "%u" "Hour"
    scan [clock format [clock seconds] -format %M] "%u" "Minute"
    scan [clock format [clock seconds] -format %S] "%u" "Sec"

    TlPrint "Write actual time to device: [format "%02d/%02d/%02d %02d:%02d:%02d" $Day $Month \
   $Year $Hour $Minute $Sec]"

    set Frame [format "0000%02X%02X%02X%02X%02X%04X" $Year $Month $Day $Hour $Minute [expr $Sec*1000]]
    FC43SendReceive 0x10 $Frame
};#ATVSetTime

proc doFactorySetting { {fry_mask 0x0001} } {      ;# default: Bit0 = 1 : All parameters

    global globAbbruchFlag

    TlPrint "--------------------------------------------------------"
    TlPrint "doFactorySetting {} - "

    #do not interrupt saving!!
    set globAbbruchFlag_save $globAbbruchFlag
    set globAbbruchFlag 0

    switch $fry_mask {
	0x0001  { TlPrint "--- request factory settings: All parameters" }
	0x0002  { TlPrint "--- request factory settings: Drive configuration" }
	0x0008  { TlPrint "--- request factory settings: Motor parameters" }
	0x0010  { TlPrint "--- request factory settings: Communication parameters" }
	0x0080  { TlPrint "--- request factory settings: Display parameters" }
	0x008A  { TlPrint "--- request factory settings: All except communication parameters" }
	default { TlError "--- invalid factory settings mask: 0x%04X" $fry_mask
	    return 0
	}
    }

    if { [GetDevFeat "Altivar"] } {

	ModTlWrite MODE 0x5443
	ModTlWrite RAZI 0x0200
	ModTlWrite MODE 0x5250
	doWaitForState 2 10
	ModTlWrite MODE 0x5250
	doWaitForOff 10
	doWaitForState 2 5

    } else {                                     ;# for Nera

	#TlPrint "Modbus timeouts are %s" [ModGetTimeout]

	ModTlWrite           FRY   $fry_mask
	doWaitForModObject   FRY   $fry_mask 1
	doWaitForEEPROMFinished 50

	ModTlWrite           CGTY .CUS            ;# customer factory setting -> delete System:/Conf/OEM
	doWaitForEEPROMFinished 50
	checkModObject       CGTY .CUS

	ModTlWrite           CMI   1              ;# Bit0 = 1 : Factory setting asked
	doWaitForEEPROMStarted  1
	doWaitForEEPROMFinished 50 0  ;# no mintime
    }

    set globAbbruchFlag $globAbbruchFlag_save

    TlPrint "-end----------------------------------------------------"
}

proc doWaitForEEPROMStarted { timeout {NoErrPrint 0} {keypadchannel 0} } {

	TlPrint "--------------------------------------------------------"
	TlPrint "doWaitForEEPROMStarted {}"

	set eeps_ok   0
	set eti_ok    0
	set tryNumber 0

	set starttime [clock clicks -milliseconds]
	set timeout   [expr $timeout * 1000]

	while {1} {
		set waittime [expr [clock clicks -milliseconds] - $starttime]

		if { $keypadchannel == 1 } {
			InitKeypad 0
		}

		if { [CheckBreak] } { return 0 }

		set eeps [doReadModObject EEPS]

		if { ($eeps == "")} then {
			TlError "illegal RxFrame received"
			return 0
		}

		incr tryNumber

		if { ([expr $eeps & 0x0003] > 0)  } {     ;# MotorControl or Application
			TlPrint "EEPROM access startet after %d ms (%d cycles)" $waittime $tryNumber
			return 1

		}

		if { $waittime > $timeout } {
			if { $NoErrPrint == 0 } {
				#TlError "!!!!!!!!!!!!EEPROM !!!!!!!!!!!!!storing procedure not started after $timeout ms (eeps=%04X)" $eeps
			}
			return 0
		}

		doWaitMsSilent 600

	}

	TlPrint "-end----------------------------------------------------"
}
 
proc doWaitForEEPROMFinished { timeout {mintime 0} {TTId ""} {keypadchannel 0} } {

	TlPrint "--------------------------------------------------------"
	TlPrint "doWaitForEEPROMFinished {}"

	set tryNumber 0

	set rc 0
	set starttime [clock clicks -milliseconds]
	set timeout   [expr $timeout * 1000]
	set mintime   [expr int ($mintime * 1000)]

	while {1} {
		set waittime [expr [clock clicks -milliseconds] - $starttime]

		if { $keypadchannel == 1 } {
			InitKeypad 0
		}
		if { [CheckBreak] } { return 0 }

		set eeps_ok 0
		set cmi_ok  0
		set eti_ok  0
		set eeps    [doReadModObject EEPS]
		set cmi     [doReadModObject CMI]

		if { ($eeps == "") || ($cmi == "") } then {
			TlError "illegal RxFrame received"
			return 0
		}

		incr tryNumber

		if { [expr $eeps & 0x0003] == 0 } {
			set eeps_ok 1
		}

		if { $eeps_ok } {
			if { ($mintime > 0) && ($waittime < $mintime) } {
				doWaitMsFromDate $mintime $starttime
				set rc 2
				break
			} else {

				TlPrint "EEPROM access finished after %d ms (%d cycles)" $waittime $tryNumber
				set rc 0
				break
			}
		}

		if { $waittime > $timeout } {

			if {$TTId == ""} {
				# TlError "*GEDEC00183972* EEPROM storing procedure not finished after $timeout ms (eeps=%04X) (cmi=%04X) (eti=%04X)" $eeps $cmi $eti
			} else {
				TlError "*$TTId* EEPROM storing procedure not finished after $timeout ms (eeps=%04X) (cmi=%04X) (eti=%04X)" $eeps $cmi $eti
			}
			set rc 1
			break
		}

	} ;# while 1

	#TlPrint "when EEPROM access finished, an innocent write request must be possible:"
	#otherwise wait some additional sec, maybe the eeprom access is still not finished
	#set acc [ModTlRead ACC]
	#set write_result [ModTlWrite ACC $acc 1 "GEDEC00177854"]
	#if { [string first "9004" $write_result] >= 0 } { doWaitMs 10000 } ;#abortcode 4 = Server device
	# failure

	TlPrint "-end----------------------------------------------------"
	return $rc

};# doWaitForEEPROMFinished

proc OpenShell { command } {
    global AutoIt
    ProcessClose "Putty.exe"
    $AutoIt Run "C:/Program\ Files/ExtraPuTTY/Bin/putty.exe"
    if {[doWaitForWindow "PuTTY" 5]} {
	sendKeys "PuTTY" "{TAB 4}"
	doWaitMs 100
	sendKeys "PuTTY" "{DOWN 2}"
	doWaitMs 100
	sendKeys "PuTTY" "{TAB}"
	doWaitMs 100
	sendKeys "PuTTY" "{SPACE}"
	doWaitMs 100
	sendKeys "PuTTY" "{ENTER}"
	doWaitMs 100
	sendKeys "PuTTY" "{TAB 4}"
	doWaitMs 100
	sendKeys "PuTTY" "{SPACE}"
	sendKeys "PuTTY" "{ENTER}"

	doWaitMs 100
	if {[doWaitForWindow "ATLAS" 10] } {
	    sendKeys "ATLAS" "^c"
	    doWaitMs 1000
	    sendKeys "ATLAS" "{ENTER}"
	    doWaitMs 5000
	    sendKeys "ATLAS" "$command{ENTER}"
	    doWaitMs 1000
	    sendKeys "ATLAS" "!{F4}"
	    if {[doWaitForWindow "PuTTY Exit Confirmation" 5]} {
		sendKeys "PuTTY Exit Confirmation" "{ENTER}"

	    }
	}

	set FileName "D:/documents\ and\ Settings/STP0387/Start\ Menu/Programs/ExtraPuTTY/Examples/putty.log"
	if { [file exists $FileName] == 1 } {
	    TlPrint "**** Open file: $FileName"
	    set file [open $FileName r]

	    while { [gets $file line] >= 0 } {
		TlPrint $line
	    }
	    TlPrint "**** Close file: $FileName"
	    close $file
	}

    }
}

proc doWaitForObjectList { objekt darfWerts timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}} {

    set TTId [Format_TTId $TTId]

    set ExpEnumList ""
    set ResEnum ""
    set NameValue ""
    set allowedValues ""

    foreach sollWert $darfWerts {

	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
	    set NameValue [lrange $ListOfValue 1 end]
	    set NameValue [join $NameValue ""]
	    set sollWert  [Enum_Value $objekt $NameValue]

	    if [regexp {[^0-9]} $sollWert] {
		TlError "Something wrong in list of expected values $darfWerts"
		return
	    }

	}
	lappend allowedValues [expr $sollWert & $bitmaske]
	lappend ExpEnumList   "$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {

	if { $keypadchannel == 1 } {
	    InitKeypad 0
	}

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnumList != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	set searchindex [lsearch $allowedValues [expr ($istWert & $bitmaske)]]

	if { $searchindex != -1 } {

	    set ExpEnum [lindex $ExpEnumList $searchindex]
	    if { $bitmaske  == 0xffffffff } {
		TlPrint "doWaitForObjectList $objekt act=0x%04X (%d$ResEnum) part of $darfWerts, waittime (%dms / %d requests)" $istWert $istWert $waittime $tryNumber
	    } else {
		TlPrint "doWaitForObjectList $objekt act=0x%04X (%d$ResEnum),act&maske ($bitmaske)  = [expr $istWert & $bitmaske] (0x%04X)  part of $darfWerts, waittime (%dms / %d requests)" $istWert $istWert [expr ($istWert & $bitmaske)] $waittime $tryNumber
	    }
	    break
	} elseif { [expr $waittime > $timeout] } {
	    if {$noErrPrint == 0} {
		TlError "$TTId doWaitForObjectList $objekt act=0x%08X (%d$ResEnum) not part of $darfWerts, waittime (%dms)" $istWert $istWert $waittime
		ShowStatus
	    }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

proc doWaitForObject { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0} } {
    global Debug_NERA_Storing

    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {

	if { $keypadchannel == 1 } {
	    InitKeypad 0
	}

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

	    TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
	    break

	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$objekt == "HMIS"} {
		# Error infos for actual sporadic faults in the testcabinet

		if {( $sollWert != 23) && ( $istWert == 23)} {

		    set DP0_Tmp [TlRead "DP0" 1]
		    switch $DP0_Tmp {
			27 {
			    # INF2
			    TlError "*GEDEC00203810* INF2 Fault"
			}
			68 {
			    # INF6
			    TlError "*GEDEC00203492* INF6 Fault"
			}
			69 {
			    # INFE
			    TlError "*GEDEC00201702* INFE Fault"
			}
			153 {
			    # INFM
			    TlError "*GEDEC00203425* INFM Fault"
			}
		    }

		}

	    }

	    if {$noErrPrint} {
		TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    } else {
		if { $bitmaske  == 0xffffffff } {
		    TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		}
	    }

	    if {$noErrPrint == 0} { ShowStatus }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

## Function description : Regular doWaitForObject function, except it is forced to use Modbus RTU to read the parameter. Allows to wait for an object out of the customer parameters
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
# \param[in] timeLow: duration of the maintain of the value (seconds)

proc doWaitForModObject { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
    global Debug_NERA_Storing

    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForModObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadModObject $objekt ]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

	    TlPrint "doWaitForModObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    #TlPrint  " doWaitForModObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
	    break

	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$objekt == "HMIS"} {
		# Error infos for actual sporadic faults in the testcabinet

		if {( $sollWert != 23) && ( $istWert == 23)} {

		    set DP0_Tmp [TlRead "DP0" 1]
		    switch $DP0_Tmp {
			27 {
			    # INF2
			    TlError "*GEDEC00203810* INF2 Fault"
			}
			68 {
			    # INF6
			    TlError "*GEDEC00203492* INF6 Fault"
			}
			69 {
			    # INFE
			    TlError "*GEDEC00201702* INFE Fault"
			}
			153 {
			    # INFM
			    TlError "*GEDEC00203425* INFM Fault"
			}
		    }

		}

	    }

	    if {$noErrPrint} {
		TlPrint "$TTId doWaitForModObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    } else {
		if { $bitmaske  == 0xffffffff } {
		    TlError "$TTId doWaitForModObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    TlError "$TTId doWaitForModObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		}
	    }

	    if {$noErrPrint == 0} { ShowStatus }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

## Function description : Waits for a parameter to reach a value given as a parameter and to remain to this value for a given time
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
# \param[in] timeLow: duration of the maintain of the value (seconds)
proc doWaitForObjectLevel { objekt sollWert timeout timeLow {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} } {
    global Debug_NERA_Storing
    TlPrint "Wait for object $objekt to reach value $sollWert and keep it during $timeLow s . Max wait $timeout s. Bitmaske $bitmaske, TTID : $TTId , Error print $noErrPrint"
    set TTId [Format_TTId $TTId]
    #    if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    set startLevel 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	#set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	set istWert [ModTlRead $objekt $noErrPrint $TTId]
	# TlPrint "Monitored parameter : $istWert  || wait time : $waittime"
	if { $istWert == "" } then {
	    set startLevel 0
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
		return 0
	    }
	    set currentTime [clock clicks -milliseconds]
	    if { [expr $waittime > $timeout]} {
		TlPrint "Timeout reached $TTId"
		break
	    }

	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}
	if {$istWert != ""} {
	    if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)]} {
		if {$startLevel} {set startLevel 0}
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  "
	    }
	    if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

		#debut de modif
		if {$startLevel == 0 } {
		    set startLevelTime [clock clicks -milliseconds]
		    set startLevel 1
		}

		set currentTime [clock clicks -milliseconds]
		#TlPrint "Current Time : $currentTime  || Start time : $startLevelTime "
		#TlPrint "Duration [expr $currentTime - $startLevelTime]  || goal : [expr $timeLow * 1000]"
		#TlPrint "Current value of the monitored word : $istWert"
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  || lowTime [expr $currentTime - $startLevelTime]"
		if { [expr $currentTime - $startLevelTime] >= [expr $timeLow * 1000]} {

		    TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
		    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
		    break
		}

	    } elseif { [expr $waittime > $timeout] } {

		set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

		if {$objekt == "HMIS"} {
		    # Error infos for actual sporadic faults in the testcabinet

		    if {( $sollWert != 23) && ( $istWert == 23)} {

			set DP0_Tmp [TlRead "DP0" 1]
			switch $DP0_Tmp {
			    27 {
				# INF2
				TlError "*GEDEC00203810* INF2 Fault"
			    }
			    68 {
				# INF6
				TlError "*GEDEC00203492* INF6 Fault"
			    }
			    69 {
				# INFE
				TlError "*GEDEC00201702* INFE Fault"
			    }
			    153 {
				# INFM
				TlError "*GEDEC00203425* INFM Fault"
			    }
			}

		    }

		}

		if {$noErrPrint} {
		    TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    if { $bitmaske  == 0xffffffff } {
			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		    } else {
			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		    }
		}

		if {$noErrPrint == 0} { ShowStatus }
		return 0
	    }
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

## Function description : Waits for a parameter to reach a value given as a parameter and to remain to this value for a given time
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
# \param[in] timeLow: duration of the maintain of the value (seconds)
proc doWaitForObjectLevelOK { objekt sollWert timeout timeLow {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
    global Debug_NERA_Storing
    TlPrint " Wait for object $objekt to reach value $sollWert and keep it during $timeLow . Max wait $timeout"
    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    set startLevel 0
    set Ok 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	#set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	set istWert [ModTlRead $objekt $noErrPrint $TTId]
	# TlPrint "Monitored parameter : $istWert  || wait time : $waittime"
	if { $istWert == "" } then {
	    set startLevel 0
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
		return 0
	    }

	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}
	if {$istWert != ""} {
	    if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)]} {
		if {$startLevel} {set startLevel 0}
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  "
	    }
	    if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

		#debut de modif
		if {$startLevel == 0 } {
		    set startLevelTime [clock clicks -milliseconds]
		    set startLevel 1
		}

		set currentTime [clock clicks -milliseconds]
		#TlPrint "Current Time : $currentTime  || Start time : $startLevelTime "
		#TlPrint "Duration [expr $currentTime - $startLevelTime]  || goal : [expr $timeLow * 1000]"
		#TlPrint "Current value of the monitored word : $istWert"
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  || lowTime [expr $currentTime - $startLevelTime]"
		if { [expr $currentTime - $startLevelTime] >= [expr $timeLow * 1000]} {

		    set Ok 1
		    TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
		    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
		    break
		}

	    } elseif { [expr $waittime > $timeout] } {

		set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

		if {$objekt == "HMIS"} {
		    # Error infos for actual sporadic faults in the testcabinet

		    if {( $sollWert != 23) && ( $istWert == 23)} {

			set DP0_Tmp [TlRead "DP0" 1]
			switch $DP0_Tmp {
			    27 {
				# INF2
				TlError "*GEDEC00203810* INF2 Fault"
			    }
			    68 {
				# INF6
				TlError "*GEDEC00203492* INF6 Fault"
			    }
			    69 {
				# INFE
				TlError "*GEDEC00201702* INFE Fault"
			    }
			    153 {
				# INFM
				TlError "*GEDEC00203425* INFM Fault"
			    }
			}

		    }

		}

		#		if {$noErrPrint} {
		#		    TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		#		} else {
		#		    if { $bitmaske  == 0xffffffff } {
		#			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		#		    } else {
		#			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		#		    }
		#		}
		#
		#		if {$noErrPrint == 0} { ShowStatus }
		#		return 0
		break
	    }
	}

	incr tryNumber

	if {[CheckBreak]} {break}

    }
    if {$Ok == 1} 	{
	TlPrint "_________________________________________________________________________________________________________________"
	TlPrint "the return value OK is $Ok,the target value 0x%04X (%d$ExpEnum) can be reached by $objekt at [expr $startLevelTime- $startZeit] ms and during  $timeLow s" $sollWert $sollWert
	TlPrint "_________________________________________________________________________________________________________________"
    } else {
	TlPrint "_________________________________________________________________________________________________________________"
	TlPrint "the return value OK is $Ok,the target value 0x%04X (%d$ExpEnum) can not be reached by $objekt which lasts $timeLow s"  $sollWert $sollWert
	TlPrint "_________________________________________________________________________________________________________________"
    }
    return $Ok
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------

proc doWaitForNotObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {

    global Debug_NERA_Storing

    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {
	if { $keypadchannel == 1 } {
	    InitKeypad 0
	}

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
	    #  TlPrint "doWaitForNotObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
	    TlPrint " doWaitForNotObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
	    break

	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$objekt == "HMIS"} {
		# Error infos for actual sporadic faults in the testcabinet

		if {( $sollWert != 23) && ( $istWert == 23)} {

		    set DP0_Tmp [TlRead "DP0" 1]
		    switch $DP0_Tmp {
			27 {
			    # INF2
			    TlError "*GEDEC00203810* INF2 Fault"
			}
			68 {
			    # INF6
			    TlError "*GEDEC00203492* INF6 Fault"
			}
			69 {
			    # INFE
			    TlError "*GEDEC00201702* INFE Fault"
			}
			153 {
			    # INFM
			    TlError "*GEDEC00203425* INFM Fault"
			}
		    }

		}

	    }

	    if {$noErrPrint} {
		TlPrint "$TTId doWaitForNotObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    } else {
		if { $bitmaske  == 0xffffffff } {
		    TlError "$TTId doWaitForNotObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    TlError "$TTId doWaitForNotObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		}
	    }

	    if {$noErrPrint == 0} { ShowStatus }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#It is forced to use Modbus RTU to read the parameter.
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 120122 Yahya    proc created
#
#END----------------------------------------------------------------

proc doWaitForNotModObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {

    global Debug_NERA_Storing

    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {
	if { $keypadchannel == 1 } {
	    InitKeypad 0
	}

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadModObject $objekt]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
	    #  TlPrint "doWaitForNotModObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
	    TlPrint " doWaitForNotModObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
	    break

	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$objekt == "HMIS"} {
		# Error infos for actual sporadic faults in the testcabinet

		if {( $sollWert != 23) && ( $istWert == 23)} {

		    set DP0_Tmp [ModTlRead "DP0" 1]
		    switch $DP0_Tmp {
			27 {
			    # INF2
			    TlError "*GEDEC00203810* INF2 Fault"
			}
			68 {
			    # INF6
			    TlError "*GEDEC00203492* INF6 Fault"
			}
			69 {
			    # INFE
			    TlError "*GEDEC00201702* INFE Fault"
			}
			153 {
			    # INFM
			    TlError "*GEDEC00203425* INFM Fault"
			}
		    }

		}

	    }

	    if {$noErrPrint} {
		TlPrint "$TTId doWaitForNotModObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    } else {
		if { $bitmaske  == 0xffffffff } {
		    TlError "$TTId doWaitForNotModObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    TlError "$TTId doWaitForNotModObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		}
	    }

	    if {$noErrPrint == 0} { ShowStatus }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value is not between  exp - tolerance   and exp + tolerance
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {

    set NameValue   ""
    set ListOfValue [split $sollWert {}]
    set timeout     [expr int ($timeout*1000)] ;#in ms
    set TTId [Format_TTId $TTId]

    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]
	if [regexp {[^0-9]} $sollWert] { return }
    }

    set startZeit [clock clicks -milliseconds]
    set tryNumber 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks

	set istWert [doReadObject $objekt]

	set  duration [expr [clock clicks -milliseconds] - $startZeit]
	incr tryNumber

	if { $istWert != "" } then {
	    set diff [expr $istWert - $sollWert]
	    if {[expr abs($diff)] > $tolerance} {
		TlPrint "doWaitForNotObjectTol %s exp is not =%d with tol=%d ,act=%d  diff=%d waittime=%d ms requests=%d" \
		    $objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
		break
	    }
	}

	if { $duration >= $timeout } {
	    if { $istWert == "" } {
		TlError "$TTId doWaitForNotObjectTol $objekt: no response after waittime=%d ms" $duration
	    } else {
		TlError "$TTId doWaitForNotObjectTol %s exp shall not be =%d with tol=%d, act=%d  diff=%d TO=$timeout ms WT=%d ms requests=%d" \
		    $objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
		if { $show_status } { ShowStatus }
	    }

	    break
	}
	if {[CheckBreak]} {break}
    }
    return $istWert
}



#DOC----------------------------------------------------------------
#DESCRIPTION
#ATSBackToInit_COM will reset the faults and initialize the parameters
#Copy of the original ATSBackToIniti function but adapted to work with the com parameters
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------

proc ATSBackToInit_COM { } {
    TlPrint "====================================reset with ATSBackToIniti======================================"
    global ActDev FAULT_RESET_INPUT_ID FORCED_LOCAL_ASSIGN_ID
    PhaseOnOff 1 H
    PhaseOnOff 2 H
    PhaseOnOff 3 H
    PhaseAllOnOff $ActDev H
    CtrlOnOff $ActDev H

    doResetDeviceInputs $ActDev
    TlWrite CMD 0x0
    doWaitMs 100
    TlWrite CMI 0
    doWaitMs 100

    TlWrite FCS .INI
    doWaitForObjectLevel EEPS 0 15 3

    TlWrite CHCF .STD
    doWaitForObject CHCF .STD 1

    TlWrite CD1 .TER
    doWaitForObject CCC 1 1

    DIAssigne 3 FAULT_RESET_INPUT_ID 1

    setDI 3 H
    doWaitMs 250
    setDI 3 L
    doWaitForObjectList HMIS {.NST .RDY} 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATSBackToIniti will reset the faults and initialize the parameters in the best way in function of TER or MDB
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
# 281122 ASY	  added the call to setSTO for ATS490 at the begining of the proc
# 070323 Yahya	  Added FRY = 2 prior to factory setting request
# 081123 Yahya	  Reworked the proc and adapted for all ATS devices
# 260424 Yahya	  Added FAN deactivation, Bypass opening and "service" access level deactivation (see Issue #2039)
# 130125 Kilian   Update ETI timeout after FCS = INI to prevent fail linked to profinet
#
#END----------------------------------------------------------------
proc  ATSBackToIniti  { } {
    TlPrint "====================================reset with ATSBackToIniti======================================"
    global ActDev

    #/!\ When ATSBackToIniti is called, the command interface is set to Modbus SL
    # and it remains on this interface at the end.
    #Change to another interface must be done explicitly in the test cases later
    #Change the Unifast command interface to Modbus SL
    doSetCmdInterface "MOD"

    #Set all digital inouts of the device (DIx) to low
    doResetDeviceInputs $ActDev

    #Turn off the load machine
    LoadOff 0

    #Switch to Modbus port 1 (fieldbus port)
    toggleModbusPort L

    #Deactivate 24V supply
    setP24Supply L
	
    #Deactivate the heating bloc's FAN
    setFAN L
	
    #Open the bypass contactor on the tower
    BypassPhaseAllOnOff L

    #Check if the device is already supplied via CL1/2
    #If it is the case, set up the input & output phases and no need to wait for device to boot
    #otherwise, power on the device and wait it to boot up
    if { [isActDevSupplied] } {
	PhaseAllOnOff $ActDev H
	MotorPhaseAllOnOff H
	CtrlOnOff $ActDev H
    } else { 
	DeviceOn $ActDev
    }

    if {[GetDevFeat "OPTIM"]} {
	setSTO H
    }

    #If Modbus communication with the DUT (via its specific Modbus address) is lost, raise error & reconfigure it
    ATS_ReconfigCommIfLost

    TlWrite CMI 0
    doWaitForObject CMI 0 1

    TlWrite CMD 0
    doWaitForObject CMD 0 1
	
    #Disable "service" access level
    writeLACValue "" 1

    #Set FRY = 2 to avoid impacting communication parameters by factory setting
    #NOTE : counters, error history, cybersecurity parameters are not impacted by factory setting
    TlWrite FRY 2
    doWaitForObject FRY 2 1

    TlWrite FCS .INI
    if {[GetDevFeat "Board_EthAdvanced"]} {
	doWaitForObjectLevel EEPS 0 30 5 0xFFFF "" 1
    } else {
	doWaitForEEPROMStarted  1
	doWaitForEEPROMFinished 10
    }
    doWaitForObject ETI 0x0000 9 0x0001 "GED-104811";#Waiting "Write parameter authorization"

    #Reset all switches linked to thermal sensor / AI
    setAIMode "none"
    ActiveThermResistor L
    setOCThermResistor L
    setCCThermResistor L

    #Check if device is in fault state :
    if {[doPrintModObject HMIS] == [Enum_Value HMIS .FLT]} {
	ShowStatus

	#Assign reset fault to LI3
	#Assign forced local to LI4
	#Assign forced local channel to terminal
	#NOTE : here we get the initial values of parameters RSF, FLO & FLOC to reassign them back later
	set initialValues [writeDUTParameters {RSF .LI3 FLO .LI4 FLOC .TER} ]

	#Activate forced local
	setDI 4 H
	doWaitMs 100

	#Make a rising edge to reset fault
	setDI 3 H
	doWaitMs 100
	setDI 3 L

	#Exit forced local
	setDI 4 L

	#Reassign the parameters RSF, FLO & FLOC to their initial values
	writeDUTParameters $initialValues

	if {[doPrintModObject HMIS] == [Enum_Value HMIS .FLT]} { 
	    doRP
	    if {[doPrintModObject HMIS] == [Enum_Value HMIS .FLT]} {
		TlError "Fault [Enum_Name LFT [TlRead LFT]] not reset after manual reset and RP"
		doSetDefaults 1 0 1
	    }
	}
    }

    #Set all digital inputs of the device (DIx) to low
    doResetDeviceInputs $ActDev

    #When problem of the testbench like circuit breaker KO, we will do exit
    if {[doPrintModObject HMIS] == [Enum_Value HMIS .NLP]} {
	doWaitMs 2000
	if {[doPrintModObject HMIS] == [Enum_Value HMIS .NLP]} {
	    TlPrint ""
	    TlPrint "HMIS is [Enum_Name  HMIS [expr [TlRead HMIS]]]"
	    TlPrint "CHECK WHY ATS IS IN NLP!!!!!!! MAYBE CIRCUIT BREAKER OF TEST BENCH  KO"
	    DeviceOff $ActDev
	    exit
	}
    }

    doWaitForObjectList HMIS {.RDY .NST} 5
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATS_GestionINF0 will do a DeviceOff DeviceOn if INFO is displayed (temporary  function to remove INF0 for CS18)
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 115021 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_GestionINF0 { } {
    global ActDev

    if {[Enum_Name  HMIS [expr [TlRead HMIS]]] == "FLT" && ([Enum_Name  LFT [expr [TlRead LFT]]] == "INF0" || [Enum_Name  LFT [expr [TlRead LFT]]] == "INF3")} {
	TlPrint "power off/on device, try to reset [Enum_Name  LFT [expr [TlRead LFT]]]"
	DeviceOff $ActDev

	DeviceOn $ActDev
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATS_GestionRP will check a RP=YES is really done or not, if not  it will do a DeviceOff DeviceOn (temporary  function to realize a RP for CS18)
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 115021 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_GestionRP { } {
    global ActDev DevAdr

    #set MBAdr $DevAdr($ActDev,MOD)

    set objString "ADD"
    set LogAdr [Param_Index $objString]
    set FC  3
    set TxFrame [format "%02X%02X%04X0002"       0xF8     $FC $LogAdr]
    doWaitMs 3000
    if {     [TlSendNoResponseOK $TxFrame 1] == 0} {  ;# [ doWaitForRelay R1 L 3 1] == 0
	TlPrint "device still powered on, RP=YES or MODE=RP does nothing"
	DeviceOff $ActDev

	DeviceOn $ActDev
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATS_GestionLossCommunication will check do a device off/on if no cummunication cause 3 red LED pb in CS20
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 230621 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_GestionLossCommunication { {noErrPrint 0} } {
    global ActDev DevAdr

    #set MBAdr $DevAdr($ActDev,MOD)

    set objString "ADD"
    set LogAdr [Param_Index $objString]
    set FC  3
    set TxFrame [format "%02X%02X%04X0002"       0xF8     $FC $LogAdr]

    if {     [TlSendNoResponseOK $TxFrame 1] == 1} {
	if {     $noErrPrint == 1} {
	    TlPrint "GET NO RESPONSE !!!!!!!"
	} else {
	    TlPrint "No response !!!!!!!"
	}

	DeviceOff $ActDev

	DeviceOn $ActDev

	if {     [TlSendNoResponseOK $TxFrame 1] == 1} {

	    doSetDefaults 1 0 1
	}

    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATS_ReconfigCommIfLost will check if the communication with device is lost the reconfigure it
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 251021 Yahya    proc created
#
#END----------------------------------------------------------------
proc ATS_ReconfigCommIfLost { {noErrPrint 0} } {
    global ActDev DevAdr

    set MBAdr $DevAdr($ActDev,MOD)
    TlPrint "ATS_ReconfigCommIfLost"
    set objString "ADD"
    set LogAdr [Param_Index $objString]
    set FC  3
    set TxFrame [format "%02X%02X%04X0002" $MBAdr $FC $LogAdr]

    if { [TlSendNoResponseOK $TxFrame 1] == 1 } {
	TlError "!!! Communication is lost !!!"
	doSetDefaults 1 0 1
    }
}

proc TlSendNoResponseOK { frame {crc 1} } {
    global theDebugFlagObj errorInfo
    set ok 0
    set rc [catch { set result [mbDirect $frame $crc] }]
    if {$rc != 0} {
	set ok 1
	set result ""
	TlPrint "TlSendNoResponse OK: [GetFirstLine $errorInfo]"
    } else {
	TlPrint "TlSendNoResponse: send:$frame  received:$result"
    }

    if {$theDebugFlagObj} {
	set emptyList {}
	TlPrintIntern D "send $frame : $result" emptyList
    }

    return $ok
} ;#TlSendNoResponse

#DOC----------------------------------------------------------------
#DESCRIPTION
#function identifies different types of product and the parameter to different name
#example parameters: ERROR_INHIBITION_ASSIGNMENT,ATR_CONFIGURATION, FAULT_RESET_INPUT,EXTERNAL_ERROR_ASSIGNMENT
#
# ----------HISTORY----------
# WHEN		WHO	WHAT
# 04-10-2020	kaidi	proc created
# 18-01-2023	Yahya	separated global variables definitions for ATS430 and ATS490
# 03-03-2023	F.FRIOL	Update instruction with InputList for each fieldbus comm word
# 05-05-2023	ASY	Add Input assign low level  
# 
#END----------------------------------------------------------------

proc ATSParaIdentificaiton { } {
    global LI1_ASSIGN LI2_ASSIGN LI3_ASSIGN LI4_ASSIGN DO_1_ASSIGN DO_2_ASSIGN R1_ASSIGN R2_ASSIGN R3_ASSIGN
    global EXTERNAL_ERROR_ASSIGNMENT_ID FORCED_LOCAL_ASSIGN_ID FAULT_RESET_INPUT_ID 2NDSETPARAMETER_ID FORCED_FREEWHEEL_STOP_ID EMERGENCY_STOP_ASSIGNMENT_ID ERROR_INHIBITION_ASSIGNMENT_ID
    global FORCED_LOCAL_ASSIGN FAULT_RESET_INPUT EXTERNAL_ERROR_ASSIGNMENT COMMAND_CHANNEL_SWITCHING ERROR_INHIBITION_ASSIGNMENT EMERGENCY_STOP_ASSIGNMENT PREHEATING ATR_CONFIGURATION
    global AO_1_ASSIGN AO1_ASSIGNMENT AO_1_TYPE STP_MODE RUN_ENABLED_ID RUN_FORWARD_ID RUN_ENABLED RUN_FORWARD 
    global THERMAL_FAULT_RESET_INPUT THERMAL_FAULT_RESET_ID AO_configuration JOG_OPERATION JOG_LOW_SPEED TYPE_OF_CONTROL 2W_TYPE_CONTROL EXTERNAL_ERROR_BEHAVIOR
    global InputList InputList_ID InputList_DI_HighLevel InputList_DI_LowLevel InputList_CDxx_STD InputList_C1xx_STD InputList_C2xx_STD InputList_C3xx_STD InputList_C5xx_STD
    global InputList_CDxx_IO_2C InputList_CDxx_IO_3C InputList_CDxx_IO_LC3W InputList_C1xx_IO_2C InputList_C1xx_IO_3C InputList_C2xx_IO_2C InputList_C2xx_IO_3C InputList_C3xx_IO_2C InputList_C3xx_IO_3C InputList_C5xx_IO_2C InputList_C5xx_IO_3C
    global InputList_C1xx_IO_LC3W InputList_C2xx_IO_LC3W InputList_C3xx_IO_LC3W InputList_C5xx_IO_LC3W
    global LI1L_ASSIGN LI2L_ASSIGN LI3L_ASSIGN LI4L_ASSIGN
    # ---------- Commentary -----------
    # Variable finishing by "_ID" target possible value on function parameters (like LxA/LxH/LxL or LLC)
    # Variable not finishing by "_ID" target directly parameters itself
    # Variable List finishing by "_STD" are create for listing all possible value in CHCF=STD (for All Dev)
    # Variable List finishing by "_IO" are create for listing all possible value in CHCF=IO (for ATS430/ATS490)
    # Variable List finishing by "_IO" with "_2C" are create for listing all possible value in CHCF=IO and TCC=2C (only for ATS490)
    # Variable List finishing by "_IO" with "_3C" are create for listing all possible value in CHCF=IO and TCC=3C (only for ATS490)
    # Variable List finishing by "_IO" with "_LC3W" are create for listing all possible value in CHCF=IO and TCC=LC3W (for All Dev)
    # ----------- ---------- ----------
	
    # -------------------------------- COMMON PART --------------------------------
    # parameter identification
    set DO_1_ASSIGN "DO1"
    set DO_2_ASSIGN "DO2"
    set R1_ASSIGN "R1"
    set R2_ASSIGN "R2"
    set R3_ASSIGN "R3"
    
    set EXTERNAL_ERROR_ASSIGNMENT_ID "LIETF"
    set FORCED_LOCAL_ASSIGN_ID "LIFLO"
    set FAULT_RESET_INPUT_ID "LIRSF"
    set 2NDSETPARAMETER_ID "LIS"
    set FORCED_FREEWHEEL_STOP_ID "FFSA"

    set EMERGENCY_STOP_ASSIGNMENT_ID "LILES"
    set ERROR_INHIBITION_ASSIGNMENT_ID "LIINH"
    set FORCED_LOCAL_ASSIGN "FLO"	
    set FAULT_RESET_INPUT "RSF"
    set EXTERNAL_ERROR_ASSIGNMENT "ETF"

    set COMMAND_CHANNEL_SWITCHING "CCS"
    set ERROR_INHIBITION_ASSIGNMENT "INH"
    set EMERGENCY_STOP_ASSIGNMENT "LES"
    set PREHEATING "PRHA"
    set ATR_CONFIGURATION "ATR"

    set AO_1_ASSIGN "AO1"
    set AO1_ASSIGNMENT "AO1"
    set AO_1_TYPE "AO1T"
    set STP_MODE "STT"

    set THERMAL_FAULT_RESET_INPUT "RSFT"
    set THERMAL_FAULT_RESET_ID "RSFT"
    set AO_configuration "O_0_4"

    set JOG_OPERATION "LIJOG"
    set JOG_LOW_SPEED "JOSA"
    set TYPE_OF_CONTROL "TCC"
    set 2W_TYPE_CONTROL "TCT"
    set EXTERNAL_ERROR_BEHAVIOR "EPL"

    #List for fieldbus command word in STD profile
    set InputList_CDxx_STD [list "CD11" "CD12" "CD13" "CD14" "CD15"]; #List for all CDxx possible value in STD profile
    set InputList_C1xx_STD [list "C111" "C112" "C113" "C114" "C115"]; #List for all MDB comm word possible value in STD profile
    set InputList_C2xx_STD [list "C211" "C212" "C213" "C214" "C215"]; #List for all CAN comm word possible value in STD profile
    set InputList_C3xx_STD [list "C311" "C312" "C313" "C314" "C315"]; #List for all Option board comm word possible value in STD profile
    set InputList_C5xx_STD [list "C511" "C512" "C513" "C514" "C515"]; #List for all ETH_embd comm word possible value in STD profile

    #List for CDxx command word in IO profile (2C/3C)
    set InputList_CDxx_IO_2C [list "CD01" "CD02" "CD03" "CD04" "CD05" "CD06" "CD07" "CD08" "CD09" "CD10" "CD11" "CD12" "CD13" "CD14" "CD15"]
    set InputList_CDxx_IO_3C [list "CD02" "CD03" "CD04" "CD05" "CD06" "CD07" "CD08" "CD09" "CD10" "CD11" "CD12" "CD13" "CD14" "CD15"]
    set InputList_CDxx_IO_LC3W [list "CD02" "CD03" "CD04" "CD05" "CD06" "CD07" "CD08" "CD09" "CD10" "CD11" "CD12" "CD13" "CD14" "CD15"]
    #List for MDB command word in IO profile (2C/3C)
    set InputList_C1xx_IO_2C [list "C101" "C102" "C103" "C104" "C105" "C106" "C107" "C108" "C109" "C110" "C111" "C112" "C113" "C114" "C115"]
    set InputList_C1xx_IO_3C [list "C102" "C103" "C104" "C105" "C106" "C107" "C108" "C109" "C110" "C111" "C112" "C113" "C114" "C115"]
    set InputList_C1xx_IO_LC3W [list "C102" "C103" "C104" "C105" "C106" "C107" "C108" "C109" "C110" "C111" "C112" "C113" "C114" "C115"]
    #List for CAN command word in IO profile (2C/3C)
    set InputList_C2xx_IO_2C [list "C201" "C202" "C203" "C204" "C205" "C206" "C207" "C208" "C209" "C210" "C211" "C212" "C213" "C214" "C215"]
    set InputList_C2xx_IO_3C [list "C202" "C203" "C204" "C205" "C206" "C207" "C208" "C209" "C210" "C211" "C212" "C213" "C214" "C215"]
    set InputList_C2xx_IO_LC3W [list "C202" "C203" "C204" "C205" "C206" "C207" "C208" "C209" "C210" "C211" "C212" "C213" "C214" "C215"]
    #List for Option board command word in IO profile (2C/3C)
    set InputList_C3xx_IO_2C [list "C301" "C302" "C303" "C304" "C305" "C306" "C307" "C308" "C309" "C310" "C311" "C312" "C313" "C314" "C315"]
    set InputList_C3xx_IO_3C [list "C302" "C303" "C304" "C305" "C306" "C307" "C308" "C309" "C310" "C311" "C312" "C313" "C314" "C315"]
    set InputList_C3xx_IO_LC3W [list "C302" "C303" "C304" "C305" "C306" "C307" "C308" "C309" "C310" "C311" "C312" "C313" "C314" "C315"]
    #List for Ethernet embedded command word in IO profile (2C/3C)
    set InputList_C5xx_IO_2C [list "C501" "C502" "C503" "C504" "C505" "C506" "C507" "C508" "C509" "C510" "C511" "C512" "C513" "C514" "C515"]
    set InputList_C5xx_IO_3C [list "C502" "C503" "C504" "C505" "C506" "C507" "C508" "C509" "C510" "C511" "C512" "C513" "C514" "C515"]
    set InputList_C5xx_IO_LC3W [list "C502" "C503" "C504" "C505" "C506" "C507" "C508" "C509" "C510" "C511" "C512" "C513" "C514" "C515"]
    # -------------------------------- ----------- --------------------------------

    # -------------------------------- ATS48/ATS48P PART --------------------------------
    # parameter identification
    if {[GetDevFeat "ATS48P"]} {
	set RUN_ENABLED_ID "STOP"
	set RUN_FORWARD_ID "RUN"
	set RUN_ENABLED "STOP"
	set RUN_FORWARD "S_RUN"
	#Digital Input Assignment used for DIx configuration
	set LI1_ASSIGN "L1A"
	set LI2_ASSIGN "L2A"
	set LI3_ASSIGN "L3A"
	set LI4_ASSIGN "L4A"

	# List of Digital Input
	set InputList [list "L3A" "L4A"]
	set InputList_ID [list "NO" "LI3" "LI4"]
	# -------------------------------- ----------------- --------------------------------

	# -------------------------------- OPTIM PART --------------------------------
    } elseif {[GetDevFeat "OPTIM"]} {
	set RUN_ENABLED_ID "RUN"
	set RUN_FORWARD_ID "FRD"
	set RUN_ENABLED "RUN"
	set RUN_FORWARD "FRD"
	#Digital Input Assignment used for DIx configuration (for High level)
	set LI1_ASSIGN "L1H"
	set LI2_ASSIGN "L2H"
	set LI3_ASSIGN "L3H"
	set LI4_ASSIGN "L4H"
	#Digital Input Assignment used for DIx configuration (for low level)
	set LI1L_ASSIGN  "L1L"
	set LI2L_ASSIGN  "L2L"
	set LI3L_ASSIGN  "L3L"
	set LI4L_ASSIGN  "L4L"

	# List of Digital Input
	set InputList [list "LI1" "LI2" "LI3" "LI4"]
	set InputList_ID [list "NO" "LI1" "LI2" "LI3" "LI4"]
	#set Inputlist for Logical input High
	set InputList_DI_HighLevel [list "L1H" "L2H" "L3H" "L4H"]
	#set Inputlist for Logical input Low
	set InputList_DI_LowLevel [list "L1L" "L2L" "L3L" "L4L"]
	# -------------------------------- ------------- --------------------------------

	# -------------------------------- BASIC PART --------------------------------
    } elseif {[GetDevFeat "BASIC"]} {
	set RUN_ENABLED_ID "RUN"
	set RUN_FORWARD_ID "FRD"
	set RUN_ENABLED "RUN"
	set RUN_FORWARD "FRD"
	#Digital Input Assignment used for DIx configuration
	set LI1_ASSIGN "L1A"
	set LI2_ASSIGN "L2A"
	set LI3_ASSIGN "L3A"
	set LI4_ASSIGN "L4A"

	# List of Digital Input
	set InputList [list "L3A" "L4A"]
	set InputList_ID [list "NO" "LI3" "LI4"]
	# -------------------------------- ----------- --------------------------------
    } else {
	TlError "ATS48 ATS48P OPTIM and BASIC allowed"
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#MotorStop set motor to stop in function of channel with possibility to change argument:
#- checkStopped: 	Check that ATS is stopped at 0A / 0rpm
#- forced:	Stop forced via DI1 & DI2
#- channel:	Either use the current active channel Or a specific command channel 
#- cmd: 	In case of Stop order is launch via fieldbus channel, set a value on CMD parameter to stop the motor
#
# ----------HISTORY----------
# WHEN  	WHO 	WHAT
# 131021 	kaidi 	proc created
# 081121 	yahya
# 061222 	ASY  	added the stop by ETH, CAN and NET
# 300123 	Yahya  	Added consideration of STOP with the all possible channels 
# 080323 	ASY 	added the checkStopped parameter
# 270623 	ASY	added the channel and cmd optionnal parameters
# 061123	F.FRIOL	Update checkStopped according ATS behavior (+ update doc)
# 300123 	Yahya  	Removed the change of command interface and InitKeypad & wait 1s at the end of the proc (see Issue #1819)
# 070624 	Yahya  	Removed 'forced' argument as not used and added check of IL1R / CMDA (see Issue #2301)
#
#END----------------------------------------------------------------
proc MotorStop { {checkStopped 0 } {channel 1} {cmd 0} } {
    TlPrint "---------------------------------------------------------------------------"
    TlPrint " requesting a STOP order"
    TlPrint "---------------------------------------------------------------------------"

    if { $channel == 1} {
	set CurrentCmdChannel [ModTlRead CCC]
	set CmdParam "CMDA"
    } else {
	switch $channel {
	    "TER" {
		set CurrentCmdChannel 1
	    }
	    "MDB" {
		set CurrentCmdChannel 8
		set CmdParam "CMD1"
	    }
	    "LCC" {
		set CurrentCmdChannel 4
	    }
	    "ETH" {
		set CurrentCmdChannel 2048
		set CmdParam "CMD5"
	    }
	    "CAN" { 
		set CurrentCmdChannel 64
		set CmdParam "CMD2"
	    }
	    "NET" - "MODTCP" - "MODTCP_OptionBoard" - "EIP" - "EIP_OptionBoard" { 
		set CurrentCmdChannel 512
		set CmdParam "CMD3"
	    }
	    default {
		TlError "Channel value not supported"
		return -1
	    }
	};# End of switch
    }
    set isKPDActiveChannel [expr {$CurrentCmdChannel == 4 ? 1: 0}]

    if { $CurrentCmdChannel == 1 } {     ;# if Terminal
	setDI 1 L
	doWaitForObject IL1R 0x0000 1 0x0001
	setDI 2 L
	doWaitForObject IL1R 0x0000 1 0x0002
	    
    } elseif { $CurrentCmdChannel == 4 } {   ;# if LCC
	if {[InitKeypad 1]} {  ;#keypad connected
	    keypad_Stop
	}
    } else {   ;# if MDB || NET || CAN || ETH
	TlWrite CMD $cmd
	doWaitForObject $CmdParam $cmd 1
    }

    if { $checkStopped } {
	doWaitForObject LCR 0 [expr ([ModTlRead DEC]*1.2)] 0xffffffff "" 0 $isKPDActiveChannel; #Set the timeout to DEC*1.2 to let the motor decelerate in case of stop mode = D
	doWaitForLoadObjectTol MONC.NACT 0 30 5 "" 1 $isKPDActiveChannel; #Set timeout to 30s to let motor stop in freewheel in case of stop mode = F
    }
    if { $isKPDActiveChannel } {
	InitKeypad 0
    } else {
	doWaitMs 1000
    }
}

# Doxygen Tag:
## Function description : Gives a run order according to the current active command channem
#
# WHEN   | WHO   | WHAT
# -------| ------| -----
# 240521 | ASY   | proc created
# 301222 | Yahya | Added case of RUN via ETH channel
# 170123 | Yahya | Added consideration of CHCF & 2-3Wires control to give Run order
# 101123 | Yahya | Added setDI 1 to high in case of IO profile + command via line channel (see Issue #1386)
# 030124 | Yahya | Removed the command interface change to MODTCP (see Issue #1525)
# 070624 | Yahya | Replaced constant waits by check of IL1R / CMDA (see Issue #2301)
#
#
# \n
# E.g. Use <MotorStart> to give a run order
#
proc MotorStart { } {
    TlPrint "---------------------------------------------------------------------------"
    TlPrint " requesting a RUN order"
    TlPrint "---------------------------------------------------------------------------"
    global ActInterface

    set CHCFProfile [Enum_Name CHCF [ModTlRead CHCF] ]
    set CurrentCmdChannel [ModTlRead CCC]

    if { ![GetDevFeat "OPTIM"] } {
	set 2_3WireProfile "LC3W"
    } else {
	set 2_3WireProfile [Enum_Name TCC [ModTlRead TCC] ]
    }

    if { $CurrentCmdChannel == 1 } {     ;# if Terminal
	switch $2_3WireProfile {
	    "2C" {
		setDI 1 H
		doWaitForObject IL1R 0x0001 1 0x0001
	    }
	    "3C" -
	    "LC3W" {
		setDI 1 H
		doWaitForObject IL1R 0x0001 1 0x0001
		setDI 2 H
		doWaitForObject IL1R 0x0002 1 0x0002
	    }
	    default { TlError "2_3WireProfile Value $2_3WireProfile is not taken into account in this proc" }
	}
    } elseif { $CurrentCmdChannel == 4 } {   ;# if LCC
	if { $2_3WireProfile != "2C" } {
	    setDI 1 H
	    doWaitForObject IL1R 0x0001 1 0x0001
	}

	if {[InitKeypad 1]} {  ;#keypad connected
	    keypad_Run
	}
	    
    } else {   ;# if MDB || NET || CAN || ETH

	if { $2_3WireProfile != "2C" } {
	    setDI 1 H
	    doWaitForObject IL1R 0x0001 1 0x0001
	}
	    
	if { $CHCFProfile == "IO" } {
	    switch $2_3WireProfile {
		"2C" {
		    TlWrite CMD 1
		    doWaitForObject CMDA 1 1
		}
		"3C" -
		"LC3W" {
		    TlWrite CMD 1
		    doWaitForObject CMDA 1 1
		    TlWrite CMD 3
		    doWaitForObject CMDA 3 1
		}
		default { TlError "2_3WireProfile Value $2_3WireProfile is not taken into account in this proc" }
	    }
	} else {
	    TlWrite CMD 6
	    doWaitForObject CMDA 6 1
	    TlWrite CMD 15
	    doWaitForObject CMDA 15 1
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#ATS_FaultReset trys to reset the error following  active channel
#if in TER, FAULT_RESET_INPUT_ID shall be configurated to DI4
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 110621 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_FaultReset {  } {

    if {[expr [TlRead CCC]] == 1} {     ;# if AI1

	TlPrint "---------------------------------------------------------------------------"
	TlPrint " try to reset the error in TER channel"
	TlPrint "---------------------------------------------------------------------------"
	setDI 4 L
	doWaitMs 500
	setDI 4 H

    } elseif {[expr [TlRead CCC]] == 8} {   ;# if MDB
	TlPrint "---------------------------------------------------------------------------"
	TlPrint " try to reset the error in MDB channel"
	TlPrint "---------------------------------------------------------------------------"
	doChangeMask CMD 0x0080 0
	doWaitMs 100
	doChangeMask CMD 0x0080 1

    } elseif {[expr [TlRead CCC]] == 4} {   ;# if LCC
	TlPrint "---------------------------------------------------------------------------"
	TlPrint " try to reset the error in LCC channel"
	TlPrint "---------------------------------------------------------------------------"
	if {[InitKeypad 1]} {  ;#keypad connected
	    keypad_Stop 0

	}

    } else {
	setDI 4 L
	doWaitMs 500
	setDI 4 H
	doChangeMask CMD 0x0080 0
	doWaitMs 100
	doChangeMask CMD 0x0080 1

	if {[InitKeypad 1]} {  ;#keypad connected
	    keypad_Stop

	}

    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check= 0, no check
#check= 1, assign + check
#check= 2,only  check
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
# 050523 ASY      update to assign to low level of input (issue 302)
# 060224 Yahya	  update to use ID from global namespace without need to recall global at the beginning of proc
## E.g. Use < DIAssigne 3  ERROR_INHIBITION_ASSIGNMENT_ID 1> set LI3 to $ERROR_INHIBITION_ASSIGNMENT_ID and check LI3 result
#END----------------------------------------------------------------
proc DIAssigne {DI ID {check 0}} {
    global LI1_ASSIGN LI2_ASSIGN LI3_ASSIGN LI4_ASSIGN
    global LI1L_ASSIGN LI2L_ASSIGN LI3L_ASSIGN LI4L_ASSIGN

    set OK 0
    switch $ID {
	"LIC" {
	    set ID CSCA
	}
	"LIH" {
	    set ID PRHA
	}
	"LIS" {
	    set ID LIS
	}
	"LIT" {
	    set ID RSFT
	}
	"FFSA"  {
	    set ID FFSA
	}
	"CCS"  {
	    set ID LICCS
	}
	"NO"  {
	    set ID NO

	}

	default {
	    set OK 1

	}
    }
    if { $OK == 1 } {
	set IDValue [subst $[subst ::$ID]]
    } else {
	set IDValue $ID
    }
    if { $check != 2 } {
	TlPrint "---------------------------------------------------------------------------"
	TlPrint " set  DI$DI to $ID: $IDValue"
	TlPrint "---------------------------------------------------------------------------"

	switch $DI {
	    1 {
		TlWrite $LI1_ASSIGN .$IDValue

	    }
	    2 {
		TlWrite $LI2_ASSIGN .$IDValue

	    }
	    3 {
		TlWrite $LI3_ASSIGN .$IDValue

	    }
	    4 {
		TlWrite $LI4_ASSIGN .$IDValue

	    }
	    "1L" {
		TlWrite $LI1L_ASSIGN .$IDValue

	    }
	    "2L" {
		TlWrite $LI2L_ASSIGN .$IDValue

	    }
	    "3L" {
		TlWrite $LI3L_ASSIGN .$IDValue

	    }
	    "4L" {
		TlWrite $LI4L_ASSIGN .$IDValue

	    }

	    default {
		TlPrint "-----------------------------------------------------------------"
		TlError "Wrong input DI$DI"
		TlPrint "-----------------------------------------------------------------" }
	}
    }

    if { $check == 1 || $check == 2} {
	TlPrint "---------------------------------------------------------------------------"
	TlPrint " check  DI$DI = $ID: $IDValue"
	TlPrint "---------------------------------------------------------------------------"
	doWaitForObject [subst $[subst LI$DI]_ASSIGN] .$IDValue 2
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#To clear all unexpected harware connection
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 02072021 kaidi    proc created
# 26012024 Yahya    Set the phase inversion contactor to forward direction (Issue #1645)
# 29042024 Yahya    Power off all devices on tower before launching campaign (Issue #2069)
# 04102024 Yahya    Load PLC with default program (with default baudrate) for PACY_ATLAS_CANOPEN tower (Issue #2891)
#END----------------------------------------------------------------
proc  ATS_ClearBeforeNight  {  }  {
    global ActDev
	
    # TlPrint "================= Power off all devices ================="
    # set initial_ActDev $ActDev ;#Store initial value of ActDev
    # for { set i 1 } { $i <= 3 } {incr i} {
	# TlPrint "============== Power off device $i =============="
	# set ActDev $i
	# DeviceOff $ActDev
    # }
    # set ActDev $initial_ActDev ;#Restore initial value of ActDev
	
    # Load PLC with default program (with default baudrate) for PACY_ATLAS_CANOPEN tower
    # if { [GetSysFeat "PACY_ATLAS_CANOPEN"] } {
	# TlPrint "Loading program to PLC..." 
	# PLC::PROCESS::loadProgram $::Wago_IPAddress "PACY_ATLAS_CANOPEN_DEFAULT.stu"
    # }
	
    DeviceOn $ActDev
    # RunPLC
    EthernetNetworkDisconnection L
    LoadOff

    selectAI1PT100Mode L
    selectAI1PTCMode L
    ActiveThermResistor L
    setOCThermResistor L
    setCCThermResistor L

    doSetDefaults 1 0 1
    PhaseInversion L
    doWaitForObject HMIS .RDY 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#To check that whether the targert value can be reached or not before timeout, and it returns OK 1 or NotOk 0, no TlError will be printed
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------
proc doWaitForObjectOk { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0} } {
    global Debug_NERA_Storing
    set Ok 0
    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {
	if { $keypadchannel == 1 } {	
	    InitKeypad 0	
	}
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		# TlError "illegal RxFrame received"
	    }
	    break
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {
	    #TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    set Ok 1
	    break
	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$objekt == "HMIS"} {
		# Error infos for actual sporadic faults in the testcabinet

		if {( $sollWert != 23) && ( $istWert == 23)} {

		    set DP0_Tmp [TlRead "DP0" 1]
		    switch $DP0_Tmp {
			27 {
			    # INF2
			    TlError "*GEDEC00203810* INF2 Fault"
			}
			68 {
			    # INF6
			    #TlError "*GEDEC00203492* INF6 Fault"
			}
			69 {
			    # INFE
			    # TlError "*GEDEC00201702* INFE Fault"
			}
			153 {
			    # INFM
			    # TlError "*GEDEC00203425* INFM Fault"
			}
		    }
		}

	    }

	    #	    if {$noErrPrint} {
	    #		#TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    #	    } else {
	    #		#TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    #	    }
	    #
	    #	    if {$noErrPrint == 0} { ShowStatus }

	    break
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }
    if {$Ok == 1} 	{
	TlPrint "_________________________________________________________________________________________________________________"
	TlPrint "the return value OK is $Ok,the target value 0x%04X (%d$ExpEnum) can be reached by $objekt at $waittime ms" $sollWert $sollWert
	TlPrint "_________________________________________________________________________________________________________________"
    } else {
	TlPrint "_________________________________________________________________________________________________________________"
	TlPrint "the return value OK is $Ok,the target value 0x%04X (%d$ExpEnum) can not be reached by $objekt"  $sollWert $sollWert
	TlPrint "_________________________________________________________________________________________________________________"
    }

    return  $Ok

}

#----------------------------------------------------------------------------------------------------
# warte bis Object < oder > sollwert wird
# objekt:   symbolischer Name, z.B. MONC.PACTUSR
# operator: vergleich zb. ">" oder "<"
# sollWert: gewuenschter Wert der zum Ende fuehrt
# timeout:  sekunden
#
proc doWaitForObjectOp { object operator sollwert timeout {TTId ""}} {
    if {$TTId != "" } { set TTId "*$TTId*" }

    set startZeit [clock clicks -milliseconds]
    while { 1 } {
	if {[CheckBreak]} {break}
	set istwert [doReadObject $object 0]
	set timeDiff [expr [clock clicks -milliseconds] - $startZeit]
	if { [expr $istwert $operator $sollwert] } {
	    TlPrint "doWaitForObjectOp: $object is $operator $sollwert after $timeDiff ms"
	    return 1
	}
	if {$timeDiff >= [expr $timeout * 1000] } {
	    TlError "$TTId doWaitForObjectOp: Timeout, $object is not $operator $sollwert in $timeout s"
	    return 0
	}
    }
}

## Function description : Waits for a parameter to reach a value which is > or < or = to expected value and to remain it for a given time
#
# \param[in] objekt: parameter to read
# \param[in] operator: > < = etc
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
# \param[in] timeLow: duration of the maintain of the value (seconds)
proc doWaitForObjectOpLevelOK { objekt operator sollWert timeout timeLow {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
    global Debug_NERA_Storing
    TlPrint " Wait for object $objekt to reach value $sollWert and $operator it during $timeLow . Max wait $timeout"
    set TTId [Format_TTId $TTId]
    #if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
    # printing!!!!!Timeout: $timeout s"}

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    set startLevel 0
    set Ok 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	#set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
	set istWert [ModTlRead $objekt $noErrPrint $TTId]

	#set istwert [doReadObject $object 0]
	# TlPrint "Monitored parameter : $istWert  || wait time : $waittime"
	if { $istWert == "" } then {
	    set startLevel 0
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
		return 0
	    }

	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objekt $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}
	if {$istWert != ""} {
	    # TlPrint " read :$istWert AO1R: [TlRead AO1R]"
	    if { ![expr $istWert $operator $sollWert] } {
		if {$startLevel} {set startLevel 0}
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  "
	    }
	    if { [expr $istWert $operator $sollWert] } {

		#debut de modif
		if {$startLevel == 0 } {
		    set startLevelTime [clock clicks -milliseconds]
		    set startLevel 1
		}

		set currentTime [clock clicks -milliseconds]
		#TlPrint "Current Time : $currentTime  || Start time : $startLevelTime "
		#TlPrint "Duration [expr $currentTime - $startLevelTime]  || goal : [expr $timeLow * 1000]"
		#TlPrint "Current value of the monitored word : $istWert"
		#TlPrint "Monitored parameter : $istWert  || wait time : $waittime  || lowTime [expr $currentTime - $startLevelTime]"
		if { [expr $currentTime - $startLevelTime] >= [expr $timeLow * 1000]} {

		    set Ok 1
		    TlPrint "Reached, doWaitForObjectOpLevelOK $objekt is $operator $sollWert  waittime (%dms / %d requests)"  $waittime $tryNumber
		    #TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
		    break
		}

	    }
	    if { [expr $waittime > $timeout] } {

		set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

		if {$objekt == "HMIS"} {
		    # Error infos for actual sporadic faults in the testcabinet

		    if {( $sollWert != 23) && ( $istWert == 23)} {

			set DP0_Tmp [TlRead "DP0" 1]
			switch $DP0_Tmp {
			    27 {
				# INF2
				TlError "*GEDEC00203810* INF2 Fault"
			    }
			    68 {
				# INF6
				TlError "*GEDEC00203492* INF6 Fault"
			    }
			    69 {
				# INFE
				TlError "*GEDEC00201702* INFE Fault"
			    }
			    153 {
				# INFM
				TlError "*GEDEC00203425* INFM Fault"
			    }
			}

		    }

		}
		TlPrint "Not Reached, doWaitForObjectOpLevelOK $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		#		if {$noErrPrint} {
		#		    TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		#		} else {
		#		    if { $bitmaske  == 0xffffffff } {
		#			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		#		    } else {
		#			TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		#		    }
		#		}
		#
		#		if {$noErrPrint == 0} { ShowStatus }
		#		return 0
		break
	    }
	}

	incr tryNumber

	if {[CheckBreak]} {break}

    }

    return $Ok
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#  waiting state on load machine
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  281020 cordc   created
#
#END----------------------------------------------------------------
proc LoadWaitForState { State timeout {maske 0x000F} {ErrPrint 1}} {
    global ActDev DevAdr

    TlPrint " Wait for state $State on load device"

    set startTrig [clock seconds]
    set startChange [clock clicks -milliseconds]
    set FaultCode     0
    set CurrState 0
    while {1} {
	set CurrState [LoadRead STD.STATUSWORD 1]  ;# No Error Print
	if { $CurrState != "" } then {
	    set CurrState [expr $CurrState & $maske]
	    if {[regexp {[!<>=]} $State]} {
		if { [expr $CurrState $State] } {
		    TlPrint " state is $State after [expr [clock clicks -milliseconds] - $startChange]ms"
		    break
		}
	    } else {
		if { $CurrState == $State } {
		    TlPrint " state is $State after [expr [clock clicks -milliseconds] - $startChange]ms"
		    break
		}
	    }
	}
	if { $timeout != 0 && [expr [clock seconds] - $startTrig > $timeout] } {
	    set FaultCode [LoadRead STD.STOPFAULT]
	    if { ($FaultCode != "") && ($CurrState != "") } then {
		TlError "state loaddevice will not be $State but stays at $CurrState, STOPFAULT=0x%04X->%s" $FaultCode [GetErrorText $FaultCode]
		if {$ErrPrint == 1} { ShowLoadStatus }
	    } else {
		TlError "No communication from loaddevice"
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $CurrState
} ;# LoadWaitForState

#DOC----------------------------------------------------------------
#DESCRIPTION
#  waiting state freewheel on load machine
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  281020 cordc   created
#
#END----------------------------------------------------------------
proc LoadWaitForStand {{timeout 5} {ErrPrint 1}} {
    global ActDev DevAdr

    set startZeit [clock seconds]
    set fehler     0
    set istZustand 0
    while {1} {
	set istZustand [LoadRead STD.ACTIONWORD 1]  ;# No Error Print
	if { $istZustand != "" } then {
	    set istZustand [expr $istZustand & 0x0040]
	    if { $istZustand == 0x0040 } { break }
	} else {
	    TlError "no Reply from Load"
	    set istZustand 0
	    break
	}
	if { $timeout != 0 && [expr [clock seconds] - $startZeit > $timeout] } {
	    set fehler [ModTlRead STD.STOPFAULT]
	    if { $fehler != "" } then {
		TlError "Load still not in standstill (<9Umin), STOPFAULT=0x%04X->%s" $fehler [GetErrorText $fehler]
		if {$ErrPrint == 1} { ShowLoadStatus }
	    } else {
		TlError "no Reply from Load"
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $istZustand
} ;# LoadWaitForStand

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadWaitForObject {objekt sollWert timeout {bitmaske 0xffffffff} {ErrPrint 1}} {
    global ActDev DevAdr

    set startZeit [clock clicks -milliseconds]

    set fehler     0
    set istWert    0
    while {1} {
	set istWert [LoadRead $objekt 1]
	if { $istWert == "" } then {
	    TlError "keine Rueckmeldung vom Lastgeraet"
	    set istWert 0
	    break
	}
	if [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] {
	    TlPrint "Objekt $objekt ok: Sollwert=Istwert=0x%08X , (%d) , Wartezeit (%dms) " $sollWert $sollWert [expr [clock clicks -milliseconds] - $startZeit ]
	    break
	}
	if { $timeout != 0 && [expr (([clock clicks -milliseconds] - $startZeit) / 1000)  > $timeout] } {
	    TlError "LoadWaitForObject $objekt: Sollwert=0x%08X , (%d) Istwert=0x%08X , (%d)" $sollWert $sollWert $istWert  $istWert
	    if {$ErrPrint == 1} { ShowLoadStatus }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $istWert
} ;# LoadWaitForObject

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadWaitForObjectOp { object operator sollwert timeout {TTId ""} {ErrPrint 1}} {
    set TTId [Format_TTId $TTId]

    set startZeit [clock clicks -milliseconds]
    while { 1 } {
	if {[CheckBreak]} {break}
	set istwert [LoadRead $object 0]
	set timeDiff [expr [clock clicks -milliseconds] - $startZeit]
	if { [expr $istwert $operator $sollwert] } {
	    TlPrint "LoadWaitForObjectOp: $object is $operator $sollwert after $timeDiff ms"
	    return 1
	}
	if {$timeDiff >= [expr $timeout * 1000] } {
	    TlError "$TTId LoadWaitForObjectOp: Timeout, $object is not $operator $sollwert in $timeout s"
	    if {$ErrPrint == 1} { ShowLoadStatus }
	    return 0
	}
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadBlock { } {
    global ActDev DevAdr
    global TimeBlock

    TlPrint ""
    TlPrint "Load device $ActDev: Block on, device Enable"
    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    set TimeBlock [clock clicks -milliseconds]
    TlPrint "Load device PACTUSR: [LoadRead MONC.PACTUSR]"

} ;# LoadBlock

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadUnBlock { {state ""} } {
    global HandMade
    global ActDev DevAdr
    global TimeBlock

    TlPrint ""
    TlPrint "Load device $ActDev: Block off, device disable"

    LoadWrite STD.CTRLWORD 0x01   ;# Disable

    if { $state != ""} {
	LoadWaitForState $state 15
	set TimeBlockStop  [clock clicks -milliseconds]
	set Time$ActDev    [expr abs( $TimeBlockStop - $TimeBlock)]
	TlPrint "Duration of blocking: [subst $[subst Time$ActDev]]ms"

    }

}  ;# LoadUnBlock

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadOn { {State 4} {ErrPrint 1} } {
    global ActDev
    global TimeBlock

    #DEBUG : Added in order to get exclusive control of the load machine. Otherwise impossible to start it
    if {[LoadRead MAND.ACCESSEXCL] != 1} {
	LoadWrite MAND.ACCESSEXCL 1
    }

    set TimeBlock 0
    set LoadDevNr [expr 11]

    TlPrint ""
    TlPrint "Switch on load device $LoadDevNr"

    #    set LoadPort [mb2Open SER 11 5 19200 E 8 1]
    # set LoadPort [mb2Open SER 11 5 19200 E 8 1]
    LoadOnOff "H"          ;#Set device on
    doWaitMs 1000                          ;#to compensate for switch delays
    LoadWrite STD.CTRLWORD      0x08

    switch -regexp $State {
	{[<>=1-9]} {
	    #Waiting for state
	    LoadWaitForState $State 20
	}
	"None" {
	    #ignore state in this case : used for modbus address initialization
	}
	0 -
	default {
	    if {$ErrPrint == 1} { ShowLoadStatus }
	    TlError "Parameter State( $State ) nicht definiert"
	}
    }

    # deactivate commutation monitoring
    LoadWrite DEVICE.SUPCOMM 0

    return $LoadDevNr
} ;# LoadOn

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadOff { {waittime 2000} } {
    global ActDev DevAdr Wago_IPAddress

    set LoadDevNr $DevAdr($ActDev,Load)    ;# this is not a address, its only a nr.

    #DEBUG : Added in order to get exclusive control of the load machine. Otherwise impossible to start it
    if {[LoadRead MAND.ACCESSEXCL] != 0} {
	LoadWrite MAND.ACCESSEXCL 0
    }
    TlPrint ""
    TlPrint "Switch off load device $LoadDevNr"
    LoadOnOff "L"
    doWaitMs  $waittime

    #    mb2Close "MBS01"
    #    #Open ModbusTCP interface to Wago
    #    TlPrint "Open ModBus TCP port $Wago_IPAddress to Wago"
    #    set rc [catch {mb2Open "TCP" $Wago_IPAddress 1} errMsg]
    #    if {$rc != 0} {
    #	TlPrint "Error on ModBusTCP open: $errMsg"
    #	set ModbusTCPsys 0
    #    } else {
    #	TlPrint "ModBus TCP port $Wago_IPAddress is open"
    #	set ModbusTCPsys 1
    #    }
    #
    #    mb2Close "MBS01"
    #    #Open ModbusTCP interface to Wago
    #    TlPrint "Open ModBus TCP port $Wago_IPAddress to Wago"
    #    set rc [catch {mb2Open "TCP" $Wago_IPAddress 1} errMsg]
    #    if {$rc != 0} {
    #	TlPrint "Error on ModBusTCP open: $errMsg"
    #	set ModbusTCPsys 0
    #    } else {
    #	TlPrint "ModBus TCP port $Wago_IPAddress is open"
    #	set ModbusTCPsys 1
    #    }

    return
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadTorque { Target_Torque_Percent {speedLimitation 1500} } {
    global HandMade
    global ActDev DevAdr

    LoadWrite CTRLG.IMAX 2000

    set ContTorque [LoadRead MOTACS.TQU0]

    #limit speed to ensure no damage of Asynchronous motor due to overspeed if load test is failed
    LoadWrite CTRLG.NMAX $speedLimitation

    LoadWrite CTRLG.IMAX 1000

    if { $Target_Torque_Percent != 0 } {
	TlPrint ""
	TlPrint "Load device $ActDev: Torque control with %.1f %%  (%.2f Nm) of Cont. stall torque" [expr $Target_Torque_Percent/10.0] [expr $ContTorque/100.0]
	LoadWrite TRQPRF.TORQTARGET $Target_Torque_Percent
	LoadWrite STD.CTRLWORD      0x02         ;# Enable
	LoadWaitForState 6 5
	LoadWrite TRQPRF.START      1
    } else {
	TlPrint "Load device $ActDev: Torque control off"
	LoadWrite TRQPRF.TORQTARGET 0
	#      ModTlWrite TRQPRF.START      0
	#      doWaitForAckEnd 5
	LoadWrite STD.CTRLWORD      0x08         ;# FaultReset
	LoadWrite STD.CTRLWORD      0x01         ;# Disable
	LoadWaitForState 4 5
    }

};# LoadCurrCtrl

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadVelocity { N_Ref {IMAX 0} { Ramp 6000 } {ErrPrint 1}} {
    global HandMade
    global ActDev DevAdr

    TlPrint ""
    TlPrint "Load device $ActDev: Speed profile with $N_Ref rpm"

    LoadWrite CTRLG.IMAX $IMAX

    if { $N_Ref != "NO" } {

	LoadWrite VELPRF.PRFVELTARGET $N_Ref
	LoadWrite STD.CTRLWORD 0x08          ;# FaultReset

	LoadWrite MOTION.UPRAMP0   $Ramp
	LoadWrite MOTION.DOWNRAMP0 $Ramp
	LoadWrite MOTION.SYMRAMP $Ramp

	if {[LoadRead MOTION.ENASPEEDPROFILE] != 1} {
	    LoadWrite MOTION.ENASPEEDPROFILE 1
	}

	if {([LoadRead STD.STATUSWORD] & 0x000F) != 6} {
	    #        if {$ErrPrint == 1} { ShowLoadStatus }
	    LoadWrite STD.CTRLWORD 0x02          ;# Enable
	    LoadWaitForState 6 5
	    LoadWrite VELPRF.START 1
	}

    } else {
	#      ModTlWrite VELPRF.PRFVELTARGET $N_Ref
	#      ModTlWrite MOTION.UPRAMP0   $Ramp
	#      ModTlWrite MOTION.DOWNRAMP0 $Ramp
	LoadWrite STD.CTRLWORD 0x08          ;# FaultReset
	LoadWrite STD.CTRLWORD 0x01          ;# Disable
	LoadWaitForState 4 5

    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadMoveRel { dist {nref 1000} } {
    global ActDev DevAdr Toleranz_Lage

    TlPrint ""
    TlPrint "Load device $ActDev: Position profile relative with $dist Usr and $nref rpm"

    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    doWaitMs 500
    set PosStart [LoadRead MONC.PACTUSR]
    LoadWrite MOTION.UPRAMP0   2000
    LoadWrite MOTION.DOWNRAMP0 2000
    LoadWrite POSPRF.SPDTARGETUSR  $nref
    LoadWrite POSPRF.STARTRELPREF  $dist

    while {1} {
	if { [CheckBreak] } { break }
	set istZustand [LoadRead STD.STATUSWORD]
	if { $istZustand != "" } then {
	    if { $istZustand & 0xC000 } {
		set result 1
		break
	    }
	} else {
	    set result 0
	    break
	}
    }

    if { $dist < 0} {
	set dir  1
    } else {
	set dir -1
    }
    if { [expr ($PosStart + $dist) ] > $PosStart } {
	LoadWaitForObjectOp MONC.PACTUSR > [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    } else {
	LoadWaitForObjectOp MONC.PACTUSR < [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    }

    TlPrint "Load device PACTUSR: [LoadRead MONC.PACTUSR]"

    return $result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadMoveAbs { dist {nref 1000} } {
    global ActDev DevAdr Toleranz_Lage

    TlPrint ""
    TlPrint "Load device $ActDev: Position profile absolut to $dist Usr with $nref rpm"

    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    set PosStart [LoadRead MONC.PACTUSR]
    LoadWrite MOTION.UPRAMP0   2000
    LoadWrite MOTION.DOWNRAMP0 2000
    LoadWrite POSPRF.SPDTARGETUSR  $nref
    LoadWrite POSPRF.STARTABSPOS  $dist

    # warte auf x_end oder x_err
    while {1} {
	if { [CheckBreak] } { break }
	set istZustand [LoadRead STD.STATUSWORD]
	if { $istZustand != "" } then {
	    if { $istZustand & 0xC000 } {
		set result 1
		break
	    }
	} else {
	    set result 0
	    break
	}
    }

    if { $dist < 0} {
	set dir  1
    } else {
	set dir -1
    }
    if { [expr ($PosStart + $dist) ] > $PosStart } {
	LoadWaitForObjectOp MONC.PACTUSR > [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    } else {
	LoadWaitForObjectOp MONC.PACTUSR < [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    }

    return $result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadStand { timeout {CCId ""} } {
    global ActDev DevAdr
    global AW_NACT_0

    if {$CCId != "" } { set TTId "*$CCId*" }

    set startZeit  [clock clicks -milliseconds]
    set timeout    [expr $timeout * 1000]

    while {1} {
	set istZustand [expr [LoadRead STD.ACTIONWORD]& $AW_NACT_0 ]
	if { $istZustand == $AW_NACT_0 } {
	    TlPrint "Load Device is standstill after %d ms " [expr [clock clicks -milliseconds] - $startZeit]
	    break
	}

	if {[expr [clock clicks -milliseconds] - $startZeit > $timeout] } {
	    TlError "$CCId Load Device is not standstill after $timeout ms"
	    break
	}
	if {[CheckBreak]} {break}
    }

    set ActDev $ActDevCurr

} ;# LoadStand

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadRead { obj {ErrPrint 0} } {
    global ActDev DevAdr

    if {![info exists DevAdr($ActDev,Load)]} {
	TlError "Load not available"
	return ""
    }

    set result [ModTlReadForLoad $obj $ErrPrint]

    if { ($result == "") && ($ErrPrint == 0) } {
	TlError "keine Rueckmeldung vom Lastgeraet"
    }

    return $result

} ;# LoadRead

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadWrite { obj value {ErrPrint 0}} {
    global ActDev DevAdr

    set result [ModTlWriteForLoad $obj $value $ErrPrint]

    return $result

} ;# LoadRead

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
#
#END----------------------------------------------------------------
proc LoadConfig { } {

    # Parameters after AutoTune
    #    LoadWrite CTRL1.KPN         92
    #    LoadWrite CTRL1.TNN       1184
    #    LoadWrite CTRL1.KPP        211
    #    LoadWrite CTRL1.KFPP         0
    #    LoadWrite CTRL1.TAUNREF   1184
    #
    #    LoadWrite CTRLG.POSWIN      10
    #    LoadWrite CTRLG.POSWINTM     0
    #
    #    LoadWrite PARAM.STORE        1
    #    LoadWaitForObject  PARAM.STORE   0 2

} ;# LoadConfig

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Get parameter value from Load drives
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 260115 serio proc created
# 300115 serio replace modbus address
#END------------------------------------------------------------------------------------------------
proc ModTlReadForLoad {objString {NoErrPrint 0} {TTId ""}} {

    global DevAdr ActDev
    global theLXMObjHashtable theLXMVARHashtable
    global theDebugFlagObj errorInfo glb_Error BreakPoint

    set result 0
    set glb_Error 0
    set rc 0

    if { $DevAdr($ActDev,Load) < 10} {

	TlError "Load Device number $DevAdr($ActDev,Load) is smaller than 10"
	return 0
    }

    set TTId [Format_TTId $TTId]

    if [regexp {[0-9]+\.[0-9]+} $objString] {
	# numerical operation, e.g. "11.9"
	set objList [split $objString .]
	set idx [lindex $objList 0]
	set six [lindex $objList 1]

    } else {

	if { [string first "." $objString ] > 0 } {
	    # Conversion of objString through Hashtable in Index/SubIndex
	    if { [catch { set index $theLXMObjHashtable($objString) }]  != 0 } {
		TlError "TCL-Error message: $errorInfo : Objekt: $objString"
		return 0
	    }
	} else {
	    # Conversion of objString through Hashtable in Index/SubIndex
	    if { [catch { set index $theLXMVARHashtable($objString) }]  != 0 } {
		TlError "TCL-Error message: $errorInfo : Objekt: $objString"
		return 0
	    }
	}
	set idx [lindex [split $index .] 0]
	set six [lindex [split $index .] 1]

	# Conversion in MOD-Bus-Index
	# Special handling of big Index-values
	if { $idx >= 128 } {
	    # Use Peek and Poke Parameter 22.10
	    set ParaValue [expr ($six * 65536) + $idx]
	    set LogAdr [expr (22 * 256) + (10 * 2)]
	    set rc [catch { set result [mb2WriteObj  $DevAdr($ActDev,Load) $LogAdr $ParaValue] }]
	    if {$rc != 0} {
		set result ""

		# Carry only first line
		set i [string first "\n" $errorInfo]
		if {$i != -1} {
		    incr i -1
		    set errorInfo [string range $errorInfo 0 $i]
		}
		TlError "TCL-Error at Poke access with Index >= 128 : $errorInfo : Object: $objString"
	    }
	    # Reproduction on Poke-Function
	    set LogAdr [expr (22 * 256) + (11 * 2)]
	} else {
	    set LogAdr [expr ($idx * 256) + ($six * 2)]
	}
	#Read command only for load devices
	# Usage: mbReadObj [DevAdr] [LogAdr] [AnzLogAdr]
	set rc [catch { set result [mb2ReadObj $DevAdr($ActDev,Load) $LogAdr 2] }]

    }

    #Check reception of message
    if {$rc != 0} {
	if {$result == "" } {
	    if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint) } {
		TlPrint "No answer from Modbus interface"
		puts \a\a\a\a
		if {[bp "Debugger"]} {
		    return 0
		}
	    }
	} else {
	    set result ""
	}

	# Carry only first line
	set i [string first "\n" $errorInfo]
	if {$i != -1} {
	    incr i -1
	    set errorInfo [string range $errorInfo 0 $i]
	}
	if { $NoErrPrint == 0 } {
	    set StartTime [clock clicks -milliseconds]
	    TlError "$TTId TCL-Error (mbReadObj): $errorInfo : Object: $objString Addr: $DevAdr($ActDev,Load)"

	    if {$BreakPoint} {
		if { $errorInfo == "ERRDLL: got no response  65535"} {
		    # Breakpoint for Modbus problem
		    TlPrint "No answer from Modbus interface"
		    puts \a\a\a\a
		    if {[bp "Debugger"]} {
			return 0
		    }
		}
	    } else {
		if { $errorInfo == "ERRDLL: got no response  65535"} {
		    for { set ic 2 } { $ic<4 } { incr ic } {
			if {[CheckBreak]} {
			    return 0
			}
			set errorInfo ""
			set rc [catch { set result [mb2ReadObj $DevAdr($ActDev,Load) $LogAdr 2] }]
			set StopTime [clock clicks -milliseconds]
			# Carry only first line
			set i [string first "\n" $errorInfo]
			if {$i != -1} {
			    incr i -1
			    set errorInfo [string range $errorInfo 0 $i]
			}
			puts \a
			TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
			if { $errorInfo != "ERRDLL: got no response  65535"} {
			    TlPrint "Error message No.: $ic $errorInfo"
			    break ;# Answer received further in text
			}
		    }
		}
	    }
	}
    }

    if {$theDebugFlagObj} {
	set emptyList {}
	TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,Load) 0x[format "%04X" $LogAdr]"  emptyList
    }
    if {$result == ""} {
	set glb_Error 1
    }

    return $result

}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Set parameter value for Load drives
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 260115 serio proc created
# 300115 serio replace modbus address
#END------------------------------------------------------------------------------------------------
proc ModTlWriteForLoad { objString value {NoErrPrint 0} {TTId ""}} {

    global DevAdr  ActDev
    global theLXMObjHashtable theLXMVARHashtable
    global theDebugFlagObj errorInfo glb_Error BreakPoint

    set TTId [Format_TTId $TTId]

    if { $DevAdr($ActDev,Load) < 10} {

	TlError "Load Device number $DevAdr($ActDev,Load) is smaller than 10"
	return 0
    }

    set glb_Error 0
    set result 0
    set idx 0

    if [regexp {[0-9]+\.[0-9]+} $objString] {
	# numerical operation, e.g. "11.9"
	set objList [split $objString .]
	set idx [lindex $objList 0]
	set six [lindex $objList 1]
    } else {

	# "commands Servo3"
	if { [string first "." $objString ] > 0 } {
	    # Conversion of objString through Hashtable in Index/SubIndex
	    if { [catch { set index $theLXMObjHashtable($objString) }]  != 0 } {
		TlError "TCL-Error message: $errorInfo : Object: $objString"
		return 0
	    }
	} else {
	    # Conversion of objString through Hashtable in Index/SubIndex
	    if { [catch { set index $theLXMVARHashtable($objString) }]  != 0 } {
		TlError "TCL-Error message: $errorInfo : Object: $objString"
		return 0
	    }
	}

	# Convert Hex values to decimal values
	if {[string range $value 0 1] == "0x"} {
	    set value [expr $value]
	}

	set idx [lindex [split $index .] 0]
	set six [lindex [split $index .] 1]

    }

    # Conversion in MOD-Bus-Index
    # Special handling of Index-values

    if {($idx >= 128)} {
	# Use Peek and Poke Parameter 22.10
	set ParaValue [expr ($six * 65536) + $idx]
	set LogAdr [expr (22 * 256) + (10 * 2)]
	set rc [catch { set result [mb2WriteObj  $DevAdr($ActDev,Load) $LogAdr $ParaValue] }]
	if {$rc != 0} {
	    set result ""

	    # Carry only first line
	    set i [string first "\n" $errorInfo]
	    if {$i != -1} {
		incr i -1
		set errorInfo [string range $errorInfo 0 $i]
	    }
	    TlError "TCL-Error at Poke access with Index >= 128 : $errorInfo : Object: $objString"
	}
	# Reproduction on Poke-function
	set LogAdr [expr (22 * 256) + (11 * 2)]
    } else {
	set LogAdr [expr ($idx * 256) + ($six * 2)]
    }

    set rc [catch { set result [mb2WriteObj   $DevAdr($ActDev,Load) $LogAdr $value] }]

    TlPrint "TlWrite (MDB #%d) %s=0x%04X (%d)" $DevAdr($ActDev,Load) $objString $value $value

    if {$rc != 0} {

	if {$result == "" } {
	    if {$BreakPoint } {
		# Breakpoint for Modbus problem
		TlPrint "No answer from Mod-Bus"
		puts \a\a\a\a
		if {[bp "Debugger"]} {
		    return 0
		}
	    }
	} else {
	    set result ""
	}
	set glb_Error 1
	# Carry only first line
	set i [string first "\n" $errorInfo]
	if {$i != -1} {
	    incr i -1
	    set errorInfo [string range $errorInfo 0 $i]
	}
	if { $NoErrPrint == 0 } {
	    set StartTime [clock clicks -milliseconds]
	    TlError "$TTId TCL-Error (mbWriteObj) : $errorInfo : Object: $objString"
	    if {$BreakPoint && ($ActDev == 1)} {
		if { $errorInfo == "ERRDLL:no response received  65535"} {
		    # Breakpoint for Modbus problem
		    TlPrint "no answer from Mod-Bus"
		    puts \a\a\a\a
		    if {[bp "Debugger"]} {
			return 0
		    }
		}
	    } else {
		if { $errorInfo == "ERRDLL:no response received  65535"} {
		    for { set ic 2 } { $ic<4 } { incr ic } {
			if {[CheckBreak]} {
			    return 0
			}
			set errorInfo ""
			set rc [catch { set result [mb2WriteObj   $ActDev $LogAdr $value] }]
			set StopTime [clock clicks -milliseconds]
			# Carry only first line
			set i [string first "\n" $errorInfo]
			if {$i != -1} {
			    incr i -1
			    set errorInfo [string range $errorInfo 0 $i]
			}
			puts \a
			TlPrint "Repeat for mbWriteObj Nr.: $ic for [expr $StopTime - $StartTime] ms"
			if { $errorInfo != "ERRDLL:no response received  65535"} {
			    TlPrint "Error message Nr.: $ic $errorInfo"
			    break ;# Answer received further in text
			}
		    }
		}
	    }
	}
	set CodeList [split [lindex $errorInfo 0] ":"]
	set result [lindex $CodeList 1]

    }

    # $theDebugFlagObj
    if {$theDebugFlagObj} {
	set emptyList {}
	TlPrintIntern D "  +++++  wr [format "%-20s" $objString] - mbWriteObj  $DevAdr($ActDev,Load) 0x[format "%04X" $LogAdr] 0x[format "%08X" $value] ($value)"  emptyList
    }

    return $result

}

# Doxygen Tag:
##Function description : Get the version and checksum informations from text version file
#Calling this proc with build arg set to 1, it will load information from
#build folder. Default behavior without arg still load informations from objektDB
#
# ## History :
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 011220 ASY      proc created 
# 120723 Yahya    updated proc to take into consideration DUT for getting version number (Issue #1020)
# 082923 EDM	  Added parameters to load
#
# \param[in] build : set this parameter to 1 to getVersion from build folder
# \param[in] version: version number
# \param[in] firmwareType: type of the fw (CS/ES)
# \param[in] buildFolder: path of the build folder
# \n
#E.g For OPTIM_version_ES_V9.4IE07_B01: version -> V9.4IE07_B01; firmwareType -> ES;

proc getVersionsInformation {{build 0} {version ""} {firmwareType ""} {buildFolder ""}} {
    global lname lversion lchecksum theObjektDBPath
    global DevType ActDev
    
    set DriveType [ string toupper  $DevType($ActDev,Type)   ] 
    set versionFileName "version_$DriveType.txt"
    if { $build == 1} {
	if {[GetDevFeat "OPTIM"]} {
		set file [open $buildFolder/OPTIM_version_${firmwareType}_$version.txt]
	} elseif {[GetDevFeat "BASIC"]} {
		set file [open $buildFolder/BASIC_version_${firmwareType}_$version.txt]
	} elseif {[GetDevFeat "ATS48P"]} {
		set file [open $buildFolder/$DevType($ActDev,Type)_version_${firmwareType}_$version.txt]
	}
    } else {
    	set file [open $theObjektDBPath/$versionFileName]
    }
    set ldata {}
    set lname {}
    set lversion {}
    set lchecksum {}
    #get the data and delete whitespace
    while { [gets $file data] >= 0 } {
	set dat2 [regexp -all -inline {\S+} $data]
	lappend ldata $dat2
    }

    close $file
	
    #put the data in the proper lists
    foreach ele $ldata {
	set data [split $ele " "]
	lappend lname [lindex $data 0]
	lappend lversion [lindex $data 1]
	lappend lchecksum [lindex $data 2]
    }
}


#-------------------------------------------------------------------------------
# Check different versions of internal modules and option board modules for ATLAS ATS480
#-------------------------------------------------------------------------------
proc checkVersionAtlas {} {
    global lname lversion lchecksum

    TlPrint "--------------------------------------------------------"
    TlPrint "checkVersionAtlas {} - Check versions of device and option board modules"
    TlPrint ""
    TlPrint "Check internal cards versions"
    TlPrint "*************************************************************"

    checkObject C1SV [getVersionFromString $Application] "" "Application (M3) version:"        0
    checkObject C1SB [getBuildFromString $Application]   "" "Application (M3)build:"          0
    checkObject C2SV [getVersionFromString $PowerCPU]    "" "Motor (CpuPower) version:"              0
    checkObject C2SB [getBuildFromString $PowerCPU]      "" "Motor (CpuPower) build:"                0
    # no check for Bootloader version.
    # Bootloader is provided together with Application
    # If the Application is correct, the bootloader should also be OK
    # Furthermore the Bootloader Version is not mentioned in the Releasenotes
    TlPrint "Boot version: [format 0x%04X [ModTlRead C3SV]]"
    TlPrint "Boot build: [format 0x%04X [ModTlRead C3SB]]"
    checkObject C4SV [getVersionFromString $DSP] "" "DSP (C28) version:"                0
    checkObject C4SB [getBuildFromString $DSP]   "" "DSP (C28) build:"                  0
    checkObject C5SV [getVersionFromString $CPLD] "" "CPLD version:"               0
    checkObject C5SB [getBuildFromString $CPLD]   "" "CPLD build:"                 0

    checkObject C6SV [getVersionFromString $EthBasic] "" "Ethernet basic version:"     0
    checkObject C6SB [getBuildFromString $EthBasic]   "" "Ethernet basic build:"       0

    TlPrint "-end----------------------------------------------------"

};#checkVersionNera


#DESCRIPTION
#Extract the Version and build number for ATLAS
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 011220 ASY      proc created 
# 120723 Yahya    updated proc to take into consideration getting version number of EthEmb/SafetyMicro/kpdEmb (Issue #1022)
# 311023 Yahya    safety micro version entry changed from "SafetyMicro" to "SafetyMicroApp"
# 031123 Yahya    Added entry for SafetyMicroBoot
# 260124 Yahya    Added entries "KpdEmb_ST75263" & "KpdEmb_NT7534" for ATS430 embedded keypad (Issue #1553)
#END----------------------------------------------------------------
proc getVersionAtlas {Card} {
    global lname lversion lchecksum
    switch $Card {
	"Power" {set index [lsearch $lname "Dsp"]}
	"Ctrl" {set index [lsearch $lname "Cortex"]}
	"Fsb" {set index [lsearch $lname "Fsb"]}
	"Ssb" {set index [lsearch $lname "Ssb"]}
	"Boot" {set index [lsearch $lname "Boot"]}
	"EthEmb" {set index [lsearch $lname "EthEmb"]}
	"KpdEmb_ST75263" {set index [lsearch $lname "KpdEmb_ST75263"]}
	"KpdEmb_NT7534" {set index [lsearch $lname "KpdEmb_NT7534"]}
	"SafetyMicroApp" {set index [lsearch $lname "SafetyMicroApp"]}
	"SafetyMicroBoot" {set index [lsearch $lname "SafetyMicroBoot"]}
	default { 
		TlError "Card $Card is not taken into account in getVersionAtlas" 
		return 0xFFFF
	}
    }

    set String [lindex $lversion $index]
	
    if { $index == -1 || $String == "" } { 
	TlError "No version number found corresponding to $Card" 
	return 0xFFFF
    }

    # example: V0.3IE05_B37_b00
    # for version only characters until first _ are needed
    set String [lindex [split $String "_"] 0]
    # remove "A" at the beginning
    if {[string first "V" $String] == 0} {
	set String [string range $String 1 end]
    }
    # split in version (V) and evolution (IE)
    set String [split $String "I"]
    set V [lindex $String 0]
    set IE [lindex $String 1]
    # remove dot
    set V [string replace $V 1 1]
    # remove "E"
    set IE [string range $IE 1 end]

    set result "0x$V$IE"

    if {[string is integer $result]} {
	return $result
    } else {
	return 0xFFFF
    }

}

#---------------------------------------------------------------------------------
# Extract Keypad firmware package Umas Version for ATLAS
#---------------------------------------------------------------------------------
proc getUmasVersionAtlas { } {
    global lname lversion

    set index [lsearch $lname "Labels"]
    set String [lindex $lversion $index]

    # example: V01.29
    # remove "V" at the beginning
    if {[string first "V" $String] == 0} {
	set String [string range $String 1 end]
    }
    # remove dot
    set V [string map {"." ""} $String]
    set result "0x$V"

    if {[string is integer $result]} {
	return $result
    } else {
	return 0xFFFF
    }
}


#DESCRIPTION
#Extract the checksum  for ATLAS
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 011220 ASY      proc created 
# 120723 Yahya    updated proc to take into consideration getting checksum of EthEmb/SafetyMicro/kpdEmb (Issue #1022)
# 311023 Yahya    safety micro version entry changed from "SafetyMicro" to "SafetyMicroApp"
# 031123 Yahya    Added entry for SafetyMicroBoot
# 260124 Yahya    Added entries "KpdEmb_ST75263" & "KpdEmb_NT7534" for ATS430 embedded keypad (Issue #1553)
#END----------------------------------------------------------------
proc getChecksumAtlas {Card} {
    global lname lchecksum
    switch $Card {
	"Power" {set index [lsearch $lname "Dsp"]}
	"Ctrl" {set index [lsearch $lname "Cortex"]}
	"Fsb" {set index [lsearch $lname "Fsb"]}
	"Ssb" {set index [lsearch $lname "Ssb"]}
	"Boot" {set index [lsearch $lname "Boot"]}
	"EthEmb" {set index [lsearch $lname "EthEmb"]}
	"KpdEmb_ST75263" {set index [lsearch $lname "KpdEmb_ST75263"]}
	"KpdEmb_NT7534" {set index [lsearch $lname "KpdEmb_NT7534"]}
	"SafetyMicroApp" {set index [lsearch $lname "SafetyMicroApp"]}
	"SafetyMicroBoot" {set index [lsearch $lname "SafetyMicroBoot"]}
	default { 
	    TlError "Card $Card is not taken into account in getChecksumAtlas" 
	    return 0xFFFF
	}
    }
	
    set String [lindex $lchecksum $index]

    if { $index == -1 || $String == "" } { 
	TlError "No checksum found corresponding to $Card" 
	return 0xFFFF
    }
    
    puts [regexp -all -inline 0x\[a-fA-F0-9\]+ [lindex $lchecksum $index]]

    set result [regexp -all -inline 0x\[a-fA-F0-9\]+ [lindex $lchecksum $index]]
    if {[string is integer $result]} {
	return $result
    } else {
	return 0xFFFF
    }

}

#---------------------------------------------------------------------------------
# converts a 2Bytes value to 2ASCII char
#---------------------------------------------------------------------------------
proc convertToChar { value } {
    #convert from dec to hex
    set temp [format %X $value]
    #convert each character
    set char0 [string range $temp 0 1]
    set char1 [string range $temp 2 3]
    if { $char0 != 00} {
	scan $char0 %x char0
	set char0 [binary format c* $char0]
    } else { set char0 "" }
    if {$char1 != 00} {
	scan $char1 %x char1
	set char1 [binary format c* $char1]
    } else { set char1 ""}
    #	TlPrint $char0$char1
    return $char0$char1
}

# end of file

#---------------------------------------------------------------------------------
# Return a list contain the right modifiable(never/always/gatingOff) type parameters
#---------------------------------------------------------------------------------
proc ParametersSelection_Modifiable { type } {
    global theNERAParaIndexRecord theATVParaIndexTable theNERAParaModifiableRecord
    set n 0
    #get fom .xml
    set IndexList [array names theNERAParaIndexRecord]

    #    TlPrint " IndexList is $IndexList \n"

    set SortedIndexList [lsort -integer -increasing $IndexList]
    #set list_never ""   ;#monitoring parameter
    #set list_always ""   ;# setting parameter
    #set list_gatingOff "" ;# configuration parameter
    set list ""
    for {set i 0} { $i < [llength $SortedIndexList] } { incr i } {
	################# new function  Param_Modifiable added in cmd_tower.tcl
	if {$type == [Param_Modifiable [ Param_Name [lindex $SortedIndexList $i] ]]} {
	    #TlPrint " [ Param_Name [lindex $SortedIndexList $i] ] is  $type \n "
	    set n [expr $n + 1 ]
	    lappend  list [ Param_Name [lindex $SortedIndexList $i] ]

	}
    }
    TlPrint "we have $n $type parameters"
    #TlPrint " list is  $list"
    return $list

}

proc test {  } {
    foreach para  [ParametersSelection_Modifiable never] {
	TlPrint " para is $para \n"
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to get the status displayed on the upper left corner of the advanced keypad
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210118 ASY    proc created

#---------------------------------------------------------------------------------
# Proc to get the status displayed on the upper left corner of the advanced keypad
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Connects to the virtual keypad and returns the status displayed on the upper-left corner of the screen
# E.g. use < set res [readKeypadStatus] > to get the current state of the keypad and the drive

proc readKeypadStatus { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 0
    doWaitMs 300
    keypad_Home
    doWaitMs 300
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    TlPrint $temp
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 2]

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to get the command channel displayed on the upper right corner of the advanced keypad
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 010221 KAIDI    proc created

#---------------------------------------------------------------------------------
# Proc to get the command channel displayed on the upper right corner of the advanced keypad
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Connects to the virtual keypad and returns the status displayed on the upper-right corner of the screen
# E.g. use < set res [readKeypadCmd] > to get the current command channel of the drive

proc readKeypadCmd { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 1
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 5]

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to get the RTC displayed on the upper right corner of the advanced keypad
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 010221 KAIDI    proc created

#---------------------------------------------------------------------------------
# Proc to get the RTC displayed on the upper right corner of the advanced keypad
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Connects to the virtual keypad and returns the RTC displayed on the upper-right corner of the screen
# E.g. use < set res [readKeypadCmd] > to get the current command channel of the drive

proc readKeypadRTC { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 1
    doWaitMs 300
    keypad_Home
    doWaitMs 300
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    TlPrint "--------------"
    TlPrint "temp is $temp"
    TlPrint "--------------"
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 8]

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to set the IP parameters of the ethernet communication card
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210125 ASY    proc created
#---------------------------------------------------------------------------------
# Proc to set the IP parameters of the ethernet communication card
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Sete the IP parameters of the ethernet communication card (Mode, @, NetMask, Gateway)
# E.g. use < setIPParameters > to set the ethernet parameters of the option card.
# ##Restart needed !
proc setIPParameters { {interface DefaultIPAddr} } {
    global ActDev DevAdr
    set rc [catch { writeIpAdv $DevAdr($ActDev,$interface) 255.255.255.0 192.168.100.200 1}]
    puts $rc
    if {$rc == 0} {
	doStoreEEPROM
	DeviceOff $ActDev
	DeviceOn $ActDev
	doWaitForObjectLevel EEPS 0 90 5 0xFFFF "" 1
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to set the IP parameters of the embedded ethernet communication card
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 240416 YGH    proc created
#---------------------------------------------------------------------------------
# Proc to set the IP parameters of the embedded ethernet communication card
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Sete the IP parameters of the embedded ethernet communication card (Mode, @, NetMask, Gateway)
# E.g. use < setIPParameters_emb > to set the embedded ethernet parameters.
# ##Restart needed !
proc setIPParameters_emb { {interface DefaultIPAddr_emb} } {
    global ActDev DevAdr
    set rc [catch { writeIpBas $DevAdr($ActDev,$interface) 255.255.255.0 192.168.100.200 1}]
    puts $rc
    if {$rc == 0} {
	doStoreEEPROM
	doWaitForObjectLevel EEPS 0 90 5 0xFFFF "" 1
	DeviceOff $ActDev
	DeviceOn $ActDev
	doWaitForObjectLevel EEPS 0 90 5 0xFFFF "" 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to check the IP parameters of the ethernet communication card
#
# ----------HISTORY----------
# WHEN    WHO      WHAT
# 220210  YGH      proc created
#---------------------------------------------------------------------------------
# Proc to set the IP parameters of the ethernet communication card
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Check the IP parameters of the ethernet communication card (Mode, @, NetMask, Gateway)
# \param[in] Mode: IP Mode (DHCP/MANU/BOOTP)
# \param[in] IP: IP address
# \param[in] Mask: NetMask
# \param[in] Gate: Gateway
# E.g. use < checkIPParameters "MANU" 192.168.100.30 255.255.255.0 192.168.100.200 > to check the ethernet parameters of the option card.
proc checkIPParameters { Mode IP Mask Gate { TTId "" } } {
    global ActDev DevAdr

    set IP [split $IP "."]
    set Mask [split $Mask "."]
    set Gate [split $Gate "."]

    #Check Mode
    doWaitForModObject IM10 .$Mode 1 0xffffffff $TTId

    #Check IP address
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IC1${i} [lindex $IP [expr $i - 1] ] 1 0xffffffff $TTId
    }

    #Check Mask
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IM1${i} [lindex $Mask [expr $i - 1] ] 1 0xffffffff $TTId
    }

    #Check Gateway
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IG1${i} [lindex $Gate [expr $i - 1] ] 1 0xffffffff $TTId
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to check the IP parameters of the embedded ethernet communication card
#
# ----------HISTORY----------
# WHEN    WHO      WHAT
# 220210  YGH      proc created
#---------------------------------------------------------------------------------
# Proc to set the IP parameters of the embedded ethernet communication card
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Check the IP parameters of the embedded ethernet communication card (Mode, @, NetMask, Gateway)
# \param[in] Mode: IP Mode (DHCP/MANU/BOOTP)
# \param[in] IP: IP address
# \param[in] Mask: NetMask
# \param[in] Gate: Gateway
# E.g. use < checkIPParameters_emb "MANU" 192.168.100.30 255.255.255.0 192.168.100.200 > to check the embedded ethernet communication card.
proc checkIPParameters_emb { Mode IP Mask Gate { TTId "" } } {
    global ActDev DevAdr

    set IP [split $IP "."]
    set Mask [split $Mask "."]
    set Gate [split $Gate "."]

    #Check Mode
    doWaitForModObject IM00 .$Mode 1 0xffffffff $TTId

    #Check IP address
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IC0${i} [lindex $IP [expr $i - 1] ] 1 0xffffffff $TTId
    }

    #Check Mask
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IM0${i} [lindex $Mask [expr $i - 1] ] 1 0xffffffff $TTId
    }

    #Check Gateway
    for {set i 1} {$i <= 4} {incr i} {
	doWaitForModObject IG0${i} [lindex $Gate [expr $i - 1] ] 1 0xffffffff $TTId
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# get the last fault recorded time in "User:/Drive/Log/FaultHistory.csv" file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 010221 kaidi    proc created
# 110724 Yahya    proc updated to ATS490/ATS430 for "GetTime" part (see Issue #2453)

#END----------------------------------------------------------------
proc FileManagerGetFaultHistory  { {GetTime 0} {Print 0} {Trys 10} } {
    FileManagerOpenSession
    set  FilePath "User:/Drive/Log/FaultHistory.csv"
    TlPrint "Get File '$FilePath'"

    set result [FileManagerOpen $FilePath 0 0]

    if {$result != 0} {

	set FileID [lindex $result 0]
	set MaxNumberOfLines 1024
	set ReceiveBuffer ""
	set Try 1

	for {set i 0} {$i <= $MaxNumberOfLines} {incr i} {
	    set data [FileManagerRead $FileID 0]
	    set Line [lindex $data 1]

	    if {$Line != ""} {
		lappend ReceiveBuffer $Line
	    } else {
		if {( $ReceiveBuffer == "" ) && ( $Try <= $Trys)} {
		    TlPrint "Try number $Try did not succeed, wait and try again"
		    incr Try
		    doWaitMs 1000
		} else {
		    break
		}
	    }
	}

	FileManagerClose $FileID 0

    } else {
	TlError "FileManagerGetFile failed"
	return 0
    }

    set ReceiveBuffer [join $ReceiveBuffer ""]
    set linesFromFaultHistoryFile [split [HexToString $ReceiveBuffer] "\n"]

    if {$Print} {
	TlPrint ""
	TlPrint "File content of '$FilePath':"
	TlPrint "--------------------------------------------------------"
	foreach Line $linesFromFaultHistoryFile {
	    TlPrint $Line
	}
	TlPrint "--------------------------------------------------------"
    }

    if { $GetTime ==1 }  {
	set lastFaultLine ""
	foreach Line $linesFromFaultHistoryFile {
	    if { [GetDevFeat "OPTIM"] || [GetDevFeat "BASIC"] } {
		if {[string match "LAST FAULT*" $Line]} {
		    set lastFaultLine $Line
		    break
		}
	    } else {
		if {[string match "CURRENT FAULT*" $Line]} {
		    set lastFaultLine $Line
		    break
		} 
	    }
	}
	if { $lastFaultLine == "" } {
	    TlError "No line found corresponding to last fault in fault history file"
	    return
	}

	set Time [lindex [split $lastFaultLine ";"] 2] ;#Extract Date & Time from lastFaultLine

	return $Time
    } else {
	return $ReceiveBuffer
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# get the warning EventID recorded in the "User:/Drive/Log/AlarmHistory.csv" file
#return a  warning EventID list ,the first ID is the most recent warning
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 010221 kaidi    proc created

proc FileManagerGetWarningHistory {  {GetTime 0} {Print 1} {Trys 10} } {

    #Change interface to modbus to be able to use file manager functions
    #save current interface to restore it at the end
    set currentCmdInterface [doGetCmdInterface]
    doSetCmdInterface "MOD"

    FileManagerOpenSession
    set  FilePath "User:/Drive/Log/AlarmHistory.csv"
    TlPrint "Get File '$FilePath'"

    set result [FileManagerOpen $FilePath 0 0]

    if {$result != 0} {

	set FileID [lindex $result 0]
	set MaxNumberOfLines 1024
	set ReceiveBuffer ""
	set Try 1

	for {set i 0} {$i <= $MaxNumberOfLines} {incr i} {
	    set data [FileManagerRead $FileID 0]
	    set Line [lindex $data 1]

	    if {$Line != ""} {
		lappend ReceiveBuffer $Line
	    } else {
		if {( $ReceiveBuffer == "" ) && ( $Try <= $Trys)} {
		    TlPrint "Try number $Try did not succeed, wait and try again"
		    incr Try
		    doWaitMs 1000
		} else {
		    break
		}
	    }
	}

	FileManagerClose $FileID 0

    } else {
	TlError "FileManagerGetFile failed"
	return 0
    }
    # TlPrint "ReceiveBuffer is $ReceiveBuffer"
    set ReceiveBuffer [join $ReceiveBuffer ""]   ;#converts a Tcl list into a string
    #TlPrint "ReceiveBuffer is $ReceiveBuffer"

    set warningHistoryList ""
    set warningHistoryTimeList ""
    if {$Print} {
	set PrintBuffer [split [HexToString $ReceiveBuffer] "\n"]
	set PrintBuffer1 [HexToString $ReceiveBuffer]
	TlPrint ""
	TlPrint "File content of '$FilePath':"
	TlPrint "--------------------------------------------------------"
	foreach Line $PrintBuffer {
	    TlPrint $Line
	    set wordList [split $Line ";"]
	    if {[llength $wordList] >=3 }  {

		set ALARM [lindex $wordList 0]
		set  AlarmID [lindex $wordList 1]
		set Date [lindex $wordList 2]
		#		TlPrint "wordList 0: $ALARM"
		#		TlPrint "wordList 1: $AlarmID"
		#		TlPrint "wordList 2: $Date"
		lappend warningHistoryList $AlarmID  ;# the first is the most recent warning
		lappend warningHistoryTimeList $Date
	    }

	}
	TlPrint "--------------------------------------------------------"
    }

    TlPrint "ReceiveBuffer is $ReceiveBuffer"
    #TlPrint "PrintBuffer is $PrintBuffer"
    #TlPrint "PrintBuffer1 is $PrintBuffer1"

    #restore command interface before return
    doSetCmdInterface $currentCmdInterface

    TlPrint "warningHistoryList is  $warningHistoryList"
    TlPrint "warningHistoryList length is [llength $warningHistoryList]"
    if {   $GetTime ==0 }  {
	return $warningHistoryList
    } else {
	return $warningHistoryTimeList
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#Read from CSV file UnifiedMapping_Synthesis.csv, and save data in global table ATSUnifiedMapping_Table
#This file makes the link, for some ATS parameters, between old mapping address (as it was in ATS48) and 
#the new mapping address (as it is in ATS480 / ATS490 / ATS430)
#
# IMPORTANT NOTE : 
# Design team delivers an Excel file (UnifiedMapping_Synthesis.xlsx)
# This file is then converted to CSV manually (open the Excel file with Excel application, 
# then save it as CSV file without doing any modification on it)
# The output CSV file is the one used here to get data from
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 kaidi    proc created
# 290324 Yahya	  Changed data source file from Excel to CSV (see Issue #1282)
#
#END----------------------------------------------------------------
proc ReadUnifiedMapping_ATS {} {
    global mainpath ATSUnifiedMapping_Table

    # Set the path to your CSV file.
    set csvFilePath $mainpath/ObjektDB/UnifiedMapping_Synthesis.csv

    set csvData [getDataFromCSVConvertedFromExcel $csvFilePath 1 1]

    set rowCount 4 ;#Row at which the data we want to read starts
    set end 0

    while { $end == 0 } {
	set data ""
	set CodeATS48 [getCellValue $csvData $rowCount C]

	if {  $CodeATS48 == ""  } {
	    set end 1
	    continue
	}

	set AddressATS48 [getCellValue $csvData $rowCount D]
	set CodeATS480_Compa  [getCellValue $csvData $rowCount E]
	set AddressATS480_Compa [getCellValue $csvData $rowCount F]

	set AddressATS48Length [ llength $AddressATS48 ]
	if {  $AddressATS48Length != 1  } {
	    set AddressATS48  [ lindex $AddressATS48 0  ]

	    if {  $CodeATS480_Compa == "EMPTY_FIELD"  } {
		set AddressATS480_Compa "EMPTY_FIELD"
	    } else {
		set CodeATS480_Compa [ lindex $CodeATS480_Compa 0  ]
		set AddressATS480_Compa  [ lindex $AddressATS480_Compa 0  ]
	    }
	}

	set CodeATS480 [getCellValue $csvData $rowCount G]

	set AddressATS480 [getCellValue $csvData $rowCount H]

	set AddressATS48  [expr int($AddressATS48)]
	if {  $CodeATS480_Compa != "EMPTY_FIELD"  } {
	    set AddressATS480_Compa [expr int($AddressATS480_Compa)]
	}
	set AddressATS480 [expr int($AddressATS480)]

	lappend data  $AddressATS48
	lappend data  $CodeATS480_Compa
	lappend data  $AddressATS480_Compa
	lappend data  $CodeATS480
	lappend data  $AddressATS480
	#set table
	set ATSUnifiedMapping_Table($CodeATS48) $data

	incr rowCount
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Find in UnifiedMapping_ATS table
# index = 1 : return ATS48 Address
# index = 2 : return ATS480_Compa Code
# index = 3 : return ATS480_Compa Address
# index = 4 : return ATS480 Code
# index = 5 : return ATS480 Address
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 050321 Kaidi    proc created
# Doxygen Tag:
##Function description : return right value in the ATSUnifiedMapping_Table
# E.g. use < FindUnifiedMapping_ATS ACC 5 > to return the ACC logic addres in the new mapping
# ##Restart needed !

proc FindUnifiedMapping_ATS { CodeATS48 index {NoErrorPrint 0}} {
    global  ATSUnifiedMapping_Table

    set rc [catch { set retVal $ATSUnifiedMapping_Table($CodeATS48) }]

    if {$rc != 0} {
	if {!$NoErrorPrint} {
	    TlError "data $CodeATS48 not existing in ATSUnifiedMapping_Table"
	}

	return 0
    } else {
	set retVal [ lindex $retVal [expr $index -1 ] ]
    }

    return $retVal

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#read testspec.xlsx file for the FFT and get all tc nb for product
# E.g. use < ATS_TestSpec_TCGet P FFT010 > to get all tc nb for ATS48P
#we can use global variable : TestSpec_TCGet_PrintResult
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_TestSpec_TCGet { product   FFT { NoPrint 0  } } {
    global mainpath TestSpec_TCGet_PrintResult GetTestSpecOK

    switch $product {
	"P" {
	    set product "ATS48+"
	}
	"B" {
	    set product "BASIC"
	}
	"OPT" {
	    set product "OPTIMUM"
	}
    }
    #Package to use Excel
    package require tcom

    set excelFilePath [ATS_Search_TestSpec $FFT]

    if { $GetTestSpecOK== 1} {
	# Set the path to your excel file.

	#   set excelFilePath [ATS_Search_TestSpec $FFT]
	TlPrint "reading file $excelFilePath--------------------------------------------------------------"
	set excelApp [::tcom::ref createobject Excel.Application]
	set workbooks [$excelApp Workbooks]
	set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
	set worksheets [$workbook Worksheets]
	#Sheets("Definition").select
	set worksheet [$worksheets Item [expr 2]]

	set TestSpec_TCGet_PrintResult ""
	#Check the name of selected worksheet
	if { [$worksheet Name]=="Test-Cases" } {

	    set cells [$worksheet Cells]

	    set rowCount 8
	    set end 0

	    while {  $end == 0} {
		#TlPrint "debug 1"
		set data ""
		# Read all the values in column A
		set TC_Number [[$cells Item $rowCount A] Value]

		if {  [ llength $TC_Number ] == 0  } {  ;#if celle is empty : "" or "     "
		    set end 1
		    continue
		}

		set TC_Des [[$cells Item $rowCount G] Value]
		if {  [ string length $TC_Des ] == 0  } {  ;#if Description celle is empty
		    incr rowCount
		    continue
		}

		set Context [[$cells Item $rowCount F] Value]
		#	    TlPrint "--------------"
		#    TlPrint "$TC_Number, $Context ,[ llength $TC_Number ]; [ llength $Context ]"

		#-nocase to ignore upper lower lettre
		if {[string match -nocase "*$product*" $Context] || [ llength $Context ] ==0 } {  ;#[ regexp -nocase {$product} $line ]
		    #filter TC with the right product
		    set TC_Number_filter [[$cells Item $rowCount A] Value]
		    #TlPrint "debug 2"
		    lappend     TestSpec_TCGet_PrintResult "[regexp -all -inline {\S+} $TC_Number_filter] is requested for $product"   ;#remove the space
		}

		incr rowCount
	    }

	} else {
	    TlError "not in worksheet Test-Cases "
	}
	if { $NoPrint== 0  }  {
	    for {set i 0} {$i < [llength $TestSpec_TCGet_PrintResult]} {incr i} {
		TlPrint "[lindex $TestSpec_TCGet_PrintResult $i]"
	    }
	}
	$excelApp Quit
    } else {
	set TestSpec_TCGet_PrintResult ""
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#read macroDBLOG_V2.xlsx file to get the TestCase result to set a global variable ATS_TCResult_Table
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 230321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_TCResultGet {  } {
    global ATS_TCResult_Table Result_summary_print env
    #Package to use Excel
    package require tcom

    # Set the path to your excel file.
    set excelFilePath C:/Users/$env(USERNAME)/Desktop/ATS/macroDBLOG_V2.xlsm
    TlPrint "reading file $excelFilePath--------------------------------------------------------------"
    set excelApp [::tcom::ref createobject Excel.Application]
    set workbooks [$excelApp Workbooks]
    set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
    set worksheets [$workbook Worksheets]
    #Sheets("Definition").select
    set worksheet [$worksheets Item [expr 1]]

    #Check the name of selected worksheet
    if { [$worksheet Name]=="Macro" } {

	set cells [$worksheet Cells]

	set TC_OK_nb [expr int([[$cells Item 6 O] Value])]
	set TC_PARTIAL_nb [expr int([[$cells Item 6 P] Value])]
	set TC_FAILED_nb [expr int([[$cells Item 6 Q] Value])]
	set TC_TOTAL_nb [expr int([[$cells Item 6 R] Value])]

	set rowCount 1
	set end 0

	#If ATS_TCResult_Table already exists, reset this array
	if {[info exists ATS_TCResult_Table] } {
	    foreach number [array names ATS_TCResult_Table] {
		#  parray ATS_TCResult_Table
		unset ATS_TCResult_Table($number)
	    }
	}
	#find testRUN ID
	set testrun_ID ""
	while {  $end == 0} {
	    set testrunID [[$cells Item $rowCount D] Value]
	    if { [ llength $testrunID ] == 0 } {
		set end 1
		continue
	    }
	    if { $rowCount >= 2 } {
		#TlPrint "$rowCount [expr int([[$cells Item $rowCount D] Value])] "
		lappend testrun_ID  [expr int([[$cells Item $rowCount D] Value])]
		lappend iterations  [expr int([[$cells Item $rowCount E] Value])]
	    }
	    incr rowCount
	}

	#find test result from J to M column
	set rowCount 1
	set end 0
	while {  $end == 0} {
	    set data ""

	    # Read all the values in column J
	    set TC_Number [[$cells Item $rowCount J] Value]

	    if { [ llength $TC_Number ] == 0 } {
		set end 1
		continue
	    }

	    set Result_Satus [[$cells Item $rowCount K] Value]
	    set OK_Number [expr int([[$cells Item $rowCount L] Value])]
	    set KO_Number [expr int([[$cells Item $rowCount M] Value])]
	    lappend data  $Result_Satus
	    lappend data  $OK_Number
	    lappend data  $KO_Number

	    #set table
	    set ATS_TCResult_Table($TC_Number) $data
	    #TlPrint "$TC_Number,  $data"
	    incr rowCount
	}
	set unique_testrun_ID [lsort -unique $testrun_ID]
	set iterations [lsort -integer -decreasing $iterations]
	set Result_summary_print "$TC_OK_nb         $TC_PARTIAL_nb         $TC_FAILED_nb         $TC_TOTAL_nb     iterations:[lindex $iterations 0] from testrun ID $unique_testrun_ID"
	#TlPrint "$unique_testrun_ID"
    } else {
	TlError "not in worksheet Macro "
    }

    $excelApp Quit
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#find in ATS_TCResult_Table to return the its result
# E.g. use < ATS_FindTCResult TC_FFT034_ConfigurationManagement_Test04_08> to get the TC result for TC_FFT034_ConfigurationManagement_Test04_08
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_FindTCResult { TC  { NoErrorPrint 0 }} {
    global ATS_TCResult_Table
    set rc [catch { set retVal $ATS_TCResult_Table($TC) }]

    if {$rc != 0} {
	if {!$NoErrorPrint} {
	    TlError "result of TC $TC not existing in the excel"
	}

	return
    } else {
	set retVal1 [ lindex $retVal 0 ]
	set retVal2 [ lindex $retVal 1 ]
	set retVal3 [ lindex $retVal 2 ]
	set TCresultPrint "||Result : $retVal1, $retVal2 passed, $retVal3 KO||"
    }

    return $TCresultPrint
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#get all append_test TC in a FFT.tcl file
#we can use :
#TC_append_test_FullNameList :  list of all TC at the beginning of the .tcl file
#TC_append_testList : list of all TC at the beginning of the .tcl file  for one product
#TC_append_test_NotCommentList : list of all TC not commented at the beginning of the .tcl file  for one product
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_TCL_GetTCAppendStatus { product FFT {NoPrint 0}} {
    global theTestDir theTestFileList theTestDirList testFilename theTestProcList
    global mainpath TC_append_test_FullNameList  TC_append_testList TC_append_test_NotCommentList
    switch $product {
	"P" {
	    set product "ATS48P"
	}
	"B" {
	    set product "BASIC"
	}
	"OPT" {
	    set product "OPTIM"
	}
    }

    set FFT  [ATS_MatchFFT $FFT]

    set file [open "$mainpath/TC_ATS/$FFT" r]    ;#FFT303
    TlPrint "reading file $mainpath/TC_ATS/$FFT-----------------------------------------------------------------------"
    #set file_data [read $file]

    ################get append _test TC
    set start 0
    set TC_append_testList ""
    set TC_append_test_NotCommentList ""
    set TC_append_test_FullNameList ""

    while { [gets $file line] >= 0 } {
	set TC_notCommented 0
	#TlPrint "Hello1: $line"
	#TlPrint "OK1--------------"
	if { [string match "*append_test*TestfileStart*" $line] == 1 ||[string match "*append_test*TestFileStart*" $line] == 1} {
	    set start 1
	    # TlPrint "OK3--------------"
	    # set line [RemoveSpaceFromList $line]
	    #	    set wordList [split $line]
	    #	    set TC_InAppend [lindex $wordList 2]
	    #	    TlPrint "TC_InAppend is $TC_InAppend"
	    continue
	}
	#condition for skip this line (TC)
	if { [string match "*append_test*" $line] != 1 || [string match "*bis*" $line] == 1 || [string match "*TEST*" $line] == 1 || [string range [lindex $line 2] 0 1]  != "TC" || [string match "*TestfileStop*" $line] == 1} {
	    continue
	}
	#condition for stopping
	if { [string match "proc*" $line] == 1 } {
	    #  TlPrint "OK4--------------"
	    break
	}

	if { $start == 1 } {

	    #	    TlPrint "lindex 4	 [lindex $line 4]"
	    #	    TlPrint "lindex 3	 [lindex $line 3]"
	    #	    TlPrint "lindex 2	 [lindex $line 2]"
	    #		TlPrint "line is $line"
	    #		set line [RemoveSpaceFromList $line]
	    #		TlPrint "line is $line"
	    #		set wordList [split $line]
	    #		TlPrint "wordList is $wordList"
	    set TC_FullName [lindex $line 2]
	    lappend   TC_append_test_FullNameList $TC_FullName    ;#list for all DUT

	    #check is append_test is commented or not

	    if { [string range [lindex $line 0] 0 0]   != "#" } {
		set TC_notCommented 1
	    }

	    set Context [lindex $line 3]
	    #TlPrint "Context is $Context"

	    #gestion of feature begin
	    set ListOR {}
	    set ListAND {}
	    set ListNOT {}
	    set ATS48P_InContext 0
	    set BASIC_InContext 0
	    set OPTIM_InContext 0
	    foreach feature $Context {

		switch -regexp [string index $feature 0] {
		    "!" { lappend ListNOT [string range $feature 1 end] }
		    "&" { lappend ListAND [string range $feature 1 end] }
		    default {lappend ListOR $feature}
		}
	    }
	    #if in or list ,set feature to 1
	    if {[lsearch $ListOR "DevAll" ] >=0 }  {
		set ATS48P_InContext 1
		set BASIC_InContext 1
		set OPTIM_InContext 1
	    } else {
		for {set i 0} {$i < [llength $ListOR]} {incr i} {
		    set DUT [lindex $ListOR $i]
		    set [subst $DUT]_InContext 1
		}

	    }
	    #if in not list ,set feature to 0
	    for {set i 0} {$i < [llength $ListNOT]} {incr i} {
		set DUT [lindex $ListNOT $i]
		set [subst $DUT]_InContext 0
	    }
	    #gestion of feature end

	    #	    set TC_InAppend [lindex $line 2]
	    #	    set TC_nb [split $TC_InAppend "_"]
	    #	    set TC_nb_end [lindex $TC_nb end]
	    #	    set TC_nb_Before_end [lindex $TC_nb end-1]
	    #
	    #	    #	    for {set i 0} {$i < [llength $wordList]} {incr i} {  ;#[llength $wordList]
	    #	    #		TlPrint "OK2--------------"
	    #	    #		puts "------------------$i"
	    #	    #		puts [lindex $wordList $i]
	    #	    #	    }
	    #
	    #	    if { [ regexp {^([0-9]+)$} $TC_nb_end ]  || [ regexp {^([0-9]+)$} [string range $TC_nb_end 0 0] ]} {   ;#the cas for _Test09_01  or TC06__02bis
	    #		if { [string match "*TC*" [lindex $TC_nb end-2]]  ||  [string match "*Test*" [lindex $TC_nb end-2]]} {
	    #		    set TC_nb [lindex $TC_nb end-2]-$TC_nb_Before_end-$TC_nb_end
	    #		} else {
	    #		    set TC_nb $TC_nb_Before_end-$TC_nb_end
	    #		}
	    #
	    #	    }  else { ;#the cas for _Test09
	    #		set TC_nb $TC_nb_end
	    #	    }

	    #TlPrint "  $TC_nb ,Context is $Context, ATS48P_InContext :$ATS48P_InContext ,BASIC_InContext : $BASIC_InContext,OPTIM_InContext : $OPTIM_InContext"

	    if {  [subst $[subst $product]_InContext ]== 1  }  {
		lappend TC_append_testList  $TC_FullName

	    }

	    if {  $TC_notCommented== 1  && [subst $[subst $product]_InContext ]== 1  }  {
		lappend TC_append_test_NotCommentList $TC_FullName
	    }

	    #TlPrint "  $TC_InAppend : $TC_nb_end, $TC_nb_Before_end"

	}

    }
    set TC_append_testList [lsort  -dictionary -unique $TC_append_testList]
    set TC_append_test_NotCommentList [lsort -dictionary -unique $TC_append_test_NotCommentList]
    set TC_append_test_FullNameList [lsort -dictionary -unique $TC_append_test_FullNameList]
    if { $NoPrint== 0  }  {
	puts "-------------------------------------  for $product we have append_test :--------------------------------------------------"
	for {set i 0} {$i < [llength $TC_append_testList]} {incr i} {
	    TlPrint "  [lindex $TC_append_testList $i]"
	}
	puts "------------------------------------  for $product we have append_test not commented :-----------------------------------"
	for {set i 0} {$i < [llength $TC_append_test_NotCommentList]} {incr i} {
	    TlPrint "  [lindex $TC_append_test_NotCommentList $i]"
	}
    }

    #TlPrint "theTestFileList:  $theTestFileList "

    #  TlPrint "testFilename:  $testFilename "
    # TlPrint "theTestProcList:  $theTestProcList "
    #    set line [RemoveSpaceFromList $line]
    #    TlPrint " line $line--------------"
    #    set wordList [split $line]
    #    TlPrint " length :[llength $wordList]--------------"
    # set wordList [split $file_data "\n"]

    #    for {set i 0} {$i < [llength $wordList]} {incr i} {  ;#[llength $wordList]
    #	TlPrint "OK2--------------"
    #	puts "------------------$i"
    #	puts [lindex $wordList $i]
    #    }
    # puts $file_data
    close $file

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#get  full fft .tcl file name
# E.g. use <ATS_MatchFFT FFT010 > to return FFT010_CommandSwitching.tcl
# E.g. use <ATS_MatchFFT FFT010 1 > to return all .tcl file listed in the 0top_Single.tcl
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_MatchFFT { FFT {getAll 0} } {

    global mainpath FFTIDlist
    set file [open "$mainpath/TC_ATS/0top_Single.tcl" r]    ;#0top_Single
    set FFTlist ""
    set FFTIDlist ""
    while { [gets $file line] >= 0 } {

	#get all FFT for ATS
	if { [string match "*##*" $line] == 1|| [string match "*append_test*" $line] != 1 || [string match "*FFTtest*" $line] == 1 || [string match "*FFT*" $line] != 1 || [string match "*obsolete*" $line] == 1 || ![ regexp {^([0-9]+)$} [string range [lindex $line 2] 3 3] ] } { ;#exclure some tcl file like FFTtest_kaidi
	    continue
	}

	lappend FFTlist	 [lindex $line 2]

	if { $getAll !=0 } {
	    set FFTID  [lindex $line 2]
	    set TC_nb [split $FFTID "_"]
	    set TC_nb_first [lindex $TC_nb 0]
	    set TC_nb_second [lindex $TC_nb 1]

	    if { [ regexp {^([0-9]+)$} $TC_nb_second ] } {
		set FFTID  [subst $TC_nb_first]_[subst $TC_nb_second]

	    } else {
		set FFTID  $TC_nb_first
	    }
	    lappend FFTIDlist $FFTID
	}
	#sort FFT number from small to large
	set  FFTIDlist [lsort -dictionary $FFTIDlist]

    }
    close $file

    if { $getAll ==0 } {
	set Found 0
	for {set i 0} {$i < [llength $FFTlist]} {incr i} {
	    if { [string match "*$FFT*" [lindex $FFTlist $i]] == 1} {
		set Found 1
		set FFT_Name [lindex $FFTlist $i]
		break
	    }
	}
	if { $Found ==1 } {
	    # TlPrint " $FFT is $FFT_Name "
	    set    FFTlist $FFT_Name
	} else {
	    TlError "No such FFT $FFT found"
	}
    }
    # TlPrint " FFTIDlist is $FFTIDlist "
    return  $FFTlist

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#evaluate for each TC in a FFT of the DUT is scripted or not
# E.g. use < ATS_TCL_CheckFFTTC_Scripted P FFT068> to see whether the TCs for ATS48P in FFT068 are well scripted or not
# E.g. use <ATS_TCL_CheckFFTTC_Scripted P FFT 0 1> to  print all tc scripted status
#we can use global variable : CheckFFTTC_print_result
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_TCL_CheckFFTTC_Scripted { product FFT  {NoPrint 0} {GetAll 0}} {
    global mainpath TC_append_testList CheckFFTTC_print_result GEDEC_list FFTIDlist
    set CheckFFTTC_print_result ""

    if { $GetAll == 1  } {
	ATS_MatchFFT $FFT 1  ;# then we can use global variable FFTIDlist

	foreach FFT  $FFTIDlist {
	    set CheckFFTTC_print_result ""
	    ATS_TCL_GetTCAppendStatus $product $FFT 1
	    foreach TCID  $TC_append_testList {

		set result [ATS_TCL_CheckOneTC_Scripted  $FFT $TCID]

		if { $result == 1  } {
		    if { [ llength $GEDEC_list ] != 0  } {
			lappend  CheckFFTTC_print_result "$TCID is scripted($GEDEC_list)"
		    } else {
			lappend  CheckFFTTC_print_result "$TCID is scripted"
		    }
		} else {
		    if { [ llength $GEDEC_list ] != 0  } {
			lappend  CheckFFTTC_print_result "$TCID is NOT scripted($GEDEC_list)"
		    } else {
			lappend  CheckFFTTC_print_result "$TCID is NOT scripted"
		    }
		}

	    }
	    if { $NoPrint== 0  }  {
		for {set i 0} {$i < [llength $CheckFFTTC_print_result]} {incr i} {
		    TlPrint "  [lindex $CheckFFTTC_print_result $i]"
		}
	    }
	}

    } else {
	ATS_TCL_GetTCAppendStatus $product $FFT 1
	foreach TCID  $TC_append_testList {

	    set result [ATS_TCL_CheckOneTC_Scripted  $FFT $TCID]

	    if { $result == 1  } {
		if { [ llength $GEDEC_list ] != 0  } {
		    lappend  CheckFFTTC_print_result "$TCID is scripted($GEDEC_list)"
		} else {
		    lappend  CheckFFTTC_print_result "$TCID is scripted"
		}
	    } else {
		if { [ llength $GEDEC_list ] != 0  } {
		    lappend  CheckFFTTC_print_result "$TCID is NOT scripted($GEDEC_list)"
		} else {
		    lappend  CheckFFTTC_print_result "$TCID is NOT scripted"
		}
	    }
	}
	if { $NoPrint== 0  }  {
	    for {set i 0} {$i < [llength $CheckFFTTC_print_result]} {incr i} {
		TlPrint "  [lindex $CheckFFTTC_print_result $i]"
	    }
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check a TC is scripted or not, return value 1 means scipted, 0 means not scripted
# E.g. use < ATS_TCL_CheckOneTC_Scripted FFT068 TC_FFT068_DigitalOutputConfiguration_Test10 > to see whether TC_FFT068_DigitalOutputConfiguration_Test10 is scripted or not
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_TCL_CheckOneTC_Scripted {  FFT TC } {
    global mainpath TC_append_testList GEDEC_list
    set FFT  [ATS_MatchFFT $FFT]
    set file [open "$mainpath/TC_ATS/$FFT" r]

    #set file_data [read $file]

    ################get append _test TC
    set TC_Found 0
    set TC_Nplus1 0
    set TC_Scripted 0
    set GEDEC_list ""
    #TlPrint " 1  TC_Scripted is $TC_Scripted "
    while { [gets $file line] >= 0 } {
	set Linecomment 0

	#   TlPrint " debug $line "
	if { [string match "proc $TC*" $line] == 1} {
	    set TC_Found 1
	    #TlPrint " debug 1 "
	    continue
	}

	if { $TC_Found==1 } {
	    if { [string match "proc*" $line] == 1  } {
		set TC_Nplus1 1
		# TlPrint " debug 3 "
		break
	    } else {
		#find GEDEC

		if { [string match "*GEDEC*" $line] == 1  } {
		    regexp {(GEDEC[0-9]*)} $line GEDECmatched
		    lappend GEDEC_list $GEDECmatched
		}
		#evaluation for TC scripted
		if { $TC_Scripted==0 &&[FirstNoEmptyChar $line] != "#" && [string match "*TlPrint*" $line] != 1  && ( [string match "*doWaitForObject*" $line] == 1 ||[string match "*doWaitForRelay*" $line] == 1 ||[string match "*set*" $line] == 1 || [string match "*ATVSetTime*" $line] == 1 ||[string match "*ATVGetTime*" $line] == 1 ) } {
		    set TC_Scripted 1

		    #TlPrint " debug 2 "
		}
	    }
	}

    }

    #    #TlPrint " 2 TC_Scripted is $TC_Scripted "
    #    if { $TC_Scripted == 1  } {
    #	TlPrint "  $TC is scripted "
    #    } else {
    #	TlPrint "  $TC is not scripted "
    #    }
    set GEDEC_list [lsort -unique $GEDEC_list]
    # puts $GEDEC_list
    return $TC_Scripted

}

#DOC----------------------------------------------------------------
##DESCRIPTION
#return the first no empty char in a string
# E.g. use < FirstNoEmptyChar "    #dqdsqd dq" > to return #
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc FirstNoEmptyChar { line } {

    for {set i 0} {$i <  [string length $line] } {incr i} {

	if { [string range $line $i $i] != " " } {

	    return [string range $line $i $i]
	}
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#Algin the texte in one line for argument line1 and line2
#distance : set the length between the first letter of line1 and the first letter of line2
# E.g. use <ATS_StringAlign  "TC07-3 is requested for ATS48+" 49 "TC_FFT010" >
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 200421 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_StringAlign { line1 distance line2 } {
    set result ""
    append result $line1
    set length1 [ string  length $line1]
    set length2 [ string  length $line2]
    #puts $length1
    # puts $length2
    for {set a 0} {$a <  [expr $distance -$length1]} {incr a} {
	append result " "
    }
    # puts [ string  length $result]
    set result   [format "%s  %s" $result  $line2]
    return $result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#generate a TC report in which it prints all TC in testspec for DUT and evaluate if these tc are scripted or not in the .TCL file, when PrintResult=1, the tc result will be also showed in ATS_TCReport.txt file
# E.g. use <ATS_TC_Evaluation_Print P FFT010 > for only FFT010, to print all tc for ATS48P in FFT010.excel fiel and evalue if they are scripted in FFT010.tcl file
# E.g. use <ATS_TC_Evaluation_Print P FFT010 1> for each FFT, to print all tc for ATS48P in excel fiel and evalue if they are scripted in tcl file, and we can find the result in  ATSTC_Tcl_Excel_Check.txt file
# E.g. use <ATS_TC_Evaluation_Print P FFT010 1 1> to also print the tc result from macroDBLOG_V2 file
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 220321 kaidi    proc created
#
#END----------------------------------------------------------------

proc ATS_TC_Evaluation_Print { product FFT {All 0} {PrintResult 0}} {
    global mainpath TestSpec_TCGet_PrintResult CheckFFTTC_print_result FFTIDlist  Result_summary_print

    if { $All ==0 } {

	ATS_TestSpec_TCGet $product $FFT 1
	ATS_TCL_CheckFFTTC_Scripted $product $FFT 1

	TlPrint "##---------------------------------------------------------$FFT for ATS48$product----------------------------------------------------------------------##"
	TlPrint "##In TestSpec $FFT.excel file##                                                      ## In $FFT.tcl scipt##"
	for {set i 0} {$i < [ expr max([llength $TestSpec_TCGet_PrintResult],[llength $CheckFFTTC_print_result]) ] } {incr i} {
	    #  TlPrint "[lindex $TestSpec_TCGet_PrintResult $i]                                   [lindex $CheckFFTTC_print_result $i]"
	    set ExcelPrint [lindex $TestSpec_TCGet_PrintResult $i]
	    set TclPrint [lindex $CheckFFTTC_print_result $i]
	    TlPrint  "[ATS_StringAlign  $ExcelPrint 49 $TclPrint]"

	}

    } else {
	if { $PrintResult ==1 } {
	    #get TC result from excel
	    ATS_TCResultGet
	}

	set systemTime [clock seconds]
	set day  [clock format $systemTime -format {%d}]
	set month  [clock format $systemTime -format {%m}]
	set year  [clock format $systemTime -format {%Y}]

	#creat a dir ATS_TCReport is not exist
	set dirname $mainpath/TC_ATS/ATS_TCReport
	if {![file exist $dirname]} {
	    file mkdir $dirname
	}
	#Open ATS_TCReport.txt for writing
	if { $PrintResult ==1 } {
	    set outputFile [open "$mainpath/TC_ATS/ATS_TCReport/ATS48[subst $product]_TCReport_$day$month$year.txt" w]
	} else {
	    set outputFile [open "$mainpath/TC_ATS/ATS_TCReport/ATS48[subst $product]_TCReport_[subst $day$month$year]_NoResult.txt" w]
	}

	puts $outputFile "Report for ATS48$product TestCase, [clock format $systemTime -format {Today is: %A, the %d of %B, %Y}] , the time is: [clock format $systemTime -format %H:%M:%S]"

	ATS_MatchFFT $FFT 1  ;# then we can use global variable FFTIDlist

	#set Counter
	set ExcelCounter 0
	set TclScriptedCounter 0
	set TclNotScriptedCounter 0

	foreach FFT  $FFTIDlist {

	    ATS_TestSpec_TCGet $product $FFT 1
	    ATS_TCL_CheckFFTTC_Scripted $product $FFT 1

	    # Put some text in to the file

	    puts $outputFile "##----------------------------------------------------------$FFT for ATS48$product----------------------------------------------------------------------##"
	    puts $outputFile "##In TestSpec $FFT.excel file##                                            ## In $FFT.tcl scipt##"
	    for {set i 0} {$i < [ expr max([llength $TestSpec_TCGet_PrintResult],[llength $CheckFFTTC_print_result]) ] } {incr i} {
		set ExcelPrint [lindex $TestSpec_TCGet_PrintResult $i]
		set TclPrint [lindex $CheckFFTTC_print_result $i]

		if { $PrintResult ==1 } {
		    #set result from excel file
		    set TclPrint_TestID [lindex $TclPrint 0]
		    set ResultPrint [ATS_FindTCResult $TclPrint_TestID 1]

		    puts $outputFile [ATS_StringAlign  $ExcelPrint 49 [format "%s %s" $TclPrint  $ResultPrint]]

		    #puts $outputFile "$ExcelPrint                  $TclPrint $ResultPrint"
		} else {
		    puts $outputFile [ATS_StringAlign  $ExcelPrint 49 $TclPrint]
		    #  puts $outputFile "$ExcelPrint                                         $TclPrint"
		}
		#counter calcul
		if {  [llength $ExcelPrint ] != 0} { ;#if line is not empty
		    incr ExcelCounter
		} else {
		    #puts " emptyExcelPrint : $ExcelPrint"
		}
		if {[string match "*NOT*" $TclPrint] == 1} {
		    # puts " NOT : $TclPrint"
		    incr TclNotScriptedCounter

		} elseif {  [llength $TclPrint ] == 0} {
		    # puts " empty : $TclPrint"
		} else {
		    incr TclScriptedCounter
		    #   puts " Scripted : $TclPrint"
		    #  puts $TclPrint

		}

	    }

	}

	puts $outputFile "============================================================================================================="
	puts $outputFile "  We have total $ExcelCounter requested TC for ATS48$product, in .Tcl file $TclScriptedCounter scripted, $TclNotScriptedCounter NOT scripted"
	if { $PrintResult ==1 } {
	    set a [lindex $Result_summary_print 0]
	    set b [lindex $Result_summary_print 1]
	    set c [lindex $Result_summary_print 2]
	    puts $outputFile "  TC OK ||TC PARTIAL||TC FAILED||tested TC TOTAL           SW version :[format 0x%04X [TlRead C1SV]]"
	    puts $outputFile "    $Result_summary_print"
	    set plotResult [ATS_TCResult_PlotGraph $a $b $c]
	    puts $outputFile "  $plotResult"

	}
	puts $outputFile "============================================================================================================="
	#Close the file
	close $outputFile
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#return the filepath of the testspec
#Read for C:/Users/SESAxxx/Desktop/ATS/TestSpec
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_Search_TestSpec { FFT  } {
    global mainpath GetTestSpecOK env

    set param ".xls*"
    set files ""
    set objectFiles ""
    set GetTestSpecOK 0
    #find testspec file in the C:/Users/SESAxxx/Desktop/ATS/TestSpec
    foreach file [glob -nocomplain -directory C:/Users/$env(USERNAME)/Desktop/ATS/TestSpec "*$param"] {
	set objectFile [file tail [file rootname $file]]$param

	lappend objectFiles $objectFile
	lappend files $file

    }

    for {set i 0} {$i <  [llength $objectFiles] } {incr i} {

	if { [string match "*$FFT*" [lindex $objectFiles $i]] == 1} {
	    set GetTestSpecOK 1
	    return [lindex $files $i]
	}
    }
    if { $GetTestSpecOK== 0} {
	TlError "I can not find $FFT"
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#return the filepath of the testspec
#Read for box
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 090621 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_Search_TestSpecOld { FFT  } {
    global mainpath GetTestSpecOK
    global env
    set param ".xls*"

    set GetTestSpecOK 0

    # "C://Users/$env(USERNAME)/Box/ATLAS FFTs & TestSpecs Reviews/FFT Reviews"
    foreach floder [list "ToReview" "Commited"  "Working" "Reviewed"] {

	set path  "C:/Users/$env(USERNAME)/Box/ATLAS FFTs & TestSpecs Reviews/TestSpec Reviews/APP/$floder"
	set files ""
	set objectFiles ""
	foreach file [glob -nocomplain -directory $path "*$param"] {
	    set objectFile [file tail [file rootname $file]]$param

	    lappend objectFiles $objectFile
	    lappend files $file

	}
	for {set i 0} {$i <  [llength $objectFiles] } {incr i} {

	    if { [string match "*$FFT*" [lindex $objectFiles $i]] == 1} {
		set GetTestSpecOK 1
		return [lindex $files $i]
	    }
	}
    }

    if { $GetTestSpecOK== 0} {
	TlError "I can not find $FFT"
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#return the SESA of this PC
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 180321 kaidi    proc created
#
#END----------------------------------------------------------------
proc Get_SESA {   } {

    set FileList ""
    foreach file [glob -nocomplain -directory C:/Users "*"] {
	set objectFile [file tail [file rootname $file]]

	lappend FileList $objectFile

    }

    for {set i 0} {$i <  [llength $FileList] } {incr i} {

	if { [string match "SESA*" [lindex $FileList $i]] == 1} {
	    return [lindex $FileList $i]
	}
    }
}

proc ATS_TCResult_PlotGraph { a  b c  } {

    set a_percentage [format "%.2f" [expr 100.0*$a/ [expr $a +$b +$c]]]
    set b_percentage [format "%.2f" [expr 100.0*$b/ [expr $a +$b +$c]]]
    set c_percentage [format "%.2f" [expr 100.0*$c/ [expr $a +$b +$c]]]
    set  TCResultpercentage "$a_percentage%      $b_percentage%      $c_percentage%"
    return $TCResultpercentage
    #    set plot_list ""
    #    for {set i 0} {$i <  $a_percentage } {incr i} {
    #	lappend plot_list "+++"
    #    }
    #    for {set i 0} {$i <  $b_percentage } {incr i} {
    #	lappend plot_list "***"
    #    }
    #    for {set i 0} {$i <  $c_percentage } {incr i} {
    #	lappend plot_list "xxx"
    #    }
    #    if { $NoPrint== 0  }  {
    #	foreach Result  $plot_list {
    #
    #	    puts  "$Result"
    #	}
    #    }
    #    return $plot_list
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#generate a summary TC report for one product in reading all ATS48x_TCReport_date.txt file
# E.g. use <ATS_generate_SummaryReport P> to generate ATS48P_TCReport_summary.txt
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 250321 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_generate_SummaryReport {product } {
    global mainpath

    set param ".txt"
    set files ""
    set objectFiles ""
    set objectFiles_filter_list ""
    set GetTCReportOK 0

    foreach file [glob -nocomplain -directory $mainpath/TC_ATS/ATS_TCReport "*$param"] {
	set objectFile [file tail [file rootname $file]]$param

	lappend objectFiles $objectFile
	lappend files $file

    }
    # puts "objectFiles $objectFiles"
    #puts "files $files"
    #find the right file for the DUT
    for {set i 0} {$i <  [ llength $objectFiles] } {incr i} {
	#if file is _NoResult file, pass it
	if { [string match "*NoResult*" [lindex $objectFiles $i]] == 1 } {
	    continue
	}
	set objectFiles_split [split [lindex $objectFiles $i] "_"]
	set Date [lindex $objectFiles_split end]
	set Date [split $Date "."]
	set Date [lindex $Date 0]

	set DUT [lindex $objectFiles_split 0]
	#puts "$i Date $Date"
	#puts "$i DUT $DUT"
	if { [ regexp {^([0-9]+)$} $Date ] && $DUT=="ATS48$product"} {
	    set GetTCReportOK 1
	    lappend objectFiles_filter_list [lindex $objectFiles $i]
	}
    }
    # puts "objectFiles_filter_list $objectFiles_filter_list"
    if { $GetTCReportOK== 0} {
	TlError "I can not find ATS$product TCReport"
    } else {
	set result_nb_list ""
	set result_porcentage_list ""
	set OK_nb_list ""
	set PARTIAL_nb_list ""
	set FAILED_nb_list ""
	set TOTAL_nb_list ""
	set Date_list ""
	set i 1
	#get data from each filtered file
	foreach objectFiles_filter $objectFiles_filter_list {
	    set iteration_ok 0
	    set GetPourcentage 0
	    set file [open "$mainpath/TC_ATS/ATS_TCReport/$objectFiles_filter" r]

	    set objectFiles_split [split  $objectFiles_filter "_"]
	    set Date [lindex $objectFiles_split end]
	    set Date [split $Date "."]
	    set Date [lindex $Date 0]

	    set DAY [string range $Date 0 1]
	    set MONTH [string range $Date 2 3]
	    set YEAR [string range $Date 4 7]
	    set Date $YEAR$MONTH$DAY

	    # lappend Date_list $Date
	    lappend Date_list $i
	    incr i
	    while { [gets $file line] >= 0 } {

		if { $GetPourcentage == 1 } {

		    if { [string match "*%*" $line] == 1 } {

			set value_porcentage1 [lindex $line 0]
			set value_porcentage2 [lindex $line 1]
			set value_porcentage3 [lindex $line 2]
			#set align format for print result
			set result_line   [format "%d    %s : %8d (%s) %8d (%s) %8d (%s) %8d" $Date $Version_matched $value1 $value_porcentage1 $value2 $value_porcentage2 $value3 $value_porcentage3 $value4]
			#if iterations data is displayed
			if { $iteration_ok == 1 } {
			    set result_line   [format "%d    %s : %8d (%s) %8d (%s) %8d (%s) %8d        %s" $Date $Version_matched $value1 $value_porcentage1 $value2 $value_porcentage2 $value3 $value_porcentage3 $value4 $value5]

			}

			lappend result_nb_list $result_line
			#lappend result_nb_list "$Date    $Version_matched    :  $value1 ($value_porcentage1)       $value2 ($value_porcentage2)        $value3 ($value_porcentage3)       $value4"
			break
		    }

		}

		if { [string match "*tested TC TOTAL*" $line] == 1 } {
		    regexp {(0x[0-9]*)} $line Version_matched

		}

		if { [string match "*from testrun ID*" $line] == 1 } {
		    set value1 [lindex $line 0]
		    set value2 [lindex $line 1]
		    set value3 [lindex $line 2]
		    set value4 [lindex $line 3]

		    #if iterations data is displayed
		    if { [string match "*iterations*" $line] == 1 } {
			set iteration_ok 1
			set value5 [lindex $line 4]
		    }
		    # TlPrint "debug 1"
		    #  TlPrint "result_nb $result_nb_list"
		    lappend OK_nb_list [lindex $line 0]
		    lappend PARTIAL_nb_list [lindex $line 1]
		    lappend FAILED_nb_list [lindex $line 2]
		    lappend TOTAL_nb_list [lindex $line 3]

		    set GetPourcentage 1

		    continue

		} else {

		    continue
		}
	    }
	    close $file
	}
	#sort by date
	set result_nb_list [lsort -dictionary $result_nb_list]

	set outputFile [open "$mainpath/TC_ATS/ATS_TCReport/ATS48[subst $product]_TCReport_summary.txt" w]
	puts $outputFile "    ==============================================="
	puts $outputFile "      Summary TC Result Report for ATS48$product"
	puts $outputFile "    ==============================================="
	puts $outputFile "     date     SW version     TC OK        ||   TC PARTIAL   ||   TC FAILED   ||  tested TC TOTAL"
	foreach result $result_nb_list {
	    puts $outputFile "  $result"

	}
	#	puts "  Date_list $Date_list"
	#	puts "  OK_nb_list $OK_nb_list"
	#	puts "  PARTIAL_nb_list $PARTIAL_nb_list"
	#	puts "  FAILED_nb_list $FAILED_nb_list"
	#	puts "  TOTAL_nb_list  $TOTAL_nb_list"

	#PlotGraph $Date_list $OK_nb_list $TOTAL_nb_list

	close $outputFile

    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#sort nb of CR created by people by reading /Desktop/ATS/QueryResult.xls file
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210521 kaidi    proc created
#
#END----------------------------------------------------------------
proc ATS_AnalyzeCR { } {
    global CRdata env
    #Package to use Excel
    package require tcom

    # Set the path to your excel file.
    set excelFilePath C:/Users/$env(USERNAME)/Desktop/ATS/QueryResult.xls
    TlPrint "reading file $excelFilePath--------------------------------------------------------------"
    set excelApp [::tcom::ref createobject Excel.Application]
    set workbooks [$excelApp Workbooks]
    set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
    set worksheets [$workbook Worksheets]
    #Sheets("IBM Rational ClearQuest Web").select
    set worksheet [$worksheets Item [expr 1]]

    #Check the name of selected worksheet
    if { [$worksheet Name]=="IBM Rational ClearQuest Web" } {

	set cells [$worksheet Cells]

	set rowCount 2
	set end 0
	set CRdata ""
	set SubmitterList ""
	while {  $end == 0} {

	    # Read all the values in column

	    set UniqueID [[$cells Item $rowCount A] Value]

	    if { [ llength $UniqueID ] == 0 } {
		set end 1
		continue
	    }

	    set Submitter [[$cells Item $rowCount F] Value]
	    set State [[$cells Item $rowCount D] Value]
	    set Severity [[$cells Item $rowCount C] Value]
	    set Headline [[$cells Item $rowCount B] Value]

	    set data "$UniqueID $Headline $Severity $State $Submitter"
	    lappend CRdata  $data
	    lappend SubmitterList $Submitter

	    incr rowCount
	}

    } else {
	TlError "not in worksheet IBM Rational ClearQuest Web "
    }

    $excelApp Quit

    set unique_Submitter [lsort -unique $SubmitterList]

    for {set i 0} {$i < [llength $CRdata]} {incr i} {
	TlPrint "[lindex $CRdata $i]"
    }

    TlPrint "$unique_Submitter"
    set SubmitterListNumber  [llength $SubmitterList]   ;#number of all CR
    TlPrint "total CR : $SubmitterListNumber"
    set SubmitterNumber  [llength $unique_Submitter]
    for {set i 0} {$i < $SubmitterNumber} {incr i} {
	set SubmitterName$i    [lindex $unique_Submitter $i]
	set   [subst Submitter$i]CRNumber  0
    }

    for {set i 0} {$i < $SubmitterListNumber} {incr i} {
	for {set j 0} {$j < $SubmitterNumber} {incr j} {
	    if { [lindex $SubmitterList $i] == [lindex $unique_Submitter $j] } {
		incr [subst Submitter$j]CRNumber
		break
	    }
	}
    }

    set result ""
    for {set i 0} {$i < $SubmitterNumber} {incr i} {

	set data   [format "%4d CR by %22s" [subst $[subst Submitter$i]CRNumber]  [subst $[subst SubmitterName$i]] ]
	lappend result $data
	#	TlPrint "$result"

    }
    set  result [lsort -dictionary  -decreasing $result]

    for {set i 0} {$i < [llength $result]} {incr i} {

	TlPrint   [lindex $result $i]

    }
}

# Doxygen Tag:
## Function description : Writes the name of the device in the PANx registers via the current cmdInterface. If no name is specified will write "Altistart480"
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 20210414 | ASY | proc created
# 20211026 | SE  | Check if the PANx has been correctely written
#
# \param[in] name: Name of the device to write. Default value "Altistart480"
#
# \n
# E.g. Use < WritePANRegisters "ATS480_DHCP" > to write ATS480_DHCP to the PANx registers
#
proc WritePANRegisters { {name "Altistart480"}} {
    global ActDev
    set length [string len $name]

    if {[expr $length % 2 ] == 1 } {
	set maxIndex [expr $length / 2 + 1]
    } else {
	set maxIndex [expr $length / 2]
    }

    set maxRetry 3
    set retry 1
    set noErrPrint 1
    ErasePANRegisters ;#Erase PANx before writing the new name
    while { ( $retry <= $maxRetry) && ( [ReadDeviceName] != $name) } {
	TlPrint "======== WritePANRegisters : retry number $retry ========"
	if {$retry == $maxRetry} {
	    set noErrPrint 0
	}
	incr retry

	for {set i 0} {$i < $maxIndex} {incr i} {
	    set tempStr [string range $name [expr $i * 2] [expr $i * 2 +1]]
	    puts $tempStr
	    set res ""
	    append res [format %02X [scan [string range $tempStr 0 0] %c]]
	    if {[string range $tempStr 1 1] != "" } {
		append res [format %02X [scan [string range $tempStr 1 1] %c]]
	    } else {
		append res "00"
	    }
	    TlWrite PAN$i 0x$res
	    doWaitForObject PAN$i [scan $res %x] 2 0xffffffff "" $noErrPrint
	}
    }
}

# Doxygen Tag:
## Function description : Fills the PANx registers with 0x0000
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 20210414 | ASY | proc created
#
# E.g. Use < ErasePANRegisters> to fill the PANx registers with 0x0000
#
proc ErasePANRegisters { } {

    for {set i 0} {$i < 8} {incr i} {
	TlWrite PAN$i 0
	doWaitForObject PAN$i 0 1
    }

}

# Doxygen Tag:
## Function description : Read the ASCII value contained in the PANx registers. returns a string
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 20210414 | ASY | proc created
#
#
# \n
# E.g. Use < ReadPANRegisters  > to read the PANx registers
#
proc ReadPANRegisters { } {

    set recvString ""
    set asciiString ""
    for {set i 0} {$i < 8} {incr i} {
	set syl [TlRead PAN$i ]
	append recvString [format %04X $syl]
	foreach char [regexp -all -inline .{2} [format %04X $syl]] {
	    append asciiString [format %c [scan $char %x]]
	}
    }

    TlPrint $asciiString
    return $recvString
}

# Doxygen Tag:
## Function description : Read the device name as a string
#
# WHEN     | WHO  | WHAT
# ---------| -----| -----
# 20220209 | YGH  | proc created
#
#
# \n
# E.g. Use < ReadDeviceName  > to read the deviceName
#
proc ReadDeviceName { } {

    set asciiString ""
    for {set i 0} {$i < 8} {incr i} {
	set syl [TlRead PAN$i ]
	foreach char [regexp -all -inline .{2} [format %04X $syl]] {
	    if { $char == "00" } { ;#stop reading at the first empty character
		TlPrint $asciiString
		return $asciiString
	    }
	    append asciiString [format %c [scan $char %x]]
	}
    }

    TlPrint $asciiString
    return $asciiString
}

# Doxygen Tag:
## Function description : browses the FFT and  Specs folders of the design the check if one of the definition files have been modified later thant the corresponding script
#Raises an error if a definition file is more recent than a script
#creates a txt report with all the last modification dates
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021-05-27 | ASY |   proc created
#
#
# \n
# E.g. Use < checkFileModification > to check that the scripts are more recent than the specification files.
#
proc checkFileModification {} {
    #memorize the starting position in order to be able to return to it
    set home [pwd]
    #create the path to the design's files according to the current SESA
    global env
    #cd "C://Users/$env(USERNAME)/Box/ATLAS FFTs & TestSpecs Reviews/FFT Reviews"
    cd "C://Users/$env(USERNAME)/Box/ATLAS FFTs & TestSpecs Reviews"
    #    cd C://Users/SESA583453/Documents/DIVERS/ESSAIS_SAUVEGARDES/GestionVersions
    #Create the first level of the tree
    set root [pwd]
    #create the tree that will contain all the folders names
    set tree [list]
    set fullDirList [list]
    lappend fullDirList $root
    lappend tree $root

    #create the first folders level list
    set dirList [list]

    #Get all the folders at root level
    set rc [ catch {glob -types d "*"}]
    if {!$rc} {
	foreach folder [glob -types d "*"] {
	    #puts $folder
	    lappend dirList [file normalize $folder]
	    lappend fullDirList [file normalize $folder]
	}
    } else { return }

    lappend tree $dirList
    #foreach branch $tree { puts $branch }
    set dirList [list]
    #initialize the variables regarding scanning
    #maximal depth the script will look into
    set maxDepth 5
    set i 1
    set stop 0
    #main loop : lists all the directories in the root folder
    while { $i < $maxDepth && !$stop } {
	set dirList [list]
	foreach dir [lindex $tree $i] {
	    cd $dir
	    set rc [ catch {glob -types d "*"}]
	    if {!$rc} {
		foreach folder [glob -types d "*"] {
		    lappend dirList [file normalize $folder]
		    lappend fullDirList [file normalize $folder]
		}
	    }
	}
	#if no more subdirectory was found exit the loop
	if {[llength $dirList] == 0 } {
	    set stop 1
	} else { ;# append the folders found to the main tree
	    lappend tree $dirList
	    incr i
	}
    }
    #list of all the files present in the tree
    set fileList [list]
    #scan every folder of the tree for all the files
    foreach folder $fullDirList {
	cd $folder
	set rc [catch {glob -types f "*"}]
	if {!$rc} {
	    foreach fil [glob -types f "*"] {
		lappend fileList [file normalize $fil]
	    }
	}
    }

    #Check the modification date for each tcl file in TC_ATS :
    global mainpath
    cd $mainpath/TC_ATS/
    #create the list of the tcl files
    #tcl files list
    set tclFiles [list]
    set rc [catch {glob "*.tcl"}]
    if {!$rc} {
	foreach tclFile [glob "FFT\[0-9\]\[0-9\]\[0-9\]*.tcl"] {
	    lappend tclFiles $tclFile
	}
    } else {
	TlError "No Tcl file found"
	return
    }

    #loop to check the mod status for every file
    set f [open "definitionFilesHistory.txt" "w"]
    #    puts $f "Init"
    #    close $f
    foreach tclFile $tclFiles {
	set FFT [string range $tclFile 3 5]
	#puts $FFT
	set FFTMod [getLastFFTModification $fileList $FFT]
	set SPECMod [getLastSPECModification $fileList $FFT]
	set SCRIPTMod [file mtime $tclFile]
	if { $FFTMod > $SCRIPTMod || $SPECMod > $SCRIPTMod} {
	    set MODStatus "KO"
	    TlError "Definition files updated more recently than the script ($tclFile)"
	} else {
	    set MODStatus "OK"
	}
	#TlPrint "File : $tclFile ; Script mod date : [clock format $SCRIPTMod] ; FFT mod date : [clock format $FFTMod] ; SPEC mod date : [clock format $SPECMod] ; Statut : $MODStatus "
	#	set f [open "results.txt" "a"]
	puts $f "File : $tclFile ; Script mod date : [clock format $SCRIPTMod] ; FFT mod date : [clock format $FFTMod] ; SPEC mod date : [clock format $SPECMod] ; Statut : $MODStatus "
	#	close $f
	flush $f

    }
    close $f
    cd $home
}

# Doxygen Tag:
## Function description : Browses the files given as parameters to check what is the most recent modification date according to the FFT number given as second parameter
#Raises an error if no FFT file is found
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021-05-27 | ASY |   proc created
#
# \param[in] fileList: list containing all the files from the design.
# \param[in] FFT: number of the FFT we are looking for
# \n
# E.g. Use < getLastFFTModification $fileList 107 > to get the last modification date of the FFT107
#
proc getLastFFTModification {fileList FFT} {
    #return the most recent modification of any docx document containing the FFT number
    #create the documents list
    set docList [list]
    #find all the fft files related to FFT
    foreach fil $fileList {
	if {[regexp "FFT$FFT.+\.docx" $fil]} {
	    lappend docList $fil
	}
    }
    if {[llength $docList] == 0 } { ;# No FFT file found
	TlError "No FFT file found"
	return 0
    } else {;# { [llength $docList] == 1 }  ;# Only one file found
	set modDate [file mtime [lindex $docList 0]]
    }
    #get the most recent date
    foreach doc $docList {
	if { [file mtime $doc] > $modDate } {set modDate [file mtime $doc] }
    }
    return $modDate
}

# Doxygen Tag:
## Function description : Browses the files given as parameters to check what is the most recent modification date according to the SPEC number given as second parameter
#Raises an error if no SPEC file is found
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021-05-27 | ASY |   proc created
#
# \param[in] fileList: list containing all the files from the design.
# \param[in] SPEC: number of the SPEC we are looking for
# \n
# E.g. Use < getLastSPECModification $fileList 107 > to get the last modification date of the TestSpec_FFT107
#
proc getLastSPECModification {fileList SPEC} {
    #return the most recent modification of any xlsx document containing the SPEC number
    #create the documents list
    set docList [list]
    #find all the fft files related to SPEC
    foreach fil $fileList {
	if {[regexp "TestSpec_FFT$SPEC.+\.xls.*" $fil]} {
	    lappend docList $fil
	}
    }
    if {[llength $docList] == 0 } { ;# No FFT file found
	TlError "No SPEC file found for number $SPEC"
	return 0
    } else {;# { [llength $docList] == 1 }  ;# Only one file found
	set modDate [file mtime [lindex $docList 0]]
    }
    #get the most recent date
    foreach doc $docList {
	if { [file mtime $doc] > $modDate } {set modDate [file mtime $doc] }
    }
    return $modDate
}

# Doxygen Tag:
## Function description : Checks when the definition files versions were checked for the last time. If it's more than a week ago, runs the checkFileModification funciton.
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021-06-04 | ASY |   proc created
# 2021-06-07 | ASY |   added the cd $home command in order to restore initial current directory
#
# \n
# E.g. Use < checkLastDefinitionFileHistoryCheck  > to check that the definition files were controlled less than a week ago.
#
proc checkLastDefinitionFileHistoryCheck { } {
    global mainpath
    #memorize the starting position
    set home [pwd]
    #go to the main ATLAS directory
    cd $mainpath/TC_ATS/
    #check that definitionFileHistory.txt exists
    set rc [ catch {set f [glob "definitionFilesHistory.txt"]}]
    if { $rc} {
	TlPrint "definitionFileHistory.txt not found."
	TlPrint "running checkFileModification"
	checkFileModification
    } else {
	set modTime [file mtime $f]
	set currTime [clock seconds]
	if {[expr $currTime - $modTime] > [expr 7 * 24 * 3600]} {
	    TlPrint "checkFileModification last run is more than one week old"
	    TlPrint "running checkFileModification"
	    checkFileModification
	}
    }
    #restore the starting position
    cd $home
}

# Doxygen Tag:
## Function description : Waits for a Load parameter to reach a value with a given tolerance and a given timeout
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021/06/xx | YEG 	| proc created
# 2021/06/10 |ASY	| removed the connexion handling to the laod as it is now done at the tower init
# 2023/11/17 | Yahya 	| replaced call to Keypad_keepAlive by InitKeypad (see Issue #1409)
#
# \param[in] object: the load parameter to read.
# \param[in] sollwert : expected value
# \param[in] timeout : timeout
# \param[in] tolerance : tolerance around the expected value
#
# \n
# E.g. Use <doWaitForLoadObjectTol MONC.NACT 0 10 10> to ensure that the load speed has reached a value between -10 and 10 rpm in a 10s time.
#
proc doWaitForLoadObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} {keypad_keepAlive 0} } {

    global Wago_IPAddress

    #set LoadPort [mb2Open SER 11 5 19200 E 8 1]

    set timeout     [expr int ($timeout*1000)] ;#in ms
    set TTId [Format_TTId $TTId]

    set startZeit [clock clicks -milliseconds]
    set tryNumber 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks

	if { $keypad_keepAlive == 1 } { InitKeypad 0 }

	set istWert [LoadRead $objekt]

	set  duration [expr [clock clicks -milliseconds] - $startZeit]
	incr tryNumber

	if { $istWert != "" } then {
	    set diff [expr ($istWert - $sollWert)]
	    if {[expr abs($diff)] <= $tolerance} {
		TlPrint "doWaitForLoadObject %s exp=%d act=%d tol=%d diff=%d waittime=%d ms requests=%d" \
		    $objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
		break
	    }
	}

	if { $duration >= $timeout } {
	    if { $istWert == "" } {
		TlError "$TTId doWaitForLoadObject $objekt: no response after waittime=%d ms" $duration
	    } else {
		TlError "$TTId doWaitForLoadObject %s exp=%d act=%d tol=%d diff=%d TO=$timeout ms WT=%d ms requests=%d" \
		    $objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
		if { $show_status } { ShowStatus }
	    }

	    break
	}
	if {[CheckBreak]} {break}
    }; #end of while

    #    mb2Close "MBS01"
    #    #Open ModbusTCP interface to Wago
    #    TlPrint "Open ModBus TCP port $Wago_IPAddress to Wago"
    #    set rc [catch {mb2Open "TCP" $Wago_IPAddress 1} errMsg]
    #    if {$rc != 0} {
    #	TlPrint "Error on ModBusTCP open: $errMsg"
    #	set ModbusTCPsys 0
    #    } else {
    #	TlPrint "ModBus TCP port $Wago_IPAddress is open"
    #	set ModbusTCPsys 1
    #    }

    return $istWert
}

# Doxygen Tag:
## Function description :Checks if the device is in root mode. If yes, uses the keypad lib to exit root mode
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021/07/29| ASY 	| proc created
# 2023/03/17| Yahya     | added wait end of forcing state before intializing an external keypad (for ATS30)
# 2024/02/29| Yahya     | changed the value of timeout to exit from ROOT mode (see issue #1748)
#
#
# \n
# E.g. Use <exitRootMode > after a RAZI for example to exit the root mode
#

proc exitRootMode { } {
    #Check that the drive is in root mode :
    if {[Enum_Name PTST [TlRead PTST] ] == "ROOT" } {
	#init the keypad and navigate to the proper menu : DVS|EPS|DVSTP
	InitKeypad 1

	#Select language
	keypad_OK
	doWaitMs 200

	#Validate time offset
	keypad_OK
	doWaitMs 200

	#Validate date/time
	keypad_OK
	doWaitMs 200

	#Validate IRTC screen
	keypad_OK
	doWaitMs 200

	Keypad_Select "PRDM"
	keypad_OK

	Keypad_Select "CSE"
	keypad_OK
	doWaitMs 200

	#Press and hold ok for until the device goes into operational mode or reaches the timeout
	#Set timeout for exit from ROOT mode
	#NOTE : The timeout values are defined following endurance done to mesure 
	# duration for going from ROOT mode to operational mode (see issue #1748)
	if { [GetDevFeat "ATS48P"] } {
	    set timeout 10
	} elseif { [GetDevFeat "BASIC"] } {
	    set timeout 9
	} elseif { [GetDevFeat "OPTIM"] } {
	    set timeout 10.5
	} else {
	    TlError "Only ATS48P OPTIM and BASIC allowed"
	}
	
	set deltaTime 0
	set startTime [clock clicks -milliseconds]

	#Loop to press and hold OK
	while {[Enum_Name PTST [TlRead PTST] ] == "ROOT" && $deltaTime < [expr $timeout * 1000]} {
	    kpd_Touch "Ok"
	    set deltaTime [expr [clock clicks -milliseconds] - $startTime]
	    if {[CheckBreak]} {break}
	}

	kpd_Touch "No"

	if { $deltaTime > [expr $timeout * 1000] } {
	    TlError "Exit from ROOT mode to operational mode takes more than $timeout s"
	}
	    
	doWaitForObjectStable EEPS 0 30 5000

    } else {
	#Device in Operational mode
	return
    }
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectTolWaittime
# TYPE        : util
# AUTHOR      : Yahya
# DESCRIPTION : wait until value becomes target (with tolerance) and returns wait time in 'ms'
#               read via actual interface
#  objekt:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  tolerance: accepted tolerance between actual value and target value
#
#
#END-------------------------------------------------------------------
proc doWaitForObjectTolWaittime { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {

    set NameValue   ""
    set ListOfValue [split $sollWert {}]
    set timeout     [expr int ($timeout*1000)] ;#in ms
    set TTId [Format_TTId $TTId]

    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objekt $NameValue]
	if [regexp {[^0-9]} $sollWert] { return }
    }

    set startZeit [clock clicks -milliseconds]
    set tryNumber 0
    while {1} {
	after 2   ;# wait 1 mS
	update idletasks

	set istWert [doReadObject $objekt]

	set  duration [expr [clock clicks -milliseconds] - $startZeit]
	incr tryNumber

	if { $istWert != "" } then {
	    set diff [expr $istWert - $sollWert]
	    if {[expr abs($diff)] <= $tolerance} {
		TlPrint "doWaitForObject %s exp=%d act=%d tol=%d diff=%d waittime=%d ms requests=%d" \
		    $objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
		break
	    }
	}

	if { $duration >= $timeout } {
	    if { $istWert == "" } {
		TlError "$TTId doWaitForObject $objekt: no response after waittime=%d ms" $duration
	    } else {
		TlError "$TTId doWaitForObject %s exp=%d act=%d tol=%d diff=%d TO=$timeout ms WT=%d ms requests=%d" \
		    $objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
		if { $show_status } { ShowStatus }
	    }

	    break
	}
	if {[CheckBreak]} {break}
    }
    return $duration
}


#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForKeypadStatus
# TYPE        : util
# AUTHOR      : Yahya
# DESCRIPTION : wait until HMIS value displayed on keypad (on top left corner) is set to expectedStatus
#  expectedStatus: the expected status on keypad (on top left corner)
#  timeout:  seconds
#  TTId: reference to a GEDEC if necessary
#
#END-------------------------------------------------------------------
proc doWaitForKeypadStatus { expectedStatus timeout {TTId ""} } {
    set timeout     [expr int ($timeout*1000)] ;#in ms
    set start [clock clicks -milliseconds]
    set status ""

    while {[expr [clock clicks -milliseconds] - $start] < $timeout } {
	set status [readKeypadStatus]
	if { $status == $expectedStatus } {
	    TlPrint "Keypad status OK : exp=act=$status waittime=%d ms" [expr [clock clicks -milliseconds] - $start]
	    return
	}
	after 200
    }

    TlError "Keypad status not OK : exp=$expectedStatus act=$status waittime=%d ms" [expr [clock clicks -milliseconds] - $start]
}

# Doxygen Tag:
## Function description :Run motor by the channel specified in argument
# \param[in] channel : channel to use for running the motor
# \param[in] TTId : reference to a GEDEC if necessary
#
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 07/06/2021| Yahya 	| proc created
# 31/01/2024| Yahya     | added TTId input argument
#
# \n
# E.g. Use <ATSRunMotor TER > to give a run order via terminal
#
proc ATSRunMotor { channel {TTId ""} } {

    if {$channel == "TER" } {
	doWaitMs 500
	setDI 1 H
	doWaitMs 500
	setDI 2 H
    } elseif {$channel == "MDB" || $channel == "MODTCP" || $channel == "MODTCP_OptionBoard" || $channel == "EIP" || $channel == "EIP_OptionBoard" || $channel == "CAN"} {
	TlWrite CMD 0
	doWaitMs 500
	setDI 1 H
	doWaitMs 500
	TlWrite CMD 6
	doWaitMs 500
	TlWrite CMD 7
	doWaitMs 500
	TlWrite CMD 15
    } elseif {$channel == "LCC" } {
	setDI 1 H
	if {[InitKeypad 0]} {
	    keypad_Run 1
	}
    } else {
	TlError "Wrong input : $channel"
    }

    doWaitForObject HMIS .RUN [expr [TlRead ACC]* 1.5] 0xffffffff $TTId
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectIntern
# TYPE        : util
# AUTHOR      : Yahya
# DESCRIPTION : wait until internal variable value becomes target value
#               read via actual interface
#  objektIntern : name of internal variable
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  bitmaske: bit mask used to check value of specific bits of '
#  TTId: reference to a GEDEC if necessary
#
#END-------------------------------------------------------------------
proc doWaitForObjectIntern { objektIntern sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0} } {
    global Debug_NERA_Storing

    set TTId [Format_TTId $TTId]

    set DebugTimeStart [clock clicks -milliseconds]

    set ExpEnum ""
    set ResEnum ""
    set NameValue ""

    set ListOfValue [split $sollWert {}]
    if {[lindex $ListOfValue 0] == "."} {
	set NameValue [lrange $ListOfValue 1 end]
	set NameValue [join $NameValue ""]
	set sollWert  [Enum_Value $objektIntern $NameValue]

	if [regexp {[^0-9]} $sollWert] {
	    return
	}

	set ExpEnum   "=$NameValue"
    }

    set startZeit [clock clicks -milliseconds]
    set timeout   [expr int ($timeout * 1000)]

    set tryNumber 1
    while {1} {

	if { $keypadchannel == 1 } {
	    InitKeypad 0
	}

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startZeit]

	set istWert [ModTlReadIntern $objektIntern $noErrPrint $TTId]
	if { $istWert == "" } then {
	    if {$noErrPrint == 0} {
		TlError "illegal RxFrame received"
	    }
	    return 0
	} else {
	    if { $ExpEnum != "" } {
		set ResEnum [Enum_Name $objektIntern $istWert]
		set ResEnum "=$ResEnum"
	    } else {
		set ResEnum ""
	    }
	}

	if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

	    TlPrint "doWaitForObjectIntern $objektIntern exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
	    break

	} elseif { [expr $waittime > $timeout] } {

	    set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

	    if {$noErrPrint} {
		TlPrint "$TTId doWaitForObjectIntern $objektIntern exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
	    } else {
		if { $bitmaske  == 0xffffffff } {
		    TlError "$TTId doWaitForObjectIntern $objektIntern exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
		} else {
		    TlError "$TTId doWaitForObjectIntern $objektIntern exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
		}
	    }

	    if {$noErrPrint == 0} { ShowStatus }
	    return 0
	}

	incr tryNumber

	if {[CheckBreak]} {break}
    }

    return $istWert
}

# Doxygen Tag:
## Function description : Runs the PLC program
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2021/12/13| YGH  | proc created
#
#
# \n
# E.g. Use < RunPLC > to run the PLC program
#
proc RunPLC { } {
    global Wago_IPAddress

    TlPrint "Run PLC"
    PLC_command "ORC" "" $Wago_IPAddress
}

# Doxygen Tag:
## Function description : Stops the PLC program
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2021/12/13| YGH  | proc created
#
#
# \n
# E.g. Use < StopPLC > to stop the program running on PLC
#
proc StopPLC { } {
    global Wago_IPAddress

    TlPrint "Stop PLC"
    PLC_command "OSC" "" $Wago_IPAddress
}

# Doxygen Tag:
## Function description : Initialize the campaign description on DBLog with Product/option module versions
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2022/01/04| YGH  | proc created
# 2022/12/18| YGH  | excluded ATS430 for parameters linked to option board
proc initDBLogCampaignHeader { } {
	global AutoLoop ActDev
	global theTestDevList
    
	set ATSapplVer   [format "%04X" [doReadObject C1SV]]
	set ATSapplBuild [format "%04X" [doReadObject C1SB]]
	set ATSapplChecksum [format "%04X" [doReadObject C1SC]]
	set ATSmotVer    [format "%04X" [doReadObject C2SV]]
	set ATSmotBuild  [format "%04X" [doReadObject C2SB]]
	set ATSmotChecksum  [format "%04X" [doReadObject C2SC]]
	set ATSplatVer   [format "%04X" [doReadObject PLTV]]
	set ATSplatBuild [format "%04X" [doReadObject PLTB]]
    
        if {![GetDevFeat "BASIC"]} {
		set ATSmodType   [ModTlRead O1CT 1]
		set ATSmodVer    [format "%04X" [ModTlRead O1SV 1]]
		set ATSmodBuild  [format "%04X" [ModTlRead O1SB 1]]
		set ATSmodChecksum  [format "%04X" [ModTlRead O1SC 1]]
        }
	
        if {[GetDevFeat "OPTIM"]} {
        	set ATSembdType  [doReadObject C6CT]
        	set ATSembdVer   [format "%04X" [doReadObject C6SV]]
        	set ATSembdBuild [format "%04X" [doReadObject C6SB]]
        	set ATSembdChecksum [format "%04X" [doReadObject C6SC]]
        }
    
	# show date and time and program infos
	TlReport "============================================================="
	TlReport "Altistart Testrun No: $AutoLoop on Device Nr.: $ActDev"
	TlReport "Test started at        : %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
	if {[GetDevFeat "ATS48P"]} {
	    TlReport "Device name            : Altistart 480"
	} elseif {[GetDevFeat "BASIC"]} {
	    TlReport "Device name            : Altistart 430"
	} elseif {[GetDevFeat "OPTIM"]} {
	    TlReport "Device name            : Altistart 490"
	}
    
	TlReport "Application version    : V%X.%Xie%02X  Build%02X build%02X (Checksum = 0x%04X)" "0x[string range $ATSapplVer 0 0]" "0x[string range $ATSapplVer 1 1]" "0x[string range $ATSapplVer 2 3]" "0x[string range $ATSapplBuild 0 1]" "0x[string range $ATSapplBuild 2 3]" 0x$ATSapplChecksum
	TlReport "Motor control version  : V%X.%Xie%02X  Build%02X build%02X (Checksum = 0x%04X)" "0x[string range $ATSmotVer  0 0]" "0x[string range $ATSmotVer  1 1]" "0x[string range $ATSmotVer  2 3]" "0x[string range $ATSmotBuild  0 1]" "0x[string range $ATSmotBuild  2 3]" 0x$ATSmotChecksum
	TlReport "============================================================="
	
	if {[GetDevFeat "BASIC"]} {
        	set VersionString0 [format "Dummy Err of Program $theTestDevList V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)"  \
        	    "0x[string range $ATSapplVer 0 0]" "0x[string range $ATSapplVer 1 1]" "0x[string range $ATSapplVer 2 3]" "0x[string range $ATSapplBuild 0 1]" "0x[string range $ATSapplBuild 2 3]" 0x$ATSapplChecksum ]
	} else {
		set VersionString0 [format "Dummy Err of Program $theTestDevList V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X), OptionBoard1 V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)"   \
		    "0x[string range $ATSapplVer 0 0]" "0x[string range $ATSapplVer 1 1]" "0x[string range $ATSapplVer 2 3]" "0x[string range $ATSapplBuild 0 1]" "0x[string range $ATSapplBuild 2 3]" 0x$ATSapplChecksum \
		    "0x[string range $ATSmodVer  0 0]" "0x[string range $ATSmodVer  1 1]" "0x[string range $ATSmodVer  2 3]" "0x[string range $ATSmodBuild  0 1]" "0x[string range $ATSmodBuild 2 3]"  0x$ATSmodChecksum]
	}
	
	set VersionStringP [format "Platform                                     : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATSplatVer 0 0]" "0x[string range $ATSplatVer 1 1]" "0x[string range $ATSplatVer 2 3]" "0x[string range $ATSplatBuild 0 1]" "0x[string range $ATSplatBuild 2 3]"]
	set VersionString1 [format "Application (M3 SwVersion)                   : V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)" "0x[string range $ATSapplVer 0 0]" "0x[string range $ATSapplVer 1 1]" "0x[string range $ATSapplVer 2 3]" "0x[string range $ATSapplBuild 0 1]" "0x[string range $ATSapplBuild 2 3]" 0x$ATSapplChecksum]
	set VersionString2 [format "Motor control (CpuPower SwVersion)           : V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)" "0x[string range $ATSmotVer  0 0]" "0x[string range $ATSmotVer  1 1]" "0x[string range $ATSmotVer  2 3]" "0x[string range $ATSmotBuild  0 1]" "0x[string range $ATSmotBuild 2 3]" 0x$ATSmotChecksum]
	
	if {[GetDevFeat "BASIC"]} {
		set args ""
		TlPrintIntern E "$VersionString0                </br>$VersionString1</br>$VersionStringP</br>$VersionString2" args
	
	} elseif {[GetDevFeat "OPTIM"]} {
		set VersionString6 [format "Ethernet Embedded : CT=%s V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)" [Enum_Name C6CT $ATSembdType ] "0x[string range $ATSembdVer 0 0]" "0x[string range $ATSembdVer 1 1]" "0x[string range $ATSembdVer 2 3]" "0x[string range $ATSembdBuild 0 1]" "0x[string range $ATSembdBuild 2 3]" 0x$ATSembdChecksum]
		set VersionString7 [format "Option Board 1                               : CT=%s V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)" [Enum_Name O1CT $ATSmodType ] "0x[string range $ATSmodVer  0 0]" "0x[string range $ATSmodVer  1 1]" "0x[string range $ATSmodVer  2 3]" "0x[string range $ATSmodBuild  0 1]" "0x[string range $ATSmodBuild 2 3]" 0x$ATSmodChecksum]
		set args ""
		TlPrintIntern E "$VersionString0                </br>$VersionString1</br>$VersionStringP</br>$VersionString2</br>$VersionString6</br>$VersionString7" args
	
	} else {
		set VersionString7 [format "Option Board 1                               : CT=%s V%X.%Xie%02X B%02X b%02X (Checksum = 0x%04X)" [Enum_Name O1CT $ATSmodType ] "0x[string range $ATSmodVer  0 0]" "0x[string range $ATSmodVer  1 1]" "0x[string range $ATSmodVer  2 3]" "0x[string range $ATSmodBuild  0 1]" "0x[string range $ATSmodBuild 2 3]" 0x$ATSmodChecksum]
		set args ""
		TlPrintIntern E "$VersionString0                </br>$VersionString1</br>$VersionStringP</br>$VersionString2</br>$VersionString7" args
	}
	
	TlPrint ""

	TlPrint $VersionString1
	TlPrint $VersionStringP
	TlPrint $VersionString2
	
	if {![GetDevFeat "BASIC"]} {
		TlPrint $VersionString7
	}
}

# Doxygen Tag:
## Function description : Generate an external fault to populate error/alarm history
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2022/01/13| YGH  | proc created
proc genExternalFaultAlarm { } {
    global ActDev
    doResetDeviceInputs $ActDev
    FFT146_AlarmManagement_AddToGroup "EFA" 1
    DIAssigne 3  EXTERNAL_ERROR_ASSIGNMENT_ID
    DIAssigne 4  FAULT_RESET_INPUT_ID
    setDI 3 H
    doWaitMs 100
    setDI 3 L
    doWaitForObject HMIS .FLT 1
    doWaitForObject LFT .EPF1 1
    doWaitMs 1000
    setDI 4 H
    doWaitMs 500
    setDI 4 L
    doWaitForNotObject HMIS .FLT 1
}

# Doxygen Tag:
## Function description : Workaround to avoid braking problem present on ATS490 until specified fix date (see GitHub issue #287 for more details)
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2022/11/18| YGH  | proc created
# 2022/12/14| YGH  | added the date format to ensure comparison correctness  
proc brakingWorkaroundUntilDate_GitHubIssue_287 { } {
    set expectedFixDate "30/11/2022"
    set todayDate [clock format [clock seconds] -format "%d/%m/%Y"]

    if {[clock scan $todayDate -format "%d/%m/%Y"] > [clock scan $expectedFixDate -format "%d/%m/%Y"]} {
	TlError "expected fix date is passed ==> check with project team to remove this workaround if no more necessary or update fixDate"
	ATSBackToIniti
	return -level 2
    }
    TlWrite BRC 0
    doWaitForObject BRC 0 1
    doStoreEEPROM
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#configurate R1 to Isolating relay; R2 to  End of starting relay; R3 to  Fault relay
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 070621 kaidi    proc created
# 291122 ASY      moved, renamed and adapted for ATS430
# 291122 YGH      Added input parameters for R1, R2 and R3 assignments
#END----------------------------------------------------------------
proc setRelayConfiguration { {R1assign "ISOL"} {R2assign "BPS"} {R3assign "FLT"} } {

    TlPrint "R1 configured to $R1assign"
    TlWrite R1 .$R1assign
    doWaitForObject R1 .$R1assign 1
    TlPrint "R2 configured to $R2assign"
    TlWrite R2 .$R2assign
    doWaitForObject R2 .$R2assign 1
    if {![GetDevFeat "BASIC"]} {
	TlPrint "R3 configured to $R3assign"
	TlWrite R3 .$R3assign
	doWaitForObject R3 .$R3assign 1
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check R1/R2/R3 is closed or open, 1 is closed, 0 is open
#R1 is Isolating relay; R2 is  End of starting relay; R3 is  Fault relay
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 070621 kaidi    proc created
# 291122 ASY      moved, renamed, adapted and improved for ATS430
#
#END----------------------------------------------------------------
proc checkAllRelayStatus { R1 R2 {R3 "NA"} } {
    if { $R1 == "1"  } {
	doWaitForObject OL1I 0x0001 1 0x0001
	checkRelay R1 1
    } else {
	doWaitForObject OL1I 0x0000 1 0x0001
	checkRelay R1 0
    }

    if { $R2 == "1"  } {
	doWaitForObject OL1I 0x0002 1 0x0002
	checkRelay R2 1
    } else {
	doWaitForObject OL1I 0x0000 1 0x0002
	checkRelay R2 0
    }
    if {![GetDevFeat "BASIC"] || $R3 != "NA"} {
	if { $R3 == "1"  } {
	    doWaitForObject OL1I 0x0004 1 0x0004
	    checkRelay R3 1
	} else {
	    doWaitForObject OL1I 0x0000 1 0x0004
	    checkRelay R3 0
	}
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#Configure ATS command switching parameters
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 070621 kaidi    proc created
# 011222 ASY      moved
# 191222 ASY      added the switchCmdInterface parameter
# 291222 Yahya    added case of channel "ETH"
# 151123 Yahya    Removed parameter setDI1 (see Issue #1345)
# 220324 Yahya    Added doWaitForObject CHCF/CCS/CD1... (see Issue #1819)
#
#END----------------------------------------------------------------
proc ATSCommandSwitch { profil channel {switchCmdInterface 0}} {
    TlPrint "ATS command switch"
    if {$profil == "STD" ||$profil == "IO"} {
	TlWrite CHCF .$profil
	doWaitForObject CHCF .$profil 1
	TlPrint "Channel : $channel"
	TlWrite CCS .CD1
	doWaitForObject CCS .CD1 1
	if {$channel == "MDB"} {
	    TlWrite CD1 .MDB
	    doWaitForObject CD1 .MDB 1
	    doWaitForObject CCC 8 1
	    if {$switchCmdInterface} {doSetCmdInterface "MOD"}
	} elseif {$channel == "TER" } {
	    TlWrite CD1 .TER
	    doWaitForObject CD1 .TER 1
	    doWaitForObject CCC 1 1
	} elseif {$channel == "LCC" } {
	    TlWrite CD1 .LCC
	    doWaitForObject CD1 .LCC 1
	    doWaitForObject CCC 4 1
	} elseif {$channel == "CAN" } {
	    TlWrite CD1 .CAN
	    doWaitForObject CD1 .CAN 1
	    doWaitForObject CCC 64 1
	    if {$switchCmdInterface} {doSetCmdInterface "CAN"}
	} elseif {$channel == "MODTCP" || $channel == "EIP" || $channel =="MODTCP_OptionBoard" || $channel == "EIP_OptionBoard"} {
	    TlWrite CD1 .NET
	    doWaitForObject CD1 .NET 1
	    doWaitForObject CCC 512 1
	    if {$switchCmdInterface} {doSetCmdInterface $channel}
	} elseif {$channel == "NET" } {
	    TlWrite CD1 .NET
	    doWaitForObject CD1 .NET 1
	    doWaitForObject CCC 512 1
	} elseif {$channel == "ETH" } {
	    TlWrite CD1 .ETH
	    doWaitForObject CD1 .ETH 1
	    doWaitForObject CCC 2048 1
	} else {
	    TlError "$channel is not corresponding to any available channel in $profil profile "
	    return
	}
    }

    if {$profil == "SE8"} {
	TlWrite CHCF .SE8
	doWaitForObject CHCF .SE8 1
	if {$channel == "MDB"} {
	    TlWrite CMD 0
	    doWaitForObject CCC 8 1
	} elseif {$channel == "TER" } {
	    doChangeMask CMD 0x8100 1
	    doWaitForObject CCC 1 1
	}
    }
    TlPrint "---------------------------------------------------------------------------"
    TlPrint "CHCF  :[Enum_Name CHCF [TlRead CHCF] ] "
    TlPrint "CCC :  [TlRead CCC]-------  1 : TER, 4 : keypad, 8 : MDB, 64 : CAN, 512 : NET, 2048 : ETH"
    TlPrint "CMD :  [TlRead CMD] "
    TlPrint "CD1 :  [Enum_Name CD1 [TlRead CD1] ] "
    TlPrint "---------------------------------------------------------------------------"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to check Possible Value can be affected to para
#para : name of parameter to check
#expectedList : list value that set to the paremeter
#mutable : to specify if the parameter is a configuration or a setting parameter (mutable = gatingOff or always)
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 140621 kaidi    proc created
# 011222 ASY      moved
# 291222 Yahya    In case of possible value, wait for HMIS to be "RDY" or "NST"
# 020523 ASY      Removed handling of LLC and R3
# 220323 ASY 	  Added the hanling of LxL values
# 161023 Yahya	  Added check that the expected list is included in the list extracted from AltiLab_KOP XML file
# 261023 Yahya	  Added unset of 'index' variable & consideration of L2L in assignment (Issue #1158)
# 250424 Kilian   Added the handling of LxL values from para
# 160724 Yahya    Added "mutable" parameter (Issue #2476)
#
#END----------------------------------------------------------------
proc ATSCheckPossibleValue { para expectedList {mutable "gatingOff"} {TTId ""} }   {
    set TTId [Format_TTId $TTId]
    set initValue [TlRead $para]
	
    #Check that the expected list is included in the list extracted from AltiLab_KOP XML file
    foreach value $expectedList {
	if {[lsearch [Enum_List_Names $para] $value ] == -1 } { ;# if value is NOT in the List
	    TlError "$value is in the expected list but NOT present in the list from AltiLab_KOP XML file"
	}
    }
		
    foreach value [Enum_List_Names $para] {

	after 20
	#check if the parameter is to be set to an input active at low level
	#if yes, then set the input to high level
	if {[regexp "L(\[2-4\])L" $value res index]} {
	    TlWrite $para 0
	    setDI $index H
	}
	if {[regexp "^L(\[2-4\])L$" $para res index]} {
	    setDI $index H
	}
	TlWrite $para .$value

	TlPrint "---------------------------$para is set to $value--------------------"
	if {[lsearch $expectedList $value ] >=0 } { ;# if value is  in the  List
	    doWaitForObject $para .$value 1 0xffffffff $TTId
	    doWaitForObjectList HMIS {.RDY .NST} 1 0xffffffff $TTId

	} else {
	    switch $mutable {
		"gatingOff" {
		    doWaitForObject HMIS .FLT 1 0xffffffff $TTId
		    doWaitForObject LFT .CFI 0 0xffffffff $TTId
		}
		"always" {
		    doWaitForNotObject $para .$value 1 0xffffffff $TTId
		    doWaitForNotObject HMIS .FLT 1 0xffffffff $TTId
		}
		default { 
		    TlError "Wrong input for mutable parameter : $mutable"
		}
	    }

	    TlWrite $para $initValue
	    doWaitForObjectList HMIS {.RDY .NST} 1 0xffffffff $TTId
	}
	#if the input was set to a high level then reset it 
	if {[info exists index]} {
	    TlWrite $para $initValue
	    setDI $index L
	    unset index
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to check memorization
#para : name of parameter to check
#SetValuelist : list value to be set to the paremeter
#profil : by default is default profil
#constraintParams : List of parameters that need to be written to a given value after the ATSBackToIniti function
#constraintValues : List of the values to write to the parameters
#
#The lists size must be identical. For enumerated parameters, the value must contain the dot eg: .TER 
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 100621 kaidi    proc created
# 011222 ASY      moved
# 080323 ASY      added the constraintParams and constraintValues parameters
# 270323 ASY      added the TTId variable
#END----------------------------------------------------------------
proc ATSCheckMemorization { para SetValuelist {constraintParams ""} {constraintValues "" } {TTId ""}}   {
    set TTId [Format_TTId $TTId]
    TlPrint "----------------------------------check Memorization for parameter $para" 
    #Check if the lists have the same size
    if { [llength $constraintParams] != [llength $constraintValues] } {
	    TlError "Input parameters inconsistents"
	    return -1
    }
    #Display the requested constraints
    if { [llength $constraintParams ] != 0 } {
	TlPrint "Requested constraints for the memorization test : "
	for {set i 0} { $i < [llength $constraintParams] } {incr i } {
		TlPrint " [lindex $constraintParams $i] =  [lindex $constraintValues $i]"
	}
    }
    foreach SetValue $SetValuelist {
	ATSBackToIniti
	#Apply the constraints
       if { [llength $constraintParams ] != 0 } {
           for {set i 0} { $i < [llength $constraintParams] } {incr i } {
           	TlWrite [lindex $constraintParams $i] [lindex $constraintValues $i]
           	doWaitForObject  [lindex $constraintParams $i] [lindex $constraintValues $i] 1
           }
       }
	doStoreEEPROM

	set  Iniresult [Enum_Name  $para [expr [TlRead $para]]]

	TlPrint "---------------------------------------------------------------------------"
	TlPrint "Iniresult is $Iniresult ;$para is set to $SetValue without CMI=2"
	TlPrint "---------------------------------------------------------------------------"

	TlWrite $para .$SetValue
	

	doWaitForObject $para .$SetValue 1 0xFFFF $TTId
	doRP ;#Restart the softstarter
	doWaitForObject $para .$Iniresult 1 0xFFFF $TTId ;# shall not be memorized
	TlPrint "---------------------------------------------------------------------------"
	TlPrint "$para is set to $SetValue with CMI=2"
	TlPrint "---------------------------------------------------------------------------"
	
	TlWrite $para .$SetValue
	

	doWaitForObject $para .$SetValue 1 0xFFFF $TTId
	doStoreEEPROM
	doRP ;#Restart the softstarter
	doWaitForObject $para .$SetValue 1 0xFFFF $TTId ;# shall be memorized after CMI=2
    }

    ATSBackToIniti
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to check Possible Value can be affected to para
#para : name of parameter to check
#min : lowest value possible to set on the parameter
#max : highest value possible to set on the parameter
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 270821 Yahya    proc created
# 081222 ASY	  moved and renamed
# 030124 ASY	  changed the expected device state from RDY only to { RDY NST} issue #1522
#
#END----------------------------------------------------------------
proc CheckNumericParamValue { para min max {TTId ""}}   {

    #Create a list with border values
    set testBorderValuesList [list [expr $min - 1] $min [expr $min + 1] [expr $max - 1] $max [expr $max + 1] ]
    #Create a list of 3 random values between min and max
    set randomValuesList ""
    for {set i 0 } {$i < 3 } { incr i } {
	lappend randomValuesList [random $min $max ]
    }
    set testValuesList [concat $testBorderValuesList $randomValuesList]
    TlPrint "test values : $testValuesList"
    foreach SetValue $testValuesList {
	TlWrite $para $SetValue
	if { ( $SetValue >= $min ) && ( $SetValue <= $max )} {
	    doWaitForObject $para $SetValue 1
	    doWaitForObjectList HMIS {.RDY .NST} 1
	    TlPrint "----------------------------------------------------------"
	    TlPrint " $para can be set to $SetValue"
	    TlPrint "----------------------------------------------------------"
	} else {
	    if {[lsearch [ParametersSelection_Modifiable "gatingOff"] $para ] >=0 } { ;# if para is a configuration parameter
		doWaitForObject HMIS .FLT 1
	    }
	    set result [TlRead $para]

	    if { ( $result < $min) || ( $result > $max) } {
		TlError "delay value shall not be $result, which is not in the range of $min-$max"
	    } else {
		TlPrint "----------------------------------------------------------"
		TlPrint " $para can not be set to $SetValue, when we set $SetValue,$para becomes $result"
		TlPrint "----------------------------------------------------------"
	    }
	    TlWrite $para $min
	    doWaitForObject $para $min 1
	    doWaitForObjectList HMIS {.RDY .NST} 1
	}
    }
    ATSBackToIniti
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to check memorization of values in para
#para : name of parameter to check
#min : lowest value possible to set on the parameter
#max : highest value possible to set on the parameter
#constraintParams : List of parameters that need to be written to a given value after the ATSBackToIniti function
#constraintValues : List of the values to write to the parameters
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 270821 Yahya    proc created
# 081222 ASY	  moved and renamed
# 270323 ASY	  added the constraintParams and constraintValues parameters and the handling of TTId
#END----------------------------------------------------------------
proc CheckNumericParamMemorization { para min max {constraintParams ""} {constraintValues "" } {TTId ""}}   {
    set TTId [Format_TTId $TTId]

    #Check if the lists have the same size
    if { [llength $constraintParams] != [llength $constraintValues] } {
	TlError "Input parameters inconsistents"
	return -1
    }
    #Display the requested constraints
    if { [llength $constraintParams ] != 0 } {
	TlPrint "Requested constraints for the memorization test : "
	for {set i 0} { $i < [llength $constraintParams] } {incr i } {
	    TlPrint " [lindex $constraintParams $i] =  [lindex $constraintValues $i]"
	}
    }
    #Create a list with border values
    set testBorderValuesList [list $min [expr $min + 1] [expr $max - 1] $max ]
    #Create a list of 2 random values between min and max
    set randomValuesList ""
    for {set i 0 } {$i < 2 } { incr i } {
	lappend randomValuesList [random $min $max ]
    }
    set testValuesList [concat $testBorderValuesList $randomValuesList]
    TlPrint "test values : $testValuesList"
    foreach SetValue $testValuesList {
	ATSBackToIniti
	#Apply the constraints
	if { [llength $constraintParams ] != 0 } {
	    for {set i 0} { $i < [llength $constraintParams] } {incr i } {
		TlWrite [lindex $constraintParams $i] [lindex $constraintValues $i]
		doWaitForObject  [lindex $constraintParams $i] [lindex $constraintValues $i] 1
	    }
	}
	doStoreEEPROM 
	    
	set  Iniresult [TlRead $para]

	TlPrint "---------------------------------------------------------------------------"
	TlPrint "Iniresult is $Iniresult ;$para is set to $SetValue without CMI=2"
	TlPrint "---------------------------------------------------------------------------"

	TlWrite $para $SetValue
	doWaitForObject $para $SetValue 1 0xFFFF $TTId
	doRP ;#Restart the softstarter
	    

	doWaitForObject $para $Iniresult 1 0xFFFF $TTId ;# shall not be memorized

	TlPrint "---------------------------------------------------------------------------"
	TlPrint "$para is set to $SetValue with CMI=2"
	TlPrint "---------------------------------------------------------------------------"

	TlWrite $para $SetValue
	doWaitForObject $para $SetValue 1 0xFFFF $TTId
	doStoreEEPROM
	doRP ;#Restart the softstarter
	doWaitForObject $para $SetValue 1 0xFFFF $TTId ;# shall be memorized after CMI=2
    }
    ATSBackToIniti
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to set the device command channel and put it in a chosen state (RDY/NST/RUN..)
#channel : the command channel to be set on the device
#state : the state we want to set the device to (RDY/NST/RUN..)
#InForcedLocal : this parameter indicates if the device is in forced local state at the moment of the call to this function
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 181621 kaidi	  proc created
# 281222 Yahya    moved & documented
# 170123 Yahya    added .BYP state in case of RUN request
# 180123 Yahya    Added consideration of CHCF & 2-3Wires control to give Run order
# 100323 Yahya	  Added consideration of channel ETH & raising error in case of unsupported channel / state
# 120623 F.FRIOL  Update according CHCF = IO profile (considering update on FFT013-014_IE02-03)	
# 031123 Yahya    Updated case of state = RDY in IO profile (see issue #1305)
# 301123 Yahya    Removed the change of communication interface (see issue #1387)
# 030124 Yahya    Removed call to Keypad_Home to get state RDY via keypad (see issue #1388)
# 080824 Yahya    Added consideration of NLP state (see issue #1056)
# 311224 Yahya    Added consideration of NET (see issue #3229)
#
#END----------------------------------------------------------------
proc ATSChannelStateWrite { channel state {InForcedLocal 0}} {

    TlPrint " ==give a $state order via $channel channel"
    if {$InForcedLocal != "1"} {
	TlWrite CD1 .$channel
	doWaitForObject CD1 .$channel 1
    }

    set CHCFProfile [Enum_Name CHCF [ModTlRead CHCF] ]

    if { ![GetDevFeat "OPTIM"] } {
	set 2_3WireProfile "LC3W"
    } else {
	set 2_3WireProfile [Enum_Name TCC [ModTlRead TCC] ]
    }

    if {$state == "RDY" || $state == "NLP"} {
	switch $channel {
	    "MDB" -
	    "NET" -
	    "ETH" {
		    
		if { $CHCFProfile != "IO" } {
		    if { $2_3WireProfile != "2C" } {setDI 1 H}
		    TlWrite CMD 6
			
		} else { ;#Case of CHCF = IO
			if { $2_3WireProfile != "2C" } {
				setDI 1 H
				TlWrite CMD 1
			} else {
				TlWrite CMD 0
			}
		}
	    }
	    "TER" {
	    	if { $2_3WireProfile != "2C" } {setDI 1 H}
	    }
	    "LCC" {
		if { $2_3WireProfile != "2C" } {setDI 1 H}
		InitKeypad 1 ;#simulate keypad connected
	    }
	    default { TlError "Channel $channel is not taken into consideration in this proc in case : state = $state" }
	}; #End of switch 
	  
	if {$state == "NLP"} {
	    PhaseAllOnOff $::ActDev L
	    doWaitForObject HMIS .NLP [ModTlRead TBS]
	} else {
	    doWaitForObject HMIS .RDY [ModTlRead TBS]
	}

    } elseif {$state == "RUN"}  {
	set isKPDActiveChannel [expr {$channel == "LCC" ? 1: 0}]
	MotorStart
	doWaitForObjectList HMIS {.RUN .BYP} [expr [TlRead ACC]* 1.5] 0xffffffff "" 0 $isKPDActiveChannel

    } elseif {$state == "IDLE"}  {

    } elseif {$state == "FLT"}  {
	switch $channel {
	    "MDB" {
		Function_Fault_SLF

		doWaitForObject HMIS .FLT 1
		doWaitForObject LFT .SLF1 1
	    }
	    "TER" - 
	    "NET" - 
	    "ETH" {
		Function_Fault_ETF

		doWaitForObject HMIS .FLT 1
		doWaitForObject LFT .EPF1 1
	    }
	    "LCC" {
		InitKeypad 0

		doWaitMs 2500
		doWaitForObject HMIS .FLT 1
		doWaitForObject LFT .SLF3 1
	    }
	    default { TlError "Channel $channel is not taken into consideration in this proc in case : state = $state" }
	}; #End of switch 

    } else {
	TlError "State $state is not taken into consideration in this proc" 
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#function to give a RUN command on the device
#level : "H" to RUN the motor / "L" to stop the motor
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 181621 kaidi	  proc created
# 281222 Yahya    moved & documented
#
#END----------------------------------------------------------------
proc RunCommand { level} {
    if {[GetDevFeat "ATS48P"] } {
	switch $level {
	    "L" {
		TlPrint "================we do nothing for RUN level $level"  ;#we do nothing for low
	    }
	    "H" {
		setDI 1 $level
		doWaitMs 500
		setDI 2 $level
		TlPrint "================setDI 1 to $level, setDI 2 to $level"
	    }
	}

    } elseif {[GetDevFeat "BASIC"]  } {
	switch $level {
	    "L" {
		TlPrint "================we do nothing for RUN level $level"  ;#we do nothing for low
	    }
	    "H" {
		setDI 1 $level
		doWaitMs 500
		setDI 2 $level
		TlPrint "================setDI 1 to $level, setDI 2 to $level"
	    }
	}
    } elseif {[GetDevFeat "OPTIM"] } {
	switch $level {
	    "L" {
		TlPrint "================we do nothing for RUN level $level"  ;#we do nothing for low
	    }
	    "H" {
		setDI 1 $level
		doWaitMs 500
		setDI 2 $level
		TlPrint "================setDI 1 to $level, setDI 2 to $level"
	    }
	}
    } else {
	TlError "ATS48 ATS48P OPTIM and BASIC allowed"
    }
}



#-------------------------------------------------------------------------------
#Read Relay function
#
#Aim of this instruction is to return level of relay, 
#This is used for PhaseAllOnOff to manage input circuit breaker according to Relay configured to LLC function
#possible value returned = 'L' or 'H'
#-------------------------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 2023/03/01 FFL	  proc created
# 2024/07/15 ASY      add the default case in the switch
proc ReadRelay {Relay {TTId ""}} {
    global ActDev

    set PLC_Register1 1004;# identify the PLC register to control the right output
    set PLC_Bit1 7
    set PLC_Register2 1005;# identify the PLC register to control the right output
    set PLC_Bit2 -1
    set PLC_Register3 1005;# identify the PLC register to control the right output
    set PLC_Bit3 7

    switch $Relay {
	"R1" {set Rx 1 }
	"R2" {set Rx 2 }
	"R3" {set Rx 3 }
	"DQ1" {set Rx 4 }
	"DQ2" {set Rx 5 }
    default { 
        TlError "Invalid input in ReadRelay function : $Relay "
        return -1
    }
    }

    if {[TlRead CCC] == 4} {
	InitKeypad 0
    }

    switch -regexp $ActDev {
	1 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register1 1] >> [expr $PLC_Bit1 + $Rx] ]
	}
	2 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register2 1] >> [expr $PLC_Bit2 + $Rx] ]
	}
	3 {
	    set ix [expr [wc_TCP_ReadWord $PLC_Register3 1] >> [expr $PLC_Bit3 + $Rx] ]
	}
    }
    if { [expr $ix & 0x01] } {
	return "H"
    } else {
	return "L"
    }
}

# Doxygen Tag:
## Function description : Workaround to wait for EEPS to be stable at 0 (see GitHub issue #688 / GED-91587 for more details)
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2023/03/10| YGH  | proc created
proc EEPS_WorkaroundUntilDate_GitHubIssue_688 { } {
    set expectedFixDate "15/06/2023"
    set todayDate [clock format [clock seconds] -format "%d/%m/%Y"]

    if { [GetDevFeat "OPTIM"] || [GetDevFeat "BASIC"] } {
	if {[clock scan $todayDate -format "%d/%m/%Y" ] > [clock scan $expectedFixDate -format "%d/%m/%Y" ]} {
	    TlError "expected fix date is passed ==> check if GED-91587 is closed to remove this workaround or update fixDate"
	} else {
	    doWaitForObjectStable EEPS 0 60 5000 0xffffffff "" 1
	}
    }
}


# Doxygen Tag:
## Function description :check and take into consideration a list of constraints in input arguments and a
#                        parameter to indicate if we expect the parameter to be writable during RUN or not.
#
#WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2023/04/21| YGH  | proc created

proc ATSCheckWriteInRun { para value { isWritable 0 } {constraintParams ""} {constraintValues "" } { TTId "" } } {
    set TTId [Format_TTId $TTId]

    TlPrint "----------------------------------check writing parameter $para to $value during RUN"
    #Check if the lists have the same size
    if { [llength $constraintParams] != [llength $constraintValues] } {
	TlError "Input parameters inconsistent"
	return -1
    }

    #Display the requested constraints
    if { [llength $constraintParams ] != 0 } {
	TlPrint "Requested constraints for the memorization test : "
	for {set i 0} { $i < [llength $constraintParams] } {incr i } {
	    TlPrint " [lindex $constraintParams $i] = [lindex $constraintValues $i]"
	}
    }

    #Apply the constraints
    if { [llength $constraintParams ] != 0 } {
	for {set i 0} { $i < [llength $constraintParams] } {incr i } {
	    TlWrite [lindex $constraintParams $i] [lindex $constraintValues $i]
	    doWaitForObject [lindex $constraintParams $i] [lindex $constraintValues $i] 1
	}
    }

    set initialValue [TlRead $para]

    MotorStart
    doWaitForObjectList HMIS { .ACC .RUN .BYP } [expr [TlRead ACC]* 1.2]
    if { $isWritable } {
	TlWrite $para $value
	doWaitForObject $para $value 1 0xffffffff $TTId
    } else {
	TlWriteAbort $para $value 4 $TTId
	doWaitForObject $para $initialValue 1 0xffffffff $TTId
    }
    MotorStop

    #Check value is not taken into account after motor is stopped
    if { $isWritable == 0 } {
	doWaitForObject $para $initialValue 1 0xffffffff $TTId
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#function to check the status of the LEDs on the device (softstarter / drive)
#LedID : The ID of the LED to check ("STATUS" / "WARNING_ERROR" / "COM" ...)
#expectedColor : The expected color on the LED ("GREEN" / "YELLOW" / "RED")
#expectedStatus : The expected status of the LED ("OFF" / "ON" / "FLASHING" / "BLINKING")
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 270821 Yahya    proc created
#END----------------------------------------------------------------
proc checkLEDStatus { LedID expectedColor expectedStatus } {
    switch -exact $LedID {
	"STATUS" { set ID 0}
	"WARNING_ERROR" { set ID 1}
	"ASF" 	{ set ID 2}
	"COM" 	{ set ID 3}
	"NET1" 	{TlError "Incomplete implementation: LedID to be checked on drive"; return}
	"NET2" 	{TlError "Incomplete implementation: LedID to be checked on drive"; return}
	"NET3" 	{TlError "Incomplete implementation: LedID to be checked on drive"; return}
	"NET4" 	{TlError "Incomplete implementation: LedID to be checked on drive"; return}
	"UAP" 	{TlError "Incomplete implementation: LedID to be checked on drive"; return}
	default {TlError "Wrong input : $LedID"; return}
    }

    switch -exact $expectedColor {
	"GREEN" 	{ set expColor 01}
	"YELLOW" 	{ set expColor 02}
	"RED" 	{ set expColor 03}
	default {TlError "Wrong input : $expectedColor"; return}
    }

    switch -exact $expectedStatus {
	"OFF" 	{ set expStatus 00; set expColor 00}
	"ON" 	{ set expStatus 01}
	"FLASHING" 	{ set expStatus 02}
	"BLINKING" 	{ set expStatus 03}
	default {TlError "Wrong input : $expectedStatus"; return}
    }

    set LED [ATVGetLEDstatus]

    set status [lindex [lindex $LED 0 ] $ID]
    set color [lindex [lindex $LED 1 ] $ID]	

    if { $expStatus != $status || $expColor != $color } {
	TlError "LED status is not as expected, expected : status=$expectedStatus color=$expectedColor, actual : status=$status color=$color "
    } else {
	TlPrint "LED status is as expected, status=$expectedStatus color=$expectedColor"
    }
}

# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 100723  Yahya    proc created
# 180823  Yahya    Added TTId input argument
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Check product serial number
#read the product serial number (from CxP1 to CxPA) and checks that the results has the proper format
# \param[in] cardIndex: root of the register you want to read the serial nomber from. C1P for registers C1Px, etc
# \param[in] TTId: reference to a GEDEC if necessary
# Returns 1 if the formating is correct. throws up an error otherwise
#E.g. Use < checkProductSerialNumber C1P > to check if the serial number of product card 1 has the correct format (C1P1 to C1PA)
proc checkProductSerialNumber { cardIndex {TTId ""} } {
    global ActDev DevAdr
    set TTId [Format_TTId $TTId]
    set charMap { 10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H }
    #Check that cardIndex is one capital letter and 1 digit
    if { [regexp \[A-Z\]{1}\\d{1} $cardIndex] == 0 } {
	TlError "Wrong input"
	return 0
    }

    set param $cardIndex
    set result ""

    #read all the data
    for {set i 1} {$i <= 10 } {incr i} {
	set value [format %02X [TlRead $param[string map $charMap $i]]]
	foreach char [regexp -all -inline .{2} $value ] {
	    append result [format %c [scan $char %x ]]
	}
    }
    TlPrint "serial number (${cardIndex}x) : $result"
    #Check the part number
    set plantCode [string range $result 0 1 ]
    set yearNumber [string range $result 2 3 ]
    set weekNumber [string range $result 4 5 ]
    set dayOfTheWeek [string range $result 6 6 ]
    set manufacturingLineNumber [string range $result 7 9 ]
    set uniqueProductNumber [string range $result 10 14 ]

    if { [regexp \[a-zA-Z0-9\]{2} $plantCode] != 1 } { TlError "$TTId Plant code incorrect : $plantCode" }
    if { [regexp \\d{2} $yearNumber] != 1 } { TlError "$TTId Year Number incorrect : $yearNumber" }
    if { [regexp \\d{2} $weekNumber] != 1 || $weekNumber > 53 || $weekNumber < 1 } { TlError "$TTId Week Number incorrect : $weekNumber" }
    if { [regexp \\d{1} $dayOfTheWeek] != 1 || $dayOfTheWeek > 7 || $dayOfTheWeek < 1 } { TlError "$TTId Day of the week incorrect : $dayOfTheWeek" }
    if { [regexp \\d{3} $manufacturingLineNumber] != 1 } { TlError "$TTId manufacturing line number incorrect : $manufacturingLineNumber" }
    if { [regexp \\d{5} $uniqueProductNumber] != 1 || [regexp \\w [string range $result 15 end ]] == 1 } { TlError "$TTId unique product Number incorrect : $uniqueProductNumber" }
    return 1
}


# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 210201 ASY      proc created
# 120723 Yahya	  moved proc to ATS_lib and added more info in error logs generated
# 180823 Yahya    Added TTId input argument
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Check card serial number
#read the card serial number (from CxN1 to CxNA) and checks that the results has the proper format
# \param[in] cardIndex: root of the register you want to read the serial nomber from. C1N for registers C1Nx, S1N for registers S1Nx etc
# \param[in] TTId: reference to a GEDEC if necessary
# Returns 1 if the formating is correct. throws up an error otherwise
#E.g. Use < checkCardSerialNumber C1N > to check if the serial number of card 1 has the correct format (C1N1 to C1NA)
#END-------------------------------------------------------------------
proc checkCardSerialNumber { cardIndex {TTId ""} } {
    global ActDev DevAdr
    set TTId [Format_TTId $TTId]
    set charMap { 10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H }
    #Check that cardIndex is one capital letter and 1 digit
    if { [regexp \[A-Z\]{1}\\d{1} $cardIndex] == 0 } {
	TlError "Wrong input"
	return 0
    }
    #create the frame to send in order to read the 10 words at once

    set param $cardIndex
    set result ""

    #read all the data
    for {set i 1} {$i <= 10 } {incr i} {
	set value [format %02X [TlRead $param[string map $charMap $i]]]
	foreach char [regexp -all -inline .{2} $value ] {
	    append result [format %c [scan $char %x ]]
	}
    }
    TlPrint "serial number (${cardIndex}x) : $result"
    #Check the part number
    set partNumber [string range $result 0 7 ]
    set revisionNumber [string range $result 8 9 ]
    set plantCode [string range $result 10 11 ]
    set yearNumber [string range  $result 12 13 ]
    set weekNumber [string range $result 14 15 ]
    set sequenceNumber [string range $result 16 end ]
    if { [regexp \[a-zA-Z\]{3}\[0-9\]{5} $partNumber] != 1 } { TlError "$TTId Part Number incorrect : $partNumber" }
    if { [regexp \[0-9\]{2} $revisionNumber] != 1 } { TlError "$TTId Revision Number incorrect : $revisionNumber" }
    if { [regexp \[0-9a-zA-Z\]{2} $plantCode] != 1 } { TlError "$TTId Plant code incorrect : $plantCode" }
    if { [regexp \\d{2} $yearNumber] != 1 } { TlError "$TTId Year Number incorrect : $yearNumber" }
    if { [regexp \\d{2} $weekNumber] != 1 || $weekNumber > 53 || $weekNumber < 1} { TlError "$TTId Week Number incorrect : $weekNumber" }
    if { [regexp \\w{4} $sequenceNumber] != 1 } { TlError "$TTId Sequence Number incorrect : $sequenceNumber" }
    return 1
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Returns 1 if the ActDev is powered on either by CL1/CL2 or by 24V and 0 otherwise
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 301023 ASY    proc created
#
#END----------------------------------------------------------------
## Function description : Returns 1 if the ActDev is powered on either by CL1/CL2 or by 24V and 0 otherwise
#
# E.G. use < set status [isActDevSupplied]> to get the status of the device in the status variable. 
proc isActDevSupplied { } {
    global ActDev

    set CtrlSupply_PLC_Register1 1007							;# identify the PLC register to control the right output
    set CtrlSupply_PLC_Bit1 0
    set CtrlSupply_PLC_Register2 1007
    set CtrlSupply_PLC_Bit2 8
    set CtrlSupply_PLC_Register3 1008
    set CtrlSupply_PLC_Bit3 0


    set SepSupply_PLC_Register1 1007							;# identify the PLC register to control the right output
    set SepSupply_PLC_Bit1 6
    set SepSupply_PLC_Register2 1007							;# identify the PLC register to control the right output
    set SepSupply_PLC_Bit2 14
    set SepSupply_PLC_Register3 1008							;# identify the PLC register to control the right output
    set SepSupply_PLC_Bit3 6

    set Result_Ctrl [wc_TCP_ReadWord [subst $[subst CtrlSupply_PLC_Register$ActDev ]] 1]
    set Mask_Ctrl [ expr round(pow(2,[subst $[subst CtrlSupply_PLC_Bit$ActDev]]))]

    set Result_Sep [wc_TCP_ReadWord [subst $[subst SepSupply_PLC_Register$ActDev]] 1]
    set Mask_Sep [ expr round(pow(2,[subst $[subst SepSupply_PLC_Bit$ActDev]]))]

    set IntVar [expr ($Result_Ctrl & $Mask_Ctrl) || ($Result_Sep & $Mask_Sep)]
    return $IntVar
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Reads FFT146_Status&Alarm_Synthesis.xlsx file and initializes global variables/registers for alarms
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
# 180124 Yahya	  Removed ALR2 register for ATS490 following GED-95999 (see Issue #1598)
# 290324 Yahya	  Removed ALR2 register for ATS490 in RFV7 release (see Issue #1846 for details)
# 020424 Yahya	  Added alarm register 10 (ALRA) to AlarmRegList for ATS490 & ATS430 (see Issue #1855)
# 030424 Yahya	  Changed data source file from Excel to CSV (see Issue #1282)
#
#END----------------------------------------------------------------
## Function description : Reads FFT146_Status&Alarm_Synthesis.xlsx file and initializes global variables/registers for alarms
#
proc FFT146_AlarmManagement_Init { } {
    global ActDev EventIDList AlarmRegList EventIDAlwaysList NUMBER_OF_ALR_GROUPS EventIDFullList
    set NUMBER_OF_ALR_GROUPS 5

    FFT146_AlarmManagement_ReadFromCSV
	
    if {[GetDevFeat "ATS48P"] } {
	set EventIDList [list "INH" "OLA" "EFA"] ;#EventID that i can generate an alarm with UniFast
	set EventIDAlwaysList    [FFT146_AlarmManagement_SetList ATS48P Always] ;#EventID that is Always Alarm type
	set EventIDFullList    [FFT146_AlarmManagement_SetList ATS48P Alarm] ;#EventID that is  Alarm type
	set AlarmRegList [list 3 4 6 7 9] ;#Available alarm registers

    } elseif {[GetDevFeat "BASIC"]  } {
	set EventIDList [list "INH" "EFA"] ;#EventID that i can generate an alarm with UniFast
	set EventIDAlwaysList    [FFT146_AlarmManagement_SetList BASIC Always] ;#EventID that is Always Alarm type
	set EventIDFullList    [FFT146_AlarmManagement_SetList BASIC Alarm] ;#EventID that is  Alarm type
	set AlarmRegList [list 3 4 6 9 A] ;#Available alarm registers

    } elseif {[GetDevFeat "OPTIM"] } {
	set EventIDList [list "INH" "EFA"] ;#EventID that i can generate an alarm with UniFast
	set EventIDAlwaysList    [FFT146_AlarmManagement_SetList OPTIM Always] ;#EventID that is Always Alarm type
	set EventIDFullList    [FFT146_AlarmManagement_SetList OPTIM Alarm] ;#EventID that is  Alarm type
	set AlarmRegList [list 1 3 4 5 6 7 9 A] ;#Available alarm registers

    } else {
	TlError "ATS48 ATS48P OPTIM and BASIC allowed"
    }

}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Checks an alarm status (active or not)
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Checks an alarm status (active or not)
#
# E.G. use < FFT146_AlarmManagement_CheckAlarmStatus EFA 1 > to check that alarm EFA is active.
proc FFT146_AlarmManagement_CheckAlarmStatus {EventID status {TTId ""}} {
    global AlarmReg  StatusReg Alarmbit Statusbit FFT146_AlarmMask FFT146_StatusMask
    FFT146_AlarmManagement_ConfigAlarm $EventID

    doWaitMs 500
    switch $status {
	1 {

	    TlPrint ""
	    TlPrint "$EventID :check ALR$AlarmReg.b$Alarmbit is 1,  ST$StatusReg.b$Statusbit is 1 "
	    doWaitForModObject  ALR$AlarmReg $FFT146_AlarmMask 1 $FFT146_AlarmMask $TTId
	    doWaitForModObject  ST$StatusReg $FFT146_StatusMask 1 $FFT146_StatusMask $TTId

	}
	0 {
	    TlPrint ""
	    TlPrint "$EventID :check ALR$AlarmReg.b$Alarmbit is 0 , ST$StatusReg.b$Statusbit is 0"
	    doWaitForModObject  ALR$AlarmReg 0x0000 1 $FFT146_AlarmMask $TTId
	    doWaitForModObject  ST$StatusReg 0x0000 1 $FFT146_StatusMask $TTId
	}
	default {
	    TlError "status : $status shall be 0 or 1"

	}
    }

}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Generates an alarm
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Generates an alarm
#
# E.G. use < FFT146_AlarmManagement_GenerateAlarm "EFA" > to generate EFA alarm.
proc FFT146_AlarmManagement_GenerateAlarm { EventID } {
    global  ERROR_INHIBITION_ASSIGNMENT_ID EXTERNAL_ERROR_ASSIGNMENT_ID EventIDName
    TlPrint "--------------------active  alarm EventID : $EventID"
    switch $EventID {
	"INH" {

	    DIAssigne 3  EXTERNAL_ERROR_ASSIGNMENT_ID
	    DIAssigne 4  ERROR_INHIBITION_ASSIGNMENT_ID

	    setDI 4 H

	}
	"OLA" {
	    if {[GetDevFeat "ATS48P"] } {
		TlWrite ODLA .YES
		TlWrite ODL .NO
		TlWrite TOL 5

		set offset 2
		set updateLoad 300
		TlWrite LOC 60
		set LOCValue [TlRead LOC]
		set  threshold [expr [expr $LOCValue - $offset] * 10  ]
		LoadOn
		TlPrint "--------------------SET LoadVelocity 0 $updateLoad"
		LoadVelocity 0 $updateLoad

		setDI 1 H
		setDI 2 H
		#check O_ETI2.b6=0
		doWaitForObject O_ETI2 0x0000 1 0x40

		doWaitForObjectList HMIS {.RUN .BYP} [expr [TlRead ACC] *1.5]

		doWaitMs 1000

		set  slowOk 0

		while {[Enum_Name HMIS [TlRead HMIS] ] != "FLT"  && $updateLoad < 1800 } {
		    #print one dot per second (still alive!!)
		    puts -nonewline "."
		    flush  stdout
		    #wait until  O_ETI2.b6=1
		    if { [expr [TlRead O_ETI2] & 0x40 ]== 0x40  } {
			set stopOCR [TlRead OCR]
			TlPrint " ===================   REACHED !!!!!!!!!!!!!!!! O_ETI2.b6=1    ========================"
			puts "" ;# linebreak for the status graph
			break
		    } else {
			TlPrint " "
			TlPrint " O_ETI2.b6=0"
			TlPrint "OCR is [expr [TlRead OCR] * 0.1] %, LOC over load limite current is $LOCValue "
			TlPrint "LTR is [TlRead LTR], S_LUL under load limite is [TlRead S_LUL] "
		    }
		    #set updateLoad and  waittime variable

		    if { $slowOk !=1 && [TlRead OCR]  < [expr  $LOCValue *10* 0.94 ] } {
			set  multi 3

		    } else  {

			set multi 0
			set slowOk 1
			if { $slowOk !=1 && [TlRead OCR]  < [expr  $LOCValue *10* 0.97 ] } {

			} else {

			}

		    }
		    set updateLoad [expr $updateLoad+ 10  + 10 * $multi]
		    TlPrint "--------------------SET LoadVelocity 0 $updateLoad"
		    LoadVelocity 0 $updateLoad
		    doWaitMs 500
		    set loadthreshold $updateLoad

		}
		for {set i 0 } {$i<10 } { incr i} {
		    TlPrint "OCR is [expr [TlRead OCR] * 0.1] %, LOC over load limite current is $LOCValue "
		    TlPrint "LTR is [TlRead LTR], S_LUL under load limite is [TlRead S_LUL] "
		    set loadvalue [expr $loadthreshold+20 * $i]
		    LoadVelocity 0 $loadvalue
		    #  check O_ETI2.b6=1
		    doWaitForObject O_ETI2 0x40 2 0x40
		}

	    } else {
		TlPrint "OLA not available for  ATS48PT and BASIC"
	    }

	}
	"EFA" {
	    if { [Enum_Name  HMIS [expr [TlRead HMIS]]] == "ACC" || [Enum_Name  HMIS [expr [TlRead HMIS]]] == "RUN" } {
		TlPrint "LI3 shall be assigned to $EXTERNAL_ERROR_ASSIGNMENT_ID before "
		setDI 3 H
	    } else {
		DIAssigne 3  EXTERNAL_ERROR_ASSIGNMENT_ID

		setDI 3 H
	    }

	}
	default {
	    TlError "Function not defined for Alarm Register $EventID"

	}
    }

}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Clears (deactivates) an alarm
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Clears (deactivates) an alarm
#
# E.G. use < FFT146_AlarmManagement_ClearAlarm "EFA" > to clear EFA alarm.
proc FFT146_AlarmManagement_ClearAlarm { EventID } {

    global  ERROR_INHIBITION_ASSIGNMENT_ID EXTERNAL_ERROR_ASSIGNMENT_ID EventIDName
    TlPrint "--------------------clear alarm EventID : $EventID"
    switch $EventID {
	"INH" {
	    setDI 4 L
	}
	"OLA" {
	    if {[GetDevFeat "ATS48P"] } {
		LoadOff
		setDI 1 L
		setDI 2 L
	    }
	} else {
	    TlPrint "OLA not available for  ATS48PT and BASIC"
	}
	"EFA" {
	    setDI 3 L
	}
	default {
	    TlError "Function not defined for Alarm Register $EventID"
	}
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Checks the consistency of alarm groups status Vs general alarm status
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Checks the consistency of alarm groups status Vs general alarm status
#
proc FFT146_AlarmManagement_CheckGroupConsistency {  {onlyprint 0} }  {
    global  AlarmRegList NUMBER_OF_ALR_GROUPS

    TlPrint ""
    TlPrint "----- Check alarm groups -----"
    for {set Group 1} {$Group <= $NUMBER_OF_ALR_GROUPS} {incr Group} {
	if {[CheckBreak]} {break}
	set GrpLine$Group "Group$Group"

	foreach Reg $AlarmRegList {

	    if {[CheckBreak]} {break}
	    set "AG$Group$Reg" [TlRead "AG$Group$Reg"]
	    #    TlPrint "AG$Group$Reg is [subst $[subst AG$Group$Reg]] "
	    append GrpLine$Group " 0x[format %04X [subst $[subst AG$Group$Reg]]]"
	    # TlPrint "GrpLine$Group is [subst $[subst GrpLine$Group]] "
	}
    }
    set GrpLine0 "        "
    set GrpLine6 "        "
    set GrpLineEnd "ALRx  "
    foreach Reg $AlarmRegList {
	if {[CheckBreak]} {break}
	set "ALR$Reg" [TlRead "ALR$Reg"]
	#TlPrint "ALR$Reg is [subst $[subst ALR$Reg]]"
	append GrpLine0 " Reg$Reg  "
	append GrpLine6 " ALR$Reg  "
	append GrpLineEnd " 0x[format %04X [subst $[subst ALR$Reg]]]"
    }

    TlPrint $GrpLine0
    TlPrint $GrpLine1
    TlPrint $GrpLine2
    TlPrint $GrpLine3
    TlPrint $GrpLine4
    TlPrint $GrpLine5
    TlPrint $GrpLine6
    TlPrint $GrpLineEnd

    if {$onlyprint == 0 } {
	set AGS [TlRead "AGS"]
	TlPrint "AGS: 0x[format %04X $AGS]"

	set ST07 [TlRead "ST07"]
	TlPrint "ST07: 0x[format %04X $ST07]"

	set ETA [TlRead "ETA"]
	TlPrint "ETA: 0x[format %04X $ETA]"

	TlPrint "------------------------------"

	set SummAll 0
	for {set Group 1} {$Group <= $NUMBER_OF_ALR_GROUPS} {incr Group} {
	    if {[CheckBreak]} {break}
	    set SummGroup 0
	    foreach Reg $AlarmRegList {
		if {[CheckBreak]} {break}
		# logical AND of alarm register and alarm group register (mask)
		set tmp [expr [subst $[subst ALR$Reg]] & [subst $[subst AG$Group$Reg]] ]
		#TlPrint "tmp is $tmp"
		incr SummGroup $tmp
		#TlPrint "SummGroup is $SummGroup"
	    }
	    set mask [expr 1 << [expr $Group -1]]
	    incr SummAll $SummGroup
	    # TlPrint "SummAll is $SummAll"
	    if {$SummGroup != 0} {
		checkValueMask "AGS Bit of Group$Group" $AGS $mask $mask
		checkValueMask "ST07 Bit of Group$Group" $ST07 $mask $mask
	    } else {
		checkValueMask "AGS Bit of Group$Group" $AGS 0 $mask
		checkValueMask "ST07 Bit of Group$Group" $ST07 0 $mask
	    }
	}

	if {$SummAll != 0} {
	    checkValueMask "ETA Bit 7" $ETA 0x80 0x80
	} else {
	    checkValueMask "ETA Bit 7" $ETA 0 0x80
	}

	TlPrint "------------------------------"
	TlPrint ""
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Adds an alarm to an alarms group
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Adds an alarm to an alarms group
#
# E.G. use < FFT146_AlarmManagement_AddToGroup "EFA" 1 > to add EFA alarm to alarm group 1.
proc FFT146_AlarmManagement_AddToGroup { EventID GroupID} {
    global AlarmReg  StatusReg Alarmbit Statusbit FFT146_AlarmMask FFT146_StatusMask
    
    FFT146_AlarmManagement_ConfigAlarm $EventID
    TlPrint ""
    TlPrint "-----------------------------------------add $EventID : ALR$AlarmReg.b$Alarmbit to Group $GroupID"

    set OldAG  [TlRead  AG$GroupID$AlarmReg]
    TlPrint "Old  AG$GroupID$AlarmReg is $OldAG"
    set NewAG [expr $OldAG | $FFT146_AlarmMask]
    TlPrint "set New  AG$GroupID$AlarmReg to $NewAG"

    #check EventID can be added to new group
    TlWrite AG$GroupID$AlarmReg $NewAG
    doWaitForObject AG$GroupID$AlarmReg $NewAG 1
    FFT146_AlarmManagement_CheckGroupConsistency 1 ;# only print the value of alarm group
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Removes an alarm from an alarms group
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Removes an alarm from an alarms group
#
# E.G. use < FFT146_AlarmManagement_RemoveFromGroup "EFA" 1 > to remove EFA alarm grom alarm group 1.
proc FFT146_AlarmManagement_RemoveFromGroup { EventID GroupID} {
    global AlarmReg  StatusReg Alarmbit Statusbit FFT146_AlarmMask FFT146_StatusMask
    FFT146_AlarmManagement_ConfigAlarm $EventID
    TlPrint ""
    TlPrint "-----------------------------------------remove $EventID : ALR$AlarmReg.b$Alarmbit from Group $GroupID"

    set OldAG  [TlRead  AG$GroupID$AlarmReg]
    TlPrint "Old  AG$GroupID$AlarmReg is $OldAG"
    set NewAG [expr $OldAG & ~$FFT146_AlarmMask]
    TlPrint "set New  AG$GroupID$AlarmReg to $NewAG"

    #check EventID can be removed  from the group
    TlWrite AG$GroupID$AlarmReg $NewAG
    doWaitForObject AG$GroupID$AlarmReg $NewAG 1
    FFT146_AlarmManagement_CheckGroupConsistency 1 ;# only print the value of alarm group
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#Read from CSV file FFT146_Status&Alarm_Synthesis_ATLAS.csv, and save 4 types tables : full EventID, EventID only for ATS48P, only for OPTIM and only for BASIC
#For each type, we have : EventID  Type
#                        EventID  STxx
# 			EventID  Status bit
# 			EventID ALRxx.bxx
#
# IMPORTANT NOTE : 
# Design team delivers an Excel file (FFT146_Status&Alarm_Synthesis_ATLAS.xlsx)
# This file is then converted to CSV manually (open the Excel file with Excel application, 
# then save it as CSV file without doing any modification on it)
# The output CSV file is the one used here to get data from
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
# 290324 Yahya	  Changed data source file from Excel to CSV (see Issue #1282)
#
#END----------------------------------------------------------------
proc FFT146_AlarmManagement_ReadFromCSV {} {
    global mainpath EventIDList
    global ATS48PTypeRecord_Table ATS48PALRRecord_Table ATS48PSTRecord_Table ATS48PST_bitRecord_Table
    global OPTIMTypeRecord_Table OPTIMALRRecord_Table OPTIMSTRecord_Table OPTIMST_bitRecord_Table
    global BASICTypeRecord_Table BASICALRRecord_Table BASICSTRecord_Table BASICST_bitRecord_Table
    global ATSTypeRecord_Table ATSALRRecord_Table ATSSTRecord_Table ATSST_bitRecord_Table


    TlPrint "Reading FFT146_Status&Alarm_Synthesis.csv in progress..."

    # Set the path to your CSV file.
    set csvFilePath $mainpath/ObjektDB/FFT146_Status&Alarm_Synthesis.csv

    set csvData [getDataFromCSVConvertedFromExcel $csvFilePath 0 0]

    # Read all the values in column A
    set rowDataStart 5 ;#Row at which the data we want to read starts
    set end 0

    for { set rowCount $rowDataStart } { $rowCount <= [llength $csvData] } { incr rowCount } {

	set EventIDValue [getCellValue $csvData $rowCount N]

	if {  $EventIDValue == "EMPTY_FIELD"  } {
	    continue
	}

	set ATS48PYes_No   [getCellValue $csvData $rowCount B]
	set OPTIMYes_No  [getCellValue $csvData $rowCount C]
	set BASICYes_No  [getCellValue $csvData $rowCount D]

	if {  $ATS48PYes_No == "No" && $OPTIMYes_No == "No" && $BASICYes_No == "No"} {
	    continue
	}

	if {  $ATS48PYes_No == "" && $OPTIMYes_No == "" && $BASICYes_No == ""} {
	    continue
	}

	set StatusValue [getCellValue $csvData $rowCount M]
	set TypeValue [getCellValue $csvData $rowCount U]
	set AlarmValue [getCellValue $csvData $rowCount V]
	set StatusBitValue [expr int([getCellValue $csvData $rowCount O])]

	#Full list
	set ATSTypeRecord_Table($EventIDValue) $TypeValue
	set ATSALRRecord_Table($EventIDValue) $AlarmValue
	set ATSSTRecord_Table($EventIDValue) $StatusValue
	set ATSST_bitRecord_Table($EventIDValue) $StatusBitValue

	if {   $ATS48PYes_No == "Yes"} {
	    set ATS48PTypeRecord_Table($EventIDValue) $TypeValue
	    set ATS48PALRRecord_Table($EventIDValue) $AlarmValue
	    set ATS48PSTRecord_Table($EventIDValue) $StatusValue
	    set ATS48PST_bitRecord_Table($EventIDValue) $StatusBitValue
	}

	if {   $OPTIMYes_No == "Yes"} {
	    set OPTIMTypeRecord_Table($EventIDValue) $TypeValue
	    set OPTIMALRRecord_Table($EventIDValue) $AlarmValue
	    set OPTIMSTRecord_Table($EventIDValue) $StatusValue
	    set OPTIMST_bitRecord_Table($EventIDValue) $StatusBitValue
	}
	if {   $BASICYes_No == "Yes"} {
	    set BASICTypeRecord_Table($EventIDValue) $TypeValue
	    set BASICALRRecord_Table($EventIDValue) $AlarmValue
	    set BASICSTRecord_Table($EventIDValue) $StatusValue
	    set BASICST_bitRecord_Table($EventIDValue) $StatusBitValue
	}
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#return a list EventID list in fonction of DUT and event type
#Type : "Always" return full list of alarms which are set to group 1 by defaut
#Type : "Alarm" return full list of alarms
#Type : "Status" return full list of only status (EventID which has no ALRxx.bxx)
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
proc FFT146_AlarmManagement_SetList { DUT Type } {
    global ATS48PTypeRecord_Table ATS48PALRRecord_Table ATS48PSTRecord_Table ATS48PST_bitRecord_Table
    global OPTIMTypeRecord_Table OPTIMALRRecord_Table OPTIMSTRecord_Table OPTIMST_bitRecord_Table
    global BASICTypeRecord_Table BASICALRRecord_Table BASICSTRecord_Table BASICST_bitRecord_Table
    global ATSTypeRecord_Table ATSALRRecord_Table ATSSTRecord_Table ATSST_bitRecord_Table
    set  ATS_TypeList ""

    if {   $DUT == "ATS48P"} {
	set IDList [array names ATS48PTypeRecord_Table]
    } elseif { $DUT == "OPTIM" } {
	set IDList [array names OPTIMTypeRecord_Table]
    } elseif {  $DUT == "BASIC" } {
	set IDList [array names BASICTypeRecord_Table]
    } else {
	TlError "$DUT not supported"
    }

    for {set i 0} { $i < [llength $IDList] } { incr i } {
	if {[string match "*$Type*" [set [subst $DUT]TypeRecord_Table([lindex $IDList $i]) ] ]  } {
	    lappend ATS_TypeList  [lindex $IDList $i]
	}
    }
    puts "for $DUT ,ATS_TypeList $Type is $ATS_TypeList ,length is  [llength $ATS_TypeList]"
    return $ATS_TypeList
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#find the right number of ALR, ST and ALR bit, ST bit for the EventID
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
# 020424 Yahya	  Updated scan specifiers for ALRx (see Issue #1855)
#
#END----------------------------------------------------------------
proc FFT146_AlarmManagement_ConfigAlarm { EventID} {
    global ATSTypeRecord_Table ATSALRRecord_Table ATSSTRecord_Table ATSST_bitRecord_Table EventIDName

    global AlarmReg  StatusReg Alarmbit Statusbit FFT146_AlarmMask FFT146_StatusMask EventIDName EventIDList
    set EventIDName  $EventID

    if { $ATSTypeRecord_Table($EventID) != "Status" } {; #Check for column V != Status
	#ALR parameter
	set ALR $ATSALRRecord_Table($EventID)
	set wordList [split $ALR "."]; #Parameter like : ALRxx.xx
	set ALRx [lindex $wordList 0]
	set ALRBit [lindex $wordList 1]

	#set AlarmReg
	set name $ALRx
	scan $name {%3[a-zA-Z]%1[0-9a-fA-F]} word num
	set AlarmReg $num

	#set StatusReg
	set name $ATSSTRecord_Table($EventID)
	scan $name {%[a-zA-Z]%d} word num
	set StatusReg $num
	
	#set Alarmbit
	if { [ regexp {^([0-9]+)$} $ALRBit ] } {
	    #if is only number
	    set Alarmbit $ALRBit
	} else {
	    set name $ALRBit
	    scan $name {%[a-zA-Z]%d} word num
	    set Alarmbit $num
	}

	#set Statusbit
	set Statusbit $ATSST_bitRecord_Table($EventID)

	set FFT146_AlarmMask [format 0x%04X  [expr 2**$Alarmbit] ]
	set FFT146_StatusMask [format 0x%04X  [expr 2**$Statusbit] ]
	TlPrint "type $ATSTypeRecord_Table($EventID) , $EventID is ALR$AlarmReg.b$Alarmbit , ST$StatusReg.b$Statusbit"
	    
    } else {; #Check for column V == status
	#for type status ID
	set AlarmReg 0
	set Alarmbit 0
	#set StatusReg
	set name $ATSSTRecord_Table($EventID)
	scan $name {%[a-zA-Z]%d} word num
	set StatusReg $num

	#set Statusbit
	set Statusbit $ATSST_bitRecord_Table($EventID)

	set FFT146_StatusMask [format 0x%04X  [expr 2**$Statusbit] ]
	TlPrint "type $ATSTypeRecord_Table($EventID), $EventID is  ST$StatusReg.b$Statusbit"
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# proc to select if we write SER = LAC or SMOD = YES depending on the FW version
# Inputs are LACValue and disable (if you want to disable SMOD, by default 0)
#
# ----------HISTORY------------------------------------------------
# WHEN			WHO			WHAT
# 04/12/2023	Kilian		proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : Write LAC = SER for FW before RC1 or write SMOD = YES starting from FW version RC1 and above
# \param[in] LACValue: LAC value wanted by default STD
# \param[in] disable: Parameter to disable SMOD in order to prevent fail due to loop in the scripts
proc writeLACValue { {LACValue "STD"} {disable 0} } {
	global theNERAenumListRecord
	#Parameter to check in the Enum list
	set parameter "SMOD"
	if {$disable == 0} {
		if {$LACValue == "SER"} {; #If we try to write LAC = SER
			#Check Enum list to verify existance of SMOD
			set rc [catch {set EnumList $theNERAenumListRecord($parameter) }]
			if {$rc != 0} {; #If don't exists then LAC = SER
				TlWrite LAC .SER
				doWaitForObject LAC .SER 1
			} else {; #If exists then SMOD = YES
				TlWrite SMOD .YES
				doWaitForObject SMOD .YES 1
			}
		} else {; #If we try to write LAC != SER
			set rc [catch {set EnumList $theNERAenumListRecord($parameter) }]
			if {$rc == 0} {; #Take care of SMOD before setting LAC, prevent fails
				TlWrite SMOD .NO
				doWaitForObject SMOD .NO 1
			}
			TlWrite LAC .$LACValue
			doWaitForObject LAC .$LACValue 1
		}
	} else {
		set rc [catch {set EnumList $theNERAenumListRecord($parameter) }]
		if {$rc == 0} {; #If SMOD exists
			TlWrite SMOD .NO
			doWaitForObject SMOD .NO 1
		}
	}
}
