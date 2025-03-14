#
# CPD Test environment
# Project: ATV32 & NERA & NERA Medium Offer
# Filename     : cmd_Mod_ATV_tlxxx.tcl
#
#
# ----------HISTORY----------
# WHEN      WHO      WHAT
# 300304    pfeig    Attached file
# 010404    pfeig    TlWrite TlRead
# 050404    pfeig    TlSend  TlWriteAbort
# 270504    pfeig    Object Info added to TlError
# 090704    pfeig    Upgrading to 7000er Parameter in TlWrite
# 270904    pfeig    Upgrading to 7000er Parameter also for TlRead
# 051004    pfeig    Error Code Return for TlWrite
# 041104    pfeig    theVARHashtable
# 180105    pfeig    BreakPoint Variable and Code to detect a Modbus error
# 080205    pfeig    Firmware Variables identification rebuild (of _ for Vari on . for Object)
# 210405    ockeg    TlWriteAbort bored for Indexes > 127
# 280405    pfeig    new Read/Write with upgraded protocol string
# 210705    pfeig    TlRead { objString {NoErrPrint 0}
# 250705    grana    TlSendSilent

# 030506    pfeig    checkDCOM_NAct created to read the speed on different Ifc with the same function
# 250612    lefef    Add Enum_number in TlWrite to can use TlWrite with value name for enumeration
# parameters
# 121013    haimingw Update TlReadAbort and TlWriteAbort, add one acceptable case that negative
# response is also expected test results except for communication abort
# 151013    haimingw Change the use of the ParameterList by new proc Param_Name, Param_Index and
# Param_Type in TlRead, TlReadAbort, TlWrite, TlWriteAbort
# 280114    serio    adapt TlWrite to check that result of mbdirect is positive.
# 030214    serio    enhance TlWrite to report the kind of error code
# 230622    savra    create the TlSetBits function
#--------------------------------------------------------------------------------------------------------------
#
#      MOD-Bus Master for TCL-Testturm
#
#   Normal object accesses with TlRead/TlWrite etc. execute on Mod-Bus
#   Is activated when test environment is started with interface=MOD
#
#--------------------------------------------------------------------------------------------------------------

global ActInterface
set ActInterface "MOD"
TlPrint "Actual bus interface: $ActInterface"

TlDebugLevel 0     ;# Debug-Flag

#----------------------------------------------------------------------------
proc TlSendNoResponse { frame {crc 1} } {
    global theDebugFlagObj errorInfo

    set rc [catch { set result [mbDirect $frame $crc] }]
    if {$rc != 0} {
	set result ""
	TlPrint "TlSendNoResponse: [GetFirstLine $errorInfo]"
    } else {
	TlError "TlSendNoResponse: send:$frame  received:$result"
    }

    if {$theDebugFlagObj} {
	set emptyList {}
	TlPrintIntern D "send $frame : $result" emptyList
    }

    return $result
} ;#TlSendNoResponse

#----------------------------------------------------------------------------
proc TlSend { frame {crc 1} } {

    set result [ModTlSend $frame $crc]
    return $result

} ;#TlSend

#----------------------------------------------------------------------------
proc TlSendSilent { frame {crc 1} } {
    global theDebugFlagObj errorInfo

    set rc [catch { set result [mbDirect $frame $crc] }]
    if {$rc != 0} {
	set result ""
	TlError "TCL-Error message: $errorInfo"
    }

    if {$theDebugFlagObj} {
	set emptyList {}
	TlPrintIntern D "send $frame : $result" emptyList
    }

    return $result
} ;#TlSendSilent

#-----------------------------------------------------------------------
proc TlSendAndReceive { desc sndFrame rcvFrame {crc 1} {CQId ""}} {

    TlPrint "Test: $desc"
    CheckBreak

    set answer [TlSend $sndFrame $crc]
    if {$answer == $rcvFrame} {
	#      TlPrint "ok   $sndFrame : $answer" is doing now TlSend
    } else {
	if {$CQId != "" } { set CQId "*$CQId*" }
	TlError "$CQId Communication error at :$desc"
	TlPrint "sent    : $sndFrame"
	TlPrint "received: $answer"
	TlPrint "expected: $rcvFrame"
	ShowStatus
    }
} ;#TlSendAndReceive

#----------------------------------------------------------------------------
proc TlRead { objString {NoErrPrint 0} {TTId ""}} {

    set result [ModTlRead $objString $NoErrPrint $TTId]
    return $result
} ;#TlRead

#----------------------------------------------------------------------------
proc TlReadAbort { objString {sollErrCode 0} {TTId ""}} {
    global theDebugFlagObj errorInfo glb_Error
    global DevAdr ActDev BreakPoint

    TlError "Function not yet implemented for ATV"

    set result 0
    set glb_Error 0

    set TTId [Format_TTId $TTId]

    set LogAdr        [lindex [GetParaAttributes $objString] 0]
    set ParaType      [lindex [GetParaAttributes $objString] 3]

    # check if datatype is UINT32 or INT32
    # if {[string first "INT32" $ParaType ] == -1} {
    # if not -> 16 Bit
    #    set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0001"
    # $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 9]] }]
    # } else {
    #else -> 32 Bit
    #    set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0002"
    # $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 13]] }]
    # }

    # if not -> 16 Bit, #else -> 32 Bit, but in fact Altivar parameters´ value always 16bit
    if {[string first "INT32" $ParaType ] == -1} {
	set rc [catch { set result01 [mbDirect [format "%02X03%04X0001"  $DevAdr($ActDev,MOD) $LogAdr ] 1] }]
	# set result [format "%d" 0x[string range $result01 6 9]]
    } else {
	set rc [catch { set result01 [mbDirect [format "%02X03%04X0002"  $DevAdr($ActDev,MOD) $LogAdr ] 1] }]
	# set result [format "%d" 0x[string range $result01 6 13]]
    }

    if {($rc == 0) && ([string length $result01] == 6)} {
	set negAnswerCode [format "0x%02X" 0x[format %s [string range $result01 2 3]]]
	TlPrint "negAnswerCode: $negAnswerCode"
    } else {
	set negAnswerCode 0
    }

    if {($rc == 0) && ($negAnswerCode != 0x83)} {
	# No Abort message from device: error
	if {[string first "INT32" $ParaType ] == -1} {
	    #only 16Bit values for ATV platform
	    set result [format "%d" 0x[string range $result01 6 9]]
	    set result [UINT_TO_INT $result]
	} else {
	    #only 16Bit values for ATV platform
	    set result [format "%d" 0x[string range $result01 6 13]]
	    set result [UDINT_TO_DINT $result]
	}
	TlError "$TTId TlReadAbortMod Adr(%3s)  : no abort, but result=0x$result01" $DevAdr($ActDev,MOD)
    } elseif {($rc == 0) && ($negAnswerCode == 0x83)} {
	set negExcepCode [format "0x%02X" 0x[format %s [string range $result01 4 5]]]
	set sollErrCode [format "0x%02X" 0x$sollErrCode]
	set negExcepText [GetAltivarAbortText $negExcepCode]
	set expExcepText [GetAltivarAbortText $sollErrCode]

	if {$sollErrCode} {
	    if {$sollErrCode != $negExcepCode} {
		TlError "$TTId TlWriteAbortMod Adr(%3s) ObjAdr($objString): ExpectedExcepCode=$sollErrCode ExpectedExcepText=<%s>  ActualExcepCode=$negExcepCode ActualExcepText=<%s>" $DevAdr($ActDev,MOD) $expExcepText $negExcepText
	    } else {
		TlPrint "TlWriteAbortMod Adr(%3s) ObjAdr($objString): ActualExcepCode=ExpectedExcepCode=$negExcepCode  ActualExcepText=ExpectedExcepText=<%s>" $DevAdr($ActDev,MOD) $negExcepText
	    }
	}
    } else {
	# Abort message from device: ok
	# Extract Errorcode from errorInfo
	set dummy ""
	set errCode ""
	if {[regexp {0x(........)} $errorInfo dummy errCode]} {
	    if { ![string is xdigit -failindex ixfail $errCode] } {
		# Copy until the first Hex-Digit
		if { $ixfail > 0 } {
		    incr ixfail -1
		} else {
		    TlError "not a valid number: $errCode"
		    set errCode 0
		}
		set errCode [string range $errCode 0 $ixfail]
	    }
	    # Errorcode found in errInfo
	    set errCode "0x$errCode"
	    set result $errCode

	    TlPrint "TlReadAbortMod Adr(%3s) $objString : actErrCode=$errCode" $DevAdr($ActDev,MOD)
	    if {$sollErrCode} {
		TlPrint "expected  errormsg: %s" [GetErrorText $sollErrCode]
		if {$sollErrCode != $errCode} {
		    TlError "$TTId TlWriteAbortMod Adr(%3s) $objString  expErrCode=$sollErrCode actErrCode=$errCode" $DevAdr($ActDev,MOD)
		    TlPrint "actual errormsg: %s" [GetErrorText $errCode]
		}
	    }
	} else {
	    # Errorcode not found
	    TlPrint "TlReadAbortMod Adr(%3s) $objString : errorInfo=$errorInfo" $DevAdr($ActDev,MOD)
	    set result ""
	}
    }

    if {$theDebugFlagObj} {
	set emptyList {}
	#TlPrintIntern D "rd $objString : 0x[format "%08X" $result]" emptyList
	#TlPrintIntern D "mbReadObj $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 2"  emptyList
	TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
    }

    if {$result == ""} {
	set glb_Error 1
    }
    return $result
} ;#TlReadAbort

#----------------------------------------------------------------------------
proc TlWrite { objString value {NoErrPrint 0} {TTId ""}} {

    set result [ ModTlWrite $objString $value $NoErrPrint $TTId ]
    return $result
} ;#TlWrite

#----------------------------------------------------------------------------
proc TlWriteAbort { objString value {sollErrCode 0} {TTId ""} } {

    set result [ModTlWriteAbort $objString $value $sollErrCode $TTId]
    return $result
}  ;#TlWriteAbort

#----------------------------------------------------------------------------
# read Block of 32 bit parameter
#----------------------------------------------------------------------------
proc TlReadBlock { objString { blockLength {1}} } {

    set result [ModTlReadBlock $objString $blockLength]
    return $result
}

proc GetAltivarAbortText {AbortCode} {
    switch $AbortCode {
	"0x01" {
	    return "Illegal Function"
	}

	"0x02" {
	    return "Illegal Data Address"
	}

	"0x03" {
	    return "Illegal Data Value"
	}

	"0x04" {
	    return "Slave Device Failure"
	}

	default {
	    return "Unknown Exception code"
	}
    }
}

#DESCRIPTION
# function used to set particular bits of a word to a given value
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20220623   ASY    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description :  function used to set particular bits of a word to a given value
# Takes as input parameters the register to write to and two lists. The first one is the list of bits to write. Numbers must be included between 0 and 15 in *decimal* representation.
# The second one is the register containing the values to assign to each of the previously mentionned bits. Those values must be only 0 and 1. The length of the two lists must be identical
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021/01/07 | ASY | proc created
#
# /param[in] objString : representation of the parameter to write to
# /param[in] lBits : list of the bits to write
# /param[in] lValues : list of the values to write to each of the bits.
# /param[in] timeout : timeout in seconds to check that the value was applied
# /param[in] mdb : force the write through modbus, otherwise uses the current communication channel
# /param[in] NoErrPrint : Default value 0 deactivates error print
# /param[in] TTId : default value "" string to display in case of error
# E.g. use < TlSetBit CMD  {0 1 2 3} {1 1 1 1} > to set CMD to 0bxxxx xxxx xxxx 1111
proc TlSetBits {objString lBits lValues {timeout 1} {mdb 0} {NoErrPrint 0} {TTId ""}} {
    #Check that the lists have the same length
    if {!$NoErrPrint && [llength $lBits] != [llength $lValues]} {
	TlError "Inputs lists size are different"
	return -1
    }
    #Check that lBits list contains only numbers
    if {!$NoErrPrint && [lsearch -regexp  $lBits "\[^\[:digit:\]\]"] != -1 } {
	TlError "Bits to set list does not contain only numbers"
	return -1
    }
    #Check that lBits does not contain duplicates
    if {!$NoErrPrint && [llength [lsort -unique $lBits]] != [llength $lBits] } {
	TlError "Bits to set list contains duplicates"
	return -1
    }
    #Check that lValue contains only 0 and 1
    if {!$NoErrPrint && [lsearch -regexp  $lValues "\[^\[:digit:\]\]|\[2-9\]|.\{2,\}"] != -1 } {
	TlError "Values to write do not contain only 0 and 1"
	return -1
    }
    #calculate the mask and value to use
    set mask 0
    set value 0
    for {set i 0} {$i < [llength $lBits]} {incr i} {
	set mask [expr $mask + round(pow(2,[lindex $lBits $i]))]
	set value [expr $value + round(pow(2,[lindex $lBits $i])) * [lindex $lValues $i] ]
    }
    #get the current value of the word
    if { $mdb } {
	set currentWordValue [ModTlRead $objString]
    } else {
	set currentWordValue [TlRead $objString]
    }
	
    #calculate the new value to write
    #new value is equal to : ValueToWrite AND Mask OR CurrentValue AND NOT Mask
    #use XOR with 0xFFFF to get the NOT(MASK)
    set newWordValue [ expr $value & $mask | [expr $mask ^ 0xFFFF] & $currentWordValue]
    TlPrint "newWordValue : $newWordValue"
    TlWrite $objString $newWordValue
}