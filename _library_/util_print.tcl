# TCL Testturm environment
# Utility functions for display screen

# ----------HISTORY----------
# WHEN   WHO   WHAT
# 311007 ockeg proc created

if {![info exists ShowStatusOnline]} {
   set ShowStatusOnline 0
}

#DOC----------------------------------------------------------------
#
# Display of drive MODE
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 070416 pfeig create
#
proc doPrintMODE { } {

   set MODE0 [ModTlRead MODE]
   TlPrint "Mode = [HexToString [format %X $MODE0]]"

}

#================================================================================
# read a code assigned to error text from a error description file
# if the code do not exist in the file, display it, then return 1
# if the code is not found in the file, then return 0
#
# IMPORTANT: the error code and the description must be in one line
# only this one line is displayed:
# Ex for error code files:
#   CAN_SDO_Abort_Errors.txt:
#     0x05030000 Toggle bit not alternated.
#     0x05040000 SDO protocol timed out.
#   errorcodes.ini:
#     E1100=Parameter outside from permissible value range
#     E1101=Parameter does not exist
proc doPrintErrorText { File Code {tlerror 0} } {

   set datei [open $File]
   while { ![eof $datei] } {
      set line [gets $datei]
      if { [string first $Code $line] >= 0 } {
         if { $tlerror } {
            TlError "Error $line"  ;# HURRAH, found!
         } else {
            TlPrint "Error $line"  ;# HURRAH, found!
         }
         close $datei
         return 1
      }
   }

   close $datei
   return 0  ;# not found
}

#================================================================================
# as doPrintErrorText, however not display, just return in result
proc doGetErrorText { File Code } {

   set datei [open $File]
   while { ![eof $datei] } {
      set line [gets $datei]
      if { [string first $Code $line] >= 0 } {
         set result "$line"
         close $datei
         return $result
      }
   }

   close $datei
   return "unknown"  ;# not found
}

#----------------------------------------------------------------------------
#  Output of procedure info (currently procname only)
#----------------------------------------------------------------------------
proc PrintProcEntryInfo { } {

   set funcNames ""
   set startLevel 1
   set endLevel [expr [info level] -1]

   set funcName [info level $endLevel]
   # TwinPrint [format "  _Entry_> %s" $funcName]
   TlPrint  "  _Entry_> %s" $funcName
   return
}

#================================================================================
# read a Windows ErrorCode assigned to error text from the Winerror.h file
# if the code do not exist in the file, display it, then return 1
# if the code is not found in the file, then return 0
#
# IMPORTANT: the error code and the description are not in the same line
# in Winerror.h file.
# Ex:
#---------Extract from WinError.H---------------------------------------
# MessageId: DV_E_CLIPFORMAT
#
# MessageText:
#
# Invalid clipboard format
#
# #define DV_E_CLIPFORMAT                  _HRESULT_TYPEDEF_(0x8004006AL)
#---------Extract from WinError.H---------------------------------------
#
# All lines between "MessageText" and "define" are displayed
# (without the empty lines)
#
# It would be easier with the regexp instruction, if it works!
# Ex (TCL Interpreter does not find following lines,
#      CodeWrite with Option "regular expression" find it but
#      as well as Regexpr Coach):
#
#    if { [regexp { (.)*(0x)([0-9a-fA-F]+)(.)* } "#define  CLIPBRD_E_CANT_EMPTY
# _HRESULT_TYPEDEF_(0x800401D1L)" a b c d] } {
#      TlPrint "a=$a"
#      TlPrint "b=$b"
#      TlPrint "c=$c"
#      TlPrint "d=$d"
#   }
#
proc doPrintWinErrorText { File Code } {

   #TlPrint "search for errorcode %d (0x%08X) in File %s" $Code $Code $File

   set lastline 9
   for {set i 0} {$i <= $lastline} {incr i} {
      set fifo($i) ""
   }

   set errCode 0
   set found 0
   set datei [open $File]
   while { ![eof $datei] } {
      # Shiftregister with $lastline line
      for {set i 0} {$i < $lastline } {incr i} {
         set fifo($i) $fifo([expr $i+1])
      }
      set fifo($lastline) [gets $datei]
      set line $fifo($lastline)

      if { [string first "define" $line] >= 0 } {
         set hexbegin [string first "0x" $line]
         if { $hexbegin >= 0 } {
            # hexadecimal value
            if { ![string is xdigit -failindex ixfail [string range $line [expr $hexbegin+2] end] ] } {
               if { $ixfail <= 0 } { continue }
               set errCode [string range $line $hexbegin [expr $hexbegin+2+$ixfail-1]]
               if { $errCode != $Code } { continue }
               set found 1  ;# HURRAH, found!
               break
            }
         } else {
            # decimal value
            set l [string length $line]
            for {set i 0} {$i < $l } {incr i} {
               if { ![string is digit -failindex ixfail [string range $line $i end] ] } {
                  if { $ixfail <= 0 } { continue }
                  set errCode [string range $line $i [expr $i+$ixfail-1]]
                  if { $errCode != $Code } { continue }
                  set found 1  ;# HURRAH, found!
                  break
               }
            }
            if { $found } { break }
         } ;# if hex/dez

      } ;# if string first define

   } ;# while eof
   close $datei

   # All lines between "MessageText" and "define" are displayed
   set errtext ""
   if { $found } {
      for {set i $lastline} {$i >= 0 } {incr i -1} {
         if { [string first "MessageText" $fifo($i)] >= 0 } {
            for {set j [expr $i+1]} {$j < $lastline} {incr j} {
               if { [string length $fifo($j)] > 2 } {
                  append errtext [string trim [string range $fifo($j) 2 end]]
                  append errtext " "
               }
            }
            break
         }
      }
      TlPrint "WinErrror 0x%08X (%d): %s" $errCode $errCode $errtext
      return 1
   } else {
      return 0  ;# not found
   }

}

#-----------------------------------------------------------------------
# 21.11.2007 ockeg all read instructions always on Modbus
# 05.11.2013 ockeg new input parameter broadcast
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
   doPrintFaultInfo
   if {[CheckBreak]} {return}

   doPrint_SM_ErrorState
   if {[CheckBreak]} {return}

   doPrintStatus
   if {[CheckBreak]} {return}

   doPrintModules
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

#   TlPrint "SFFault_u16DiagnoseFaultReq=%s"        [ModTlReadIntern "SFFault_u16DiagnoseFaultReq" 1]
#   TlPrint "DbgAssert_u16Id=%s"                    [ModTlReadIntern "DbgAssert_u16Id" 1]
#   TlPrint "SFATAP_u16PublicInternalFaults=%s"     [ModTlReadIntern "SFATAP_u16PublicInternalFaults" 1]
#   TlPrint "SFFault_u16PublicDiagFaultStatus=%s"   [ModTlReadIntern "SFFault_u16PublicDiagFaultStatus" 1]

   TlPrint "===End of ShowStatus========================="

   if {![info exists INFM_COUNTER]} {set INFM_COUNTER 0}

   if {$INFM_COUNTER >= 1} {

      set INFM_COUNTER 0

      set MODE0 [ModTlRead MODE]

      TlPrint ""
      TlPrint "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      TlPrint "Workaround, remove again if no more problems with INFM"
      
      
  

      ModTlWrite MODE .TP
      
      if { ![GetDevFeat "Altivar"]} {      
     
      }
      set Timestamp [clock format [clock seconds] -format {%d%m%Y_%H%M%S}]

      set File "System:/Conf/Modules/Conf/1/ADV/IPCL/Config.eth"

      if {[FileManagerOpenSession]} {
         set Buffer [FileManagerGetFile $File 0 10]
         FileManagerDumpHexToFile "C:/EthernetProblems/INFM_Config$Timestamp.cfg" $Buffer
         set Length [string length $Buffer]
         TlPrint "Length of 'System:/Conf/Modules/Conf/A/ADV/IPCL/Config.eth': $Length"

         if {$Length < 5000} {
            doWaitMs 5000
            if {[FileManagerOpenSession]} {
               set Buffer [FileManagerGetFile $File 0 10]
               FileManagerDumpHexToFile "C:/EthernetProblems/INFM_Config2_$Timestamp.cfg" $Buffer
            }
         }
      }

      set File "User:/Drive/Conf/ConfPackage.cfg"

      if {[FileManagerOpenSession]} {
         set Buffer [FileManagerGetFile $File 0 10]
         FileManagerDumpHexToFile "C:/EthernetProblems/INFM_ConfPackage$Timestamp.cfg" $Buffer
      }

      doReset >=2

      ModTlWrite MODE $MODE0
      doWaitForObject MODE $MODE0 0.1 0xffffffff "" 1

   }

   set ShowStatusOnline 0
};#ShowStatus

#DOC----------------------------------------------------------------
#DESCRIPTION
# Display of info drive state, reference and command channels
#END----------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 260615 serio add param FRO
proc doPrintStatus { } {
   TlPrint "----------- Status --------------------"
   set chcf [Enum_Name CHCF [ModTlRead CHCF 1] ]
   set fr1  [Enum_Name FR1  [ModTlRead FR1  1] ]
   set cd1  [Enum_Name CD1  [ModTlRead CD1  1] ]
   set tcc  [Enum_Name TCC  [ModTlRead TCC  1] ]
   TlPrint " CHCF FR1 CD1 TCC.................. %s %s %s %s" $chcf $fr1 $cd1 $tcc

   set CMDLFRlist [ModTlReadBlock CMD1 19 1] ;#CMD1->5, LFR1->5
   TlPrint " CMD1 CMD2 CMD3 CMD5 CMDA.......... 0x{%04X %04X %04X %04X %04X }" \
      [lindex $CMDLFRlist 0] [lindex $CMDLFRlist 1] [lindex $CMDLFRlist 2] [lindex $CMDLFRlist 4] [lindex $CMDLFRlist 8]
   TlPrint " LFR1 LFR2 LFR3 LFR5 LFRA..........    %4d %4d %4d %4d %4d" \
      [lindex $CMDLFRlist 10] [lindex $CMDLFRlist 11] [lindex $CMDLFRlist 12] [lindex $CMDLFRlist 14] [lindex $CMDLFRlist 18]
   TlPrint " RFR ..............................    %4d" [ModTlRead RFR 1]
   TlPrint " RFRD ..............................    %4d" [ModTlRead RFRD 1]
   TlPrint " FRO ..............................    %4d" [ModTlRead FRO 1]
   set SFlist [ModTlReadBlock SF00 8 1] ;#SF00 -> SF07
   TlPrint " SF00 SF02 SF03 SF04 SF07.......... 0x{%04X %04X %04X %04X %04X }" \
      [lindex $SFlist 0] [lindex $SFlist 2] [lindex $SFlist 3] [lindex $SFlist 4] [lindex $SFlist 7]
   TlPrint " SAF1 .............................    %4d" [ModTlRead SAF1 1]

   set hmis [ModTlRead HMIS 1]
   TlPrint " Drive state..(HMIS)............... %d (%s)" $hmis [Enum_Name HMIS $hmis]
   set eta [ModTlRead ETA 1]
   TlPrint " Status word..(ETA)................ 0x%04X (%s)" $eta [getETAStateName $eta]
   set eti [ModTlRead ETI 1]
   TlPrint " Extended status word..(ETI)....... 0x%04X" $eti
   #set wert [ModTlRead ERRD 1]
   #TlPrint " CiA402 fault code..(ERRD)......... 0x%04X"  $wert
   set crc [ModTlRead CRC 1]
   TlPrint " Active reference channel..(CRC)... 0x%04X (%s)" $crc [GetCDFRchannel $crc]
   set ccc [ModTlRead CCC 1]
   TlPrint " Active command channel..(CCC)..... 0x%04X (%s)" $ccc [GetCDFRchannel $ccc]
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Display of info from modules and option boards
#END----------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 150415 serio remove option board 2 check for Beidou
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

   if { (![GetDevFeat "Beidou"]) && ( ![GetDevFeat "Altivar"] ) && ( ![GetDevFeat "K2"] )} {

      #Info about option board 2
      set o2ct [ModTlRead "O2CT"]
      if { $o2ct != 0 } {
         TlPrint "----------- Option board 2 (CT=%s) ------------" [Enum_Name O2CT $o2ct]
         #also print versions, to check if module is correctly identified
         set o2sv [ModTlRead "O2SV"]
         if {$glb_Error || $o2sv == ""} { return }
         set o2sb [ModTlRead "O2SB"]
         if {$glb_Error || $o2sb == ""} { return }
         TlPrint " Type    (O2CT) %d (%s)" $o2ct [Enum_Name O2CT $o2ct]
         TlPrint " Version (O2SV) Build (O2SB) 0x%04X 0x%04X" $o2sv $o2sb
      }
   }
};#doPrintModules

#DOC----------------------------------------------------------------
#DESCRIPTION
# Display of In- Outputs DINGET and DOUTGET
#END----------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 250615 serio add analog io as well
proc doPrintIO { } {
   TlPrint "----------- IO Status -----------------"
   set IOlist [ModTlReadBlock IL1I 12 1] ;#IL1I,IL1R,OL1I,OL1R

   TlPrint " LO physical/real: %04X %04X" [lindex $IOlist 10] [lindex $IOlist 11]
   TlPrint " LI physical/real: %04X %04X" [lindex $IOlist 0 ] [lindex $IOlist 1 ]

   set AIOlist [ModTlReadBlock AI1I 25 1] ;#AIxI,AIxR,AIxC x= 1 to 5

   TlPrint " AI1 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 0] [lindex $AIOlist 10] [lindex $AIOlist 20]
   TlPrint " AI2 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 1] [lindex $AIOlist 11] [lindex $AIOlist 21]
   TlPrint " AI3 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 2] [lindex $AIOlist 12] [lindex $AIOlist 22]
   TlPrint " AI4 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 3] [lindex $AIOlist 13] [lindex $AIOlist 23]
   TlPrint " AI5 physical/real/customer : %04d %04d %05d " [lindex $AIOlist 4] [lindex $AIOlist 14] [lindex $AIOlist 24]

};#doPrintIO

#DOC----------------------------------------------------------------
#DESCRIPTION
# Display of all Modbus Com Parameter
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
# ----------HISTORY----------
# WANN   WER   WAS
# 060404 FiesJ Modbus Connect
# 271005 pfeig Feldnamen hinzugefügt
# 270207 ockeg Ausgabe ARRADM-Parameter
#
#DESCRIPTION
# display error memory
#END----------------------------------------------------------------
proc doDisplayErrorMemory {} {

   #Initial values
   set flt 0
   set sts 0
   set eSts 0
   set cmd 0
   set cur 0
   set freq 0
   set opTime 0
   set volt 0
   set motTherm 0
   set actChan 0  
   set motTorq 0
   set drvTherm  0
   set tj 0
   set switchFreq 0
   
   TlPrint "--------------------------------------------------------"
   TlPrint "doDisplayErrorMemory {} - Error memory"

   TlPrint " Fault  Status eStatus Command Current Freq  Time Volt motTh actChan motTrq drvTh TJ  switchFreq"

   set List1 [ModTlReadBlock DP0 100 1]   ;#Object list: DPx,EPx,IPx,CMPx,LCPx,RFPx,RTPx,ULPx,THPx,CRPx (index:0->9)
   #TlPrint "list1 is $List1"
   if {$List1 == ""} {
      TlPrint "return 0"
      return 0
   }    
   set List2 [ModTlReadBlock OTP0 40 1]   ;#Object list: OTPx,TDPx,TJPx,SFPx (index:0->9)
   if { ![GetDevFeat "Altivar"]} {       
   set List3 [ModTlReadBlock DPA 100 1]   ;#Object list: DPx,EPx,IPx,CMPx,LCPx,RFPx,RTPx,ULPx,THPx,CRPx (index:A->F)
   set List4 [ModTlReadBlock OTPA 40 1]   ;#Object list: OTPx,TDPx,TJPx,SFPx (index:A->F)
      set dp 15    
      
   } else {
      set dp 9  
   }

   for { set i 0} { $i <= $dp } { incr i } {
      #List1+2
      if {$i<=9 } {

         set flt        [lindex $List1 [expr $i+0 ]]  ;#DPx      
         set sts        [lindex $List1 [expr $i+10]]  ;#EPx      
         set eSts       [lindex $List1 [expr $i+20]]  ;#IPx        
         set cmd        [lindex $List1 [expr $i+30]]  ;#CMPx       
         set cur        [lindex $List1 [expr $i+40]]  ;#LCPx     
         set freq       [lindex $List1 [expr $i+50]]  ;#RFPx        
         set opTime     [lindex $List1 [expr $i+60]]  ;#RTPx       
         set volt       [lindex $List1 [expr $i+70]]  ;#ULPx      
         set motTherm   [lindex $List1 [expr $i+80]]  ;#THPx       
         set actChan    [lindex $List1 [expr $i+90]]  ;#CRPx        
         set motTorq    [lindex $List2 [expr $i+0 ]]  ;#OTPx         
         set drvTherm   [lindex $List2 [expr $i+10]]  ;#TDPx       
         set tj         [lindex $List2 [expr $i+20]]  ;#TJPx       
         set switchFreq [lindex $List2 [expr $i+30]]  ;#SFPx      
      } else {
         #List3+4
         set j [expr $i-10]

         set flt        [lindex $List3 [expr $j+0 ]]  ;#DPx
         set sts        [lindex $List3 [expr $j+10]]  ;#EPx
         set eSts       [lindex $List3 [expr $j+20]]  ;#IPx
         set cmd        [lindex $List3 [expr $j+30]]  ;#CMPx
         set cur        [lindex $List3 [expr $j+40]]  ;#LCPx
         set freq       [lindex $List3 [expr $j+50]]  ;#RFPx
         set opTime     [lindex $List3 [expr $j+60]]  ;#RTPx
         set volt       [lindex $List3 [expr $j+70]]  ;#ULPx
         set motTherm   [lindex $List3 [expr $j+80]]  ;#THPx
         set actChan    [lindex $List3 [expr $j+90]]  ;#CRPx
         set motTorq    [lindex $List4 [expr $j+0 ]]  ;#OTPx
         set drvTherm   [lindex $List4 [expr $j+10]]  ;#TDPx
         set tj         [lindex $List4 [expr $j+20]]  ;#TJPx
         set switchFreq [lindex $List4 [expr $j+30]]  ;#SFPx
      };#endif  
#      
#      TlPrint "flt = $flt "
#      TlPrint "sts = $sts "
#      TlPrint "eSts = $eSts "
#      TlPrint "cmd = $cmd "
#      TlPrint "cur = $cur "
#      TlPrint "freq = $freq "      
#      TlPrint "opTime = $opTime "
#      TlPrint "volt = $volt "  
#      TlPrint "motTherm = $motTherm "      
#      TlPrint "actChan = $actChan "       
#      TlPrint "motTorq = $motTorq "  
#      TlPrint "drvTherm = $drvTherm "       
#      TlPrint "tj = $tj "    
#      TlPrint "switchFreq = $switchFreq "        
                        
      
      if {$flt == "" || $sts == "" || $eSts == "" || $cmd == "" } {
         TlPrint "empty variable : quit display memory" 
       return 0  
      }
      
      if { ( $flt  == "" ) ||  ( $flt  == "0x]" ) ||  ( $flt  == "0x" )} {set flt  0 }     
      if {   ( $sts  == "0x]" ) ||  ( $sts  == "0x" ) }  { set sts  0 }     
      if {   ( $eSts  == "0x]" ) ||  ( $eSts == "0x" ) } { set eSts 0 }
      if {  ( $cmd  == "0x]" ) ||  ( $cmd == "0x" ) } { set cmd  0 }
      set flt    [expr $flt  & 0x0000FFFF]   ;# is only WORD         
      set sts    [expr $sts  & 0x0000FFFF]   ;# is only WORD          
      set eSts   [expr $eSts & 0x0000FFFF]   ;# is only WORD      
      set cmd    [expr $cmd  & 0x0000FFFF]   ;# is only WORD          
      set rc [catch  {TlPrint " 0x%04X 0x%04X 0x%04X  0x%04X  %7d %5d %4d %4d %5d %7d %6d %5d %2d %5d" $flt $sts $eSts $cmd $cur $freq $opTime $volt $motTherm $actChan $motTorq $drvTherm $tj $switchFreq}]
   
      if { ( $rc != 0 ) &&   ( ![GetDevFeat "Altivar"] ) } {
         TlPrint "Some arguments to display are empty: not possible to format and display"
         #TlError "Some arguments to display are empty: not possible to format and display"
      };#endif
   };#endfor
   
   TlPrint "-end----------------------------------------------------"

};#doDisplayErrorMemory

#DOC----------------------------------------------------------------
#DESCRIPTION
#  print SME0..SME9
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  090216 pfeig   created
#
#END----------------------------------------------------------------

#DOC----------------------------------------------------------------
#DESCRIPTION
#  print DP0..DPF
#
#  ----------HISTORY----------
#  WHEN   WHO     WHAT
#  170904 ockeg   created
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

# ----------HISTORY----------
# WHEN   WHO   WHAT
# xx0216 todet proc created
# 010316 pfeig renamed
# 041224 B.C   proc updated according to PROFIsafe project : Error number more than 1 byte
#
#-----------------------------------------------------------------------
# Check SM Module Error state
#-----------------------------------------------------------------------
proc doPrint_SM_ErrorState {} {
   global theSafetyErrorList

   if {![GetDevFeat "Modul_SM1"] && ![GetDevFeat "FW_CIPSFTY"]} {
      return
   }

#   TlPrint ""
#   if {![GetDevFeat "Opal"] || [GetSysFeat "PACY_SFTY_FORTIS"]} {
#   set  SFSV        [ModTlRead "SFSV" 1]
#      TlPrint "-------------------- Safety Error State SM-Version: $SFSV --------------------"
#   } else {
#      TlPrint "-------------------- Safety Error State --------------------------------------"
#      
#   }
#   

   #  set ErrList [ModTlReadBlock SME0 10 1]   ;#Object list: SMEx (index:0->9)
   set SMElist { 0 1 2 3 4 5 6 7 8 9 }
   foreach SMEx $SMElist {
      lappend ErrList [format 0x%04X [expr [ModTlRead SME$SMEx] & 0xFFFF]]
   }

   set  SAF1        [ModTlRead "SAF1" 1]
   set  SFID        [ModTlRead "SFID" 1]
   set  SF00        [ModTlRead "SF00" 1]
   set  SF02        [ModTlRead "SF02" 1]
   set  SF03        [ModTlRead "SF03" 1]
   set  SF04        [ModTlRead "SF04" 1]
   set  SF07        [ModTlRead "SF07" 1]

   set  STOS        [ModTlRead "STOS" 1]
   set  STOF        [ModTlRead "STOF" 1]
	

   TlPrint "| SME0 | SME1 | SME2 | SME3 | SME4 | SME5 | SME6 | SME7 | SME8 | SME9 |"
   TlPrint [format "|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|0x%04X|" \
      [lindex $ErrList 0] [lindex $ErrList 1] [lindex $ErrList 2] [lindex $ErrList 3] [lindex $ErrList 4] \
      [lindex $ErrList 5] [lindex $ErrList 6] [lindex $ErrList 7] [lindex $ErrList 8] [lindex $ErrList 9]]
   TlPrint "-----------------------------------------------------------------------"
   TlPrint " SAF1      : Safety Fault Register 1 | STOS: Safety TorqueOff Status "
   TlPrint " STOF      : Safety TorqueOff Feedback A and B monitoring"
   TlPrint " SFID      : Safety Fault Subregister for faulty task identification "
   TlPrint " SF00 - 07 : Safety Fault Subregister00 - 07 "
   TlPrint " "
   TlPrint " SAF1 = $SAF1 STOS = $STOS STOF = $STOF SFID = $SFID"
   TlPrint " SF00 = $SF00 SF02 = $SF02 SF03 = $SF03 SF04 = $SF04 SF07 = $SF07"
   TlPrint " "
   SM_check_SAFETY_FUNCTION_ViaDrive

   set result [catch {

      for {set i 0} {$i <= 9} {incr i} {
         if {[lindex $ErrList $i] != 0} {

            # search theSafetyErrorList for this error number if != 0
            set ErrorInfo [lsearch -index 0 $theSafetyErrorList [lindex $ErrList $i]]

            if {$ErrorInfo != -1} {

               # If there is a entry, print the error info

               set ErrorInfo [lindex $theSafetyErrorList $ErrorInfo]
               TlPrint "-----------------------------------------------------------------------"
               TlPrint "SME$i:"
               TlPrint "ErrorNumber      : 0x%04X" [lindex $ErrorInfo 0]
               TlPrint "ErrorClass       : [lindex $ErrorInfo 1]"
               TlPrint "ErrorName        : [lindex $ErrorInfo 2]"
               TlPrint "ErrorDescription : [lindex $ErrorInfo 3]"
               TlPrint "ErrorRootCause   : [lindex $ErrorInfo 4]"
               TlPrint "ErrorIsResetable : [lindex $ErrorInfo 5]"
               TlPrint "AtvFaultRegister : [lindex $ErrorInfo 6]"

            }

         }
      }

   }]

   if {$result != 0} {
      TlPrint "Failed to display all Safety Errors!!!"
   }

   TlPrint "-----------------------------------------------------------------------"
   doPrint_SM_ModulState

   TlPrint "-----------------------End of Safety Status----------------------------"
   TlPrint ""

} ;#doPrint_SM_ErrorState

# ----------HISTORY----------
# WHEN   WHO   WHAT
# 120216 pfeig proc created
#-----------------------------------------------------------------------
# Check SM Module state in SSTA
#-----------------------------------------------------------------------
proc doPrint_SM_ModulState { } {

   set actual [ doReadModObject "SSTA" ]
   if { $actual == "" } { return }
   set actual [format "0x%04X" $actual]

   #   if { ($actual & 0x0001) == 0 }         { TlPrint "  SM Status Bit0     = 0 : Power stage control blocked by SM"}
   #   if { ($actual & 0x0001) == 1 }         { TlPrint "  SM Status Bit0     = 1 : Power stage control enabled by SM"}
   #   if { ($actual & 0x0002) == 0 }         { TlPrint "  SM Status Bit1     = 0 : SM initialization and selftests not yet done"}
   #   if { ($actual & 0x0002) == 2 }         { TlPrint "  SM Status Bit1     = 1 : SM initialization and selftests done"}
   #   if { (($actual & 0x001C) >> 2) == 0 }  { TlPrint "  SM Status Bit2-4   = 0 : Safety Configuration: not configured "}
   #   if { (($actual & 0x001C) >> 2) == 1 }  { TlPrint "  SM Status Bit2-4   = 1 : Safety Configuration: not validated "}
   #   if { (($actual & 0x001C) >> 2) == 2 }  { TlPrint "  SM Status Bit2-4   = 2 : Safety Configuration: valid but not approved "}
   #   if { (($actual & 0x001C) >> 2) == 3 }  { TlPrint "  SM Status Bit2-4   = 3 : Safety Configuration: approved "}
   #   if { (($actual & 0x001C) >> 2) == 4 }  { TlPrint "  SM Status Bit2-4   = 4 : Safety Configuration: no Password "}
   #   if { ($actual & 0x0020) == 0 }         { TlPrint "  SM Status Bit5     = 0 : Safety Module Locked"}
   #   if { ($actual & 0x0020) == 0x20 }      { TlPrint "  SM Status Bit5     = 1 : Safety Module Unlocked"}
   #   if { ($actual & 0x0040) == 0 }         { TlPrint "  SM Status Bit6     = 0 : Reserved"}
   #   if { ($actual & 0x0040) == 0x40 }      { TlPrint "  SM Status Bit6     = 1 : Reserved"}
   #   if { ($actual & 0x0080) == 0 }         { TlPrint "  SM Status Bit7     = 0 : ToggleBit"}
   #   if { ($actual & 0x0080) == 0x80 }      { TlPrint "  SM Status Bit7     = 1 : ToggleBit"}

   set actState [expr ($actual & 0xFF) ]
   switch -exact $actState {
      0  { set StateName "START" }
      1  { set StateName "NOT READY TO SWITCH_ON" }
      2  { set StateName "SWITCH ON DISABLED" }
      3  { set StateName "READY TO SWITCH ON" }
      4  { set StateName "Not available" }
      5  { set StateName "OPERATION ENABLED" }
      6  { set StateName "Not available" }
      7  { set StateName "FAULT REACTION ACTIVE" }
      8  { set StateName "FAULT" }
      10 { set StateName "SS1_Active" }
      11 { set StateName "STO_Active" }
      24 { set StateName "STATE_DEAD_END_FAULT" }
      default { set StateName "Not available" }
   }

   TlPrint " Safety Modul state from Object SSTA (Drive-Parameter) ............... %s   ************ $StateName " $actual

   #   TlPrint "  SM Status Bit8-11  = X : Modulstate : ($actState) $StateName"
   #
   #   if { ($actual & 0x100) == 0x1000 }     { TlPrint "  SM Status Bit12    = 1 : Safety IO Fault"}
   #   if { ($actual & 0x200) == 0x2000 }     { TlPrint "  SM Status Bit13    = 1 : Safety Violation Fault"}
   #   if { ($actual & 0x400) == 0x4000 }     { TlPrint "  SM Status Bit14    = 1 : Safety Configuration Fault"}
   #   if { ($actual & 0x800) == 0x8000 }     { TlPrint "  SM Status Bit15    = 1 : Safety Module Internal Fault"}
}

#----------------------------------------------------------------------------------------------------
proc doPrintRefTyp { Typ {MitTlError 1}} {
   # Abkürzungen:
   # REF+: Suchfahrt in pos. Richtung
   # REF-: Suchfahrt in neg. Richtung
   # inv: Drehrichtung vor Ausfahren invertieren
   # nicht inv: Drehrichtung vor Ausfahren nicht invert.
   # außerhalb: Indexpuls/Abstand außerhalb Schalt.
   # innerhalb: Indexpuls/Abstand innerhalb Schalt.

   set result 1
   set text "0"
   switch -- $Typ {
      1  { set text "RefTyp  1: to LIMN plus Index" }
      2  { set text "RefTyp  2: to LIMP plus Index" }
      7  { set text "RefTyp  7: pos dir to Ref, plus Index, inv, outer" }
      8  { set text "RefTyp  8: pos dir to Ref, plus Index, inv, inner" }
      9  { set text "RefTyp  9: pos dir to Ref, plus Index, not inv, inner" }
      10 { set text "RefTyp 10: pos dir to Ref, plus Index, not inv, outer" }
      11 { set text "RefTyp 11: neg dir to Ref, plus Index, inv, outer" }
      12 { set text "RefTyp 12: neg dir to Ref, plus Index, inv, inner" }
      13 { set text "RefTyp 13: neg dir to Ref, plus Index, not inv, inner" }
      14 { set text "RefTyp 14: neg dir to Ref, plus Index, not inv, outer" }
      17 { set text "RefTyp 17: to LIMN" }
      18 { set text "RefTyp 18: to LIMP" }
      23 { set text "RefTyp 23: pos dir to Ref, inv, outer" }
      24 { set text "RefTyp 24: pos dir to Ref, inv, inner" }
      25 { set text "RefTyp 25: pos dir to Ref, not inv, inner" }
      26 { set text "RefTyp 26: pos dir to Ref, not inv, outer" }
      27 { set text "RefTyp 27: neg dir to Ref, inv, outer" }
      28 { set text "RefTyp 28: neg dir to Ref, inv, inner" }
      29 { set text "RefTyp 29: neg dir to Ref, not inv, inner" }
      30 { set text "RefTyp 30: neg dir to Ref, outer inv, outer" }
      33 { set text "RefTyp 33: neg dir to Indexpulse" }
      34 { set text "RefTyp 34: pos dir to Indexpulse" }
      35 { set text "RefTyp 35: Massetzen" }
      default { if { $MitTlError } { TlError "invalid homing methode $Typ" }
         set result 0
      }
   }
   if { $text != "0" } {
      TlPrint ""
      TlPrint "$text"
   }

   return $result

} ;# doPrintRefTyp

#-----------------------------------------------------------------------
# Object innerhalb einer WaitTime im Zeitabstand PrintTime ausgeben
#-----------------------------------------------------------------------
proc doPrintObjectIntoWaitTime { WaitTime Object PrintTime } {

   set StartTime [clock clicks -milliseconds]
   set RefTime   [clock clicks -milliseconds]

   while { 1 } {
      if { [expr [clock clicks -milliseconds] - $StartTime ] >= $WaitTime } {
         break
      }
      if { [expr abs( $RefTime - [clock clicks -milliseconds])] >= $PrintTime } {
         doPrintObject $Object
         set RefTime [clock clicks -milliseconds]
      }
   }
}

#DOC----------------------------------------------------------------
# ----------HISTORY----------
# WANN   WER   WAS
# 161110 rothf proc created
#
#DESCRIPTION
# print out required values in ini file format
#END----------------------------------------------------------------
proc doPrintIniFileValues {} {
   global ActDev

   doLoginLevelTest

   TlPrint ""
   TlPrint "Controller parameters"
   TlPrint "KPN=[doReadModObject CTRL1.KPN]"
   TlPrint "TNN=[doReadModObject CTRL1.TNN]"
   TlPrint "KPP=[doReadModObject CTRL1.KPP]"
   TlPrint "TAUNREF=[doReadModObject CTRL1.TAUNREF]"
   TlPrint "CURRFOL=[doReadModObject CTRL1.CURRFOL]"
   TlPrint "KFPP=[doReadModObject CTRL1.KFPP]"
   TlPrint "NOTCH1D=[doReadModObject CTRL1.NOTCH1D]"
   TlPrint "NOTCH1F=[doReadModObject CTRL1.NOTCH1F]"
   TlPrint "NOTCH1BW=[doReadModObject CTRL1.NOTCH1BW]"
   TlPrint "NOTCH2D=[doReadModObject CTRL1.NOTCH2D]"
   TlPrint "NOTCH2F=[doReadModObject CTRL1.NOTCH2F]"
   TlPrint "NOTCH2BW=[doReadModObject CTRL1.NOTCH2BW]"
   TlPrint "SPEEDOSUPDAMP=[doReadModObject CTRL1.SPEEDOSUPDAMP]"
   TlPrint "SPEEDOSUPDLAY=[doReadModObject CTRL1.SPEEDOSUPDLAY]"
   TlPrint "KFRIC=[doReadModObject CTRL1.KFRIC]"

   TlPrint ""
   TlPrint "ADC alignment"
   TlPrint "IuOffset=[doReadModObject  paramManu_uiIuOffset]"
   TlPrint "IvOffset=[doReadModObject  paramManu_uiIvOffset]"
   TlPrint "SinCosGain=[doReadModObject  paramManu_uiSinCosGain]"
   TlPrint "SinOffset=[doReadModObject  paramManu_uiSinOffset]"
   TlPrint "CosOffset=[doReadModObject  paramManu_uiCosOffset]"
   TlPrint "SinCosGain2=[doReadModObject  paramManu_uiSinCosGain2]"
   TlPrint "SinOffset2=[doReadModObject  paramManu_uiSinOffset2]"
   TlPrint "CosOffset2=[doReadModObject  paramManu_uiCosOffset2]"
   TlPrint "Iu_usr_sc=[doReadModObject  paramManu_uiIu_usr_sc]"
   TlPrint "I_sc_uv=[doReadModObject  paramManu_uiI_sc_uv]"

}

#DOC----------------------------------------------------------------
# print descriptions of all active alarmbits in a given alarm parameter ALR1 .. ALR5
# example:
#   PrintAlarm 1 0x0028
#   SRA  = Frequency reference reached
#   LCA2 = Life Cycle Alarm 2 alarm
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 210314 ockeg proc created
#
#END----------------------------------------------------------------
proc PrintAlarm { alr_no alr_value } {
   global theAltiLabParameterFile

   if { ($alr_no < 1) || ($alr_no > 8) } {
      TlError "only ALR No 1 to 5 are allowed"
      return 0
   }

   set firstentry [expr 16*($alr_no - 1) + 1]
   set mask 0x0001

   if {  $alr_value == "????"} {
      TlPrint "  not a correct alarm information"
   } else {
      for {set i 0} {$i <= 15} {incr i} {
         set entry [expr $firstentry + $i]
         if {[expr $alr_value & $mask] != 0 } {
            # get attribute "description" of enum entry of list "ALR"
            set     SearchList {}
            lappend SearchList device
            lappend SearchList [list dataobjectcollection [list Attr defaultgroupname="Functions"]]
            lappend SearchList choicetypelist
            lappend SearchList [list choicetype [list Attr id="ALR"]]
            lappend SearchList [list choice     [list Attr value=$entry]]
            set nodevalue   [ParseXmlFile $theAltiLabParameterFile $SearchList]
            if { [string length $nodevalue] > 0  } {
               set description [ParseXmlFile $theAltiLabParameterFile $SearchList "description"]
               TlPrint "  active alarm %-4s = %s" $nodevalue $description
            } else {
               return 0
            }
         }
         set mask [expr $mask << 1]
      }
   }

   return 1

}

#-----------------------------------------------------------------------
# Print extended informations (longnames) of an Object and its value.
# If Value is empty string, read the actual Value via modbus out of the drive
#   TCL>  ? doPrintObjectEx PFM
#   MOD-Read (#3): PFM (Pipe fill : Mode) Value=0 (NO=Pipe fill disabled)
#   Output : 0
#
# If Value is given, print out the longname and all allowed values out of database:
#   TCL>  ? doPrintObjectEx PFM NO
#   XML info: PFM (Pipe fill : Mode)
#     0 NO    Pipe fill disabled
#     1 HOR   Horizontal pipe fill is enabled
#
# History:
# 070514 ockeg 	created
# 130614 ockeg 	print all valid enum_values out of database
#-----------------------------------------------------------------------
proc doPrintObjectEx { Obj {Value ""} } {
   global theAltiLabParameterFile

   if { $Value == "" } {
      #read Obj via Modbus
      set read_channel [format "MOD-Read (#%d):" [GetDevAdr MOD]]
      set Value [ModTlRead $Obj]
      if { $Value == "" } {
         TlError "$read_channel no response Object: $Obj "
         return  0
      } else {
         set enum_name  [Enum_Name $Obj $Value]
         set enum_value $Value
      }

   } else {
      #just print out the database infos
      set read_channel "XML info:"
      if { [string index $Value 0 ] == "." } {
         set enum_name  [string range $Value 1 end]
         set enum_value [Enum_Value $Obj $Value]

      } elseif { [regexp {[A-Z]} [string index $Value 0 ]] } {
         set enum_name  $Value
         set enum_value [Enum_Value $Obj $Value]

      } elseif { [string is integer $Value] } {
         set enum_name  [Enum_Name $Obj $Value]
         set enum_value $Value

      } else {
         TlError "no valid Value given: $Value"
         return 0
      }
   }
   #TlPrint "enum_name=$enum_name"

   # get longname
   set     SearchList {}
   lappend SearchList device
   lappend SearchList [list dataobjectcollection [list Attr id=PARAM]]
   lappend SearchList dataobjectlist
   lappend SearchList [list dataobject [list Attr id=$Obj]]
   lappend SearchList longname
   set longname [ParseXmlFile $theAltiLabParameterFile $SearchList]
   #TlPrint "longname=$longname"

   # get choicetype
   set     SearchList {}
   lappend SearchList device
   lappend SearchList [list dataobjectcollection [list Attr id=PARAM]]
   lappend SearchList dataobjectlist
   lappend SearchList [list dataobject [list Attr id=$Obj]]
   lappend SearchList choicetype
   set choicetype [ParseXmlFile $theAltiLabParameterFile $SearchList]
   #TlPrint "choicetype=$choicetype"

   # get attribute "description" of enum entry x of list y
   if { [string length $choicetype] > 0 } {

      #print the received MOD value or the specified XML value
      set     SearchList {}
      lappend SearchList device
      lappend SearchList [list dataobjectcollection [list Attr defaultgroupname="Functions"]]
      lappend SearchList choicetypelist
      lappend SearchList [list choicetype [list Attr id=$choicetype]]
      lappend SearchList [list choice     [list Attr value=$enum_value]]
      #set nodevalue   [ParseXmlFile $theAltiLabParameterFile $SearchList]
      #TlPrint "nodevalue= \"$nodevalue\""
      set description [ParseXmlFile $theAltiLabParameterFile $SearchList "description"]
      #TlPrint "attribute= \"$description\""

      TlPrint "%s %s (%s) Value=%d (%s=%s)" \
         $read_channel $Obj $longname $enum_value $enum_name $description

      if { [string first "XML" $read_channel] == 0 } {

         #read from XML: print out all valid choicetypes
         for {set v 0} {$v <= 512} {incr v} {
            set enum_name [Enum_Name $Obj $v]
            set     SearchList {}
            lappend SearchList device
            lappend SearchList [list dataobjectcollection [list Attr defaultgroupname="Functions"]]
            lappend SearchList choicetypelist
            lappend SearchList [list choicetype [list Attr id=$choicetype]]
            lappend SearchList [list choice     [list Attr value=$v]]
            set description [ParseXmlFile $theAltiLabParameterFile $SearchList "description"]
            if { [string length $description] == 0 } { continue }
            TlPrint "  %3d %-5s %s" $v $enum_name $description
         }
      }

   } else {
      # no choicetype: print only value
      TlPrint "%s %s (%s) Value=0x%04X (%d)" \
         $read_channel $Obj $longname $enum_value $enum_value
   }

   return  $Value

}

#DOC----------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 251113 todet proc created
# 020415 serio set Mask for DBGF
# 210415 serio add reset
# 110615 serio add MODE0 param
#
#END----------------------------------------------------------------
proc doPrintFaultInfo {} {
   global INFM_COUNTER
   TlPrint "----------- Fault Info ----------------"

   set ActFlt         [ModTlRead "DP0" 1]
   set ActFltName     [Enum_Name "DP0" $ActFlt]
   set ActFltParam    [Param_Index $ActFltName 1]
   set ActFltLongname [GetListEntryLFT $ActFlt]
   TlPrint " Actual fault DP0 : $ActFltLongname"
   set hmis [ModTlRead HMIS 1]
   TlPrint " Drive state..(HMIS)............... %d (%s)" $hmis [Enum_Name HMIS $hmis]

   if {$ActFltParam != ""} {
      set ActFltInfo [ModTlRead $ActFltParam 1]
      TlPrint " Add info in $ActFltName : %d" $ActFltInfo
   }

   if { $ActFltName == "ILF" } {
      set IlfInfo [ModTlRead "ILF1" 1]
      switch $IlfInfo {
         1 { set IlfText "Internal communication interruption with the drive" }
         2 { set IlfText "Hardware fault detected" }
         3 { set IlfText "Error found in the EEPROM checksum" }
         4 { set IlfText "EEPROM" }
         5 { set IlfText "Flash memory" }
         6 { set IlfText "RAM memory" }
         7 { set IlfText "NVRAM memory" }
         8 { set IlfText "Analog input" }
         9 { set IlfText "Analog output" }
         10 { set IlfText "Logic input" }
         11 { set IlfText "Logic output" }
         101 { set IlfText "Unknown card" }
         102 { set IlfText "Exchange fault detected on the drive internal bus" }
         103 { set IlfText "Time out on the drive internal bus (500 ms)" }
         default { set IlfText "unknown" }
      }
      TlPrint " Add info in ILF1 : %d = %s" $IlfInfo $IlfText
   }

   #DFx Status parameters giving faults states
   set DFlist [ModTlReadBlock DF1 10 1]   ;#DF1,DF2,DF3,DF4,DF5,DF6,DF8,DF9,DF10.
   #1st list from DF1 -> DF6
   for {set i 0} {$i < 6} {incr i} {
      if {$i == 6} {
         continue                         ;#Object DF7 not available
      }

      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         if {[ catch {set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]}] != 0} {
            set dfx "???? "
         }
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status parameters DF1 .. DF6  ..... 0x%s" $dfxlist

   if {[GetDevFeat "Fortis"]} {
      TlPrint " I/O Cassette Version TBHT ......... [format %04X  [ModTlRead TBHT]]"
   }

   #2nd list from DF8 -> DF10
   unset dfxlist
   for {set i 7} {$i < 10} {incr i} {
      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         if {[ catch {set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]}] != 0} {
            set dfx "???? "
         }
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status parameters DF8 .. DF10 ..... 0x%s" $dfxlist
   #for DFx parameter there are no longnames in database

   if { ![GetDevFeat "Altivar"]} {      
      #Warning status word
      doPrintWarnings
      #Print debug informations
      doPrintDebug      
   }     
 

 

   if { $ActFltName == "INFM" } {
      if {![info exists INFM_COUNTER]} {set INFM_COUNTER 0}
      incr INFM_COUNTER
   }
}

#-----------------------------------------------------------------------
proc doPrintWarnings {  } {

   TlPrint "----------- Warning Info ----------------"

   set wr [ModTlRead WR1]
   if { $wr == "" } { return }
   set wr [format "0x%04X" $wr]
   TlPrint " Warning status WR1 ............... %s" $wr
   if { $wr & 0x0001 } { TlPrint "  Warning Bit0 : Impossible to read EEPROM calibration area"}
   if { $wr & 0x0002 } { TlPrint "  Warning Bit1 : Drive can not be identified"}
   if { $wr & 0x0004 } { TlPrint "  Warning Bit2 : Invalid option is connected to the drive"}
   if { $wr & 0x0008 } { TlPrint "  Warning Bit3 : Hardware init error"}
   if { $wr & 0x1000 } { TlPrint "  Warning Bit12 : Invalid customer configuration parameter set 0"}
   if { $wr & 0x2000 } { TlPrint "  Warning Bit13 : Invalid customer configuration parameter set 1"}
   if { $wr & 0x4000 } { TlPrint "  Warning Bit14 : Invalid customer configuration parameter set 2"}
   if { $wr & 0x8000 } { TlPrint "  Warning Bit15 : Invalid customer configuration parameter set 3"}

   #Alarm registers
   set ALRlist [ModTlReadBlock ALR1 8 1] ;#ALR1,ALR2,ALR3,ALR4,ALR5,ALR6,ALR7,ALR8
   for {set i 0} {$i < 8} {incr i} {
      set alrx [lindex $ALRlist $i]
      if { [string is integer $alrx] } {
         if {[ catch {set alrx [format "%04X " [expr $alrx & 0x0000FFFF]]}] != 0} {
            set alrx "???? "
         }
      } else {
         set alrx "0000 "
      }
      append alrxlist $alrx
   }
   TlPrint " Alarm registers ALR1 .. ALR8  ..... 0x%s" $alrxlist
   for {set i 1} {$i <= 8} {incr i} {
      if {[lindex $alrxlist [expr $i-1]] == "????"} {
         PrintAlarm $i [format "%s" [lindex $alrxlist [expr $i-1]]]  ;# print longnames out of database
      } else {
         PrintAlarm $i [format "0x%s" [lindex $alrxlist [expr $i-1]]]  ;# print longnames out of database
      }
   }

}

#-----------------------------------------------------------------------
# get one entry of LFT list (last fault)
proc GetListEntryLFT { listentry_lft  } {
   global theAltiLabParameterFile
   global cmd_XML_Filename

   # get attribute "description" of entry listentry_lft of list LFT
   set     SearchList {}
   lappend SearchList device
   lappend SearchList [list dataobjectcollection [list Attr defaultgroupname="Functions"]]
   lappend SearchList choicetypelist
   lappend SearchList [list choicetype [list Attr id="LFT"]]
   lappend SearchList [list choice     [list Attr value="$listentry_lft"]]
   set cmd_XML_Filename ""
   set nodevalue   [ParseXmlFile $theAltiLabParameterFile $SearchList]
   #TlPrint "nodevalue=$nodevalue"
   set description [ParseXmlFile $theAltiLabParameterFile $SearchList "description"]
   #TlPrint "Attribute description=$description"
   return [format "%-4s (%-3d) %s" $nodevalue $listentry_lft $description]

}

#-----------------------------------------------------------------------
#  Read descriptions of variable-bits from BitTable.txt
#  and print if bit is set
#
#
# ----------HISTORY----------
# when   who   what
# 280211 todet file created
#-----------------------------------------------------------------------
proc PrintActiveBits {objString  value} {

   global mainpath globAbbruchFlag theLXMObjHashtable theLXMVARHashtable errorInfo

   set theBitTablePath "$mainpath/ObjektDB/BitTable.txt"

   catch {

      # Löse Parameterstring in Index und Subindex auf

      # [string match '[0-9]' [string index $idx 0]]
      if [regexp {[0-9]+\.[0-9]+} $objString] {
         # numerische Uebergabe, z.B. "11.9"
         set objList [split $objString .]
         set idx [lindex $objList 0]
         set six [lindex $objList 1]
      } else {
         if { [string first "." $objString ] > 0 } {
            # Umwandlung des objString's durch Hashtable in Index/SubIndex
            if { [catch { set index $theLXMObjHashtable($objString) }]  != 0 } {
               TlError "TCL-Fehlermeldung: $errorInfo : Objekt: $objString"
               return 0
            }
         } else {
            # Umwandlung des objString's durch Hashtable in Index/SubIndex
            if { [catch { set index $theLXMVARHashtable($objString) }]  != 0 } {
               TlError "TCL-Fehlermeldung: $errorInfo : Objekt: $objString"
               return 0
            }
         }

         set idx [lindex [split $index .] 0]
         set six [lindex [split $index .] 1]
      }

      # Merker für ausgegebene Bits zurücksetzen
      set PrintedBits {}
      set OutputArray {}

      if {![file exists $theBitTablePath]} {CreateBitTable}

      if [file exists $theBitTablePath] {

         set file [open $theBitTablePath r]

         while { [gets $file line] >= 0 } {

            if {[CheckBreak] == 1} {break}
            if {$globAbbruchFlag} {break}

            # Wenn Zeile mit # beginnt oder leer ist -> überspringen
            if {$line == ""} {continue}
            if {[string first "#" $line 0] == 0} {continue}

            # Zeile aufteilen
            set SeperatedFields [split $line "|"]
            # Index  Inhalt
            #
            #  0     Index
            #  1     Subindex
            #  2     Bit-Bereich als Text
            #  3     StartBit
            #  4     StopBit
            #  5     Kommentar

            #Falls Index oder Subindex nicht passen -> nächste Zeile
            if {([lindex $SeperatedFields 0] != $idx) || ([lindex $SeperatedFields 1] != $six)} {continue}

            # Informationen auslesen
            set StartBit [lindex $SeperatedFields 3]
            set StopBit [lindex $SeperatedFields 4]
            set Comment [lindex $SeperatedFields 5]

            #Teste ob Information zum Bit schon ausgegeben wurde
            set BitAlreadyShown 0
            foreach Bit $PrintedBits {
               if {( $Bit >= $StartBit ) && ( $Bit <= $StopBit ) } {set BitAlreadyShown 1}
            }
            if {$BitAlreadyShown == 1} {continue}

            #Speichere als ausgegebene Bits
            for {set Bit $StartBit} {$Bit <= $StopBit} {incr Bit} {
               lappend PrintedBits $Bit
            }

            # Unterscheidung ob einzelnes Bit oder mehrere Bits zusammengefasst
            if {$StartBit == $StopBit} {
               set Range 1
            } else {
               set Range [expr $StopBit - $StartBit +1]
            }

            # Maske in der Größe der Bitbreite (Range) generieren
            set Mask 0
            for {set i 0} {$i < $Range} {incr i} {
               set Mask [expr $Mask << 1]
               set Mask [expr $Mask | 1]
            }

            # Unterscheidung ob einzelnes Bit oder mehrere Bits zusammengefasst
            if {$StartBit == $StopBit} {
               if {[expr [expr $value >> $StartBit] & $Mask] != 0} {
                  lappend OutputArray "   Bit  $StartBit = 1 ($Comment)"
                  #TlPrint "   Bit $StartBit = 1 ($Comment)"
               }
            } else {
               if {[expr [expr $value >> $StartBit] & $Mask] != 0} {
                  lappend OutputArray "   Bits $StartBit..$StopBit = [expr [expr $value >> $StartBit] & $Mask] ($Comment)"
                  #TlPrint "   Bits $StartBit..$StopBit = [expr [expr $value >> $StartBit] & $Mask]
                  # ($Comment)"
               }
            }

         } ;# while

         close $file

         if {[llength $OutputArray] > 0} {

            set PosEqualMax 0
            foreach Line $OutputArray {
               # Suche "=" mit dem größten Offset
               if {[string first "=" $Line 0] > $PosEqualMax} {set PosEqualMax [string first "=" $Line 0]}
            } ;#Foreach

            foreach Line $OutputArray {
               set PosEqual [string first "=" $Line 0]
               set FillSpace ""
               #Fehlenden Platz mit Leerzeichen füllen
               for {set i $PosEqual} {$i < $PosEqualMax} {incr i} {
                  set FillSpace "$FillSpace "
               }
               # Ausgabe mit "=" in gleichen Abständen
               TlPrint "%s%s=%s" [string range $Line 0 [expr $PosEqual -1]] $FillSpace [string range $Line [expr $PosEqual +1] [string length $Line]]
            } ;#Foreach

         } ;#If

      } ;# if file exists

   } ;# catch

}  ;#PrintActiveBits

#-----------------------------------------------------------------------
#  Descriptions of variable-bits are stored in the Twinalyzer-comments
#  without a defined formating!
#  CreateBitTable generates a formated .txt file with variable-bits and
#  their discription out of the oli_twina.txt File.
#
#
#
# ----------HISTORY----------
# when   who   what
# 280211 todet file created
#-----------------------------------------------------------------------

proc CreateBitTable { } {

   global mainpath globAbbruchFlag

   set theBitTablePath "$mainpath/ObjektDB/BitTable.txt"
   set theTwinaObjectList "$mainpath/ObjektDB/oli_twina.txt"
   if [file exists $theTwinaObjectList] {

      set file [open $theTwinaObjectList r]

      set theBitTable [open $theBitTablePath w]

      puts  $theBitTable "#############################################################"
      puts  $theBitTable "# Verwendung der einzelnen Bits der LXM32 Variablen         #"
      puts  $theBitTable "#                                                           #"
      puts  $theBitTable "# File automatisch aus oli_twina.txt generiert              #"
      puts  $theBitTable "#                                                           #"
      puts  $theBitTable "#############################################################"
      puts  $theBitTable ""
      puts  $theBitTable "idx|sidx|bit text|bit start|bit end|description"

      while { [gets $file line] >= 0 } {

         if {[CheckBreak] == 1} {break}
         if {$globAbbruchFlag} {break}

         # Zeilen die nicht mit einer Parameteradresse beginnen überspringen
         if {[string first \" $line 0] == 0} {continue}

         # Finde den Kommentar (begrenzt durch "")
         set CommentStart [expr [string first \" $line 0] +1]
         set CommentEnd [expr [string first \" $line $CommentStart] -1]

         #Parameteradresse zwischen Zeilenanfang und "
         set Parameter [string range $line 0 $CommentStart]
         #Kommentar innerhalb ""
         set line [string range $line $CommentStart $CommentEnd]

         #Teile $Parameter in Zeilen (Format der Adressen ist "idx,sidx,")
         set SeperatedLines [split $Parameter ","]

         #Überspringen, falls Index oder Subindex keine Zahlen enthalten
         if {![string is integer [lindex $SeperatedLines 0]] || ([lindex $SeperatedLines 0] == "")} {continue}
         if {![string is integer [lindex $SeperatedLines 1]] || ([lindex $SeperatedLines 1] == "")} {continue}

         # Erster Argument = Index, zweites Argument = Subindex
         set Index [lindex $SeperatedLines 0]
         set Subindex [lindex $SeperatedLines 1]

         # Teile den Kommentar in Zeilen
         set SeperatedLines [split $line "|"]

         # Zeilen suchen, die mit "Bit" beginnen
         set BitComments {}
         foreach CommentLine $SeperatedLines {
            if {[string first "Bit" $CommentLine 0] == 0} {
               lappend BitComments $CommentLine
            }
         }

         if {[llength $BitComments] == 0} {continue}

         puts  $theBitTable ""
         puts  $theBitTable "######### idx:$Index sidx:$Subindex #########"

         set BitArray {}
         set DescriptionArray {}

         set BitOutput {}
         set DescriptionOutput {}
         set ValueOutput {}
         set BitCommentBuffer ""
         set CommentInNextLine 0

         # Gehe die einzelnen Kommentarzeilen durch
         foreach CommentLine $SeperatedLines {

            # Leerzeilen überspringen
            if {$CommentLine == ""} {continue}

            #Konvertiere Umlaute und Sonderzeichen
            regsub -all "ä" $CommentLine "ae" CommentLine
            regsub -all "ö" $CommentLine "oe" CommentLine
            regsub -all "ü" $CommentLine "ue" CommentLine
            regsub -all "ß" $CommentLine "ss" CommentLine
            regsub -all "²" $CommentLine "2" CommentLine
            regsub -all "³" $CommentLine "3" CommentLine
            regsub -all "µ" $CommentLine "u" CommentLine

            if {[string first "Bit" $CommentLine 0] != 0} {
               if {$CommentInNextLine == 0} {
                  continue
               }
            } else {
               if {$CommentInNextLine == 1} {
                  set CommentInNextLine 0
                  puts  $theBitTable "$Index|$Subindex|$BitText|$StartBit|$StopBit|$BitCommentBuffer"
                  set BitCommentBuffer ""
               }
            }

            # Nur nach Bits suchen, wenn aktuelle Zeile nicht zum Kommentar der vorherigen gehört
            if {$CommentInNextLine == 0} {

               # Falls "Bits" -> erstes Zeichen an Pos 4, falls "Bit" -> erstes Zeichen an Pos 3
               if {[string first "Bits" $CommentLine 0] == 0} {
                  set BitOrBits "Bits"
                  set Offset 4
               } else {
                  set BitOrBits "Bit"
                  set Offset 3
               }

               # Formatierung herausfinden
               set RangeOrSingle "Single"
               set Dot 0
               set Hyphen 0
               set Arrow 0
               set EqualSign 0
               set Number ""
               set StartBit ""
               set StopBit ""
               set JustComment 0
               set BitText ""

               # Nacheinander die einzelnen Zeichen des Kommentars prüfen
               for {set Pointer $Offset} {$Pointer < [string length $CommentLine ]} {incr Pointer} {
                  if {[CheckBreak] == 1} {break}
                  set Char [string range $CommentLine $Pointer $Pointer]

                  if {$Char == "-"} {set Char "Hyphen"}

                  switch -exact $Char {

                     " " {
                        #Wenn Leerzeichen und Start und StopBit schon gefunden -> fertig
                        if {( $StartBit != "") && ( $StopBit != "")} {
                           break
                        } else {
                           continue
                        }
                     }
                     "(" {
                        continue
                     }
                     ")" {
                        continue
                     }
                     "." {
                        # Wenn "." dann Bit-Bereich
                        set RangeOrSingle "Range"
                        set Dot 1
                     }
                     "," {
                        # Wenn "," dann Bit-Bereich
                        set RangeOrSingle "Range"
                        set Dot 1
                     }
                     "Hyphen" {
                        # Wenn "-" dann Bereich
                        if {$Dot == 0} {
                           set RangeOrSingle "Range"
                           set Hyphen 1
                        }
                     }
                     ">" {
                        # Wenn "-" und ">" dann Ende
                        if {$Hyphen == 1} {
                           set RangeOrSingle "Range"
                           set StopBit $StartBit
                           set Arrow 1
                           break
                        }
                     }
                     "=" {
                        # Wenn "=" dann Ende
                        set StopBit $StartBit
                        set RangeOrSingle "Single"
                        set EqualSign 1
                        break
                     }
                     ":" {
                        if {$RangeOrSingle == "Single"} { set StopBit $StartBit }
                        break
                     }
                     default {
                        # Falls Zahl -> Start oder Stop Bit
                        # Falls Text -> Ende
                        if {[string is integer $Char]} {
                           set Number $Char
                        } else {
                           if {$RangeOrSingle == "Single"} { set StopBit $StartBit }
                           if {$StartBit == ""} {set JustComment 1}
                           incr Pointer -1
                           break
                        }
                     }
                  } ;# switch

                  # Falls Zahl gefunden und noch kein Sonderzeichen entdeckt -> Zahl gehört zu
                  # StartBit
                  if {($Number != "") && ($Dot == 0) && ($Hyphen == 0)} {
                     set StartBit "$StartBit$Char"
                     set Number ""
                  }
                  # Falls Zahl gefunden und Sonderzeichen ausser "=" bereits entdeckt -> Zahl gehört
                  # zu StopBit
                  if {( $Number != "" ) && (($Dot != 0) || ($Hyphen != 0)) && ( $RangeOrSingle == "Range" )} {
                     set StopBit "$StopBit$Char"
                     set Number ""
                  }

               } ;#for (Chars in Comment)

               # Falls kein Bit beschrieben wird -> weiter
               if {$JustComment == 1} {continue}

               # Falls StopBit vor StartBit genannt -> vertauschen
               if {( $StartBit > $StopBit) && ( $RangeOrSingle == "Range" )} {
                  set Merker $StartBit
                  set StartBit $StopBit
                  set StopBit $Merker
               }

               # Text mit Informationen zu den Bits extrahieren (String-Anfang bis Pointer)
               set BitText [string range $CommentLine 0 [expr $Pointer -1]]
               # Leerzeichen entfernen
               regsub -all {[ ]} $BitText "" BitText
               # "Bit" bzw. "Bits" entfernen
               set BitText [string range $BitText $Offset $Pointer]

               # Wenn nach Angabe des Bits kein Kommentar folgt steht dieser warscheinlich in der
               # nächsten Zeile
               if {$Pointer >= [expr [string length $CommentLine ] -3]} {
                  set CommentInNextLine 1
               }
            } else {
               set Pointer -1
            } ;# if CommentInNextLine

            set BitComment [string range $CommentLine [expr $Pointer +1] [string length $CommentLine ]]

            # Entferne vorausgehende Leerzeichen
            for {set i 0} {([string first " " $BitComment 0] == 0) && ($i < 3)} {incr i} {
               set BitComment [string range $BitComment 1 [string length $BitComment ]]
            }

            if {$CommentInNextLine == 1} {
               set BitCommentBuffer "$BitCommentBuffer$BitComment; "
               continue
            } else {
               set BitCommentBuffer $BitComment
            }

            puts  $theBitTable "$Index|$Subindex|$BitText|$StartBit|$StopBit|$BitCommentBuffer"
            set BitCommentBuffer ""

         } ;# foreach CommentLine $SeperatedLines

         # Falls der Kommentar in der letzten Zeile war und die Schleife verlassen wurde -> anhängen
         if {$CommentInNextLine == 1} {
            set CommentInNextLine 0
            puts  $theBitTable "$Index|$Subindex|$BitText|$StartBit|$StopBit|$BitCommentBuffer"
            set BitCommentBuffer ""
         }

      } ;# while

      close $file
      close $theBitTable

   } ;# if file exists

}  ;#CreateBitTable

#-----------------------------------------------------------------------------------
#initalization of ShowBit from New_Mapping_V3.txt
#Storage of each word information in a global array
proc ShowBit_init {} {
   global ParamList libpath

   set StatusTXT  $libpath/New_Mapping_V3.txt
   set OpenStatus [open $StatusTXT]
   foreach line [split [read $OpenStatus] \n] {
      if {[lindex $line 3] == "word"} {
         set Param [lindex $line 0]
         set ParamList($Param) [list]
         #puts $Param
      }  elseif {[lindex $line 3] == "cons" \
            || [lindex $line 3] == "uInt" \
            || [lindex $line 4] == "uInt" \
            || [lindex $line 3] == "int" \
            || [lindex $line 4] == "int" \
            || [lindex $line 3] == "enum" \
            || [lindex $line 3] == "prod" \
            || [lindex $line 0] == "Code" \
            || [lindex $line 0] == "RS3" \
            || [lindex $line 0] == "Function" \
            || [lindex $line 0] == ""} {
         if {[info exists Param]} {
            unset Param
         }
      }  elseif {[info exists Param]} {
         set FirstElement [string trimleft [lindex $line 0] chars]
         set Restofline [lreplace $line 0 0]
         lappend ParamList($Param) "$FirstElement $Restofline"
      }
   }
   close $OpenStatus
}

#--------------------------------------------------------------------------
#Display information about parameter's bits on tcl4tower
#Can be called without argument, with the name of the wanted parameter
#or with the name and its value to display activ bits
proc ShowBit {{ParamName ""} {ParamValue ""}} {
   ShowBit_init
   while {1} {

      TlPrint "-----------------------------------------------"

      TlPrint ""
      if {$ParamName == ""} {
         TlPrint " 1 - Status of word"
         TlPrint " 2 - All word informations"
         TlPrint " X - Exit (End)"

         TlPrint ""

         set answer_func [TlInput "Menuepunkt" "" 0]

         TlPrint ""
         switch -regexp $answer_func {
            "1" {
               Print_STATUSWORD
            }
            "2" {
               Print_ALLWORDINFORMATIONS
            }
            "^[Xx]" {
               break   ;# Exit
            }

            default {
               TlPrint "wrong input"
            }
         }

      }  elseif {$ParamValue != ""} {

         Print_STATUSWORD $ParamName $ParamValue
         set ParamName ""
         set ParamValue ""
      }  else {
         Print_ALLWORDINFORMATIONS $ParamName
         set ParamName ""
      }

   }
}

#-------------------------------------------------------------------------
#display active bits of one parameters for a given value of parameter

proc Print_STATUSWORD {{Word ""} {Value ""}} {

   global ParamList

   if {$Word == ""} {

      set Word [TlInput "Word" 0 0]
      TlPrint ""

   }

   if {$Value== ""} {
      set Value [TlInput "Value" 0 0]
      TlPrint ""

   }

   set InitialValue $Value

   if {[info exists ParamList($Word)]} {
      set DisplayedBits 0

      for { set PosBit 0 } { $PosBit < 16 } { incr PosBit } {

         foreach Status $ParamList($Word) {
            set FirstElement [lindex $Status 0]
            set ThirdElement [lindex $Status 2]
            if {[expr (0x[format %X $Value] & 0x1) == 0x1] } {
               if {$ThirdElement != 0} {
                  if {$FirstElement == "Bit$PosBit"} {
                     TlPrint $Status
                     incr DisplayedBits
                  }
               }
            }  elseif {[expr (0x[format %X $Value] & 0x1) == 0x0]} {
               if {$ThirdElement == 0} {

                  if {$FirstElement == "Bit$PosBit"} {
                     TlPrint $Status
                     incr DisplayedBits
                  }
               }
            }
         }

         set Value [expr ($Value >> 1) ]
      }

      if {$DisplayedBits == 0 } {
         foreach Status $ParamList($Word) {
            TlPrint $Status
            TlPrint ""
            Print_STATUSWORD [lindex $Status 2] $InitialValue

         }
      }

   }  else {TlPrint "Wrong parameter - Doesn't exist" }

   TlPrint ""

}

#-----------------------------------------------------------------------------
#Display all information for a given parameter
proc Print_ALLWORDINFORMATIONS {{Word ""}} {
   global ParamList
   TlPrint ""

   if {$Word == ""} {

      set Word [TlInput "Word" 0 0]
   }
   TlPrint ""
   TlPrint ""
   if {[info exists ParamList($Word)]} {
      foreach Status $ParamList($Word) {

         TlPrint $Status
      }
   }  else {TlPrint "Wrong parameter - Doesn't exist" }

   TlPrint ""
}

proc PlotGraph { Xvalues  Y1values {Y2values {} } {Y3values {} } {Y4values {} } } {

   global UseGrid

   set Xlength [llength $Xvalues]
   set Y1length [llength $Y1values]
   set Y2length [llength $Y2values]
   set Y3length [llength $Y3values]
   set Y4length [llength $Y4values]

   set Line1Char "+"
   set Line2Char "*"
   set Line3Char "x"
   set Line4Char "~"

   set ZeroChar "0"
   set TopFrameChar "#"
   set SideFrameChar "|"

   set HGridChar "."
   set VGridChar "."

   set ScreenWidth 115
   set GridWidth 23
   set ScreenHeight 40
   set GridHeight 8

   if {![info exists UseGrid]} {
      set UseGrid 0
   }

   if {$Y2length == 0} {
      set Lines 1
   } elseif {$Y3length == 0} {
      set Lines 2
   } elseif {$Y4length == 0} {
      set Lines 3
   } else {
      set Lines 4
   }

   set TmpX [lsort -increasing -real $Xvalues]
   set Tmp1 [lsort -increasing -real $Y1values]

   set XMin [lindex $TmpX 0]
   set XMax [lindex $TmpX end]
   set Y1Min [lindex $Tmp1 0]
   set Y1Max [lindex $Tmp1 end]

   set Y2Min $Y1Min
   set Y3Min $Y1Min
   set Y4Min $Y1Min

   set Y2Max $Y1Max
   set Y3Max $Y1Max
   set Y4Max $Y1Max

   if {$Y2length != 0} {
      set Tmp2 [lsort -increasing -real $Y2values]
      set Y2Min [lindex $Tmp2 0]
      set Y2Max [lindex $Tmp2 end]
   }

   if {$Y3length != 0} {
      set Tmp3 [lsort -increasing -real $Y3values]
      set Y3Min [lindex $Tmp3 0]
      set Y3Max [lindex $Tmp3 end]
   }

   if {$Y4length != 0} {
      set Tmp4 [lsort -increasing -real $Y4values]
      set Y4Min [lindex $Tmp4 0]
      set Y4Max [lindex $Tmp4 end]
   }

   set TmpY [lsort -increasing -real [list $Y1Min $Y2Min $Y3Min $Y4Min $Y1Max $Y2Max $Y3Max $Y4Max]]
   set YMin [lindex $TmpY 0]
   set YMax [lindex $TmpY end]

   if {$Xlength != $Y1length} {
      TlPrint "X length and Y1 length unequal: $Xlength != $Y1length"
      return -1
   }

   if {( $Xlength != $Y2length ) && ( $Y2length != 0 )} {
      TlPrint "X length and Y2 length unequal: $Xlength != $Y2length"
      return -1
   }

   if {( $Xlength != $Y3length ) && ( $Y3length != 0 )} {
      TlPrint "X length and Y3 length unequal: $Xlength != $Y3length"
      return -1
   }

   if {( $Xlength != $Y4length ) && ( $Y4length != 0 )} {
      TlPrint "X length and Y4 length unequal: $Xlength != $Y4length"
      return -1
   }

   # draw scope frame
   for {set x -1} {$x <= $ScreenWidth} {incr x} {

      for {set y -1} {$y <= $ScreenHeight} {incr y} {
         if {($x == -1) || ($x == $ScreenWidth)} {
            set Screen($x,$y) $SideFrameChar
         } elseif {($y == -1) || ($y == $ScreenHeight)} {
            set Screen($x,$y) $TopFrameChar
         } elseif {(($x % $GridWidth) == 0) && $UseGrid} {
            set Screen($x,$y) $VGridChar
         } elseif {(($y % $GridHeight) == 0) && $UseGrid} {
            set Screen($x,$y) $HGridChar
         } else {
            set Screen($x,$y) " "
         }

      }

   }

   # draw zero line
   set y [expr int(((0 - $YMin) * ($ScreenHeight-1))/ ($YMax - $YMin) )]
   for {set x 0} {$x < $ScreenWidth} {incr x} {
      set Screen($x,$y) $ZeroChar
   }

   #   if {$Y1length != 0} {
   #      # draw Y1 data
   #      for {set x 0} {$x < $ScreenWidth} {incr x} {
   #         set point [expr ($Xlength * $x) /$ScreenWidth ]
   #         set y [expr int((([lindex $Y1values $point] - $YMin) * ($ScreenHeight-1))/ ($YMax -
   # $YMin) )]
   #         set Screen($x,$y) $Line1Char
   #      }
   #   }

   if {$Y1length != 0} {
      # draw Y1 data
      for {set x 0} {$x < $ScreenWidth} {incr x} {
         set point [expr ($Xlength * $x) /$ScreenWidth ]
         set y [expr int((([lindex $Y1values $point] - $YMin) * ($ScreenHeight-1))/ ($YMax - $YMin) )]
         set Screen($x,$y) $Line1Char
      }
   }

   if {$Y2length != 0} {
      # draw Y2 data
      for {set x 0} {$x < $ScreenWidth} {incr x} {
         set point [expr ($Xlength * $x) /$ScreenWidth ]
         set y [expr int((([lindex $Y2values $point] - $YMin) * ($ScreenHeight-1))/ ($YMax - $YMin) )]
         set Screen($x,$y) $Line2Char
      }
   }

   if {$Y3length != 0} {
      # draw Y3 data
      for {set x 0} {$x < $ScreenWidth} {incr x} {
         set point [expr ($Xlength * $x) /$ScreenWidth ]
         set y [expr int((([lindex $Y3values $point] - $YMin) * ($ScreenHeight-1))/ ($YMax - $YMin) )]
         set Screen($x,$y) $Line3Char
      }
   }

   if {$Y4length != 0} {
      # draw Y4 data
      for {set x 0} {$x < $ScreenWidth} {incr x} {
         set point [expr ($Xlength * $x) /$ScreenWidth ]
         set y [expr int((([lindex $Y4values $point] - $YMin) * ($ScreenHeight-1))/ ($YMax - $YMin) )]
         set Screen($x,$y) $Line4Char
      }
   }

   # Print on screen
   TlPrint ""
   for {set y $ScreenHeight} {$y >= -1} {incr y -1} {

      set Line ""
      for {set x -1} {$x <= $ScreenWidth} {incr x} {
         set Line [format "%s%s" $Line $Screen($x,$y)]
      }
      TlPrint $Line
   }

   TlPrint [format "X Scaling: % 12.3f to % 12.3f" $XMin $XMax]
   TlPrint [format "Y Scaling: % 12.3f to % 12.3f" $YMin $YMax]
   TlPrint ""

   if {$Y1length != 0} {
      # draw Y1 legend
      TlPrint [format "Graph 1 ($Line1Char): Min=% 12.3f Max=% 12.3f" $Y1Min $Y1Max]
   }

   if {$Y2length != 0} {
      # draw Y1 legend
      TlPrint [format "Graph 2 ($Line2Char): Min=% 12.3f Max=% 12.3f" $Y2Min $Y2Max]
   }

   if {$Y3length != 0} {
      # draw Y1 legend
      TlPrint [format "Graph 3 ($Line3Char): Min=% 12.3f Max=% 12.3f" $Y3Min $Y3Max]
   }

   if {$Y4length != 0} {
      # draw Y1 legend
      TlPrint [format "Graph 4 ($Line4Char): Min=% 12.3f Max=% 12.3f" $Y4Min $Y4Max]
   }

   TlPrint ""

}

#-----------------------------------------------------------------
# return full name of corresponding values in list from objects
#  CCC and CRC:
#  Bit0 = 1 :  Terminal board
#  Bit1 = 1 :  Local keypad
#  Bit2 = 1 :  Deported keypad
#  Bit3 = 1 :  Modbus
#  Bit4 :      Reserved
#  Bit5 :      Reserved
#  Bit6 = 1 :  CANopen
#  Bit7 = 1 :  Terminal up-Down speed
#  Bit8 = 1 :  Deported keypad up-down speed
#  Bit9 = 1 :  COM option board
#  Bit10 = 1 : APP option board
#  Bit11 = 1 : Embedded Ethernet
#  Bit12 :     Reserved
#  Bit13 :     Reserved
#  Bit14 = 1 : Indus
#  Bit15 = 1 : PowerSuite
#
# ----------HISTORY----------
# When   Who   What
# 300914 weiss proc created
#-----------------------------------------------------------------
proc GetCDFRchannel { value } {
   set value [format %#06x $value]

   switch $value {
      "0x0001" { return "Terminal board" }
      "0x0002" { return "Local keypad" }
      "0x0004" { return "Deported keypad" }
      "0x0008" { return "Modbus" }
      "0x0010" { return "Reserved" }
      "0x0020" { return "Reserved" }
      "0x0040" { return "CANopen" }
      "0x0080" { return "Terminal up-Down speed" }
      "0x0100" { return "Deported keypad up-down speed" }
      "0x0200" { return "COM option board" }
      "0x0400" { return "APP option board" }
      "0x0800" { return "Embedded Ethernet" }
      "0x1000" { return "Reserved" }
      "0x2000" { return "Reserved" }
      "0x4000" { return "Indus" }
      "0x8000" { return "PowerSuite" }
      default { TlError "invalid value $value" }
   }
};#GetCDFRchannel

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Format TTId to be print in blue in html log report
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 240315 serio    Proc created
#END------------------------------------------------------------------------------------------------

proc Format_TTId {{TTId ""}} {

   if {$TTId != "" && [string index $TTId 0] != "*"} { set TTId "*$TTId*" }
   return $TTId
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Print Debug informations
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 310315 serio    Proc created
# 010415 serio    Use doPrintModObject
#END------------------------------------------------------------------------------------------------

proc doPrintDebug {} {

   TlPrint "----------- Debug Info ----------------"
   set DBGF [doPrintModObject DBGF]

   if {[GetDevFeat "MVK"]} {
    TlPrint "NST1 : [TlRead NST1]"  
   }
	
   
   for {set i 0} {$i <= 15} {incr i} {

      if { $DBGF & [expr 1 << $i] } {

         switch $i {

            0 { TlPrint "Bit$i : FM_ACCESS_ALL is set to 1 " }
            1 { TlPrint "Bit$i : ATVD : CPU Time logging is set to 1 " }
            2 { TlPrint "Bit$i : UARTs : enable all modes is set to 1 " }
            3 { TlPrint "Bit$i : Avoid INF8 Fault is set to 1 " }
            4 { TlPrint "Bit$i : Avoid INF6 Fault is set to 1 " }
            5 { TlPrint "Bit$i : Ask Save Conf Log is set to 1 " }
            6 { TlPrint "Bit$i : Fan Command Inhibition is set to 1 " }
            7 { TlPrint "Bit$i : ILF inhibition is set to 1 " }
            8 { TlPrint "Bit$i : INFM inhibition is set to 1 " }
            9 { TlPrint "Bit$i : Stack Level is set to 1 " }
            10 { TlPrint "Bit$i : Allow all URES values in case of VCAL = 480T is set to 1 " }
            11 { TlPrint "Bit$i : INF2 inhibition is set to 1 " }
            12 { TlPrint "Bit$i : INF1 inhibition (topology check) " }
            13 { TlPrint "Bit$i : INFL inhibition " }
            14 { TlPrint "Bit$i : Reserved for Safety Module " }
            15 { TlPrint "Bit$i : Reserved is set to 1 " }

         }

      }

   }
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Print status information.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 050515 weiss    proc created
#END------------------------------------------------------------------------------------------------
proc doPrintStatusRegister {} {
   #STxx status registers
   set DFlist [ModTlReadBlock ST00 20 1]   ;#ST00 -> ST19
   #1st list from ST00 -> ST04
   for {set i 0} {$i <= 4} {incr i} {
      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status registers ST00 .. ST04 ..... 0x%s" $dfxlist

   #2nd list from ST05 -> ST9
   unset dfxlist
   for {set i 5} {$i <= 9} {incr i} {
      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status registers ST05 .. ST09 ..... 0x%s" $dfxlist

   #3rd list from ST10 -> ST14
   unset dfxlist
   for {set i 10} {$i <= 14} {incr i} {
      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status registers ST10 .. ST14 ..... 0x%s" $dfxlist

   #4th list from ST15 -> ST19
   unset dfxlist
   for {set i 15} {$i <= 19} {incr i} {
      set dfx [lindex $DFlist $i]
      if { [string is integer $dfx]  } {
         set dfx [format "%04X " [expr $dfx & 0x0000FFFF]]
      } else {
         set dfx "???? "
      }
      append dfxlist $dfx
   }
   TlPrint " Status registers ST15 .. ST19 ..... 0x%s" $dfxlist
   #for STxx parameter there are no longnames in database
};#doPrintStatusRegister

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Show Status Information on Load Device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080615 serio proc created
#END------------------------------------------------------------------------------------------------

proc ShowLoadStatus {} {
   global ActDev glb_AccessExcl glb_Error
   global ShowStatusOnline

   # for debug use:
   # print internal variables (if 1)
   set printDebugVariables 0

   if {$ShowStatusOnline} {
      TlError "******************recursion error in ShowStatus***************************"

      set ShowStatusOnline 0
      return 0
      #      if {[bp "Debugger at ShowStatus"]} {
      #         return 0
      #      }
   } else {
      set ShowStatusOnline 1
   }

   TlPrint "ShowLoadStatus Start********"
   #Only when the first load Read HERE aborts, not before!
   set glb_Error 0
   set wert [LoadRead STD.SIGSR]
   if {$glb_Error || $wert == ""} { return }
   TlPrint "SIGSR ext. Ueberwachungssignale.. : 0x%08X" $wert
   PrintActiveBits STD.SIGSR $wert

   set wert [LoadRead STD.WARNSIGSR]
   TlPrint "WARNSIGSR mit Fehlerkl. 0........ : 0x%08X" $wert
   if {[CheckBreak]} {return}
   PrintActiveBits STD.WARNSIGSR $wert

   set wert [LoadRead STD.STOPFAULT]
   TlPrint "STOPFAULT........................ : 0x%08X %s" $wert [GetErrorText $wert]
   if {[CheckBreak]} {return}

   if {$wert == 0x5501} {
      LoadWrite MAND.ACCESSLEVEL 0x54455354 ;#LoginLevelTest
      LoadWrite DIAG.MEMTYPE 0
      for {set Addr 0xFC00} {$Addr <= 0xFC1C} {incr Addr} {
         LoadWrite DIAG.MEMADR $Addr
         doPrintModLoadObject DIAG.MEMACCESS
      }
      doPrintModLoadObject CSbi_m_psDMA
   }

   if {[string first "(additional info = detailed error number)" [GetErrorText $wert] 0] != -1} {
      set wert [LoadRead STD.STOPFAULTINFO]
      set AddErrorText [GetErrorText $wert]
   } else {
      set wert [LoadRead STD.STOPFAULTINFO]
      set AddErrorText ""
   }

   set wert [LoadRead STD.STOPFAULTINFO]
   TlPrint "STOPFAULTINFO.................... : 0x%08X %s" $wert $AddErrorText
   if {[CheckBreak]} {return}

   set wert [LoadRead STD.LASTWARNING]
   TlPrint "LASTWARNING ..................... : 0x%08X %s" $wert [GetErrorText $wert]
   if {[CheckBreak]} {return}

   set errPara [LoadRead STD.INVALIDPARAM]
   if { ($errPara != 0) && ($errPara != "") } {
      set errObj [format "%d.%d" [expr ($errPara>>8)&0xFF] [expr32 ($errPara>>1)&0x7F]]
      set wert   [LoadRead $errObj]
      TlPrint "STD.INVALIDPARAM: $errObj .......... : 0x%08X (%d)" $wert $wert
   }
   if {[CheckBreak]} {return}

   set wert [LoadRead STD.AXISMODE]
   TlPrint "AXISMODE......................... : 0x%08X" $wert
   if {[CheckBreak]} {return}
   PrintActiveBits STD.AXISMODE $wert

   set wert [LoadRead STD.STATUSWORD]
   TlPrint "Statusword....................... : 0x%08X" $wert
   if {[CheckBreak]} {return}
   PrintActiveBits STD.STATUSWORD $wert

   set wert [LoadRead STD.ACTIONWORD]
   TlPrint "Actionword....................... : 0x%08X" $wert
   if {[CheckBreak]} {return}
   PrintActiveBits STD.ACTIONWORD $wert

   set wert [LoadRead STD.UZ]
   TlPrint "UZ............................... : 0x%08X (%d)" $wert $wert
   if {[CheckBreak]} {return}

   set wert [LoadRead PA.UKZMIN]
   TlPrint "UKZMIN........................... : 0x%08X (%d)" $wert $wert
   if {[CheckBreak]} {return}

   set wert [LoadRead PA.UKZMAX]
   TlPrint "UKZMAX........................... : 0x%08X (%d)" $wert $wert
   if {[CheckBreak]} {return}

   set wert [LoadRead DEVICE.DEVCONTROL]
   TlPrint "DEVCONTROL....................... : 0x%08X" $wert

   set wert [LoadRead MAND.ACCESSINFO]
   TlPrint "ACCESSINFO....................... : 0x%08X" $wert

   TlPrint "glb_AccessExcl................... : $glb_AccessExcl"

   set wert [LoadRead IO.DINGET]
   TlPrint "DINGET........................... : 0x%08X" $wert

   set wert [LoadRead IO.DOUTGET]
   TlPrint "DOUTGET.......................... : 0x%08X" $wert

   set wert [LoadRead IO.DPOWINGET]
   TlPrint "DPOWINGET........................ : 0x%08X" $wert
   if {[CheckBreak]} {return}

   set wert [LoadRead DEVICE.REFEXT]
   TlPrint "REFEXT........................... : 0x%08X" $wert

   set wert [LoadRead MONC.NACT]
   TlPrint "MONC.NACT........................ : 0x%08X" $wert

   # for debug use only
   # set variable on top of proc = 0 if not needed

   if {$printDebugVariables == 1} {

      LoadWrite MAND.ACCESSLEVEL 0x54455354 ;#LoginLevelTest

      TlPrint ""
      TlPrint "CAxfUmodeManPos"
      doPrintModLoadObject CAxfUmodeManPos_m_bitManPosStartUserChg
      doPrintModLoadObject CAxfUmodeManPos_m_uiManPosStartUser
      doPrintModLoadObject CAxfUmodeManPos_m_uiTimeTick1msFctCallSave
      doPrintModLoadObject CAxfUmodeManPos_m_uiManPosStateIntern
      doPrintModLoadObject CAxfUmodeManPos_m_uiAckData
      doPrintModLoadObject CAxfUmodeManPos_m_uiManPosStateInternSave
      doPrintModLoadObject CAxfUmodeManPos_m_uiManuStateCtrl
      doPrintModLoadObject CAxfUmodeManPos_m_uiManMotionInWork
      doPrintModLoadObject CAxfUmodeManPos_m_uiDelayTimeStartValue
      doPrintModLoadObject CAxfUmodeManPos_m_uiManPosStartReqForRestart

      TlPrint ""
      TlPrint "CAxf"
      doPrintModLoadObject CAxf_m_uiAxModeUser
      doPrintModLoadObject CAxf_m_uiUserActionWord
      doPrintModLoadObject CAxf_m_uiBergerAxisMode
      doPrintModLoadObject CAxf_m_ulBergerStatusWordBits
      doPrintModLoadObject CAxf_m_uiAxInternMode
      doPrintModLoadObject CAxf_m_sGlbFlags_bitUseProfileForHalt
      doPrintModLoadObject CAxf_m_eProfilGenType
      doPrintModLoadObject CAxf_m_bInternalFaultResetReq
      doPrintModLoadObject CAxf_m_bSupressSWLimError
      doPrintModLoadObject CAxf_m_sIntState
      doPrintModLoadObject CAxf_m_uMainloopValSaved
      doPrintModLoadObject CAxf_m_signal_uiMarkerBits
      doPrintModLoadObject CAxf_m_signal_uiEnableBits
      doPrintModLoadObject CAxf_m_sExtSigSupVis_uiActual
      doPrintModLoadObject CAxf_m_sExtSigSupVis_uiDirectSr
      doPrintModLoadObject CAxf_m_sExtSigSupVis_uiDirectAndEnaSr
      doPrintModLoadObject CAxf_m_sExtSigSupVis_uiDrvErrReactSigSr
      doPrintModLoadObject CAxf_m_sExtSigSupVis_uiRetrigger
      doPrintModLoadObject CAxf_m_sExtSigSupVis_bDisLimSwitchHandling
      doPrintModLoadObject CAxf_m_uiBreakMotionRequestMode
      doPrintModLoadObject CAxf_m_uiBreakMotionActiveMode
      doPrintModLoadObject CAxf_m_bReleaseBreakMotion
      doPrintModLoadObject CAxf_m_uiReqPosAdjustState
      doPrintModLoadObject CAxf_m_bStateOpEnaActiveMinOneTime

      TlPrint ""
      TlPrint "CSpg / Profile"
      doPrintModLoadObject Profile_m_sSpgDss_lVelTarg
      doPrintModLoadObject Profile_m_sSpgDss_uiMode
      doPrintModLoadObject Profile_m_sSpgDss_uiBreakRequest
      doPrintModLoadObject Profile_m_sSpgDss_bDisableRequest
      doPrintModLoadObject Profile_m_sSpgDss_uiMoveState
      doPrintModLoadObject Profile_m_sSpgDss_uiGlobalState
      doPrintModLoadObject Profile_m_sSpgDss_lVelActAbs
      doPrintModLoadObject Profile_m_sSpgDss_lVelActInclDirSign
      doPrintModLoadObject Profile_m_sSpgDss_lPosAct
      doPrintModLoadObject Profile_m_bReqMoveDirIsNegAtStandstill
      doPrintModLoadObject Profile_m_l_v_ist_abs
      doPrintModLoadObject Profile_m_uiInternStateAct
      doPrintModLoadObject Profile_m_uiInternStateNext
      doPrintModLoadObject Profile_m_lVelDiff
      doPrintModLoadObject Profile_m_l_v_soll_abs

      TlPrint ""
      TlPrint "Interface_to_drive_component"
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_uiOpmRequest
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_uiAxModeInt
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_lPosRef
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_uiPosRefRem
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_lSpdRef
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_bDoZeroClamp
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_uiBreakMotionActive
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_lPosAct
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_uiActionWordUser
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_uiStatus
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_uiUsrStateInfos
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_uiCmdRequest
      doPrintModLoadObject Interface_to_drive_component_FromDrvCtrl_bSelErrIsSet
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_lSpdFeed
      doPrintModLoadObject Interface_to_drive_component_ToDrvCtrl_lAccFeed

      TlPrint ""
      TlPrint "CSpe_QStopHalt"
      doPrintModLoadObject CSpe_QStopHalt_m_l_act
      doPrintModLoadObject CSpe_QStopHalt_m_l_actnew
      doPrintModLoadObject CSpe_QStopHalt_m_l_targetnew
      doPrintModLoadObject CSpe_QStopHalt_m_l_acc
      doPrintModLoadObject CSpe_QStopHalt_m_l_decc
      doPrintModLoadObject CSpe_QStopHalt_m_l_deccact
      doPrintModLoadObject CSpe_QStopHalt_m_ui_state
      doPrintModLoadObject CSpe_QStopHalt_m_ui_actionstat

   }

   doDisplayLoadErrorMemory

   if {[checkErrMemEntrys {0x782C} 2]} {
      # E782C=eSM: System Error:  Velocity evaluation error (values not identical)
      LoadWrite "SFTYA.MONITOROBJ"       0x00010A98
      doPrintModLoadObject "SFTYA.MONITOROBJ"
      LoadWrite "SFTYA.MONITOROBJ"       0x00010A9A
      doPrintModLoadObject "SFTYA.MONITOROBJ"

      LoadWrite "SFTYB.MONITOROBJ"       0x00010A98
      doPrintModLoadObject "SFTYB.MONITOROBJ"
      LoadWrite "SFTYB.MONITOROBJ"       0x00010A9A
      doPrintModLoadObject "SFTYB.MONITOROBJ"

   }

   TlPrint "ShowLoadStatus Stop**********"
   set ShowStatusOnline 0
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Read an object with Error Check over Modbus and displays the value for Load Device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080615 serio proc created
#END------------------------------------------------------------------------------------------------

proc doPrintModLoadObject { Object } {
   global ActDev DevAdr

   if {![info exists DevAdr($ActDev,Load)]} {
      TlError "Load not avaliable"
      return ""
   }

   set actual [ModTlReadForLoad $Object]
   if { $actual == "" } {
      TlError "Mod-Read(Adr(%s)) Object: $Object actual= $actual" $DevAdr($ActDev,Load)
      return  0
   } else {
      TlPrint "Mod-Read(Adr(%s)) Object: %-5s actual=0x%08X (%d)" \
         $DevAdr($ActDev,Load) $Object $actual $actual
      return  $actual
   }

}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Display error memory for Load device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080615 serio proc created
#END------------------------------------------------------------------------------------------------
proc doDisplayLoadErrorMemory {} {

   global ActDev DevAdr

   if {![info exists DevAdr($ActDev,Load)]} {
      TlError "Load not available"
      return ""
   }

   TlPrint "Error memory: --------"
   LoadWrite ERRADM.ERRMEMRESET 0  ;# Zeiger auf ersten Fehlerspeichereintrag
   doPrintModLoadObject ERRADM.ERRCHANGE
   doPrintModLoadObject ERRADM.POWONNUM
   set max [doPrintModLoadObject ERRADM.MEMNUM]
   TlPrint "Actual system time: 0x%08X" [LoadRead STD.OPHOURS]

   for { set i 1} { $i <= $max } { incr i } {
      # einen Fehlerspeichereintrag lesen (mit allen 11 Attributen)
      set errorlist {}

      set errorlist [ModTlReadBlockForLoad ERRMEM.ERRNUM 11]
      if { $i == 1 } {
         if { [lindex $errorlist 0] == 0 } {
            TlPrint "    error memory is empty"
            break
         } else {
            TlPrint "    ERRNUM    ERRCLASS  ERRTIME   ERRQUAL   ERRAMPCYC ERRAMPTIM ERRUZ     ERRNACT   ERRIACTDQ ERRTLE    ERRTCPU"
         }
      }
      #stop error output if entry is empty
      if { [lindex $errorlist 0] == 0 } {break}

      # alle Attribute des Eintrages formatiert ausgeben
      set szError [format "%2d: " $i]
      for { set j 0 } { $j<=10 } {incr j} {
         set sz [format "0x%04X   " [lindex $errorlist $j]]
         set szError "$szError$sz "
      }
      TlPrint $szError
   }

}
