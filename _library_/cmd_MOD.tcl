#--------------------------------------------------------------------------------------------------------------
#
#      MOD-Bus Master for TCL-Testturm
#
#--------------------------------------------------------------------------------------------------------------

# Description: Modbus RTU communication function
#
# Project: ATV32,OPAL,NERA and NERA Medium Offer
#
# Filename     : cmd_MOD.tcl
#
# ----------HISTORY----------
# WANN    WER    WAS
# 180504  pfeig  Attached file
# 290705  FC90   Adapted on other Bus Interfaces
# 101005  pfeig  Made Stopbits and Parity optional
# 101106  ockeg  New functions ModTlRead ModTlWrite
# 211206  grana  Issue upgraded
# 300608  rothf  New function ModTlWriteAbort
# 151013  haimingw  Change the use of the ParameterList by new proc Param_Name, Param_Index and Param_Type
# 290114  ockeg  new ModDefaultTimeout
# 030214  serio  enhance ModTlWrite to report the kind of error code.
# 090115  serio  enhance ModTlWrite to manage errors related to Enum_Value
# 260115  serio  separate Modbus commands for Load Devices
# 240315 serio   add TTId argument to ModTlRead

#----------------------------------------------------------------------
proc ModOpen { ComportNr Baudrate {Stopbits 1} {Parity 1} } {
   global theDebugFlagObj errorInfo ErrCodeIniPath

   set rc [catch { set result [mbOpen $ComportNr $Baudrate $Stopbits $Parity] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }
      TlError "TCL-Error message: $errorInfo"
   }

   #todo: change to default if modbus request problems are solved
   #28082020 cc : Initial value 40 2000 2000
   ModSetTimeout 40 2000 2000  ;#!!!!to test!!!!!!!!!!!!!!!!!!!!!!!!!!!

   TlPrint "Set ModBus DLL Error-Code Ini Path on $ErrCodeIniPath"
   set rc [catch "mbSetErrcodesiniPath $ErrCodeIniPath" errMsg]
   if {$rc != 0} {
      TlError $errMsg
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbOpen $ComportNr $Baudrate $Stopbits $Parity"  emptyList
   }
   return $result
}

#----------------------------------------------------------------------
proc ModClose { } {
   global theDebugFlagObj errorInfo

   set rc [catch { set result [mbClose] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }
      TlError "TCL-Error message: $errorInfo"
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbClose "  emptyList
   }
   return $result
}

#----------------------------------------------------------------------
proc ModSetDebug { On } {
   global theDebugFlagObj errorInfo

   set rc [catch { set result [mbSetDebug $On] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }
      TlError "TCL-Error message: $errorInfo"
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbSetDebug $On"  emptyList
   }
   return $result
}

#----------------------------------------------------------------------
proc ModGetTimeout { } {
   global theDebugFlagObj errorInfo

   set rc [catch { set result [mbGetTimeout ] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }
      TlError "TCL-Error message: $errorInfo"
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbGetTimeout "  emptyList
   }

   return $result
}

#----------------------------------------------------------------------
proc ModSetTimeout { ReadIntervaltimeout ReadTotaltimeout WriteTotaltimeout } {
   global theDebugFlagObj errorInfo

   set rc [catch { set result [mbGetTimeout] }]
   if {$rc != 0} {
      TlError "TCL-Error message: $errorInfo"
      return 0
   }

   TlPrint "--- ModSetTimeout"
   TlPrint "originally Modbus readintervaltimeout: %d ms" [lindex $result 0]
   TlPrint "originally Modbus readtotaltimeout   : %d ms" [lindex $result 1]
   TlPrint "originally Modbus writetotaltimeout  : %d ms" [lindex $result 2]

   TlPrint "set new Modbus readintervaltimeout: %d ms" $ReadIntervaltimeout
   TlPrint "set new Modbus readtotaltimeout   : %d ms" $ReadTotaltimeout
   TlPrint "set new Modbus writetotaltimeout  : %d ms" $WriteTotaltimeout

   set rc [catch { set result [mbSetTimeout $ReadIntervaltimeout $ReadTotaltimeout $WriteTotaltimeout] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }

      TlPrint "TCL-Error message: $errorInfo"
      TlPrint "Try again in a loop, timeout 30s"

      set Timeout 30000
      set EndTime [expr [clock clicks -milliseconds] + $Timeout]
      set Counter 0

      for {set ActTime 0} {$ActTime < $EndTime} {set ActTime [clock clicks -milliseconds]} {
         set rc [catch { set result [mbSetTimeout $ReadIntervaltimeout $ReadTotaltimeout $WriteTotaltimeout] }]
         incr Counter
         if {$rc != 0} {
            set result 0
            TlPrint "rc=$rc"

            # Carry only first line
            set i [string first "\n" $errorInfo]
            if {$i != -1} {
               incr i -1
               set errorInfo [string range $errorInfo 0 $i]
            }

            doWaitMs 500

            TlPrint "TCL-Error message: $errorInfo"

            if {$Counter > 20} {
               ModTlRead ADD 1
            }

         } else {
            TlPrint "Success after $Counter tries"
            break
         }
      }

      if {$ActTime >= $EndTime} {
         TlError "mbSetTimeout failed ($Counter times)"
      }
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbSetTimeout $ReadIntervaltimeout $ReadTotaltimeout $WriteTotaltimeout"  emptyList
   }

   return $result
}

#----------------------------------------------------------------------
proc ModDefaultTimeout {  } {
   global theDebugFlagObj errorInfo

   #todo: change to default if modbus request problems are solved
   #28082020 cc : Initial value 40 2000 2000
   TlPrint "--- ModDefaultTimeout"
   TlPrint "restore Modbus readintervaltimeout: 80 ms"
   TlPrint "restore Modbus readtotaltimeout   : 2000 ms"
   TlPrint "restore Modbus writetotaltimeout  : 2000 ms"

   set rc [catch { set result [mbSetTimeout 80 2000 2000] }]
   if {$rc != 0} {
      set result 0
      TlPrint "rc=$rc"

      # Carry only first line
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }

      TlPrint "TCL-Error message: $errorInfo"
      TlPrint "Try again in a loop, timeout 30s"

      set Timeout 30000
      set EndTime [expr [clock clicks -milliseconds] + $Timeout]
      set Counter 0

      for {set ActTime 0} {$ActTime < $EndTime} {set ActTime [clock clicks -milliseconds]} {
         set rc [catch { set result [mbSetTimeout 40 2000 2000] }]
         incr Counter
         if {$rc != 0} {
            set result 0
            TlPrint "rc=$rc"

            # Carry only first line
            set i [string first "\n" $errorInfo]
            if {$i != -1} {
               incr i -1
               set errorInfo [string range $errorInfo 0 $i]
            }

            doWaitMs 500

            TlPrint "TCL-Error message: $errorInfo"

            if {$Counter > 3} {
               ModTlRead ADD 1
            }

         } else {
            TlPrint "Success after $Counter tries"
            break
         }
      }

      if {$ActTime >= $EndTime} {
         TlError "mbSetTimeout failed ($Counter times)"
      }

   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "mbSetTimeout $ReadIntervaltimeout $ReadTotaltimeout $WriteTotaltimeout"  emptyList
   }

   return $result
}

#----------------------------------------------------------------------
#nowhere used (11.10.2007 ockeg) -> use TlSend
#proc ModDirect { Sendstring CRC } {
#   global theDebugFlagObj errorInfo
#
#   # Usage: mbDirect [Sendstring] [0=ohne CRC-Berechnung,1=mit CRC-Berechnung]
#   set rc [catch { set result [mbDirect $Sendstring $CRC ] }]
#   if {$rc != 0} {
#      set result 0
#      TlPrint "rc=$rc"
#
#      # Carry only first line
#      set i [string first "\n" $errorInfo]
#      if {$i != -1} {
#          incr i -1
#          set errorInfo [string range $errorInfo 0 $i]
#      }
#      TlError "TCL-Error message: $errorInfo"
#   }
#
#   if {$theDebugFlagObj} {
#      set emptyList {}
#      TlPrintIntern D "mbDirect $Sendstring $CRC "  emptyList
#   }
#
#   return $result
#}

#----------------------------------------------------------------------------
# 10.11.2006 ockeg: new function ModTlRead:
# is the same function as TlRead.
# can also be used, when the TlRead Commands are switched to an other
# Interface (CAN, Devicenet).
# In order to read/modify serial interface parameters (CAN, Devicenet) for example.
proc ModTlRead { objString {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj errorInfo glb_Error
   global DevAdr ActDev BreakPoint

   set result 0
   set glb_Error 0
   set rc 0

   set TTId [Format_TTId $TTId]

   set DataParam [GetParaAttributes $objString $TTId]
   set LogAdr    [lindex $DataParam 0]
   set ParaType  [lindex $DataParam 3]

   # check if datatype is UINT32 or INT32
   if {[string first "INT32" $ParaType ] == -1} {
      # 16 Bit
      set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0001"  $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 9]] }]
   } else {
      # 32 Bit
      set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0002"  $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 13]] }]
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
         set errorInfo [string trim [string range $errorInfo 0 $i]]
         set errorInfo [string range $errorInfo 0 21]
      }
      if { $NoErrPrint == 0 } {
         set StartTime [clock clicks -milliseconds]
         if {[CR_Postponed "GEDEC00204834"]} {
            TlPrint "$TTId TCL-Error § (mbReadObj): $errorInfo : Object: $objString Addr: $DevAdr($ActDev,MOD)"
         } else {
            TlError "$TTId TCL-Error § (mbReadObj): $errorInfo : Object: $objString Addr: $DevAdr($ActDev,MOD)"
         }

         if {$BreakPoint} {
            if { $errorInfo == "ERRDLL:got no response"} {
               # Breakpoint for Modbus problem
               TlPrint "No answer from Modbus interface"
               puts \a\a\a\a
               if {[bp "Debugger"]} {
                  return 0
               }
            }
         } else {
            if { $errorInfo == "ERRDLL:got no response"} {
               for { set ic 2 } { $ic<4 } { incr ic } {
                  if {[CheckBreak]} {
                     return 0
                  }
                  set errorInfo ""
                  #set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                  # check if datatype is UINT32 or INT32
                  if {[string first "INT32" $ParaType ] == -1} {
                     # 16 Bit
                     set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0001"  $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 9]] }]
                  } else {
                     # 32 Bit
                     set rc [catch { set result [format "%d" 0x[string range [mbDirect [format "%02X03%04X0002"  $DevAdr($ActDev,MOD) $LogAdr ] 1] 6 13]] }]
                  }
                  set StopTime [clock clicks -milliseconds]
                  # Carry only first line
                  set i [string first "\n" $errorInfo]
                  if {$i != -1} {
                     incr i -1
                     set errorInfo [string trim [string range $errorInfo 0 $i]]
                     set errorInfo [string range $errorInfo 0 21]
                  }
                  puts \a
                  TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                  if { $errorInfo != "ERRDLL:got no response"} {
                     TlPrint "Error message No.: $ic $errorInfo"
                     TlPrint "result= $result"
                     break ;# Answer received further in text
                  } else {
                     TlError "$TTId TCL-Error (mbReadObj): $errorInfo : Object: $objString Addr: $DevAdr($ActDev,MOD) Try: ($ic)"
                  }
               }
            }
         }
      }
   }

   if {$ParaType == "INT16"} {
      set result [UINT_TO_INT $result]
   } elseif {$ParaType == "INT32"} {
      set result [UDINT_TO_DINT $result]
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
   }
   if {$result == ""} {
      set glb_Error 1
   }

   return $result
} ;# ModTlRead

#----------------------------------------------------------------------------
#
# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
#----------------------------------------------------------------------------
proc ModTlReadIntern { objString {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj errorInfo glb_Error
   global theLXMObjHashtable
   global theLXMVARHashtable
   global DevAdr ActDev BreakPoint

   set result 0
   set glb_Error 0
   set InternalVariable 0

   set TTId [Format_TTId $TTId]

   # [string match '[0-9]' [string index $idx 0]]
   if {[regexp {^0x[0-9A-Fa-f]+$} $objString] || [regexp {^[0-9]+$} $objString]} {
      # numerical operation
      set IntVarName [IntVar_Name $objString]
      set IntVarIndex $objString
      set IntVarCPU [IntVar_CPU $IntVarName]
      set IntVarLength [IntVar_Length $IntVarName]
      set IntVarType [IntVar_Type $IntVarName]
   } else {

      set IntVarName $objString
      set IntVarIndex [IntVar_Index $objString]
      set IntVarCPU [IntVar_CPU $objString]
      set IntVarLength [IntVar_Length $objString]
      set IntVarType [IntVar_Type $objString]
   }

   set rc [catch { set result [mbDirect [format "%02X47%02X%016X%02X"  $DevAdr($ActDev,MOD) $IntVarCPU $IntVarIndex $IntVarLength ] 1]}]

   #Check reception of message
   if {$rc != 0} {
      if {$result == "" } {
         if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint && ( $ActDev > 10) ) || ( $BreakPoint && ($ActDev == 1) ) } {
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
         set errorInfo [string trim [string range $errorInfo 0 $i]]
         set errorInfo [string range $errorInfo 0 21]
      }
      if { $NoErrPrint == 0 } {
         set StartTime [clock clicks -milliseconds]
         TlError "$TTId TCL-Error (mbDirect): $errorInfo : Object: $objString"
         #      doWaitMs 500
         if {$BreakPoint && ($ActDev == 1)} {
            if { $errorInfo == "ERRDLL: got no response"} {
               # Breakpoint for Modbus problem
               TlPrint "No answer from Modbus interface"
               puts \a\a\a\a
               if {[bp "Debugger"]} {
                  return 0
               }
            }
         } else {
            if { $errorInfo == "ERRDLL: got no response"} {
               for { set ic 2 } { $ic<4 } { incr ic } {
                  if {[CheckBreak]} {
                     return 0
                  }
                  set errorInfo ""
                  set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                  set StopTime [clock clicks -milliseconds]
                  # Carry only first line
                  set i [string first "\n" $errorInfo]
                  if {$i != -1} {
                     incr i -1
                     set errorInfo [string trim [string range $errorInfo 0 $i]]
                     set errorInfo [string range $errorInfo 0 21]
                  }
                  puts \a
                  TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                  if { $errorInfo != "ERRDLL: got no response"} {
                     TlPrint "Error message No.: $ic $errorInfo"
                     TlPrint "result= $result"
                     break ;# Answer received further in text
                  }
               }
            }
         }
      }
   } else {
      set AnswerCode [string range $result 2 3]
      if {$AnswerCode == "47"} {
         set result 0x[string range $result 6 end]
      } else {
         set result ""
         TlError "$TTId Modbus errorcode received: 0x[string range $result 4 5]"
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
} ;# ModTlReadIntern

#----------------------------------------------------------------------------
#
# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
#----------------------------------------------------------------------------
proc ModTlWriteIntern { objString value {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj errorInfo glb_Error
   global theLXMObjHashtable
   global theLXMVARHashtable
   global DevAdr ActDev BreakPoint

   set result 0
   set glb_Error 0
   set InternalVariable 0

   set TTId [Format_TTId $TTId]

   # [string match '[0-9]' [string index $idx 0]]
   if {[regexp {^0x[0-9A-Fa-f]+$} $objString] || [regexp {^[0-9]+$} $objString]} {
      # numerical operation
      set IntVarName [IntVar_Name $objString]
      set IntVarIndex $objString
      set IntVarCPU [IntVar_CPU $IntVarName]
      set IntVarLength [IntVar_Length $IntVarName]
      set IntVarType [IntVar_Type $IntVarName]
   } else {
      set IntVarName $objString
      set IntVarIndex [IntVar_Index $objString]
      set IntVarCPU [IntVar_CPU $objString]
      set IntVarLength [IntVar_Length $objString]
      set IntVarType [IntVar_Type $objString]
   }

   TlPrint "TlWriteIntern (MDB #%d) %s=0x%04X (%d)" $DevAdr($ActDev,MOD) $objString $value $value

   switch $IntVarLength {
      1 {set value [format "%02X" $value]}
      2 {set value [format "%04X" $value]}
      4 {set value [format "%08X" $value]}
      default {
         TlError "Invalid Length: $IntVarLength"
         return 0
      }
   }

   set rc [catch { set result [mbDirect [format "%02X48%02X%016X%02X%s"  $DevAdr($ActDev,MOD) $IntVarCPU $IntVarIndex $IntVarLength $value ] 1]}]

   #Check reception of message
   if {$rc != 0} {
      if {$result == "" } {
         if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint && ( $ActDev > 10) ) || ( $BreakPoint && ($ActDev == 1) ) } {
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
         set errorInfo [string trim [string range $errorInfo 0 $i]]
         set errorInfo [string range $errorInfo 0 21]
      }
      if { $NoErrPrint == 0 } {
         set StartTime [clock clicks -milliseconds]
         TlError "$TTId TCL-Error (mbDirect): $errorInfo : Object: $objString"
         #      doWaitMs 500
         if {$BreakPoint && ($ActDev == 1)} {
            if { $errorInfo == "ERRDLL: got no response"} {
               # Breakpoint for Modbus problem
               TlPrint "No answer from Modbus interface"
               puts \a\a\a\a
               if {[bp "Debugger"]} {
                  return 0
               }
            }
         } else {
            if { $errorInfo == "ERRDLL: got no response"} {
               for { set ic 2 } { $ic<4 } { incr ic } {
                  if {[CheckBreak]} {
                     return 0
                  }
                  set errorInfo ""
                  set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                  set StopTime [clock clicks -milliseconds]
                  # Carry only first line
                  set i [string first "\n" $errorInfo]
                  if {$i != -1} {
                     incr i -1
                     set errorInfo [string trim [string range $errorInfo 0 $i]]
                     set errorInfo [string range $errorInfo 0 21]
                  }
                  puts \a
                  TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                  if { $errorInfo != "ERRDLL: got no response"} {
                     TlPrint "Error message No.: $ic $errorInfo"
                     TlPrint "result= $result"
                     break ;# Answer received further in text
                  }
               }
            }
         }
      }
   } else {
      set AnswerCode [string range $result 2 3]
      if {$AnswerCode != "48"} {
         TlError "$TTId Modbus errorcode received: 0x[string range $result 4 5]"
         return 0
      }
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
   }
   if {$result == ""} {
      set glb_Error 1
   }

   return 1
} ;# ModTlWriteIntern

#----------------------------------------------------------------------------
# read Block of 32 bit parameter
#----------------------------------------------------------------------------
proc ModTlReadBlock { objString { blockLength {1}} {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj theLXMObjHashtable errorInfo
   global DevAdr ActDev

   set rcvframe 0

   if { ($ActDev >= 10 && $ActDev <= 20) && ( $ActDev != 15 )  } {
      set Address    [getIndex $objString]
      set idx        [lindex $Address 0]
      set six        [lindex $Address 1]
      set DataLength [lindex $Address 2]

      # Conversion in MOD-Bus-Index
      set LogAdr [expr ($idx * 256) + ($six * 2)]
      set blockLength [expr $blockLength*2]  ;# 16 bit words

      # Usage: mbReadObj [DevAdr] [LogAdr] [AnzLogAdr]
      set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr $blockLength] }]
      if {$rc != 0} {
         set result 0

         # Carry only first line
         set i [string first "\n" $errorInfo]
         if {$i != -1} {
            incr i -1
            set errorInfo [string trim [string range $errorInfo 0 $i]]
            set errorInfo [string range $errorInfo 0 21]
         }

         TlError "TCL-Error message: $errorInfo"
      }

      if {$theDebugFlagObj} {
         set emptyList {}
         TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
      }
      return $result
   } else {
      #Read a consecutive list of objects
      set WordNumber    $blockLength                                 ;#Number of objects to read
      set FirstLogAdr   [lindex [GetParaAttributes $objString] 0]    ;#Begin to read with this address
      set LogAdr        $FirstLogAdr                                 ;#index for each object address

      #Check length of 32bits parameter
      for {set i 0} {$i < $blockLength} {incr i} {
         #32bits parameter require one Wordnumber and Address index more
         if {[regexp {32$} [Param_Type [Param_Name $LogAdr 1] 1]]} {
            incr WordNumber
            incr LogAdr
         }
         incr LogAdr                                                 ;#Continue with next object
      };#endfor

      set frame [format "%02X03%04X%04X"  $DevAdr($ActDev,MOD) $FirstLogAdr $WordNumber]     ;#Sent frame

      set rc [catch { set rcvframe [mbDirect $frame 1]]}]                                    ;#Received frame

      #Check reception of message
      if {$rc != 0} {
         if {$rcvframe == "" } {
            if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint && ( $ActDev <= 10) ) || ( $BreakPoint && ($ActDev == 1) ) } {
               TlPrint "No answer from Modbus interface"
               puts \a\a\a\a
               if {[bp "Debugger"]} {
                  return 0
               }
            }
         } else {
            set rcvframe ""
         }

         # Carry only first line
         set i [string first "\n" $errorInfo]
         if {$i != -1} {
            incr i -1
            set errorInfo [string trim [string range $errorInfo 0 $i]]
            set errorInfo [string range $errorInfo 0 21]
         }
         if { $NoErrPrint == 0 } {
            set StartTime [clock clicks -milliseconds]
            TlError "$TTId TCL-Error (mbReadObj): $errorInfo : Object: $objString Addr: $DevAdr($ActDev,MOD)"
            #      doWaitMs 500
            if {$BreakPoint && ($ActDev == 1)} {
               if { $errorInfo == "ERRDLL: got no response"} {
                  # Breakpoint for Modbus problem
                  TlPrint "No answer from Modbus interface"
                  puts \a\a\a\a
                  if {[bp "Debugger"]} {
                     return 0
                  }
               }
            } else {
               if { $errorInfo == "ERRDLL: got no response"} {
                  for { set ic 2 } { $ic<4 } { incr ic } {
                     if {[CheckBreak]} {
                        return 0
                     }
                     set errorInfo ""
                     set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                     set StopTime [clock clicks -milliseconds]
                     # Carry only first line
                     set i [string first "\n" $errorInfo]
                     if {$i != -1} {
                        incr i -1
                        set errorInfo [string range $errorInfo 0 $i]
                     }
                     puts \a
                     TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                     if { $errorInfo != "ERRDLL: got no response"} {
                        TlPrint "Error message No.: $ic $errorInfo"
                        TlPrint "result= $result"
                        break ;# Answer received further in text
                     }
                  }
               }
            }
         }
      }

      if {$theDebugFlagObj} {
         set emptyList {}
         #TlPrintIntern D "rd $objString : 0x[format "%08X" $result]" emptyList
         #TlPrintIntern D "mbReadObj $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 2"  emptyList
         TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $rcvframe] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
      }

      if {$rcvframe == ""} {
         set glb_Error 1
         return ""
      } else {
         #Analyse received frame
         #For each object to be read, and according to type, take the corresponding value from string
         #If required do the conversion

         set LogAdr $FirstLogAdr
         set Index 0                                                                ;#Position in string
         set stringresult [string range $rcvframe 6 end]                            ;#Keep only values

         #Check length and report each object value in a list
         for {set i 0} {$i < $blockLength} {incr i} {
            if {![regexp {32$} [Param_Type [Param_Name $LogAdr 1] 1]]} {
               set value "0x[string range $stringresult $Index [expr $Index + 3]]"  ;#4 caracters for 8bit/16bit values
               incr Index 4                                                         ;#Next position
            } else {
               set value "0x[string range $stringresult $Index [expr $Index + 7]]"  ;#8 caracters for 32bit values
               incr Index 8                                                         ;#Next position
               incr LogAdr                                                          ;#32bit objects require 2 index addresses
            };#endif

            #Conversion
            switch -exact [Param_Type [Param_Name $LogAdr 1] 1] {
               "INT08" {
                  set value [UINT08_TO_INT08 $value]
               }
               "INT16" {
                  set value [UINT_TO_INT $value]
               }
               "INT32" {
                  set value [UDINT_TO_DINT $value]
               }
               default {}
            };#endswitch
            lappend result $value      ;#Create list
            incr LogAdr                ;#Continue with next object
         };#endfor
         return $result                ;#Final list
      };#endif
   };#endif
};#ModTlReadBlock

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Read Block of 32 bit parameter
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080615 serio proc created
#END------------------------------------------------------------------------------------------------

proc ModTlReadBlockForLoad { objString { blockLength {1}} } {

   global theDebugFlagObj theObjHashtable errorInfo
   global DevAdr ActDev

   if { $DevAdr($ActDev,Load) < 10} {

      TlError "Load Device number $DevAdr($ActDev,Load) is smaller than 10"
      return 0
   }

   set Address    [getIndex $objString]
   set idx        [lindex $Address 0]
   set six        [lindex $Address 1]
   set DataLength [lindex $Address 2]

   # Change to MOD-Bus-Index
   set LogAdr [expr ($idx * 256) + ($six * 2)]
   set blockLength [expr $blockLength*2]  ;# 16 bit words

   # Usage: mbReadObj [DevAdr] [LogAdr] [AnzLogAdr]
   set rc [catch { set result [mbReadObj $DevAdr($ActDev,Load) $LogAdr $blockLength] }]
   if {$rc != 0} {
      set result 0

      # Take only the first number
      set i [string first "\n" $errorInfo]
      if {$i != -1} {
         incr i -1
         set errorInfo [string range $errorInfo 0 $i]
      }

      TlError "TCL-Fehlermeldung: $errorInfo"
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,Load) 0x[format "%04X" $LogAdr]"  emptyList
   }

   return $result
}

#----------------------------------------------------------------------------
# 10.11.2006 ockeg: new function ModTlWrite:
# is the same function as TlWrite.
# can also be used, when the TlRead Commands are switched to an other
# Interface (CAN, Devicenet).
# In order to read/modify serial interface parameters (CAN, Devicenet) for example.
# 060524 asy  update the default case in the switch statement, to handle generic products 
proc ModTlWrite { objString value {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj errorInfo
   global theLXMObjHashtable
   global theLXMVARHashtable
   global DevAdr  ActDev  BreakPoint
   global glb_Error DevType

   set TTId [Format_TTId $TTId]

   set glb_Error 0
   set result 0
   set idx 0

   # decode enum list
   if {[string index $value 0] == "."} {
      set PrintNameValue [string range $value 1 end]
      set value [Enum_Value $objString $value $TTId]
      if [regexp {[^0-9]} $value] { return }

   } else {
      set PrintNameValue [Enum_Name $objString $value]
      if {[string is integer $PrintNameValue] } { set PrintNameValue "" }
   }

   # Conversion of Hex values into Decimal values
   if {[string range $value 0 1] == "0x"} {
      set value [expr $value]
   }

   set DataParam 		[GetParaAttributes $objString]
   set LogAdr        [lindex $DataParam 0]
   set ParaType      [lindex $DataParam 3]
   set ParaLength    [lindex $DataParam 4]
   set ParaName      [lindex $DataParam 5]

   switch -exact $DevType($ActDev,Type) {
      "Altivar" {	
      
	       # Only 16Bit values for ATV platform	
	       set value16Bit [expr $value & 0xFFFF]	
	       set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]	
      
	    }
      "Beidou" -
      "Fortis" -
      "MVK" -
      "ATS48P" -
      "OPTIM" -
      "BASIC" -
      "Nera"  -
      "Opal" {

         # check if datatype is UINT32 or INT32
         if {[string first "INT32" $ParaType ] == -1} {
            # if not -> 16 Bit
            set value16Bit [expr $value & 0xFFFF]

            #not here
            #if { $NoErrPrint == 0 } {
            #   TlPrint "TlWriteMod Adr:%3s   %-5s (0x%04X)   Decimal:%-5d Enum: %-6s" $DevAdr($ActDev,MOD) $objString $value16Bit $value $PrintNameValue
            #}

            set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
         } else {
            #else -> 32 Bit
            set value32Bit [expr $value & 0xFFFFFFFF]

            #not here
            #if { $NoErrPrint == 0 } {
            #   TlPrint "TlWriteMod Adr:%3s   %-5s (0x%08X)   Decimal:%-5d Enum: %-6s" $DevAdr($ActDev,MOD) $objString $value32Bit $value $PrintNameValue
            #}

            set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
         }

      }

      default {
         # check if datatype is UINT32 or INT32
         if {[string first "INT32" $ParaType ] == -1} {
            set value16Bit [expr $value & 0xFFFF]
            set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
         } else {
            #else -> 32 Bit
            set value32Bit [expr $value & 0xFFFFFFFF]
            set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
         }
      }
   }

   TlPrint "TlWrite (MDB #%d) %s=0x%04X (%d %s)" $DevAdr($ActDev,MOD) $objString $value $value $PrintNameValue

   set rc [catch { set result [mbDirect $sendstring 1]}]

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
         set errorInfo [string trim [string range $errorInfo 0 $i]]
         set errorInfo [string range $errorInfo 0 21]
      }
      if { $NoErrPrint == 0 } {
         set StartTime [clock clicks -milliseconds]
         TlError "$TTId TCL-Error (mbWriteObj) : $errorInfo : Object: $objString"
         if {$BreakPoint && ($ActDev == 1)} {
            if { $errorInfo == "ERRDLL:got no response"} {
               # Breakpoint for Modbus problem
               TlPrint "no answer from Mod-Bus"
               puts \a\a\a\a
               if {[bp "Debugger"]} {
                  return 0
               }
            }
         } else {
            if { $errorInfo == "ERRDLL:got no response"} {
               for { set ic 2 } { $ic<4 } { incr ic } {
                  if {[CheckBreak]} {
                     return 0
                  }
                  set errorInfo ""
                  set rc [catch { set result [mbWriteObj   $ActDev $LogAdr $value] }]
                  set StopTime [clock clicks -milliseconds]
                  # Carry only first line
                  set i [string first "\n" $errorInfo]
                  if {$i != -1} {
                     incr i -1
                     set errorInfo [string trim [string range $errorInfo 0 $i]]
                     set errorInfo [string range $errorInfo 0 21]
                  }
                  puts \a
                  TlPrint "Repeat for mbWriteObj Nr.: $ic for [expr $StopTime - $StartTime] ms"
                  if { $errorInfo != "ERRDLL:got no response"} {
                     TlPrint "Error message Nr.: $ic $errorInfo"
                     TlPrint "result= $result"
                     break ;# Answer received further in text
                  } else {
                     TlError "TCL-Error (mbWriteObj) : $errorInfo : Object: $objString Try: ($ic)"
                  }
               }
            }
         }
      } else {
         TlPrint "TCL-Error (mbWriteObj) : $errorInfo : Object: $objString"
         return 0
      }
      set CodeList [split [lindex $errorInfo 0] ":"]
      set result [lindex $CodeList 1]

   } else {

      set resultlength ok

      if {[string index $result 3] != "" } { set AnswerCodeFC16 [string range $result 2 3] } else { set resultlength nok }
      if {[string index $result 7] != "" } { set AddressFC16 "0x[string range $result 4 7]" } else { set resultlength nok }
      if {[string index $result 11] != "" } { set QuantityOfRegistersFC16 "0x[string range $result 8 11]" } else { set resultlength nok }

      if {$resultlength == "nok"} {

         if {[expr ([info exists AnswerCodeFC16]) && ($AnswerCodeFC16 == 90)] } {

            if {[string index $result 5] != "" } {

               set NegativeCodeFC16 "0x[string range $result 4 5]"

               TlError "$TTId Modbus errorcode received $NegativeCodeFC16 = [getModbusNegativeCode $NegativeCodeFC16]"

            } else {

               TlError "Modbus write result does not have length of positive answer : $result"

            }

         } else {

            TlError "Modbus write result does not have length of positive answer : $result"

         }

      } else {

         if {$AnswerCodeFC16 != "10"} {

            TlError "Modbus write result does not have correct answer code : $result"

         }

         if {$AddressFC16 != $LogAdr } {

            TlError "Modbus write result does not have correct logical address : $result"

         }

         if {$QuantityOfRegistersFC16 != [expr $ParaLength /2] } {

            TlError "Modbus write result did not write correct amount of registers : $result"

         }

      }

   }
   # $theDebugFlagObj
   if {$theDebugFlagObj} {
      set emptyList {}
      #TlPrintIntern D "wr [format "%-20s" $objString] = 0x[format "%08X" $value]  on ModAdr: $DevAdr($ActDev,MOD)" emptyList
      #TlPrintIntern D "mbWriteObj $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 0x[format "%08X" $value] ($value)"  emptyList
      TlPrintIntern D "  +++++  wr [format "%-20s" $objString] - mbWriteObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 0x[format "%08X" $value] ($value)"  emptyList
   }

   return $result
} ;# ModTlWrite

#----------------------------------------------------------------------------
proc ModTlSend { frame {crc 1} } {
   global theDebugFlagObj errorInfo
   global DevAdr ActDev

   set rc [catch { set result [mbDirect $frame $crc] }]
   if {$rc != 0} {
      set result ""
      TlError "TCL-Error message: $errorInfo"
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "send $frame : $result" emptyList
   }

   TlPrint "TlSend (MDB #%d) send:$frame received:$result" $DevAdr($ActDev,MOD)
   return $result
} ;# ModTlSend

#----------------------------------------------------------------------------
# 30.06.2008 rothf: new function ModTlWriteAbort:
# is the same function as TlWriteAbort.
# can also be used, when the TlRead Commands are switched to an other
# Interface (CAN, Devicenet).
# In order to read/modify serial interface parameters (CAN, Devicenet) for example.
# 060524 asy  update the default case in the switch statement, to handle generic products
# 18/02/25 EDM Remove condition where sollErrCode have to been set if you want function to print

proc ModTlWriteAbort { objString value {sollErrCode 0} {TTId ""} } {
   global theDebugFlagObj theLXMObjHashtable errorInfo
   global DevAdr ActDev theLXMVARHashtable theNERAParaIndexRecord DevType

   set TTId [Format_TTId $TTId]

   set result 0

   if {[string first "O_SFTY" $objString] != -1} {
      set result [ModTlWriteSafety $objString $value 3 $TTId 1]
      if {$sollErrCode != "" } {
         if {$sollErrCode != $result} {
            TlError "$TTId TlWriteAbortMod $objString = $value: exp abortcode=$sollErrCode act abortcode=$result "
         } else {
            TlPrint "TlWriteAbortMod $objString=$value: abortcode=$result"
         }
      } else {
         if {$result == 0} {
            TlError "$TTId TlWriteAbortMod $objString = $value: exp abortcode!=0 act abortcode=$result "
         } else {
            TlPrint "TlWriteAbortMod $objString=$value: abortcode=$result"
         }
      }
      return $result
   }

   # [string match '[0-9]' [string index $idx 0]]
   if [regexp {[0-9]+\.[0-9]+} $objString] {
      # numerical operation, e.g. "11.9"
      set objList [split $objString .]
      set idx [lindex $objList 0]
      set six [lindex $objList 1]
   } else {

      if { $ActDev < 10 || $ActDev > 20 } {
         set NameValue ""
         set PrintNameValue ""

         if {[string index $value 0] == "."} {
            set PrintNameValue $value
            set NameValue [string range $value 1 end]
            set value [Enum_Value $objString $NameValue]
         }

         # Conversion of Hex values into Decimal values
         if {[string range $value 0 1] == "0x"} {
            set value [expr $value]
         }

         set DataParam 		[GetParaAttributes $objString]
         set LogAdr        [lindex $DataParam 0]
         set ParaType      [lindex $DataParam 3]
         set ParaLength    [lindex $DataParam 4]
         set ParaName      [lindex $DataParam 5]

	    switch -exact $DevType($ActDev,Type) {
		"Altivar" {	
		    # Only 16Bit values for ATV platform	
		    set value16Bit [expr $value & 0xFFFF]	
		    #TlPrint TlWriteAbortMod Adr:%3s   %-5s (0x%04X)   Decimal:%-5d Enum: %-6s" $DevAdr($ActDev,MOD) $ParaName $value16Bit $value $PrintNameValue	
		    set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]	
		} 
		"Fortis" -
		"Beidou" -
		"MVK" -
		"Nera"  -
		"ATS48P"  -
		"OPTIM" -
		"BASIC" -
		"Opal" {

		    if {[info exists  theNERAParaIndexRecord($LogAdr)]} {

			# check if datatype is UINT32 or INT32
			if {[string first "INT32" $ParaType ] == -1} {
			    # if not -> 16 Bit
			    set value16Bit [expr $value & 0xFFFF]

			    set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
			} else {
			    #else -> 32 Bit
			    set value32Bit [expr $value & 0xFFFFFFFF]

			    set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
			}

		    } else {
			set value16Bit [expr $value & 0xFFFF]
			set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
		    }
		}
		default {
		    if {[info exists  theNERAParaIndexRecord($LogAdr)]} {
			# check if datatype is UINT32 or INT32
			if {[string first "INT32" $ParaType ] == -1} {
			    # if not -> 16 Bit
			    set value16Bit [expr $value & 0xFFFF]
			    set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
			} else {
			    #else -> 32 Bit
			    set value32Bit [expr $value & 0xFFFFFFFF]
			    set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
			}
		    } else {
			set value16Bit [expr $value & 0xFFFF]
			set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
		    }
		} 
	    }

      } else {

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

         set idx [lindex [split $index .] 0]
         set six [lindex [split $index .] 1]

         # Conversion of Hex values into Decimal values
         if {[string range $value 0 1] == "0x"} {
            set value [expr $value]
         }
      }
   }

   # COnversion in MOD-Bus-Index
   # Special handling of Index-Values
   if { $ActDev > 10 && $ActDev < 20   }  {
      
      if { ($idx >= 128)} {
      # use Peek and Poke parameter 22.10
      set ParaValue [expr ($six * 65536) + $idx]
      set LogAdr [expr (22 * 256) + (10 * 2)]
      set rc [catch { set result [mbWriteObj  $DevAdr($ActDev,MOD) $LogAdr $ParaValue] }]
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
   } elseif {$ActDev > 10} {
      set LogAdr [expr ($idx * 256) + ($six * 2)]
    }
   }
   # Usage: mbWriteObj [DevAdr] [LogAdr] [Par1] ...[ParX]
   if {($ActDev > 10 && $ActDev < 20) } {
      set rc [catch { set result [mbWriteObj  $DevAdr($ActDev,MOD) $LogAdr $value] }]
   } else {
      set rc [catch { set result [mbDirect $sendstring 1]}]
   }

   if {($rc == 0) && ([string length $result] == 6)} {
      set negAnswerCode [format "0x%02X" 0x[format %s [string range $result 2 3]]]
      #TlPrint "negAnswerCode: $negAnswerCode"
   } else {
      set negAnswerCode 0
   }

   if {($rc == 0) && ($negAnswerCode != 0x90)} {
      # No Abort message from device: error
      TlError "$TTId TlWriteAbortMod $objString $value: no Abort, but Result=$result"
      #set result1 [ModTlRead HMIS]
      #set result2 [ModTlRead DP0]
      #set result3 [ModTlRead LFT]
      #TlPrint "HMIS=%d DP0=%d LFT=%d" $result1 $result2 $result3
   } elseif {($rc == 0) && ($negAnswerCode == 0x90)} {
      set negExcepCode [format "0x%02X" 0x[format %s [string range $result 4 5]]]
      set sollErrCode [format "0x%02X" 0x$sollErrCode]
      set negExcepText [GetAltivarAbortText $negExcepCode]
      set expExcepText [GetAltivarAbortText $sollErrCode]


         if {($sollErrCode != $negExcepCode)  && ($sollErrCode != 0)} {
            TlError "$TTId TlWriteAbortMod Adr(%3s) ObjAdr($objString)=ObjVal($value): exp abortcode=$sollErrCode ($expExcepText)  act abortcode=$negExcepCode ($negExcepText)" $DevAdr($ActDev,MOD)
         } else {
            TlPrint "TlWriteAbortMod Adr(%3s) ObjAdr($objString)=ObjVal($value): abortcode=$negExcepCode ($negExcepText)" $DevAdr($ActDev,MOD)
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

         TlPrint "TlWriteAbort Adr(%3s) $objString=$value: ActualErrCode=$errCode" $DevAdr($ActDev,MOD)
         if {$sollErrCode} {
            TlPrint "Expected error text: %s" [GetErrorText $sollErrCode]
            if {$sollErrCode != $errCode} {
               TlError "$TTId TlWriteAbort Adr(%3s) $objString $value: DesiredErrCode=$sollErrCode ActualErrCode=$errCode" $DevAdr($ActDev,MOD)
               TlPrint "Actual error text: %s" [GetErrorText $errCode]
            }
         }
      } else {
         # Errorcode not found
         TlPrint "TlWriteAbort Adr(%3s) $objString=$value: errorInfo=$errorInfo" $DevAdr($ActDev,MOD)
         set result ""
      }
   }

   if {$theDebugFlagObj} {
      set emptyList {}
      TlPrintIntern D "wrAbort $objString = $value" emptyList
      TlPrintIntern D "mbWriteObj $DevAdr($ActDev,MOD) $LogAdr $value"  emptyList
   }
   return $result

}  ;#ModTlWriteAbort

#======================================================================
proc ModGetParameterAdress {objString} {
   global theDebugFlagObj theLXMObjHashtable errorInfo  glb_Error
   global DevAdr ActDev theLXMVARHashtable BreakPoint

   # Get index and subindex of parameter
   # [string match '[0-9]' [string index $idx 0]]
   if [regexp {[0-9]+\.[0-9]+} $objString] {
      # numerical operation, e.g. "11.9"
      set objList [split $objString .]
      set idx [lindex $objList 0]
      set six [lindex $objList 1]
   } else {
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

      set idx [lindex [split $index .] 0]
      set six [lindex [split $index .] 1]
   }

   set modbusadresse 0x[format %08X [expr $idx * 256 + $six * 2]]
   return $modbusadresse

}

#======================================================================
proc ModSetAddress { adr } {
   global DevAdr ActDev

   set DevAdr($ActDev,MOD) $adr

}

#======================================================================
proc ModGetAddress { } {
   global DevAdr ActDev

   return $DevAdr($ActDev,MOD)

}

#======================================================================
proc getModbusNegativeCode { errorNumber } {

   switch $errorNumber {

      0x01 { return "Illegal function" }
      0x02 { return "Illegal data address" }
      0x03 { return "Illegal data value" }
      0x04 { return "Server device failure" }
      0x05 { return "Acknowledge" }
      0x06 { return "Server device busy" }
      0x08 { return "Memory parity error" }
      0x0A { return "Gateway path unavailable"  }
      0x0B { return "Gateway target device failed to respond" }
      default { return "Unknown error code" }
   }

}

#======================================================================
#DOC----------------------------------------------------------------
#DESCRIPTION
#
#  write a parameter with ADL instead of ENUM value including param not in Database
#  do not check the modbus response
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 230913 cordc    proc created
#
#END----------------------------------------------------------------
proc WriteADL {LogAdr Value} {
   global DevAdr ActDev

   set MBAdr $DevAdr($ActDev,MOD)
   set TxFrame [format "%02X06%04X%04X" $MBAdr $LogAdr $Value]
   mbDirect $TxFrame 1
   TlPrint "WriteADL MDB#$MBAdr $LogAdr $Value"
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : Basic command to access to Modbus encapsulation
#              interface transport with FC43
# AUTHOR      : WeisS
# DESCRIPTION : Sends a FC43 package and receives / validates the answer
#
# ----------HISTORY----------
# WHEN      WHO   WHAT
# 040315    weiss created
#END-------------------------------------------------------------------
proc FC43SendReceive {MEItype Data} {
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
      TlError "Wrong FC received: $RxFC (expected: $FC)"
      return 0
   }

   if {$RxMEItype != $MEItype} {
      TlError "Wrong MEI type received: $RxMEItype (expected: $MEItype)"
      return 0
   }

   return $RxFrame
};#FC43SendReceive

proc FC51Read { Object } {
   global DevAdr ActDev

   set FC 0x33
   set ServiceID 0x04
   set RequesterID 0x0808
   set SessionID 0

   set TxFrame [format "%02X%02X%02X%04X%04X0004000100%04X" $DevAdr($ActDev,MOD) $FC $ServiceID $RequesterID $SessionID $Object]

   set RxFrame [TlSend $TxFrame]

   set RxFrame [string range $RxFrame 2 end]

   set RxFC 0x[string range $RxFrame 0 1]
   set RxServiceID 0x[string range $RxFrame 2 3]

   if {$RxFC != $FC} {
      TlError "Wrong FC received: $RxFC (expected: $FC)"
      return 0
   }

   if {$RxServiceID != $ServiceID} {
      TlError "Wrong ServiceID received: $RxServiceID (expected: $ServiceID)"
      return 0
   }

   set BytesTotal 0x[string range $RxFrame 12 13]
   set ObjCount 0x[string range $RxFrame 14 21]
   set BytesData  0x[string range $RxFrame 24 27]
   set Data [string range $RxFrame 28 end]

   if {$BytesTotal != [expr $BytesData + 5]} {
      TlError "Incorrect Length (BytesTotal: $BytesTotal; BytesData: $BytesData)"
      return 0
   }

   set result ""
   for {set i 0} {$i < $BytesData} {incr i} {
      lappend result [string range $Data [expr 2*$i] [expr 2*$i +1]]
   }

   TlPrint "Received %d Object(s) with %d bytes of data" $ObjCount $BytesData

   return $result

}

proc FC51Write { Object Bytelist } {
   global DevAdr ActDev

   set FC 0x33
   set Access 0x05
   # additional 6 bytes for Length, Object and 00
   set Length [expr [llength $Bytelist] + 6]

   set TxFrame [format "%02X%02X%02X0808000000%02X000100%04X%04X" $DevAdr($ActDev,MOD) $FC $Access $Length $Object [llength $Bytelist]]

   foreach Byte $Bytelist {
      set TxFrame [format "%s%02X" $TxFrame "0x$Byte"]
   }

   set RxFrame [TlSend $TxFrame]

   set RxFrame [string range $RxFrame 2 end]

   set RxFC 0x[string range $RxFrame 0 1]
   set RxAccess 0x[string range $RxFrame 2 3]

   if {$RxFC != $FC} {
      TlError "Wrong FC received: $RxFC (expected: $FC)"
      return 0
   }

   if {$RxAccess != $Access} {
      TlError "Wrong Access received: $RxAccess (expected: $Access)"
      return 0
   }

   return $RxFrame

}

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
         set rc [catch { set result [mbWriteObj  $DevAdr($ActDev,Load) $LogAdr $ParaValue] }]
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
      set rc [catch { set result [mbReadObj $DevAdr($ActDev,Load) $LogAdr 2] }]

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
                  set rc [catch { set result [mbReadObj $DevAdr($ActDev,Load) $LogAdr 2] }]
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
      set rc [catch { set result [mbWriteObj  $DevAdr($ActDev,Load) $LogAdr $ParaValue] }]
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

   set rc [catch { set result [mbWriteObj   $DevAdr($ActDev,Load) $LogAdr $value] }]

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
                  set rc [catch { set result [mbWriteObj   $ActDev $LogAdr $value] }]
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

#----------------------------------------------------------------------------
# is the same function as TlWrite.
# can also be used, when the TlRead Commands are switched to an other
# Interface (CAN, Devicenet).
# In order to read/modify serial interface parameters (CAN, Devicenet) for example.
# 060524 asy  update the default case in the switch statement, to handle generic products 
proc ModTlWriteSilent { objString value {Silent 1} {NoErrPrint 0} {TTId ""}} {
   global theDebugFlagObj errorInfo
   global theLXMObjHashtable
   global theLXMVARHashtable
   global DevAdr  ActDev  BreakPoint
   global glb_Error DevType

   set TTId [Format_TTId $TTId]

   set glb_Error 0
   set result 0
   set idx 0

   # decode enum list
   if {[string index $value 0] == "."} {
      set PrintNameValue [string range $value 1 end]
      set value [Enum_Value $objString $value $TTId]
      if [regexp {[^0-9]} $value] { return }

   } else {
      set PrintNameValue [Enum_Name $objString $value]
      if {[string is integer $PrintNameValue] } { set PrintNameValue "" }
   }

   # Conversion of Hex values into Decimal values
   if {[string range $value 0 1] == "0x"} {
      set value [expr $value]
   }

   set DataParam     [GetParaAttributes $objString]
   set LogAdr        [lindex $DataParam 0]
   set ParaType      [lindex $DataParam 3]
   set ParaLength    [lindex $DataParam 4]
   set ParaName      [lindex $DataParam 5]

   switch -exact $DevType($ActDev,Type) {
      "Altivar" {
         # Only 16Bit values for ATV platform
         set value16Bit [expr $value & 0xFFFF]
         set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]

      }
      "Beidou" -
      "Fortis" -
      "MVK" -   
      "ATS48P" -
      "OPTIM" -
      "BASIC" -
      "Nera" -
      "Opal"  {

         # check if datatype is UINT32 or INT32
         if {[string first "INT32" $ParaType ] == -1} {
            # if not -> 16 Bit
            set value16Bit [expr $value & 0xFFFF]

            #not here
            #if { $NoErrPrint == 0 } {
            #   TlPrint "TlWriteMod Adr:%3s   %-5s (0x%04X)   Decimal:%-5d Enum: %-6s" $DevAdr($ActDev,MOD) $objString $value16Bit $value $PrintNameValue
            #}

            set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
         } else {
            #else -> 32 Bit
            set value32Bit [expr $value & 0xFFFFFFFF]

            #not here
            #if { $NoErrPrint == 0 } {
            #   TlPrint "TlWriteMod Adr:%3s   %-5s (0x%08X)   Decimal:%-5d Enum: %-6s" $DevAdr($ActDev,MOD) $objString $value32Bit $value $PrintNameValue
            #}

            set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
         }

      }

      default {
	      # check if datatype is UINT32 or INT32
	      if {[string first "INT32" $ParaType ] == -1} {
		      # if not -> 16 Bit
		      set value16Bit [expr $value & 0xFFFF]
		      set sendstring [format "%02X10%04X000102%04X" $DevAdr($ActDev,MOD) $LogAdr $value16Bit]
	      } else {
		      #else -> 32 Bit
		      set value32Bit [expr $value & 0xFFFFFFFF]
		      set sendstring [format "%02X10%04X000204%08X" $DevAdr($ActDev,MOD) $LogAdr $value32Bit]
	      }


      }
   }

   if { $Silent != 1  } {
      TlPrint "TlWrite (MDB #%d) %s=0x%04X (%d %s)" $DevAdr($ActDev,MOD) $objString $value $value $PrintNameValue
   }

   set rc [catch { set result [mbDirect $sendstring 1]}]

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
                  set rc [catch { set result [mbWriteObj   $ActDev $LogAdr $value] }]
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
      } else {
         TlPrint "TCL-Error (mbWriteObj) : $errorInfo : Object: $objString"
         return 0
      }
      set CodeList [split [lindex $errorInfo 0] ":"]
      set result [lindex $CodeList 1]

   } else {

      set resultlength ok

      if {[string index $result 3] != "" } { set AnswerCodeFC16 [string range $result 2 3] } else { set resultlength nok }
      if {[string index $result 7] != "" } { set AddressFC16 "0x[string range $result 4 7]" } else { set resultlength nok }
      if {[string index $result 11] != "" } { set QuantityOfRegistersFC16 "0x[string range $result 8 11]" } else { set resultlength nok }

      if {$resultlength == "nok"} {

         if {[expr ([info exists AnswerCodeFC16]) && ($AnswerCodeFC16 == 90)] } {

            if {[string index $result 5] != "" } {

               set NegativeCodeFC16 "0x[string range $result 4 5]"

               if {$NoErrPrint} {
                  TlPrint "$TTId Modbus errorcode received $NegativeCodeFC16 = [getModbusNegativeCode $NegativeCodeFC16]"
               } else {
                  TlError "$TTId Modbus errorcode received $NegativeCodeFC16 = [getModbusNegativeCode $NegativeCodeFC16]"
               }
               set result -1

            } else {

               TlError "Modbus write result does not have length of positive answer : $result"

            }

         } else {

            TlError "Modbus write result does not have length of positive answer : $result"

         }

      } else {

         if {$AnswerCodeFC16 != "10"} {

            TlError "Modbus write result does not have correct answer code : $result"

         }

         if {$AddressFC16 != $LogAdr } {

            TlError "Modbus write result does not have correct logical address : $result"

         }

         if {$QuantityOfRegistersFC16 != [expr $ParaLength /2] } {

            TlError "Modbus write result did not write correct amount of registers : $result"

         }

      }

   }
   # $theDebugFlagObj
   if {$theDebugFlagObj} {
      set emptyList {}
      #TlPrintIntern D "wr [format "%-20s" $objString] = 0x[format "%08X" $value]  on ModAdr: $DevAdr($ActDev,MOD)" emptyList
      #TlPrintIntern D "mbWriteObj $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 0x[format "%08X" $value] ($value)"  emptyList
      TlPrintIntern D "  +++++  wr [format "%-20s" $objString] - mbWriteObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr] 0x[format "%08X" $value] ($value)"  emptyList
   }

   return $result
} ;# ModTlWrite

#----------------------------------------------------------------------------
# Read Safety Module Parameters
#
# objString: Object name or address
# SetModeTP:   Bit0: set Mode TP at beginning
#              Bit1: set Mode OK at end
#
# ----------HISTORY----------
# when   who   what
# 040216 todet proc creation
#----------------------------------------------------------------------------
proc ModTlReadSafety { objString {SetModeTP 0} {TTId ""} {NoErrPrint 0}} {

   global theSafetyErrorList
   global theDebugFlagObj errorInfo glb_Error
   global DevAdr ActDev BreakPoint   
   
   set result 0
   set glb_Error 0
   set MaxLoop 10
   set resultTMP ""

   set TTId [Format_TTId $TTId]

   set DataParam     [GetParaAttributes $objString]

   set IntVarName [lindex $DataParam 5]
   set IntVarIndex [lindex $DataParam 0]
   set IntVarCPU 3
   set IntVarLength [lindex $DataParam 4]
   set IntVarType [lindex $DataParam 3]

   for {set loop 1} {$loop <= $MaxLoop} {incr loop} {

      set rc [catch { set result [mbDirect [format "%02X47%02X%016X%02X"  $DevAdr($ActDev,MOD) $IntVarCPU $IntVarIndex $IntVarLength ] 1]}]
   
      #Check reception of message
      if {$rc != 0} {
         if {$result == "" } {
            if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint && ( $ActDev > 10) ) || ( $BreakPoint && ($ActDev == 1) ) } {
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
            set errorInfo [string trim [string range $errorInfo 0 $i]]
            set errorInfo [string range $errorInfo 0 21]
         }
         if { $NoErrPrint == 0 } {
            set StartTime [clock clicks -milliseconds]
            TlError "$TTId TCL-Error (mbDirect): $errorInfo : Object: $objString"
            #      doWaitMs 500
            if {$BreakPoint && ($ActDev == 1)} {
               if { $errorInfo == "ERRDLL: got no response"} {
                  # Breakpoint for Modbus problem
                  TlPrint "No answer from Modbus interface"
                  puts \a\a\a\a
                  if {[bp "Debugger"]} {
                     return 0
                  }
               }
            } else {
               if { $errorInfo == "ERRDLL: got no response"} {
                  for { set ic 2 } { $ic<4 } { incr ic } {
                     if {[CheckBreak]} {
                        return 0
                     }
                     set errorInfo ""
                     set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                     set StopTime [clock clicks -milliseconds]
                     # Carry only first line
                     set i [string first "\n" $errorInfo]
                     if {$i != -1} {
                        incr i -1
                        set errorInfo [string trim [string range $errorInfo 0 $i]]
                        set errorInfo [string range $errorInfo 0 21]
                     }
                     puts \a
                     TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                     if { $errorInfo != "ERRDLL: got no response"} {
                        TlPrint "Error message No.: $ic $errorInfo"
                        TlPrint "result= $result"
                        break ;# Answer received further in text
                     }
                  }
               }
            }
         }
      } else {
         set AnswerCode [string range $result 2 3]
         if {$AnswerCode == "47"} {
            set result 0x[string range $result 6 end]
         } else {
            TlPrint "$TTId Modbus errorcode received: 0x[string range $result 4 5]"
            set resultTMP $result
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
         TlPrint "ModTlReadSafety '$objString' failed, try again (loop $loop)"         
         set glb_Error 1
# only for debugging:
#         set ParamList [list CConfig_sDataExchange.u16Control CConfig_sDataExchange.u16Idx CConfig_sDataExchange.u32Data CConfig_cCfgSftyMdlMngr.u16CnfgState \
#          CConfig_cCfgSftyMdlMngr.sPswdCfg.u08State CConfig_cCfgSftyMdlMngr.sPswdCfg.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sDbg.u08NbProcFileWriteOK \
#          CConfig_cCfgSftyMdlMngr.sDbg.u08NbProcFileWriteNOK CConfig_cCfgSftyMdlMngr.sLockUnlock.u08State CConfig_cCfgSftyMdlMngr.sLockUnlock.u08ErrIndicator \
#          CConfig_cCfgSftyMdlMngr.sDownload.u08State CConfig_cCfgSftyMdlMngr.sDownload.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sConfVal.u08State \
#          CConfig_cCfgSftyMdlMngr.sConfVal.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sLocalApproval.u08State CConfig_cCfgSftyMdlMngr.sLocalApproval.u08ErrIndicator \
#          ComSfty_sDriveToSafety.sBlockCyclic.u16RequestControl ComSfty_sDriveToSafety.sBlockCyclic.u16Index ComSfty_sDriveToSafety.sBlockAcyclic.u32DataIn \
#          ComSfty_sSafetyToDrive.sBlockAcyclic.u16ResponseControl ComSfty_sSafetyToDrive.sBlockAcyclic.u16ResponseErrorCode ComSfty_sSafetyToDrive.sBlockAcyclic.u32DataOut]
#         
#         foreach IntPara $ParamList {
#            TlPrint [format "%-60s = 0x%08X" $IntPara [ModTlReadIntern $IntPara]]
#         }         
         #doWaitMsSilent 250
      } else {
         break
      }

   }
    
   if {$loop >= $MaxLoop} {
      set result -1
      TlError "$TTId Modbus errorcode received: 0x[string range $resultTMP 4 5] (complete Frame: $resultTMP)"
      doPrint_SM_ErrorState
# only for debugging:
#      set ParamList [list CConfig_sDataExchange.u16Control CConfig_sDataExchange.u16Idx CConfig_sDataExchange.u32Data CConfig_cCfgSftyMdlMngr.u16CnfgState \
#         CConfig_cCfgSftyMdlMngr.sPswdCfg.u08State CConfig_cCfgSftyMdlMngr.sPswdCfg.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sDbg.u08NbProcFileWriteOK \
#         CConfig_cCfgSftyMdlMngr.sDbg.u08NbProcFileWriteNOK CConfig_cCfgSftyMdlMngr.sLockUnlock.u08State CConfig_cCfgSftyMdlMngr.sLockUnlock.u08ErrIndicator \
#         CConfig_cCfgSftyMdlMngr.sDownload.u08State CConfig_cCfgSftyMdlMngr.sDownload.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sConfVal.u08State \
#         CConfig_cCfgSftyMdlMngr.sConfVal.u08ErrIndicator CConfig_cCfgSftyMdlMngr.sLocalApproval.u08State CConfig_cCfgSftyMdlMngr.sLocalApproval.u08ErrIndicator \
#         ComSfty_sDriveToSafety.sBlockCyclic.u16RequestControl ComSfty_sDriveToSafety.sBlockCyclic.u16Index ComSfty_sDriveToSafety.sBlockAcyclic.u32DataIn \
#         ComSfty_sSafetyToDrive.sBlockAcyclic.u16ResponseControl ComSfty_sSafetyToDrive.sBlockAcyclic.u16ResponseErrorCode ComSfty_sSafetyToDrive.sBlockAcyclic.u32DataOut]
#      
#      foreach IntPara $ParamList {
#         TlPrint [format "%-60s = 0x%08X" $IntPara [ModTlReadIntern $IntPara]]
#      }
   }
   
   return $result

} ;# ModTlReadSafety

#----------------------------------------------------------------------------
# Write Safety Module Parameters
#
# objString: Object name or address
# SetModeTP:   Bit0: set Mode TP at beginning
#              Bit1: set Mode OK at end
#
# ----------HISTORY----------
# when   who   what
# 040216 todet proc creation
#----------------------------------------------------------------------------
proc ModTlWriteSafety { objString value {SetModeTP 0} {TTId ""} {NoErrPrint 0}} {

   global theSafetyErrorList
   global theDebugFlagObj errorInfo glb_Error
   global DevAdr ActDev BreakPoint    

   set result 0
   set glb_Error 0
   set loop 1
   set MaxLoop 10

   set TTId [Format_TTId $TTId]

   if {([string first "O_SFTYA_PARAM" $objString] == -1) && ([string first "O_SFTYB_PARAM" $objString] == -1)} {
      # write CPU_A and CPU_B
      # !!! recursive call
      ModTlWriteSafety "O_SFTYA_PARAM_$objString" $value $SetModeTP $TTId
      ModTlWriteSafety "O_SFTYB_PARAM_$objString" $value $SetModeTP $TTId
      return
   }

   set DataParam     [GetParaAttributes $objString]
   
   set IntVarName [lindex $DataParam 5]
   set IntVarIndex [lindex $DataParam 0]
   set IntVarCPU 3
   set IntVarLength [lindex $DataParam 4]
   set IntVarType [lindex $DataParam 3]

   
   TlPrint "Write SM Parameter '$objString' Value: $value"   
   
   switch $IntVarLength {
      1 {set value [format "%02X" $value]}
      2 {set value [format "%04X" $value]}
      4 {set value [format "%08X" $value]}
      default {
         TlError "Invalid Length: $IntVarLength"
         return 0
      }
   }
   
   for {set loop 0} {$loop <= $MaxLoop} {incr loop} {
      
      
      set rc [catch { set result [mbDirect [format "%02X48%02X%016X%02X%s"  $DevAdr($ActDev,MOD) $IntVarCPU $IntVarIndex $IntVarLength $value ] 1]}]
      
      #Check reception of message
      if {$rc != 0} {
         if {$result == "" } {
            if { ( ( $NoErrPrint == 0 ) &&  $BreakPoint && ( $ActDev > 10) ) || ( $BreakPoint && ($ActDev == 1) ) } {
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
            set errorInfo [string trim [string range $errorInfo 0 $i]]
            set errorInfo [string range $errorInfo 0 21]
         }
         if { $NoErrPrint == 0 } {
            set StartTime [clock clicks -milliseconds]
            TlError "$TTId TCL-Error (mbDirect): $errorInfo : Object: $objString"
            #      doWaitMs 500
            if {$BreakPoint && ($ActDev == 1)} {
               if { $errorInfo == "ERRDLL: got no response"} {
                  # Breakpoint for Modbus problem
                  TlPrint "No answer from Modbus interface"
                  puts \a\a\a\a
                  if {[bp "Debugger"]} {
                     return 0
                  }
               }
            } else {
               if { $errorInfo == "ERRDLL: got no response"} {
                  for { set ic 2 } { $ic<4 } { incr ic } {
                     if {[CheckBreak]} {
                        return 0
                     }
                     set errorInfo ""
                     set rc [catch { set result [mbReadObj $DevAdr($ActDev,MOD) $LogAdr 2] }]
                     set StopTime [clock clicks -milliseconds]
                     # Carry only first line
                     set i [string first "\n" $errorInfo]
                     if {$i != -1} {
                        incr i -1
                        set errorInfo [string trim [string range $errorInfo 0 $i]]
                        set errorInfo [string range $errorInfo 0 21]
                     }
                     puts \a
                     TlPrint "Repetition for mbReadObj No.: $ic since [expr $StopTime - $StartTime] ms"
                     if { $errorInfo != "ERRDLL: got no response"} {
                        TlPrint "Error message No.: $ic $errorInfo"
                        TlPrint "result= $result"
                        break ;# Answer received further in text
                     }
                  }
               }
            }
         }
      } else {
         set AnswerCode [string range $result 2 3]
         if {$AnswerCode != "48"} {
            TlPrint "$TTId Modbus errorcode received: 0x[string range $result 4 5] Abortcode: 0x[string range $result 6 end]"
            if {$NoErrPrint} {break}
            TlPrint "ModTlWriteSafety '$objString' ($value) failed, try again (loop $loop)"            
            doWaitMsSilent 250
         } else {
            break
         }
      }
      
      if {$theDebugFlagObj} {
         set emptyList {}
         TlPrintIntern D "rd [format "%-20s" $objString] : 0x[format "%08X" $result] - mbReadObj  $DevAdr($ActDev,MOD) 0x[format "%04X" $LogAdr]"  emptyList
      }
      if {$result == ""} {
         set glb_Error 1
      }   

   }
      
   
   if {$loop >= $MaxLoop} {
      if {$NoErrPrint} {
         TlPrint "$TTId Modbus errorcode received: 0x[string range $result 4 5] (complete Frame: $result)"          
      } else {
         TlError "$TTId Modbus errorcode received: 0x[string range $result 4 5] (complete Frame: $result)"
         doPrint_SM_ErrorState            
      }      
      doPrint_SM_ErrorState      
   }     
   
   return $result

} ;# ModTlWriteSafety


proc WritableParameter { AdrParam value} {
    global DevAdr ActDev
    set MBAdr $DevAdr($ActDev,MOD)
    set frame [format "%02x06%04x%04x"  $MBAdr $AdrParam $value ]
    TlPrint "frame : $frame"
    set RxFrame [mbDirect $frame 1]
    TlPrint "RxFrame : $RxFrame"
    if { [ string rang $RxFrame 2 3 ]=="06"} {
	return 1 
    } else {

	  return 0  
	  } 

 }   
