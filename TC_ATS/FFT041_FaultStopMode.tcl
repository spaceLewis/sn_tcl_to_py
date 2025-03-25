# ---------- File HISTORY ------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      Yahya    Scripts implemented with TestSpec (IE02-01) & FFT (IE02-01)
# 08/24/2023      Lylia    Scripts implemented with TestSpec (IE02-02) & FFT (IE02-01)
#END----------------------------------------------------------------

append_test theTestProcList TC_FFT041_FaultStopMode_TestfileStart    {DevAll}
append_test theTestProcList TC_FFT041_FaultStopMode_TC01  { ATS48P OPTIM  BASIC}
append_test theTestProcList TC_FFT041_FaultStopMode_TC02  { ATS48P OPTIM  BASIC}
append_test theTestProcList TC_FFT041_FaultStopMode_TC03  { ATS48P OPTIM  BASIC}
append_test theTestProcList TC_FFT041_FaultStopMode_TC04  { ATS48P OPTIM  BASIC}
append_test theTestProcList TC_FFT041_FaultStopMode_TC05  { ATS48P OPTIM  }
append_test theTestProcList TC_FFT041_FaultStopMode_TC06  { ATS48P OPTIM  BASIC}
append_test theTestProcList TC_FFT041_FaultStopMode_TestfileStop    {DevAll}


# Doxygen Tag : 
##Function description : TestfileStart
proc TC_FFT041_FaultStopMode_TestfileStart { } {
    TlTestCase "Start test file"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "Start test file"
    TlPrint "#-------------------------------------------------------------------"

    global ActDev mainpath StopModeList

    DeviceOn $ActDev
    ATSParaIdentificaiton
    doSetDefaults 0 0 0

    if {[GetDevFeat "ATS48P"] } {
	set StopModeList [list   "D" "B" "F"]

    } elseif {[GetDevFeat "BASIC"]  } {
	set StopModeList [list "D" "F"]

    } elseif {[GetDevFeat "OPTIM"] } {
	#NOTE : stop by reverse will not be implemented for optimum (design feedback on 06/10/2022)
	set StopModeList [list  "D" "B" "F"]
    } else {
	TlError "ATS48 ATS48P OPTIM and BASIC allowed"
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when no error behavior is linked to error triggered
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when no error behavior is linked to error triggered
#Check motor stops on freewheel at error detection

proc TC_FFT041_FaultStopMode_TC01 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC01"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when no error behavior is linked to error triggered"
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode 
    foreach StopMode $StopModeList {

	TlPrint "============== Test for stop mode : $StopMode ==============" 

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"

	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	if { $StopMode == "D"  } {
	    LoadOn
	    TlPrint "--------------------SET LoadVelocity 0 0"
	    LoadVelocity 0 0
	}

	DIAssigne 3 EXTERNAL_ERROR_ASSIGNMENT_ID 1

	#-Give a run order
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS { .BYP .RUN } [expr [TlRead ACC]*1.5]

	if { $StopMode == "D"  } {
	    TlPrint "--------------------SET LoadVelocity 0 400"
	    LoadVelocity 0 400
	}


	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}


	#-Generate an error with no error behavior
	setDI 3 H

	#Check:
	#- Motor stops immediately on freewheel stop
	doWaitForObject OCR 0 1

	#- Error is triggered immediately and displayed on HMI
	doWaitForKeypadStatus "EPF1" 2

	#check HMIS & LFT
	doWaitForObject HMIS .FLT 1
	doWaitForObject LFT .EPF1 1

	#- Fault relay if configured behavior depends on type of error triggered:
	#>>Remains CLOSED when automatioc restart sequence is in progress
	#>> OPENED when automatic restart sequence is not in progress
	#- End of starting relay if configured is OPENED 
	#- Isolating relay if configured is OPENED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 0 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	if { $StopMode == "D"  } {
	    LoadOff
	}

	ATSBackToIniti
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when error behavior linked to error triggered is not configured 
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when error behavior linked to error triggered is not configured 
#Verify that the device ignores the error

proc TC_FFT041_FaultStopMode_TC02 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC02"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when error behavior linked to error triggered is not configured "
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode 
    foreach StopMode $StopModeList {

	TlPrint "=============== Test for stop mode : $StopMode, fault behavior SLL is NO =============="

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"
	} else {
	    TlError "Device is not taken into account in this TC"
	}


	# [ERROR_BEHAVIOR] = NO
	TlWrite SLL .NO
	doWaitForObject SLL .NO 1

	TlWrite TTO 30
	doWaitForObject TTO 30 1

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	if { $StopMode == "D"  } {
	    LoadOn
	    TlPrint "--------------------SET LoadVelocity 0 0"
	    LoadVelocity 0 0
	}

	#-Give a run order
	ATSCommandSwitch STD MDB
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS {.BYP .RUN } [expr [TlRead ACC]*1.5]

	if { $StopMode == "D"  } {
	    TlPrint "--------------------SET LoadVelocity 0 400"
	    LoadVelocity 0 400
	}

	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#-Generate an error which [ERROR_BEHAVIOR] = NO
	set TTOTime [TlRead TTO]
	TlPrint "wait more than $TTOTime to  Generate an error which ERROR_BEHAVIOR = NO"
	set WaitTime [expr 500 + 100 * $TTOTime]
	doWaitMs  $WaitTime

	#Check:
	#- Motor remains running
	#- No error is triggered
	doWaitForObjectList HMIS {.BYP .RUN }  1

	#- Relays remain it state
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#- Alarm corresponding to the error is raised
	#check ALR6.b14=1
	doWaitForObject ALR6 0x4000 1 0x4000  "GEDEC00283086" ;#SLLA
	#check ST17.b5=1
	doWaitForObject ST17 0x20 1 0x20 "GEDEC00283086" ;#SLLA

	if { $StopMode == "D"  } {
	    LoadOff
	}

	MotorStop 1; #Stop motor with Check that motor is correctly stopped
	ATSBackToIniti
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when error behavior linked to error triggered is configured on YES
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when error behavior linked to error triggered is configured on YES
#Check motor stops on freewheel at error detection

proc TC_FFT041_FaultStopMode_TC03 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC03"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when error behavior linked to error triggered is configured on YES"
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode 
    foreach StopMode $StopModeList {

	TlPrint "=============== Test for stop mode : $StopMode, fault behavior SLL is YES =============="

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"
	} else {
	    TlError "Device is not taken into account in this TC"
	}


	# [ERROR_BEHAVIOR] = YES
	TlWrite SLL .YES
	doWaitForObject SLL .YES 1

	TlWrite TTO 30
	doWaitForObject TTO 30 1

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	if { $StopMode == "D"  } {
	    LoadOn
	    TlPrint "--------------------SET LoadVelocity 0 0"
	    LoadVelocity 0 0
	}

	#-Give a run order
	ATSCommandSwitch STD MDB
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS { .BYP .RUN } [expr [TlRead ACC]*1.5]

	if { $StopMode == "D"  } {
	    TlPrint "--------------------SET LoadVelocity 0 400"
	    LoadVelocity 0 400
	}

	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}
	#-Generate an error which [ERROR_BEHAVIOR] = YES
	set TTOTime [TlRead TTO]
	TlPrint "wait more than $TTOTime to  Generate an error which ERROR_BEHAVIOR = YES"
	set WaitTime [expr 500 + 100 * $TTOTime]
	doWaitMs  $WaitTime

	#Check:
	#- Motor stops immediately on freewheel stop 
	doWaitForObject OCR 0 1  ;#check stop in freewheel

	#- Error is triggered immediately and displayed on HMI
	doWaitForKeypadStatus "SLF1" 2  

	#check HMIS & LFT
	doWaitForObject HMIS .FLT 1
	doWaitForObject LFT .SLF1 1

	#- Fault relay if configured behavior depends on type of error triggered:
	#>>Remains CLOSED when automatioc restart sequence is in progress
	#>> OPENED when automatic restart sequence is not in progress
	#- End of starting relay if configured is OPENED 
	#- Isolating relay if configured is OPENED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 0 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	if { $StopMode == "D"  } {
	    LoadOff
	}

	MotorStop 1
	ATSBackToIniti
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when error behavior linked to error triggered is configured on DEC
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when error behavior linked to error triggered is configured on DEC
#Check motor stops on decelerated stop at error detection and error is triggered once motor is completely stopped

proc TC_FFT041_FaultStopMode_TC04 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC04"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when error behavior linked to error triggered is configured on DEC"
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode 
    foreach StopMode $StopModeList {

	TlPrint "=============== Test for stop mode : $StopMode, fault behavior SLL is DEC =============="

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	# [ERROR_BEHAVIOR] = DEC
	TlWrite SLL .DEC
	doWaitForObject SLL .DEC 1

	TlWrite TTO 30
	doWaitForObject TTO 30 1

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	LoadOn
	TlPrint "--------------------SET LoadVelocity 0 0"
	LoadVelocity 0 0

	#-Give a run order
	ATSCommandSwitch STD MDB
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS { .BYP .RUN }  [expr [TlRead ACC]*1.5]

	TlPrint "--------------------SET LoadVelocity 0 400"
	LoadVelocity 0 400

	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#-Generate an error which [ERROR_BEHAVIOR] = DEC
	set TTOTime [TlRead TTO]
	TlPrint "wait more than $TTOTime to  Generate an error which ERROR_BEHAVIOR = DEC"
	set WaitTime [expr 500 + 100 * $TTOTime]
	doWaitMs  $WaitTime

	#- Motor stops immediately on decelerated stop
	doWaitForObject HMIS .DEC 2

	#During deceleration state, check:
	#- Fault relay if configured remains CLOSED
	#- End of starting relay if configured is OPENED 
	#- Isolating relay if configured is CLOSED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 0 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 0 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#- Error is triggered once motor is completely stopped and displayed on HMI
	#check HMIS & LFT
	doWaitForNotObject HMIS .DEC 20
	doWaitForObject HMIS .FLT 2
	doWaitForObject LFT .SLF1 1
	doWaitForKeypadStatus "SLF1" 2

	#- At end of deceleration stop:
	#>>Fault relay if configured behavior depends on type of error triggered:
	#>>>>Remains CLOSED when automatioc restart sequence is in progress
	#>>>> OPENED when automatic restart sequence is not in progress
	#>> End of starting relay if configured is OPENED 
	#>> Isolating relay if configured is OPENED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 0 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	LoadOff

	MotorStop 1
	ATSBackToIniti
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when error behavior linked to error triggered is configured on BRK
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when error behavior linked to error triggered is configured on BRK
#Check motor stops on braking stop at error detection and error is triggered once motor is completely stopped

proc TC_FFT041_FaultStopMode_TC05 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC05"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when error behavior linked to error triggered is configured on BRK"
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode 
    foreach StopMode $StopModeList {

	TlPrint "=============== Test for stop mode : $StopMode, fault behavior SLL is BRK =============="

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"
	} else {
	    TlError "Device is not taken into account in this TC"
	}


	# [ERROR_BEHAVIOR] = BRK
	TlWrite SLL .BRK
	doWaitForObject SLL .BRK 1

	TlWrite TTO 30
	doWaitForObject TTO 30 1

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	if { $StopMode == "D"  } {
	    LoadOn
	    TlPrint "--------------------SET LoadVelocity 0 0"
	    LoadVelocity 0 0
	}

	#-Give a run order
	ATSCommandSwitch STD MDB
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS {.BYP .RUN} [expr [TlRead ACC]*1.5]

	if { $StopMode == "D"  } {
	    TlPrint "--------------------SET LoadVelocity 0 400"
	    LoadVelocity 0 400
	}

	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#-Generate an error which [ERROR_BEHAVIOR] = BRK
	set TTOTime [TlRead TTO]
	TlPrint "wait more than $TTOTime to  Generate an error which ERROR_BEHAVIOR = BRK"
	set WaitTime [expr  100 * $TTOTime]
	doWaitMs  $WaitTime

	#Check:
	#- Motor stops immediately on braking stop 
	doWaitForObject HMIS .BRL 2

	#During braking state, check:
	#- Fault relay if configured remains CLOSED
	#- End of starting relay if configured is OPENED 
	#- Isolating relay if configured is CLOSED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 0 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 0 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#- Error is triggered once motor is completely stopped and displayed on HMI
	#check HMIS & LFT
	doWaitForNotObject HMIS .BRL 20
	doWaitForObject HMIS .FLT 2
	doWaitForObject LFT .SLF1 1
	doWaitForKeypadStatus "SLF1" 2

	#- At end of braking stop:
	#>>Fault relay if configured behavior depends on type of error triggered:
	#>>>>Remains CLOSED when automatioc restart sequence is in progress
	#>>>> OPENED when automatic restart sequence is not in progress
	#>> End of starting relay if configured is OPENED 
	#>> Isolating relay if configured is OPENED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 0 0 0
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 0 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	if { $StopMode == "D"  } {
	    LoadOff
	}

	MotorStop 1
	ATSBackToIniti
    }
}


#DOC----------------------------------------------------------------
#DESCRIPTION 
#
# Device reaction when error behavior linked to error triggered is configured on STT
# 
# ----------HISTORY------------------------------------------------
# WHEN            WHO      WHAT
# 12/26/2022      XXX    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag : 
##Function description : Device reaction when error behavior linked to error triggered is configured on STT
#'Check motor stops following stop mode configured at error detection and no error is triggered

proc TC_FFT041_FaultStopMode_TC06 { } {
    global  StopModeList STP_MODE
    TlTestCase "TC06"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "#          Title : Device reaction when error behavior linked to error triggered is configured on STT"
    TlPrint "#-------------------------------------------------------------------"

    #Test will be done with all possible values of stop mode
    foreach StopMode $StopModeList {

	TlPrint "=============== Test for stop mode : $StopMode, fault behavior SLL is STT =============="

	if { [GetDevFeat "ATS48P"] } {
	    setRelayConfiguration "ISOL" "BPS" "FLT"

	} elseif { [GetDevFeat "OPTIM"] } {
	    setRelayConfiguration "FLT" "BPS" "FLT"

	} elseif { [GetDevFeat "BASIC"] } {
	    setRelayConfiguration "FLT" "BPS"
	} else {
	    TlError "Device is not taken into account in this TC"
	}


	# [ERROR_BEHAVIOR] = STT
	TlWrite SLL .STT
	doWaitForObject SLL .STT 1

	TlWrite TTO 30
	doWaitForObject TTO 30 1

	#configure the stop mode
	TlWrite $STP_MODE .$StopMode
	doWaitForObject $STP_MODE .$StopMode 1

	if { $StopMode == "D"  } {
	    LoadOn
	    TlPrint "--------------------SET LoadVelocity 0 0"
	    LoadVelocity 0 0
	}

	#-Give a run order
	ATSCommandSwitch STD MDB
	TlPrint "#------------------------give a RUN order"
	MotorStart
	doWaitForObjectList HMIS { .BYP .RUN } [expr [TlRead ACC]*1.5]

	if { $StopMode == "D"  } {
	    TlPrint "--------------------SET LoadVelocity 0 400"
	    LoadVelocity 0 400
	}

	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 1 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 1
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	#-Generate an error which [ERROR_BEHAVIOR] = STT
	set TTOTime [TlRead TTO]
	TlPrint "wait more than $TTOTime to  Generate an error which ERROR_BEHAVIOR = STT"
	set WaitTime [expr  100 * $TTOTime]
	doWaitMs  $WaitTime

	#Check:
	#- Motor stops immediately following stop mode configured  
	#- Error is never triggered
	#- Fault relay if configured remains CLOSED
	#- End of starting relay if configured is OPENED 
	#- Isolating relay if configured is CLOSED if STT is not configured on freewheel, ohterwise it is OPENED {ATLAS_ATS48+}
	switch  $StopMode {
	    "B"
	    {
		doWaitForObject HMIS .BRL 2;#check stop in braking
		if { [GetDevFeat "ATS48P"] } {
		    checkAllRelayStatus 1 0 1
		} elseif { [GetDevFeat "OPTIM"] } {
		    checkAllRelayStatus 1 0 1
		} elseif { [GetDevFeat "BASIC"] } {
		    checkAllRelayStatus 1 0
		} else {
		    TlError "Device is not taken into account in this TC"
		}
		doWaitForObject HMIS .RDY 20
	    }
	    "F"
	    {
		doWaitForObject HMIS .TBS 2;#check stop in freewheel
		if { [GetDevFeat "ATS48P"] } {
		    checkAllRelayStatus 0 0 1
		} elseif { [GetDevFeat "OPTIM"] } {
		    checkAllRelayStatus 1 0 1
		} elseif { [GetDevFeat "BASIC"] } {
		    checkAllRelayStatus 1 0
		} else {
		    TlError "Device is not taken into account in this TC"
		}
		doWaitForObject HMIS .RDY 20
	    }
	    "D"
	    {
		doWaitForObject HMIS .DEC 2;#check stop in dec
		if { [GetDevFeat "ATS48P"] } {
		    checkAllRelayStatus 1 0 1
		} elseif { [GetDevFeat "OPTIM"] } {
		    checkAllRelayStatus 1 0 1
		} elseif { [GetDevFeat "BASIC"] } {
		    checkAllRelayStatus 1 0
		} else {
		    TlError "Device is not taken into account in this TC"
		}
		doWaitForObject HMIS .RDY 20
	    }
	}

	#- At end of  stop, :
	#>>Fault relay if configured remains CLOSED:
	#>> End of starting relay if configured is OPENED 
	#>> Isolating relay if configured is OPENED {ATLAS_ATS48+}
	if { [GetDevFeat "ATS48P"] } {
	    checkAllRelayStatus 0 0 1
	} elseif { [GetDevFeat "OPTIM"] } {
	    checkAllRelayStatus 1 0 1
	} elseif { [GetDevFeat "BASIC"] } {
	    checkAllRelayStatus 1 0
	} else {
	    TlError "Device is not taken into account in this TC"
	}

	if { $StopMode == "D"  } {
	    LoadOff
	}

	MotorStop 1
	ATSBackToIniti
    }
}


# Doxygen Tag : 
##Function description : TestfileStop
proc TC_FFT041_FaultStopMode_TestfileStop { } {
    TlTestCase "Stop test file"
    TlPrint "#-------------------------------------------------------------------"
    TlPrint "Stop test file"
    TlPrint "#-------------------------------------------------------------------"

    global ActDev StopModeList
    unset -nocomplain StopModeList

    ATSBackToIniti
    DeviceOff $ActDev
}


