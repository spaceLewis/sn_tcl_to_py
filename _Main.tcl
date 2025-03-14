# CPD Testumgebung TCL Main


# ----------HISTORY----------
# WANN      WER      WAS
# 100401    wurtr    Datei angelegt
# 111203    pfeig    Anpassung CPD
# 120204    pfeig    Config nach TK_0Init
# 080404    pfeig    cmd
# 130905    pfeig    AutoLoop
# 071206    pfeig    Dateiname von config nach config_testturm geändert
# 120207    grana    s - Software Kommandos
# 180211    todet    file / file+ - Testcase IDs aus .txt Datei auslesen und ausführen

global Jenkins JenkinsFULLCAMPAIN serialCampaignLaunch ActDev UnifastCI quitFlag exportFlag CIFlash
set quitFlag 0
set exportFlag 0
set Jenkins 0
set JenkinsFULLCAMPAIN 0
set UnifastCI 0
set CIFlash 0
set serialCampaignLaunch 0

global AutoLoop
package require inifile

#
# Config-Datei einlesen
#set configfile "p:/usr/projekte/ids/software/swtest/testturm/config.tcl"
set configfile "TC_0Init/config_tower.tcl"
puts "arguments : "
puts "argc : $argc"
puts "argv : $argv"
# Pruefe ob Configfile in Kommandozeile angegeben wurde
#MODIF : Remplacement de l'entrée liée au fichier de configuration par le passage de la feature de campagne série
if [info exists argc] {
    if {$argc > 0} {
	#set configfile [lindex $argv 0]
	switch [lindex $argv 0] {
	    "serialCampaignLaunch" {
		set serialCampaignLaunch 1
		puts "serial campaign "
	    }

	    "Jenkins" {
		set Jenkins 1
		if {$argc < 2 } {
		    puts "missing device argument "
		    return
		} else {
		    set ActDev [lindex $argv 1]
		}
		puts "Jenkins mode"
		puts "ActDev : $ActDev"
	    }
 
        "JenkinsFULLCAMPAIN" {
            set JenkinsFULLCAMPAIN 1
            if {$argc < 2} {
                puts "Missing device argument"
                return
            } else {
                set ActDev [lindex $argv 1]
            }
            puts "JenkinsFULLCAMPAIN mode"
            puts "ActDev: $ActDev"
        }
 
		"UnifastCI" {
			set UnifastCI 1
			if {$argc < 2 } {
				puts "missing device argument "
				return
			} else {
				set ActDev [lindex $argv 1]
				set CIFlash [lindex $argv 2]
			}
			puts "UnifastCI mode"
			puts "ActDev : $ActDev"
			
		}
	    default {
		set serialCampaignLaunch 1
		puts "serial campaign "
	    }
	}

    } else { 
	set serialCampaignLaunch 0
	puts "campagne unique"
    }

}

puts "=============================================="
puts "=============================================="
puts "=============================================="

source $configfile
cd $testpath

global  theTestSubDirList
global InitialTestDirList
global  theTestDirList
global  theTopScript
global TestsBlocked

set     Geraet   ""
set     theTestDirList
set      theTopScript "0top_Single.tcl"                ;# kann in config_geraete gesetzt werden
set TestsBlocked 0

# alle Testkategorien einlesen
set DirList [glob TC_*/]

foreach dir $DirList {
    lappend theTestSubDirList $dir
}

TlPrint ""
TlPrint "==============================================================="
TlPrint "Testturm started by %s at %s" $env(USERNAME) [clock format [clock seconds] -format "%a %d.%m.%y %H:%M"]
TlPrint "==============================================================="

#MODIF : Affichage du menu que si on n'utilise pas le lancement de campagne en série
#if {  !$serialCampaignLaunch} {
#set Geraet [source TC_0Init/config_device_test.tcl]
#}
# Geraeteinfo in Variablen sichern
#doCheckDeviceAndSetGlobVars

#==========================================================
# proc SubMenuDir
#==========================================================

proc SubMenuDir { } {
    global  theTestSubDirList
    global  theTestDirList
    global  theTopScript
    global  Geraet

    TlPrint ""
    TlPrint "############################################"
    TlPrint "#        MAIN-MENU                         #"
    TlPrint "#  %-32s        # " "$Geraet"
    TlPrint "#                                          #"
    TlPrint "############################################"

    set i 1
    foreach dir $theTestSubDirList {
	TlPrint [format " %2d - %s" $i $dir]
	incr i
    }
    TlPrint "  other key - MainMenu"

    set answer [TlInput "test directory" "" 0]
    TlPrint ""

    switch -regexp $answer {

	"^[0-9]+" {
	    if { ($answer > 0) & ($answer < $i)} {
		set i [expr $answer - 1]
		set dir [lindex $theTestSubDirList $i]
		return $dir
	    } else {
		TlPrint "directory does not exist"
		return ""
	    }

	}

	default {
	    TlPrint ""
	}
    };#switch

    return ""

}; # Prco SubMenuDir

#==========================================================
# proc Commando
#==========================================================

proc Commando {} {
    global errorInfo  globAbbruchFlag Jenkins JenkinsFULLCAMPAIN UnifastCI 

    TlPrint "  x - Exit (Ende)"
    set procedure ""
	
# Check if the 'Jenkins' variable is set
	set isJenkins [expr $Jenkins || $JenkinsFULLCAMPAIN || $UnifastCI]
	
	while { !$isJenkins && ("$procedure" != "x" && "$procedure" != "X") } {
	
	if {$isJenkins || ("$procedure" != "") && ("$procedure" != "x") && ("$procedure" != "X")} {
            set rc [catch "eval $procedure" Msg]
	    # set rc 0

            if {$rc != 0} {
		TlPrint "Error text: %s" $Msg
                # TlPrint "ErrorInfo: $errorInfo"
            } else {
		TlPrint "Output : %s " $Msg

            }
        }

            if {!$UnifastCI} {
			TlPrint "\n Exit with x"

            # TCL Kommando eingeben
            set rc [catch {set procedure [TlInput "TCL> " "" 0]} errMsg]
            TlPrint "\n"
            if {$rc != 0} {
                #set globAbbruchFlag 1
                TlPrint $errMsg
                TlPrint "ErrorInfo: $errorInfo"
            }

			}

    }; # End while
}; # Prco Commando

#==========================================================
# Main
#==========================================================

set InitialTestDirList $theTestDirList
while {1} {

    global serialCampaignLaunch Jenkins JenkinsFULLCAMPAIN mainpath UnifastCI CIFlash
    global theDevList TestModus theTopScript theTestDevList DevType ActDev
    set globAbbruchFlag 0
    set reducedTestExecution 0
    global theTopScript
    set theTopScript "0top_Single.tcl"

    #Main_Layer 1 $theTestDirList
    if {$serialCampaignLaunch} {
	TlPrint "Campagne Serie"

	#		 AllChoicesRun 1 0 0 0 0 0 0
	set selection [towerDisplayDrives]
	TlPrint "============================================"
	TlPrint "answer : $selection"
	TlPrint "============================================"
	set driveList [regexp -all -inline \[0-9\] $selection]

	foreach drive $driveList {
	    TlPrint "Current drive : $drive"
	    #creation of the new night entry in dblog 
	    SQL_WriteTestRun "Night_[clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
	    driveDisplayTestDir $drive
	    set answer $drive
	    set Geraet [source TC_0Init/config_multiDeviceReturn.tcl]
	    AllChoicesRun 1 0 0 0 0 0 0
	    export_campaignSynthesis
	}
    } elseif { $Jenkins}  {
		TlPrint "This is the Jenkins campaign"
		towerDisplayDrives
	    driveDisplayTestDir $ActDev
		set answer $ActDev
	    set Geraet [source TC_0Init/config_multiDeviceReturn.tcl]
		TlPrint "theDevList : $theDevList"
		TlPrint "TestModus : $TestModus"
		TlPrint "theTopScript : $theTopScript"
		TlPrint "theTestDevList : $theTestDevList"
		#Proceed to drive flashing
		source $mainpath//TC_try_TTSW//CampaignLaunching.tcl
		#call the drive flashing procedure
		CampaignLaunching
		fileTC_V2
		#Close Unifast once everything is done
	} elseif { $JenkinsFULLCAMPAIN } {
		TlPrint "This is the JenkinsFULLCAMPAIN campaign"
		towerDisplayDrives
		driveDisplayTestDir $ActDev
		set answer $ActDev
		set Geraet [source TC_0Init/config_multiDeviceReturn.tcl]
		TlPrint "theDevList : $theDevList"
		TlPrint "TestModus : $TestModus"
		TlPrint "theTopScript : $theTopScript"
		TlPrint "theTestDevList : $theTestDevList"
		# Proceed to drive flashing
		source $mainpath//TC_try_TTSW//CampaignLaunching.tcl
		# Call the drive flashing procedure
		CampaignLaunching
		AllChoicesRun 1 0 0 0 0 0 0
	} elseif { $UnifastCI}  {
		TlPrint "This is the UnifastCI campaign"
		towerDisplayDrives
		driveDisplayTestDir $ActDev
		set answer $ActDev
		set Geraet [source TC_0Init/config_multiDeviceReturn.tcl]
		TlPrint "theDevList : $theDevList"
		TlPrint "TestModus : $TestModus"
		TlPrint "theTopScript : $theTopScript"
		TlPrint "theTestDevList : $theTestDevList"
		if { $CIFlash == "true" } {
			# Proceed to drive flashing
			source $mainpath//TC_try_TTSW//CampaignLaunching.tcl
			# Call the drive flashing procedure
			CampaignLaunching
		}
		AllChoicesRun 1 0 0 0 0 0 0

	} else {

        while {1} { 
        	
            set selection [towerDisplayDrives]
            set driveList [regexp -all -inline \[0-9\] $selection]
            if {[driveDisplayTestDir [lindex $driveList 0]] != -1 } {break}
        }
	set answer [lindex $driveList 0]
	set Geraet [source TC_0Init/config_multiDeviceReturn.tcl]
	set InitialTestDirList $theTestDirList	
	Main_Layer 1 $theTestDirList
    }
    set globTestumgebung 0
    TlExit   ;# Close Logfiles 
    exec taskkill /f /pid [pid]

};# while(1)

