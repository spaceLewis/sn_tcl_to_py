#
# Description  :  library functions for string action
#
# Filename     :  util_String.tcl
#
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 070509 pfeig file created
# 251011 pfeig update with functions from sercos
# 200313 weiss translation into english

proc CompStr { str1 str2 } {

   set result [string compare $str1 $str2]
   if {$result == 0 } {
      return 1
   } else {
      return 0
   }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
# convert a value into Little-Endian or Big-Endian format
# and inversely
# type = s for 16bits objects
# type = i for 32bits objects
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080814 weiss proc created
#END----------------------------------------------------------------
proc ConvEndian {type value} {
   binary scan [binary format $type $value] [string toupper $type] value
   return $value
}

##----------------------------------------------------------------------------
proc SwapWords {UDINT} {
   # swap low and high word of UDINT
   return [expr (($UDINT <<16)& 0xFFFF0000)|(($UDINT >>16) & 0x0000FFFF)]
}

##----------------------------------------------------------------------------

##----------------------------------------------------------------------------
proc SwapBytes {UDINT} {
   # swap low and high word of UDINT
   return [expr (($UDINT <<8)& 0xFF00)|(($UDINT >>8) & 0x00FF)]
}

##----------------------------------------------------------------------------

proc FloatToHex { Float } {

   # Bsp:
   #      1.0 (Float)
   #      / \
   #  00 00 80 3F (Hex Bytes)
   #   \ /   \ /
   #    X     X
   #   / \   / \
   #    0   16256 (2 Decimal Strings)
   #   / \   / \
   #   0000 3F80 (Hex String for PLC)

   #seperate Float to HexBytes
   set Hex [binary format f* $Float]
   #swap byte-order, store in decimal
   binary scan $Hex s* Hex
   #seperate decimal-string to hex-bytes
   set Hex [binary format S* $Hex]
   #build hex-string out of hex-bytes
   binary scan $Hex H* Hex

   return "0x$Hex"

}

proc HexToFloat { Hex } {

   # Bsp:
   #   F3B6 3F9D (Hex String from PLC)
   #   /  \ /  \
   #  F3 B6 3F 9D (Hex Bytes)
   #   \ /   \ /
   #    X     X
   #   / \   / \
   #    0   16256 (2 Decimal Strings)
   #   / \   / \
   #  B6 F3 9D 3F (Hex Bytes)
   #   \  \ /  /
   #    \  |  /
   #     1.234 (Float)

   set Hex [format "%08x" $Hex]

   #seperate hex-string to hex-bytes
   set Float [binary format H* $Hex]
   #swap byte-order, store in decimal
   binary scan $Float s* Float
   #seperate decimal-string to hex-bytes
   set Float [binary format S* $Float]
   #convert to float
   binary scan $Float f Float

   return $Float

}

#DOC----------------------------------------------------------------
# Convert Hex values in binary String
# Example: 0x4944 produces "0100100101000100"
#END----------------------------------------------------------------
proc HexToBin { value {BitLength 16} } {
   set length [expr int($BitLength / 4) + 2]

   set value [format %#0$length\x $value]

   for {set i 2} {$i <= [expr $length - 1]} {incr i} {
      switch -exact [string index $value $i] {
         0 { append result "0000" }
         1 { append result "0001" }
         2 { append result "0010" }
         3 { append result "0011" }
         4 { append result "0100" }
         5 { append result "0101" }
         6 { append result "0110" }
         7 { append result "0111" }
         8 { append result "1000" }
         9 { append result "1001" }
         a -
         A { append result "1010" }
         b -
         B { append result "1011" }
         c -
         C { append result "1100" }
         d -
         D { append result "1101" }
         e -
         E { append result "1110" }
         f -
         F { append result "1111" }
         default {  }
      }
   }
   return $result
} ;#HexToBin

#-----------------------------------------------------------------------
proc asciiValueToString32 { value } {
   #DOC----------------------------------------------------------------
   #DESCRIPTION
   # Convert ASCII-Coded 32 bits values in string
   # Example: 0x49445320 produces "IDS "
   #
   # ----------HISTORY----------
   # WHEN   WHO   WHAT
   #
   #END----------------------------------------------------------------
   set c1 [expr ($value >> 24) & 255]
   set c2 [expr ($value >> 16) & 255]
   set c3 [expr ($value >>  8) & 255]
   set c4 [expr ($value >>  0) & 255]

   return [format "%c%c%c%c" $c1 $c2 $c3 $c4]
}

#DOC----------------------------------------------------------------
# Convert ASCII-Coded 16 bits values in String
# Example: 0x4944 produces "ID"
#END----------------------------------------------------------------
proc asciiToString16 { value } {

   set c3 [expr ($value >>  8) & 255]
   set c4 [expr ($value >>  0) & 255]

   if {$c3 == 0x00} {
      return [format "%c" $c4]
   } elseif {$c4 == 0x00} {
      return [format "%c" $c3]

   } else {   return [format "%c%c" $c3 $c4]}

}

#DOC----------------------------------------------------------------
# Convert ASCII-Coded values in String
#   TCL>  ? asciiToString 04000106415456333248
#   Output : ....ATV32H
#END----------------------------------------------------------------
proc asciiToString { value {IgnoreSpecialChars 0}} {

   set length [string length $value]
   if {[string first "0x" $value] == 0} {
      incr length -2
      set value [string range $value 2 end]
   }

   set String ""
   for {set char 0} {$char < $length} {incr char 2} {
      set chr "0x[string range $value $char [expr $char + 1 ] ]"
      if { ($chr >= 0x20) && ($chr <= 0x7E) } {
         append String [format "%c" "0x[string range $value $char [expr $char + 1 ] ]" ]
      } else {
         if {!$IgnoreSpecialChars} {
            append String "."
         }
      }
   }

   return $String

}

#DOC----------------------------------------------------------------
# Convert ASCII-Coded values in String
#   TCL>  ? asciiToString 04000106415456333248
#   Output : ....ATV32H
#END----------------------------------------------------------------
proc HexToString { value } {

   set length [string length $value]
   if {[string first "0x" $value] == 0} {
      incr length -2
      set value [string range $value 2 end]
   }

   set String ""
   for {set char 0} {$char < $length} {incr char 2} {
      set chr "0x[string range $value $char [expr $char + 1 ] ]"
      append String [format "%c" "0x[string range $value $char [expr $char + 1 ] ]" ]
   }

   return $String

}

#DOC----------------------------------------------------------------
# find and extract a hexcode out of a Text that is marked with Pattern
# Pattern doesn't distinguish between upper- and lowercase
# for example:
# ExtractHexCode "Set_Attribute_Single Service failed: CODE=0x09 (Invalid attribute value)" "Code=0x"
# -> result 0x09
#END----------------------------------------------------------------
proc ExtractHexCode { Text Pattern {ErrPrint 0} } {

   set dummy ""
   set errCode 0
   set p [format "%s(.*)" $Pattern]   ;# max 8 hex Digits
   if { [regexp -nocase $p $Text dummy errCode] } {
      # Hexcode found in Text
      if { ![string is xdigit -failindex ixfail $errCode] } {
         # Copy till the first not Hex-Digit
         if { $ixfail > 0 } {
            incr ixfail -1
         } else {
            if { $ErrPrint } { TlError "not a valid number: $errCode"}
            return 0
         }
         set errCode [string range $errCode 0 $ixfail]
      }
      return "0x$errCode"
   } else {
      if { $ErrPrint } { TlError "no hex value found in ($Text)" }
      return 0
   }
}

#-------------------------------------------------------------------
# Carry only first line
# Search in a longer text the first occurrence of \n
# Give the text till there
proc GetFirstLine { text } {
   set i [string first "\n" $text]
   if {$i != -1} {
      incr i -1
      return [string range $text 0 $i]
   }
   return $text
}

#-------------------------------------------------------------------
# in str replace the first occurence of searchfor and replace it with replacewith
proc StringReplace { str searchfor {replacewith ""} } {
   set first [string first $searchfor $str]
   if { $first == -1 } {
      return $str
   } else {
      set last [expr $first + [string length $searchfor] - 1]
      return [string replace $str $first $last $replacewith]
   }
}

proc StringToAscii { str } {

   #DOC----------------------------------------------------------------
   #DESCRIPTION
   # Convert string to ASCII value
   # Example: {IDS } produces 0x49445320
   #
   # ----------HISTORY----------
   # WHEN   WHO   WHAT
   #
   # 040714 serio proc created
   #
   #END----------------------------------------------------------------

   set ascii 0

   for {set i 0} {$i<[string length $str]} {incr i} {

      set ascii [expr 0x$ascii << 8]
      scan "[string index $str $i]" %c temp
      set ascii [format %04llX [expr $ascii + $temp]]

   }

   return 0x$ascii

}

proc StringToHex { str } {

   #DOC----------------------------------------------------------------
   #DESCRIPTION
   # Convert string to ASCII value
   # Example: {IDS } produces 0x49445320
   #
   # ----------HISTORY----------
   # WHEN   WHO   WHAT
   #
   # 040714 serio proc created
   #
   #END----------------------------------------------------------------

   set ascii 0

   for {set i 0} {$i<[string length $str]} {incr i} {

      set ascii [expr 0x$ascii << 8]
      scan "[string index $str $i]" %c temp
      set ascii [format %04llX [expr $ascii + $temp]]

   }

   return $ascii

}

proc WriteAsciiToPar { args } {

   #DOC----------------------------------------------------------------
   #DESCRIPTION
   # Convert string to ASCII value then writes values to given parameters
   # Think of passing the string argument in between brackets for spaces { }
   #
   # ----------HISTORY----------
   # WHEN   WHO   WHAT
   #
   # 040714 serio proc created
   #
   #END----------------------------------------------------------------

   set str [lindex $args 0]            ;#extracting string as first argument
   set param_list [lrange $args 1 end] ;#extracting the list of parameters as next arguments

   #check enough parameters are listed for the string

   set allparsize 0

   foreach par $param_list {

      set tempsize [Param_Length $par]
      set allparsize [expr $allparsize + $tempsize]

   }

   set stringsize [expr [string length $str] / 2]

   #each ASCII character is made of one byte
   if {$allparsize < $stringsize} {

      if {$param_list == "" } {
         TlError "no parameters given as input"
      } else {
         TlError "the given parameters : $param_list are not enough to contain ASCII code of string : $str"
      }
      return
   } elseif {$allparsize > $stringsize} {
      TlPrint "Warning : some parameters will be filled with ASCII code NULL"
   }

   #in a loop cut string depending on parameter size and assign to parameter

   set strindex 0

   for {set i 0} { $i < [llength $param_list] } { incr i } {

      set par [lindex $param_list $i]
      set tempsize [Param_Length $par]

      set tempstr ""

      for {set j 0} { $j < [Param_Length $par] } { incr j } {

         if {[string index $str [expr $strindex + $j]] != ""} {

            append tempstr [string index $str [expr $strindex + $j]]

         } else {
            append tempstr [format %c 0]
         }

      }

      TlWrite $par [StringToAscii $tempstr ]
      doWaitForObject $par [StringToAscii $tempstr] 1

      set strindex [expr $strindex + [Param_Length $par]]

   }

}

proc CheckAsciiInPar { args } {

   #DOC----------------------------------------------------------------
   #DESCRIPTION
   # Convert string to ASCII value then check values to given parameters
   # Think of passing the string argument in between brackets for spaces { }
   #
   # ----------HISTORY----------
   # WHEN   WHO   WHAT
   #
   # 160714 serio proc created
   #
   #END----------------------------------------------------------------

   set str [lindex $args 0]            ;#extracting string as first argument
   set param_list [lrange $args 1 end] ;#extracting the list of parameters as next arguments

   #check enough parameters are listed for the string

   set allparsize 0

   foreach par $param_list {

      set tempsize [Param_Length $par]
      set allparsize [expr $allparsize + $tempsize]

   }

   set stringsize [string length $str]

   #each ASCII character is made of one byte

   if {$allparsize < $stringsize} {

      if {$param_list == "" } {
         TlError "no parameters given as input"
      } else {
         TlError "the given parameters : $param_list are not enough to contain ASCII code of string : $str"
      }
      return
   } elseif {$allparsize > $stringsize} {
      TlPrint "Warning : some parameters will be checked for ASCII code NULL"
   }

   #in a loop cut string depending on parameter size and check in parameter

   set strindex 0

   for {set i 0} { $i < [llength $param_list] } { incr i } {

      set par [lindex $param_list $i]
      set tempsize [Param_Length $par]

      set tempstr ""

      for {set j 0} { $j < [Param_Length $par] } { incr j } {

         if {[string index $str [expr $strindex + $j]] != ""} {

            append tempstr [string index $str [expr $strindex + $j]]

         } else {
            append tempstr [format %c 0]
         }

      }

      if { [doWaitForObject $par [StringToAscii $tempstr] 1] == 0 } {
         break
      }

      set strindex [expr $strindex + [Param_Length $par]]

   }

}

