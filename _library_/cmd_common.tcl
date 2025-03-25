# Umsetzung der TCL Testturm-Kommandos auf Twinalyzer-Kommandos
# siehe P:\usr\projekte\ids\software\spezifik\swtest\testumgebung.htm
#
# R.Wurth/J.Fiess/S.Hogenmueller 17.07.2001
#
# Implementierte Kommandos:
#
#  TlLogfile filename
#  TlPrint "format" arg1 arg2 ...
#  TlError "format" arg1 arg2 ...
#  TlInput "Prompt" Default Timeout
#  TlLastAbort
#  TlTestCase Datei.tcl TestId "Beschreibung"
#  TlDebugLevel level
#  TlExit
#
#  In cmd_twina.tcl bzw. cmd_Berger_tlxxx.tcl:
#     TlRead BEREICH.OBJEKT
#     TlRead Index.Subindex
#     TlWrite BEREICH.OBJEKT Wert
#     TlWrite Index.Subindex Wert
#
#  Änderungen:
#     10.07.2001 S.Hogenmueller : TlRead und TlWrite geaendert (Bearbeitung mit Hashtable)
#
#  Änderung:
#     07.07.2003 G.Pfeiffer : Ausgabe der ms von 3 auf 5 Stellen erhöht
#     27.09.2004 G.Pfeiffer : Workaround für das Problem Modbus No Respons
#     17.11.2004 G.Pfeiffer : global GlobErr
#     26.11.2005 G.Pfeiffer : OldErrLogTestId als Merker für die letzte ID bei der ein Fehler reportet wurde
# 270105 pfeig Datum zum Logfile noch hinzugefügt
# 270105 pfeig OldErrLogTestId eingebaut zur unterscheidung ob ErrorLog geschrieben werden soll
# 010405 pfeig Workaround für das Problem Modbus No Respons
# 280405 pfeig Neues Testprotokoll WriteReportHead
# 060705 pfeig TlPrint auf 8 Parameter erweitert

# 231106 rittp In die *.tlg (Testcase LoG)-File werden nur noch Testfälle (Funktionen die mit TC_ anfangen) eingetragen
# 131206 pfeig SQL_DeleteLog SQL_WriteLog
# 150108 pfeig SQL_WriteTestRun getauscht gegen: SQL_NewDefaultTestRun
# 040208 pfeig TC von der TestCaseID entfernt
# 160614 serio Adapt WriteReportHead for Beidou

global AutoLoop
global OldErrLogTestId
global testpath
global Fieldbus
global CreateLog

set OldErrLogTestId ""
set GlobErr 0
set funcNames ""

puts "load cmd_common.tcl"

if [info exists env(COMPUTERNAME)] {
   set COMPUTERNAME $env(COMPUTERNAME)
} else {
   set COMPUTERNAME "unknown"
}
#set CreateLog "YES"
set theLogFileName "DUMMY"   ;# Initialization
set theLogFileName "$testpath/tturm-$COMPUTERNAME.log"
set theTestCaseLogFileName "$testpath/tturm-$COMPUTERNAME.tlg"

set theLogFileFlushCounter 0
set theTestCaseLogFileFlushCounter 0
set theTestCaseObjLogFileFlushCounter 0

set theErrfileFirstErrName "$testpath/tturm-$COMPUTERNAME.err_first"
set theTestReportFileName "$testpath/tturm-${COMPUTERNAME}_report.log"
set theTestStatisticsFileName "$testpath/tturm-${COMPUTERNAME}_statistic.log"
set theTestDurationFileName {}
append theTestDurationFileName "$testpath/tturm-${COMPUTERNAME}_$Fieldbus" "_testDuration.log"

set theTestReportID ""           ;# ID   für TestReport
set theTestReportErrFlag   0     ;# Flag für TestReport
set theErrFileName "$testpath/tturm-$COMPUTERNAME.err"

set theDebugFlagObj        0
set theDebugFlagFrame      0

set theTestTclFilename     ""
set theTestcaseID          ""
set theTestDescription     ""

set theLogFile "DUMMY"   ;# Initialization
set theTestCaseLogFile "DUMMY"
set theTestReportFile "DUMMY"
set theTestStatisticsFile "DUMMY"
set theTestDurationFile "DUMMY"
set theErrFile "DUMMY"
set theErrfileFirstErr "DUMMY"

if { $CreateLog } {
   # Logfile oeffnen
   puts "Open Logfile"
   TwinPrint "Logfile: $theLogFileName"
   set theLogFile [open $theLogFileName a]

   # TestCaseLogfile oeffnen
   puts "Open TestCaseLogfile"
   TwinPrint "TestCaseLogfile: $theTestCaseLogFileName"
   set theTestCaseLogFile [open $theTestCaseLogFileName a]

   # TestReport oeffnen
   puts "Open TestReportFile"
   TwinPrint "TestReportFile: $theTestReportFileName"
   set theTestReportFile [open $theTestReportFileName a]

   # Create statistic file if it does not exist
   puts "Open StatisticFile"
   TwinPrint "StatisticFile: $theTestStatisticsFileName"
   set theTestStatisticsFile [open $theTestStatisticsFileName a]
   close $theTestStatisticsFile

   # Create TestDuration file if it does not exist
   puts "Open TestDurationFile"
   TwinPrint "TestDurationFile: $theTestDurationFileName"
   set theTestDurationFile [open $theTestDurationFileName a]
   close $theTestDurationFile

   # Errfile oeffnen
   puts "Open Errfile"
   TwinPrint "Errfile: $theErrFileName"
   set theErrFile [open $theErrFileName a]

   # Errfile das nur jeweils den ersten Fehler pro TestCaseID enthält oeffnen
   puts "Open ErrfileFirstErr"
   TwinPrint "ErrfileFirstErr: $theErrfileFirstErrName"
   set theErrfileFirstErr [open $theErrfileFirstErrName a]
}

#----------------------------------------------------------------------------
proc TlLogfile { logFilename } {
   global theLogFileName theLogFile CreateLog

   if { $CreateLog } {
      close $theLogFile

      set theLogFileName $logFilename
      set theLogFile [open $theLogFileName a]
   } else {
      TlPrint " #info: No Log-File is created, see config_PCName.ini for details"
   }
}

#----------------------------------------------------------------------------
# proc TlTestCaseLogfile { TestCaselogFilename } {
#    global theTestCaseLogFileName theTestCaseLogFile
#
#    close $theTestCaseLogFile
#
#    set theTestCaseLogFileName $TestCaselogFilename
#    set theTestCaseLogFile [open $theTestCaseLogFileName a]
# }
#----------------------------------------------------------------------------

proc TlDeleteFile { delLogfile delErrfile} {
   global theLogFileName theLogFile  TestRunID
   global theTestCaseLogFileName theTestCaseLogFile
   global theErrFileName theErrFile theErrfileFirstErr theErrfileFirstErrName
   global theTestReportFileName theTestReportFile PrgNr
   global theTestCaseLogFile theTestCaseObjLogFileName theTestCaseObjLogFile
   global CreateLog

   if { $CreateLog } {
      if { $delLogfile } {
         TlPrint "delete $theLogFileName"
         close $theLogFile
         set theLogFile [open $theLogFileName w]

         TlPrint "delete $theTestCaseLogFileName"
         close $theTestCaseLogFile
         set theTestCaseLogFile [open $theTestCaseLogFileName w]

         TlPrint "delete $theTestReportFileName"
         close $theTestReportFile
         set theTestReportFile [open $theTestReportFileName w]
      }

      if { $delErrfile } {
         TlPrint  "delete $theErrFileName"
         close $theErrFile
         set theErrFile [open $theErrFileName w]

         TlPrint  "delete $theErrfileFirstErrName"
         close $theErrfileFirstErr
         set theErrfileFirstErr [open $theErrfileFirstErrName w]
      }
   } else {
      TlPrint " #info:TlDeleteFile: LogFiles were not created -> deletion impossible "
   }

   # erst werden alle alten Default Protokolle ausser dem aktuellen gelöscht
   SQL_DeleteAllOldLog
   # dann wird ein neuer Testrun in der DB erzeugt
   SQL_NewDefaultTestRun
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Search for log files and clear the directories. LogFiles (*.log, *.tlg, *.err_first, *.err) will
# be deleted.
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 311014 gelbg    Proc created
# 211114 gelbg    Expand deletion for all LogFiles
#END------------------------------------------------------------------------------------------------
proc TlDelLogFiles { } {
   global theLogFile theTestCaseLogFile theTestReportFile theTestStatisticsFile
   global theTestDurationFile theErrFile theErrfileFirstErr
   global mainpath CreateLog
   set files {}
   set ext ".log"
   #   puts "Mainpath: $mainpath"
   set dir [pwd]
   set lFileExt [list ".log" ".tlg" ".err_first" ".err" ]

   if { $CreateLog } {
      TlError " #info:TlDelLogFiles: create log file switch shall be off"
      return
   }

   if {[info exists $theLogFile]} {
      close $theLogFile
   }
   if {[info exists $theTestCaseLogFile]} {
      close $theTestCaseLogFile
   }
   if {[info exists $theTestReportFile]} {
      close $theTestReportFile
   }
   if {[info exists $theTestStatisticsFile]} {
      close $theTestStatisticsFile
   }
   if {[info exists $theTestDurationFile]} {
      close $theTestDurationFile
   }
   if {[info exists $theErrFile]} {
      close $theErrFile
   }
   if {[info exists $theErrfileFirstErr]} {
      close $theErrfileFirstErr
   }

   # Search in all subfolder (1 Level deeper)
   foreach folder [glob -nocomplain -type d -directory $mainpath *] {

      foreach file [glob -nocomplain -directory $folder "tturm-*$ext"] {
         set objectFile [file tail [file rootname $file]]$ext
         puts "$objectFile"
         lappend files $file
      }
   }
   foreach param $lFileExt {
      # Search in the current working directory (pwd)
      foreach file [glob -nocomplain -directory $mainpath "tturm-*$param"] {
         set objectFile [file tail [file rootname $file]]$param
         puts "Extension: $param"
         puts "$objectFile"
         lappend files $file
      }
   }

   foreach File $files {
      file delete $File
      puts "File deleted: $File"
   }
}

#----------------------------------------------------------------------------
proc TlReport { sFormat args } {

   TlPrintIntern R "$sFormat" args
}

#----------------------------------------------------------------------------
#
#
proc TlStatistics { TestCaseId executionState } {
   global theTestStatisticsFileName
   global startTimeOfTest
   global TestSuiteId theTestSuite theTestSuiteFailed
   global CreateLog

   if { !$CreateLog } {
      TlPrint " #info:TlStatistics: create log file switched off"
      return
   }

   if {![info exists theTestSuite]} {
      set theTestSuite "dummy"
   }

   set filehandle [ini::open $theTestStatisticsFileName "r+"]

   #update execution counter of TestCase:
   #if TestCase already listed and executionState is 'OK'
   # then increment execution count with 1
   # else count is 0
   #if executionState is 'Failed'
   # count is -10
   set section "TestCaseExecutionCounter"
   if {$executionState == "OK"} {
      set actCount [ini::value $filehandle $section $TestCaseId "ndef"]
      if {$actCount == "ndef"} {
         set actCount 0
      } else {
         incr actCount 1
      }
   } else {
      set actCount -10
   }
   ini::set $filehandle $section $TestCaseId $actCount

   if {[regexp {TestfileStart} $TestCaseId] } {
      set theTestSuite [string map {"_TestfileStart" ""} $TestCaseId]
   }

   #update execution counter of test Suite
   set section "TestSuiteExecutionCounter"
   if {$executionState == "OK"} {
      set actCount [ini::value $filehandle $section $theTestSuite "ndef"]
      if {$actCount == "ndef"} {
         set actCount 0
      }
   } else {
      set actCount -10
      set theTestSuiteFailed 1
   }
   #if test case Id is *TestFileStop and theTestSuiteFailed flag is 0, increment testSuite counter
   if {[regexp {TestfileStop} $TestCaseId]} {
      if {($theTestSuiteFailed == 0)} {
         incr actCount 1
      }
      set theTestSuiteFailed 0

   }

   ini::set $filehandle $section $theTestSuite $actCount

   ini::commit $filehandle
   ini::close $filehandle

}

#----------------------------------------------------------------------------
#Save duration time of last test case to file
#
proc TlDuration { TestCaseId} {
   global theTestDurationFileName
   global startTimeOfTest
   global CreateLog

   if { !$CreateLog } {
      TlPrint " #info:TlDuration: create log file switched off"
      return
   }
   set filehandle [ini::open $theTestDurationFileName "r+"]

   #update timer for TestCase execution
   set section "TestCaseExecutionTimer"
   set actTime [clock seconds]
   ini::set $filehandle $section $TestCaseId [expr $actTime - $startTimeOfTest]
   set startTimeOfTest $actTime

   ini::commit $filehandle
   ini::close $filehandle

}

#----------------------------------------------------------------------------
proc TlPrintTC { Idx Six Action {BusAdd ""} } {
   global theTestTclFilename theTestcaseID  ActDev  AutoLoop

   if {$theTestTclFilename != "TC_ParLimit/Parameter.tcl" } {
      set emptyList {}
      TlPrintIntern O " $AutoLoop $ActDev $theTestTclFilename $theTestcaseID $Idx $Six $Action" emptyList
   }

}
#TODO 
#----------------------------------------------------------------------------
# Gibt Text auf dem Bildschirm aus
#----------------------------------------------------------------------------
proc TlPrint { sFormat args } {
   global DebuggerCNT
   global Debugger_InterpreterStop
   global Debugger_Active

   ##First settle the event loop before proceeding to print out to display
   if {$Debugger_Active} {
      after 5
      update idletask
   }
   ##First settle the event loop before proceeding to print out to display

   TlPrintIntern P "$sFormat" args

   ##To stop the Interpreter by the Debugger
   if {$Debugger_InterpreterStop} {
      Debugger_ApplicationStopStart
   }
   ##To stop the Interpreter by the Debugger

   incr DebuggerCNT
}

#----------------------------------------------------------------------------
proc TlError { sFormat args } {
   global GlobErr errorInfo errorCode theTestDir testFilename
   global theTestReportErrFlag funcNames

   set funcNames ""
   set emptyList {}
   set theTestReportErrFlag 1       ;# Flag: Test FAILED

   # append info to GEDEC, if available
   set Index1GEDEC [string first "*" $sFormat]
   if {$Index1GEDEC > -1} {
      incr Index1GEDEC
      set Index2GEDEC [string first "*" $sFormat $Index1GEDEC]
      if {$Index2GEDEC > $Index1GEDEC} {
         incr Index2GEDEC -1
         set GEDEC [string range $sFormat $Index1GEDEC $Index2GEDEC]
         set GEDECinfo [getCRinfo $GEDEC]
         set GEDECwhy [getCRwhyClosed $GEDEC]
         if {$GEDECinfo != ""} {
            if {$GEDECinfo == "Closed"} {
               # if closed, print without *
               # -> entry will not be blue in dblog
               incr Index1GEDEC -1
               incr Index2GEDEC
               set sFormat [string replace $sFormat $Index1GEDEC $Index2GEDEC [format "!%s!(%s|%s)" $GEDEC $GEDECinfo $GEDECwhy]]
            } else {
               incr Index2GEDEC
               set sFormat [string replace $sFormat $Index2GEDEC $Index2GEDEC [format "*(%s)" $GEDECinfo]]
            }
         }
      }
   }

   # wird zurückgesetzt in: TlTestCase
   set GlobErr [ expr $GlobErr + 1]
   set startLevel 1
   set endLevel [expr [info level] -1]
   for {set i $startLevel} {$i <= $endLevel} {incr i} {
      set funcName [info level $i]
      lappend funcNames $funcName
   }
   TlPrintIntern E "$sFormat" args

   # Stackframe ausgeben
   if { $startLevel <= $endLevel } {
      TlPrintIntern D "      Call Stack frame:" emptyList

      for {set i $startLevel} {$i <= $endLevel} {incr i} {
         set funcName [info level $i]

         switch [lindex $funcName 0] {

            "TestDir" {
               TlPrintIntern D "      - TestDir $theTestDir" emptyList
            }

            "Main_Layer" {
               switch [lindex $funcName 1] {
                  "1" {
                     TlPrintIntern D "      - Menu layer 1 Testcase: $theTestDir" emptyList
                  }
                  "2" {
                     TlPrintIntern D "      - Menu layer 2 Testfile: $testFilename" emptyList
                  }
               }
            }

            "AllChoicesRun" {}

            "UserChoicesRun" {}

            default {
               TlPrintIntern D "      - $funcName" emptyList
            }

         }

         #         if {[lindex $funcName 0] == "TestDir" } {
         #
         #            TlPrintIntern D "      - TestDir $theTestDir" emptyList
         #
         #         } elseif {[lindex $funcName 0] == "Main_Layer" } {
         #
         #               switch [lindex $funcName 1] {
         #                  "1" {
         #                     TlPrintIntern D "      - Menu layer 1 Testcase: $theTestDir" emptyList
         #                  }
         #                  "2" {
         #                     TlPrintIntern D "      - Menu layer 2 Testfile: $testFilename" emptyList
         #                  }
         #
         #               }
         #
         #
         #            } else {TlPrintIntern D "      - $funcName" emptyList}

      }
   }

   return
}

#----------------------------------------------------------------------------

proc TlBlock { Why unblockingSteps bypassedSteps} {
	global theTestBlockedFlag 
	set  theTestBlockedFlag 1
	TlPrint "========== BLOCKING TEST ===============" 
	TlPrint "$Why"
	TlPrint "========== WORKAROUND ===============" 
	set steps [split $unblockingSteps "\n" ]
	foreach step $steps {
		TlPrint "Workaround step : $step"
		eval $step 
	}
	TlPrint "========== ORIGINAL CODE ===============" 
	set steps [split $bypassedSteps "\n" ]
	foreach step $steps {
		TlPrint "bypassed step : $step"
	}
	TlPrint "========== END OF BLOCKING  ===============" 

}
#----------------------------------------------------------------------------
proc TlInput { prompt defaultwert {timeout 0}  } {
   global theLogFile CreateLog

   set emptyList {}
   set answer [TwinInput $prompt ]
   #   puts "answer = '$answer'"
   if { $answer == "" } {
      set answer $defaultwert
   }
   TlPrintIntern I "$prompt ? $answer" emptyList
   if { $CreateLog } {
      flush $theLogFile
   }

   return $answer
}

#----------------------------------------------------------------------------
proc TlSerial { port baudrate } {
   global theDebugFlagObj

   TlPrint "Open serial port $port with $baudrate Baud"

   set rc [catch { TwinSerial $port $baudrate }]; if {$rc != 0} { set result 0 }
   return rc
}

#----------------------------------------------------------------------------
proc TlConnect { address } {
   global theDebugFlagObj

   set rc [catch { TwinConnect $address }]; if {$rc != 0} { set result 0 }
   return rc
}

#----------------------------------------------------------------------------
proc TlDebugLevel { level } {
   global theDebugFlagObj theDebugFlagFrame

   set emptyList {}
   TlPrintIntern P "TlDebugLevel $level" emptyList

   set theDebugFlagObj   [expr ($level & 0x01) != 0]  ;# Bit 0
   set theDebugFlagFrame [expr ($level & 0x02) != 0]  ;# Bit 1
}

#----------------------------------------------------------------------------
proc TlLastAbort {} {
   # not implemented yet

   return 0
}

#----------------------------------------------------------------------------
# Testfall definieren
#
# altes Format: TlTestCase filename testID descriction
# neues Format: TlTestCase description
#
# Beim neuen Format wird der filename in der Menüumgebung gesetzt und als TestID wird
# der Procedurname der aufrufenden Prozedur verwendet
proc TlTestCase { firstArg {testcaseID ""} {description ""} } {
   global theTestTclFilename theTestcaseID theTestDescription
   global theTestReportID theTestReportErrFlag GlobErr
   global ShowStatusCounter ShowStatusTime
	global theTestBlockedFlag 
	set  theTestBlockedFlag 0
	

   #
   #
   # ----------HISTORY----------
   # WANN   WER   WAS
   # ?      ?     Datei angelegt
   # 050307 pfeig set GlobErr 0 von WriteReportHead nach hier verlegt (damit nach automatisch erzeugten ID's kein Folgefehler generiert wird)
   set GlobErr 0

   WriteReportTest   ;# alten Report ausgeben

   if {$testcaseID == ""} {
      # NEU
      if {[info level] == 1} {
         set theTestcaseID "MAIN"
      } else {
         set theTestcaseID [info level -1] ;# speichert Funktionsname der uebergeordneten Prozedur

      }
      set theTestDescription $firstArg
   } else {
      # ALT
      set theTestTclFilename     $firstArg
      set theTestcaseID          $testcaseID
      set theTestDescription     $description
   }

   # Werte für Testreport vorbelegen
   set theTestReportID $theTestcaseID
   set theTestReportErrFlag 0
   set emptyList {}
   TlPrintIntern P "------------------------------------------------------------" emptyList
   TlPrintIntern P "TESTFILE: $theTestTclFilename" emptyList
   TlPrintIntern P "TESTCASE: $theTestcaseID" emptyList
   TlPrintIntern P "TESTDESC: $theTestDescription" emptyList
   TlPrintIntern P "------------------------------------------------------------" emptyList

   if { [string match "TC_*" $theTestcaseID] == 1 } {
      # 24.11.2006 Eintrag nur dann wenn es sich wirklich um ein Testfall handelt
      # Testcase-Logfile schreiben
      TlPrintIntern L "TESTFILE: $theTestTclFilename; TESTCASE: $theTestcaseID" emptyList
   }
   
   set ShowStatusCounter 0
   set ShowStatusTime 0
   
}

#----------------------------------------------------------------------------
proc TlExit {} {
   global theLogFile theErrFile theErrfileFirstErr CreateLog

   if { $CreateLog } {
      close $theLogFile
      close $theErrFile
      close $theErrfileFirstErr
   }
}

#----------------------------------------------------------------------------
# Verschiedenen Ausgabe-Devices ansprechen
proc TlPrintIntern { outTyp sFormat args } {

   #
   # ----------HISTORY----------
   # WANN   WER   WAS
   # ?      ?     Datei angelegt
   # 260105 pfeig OldErrLogTestId eingebaut zur unterscheidung ob ErrorLog geschrieben werden soll
   # 270105 pfeig Datum zum Logfile noch hinzugefügt

   global theLogFile theLogFileFlushCounter CreateLog
   global theTestCaseLogFile theTestCaseLogFileFlushCounter
   global theErrFile theErrfileFirstErr
   global theTestTclFilename theTestcaseID
   global globAbbruchFlag theTestReportFile
   global tcl_version GlobErr
   global OldErrLogTestId ActDev theTestCaseObjLogFile theTestCaseObjLogFileFlushCounter
   global TestRunID
   upvar $args a

   switch [llength $a] {
      0        { set s $sFormat }
      1        {  set LString [lindex $a 0]
         set len [ string length $LString]
         if { $len == 0} {
            # Workaround für das Problem Modbus No Respons
            set s ""
            #   set s "(Bus No Respons)$sFormat"
            #   set outTyp "E"
         } else {
            set s [format $sFormat $a]
         }
      }
      2       { set s [format $sFormat [lindex $a 0] [lindex $a 1]] }
      3       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2]] }
      4       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3]] }
      5       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4]] }
      6       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5]] }
      7       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6]] }
      8       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7]] }
      9       { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8]] }
      10      { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8] [lindex $a 9]] }
      11      { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8] [lindex $a 9] [lindex $a 10]] }
      12      { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8] [lindex $a 9] [lindex $a 10] [lindex $a 11]] }
      13      { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8] [lindex $a 9] [lindex $a 10] [lindex $a 11] [lindex $a 12]] }
      14      { set s [format $sFormat [lindex $a 0] [lindex $a 1] [lindex $a 2] [lindex $a 3] [lindex $a 4] [lindex $a 5] [lindex $a 6] [lindex $a 7] [lindex $a 8] [lindex $a 9] [lindex $a 10] [lindex $a 11] [lindex $a 12] [lindex $a 13]] }

   }

   set lineid [clock format [clock seconds] -format "%y%m%d%a%H%M%S"]
   # 2006-12-31 10:42:01
   set lineIdSql [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

   if {$tcl_version > 8.0} {
      set ms [string range [clock clicks -milliseconds] end-4 end]
      set lineid "$lineid-$ms"
   }

   set TestId "==>\[$theTestTclFilename,$theTestcaseID,$ActDev\]$s"
   if {$globAbbruchFlag} {
      set outTyp A
   }

   switch $outTyp {

      L  {
         if { $CreateLog } {
            set lineid [clock format [clock seconds] -format "%a-%d.%m.%y-%H:%M:%S"]
            # Ausgabe der Testfaelle
            puts $theTestCaseLogFile "TestRunID = $TestRunID; $lineid-$ms   >$s"
            flush $theTestCaseLogFile
         }
      }
      P  {
         # Normale Ausgabe
         if { $CreateLog } {
            puts $theLogFile "$lineid   >$s"
         }
         TwinPrint "$s"
         SQL_WriteLog $lineIdSql $theTestTclFilename $theTestcaseID $s $ms

      }
      E  {
         # Fehlerausgabe
         if { $CreateLog } {
            puts $theLogFile "$lineid $TestId"
            puts $theErrFile "$lineid $TestId"
            flush $theErrFile

            if {$OldErrLogTestId != $theTestcaseID} {
               puts $theErrfileFirstErr "$lineid $TestId"
               flush $theErrfileFirstErr

               set OldErrLogTestId $theTestcaseID
            }
         }
         SQL_WriteLog $lineIdSql $theTestTclFilename $theTestcaseID $s $ms $GlobErr
         SQL_WriteLogErr $lineIdSql $theTestTclFilename $theTestcaseID $s $ms $GlobErr

         TwinPrint "$TestId"
      }
      I  {
         # Eingabe
         if { $CreateLog } {
            puts $theLogFile "$lineid ??>$s"
         }
         SQL_WriteLog $lineIdSql $theTestTclFilename $theTestcaseID $s $ms

      }
      D  {
         # Debugausgabe
         if { $CreateLog } {
            puts $theLogFile "$lineid   :$s"
         }
         TwinPrint "$ms $s"
         SQL_WriteLog $lineIdSql $theTestTclFilename $theTestcaseID $s $ms
      }
      A  {
         # Abbruch durch Anwender
         if { $CreateLog } {
            puts $theLogFile "$lineid xx>$s"
         }
         TwinPrint "xx>$s"
      }
      R  {
         # Report
         if { $CreateLog } {
            puts  $theTestReportFile "$s"
            flush $theTestReportFile
         }

      }
   }
   if { $CreateLog } {
      # Bei jeder 10ten Zeile Datei flushen
      incr theLogFileFlushCounter
      if {$theLogFileFlushCounter > 10} {
         set theLogFileFlushCounter 0
         flush $theLogFile
      }
   }

}

#----------------------------------------------------------------------------

proc WriteReportTest {} {
   global theTestReportID theTestReportErrFlag GlobErr
   global theTestTclFilename theTestcaseID
   global startTimeOfTest TraceStatistics
   global theTestBlockedFlag

   # Report ausgeben
   # todo das die sql log befehle hier stehen ist design technisch nicht so
   # ganz korrekt,
   # falls das mal jemand anpackt bitte mit TLReport realisieren gpf
   if {$theTestReportID != ""} {
      # habe das TC entfernen wieder aufgehoben da es momentan auch zur Unterscheidung
      # von "Echten Testcases" und Markern für Hilfsproceduren benutzt wird
      #set TestcaseID [string map {"TC_" ""} $theTestcaseID]
      TlPrint "Last used TestcaseID = $theTestcaseID"

      if ($theTestReportErrFlag) {
         TlReport "%-70s FAILED" $theTestReportID
         SQL_WriteLogTC $theTestTclFilename $theTestcaseID  "FAILED"
         if {$TraceStatistics} {
            TlStatistics $theTestReportID "FAILED"
         }
      } elseif {$theTestBlockedFlag} {
		TlReport "%-70s BLOCKED" $theTestReportID
		SQL_WriteLogTC $theTestTclFilename $theTestcaseID  "BLOCKED"
		if {$TraceStatistics} {
			TlStatistics $theTestReportID "BLOCKED"
		}
      } else {
         TlReport "%-70s OK" $theTestReportID
         SQL_WriteLogTC $theTestTclFilename $theTestcaseID "OK"
         if {$TraceStatistics} {
            TlDuration $theTestReportID
            TlStatistics $theTestReportID "OK"
         }
      }
   } else {
      #initial time for test execution measurement
      set startTimeOfTest [clock seconds]
   }

   # Aktuelles Autoloop schreiben und Stop Zeit aktualisieren
   SQL_UpdateTestRun
   # Werte zurücksetzen
   set theTestReportID ""
   set theTestReportErrFlag 0
   #   set GlobErr 0
}

#-------------------------------------------------------------------------
# Write head into report file
#-------------------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 140415 serio correct [GetDevFeat "!Beidou"] to ![GetDevFeat "Beidou"]

proc WriteReportHead {{DevOn 0}} {
   global ConfigSafeDisableText ConfigSafeDisable ActDev
   global AutoLoop
   global ATVapplVer ATVapplBuild ATVmotVer  ATVmotBuild
   global ATVbootVer ATVbootBuild ATVdspVer  ATVdspBuild
   global ATVcpldVer ATVcpldBuild ATVembdVer ATVembdBuild
   global ATVmodVer  ATVmodBuild  ATVmod2Ver ATVmod2Build
   global ATVembdType ATVmodType ATVmod2Type
   global ATVplatVer ATVplatBuild
   global Enable_Counter theDevList
   global ATVmod3Type ATVmod3Ver ATVmod3Build   
   global theNERAParaNameRecord

   if {$DevOn} {
      DeviceOn $ActDev
   }

   set ATVapplVer   [format "%04X" [doReadObject C1SV]]
   set ATVapplBuild [format "%04X" [doReadObject C1SB]]
   set ATVmotVer    [format "%04X" [doReadObject C2SV]]
   set ATVmotBuild  [format "%04X" [doReadObject C2SB]]   
   if {![GetDevFeat "Altivar"]} {   
   set ATVplatVer   [format "%04X" [doReadObject PLTV]]
   set ATVplatBuild [format "%04X" [doReadObject PLTB]]   
   set ATVbootVer   [format "%04X" [doReadObject C3SV]]
   set ATVbootBuild [format "%04X" [doReadObject C3SB]]
   set ATVdspVer    [format "%04X" [doReadObject C4SV]]
   set ATVdspBuild  [format "%04X" [doReadObject C4SB]]
   set ATVcpldVer   [format "%04X" [doReadObject C5SV]]
   set ATVcpldBuild [format "%04X" [doReadObject C5SB]]
   } else {
      set ATVplatVer   [format "%04X" [doReadObject C1SV]]
      set ATVplatBuild [format "%04X" [doReadObject C1SB]]   
      set ATVbootVer   [format "%04X" [doReadObject C1SV]]
      set ATVbootBuild [format "%04X" [doReadObject C3SB]]
      set ATVdspVer    [format "%04X" [doReadObject C1SV]]
      set ATVdspBuild  [format "%04X" [doReadObject C1SB]]
      set ATVcpldVer   [format "%04X" [doReadObject C1SV]]
      set ATVcpldBuild [format "%04X" [doReadObject C1SB]]      
      
   }
   #Card6 needs some sec to boot
   set ATVembdType  [format "%04X" 0]
   set ATVembdVer   [format "%04X" 0]
   set ATVembdBuild [format "%04X" 0]
   if { [GetDevFeat "Card_EthBasic"] || [GetDevFeat "Card_AdvEmbedded"] } {
      set timeout 10  ;# sec
      set starttime [clock seconds]
      while { ($ATVembdType == "") || ($ATVembdType == 0) } {
         if {[CheckBreak]} {break}
         set ATVembdType  [ModTlRead C6CT 1]
         set ATVembdVer   [format "%04X" [ModTlRead C6SV 1]]
         set ATVembdBuild [format "%04X" [ModTlRead C6SB 1]]
         set waittime [expr [clock seconds] - $starttime]
         if { $waittime > $timeout } {
            TlError "no connection to Card_EthBasic within $timeout sec"
            break
         }
      }
   }

   set ATVmodType   [ModTlRead O1CT 1]
   set ATVmodVer    [format "%04X" [ModTlRead O1SV 1]]
   set ATVmodBuild  [format "%04X" [ModTlRead O1SB 1]]
   if {![GetDevFeat "Beidou"] & ![GetDevFeat "Altivar"] } {
      set ATVmod2Type  [ModTlRead O2CT 1]
      set ATVmod2Ver   [format "%04X" [ModTlRead O2SV 1]]
      set ATVmod2Build [format "%04X" [ModTlRead O2SB 1]]
   }
   if { [info exists theNERAParaNameRecord(O3CT)] } {
      set ATVmod3Type  [ModTlRead O3CT 1]
      set ATVmod3Ver   [format "%04X" [ModTlRead O3SV 1]]
      set ATVmod3Build [format "%04X" [ModTlRead O3SB 1]]
   }   

   #fixme: check if this is still necessary for OPAL
   # print out the amount of enable cycles of the run before
   if {$AutoLoop > 1} {
      TlReport "Number of Enable-cycles from the last run"
      foreach i $theDevList {
         TlReport "Device $i was Enabled $Enable_Counter($i) times "
      }
      TlReport ""
   }

   #Enable-Counter löschen
   foreach i $theDevList {
      set Enable_Counter($i) 0
   }

   # show date and time and program infos
   TlReport "============================================================="
   TlReport "Altivar Testrun No: $AutoLoop on Device Nr.: $ActDev"
   TlReport "Test startet at        : %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
   if {[GetDevFeat "Nera"]} {
      TlReport "Device name            : Altivar 630 with EtherCAT option module"
   } elseif {[GetDevFeat "Beidou"]} {
      TlReport "Device name            : Altivar 610 with EtherCAT option module"
   } else {
      TlReport "Device name            : Altivar 32 with EtherCAT option module"
   }

   TlReport "Application version    : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVapplVer 0 0]" "0x[string range $ATVapplVer 1 1]" "0x[string range $ATVapplVer 2 3]" "0x[string range $ATVapplBuild 0 1]" "0x[string range $ATVapplBuild 2 3]"
   TlReport "Motor control version  : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVmotVer  0 0]" "0x[string range $ATVmotVer  1 1]" "0x[string range $ATVmotVer  2 3]" "0x[string range $ATVmotBuild  0 1]" "0x[string range $ATVmotBuild  2 3]"
   TlReport "Boot version           : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVbootVer 0 0]" "0x[string range $ATVbootVer 1 1]" "0x[string range $ATVbootVer 2 3]" "0x[string range $ATVbootBuild 0 1]" "0x[string range $ATVbootBuild 2 3]"
   TlReport "DSP version            : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVdspVer  0 0]" "0x[string range $ATVdspVer  1 1]" "0x[string range $ATVdspVer  2 3]" "0x[string range $ATVdspBuild  0 1]" "0x[string range $ATVdspBuild  2 3]"
   TlReport "CPLD version           : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVcpldVer 0 0]" "0x[string range $ATVcpldVer 1 1]" "0x[string range $ATVcpldVer 2 3]" "0x[string range $ATVcpldBuild 0 1]" "0x[string range $ATVcpldBuild 2 3]"
   if {[GetDevFeat "Nera"]} {
      TlReport "Ethernet Basic version : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVembdVer 0 0]" "0x[string range $ATVembdVer 1 1]" "0x[string range $ATVembdVer 2 3]" "0x[string range $ATVembdBuild 0 1]" "0x[string range $ATVembdBuild 2 3]"
   }
   TlReport "Option Board 1 version : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVmodVer  0 0]" "0x[string range $ATVmodVer  1 1]" "0x[string range $ATVmodVer  2 3]" "0x[string range $ATVmodBuild  0 1]" "0x[string range $ATVmodBuild  2 3]"
   if {![GetDevFeat "Beidou"] & ![GetDevFeat "Altivar"] } {
      TlReport "Option Board 2 version : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVmod2Ver 0 0]" "0x[string range $ATVmod2Ver 1 1]" "0x[string range $ATVmod2Ver 2 3]" "0x[string range $ATVmod2Build 0 1]" "0x[string range $ATVmod2Build 2 3]"
   }
 if { [info exists theNERAParaNameRecord(O3CT)] } {
      TlReport "Option Board 3 version : V%X.%Xie%02X  Build%02X build%02X" "0x[string range $ATVmod3Ver 0 0]" "0x[string range $ATVmod3Ver 1 1]" "0x[string range $ATVmod3Ver 2 3]" "0x[string range $ATVmod3Build 0 1]" "0x[string range $ATVmod3Build 2 3]"
   }   
   TlReport "============================================================="
   if {$DevOn} {
      DeviceOff $ActDev
   }
}

#----------------------------------------------------------------------------
