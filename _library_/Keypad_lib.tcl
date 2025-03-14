global KpdAccess kpdKeyAction kpdKeyAct kpdScrAct kpdScr0 kpdScr1 kpdScr2 kpdScrStr kpdScrStrSet kpdScrStr2 kpdTouch
set KpdAccess "F844"
set kpdKeyAct "03"
set kpdScrAct "08"
set kpdScrStrSet "0E"
set kpdScr0 "070F00"
set kpdScr1 "020600"
set kpdScr2 "050300"
set kpdScrStr "0F00010502"
set kpdScrStr2 "0F000205020403"

#tag for doc
## \file Keypad_lib.tcl

##History :
# xx/xx/xx a&c file creation
# 22/07/11 ASY	update for multitouch

#Create the array that will contain the data for the multitouch
set kpdTouch(Ok,field)  0
set kpdTouch(Ok,value) 0x0010
set kpdTouch(Esc,field) 0
set kpdTouch(Esc,value) 0x0020
set kpdTouch(Home,field) 0
set kpdTouch(Home,value) 0x0040
set kpdTouch(Up,field) 0
set kpdTouch(Up,value) 0x8100
set kpdTouch(F1,field) 0
set kpdTouch(F1,value) 0x0001
set kpdTouch(F2,field) 0
set kpdTouch(F2,value) 0x0002
set kpdTouch(F3,field) 0
set kpdTouch(F3,value) 0x0004
set kpdTouch(F4,field) 0
set kpdTouch(F4,value) 0x0008
set kpdTouch(Info,field) 0
set kpdTouch(Info,value) 0x0080
set kpdTouch(Down,field) 0
set kpdTouch(Down,value) 0x0100
set kpdTouch(Stop,field) 1
set kpdTouch(Stop,value) 0x0000
set kpdTouch(Run,field) 2
set kpdTouch(Run,value) 0x0000
set kpdTouch(L/R,field) 4
set kpdTouch(L/R,value) 0x0000
set kpdTouch(No,field) 0
set kpdTouch(No,value) 0x0000

proc readWBS_PWD { } {
    global KpdAccess kpdScrAct kpdScr2
    if { [ InitKeypad  0 ] } {
	set result [ Keypad_Read "MYP|WBS|WDPE" ]
	set result [string range $result 1 8 ]
	TlPrint "result : $result "
	return $result
    }
}

proc WriteCyberParameter { value } {
    global KpdAccess kpdScrAct kpdScr2
    if { [ InitKeypad  0 ] } {
	keypad_Home 0
	keypad_Down 6 0
	keypad_OK 0
	doWaitMs 100
	keypad_OK 0
	keypad_Down 2 0
	keypad_OK 0
	keypad_Down 6 0

    }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# initialisation phase of keypad simulation for Advanced keypad.
#
# E.g. Use < if {[InitKeypad 1]} { > to check that it's possible to connect( no keypad is already connected).
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c      proc created
# 310124 Yahya    Increased the timeout in the call of ATS430_waitEmbKPDForcedFinished to 11s (See Issue #1660)
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : initialisation phase of keypad simulation.
#
# \param[in] display: display the first screen data if set to 1 .
#
# \n
# E.g. Use < if {[InitKeypad 1]} { > to check that it's possible to connect( no keypad is already connected).
#

proc InitKeypad_old { { display 0 }} {
    if { $display  } { TlPrint "Initialization sequence" }
    if { [GetDevFeat "BASIC"] } { ATS430_waitEmbKPDForcedFinished 11000 }
    mbDirect F84400000A0000 1
    #initialization
    set result [expr [ format "0x%s" [string range [ mbDirect F84409000A656E3201 1 ] 6 7 ]]]
    if { $result == 1 } {
	mbDirect F8440A0F010246310202463203024633040246340503454E540603455343810453544F50820352554E0704484F4D4583024C520804494E464F0D034157550E034157440F0341574C1003415752 1
	mbDirect F844100C045254430004544142000544415348000543555256000649435552560006435553544F00044C4F470008424B4C4947485400065152434F44000856554D455445520006464D505631000743555256585900 1
	mbDirect F8440C0014020C081636B0 1
	mbDirect F8440E030000 1
	if { $display  } { 
	    TlPrint "Drive connected" 
	    displayFirstScreen $display
	}
	return 1
    }
    TlError "Keypad already connected"
    return 0
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# initialisation phase of keypad simulation for Advanced keypad.
#
# E.g. Use < if {[InitKeypad 1]} { > to check that it's possible to connect( no keypad is already connected).
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 20220810 ASY    proc created
# 20241002 ASY    update returned value
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : initialisation phase of keypad simulation.
# Data based of a recording of the start procedure for FORTIS
#
# \param[in] display: display the first screen data if set to 1 .
#
# \n
# E.g. Use < if {[InitKeypad 1]} { > to check that it's possible to connect( no keypad is already connected).
#
proc InitKeypad { { display 1 }} {
    if {[GetSysFeat "ATLAS"]} {
	InitKeypad_old $display
    } else {
	if { $display  } { TlPrint "Initialization sequence" }

	mbDirect F84400000A04004F49 0
	mbDirect F84409000A66723200C605 0
	mbDirect F8440A0F010246310202463203024633040246340503454E540603455343810453544F50820352554E0704484F4D4583024C520804494E464F0D034157550E034157440F0341574C10034157528786 0
	mbDirect F844100C045254430004544142000544415348000543555256000649435552560006435553544F00044C4F470008424B4C4947485400065152434F44000856554D455445520006464D505631000743555256585900FD2F 0
	#    mbDirect F8440C00000101112D4268A1EC 0
	mbDirect F8440300000000804B7E 0
	mbDirect F8440E0300001744 0
	mbDirect F8440300000000004ADE 0
	mbDirect F8440800010200DCEA 0
	mbDirect F8440801040200CD17 0
	mbDirect F86900DE61 0
	mbDirect F8690000220100004ADE80800000810000000008010000E52710C7155C49 0
	mbDirect F86900DE61 0
	mbDirect F86900002201C7154ADE00000000820100000006779D00000000A7A6 0
	mbDirect F86900DE61 0
	mbDirect F86900002201C7154ADE01010000870200000000C3E7 0
	mbDirect F86900DE61 0
	mbDirect F8440B00000000C84A 0
	mbDirect F86900002201C71500000202000084010000005D000000590000591052423637383335313735303630303737184772617068696320446973706C6179205465726D696E616C0856322E3049453533011000190A656E636E646565736672697472757472706C62726672535428000000D2ECD96C 0
	mbDirect F86900DE61  0
	mbDirect F86900002201C715000003030000C401818200003CA6  0
	mbDirect F86900DE61 0
	mbDirect F8440B00000000C84A 0
	mbDirect F86900002201C715000004040000C40181820000AB4C 0
	mbDirect F86900DE61 0
	mbDirect F86900002201C715000005050000870100010000203E 0
	mbDirect F86900DE61 0
	mbDirect F86900002201C7150000060600008301000000009485 0
	mbDirect F86900DE61 0
	mbDirect F86900DE61 0
	mbDirect F86900DE61 0
	mbDirect F86900DE61 0
	mbDirect F86900DE61 0
	return [displayFirstScreen 1]
	#    mbDirect F8440B00000000C84A 0
	#    keypad_Home
    }
}

proc Init_BasicKeypad { { display 1 }} {
    if { $display  } { TlPrint "Initialization sequence" }

    TlPrint [ mbDirect F84400000A0000 1 ]
    #initialization
    set result [expr [ format "0x%s" [string range [ mbDirect F844020000000080 1 ] 6 7 ]]]
    TlPrint $result
    if { $result == 4 } {
	#      mbDirect F844050900 1
	##      mbDirect F844100C045254430004544142000544415348000543555256000649435552560006435553544F00044C4F470008424B4C4947485400065152434F44000856554D455445520006464D505631000743555256585900 1
	##      mbDirect F8440C0014020C081636B0 1
	##      mbDirect F8440E030000 1
	#      if { $display  } { TlPrint "Drive connected" }
	#      displayFirstScreen $display
	#      return 1
    }
    return 0
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Manage the first screen with drive reference and power stage data.
#
# E.g. Use < displayFirstScreen 0 > to hide the monitoring of  the first screen.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
# 021024 ASY    update the returned value
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Manage the first screen with drive reference and power stage data.
#
# \param[in] display: 1 to show, 0 to hide.
#
# \n
# E.g. Use < displayFirstScreen 0 > to hide the monitoring of the first screen.
#
proc displayFirstScreen { { display 0 }} {
    global KpdAccess kpdScrStrSet kpdScrStr
    mbDirect F8440800010200 1
    if { $display } { TlPrint [ Hexa2Ascii [ mbDirect F8440801040200 1 ]]}

    while { [ mbDirect F8440800070F00 1 ] == "F844080000010002000504494E4900" } {
	if {[CheckBreak]} {break}
	kpd_Touch "No"
    }
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    if { $display } { return [displayScreenStatus 1] }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Monitoring of the current keypad screen.
#
# E.g. Use < displayScreen > to see what are the current screen data.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
# 021024 ASY    update the returned value
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Monitoring of the current keypad screen.
#
# \param[in] display: display the current screen data if set to 1.
# \n
# E.g. Use < displayScreen 1 > to see what are the current screen data.
#
proc displayScreen { {display 0} } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    set screen0 [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    set screen1 [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "01" $kpdScr1 ]  1 ]]
    set screen2 [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "02" $kpdScr2 ]  1 ]]
    if { $display != 0 } {
	TlPrint $screen0
	TlPrint $screen1
	TlPrint $screen2
    }
    return $screen2
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Monitoring of the current keypad screen.
#
# E.g. Use < displayScreenStatus > to see if the keypad is connected or not 
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 021024 ASY    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Monitoring of the current keypad status.
#
# \param[in] display: display the current screen data if set to 1.
# \n
# E.g. Use < displayScreenStatus 1 > to get the keypad status.
#
proc displayScreenStatus { {display 0} } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    set screen0 [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    set screen1 [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "01" $kpdScr1 ]  1 ]]
    set tempScreen2 [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "02" $kpdScr2 ]  1 ]
    set screen2 [ Hexa2Ascii $tempScreen2]
    if { $display != 0 } {
        TlPrint $screen0
        TlPrint $screen1
        TlPrint $screen2

    }
	if { [string range $tempScreen2 2 2] == "C"} {
		return 0
	} else {
		return 1
	}
}
#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Simulate key press .
#
# E.g. Use <  kpd_Touch "Ok"  > simulate press of button "Ok" .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Simulate key press .
#
# \param[in] key: button reference (Ok , Esc , Home , Up , F1 , F2 , F3 , F4 , Info , Down , Stop , Run , L/R , No  ) .
#
# \n
# E.g. Use <  kpd_Touch "Ok"  > simulate press of button "Ok" .
#
proc kpd_Touch_old { key  } {

    global KpdAccess kpdKeyAct
    switch $key {
	"Ok" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0010"] 1}
	"Esc" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0020"] 1}
	"Home" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0040"] 1}
	"Up" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "8100"] 1}
	"F1" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0001"] 1}
	"F2" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0002"] 1}
	"F3" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0004"] 1}
	"F4" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0008"] 1}
	"Info" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0080"] 1}
	"Down" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0100"] 1}
	"Stop" { mbDirect [format "%4s%2s01%4s0000" $KpdAccess $kpdKeyAct "0000"] 1}
	"Run" { mbDirect [format "%4s%2s02%4s0000" $KpdAccess $kpdKeyAct "0000"] 1}
	"L/R" { mbDirect [format "%4s%2s04%4s0000" $KpdAccess $kpdKeyAct "0000"] 1}
	"No" { mbDirect [format "%4s%2s00%4s0000" $KpdAccess $kpdKeyAct "0000"] 1}

    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Simulate key press .
#
# E.g. Use <  kpd_Touch2 "Ok"  > simulate press of button "Ok" .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 220711 ASY    proc created
#
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Simulate key press .
#
# \param[in] key: button reference (Ok , Esc , Home , Up , F1 , F2 , F3 , F4 , Info , Down , Stop , Run , L/R , No  ) .
#
# \n
# E.g. Use <  kpd_Touch2 "Ok"  > simulate press of button "Ok" .
#
proc kpd_Touch { key  } {

    global KpdAccess kpdKeyAct kpdTouch
    mbDirect [format "%4s%2s%02x%04x0000" $KpdAccess $kpdKeyAct $kpdTouch($key,field) $kpdTouch($key,value)] 1

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Simulate simultaneous key press .
#
# E.g. Use <  kpd_TouchList {"Ok" "Esc"}  > simulate press of button "Ok" and "Esc" .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 220711 ASY    proc created
#
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Simulate key press .
#
# \param[in] key: button reference (Ok , Esc , Home , Up , F1 , F2 , F3 , F4 , Info , Down , Stop , Run , L/R , No  ) .
#
# \n
# E.g. Use <  kpd_TouchList {"Ok" "Esc"}  > simulate press of button "Ok" and "Esc"
#
proc kpd_TouchList { keyList  } {

    global KpdAccess kpdKeyAct kpdTouch
    set globalField 0
    set globalValue 0

    foreach key $keyList {
	set globalField [expr $globalField + $kpdTouch($key,field)]
	set globalValue [expr $globalValue + $kpdTouch($key,value)]
    }
    mbDirect [format "%4s%2s%02x%04x0000" $KpdAccess $kpdKeyAct $globalField $globalValue] 1
    mbDirect [format "%4s%2s%02x%04x0000" $KpdAccess $kpdKeyAct $globalField $globalValue] 1

}


#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Ok".
#
# E.g. Use < keypad_OK 1 > press button ok and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Ok".
#
# \param[in] display: display the current screen data if set to 1.
#
# \n
# E.g. Use < keypad_OK 1 > press button ok and display current screen .
#
proc keypad_OK { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Ok"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Esc".
#
# E.g. Use < keypad_Esc 1 > press button Esc and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Esc".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Esc 1 > press button Esc and display current screen .
#
proc keypad_Esc { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Esc"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on multiple buttons at the same time.
#
# E.g. Use < keypad_TouchList [list Run Stop ] > press run and stop button at the same time.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Home".
#
# \param[in] keyList : list of the keys to press
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_TouchList [list Run Stop ] >  press run and stop button at the same time.
#
proc keypad_TouchList { keyList { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_TouchList $keyList
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Home".
#
# E.g. Use < keypad_Home 1 > press button Home and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Home".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Home 1 > press button Home and display current screen .
#
proc keypad_Home { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Home"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "F1".
#
# E.g. Use < keypad_F1 1 > press button F1 and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "F1".
#
# \param[in] tab: use in case of tab selection if set to 1 .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_F1 1 > press button F1 and display current screen .
#
proc keypad_F1 { { tab 1 } { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr kpdScrStr2
    kpd_Touch "F1"
    if { $tab } {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
	kpd_Touch "No"
	kpd_Touch "F1"
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
    } else {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1

    }
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "F2".
#
# E.g. Use < keypad_F2 1 > press button F2 and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "F2".
#
# \param[in] tab: use in case of tab selection if set to 1 .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_F2 1 > press button F2 and display current screen .
#
proc keypad_F2 { { tab 0 } { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr kpdScrStr2
    kpd_Touch "F2"
    if { $tab } {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
	kpd_Touch "No"
	kpd_Touch "F2"
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1

    } else {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1

    }

    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : resets the frequency setpoint of the HMI channel
#
# E.g. Use < keypad_resetFrequencySetpoint  > to set the setpoint to 0 .
#
# By default this proc will stop the motor
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 2022/09/22 ASY    proc created
# 2024/02/24 EDM    Added possibility to use the proc without stopping motor (0: Motor not stopped, 1 motor stopped) Motor is stopped by default
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : resets the frequency setpoint of the HMI channel
#
#
# \n
#E.g. Use < keypad_resetFrequencySetpoint  > to set the setpoint to 0 .
proc keypad_resetFrequencySetpoint {{stop 1}} {
    #Get the current value of the setpoint
    set startPoint [TlRead LFRA]
    # get the sign. 1 if positive 0 if negative
    if { [ regexp "^\[0-9\]" $startPoint ] } {
	set direction 0
    } elseif  { [string index $startPoint 0] == "-" } {
	set direction 1
	#remove the - sign if negative
	set startPoint [string range $startPoint 1 end]
    } else {
	TlError "Bad reading of LFRA "
	return -1
    }

    set nbOperation [expr [ string length $startPoint ] - 1]  		;#count the number of digits
    InitKeypad
    if {$stop != 0} {
    	keypad_Stop
    }
    keypad_Home
    keypad_Esc

    #press the F2 key to reach the highest digit
    for {set i 0} {$i < $nbOperation} {incr i} {
	keypad_F2
    }
    #loop accross all the digits to set the to 0
    for {set k 0} {$k <= $nbOperation} {incr k} {

	set maxDig [string index $startPoint $k]
	for {set j 0} { $j < $maxDig} {incr j} {
	    if {$direction} {
		keypad_Down
	    } else {
		keypad_Up
	    }
	}
	keypad_F3
    }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : sets the frequency setpoint of the HMI channel
#
# E.g. Use < keypad_setFrequencySetpoint 450 > to set the setpoint to 45.0 Hz .
#
# By default this proc will stop the motor by using Keypad resetFrequencySetpoint
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 2022/09/22 ASY    proc created
# 2024/02/24 EDM    Added possibility to use the proc without stopping motor (0: Motor not stopped, 1 motor stopped) Motor is stopped by default
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description :  sets the frequency setpoint of the HMI channel
#
#\param[in] setpoint : value to set the setpoint to. In 1/10 Hz
# \n
#E.g. Use < keypad_setFrequencySetpoint 450 > to set the setpoint to 45.0 Hz .
proc keypad_setFrequencySetpoint {setpoint {stop 1}} {
    #reset the current value of the setpoint
    keypad_resetFrequencySetpoint $stop
    #Get the current value of the setpoint
    TlPrint "LFRA : [TlRead LFRA]"
    # get the sign. 1 if positive 0 if negative
    if { [ regexp "^\[1-9\]" $setpoint ] } {
	set direction 0
    } elseif  { [string index $setpoint 0] == "-" } {
	set direction 1
	#remove the - sign if negative
	set setpoint [string range $setpoint 1 end]
    } else {
	TlError "Invalid range of value "
	return -1
    }
    Keypad_keepAlive 1
    set nbOperation [expr [ string length $setpoint ] - 1]  		;#count the number of digits

    keypad_Home
    keypad_Esc

    #press the F2 key to reach the highest digit
    for {set i 0} {$i < $nbOperation} {incr i} {
	keypad_F2
    }
    #loop accross all the digits to set the to 0
    for {set k 0} {$k <= $nbOperation} {incr k} {

	set dig [string index $setpoint $k]
	for {set j 0} { $j < $dig} {incr j} {
	    if {$direction} {
		keypad_Up
	    } else {
		keypad_Down
	    }
	}
	keypad_F3
    }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "F3".
#
# E.g. Use < keypad_F3 1 > press button F3 and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "F3".
#
# \param[in] tab: use in case of tab selection if set to 1 .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_F3 1 > press button F1 and display current screen .
#
proc keypad_F3 { { tab 0 } { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr kpdScrStr2
    kpd_Touch "F3"
    if { $tab } {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
	kpd_Touch "No"
	kpd_Touch "F3"
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
    } else {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1

    }
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "F4".
#
# E.g. Use < keypad_F4 1 > press button F4 and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "F4".
#
# \param[in] tab: use in case of tab selection if set to 1 .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_F4 1 > press button F4 and display current screen .
#
proc keypad_F4 { { tab 1 } { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr kpdScrStr2
    kpd_Touch "F4"
    if { $tab } {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
	kpd_Touch "No"
	kpd_Touch "F4"
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr2 ] 1
    } else {
	mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1

    }
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Info".
#
# E.g. Use < keypad_Info 1 > press button Info and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Info".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Info 1 > press button Info and display current screen .
#
proc keypad_Info { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Info"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Stop".
#
# E.g. Use < keypad_Stop 1 > press button Info and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Stop".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Stop 1 > press button stop and display current screen .
#
proc keypad_Stop { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Stop"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Run".
#
# E.g. Use < keypad_run 1 > press button Run and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Run".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Run 1 > press button Run and display current screen .
#
proc keypad_Run { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "Run"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "LocalRemote".
#
# E.g. Use < keypad_LocalRemote 1 > press button LocalRemote and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "LocalRemote".
#
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_LocalRemote 1 > press button LocalRemote and display current screen .
#
proc keypad_LocalRemote { { display 0 } } {
    global KpdAccess kpdScrStrSet kpdScrStr
    kpd_Touch "L/R"
    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
    kpd_Touch "No"
    displayScreen $display
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Down".
#
# E.g. Use < keypad_Down 2 1 > press button Down 2 time and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Down".
#
# \param[in] loop: number of time to repeat the command .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Down 2 1 > press button Down 2 time and display current screen .
#
proc keypad_Down { {loop 1 } { display 0 } } {

    #    for {set i 1 } { $i < $loop } { incr i } {
    kpd_Touch "Down"
    kpd_Touch "No"
    displayScreen $display
    #    }
    #    if { $display == 2 } { displayScreen 1 }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function description : press on button "Up".
#
# E.g. Use < keypad_Up 2 1 > press button Up 2 time and display current screen .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : press on button "Up".
#
# \param[in] loop: number of time to repeat the command .
# \param[in] display: display the current screen data if set to 1 .
#
# \n
# E.g. Use < keypad_Up 2 1 > press button Up 2 time and display current screen .
#
proc keypad_Up { {loop 1 } { display 0 } } {
    #    for {set i 1 } { $i < $loop } { incr i } {
    kpd_Touch "Up"
    kpd_Touch "No"
    displayScreen $display
    #    }
    #    if { $display == 2 } { displayScreen 1 }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# check availibility of menu code in current screen .
#
# E.g. Use < if {[checkMenu "SYS" 1 1 ]} { > to verify menu "SYS" availibility .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : check availibility of menu code in current screen.
#
# \param[in] name: expected menu code or list enumerator .
# \param[in] find: 1 or 0 if it's expected to have it or not .
# \param[in] errorPrint: 1 or 0 if display comments or not .
#
# \n
# E.g. Use < if {[checkMenu "SYS" 1 1 ]} { > to verify menu "SYS" availibility
proc checkMenu { name { find 1 } { errorPrint 1 }} {

    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    if { [ InitKeypad 1] } {
	kpd_Touch "No"
	set menu [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "02" $kpdScr2 ]  1 ]]]

	set menu [split $menu "#" ]
	# TlPrint $menu
	set findName 0
	foreach nameCompare $menu {
	    append nameCompare " "
	    set nameKeypad  [string range $nameCompare 0 [ string first " " $nameCompare ] ]
	    set nameKeypad  [string map {"\]" "" } $nameKeypad]
	    set nameKeypad  [string trimright $nameKeypad]
	    #             TlPrint $nameKeypad
	    if { $nameKeypad == $name } {
		set findName 1
		break
	    }
	}

	if { ( $find == 1 && $findName == 1 ) || ( $find == 0 && $findName == 0 )  } {
	    if { $errorPrint } { TlPrint " menu keypad is correct" }
	    return 1

	} else {
	    if { $errorPrint } { TlError " menu keypad is'nt correct" }

	    return 0
	}

    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Extract the current value for selection of menu or parameter list.
#
# E.g. Use < if{[ currentSelect ]=="SIM"} { > to verifiy that the current keypad selection is simply start menu ("SIM").
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Extract the current value for selection of menu or parameter list..
#
# \param[out] elemName : return menu code or list enumerator .
# \n
# E.g. Use < if{[ currentSelect ]=="SIM"} { > to verifiy that the current keypad selection is simply start menu ("SIM").
#
proc currentSelect { } {

    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2

    set menu [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "02" $kpdScr2 ]  1 ]]]
    set menu [split $menu ]
    set pos 0
    foreach element $menu {

	if { [ Ascii2Hexa $element ] == "80" } {
	    break
	}
	incr pos
    }

    set elemNum [ lindex $menu [ expr $pos +1 ]]
    if { [ string match  *#* $elemNum ]} {
	set value  [ split $elemNum "#" ]
	return [ lindex $value 1 ]
    } else {
	set elemName [ split  [ lindex $menu [ expr $pos +2 ]] "#" ]
	set elemName [ lindex $elemName 1 ]

	return $elemName
    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Browse current menu or parameter list until find the expected value.
#
# E.g. Use < [Keypad_Select  "COM"]  > to select "COM"(communication) menu from home screen.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
# 080323 ASY    added the ErrPrint parameter
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Browse current menu or parameter list until find the expected value..
#
# \param[in] menu: expected menu code or list enumerator to select .
#
# \n
# E.g.  Use < [Keypad_Select  "COM"]  > to select "COM"(communication) menu from home screen.
#
proc Keypad_Select { menu {ErrPrint 1} } {

    while { [currentSelect] != $menu } {

	set OldSelect [currentSelect]
	kpd_Touch "Down"
	kpd_Touch "No"
	doWaitMs 100
	set newSelect [currentSelect]
	if { $OldSelect == $newSelect } {
	    if { $ErrPrint} {	
	        TlError "I cannot find $menu"
   	    }
	    return 0
	}

    }
    TlPrint "[currentSelect]"
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Using inside Keypad_WriteAbort or Keypad_ReadAbort to not generate error when the parameter on keypad can not be find or invisible
#
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 070121 kaidi    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------

proc Keypad_SelectAbort { menu } {

    while { [currentSelect] != $menu } {

	set OldSelect [currentSelect]
	TlPrint "OldSelect is $OldSelect"
	kpd_Touch "Down"
	kpd_Touch "No"
	doWaitMs 500
	set newSelect [currentSelect]
	TlPrint "newSelect is $newSelect"
	if { $OldSelect == $newSelect } {
	    TlPrint "I cannot find $menu"
	    return 0
	}

    }
    TlError "Found [currentSelect] amongst the available values"
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Write the value of parameter from hmi tree.
#
# E.g. Use < Keypad_Write "SYS|ACC" 20 > to write acceleration to 20.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c      proc created
# 251121 YGH	  added the display optional parameter
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Write the value of parameter from hmi tree.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) .
# \param[in] value: expected value to write.
#
# \n
# E.g. Use < Keypad_Write "SYS|ACC" 20 > to write acceleration to 20.
#
proc Keypad_Write { HMITree value {display 0}} {

    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	doWaitMs 200
	keypad_OK $display

    }
    if { [ string match ".*" $value  ]} {

	set value [ string map {"." ""} $value ]
	Keypad_Select  $value
	doWaitMs 200
	keypad_OK 0
	doWaitMs 200
	keypad_OK 0
	keypad_Home 0
    } else {
	set currentValue  [TlRead $element ]
	#	if { $currentValue < $value   } {
	#		kpd_Touch "Up"
	#		kpd_Touch "No"
	#	}
	set diff [ expr ($currentValue-$value  )]
	if { $display } { TlPrint "Dif:$diff"}
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"

	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }

	}
	keypad_OK $display
	TlPrint "$element : [TlRead $element ] "

    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Not return the error when write a parameter which can not be found
#
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 070121 kaidi    proc created
# 251121 ASY	  added the display optional parameter
#
#END-----------------------------------------------------------------------------------------------------------------------

proc Keypad_WriteAbort { HMITree value {display 0}} {

    InitKeypad  $display
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	doWaitMs 200
	keypad_OK $display

    }
    if { [ string match ".*" $value  ]} {

	set value [ string map {"." ""} $value ]
	Keypad_SelectAbort  $value
	doWaitMs 200
	keypad_OK 0
	doWaitMs 200
	keypad_OK 0
	keypad_Home 0
    } else {
	set currentValue  [TlRead $element ]
	#	if { $currentValue < $value   } {
	#		kpd_Touch "Up"
	#		kpd_Touch "No"
	#	}
	set diff [ expr ($currentValue-$value  )]
	if { $display } { TlPrint "Dif:$diff"}
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"

	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }

	}
	keypad_OK $display
	if { $display } {TlPrint "$element : [TlRead $element ] "}

    }

}

proc Keypad_ReadIndexCalcul_isList { isList  } {
    global listValue
    #simple data
    set listEnum [ split $isList "#" ]
    set listValue ""
    set listLength [ llength $listEnum ]
    TlPrint "listLength is $listLength"

    #list management
    for { set a 1 } { $a < $listLength } { incr a } {
	set valueInt [ split [ lindex $listEnum $a  ] ]
	#		   TlPrint $valueInt
	lappend listValue [ lindex $valueInt 0 ]

    }

    TlPrint " listValue : $listValue"
    set listLength [ llength $listValue ]
    TlPrint "  listLength : $listLength"
    set value1  [ mbDirect "F8440802013C00"  1 ]
    TlPrint "  11111  value1 : $value1"
    set i [ expr (2 * $listLength ) + 8 ]
    set value1 [ string map { "0504534C54" "0000000001" } $value1 ]
    TlPrint " 2222222222  value1 : $value1"
    set value1 [ string map { 4 0 8 0 } $value1 ]
    TlPrint " 333333333  value1 : $value1"
    set numList [ string range $value1 end-$i  end-2 ]
    TlPrint "   numList : $numList"
    set lengthValue1 [ string length $numList]
    TlPrint "   lengthValue1 : $lengthValue1"
    set test1 [ expr ( $lengthValue1 - [string last "1" $numList ]  ) - 1 ]

    TlPrint  " test1 : $test1"
    set indexList [ expr $listLength - ( $test1 / 4 ) - 1]
    TlPrint "indexList : $indexList  "

    if {  $lengthValue1 == $test1 } {
	set OK 0
	TlPrint "Keypad_ReadIndexCalcul_isList returns 999 "
	return  999
    } else {
	set OK 1
	TlPrint "Keypad_ReadIndexCalcul_isList returns $indexList "
	return  $indexList
    }
}

proc Keypad_ReadIndexCalcul_listValue { listValue  } {

    TlPrint " listValue : $listValue"
    set listLength [ llength $listValue ]
    TlPrint "  listLength : $listLength"
    set value1  [ mbDirect "F8440802013C00"  1 ]
    TlPrint "  11111  value1 : $value1"
    set i [ expr (2 * $listLength ) + 8 ]
    set value1 [ string map { "0504534C54" "0000000001" } $value1 ]
    TlPrint " 2222222222  value1 : $value1"
    set value1 [ string map { 4 0 8 0 } $value1 ]
    TlPrint " 333333333  value1 : $value1"
    set numList [ string range $value1 end-$i  end-2 ]
    TlPrint "   numList : $numList"
    set lengthValue1 [ string length $numList]
    TlPrint "   lengthValue1 : $lengthValue1"
    set test1 [ expr ( $lengthValue1 - [string last "1" $numList ]  ) - 1 ]

    TlPrint  " test1 : $test1"
    set indexList [ expr $listLength - ( $test1 / 4 ) - 1]
    TlPrint "indexList : $indexList  "
    TlPrint " numList : $numList "

    TlPrint " value1 is $value1"
    if {  $lengthValue1 == $test1 } {
	set OK 0
	return  999
    } else {
	set OK 1
	return  $indexList
    }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Read the value of a parameter in keypad HMI tree.
#
# E.g. Use < Keypad_Read "SYS|ACC" > to read acceleration parameter . returns list with value,unit min and max for parameter or current selection for list.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
# 251121 ASY	  added the display with default value 0 in order to print less an ease dblog reading
# 251121 Yahya	  updated reading of parameters with "value|unit|min|max" (see Issue #1251) 
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Read the value of a parameter in keypad HMI tree.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) ..
# \param[in] display: 0 by default this parameter allows to toggle informations display
#
# \n
# E.g. Use < Keypad_Read "SYS|ACC" > to read acceleration parameter . returns list with value,unit min and max for parameter or current selection for list.
#
proc Keypad_Read { HMITree {display 0} } {

    InitKeypad  $display
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	doWaitMs 500
	keypad_OK $display
    }

    set isList [ RemoveSpaceFromList [ displayScreen ]]

    TlPrint "isList : $isList "
    if { [ string length $isList] == 2} {
	#  parameter management

	set valuelist [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect "F8440802013C00"  1 ]]]
	set valuelist [ split $valuelist ]

	set maxValue [ lindex $valuelist end ]
	set minValue [ lindex $valuelist end-1 ]
	if { [regexp {^\D+$} [ lindex $valuelist end-2 ]] } {
	    set unit [ lindex $valuelist end-2 ]
	    set value [join [lrange $valuelist 2 end-3] ""]
	} else {
	    set unit ""
	    set value [join [lrange $valuelist 2 end-2] ""]
	}

	set result [join [list $value $unit $minValue $maxValue] "|"]
	return $result

    } else {
	###### update list
	set OldisList [ RemoveSpaceFromList [ displayScreen ]]
	TlPrint "  OldisList : $OldisList"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "No"
	doWaitMs 500
	set newisList [ RemoveSpaceFromList [ displayScreen ]]
	if { $display } {TlPrint "  newisList : $newisList"}
	set a 0
	set addElement ""
	while { [Keypad_ListToEnum $OldisList] != [Keypad_ListToEnum $newisList] } {
	    append addElement "#"
	    incr a
	    TlPrint "Keypad_ListToEnum $OldisList : [Keypad_ListToEnum $OldisList] "
	    TlPrint "Keypad_ListToEnum $newisList : [Keypad_ListToEnum $newisList] "
	    set endElement [lindex [Keypad_ListToEnum $newisList] end]

	    set OldisList [ RemoveSpaceFromList [ displayScreen ]]
	    TlPrint "# $a$a $a $a $a $a   OldisList : $OldisList"
	    kpd_Touch "Down"
	    kpd_Touch "No"
	    doWaitMs 500
	    set newisList [ RemoveSpaceFromList [ displayScreen ]]
	    TlPrint "# $a$a $a $a $a $a   newisList : $newisList"

	    append addElement $endElement
	    TlPrint " # $a$a $a $a $a $a  addElement : $addElement"

	}
	append isList  $addElement
	#########

	#simple data
	if { $display } {TlPrint " final 	isList: $isList"}
	set listEnum [ split $isList "#" ]
	if { $display } {TlPrint "  listEnum : $listEnum"}
	set listValue ""
	set listLength [ llength $listEnum ]
	if { $display } {TlPrint " listLength : $listLength"}
	if { $listLength == 1 } {
	    set valueList [ split $listEnum  ]
	    set value [ string map { "\}" "" } [ lindex $valueList 1 ] ]

	} else {
	    #list management
	    for { set a 1 } { $a < $listLength } { incr a } {
		set valueInt [ split [ lindex $listEnum $a  ] ]
		set valueInt1  [ lindex $listEnum $a  ]
		#		   TlPrint $valueInt
		if { $display } { TlPrint "  valueInt : $valueInt , valueInt1 : $valueInt1"}
		lappend listValue [ lindex $valueInt 0 ]

	    }

	    if { $display } { TlPrint " listValue : $listValue"}
	    set listLength [ llength $listValue ]
	    if { $display } { TlPrint "  listLength : $listLength"}
	    set value1  [ mbDirect "F8440802013C00"  1 ]
	    if { $display } {TlPrint "  11111  value1 : $value1"}
	    set i [ expr (2 * $listLength ) + 8 ]
	    set value1 [ string map { "0504534C54" "0000000001" } $value1 ]
	    if { $display } {TlPrint " 2222222222  value1 : $value1"}
	    set value1 [ string map { 4 0 8 0 } $value1 ]
	    if { $display } {TlPrint " 333333333  value1 : $value1"}
	    set numList [ string range $value1 end-$i  end-2 ]
	    if { $display } {TlPrint "   numList : $numList" }
	    set lengthValue1 [ string length $numList]
	    if { $display } {TlPrint "   lengthValue1 : $lengthValue1"}
	    set test1 [ expr ( $lengthValue1 - [string last "1" $numList ]  ) - 1 ]

	    if { $display } {TlPrint  " test1 : $test1"}
	    set indexList [ expr $listLength - ( $test1 / 4 ) - 1]
	    if { $display } {TlPrint "indexList : $indexList  "}
	    if {  $indexList < 0 } {
		set indexList 0
	    }
	    set value [ lindex $listValue $indexList ]
	    #
	    if { $display } { TlPrint " numList : $numList "}

	    if { $display } { TlPrint " value1 is $value1"}

	}

    }
    if { $display } {TlPrint "value is $value"}

    return $value
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Based on Keypad_Read1. Returns the value of the parameter given as argument.
# This works both in gating and not gatin states
#
# E.g. Use < Keypad_ReadSimple "CST|LLC|LES"> to read Drive Lock assignement
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 020621 kaidi    Keypad_Read1 created
# 100723 ASY      proc updated
#
#END-----------------------------------------------------------------------------------------------------------------------

proc Keypad_ReadSimple { HMITree  } {
	global listValue

	global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
	InitKeypad  1
	doWaitMs 300
	keypad_Esc
	doWaitMs 300
	keypad_Home 1
	doWaitMs 500
	set elementHMI [ split $HMITree "|" ]
	set lastElement [lindex $elementHMI end]
	foreach element $elementHMI {
		TlPrint "Keypad_Select $element"
		Keypad_Select  $element
		doWaitMs 500
		if {$element != $lastElement} {
			keypad_OK 1
		}
		# "F8440802013C00"

	}


	set input [RemoveSpaceFromList [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "02" $kpdScr1 ]  1 ]]]
	regsub -all "P\#" $input "_" input ;#replace all the P# that delimit the parameters and the corresponding data by a _ in order to be able to use split afterwards
	set input [split $input "_"]
	#Get the element where the choosen parameter appears
	set index [lsearch -regexp $input $lastElement]
	set input [string trimright [lindex $input $index]]
	#Get only the data we are interested in : 
	if {[string first "\#" $input] != -1 } { ;# if there is a \# then the parameter is enumerated 
		set input [split $input "\#"]
		set input [lindex $input end]
	} else { ;# otherwise it is a numerical value 
		set input [lindex [split $input] 1]
	}
	return $input 
}
#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Read the value of a parameter in keypad HMI tree where the list is very long .
#
# E.g. Use < Keypad_Read1 "CST|LLC|LES"> to read Drive Lock assignement
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 020621 kaidi    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------

proc Keypad_Read1 { HMITree  } {
    global listValue

    InitKeypad  1
    doWaitMs 300
    keypad_Esc
    doWaitMs 300
    keypad_Home 1
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	doWaitMs 500
	keypad_OK 1
	# "F8440802013C00"

    }

    set isList [ RemoveSpaceFromList [ displayScreen ]]

    TlPrint "isList : $isList "
    if { [ string length $isList] == 2} {
	#  parameter management

	set valuelist [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect "F8440802013C00"  1 ]]]
	set valuelist [ split $valuelist ]
	set value [ lindex $valuelist 2 ]
	append value [ lindex $valuelist 3 ]
	append value [ lindex $valuelist 4 ]
	append value "|"
	append value [ lindex $valuelist 5 ]
	append value "|"
	append value [ lindex $valuelist 6 ]
    } else {
	set godown 0

	#simple data
	TlPrint " final 	isList: $isList"
	set listEnum [ split $isList "#" ]
	TlPrint "  listEnum : $listEnum"
	set listValue ""
	set listLength [ llength $listEnum ]
	TlPrint " listLength : $listLength"
	if { $listLength == 1 } {
	    set valueList [ split $listEnum  ]
	    set value [ string map { "\}" "" } [ lindex $valueList 1 ] ]

	} else {
	    #list management
	    for { set a 1 } { $a < $listLength } { incr a } {
		set valueInt [ split [ lindex $listEnum $a  ] ]
		set valueInt1  [ lindex $listEnum $a  ]
		#		   TlPrint $valueInt
		TlPrint "  valueInt : $valueInt , valueInt1 : $valueInt1"
		lappend listValue [ lindex $valueInt 0 ]

	    }

	    set IndexCalcul [Keypad_ReadIndexCalcul_listValue  $listValue]
	    if {  $IndexCalcul  != 999 } {
		set value [ lindex $listValue $IndexCalcul ]
		set godown 1
	    }

	    #

	    if {  $godown ==0  && $IndexCalcul  == 999   } {
		set godown 1

		###### update list
		set OldisList [ RemoveSpaceFromList [ displayScreen ]]
		TlPrint "  OldisList : $OldisList"
		kpd_Touch "Down"
		kpd_Touch "Down"
		kpd_Touch "Down"
		kpd_Touch "Down"
		kpd_Touch "Down"
		kpd_Touch "No"
		doWaitMs 500
		set newisList [ RemoveSpaceFromList [ displayScreen ]]
		TlPrint "  newisList : $newisList"
		set a 0

		set addElement ""
		append addElement "#"
		set endElement [lindex [Keypad_ListToEnum $newisList] end]
		append addElement $endElement
		append isList  $addElement

		set IndexCalcul1 [Keypad_ReadIndexCalcul_isList  $isList]
		if {  $IndexCalcul1  != 999 } {
		    set value [ lindex $listValue $IndexCalcul1 ]
		} else {

		    while { [Keypad_ListToEnum $OldisList] != [Keypad_ListToEnum $newisList] } {
			set addElement ""
			append addElement "#"
			incr a

			set OldisList [ RemoveSpaceFromList [ displayScreen ]]
			TlPrint "# $a$a $a $a $a $a   OldisList : $OldisList"
			kpd_Touch "Down"
			kpd_Touch "No"
			doWaitMs 500
			set newisList [ RemoveSpaceFromList [ displayScreen ]]
			TlPrint "# $a$a $a $a $a $a   newisList : $newisList"

			TlPrint "Keypad_ListToEnum $OldisList : [Keypad_ListToEnum $OldisList] "
			TlPrint "Keypad_ListToEnum $newisList : [Keypad_ListToEnum $newisList] "
			set endElement [lindex [Keypad_ListToEnum $newisList] end]

			append addElement $endElement
			TlPrint " # $a$a $a $a $a $a  addElement : $addElement"
			append isList  $addElement
			set IndexCalcul [Keypad_ReadIndexCalcul_isList  $isList]
			if {  $IndexCalcul  != 999 } {
			    break

			}
		    }
		}
		set value [ lindex $listValue $IndexCalcul ]
		#########
	    }

	}

    }

    TlPrint "value is $value"

    return $value
}

proc Keypad_FactorySetting { FRY } {

    Keypad_Write "FMT|FCS|FRY" .$FRY
    doWaitMs 200
    keypad_Home
    doWaitMs 200
    Keypad_Select FMT
    doWaitMs 150
    keypad_OK
    doWaitMs 150
    Keypad_Select FCS
    doWaitMs 150
    keypad_OK
    doWaitMs 150
    Keypad_Select GFS
    doWaitMs 150
    keypad_OK
    doWaitMs 150
    keypad_OK
    doWaitMs 200

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Not return the error when read a parameter which  is not visible
#
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 250121 kaidi    proc created
# 251121 ASY	  added the display with default value 0 in order to print less an ease dblog reading
#END-----------------------------------------------------------------------------------------------------------------------

proc Keypad_ReadAbort { HMITree  {TTId ""} {display 0}} {
    set TTId [Format_TTId $TTId]
    InitKeypad  $display
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	set result [Keypad_SelectAbort  $element]
	doWaitMs 500
	keypad_OK $display
	# "F8440802013C00"

    }
    if {$result != 0} {
	TlError "$TTId No abort, I can find $HMITree"
    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# convert hexadecimal value to ascii character.
#
# E.g.  Use < [Hexa2Ascii 5450] > return "TP" .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : convert hexadecimal value to ascii character.
#
# \param[in] HexaValue: value to convert .
#
# \n
# E.g. Use < [Hexa2Ascii 5450] > return "TP" .
#
proc Hexa2Ascii {HexaValue} {
    set AsciiString  ""
    set NumberOfChar [string length $HexaValue]
    for {set z 0} {$z < [expr $NumberOfChar]} {incr z 2} {
	set HexaChar  "0x[string range $HexaValue [ expr ($z)] [ expr ($z+1)] ]"
	if {[expr $HexaChar]>31 } {
	    append AsciiString [binary format c* $HexaChar]
	} else {
	    append AsciiString " "
	}
    }
    return $AsciiString
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# convert ascii characters to list of hexadecimal value.
#
# E.g. Use < [Ascii2Hexa TP] > return 54 50 .
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : convert ascii characters to list of hexadecimal value..
#
# \param[in] string : characters to convert .
#
# \n
# E.g. Use < [Ascii2Hexa TP] > return 54 50 .
#
proc Ascii2Hexa {string} {
    binary scan $string c* ints
    set list {}
    foreach i $ints {
	lappend list [format %0.2X [expr {$i & 0xFF}]]
    }
    return $list
}

# end of file

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# return the current date and time from keypad.
#
# E.g. Use < [Keypad_GetRTC] > return the current date and time from keypad.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 a&c    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : return the current date and time from keypad.
#
# \param[in] HMITree : path of the parameter in HMI tree ("|" is used to separate hmi tree structure).
#
# \n
# E.g. Use < [Keypad_GetRTC] > return the current date and time from keypad.
#
proc Keypad_GetRTC { {HMITree {MYP|DTO|RTC} } } {

    #check time by menu "setting" but format in not apply in this menu
    if {[InitKeypad 1]} {
	keypad_Stop 0
	keypad_Esc 0
	keypad_Home 0
	set elementHMI [ split $HMITree "|" ]
	foreach element $elementHMI {
	    Keypad_Select  $element
	    #doWaitMs 500
	    keypad_OK 0
	}
	# date and time with keypad format
	set valuelist [ string map {"\ :" ":"}  [string range [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect "F8440802023C00"  1 ]]] 3 end ]]
	set ltemp [regexp -all -inline -- {\S+} $valuelist]
	set TIME ""
	lappend  TIME [lindex $ltemp 1]
	lappend  TIME [lindex $ltemp 0]
	return $TIME
    }
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# return the fault or warning info from keypad.
#
# E.g. Use < [Keypad_GetAlarm] > return the value concerning fault or warning.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 010321 kaidi    proc created
# 251121 ASY	  added the display optionnal parameter
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : return the fault or warning info from keypad.
#
# \param[in] HMITree : path of the parameter in HMI tree ("|" is used to separate hmi tree structure).
# \param[in] display : toggles the information printing
#
# \n
# E.g. Use <Keypad_GetAlarm "DIA|ALR|ALRD"> return the current warning (can be a list).
# E.g. Use <Keypad_GetAlarm "DIA|DDT|LALR"> return the last warning.
proc Keypad_GetAlarm {  HMITree {display 0}} {
    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    set element1 [lindex $elementHMI 0]
    set page [lindex $elementHMI 1]
    set element3 [lindex $elementHMI 2]
    if { $display } { TlPrint "element1 : $element1;page : $page;element3 : $element3 "}
    Keypad_Select  $element1
    doWaitMs 500
    keypad_OK $display
    # "F8440802013C00"

    if {  $page == "PFH"} {
	keypad_F2 1 $display
    } elseif { $page == "ALR" }  {
	keypad_F3 1 $display
    } elseif { $page == "DDT" } {

    } else {
	TlError "can not find $element1|$page  "
    }

    if {  $element3 != "" } {
	Keypad_Select  $element3
	doWaitMs 500
	keypad_OK $display
    }

    set isList [ RemoveSpaceFromList [ displayScreen ]]   ;# ecran gauche

    if { $display } {  TlPrint "isList : $isList , string length is [ string length $isList]" }
    if { [ string length $isList] == 2} {
	#  parameter management

	set valuelist [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect "F8440802013C00"  1 ]]]
	set valuelist [ split $valuelist ]
	set value [ lindex $valuelist 2 ]
	append value [ lindex $valuelist 3 ]
	append value [ lindex $valuelist 4 ]
	append value "|"
	append value [ lindex $valuelist 5 ]
	append value "|"
	append value [ lindex $valuelist 6 ]

	if {  $element3 == "ALRD" } {
	    set result ""
	    TlPrint "menu is empty "
	    return $result

	}
    } else {
	#simple data
	set listEnum [ split $isList "#" ]
	set listValue ""
	set listLength [ llength $listEnum ]
	if { $display } { TlPrint "listLength is $listLength"}
	if { $listLength == 1 } {
	    set valueList [ split $listEnum  ]
	    set value [ string map { "\}" "" } [ lindex $valueList 1 ] ]

	} else {
	    #list management
	    for { set a 1 } { $a < $listLength } { incr a } {
		set valueInt [ split [ lindex $listEnum $a  ] ]
		#		   TlPrint $valueInt
		lappend listValue [ lindex $valueInt 0 ]

	    }

	    if { $display } { TlPrint " listValue : $listValue" }
	    set listLength [ llength $listValue ]
	    set value1  [ mbDirect "F8440802013C00"  1 ]
	    set i [ expr (2 * $listLength ) + 8 ]
	    set value1 [ string map { "0504534C54" "0000000001" } $value1 ]
	    set value1 [ string map { 4 0 8 0 } $value1 ]
	    set numList [ string range $value1 end-$i  end-2 ]
	    set lengthValue1 [ string length $numList]
	    set test1 [ expr ( $lengthValue1 - [string last "1" $numList ]  ) - 1 ]

	    if { $display } { TlPrint  " test1 : $test1" }
	    set indexList [ expr $listLength - ( $test1 / 4 ) - 1]

	    if { $display } {TlPrint "indexList : $indexList  " }
	    if {  $indexList < 0 } {
		set indexList 0
	    }
	    set value [ lindex $listValue $indexList ]
	    #
	    if { $display } { TlPrint " numList : $numList "}

	    if { $display } {TlPrint " value1 is $value1"}
	}

	if {  $element3 == "ALRD" || $page == "PFH" } {
	    return $listValue

	}

    }
    TlPrint "value is $value"

    return $value

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Used by Keypad_Read which convet [ RemoveSpaceFromList [ displayScreen ]] to list of Enum
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 170820 kaidi    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
proc Keypad_ListToEnum {  isList } {

    set listEnum [ split $isList "#" ]

    set listValue ""
    set listLength [ llength $listEnum ]

    for { set a 1 } { $a < $listLength } { incr a } {
	set valueInt  [ lindex $listEnum $a  ]

	lappend listValue [ lindex $valueInt 0 ]

    }
    return  $listValue
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# return the input/output menu parameters info from keypad.
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 120521 kaidi    proc created
# 251121 ASY      added the display optionnal parameter
# 150223 Yahya	  Removed setting LAC to EPR from proc Keypad_ReadIO
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : return the input/output menu parameters info from keypad.
#
# \param[in] HMITree : path of the parameter in HMI tree ("|" is used to separate hmi tree structure).
# \param[in] display : toggles the information printing
#
# \n
# E.g. Use <Keypad_ReadIO "IO|AIAO|AO1|AO1S">
# E.g. Use <Keypad_ReadIO "IO|IOAS|AO1">
proc Keypad_ReadIO {  HMITree {display 0} } {
    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    set element1 [lindex $elementHMI 0]
    set page [lindex $elementHMI 1]
    set element3 [lindex $elementHMI 2]
    set element4 [lindex $elementHMI 3]
    if { $display } {TlPrint "element1 : $element1;page : $page;element3 : $element3 ;element4 : $element4"}
    Keypad_Select  $element1
    doWaitMs 500
    keypad_OK $display
    # "F8440802013C00"

    if {  $page == "AIAO"} {
	keypad_F3 1 $display
    } elseif { $page == "IOAS" } {

    } elseif { $page == "DIDO" } {
	keypad_F2 1 $display
    } elseif { $page == "RELA" } {
	keypad_F4 1 $display
    } else {
	TlError "can not find $element1|$page  "
    }

    if {  $element3 != "" } {
	Keypad_Select  $element3
	doWaitMs 500
	keypad_OK $display
	if {  $element4 != "" } {
	    Keypad_Select  $element4
	    doWaitMs 500
	    keypad_OK $display
	}
    }

    set isList [ RemoveSpaceFromList [ displayScreen ]]   ;# ecran gauche

    if { $display } {TlPrint "isList : $isList , string length is [ string length $isList]"}
    if { [ string length $isList] == 2} {
	#  parameter management

	set valuelist [ RemoveSpaceFromList [ Hexa2Ascii [ mbDirect "F8440802013C00"  1 ]]]
	set valuelist [ split $valuelist ]
	set value [ lindex $valuelist 2 ]
	append value [ lindex $valuelist 3 ]
	append value [ lindex $valuelist 4 ]
	append value "|"
	append value [ lindex $valuelist 5 ]
	append value "|"
	append value [ lindex $valuelist 6 ]

    } else {
	###### update list
	set OldisList [ RemoveSpaceFromList [ displayScreen ]]
	TlPrint "  OldisList : $OldisList"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "Down"
	kpd_Touch "No"
	doWaitMs 500
	set newisList [ RemoveSpaceFromList [ displayScreen ]]
	if { $display } { TlPrint "  newisList : $newisList" }
	set a 0
	set addElement ""
	while { [Keypad_ListToEnum $OldisList] != [Keypad_ListToEnum $newisList] } {
	    append addElement "#"
	    incr a
	    if { $display } {TlPrint "Keypad_ListToEnum $OldisList : [Keypad_ListToEnum $OldisList] "}
	    if { $display } {TlPrint "Keypad_ListToEnum $newisList : [Keypad_ListToEnum $newisList] "}
	    set endElement [lindex [Keypad_ListToEnum $newisList] end]

	    set OldisList [ RemoveSpaceFromList [ displayScreen ]]
	    if { $display } {TlPrint "# $a$a $a $a $a $a   OldisList : $OldisList"}
	    kpd_Touch "Down"
	    kpd_Touch "No"
	    doWaitMs 500
	    set newisList [ RemoveSpaceFromList [ displayScreen ]]
	    if { $display } {TlPrint "# $a$a $a $a $a $a   newisList : $newisList"}

	    append addElement $endElement
	    if { $display } {TlPrint " # $a$a $a $a $a $a  addElement : $addElement"}

	}
	append isList  $addElement
	#simple data
	set listEnum [ split $isList "#" ]
	set listValue ""
	set listLength [ llength $listEnum ]
	if { $display } {TlPrint "listLength is $listLength"}
	if { $listLength == 1 } {
	    set valueList [ split $listEnum  ]
	    set value [ string map { "\}" "" } [ lindex $valueList 1 ] ]

	} else {
	    #list management
	    for { set a 1 } { $a < $listLength } { incr a } {
		set valueInt [ split [ lindex $listEnum $a  ] ]
		#		   TlPrint $valueInt
		lappend listValue [ lindex $valueInt 0 ]

	    }

	    if { $display } {TlPrint " listValue : $listValue"}
	    set listLength [ llength $listValue ]
	    set value1  [ mbDirect "F8440802013C00"  1 ]
	    set i [ expr (2 * $listLength ) + 8 ]
	    set value1 [ string map { "0504534C54" "0000000001" } $value1 ]
	    set value1 [ string map { 4 0 8 0 } $value1 ]
	    set numList [ string range $value1 end-$i  end-2 ]
	    set lengthValue1 [ string length $numList]
	    set test1 [ expr ( $lengthValue1 - [string last "1" $numList ]  ) - 1 ]

	    set indexList [ expr $listLength - ( $test1 / 4 ) - 1]

	    if {  $indexList < 0 } {
		set indexList 0
	    }
	    set value [ lindex $listValue $indexList ]
	    #
	    if { $display } {TlPrint " numList : $numList "}

	    if { $display } {TlPrint " value1 is $value1" }
	}

    }
    TlPrint "value is $value"

    return $value

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# This proc is used to check that a parameter is not visible on keypad in input/output menu
#
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 150223 Yahya    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : This proc is used to check that a parameter is not visible on keypad in input/output menu
#
# \param[in] HMITree : path of the parameter in HMI tree ("|" is used to separate hmi tree structure).
# \param[in] display : toggles the information printing
# \param[in] TTId    : reference to a GEDEC if necessary
#
# \n
# E.g. Use <Keypad_ReadIOAbort "IO|AIAO|AO1|AO1S">
# E.g. Use <Keypad_ReadIOAbort "IO|IOAS|AO1">
proc Keypad_ReadIOAbort {  HMITree {display 0} {TTId ""} } {
    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    set elementHMI [ split $HMITree "|" ]
    set element1 [lindex $elementHMI 0]
    set page [lindex $elementHMI 1]
    set element3 [lindex $elementHMI 2]
    set element4 [lindex $elementHMI 3]
    if { $display } {TlPrint "element1 : $element1;page : $page;element3 : $element3 ;element4 : $element4"}
    Keypad_Select  $element1
    doWaitMs 500
    keypad_OK $display

    if {  $page == "AIAO"} {
	keypad_F3 1 $display
    } elseif { $page == "IOAS" } {

    } elseif { $page == "DIDO" } {
	keypad_F2 1 $display
    } elseif { $page == "RELA" } {
	keypad_F4 1 $display
    } else {
	TlError "can not find $element1|$page  "
    }

    if {  $element4 != "" } {
	Keypad_Select  $element3
	doWaitMs 500
	keypad_OK $display
	set result [Keypad_SelectAbort $element4]

    } else {
	set result [Keypad_SelectAbort $element3]

    }

    if {$result != 0} {
	TlError "$TTId No abort, I can find $HMITree"
    }

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Write the value of parameter from hmi tree for input/output menu parameters.
#

#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 120521 kaidi    proc created
# 251121 ASY	  added optional display parameter
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Write the value of parameter from hmi tree.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) .
# \param[in] value: expected value to write.
# \param[in] display : toggles the informations display
#
# \n
# E.g. Use <Keypad_WriteIO "IO|AIAO|AO1|AO1S" 250>
# E.g. Use <Keypad_WriteIO "IO|IOAS|AO1" .OCO>
proc Keypad_WriteIO { HMITree value {display 0} } {
    TlWrite LAC .EPR

    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    set element1 [lindex $elementHMI 0]
    set page [lindex $elementHMI 1]
    set element3 [lindex $elementHMI 2]
    set element4 [lindex $elementHMI 3]
    if { $display } { TlPrint "element1 : $element1;page : $page;element3 : $element3 ;element4 : $element4"}
    Keypad_Select  $element1
    doWaitMs 500
    keypad_OK $display
    # "F8440802013C00"

    if {  $page == "AIAO"} {
	keypad_F3 1 $display
    } elseif { $page == "IOAS" } {

    } elseif { $page == "DIDO" } {
	keypad_F2 1 $display
    } elseif { $page == "RELA" } {
	keypad_F4 1 $display
    } else {
	TlError "can not find $element1|$page  "
    }

    if {  $element3 != "" } {
	Keypad_Select  $element3
	doWaitMs 500
	keypad_OK $display
	set element $element3
	if {  $element4 != "" } {
	    Keypad_Select  $element4
	    doWaitMs 500
	    keypad_OK $display
	    set element $element4
	}
    }

    if { [ string match ".*" $value  ]} {

	set value [ string map {"." ""} $value ]
	Keypad_Select  $value
	doWaitMs 200
	keypad_OK $display
	doWaitMs 200
	keypad_OK $display
	keypad_Home $display
    } else {
	set currentValue  [TlRead $element ]
	#	if { $currentValue < $value   } {
	#		kpd_Touch "Up"
	#		kpd_Touch "No"
	#	}
	set diff [ expr ($currentValue-$value  )]
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"

	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }

	}
	keypad_OK 1
	TlPrint "$element : [TlRead $element ] "

    }

}

proc Keypad_keepAlive { timeout_s {silent 0} } {
    #Refresh keypad connection (keepAlive)
    if {$silent == 0} { TlPrint "Keep keypad alive for $timeout_s s" }
    for {set i 0 } {$i< [expr $timeout_s* 2] } { incr i} {
	if {[CheckBreak]} {break}
	puts -nonewline "."
	InitKeypad 0
	doWaitMs 500
    }
}

proc Keypad_keepAliveWaitForObject { object value timeout_s } {
    set startTime [clock clicks -milliseconds]
    while {![doWaitForObject $object $value 1 0xffffffff "" 1]} {
	if {[CheckBreak]} {break}
	Keypad_keepAlive 1 1

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startTime]

	if { [expr $waittime > [expr $timeout_s* 1000] ] } {
	    doWaitForObject $object $value 1
	    break
	}
    }
}

proc Keypad_keepAliveWaitForObjectList { object valueList timeout_s } {
    set startTime [clock clicks -milliseconds]
    while {![doWaitForObjectList $object $valueList 1 0xffffffff "" 1]} {
	if {[CheckBreak]} {break}
	Keypad_keepAlive 1 1

	after 2   ;# wait 1 mS
	update idletasks
	set waittime [expr [clock clicks -milliseconds] - $startTime]

	if { [expr $waittime > [expr $timeout_s* 1000] ] } {
	    doWaitForObjectList $object $valueList 1
	    break
	}
    }
}

#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 240921 YGH    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Write the value of parameter from hmi tree and returns title of warning message displayed on keypad when writing parameter.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) .
# \param[in] value: expected value to write.
# \param[in] doubleConfirm: shoud be set to 1 for parameters needing double confirmation at assignment.
#
# \n
# E.g. Use <Keypad_Write_getWarningMsgTitle CST|CSWM|ETF|ETF .LI4 >
proc Keypad_Write_getWarningMsgTitle { HMITree value {doubleConfirm 0}} {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2

    set msgScreenTitle ""
    InitKeypad  1
    doWaitMs 300
    keypad_Esc 1
    doWaitMs 300
    keypad_Home 1
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	keypad_OK 1
	doWaitMs 200
    }
    if { [ string match ".*" $value  ]} {

	set value [ string map {"." ""} $value ]
	Keypad_Select  $value
	doWaitMs 200
	keypad_OK 0
	doWaitMs 200
	set msgScreenTitle [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "01" $kpdScr1 ]  1 ]]
	set ltemp [regexp -all -inline -- {\S+} $msgScreenTitle]
	set ltemp [lindex $ltemp 1]
	set ltemp [split $ltemp "#" ]
	set msgScreenTitle [lindex $ltemp 1]
	keypad_OK 0
	doWaitMs 200
	if {$doubleConfirm == 1} {
	    keypad_OK 1
	    doWaitMs 200

	    #The following OK should be removed in ES25
	    keypad_OK 1
	    doWaitMs 200
	}
	keypad_Home 0
    } else {
	set currentValue  [TlRead $element ]
	#	if { $currentValue < $value   } {
	#		kpd_Touch "Up"
	#		kpd_Touch "No"
	#	}
	set diff [ expr ($currentValue-$value  )]
	TlPrint "Dif:$diff"
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"

	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }

	}
	keypad_OK 1
	TlPrint "$element : [TlRead $element ] "

    }

    return $msgScreenTitle
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Write the value of parameter from hmi tree and returns title of warning message displayed on keypad
# when writing parameter when warning is expected.

#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 270921 YGH    proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Write the value of parameter from hmi tree and returns title of warning message displayed on keypad
# 			  when writing parameter when warning is expected.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure).
# \param[in] value: expected value to write.
# \param[in] doubleConfirm: shoud be set to 1 for parameters needing double confirmation at assignment.
#
# \n
# E.g. Use <Keypad_WriteIO_getWarningMsgTitle "IO|IOAS|L3A" .LIINH>
proc Keypad_WriteIO_getWarningMsgTitle { HMITree value {doubleConfirm 0}} {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2

    TlWrite LAC .EPR

    set msgScreenTitle ""
    InitKeypad  1
    doWaitMs 300
    keypad_Esc 1
    doWaitMs 300
    keypad_Home 1
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    set element1 [lindex $elementHMI 0]
    set page [lindex $elementHMI 1]
    set element3 [lindex $elementHMI 2]
    set element4 [lindex $elementHMI 3]
    TlPrint "element1 : $element1;page : $page;element3 : $element3 ;element4 : $element4"
    Keypad_Select  $element1
    doWaitMs 500
    keypad_OK 1
    # "F8440802013C00"

    if {  $page == "AIAO"} {
	keypad_F3
    } elseif { $page == "IOAS" } {

    } elseif { $page == "DIDO" } {
	keypad_F2
    } elseif { $page == "RELA" } {
	keypad_F4
    } else {
	TlError "can not find $element1|$page  "
    }

    if {  $element3 != "" } {
	Keypad_Select  $element3
	doWaitMs 500
	keypad_OK 1
	set element $element3
	if {  $element4 != "" } {
	    Keypad_Select  $element4
	    doWaitMs 500
	    keypad_OK 1
	    set element $element4
	}
    }

    if { [ string match ".*" $value  ]} {

	set value [ string map {"." ""} $value ]
	Keypad_Select  $value
	doWaitMs 200
	keypad_OK 0
	doWaitMs 200
	set msgScreenTitle [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "01" $kpdScr1 ]  1 ]]
	set ltemp [regexp -all -inline -- {\S+} $msgScreenTitle]
	set ltemp [lindex $ltemp 1]
	set ltemp [split $ltemp "#" ]
	set msgScreenTitle [lindex $ltemp 1]
	keypad_OK 0
	doWaitMs 200
	if {$doubleConfirm == 1} {
	    keypad_OK 1
	    doWaitMs 200

	    #The following OK should be removed in ES25
	    keypad_OK 1
	    doWaitMs 200
	}
	keypad_Home 0
    } else {
	set currentValue  [TlRead $element ]
	#	if { $currentValue < $value   } {
	#		kpd_Touch "Up"
	#		kpd_Touch "No"
	#	}
	set diff [ expr ($currentValue-$value  )]
	TlPrint "Dif:$diff"
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"

	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }

	}
	keypad_OK 1
	TlPrint "$element : [TlRead $element ] "

    }
    return $msgScreenTitle
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Write the value of parameter from hmi tree with long hold of OK key.
#
# E.g. Use < Keypad_WriteHoldOK "MON|ELT|NSM" 20 2000> to write NSM to 20 with holding OK key pressed for 2000ms.
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 271121 YGH	  proc created
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Write the value of parameter from hmi tree with long hold of OK key.
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) .
# \param[in] value: expected value to write.
# \param[in] holdTimeMs: the time to hold the OK key pressed to confirm the writing.
#
# \n
# E.g. Use < Keypad_WriteHoldOK "MON|ELT|NSM" 20 2000> to write NSM to 20 with holding OK key pressed for 2000ms.
#
proc Keypad_WriteHoldOK { HMITree value holdTimeMs {display 0} } {
    global KpdAccess kpdScrStrSet kpdScrStr
    InitKeypad 1
    doWaitMs 300
    keypad_Esc $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 300
    set elementHMI [ split $HMITree "|" ]
    foreach element $elementHMI {
	Keypad_Select  $element
	doWaitMs 200
	keypad_OK $display
    }
    if { [ string match ".*" $value  ]} {
	set value [ string map {"." ""} $value ]
	Keypad_Select  $value
	doWaitMs 200
	keypad_OK $display
	doWaitMs 200
	keypad_OK $display
	keypad_Home $display
    } else {
	set currentValue  [TlRead $element ]
	set diff [ expr ($currentValue-$value  )]
	TlPrint "Dif:$diff"
	for { set a 1} {$a<=[expr abs( $diff)]} {incr a} {
	    if { $diff < 0} {

		kpd_Touch "Down"
		kpd_Touch "No"
	    } else {

		kpd_Touch "Up"
		kpd_Touch "No"
	    }
	}
	set startTime [clock clicks -milliseconds]
	while {[expr [clock clicks -milliseconds] - $startTime ] < $holdTimeMs } {
	    kpd_Touch "Ok"
	    mbDirect [format "%4s%2s%10s" $KpdAccess $kpdScrStrSet $kpdScrStr ] 1
	}
	kpd_Touch "No"
	TlPrint "$element : [TlRead $element ] "
    }
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
	if {[GetSysFeat "ATLAS"]} {
	    set status [readKeypadStatus]
	} else {
	    set status [readKeypadStatus_light]    
	}
	if { $status == $expectedStatus } {
	    TlPrint "Keypad status OK : exp=act=$status waittime=%d ms" [expr [clock clicks -milliseconds] - $start]
	    return
	}
	after 200
    }

    TlError "Keypad status not OK : exp=$expectedStatus act=$status waittime=%d ms" [expr [clock clicks -milliseconds] - $start]
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForKeypadStatusStable
# TYPE        : util
# AUTHOR      : ASY
# DESCRIPTION : wait until HMIS value displayed on keypad (on top left corner) is set to expectedStatus and is maintained during  stable time
#  expectedStatus: the expected status on keypad (on top left corner)
#  timeout:  seconds
#  stabletime : seconds
#  TTId: reference to a GEDEC if necessary
#
#END-------------------------------------------------------------------
proc doWaitForKeypadStatusStable { expectedStatus timeout stableTime {TTId ""} {noErrPrint 0 }} {
    set timeout     [expr int ($timeout*1000)] ;#in ms
	set stableTime     [expr int ($stableTime*1000)] ;#in ms
    set start [clock clicks -milliseconds]
    set status ""

    set tryNumber 1
    set changeFlag 0
    while {1} {
        after 2   ;# wait 2 mS
        update idletasks
        set waittime [expr [clock clicks -milliseconds] - $start]
        if { [expr $waittime > $timeout] && !$changeFlag} {
            if {$tryNumber!=1} {
                TlError "Keypad status not OK : exp=$expectedStatus act=$status waittime=%d ms" [expr [clock clicks -milliseconds] - $start]
                if {$noErrPrint == 0} { ShowStatus }
                return 0
            }
        } 
        if {[GetSysFeat "ATLAS"]} {
            set status [readKeypadStatus]
        } else {
            set status [readKeypadStatus_light]    
        }
        if { $status == $expectedStatus } {
            if { !$changeFlag } {
                set start2 [clock clicks -milliseconds]
                set changeFlag 1
                TlPrint "target value reached after [expr $start2 - $start] ms"
            }
            set waittime2 [expr [clock clicks -milliseconds] - $start2]
            if { [expr $waittime2 > $stableTime] } {
                TlPrint "Keypad status OK and stable : exp=act=$status waittime(%dms / %d requests)" [expr [clock clicks -milliseconds] - $start] $tryNumber
                return 1
            } 
        }
        if { $status != $expectedStatus  & $changeFlag} {
            set changeFlag 0
            TlPrint "Status changed from $expectedStatus to $status at $waittime ms after $waittime2 ms of stability"
        }

        incr tryNumber
        if {[CheckBreak]} {break}
    }
    return $status
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to get the current active channel displayed on the top right corner of the advanced keypad
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 230710 ASY    proc created

#---------------------------------------------------------------------------------
# Proc to get the current active channel displayed on the top right corner of the advanced keypad
#---------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Connects to the virtual keypad and returns the active channel displayed on the upper-right corner of the screen
# E.g. use < set res [readKeypadCommandChannel] > to get the current command channel from the keypad

proc readKeypadCommandChannel { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 0
    doWaitMs 300
    keypad_Home
    doWaitMs 300
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "07" $kpdScr0 ] 1 ] ]
    TlPrint $temp
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 7]

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

proc readKeypadStatus_light { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 0
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 2]

}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function used to check the visibility of a parameter based on the HMITree leading to it
# 
# E.g. Use < set visibility [Keypad_CheckVisibility "SYS|ACC"] > to get a boolean representing the parameter's visibility 1 if visible, 0 otherwise
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   WHO      WHAT
# 2023/03/08 ASY proc creation 
# 2023/04/11 ASY added visibility parameter and update of tabs handling
# 2023/04/13 ASY added TTid parameter
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Returns the visibility of a parameter based on the HMITree leading to it
#
# \param[in] HMITree: path of the parameter in HMI tree ("|" is used to separate hmi tree structure) .. to add a tab in the path, use F1,F2,F3,F4
# \param[in] visibility : expected visibility of the parameter. default value 1
# \param[in] display: 0 by default this parameter allows to toggle informations display
# \param[in] display: 0 by default this parameter allows to toggle informations display
#
# \n
# E.g. Use < set visibility [Keypad_CheckVisibility "SYS|ACC" 1] > to check that ACC is visible
# E.g. Use < set visibility [Keypad_CheckVisibility "CST|IO|F2|DI2|L2L" 1] > to check that L2L is visible
#
proc Keypad_CheckVisibility { HMITree {visibility 1} {display 0} {TTId ""}} {
    set TTId [Format_TTId $TTId]
    #Init Keypad
    InitKeypad  $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 300
    keypad_Home $display
    doWaitMs 500
    #Parse the HMITree
    set elementHMI [ split $HMITree "|" ]
    #Get the last element
    set lastElement [lindex $elementHMI end ]
    #Get all the elements but the last one
    set elementHMI [lrange $elementHMI 0 [expr [llength $elementHMI] - 2]]
    if { [llength $elementHMI ] > 0 } {
	foreach element $elementHMI {
	    #Check if the element starts with F to indicate navigation in tabs.
	    if { [regexp ^F $element] && [regexp \[1-4\] $element] && ([string length $element] == 2) } {
		if { [regexp \[1-4\] $element] && ([string length $element] == 2) } {
		    set function "keypad_"
		    append function $element
		    eval "$function 1"
		} else {
		    TlError "Tab outside of the allowed range"
		    return -1
		}
	    } else {
		if { [Keypad_Select  $element $visibility] == 0 } {
		    if { !$visibility} { TlPrint "Menu $element was not visible, then $lastElement will not be visible neither" }
		    return -1
		} 
		doWaitMs 500
		keypad_OK $display
	    }
	}
    }
    # Call the Keypad_Select function without the ErrPrint parameter in order to prevent TlError  
    set visible [expr [Keypad_Select $lastElement 0 ] != 0] 
    TlPrint "visible : $visible"
    set currentStatus [ string map {"1" "visible" "0" "not visible"} $visible] 
    set expectedStatus [ string map {"1" "visible" "0" "not visible"} $visibility]
    if { $visible != $visibility } { ;# case where current visibility is different from the expected one
	TlError "Parameter $lastElement is $currentStatus while it is expected to be $expectedStatus : $TTId"
	return 0
    } else {
	TlPrint "Parameter $lastElement is $currentStatus "
	return 1 
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Proc to read the content of a parameter in a tab from the keypad
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20230307 ASY    proc created

#---------------------------------------------------------------------------------
# Proc to read the content of a parameter in a tab from the keypad
#---------------------------------------------------------------------------------
# Doxygen Tag:
# Function description : Proc to get the status displayed on the upper left corner of the advanced keypad
# \param[in]  HMITree : path to the page where the tab choice happends 
# \param[in]  tab : number of the tab in which to go 
# \param[in]  param : name of the parameter to read 
# \param[in]  paramType : type of the parameter number or enumerated. default value number. possible values "num" and "enum"
# \param[in]  display : to activate the display of the various keypad functions used
# E.g. use < set res [Keypad_ReadInTab "SIM|SIM" 1 "IN" ] > to get the value of parameter IN in tab one of menu SIM 
# E.g. use < set res [Keypad_ReadInTab "SIM|SIM" 2 "L3A" "enum" ] > to get the value of parameter L3A in tab two of menu SIM 
proc Keypad_ReadInTab { HMITree tab param {paramType "num" } {display 0} } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    #Init Keypad and go back to home page
    InitKeypad 1
    doWaitMs 300
    keypad_Home
    doWaitMs 300
    #Check if paramtype is equal to num or enum 
    if { [string compare -nocase $paramType "num"] < 0 && [string compare -nocase $paramType "enum"] < 0} { 
	    TlError "wrong value for paramType parameter"
	    return -1
    }

    #split the string corresponding to the HMI path
    set elementHMI [ split $HMITree "|" ]
    #navigate through all the expected elements 
    foreach element $elementHMI {
	#if the element is not found return
	if { [Keypad_Select $element] == 0 } {return 0}
	doWaitMs 500
	keypad_OK $display
    }
    #check that the tab input is a value between 1 and 4 
    if { [regexp \[1-4\] $tab] && [string length $tab] == 1 } {
	set function "keypad_F"
	append function $tab
        eval $function
    } else {
	    TlError "Tab outside of the allowed range"
	    return -1
    }
    Keypad_Select $param
    doWaitMs 500

    if { [string compare -nocase $paramType "num"] == 0 } {
	keypad_OK $display
    }
    set valuelist [  Hexa2Ascii [ mbDirect "F8440802013C00"  1 ]]
    if { [string compare -nocase $paramType "num"] == 0 } {
        set newValueList "[lindex $valuelist 2][lindex $valuelist 3]"
    } else { 
	# Search the first item in the response frame containing a # 
	# ==> could be replaced by the name of the name of the list to which the parameter is linked
        set newValueList [lindex $valuelist [lsearch -regexp $valuelist "#"]]
        set index [string first "#" $newValueList]
        set newValueList [string range $newValueList [expr $index + 1] end]
    }
    return $newValueList
}

#DOC-----------------------------------------------------------------------------------------------------------------------
#
# Function used for ATS430 to wait end of forcing state to embedded keypad (see GitHub issue #793)
# 
# E.g. Use < ATS430_waitEmbKPDForcedFinished 5000 > to wait end of forcing state to embedded keypad for 5000 ms
#
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN   	WHO      WHAT
# 2023/04/18 	Yahya	 proc creation 
# 2023/06/22	Yahya	 Added wait end of embedded keypad first full start before returning to authorize external keypad connection
#
#END-----------------------------------------------------------------------------------------------------------------------
# Doxygen Tag:
## Function description : Function used for ATS430 to wait end of forcing state to embedded keypad (see GitHub issue #793)
#
# \param[in] timeoutMs: wait time in ms
#
# \n
# E.g. Use < ATS430_waitEmbKPDForcedFinished 5000 > to wait end of forcing state to embedded keypad for 5000 ms
proc ATS430_waitEmbKPDForcedFinished { timeoutMs } {
    set startTime [clock clicks -milliseconds]
    set rc [catch { mbDirect F84400000A0000 1 } ]
    if { $rc == 0 } { return }
    while { $rc != 0 } {
	if { [expr [clock clicks -milliseconds] - $startTime] > $timeoutMs } {
	    TlError "Embedded keypad forced state not finished after [expr [clock clicks -milliseconds] - $startTime] ms"
	    return
	}
	doWaitMs 200
	set rc [catch { mbDirect F84400000A0000 1 } ]
    }

    #Wait end of embedded keypad first full start before returning to authorize external keypad connection
    set firstInitStartTime [clock clicks -milliseconds]
    while { [expr [clock clicks -milliseconds] - $firstInitStartTime] < 2500 } {
	mbDirect F8440A0F010246310202463203024633040246340503454E540603455343810453544F50820352554E0704484F4D4583024C520804494E464F0D034157550E034157440F0341574C1003415752 1
	mbDirect F844100C045254430004544142000544415348000543555256000649435552560006435553544F00044C4F470008424B4C4947485400065152434F44000856554D455445520006464D505631000743555256585900 1
	mbDirect F8440C0014020C081636B0 1
	mbDirect F8440E030000 1
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Reads the status of alarm pictogram on keypad.
# Returns "ALR0" if alarm pictogram is NOT displayed
# Returns "ALR1" if alarm pictogram is displayed
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 260221 Kaidi    proc created
# 141123 Yahya	  Moved proc to library and document it (see Issue #1396)
#
#END----------------------------------------------------------------
## Function description : Reads the status of alarm pictogram on keypad
#
# E.G. use < set pictogram [readKeypadPictogram] > to get status of alarm pictogram on the keypad.
proc readKeypadPictogram { } {
    global KpdAccess kpdScrAct kpdScr0 kpdScr1 kpdScr2
    InitKeypad 1
    set temp [ Hexa2Ascii [ mbDirect [format "%4s%2s%2s%6s" $KpdAccess $kpdScrAct "00" $kpdScr0 ] 1 ] ]
    TlPrint "--------------"
    TlPrint "temp is $temp"
    TlPrint "--------------"
    set ltemp [regexp -all -inline -- {\S+} $temp]
    return [lindex $ltemp 6]
}
