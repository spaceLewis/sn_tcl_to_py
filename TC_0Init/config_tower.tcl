#---------------------------------------------------------------------------------------------------
#  Project     : Global
#  Category    : TC_0Init
#  Filename    : config_testturm.tcl
#  Description : Configuration of the TCL test environment
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 111203 pfeig    Datei erstellt
# 160404 pfeig    Pfad angepasst, ModBusPort
# 200404 pfeig    ErrorCode Ini
# 260404 pfeig    Initpath
# 290404 pfeig    Schnittstellenvariablen
# 040504 pfeig    0param_by_parameter
# 100504 pfeig    Mehrgerätesteuerung Device1-4
# 270504 pfeig    Can-Baud
# 290904 pfeig    theCANObjectListFile
# 120105 pfeig    Variable HandMade eingeführt um per Batch Datei wählen zu können ob der
#                 Interpreter ausserhalb des TT Meldungen beim Ein/Ausschalten ausgibt
# 090505 pfeig    Variable BUS eingeführt um Siemen PB zu unterscheiden
# 150206 pfeig    DB öffnen
# 250608 rothf    Umstrukturiert und aufgeräumt
# 241114 gelbg    Add the feature to switch off/on the usage of DataBase
# 191214 serio    Add the IOcommon library
#---------------------------------------------------------------------------------------------------

set DB_Open 0 ;# = false

# Initialisation of the environment variables

global theSerialPort theSerialBaud Jenkins JenkinsFULLCAMPAIN

set HandMade      0
set theSerialPort 4
set Protocol      "MOD"
set Fieldbus      "MOD"
set Fieldbus2      "EIP"
set theSerialBaud 19200
set theCanBaud    1000
set COMPUTERNAME  "unknown"
set CreateLog     1
set UseDB         1

if [info exists env(COMPUTERNAME)] {
   set COMPUTERNAME $env(COMPUTERNAME)
}


if {$Jenkins && $JenkinsFULLCAMPAIN} {
	#Definition of data paths
	set    mainpath         "[pwd]"
	puts " Actual folder: $mainpath"
	
} else {	
	#Definition of data paths
	set    mainpath         "[pwd]"
	puts " Actual folder: $mainpath"
}


#for delete: #append theATVParameterFile       $mainpath             "/ObjektDB/R3Dev_PrmUnifiedMappingSimulatorGen_A1.5IE08_B10.sim"
#for delete: #append theNERAParameterFile      $mainpath             "/ObjektDB/NeraDev_PrmUnifiedMappingGen_A0.2IE01_B18.sim"
#for delete: #append theAltiLabParameterFile   $mainpath             "/ObjektDB/AltiLab_KOP_NERA.xml"

append theLXMObjectListFile      $mainpath             "/ObjektDB/LXM_Load/objdefs.h"
append theLXMVARListFile         $mainpath             "/ObjektDB/LXM_Load/0MAIN.txt"
append theLXMLimitCheckFile      $mainpath             "/ObjektDB/LXM_Load/limitcheck.txt"

append BlePath                   $mainpath             "/ble/"
#for delete: append BlePathESM                $mainpath             "/ble/BLE_eSM/"
#for delete: append BlePathMot                $mainpath             "/ble/BLE_Motor/"
append testpath                  $mainpath
append libpath                   $mainpath             "/_library_"
append Initpath                  $mainpath             "/TC_0Init"
append theObjektDBPath           $mainpath             "/ObjektDB"
append theLimitCheckPath         $mainpath             "/ObjektDB"
append theIoFuncDefsPath         $mainpath             "/ObjektDB"

append theOpalECATESIFile        $mainpath             "/ObjektDB/SEATV6x0_ECAT.xml"
append theNeraCANObjectFile      $mainpath             "/ObjektDB/NERA_SEATV6x0_CANopen.eds"
append theFortisCANObjectFile    $mainpath             "/ObjektDB/FORTIS_SEATV9x0_CANopen.eds"
append theOpalCANObjectFile      $mainpath             "/ObjektDB/OPAL_SEATV3x0_CANopen.eds"
append theMVKCANObjectFile      $mainpath             "/ObjektDB/MVK_SEATV60x0_CANopen.eds"
append theAltivarCANObjectFile      $mainpath             "/ObjektDB/ATV320_SEATV320_CANopen.eds"
append theATSCANObjectFile      $mainpath             "/ObjektDB/ATS480_SEATS48P_CANopen.eds"
#for delete: append theCodesysV3AppPath       $mainpath             "/TC_GPMB/Servo3Motion/Applications"

append theLimitCheckFile         $theLimitCheckPath    "/LimitCheck.txt"
append theAltivarLimitCheckFile         $theLimitCheckPath    "/Altivar_LimitCheck.txt"
# append theNERALimitCheckFile   $theLimitCheckPath    "/NERA_LimitCheck.txt"

append devnetconfig_FileName     $mainpath             "/TC_0Init/DevNetConfig.ini"

append ErrCodeIniPath            $mainpath             "/ObjektDB/LXM_Load"
append theErrorTextFile          $ErrCodeIniPath       "/errcodes.ini"
#for delete: append theParameterFile          $ErrCodeIniPath       "/0param_by_parameter.txt"
append theCANerrTextFile         $Initpath             "/CAN_PEAK_Errors.txt"
append theCAN_SDO_AbortErrFile   $Initpath             "/CAN_SDO_Abort_Errors.txt"
append theConfigIniFile          $Initpath             "/config_$COMPUTERNAME.ini"
append theCfgDefaultIniFile      $Initpath             "/config_default.ini"
#append theConfigXMLFile         $Initpath             "/config_$COMPUTERNAME.xml"
append theHomingLibrary          $mainpath             "/TC_OpMode/Homing_lib.tcl"
append theSpeedContLibrary       $mainpath             "/TC_OpMode/PrfVel_lib.tcl"
append theProfilePositionLibrary $mainpath             "/TC_OpMode/PrfPos_lib.tcl"
append theProfileTorqueLibrary   $mainpath             "/TC_OpMode/PrfTorq_lib.tcl"
append theDatasetLibrary         $mainpath             "/TC_OpMode/DataSet_lib.tcl"
append theSystemLoadLibrary      $mainpath             "/TC_Function/SystemLoad_lib.tcl"
append theHilscherPath           $Initpath             "/Hilscher"
#for delete: append eSMFlashPath              $mainpath             "/TC_try_TTSW/Flash_eSM"
append theKalaCRFile             $mainpath             "/ObjektDB/KalaQueryResult.txt"
append theCrPostponedFile        $mainpath             "/ObjektDB/PostponedCRs.txt"
append theConfPackagePath        $mainpath             "/ObjektDB/ConfPackageFiles"
append theSafetyParamFile        $mainpath             "/ObjektDB/SafetyParameters4TestTowers.csv"
append theSafetyErrorFile        $mainpath             "/ObjektDB/SafetyErrors.xml"
append theSafetyMappingFileCPUA  $mainpath             "/ObjektDB/CPUA_Fw.map"
append theSafetyMappingFileCPUB  $mainpath             "/ObjektDB/CPUB_Fw.map"

# set FlashPath "C:/Program Files/Schneider Electric/Lexium CT/bin/FLASH3"

# set some global variables for TCL
set errorInfo         ""
set errorCode         ""
set globAbbruchFlag   0

# test directories, test files, test procedures
set theTestDirList   {} ;# List of test directories
set theTestDir       "" ;# actual test directory
set theTestFileList  {} ;# List of actual Tcl test files
set theTestProcList  {} ;# List of actual test procedures
global theDevList
set theDevList {}       ;# List of all used Test Devices

global MBTCPCom MBTCPioCom
set MBTCPCom(2)      "Closed"
set MBTCPCom(3)      "Closed"
set MBTCPioCom       0

package require inifile
package require tdom

source "$libpath/util_Mathe.tcl"             ;# Utility functions
source "$libpath/cmd_debugger.tcl"           ;# Tcl_Debugger procedures
source "$libpath/defs.tcl"                   ;# global constants
source "$libpath/cmd_sql.tcl"                ;# SQL commands
source "$libpath/cmd_tower.tcl"              ;# special tower commands
ReadConfigValues                             ;#Read configuration values from ini-File
if {[info exists coCREATE_LOG]} {
    set CreateLog $coCREATE_LOG
}
if {[info exists coUSE_DB]} {
    set UseDB $coUSE_DB
}
source "$libpath/cmd_common.tcl"             ;# global commands
source "$libpath/menu.tcl"                   ;# menu handled
source "$libpath/util.tcl"                   ;# Utility functions
source "$libpath/util_CSV.tcl"               ;# Utility functions
source "$libpath/util_print.tcl"             ;# Utility functions
# source "$libpath/util_FastScope.tcl"         ;# Utility functions
# source "$libpath/util_ObjektDB.tcl"          ;# Utility functions
source "$libpath/util_String.tcl"            ;# Utility functions
# source "$libpath/util_workaround.tcl"	     ;# Utility functions
source "$libpath/check.tcl"                  ;# Check functions
# source "$libpath/cmd_OPC.tcl"                ;# OPC-commands to external controler
source "$libpath/ble_parser.tcl"             ;# read BLE-files and other functions
source "$libpath/cmd_WagoController.tcl"     ;# functions to control wago plc
# source "$libpath/cmd_ProfinetV2.tcl"	     ;# additionnal functions dedication to GEN2Towers
# source "$libpath/cmd_WagoStepper.tcl"        ;# functions for Wago-Stepper
source "$libpath/cmd_MOD.tcl"                ;# MOD-Bus DLL commands
# source "$libpath/cmd_MOD2.tcl"               ;# MOD-Bus DLL commands for Schneider NetObj (TCP/Seriell)
#source "$libpath/cmd_tower.tcl"              ;# special tower commands
# source "$libpath/cmd_PMCProf.tcl"            ;# special commands for PLCOpen Motion Control Profile
# source "$libpath/cmd_DriveCom_Profile.tcl"   ;# special commands for PLCOpen Motion Control Profile
# source "$libpath/cmd_PChannel.tcl"           ;# special commands for Parameter Channel
# source "$libpath/cmd_FTP.tcl"                ;# special commands for FTP
# source "$libpath/cmd_Hilscher.tcl"           ;# special commands for Hilscher card
# source "$libpath/cmd_ModiconInterface.tcl"      ;# PLC interface for Modicon
# source "$libpath/cmd_Wireshark.tcl"          ;# commands Wireshark remote control
# source "$libpath/cmd_XML.tcl"                ;# commands for XML files
# source "$libpath/cmd_FileManager.tcl"        ;# commands for FileManager access on Kala plattform
# source "$libpath/cmd_TransportService.tcl"   ;# commands for Object access on Kala plattform
# source "$libpath/CR.tcl"                     ;# CR management
# source "$libpath/hw_drive.tcl"               ;# High level function for setting Out or Inputs for the drive
# source "$libpath/IOcommon.tcl"               ;# Common procedures for IO functions
# source "$libpath/cmd_RSim.tcl"               ;# special commands for RSim interface Board
# source "$libpath/Safety_lib.tcl"             ;# Safety module commands
# source "$libpath/cmd_Safety.tcl"             ;# Generic safety functions 
# source "$libpath/cmd_GNGRules.tcl"	     ;# Loading the GNGRULES namespace declaration	
# source "$libpath/DriveCom_VelMode_lib.tcl"   ;# Loading driveCom functionalities 
# source "$libpath/util_export.tcl"            ;# functions to export data from the test campaign
# if {[GetSysFeat "Gen2Tower"]} { source $libpath/cmd_towerGen2.tcl }
# source "$libpath/cmd_MVK.tcl"        ;# To execute the MVK system related manipulations 


if { [GetSysFeat "ATLAS"]} {
    source "$mainpath/TC_ATS/ATS_lib.tcl"
    # source "$mainpath/TC_ATS/FaultGeneration_lib.tcl"
    source "$libpath/Keypad_lib.tcl"	     ;# keypad commands
    # source "$libpath/PLC_lib.tcl"		     ;# PLC commands
    # source $libpath/cmd_CAN_ATLAS.tcl 	     ;# CANOpen commands for atlas
    # source $mainpath/_library_/cmd_GNG_ATLAS.tcl ; #Initialize com protocols for GnG rules for atlas
}

source "$mainpath/TC_0Init/config_TestObject.tcl"
#all other libraries are loaded when device is selected (call to InitializeFieldbus in config_device_test)

if { [catch {set UniFASTinfo [Tcl4TowerInfo]} Msg] } {
   # When lib twapi not existing or it is used an older ver of UniFAST
   TlPrint " #info: Procedures SetPrio GetPrio are inactive for this session due to: $Msg"
   TlPrint " ERROR: if using WIN7, update your UNIFast package!"
} else {
   set Build [lindex $UniFASTinfo 1]
   set Build [expr [scan $Build %d]]

   if { $Build > 116} {
      # Library, necessary for this procedures, will be available with UniFAST Ver 2.117
      SetPrio
      GetPrio
   }
}

# #MODIF : ASY 2021/12/07
# #MODIF : Implemeting the checking of the current git branch and if it is up to date or not
# TlPrint "################GIT#######CHECKING####################################"
# TlPrint "######################################################################"
 global currentCommit currentBranch Jenkins UnifastCI
 set currentCommit "aaaaaaaaaaaaaaa"
 set currentBranch "toto"
# if {!$Jenkins && !$JenkinsFULLCAMPAIN && !$UnifastCI} {
	# #execute the fetch command
	# set temp [catch {exec git fetch}]
# }
# # get the result of the git status command
# set gitResult [exec git status]
# #split the git status in lines
# set ngitResult [ split $gitResult "\n" ]
# #get the first line which contains the branch's name
# set branch [lindex $ngitResult 0]
# #get the second line which tells if up to date or not
# set status [lindex $ngitResult 1]
# #Keep only the branch name
# set branchName [string range $branch 10 end]
# set currentBranch $branchName
# #Get the commit information 
# set commit [exec git log -n 1]
# set ncommit [split $$commit "\n"]
# set currentCommit [string range [lindex $ncommit 0] 7 end]
    # #check if up to date
# #Check to be done only if not Jenkins and not JenkinsFULLCAMPAIN

# if {!$Jenkins && !$JenkinsFULLCAMPAIN && !$UnifastCI} {
    # #check if up to date
    # set statusResult [string first "up to date" $status]
    # if {![regexp "\/main" $branchName] } {
	# TlPrint "Carrefull, main branch not checked out. "
	# TlPrint "Do you want to execute anyway ?"
	# set keepGoing 1
	# while {$keepGoing} {
	    # set answer [TlInput "y/n " "" 0]
	    # switch -regexp $answer {
		# "^[nN]" { exit }
		# "^[yY]" { set keepGoing 0 }
	    # }
	# }
	# if {[regexp "n" $answer]} {exit}
    # } else {
	# #handling the automatic export in case campaign launched on main branch 
	# TlPrint " Campaign launched on Unifast/main branch, automatic export turned on"
	# global exportFlag 
	# set exportFlag 1
    # }
    # TlPrint "Branch status : $status"
    # if {$statusResult < 0} {
	# TlPrint "Your branch is not up to date with the remote repo "
	# TlPrint "We suggest you to update before running tests"
	# set keepGoing 1
	# while {$keepGoing} {
	    # set answer [TlInput "Do you want to continue : y/n " "" 0]
	    # switch -regexp $answer {
		# "^[nN]" { exit }
		# "^[yY]" { set keepGoing 0 }
	    # }
	# }
    # }
# }
if { $UseDB } {
   set rc [catch "package require tclodbc" errMsg]

   if {$rc == 0} {
      # only execute when the script is not called from nagelfar
      if { ![info exists NoAction] } {
         set rc [catch "database db dbLog root" errMsg]
         set rc [catch "database connect db {Driver=MySQL ODBC 5.1 Driver;DATABASE=dbLog;SERVER=\
                        localhost;PORT=3306;UID=testtower;PWD=TestTowerSchneider} " errMsg]
         if {$rc != 0} {
            set rc [catch "database connect db {Driver=MySQL ODBC 5.3 Unicode Driver;DATABASE=\
                           dbLog;SERVER=localhost;PORT=3306;UID=testtower;PWD=TestTowerSchneider} " errMsg]
            if {$rc != 0} {
               set DB_Open 0
               puts "Database:dbLog could not be opened:  $errMsg"
            } else {
               set DB_Open 1
               puts "Database:dbLog is connected with MySQL ODBC 5.3 Unicode Driver and open"
            }
         } else {
            set DB_Open 1
            puts "Database:dbLog is connected with MySQL ODBC 5.1 Driver and open"
         }
      }
   } else {
      puts "package tclodbc not found"
      puts $errMsg
   }

   if {$DB_Open} {
      SQL_WriteTestRun "Default_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"

      if { $CreateLog } {
         TlPrint "-----------------------------------------------"
         TlPrint "ATTENTION: the script process is logged in following media:"
         TlPrint " - LogFiles, -genereated on the local machine"
         TlPrint " - SQL database"
         TlPrint "-----------------------------------------------"
      } else {
         TlPrint "-----------------------------------------------"
         TlPrint "ATTENTION: the script process is logged in following media:"
         TlPrint " - SQL database"
         TlPrint "-----------------------------------------------"
      }
   }
}

if { !$UseDB || !$DB_Open } {
   if { $CreateLog } {
      TlPrint "-----------------------------------------------"
      TlPrint "ATTENTION: the script process is logged in following media:"
      TlPrint " - LogFiles, -genereated on the local machine"
      TlPrint "-----------------------------------------------"
   } else {
      TlPrint "-----------------------------------------------"
      TlPrint "ATTENTION: no logging of script is selected"
      TlPrint "-----------------------------------------------"
      set Loop 1
      while { $Loop } {
         TlPrint "Do you wish to enable logging via LogFiles? \[y/n\]"
         set Input [gets stdin]
         switch -regexp $Input {
            "[Yy]" {
               TlPrint "The results will be logged via LogFiles only for this opened session"
               set CreateLog 1
               source "$libpath/cmd_common.tcl"             ;# global commands
               set Loop 0
            }
            "[Nn]" {
               TlPrint "No results will be logged"
               set Loop 0
            }
            default {
            }
         }
      }
   }
}

#Read objects and error description
#ReadErrorTextFile       $theErrorTextFile
ReadLXMObjectListFile   $theLXMObjectListFile
ReadLXMLimitCheckFile   $theLXMLimitCheckFile
ReadVARListFile         $theLXMVARListFile  0    ;# 0=without displaying on the screen                                                                                    

# for Load Device
#ReadCPDObjectListFile   $theCPDObjectListFile
#ReadCPDVARListFile      $theCPDVARListFile  0

#ReadConfigValues        ;#Read configuration values from ini-File

#if available, load environmental variables
if {[info exists cPROTOCOL]} {
   set Protocol $cPROTOCOL
}
if {[info exists cFIELDBUS]} {
   set Fieldbus $cFIELDBUS
}
if {[info exists cFIELDBUS2]} {
   set Fieldbus2 $cFIELDBUS2
   set EthernetBus $cFIELDBUS2
}
if {[info exists cHANDMADE]} {
   set HandMade $cHANDMADE
}
if {[info exists cSERIAL_PORT]} {
   set theSerialPort $cSERIAL_PORT
}
if {[info exists cSERIAL_BAUD]} {
   set theSerialBaud $cSERIAL_BAUD
}
if {[info exists cCAN_BAUD]} {
   set theCanBaud $cCAN_BAUD
}

#Printing of the values
puts "Set variable: Protocol to      $Protocol"
puts "Set variable: Fieldbus to      $Fieldbus"
puts "Set variable: HandMade to      $HandMade"
puts "Set variable: theSerialPort to $theSerialPort"
puts "Set variable: theSerialBaud to $theSerialBaud"
puts "Set variable: theCanBaud to    $theCanBaud"
puts "Set variable: COMPUTERNAME to  $COMPUTERNAME"

set ModbusTCPsys 0

#Open Modbus interface in all cases
puts "Open serial ModBus port $theSerialPort with $theSerialBaud baud"
# Usage: ModOpen [Comportnr] [Baudrate] [Stopbits] [Parity]
ModOpen $theSerialPort $theSerialBaud 1 1
if { [GetSysFeat "ATLAS"]} {
	#Open modbus connexion to the load machine
	set LoadPort [mb2Open SER 11 5 19200 E 8 1]
}
#load modbus interface first to get known some needed procs only available by modbus

#ReadParaFile_ATV        $theATVParameterFile
#ReadParaTypeFile_ATV    $theLimitCheckFile
#ReadParaFile_NERA       $theNERAParameterFile
#ReadParaFile_AltiLab    $theAltiLabParameterFile
# includes type information

#readCrQuerryFile $theKalaCRFile

#initialization of enum number global array
Enum_number_init

#doSetCmdInterface $Fieldbus     ;#not here, but in InitializeFieldbus

if {!$HandMade} {
   #Open ModbusTCP interface to Wago
   TlPrint "Open ModBus TCP port $Wago_IPAddress to Wago"
   set rc [catch {mb2Open "TCP" $Wago_IPAddress 1} errMsg]
   if {$rc != 0} {
      TlPrint "Error on ModBusTCP open: $errMsg"
      set ModbusTCPsys 0
   } else {
      TlPrint "ModBus TCP port $Wago_IPAddress is open"
      set ModbusTCPsys 1
   }
}

#source "$libpath/cmd_CableDisconnection.tcl" ;# Cable disconnection commands. Have to be loaded after connection to the PLC
if {[GetSysFeat "FortisLoad"]} {
    source "$libpath/cmd_fortisLoad.tcl"
    ReadParaFile_FortisLoad
}
