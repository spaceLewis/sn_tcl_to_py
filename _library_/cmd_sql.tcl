#--------------------------------------------------------------------------------------------------------------
#
#      SQL commands for TCL-Test tower
#
#--------------------------------------------------------------------------------------------------------------
#
# CPD Test environment
#
# Filename     : cmd_SQL.tcl
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 030107 pfeig created proc
#----------------------------------------------------------------------

global AutoLoop



set TestRunID 0
set LogTableName "entries"
set LogTableID 0

puts "load cmd_sql.tcl"



# SQL Commands start ----------------------------------------------

proc lw { msg } {
   global CreateLog
   # lw steht f�r LogWrite
   # schreibt sowohl auf den Bildschirm, wie auch in das Textlogfile
   # wird anstelle von TlPrint benutzt, wenn die DB nicht zur Verf�gung steht
   if { $CreateLog } {
      global theLogFile
   
      puts $msg
      puts $theLogFile $msg
   }   
}


proc SQL_DeleteOldLog { } {
   # bietet eine M�glichkeit �ltere LogTabellen zu l�schen
   global DB_Open  theLogFile TestRunID

   if {$DB_Open} {
      set SQL  "SELECT `pk_testrun` , `description` FROM `testrun` ORDER BY `pk_testrun`;"

#puts $SQL
      lappend SQL1  db  $SQL
#puts $SQL_String

      set rc [catch  $SQL1 rows]

      if {$rc != 0} {
         lw " SQL_DeleteOldLog: $SQL1 "
         lw " rc: $rc "
         lw " Msg: $Msg "
      } else {
         set i 1
         TlPrint "  0 - All Default Protocols"
         foreach row $rows {
            foreach {a b} $row { }
            TlPrint [format " %2d - %s    %s" $i $a $b]
            lappend LineIDs $a
            incr i

         }
         set answer [TlInput "Please specify it to empty protocol" "" 0]

         if { ($answer < 0 ) || ($answer >= $i) } {
            return
         } else {
            if { $answer == 0 } {
               foreach row $rows {
                  #bp "Debugger"
                  foreach {a b} $row { }
                  if { [lindex [split $b "_"] 0] == "Default"} {
                     #TlPrint " Loesche : $a"
                     if { !($a == $TestRunID) } {
                        # nur l�schen wenn das Protokoll nicht das aktuelle ist
                        SQL_DeleteLog $a
                     }
                  }
               }
            } else {
               set LineID [lindex $LineIDs [expr $answer - 1]]
               TlPrint "\n Selected protocol: $LineID"
               if { $LineID == "" } {
                  return
               }
               SQL_DeleteLog $LineID
            }
         }
      }
   }
}


proc SQL_DeleteAllOldLog { } {
   # bietet eine M�glichkeit alle  Default LogTabellen zu l�schen
   global DB_Open  theLogFile TestRunID

   if {$DB_Open} {
      set SQL  "SELECT `pk_testrun` , `description` FROM `testrun` ORDER BY `pk_testrun`;"

#puts $SQL
      lappend SQL1  db  $SQL
#puts $SQL_String

      set rc [catch  $SQL1 rows]

      if {$rc != 0} {
         lw " SQL_DeleteOldLog: $SQL1 "
         lw " rc: $rc "
         lw " Msg: $Msg "
      }

      foreach row $rows {
         #bp "Debugger"
         foreach {a b} $row {
            if { [lindex [split $b "_"] 0] == "Default"} {
               # TlPrint " Loesche : $a"
               if { !($a == $TestRunID) } {
                  # nur l�schen wenn das Protokoll nicht das aktuelle ist
                  SQL_DeleteLog $a
               }
            }
         }

      }
   }
}



proc SQL_DeleteLog { delID } {
   # l�scht das angegebene Protokoll
   # sowohl die Logtabellen wie auch die Kopfzeile in TestRun
   # und tcid_entries
   global DB_Open  theLogFile TestRunID PrgNr  AutoLoop

   if {$DB_Open} {
      lw " Log tables are being cleared, please wait... "

      set SQL [subst -nobackslashes "SHOW TABLES LIKE 'Log\\_$delID" ]
      append  SQL "\\_%';"
#puts $SQL
      lappend SQL_String  db  $SQL
#puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_DeleteLog: $SQL_String "
         lw " rc: $rc "
         lw " Msg: $Msg "
      } else {
 #        lw "'$Msg'"
         if { $Msg == ""} {
            lw " Log table: Log_$delID not available "
            return
         }
         set Tables [string map {" " ","} $Msg]
         #lw "'$Msg'"
         set SQL [subst  "DROP TABLE $Tables" ]
         append  SQL ";"

         set SQL_String ""
         lappend SQL_String  db  $SQL

         set rc [catch  $SQL_String Msg]

         if {$rc != 0} {
            lw " SQL_DeleteLog: $SQL_String "
            lw " rc: $rc "
            lw " Msg: $Msg "
         } else {
            lw  " Following tables are cleared: $Tables"
         }
         SQL_DeleteTcIdLines   $delID
         SQL_DeleteLogErrTable $delID
         SQL_DeleteTestRunLine $delID
         if { $delID == $TestRunID } {
            # wenn das aktuelle Protokoll gel�scht wird, muss ein neues erzeugt werden
            SQL_NewDefaultTestRun
         }

      }
   }
   set AutoLoop 1
}

proc SQL_DeleteTcIdLines { pk_testrun } {
   global DB_Open  theLogFile

   if {$DB_Open} {
      lw " Test run No. $pk_testrun is being cleared from tcid_entries, please wait... "
      lappend SQL_String  db  "DELETE FROM tcid_entries WHERE fk_testrun = $pk_testrun"
#puts "SQL_String: $SQL_String"

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_DeleteTcIdLines: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      } else {
         lw " Cleared $Msg entries"
      }
   }

}


proc SQL_DeleteTestRunLine { pk_testrun } {
   global DB_Open  theLogFile

   if {$DB_Open} {
      lw " Test run No. $pk_testrun is being cleared, please wait... "
      lappend SQL_String  db  "DELETE FROM testrun WHERE pk_testrun = $pk_testrun"
#puts "SQL_String: $SQL_String"

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_DeleteTestRunLine: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      } else {
         lw  " Cleared $Msg entries"
      }
   }

}


proc SQL_DeleteLogErrTable { fk_testrun } {
   global DB_Open  theLogFile

   if {$DB_Open} {
      lw " Error entries for test run: $fk_testrun are being cleared, please wait... "

      lappend SQL_String  db  "DELETE FROM log_err WHERE fk_testrun = $fk_testrun"
#puts "SQL_String: $SQL_String"

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_DeleteLogErrTable: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      } else {
         lw  " Cleared $Msg entries "
      }
   }

}

proc SQL_DeleteLogTable { fk_testrun } {
   global DB_Open  theLogFile

   if {$DB_Open} {
      # SqlInsert {db stmt table columns {mode eval}}
      # SqlInsert db
      lw " Data base content is being cleared, please wait... "

      lappend SQL_String  db  "DELETE FROM entries WHERE fk_testrun = $fk_testrun"
#puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_DeleteLog: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      } else {
         lw  " Cleared $Msg entries "
      }
   }

}
# Doxygen Tag:
##Function description : Writes a line in the dblog entry
# WHEN  | WHO  | WHAT
# -----| -----| -----
# xxxx/xx/xx | ??? | proc created
# 2023/04/03 | ASY | update to correct a wrong behaviour in case of character \u0000
#
proc SQL_WriteLog { LogDateTime categorie testcaseid description mSec {error_flag 0} } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop LogTableName LogTableID

   if {$DB_Open} {
      # SqlInsert {db stmt table columns {mode eval}}
      # SqlInsert db
      set description [string map {"'" " " } $description]
      regsub -all \u0000 $description " " description

      set SQL { INSERT INTO $LogTableName ( LogDateTime, categorie, testcaseid, devicenumber, iterations, description, fk_testrun, mSec, error_flag )
              VALUES ( '$LogDateTime', '$categorie', '$testcaseid', '$ActDev', '$AutoLoop', '$description' , '$TestRunID', '$mSec', '$error_flag' ) }

#      append SQL_String  "db " "{"  "INSERT INTO $LogTableName ( LogDateTime, categorie, testcaseid, devicenumber, iterations, description, fk_testrun, mSec, error_flag ) "
#      append SQL_String  "VALUES ( '$LogDateTime', '$categorie', '$testcaseid', '$ActDev', '$AutoLoop', '$description' , '$TestRunID', '$mSec', '$error_flag' )" "}"

      set SQL [subst $SQL]
      lappend SQL_String  "db"   $SQL

# puts $SQL_String

      set rc [catch  $SQL_String Msg]
#      puts "RC: $rc"
      if {$rc != 0} {
         lw " SQL_WriteLog: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "
         return
      }
      set LogTableID [ db "SELECT LAST_INSERT_ID();"]
   }

}
# Doxygen Tag:
##Function description : Writes an error  line in the dblog entry
# WHEN  | WHO  | WHAT
# -----| -----| -----
# xxxx/xx/xx | ??? | proc created
# 2023/04/03 | ASY | update to correct a wrong behaviour in case of character \u0000
proc SQL_WriteLogErr { LogDateTime categorie testcaseid description mSec {error_flag 0} } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop LogTableID funcNames

   if {$DB_Open} {
      set description [string map {"'" " "} $description]
      regsub -all \u0000 $description " " description
      regsub -all {= *0x[0-9A-Fa-f]+} $description =xxx a     ;# hexzahlen entfernen
#      puts $a
      regsub -all {= *[+-]?[0-9\.]+} $a =xxx a                ;# dezimalzahlen entfernen
#      puts $a
      regsub -all {[(] *0x[0-9A-Fa-f]+} $a (xxx a             ;# hexzahlen nach Klammer entfernen
#      puts $a
      regsub -all {[(] *[+-]?[0-9\.]+} $a (xxx a              ;# dezimalzahlen nach Klammer entfernen
#      puts $a


      set ChkSum [doCheckSum $a]

      set SQL { INSERT INTO log_err ( LogDateTime, categorie, testcaseid, devicenumber, iterations, description, fk_testrun, fk_log_id, mSec, error_flag, StackFrame, ChkSum )
            VALUES ( '$LogDateTime', '$categorie', '$testcaseid', '$ActDev', '$AutoLoop', '$description' , '$TestRunID', '$LogTableID', '$mSec', '$error_flag', '$funcNames', '$ChkSum' ) }

      set SQL [subst $SQL]
      lappend SQL_String  "db"   $SQL

# puts " SQL_WriteLogErr ------------------------------------------!!!!!!"
#       puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_WriteLogErr: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      }
   }

}


proc SQL_WriteLogTC { categorie testcaseid result } {
   global DB_Open  theLogFile TestRunID AutoLoop LogTableID

   if {$DB_Open} {

      set SQL { INSERT INTO tcid_entries ( categorie, testcaseid, result, iterations, fk_testrun, fk_log_id )
            VALUES ( '$categorie', '$testcaseid', '$result', '$AutoLoop', '$TestRunID', '$LogTableID' ) }

      set SQL [subst $SQL]
      lappend SQL_String  "db"   $SQL

# puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_WriteLogTC: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "

      }
   }

}


proc SQL_NewDefaultTestRun {} {
   global PrgNr AutoLoop



   TlPrint "1 - Default_xxxx-xx-xx"
   TlPrint "2 - Night_xxxx-xx-xx"
   TlPrint "3 - Weekend_xxxx-xx-xx"
   TlPrint "4 - Insert free description"
   TlPrint ""

   set answer [TlInput "Select test run description (Default:1)" "1" 1]
   TlPrint ""
   TlPrint ""

   switch -regexp $answer {

      "1" {
         SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
      }

      "2" {
         SQL_WriteTestRun "Night_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
      }

      "3" {
         SQL_WriteTestRun "Weekend_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
      }
      "4" {
         set DefaultAnswer "Default_$PrgNr [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
         set answer [TlInput "Insert free test run description (Default:) $DefaultAnswer" "$DefaultAnswer" 1]
         TlPrint ""
         SQL_WriteTestRun $answer

      }
      default {
         TlPrint " "
      }
      
   };#switch
   
   set AutoLoop 1


}


proc SQL_WriteTestRun { description } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop
   global currentBranch currentCommit env
   # Achtung DB steht hier f�rs logging noch nicht zur Verf�gung
   # Schleifenz�hler zur�cksetzen damit die neuen Logtabellen wieder mit Index 1 beginnen
   set  AutoLoop 1
   if {$DB_Open} {
      # 2006-12-31 10:42:01
      set start [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

      append SQL_String  "db " "{"  "INSERT INTO testrun ( start, devicenumber, description, branch, commit, author ) "
      append SQL_String  "VALUES ( '$start', '$ActDev', '$description', '$currentBranch', '$currentCommit', '$env(USERNAME)' )" "}"
#puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_WriteTestRun: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "
         return
      }
      set TestRunID [ db "SELECT LAST_INSERT_ID();"]
      lw " Generate test run: ID: $TestRunID Desc.: $description"
      SQL_CreateLogTable
   }

}



proc SQL_UpdateTestRun { } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop

   if {$DB_Open} {
      # 2006-12-31 10:42:01
      # diese Zeit hier wird sp�ter noch �berschrieben beim Tats�chlichen Ende.
      # wird hier schon mal vorbelegt falls der Interpreter unkontrolliert abschmiert
      set stop [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]

      append SQL_String  "db " "{"  "UPDATE testrun SET iterations = '$AutoLoop' , stop = '$stop' "
      append SQL_String  "WHERE pk_testrun = '$TestRunID'; " "}"
#puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_UpdateTestRun: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "
         return
      }

   }

}

#Updates the test run description of actual log, parameter prefix will be added
proc SQL_UpdateTestRun_DescriptionPrefix {Prefix } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop

   if {$DB_Open} {
      #get actual test run description from data base
      set description [db "SELECT description FROM testrun WHERE pk_testrun = $TestRunID; "]
      #remove {{ }} from SQL result
      set description [join [join $description]]
      TlPrint "description: $description"

      append descriptionNew $Prefix "_" $description

      append SQL_String  "db " "{"  "UPDATE testrun SET description = '$descriptionNew' "
      append SQL_String  "WHERE pk_testrun = '$TestRunID'; " "}"
      #puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_UpdateTestRun: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "
         return
      }
   }
}

proc SQL_CreateLogTable { } {
   global DB_Open  theLogFile ActDev TestRunID AutoLoop LogTableName
   set LogTableName ""
   append LogTableName "Log_" $TestRunID "_" $AutoLoop

   set SQL {CREATE TABLE `dblog`.`$LogTableName` (
     `pk_log_id` int(10) unsigned NOT NULL auto_increment,
     `TIMESTAMP` timestamp NOT NULL default CURRENT_TIMESTAMP,
     `testcaseid` varchar(200) collate latin1_general_ci default NULL,
     `categorie` varchar(200) collate latin1_general_ci NOT NULL,
     `devicenumber` smallint(5) unsigned default NULL,
     `description` text collate latin1_general_ci default NULL,
     `error_flag` int(10) unsigned default NULL,
     `sollwert` double default NULL,
     `istwert` double default NULL,
     `iterations` int(10) unsigned default NULL,
     `script_link` varchar(50) collate latin1_general_ci default NULL,
     `fk_testrun` int(10) unsigned NOT NULL,
     `LogDateTime` datetime default NULL,
     `mSec` int(10) unsigned default NULL,
     PRIMARY KEY  (`pk_log_id`)
   ) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci PACK_KEYS=0 ;}

   set SQL [subst $SQL]

   if {$DB_Open} {

      lappend SQL_String  "db"   $SQL

# puts $SQL_String

      set rc [catch  $SQL_String Msg]

      if {$rc != 0} {
         lw " SQL_CreateLogTable: $SQL_String "
         lw " rc: $rc "
         lw " errMsg: $Msg "
      } else {
         lw " Table $LogTableName was generated"
      }
   }

}



#db "INSERT INTO entries ( LogDateTime, description, fk_testrun) VALUES ( '061211Mon124252-35644' , 'adc_raw_current_i_v  <- 7003.1' , '1')"


# SQL Befehle Ende ------------------------------------------------

# Doxygen Tag:
##Function description : Updates the features used for a campaign
## Prerequisites :
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2022/12/26 | ASY | proc created
#
# E.g. use < SQL_UpdateFeatures> to write the current value of DeviceFeatureList in dblog

#Updates the test run description of actual log, parameter prefix will be added
proc SQL_UpdateFeatures { } {
    global ActDev TestRunID DeviceFeatureList
    set str [join $DeviceFeatureList($ActDev) ,]
    set rc [catch { set res [db "update testrun set features='$str' where pk_testrun = $TestRunID"]}]
    set sqlString "update testrun set features='$str' where pk_testrun = $TestRunID"
    if {$rc != 0} {
	lw " SQL_UpdateTestRun: $sqlString "
	return
    }

}