# CPD Testturm
#
# menu.tcl
#
#
# ----------HISTORY----------
# WHEN   WHO    WHAT
# ?      ?      file created
# 160903 pfeig  IDS-ON / OFF  removed from main folder to subfolders
# 091003 pfeig  The same for endurance tests from each files
# 101203 pfeig  Adaptation CPD
# 170204 pfeig  all
# 080404 pfeig  func_x
# 160404 pfeig  func_x modified
# 230404 pfeig  load Library
# 270105 pfeig  OldErrLogTestId created to differentiate if ErrorLog must be written
# 080305 pfeig  Interruption possibility for the script (theTestProcList == {})
#                The menu has been modified so that x does not bring you to the top menu
#                but a level higher. Also when the automation is interrupted through escape
#                will the menu stay on the level of the interrupted file.
# 280405 pfeig  new test protocol
# 130705 pfeig  AutoLoop
# 120207 grana  Possibiliy to combine any tests from test folder or procedure file added
# 100914 serio  Correction to get "file" command back
#

global theTestProcList
global AutoLoop

set AutoLoop 1

proc openrs {} {
    global theSerialBaud
    global theSerialPort

    TlPrint "Switch on Modbus interface"
    set UserChoices [TlInput "Serial interface No. (default: $theSerialPort)" $theSerialPort ]
    puts "Open serial Modbus Port $UserChoices with $theSerialBaud"
    ModOpen $UserChoices $theSerialBaud 1 1
}

proc Main_Layer {LayerLevel  {InputChoices 0} }  {

    global theTestDir theTestFileList theTestDirList testFilename theTestProcList
    global InitialTestDirList
    global globAbbruchFlag
    global COMPUTERNAME
    global theTestTclFilename errorInfo errorCode libpath Initpath
    global OldErrLogTestId
    global AutoLoop Loop
    global quitFlag exportFlag
    global ActDev TestRunID
    global Def_Layer LayerOption
    global Geraet PrgNr
    global theTestSubDirList
    global theTopScript Reload_Proc
    global  ReadParameterFile_Endurancetest_ON
    global CreateLog DeviceFeatureList ActDev Jenkins remanentDeviceFeatureList

    if {$Jenkins} {
	TlPrint "This is Jenkins"
	TlPrint "===================================================="
	fileTC 1 1

    } else {

	while {1} {
	    #Display top indication of menu depends on the layer
		Write_Flag "NOTRUN"	
	    set  ReadParameterFile_Endurancetest_ON    0
	    if {$LayerLevel == 1} {
		set Loop 1
		set globAbbruchFlag 0
		set Reload_Proc 1
		TlPrint ""
		TlPrint "############################################"
		TlPrint "#        MAIN-MENU                         #"
		TlPrint "#  %-32s        # " "$Geraet"
		TlPrint "#                                          #"
		TlPrint "############################################"
		TlPrint ""
		TlPrint " 0      - All test directories"
		TlPrint ""
	    }
	    if {$LayerLevel == 2} {
		set Loop 1
		set globAbbruchFlag 0
		set Reload_Proc 1
		TlPrint ""
		TlPrint "-----------------------------------------------"
		TlPrint "Test directory : $theTestDir"
		TlPrint "-----------------------------------------------"
		TlPrint ""
		TlPrint " 0      - All test files"
		TlPrint ""
	    }
	    if {$LayerLevel == 3} {
		if {$Reload_Proc == 1} {
		    set theTestProcList {}
		    source $testFilename
		}
		set InputChoices $theTestProcList
		set Loop 1
		set globAbbruchFlag 0
		TlPrint ""
		TlPrint "-----------------------------------------------"
		TlPrint "test procedures from : $testFilename"
		TlPrint "-----------------------------------------------"
		TlPrint ""
		TlPrint " 0      - all test procedures"
		TlPrint ""
	    }
	    init_layer_functions $LayerLevel
	    set i 0
	    #Display each available choice and its corresponding number in this layer
	    foreach dir $InputChoices {
		incr i
		TlPrint [format "%2d      - %s" $i $dir]
		#	      TlPrint "Label_1XXXXXXXXXXXXXXXXXXXXXXXXX"
		#	      puts "i: $i"
	    }
	    set NoOfTCs $i
	    TlPrint ""
	    #Display each available function in this layer
	    foreach func $Def_Layer($LayerLevel) {
		TlPrint $LayerOption($func)
	    }
	    TlPrint ""
	    #give some advices to the user to use special functions
	    if {$LayerLevel == 3} {
		TlPrint " Test procedures can be combined "
		TlPrint " with blanks at will (e.g. 3 8 6)"
		TlPrint " or with current run (e.g. 3 8 6+)"
		TlPrint " or with repeats (e.g. 3 8 6 4x)"
		TlPrint ""
	    }
	    if {$LayerLevel == 1 || $LayerLevel == 2 } {
		TlPrint " Test directories or files can be combined "
		TlPrint " with current run (e.g. 3 8 6+)"
		TlPrint " or with repeats (e.g. 3 8 6 4x)"
		TlPrint ""
	    }

	    set UserChoices [list [TlInput "Menu point" "" 0]]
	    TlPrint ""

	    # answers slpit in list
	    set UserChoices [split $UserChoices " " ]
	    # Delete all braces
	    regsub -all {[][${}\\]} $UserChoices "" UserChoices

	    if {$UserChoices == "t" } {
		set UserChoices [UserTimer]
	    }

	    set DauerMark [regsub -all {[+$]}  "$UserChoices"  "" UserChoices]

	    set ReducedMark [regsub -all {[-$]}  "$UserChoices"  "" UserChoices]

	    set FirstChoice  [lindex $UserChoices 0]
	    # if the list ends mit a x
	    # transform <1 4 9 3x> in <1 4 9 1 4 9 1 4 9>
	    set RepeatMark    [regsub -all {[$x]}  "$UserChoices"  "" UserChoices]
	    set Loops         0
	    set NumRepeat     0

	    if {[llength  $UserChoices ] <= 1} { set RepeatMark 0 }        ;# doesn´t work with an alone x

	    if { $RepeatMark == 1 } {
		# determine number of repetitions
		set NumRepeat [expr  [llength  $UserChoices ] - 1]
		set Loops [lindex $UserChoices $NumRepeat]
		# makes answertorepeat null
		set answertorepeat ""
		for {set i 0} {$i <= [expr $NumRepeat - 1] } {incr i} {
		    #puts the initial answer in an intermediate variable
		    lappend  answertorepeat [lindex $UserChoices $i]
		}
		# unset the initial answer
		unset UserChoices
		for {set i 1} {$i <= $Loops } {incr i} {
		    #create and add initial UserChoices for each number of repetitions
		    lappend  UserChoices $answertorepeat
		}
		regsub -all {[${}]} $UserChoices "" UserChoices
	    }
	    if { [regexp {(quit)} $UserChoices] } {
		set quitFlag [expr !$quitFlag]
		regsub -- {(quit)} $UserChoices "" UserChoices
	    }
	    # Insanity check of the user input
	    if { [regexp {[0-9]} $UserChoices] } {
		# case1: 1 2 5 6x
		# case2: 1 2 5
		foreach TC $UserChoices {

		    # case3: 1 2 5 No>MaxTCNo, case is treated here
		    if { $NoOfTCs < $TC } {
			set FirstChoice "InvalidIn"
		    }

		    # case4: (t OR l OR clear) AND (1 OR 4 OR 5) OR (# $), case is treated here
		    #            TlPrint "TC: $TC"
		    if { ![regexp {[0-9]} $TC] } {
			#               TlPrint "TC: $TC"
			set FirstChoice "InvalidCombi"
		    }
		}
	    }

	    #Define what to do depends on the first answer given
	    switch -regexp $FirstChoice {
		"^sort" {
		    if {$LayerLevel == 2} {
			#print test suites in alphabetic order
			set InputChoices [lsort $InputChoices]
			set theTestFileList [lsort $theTestFileList]
		    }  else {
			TlPrint ""
			TlPrint "wrong input"
		    }
		}
        "export" {
            set exportFlag [expr !$exportFlag] 
            if {$exportFlag} {
                TlPrint "Export turned on" 
            } else { 
                TlPrint "Export turned off"
            }
        }
		"^ShowBit" {
		    ShowBit
		}
		"^delOld" {
		    SQL_DeleteOldLog
		}
		"^cmd" {
		    Commando;
		}
		"^del" {
		    SQL_DeleteLog $TestRunID
		}
		"^new" {
		    SQL_NewDefaultTestRun
		}
		"^[Xx]" {
		    return

		}
		"^[hH]" {

		    Keep_old $LayerLevel

		    # set directory where HW command files exist
		    set theTestDir "TC_try_TTHW"
		    cd $theTestDir
		    TlLogfile "tturm-$COMPUTERNAME.log"
		    if [file exists $theTopScript] {
			# Lese spezielles Top-Script "0top_???.tcl"
			TlPrint "Top-Script: $theTopScript"
			source $theTopScript
		    }  else {
			TlPrint "0top_Single file is missing"
		    }

		    Main_Layer 2 $theTestFileList
		    cd ".."

		    Reload_old $LayerLevel

		    TlLogfile "tturm-$COMPUTERNAME.log"
		}
		"^[sS]" {

		    Keep_old $LayerLevel

		    # set directory where SW command files exist
		    set theTestDir "TC_try_TTSW"
		    cd $theTestDir
		    TlLogfile "tturm-$COMPUTERNAME.log"

		    AutomatedFileLoading $theTopScript

		    Main_Layer 2 $theTestFileList

		    cd ".."

		    Reload_old $LayerLevel

		    TlLogfile "tturm-$COMPUTERNAME.log"
		}
		"^clear" {
		    if { $CreateLog } {
			# All Sub-Logfiles delete
			foreach dir $theTestDirList {
			    TlPrint  "delete $dir/tturm-$COMPUTERNAME.log"
			    if { [catch { set aFile [open "$dir/tturm-$COMPUTERNAME.log" w] ; close $aFile } ]} {
				puts "Error with delete of $dir/tturm-$COMPUTERNAME.log "
			    }
			}
		    }
		    # TXT Logfiles and Default Testruns in DB Delete
		    TlDeleteFile 1 1
		}
		"^all" {

		    set InputChoices [DisplayAllChoices $LayerLevel]

		    set Reload_Proc 0

		}
		"^(IniDir)" {
		    set  theTestDirList $InitialTestDirList
		    set Reload_Proc 1

		    #Reload The test file list before to display again test file in current directory
		    if {$LayerLevel == 2} {
			AutomatedFileLoading $theTopScript
			set InputChoices $theTestFileList
		    }

		    if {$LayerLevel == 1} {
			set InputChoices $theTestDirList
		    }
		}

		"^l" {

		    load_library $LayerLevel
		}

		"^on" {
		    DeviceOn $ActDev 0 ">=0"
		}

		"^off" {
		    DeviceOff $ActDev 1
		}

		"^ActDev" {
		    set ActDev [list [TlInput "set ActDev" "1" 0]]
		}

		"^close" {
		    TlPrint "Modbus closed"
		    ModClose
		}

		"^open" {
		    openrs
		}

		"^0" {
		    if {$LayerLevel == 1} {
			set quitFlag [expr !$quitFlag ]
		    }
		    AllChoicesRun $LayerLevel $UserChoices $RepeatMark $DauerMark $ReducedMark $NumRepeat $Loops
            if {$exportFlag} {export_campaignSynthesis}
		    if {$quitFlag == 1} {
			exec taskkill /f /pid [pid]
		    }

		}

		"^[0-9]+" {

		    UserChoicesRun $LayerLevel $UserChoices $RepeatMark $DauerMark $NumRepeat $Loops
            if {$exportFlag} {export_campaignSynthesis}
		    if {$quitFlag == 1} {
			exec taskkill /f /pid [pid]
		    }
		}
		"InvalidIn" {
		    TlPrint "ATTENTION: TC selected which is not given by the list"
		}
		"InvalidCombi" {
		    TlPrint "ATTENTION: Combination of menu options selected is invalid"
		}
		"^check" {
		    if {$LayerLevel == 1} {
			checkTestsystem
		    }
		}
		"^[fF]" {
		    TlPrint "Firmware Feature activation"
		    TlPrint "Select the current type of firmware : "
		    TlPrint "1 - CIPSafety"
		    TlPrint "2 - ATVPredict"
		    set choice [TlInput "FW " 1]
		    switch  $choice {

			1 {
			    lappend remanentDeviceFeatureList($ActDev) FW_CIPSFTY
			}

			2 {
			    lappend remanentDeviceFeatureList($ActDev) FW_ATVPredict
			}

			default { TlError " Feature not available" }
		    }
		    SQL_UpdateFeatures
		}
		default {
		    if {$FirstChoice != "t" && $FirstChoice != "quit" } {
			TlPrint "wrong input"
		    }

		    set Reload_Proc 1

		    #Reload The test file list before to display again test file in current directory
		    if {$LayerLevel == 2} {
			AutomatedFileLoading $theTopScript
			set InputChoices $theTestFileList
		    }

		    if {$LayerLevel == 1} {
			set InputChoices $theTestDirList
		    }
		}
	    };#switch
	};#while
	return
    }
}

#----------------------------------------------------------------------------------------------------------
#Read File  For Endurancetest
#-----------------------------------------------------------------------------------------------------------
proc  ReplayParameterFileforEnduranceTest {}  {
    global theErrorTextFile  theObjectListFile  theCANObjectListFile  theLimitCheckFile  theVARListFile
    global  theCPDObjectListFile   theCPDVARListFile ReadParameterFile_Endurancetest_ON

    if {$ReadParameterFile_Endurancetest_ON == 0} {
	TlPrint ""
	TlPrint "===================================================================="
	TlPrint " ReadParameterFile for EnduranceTest Starts"
	TlPrint "====================================================================="
	#Read objects and error description
	ReadErrorTextFile       $theErrorTextFile
	ReadObjectListFile      $theObjectListFile
	#ReadCANObjectListFile   $theCANObjectListFile
	ReadLimitCheckFile      $theLimitCheckFile
	ReadCANObjectListFile   $theCANObjectListFile
	ReadVARListFile         $theVARListFile  0    ;# 0=without displaying on the screen
	# for Load Device
	ReadCPDObjectListFile   $theCPDObjectListFile
	ReadCPDVARListFile      $theCPDVARListFile  0
	ReadConfigValues        ;#Read configuration values from ini-File
	TlPrint ""
	TlPrint "===================================================================="
	TlPrint " ReadParameterFile for EnduranceTest is ready"
	TlPrint "====================================================================="
	TlPrint ""
	set ReadParameterFile_Endurancetest_ON 1
    } else {
	TlPrint ""
	TlPrint "===================================================================="
	TlPrint " ReadparameterFile for EnduranceTest is ready"
	TlPrint "====================================================================="
	TlPrint ""
    }
}

#---------------------------------------------------------------------------------------------------------------------
# Initialization of user informations given in each layer
#-------------------------------------------------------------------------

proc init_layer_functions {Layer} {

    global Def_Layer LayerOption
    global quitFlag

    set LayerOption(X)               " X          - Exit"
    set LayerOption(quit)        " 'xx' quit  - Raise/Lower flag to kill Unifast at the end of next test (current status: $quitFlag)"
    set LayerOption(+)               " +          - Add close to the last number for permanent run test (e.g. \"1+\")"
    set LayerOption(-)               " -          - Add close to the 0 for reduced endurance test (e.g. \"0+\")"
    set LayerOption('repeat'x)       " 'repeat'x  - Attach run with x repeats (e.g. \"1 3x\" for 3 repeats)"
    set LayerOption(t)               " t          - Timer"
    set LayerOption(l)               " l          - Load libraries"
    set LayerOption(h)               " h          - Hardware commands"
    set LayerOption(s)               " s          - Software commands"
    set LayerOption(f)               " f          - Set firmware features"
    set LayerOption(file)            " file       - Execute test case IDs listed in a file"
    set LayerOption(exportFlag)      " export     - Exports the campaign synthesys at the end of the campaign"
    if {$Layer == 1} {
	set LayerOption(all)          " all        - Show all test directory"
    } elseif {$Layer == 2} {
	set LayerOption(all)          " all        - Show all TCL files in the directory"
    } elseif {$Layer == 3} {
	set LayerOption(all)          " all        - Show all procedure files in the file"
    }
    if {$Layer == 1} {
	set LayerOption(IniDir)          " IniDir     - Show initial test directory"
    } elseif {$Layer == 2} {
	set LayerOption(IniDir)          " IniDir     - Show initial TCL files in the directory"
    } elseif {$Layer == 3} {
	set LayerOption(IniDir)          " IniDir     - Show initial procedure files in the file"
    }
    set LayerOption(clear)           " clear      - Delete TXT log files and default test runs in data base"
    set LayerOption(cmd)             " cmd        - Enter TCL commands"
    set LayerOption(new)             " new        - Initialize new Data base test log"
    set LayerOption(del)             " del        - Delete current database test log"
    set LayerOption(delOld)          " delOld     - Delete old data base test log"
    set LayerOption(sort)            " sort       - Sort directory alphabetically"
    set LayerOption(open)            " open       - Open serial port"
    set LayerOption(close)           " close      - Close serial port"
    set LayerOption(on)              " on         - Switch current device on"
    set LayerOption(off)             " off        - Switch current device off"
    set LayerOption(ActDev)          " ActDev     - Set active device"
    set LayerOption(ShowBit)         " ShowBit    - Show all bits set in a given parameter"
    if {$Layer == 1} {
	set LayerOption(check)        " check      - Check if everything is ready for a test-run"
    }

    set Def_Layer(1) [list  "X" "+" "-" "'repeat'x" "t" "h" "s" "f" "file" "all" "IniDir" "quit" "clear" "cmd" "new" "del" "delOld" "open" "close" "on" "off" "ActDev" "ShowBit" "check" "exportFlag"]
    set Def_Layer(2) [list  "X" "+" "'repeat'x" "t" "l" "h" "s" "f" "file" "all" "IniDir" "quit" "clear" "cmd" "new" "del" "delOld" "sort" "open" "close" "on" "off" "ActDev" "ShowBit"]
    set Def_Layer(3) [list  "X" "+" "'repeat'x" "t" "l" "h" "s" "f" "file" "all" "IniDir" "quit" "clear" "cmd" "new" "del" "delOld" "open" "close" "on" "off" "ActDev" "ShowBit"]
}

#-------------------------------------------------------------------------
# Execute each automated file present in a given directory
#-------------------------------------------------------------------------

proc TestDir {} {

    global theTestDir theTestFileList globAbbruchFlag theTestProcList testFilename

    while {1} {
	# debugger_break
	set globAbbruchFlag 0
	set anzahlTestfiles [llength $theTestFileList]
	# All test files run automaticaly in a directory
	TlPrint ""
	TlPrint "-----------------------------------------------"
	TlPrint "All tests in $theTestDir"
	TlPrint "-----------------------------------------------"
	TlPrint ""
	set OldErrLogTestId ""
	for {set FileNr 0} {$FileNr < $anzahlTestfiles} {incr FileNr} {
	    set testFilename [lindex $theTestFileList $FileNr]
	    TlPrint ""
	    TlPrint "-----------------------------------------------"
	    TlPrint "Start file $testFilename in directory $theTestDir"
	    TlPrint "-----------------------------------------------"
	    TlPrint ""
	    set theTestProcList {}
	    source $testFilename  ;# Reload source code
	    TestfileRun $testFilename
	    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
	    if {$globAbbruchFlag} {break}
	}
	return
    }
}

# Doxygen Tag:
##Function description : Function that runs the test cases listed in a .txt file
# This function is to be used during the Jenkins integration prototyping phase
# Limitations due to prototyping phase :
# - Fixed input path: C:\Unifast\data\Testturm2.0\ObjektDB\TestCases.txt
# - Fixed output path : C:\unifast\data\Testturm2.0\ObjektDB\TestResults.tap
#
# Script name must respect the following format :
# FolderName, TestCaseName
#
# WHEN       | WHO   | WHAT
# -----------| ------| -----
# 2023/01/5  | ASY   | proc created
# 2024/07/25 | Yahya | updated proc to add results after each TC execution (see issue #2525)
# 2024/08/14 | Yahya | updated proc to catch exceptions when executing test cases (see issue #2656)
#
# E.g. use < fileTC_V2 > to run the tests
proc fileTC_V2 { } {
    global mainpath theTestFileList GlobErr
    #get the file path
    set theExecuteIDFile "$mainpath/ObjektDB/TestCases.txt"
    set theResultFile "$mainpath/ObjektDB/TestResults.tap"
    #open the file and get the data
    set f [open $theExecuteIDFile r]
    set data [read $f]
    close $f
    #Delete old theResultFile if it already exists
    file delete $theResultFile
    #split the data on new line symbol
    set data [split $data "\n"]
    #iterate on the line to extract data
    foreach line $data {
	set line [split $line ,]
	set Folder [lindex $line 0]
	set File [lindex $line 1]
	#			puts "Folder $Folder : file $File"
	#puts data in the array that will contain the tests
	if {$Folder != "" } {
	    lappend folder_testCaseList $line
	}
    }

    foreach folder_testCase $folder_testCaseList {
	set folder [lindex $folder_testCase 0]
	set testCase [lindex $folder_testCase 1]
	#go into the directory
	cd $mainpath//$folder
	#get the list of the applicable test files
	if { [ file exists "0top_Single.tcl"] } {
	    # read special Top-Script "0top_???.tcl"
	    source "0top_Single.tcl"
	} else {
	    TlPrint "0top_Single file is missing"
	}
	puts $theTestFileList
	#load all the testCases
	foreach testFile $theTestFileList {
	    source $testFile
	}

	puts "$testCase"
	set ret [catch "eval $testCase" errMsg]
	if {$ret != 0} {
	    TlError "ErrorInfo: $::errorInfo  ErrorCode: $::errorCode"
	}
	set rf [open $theResultFile a]
	if {$GlobErr != 0} {
	    puts $rf "\[ $testCase \] : FAILED"
	} else {
	    puts $rf "\[ $testCase \] : OK"
	}
	close $rf

	cd $mainpath
    }
}

#-------------------------------------------------------------------------
# Execute procedures wich are referenced in a .txt file
#  File layout:
#  -  One Testcase ID per line
#  -  Only IDs with "TC_" at the beginning can be called
#  -  IDs saved without "TC_"  will be read as a previous "TC_"
#  -  The elements []${}\% and space will be remove from the line
#  -  Lines started with # will be ignored
#  -  empty lines will be ignored
#  -  Do not use tabs!
#-------------------------------------------------------------------------
proc fileTC {CurrentRun Repetition} {

    global mainpath errorInfo errorCode AutoLoop Loop
    global theTestDir theTestFileList globAbbruchFlag COMPUTERNAME
    global theTestDirList testFilename theTestProcList theTestTclFilename
    global theTopScript

    if {($CurrentRun == 1) || ($Repetition != 0)} {
	set Loop 1
    }

    set theExecuteIDFile ""
    set RunTC_0Init 0

    #Rename test run description to make known that test run is reduced
    SQL_UpdateTestRun_DescriptionPrefix "reduced_(file)"
    if {!$Jenkins} {
	TlPrint ""
	TlPrint "Enter file location or"
	TlPrint "press return for default: $mainpath/ObjektDB/TestCases.txt"
	set theExecuteIDFile [TlInput "File location?" "" 0]
    }
    if {$theExecuteIDFile == ""} {
	set theExecuteIDFile "$mainpath/ObjektDB/TestCases.txt"
    }

    if [file exists $theExecuteIDFile] {
	if {!$Jenkins} {
	    TlPrint ""
	    set RunTC_0Init [ TlInput "Execute TC_0Init? (y or n)" "" 1]
	    switch -exact $RunTC_0Init {
		"0" -
		"N" -
		"n" {set RunTC_0Init 0}
		default {set RunTC_0Init 1}
	    }
	} else { set RunTC_0Init 0}

	TlPrint ""
	TlPrint "Execute test cases from $theExecuteIDFile"
	TlPrint ""

	set file [open $theExecuteIDFile r]

	set theExecuteIDFileList ""
	set theExecutedIDList ""

	if { $Jenkins} {
	    set theTestDirList ""
	}

	while { [gets $file line] >= 0 } {
	    set line [RemoveSpaceFromList $line]
	    set wordList [split $line ","]
	    TlPrint "wordList : $wordList"
	    #	    if {$Jenkins} {
	    lappend theTestDirList [lindex $wordList 0 ]
	    #		}
	    set TestCaseIDJenkins([RemoveSpaceFromList [lindex $wordList 1]]) [RemoveSpaceFromList [lindex $wordList 0]]

	    set line [lindex $wordList 1]

	    if {$CurrentRun} {
		if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		if {$globAbbruchFlag} {break}
	    }

	    # Remove any spaces / special characters, if present
	    regsub -all {[][${}\\% ]} $line "" line

	    #Empty lines don't take into account
	    if {$line != ""} {
		#Lines started with # don't take into account
		if {[string first "#" $line] != 0} {
		    # TC_ prepend, if not available
		    #               if {[string first "TC_" $line] != 0} {
		    #                  lappend theExecuteIDFileList "TC_$line"
		    #               } else {
		    lappend theExecuteIDFileList $line
		    #               }
		}
	    }
	}

	TlPrint " TestCaseIDJenkins : [array names TestCaseIDJenkins]"
	TlPrint "TheTestDirList : $theTestDirList"
	close $file

	#startin debug process
	foreach item $theExecuteIDFileList {
	    TlPrint "$item"
	}

	set ListTestCase [lsort -increasing [array get TestCaseIDJenkins]]
	set SizeTestCase [array size TestCaseIDJenkins]
	#	  set ResultFile [open "C:/Schneider/Developments/Jenkins-slave-svp/workspace/UniFastBasic/results/op-1741_test.tap" "w"]
	#	  puts $ResultFile [lindex $ListTestCase 0 ]..[lindex $ListTestCase [expr ($SizeTestCase-1)]]
	#	  close $ResultFile

	# If empty data, don't run the test
	if {$theExecuteIDFileList != ""} {
	    if {![GetSysFeat "PACY_APP_FORTIS"]} {
		if {$CurrentRun} {
		    global libpath
		    # exec cmd.exe /c $mainpath/Autoit/minimize.vbs
		    # exec C:/AutoIt3/AutoIt3.exe $libpath/Autoit/minimize.au3
		}
	    }
	    while {1} {
		if {$CurrentRun} {
		    if {[CheckBreak] == 1} {break}
		    if {$globAbbruchFlag} {break}
		    TlPrint ""
		    TlPrint "============================================================="
		    TlPrint "Start cycle $Loop of all categorys in File: $theExecuteIDFile"
		    TlPrint "============================================================="
		    TlPrint ""
		    TlReport "Test cycle $Loop started %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		}

		if {$Repetition != 0} {
		    if {[CheckBreak] == 1} {break}
		    if {$globAbbruchFlag} {break}
		    TlPrint ""
		    TlPrint "============================================================="
		    TlPrint "Start cycle $Loop out of $Repetition of all categories in File: $theExecuteIDFile"
		    TlPrint "============================================================="
		    TlPrint ""
		    TlReport "Test cycle $Loop started %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		}

		foreach dir $theTestDirList {

		    cd $mainpath
		    cd $dir
		    set theTestDir $dir

		    TlLogfile "tturm-$COMPUTERNAME.log"

		    # Make test files list empty and then load from new reading of Top-Script
		    set theTestFileList {}

		    if [file exists $theTopScript] {
			# read special Top-Script "0top_???.tcl"
			source $theTopScript
		    } else {
			TlPrint "0top_Single.tcl file is missing"
		    }

		    foreach testFilename $theTestFileList {

			# Make the list of procedures empty and reload it from testfile source code
			set theTestProcList {}
			source $testFilename

			# check if test procedures to be used exist in the test file
			set NumberOfProcs 0
			foreach testproc $theTestProcList {
			    if {[lsearch -exact $theExecuteIDFileList $testproc ] != (-1)} { incr NumberOfProcs }
			}

			foreach testproc $theTestProcList {

			    # search for testproc in theExecuteIDFileList
			    # TestfileStart is run, if exist a corresponding procedure in the file
			    # TestfileStop is run, if exist a corresponding procedure in the file
			    # TC_0init allways run
			    if {[lsearch -exact $theExecuteIDFileList $testproc ] != (-1) \
				    || ( ( $NumberOfProcs > 0) && ([regexp "TestfileStart" $testproc])) \
				    || ( ( $NumberOfProcs > 0) && ([regexp "TestfileStop" $testproc])) \
				    || ( ( $dir == "TC_0Init" ) && ( $RunTC_0Init == 1 )) } {

				set theTestTclFilename "$dir/$testFilename"

				TlPrint ""
				TlPrint "Running $theTestTclFilename: $testproc"
				TlPrint "%s" [clock format [clock seconds] -format "%a %d.%m.%y %H:%M"]
				TlPrint ""

				set rc [catch "eval $testproc" errMsg]
				if {$rc != 0} {
				    TlError "ErrorInfo: $errorInfo  ErrorCode: $errorCode"
				}

				WriteReportTest   ;# TestReport written
				if {[CheckBreak] == 1} {set globAbbruchFlag 1 }
				if {$globAbbruchFlag} {break}

				lappend theExecutedIDList $testproc

			    } ;# if

			    if {$globAbbruchFlag} {break}

			} ;# foreach testproc

			if {$globAbbruchFlag} {break}

		    } ;# foreach testfile

		    if {$globAbbruchFlag} {break}

		} ;# foreach dir#

		TlLogfile "tturm-$COMPUTERNAME.log"

		if {$CurrentRun} {
		    TlReport "Test cycle $Loop ended %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		}

		cd $mainpath

		foreach testproc_executed $theExecuteIDFileList {

		    if {$globAbbruchFlag} {break}

		    # Test if all test procedures were performed in theExecuteIDFileList
		    if {[lsearch -exact $theExecutedIDList $testproc_executed ] == (-1)} {

			TlTestCase "_Main.tcl" "$testproc_executed" "Compare tests from .txt file with executed tests"

			TlError "$testproc_executed from $theExecuteIDFile not found"

		    } ;# if

		} ;# foreach testproc_executed

		#Create a new default test run after the previous test run has been finished
		if {($Loop >= $Repetition) && ($Repetition != 0)} {
		    SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
		    break
		}

		if {($CurrentRun) || ($Loop < $Repetition)} {
		    if {[CheckBreak] == 1} {set globAbbruchFlag 1 }
		    if {$globAbbruchFlag} {break}
		    incr Loop
		    incr AutoLoop
		    SQL_CreateLogTable
		}  else {break}

	    };#while 1

	} else {

	    TlPrint ""
	    TlPrint "No test cases found in $theExecuteIDFile"
	    TlPrint ""

	} ;# if {$theExecuteIDFileList != ""}

    } else {

	TlPrint ""
	TlPrint "File $theExecuteIDFile does not exist"
	TlPrint ""

    } ;#if

}

#-------------------------------------------------------------------------
# Running an entire file
#-------------------------------------------------------------------------

proc TestfileRun {testFilename} {
    global theTestDir theTestTclFilename globAbbruchFlag
    global errorInfo errorCode
    global theTestProcList
    global TestsBlocked

    set StartList $theTestProcList

    set theTestTclFilename "$theTestDir/$testFilename"

    set TestsBlocked 0

    foreach procedure $theTestProcList {
	# Demolition way through the script
	# Reset theTestProcList in TestFileStart
	if {$theTestProcList != $StartList }    {
	    if {$theTestProcList != {} } {
		TlPrint ""
		TlPrint "Running $theTestTclFilename: $theTestProcList"
		TlPrint "%s" [clock format [clock seconds] -format "%a %d.%m.%y %H:%M"]
		TlPrint ""
		Write_Flag "RUN"
		set rc [catch "eval $theTestProcList" errMsg]
		if {$rc != 0} {

		    TlError "ErrorInfo: $errorInfo  ErrorCode: $errorCode"

		} else {
		    WriteReportTest   ;# emit the test report
		    set UniCancel [Check_Flag]
			if {$UniCancel == "1"} {
				exec taskkill /f /pid [pid]
			}
		}
	    }
	    return
	}

	TlPrint ""
	TlPrint "Running $theTestTclFilename: $procedure"
	TlPrint "%s" [clock format [clock seconds] -format "%a %d.%m.%y %H:%M"]
	TlPrint ""
	Write_Flag "RUN"
	set rc [catch "eval $procedure" errMsg]
	if {$rc != 0} {
	    TlError "ErrorInfo: $errorInfo  ErrorCode: $errorCode"
	}

	WriteReportTest   ;# emit the test report
	set UniCancel [Check_Flag]
	if {$UniCancel == "1"} {
		exec taskkill /f /pid [pid]
	}
	if {[CheckBreak] == 1} {set globAbbruchFlag 1}
	if {$globAbbruchFlag} {break}
    }
}

#-------------------------------------------------------------------------
# Load libraries contained the library directory
#-------------------------------------------------------------------------

proc load_library {Layer} {

    global libpath LibFileList LibFileList errMsg errorInfo globAbbruchFlag

    #isn't permitted in the first layer of menu
    if {$Layer == 1} {
	TlPrint ""
	TlPrint "wrong input"
	return

    }

    set LibFileList [glob $libpath/*.tcl];  # All TCL files in the library directory
    set anzahlLibfiles [llength $LibFileList]

    for {set i 0} {$i < $anzahlLibfiles} {incr i} {
	set PathLibFilename [lindex $LibFileList $i]

	set LibFilename [split $PathLibFilename /]
	set Anz [expr [llength $LibFilename] -1 ]
	set LibFilename [lindex $LibFilename $Anz ]

	#Display all present libraries with an attributed number
	TlPrint [format " %2d - %s" [expr $i+1] $LibFilename]
	if {[CheckBreak] == 1} {set globAbbruchFlag 1}
	if {$globAbbruchFlag} {break}

    }

    #Ask at the user which library to load

    set answerLib [TlInput "Menu point" "" 0]
    TlPrint ""
    if { $answerLib != 0 } {

	set LibNr    [expr $answerLib - 1]
	set PathLibFilename [lindex $LibFileList $LibNr ]

	TlPrint ""
	TlPrint "Load library: %s" $PathLibFilename
	TlPrint ""
	set rc [catch "eval source $PathLibFilename" errMsg]
	if {$rc != 0} {
	    TlPrint $errMsg
	    TlPrint "ErrorInfo: $errorInfo"
	}
    } else {
	TlPrint "No library for 0"
    };# if answerLib

}

proc Check_Flag {} {
	global mainpath
	
	set file [open "$mainpath/ObjektDB/CancelFlag.txt" r]
	set value [gets $file]
	close $file
	return $value
}

proc Write_Flag {new_value} {
	global mainpath
	
	
	# Define the file path
	set file_path "$mainpath/ObjektDB/CancelFlag.txt"
	
	# Check if the file exists
	if {![file exists $file_path]} {
		
		# Open the file for writing
		set file_id [open $file_path w]

		# Write the specified content
		puts $file_id "0"
		puts $file_id "NOTRUN"
	
		# Close the file
		close $file_id
	
		puts "File created and content written"
	} 
	
	# Read the entire file into a list of lines
	set file [open $file_path r]
	set lines [split [read $file] "\n"]
	close $file
	
	# Overwrite the second line with the new value
	set lines [lset lines 1 $new_value]

	# Write the modified lines back to the file
	set file [open $file_path w]
	puts $file [join $lines "\n"]
	close $file
}

#-----------------------------------------------------------------------------
# Keep actual layer information that can be reset after an other layer calling
#-----------------------------------------------------------------------------
proc Keep_old {Layer} {

    global testFilename theTestProcList theTestDir theTestFileList
    global oldFilename oldTestProcList oldTestDir oldFileList

    #If in layer 2 and 3 go to previous directory
    #keep some informations will be changed by a function
    if {$Layer == 3} {
	set oldFilename $testFilename
	set oldTestProcList $theTestProcList
    }
    if {$Layer != 1} {
	cd ".."
	set oldTestDir $theTestDir
	set oldFileList $theTestFileList
    }

}

#-------------------------------------------------------------------------
# Restore old information stored in Keep_old function
#-------------------------------------------------------------------------

proc Reload_old {Layer} {

    global testFilename theTestProcList theTestDir theTestFileList
    global oldFilename oldTestProcList oldTestDir oldFileList

    #Reset global variables as before the a function
    #return to the good directory
    if {$Layer != 1} {
	set theTestFileList $oldFileList
	set theTestDir $oldTestDir
	cd $theTestDir
    }

    if {$Layer == 3} {
	set theTestProcList $oldTestProcList
	set testFilename $oldFilename

    }

}

#----------------------------------------------------------------------------------------------
# Function to display all user choices for each layer (not only initialization defined choices)
#----------------------------------------------------------------------------------------------

proc DisplayAllChoices {Layer} {

    global COMPUTERNAME
    global theTopScript
    global theTestDirList theTestFileList testFilename theTestProcList
    global InputChoices theTestSubDirList

    switch $Layer {

	"1" {
	    set theTestDirList $theTestSubDirList
	    return $theTestSubDirList
	}

	"2" {
	    set theTestFileList [glob *.tcl]
	    return $theTestFileList
	}

	"3" {
	    set theTestProcList {}
	    set file [open $testFilename r]
	    foreach line [split [read -nonewline $file] "\n"] {
		set line [split $line " "]
		if {[lindex $line 0] == "append_test"} {
		    lappend theTestProcList [lindex  $line 2]
		}
	    }
	    close $file

	    return {}

	}

	default {}

    }

}

#-------------------------------------------------------------------------
# Reload each automatic execution files in a give directory
#-------------------------------------------------------------------------

proc AutomatedFileLoading {TopScript} {

    global theTestFileList

    if [file exists $TopScript] {
	# Read special 0top script "0top_???.tcl"
	TlPrint "Top-Script: $TopScript"
	source $TopScript
    }  else {
	TlPrint "0top_Single.tcl file is missing"
    }
}

#-------------------------------------------------------------------------
# Update information in repeat mode
#-------------------------------------------------------------------------

proc RepeatInfoUpdate {LoopRep counter counter_nominator counter_denominator UserAnswer Bool_Dauer Bool_Rep} {

    global AutoLoop Loop COMPUTERNAME

    upvar $LoopRep Loop_up
    upvar $counter count_up
    upvar $counter_nominator count_nom_up

    #set parameter for the repeat management during the reading of file list
    if {$count_up >= [llength $UserAnswer]} {
	if {$Bool_Dauer == 1}  {
	    set count_up 0
	} else {
	    set Loop_up 0
	}
    }

    #set parameter for the repeat management at the end of the reading of file list
    if {$count_up < [llength $UserAnswer]} {
	set Loop_up 1
	incr count_up
    }

    if { $Bool_Rep == 1 } {
	incr count_nom_up
	set OldLoop $Loop
	set Loop [expr int( $count_nom_up / $counter_denominator)]
	if {($OldLoop != $Loop) && $Loop_up} {
	    incr AutoLoop
	    SQL_CreateLogTable

	}

    }

}

#-------------------------------------------------------------------------
# Running all given user choices
#-------------------------------------------------------------------------

proc AllChoicesRun {Layer answer Repeat dauerlauf reduced counter_number counter_target} {

    global theTestDir theTestFileList theTestDirList testFilename theTestProcList
    global globAbbruchFlag
    global COMPUTERNAME
    global OldErrLogTestId
    global AutoLoop Loop
    global theTopScript Reload_Proc
    global mainpath libpath TraceStatistics

    set firstanswer  [lindex $answer 0]

    set counter_x  $counter_number

    #Treat the answer corresponding to the layer
    switch $Layer {

	"1" {

	    set Loop 1
	    set counter_Repeat  1
	    if {$dauerlauf || $reduced} {
		set TraceStatistics 1
		if {$reduced} {
		    set reducedTestExecution 1
		    SQL_UpdateTestRun_DescriptionPrefix "SkipLot"
		}
	    }
	    if {![GetSysFeat "PACY_APP_FORTIS"] && ![GetSysFeat "EAETower1"]} {
		#exec cmd.exe /c $mainpath/minimize.vbs
		exec C:/AutoIt3/AutoIt3.exe $libpath/Autoit/minimize.au3 &
	    }
	    while {1} {
		#Display informations corresponding to the chosen function
		if {$reduced} {
		    TlPrint ""
		    TlPrint "============================================================="
		    TlPrint "Start reduced cycle $Loop of all categories on PC: $COMPUTERNAME"
		    TlPrint "============================================================="
		    TlPrint ""
		}  elseif {$dauerlauf} {
		    TlPrint ""
		    TlPrint "============================================================="
		    TlPrint "Start cycle $Loop of all categories on PC: $COMPUTERNAME"
		    TlPrint "============================================================="
		    TlPrint ""
		} elseif {$Repeat} {
		    TlPrint "***************************************************"
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start repeat cycle $counter_Repeat out of $counter_target of all directories on PC: $COMPUTERNAME"
		    TlPrint "-----------------------------------------------"
		    TlPrint "***************************************************"
		}
		TlReport "Test cycle $Loop in all directories started %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]

		#Treat each test case directory
		foreach dir $theTestDirList {
		    set theTestDir $dir
		    TlPrint ""
		    TlPrint "-----------------------------------------------"
		    TlPrint "Open directory $theTestDir"
		    TlPrint "-----------------------------------------------"
		    TlPrint ""
		    #enter in the directory
		    cd $dir
		    TlLogfile "tturm-$COMPUTERNAME.log"

		    AutomatedFileLoading $theTopScript

		    #Run the TestDir procedure which will execute each file in this directory
		    TestDir
		    #Come back to the previous directory
		    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		    if {$globAbbruchFlag} {
			TlReport "Test was stopped by user in directory: $dir"
			SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
			break

		    }
		    cd ".."
		    TlLogfile "tturm-$COMPUTERNAME.log"

		};#foreach
		TlReport "Test cycle $Loop in all directories ended %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		#check if the Esc touch has been pressed to stop running
		if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		if {$globAbbruchFlag} {

		    #Call sublayer
		    Main_Layer 3 ;#$theTestProcList

		    #Call sublayer
		    Main_Layer 2 $theTestFileList

		    #come back to the previous directory
		    cd ".."
		    TlLogfile "tturm-$COMPUTERNAME.log"
		    SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
		    break

		}

		#Stop running if all repeats have been executed in case of repeat mode
		if {$counter_Repeat >= $counter_target && !$dauerlauf && !$reduced} {
		    #SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
		    break
		}
		incr Loop
		incr AutoLoop
		incr counter_Repeat
		SQL_CreateLogTable
	    };#while 1
	}

	"2" {
	    set counter_Repeat  1
	    while {1} {
		TlReport "Start cycle $Loop: test case $theTestDir %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		set OldErrLogTestId ""
		#Display informations corresponding to the chosen function
		if {$dauerlauf} {
		    TlPrint ""
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start cycle $Loop of all files in directory $theTestDir"
		    TlPrint "-----------------------------------------------"
		    TlPrint ""
		    set emptyList {}
		    TlPrintIntern P "----------------------" emptyList
		    TlPrintIntern P "Start cycle $Loop" emptyList
		    TlPrintIntern P "----------------------" emptyList
		} elseif {$Repeat} {
		    TlPrint "***************************************************"
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start repeat cycle $counter_Repeat out of $counter_target of all files in directory $theTestDir"
		    TlPrint "-----------------------------------------------"
		    TlPrint "***************************************************"
		}
		#Treat each file in a given test case directory
		for {set i 0} {$i < [llength $theTestFileList]} {incr i} {
		    set testFilename [lindex $theTestFileList $i]
		    TlPrint ""
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start file $testFilename in directory $theTestDir"
		    TlPrint "-----------------------------------------------"
		    TlPrint ""
		    #load each proc must be executed in test
		    set theTestProcList {}
		    source $testFilename  ;# Reload source code
		    #Run the TestfileRun procedure which will execute each procedure of this file
		    TestfileRun $testFilename
		    #check if the Esc touch has been pressed to stop running
		    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		    if {$globAbbruchFlag} {
			TlReport "Test was stopped by user in file: $testFilename in directory: $theTestDir"
			break

		    }

		}
		TlReport "End  cycle $Loop: test case $theTestDir %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]

		#check if the Esc touch has been pressed to stop running
		if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		if {$globAbbruchFlag} {

		    #Call sublayer
		    Main_Layer 3 ;#$theTestProcList

		    break

		}

		#Stop running if all repeats have been executed in case of repeat mode
		if {$counter_Repeat >= $counter_target && !$dauerlauf} {break}
		incr Loop
		incr AutoLoop
		incr counter_Repeat
		SQL_CreateLogTable

	    } ;# while
	}

	"3" {

	    set counter_Repeat  1

	    if {$Reload_Proc == 1} {
		set theTestProcList {}
		source $testFilename
	    } else {set Reload_Proc 1}

	    while {1} {
		TlReport "Start cycle $Loop in $testFilename %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		set OldErrLogTestId ""
		#Display informations corresponding to the chosen function
		if {$dauerlauf} {
		    TlPrint ""
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start cycle $Loop of all procedures in test file $testFilename"
		    TlPrint "-----------------------------------------------"
		    TlPrint ""
		    set emptyList {}
		    TlPrintIntern P "----------------------" emptyList
		    TlPrintIntern P "Start cycle $Loop" emptyList
		    TlPrintIntern P "----------------------" emptyList
		} elseif {$Repeat} {
		    TlPrint ""
		    TlPrint "***************************************************"
		    TlPrint "-----------------------------------------------"
		    TlPrint "Start repeat cycle $counter_Repeat out of $counter_target of all procedures in file $testFilename"
		    TlPrint "-----------------------------------------------"
		    TlPrint "***************************************************"
		}

		#Execute each procedure contained in the file
		TestfileRun $testFilename

		TlReport "End cycle $Loop in $testFilename %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		#check if the Esc touch has been pressed to stop running
		if {[CheckBreak] == 1} {set globAbbruchFlag 1}
		if {$globAbbruchFlag} {break}

		#Stop running if all repeats have been executed in case of repeat mode
		if {$counter_Repeat >= $counter_target && !$dauerlauf} {break}
		incr AutoLoop
		incr counter_Repeat
		incr Loop
		SQL_CreateLogTable
	    }
	}
    }
}

#-------------------------------------------------------------------------
# Running user choices if with - + or x or open the next layer
#-------------------------------------------------------------------------

proc UserChoicesRun {Layer answer Repeat dauerlauf counter_number counter_target} {

    global theTestDir theTestFileList theTestDirList testFilename theTestProcList
    global globAbbruchFlag
    global COMPUTERNAME
    global theTestTclFilename  errorCode
    global OldErrLogTestId
    global AutoLoop Loop
    global theTopScript Reload_Proc
    global TestsBlocked TraceStatistics

    set firstanswer  [lindex $answer 0]

    set counter_x  $counter_number

    #Treat the response corresponding to the layer
    switch $Layer {

	"1" {
	    set TraceStatistics 1
	    if { $firstanswer  > [ llength $theTestDirList] }  {
		TlPrint "Answer : $firstanswer"
	    } else {

		#Run files contained in the given Directory if enter with a + or a x
		if {$dauerlauf || $Repeat || [llength $answer] > 1} {
		    set counter_Repeat  1
		    set Loop_Repeat 1
		    while {1} {

			TlReport "Test cycle $Loop in given directories started %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]

			#Display informations corresponding to the chosen function
			if { $dauerlauf} {
			    TlPrint ""
			    TlPrint "============================================================="
			    TlPrint "Start cycle $Loop of given categories"
			    TlPrint "============================================================="
			    TlPrint ""
			}

			#read each given directory
			for {set i 0} {$i < [llength $answer]} {incr i} {
			    #set the current directory
			    set directory [lindex $answer $i]
			    set dir [lindex $theTestDirList [expr $directory - 1]]
			    set theTestDir $dir

			    #Display informations corresponding to the chosen function
			    if { $Repeat } {
				TlPrint ""
				TlPrint "***************************************************"
				TlPrint "-----------------------------------------------"
				TlPrint "Start repeat cycle [expr int( $counter_x / $counter_number)] out of $counter_target of all files in $theTestDir"
				TlPrint "-----------------------------------------------"
				TlPrint "***************************************************"
				TlPrint ""
			    } else {
				TlPrint "============================================================="
				TlPrint "Start category $theTestDir"
				TlPrint "============================================================="
			    }

			    #Change directory
			    cd $dir
			    TlLogfile "tturm-$COMPUTERNAME.log"

			    AutomatedFileLoading $theTopScript

			    #Execute TestDir proc to run each file in the current directory
			    TestDir

			    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
			    if {$globAbbruchFlag} {
				TlReport "Test was stopped by user in directory: $dir"
				break

			    }

			    #come back to the previous directory
			    cd ".."

			    TlLogfile "tturm-$COMPUTERNAME.log"

			    RepeatInfoUpdate Loop_Repeat counter_Repeat counter_x $counter_number $answer $dauerlauf $Repeat

			}
			TlReport "Test cycle $Loop in given directories ended %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]

			#check if the Esc touch has been pressed to stop running
			if {[CheckBreak] == 1} {set globAbbruchFlag 1}
			if {$globAbbruchFlag} {

			    #Call sublayer
			    Main_Layer 3 ;#$theTestProcList

			    #Call previous layer
			    Main_Layer 2 $theTestFileList

			    #come back to the previous directory
			    cd ".."
			    TlLogfile "tturm-$COMPUTERNAME.log"
			    break
			}

			#Stop running if all repeats have been executed in case of repeat mode
			if {($dauerlauf == 0) && ($Loop_Repeat == 0)}  {break}
			incr Loop
			incr AutoLoop
			SQL_CreateLogTable

		    };#while 1
		}  else {
		    #if no repeat or current run, the response must be one number
		    if {[llength $answer] == 1} {
			#Define the next directory layer
			set dir [lindex $theTestDirList [expr $answer - 1]]
			set theTestDir $dir
			#enter in the directory
			cd $dir
			TlLogfile "tturm-$COMPUTERNAME.log"

			AutomatedFileLoading $theTopScript

			#Call sublayer
			Main_Layer 2 $theTestFileList

			#come back to the previous directory
			cd ".."
			TlLogfile "tturm-$COMPUTERNAME.log"

		    } else {TlPrint "wrong input"}
		};#if dauerlauf/repeat

	    };#if wrong answer
	}

	"2" {

	    if { $firstanswer  > [ llength $theTestFileList] }  {
		TlPrint "Answer : $firstanswer"

	    } else {

		#Run given files if enter with a + or a x
		if { $dauerlauf || $Repeat || [llength $answer] > 1} {
		    set counter_Repeat  1
		    set Loop_Repeat 1
		    while {1} {

			TlReport "Start cycle $Loop in given files of test case $theTestDir %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
			set OldErrLogTestId ""

			#Display informations corresponding to the chosen function
			if { $dauerlauf} {

			    TlPrint ""
			    TlPrint "-----------------------------------------------"
			    TlPrint "Start cycle $Loop of given files in directory $theTestDir"
			    TlPrint "-----------------------------------------------"
			    TlPrint ""
			    set emptyList {}
			    TlPrintIntern P "----------------------" emptyList
			    TlPrintIntern P "Start cycle $Loop" emptyList
			    TlPrintIntern P "----------------------" emptyList
			    TlPrint ""
			}

			#read each answer given file
			for {set i 0} {$i < [llength $answer]} {incr i} {

			    #set the current file
			    set answerTest [lindex $answer $i]
			    set testFilename [lindex $theTestFileList [expr $answerTest - 1]]
			    #Display informations corresponding to the chosen function
			    if {$Repeat} {
				TlPrint ""
				TlPrint "***************************************************"
				TlPrint "-----------------------------------------------"
				TlPrint "Start repeat cycle [expr int( $counter_x / $counter_number)] out of $counter_target of $testFilename in $theTestDir"
				TlPrint "-----------------------------------------------"
				TlPrint "***************************************************"
				TlPrint ""

			    } else {
				TlPrint ""
				TlPrint "-----------------------------------------------"
				TlPrint "Start file $testFilename in directory $theTestDir"
				TlPrint "-----------------------------------------------"
				TlPrint ""
			    }

			    #load each proc must be executed in test
			    set theTestProcList {}
			    source $testFilename  ;# Reload source code

			    #Run TestfileRun proc which will execute each proc of the file
			    TestfileRun $testFilename

			    #check if the Esc touch has been pressed to stop running
			    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
			    if {$globAbbruchFlag} {

				TlReport "Test was stopped by user in file: $testFilename in directory: $theTestDir"
				break

			    }

			    RepeatInfoUpdate Loop_Repeat counter_Repeat counter_x $counter_number $answer $dauerlauf $Repeat

			} ;# for
			TlReport "End cycle $Loop in given files of test case $theTestDir %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
			if {$globAbbruchFlag} {

			    #Call sublayer
			    Main_Layer 3 ;#$theTestProcList

			    break

			}

			#Stop running if all repeats have been executed in case of repeat mode
			if {($dauerlauf == 0) && ($Loop_Repeat == 0)}  {break}
			incr AutoLoop
			incr Loop
			SQL_CreateLogTable

		    } ;# while

		} else {

		    #Define the next file sublayer
		    set FuncNr [expr $answer - 1]
		    set testFilename [lindex $theTestFileList $FuncNr ]

		    #Call sublayer
		    Main_Layer 3 ;#$theTestProcList

		} ;#if dauerlauf/repeat

	    };#if wrong input
	}

	"3" {

	    # procedure excution, in repeat mode or in endurence mode
	    set Loop_Repeat 1
	    set counter_Repeat  1
	    set TestsBlocked 0

	    TlReport "Start cycle $Loop in given proc of file $testFilename %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]

	    if { $firstanswer  > [ llength $theTestProcList] }  {
		TlPrint "Answer : $firstanswer"
	    } else {

		if {$Reload_Proc == 1} {
		    set theTestProcList {}
		    source $testFilename
		} else {set Reload_Proc 1}

		while {1} {
		    set OldErrLogTestId ""
		    set theTestTclFilename "$theTestDir/$testFilename"
		    #Display informations corresponding to the chosen function
		    if {$dauerlauf} {
			TlPrint ""
			TlPrint "-----------------------------------------------"
			TlPrint "Start cycle $Loop of given procedures in file $theTestTclFilename"
			TlPrint "-----------------------------------------------"
			TlPrint ""
			set emptyList {}
			TlPrintIntern P "----------------------" emptyList
			TlPrintIntern P "Start cycle $Loop" emptyList
			TlPrintIntern P "----------------------" emptyList
			TlPrint ""
		    }

		    for {set i 0} {$i < [llength $answer]} {incr i} {
			#set the list of proc
			set answer_func [lindex $answer [expr $counter_Repeat - 1]]
			if { $answer_func > [ llength $theTestProcList] }  {
			    TlPrint "Answer : $answer_func"
			    break
			}

			#set current proc
			if {[catch {set procedure [lindex $theTestProcList [expr $answer_func - 1 ]]}] } {
			    TlPrint "wrong input 1"
			    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
			    if {$globAbbruchFlag} {break}
			} else {
			    #Display informations corresponding to the chosen function
			    if {$Repeat} {
				TlPrint ""
				TlPrint "***************************************************"
				TlPrint "-----------------------------------------------"
				TlPrint "Start repeat cycle [expr int( $counter_x / $counter_number)] out of $counter_target of procedures $procedure in $theTestTclFilename"
				TlPrint "-----------------------------------------------"
				TlPrint "***************************************************"
				TlPrint ""

			    } else {

				TlPrint ""
				TlPrint "-------------------------------------------------"
				TlPrint "Running $theTestTclFilename: $procedure"
				TlPrint "-------------------------------------------------"
				TlPrint "At %s" [clock format [clock seconds] -format "%a %d.%m.%y %H:%M"]
				TlPrint ""
			    }
				Write_Flag "RUN"
			    #run procedure
			    set rc [catch "eval $procedure" errMsg]
				
			    if {$rc != 0} {
				TlError "Msg: $errMsg errorCode: $errorCode"
			    }

			    WriteReportTest   ;# emit the test report
				
				set UniCancel [Check_Flag]
				if {$UniCancel == "1"} {
					exec taskkill /f /pid [pid]
				}

			    RepeatInfoUpdate Loop_Repeat counter_Repeat counter_x $counter_number $answer $dauerlauf $Repeat

			    if {[CheckBreak] == 1} {set globAbbruchFlag 1}
			    if {$globAbbruchFlag} {
				TlReport "Test was stopped by user in procedure: $procedure in file: $testFilename "
				break
			    }
			} ;# catch
		    } ;# for

		    TlReport "End cycle $Loop in given proc of file $testFilename %s" [clock format [clock seconds] -format "%a %d.%m.%Y %H:%M"]
		    #check if the Esc touch has been pressed to stop running

		    if {$globAbbruchFlag} {break}

		    #Stop running if all repeats have been executed in case of repeat mode
		    if {($dauerlauf == 0) && ($Loop_Repeat == 0)}  {break}
		    incr Loop
		    incr AutoLoop
		    SQL_CreateLogTable

		} ;# while {1}
	    } ;# if { $answer_func > [ llength $theTestProcList] }
	}
    }
}

#------------------------------------------------------------------------------------------------------
proc UserTimer {} {

    global globAbbruchFlag

    TlPrint "current time : %s   am : %s" [clock format [clock seconds] -format "%H:%M"]  [clock format [clock seconds] -format "%a %d.%m.%Y"]
    TlPrint ""
    TlPrint "Start time has to be today!"
    TlPrint "Please look after right input!"
    TlPrint ""
    set StartTime [TlInput "Time started: HH:MM" "" 0]
    TlPrint ""
    set Order [TlInput "test directory" "" 0]
    TlPrint ""
    TlPrint ""
    TlPrint "current time  : %s   am : %s" [clock format [clock seconds] -format "%H:%M"]  [clock format [clock seconds] -format "%a %d.%m.%Y"]
    while {1} {
	set IstTime  [clock format [clock seconds] -format "%H:%M"]
	if {$IstTime >= $StartTime } {
	    TlPrint "Test started at : %s   am : %s" [clock format [clock seconds] -format "%H:%M"]  [clock format [clock seconds] -format "%a %d.%m.%Y"]
	    return $Order
	}
	doWaitMsSilent 10
	if {$globAbbruchFlag} {return "t"}
    } ;# while
}

#MODIF : Creation de la fonction permettant d'établir la liste des drives en fonction de la tour :

proc towerDisplayDrives { } {
    global      Protocol
    global 	Geraeteliste
    set  	Geraeteliste [list]
    switch $Protocol {
	"MOD"       {set ProtName "MODBUS     "}
	"MOD_ATV"   {set ProtName "MODBUS(ATV)"}
	default     {set ProtName "Not defined"}
    }

    if { [GetSysFeat "EAETower1"] } {
	# Test EAE tower ATV900 ATV600 ATV340 DPAC + ATV340E ATV320 mdb slave
	lappend     Geraeteliste    " ATV600 - Device 1	$ProtName"
	lappend     Geraeteliste    " ATV900 - Device 2	$ProtName"
	lappend     Geraeteliste    " ATV340 - Device 3	$ProtName"
	lappend     Geraeteliste    " ATV340 - Device 4	$ProtName"
	lappend     Geraeteliste    " ATV320 - Device 5	$ProtName"

    } elseif { [GetSysFeat "PACY_COM_DEVICENET"] } {
	# Testtower DevNet
	lappend     Geraeteliste    " ATV340 - Opal            Device 1   $ProtName"
	#lappend     Geraeteliste    " ATV320 - Altivar Compact Device 2   $ProtName" not yet commissionned
	lappend     Geraeteliste    " ATV630 - Nera            Device 3   $ProtName"
	lappend     Geraeteliste    " ATV320 - Altivar Book    Device 4   $ProtName"
	lappend     Geraeteliste    " ATV900 - Fortis          Device 5   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK            Device 6   $ProtName"
	lappend     Geraeteliste    " ATV955 - Shadow Offer               $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_COM_PROFIBUS"]} {
	# Testtower Profibus
	lappend     Geraeteliste    " ATV340 - Opal            Device 1   $ProtName"
	#lappend     Geraeteliste    " ATV320 - Altivar Compact Device 2   $ProtName" not yet commissionned
	lappend     Geraeteliste    " ATV630 - Nera            Device 3   $ProtName"
	lappend     Geraeteliste    " ATV320 - Altivar Book    Device 4   $ProtName"
	lappend     Geraeteliste    " ATV900 - Fortis          Device 5   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK            Device 6   $ProtName"
	lappend     Geraeteliste    " ATV955 - Shadow Offer               $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_COM_PROFINET2"]} {
	# Testtower kala profinet V2
	lappend     Geraeteliste    " ATV340 - Opal	Device 1    $ProtName"
	lappend     Geraeteliste    " ATV630 - Nera   	Dev 2     $ProtName"
	lappend     Geraeteliste    " ATV930 - Fortis	Dev 3     $ProtName"
	lappend     Geraeteliste    " ATV320 - Altivar 	Device 4         $ProtName"
	lappend     Geraeteliste    " ATV6xxx - MVK	Device 5         $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_COM_PROFINET"]} {
	# Testtower ProfiNET
	lappend     Geraeteliste    " ATV340 - Opal            Device 1   $ProtName"
	#lappend     Geraeteliste    " ATV320 - Altivar Compact Device 2   $ProtName" not yet commissionned
	lappend     Geraeteliste    " ATV630 - Nera            Device 3   $ProtName"
	lappend     Geraeteliste    " ATV320 - Altivar Book    Device 4   $ProtName"
	lappend     Geraeteliste    " ATV900 - Fortis          Device 5   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK            Device 6   $ProtName"
	lappend     Geraeteliste    " ATV955 - Shadow Offer               $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_COM_ETHERCAT"]} {
	# Testtower EtherCAT
	lappend     Geraeteliste    " ATV340 - Opal              Device 1   $ProtName"
	#lappend     Geraeteliste    " ATV320 - Altivar Compact   Device 2   $ProtName" not yet commissionned
	lappend     Geraeteliste    " ATV320 - Altivar Book      Device 4   $ProtName"
	lappend     Geraeteliste    " ATV9xx - Fortis            Device 5   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK              Device 6   $ProtName"
	lappend     Geraeteliste    " ATV955 - Shadow Offer                 $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_COM_CANOPEN"]} {
	# Testtower CANopen
	lappend     Geraeteliste    " ATV340 - Opal            Device 1   $ProtName"
	#lappend     Geraeteliste    " ATV320 - Altivar Compact Device 2   $ProtName" not yet commissionned
	lappend     Geraeteliste    " ATV630 - Nera            Device 3   $ProtName"
	lappend     Geraeteliste    " ATV320 - Altivar Book    Device 4   $ProtName"
	lappend     Geraeteliste    " ATV900 - Fortis          Device 5   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK            Device 6   $ProtName"
	lappend     Geraeteliste    " ATV955 - Shadow Offer               $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_APP_OPAL"]} {
	# Testtower Opal EthernetIP
	lappend     Geraeteliste    " ATV340 - Opal            Device 1   $ProtName"
	lappend     Geraeteliste    " ATV6000 - MVK            Device 6   $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_APP_NERA"]} {
	# Testtower Nera EthernetIP
	lappend     Geraeteliste    "ATV320 - Altivar       		Device 1 $ProtName"
	lappend     Geraeteliste    "ATV630 - Nera Shanghai		Device 2 $ProtName"
	lappend     Geraeteliste    "ATV630 - Nera Pacy     		Device 3 $ProtName"
	set  PrgNr  XXX00

    } elseif {[GetSysFeat "PACY_APP_FORTIS"]} {
	# Testtower Fortis
	set  PrgNr  00000
	lappend     Geraeteliste    "ATV930 - Fortis  N1 $ProtName"
	lappend     Geraeteliste    "ATV955 - ShadowOffer   Network 3 dev."

    } elseif {[GetSysFeat "PACY_SFTY_FORTIS"]} {
	# Testtower safety with Fortis
	set  PrgNr  00000
	lappend     Geraeteliste    "ATV930 - Fortis  N1 $ProtName"

    } elseif {[GetSysFeat "PACY_SFTY_OPAL"]} {
	# Testtower safety with Opal
	set  PrgNr  00000
	lappend     Geraeteliste    "ATV340 - Opal    N1 $ProtName"

    }  elseif {[GetSysFeat "MVKTower1"]} {
	# Testtower MVK 1
	TlPrint "MVK setup"
	set  PrgNr  00000
	lappend     Geraeteliste    "ATV6000    - APP Campaign Fix Range	N1 $ProtName"
	lappend     Geraeteliste    "ATV6000    - PLC Campaign			N1 $ProtName"

    } elseif {[GetSysFeat "MVKTower2"]} {
	# Testtower MVK 1
	TlPrint "MVK setup"
	set  PrgNr  00000
	lappend     Geraeteliste    "ATV6000    -  N1 $ProtName"

    }  elseif { [GetSysFeat "PACY_ATLAS_PROFINET"] } {
	# Testtower ATS_PROFINET
	lappend     Geraeteliste    "ATS 48P   - Device 1  - Profinet Option"
	lappend     Geraeteliste    "ATS 48OPT - Device 2  - Profinet Option"
	lappend     Geraeteliste    "ATS 48P   - Device 3  - Applicative (w/o Option)"
	lappend     Geraeteliste    "ATS 48OPT - Device 2B - Applicative & Ethernet Embedded"

	TlPrint "Kala/Nera Fieldbus Device -> Programnumber XXXX"
	set  PrgNr  XXX00

    }  elseif { [GetSysFeat "PACY_ATLAS_ETHERNET"] } {
	# Testtower ATS_ETHERNET
	lappend     Geraeteliste    "ATS 48P   - Device 1  - Ethernet Option"
	lappend     Geraeteliste    "ATS 48OPT - Device 2  - Ethernet Option"
	lappend     Geraeteliste    "ATS 48OPT - Device 3  - Applicative & Ethernet Embedded"
	lappend     Geraeteliste    "ATS 48P   - Device 1B - Applicative (w/o Option)"

	TlPrint "Kala/Nera Fieldbus Device -> Programnumber XXXX"
	set  PrgNr  XXX00

    }  elseif { [GetSysFeat "PACY_ATLAS_PROFIBUS"] } {
	# Testtower ATS_PROFIBUS
	lappend     Geraeteliste    "ATS 48P   - Device 1  - Profibus Option"
	lappend     Geraeteliste    "ATS 48OPT - Device 2  - Profibus Option"
	lappend     Geraeteliste    "ATS 48B   - Device 3  - Applicative"
	lappend     Geraeteliste    "ATS 48P   - Device 1B - Applicative (w/o Option)"
	lappend     Geraeteliste    "ATS 48OPT - Device 2B - Applicative & Ethernet Embedded"

	TlPrint "Kala/Nera Fieldbus Device -> Programnumber XXXX"
	set  PrgNr  XXX00

    }  elseif { [GetSysFeat "PACY_ATLAS_CANOPEN"] } {
	# Testtower ATS_CANOPEN
	lappend     Geraeteliste    "ATS 48OPT - Device 2B - Applicative & Ethernet Embedded"

	TlPrint "Kala/Nera Fieldbus Device -> Programnumber XXXX"
	set  PrgNr  XXX00
    }  elseif { [GetSysFeat "PACY_ATLAS_CI"] } {
	# Testtower ATLAS Continuous Integration
	lappend     Geraeteliste    "ATS 48P   - Device 1  "
	lappend     Geraeteliste    "ATS 48OPT - Device 2  "
	lappend     Geraeteliste    "ATS 48B   - Device 3  "

	TlPrint "Kala/Nera Fieldbus Device -> Programnumber XXXX"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "SHANGHAI_APP_KY"]} {
	# Testtower Kaiyuan
	lappend     Geraeteliste    " K1 ATV610+  - Device 1      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 2      $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "SHANGHAI_APP_K2"]} {
	# Testtower K2
	lappend     Geraeteliste    " K2 HVAC     - Device 1      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 2      $ProtName"
	set  PrgNr  XXX00

    } elseif { [GetSysFeat "PACY_APP_K2"]} {
	# Testtower K2 in PACY for Verification
	lappend     Geraeteliste    " K2 HVAC     - Device 1      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 2      $ProtName"
	set  PrgNr  XXX00
    } elseif { [GetSysFeat "PACY_K2_BACNET"]} {
	# Testtower K2 in PACY for BACNET protocol
	lappend     Geraeteliste    " NERA ATV630 - Device 1      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 2      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 3      $ProtName"
	lappend     Geraeteliste    " NERA ATV630 - Device 4      $ProtName"
	lappend     Geraeteliste    " K2 HHP      - Device 5      $ProtName"
	set  PrgNr  XXX00
    } elseif { [GetSysFeat "PACY_APP_FLEX"] } {
	lappend     Geraeteliste    "ATV320   - Device 1  - Ethernet Option"
	lappend     Geraeteliste    "ATV340   - Device 2  - OPAL "
	lappend     Geraeteliste    "ATV630   - Device 3  - NERA "
	lappend     Geraeteliste    "ATV930   - Device 4  - FORTIS"
	lappend     Geraeteliste    "ATV320 (India) - Device 5"
    } elseif { [GetSysFeat "INDIA_APP_ATV320"] } {
    	#TestTower in India for ATV320 tests
	lappend     Geraeteliste    "ATV320   - Device 1  - Ethernet Option"
    } elseif { [GetSysFeat "PACY_SFTY_FIELDBUS"]} {
	# Testtower CIPSafety/Profisafe in Pacy
	lappend     Geraeteliste    " FORTIS CIPSAFETY        - Synchronous motor  - Device 1 "
	lappend     Geraeteliste    " FORTIS CIPSAFETY        - Asynchronous motor - Device 1 "
	lappend     Geraeteliste    " FORTIS PROFISAFE        - Synchronous motor  - Device 2 "
	lappend     Geraeteliste    " FORTIS PROFISAFE        - Asynchronous motor - Device 2 "
	lappend     Geraeteliste    " OPAL CIPSAFETY          - Synchronous motor  - Device 3 "
	lappend     Geraeteliste    " OPAL CIPSAFETY          - Asynchronous motor - Device 3 "
	lappend     Geraeteliste    " OPAL PROFISAFE          - Synchronous motor  - Device 4 "
	lappend     Geraeteliste    " OPAL PROFISAFE          - Asynchronous motor - Device 4 "
	lappend     Geraeteliste    " FORTIS RESERVE CIP      - Asynchronous motor - Device 5 "
	lappend     Geraeteliste    " FORTIS RESERVE PROFINET - Asynchronous motor - Device 5 "
	lappend     Geraeteliste    " OPAL RESERVE CIP        - Asynchronous motor - Device 6 "
	lappend     Geraeteliste    " OPAL RESERVE PROFINET   - Asynchronous motor - Device 6 "
	set  PrgNr  XXX00
    }  	else {
	lappend     Geraeteliste    "PR840.00 - Device 1 $ProtName"
	lappend     Geraeteliste    "PR840.00 - Device 2 $ProtName"
	lappend     Geraeteliste    "PR840.00 - Device 3 $ProtName"
	lappend     Geraeteliste    "PR840.00 - Device 4 $ProtName"
	lappend     Geraeteliste    "PR840.00 - Network 4 devices"
	lappend     Geraeteliste    "PR840.00 - Single test without TT"
	TlPrint "representative for PRG-Family set programmnumber to 840.00"
	set  PrgNr  8400
    }

    TlPrint "-----------------------------------------------"
    TlPrint "Choice of device configuration"
    TlPrint "-----------------------------------------------"
    set i 1
    foreach dir $Geraeteliste {
	TlPrint [format " %s - %s " $i $dir]
	incr i
    }
    TlPrint "-----------------------------------------------"
    while { 1 } {
	global Jenkins JenkinsFULLCAMPAIN ActDev UnifastCI
	if {$Jenkins || $JenkinsFULLCAMPAIN || $UnifastCI} {

	    set answer $ActDev
	} else {
	    set answer [TlInput "device configuration:" "" 0]
	}
	if {$answer != "" } { break }
    }

    TlPrint "Fin de towerDisplayDrives"
    return $answer
}

proc driveDisplayTestDir { answer } {

    global      theTestDirList  libpath
    global      theTestDevList IOScanConf
    global      ActDev DevAdr
    global      TestModus
    global      PrgNr
    global      OPC_servername
    global      Protocol
    global      mainpath theATVParameterFile theAltiLabParameterFile
    global      Fieldbus
    global      theSafetyParamFile
    global 	ActDevConf
    global 	theDevList

    set theTestDirList ""
    set theTestDevList ""

    set out 1
    set ActDev 0

    if { [GetSysFeat "EAETower1"] } {
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1 4 5]
		set TestModus "Multi"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_UAP

		# theTestDevList is used in GetSysFeat
		lappend theTestDevList "Nera"
	    }
	    "2" {
		set theDevList [list 2 4 5]
		set TestModus "Multi"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_UAP

		# theTestDevList is used in GetSysFeat
		lappend theTestDevList "Fortis"
	    }
	    "3" {
		set theDevList [list 3 4 5]
		set TestModus "Multi"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_UAP

		# theTestDevList is used in GetSysFeat
		lappend theTestDevList "Opal"
	    }
	    "4" {
		set theDevList [list 4]
		set TestModus "Single"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_UAP

		# theTestDevList is used in GetSysFeat
		lappend theTestDevList "Opal"
	    }
	    "5" {
		set theDevList [list 5]
		set TestModus "Single"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_UAP

		# theTestDevList is used in GetSysFeat
		lappend theTestDevList "Altivar"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_COM_CANOPEN"] } {
	# Test tower CANopen
	switch -exact  $answer {
	    "1"   {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		set NodeID $DevAdr($ActDev,CAN)
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf $ActDev
		set NodeID $DevAdr($ActDev,CAN)
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile

		lappend theTestDevList "Nera"
	    }

	    "3" {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf $ActDev
		set Fieldbus "MOD"
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile

		lappend theTestDevList "Altivar"
	    }

	    "4" {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf $ActDev
		set Fieldbus "MOD"   ;# Fortis device without fieldbus atm
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile

		lappend theTestDevList "Fortis"
	    }
	    "5" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev
		set Fieldbus "MOD"   ;# MVK device without fieldbus atm
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_AppFunct
		lappend theTestDevList "MVK"
	    }
	    "6" {
		set theDevList [list 15]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 15
		set Fieldbus "MOD"   ;# Fortis SO device without fieldbus atm
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CANopen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Profile

		lappend theTestDevList "ShadowOffer"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif {[GetSysFeat "PACY_COM_PROFINET2"]} {
	switch -exact  $answer {
	    "1"   {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Opal"
	    }
	    "2"   {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Nera"
	    }
	    "3"   {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Fortis"
	    }
	    "4"  {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Altivar"
	    }
	    "5"  {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "MVK"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_COM_DEVICENET"] } {
	# Test tower DevNET
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Nera"
	    }

	    "3" {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf $ActDev
		set Fieldbus "MOD"   ;# Altivar device without fieldbus
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Altivar"
	    }

	    "4" {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Fortis"
	    }

	    "5" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_AppFunct

		lappend theTestDevList "MVK"
	    }

	    "6" {
		set theDevList [list 15]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 15
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_DevNet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "ShadowOffer"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_COM_PROFIBUS"] } {
	# Test tower Profibus
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Nera"
	    }

	    "3" {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Altivar"
	    }

	    "4" {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Fortis"
	    }

	    "5" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev

		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "MVK"
	    }

	    "6" {
		set theDevList [list 15]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 15
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "ShadowOffer"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_APP_OPAL"] } {
	#Testtower Ethernet IP
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_CtrlFunc
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_DriveThermProt
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_Password
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_Safety
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_OpMode
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_GNG_Rules_EIP

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev

		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_GNG_Rules_EIP
		lappend theTestDevList "MVK"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_COM_PROFINET"] } {
	# Testtower ProfiNET
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile.
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Nera"
	    }

	    "3" {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Altivar"
	    }

	    "4" {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "Fortis"
	    }

	    "5" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_AppFunct

		lappend theTestDevList "MVK"
	    }

	    "6" {
		set theDevList [list 15]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 15
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Profinet
		lappend theTestDirList TC_Profibus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "ShadowOffer"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_COM_ETHERCAT"] } {
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_EtherCAT
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Opal"
	    }

	    "2" {
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf $ActDev
		set Fieldbus "MOD"   ;# Altivar device without fieldbus
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_EtherCAT
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Altivar"
	    }

	    "3" {
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf $ActDev
		set Fieldbus "MOD"   ;# Fortis device without fieldbus atm
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_EtherCAT
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "Fortis"
	    }

	    "4" {
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf $ActDev
		set Fieldbus "MOD"
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_EtherCAT
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_AppFunct

		lappend theTestDevList "MVK"
	    }
	    "5" {
		set theDevList [list 15]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 15
		set Fieldbus "MOD"   ;# Fortis SO device without fieldbus atm
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_EtherCAT
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_CableDisconnection

		lappend theTestDevList "ShadowOffer"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_APP_NERA"] } {
	# Testtower Ethernet IP
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATV320_India
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_ATV320
		lappend theTestDirList TC_GNG_Rules_EIP

		lappend theTestDevList "Altivar"
	    }

	    "2" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3 ;#configuration done for Nera Task force work. Purpose : improve Nera scripts w/o impacting PEP campaign
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_Function

		lappend theTestDevList "Nera"
	    }

	    "3" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Function
		lappend theTestDirList TC_OpMode
		lappend theTestDirList TC_Param
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_GNG_Rules_EIP
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_MotorProtect
                lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_NERA_BEIDOU

		lappend theTestDevList "Nera"
	    }

	    "4" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATV320_India

		lappend theTestDevList "Altivar"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_SFTY_FORTIS"] } {
	# Testtower safety with Fortis
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		if {[GetDevFeat "Modul_SM1"]} {
		    lappend theTestDirList TC_Safety
		}

		lappend theTestDevList "Fortis"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
	    }
	}

    } elseif { [GetSysFeat "PACY_APP_FORTIS"] } {
	# Testtower Fortis
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_CtrlFunc
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_DriveThermProt
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_Password
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_Safety
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_OpMode
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_GNG_Rules_EIP

		lappend theTestDevList "Fortis"
	    }

	    "2" {
		set theDevList [list 1]
		set TestModus "Multi"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 9
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_CtrlFunc
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_CableDisconnection
		lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_DriveThermProt
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_Password
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_Safety
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_OpMode
		lappend theTestDirList TC_Cybersecurity

		lappend theTestDevList "ShadowOffer"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_SFTY_OPAL"] } {
	# Testtower Safety wih Opal
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_Safety

		lappend theTestDevList "Opal"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "MVKTower1"] } {
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDevList "MVK"
	    }
	    "2" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_PLCInside
		lappend theTestDevList "MVK"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "MVKTower2"] } {
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init

		lappend theTestDevList "MVK"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_ATLAS_ETHERNET"] } {; #ATLAS TOWER 1
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Ethernet_ATLAS
		lappend theTestDirList TC_Cybersecurity_ATLAS
		lappend theTestDirList TC_Timeout_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    "2" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Ethernet_ATLAS
		lappend theTestDirList TC_Cybersecurity_ATLAS
		lappend theTestDirList TC_Timeout_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    "3" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Ethernet_ATLAS
		lappend theTestDirList TC_Cybersecurity_ATLAS
		lappend theTestDirList TC_Timeout_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    "4" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $answer
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
	    	lappend theTestDirList TC_CableDisconnection_ATLAS
	    	lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_ATLAS_PROFINET"] } {; #ATLAS TOWER 2
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Profinet_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    "2" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Profinet_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    "3" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
	    	lappend theTestDirList TC_CableDisconnection_ATLAS
	    	lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    "4" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 2
		set ActDevConf $answer
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_ATLAS_CANOPEN"] } {; #ATLAS TOWER 3
	switch -exact  $answer {
	    "1" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 2
		set ActDevConf $answer
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDevList "OPTIM"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_ATLAS_CI"] } {; #ATLAS TOWER 5
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDevList "ATS48P"
	    }
	    "2" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDevList "OPTIM"
	    }
	    "3" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDevList "BASIC"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_ATLAS_PROFIBUS"] } {; #ATLAS TOWER 4
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Profibus_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    "2" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Profibus_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    "3" {
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Cybersecurity_ATLAS
		lappend theTestDirList TC_Timeout_ATLAS
		lappend theTestDirList TC_CableDisconnection_ATLAS
	        lappend theTestDirList TC_Miscellaneous
	        lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "BASIC"
	    }
	    "4" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf $answer
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
	    	lappend theTestDirList TC_CableDisconnection_ATLAS
	    	lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "ATS48P"
	    }
	    "5" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 2
		set ActDevConf $answer
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATS
		lappend theTestDirList TC_GNG_rules_ATLAS
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_GED_ATLAS
		lappend theTestDevList "OPTIM"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_APP_FLEX"] } {
	switch -exact $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 1
		lappend theTestDirList TC_0Init
		lappend theTestDevList "Altivar"
	    }

	    "2" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 2
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_MotorFunc
		lappend theTestDevList "Opal"
	    }
	    "3" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 3
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_Ethernet
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_IOmanage
		lappend theTestDevList "Nera"
	    }
	    "4" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 4
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_MotorFunc
		lappend theTestDevList "Fortis"
	    }
	    "5" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 5
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATV320_India
		lappend theTestDevList "Altivar"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
	    }

	}
    } elseif { [GetSysFeat "INDIA_APP_ATV320"] } {
	switch -exact $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 1
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_ATV320_India
		lappend theTestDevList "Altivar"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
	    }

	}

    } elseif { [GetSysFeat "DevDesk"] } { ;#Fictional tower for development purpose, Aurelien PC
	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_TestFile1
		lappend theTestDirList TC_TestFile2
		lappend theTestDirList TC_TestFile3
		lappend theTestDevList "Opal"
	    }

	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}

    } elseif { [GetSysFeat "PACY_SFTY_FIELDBUS"]} {
	switch -exact  $answer {
	    "1" { ;# FORTIS CIPSAFETY Synch
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 11
		lappend theTestDirList TC_0Init
		lappend theTestDirList	TC_GNG_Rules_EIP
	    	lappend theTestDirList TC_Safety_Verification
	    	lappend theTestDirList TC_Safety_Validation
	    	lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Fortis"
	    }
	    "2" { ;# FORTIS CIPSAFETY Asynch
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 1
		set ActDevConf 12
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_EIP
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Fortis"
	    }
	    "3" { ;# FORTIS PROFISAFE Synch
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 2
		set ActDevConf 21
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection 
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Fortis"
	    }
	    "4" { ;# FORTIS PROFISAFE Asynch
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 2
		set ActDevConf 22
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection 
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Fortis"
	    }
	    "5" { ;#OPAL CIPSAFETY Synch
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf 31
		lappend theTestDirList TC_0Init
		lappend theTestDirList	TC_GNG_Rules_EIP
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Opal"
	    }
	    "6" { ;#OPAL CIPSAFETY Asynch
		set theDevList [list 3]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 3
		set ActDevConf 32
		lappend theTestDirList TC_0Init
		lappend theTestDirList	TC_GNG_Rules_EIP
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Opal"
	    }
	    "7" { ;#OPAL PROFISAFE Synch
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf 41
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection 
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Opal"
	    }
	    "8" { ;#OPAL PROFISAFE Asynch
		set theDevList [list 4]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 4
		set ActDevConf 42
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_GNG_Rules_Profinet
		lappend theTestDirList TC_ProfinetV2
		lappend theTestDirList TC_CableDisconnection 
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Profile
		lappend theTestDirList TC_Cybersecurity
		lappend theTestDirList TC_Safety_Verification
		lappend theTestDirList TC_Safety_Validation
		lappend theTestDirList TC_Safety_GEDEC
		lappend theTestDevList "Opal"
	    }
	    "9" { ;# FORTIS RESERVE EIP
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 51
		lappend theTestDirList TC_0Init
		lappend theTestDevList "Fortis"
	    }
	    "10" { ;# FORTIS RESERVE PROFINET
		set theDevList [list 5]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 5
		set ActDevConf 52
		lappend theTestDirList TC_0Init
		lappend theTestDevList "Fortis"
	    }
	    "11" { ;# OPAL RESERVE EIP
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf 61
		lappend theTestDirList TC_0Init
		lappend theTestDevList "Opal"
	    }
	    "12" { ;# OPAL RESERVE PROFINET
		set theDevList [list 6]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev 6
		set ActDevConf 62
		lappend theTestDirList TC_0Init
		lappend theTestDevList "Opal"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
    } elseif { [GetSysFeat "PACY_APP_K2"] || [GetSysFeat "SHANGHAI_APP_K2"] } {

	switch -exact  $answer {
	    "1" {
		set theDevList [list 1]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_DriveThermProt
		lappend theTestDirList TC_K2
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_Function
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Water

		lappend theTestDevList "K2"
	    }
	    "2" {
		set theDevList [list 2]
		set TestModus "Singel"
		set theTopScript "0top_Single.tcl"
		set ActDev $answer
		set ActDevConf $ActDev
		lappend theTestDirList TC_0Init
		lappend theTestDirList TC_AppFunct
		lappend theTestDirList TC_AppProtect
		lappend theTestDirList TC_SpeedSetPointFunc
		lappend theTestDirList TC_CmdRefChanFunc
		lappend theTestDirList TC_StopFunction
		lappend theTestDirList TC_SignalFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_IOmanage
		lappend theTestDirList TC_MotorProtect
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_ConfigManage
		lappend theTestDirList TC_RampGen
		lappend theTestDirList TC_DriveProtec
		lappend theTestDirList TC_K2
		lappend theTestDirList TC_Miscellaneous
		lappend theTestDirList TC_Function
		lappend theTestDirList TC_Modbus
		lappend theTestDirList TC_Water

		lappend theTestDevList "Nera"
	    }
	    default {
		set out 1
		TlPrint "wrong input"
		return -1
	    }
	}
} elseif { [GetSysFeat "SHANGHAI_APP_KY"] } {

    switch -exact  $answer {
        "1" {
            set theDevList [list 1]
            set TestModus "Singel"
            set theTopScript "0top_Single.tcl"
            set ActDev $answer
            set ActDevConf $ActDev
            lappend theTestDirList TC_0Init
            lappend theTestDirList TC_AppFunct
            lappend theTestDirList TC_AppProtect
            lappend theTestDirList TC_SpeedSetPointFunc
            lappend theTestDirList TC_CmdRefChanFunc
            lappend theTestDirList TC_StopFunction
            lappend theTestDirList TC_SignalFunc
            lappend theTestDirList TC_ErrorDetection
            lappend theTestDirList TC_IOmanage
            lappend theTestDirList TC_MotorProtect
            lappend theTestDirList TC_CustMaintFunc
            lappend theTestDirList TC_MotorFunc
            lappend theTestDirList TC_ConfigManage
            lappend theTestDirList TC_RampGen
            lappend theTestDirList TC_DriveProtec
            lappend theTestDirList TC_K2
            lappend theTestDirList TC_Miscellaneous
            lappend theTestDirList TC_Function
            lappend theTestDirList TC_Modbus
            lappend theTestDirList TC_Water
            lappend theTestDirList TC_Param

            lappend theTestDevList "KAIYUAN"
        }
        "2" {
            set theDevList [list 2]
            set TestModus "Singel"
            set theTopScript "0top_Single.tcl"
            set ActDev $answer
            set ActDevConf $ActDev
            lappend theTestDirList TC_0Init
            lappend theTestDirList TC_AppFunct
            lappend theTestDirList TC_AppProtect
            lappend theTestDirList TC_SpeedSetPointFunc
            lappend theTestDirList TC_CmdRefChanFunc
            lappend theTestDirList TC_StopFunction
            lappend theTestDirList TC_SignalFunc
            lappend theTestDirList TC_ErrorDetection
            lappend theTestDirList TC_IOmanage
            lappend theTestDirList TC_MotorProtect
            lappend theTestDirList TC_CustMaintFunc
            lappend theTestDirList TC_MotorFunc
            lappend theTestDirList TC_ConfigManage
            lappend theTestDirList TC_RampGen
            lappend theTestDirList TC_DriveProtec
            lappend theTestDirList TC_K2
            lappend theTestDirList TC_Miscellaneous
            lappend theTestDirList TC_Function
            lappend theTestDirList TC_Modbus
            lappend theTestDirList TC_Water

            lappend theTestDevList "Nera"
        }
        default {
            set out 1
            TlPrint "wrong input"
            return -1
        }
    }
    } elseif { [GetSysFeat "PACY_K2_BACNET"] } {

        switch -exact  $answer {
            "1" {
                set theDevList [list 1]
                set TestModus "Singel"
                set theTopScript "0top_Single.tcl"
                set ActDev $answer
                set ActDevConf $ActDev
                lappend theTestDirList TC_0Init
                lappend theTestDevList "NERA"
            }
            "2" {
                set theDevList [list 2]
                set TestModus "Singel"
                set theTopScript "0top_Single.tcl"
                set ActDev $answer
                set ActDevConf $ActDev
                lappend theTestDirList TC_0Init
                lappend theTestDevList "NERA"
            }
            "3" {
                set theDevList [list 3]
                set TestModus "Singel"
                set theTopScript "0top_Single.tcl"
                set ActDev $answer
                set ActDevConf $ActDev
                lappend theTestDirList TC_0Init
                lappend theTestDevList "NERA"
            }
            "4" {
                set theDevList [list 4]
                set TestModus "Singel"
                set theTopScript "0top_Single.tcl"
                set ActDev $answer
                set ActDevConf $ActDev
                lappend theTestDirList TC_0Init
                lappend theTestDevList "NERA"
            }
            "5" {
                set theDevList [list 5]
                set TestModus "Singel"
                set theTopScript "0top_Single.tcl"
                set ActDev $answer
                set ActDevConf $ActDev
                lappend theTestDirList TC_0Init
		lappend theTestDirList TC_CustMaintFunc
		lappend theTestDirList TC_ErrorDetection
		lappend theTestDirList TC_K2
		lappend theTestDirList TC_MotorFunc
		lappend theTestDirList TC_SpeedSetPointFunc
                lappend theTestDevList "K2"
            }
            default {
                set out 1
                TlPrint "wrong input"
                return -1
            }
        }
    } else {
	set out 1
	TlError "No Tower configured so i don't know what object file should use, please check ini files"
	break
    }
    updateActDevValues
}
