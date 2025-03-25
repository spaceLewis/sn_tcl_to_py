###############################################################################
# DESCRIPTION                                                                 #
# Skript contains TCL_Debugger Procedures to be executed by the Interperter   #
#                                                                             #
#                                                                             #
# ----------HISTORY----------                                                 #
#  WHEN        WHO        WHAT                                                #
#  240212      warkp      script created                                      #
#                                                                             #
###############################################################################

##Put this code in your applications event loop to activate Tcl_Debugger
#global Debugger_Active
#if {$Debugger_Active} {
#   after 5
#   update idletask
#}
##Put this code in your applications event loop to activate Tcl_Debugger

###################################################
##  Tcl_Debugger Settings                        ##
###################################################
package require dde

set Servername MyDDEServer
dde servername -force $Servername

global Debugger_Active
global DebuggerCNT
global Debugger_StopParaRead
global Debugger_InterpreterStop
global debugger_BreakpointFlag
global debugger_InterpreterFinished
global debugger_LogModeFlag

set Debugger_Active 0
set debugger_BreakpointFlag 0
set DebuggerCNT 0
set Debugger_StopParaRead 0
set Debugger_InterpreterStop 0
set debugger_InterpreterFinished 0
set debugger_LogModeFlag 0

puts ""
puts "**** DDE Server $Servername started ****"
puts ""
###################################################
##  Tcl_Debugger Settings                        ##
###################################################

###################################################
# DESCRIPTION                                     #
# Procedure to Read ServoDrive Objects with       #
# Modbus serial Interface                         #
#                                                 #
# ----------HISTORY----------                     #
#  WHEN        WHO        WHAT                    #
#  240212      warkp      proc created            #
#                                                 #
###################################################
proc Debugger_ModTlRead {Object} {

	global Debugger_StopParaRead

	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by other procedures
	if { "$Debugger_StopParaRead" == "1" } {
		return "access denied"
	}
	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by other procedures

	set result [ModTlRead $Object]

	return $result
}

###################################################
# DESCRIPTION                                     #
# To stop/start Interpreter by the Tcl_Debugger   #
#                                                 #
#                                                 #
# ----------HISTORY----------                     #
#  WHEN        WHO        WHAT                    #
#  240212      warkp      proc created            #
#                                                 #
###################################################
proc Debugger_ApplicationStopStart {} {

	global Debugger_InterpreterStop

	##Output
	puts ""
	puts "**** Stopped by TCL_Debugger ****"
	puts ""
	##Output

	vwait Debugger_InterpreterStop
}

###################################################
# DESCRIPTION                                     #
# To handle Tcl_Debugger Breakpoints              #
#                                                 #
#                                                 #
# ----------HISTORY----------                     #
#  WHEN        WHO                 WHAT           #
#  270212      warkp               proc created   #
###################################################
proc Debugger_Breakpoint {{BreakpointType {}}} {

	global debugger_BreakpointFlag
	global debugger_GetLokalVars
	global debugger_GetCommand
	global debugger_GetLokalVarValue
	global debugger_GetBreakPointType

	set debugger_GetLokalVars 0
	set debugger_GetLokalVarValue 0
	set debugger_GetCommand 0
	set debugger_GetBreakPointType 0

	##activate Breakpoint for Tcl_Debugger
	set debugger_BreakpointFlag 1
	##activate Breakpoint for Tcl_Debugger

	##Output
	puts ""
	puts "**** TCL_Debugger Breakpoint: $BreakpointType ****"
	puts ""
	##Output

	while 1 {

		##Continuing on Skript
		if {!$debugger_BreakpointFlag} {
			break
		}
		##Continuing on Skript

		##Get BreakpointType
		if {$debugger_GetBreakPointType} {
			set debugger_GetBreakPointType $BreakpointType
			vwait debugger_GetBreakPointType
			set debugger_GetBreakPointType [info level -1]
			vwait debugger_GetBreakPointType
		}
		##Get BreakpointType

		##Get Lokal Variables from current Interpreter procedure
		if {$debugger_GetLokalVars} {
			set line "info locals"
			catch {uplevel 1 $line} debugger_GetLokalVars
			vwait debugger_GetLokalVars
		}
		##Get Lokal Variables from current Interpreter procedure

		##Get Lokal Variable Value
		if {$debugger_GetLokalVarValue} {
			vwait debugger_GetLokalVarValue
			update idletask
			catch {uplevel 1 set "$debugger_GetLokalVarValue" $$debugger_GetLokalVarValue} debugger_GetLokalVarValue
			vwait debugger_GetLokalVarValue
		}
		##Get Lokal Variable Value

		##Handle everything else
		if {$debugger_GetCommand} {
			vwait debugger_GetCommand
			update idletask
			catch {uplevel 1 $debugger_GetCommand} debugger_GetCommand
			vwait debugger_GetCommand
		}
		##Handle everything else

		after 50
		update idletask
	}

}

###################################################
# DESCRIPTION                                     #
# Procedure to Read/Write global Variables        #
#                                                 #
#                                                 #
# ----------HISTORY----------                     #
#  WHEN        WHO        WHAT                    #
#  290212      warkp      proc created            #
#                                                 #
###################################################
proc Debugger_RWVariable {Object {Value "ReadMode"}} {

	global debugger_InterpreterFinished
	global debugger_GetCommand

	##Do only  allow access to Read global Variables by Tcl_Debugger if the Interpreter is not stopped
	#Not implemented yet
	if {$debugger_InterpreterFinished} {
		return "Interpreter finished"
	}
	##Do only  allow access to Read global Variables by Tcl_Debugger if the Interpreter is not stopped

	##Read/Write global Variable
	global $Object
	if {"$Value" == "ReadMode"} {
		catch {uplevel 1 set dummy $$Object} Object
		return $Object
	} else {
		set Value \{$Value\}
		catch {uplevel 1 set "$Object" $Value} Object
		return $Object
	}
	##Read/Write global Variable

}

###################################################
# DESCRIPTION                                     #
# Procedure to Read a List of variables and       #
# parameters                                      #
#                                                 #
# ----------HISTORY----------                     #
#  WHEN        WHO        WHAT                    #
#  290212      warkp      proc created            #
#                                                 #
###################################################
proc Debugger_ReadList args {

	global Debugger_StopParaRead

	#Get number of global variables and number of parameters
	set Listlength [expr [llength $args] -1]
	set ListLengthVars [lsearch $args "EOF"]
	set ListLengthPars [expr $Listlength - $ListLengthVars]
	#Get number of variables and number of parameters

	##Get all global variables
	set cnt 0
	set cntListLengthVars $ListLengthVars
	while {$cntListLengthVars} {
		set ListElement [lindex $args $cnt]
		global $ListElement
		catch {uplevel 1 set ListElement $$ListElement} ListElement
		lappend NewList $ListElement
		incr cntListLengthVars -1
		incr cnt
	}
	##Get all global variables

	##Get all Parameters from ServoDrive
	set cnt [expr $ListLengthVars + 1]
	set cntListLengthPars $ListLengthPars
	while {$cntListLengthPars} {
		set ListElement [lindex $args $cnt]

		if {$Debugger_StopParaRead} {
			set ListElement "Access denied"
		} else {
			set ListElement [ModTlRead $ListElement]
		}
		lappend NewList $ListElement

		incr cntListLengthPars -1
		incr cnt
	}
	##Get all Parameters from ServoDrive

	return $NewList
}

