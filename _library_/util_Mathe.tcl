# TCL Test tower-Environment
# Utility-functions for mathematical operations

# ----------HISTORY----------
# WHEN   WHO   WHAT
# 261107 ockeg Attached file
#

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Build mean value of parameter across a number x.
#  100ms waiting time between the values.
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 020506 grana proc created
# 290808 rothf Reading now always via Modbus
#END----------------------------------------------------------------
proc doMeanValue { Parameter Anzahl {Display 0}} {
   set ValueAll 0
   for { set i 1 } { $i <= $Anzahl } { incr i } {
      if {$Display == 0 } {
         set Value [doReadModObject $Parameter]
      } else {
         set Value [doPrintModObject $Parameter]
      }
      doWaitMsSilent 100
      incr ValueAll $Value
   }
   set ValueDiff [expr $ValueAll / $Anzahl]

   return $ValueDiff
};#doMeanValue

#DOC----------------------------------------------------------------
#DESCRIPTION
# give the smaller of two values
#
#END----------------------------------------------------------------
proc min { val1 val2 } {
   if { $val1 < $val2 } {
      return $val1
   } else {
      return $val2
   }
};#min

#DOC----------------------------------------------------------------
#DESCRIPTION
# give the bigger of two values
#
#END----------------------------------------------------------------
proc max { val1 val2 } {
   if { $val1 > $val2 } {
      return $val1
   } else {
      return $val2
   }
};#max

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Calculate the Modbus CRC through the pBuf message
#  WARNING: pBuf must contain an even-numbered number of marks !
#           this is not checked here
#  Example:
#  pbuf                  : 020316060004 (Read Obj 22.3 of device #2)
#  CRC Soll              : 73A0
#  MakeCRC gives         : A073
#END----------------------------------------------------------------
proc MakeCRC { pbuf {Polynom 0xA001} } {
   set lbuf [ string length $pbuf ]
   set CRC  0xFFFF

   for { set i 0 } { $i < $lbuf} { incr i 2 } {
      set c   [string range $pbuf $i [expr $i + 1]]
      set CRC [expr $CRC ^ 0x$c]
      for { set sc 0 } { $sc < 8} { incr sc } {
         if { [expr $CRC & 1] } {
            set CRC [expr $CRC >> 1]           ;#right shift 1
            set CRC [expr $CRC ^  $Polynom]    ;#XOR with CRC-Polynom
         } else {
            set CRC [expr $CRC >> 1]           ;#right shift 1
         }
      }
   }
   set crclo [ expr $CRC >> 8 ]
   set crchi [ expr $CRC << 8 ]
   set crchi [ expr $crchi & 0xFF00 ]
   return [ expr $crchi | $crclo ]
};#MakeCRC

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Calculate the Modbus CRC word.
#
#END----------------------------------------------------------------
proc MakeCRC_word {data_list CrcPoly} {
   set ShiftRegister 0
   #   TlPrint "data_list: $data_list"
   #   TlPrint "CrcPoly: $CrcPoly"

   for { set PosWord 0 } { $PosWord < [string length $data_list] } { incr PosWord 4} {

      set BitPosition 0x8000
      for { set PosBit 0 } { $PosBit < 16 } { incr PosBit } {
         #TlPrint "data_list(PosWord): 0x[string range $data_list $PosWord [expr $PosWord + 3]]"
         #TlPrint "BitPosition: $BitPosition"
         if { [expr (0x[string range $data_list $PosWord [expr $PosWord + 3]] & $BitPosition ) == $BitPosition]} {
            set DataBit 1
         } else {
            set DataBit 0
         }
         if {[expr (0x[format %X $ShiftRegister] & 0x8000) == 0x8000]} {
            set RegBit 1
         } else {
            set RegBit 0
         }
         #TlPrint "ShiftRegister: [format %X $ShiftRegister]"
         #TlPrint "RegBit: $RegBit"
         #TlPrint "DataBit: $DataBit"
         if {$RegBit != $DataBit } {
            set ShiftRegister [expr (($ShiftRegister << 1) & 0xFFFF)  ^ $CrcPoly]
         } else {
            set ShiftRegister [expr (($ShiftRegister << 1) & 0xFFFF)]
         }
         #TlPrint "ShiftRegister: [format %X $ShiftRegister]"
         set BitPosition [expr $BitPosition >> 1]
         #TlPrint "BitPosition: $BitPosition"
      }
      #TlPrint ""
      #TlPrint ""
   }

   set High_Byte [format %02X [expr $ShiftRegister & 0xFF]]
   set Low_Byte  [format %02X [expr ($ShiftRegister & 0xFF00) >> 8]]

   append return_value $High_Byte $Low_Byte

   return $return_value
} ;#MakeCRC_word

#DOC----------------------------------------------------------------
#DESCRIPTION
# Convert an unsigned 8 Bit value into a signed value
#
#END----------------------------------------------------------------
proc UINT08_TO_INT08 { val8 } {
   if {[ catch {
            if { $val8 & 0x80 } {
               set val [expr $val8-0xFF-1]
            } else {
               set val $val8
            }
         } ] } {
      return $val8
   } else {
      return $val
   }

};#UINT08_TO_INT08

#DOC----------------------------------------------------------------
#DESCRIPTION
# Convert an unsigned 16 Bit value into a signed value
#
#END----------------------------------------------------------------
proc UINT_TO_INT { val16 } {
   if {[ catch {
            if { $val16 & 0x8000 } {
               set val [expr $val16-0xFFFF-1]
            } else {
               set val $val16
            }
         } ] } {
      return $val16
   } else {
      return $val
   }
};#UINT_TO_INT

#DOC----------------------------------------------------------------
#DESCRIPTION
# Convert an unsigned 32 Bit value into a signed value
#
#END----------------------------------------------------------------
proc UDINT_TO_DINT { val32 } {
   if {[ catch {
            if { $val32 & 0x80000000 } {
               set val32 [format "0x%X" $val32]
               set val [expr $val32-0xFFFFFFFF-1]
            } else {
               set val $val32
            }
         } ] } {
      return $val32
   } else {
      return $val
   }
};#UDINT_TO_DINT

#DOC----------------------------------------------------------------
#DESCRIPTION
# Detect sign
#
#END----------------------------------------------------------------
proc sign {value} {
   if {$value < 0} {
      return -1
   } else {
      return 1
   }
};#sign

#DOC----------------------------------------------------------------
#DESCRIPTION
# return 1 when it is an even number
#
#END----------------------------------------------------------------
proc even {value} {
   if { [expr $value & 1] } {
      return 0
   } else {
      return 1
   }
};#even

#DOC----------------------------------------------------------------
#DESCRIPTION
# return 1 when it is an odd number
#
#END----------------------------------------------------------------
proc odd {value} {
   if { [expr $value & 1] } {
      return 1
   } else {
      return 0
   }
};#odd

#DOC----------------------------------------------------------------
#DESCRIPTION
#  random nr in defined range
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 010310 pfeig file created
#END----------------------------------------------------------------
proc random {min max} {
   expr {int(rand()*($max-$min+1))+$min}
};#random

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Perform a shift operation on a given word (WD) of a given number (Number) of places.
# Benefits: - new Bits on the right will have "1" instead of "0"
#           - the return value is a word (16Bit wide)
# PRECAUTION: - If a given word (WD) is longer, the remaining Bits will be cut
# ATTENTION:  - In case of "1" shift the result will have "1" on the new places compared to "<<"
#		operator
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 101114 gelbg    Proc created
#END------------------------------------------------------------------------------------------------
proc WordShiftZeroL { WD Number} {
   set WD [expr (~$WD)]
   set WD [expr ($WD<<$Number)]
   set WD [expr (~$WD)]
   set WD [expr ($WD & 0xFFFF)]
   return $WD
}
