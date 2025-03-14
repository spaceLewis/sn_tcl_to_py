# TCT Testtower environment
# Check Functions

# ----------HISTORY----------
# WANN   WER   WAS
# ?      ?     File created
# 020403 pfeig Delay in Checkpos for EC-Motor
# 030403 pfeig Actionword printed for faults in CheckSpeed
# 040403 pfeig checkPREF
# 080403 pfeig actual and expected value printed in checkSpeed
# 160603 pfeig Gobal tolerance to speed
# 180603 pfeig Showstatus
# 260603 pfeig diverse waiting time for EC-Motor
# 210703 pfeig in checkSpeed positive response for nominalValue and Toleranz enhanced
# 220703 wurtr checkPos: in case of fault additional p_ref to be printed
# 171103 pfeig checkObjektOp
# 310304 pfeig ShowStatus
# 080404 pfeig Hex for checkObjektOp, checkObjekt
# 240504 ockeg TlRead result "" abgefangen
# 240604 pfeig checkSpeed adapted
# 240604 ockeg checkPACT, checkPREF adapted
# 050704 pfeig checkNAct
# 070704 pfeig checkObjektOpAbs
# 060804 badua checkPREFUsr
# 270804 pfeig checkPREFUSR checkPACTUSR
# 210904 ockeg CheckLastErrorMem
# 051004 pfeig faults managed for compareBits
# 121004 pfeig CheckBreak
# 171104 ockeg checkNRefEA
# 260105 pfeig TTId = Testtrack Identifier, for known and not corrected bugs
# 150305 ockeg function abs cant convert the number 0x80000000 !
# 240406 pfeig sequencing in ShowStatus modified
# 081106 pfeig VarExist
# 181113 serio correct function checkValueRange arguments names
# 280414 serio update versions for devicenet option board
# 270514 serio update versions for devicenet/iostandard option board
# 170614 serio checkVersion adaptation for Beidou/PACY_COM_DEVICENET
# 240614 serio checkVersionBeidou adaptation after flash
# 040714 serio add tower5 option board to checkVersionBeidou
# 250714 ockeg checkObjectxxx with timeout, and common check for all types
# 051114 serio add of procedure CheckATVParam

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# Überpüft das Vorhandensein von Globalen Variablen
#-----------------------------------------------------------------------

proc VarExist { VarName } {
   # ----------HISTORY----------
   # WANN   WER   WAS
   # 081106 pfeig proc created
   #

   if { [catch { global  $VarName ; set x [subst $$VarName]} err] } {
      TlError "Parameter does not exist:  $err"
      return 0
   } else {
      return 1

   }

}

proc checkHMIDisplay {target {TTId ""}} {
   checkObject HMIS $target $TTId
}

proc checkDS402Vel {speedTarget tolerance {TTId ""}} {

   set speedAct [SDO402Read 0x6044.0]

   if {[expr abs($speedAct - $speedTarget)] <= $tolerance} {
      TlPrint "Object 0x6044.0 ok: exp=%d act=%d Tol=%d diff=%d" $speedTarget $speedAct $tolerance [expr $speedTarget-$speedAct]
   } else {
      if {$TTId != "" } {
         set TTId "*$TTId*"
      }
      TlError "$TTId Object 0x6044.0: exp=%d act=%d Tol=%d diff=%d" $speedTarget $speedAct $tolerance [expr $speedTarget-$speedAct]
      ShowStatus
      return 0
   }
   return 1

}

proc checkATVprofile {profile Ref1Channel {Cmd1Channel "TER"} } {

   set profile     [string toupper $profile]
   set Ref1Channel [string toupper $Ref1Channel]
   set Cmd1Channel [string toupper $Cmd1Channel]

   checkObject CHCF .$profile
   checkObject FR1  .$Ref1Channel
   checkObject CD1  .$Cmd1Channel
}

#-----------------------------------------------------------------------
# Check status of digital inputs
#-----------------------------------------------------------------------
proc CheckIO_In { Bit {bitmaske 0x00FF} {TTId ""} } {
   checkBits  IO.DINGET $Bit $bitmaske $TTId
} ;# CheckIO_In

#-----------------------------------------------------------------------
# Check status of digital inputs from IO module
#-----------------------------------------------------------------------
proc CheckIOX_In { Bit {bitmaske 0x00FF} {TTId ""} } {
   checkBits  IOM.DI1XGET $Bit $bitmaske $TTId
} ;# CheckIOX_In

#-----------------------------------------------------------------------
# Check status of digital outputs
#-----------------------------------------------------------------------
proc CheckIO_Out { Bit {bitmaske 0xFF} {TTId ""}} {
   checkBits IO.DOUTGET $Bit $bitmaske $TTId
} ;# CheckIO_Out

#-----------------------------------------------------------------------
# Check status of digital outputs
#-----------------------------------------------------------------------
proc CheckIOX_Out { Bit {bitmaske 0xFF} {TTId ""}} {
   checkBits IOM.DQ1XGET $Bit $bitmaske $TTId
} ;# CheckIO_Out

#===================================================================================
proc checkPhysicalOutputsIOM {checkValue {checkMask 0x000F}} {
   global ActDev

   set selected_bit  1                          ;#zeigt die Position des in der Folge zu überprüfenden Bits

   for {set bit 0} {$bit <= 15} {incr bit} {
      if {$selected_bit & $checkMask} {

         set phys_state [expr [wc_GetDigital 5] >> $bit & 1]
         set phys_state_soll [expr $checkValue >> $bit & 1 ]
         #--> for Debugging-purpose
         #TlPrint "phys_state_soll: $phys_state_soll"
         #TlPrint "phys_state: $phys_state"

         if {$phys_state != "NDEF"} {
            if {$phys_state != $phys_state_soll} {
               TlError "Wago input bit $bit, Exp=$phys_state_soll, Act=$phys_state"
            } elseif {$phys_state == $phys_state_soll} {
               TlPrint "Wago input bit $bit=$phys_state"
            }
         }
      }
      set selected_bit [expr $selected_bit << 1]
   }

} ;# checkPhysicalOutputsOther

#-----------------------------------------------------------------------
# Check auf Abruch
#-----------------------------------------------------------------------

proc CheckBreak { } {
   global globAbbruchFlag
   global reducedTestExecution TraceStatistics theTestSuite

   if {([TwinCheckBreak] == 1) || ($globAbbruchFlag == 1)} {
      set globAbbruchFlag 1
      #reset flags for 'skip lot' when test is interrupted
      set reducedTestExecution 0
      set TraceStatistics 0
      set theTestSuite ""
      SQL_UpdateTestRun
      return 1
   } else {
      return 0
   }

} ;# CheckBreak

#-----------------------------------------------------------------------
# Check:
# errMemEntry:  last fault entry in memory
proc CheckLastErrorMem { {errMemEntry 0} {TTId ""}} {

   if {$TTId != "" } {set TTId "*$TTId*"}

   # Pointer to first fault entry
   TlWrite ERRADM.ERRMEMRESET 0

   TlPrint "check last error memory entry"
   set Error 0
   set max [doPrintObject ERRADM.MEMNUM]
   for {set i 1} {$i <= $max} {incr i} {
      set x [doPrintObject ERRMEM.ERRNUM]
      if {$x > 0} {
         set Error $x
      } else {
         break
      }
   }

   if { $Error == $errMemEntry } {
      if { $errMemEntry == 0 } {
         TlPrint "last error memory entry = 0"
      } else {
         TlPrint "last error memory entry = 0x%04X=%s" $Error [GetErrorText $Error]
      }
      return 1
   } else {
      TlError "$TTId last error memory entry not exp=0x%X but act=0x%X" $errMemEntry $Error
      TlPrint "ERRMEM.ERRNUM = 0x%04X=%s" $Error [GetErrorText $Error]
      doDisplayErrorMemory
      return 0
   }

} ;#CheckLastErrorMem

#----------------------------------------------------------------------------------------------------
proc checkLastWarning { WarningNr } {

   set Value [doReadObject STD.LASTWARNING]
   if {$Value == $WarningNr } {
      if { $Value > 0 } {
         TlPrint "STD.LASTWARNING ok: 0x%04X=%s" $Value [GetErrorText $Value]
      } else {
         TlPrint "STD.LASTWARNING ok: 0"
      }
      return 1
   } else {
      TlError "STD.LASTWARNING exp=0x%04X, act=0x%04X" $WarningNr $Value
      doDisplayErrorMemory
      if {[format 0x%04X [expr $Value & 0xFF00]] == 0x4300 } {   ;# all warnings 0x43xx
         doPrintObject STD.TENC
         doPrintObject STD.TMOT
         doPrintObject STD.TCPU
      }
      return 0
   }

} ;# checkLastWarning

#-----------------------------------------------------------------------
# Pruefe:
# stopfault:    last interruption cause
# errMemEntry:  first fault entry
proc CheckErrorMem { {errMemEntry 0} {TTId ""}} {

   TlPrint "check last Stopfault"
   checkStopFault $errMemEntry $TTId

   if {$TTId != "" } {set TTId "*$TTId*"}

   # Pointer to first fault entry
   TlWrite ERRADM.ERRMEMRESET 0

   TlPrint "check first error memory entry"
   set Error [doPrintObject ERRMEM.ERRNUM]
   if { $Error == $errMemEntry } {
      if { $errMemEntry == 0 } {
         TlPrint "ERRMEM.ERRNUM = 0"
      } else {
         TlPrint "ERRMEM.ERRNUM = 0x%04X=%s" $Error [GetErrorText $Error]
      }
      return 1
   } else {
      TlError "$TTId ERRMEM.ERRNUM not exp=0x%04X but act=0x%04X" $errMemEntry $Error
      doDisplayErrorMemory
      return 0
   }

} ;#CheckErrorMem

#checks more than one entry in error memory
# orderly=2 check if given errors are present is the whole memory (list must not contain all errors)
# orderly=1 in the correct order given by list
# orderly=0 check only if all errors are present
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 091028 rothf    proc created
# 080615 serio    adapt to load device in Kala env
#
#
# END----------------------------------------------------------------
proc checkErrMemEntrys {errorList {orderly 1} {noErrPrint 1} {TTId ""}} {

   set lengthErrList [llength $errorList]
   set lengthErrMem [LoadRead ERRADM.MEMNUM]
   set errorActList "" ;# initialisierung für den Fall lengthErrMem == ""

   if {$TTId != "" } {set TTId "*$TTId*"}

   switch $orderly {
      0 {
         LoadWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         #read our errors
         for {set i 1} {$i <= $lengthErrMem} {incr i} {
            lappend errorActList 0x[format %04X [LoadRead ERRMEM.ERRNUM]]
         }
         #check if expected errors are available somewhere in error memory
         for {set i 1} {$i <= $lengthErrList} {incr i} {
            set expError [lindex $errorList [expr $i-1]]
            if {[lsearch -exact $errorActList $expError] < 0} {
               TlError "$TTId Expected error $i ($expError) is not available in error memory"
               TlPrint "-- available errors: $errorActList"
            } else {
               TlPrint "Expected error $i ($expError) is available in error memory"
            }
         }

         #check if no other error is present
         checkValue "Expected error $i" [LoadRead ERRMEM.ERRNUM] 0x0000 0 0 $TTId

      }
      1 {
         LoadWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         for {set i 1} {$i <= $lengthErrList} {incr i} {
            checkValue "ErrMemEntry $i" [LoadRead ERRMEM.ERRNUM] [lindex $errorList [expr $i-1]] 0 0 $TTId
         }
         #check if no other error is present
         checkValue "ErrMemEntry $i" [LoadRead ERRMEM.ERRNUM] 0x0000 0 0 $TTId
      }
      2 {
         LoadWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         #read all errors
         for {set i 1} {$i <= $lengthErrMem} {incr i} {
            lappend errorActList 0x[format %04X [LoadRead ERRMEM.ERRNUM]]
         }
         #check if expected errors are available somewhere in error memory
         for {set i 1} {$i <= $lengthErrList} {incr i} {
            set expError [lindex $errorList [expr $i-1]]
            if {[lsearch -exact $errorActList $expError] < 0} {
               if {$noErrPrint } {
                  #  TlPrint "Expected error $i ($expError) is not available in error memory"
               } else {
                  TlError "$TTId Expected error $i ($expError) is not available in error memory"
               }

               return 0
            } else {
               TlPrint "Expected error $i ($expError) is available in error memory"
               return 1
            }
         }
         TlPrint "-- available errors: $errorActList"
      }
   }

}

#checks more than one entry in error memory inclusive error qualifier
# orderly=2 check if given errors are present is the whole memory (list must not contain all errors)
# orderly=1 in the correct order given by list
# orderly=0 check only if all errors are present
#
# errorAndQualList = {ERRNUM1 ERRQUAL1 ERRNUM2 ERRQUAL2 ......}
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 150410 rothf    proc created
#
#
# END----------------------------------------------------------------
proc checkErrMemEntrysWithQual {errorAndQualList {orderly 1} {noErrPrint 1}} {

   set lengthErrList [llength $errorAndQualList]
   set lengthErrMem [doReadObject ERRADM.MEMNUM]
   set errorActList "" ;# initialisierung für den Fall lengthErrMem == ""
   set errorQualList "" ;# initialisierung für den Fall lengthErrMem == ""

   switch $orderly {
      0 {
         TlWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         #read out errors
         for {set i 1} {$i <= $lengthErrMem} {incr i} {
            lappend errorActList  0x[format %04X [doReadObject ERRMEM.ERRNUM]]
            lappend errorQualList 0x[format %04X [doReadObject ERRMEM.ERRQUAL]]
         }
         #check if expected errors are available somewhere in error memory
         for {set i 1} {$i <= $lengthErrList} {incr i 2} {
            set expError [lindex $errorAndQualList [expr $i - 1]]
            set errorPosition [lsearch -exact $errorActList $expError]
            if { $errorPosition < 0} {
               TlError "Expected error $i ($expError) is not available in error memory"
               TlPrint "-- available errors: $errorActList"
            } else {
               TlPrint "Expected error $i ($expError) is available in error memory"
               checkValue "ERRQUAL of error [lindex $errorAndQualList $errorPosition]" \
                  [lindex $errorQualList [expr $errorPosition ]] [lindex $errorAndQualList [expr (2 * $errorPosition) + 1]]
            }
         }

         #check if no other error is present
         checkValue "Expected error $i" [doReadObject ERRMEM.ERRNUM] 0x0000 0 0

      }
      1 {
         TlWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         for {set i 1} {$i <= $lengthErrList} {incr i 2} {
            checkValue "ErrMemEntry  $i" [doReadObject ERRMEM.ERRNUM] [lindex $errorQualList [expr $i-1]] 0 0
            checkValue "ErrQualEntry $i" [doReadObject ERRMEM.ERRQUAL] [lindex $errorQualList [expr $i]] 0 0
         }
         #check if no other error is present
         checkValue "ErrMemEntry $i" [doReadObject ERRMEM.ERRNUM] 0x0000 0 0
      }
      2 {
         TlWrite ERRADM.ERRMEMRESET 1        ;#set pointer to oldest entry
         #read all errors
         for {set i 1} {$i <= $lengthErrMem} {incr i} {
            lappend errorActList  0x[format %04X [doReadObject ERRMEM.ERRNUM]]
            lappend errorQualList 0x[format %04X [doReadObject ERRMEM.ERRQUAL]]
         }
         #check if expected errors are available somewhere in error memory
         for {set i 1} {$i <= $lengthErrList} {incr i 2} {
            set expError [lindex $errorAndQualList [expr $i - 1]]
            set errorPosition [lsearch -exact $errorActList $expError]
            if {$errorPosition < 0} {
               if {$noErrPrint } {
                  #  TlPrint "Expected error $i ($expError) is not available in error memory"
               } else {
                  TlError "Expected error $i ($expError) is not available in error memory"
               }

               return 0
            } else {
               TlPrint "Expected error $i ($expError) is available in error memory"
               checkValue "ERRQUAL of error [lindex $errorAndQualList $errorPosition]" \
                  [lindex $errorQualList [expr $errorPosition ]] [lindex $errorAndQualList [expr (2 * $errorPosition) + 1]]
               return 1
            }
         }
         TlPrint "-- available errors: $errorActList"
      }
   }

}

#-----------------------------------------------------------------------
# check objekt with operator "=="
#-----------------------------------------------------------------------
proc checkObject { objekt nominalValue {TTId ""} {comment ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll $ActInterface $objekt "==" $nominalValue 0 0 $TTId $ErrStat $timeout $comment]
}

#-----------------------------------------------------------------------
# check objekt with operator "=="
#-----------------------------------------------------------------------
proc checkModObject { objekt nominalValue {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll "MOD" $objekt "==" $nominalValue 0 0 $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with operators "<" "<=" "==" ">=" ">"
#-----------------------------------------------------------------------
proc checkObjectOp { objekt operator nominalValue {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll $ActInterface $objekt $operator $nominalValue 0 0 $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with operators "<" "<=" "==" ">=" ">"
#-----------------------------------------------------------------------
proc checkModObjectOp { objekt operator nominalValue {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll "MOD" $objekt $operator $nominalValue 0 0 $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with +- tolerance
#-----------------------------------------------------------------------
proc checkObjectTol { objekt nominalValue tolerance {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll $ActInterface $objekt "==" $nominalValue $tolerance 0 $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with +- tolerance
#-----------------------------------------------------------------------
proc checkModObjectTol { objekt nominalValue tolerance {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll "MOD" $objekt "==" $nominalValue $tolerance 0 $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with bitmask
#-----------------------------------------------------------------------
proc checkObjectMask { objekt nominalValue bitmask {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll $ActInterface $objekt "==" $nominalValue 0 $bitmask $TTId $ErrStat $timeout]
}

#-----------------------------------------------------------------------
# check objekt with bitmask
#-----------------------------------------------------------------------
proc checkModObjectMask { objekt nominalValue bitmask {TTId ""} {ErrStat 1} {timeout 0} } {
   global ActInterface
   return [checkObjectAll "MOD" $objekt "==" $nominalValue 0 $bitmask $TTId $ErrStat $timeout]
}

#----------------------------------------------------------------------------------------------------
# common routine for all checkObject
# one of the following parameters must be given
#  - bitmask or
#  - tolerance or
#  - operator
#
# if bitmask is given: mask out unused bits, then compare nominal and actual
# else if tolerance is given: compute allowed range for nominal and actual
# else if operator is given: [expr nominal operator actual]
#
# enum names are only shown for "operator" evaluations
# timeout in sec
#
# history:
# 250714 ockeg created
#
#----------------------------------------------------------------------------------------------------
proc checkObjectAll { bus objekt operator nominalValue tolerance bitmask {TTId ""} {ErrStat 0} {timeout 0} {comment ""} } {

   if { $TTId != ""  } { set TTId "*$TTId*" }

   if { $comment != ""  } { set comment "($comment)" }

   # get name of nominal value, if any
   if { ![string is integer $nominalValue] } {
      set nominalValue [Enum_Value $objekt $nominalValue]
   }
   set NameNominalValue [format "%s" [Enum_Name $objekt $nominalValue]]
   if { [string is integer $NameNominalValue] } {
      set NameNominalValue ""
   } else {
      set NameNominalValue "($NameNominalValue)"
   }

   set waittext  ""
   set timeout   [expr $timeout * 1000]         ;# in ms
   set starttime [clock clicks -milliseconds]
	
   while {1} {
      after 2   ;# wait 1 mS
      update idletasks

      set waittime [expr [clock clicks -milliseconds] - $starttime]
      # "waittime=" because dblog then presents only 1 entry for different waittimes
      if { $timeout > 0 } { set waittext "(waittime=$waittime\ms)" }
      if { [CheckBreak] } { return 0 }
      if {[string first "O_SFTY" $objekt] != -1} {
         # read safety module object
         set  actualValue [ModTlReadSafety $objekt ]   ;# via modbus        
      } else {
         # read object
         if { $bus == "MOD" } {
            set  actualValue [doReadModObject $objekt ""]   ;# via modbus
         } else {
            set  actualValue [doReadObject $objekt ""]      ;# via actual fieldbus
         }         
      }

      if { $actualValue == "" } {
         TlError "empty string received"
         return 0
      }

      # get name of actual value, if any
      if { $actualValue == "" } { return 0 }
      set NameActualValue [format "%s" [Enum_Name $objekt $actualValue]]
      if { [string is integer $NameActualValue] } {
         set NameActualValue ""
      } else {
         set NameActualValue "($NameActualValue)"
      }

      # what to check?
      if { ($bitmask != 0) } {
         # when a bitmask is defined, mask out unused bits
         set actualValueReal $actualValue    ;# print out all bits of actual value, not only the masked bits
         set actualValue  [expr $actualValue  & $bitmask]
         set nominalValue [expr $nominalValue & $bitmask]
         set diff         [expr $actualValue  ^ $nominalValue]
         if { $actualValue == $nominalValue } {
            TlPrint "checkObject ($bus) %-5s %s: act=exp=0x%08X, mask=0x%08X %s" \
               $objekt $comment $nominalValue $bitmask $waittext
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkObject ($bus) %-5s %s: exp=0x%08X, act=0x%08X, mask=0x%08X, diff=0x%08X %s" \
               $objekt $comment $nominalValue $actualValueReal $bitmask $diff $waittext
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } elseif { $tolerance != 0 } {
         # tolerance is defined: compute allowed range
         set tolerance [expr abs($tolerance)]
         set diff      [expr abs($nominalValue - $actualValue)]
         if { $diff <= $tolerance} {
            TlPrint "checkObjekt ($bus) %-5s %s: exp=%d act=%d tol=%d diff=%d %s" \
               $objekt $comment $nominalValue $actualValue $tolerance $diff $waittext
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkObjekt ($bus) %-5s %s: exp=%d act=%d tol=%d diff=%d %s" \
               $objekt $comment $nominalValue $actualValue $tolerance $diff $waittext
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } elseif { ($operator == ">") || ($operator == ">=") || ($operator == "==") || ($operator == "!=") || ($operator == "<=") || ($operator == "<") } {
         # if no bitmask and no tolerance is defined, there must be an operator!
         if { [expr $actualValue $operator $nominalValue] } {
            TlPrint "checkObject ($bus) %-5s %s: act=%d (0x%08X) %s, is $operator %d (0x%08X) $NameNominalValue $waittext" \
               $objekt $comment $actualValue $actualValue $NameActualValue $nominalValue $nominalValue
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkObject ($bus) %-5s %s: act=%d (0x%08X) %s, is not $operator %d (0x%08X) $NameNominalValue $waittext" \
               $objekt $comment $actualValue $actualValue $NameActualValue $nominalValue $nominalValue
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } else {
         TlError "invalid combination for checkObject: operator=$operator  bitmask=$bitmask  tolerance=$tolerance"
         return 0
      }
   } ;# end while

   return 0    ;# should never be reached

} ;# checkObjectAll

proc checkValue { valueName actualValue nominalValue  {toleranz 0} {show_status 1} {TTId ""} } {
   #-----------------------------------------------------------------------
   # Check Value mit Toleranz
   #
   # ----------HISTORY----------
   # 301206 grana  proc created
   # 160507 ockeg  ShowStatus only when show_status=1  (checkValue can be used for all possible
   #               verification and not necessarily for Drive status)
   # 140514 ockeg 7 years later: standard format 32 bit, will be extended automatically
   # 250614 serio do not truncate values while printed
   # 300323 asy   display the diff as is to avoid showing 0 in case of number > 32 bits
   #
   #END-------------------------------------------------------------------------------------------------
  
   if { $actualValue == $nominalValue } {
      TlPrint "checkValue %-5s ok: exp=act=0x%04X (%d)" $valueName [expr $actualValue] [expr $actualValue]

   } elseif {[expr abs($actualValue - $nominalValue )] <= $toleranz} {
      TlPrint "checkValue %-5s ok: exp=0x%04X (%d), act=0x%04X (%d), tol=%d, diff=%d" \
         $valueName [expr $nominalValue ] [expr $nominalValue ] [expr $actualValue] [expr $actualValue] \
         [expr $toleranz] [expr $nominalValue - $actualValue]

   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId checkValue $valueName wrong: exp=0x%04X (%d), act=0x%04X (%d), tol=%d, diff=%s" \
         [expr $nominalValue ] [expr $nominalValue ] [expr $actualValue] [expr $actualValue] \
         [expr $toleranz] [expr $nominalValue - $actualValue]
      if { $show_status } { ShowStatus }
      return 0

   }
   return 1
}

proc checkValueFloat { valueName  actualValue nominalValue  {toleranz 0} {show_status 1} {TTId ""} } {
   #-----------------------------------------------------------------------
   # Check Value mit Toleranz
   #
   # ----------HISTORY----------
   # WANN   WER    WAS
   # 301206 grana  proc created
   # 160507 ockeg  ShowStatus only when show_status=1  (checkValue can be used for all possible
   #               verification and not necessarily for Drive status)
   #
   #END-------------------------------------------------------------------------------------------------

   if {[expr abs($actualValue - $nominalValue )] <= $toleranz} {
      TlPrint "$valueName ok: exp=%f , act=%f , tol=%f, diff=%f" $nominalValue  $actualValue $toleranz [expr $nominalValue -$actualValue]
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName wrong: exp=%f , act=%f , tol=%f, diff=%f" $nominalValue  $actualValue $toleranz [expr $nominalValue -$actualValue]
      if { $show_status } { ShowStatus }
      return 0
   }
   return 1
}

proc checkValueRange { valueName  actualValue nominalValueLow nominalValueHigh {show_status 1} {TTId ""} } {
   #-----------------------------------------------------------------------
   # check if value is in range between nominalValueLow <=  actualValue <= nominalValueHigh
   #
   # ----------HISTORY----------
   # WANN   WER    WAS
   # 041010 rothf  proc created
   #
   #END-------------------------------------------------------------------------------------------------

   if {($actualValue >= $nominalValueLow) && ($actualValue <= $nominalValueHigh)} {
      TlPrint "$valueName ok: exp=%d-%d (0x%08X-0x%08X) act=%d (0x%08X) " $nominalValueLow $nominalValueHigh $nominalValueLow $nominalValueHigh $actualValue $actualValue
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName wrong: exp=%d-%d (0x%08X-0x%08X) act=%d (0x%08X)" $nominalValueLow $nominalValueHigh $nominalValueLow $nominalValueHigh $actualValue $actualValue
      if { $show_status } { ShowStatus }
      return 0
   }
   return 1
}

proc checkValueRange_noPrint { valueName  actualValue nominalValueLow nominalValueHigh {show_status 1} {TTId ""} } {
   #-----------------------------------------------------------------------
   # check if value is in range between nominalValueLow <=  actualValue <= nominalValueHigh
   # without display of positive result.
   #
   # ----------HISTORY----------
   # WHEN   WHO    WHAT
   # 090414 weiss proc created
   #
   #END-------------------------------------------------------------------------------------------------

   if {($actualValue >= $nominalValueLow) && ($actualValue <= $nominalValueHigh)} {
      #      TlPrint "$valueName ok: exp=%d-%d (0x%08X-0x%08X) act=%d (0x%08X) " $nominalValueLow
      # $nominalValueHigh $nominalValueLow $nominalValueHigh $actualValue $actualValue
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName wrong: exp=%d-%d (0x%08X-0x%08X) act=%d (0x%08X)" $nominalValueLow $nominalValueHigh $nominalValueLow $nominalValueHigh $actualValue $actualValue
      if { $show_status } { ShowStatus }
      return 0
   }
   return 1
}

proc checkValue_noPrint { valueName  actualValue nominalValue  {toleranz 0}} {
   #-----------------------------------------------------------------------
   # Check Value mit Toleranz
   #
   # ----------HISTORY----------
   # WANN   WER    WAS
   # 260508 rothf   Comparison of values and do not print in case of positive result
   #
   #
   #END-------------------------------------------------------------------------------------------------

   if {[expr abs($actualValue - $nominalValue )] <= $toleranz} {
      #TlPrint "$valueName ok: exp=%d (0x%08X) act=%d (0x%08X) Tol=%d diff=%d" $nominalValue
      # $nominalValue  $actualValue $actualValue $toleranz [expr $nominalValue -$actualValue]
   } else {
      TlError "$valueName wrong: exp=%d (0x%08X), act=%d (0x%08X), Tol=%d, diff=%d" $nominalValue  $nominalValue  $actualValue $actualValue $toleranz [expr $nominalValue -$actualValue]
      return 0
   }
   return 1
}

proc checkValueOp { valueName  actualValue operator nominalValue  {show_status 1} {TTId ""} } {
   #DOC-----------------------------------------------------------------------
   # Check values greater, lower than ...
   #
   # ----------HISTORY----------
   # WANN   WER    WAS
   # 301206 grana  proc created
   # 160507 ockeg  ShowStatus only when show_status=1  (checkValue can be used for all possible
   #               verification and not necessarily for Drive status)
   # 140108 grana  enhanced with TTId
   #
   #END-------------------------------------------------------------------------------------------------

   if {[expr $actualValue $operator $nominalValue ]} {
      TlPrint "$valueName ok: act=%d (0x%08X) $operator exp=%d (0x%08X)" $actualValue $actualValue $nominalValue  $nominalValue
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName wrong: act=%d (0x%08X) $operator exp=%8d (0x%08X)" $actualValue $actualValue $nominalValue  $nominalValue
      if { $show_status } { ShowStatus }
      return 0
   }
   return 1
}

proc checkValueOp_noPrint { valueName  actualValue operator nominalValue  {show_status 1} {TTId ""} } {
   #DOC-----------------------------------------------------------------------
   #
   # Compare values with operand without printing positive result
   #
   # ----------HISTORY----------
   # WANN   WER    WAS
   # 170211 rothf  proc created
   #
   #
   #END-------------------------------------------------------------------------------------------------

   if {[expr $actualValue $operator $nominalValue ]} {
      #TlPrint "$valueName ok: act=%d (0x%08X) $operator exp=%d (0x%08X)" $actualValue $actualValue
      # $nominalValue  $nominalValue
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName wrong: act=%d (0x%08X) $operator exp=%8d (0x%08X)" $actualValue $actualValue $nominalValue  $nominalValue
      if { $show_status } { ShowStatus }
      return 0
   }
   return 1
}

proc checkValueMask { valueName  actualValue nominalValue  bitmaske  {TTId ""} } {
   #-----------------------------------------------------------------------
   # Check Value with Mask
   #
   #END-------------------------------------------------------------------------------------------------

   if { [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] } {
      #      TlPrint "$valueName ok: 0x%08x" $actualValue
      TlPrint "$valueName ok: exp=0x%08X, act=0x%08X, mask=0x%08X" $nominalValue  $actualValue $bitmaske
      return 1
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId $valueName exp=0x%08X, act=0x%08X, mask=0x%08X" $nominalValue  $actualValue $bitmaske
      ShowStatus
      return 0
   }
}

#----------------------------------------------------------------------------------------------------
# common routine for all checkValue
#----------------------------------------------------------------------------------------------------
proc checkValueAll { actualValue operator nominalValue tolerance bitmask {TTId ""} {ErrStat 0} {timeout 0} {comment ""} } {

   if { $TTId != ""  } { set TTId "*$TTId*" }

   if { $comment != ""  } { set comment "($comment)" }

   #Determine if input is a value or a command
   if {[regexp {^[0x]*[0-9A-Fa-f]+$} $actualValue] } {
      set newvalue "expr $actualValue"
   } else {
      set newvalue "expr \[$actualValue\]"
   }

   set waittext  ""
   set timeout   [expr $timeout * 1000]         ;# in ms
   set starttime [clock clicks -milliseconds]
   while {1} {
      after 2   ;# wait 1 mS
      update idletasks

      set waittime [expr [clock clicks -milliseconds] - $starttime]
      # "waittime=" because dblog then presents only 1 entry for different waittimes
      if { $timeout > 0 } { set waittext "(waittime=$waittime\ms)" }
      if { [CheckBreak] } { return 0 }

      set mesValue [eval $newvalue]       ;#Execute value or command

      if { $actualValue == "" } {
         TlError "empty string received"
         return 0
      }

      # what to check?
      if { ($bitmask != 0) } {
         # when a bitmask is defined, mask out unused bits
         set mesValue  [expr $mesValue  & $bitmask]
         set nominalValue [expr $nominalValue & $bitmask]
         set diff         [expr $mesValue  ^ $nominalValue]
         if { $mesValue == $nominalValue } {
            TlPrint "checkValue %s: act=exp=0x%08X, mask=0x%08X %s" \
               $comment $nominalValue $bitmask $waittext
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkValue %s: exp=0x%08X, act=0x%08X, mask=0x%08X, diff=0x%08X %s" \
               $comment $nominalValue $mesValue $bitmask $diff $waittext
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } elseif { $tolerance != 0 } {
         # tolerance is defined: compute allowed range
         set tolerance [expr abs($tolerance)]
         set diff      [expr abs($nominalValue - $mesValue)]
         if { $diff <= $tolerance} {
            TlPrint "checkValue %s: exp=%d act=%d tol=%d diff=%d %s" \
               $comment $nominalValue $mesValue $tolerance $diff $waittext
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkValue %s: exp=%d act=%d tol=%d diff=%d %s" \
               $comment $nominalValue $mesValue $tolerance $diff $waittext
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } elseif { ($operator == ">") || ($operator == ">=") || ($operator == "==") || ($operator == "!=") || ($operator == "<=") || ($operator == "<") } {
         # if no bitmask and no tolerance is defined, there must be an operator!
         if { [expr $mesValue $operator $nominalValue] } {
            TlPrint "checkValue %s: act=%d (0x%08X) %s is $operator %d (0x%08X) $NameNominalValue $waittext" \
               $comment $mesValue $actualValue $NameActualValue $nominalValue $nominalValue
            return 1
         } elseif { $waittime >= $timeout } {
            TlError "$TTId checkValue %s: act=%d (0x%08X) %s is not $operator %d (0x%08X) $NameNominalValue $waittext" \
               $comment $mesValue $actualValue $NameActualValue $nominalValue $nominalValue
            if { $ErrStat } { ShowStatus }
            return 0
         }

      } else {
         TlError "invalid combination for checkValue: operator=$operator  bitmask=$bitmask  tolerance=$tolerance"
         return 0
      }
   } ;# end while
   return 0    ;# should never be reached
} ;# checkValueAll

proc checkActionword { nominalValue  {bitmaske 0xffffffff} {TTId ""} } {
   #DOC-------------------------------------------------------------------------------------------------
   # DESCRIPTION
   # Checks STD.ACTIONWORD
   #
   # ----------HISTORY----------
   # WANN   WER      WAS
   # 020704 badua    created, copy from CheckStatusword
   # 120407 ockeg    enhanced with TTId
   #
   #END-------------------------------------------------------------------------------------------------

   set  actualValue [doReadObject STD.ACTIONWORD]

   if [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] {
      TlPrint "STD.ACTIONWORD ok: 0x%08x" $actualValue
      return 1
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId STD.ACTIONWORD exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
      ShowStatus
      return 0
   }
}

#DOC-------------------------------------------------------------------------------------------------
# DESCRIPTION
# Check STD.STATUSWORD
#
# ----------HISTORY----------
# WANN   WER      WAS
# 020704 badua    created, copy from CheckStatusword
# 120407 ockeg    enhanced with TTId and Motor Encoder Warning for EC
#
#END-------------------------------------------------------------------------------------------------
proc checkStatusword { nominalValue  {bitmaske 0xffffffff} {TTId ""} } {

   set  actualValue [doReadObject STD.STATUSWORD]

   if { [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] } {
      TlPrint "STD.STATUSWORD ok: 0x%08x" $actualValue
      return 1
   } else {
      set TTId [Format_TTId $TTId]
      TlError "$TTId STD.STATUSWORD exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
      ShowStatus
      return 0
   }
}

#DOC-------------------------------------------------------------------------------------------------
# DESCRIPTION
# Check STD.STATUSWORD
#
# ----------HISTORY----------
# WANN   WER      WAS
# 020704 badua    created, copy from CheckStatusword
# 120407 ockeg    enhanced with TTId and Motor Encoder Warning for EC
#
#END-------------------------------------------------------------------------------------------------
proc checkOpModeACK { OpMode nominalValue  {bitmaske 0xffffffff} {TTId ""} } {

   switch -exact $OpMode {
      "TRQPRF" -
      "VELPRF" -
      "CYSYN" -
      "POSPRF" -
      "GEAR" -
      "GEAOFF" -
      "HOME" -
      "MANPOS" -
      "DATSET" -
      "MTUNE" {
         append object $OpMode ".ACK"
      }
      "ATUNE" {
         append object $OpMode ".AUTOSTAT"
      }
      default {
         TlError "OpMode $OpMode not defined in proc checkOpModeACK"
         return
      }
   }

   checkBits $object $nominalValue  $bitmaske $TTId

}

#-----------------------------------------------------------------------
# Check Status in STD.STATUSWORD (Bits 0..3)
#-----------------------------------------------------------------------
proc checkBLState { nominalValue  {TTId ""} } {
   set  actualValue [doReadObject STD.STATUSWORD 0]

   if {$TTId != "" } {
      set TTId "*$TTId*"
   }

   set  actualValue [expr ($actualValue & 0x0F)]
   if { $actualValue == $nominalValue  } {
      TlPrint "State in STD.STATUSWORD ok: %d" $actualValue
   } else {
      TlError "$TTId State in STD.STATUSWORD exp=%d act=%d" $nominalValue  $actualValue
      ShowStatus
      return 0
   }
   return 1
}

#-----------------------------------------------------------------------
# Check Status in DCOM.PLCOPENTX1 (Bits 0..3)
#-----------------------------------------------------------------------
#proc checkBPZustand { nominalValue  } {
#   set  actualValue [doReadObject DCOM.PLCOPENTX1]
#   if { $actualValue == "" } then {
#     TlError "invalid RxFrame received"
#     return 0
#   }
#
#   set  actualValue [expr (($actualValue >> 16) & 0x0F)]
#   if { $actualValue == $nominalValue  } {
#      TlPrint "DCOM State in DCOM.PLCOPENTX1 ok: %d" $actualValue
#   } else {
#      TlError "DCOM State in DCOM.PLCOPENTX1 exp=%d act=%d" $nominalValue  $actualValue
#      ShowStatus
#      return 0
#   }
#   return 1
#}

#-----------------------------------------------------------------------
# Check last error entry
#
# ----------HISTORY----------
# WANN   WER    WAS
# 290208 grana  TTId = Testtrack Identifier, for known and not corrected bugs
# 121009 pfeig  5500
#-----------------------------------------------------------------------
proc checkStopFault { nominal {TTId ""} } {
   global ActDev

   set actual [doReadObject STD.STOPFAULT]
   if { $actual == $nominal } {
      if { $actual > 0 } {
         TlPrint "STD.STOPFAULT ok: 0x%04X=%s" $actual [GetErrorText $actual]
      } else {
         TlPrint "STD.STOPFAULT ok: 0"
      }
      return 1
   } else {
      if {$TTId != "" } {
         set TTId "*$TTId*"
      }
      TlError "$TTId STD.STOPFAULT exp=0x%04X act=0x%04X" $nominal $actual
      ShowStatus
      return 0
   }
}

# ----------HISTORY----------
# WHEN   WHO      WHAT
# 091028 rothf    proc created
#
#
# END----------------------------------------------------------------
proc checkStopFault_FromList {stopFaultList} {

   set stopFault 0x[format %04X [doReadObject STD.STOPFAULT]]
   if {[lsearch -exact $stopFaultList $stopFault] < 0} {
      TlError "StopFault ($stopFault) does not match one of the list entrys"
      TlPrint "-- expected stopFaults: $stopFaultList"
   } else {
      TlPrint "Expected StopFault is ok ($stopFault)"
   }

}

#-----------------------------------------------------------------------
# check error Code and Class in Error Memory
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 300909 pfeig created
proc checkErrCodeClass { errMemCode errMemClass { pos 1} } {

   # Set error memory read pointer to oldest error entry.
   TlWrite ERRADM.ERRMEMRESET 0
   doWaitMs 100

   if { $pos > 1 } {
      for {set i 1} {$i <= [expr $pos - 1]} {incr i} {
         doReadModObject ERRMEM.ERRNUM 0 1
      }
   }

   set errCode [doReadModObject ERRMEM.ERRNUM]
   if {$errCode == $errMemCode} {
      TlPrint "error memory entry on Pos $pos: Code  0x%04X: ok" $errCode
   } else {
      if { $errCode == "" } {
         TlError "error memory entry on Pos $pos: Code wrong: act=$errCode nominal=$errMemCode"
      } else {
         TlError "error memory entry on Pos $pos: Code wrong: act=0x%04X nominal=0x%04X" $errCode $errMemCode
      }
      # Result from fault entries
   }
   set errClass [doReadModObject ERRMEM.ERRCLASS]
   if {$errClass == $errMemClass} {
      TlPrint "error memory entry on Pos $pos: Class 0x%04X: ok" $errClass
   } else {
      if { $errCode == "" } {
         TlError "error memory entry on Pos $pos: Class wrong: act=$errClass nominal=$errMemClass"
      } else {
         TlError "error memory entry on Pos $pos: Class wrong: act=0x%04X nominal=0x%04X" $errClass $errMemClass
      }
   }
} ;#checkErrCodeClass

#-----------------------------------------------------------------------
# Check Axismode Bits 0...4
#-----------------------------------------------------------------------
proc checkAxismode { nominalValue  } {
   set  actualValue [doReadObject STD.AXISMODE]
   set  actualValue [expr $actualValue & 0x001F]  ;# nur Bits 0..4 vergleichen
   if { $actualValue == $nominalValue  } {
      TlPrint "Axismode ok: 0x%04x" $actualValue
      return 1
   } else {
      TlError "Axismode exp=0x%04x act=0x%04x" $nominalValue  $actualValue
      ShowStatus
      return 0
   }
}

#-----------------------------------------------------------------------
# Check Bits
#-----------------------------------------------------------------------
proc checkBits { objekt nominalValue  {bitmaske 0xffffffff} {TTId ""} } {
   set  actualValue [doReadObject $objekt]

   if {$bitmaske == 0xffffffff  } {
      set mask ""
   } else {
      set mask "mask=[format 0x%08x $bitmaske]"
   }
   if [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] {
      TlPrint "checkBits $objekt ok: 0x%08x $mask " $actualValue
      return 1 ;#  actualValue = nominalValue  ==> True
   } else {
      set TTId [Format_TTId $TTId]
      if { $actualValue == "" } {
         TlError "$TTId checkBits $objekt exp=0x%08x act=*  mask=0x%08x" $nominalValue  $bitmaske
      } else {
         TlError "$TTId checkBits $objekt exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
      }
      ShowStatus
      return 0 ;# Error = False
   }
}

#-----------------------------------------------------------------------
# Check Bits via modbus if
#-----------------------------------------------------------------------
proc checkModBits { objekt nominalValue  {bitmaske 0xffffffff} {TTId ""} {Show ""}} {
   set  actualValue [doReadModObject $objekt]

   if [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] {
      TlPrint "checkBits $objekt ok: 0x%08x" $actualValue
      return 1 ;#  actualValue = nominalValue  ==> True
   } else {
      set TTId [Format_TTId $TTId]
      if { $actualValue == "" } {
         TlError "$TTId checkModBits $objekt exp=0x%08x act=  mask=0x%08x" $nominalValue  $bitmaske
      } else {
         TlError "$TTId checkModBits $objekt exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
      }
      if {$Show == "NoStatus" } {
         # do nothing
      } else {
         ShowStatus
      }
      return 0 ;# Error = False
   }
}

#-----------------------------------------------------------------------
# Check Compare Bits
#-----------------------------------------------------------------------
proc compareBits { name  actualValue nominalValue  {bitmaske 0xffffffff} {show_status 1} {TTId ""} } {
   if { ($name != "") && ($actualValue != "") && ($nominalValue  != "") } {
      if [expr ($actualValue & $bitmaske) == ($nominalValue  & $bitmaske)] {
         TlPrint "$name ok: 0x%08x" $actualValue
      } else {
         set TTId [Format_TTId $TTId]
         TlError "$TTId $name exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
         if { $show_status } { ShowStatus }
         return 0
      }
   } else {
      TlError "Wert fehlerhaft fuer Proc: compareBits $name exp=0x%08x act=0x%08x mask=0x%08x" $nominalValue  $actualValue $bitmaske
      return 0
   }
   return 1
}


#-----------------------------------------------------------------------
# Check Speed Profilgenerator   in Usr/min
#-----------------------------------------------------------------------
proc checkVRef { sollSpeed {toleranz 0} } {
   global Toleranz_Nref  Toleranz_Nref_Null

   set istSpeed [doReadObject MONC.VREF]

   if { $sollSpeed == 0 } {
      set toleranz [expr $toleranz + $Toleranz_Nref_Null]
   } else {
      set toleranz [expr $toleranz + round (abs ($sollSpeed * $Toleranz_Nref ) + 1)]
   }

   if [expr abs($sollSpeed - $istSpeed) <= $toleranz] {
      TlPrint "MONC.VREF: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr $istSpeed-$sollSpeed]
      return 1
   } else {
      TlError "MONC.VREF: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr $istSpeed-$sollSpeed]
      doReadObject MONC.PACT 0 1
      doReadObject MONC.PREF 0 1
      # ShowStatus
      return 0
   }
}

#-----------------------------------------------------------------------
# Check rotation speed from nominalValue of P_Ref   in U/min
# toleranz = additional Toleranz in U/min, that any test can modify
#-----------------------------------------------------------------------
proc checkNPRef { sollSpeed {toleranz 0} {CQID ""}} {
   global Toleranz_NPref    Toleranz_NPref_Null

   if {$CQID != "" } { set CQID "*$CQID*" }

   set istSpeed [doReadObject MONT.SPEEDPREF]

   if { $sollSpeed == 0 } {
      set toleranz [expr $toleranz + $Toleranz_NPref_Null]
   } else {
      set toleranz [expr $toleranz + round (abs ($sollSpeed * $Toleranz_NPref) + 1)]
   }

   if [expr abs($sollSpeed - $istSpeed) <= $toleranz] {
      TlPrint "MONT.SPEEDPREF: exp=%d act=%d diff=%d tol=%d" $sollSpeed $istSpeed [expr $sollSpeed-$istSpeed] $toleranz
      return 1
   } else {
      TlError "$CQID MONT.SPEEDPREF: exp=%d act=%d diff=%d tol=%d" $sollSpeed $istSpeed [expr $sollSpeed-$istSpeed] $toleranz
      doReadObject MONC.PACT 0 1
      doReadObject MONC.PREF 0 1
      ShowStatus
      return 0
   }
}

#-----------------------------------------------------------------------
# Check actual velocity    in Usr_v
#-----------------------------------------------------------------------
proc checkVAct { sollSpeed {toleranz 0} } {
   global Toleranz_Nact  Toleranz_Nact_Null

   set istSpeed [doReadObject MONC.VACT]

   if { $sollSpeed == 0 } {
      set toleranz [expr $toleranz + $Toleranz_Nact_Null]
   } else {
      set toleranz [expr $toleranz + round (abs ($sollSpeed * $Toleranz_Nact ) + 1)]
   }

   if [expr abs($sollSpeed - $istSpeed) <= $toleranz] {
      TlPrint "MONC.VACT: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr $istSpeed-$sollSpeed]
      return 1
   } else {
      TlError "MONC.VACT: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr $istSpeed-$sollSpeed]
      doReadObject MONC.VREF 0 1
      doReadObject MONC.NACT 0 1
      doReadObject MONC.NREF 0 1
      # ShowStatus
      return 0
   }
}

#-----------------------------------------------------------------------
# Check if the speed is within the tolerance
# global tolerances will be used for NACT
# additionally can any test define a tolerance, that
# will be added to the global tolerance here
# sollSpeed, istSpeed and toleranz in U/min
# return: 1=ok   0=out of tolerance
#-----------------------------------------------------------------------
proc checkNActToleranz { sollSpeed istSpeed {toleranz 0} {TTId ""} {ErrorPrint 1} } {
   global Toleranz_Nact Toleranz_Nact_Null MinNact

   set InnerhalbToleranz 0
   set differenz [expr abs($sollSpeed - $istSpeed)]

   if { abs($sollSpeed) < 10 } {
      # 1. Check : was motor not supposed to be moving ?
      incr toleranz $Toleranz_Nact_Null
      set InnerhalbToleranz [expr $differenz <= $toleranz ]
   } elseif { abs($sollSpeed) <= $MinNact } {
      # 2. Check:
      # For the range, for which the speed can not be significantly be checked
      # should at least the motor direction be checked
      TlPrint "check only direction of movement"
      set InnerhalbToleranz [expr ($sollSpeed * $istSpeed) >= 0 ]
   } elseif { abs($sollSpeed) > $MinNact } {
      # 3. Check: by actual movement
      # toleranz will be limited to Toleranz_Nact_Null
      if {[doReadObject MOCED.LINES] <= 16} {
         #use factor 2 for speed tolerance if encoder resolution is below 16 lines
         incr toleranz [expr round( abs($sollSpeed) * $Toleranz_Nact * 2)]
      } else {
         incr toleranz [expr round( abs($sollSpeed) * $Toleranz_Nact )]
      }
      if { $toleranz < $Toleranz_Nact_Null } { set toleranz $Toleranz_Nact_Null }
      set InnerhalbToleranz [expr $differenz <= $toleranz ]
   }

   if { $InnerhalbToleranz } {
      TlPrint "NACT: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz $differenz
      return 1
   } else {
      set TTId [Format_TTId $TTId]
      if { $ErrorPrint } {
         TlError "$TTId NACT: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz $differenz
         # ShowStatus
      } else {
         TlPrint       "NACT: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz $differenz
      }
      return 0
   }

} ;# checkNActToleranz

#-----------------------------------------------------------------------
# Check NACT über Modbus (MONC.NACT)
# sollSpeed in U/min
# toleranz = additional tolerance in U/min, that any test can define,
# and that will be added to the global tolerance for NACT
# return: 1=ok   0=out of tolerance
#
# Wann   Wer   Was
# 290307 ockeg in case of fault : read 3 times with 500 ms waiting time in between because of
# oscillations
#
#-----------------------------------------------------------------------
proc checkNAct { sollSpeed {toleranz 0} {TTId ""} } {

   set TTId [Format_TTId $TTId]

   if { $sollSpeed == 0 } {
      doWaitForObject STD.ACTIONWORD 0x0840 10 0x0840  ;# Motor and Profilgenerator do not move
   }

   # 1. Check
   set istSpeed [ModTlRead MONC.NACT]
   set result [checkNActToleranz $sollSpeed $istSpeed $toleranz $TTId 1]
   if { $result } {
      return $result
   }

   # 2. Check
   # when the first time was not ok, then read a second time with a waiting time in between
   # because of oscillations

   doWaitMs 200
   set istSpeed [ModTlRead MONC.NACT]
   set result [checkNActToleranz $sollSpeed $istSpeed $toleranz $TTId 0]
   if { $result } {
      return $result
   }

   # 3. Check
   # it should now be stable
   doWaitMs 200
   set istSpeed [ModTlRead MONC.NACT]
   set result [checkNActToleranz $sollSpeed $istSpeed $toleranz $TTId 0]
   if { $result == 0 } {
      ShowStatus
   }
   return $result

}

#-----------------------------------------------------------------------
# Check Actual Speed with external Encoder
#-----------------------------------------------------------------------
proc checkNActEncoder { sollSpeed {toleranz 0} } {

   set istSpeed [wc_GetSpeed_Encoder]

   if { [expr abs($sollSpeed - $istSpeed)] <= [expr abs($toleranz)] } {
      TlPrint "NACT of ext encoder: exp=%d act=%d tol=%.2f diff=%d" $sollSpeed $istSpeed [expr abs($toleranz)] [expr abs($sollSpeed-$istSpeed)]
      return 1
   } else {
      TlError "NACT of ext encoder: exp=%d act=%d tol=%.2f diff=%d" $sollSpeed $istSpeed [expr abs($toleranz)] [expr abs($sollSpeed-$istSpeed)]
      return 0
   }

}

#-----------------------------------------------------------------------
# Check Speed Profilgenerator
#-----------------------------------------------------------------------
#proc checkSpeed { sollSpeed {toleranz 1} } {
#    global Toleranz_rel_Geschwindigkeit
#
#    set istSpeed [doReadObject MONC.NREF]
#    set AktSpeed [doReadObject MONC.NACT]
#    if { ($istSpeed == "") || ($AktSpeed == "")  } then {
#      TlError "invalid RxFrame received"
#      return 0
#    }
#
#    if [expr abs($sollSpeed - $istSpeed) <= $toleranz] {
#        TlPrint "ExpectedSpeed NREF exp=%d act=%d tolerance=%.2f U/min" $sollSpeed $istSpeed
# $toleranz
#        doWaitMs 150
#        if {$sollSpeed == 0 } {
#            doWaitMs 60
#        }
#
#        set Toleranz_Speed [expr ($Toleranz_rel_Geschwindigkeit ) * $sollSpeed]; # zulaessige
# Toleranz berechnen
#        set Toleranz_Speed [expr abs($Toleranz_Speed) + $toleranz]
#        #for small speeds will the difference for NACT be really high
#        if { $sollSpeed < 500 } {
#            set Toleranz_Speed [expr $Toleranz_Speed + 50]
#            set Toleranz_Speed [expr $Toleranz_Speed + 10]
#
#        }
#
#        ;# check if rotation speed is within the tolerance
#
#        set Differenz [expr {abs($sollSpeed - $AktSpeed)} ];
#        if { $Differenz > $Toleranz_Speed} {
#            # The measured speed is much different than the expected speed
#            TlError "ActualSpeed NACT exp=%d act=%d tolerance=%.2f U/min" $sollSpeed $AktSpeed
# $Toleranz_Speed
#        }  else  {
#            TlPrint "ActualSpeed NACT ok: exp=%d act=%d tolerance=%.2f U/min" $sollSpeed $AktSpeed
# $Toleranz_Speed
#        }
#
#
#    } else {
#        TlError "ActualSpeed (NREF) exp=%d act=%d toleranz=%d U/min" $sollSpeed $istSpeed $toleranz
#
#        set ActWord [doReadObject STD.ACTIONWORD]
#        if { $ActWord == ""  } then {
#          TlError "invalid RxFrame received"
#          return 0
#        }
#        TlPrint "STD.ACTIONWORD: 0x%08x"  $ActWord
#
#        set istPos [doReadObject MONC.PACT]
#        if { $istPos == ""  } then {
#          TlError "invalid RxFrame received"
#          return 0
#        }
#        TlPrint "MONC.PACT     : %d" $istPos
#
#        set SollPos [doReadObject MONC.PREF]
#        if { $SollPos == ""  } then {
#          TlError "invalid RxFrame received"
#          return 0
#        }
#        TlPrint "MONC.PREF    : %d" $SollPos
#    }
#}

#-----------------------------------------------------------------------
# Check actual Position
#-----------------------------------------------------------------------
# R.Wurth 22.7.03: in case of fault print p_ref additionaly
#
proc checkPACT { sollPos {toleranz 0} } {
   global TOL_POSITION
   global WAIT_IN_CHECKPACTxx

   incr toleranz $TOL_POSITION

   doWaitMsSilent  $WAIT_IN_CHECKPACTxx  ;# ev the motor is sitll oscillating

   set istPos [doReadObject MONC.PACT]

   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   # that s why will the difference here first made then abs will be called

   set Diff [expr abs($sollPos - $istPos)]

   if { $Diff <= $toleranz } {
      TlPrint "MONC.PACT exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      return 1
   } else {
      TlError "MONC.PACT exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      TlPrint "MONC.PREF= [doReadObject MONC.PREF]"

      doWaitMs 100
      set istPos [doReadObject MONC.PACT]
      TlError "MONC.PACT exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos - $istPos)]
      TlPrint "MONC.PREF= [doReadObject MONC.PREF]"

      doWaitMs 500
      set istPos [doReadObject MONC.PACT]
      TlError "MONC.PACT exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos - $istPos)]
      TlPrint "MONC.PREF= [doReadObject MONC.PREF]"
      ShowStatus

      return 0
   }
} ;# checkPACT

#-----------------------------------------------------------------------
proc checkPACTEncoder { sollPos {toleranz 0} } {

   set istPos [wc_GetPos_Encoder]

   set Diff [expr abs($sollPos - $istPos)]
   if { $Diff <= $toleranz } {
      TlPrint "Position of ext. encoder: exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      return 1
   } else {
      TlError "Position of ext. encoder: exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      return 0
   }
} ;# checkPACTEncoder

#-----------------------------------------------------------------------
# Check Position Profilgenerator
#-----------------------------------------------------------------------
proc checkPREF { sollPos {toleranz 0} {TTId ""} } {

   set TTId [Format_TTId $TTId]

   set istPos [doReadObject MONC.PREF]
   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   # that s why will the difference here first made then abs will be called
   set Diff [expr abs($sollPos - $istPos)]
   if { $Diff <= $toleranz } {
      TlPrint "MONC.PREF exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      return 1
   } else {
      TlError "$TTId MONC.PREF exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($Diff)]
      TlPrint "MONC.PACT= [doReadObject MONC.PACT]"

      doWaitMs 100
      set istPos [doReadObject MONC.PREF]
      TlError "$TTId MONC.PREF exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos - $istPos)]
      TlPrint "MONC.PACT= [doReadObject MONC.PACT]"

      doWaitMs 500
      set istPos [doReadObject MONC.PREF]
      TlError "$TTId MONC.PREF exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos - $istPos)]
      TlPrint "MONC.PACT= [doReadObject MONC.PACT]"

      ShowStatus
      return 0
   }
} ;# checkPREF

#-----------------------------------------------------------------------
# Check actual Position
#-----------------------------------------------------------------------
# in case of fault print p_ref additionaly
#
proc checkPACTUSR { sollPos {toleranz 0} {CQId ""}} {
   global Toleranz_Lage
   global WAIT_IN_CHECKPACTxx

   if {$CQId != "" } { set CQId "*$CQId*" }

   incr toleranz $Toleranz_Lage

   doWaitMsSilent  $WAIT_IN_CHECKPACTxx  ;# ev the Motor is still oscillating

   set istPos [doReadObject MONC.PACTUSR]
   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   # that s why will the difference here first made then abs will be called
   #
   # WARNING : this difference calculation won t prevent
   # the overflow for example from 268435455 to -268435456 with
   # a normalisation of 1/16384.
   # When the postions are around the limit, should the function
   # checkPACTUSR_OFL be used.

   set Diff [expr abs($sollPos - $istPos)]
   if { $Diff <= $toleranz } {
      TlPrint "MONC.PACTUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      return 1
   } else {
      TlError "$CQId MONC.PACTUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"

      doWaitMs 100
      set istPos [doReadObject MONC.PACTUSR]
      TlError "$CQId MONC.PACTUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"

      doWaitMs 500
      set istPos [doReadObject MONC.PACTUSR]
      TlError "$CQId MONC.PACTUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"
      ShowStatus
      return 0
   }
} ;# checkPACTUSR

#-----------------------------------------------------------------------
# Check PositionUsr Profilgenerator
#-----------------------------------------------------------------------
proc checkPREFUSR { sollPos {toleranz 0} } {

   set istPos [doReadObject MONC.PREFUSR]
   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   # that s why will the difference here first made then abs will be called
   #
   # WARNING : this difference calculation won t prevent
   # the overflow for example from 268435455 to -268435456 with
   # a normalisation of 1/16384.
   # When the postions are around the limit, should the function
   # checkPREFUSR_OFL be used
   set Diff [expr abs($sollPos - $istPos)]
   if { $Diff <= $toleranz } {
      TlPrint "MONC.PREFUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      return 1
   } else {
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"

      doWaitMs 100
      set istPos [doReadObject MONC.PREFUSR]
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"

      doWaitMs 500
      set istPos [doReadObject MONC.PREFUSR]
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"
      ShowStatus
      return 0
   }
} ;# checkPREFUSR

#-----------------------------------------------------------------------
# Check actual Position in User around position limit
#-----------------------------------------------------------------------
# in case of fault print p_ref additionaly
#
proc checkPACTUSR_OFL { sollPos {toleranz 0} } {
   global Toleranz_Lage
   global WAIT_IN_CHECKPACTxx

   incr toleranz $Toleranz_Lage

   doWaitMsSilent  $WAIT_IN_CHECKPACTxx  ;# ev the Motor is still oscillating

   set istPos [doReadObject MONC.PACTUSR]
   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   if { ($sollPos == -2147483648) || ($istPos == -2147483648) } {
      set Diff [expr abs($sollPos - $istPos)]
   } else {
      set Diff [expr abs(abs($sollPos) - abs($istPos))]
   }
   if { $Diff <= $toleranz } {
      TlPrint "MONC.PACTUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      return 1
   } else {
      TlError "MONC.PACTUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"

      doWaitMs 100
      set istPos [doReadObject MONC.PACTUSR]
      TlError "MONC.PACTUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"

      doWaitMs 500
      set istPos [doReadObject MONC.PACTUSR]
      TlError "MONC.PACTUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PREFUSR= [doReadObject MONC.PREFUSR]"

      return 0
   }
} ;# checkPACTUSR_OFL

#-----------------------------------------------------------------------
# Check Profilgenerator Position in User around position limit
#-----------------------------------------------------------------------
proc checkPREFUSR_OFL { sollPos {toleranz 0} } {

   set istPos [doReadObject MONC.PREFUSR]
   # WARNING : istpos can exceed the range of 32 Bit
   # as well -2147483648 (0x80000000)
   # abs can not manage this number
   if { ($sollPos == -2147483648) || ($istPos == -2147483648) } {
      set Diff [expr abs($sollPos - $istPos)]
   } else {
      set Diff [expr abs(abs($sollPos) - abs($istPos))]
   }
   if { $Diff <= $toleranz } {
      TlPrint "MONC.PREFUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      return 1
   } else {
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d abs(diff)=%d" $sollPos $istPos $toleranz $Diff
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"

      doWaitMs 100
      set istPos [doReadObject MONC.PREFUSR]
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"

      doWaitMs 500
      set istPos [doReadObject MONC.PREFUSR]
      TlError "MONC.PREFUSR exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr $sollPos - $istPos]
      TlPrint "MONC.PACTUSR= [doReadObject MONC.PACTUSR]"

      return 0
   }
} ;# checkPREFUSR_OFL

#-----------------------------------------------------------------------
# Tolerance is additional to Toleranz_Iact
#
proc CheckIact { I_Soll {Tolerance 0} } {
   global Toleranz_Iact

   #only IactQ relevant for torque
   set I_Act [doPrintObject MONC.IACTQ]    ;#Amplitude

   # additional tolerance
   set tolerance [expr $Toleranz_Iact + $Tolerance]

   #check absolute current
   set deviation [expr $I_Act  - $I_Soll]
   if { abs($deviation) <= $tolerance } {
      TlPrint "MONC.IACTQ: Exp=$I_Soll Act=$I_Act Tol=$tolerance Diff=$deviation"
   } else {
      TlError "MONC.IACTQ: Exp=$I_Soll Act=$I_Act Tol=$tolerance Diff=$deviation"
      ShowStatus
   }

} ;#CheckIact

#-----------------------------------------------------------------------
# Check Position at RS422 Input (in Incr)
# toleranz in Steps
#-----------------------------------------------------------------------
proc checkPosRS422 { sollPos {toleranz 0} } {

   set istPos [doReadObject IO.POSRS422IN]

   #    set toleranz [expr abs (round ($sollPos * $toleranz / 100))]

   if [expr abs($sollPos - $istPos) <= $toleranz] {
      TlPrint "IO.POSRS422IN: exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos-$istPos)]
   } else {
      TlError "IO.POSRS422IN: exp=%d act=%d tol=%d diff=%d" $sollPos $istPos $toleranz [expr abs($sollPos-$istPos)]
   }
} ;# checkPosRS422

#-----------------------------------------------------------------------
# Check Speed at RS422 Input (in Incr/sec)
# toleranz in % with min. 10 Inc/s
#-----------------------------------------------------------------------
proc checkVelRS422 { sollSpeed {toleranz 0} {TTId ""}} {

   set TTId [Format_TTId $TTId]

   set istSpeed [doReadObject IO.VELRS422IN]

   # Toleranz min. 10 Inc/s
   set toleranz [expr abs (round ($sollSpeed * $toleranz / 100))]
   if {$toleranz < 10 } {
      set toleranz 10
   }

   if [expr abs($sollSpeed - $istSpeed) <= $toleranz] {
      TlPrint "IO.VELRS422IN: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr abs($sollSpeed-$istSpeed)]
   } else {
      TlError "$TTId IO.VELRS422IN: exp=%d act=%d tol=%d diff=%d" $sollSpeed $istSpeed $toleranz [expr abs($sollSpeed-$istSpeed)]
   }
} ;# checkVelRS422

#------------------------------------------------------------------------------
# this function checks, if 2 positions (in internal increments ) are close enough
# from one another with the precaution of limit crossed with 1 rotation.
# diese Routine prueft, ob zwei Positionen (in int. Incrementen) nahe genug bei
# einander liegen unter der Berücksichtigung des Überlaufes bei 1 Umdrehung
#------------------------------------------------------------------------------
proc checkDiffPactModulo { PosIst PosSoll {Toleranz 0} } {
   global INC_PRO_1U

   # here we do not use the normal tolerance for PACT from defs, because it is not precise enough
   # (specially by SM). For each references from Indexpuls can a better tolerance
   # be defined, because the courses are always the same.
   # Problem with Maxxon sensor for SM : it has an sinusoidal error for a rotation
   # when the same course will be done, we can set the tolerance to 6 sensor increments.
   # see also function setDefs

   # hier nicht die normale Toleranz für PACT aus defs verwenden, denn diese ist zu ungenau
   # (speziell bei SM) Bei allen Referenzfahrten auf Indexpuls kann eine genauere Toleranz
   # definiert werden, da die angefahrene Position immer die gleiche ist.
   # Problem bei Maxxon Geber bei SM: er hat eine sinusförmige Ungenauigkeit über eine Umdrehung weg
   # wenn man aber immer auf die gleiche Position fährt, kann man mit 6 Geberincrementen rechnen
   # zur Berechnung der Toleranzen siehe auch Routine setDefs
   # (18.1.2007 ockeg)
   if { [GetDevFeat "MotAC"] } {
      set TolPactModulo 48   ;# 6 Resolver Incr (=6*8 intIncr)
   } else {
      TlError "undefined motor type"
      return
   }
   set  Tol [expr $TolPactModulo + $Toleranz]

   set grenze1     [expr $INC_PRO_1U / 4]                       ;# 25% von 1U
   set grenze2     [expr $INC_PRO_1U - $grenze1]                ;# 1U - 25%

   # mit Ueberlauf
   set result 0
   if {($PosIst <= $grenze1) && ($PosSoll >= $grenze2) } {
      set result [expr $PosIst +($INC_PRO_1U - $PosSoll)]
   }
   if {($PosIst >= $grenze2) && ($PosSoll <= $grenze1) } {
      set result [expr $PosSoll +($INC_PRO_1U - $PosIst)]
   }

   # without limit crossing
   if {$result == 0 } {
      set result [expr abs($PosSoll - $PosIst)]
   }

   if {$result > $Tol } {
      TlError "MONC.PACTMODULO: Pos act=%6d and Pos exp=%6d difference to big, Diff=%6d Tol=%4d" $PosIst $PosSoll $result $Tol
      return 0
   } else {
      TlPrint "MONC.PACTMODULO: Pos act=%6d Pos exp=%6d Diff=%6d Tol=%4d" $PosIst $PosSoll $result $Tol
      return 1
   }
}

#-----------------------------------------------------------------------
# Check REF_OK-Bit in STD.AXISMODE (Bit 5)
# The Ref-OK bit will be 1 after a successull referencing.
# It will be reset :
# a) for all devices without Absencoder
#    - after an interrupted referencecourse
#    - nach abgebrochener Referenzfahrt
#    - at power off
# b) for IFEN (Quasiabsencoder)
#    - after an interrupted referencecourse
#    - nach abgebrochener Referenzfahrt
#    -at power off when the motor is moved for more than one position
#    - wenn bei ausgeschalteter Versorgungsspannung der Motor um mehr als eine Raststellung verdreht
# wird
# c) for Lex05 with Absencoder
#    - after an interrupted referencecourse
#    - nach abgebrochener Referenzfahrt
#
#-----------------------------------------------------------------------
proc checkRefOkBit { refOkSoll {TTId ""}} {

   set TTId [Format_TTId $TTId]

   set axismode [doReadObject STD.AXISMODE]
   set refOkIst [expr ($axismode >> 5) & 1]

   # REF_OK
   if { $refOkIst == $refOkSoll } {
      TlPrint "REF_OK Bit: $refOkIst"
      return 1
   } else {
      TlError "$TTId REF_OK Bit: exp=$refOkSoll act=$refOkIst"
      return 0
   }
}

#-----------------------------------------------------------------------
# Check SPG-Overrun Bit in STD.WARNSIGSR
#-----------------------------------------------------------------------
proc checkOverrun { overrunSoll } {

   set sigwarn  [doReadObject STD.WARNSIGSR]
   set warnIst  [expr ($sigwarn & 1)]
   set warnSoll $overrunSoll     ;# 0 oder 1

   # WARNUNGSBIT OVERFLOW
   if { $warnIst == $warnSoll } {
      TlPrint "Overflow-Warnungsbit ok: $warnIst"
      return 1
   } else {
      TlError "Overflow-Warnungsbit falsch: exp=$warnSoll act=$warnIst"
      return 0
   }
}

#-----------------------------------------------------------------------
# Check the speed
#-----------------------------------------------------------------------
#proc CheckSpeedTl {SollGeschwindigkeit} {
#   TlError "CheckSpeedTl is obsolete!"
#   return
#
#   #DOC----------------------------------------------------------------
#   #
#   # Checks if the rotation speed is within tolerance
#   #
#   #END----------------------------------------------------------------
#   global HAS_PROFIBUS
#   global PB_TWINLINE
#   global Toleranz_Geschwindigkeit
#   global Toleranz_rel_Geschwindigkeit
#   global Toleranz_min_Geschwindigkeit
#   global GEAR_NUM GEAR_DEN  Tol_Tl_Abs_Geschwindigkeit
#
#   if {! $HAS_PROFIBUS} {
#      # Tests need power off and on from devices
#      TlError "CheckSpeedTl() can only be run at testtowe"
#      return
#   }
#
#   # TODO: check toerance, global value ???
#
#    if { $Toleranz_rel_Geschwindigkeit != 0 } {
#        # set an acceptable tolerance
#        set Toleranz_Geschwindigkeit [expr ($Toleranz_rel_Geschwindigkeit)*$SollGeschwindigkeit];
#        set Toleranz_Geschwindigkeit [expr abs($Toleranz_Geschwindigkeit) +
# $Tol_Tl_Abs_Geschwindigkeit ];
#        #   if { $Toleranz_Geschwindigkeit < $Toleranz_min_Geschwindigkeit } {
#        #      set Toleranz_Geschwindigkeit  [expr $Toleranz_min_Geschwindigkeit];
#        #   }
#    }
#
#   TlPrint "Acceptable Toleranz = %f" $Toleranz_Geschwindigkeit
#
#   # Check if the rotation speed is within tolerance
#   # with Twinline
#   set IstGeschwindigkeit [pbTwinObjRead $PB_TWINLINE 31 9];
#
#   # Check for device
#   # calculate speed at motorblade IclA
#   set IstGeschwindigkeit [expr $IstGeschwindigkeit * $GEAR_NUM / $GEAR_DEN]
#   TlPrint "GearNum : %d   Gear_Den : %d" $GEAR_NUM  $GEAR_DEN
#
#   set Differenz [expr {abs($SollGeschwindigkeit - $IstGeschwindigkeit)} ];
#   if { $Differenz > $Toleranz_Geschwindigkeit} {
#      # the measured rotation speed is too much different than the expected one !
#      ###TlError "Fault in rotation speed!! Differenz=%f  actualValue=%d exp=%d" $Differenz
# $IstGeschwindigkeit $SollGeschwindigkeit
#      TlError "TwinLine Istgeschwindigkeit exp=%d act=%d toleranz=%f U/min" $SollGeschwindigkeit
# $IstGeschwindigkeit $Toleranz_Geschwindigkeit
#
#      TlPrint "Istgeschwindigkeit  NACT: [doReadObject READ.NACT]"
#      TlPrint "Istgeschwindigkeit  VACT: [doReadObject READ.VACT]"
#      TlPrint "Sollgeschwindigkeit VREF: [doReadObject READ.VREF]"
#      return 0
#   }  else  {
#      TlPrint "TwinLine Istgeschwindigkeit ok: exp=%d act=%d toleranz=%f U/min" $SollGeschwindigkeit
# $IstGeschwindigkeit $Toleranz_Geschwindigkeit
#      return 1
#   }
#}

#-----------------------------------------------------------------------
# Check current from motor phases
#-----------------------------------------------------------------------
#
#proc CheckCurrent {SollStrom} {
#   TlError "CheckCurrent is obsolete!"
#   return
#
#   #DOC----------------------------------------------------------------
#   #
#   # Checks if the current from motor phases are within tolerance
#   # Only for steppers
#   #END----------------------------------------------------------------
#   global Toleranz_rel_Strom
#   global Norm_Motorstrom
#
#   # Check if the current from motor phases are within tolerance
#   set IstStrom [doReadObject  MOTSM.IACT];
#   if { $IstStrom == ""  } then {
#     TlError "invalid RxFrame received"
#     return 0
#   }
#
#   TlPrint "IstStrom Rohwert = %d" $IstStrom;
#   set Differenz [expr {abs($SollStrom - $IstStrom)} ];
#   if { $Differenz >  $Toleranz_rel_Strom} {
#      # the measured rotation speed is too much different than the expected one !!
#      TlError "Fault on motor current!! Differenz=%d  actualValue=%d nominalValue =%d" $Differenz
# $IstStrom $SollStrom
#      return 0
#   }  else  {
#      TlPrint "The current from the motor is within tolerance exp=%d act=%d" $SollStrom $IstStrom
#   }
#   return 1
#}

#-----------------------------------------------------------------------
# Check parameter default value
#-----------------------------------------------------------------------
proc checkParaDefault {ObjectName {TTId ""}} {
   global globAbbruchFlag theObjNrHashtable ImplementedPara
   global theTestcaseID theLXMLimitCheckFile

   TlPrint "open file: $theLXMLimitCheckFile"
   set file [open $theLXMLimitCheckFile]

   #Set Index and Subindex
   set index_list       [getIndex $ObjectName]
   set check_index      [lindex $index_list 0]
   set check_subindex   [lindex $index_list 1]

   # check all parameters at default value
   while { ! [eof $file] } {
      set line [gets $file]

      # ignore commented lines
      if { ([regexp "^#" $line]) | [regexp "^$" $line] } {
         #         TlPrint "Comment line: $line"
         continue
      }

      # Split the line into a list
      set wordList [split $line "|"]

      set index         [lindex $wordList 0]
      set subindex      [lindex $wordList 1]
      set Defaultwert   [lindex $wordList 11]

      set ObjectNr "$index.$subindex"

      if {[CheckBreak]} {break}

      #Search until the parameter is found
      if {!($index == $check_index && $subindex == $check_subindex)} {
         continue
      }

      if {[info exists theObjNrHashtable($ObjectNr)] } {
         # only for debug
         #         TlPrint "Object name: %s" $theObjNrHashtable($ObjectNr)
      } else {
         TlError "name of objekt: %s is not defined in objDefs.h" $ObjectNr
         continue
      }

      if  {$ImplementedPara != "" }  {
         if { [lsearch -regexp  $ImplementedPara $theObjNrHashtable($ObjectNr) ] == -1 } then {

            TlPrint "not implemented: $index.$subindex (%s)" $theObjNrHashtable($ObjectNr)
            continue
         }
      }

      set Lesewert [doReadObject $ObjectNr];
      if { $Lesewert == "" } then {
         TlError "invalid RxFrame received from objekt: $ObjectNr"
      } else {
         if {$Lesewert == $Defaultwert} {
            TlPrint "Default ok: %d.%d=%d" $index $subindex $Lesewert
         } else {
            TlError "Default nok: %d.%d soll:%d ist:%d" $index $subindex $Defaultwert $Lesewert
         }
      }
      if {[CheckBreak]} {break}

   } ;#while

   close $file

} ;# checkParaDefault


#-----------------------------------------------------------------------
# Check Speed in SPD (Motor speed in RPM)
#-----------------------------------------------------------------------
proc checkSPD { expSpeed {tol ""} } {
   global Tolerance_SPD_Rel Tolerance_SPD_Min

   set actSpeed [doReadObject SPD]

   if {$tol != ""} {
      set tolerance $tol
   } else {
      set tolerance [expr round(abs($expSpeed*$Tolerance_SPD_Rel))]
      if { $tolerance < $Tolerance_SPD_Min } {
         set tolerance $Tolerance_SPD_Min
      }
   }

   if [expr abs($expSpeed - $actSpeed) <= $tolerance] {
      TlPrint "SPD: exp=%d act=%d tol=%d diff=%d" $expSpeed $actSpeed $tolerance [expr $actSpeed-$expSpeed]
      return 1
   } else {
      TlError "SPD: exp=%d act=%d tol=%d diff=%d" $expSpeed $actSpeed $tolerance [expr $actSpeed-$expSpeed]
      return 0
   }
}

#-------------------------------------------------------------------------------
# Check different versions of internal modules
#-------------------------------------------------------------------------------
proc checkVersion {} {
	global theAltilabXML_ARM_CRC theAltilabXML_DSP_CRC mainpath ActDev DevType
	set DriveType [ string toupper  $DevType($ActDev,Type)   ] 

	TlPrint "--------------------------------------------------------"
	TlPrint "checkVersion{} - Check versions of device"
	TlPrint ""
	TlPrint "Check internal cards versions"
	TlPrint "*************************************************************"
	
	if {[GetDevFeat "ShadowOffer"] } {
			ReadVersionFile	"$mainpath/ObjektDB/SHADOWF_Version.txt"
	} else {
	ReadVersionFile	"$mainpath/ObjektDB/${DriveType}_Version.txt"
	}
	#######################################################
	# Change Versions of Card 1 to 6 here:

	set Application [Find_CPUVersion "Cortex" ]   ;# C1SV and C1SB  (M3)
	set DSP         [Find_CPUVersion "Dsp" ]  ;# C4SV and C4SB  (C28)
	if {[GetDevFeat "MVK"]} {
		if {[GetSysFeat "AdaptationBoard"]} {
				set PowerCPU   	   [Find_CPUVersion "PowerMvk" ]  ;# C2SV and C2SB  (CpuPower)
				set PowerChecksum  [Find_CPUChecksum "PowerMvk" ]  ;#  C2SC  (CpuPower)
				set FPGAVersion    [Find_CPUVersion "MVK_FPGA_Power" ]  ;# C8SV and C8SB  (FPGAVersion) 
				set EthOpt    [Find_CPUVersion "EthOpt" ]  ;# O3SV and O3SB  (FPGAVersion) 
			} else {
				set PowerCPU    "V0.0IE00_B00" ;# C2SV and C2SB  (CpuPower)
			}
	} else {
		set PowerCPU    [Find_CPUVersion "Power" ]  ;# C2SV and C2SB  (CpuPower)
	}
	if {![GetDevFeat "K2"]} {
		set CPLD        [Find_CPUVersion "Cpld" ]  ;# C5SV
		if {[GetDevFeat "Card_AdvEmbedded"] || [GetDevFeat "Card_EthBasic"]} {
			set EthBasic    [Find_CPUVersion "EthEmb" ]  ;# C6SV and C6SB
		}
	}
	#######################################################
	
	checkObject C1SV [getVersionFromString $Application] "" "Application (M3) version:"        0
	checkObject C1SB [getBuildFromString $Application]   "" "Application (M3)build:"          0
	checkObject C1SC $theAltilabXML_ARM_CRC "" "ARM Firmware CRC:" 0
	checkObject C2SV [getVersionFromString $PowerCPU]    "" "Motor (CpuPower) version:"              0
	checkObject C2SB [getBuildFromString $PowerCPU]      "" "Motor (CpuPower) build:"                0
	TlPrint "Boot version: [format 0x%04X [ModTlRead C3SV]]"
	TlPrint "Boot build: [format 0x%04X [ModTlRead C3SB]]"
	checkObject C4SV [getVersionFromString $DSP] "" "DSP (C28) version:"                0
	checkObject C4SB [getBuildFromString $DSP]   "" "DSP (C28) build:"                  0
	checkObject C4SC $theAltilabXML_DSP_CRC "" "DSP Firmware CRC:" 0
	if {![GetDevFeat "K2"]} {
		checkObject C5SV [getCpldVersionFromString $CPLD] "" "CPLD version:"               0
			if {[GetDevFeat "Card_AdvEmbedded"] || [GetDevFeat "Card_EthBasic"]} {
				checkObject C6SV [getVersionFromString $EthBasic] "" "Ethernet basic version:"     0
				checkObject C6SB [getBuildFromString $EthBasic]   "" "Ethernet basic build:"       0
			}
	}

	TlPrint "-end----------------------------------------------------"

};#checkVersion


proc getVersionFromString {String} {

   # example: A0.3IE05_B37_b00 / A0.3IE05_B37 / V3.0
   set pattern {^[ADFKV]\d+\.\d+(IE\d+_B\d+(_b\d+)?)?$}
    if {![regexp $pattern $String]} {
	TlError "The string $String does NOT match expected pattern for version"
	return 0xFFFF
    }
   # for version only characters until first _ are needed
   set String [lindex [split $String "_"] 0]
   # remove "A" at the beginning
   if {[string first "A" $String] == 0 || [string first "D" $String] == 0 || [string first "F" $String] == 0 || [string first "K" $String] == 0 || [string first "V" $String] == 0} {
      set String [string range $String 1 end]
   }
   # split in version (V) and evolution (IE)
   set String [split $String "I"]
   set V [lindex $String 0]
   set IE [lindex $String 1]
   # remove dot
   set VV [split $V "."]
   set VM [lindex $VV 0]
   set Vm [lindex $VV 1]
   # change format to hexa
   set V [format %x $VM][format %x $Vm]
   # remove "E"
   set IE [string range $IE 1 end]
   set result "0x$V$IE"
   # set result 0x[format "%02X" $V][format "%02X" $IE]

   if {[string is integer $result]} {
      return $result
   } else {
      return 0xFFFF
   }

}

#--------------------------------------------------------------------------------------
# Doxygen Tag:
##Function description : Resets all the outputs of the tower
## WHEN		| WHO	| WHAT
# -----		| -----	| -----
# 2023/11/30 	| SES	| proc created to handle the check checksum from Version.txt
#--------------------------------------------------------------------------------------
proc getChecksumFromString {String} {

	# example: A0.3IE05_B37_b00
	if { [string first "(" $String] == 0} {
	set String [string range $String 1 end]
	}
	# split in : 
	set String [split $String ":"]
	set C [lindex $String 1]
	# remove )
	set CRC [split $C ")"]
	set CheckSum [lindex $CRC 0]
	# change format to hexa
	set CS [format %x $CheckSum]
	# remove "E"
	set result "0x$CS"
	# set result 0x[format "%02X" $V][format "%02X" $IE]

	if {[string is integer $result]} {
	return $result
	} else {
	return 0xFFFF
	}

}

proc getBuildFromString {String} {

   # example: A0.3IE05_B37_b00 / A0.3IE05_B37 / V3.0
   set pattern {^[ADFKV]\d+\.\d+(IE\d+_B\d+(_b\d+)?)?$}
    if {![regexp $pattern $String]} {
	TlError "The string $String does NOT match expected pattern for version"
	return 0xFFFF
    }
   # for build only characters after first _ are needed
   set String [split $String "_"]

   # get B and b
   set Bupper [lindex $String 1]
   set bLOWER [lindex $String 2]
   # remove B
   set Bupper [string range $Bupper 1 end]
   # remove b
   set bLOWER [string range $bLOWER 1 end]

   if {$Bupper == ""} {set Bupper "00"}
   if {$bLOWER == ""} {set bLOWER "00"}

   set result "0x$Bupper$bLOWER"

   if {[string is integer $result]} {
      return $result
   } else {
      return 0xFFFF
   }

}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Check Parameters default value after factory setting.
# Check Parameters min/max values and ranges.
# Check if Parameters can be written during motor run.
# Check if Parameters can be stored in EEPROM.
# Procedure must consist of list of values following the specific format
# Param1 DefaultValue1 MinValue1 MaxValue1 Type1 List1 FacSetting1 NegLogical1 TTId1 DrvStatus1
# Param2 DefaultValue2 MinValue2 MaxValue2 Type2 List2 FacSetting2 NegLogical2 TTId2 DrvStatus2
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 051114 serio    creation of proc based on ATVCheckParam
# 061114 serio    modify waiting times, add condition for min/max check, add R3 value, alternative to
# default
#END------------------------------------------------------------------------------------------------

proc CheckATVParamList {list_arguments} {

   global DevAdr ActDev
   set ActAdr $DevAdr($ActDev,MOD)

   #Extract information from list_arguments and split to several lists

   set larglength [llength $list_arguments]

   set list_names {}
   set list_defs {}
   set list_mins {}
   set list_maxs {}
   set list_types {}
   set list_islist {}
   set list_facset {}
   set list_neg {}
   set list_ttid {}
   set list_drvstat {}

   for {set i 0} {$i < $larglength} {incr i 10} {

      lappend list_names   [lindex $list_arguments [expr 0 + $i]]
      lappend list_defs    [lindex $list_arguments [expr 1 + $i]]
      lappend list_mins    [lindex $list_arguments [expr 2 + $i]]
      lappend list_maxs    [lindex $list_arguments [expr 3 + $i]]
      lappend list_types   [lindex $list_arguments [expr 4 + $i]]
      lappend list_islist  [lindex $list_arguments [expr 5 + $i]]
      lappend list_facset  [lindex $list_arguments [expr 6 + $i]]
      lappend list_neg     [lindex $list_arguments [expr 7 + $i]]
      lappend list_ttid    [lindex $list_arguments [expr 8 + $i]]
      lappend list_drvstat [lindex $list_arguments [expr 9 + $i]]

   }

   #create a reduced set of list for most of tests since lists can have many times same parameters
   # but with different mins/maxs

   set list_reduced_names {}
   set list_reduced_defs {}
   set list_reduced_mins {}
   set list_reduced_maxs {}
   set list_reduced_types {}
   set list_reduced_islist {}
   set list_reduced_facset {}
   set list_reduced_neg {}
   set list_reduced_ttid {}
   set list_reduced_drvstat {}

   for {set i 0} {$i < $larglength} {incr i 10} {

      set index [lsearch $list_reduced_names [lindex $list_arguments [expr 0 + $i]]]

      if { $index == -1 } {

         lappend list_reduced_names   [lindex $list_arguments [expr 0 + $i]]
         lappend list_reduced_defs    [lindex $list_arguments [expr 1 + $i]]
         lappend list_reduced_mins    [lindex $list_arguments [expr 2 + $i]]
         lappend list_reduced_maxs    [lindex $list_arguments [expr 3 + $i]]
         lappend list_reduced_types   [lindex $list_arguments [expr 4 + $i]]
         lappend list_reduced_islist  [lindex $list_arguments [expr 5 + $i]]
         lappend list_reduced_facset  [lindex $list_arguments [expr 6 + $i]]
         lappend list_reduced_neg     [lindex $list_arguments [expr 7 + $i]]
         lappend list_reduced_ttid    [lindex $list_arguments [expr 8 + $i]]
         lappend list_reduced_drvstat [lindex $list_arguments [expr 9 + $i]]

      } else {

         #in case the parameter exists allready replace only min/max if difference is bigger than for
         # previous min/max

         set diff1 [ expr [lindex $list_arguments [expr 3 + $i]] - [lindex $list_arguments [expr 2 + $i]] ]
         set diff2 [ expr [lindex $list_reduced_maxs $index] - [lindex $list_reduced_mins $index] ]

         if {$diff1 > $diff2 } {

            set list_reduced_mins [lreplace $list_reduced_mins $index $index [lindex $list_arguments [expr 2 + $i]]]
            set list_reduced_maxs [lreplace $list_reduced_maxs $index $index [lindex $list_arguments [expr 3 + $i]]]

         }

      }

   }

   set lists_length [llength $list_names]
   set lists_reduced_length [llength $list_reduced_names]

   #Do the factory setting in case one of the params must be tested with factory setting

   if { [lsearch $list_facset 1] != -1} {

      TlPrint "1) Factory Setting with IPL, address and motor parameters update"
      TlPrint "--------------------------------------------"

      doFactorySetting

      if {[GetDevFeat "Nera_200V"]} {
         # 200V Devices are supplied with 1 Phase only
         # -> deactivate Input Phase Loss detection
         TlWrite IPL .NO
         checkObject IPL .NO
      }

      #Clear error if occured
      if {[TlRead HMIS 1] == 23} {
         TlPrint "Clear actual error"
         setDI 4 "H"                   ;#Activate reset
         setDI 4 "L"                   ;#Switch off input
      }

      WriteAdr $ActAdr MOD

      WriteMotorData

   }

   for {set i 0} {$i < $lists_reduced_length} {incr i} {

      if {[lindex $list_reduced_facset $i] == 1 } {

         #do nothing since factory setting has been performed

      } else {

         #Write Default parameter if factory setting was not needed
         TlWrite [lindex $list_reduced_names $i] [lindex $list_reduced_defs $i]
      }

      #Check the default value
      doWaitForObject [lindex $list_reduced_names $i] [lindex $list_reduced_defs $i] 2

   }

   #in case of some parameters the default value is innapropriate for test environment
   #therefore a different value must be written
   #todo after this function library has matured put these values inside arguments for example

   for {set i 0} {$i < $lists_length} {incr i} {

      set Param [lindex $list_names $i]

      switch $Param {

         R1 -
         R2 -
         R3 {
            set list_defs [lreplace $list_defs $i $i .NO]
         }
         default {
         }
      }

   }

   for {set i 0} {$i < $lists_reduced_length} {incr i} {

      set Param [lindex $list_reduced_names $i]

      switch $Param {

         R1 -
         R2 -
         R3 {
            set list_reduced_defs [lreplace $list_reduced_defs $i $i .NO]
         }
         default {
         }
      }

   }

   if {[GetDevFeat "Beidou"]} {
      TlWrite R3 .NO
      doWaitForObject R3 .NO 2
   }

   #Check Min Max values

   TlPrint "2) Check for all min/max values"
   TlPrint "-------------------------------"

   for {set i 0} {$i < $lists_length} {incr i} {

      set Param [lindex $list_names $i]
      set Default [lindex $list_defs $i]
      set MinValue [lindex $list_mins $i]
      set MaxValue [lindex $list_maxs $i]
      set List [lindex $list_islist $i]
      set Type [lindex $list_types $i]
      set DrvStatus [lindex $list_drvstat $i]
      if { [lindex $list_ttid $i] == " " } {
         set TTId ""
      } else {
         set TTId [lindex $list_ttid $i]
      }

      TlWrite $Param $MinValue
      doWaitForObject $Param $MinValue 10 0xffffffff $TTId
      if { $MaxValue != $MinValue } {
         TlWrite $Param $MaxValue
         doWaitForObject $Param $MaxValue 10 0xffffffff $TTId
      }

      #depending on Type

      switch $Type {

         SET {

            #depending on parameters list argument

            if {$List ==0 } {

               set DataParam [GetParaAttributes $Param]
               set ParaType  [lindex $DataParam 3]

               if { [string range $ParaType 0 3] != "UINT" } {

                  TlWrite $Param [ expr ($MinValue-1)]
                  doWaitForObject $Param $MinValue 2 0xffffffff $TTId

               } else {
                  if {$MinValue > 0 } {
                     TlWrite $Param [ expr ($MinValue-1)]
                     doWaitForObject $Param $MinValue 2 0xffffffff $TTId
                  } else {
                     TlWrite $Param [ expr ($MinValue-1)]
                     doWaitForObject $Param $MaxValue 2 0xffffffff $TTId

                  }
               }
               if {$MaxValue > 32767 } {
                  TlWrite $Param [ expr ($MaxValue+1)]
                  doWaitForObject $Param $MinValue 2 0xffffffff $TTId
               } else {
                  TlWrite $Param [ expr ($MaxValue+1)]
                  doWaitForObject $Param $MaxValue 2 0xffffffff $TTId
               }

            } else {

               TlWrite $Param [ expr ($MinValue-1)]
               doWaitForObject $Param $MaxValue 2 0xffffffff $TTId
               TlWrite $Param [ expr ($MaxValue+1)]
               doWaitForObject $Param $MaxValue 2 0xffffffff $TTId

            }

         }

         CFG {

            TlWrite $Param [ expr ($MinValue-1)]
            doWaitForObject HMIS .FLT 10
            doWaitForObject LFT .CFI 10
            TlWrite $Param $MinValue
            doWaitForObjectTol HMIS $DrvStatus 2 1
            TlWrite $Param [ expr ($MaxValue+1)]
            doWaitForObject HMIS .FLT 2
            doWaitForObject LFT .CFI 2
            TlWrite $Param $MaxValue
            doWaitForObjectTol HMIS $DrvStatus 2 1

         }

      }

      #write back the default value for the next test to check if modification is working

      TlWrite $Param $Default
      doWaitForObject $Param $Default 2 0xffffffff $TTId

   }

   #Check RUN modification or not depending on type

   TlPrint "3) Check for parameter modification during RUN"
   TlPrint "----------------------------------------------"

   for {set i 0} {$i < $lists_reduced_length} {incr i} {

      set Param [lindex $list_reduced_names $i]
      set MinValue [lindex $list_reduced_mins $i]
      set MaxValue [lindex $list_reduced_maxs $i]
      set Default [lindex $list_reduced_defs $i]
      set Type [lindex $list_reduced_types $i]
      if { [lindex $list_ttid $i] == " " } {
         set TTId ""
      } else {
         set TTId [lindex $list_ttid $i]
      }

      if { $Default != $MinValue } {
         set ChangeValue $MinValue
      } elseif { $Default != $MaxValue } {
         set ChangeValue $MaxValue
      } else {
         TlPrint "Not possible to change value for $Param since min=max"
         continue
      }

      switch $Type {

         SET {

            #Check Run modification
            setDI 1 H
            doWaitForModState ">=4" 5       ;# expected values: RUN, ACC, DEC...
            TlWrite $Param $ChangeValue
            doWaitForObject $Param $ChangeValue 2 0xffffffff $TTId
            setDI 1 L

         }

         CFG {

            #Check no Run modification
            setDI 1 H
            doWaitForModState ">=4" 1
            TlWriteAbort $Param $ChangeValue
            setDI 1 L
            doWaitForObject $Param $Default 2 0xffffffff $TTId

         }

      }

   }

   #Check EEprom memo

   TlPrint "4) Check for parameter memorization in EEPROM"
   TlPrint "---------------------------------------------"

   for {set i 0} {$i < $lists_reduced_length} {incr i} {

      set Param [lindex $list_reduced_names $i]
      set MinValue [lindex $list_reduced_mins $i]
      set MaxValue [lindex $list_reduced_maxs $i]
      if { [lindex $list_ttid $i] == " " } {
         set TTId ""
      } else {
         set TTId [lindex $list_ttid $i]
      }

      if { $Default != $MinValue } {
         set ChangeValue $MinValue
      } elseif { $Default != $MaxValue } {
         set ChangeValue $MaxValue
      } else {
         TlPrint "Not possible to change value for $Param since min=max"
         continue
      }

      TlWrite $Param $ChangeValue
      doWaitForObject $Param $ChangeValue 2 0xffffffff $TTId

   }

   doStoreEEPROM

   doReset

   for {set i 0} {$i < $lists_reduced_length} {incr i} {

      set Param [lindex $list_reduced_names $i]
      set MinValue [lindex $list_reduced_mins $i]
      set MaxValue [lindex $list_reduced_maxs $i]
      if { [lindex $list_ttid $i] == " " } {
         set TTId ""
      } else {
         set TTId [lindex $list_ttid $i]
      }

      if { $Default != $MinValue } {
         set ChangeValue $MinValue
      } elseif { $Default != $MaxValue } {
         set ChangeValue $MaxValue
      } else {
         continue
      }
      doWaitForObject $Param $ChangeValue 2 0xffffffff $TTId

   }

}

proc checkObjectConstant { objekt nominalValue {timeout 0} {ErrStat 1} {TTId ""} } {
   global ActInterface

   if {$TTId != ""} {
      set TTId "*$TTId*"
   }

   # get name of nominal value, if any
   if { ![string is integer $nominalValue] } {
      set nominalValue [Enum_Value $objekt $nominalValue]
   }
   set NameNominalValue [format "%s" [Enum_Name $objekt $nominalValue]]
   if { [string is integer $NameNominalValue] } {
      set NameNominalValue ""
   } else {
      set NameNominalValue "($NameNominalValue)"
   }

   set waittext  ""
   set timeout   [expr $timeout * 1000]         ;# in ms
   set starttime [clock clicks -milliseconds]
   while {1} {
      after 2   ;# wait 1 mS
      update idletasks

      set waittime [expr [clock clicks -milliseconds] - $starttime]
      # "waittime=" because dblog then presents only 1 entry for different waittimes
      if { $timeout > 0 } { set waittext "(waittime=$waittime\ms)" }
      if { [CheckBreak] } { return 0 }

      # read object
      set  actualValue [doReadModObject $objekt ""]   ;# via modbus

      if { $actualValue == "" } {
         TlError "empty string received"
         return 0
      }

      # get name of actual value, if any
      if { $actualValue == "" } { return 0 }
      set NameActualValue [format "%s" [Enum_Name $objekt $actualValue]]
      if { [string is integer $NameActualValue] } {
         set NameActualValue ""
      } else {
         set NameActualValue "($NameActualValue)"
      }

      # check value
      if { [expr $actualValue != $nominalValue] } {
         if {$ErrStat} {
            TlError "$TTId Object '$objekt' was not constant. Expected: $NameNominalValue Actual: $NameActualValue after $waittext"
            ShowStatus
         } else {
            TlPrint "$TTId Object '$objekt' was not constant. Expected: $NameNominalValue Actual: $NameActualValue after $waittext"
         }
         return 0
      }

      if { [expr $waittime > $timeout] } {
         TlPrint "Object '$objekt' was constant (Value: $NameNominalValue) for $waittext"
         return 1
      }

   } ;# end while

   return 1
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Check all parameters needed for a successfull test
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210715 todet    creation of proc
#
#END------------------------------------------------------------------------------------------------
proc checkTestsystem {} {

   global theOpalECATESIFile theNeraCANObjectFile theFortisCANObjectFile theAltivarCANObjectFile devnetconfig_FileName
   global theKalaCRFile theCrPostponedFile theAltiLabParameterFile
   global ActDev theDevList GlobErr DevAdr
   global ActInterface
   
   set checkList {}

   set check_CRFile ""
   lappend checkList check_CRFile

   set check_CrPostponedFile ""
   lappend checkList check_CrPostponedFile

   set check_AltiLabXML ""
   lappend checkList check_AltiLabXML

   set check_CANopenEDS ""
   lappend checkList check_CANopenEDS

   set check_DeviceNetCfg ""
   lappend checkList check_DeviceNetCfg

   set check_CRFileAge ""
   lappend checkList check_CRFileAge
   
   set check_Keypad ""
   lappend checkList check_Keypad

   foreach i $theDevList {
      set check_Dev[subst $i]State ""
      lappend checkList check_Dev[subst $i]State

      set check_Dev[subst $i]VBUS ""
      lappend checkList check_Dev[subst $i]VBUS

      set check_Dev[subst $i]MOD ""
      lappend checkList check_Dev[subst $i]MOD
      
      set check_Dev[subst $i]MODTCP ""
      lappend checkList check_Dev[subst $i]MODTCP

      set check_Dev[subst $i]Version ""
      lappend checkList check_Dev[subst $i]Version

      set check_Dev[subst $i]CommOption ""
      lappend checkList check_Dev[subst $i]CommOption
      
   }

   TlPrint ""
   TlPrint "Check if the testsystem is ready for a testrun"
   TlPrint ""

   #   set answer ""
   #   while {$answer == ""} {
   #      TlPrint "Name of the tester:"
   #      set answer [gets stdin]
   #      if {[string length $answer] < 2} {
   #         TlPrint "Invalid!"
   #         set answer ""
   #      }
   #   }

   TlPrint ""
   TlPrint "--------------------------------------------------------------"
   TlPrint "Check if all common needed files are available"

   TlPrint $theKalaCRFile
   if {[file exists $theKalaCRFile]} {
      set check_CRFile "OK"
   } else {
      set check_CRFile "!Missing"
   }

   TlPrint $theCrPostponedFile
   if {[file exists $theCrPostponedFile]} {
      set check_CrPostponedFile "OK"
   } else {
      set check_CrPostponedFile "!Missing"
   }

   TlPrint $theAltiLabParameterFile
   if {[file exists $theAltiLabParameterFile]} {
      set check_AltiLabXML "OK"
   } else {
      set check_AltiLabXML "!Missing"
   }

   TlPrint ""
   TlPrint "--------------------------------------------------------------"
   TlPrint "Check if fieldbus dependent files are available"

   if {[GetDevFeat "BusCAN"] && ([GetDevFeat "Nera"] || [GetDevFeat "Beidou"])} {
      TlPrint $theNeraCANObjectFile
      if {[file exists $theNeraCANObjectFile]} {
         set check_CANopenEDS "OK"
      } else {
         set check_CANopenEDS "!Missing"
      }
   } elseif {[GetDevFeat "BusCAN"] && [GetDevFeat "Fortis"]} {
      TlPrint $theFortisCANObjectFile
      if {[file exists $theFortisCANObjectFile]} {
         set check_CANopenEDS "OK"
      } else {
         set check_CANopenEDS "!Missing"
      }
   } else {
      set check_CANopenEDS "SKIPPED"
   }

   if {[GetDevFeat "BusDevNet"]} {
      TlPrint $devnetconfig_FileName
      if {[file exists $devnetconfig_FileName]} {
         set check_DeviceNetCfg "OK"
      } else {
         set check_DeviceNetCfg "!Missing"
      }
   } else {
      set check_DeviceNetCfg "SKIPPED"
   }

   TlPrint ""
   TlPrint "--------------------------------------------------------------"
   TlPrint "Check if files are outdated"

   set TimeDiff [expr [clock seconds] - [file mtime $theKalaCRFile]]
   # 1 week = 7 days = 168h = 10080min = 604800s
   set TimeMax 604800

   TlPrint "$theKalaCRFile is [expr $TimeDiff / 86400] days old"

   if {$TimeDiff > $TimeMax} {
      set check_CRFileAge "!Outdated ([expr $TimeDiff / 86400] days old)"
   } else {
      set check_CRFileAge "OK ([expr $TimeDiff / 86400] days old)"
   }

   TlPrint ""
   TlPrint "--------------------------------------------------------------"
   TlPrint "Check the test drives"

   set ActDevOld $ActDev

   foreach ActDev $theDevList {
      #catch {

         DeviceOn $ActDev
         set Tmp [doPrintModObject HMIS]
         if {$Tmp != 2} {
            set check_Dev[subst $ActDev]State "!Not RDY ($Tmp)"
         } else {
            set check_Dev[subst $ActDev]State "OK"
         }

         if {$Tmp == 0} {
            set check_Dev[subst $ActDev]MOD "!No communication"
         } else {
            set check_Dev[subst $ActDev]MOD "OK"
         }
      
         if {[GetDevFeat "BusMBTCP"] || [GetDevFeat "BusMBTCPioScan"] || [GetDevFeat "Card_AdvEmbedded"] || [GetDevFeat "Card_EthBasic"]} {
            
            if {![doWaitForPing $DevAdr($ActDev,MODTCP) 30000]} {
               set check_Dev[subst $ActDev]MODTCP "!Failed (no answer to ping)"
            } else {
               set Port [Mod2Open "MODTCP"]
               set ActInterfaceOld $ActInterface
               doSetCmdInterface "MODTCP"
               if {[TlRead C1CT] == [ModTlRead C1CT]} {
                  set check_Dev[subst $ActDev]MODTCP "OK"
               } else {
                  set check_Dev[subst $ActDev]MODTCP "!Failed"
               }
               doSetCmdInterface $ActInterfaceOld
               Mod2Close $Port
            }
         } else {
            set check_Dev[subst $ActDev]MODTCP "SKIPPED"
         }
         
         set GlobErrOld $GlobErr
         if {[GetDevFeat "Fortis"]} {
            checkVersionFortis
         } elseif {[GetDevFeat "Nera"]} {
            checkVersionNera
         } elseif {[GetDevFeat "Beidou"]} {
            checkVersionBeidou
         } else {
            set check_Dev[subst $ActDev]Version "Not available"
         }

         if {$GlobErr == $GlobErrOld} {
            set check_Dev[subst $ActDev]Version "OK"
         } else {
            set check_Dev[subst $ActDev]Version "!Failed"
         }

         if {[GetDevFeat "Nera_200V"]} {
            set VBUS_Expected 325
         } else {
            set VBUS_Expected 565
         }
         
         set VBUS [expr int([doPrintModObject VBUS] / 10)]
         if {[expr abs( $VBUS - $VBUS_Expected) <= 25]} {
            set check_Dev[subst $ActDev]VBUS "OK ($VBUS V)"
         } else {
            set check_Dev[subst $ActDev]VBUS "!Act: $VBUS Exp: $VBUS_Expected"
         }
         
         set ActInterfaceOld $ActInterface
         
         if {[GetDevFeat "BusEIP"]} {
            global EIP_Opened
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if {$EIP_Opened} {
               if {[EIP_WaitForSlaveInterfaceState] != 4} {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               } else {
                  set check_Dev[subst $ActDev]CommOption "OK"
               }
            } else {
               EIP_Open
               if {[EIP_WaitForSlaveInterfaceState] != 4} {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               } else {
                  set check_Dev[subst $ActDev]CommOption "OK"
               }
               EIP_Close
            }
            # End of If EIP
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } elseif {[GetDevFeat "BusDevNet"]} {
            
            doSetCmdInterface "DVN"
            
            if {[TlRead C1CT] == [ModTlRead C1CT]} {
               set check_Dev[subst $ActDev]CommOption "OK"
            } else {
               set check_Dev[subst $ActDev]CommOption "!Failed"
            }

            # End of If DevNet
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } elseif {[GetDevFeat "BusCAN"]} {
            
            doSetCmdInterface "CAN"
            
            if {[TlRead C1CT] == [ModTlRead C1CT]} {
               set check_Dev[subst $ActDev]CommOption "OK"
            } else {
               set check_Dev[subst $ActDev]CommOption "!Failed"
            }

            # End of If CAN
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } elseif {[GetDevFeat "BusPN"]} {
            
            doSetCmdInterface "PN_IO"
            
            if {[Profinet::isChannelOpen]} {
               Profinet::waitForSlave 30
               if {[TlRead C1CT] == [ModTlRead C1CT]} {
                  set check_Dev[subst $ActDev]CommOption "OK"
               } else {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               }
            } else {
               Profinet::openConnection "Telegram1"
               Profinet::waitForSlave 30
               if {[TlRead C1CT] == [ModTlRead C1CT]} {
                  set check_Dev[subst $ActDev]CommOption "OK"
               } else {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               }
               Profinet::closeConnection
            }

            # End of If ProfiNet
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } elseif {[GetDevFeat "BusECAT"]} {
            global ECAT_H_IsOpen
            doSetCmdInterface "ECAT"
            
            if {$ECAT_H_IsOpen} {
               EtherCAT_WaitForSlaveState "OP" 30
               if {[TlRead C1CT] == [ModTlRead C1CT]} {
                  set check_Dev[subst $ActDev]CommOption "OK"
               } else {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               }
            } else {
               ECAT_H_Open
               EtherCAT_WaitForSlaveState "OP" 30
               if {[TlRead C1CT] == [ModTlRead C1CT]} {
                  set check_Dev[subst $ActDev]CommOption "OK"
               } else {
                  set check_Dev[subst $ActDev]CommOption "!Failed"
               }
               ECAT_H_Close
            }

            # End of If EtherCAT
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } elseif {[GetDevFeat "BusPBdev"]} {
            
            doSetCmdInterface "SPB_IO"

            PB_PN_OpenTelegram "Telegram101"
            
            if {[TlRead C1CT] == [ModTlRead C1CT]} {
               set check_Dev[subst $ActDev]CommOption "OK"
            } else {
               set check_Dev[subst $ActDev]CommOption "!Failed"
            }

            PB_PN_Telegram_Close
            
            # End of If ProfiBus
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         } else {
            set check_Dev[subst $ActDev]CommOption "SKIPPED"
         }
         
         doSetCmdInterface $ActInterfaceOld

         if {([llength $theDevList] == 1) || ($ActDev == 1)} {
            if {[ModTlRead C7SV] != 0} {
               set check_Keypad "OK"
            } else {
               set check_Keypad "!Failed"
            }
         } else {
            if {$check_Keypad == ""} {
               set check_Keypad "SKIPPED"
            }
         }
      
         DeviceOff $ActDev

      #}
   }

   set ActDev $ActDevOld

   TlPrint ""
   TlPrint ""
   TlPrint ""
   TlPrint ""
   TlPrint ""
   
   TlPrint "###################################################"
   TlPrint "Tested and OK:"

   set TextLength 0
   foreach checkPoint $checkList {
      if {[string length $checkPoint] > $TextLength} {
         set $TextLength [string length $checkPoint]
      }
   }

   foreach checkPoint $checkList {
      if {[string first "OK" [subst $[subst $checkPoint]]] == 0} {
         TlPrint "$checkPoint : [subst $[subst $checkPoint]]"
      }
   }

   TlPrint ""
   TlPrint "Skipped:"
   
   foreach checkPoint $checkList {
      if {[string first "SKIPPED" [subst $[subst $checkPoint]]] == 0} {
         TlPrint "$checkPoint : [subst $[subst $checkPoint]]"
      }
   }
   
   
   set FailedCount 0

   foreach checkPoint $checkList {
      if {[string first "OK" [subst $[subst $checkPoint]]] != 0} {
         if {[string first "SKIPPED" [subst $[subst $checkPoint]]] != 0} {
            if {$FailedCount == 0} {
               TlPrint ""
               TlPrint "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
               TlPrint "Tested and FAILED:"
            }
            incr FailedCount
            TlPrint "$checkPoint : [subst $[subst $checkPoint]]"
         }
      }
   }
   
   if {$FailedCount > 0} {
      TlPrint "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
   }
   
   TlPrint ""
   TlPrint "###################################################"

}

proc ReadVersionFile {FileName} {
    global theVersionTable theChecksumTable


    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    set line [RemoveSpaceFromList $line]
	    set wordList [split $line]
	    if {[regexp "Cpld" [lindex $wordList 0]]} {
		    set theVersionTable(Cpld) [lindex $wordList 2] 
		    set theChecksumTable([lindex $wordList 0]) [lindex $wordList 3]
	    } else {	
		set theVersionTable([lindex $wordList 0]) [lindex $wordList 1] 
		set theChecksumTable([lindex $wordList 0]) [lindex $wordList 2]
	    }
	    if {[CheckBreak] == 1} {break}
	}
	close $file	
    }
}


proc Find_CPUVersion {String {NoErrorPrint 0}} {
    global theVersionTable 
    set rc [catch { set retVal $theVersionTable($String) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$String not existing in theVersionTable"
	return 0
    }
    return $retVal
}

proc Find_CPUChecksum {String {NoErrorPrint 0}} {
    global theChecksumTable
    set rc [catch { set retVal $theChecksumTable($String) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$String not existing in theChecksumTable"
	return 0
    }
    return $retVal
}

proc getCpldVersionFromString {String} {

   # example: ID:0x13.b01
   # for build only characters after x are needed
   set String [split $String "x"]

   set V [lindex $String 1]
   set V [string range $V 0 1]
   if {$V == ""} {set V "00"}

   set result "0x$V"

   if {[string is integer $result]} {
      return $result
   } else {
      return 0xFFFF
   }

}

proc getCpldBuildFromString {String} {

   # example: ID:0x13.b01
   # for build only characters after b are needed
   set String [split $String "b"]

   set Bupper [lindex $String 1]

   set Bupper [string range $Bupper 1 end]


   if {$Bupper == ""} {set Bupper "00"}

   set result "0x$Bupper"

   if {[string is integer $result]} {
      return $result
   } else {
      return 0xFFFF
   }

}
