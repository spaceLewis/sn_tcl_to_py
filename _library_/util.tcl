# TCL Testturm-Environment
# Utility-functions
# TCT Testturm-Environment
# Global Values
# ----------HISTORY----------
# WHEN      WHO   WHAT
# ?         ?      file created
# 090103    pfeig  Comment
# 100714    hmwang Add SHANGHAI_APP_BEIDOU to proc GetDevFeat, which is used to test Beidou specific functions
# in IOCC
# 170714    hmwang Add discharge resistors to SHANGHAI_APP_BEIDOU in IOCC. The value of discharge resistors is
# 28ou
# 171114    serio  split setAI function into 3
# 120315    serio  add NET feature to GetDevFeat
# 260315    serio  add MotorCableManip feature to GetDevFeat
# 300315    serio  modify writeIpBas
# 020415    serio  add proc doChangeMask
# 160415    serio  remove NET feature from GetDevFeat
# 230715    serio  add Integrated_R to GetDevFeat
# 290622    savra  copied doWaitForNotObject, doWaitForNotModObject, doWaitForNotObjectTol from ATLAS lib (TC_ATS/ATS_lib.tcl)
# 050722    savra  add function compareWithMask
# 170624    MLT    delete MotorCableManip feature to GetDevFeat

#DOC-------------------------------------------------------------------
# PROCEDURE   : read errortext from a file in hashtable
# TYPE        : Library
# AUTHOR      : FiesJ
# DESCRIPTION : ErrorTextFile = Path + IDSerr.INI
#END-------------------------------------------------------------------
proc ReadErrorTextFile { ErrorTextFile } {
	global ErrorText
	if { [file exists $ErrorTextFile ] == 1 } {
		set file [open $ErrorTextFile r]
		while { [gets $file line] >= 0 } {
			if { [string match "E????=*" $line] == 1 } {
				set value [string trim [string range $line 1 4]]
				set Error [string trim [string range $line 6 1000]]
				# Replace for all inverted commas, leads otherwise to writing problems in the data base
				set Error [string map {"'" ""} $Error]
				#            TlPrint "ErrorTextFile : %s , %s" $value $Error
				set ErrorText($value) "$Error"
			}
		}
		close $file
	} else {
		TlError "File <$ErrorTextFile> not available !"
	}
}

# DOC----------------------------------------------------------------
# AUTHOR       : pfeig
# Date         : 04.05.04
# DESCRIPTION
# Load the yet implemented paramater to reduce the mistake amount of the limitcheck
# END----------------------------------------------------------------
proc ReadParaFile { ParaFile } {
	global ImplementedPara
	set ImplementedPara ""
	if { [file exists $ParaFile ] == 1 } {
		set file [open $ParaFile r]
		while { [gets $file line] >= 0 } {
			if { [string length $line] > 1 } {
				set value [string trim [lindex  [split $line " "] 0 ] ]
				set idx [lindex [split $value "_"] 0]
				set six [lindex [split $value "_"] 1]
				set Error [string trim [string range $line 6 1000]]
				# TlPrint "ParameterFile : $idx.$six " $value $Error
				append ImplementedPara "$idx.$six"
			}
		}
		close $file
		#     set ImplementedPara [join ImplementedPara ]
	} else {
		TlError "File <$ParaFile> not available !"
	}
} ;#ReadParaFile

#DOC----------------------------------------------------------------
#DESCRIPTION
#  Detect the configured bus address
#  If Dev = 0 the global configured Device is taken
#  Otherwise the desired Device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 241106 pfeig proc created
#
#END----------------------------------------------------------------
proc GetDevAdr {Bus {Dev 0}} {
	global ActDev DevAdr
	if {$Dev == 0} {
		set Dev $ActDev
	}
	set rc [catch {set Adr $DevAdr($Dev,$Bus)} errMsg]
	if {$rc != 0} {
		TlError "Error by address detection: $errMsg"
		return 0
	} else {
		return $Adr
	}
}

# Available device features:
#
#   Kala                = Kala Plattform drive (Fortis, Nera, Beidou...)
#   Fortis              = Kala Fortis drive
#   Nera                = Kala Nera drive
#   Nera_200V           = Nera drive, supplied with 200V single phase only
#   Opal                = Opal drive
#   Beidou              = Kala Beidou drive
#   Altivar             = ATV32
#   DevAll              = always 1
#   DevNone             = always 0
#   MotAC               = Servo Motor
#   MotASM              = Async Motor
#   MotSM		= Sync Motor
#   BusCAN              = Fieldbus CAN available
#   BusDevNet           = Fieldbus DeviceNET available
#   BusPBdev            = Fieldbus Profibus available
#   BusPN               = Fieldbus Profinet available
#   BusECAT             = Fieldbus EtherCAT available
#   BusMBTCP            = Fieldbus ModBus TCP available
#   BusMBTCPioScan      = ModBus TCP IO Scanning available
#   BusEIP              = Fieldbus Ethernet IP available
#   BusSys              = Connection to WAGO controller was established
#   Modul_IO            = IO Standard Module plugged
#   Modul_Relais        = Relais Option plugged
#   Modul_Relais_D      = Relais Option connected to WAGO
#   Modul_IO_D          = Digital in/out of IOSTD connected to WAGO
#   Modul_IO_S          = Analog in/out of IOSTD connected to WAGO
#   Modul_IO_R          = Analog in/out of IOSTD connected to Resistor network
#   Modul_SM1           = Safety Module (on Fortis) Device 1
#   Card_EthBasic       = Basic Ethernet Card embedded on the drive
#   Board_EthAdvanced   = Ethernet Advanced Option plugged
#   Card_AdvEmbedded    = Ethernet Advanced, embedded on Fortis
#   Board_Profinet      = ProfiNET Option plugged
#   DCDischarge         = Discharge Resistor available for drive DC Bus
#   NoComOption         = No Fieldbus Option board plugged
#   Load                = Load device is connected to motor

proc GetDevFeat {feature} {
	global EthernetBus Protocol
	global EncMultiTurn ModbusTCPsys
	global PrgNr COMPUTERNAME
	global theTestDevList
	global DevType ActDev DevOptBd
	global lstFeatures DeviceFeatureList remanentDeviceFeatureList
	global ActDevConf
	# Check if the requested feature is valid
	set rc [catch {set result [lsearch $lstFeatures $feature]}]
	if {$rc != 0} {
		TlError "The DevFeat '$feature' is unknown. Check the 'lstFeatures' in 'ReadConfigValues' in 'cmd_tower.tcl'"
		puts \a\a
		doWaitMs 500
		puts \a\a
		if {[bp "Debugger"]} {
			return 0
		}
	} else {
		if {$result == -1} {
			TlError "The DevFeat '$feature' is unknown. Check the 'lstFeatures' in 'ReadConfigValues' in 'cmd_tower.tcl'"
			puts \a\a
			doWaitMs 500
			puts \a\a
			if {[bp "Debugger"]} {
				return 0
			}
		}
	}
	# check if the requested feature is available on the current drive
	# common features, valid for all systems and drives
	switch -exact $feature {
		"DevAll"  { return 1 }
		"multipleCom"  { return 1 }
		"DevNone" { return 0 }
		"BusSys" {return $ModbusTCPsys}
	}
	# dedicated features, defined in .ini files
	set rc [catch {set result [lsearch $DeviceFeatureList($ActDev) $feature]}]
	# also look into the feature's list that are defined outside the ini files (during campaign)
	set rc2 [catch {set result2 [lsearch $remanentDeviceFeatureList($ActDev) $feature]}]
	if { ( $rc == 0 ) && ( $result != -1 ) || ( $rc2 == 0 ) && ( $result2 != -1 ) } {
		return 1
	} else {
		return 0
	}
}

# Available device features:
#
#   PACY_COM_DEVICENET          = OPAL Testsystem 1 PACY_COM_DEVICENET
#   PACY_COM_PROFIBUS          = OPAL Testsystem 2 PACY_COM_PROFIBUS
#   PACY_APP_OPAL          = OPAL Testsystem 3 PACY_APP_OPAL
#   PACY_COM_PROFINET          = OPAL Testsystem 4 PACY_COM_PROFINET
#   PACY_COM_ETHERCAT          = OPAL Testsystem 5 PACY_COM_ETHERCAT
#   PACY_COM_CANOPEN          = OPAL Testsystem 6 PACY_COM_CANOPEN
#   PACY_APP_NERA          = OPAL Testsystem 7 PACY_APP_NERA
#   PACY_SFTY_FORTIS        = Fortis Testsystem 1
#   PACY_APP_FORTIS        = Fortis Testsystem 2
#   PACY_SFTY_OPAL        = Fortis Testsystem 3
#   ModiconPLC             = Modicon PLC available
#
#   + all features of GetDevFeat
#
proc GetSysFeat {feature} {
	global ModbusTCPsys
	global COMPUTERNAME
	global theDevList
	global ActDev
	global lstFeatures SystemFeatureList DeviceFeatureList remanentDeviceFeatureList
	# Check if the requested feature is valid
	set rc [catch {set result [lsearch $lstFeatures $feature]}]
	if {$rc != 0} {
		TlError "The DevFeat '$feature' is unknown. Check the 'lstFeatures' in 'ReadConfigValues' in 'cmd_tower.tcl'"
		puts \a\a
		doWaitMs 500
		puts \a\a
		if {[bp "Debugger"]} {
			return 0
		}
	} else {
		if {$result == -1} {
			TlError "The DevFeat '$feature' is unknown. Check the 'lstFeatures' in 'ReadConfigValues' in 'cmd_tower.tcl'"
			puts \a\a
			doWaitMs 500
			puts \a\a
			if {[bp "Debugger"]} {
				return 0
			}
		}
	}
	# check if the requested feature is available on the current drive
	# common features, valid for all systems and drives
	switch -exact $feature {
		"DevAll"  { return 1 }
		"multipleCom"  { return 1 }
		"DevNone" { return 0 }
		"BusSys" {return $ModbusTCPsys}
	}
	# dedicated features, defined in .ini files
	set rc [catch {set result [lsearch $SystemFeatureList $feature]}]
	if {( $rc == 0 ) && ( $result != -1 )} {
		return 1
	}
	# Testdevices: 1 to 9
	foreach Dev $theDevList {
		# dedicated features, defined in .ini files
		set rc [catch {set result [lsearch $DeviceFeatureList($ActDev) $feature]}]
		# also look into the feature's list that are defined outside the ini files (during campaign)
		set rc2 [catch {set result2 [lsearch $remanentDeviceFeatureList($ActDev) $feature]}]
		if { ( $rc == 0 ) && ( $result != -1 ) || ( $rc2 == 0 ) && ( $result2 != -1 ) } {
			return 1
		}
	}
	return 0
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : bp
# TYPE        : Library
# AUTHOR      : ASPN Cookbooks / pfeig
# DESCRIPTION : A minimal debugger
#
#END-------------------------------------------------------------------
proc bp {{s {}}} {
	if {![info exists ::bp_skip]} {
		set ::bp_skip [list]
	} elseif {[lsearch -exact $::bp_skip $s]>=0} {
		return 0
	}
	set who [info level -1]
	while 1 {
		# Display prompt and read command.
		puts -nonewline "$who/$s> "; flush stdout
		gets stdin line
		# Handle shorthands
		if {$line=="c"} {
			puts "continuing.."
			return 0
		}
		if {$line=="i"} {set line "info locals"}
		if {$line=="r"} {
			puts "return from proc '$who'.."
			return 1
		}
		# Handle everything else.
		catch {uplevel 1 $line} res
		puts $res
	}
}

proc getBlState {} {
	set STATE [expr [doReadObject STD.STATUSWORD] & 0xf]
	return $STATE
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : bp
# TYPE        : Library
# AUTHOR      : ASPN Cookbooks / pfeig
# DESCRIPTION : A minimal debugger
#
#END-------------------------------------------------------------------
#proc bp {{s {}}} {
#
#   if {![info exists ::bp_skip]} {
#      set ::bp_skip [list]
#   } elseif {[lsearch -exact $::bp_skip $s]>=0} {
#      return 0
#   }
#   set who [info level -1]
#   while 1 {
#      # Display prompt and read command.
#      puts -nonewline "$who/$s> "; flush stdout
#      gets stdin line
#
#      # Handle shorthands
#      if {$line=="c"} {
#         puts "continuing.."
#         return 0
#      }
#      if {$line=="i"} {set line "info locals"}
#      if {$line=="r"} {
#         puts "return from proc '$who'.."
#         return 1
#      }
#
#      # Handle everything else.
#      catch {uplevel 1 $line} res
#      puts $res
#   }
#}

#======================================================================
# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Command to reset the product
#
# ----------HISTORY----------
# WANN   WER      WAS
# 200612 rothf    proc created
# 250913 todet    adapted for nera/beidou
#
#END----------------------------------------------------------------
proc doReset { {Status 2} } {
	global ActDev DevAdr
	global glb_AccessExcl
	TlPrint "--------------------------------------------------------"
	TlPrint "doReset {} - Reset Device"
	# At the moment, Nera/Beidou are not executing the RP command correctly
	# Use a hard-reset until it is fixed
	#240614 ockeg: only Kala products are supported
	#if { [GetDevFeat "Kala"] } {
	# workaround to avoid removal of testcategories, if modbus address is reset to 0
	set AddrOld $DevAdr($ActDev,MOD)
	set DevAdr($ActDev,MOD) 0xF8
	DeviceFastOffOn $ActDev 1 $Status
	set DevAdr($ActDev,MOD) $AddrOld
	#} else {
	#   TlWrite RP 1
	#   doWaitForOff                           ;#Wait that drive is off
	#   doWaitForState $Status 3                     ;#Wait for ready state
	#}
}

proc EncoderAdapt { {openloop 0} } {
    global ActDev
    # openloop = 1 : open loop , openloop = 0 : close loop
    if { $openloop == 1  } {
	TlWrite CTT .VVC
	doWaitForObject CTT .VVC 1
	TlWrite ENU  .SEC         ;# Encoder use:  SEC=Security only, REG=Security and regulation
    } else {
	if { [GetDevFeat "MotASM"] } {
	    TlWrite CTT .FVC
	    doWaitForObject CTT .FVC 1
	} else {
	    TlWrite CTT .FSY
	    doWaitForObject CTT .FSY 1
	}
	TlWrite ENU  .REG         ;# Encoder use:  SEC=Security only, REG=Security and regulation
    }
    if {[GetSysFeat "PACY_SFTY_FORTIS"]} {
	switch -regexp $ActDev {
	    1 {
		TlWrite RPPN .2P        ;# 4 poles
		doWaitForObject RPPN .2P 1
		TlWrite TRES .05        ;# transformation ratio 0,5
		doWaitForObject TRES .05 1
		TlWrite REFQ  .8K        ;# Resolver frequency 8kHz
		doWaitForObject REFQ .8K 1
	    }
	    2 {
		# Settings of Encoder SSI
		TlWrite UECP   .SSI         ;# SSI encoder
		TlWrite UECV    12         ;# 5=5V, 12=12V, 24=24V
	    }
	}
    }
    if {[GetSysFeat "PACY_SFTY_OPAL"]} {
	switch -regexp $ActDev {
	    1 {
		# Settings of Encoder AB
		TlWrite UECP  .AB
		TlWrite UECV   5
		TlWrite ENRI .YES
		TlWrite PGI 1024
		TlWrite PDI 1
		TlWrite ENS .AABB
	    }
	    2 {
		# Settings of Encoder SSI
		TlWrite UECP  .SSI
		TlWrite UECV   12
		TlWrite ENRI .YES
		TlWrite SSCP .NO
		TlWrite ENMR 12
		TlWrite ENTR 13
		TlWrite SSCD .BIN
		TlWrite ENSP 1
		TlWrite SSFS 0
	    }
	}
    }
    if {[GetSysFeat "PACY_APP_OPAL"]} {
	switch -regexp $ActDev {
	    1 {
		TlWrite UECP  .SC          ;# SinCos encoder
		doWaitForObject UECP  .SC 1
		TlWrite UECV   12       ;# 5=5V, 12=12V, 24=24V
		doWaitForObject UECV   12 1
		TlWrite UELC   1024    ;# Universal Encoder Line Count
		doWaitForObject UELC   1024  1
		TlWrite ENRI  .NO          ;# Encoder Rotation Inversion
		doWaitForObject ENRI  .NO 1
	    }
	    2 {
		# Settings of Encoder SSI
		TlWrite UECP   .SSI         ;# SSI encoder
		TlWrite UECV    12         ;# 5=5V, 12=12V, 24=24V
	    }
	}
    }
    if {[GetSysFeat "PACY_COM_PROFIBUS"]} {
	switch -regexp $ActDev {
	    1 {
		TlWrite EECP  .AB          ;# AB encoder
		TlWrite EECV  .12V         ;# embedded only 12=12V
		TlWrite EERI  .NO         ;# Encoder Rotation Inversion
		#              TlWrite EENU  .REG         ;# Encoder use:  SEC=Security only, REG=Security and regulation
		TlWrite EPGI  4096     ;# Encoder pulse number
		TlWrite PDI   1            ;# PLC encoder pulse divisor
	    }
	    2 {
		# Settings of Encoder SSI
		TlWrite EECP  .SC          ;# SinCos encoder
		TlWrite EECV  .12V         ;# embedded only 12=12V
		TlWrite EELC   128   ;# Universal Encoder Line Count
		TlWrite EERI  .NO          ;# Encoder Rotation Inversion
		#TlWrite EENU  .REG         ;# Encoder use: SEC=Security only, REG=Security and regulation
	    }
	}
    }
    if {[GetSysFeat "PACY_COM_PROFINET"]} {
	switch -regexp $ActDev {
	    1 {
		TlWrite RPPN .2P        ;# 4 poles
		doWaitForObject RPPN .2P 1
		TlWrite TRES .05        ;# transformation ratio 0,5
		doWaitForObject TRES .05 1
		TlWrite REFQ  .8K        ;# Resolver frequency 8kHz
		doWaitForObject REFQ .8K 1
	    }
	    2 {
		# Settings of Encoder SSI
		TlWrite UECP   .SSI         ;# SSI encoder
		TlWrite UECV    12         ;# 5=5V, 12=12V, 24=24V
	    }
	}
    }
    doStoreEEPROM
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : Reset user parameter to default value through PARUSERRESET
# DESCRIPTION :
#
#   1: Set user parameter to default value
#      All parameter are reset except for:
#      - Communication parameter
#      - Definition of sense of rotation
#      - Signal selection position interface
#      - Device control
#      - Logic type
#      - Start mode of operation for 'local control mode'
#      - ESIM settings
#      - Motor type
#      - Adaptation of motor encoder
#      - EA functions
#   2: Restore regulator parameter for the Testturm
#   3: Store everything in EEPROM
#
#   the reset user parameters are now available,
#   the device doesn't need to be put off/on !
#
#END-------------------------------------------------------------------
proc doResetUserParam { } {
	global COMPUTERNAME
	TlPrint "--------------------------------------------------------"
	TlPrint "doResetUserParam {} - Set user parameter to default value"
	# WARNING: PARUSERRESET doesn't store in EEPROM!
	TlWrite         PARAM.PARUSERRESET 1
	doWaitForObject PARAM.PARUSERRESET 0 2
	if { [GetDevFeat MotAC] } {
		WriteValueAutotune
	}
	TlPrint "in EEPROM speichern"     ;# now all in EEPROM!
	doStoreEEPROM
	#   TlWrite         PARAM.STORE 1
	#   doWaitForObject PARAM.STORE 0 2
} ;# doResetUserParam

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# factory settings:
# FRY (Factory setting mask)
#   Bit0 = 1 : All parameters
#   Bit1 = 1 : Drive configuration
#   Bit2 : Reserved
#   Bit3 = 1 : Motor parameters
#   Bit4 = 1 : Communication menu
#   Bit5 : Reserved
#   Bit6 : Reserved
#   Bit7 = 1 : Display menu
#   Bit8 : Reserved
#   Bit9 : Reserved
#   Bit10 : Reserved
#   Bit11 : Reserved
#   Bit12 : Reserved
#   Bit13 : Reserved
#   Bit14 : Reserved
#   Bit15 : Reserved (Bit15 = 1 : Communication option parameters)
#
# ----------HISTORY----------
# 280114 ockeg proc created
# 170414 ockeg fry_mask
#
#END----------------------------------------------------------------
proc doFactorySetting { {fry_mask 0x0001} } {      ;# default: Bit0 = 1 : All parameters
	global globAbbruchFlag DevAdr ActDev
	TlPrint "--------------------------------------------------------"
	TlPrint "doFactorySetting {} - "
	#do not interrupt saving!!
	set globAbbruchFlag_save $globAbbruchFlag
	set globAbbruchFlag 0
	switch $fry_mask {
		0x0001  { TlPrint "--- request factory settings: All parameters" }
		0x0002  { TlPrint "--- request factory settings: Drive configuration" }
		0x0008  { TlPrint "--- request factory settings: Motor parameters" }
		0x0010  { TlPrint "--- request factory settings: Communication parameters" }
		0x0080  { TlPrint "--- request factory settings: Display parameters" }
		0x008A  { TlPrint "--- request factory settings: All except communication parameters" }
		default { TlError "--- invalid factory settings mask: 0x%04X" $fry_mask
			return 0
		}
	}
	if { [GetDevFeat "Altivar"] } {
		ModTlWrite MODE 0x5443
		ModTlWrite RAZI 0x0200
		ModTlWrite MODE 0x5250
		doWaitForState 2 10
		ModTlWrite MODE 0x5250
		doWaitForOff 10
		doWaitMs  5000
		if { [GetSysFeat "PACY_COM_PROFINET2"] }  {
			TlWrite ADD 4
			doWaitForObject ADD 4 1
			doStoreEEPROM
			ModTlWrite MODE 0x5250
			doWaitForObjectList HMIS {.FLT .RDY .NST} 2  ;# in case of FLT it's normal to be in FLT because PNT card don't have valid IP add.

		}
	} else {                                     ;# for Nera
		#TlPrint "Modbus timeouts are %s" [ModGetTimeout]
		ModTlWrite           FRY   $fry_mask
		doWaitForModObject   FRY   $fry_mask 1
		doWaitForEEPROMFinished 50
		ModTlWrite           CGTY .CUS            ;# customer factory setting -> delete System:/Conf/OEM
		doWaitForEEPROMFinished 50
		checkModObject       CGTY .CUS
		ModTlWrite           CMI   1              ;# Bit0 = 1 : Factory setting asked
		doWaitForEEPROMStarted  1
		doWaitForEEPROMFinished 50 0  ;# no mintime
		if {([GetDevFeat "Fortis"] && [GetSysFeat "PACY_SFTY_FORTIS"]) ||([GetDevFeat "Opal"] && [GetSysFeat "PACY_COM_PROFIBUS"])  } {
			TlWrite MODE .TP
			doWaitMs 1000
			doChangeMask DBGF 0x4000 1 2
		}
	}
	if {[GetDevFeat "MVK"]} {
		TlWrite MODE .TP
		TlWrite OCT3 2
		doWaitForObject OCT3 2 1
		if { [GetDevFeat "AdaptationBoard"] } {
			TlWrite SIMM .SIM2
			doWaitForObject SIMM .SIM2 1
		} else {
			TlWrite SIMM .SIM1
			doWaitForObject SIMM .SIM1 1
		}
		TlWrite ADD $DevAdr($ActDev,MOD)
		TlWrite PLI1 .NO
		doStoreEEPROM
		TlWrite MODE .RP
		doWaitMs 10000
	}

	set globAbbruchFlag $globAbbruchFlag_save

	TlPrint "-end----------------------------------------------------"

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# - restore default parameters "factory setting"
# - write back all communication parameters
# - store in EEPROM
# - reboot devive only when parameter reboot == 1
# - wait for state 2=RDY or 3=NST, otherwise do not wait
#
# ----------HISTORY----------
# 150414 ocked use doFactorySetting and doStoreEEPROM, should be safe now
#              reboot only if wanted
#              waitfor state 2=RDY or 3=NST only if wanted
# 230414 serio create block to rewrite default values modified and influencing developped tests
# 181214 serio add baudrate update after factory settings
# 310315 serio correct DBGF
# 190722 savra Added the writing of PRFC according to the ProfinetV2_Mode feature
# 100924 bcroi Added safety configuration for PACY_SFTY_FIELDBUS tower
#
#-----------------------------------------------------------------------
proc doSetDefaults { {reboot 1} {state 0} } {
	global ActDev DevAdr DevAdr_Orig BlePath MotASMParam lstMotASMParam IOScanConf
	global libpath ActInterface
	global COMPUTERNAME glb_Error Dev_On DevID
	global theSerialBaud
	global theDevList
	global GLOB_LAST_DRIVE_REBOOT
	global mainpath
	if { $reboot } {
		TlPrint "Reset factory settings, with reboot, final state=$state"
	} else {
		TlPrint "Reset factory settings, no reboot, final state=$state"
	}
	set FBInterface $ActInterface
	# use Tl commands with MOD
	doSetCmdInterface "MOD"
	if {([GetDevFeat "Nera" ] || [GetDevFeat "Beidou" ]) && ![GetSysFeat "Gen2Tower"]} {
		if {$Dev_On(1)} {
			TlPrint "Altivar is on, switch it off"
			wc_OpalOnOff 1 L
			doWaitMs 5000
		}
	}
	if {[GetDevFeat "Fortis"] || [GetDevFeat "Opal"]} {
		foreach Dev $theDevList {
			if {[info exists DevAdr($Dev,Load)]} {
				set ActDevOld $ActDev
				set ActDev $Dev
				TlPrint "check if Load device of Dev$Dev is still running"
				if {[LoadRead MAND.PRGNR 1] != ""} {
					TlError "Load Device of Dev$Dev still on!"
					LoadOff
				}
				set ActDev $ActDevOld
			}
		}
	}
	set ActAdr $DevAdr_Orig($ActDev,MOD)
	TlPrint "Change modbus address of device $ActDev from $ActAdr to broadcast 0xF8"
	set DevAdr($ActDev,MOD) 0xF8        ;#will be restored in below
	# print out error memory before factory reset, otherwise information may be lost
	doDisplayErrorMemory
	# reset inputs of actual device
	doResetDeviceInputs $ActDev
	if {![info exists GLOB_LAST_DRIVE_REBOOT]} {
		set GLOB_LAST_DRIVE_REBOOT 0
	}
	if {([clock clicks -milliseconds] - $GLOB_LAST_DRIVE_REBOOT) < 20000} {
		doWaitMs 5000
	}
	# do the factory setting
	doFactorySetting
	if {[GetDevFeat "MVK"] } {
		ShowStatus
		#doWaitMs 10000
	}
	#write the baudrate if different than default
	TlWrite TBR .$theSerialBaud
	doWaitForObject TBR .$theSerialBaud 1
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
	# WriteProdName  ;# for debug use
	# Write original communication's and motor parameter in device and store in EEPROM
	WriteAdr $ActAdr MOD
	doStoreEEPROM
	if { ![GetDevFeat "MVK"]} {
		writeAppName $DevID($ActDev,ModelName)    ;#Write product application number
	} else {
		writeAppName "ATV6000"
	}
	if {![GetDevFeat "MVK"]} {
		WriteMotorData
	}
	WriteEncoderConfiguration
	if { ![GetDevFeat "Opal"] & ![GetDevFeat "Altivar"] } {
		TlWrite LCAC .NO        ;# Life cycle alarm configuration = off (what does that mean?)
	}
	TlWrite RIN  .NO        ;# Allow reverse operation
	#Write back default parameters as they were during test development
	TlWrite ACC 30
	doWaitForObject ACC 30 1
	TlWrite DEC 30
	doWaitForObject DEC 30 1
	#Relais issue with ready state
	#todo : remove after clarification of "GEDEC00185112"
	if { ![GetDevFeat "Opal"] & ![GetDevFeat "Altivar"] } {
		if { [Enum_Name R3 [TlRead R3] ] == "RDY" } {
			TlWrite R3 .NO
			doWaitForObject R3 .NO 1
		}
	}
	#todo : remove after solving of "GEDEC00222204"
	if {[GetDevFeat "Fortis"] && [GetDevFeat "Modul_SM1"]} {
		TlWrite FLU .FNC
		doWaitForObject R3 .NO 1
	}
	#write safety config if not already inside the drive
	if {([GetDevFeat "Fortis"] ||[GetDevFeat "Opal"]) && [GetDevFeat "Modul_SM1"] && ![GetSysFeat "PACY_SFTY_FIELDBUS"]} {
		global ratio ratio2 ratio3 ratio4
		if { [GetDevFeat "MotASM"] } {
			set ratio 1
			set ratio2 1
			set ratio3 1
			set ratio4 1
		} else {
			set ratio 10
			set ratio2 4
			set ratio3 0
			set ratio4 6
		}
		if { [GetDevFeat "MotAC"] } {
			TlWrite HSP 2000
			TlWrite CMI 2
			doWaitMs 5000
		}
		doStoreEEPROM
		TlWrite MODE .TP
		doChangeMask DBGF 0x4000 1 2
		if {[SM_GetSftyConfStatus 0] != 5} {
			# SM_GetSftyConfStatus = 2 = SFTY CONF NOT CONFIGURED
			#         SM_WriteSafetyConfig 1
			doConfigurationTest
			EncoderAdapt 0
		}
	}
	#Write safety configuration if not already inside the Safety Module
    if {([GetDevFeat "Fortis"] ||[GetDevFeat "Opal"]) && [GetDevFeat "Modul_SM1"] && [GetSysFeat "PACY_SFTY_FIELDBUS"]} {
	if {[GetDevFeat "MotASM"]} { ;# Open loop configuration with asynchronous motor
	    WriteControlLaw 0 ;#  Configure motor control law to OpenLoop
	    safety_defaultConfiguration ;# initialize the parameter list dedicated to safety
	    safety_doFactorySetting ;# do a factory setting on the safety card
	    safety_doConfigurationTest 0 ;# writes the safety configuration to the card (Open Loop)
	} else { ;# Closed loop configuration with synchronous motor
	    WriteControlLaw 1 ;#  Configure motor control law to Closed Loop
	    safety_defaultConfiguration ;# initialize the parameter list dedicated to safety
	    safety_doFactorySetting ;# do a factory setting on the safety card
	    safety_doConfigurationTest 1 ;# writes the safety configuration to the card (Closed Loop)
	}

    }


	if { ![GetDevFeat "Altivar"] && ![GetDevFeat "MVK"]} {
		TlWrite FFM .ECO
		doWaitForObject FFM .ECO 1
		TlPrint "Fan mode: ECO"
		doWaitMs 2000
	}

	if {[GetDevFeat "MVK"]} {
		if {[GetDevFeat "SimuMode"]   } {
			TlWrite MODE .TP
			TlWrite OCT3 2
			doWaitForObject  OCT3 2  1
			TlWrite PL00 1
			doWaitForObject PL00 1 1
			if { [GetDevFeat "AdaptationBoard"]  } {
				TlWrite SIMM .SIM2
				doWaitForObject SIMM .SIM2 1
				doStoreEEPROM
				doWaitForEEPROMFinished 10
				# activation of event recorder to save fault of drive even if RAZI = 512 is done
				TlWrite ERRQ 1
				doWaitForObject ERRQ 1 2
				# declaration of type of PLC module
				TlPrint "D2PV -> [TlRead D2PV] and OD2T -> [TlRead OD2T]"
				TlWrite OCC1 1
				doWaitForObject OCC1 1 1
				TlWrite OCC2 2
				doWaitForObject OCC2 2 1
				TlWrite OCC3 3
				doWaitForObject OCC3 3 1
				TlWrite OCC4 4
				doWaitForObject OCC4 4 1
				TlWrite OCC5 5
				doWaitForObject OCC5 5 1
				TlWrite OCC6 6
				doWaitForObject OCC6 6 1
				# configuration HMIP
				TlWrite MRJ2 .HMIP
				doWaitForObject MRJ2 .HMIP 1
				TlWrite OCCT .CAB4
				doWaitForObject OCCT .CAB4 1
				TlWrite PLI1 .NO
				doWaitForObject PLI1 .NO 1
				TlWrite SFE2 1
				doWaitForObject SFE2 1 1
				#PLC inputs
				# Reset all
				for {set i 0} {$i < 24} {incr i} {
					setDI_PLC_MVK $i L
				}
				for {set i 1} {$i < 8} {incr i} {
					setAI_PLC_MVK $i 0
				}
				# Initial conditions to prevent CFx fault
				setDI_PLC_MVK 0 H
				setDI_PLC_MVK 6 H
				setDI_PLC_MVK 13 H
				setDI_PLC_MVK 19 H
				setDI_PLC_MVK 20 H
				setDI_PLC_MVK 21 H
				setDI_PLC_MVK 22 H
				setDI_PLC_MVK 23 H
				SlaveOnOff 1 L
				SlaveOnOff 2 L
				TlWrite PLS0 .OLRP
				doWaitForObject PLS0 .OLRP 1
				TlWrite CCS 332
				doWaitForObject CCS 332 1
				TlWrite RFC 333
				doWaitForObject RFC 333 1
				TlWrite FLO 334
				doWaitForObject FLO 334 1
				TlWrite FR1 .AI1
				doWaitForObject FR1 .AI1 1
				TlWrite FR2 .PLCI
				doWaitForObject FR2 .PLCI 1
				#debug campaign
				TlWrite FLOC .HMIP
				doWaitForObject FLOC .HMIP 1
				setDI_PLC_MVK 16 H
				setDI_PLC_MVK 17 L
				setDI_PLC_MVK 18 L
				TlWrite BFR .50Hz
				doWaitForObject BFR .50Hz 1
				doStoreEEPROM
				if { $IOScanConf == 0 } { 
					MVK_IOScannerConfiguration
					set IOScanConf 1 
				}
				TlWrite MODE .TP
				doWaitForObject MODE .TP 1
				TlWrite OCT4 [TlRead OD2M]
				doWaitForObject OCT4 [TlRead OD2M] 1
			} else {
				TlWrite SIMM .SIM1
				doWaitForObject SIMM .SIM1 1
			}
			TlWrite CTT .VVC
			doWaitForObject CTT .VVC 1
			TlWrite RIN .NO
			doWaitForObject RIN .NO 1
			TlWrite BRA .NO
			doWaitForObject BRA .NO 1
			TlWrite FLU .FNO
			doWaitForObject FLU .FNO 1
			TlWrite RRS .LI2
			doWaitForObject RRS .LI2 1
			#MERGE 0001 from profinet tower impact on ethercat tower
			#set PCNx
			TlWrite PCNA 21590
			doWaitForObject PCNA 21590 1     ;#PCNA = "AT"
			TlWrite PCNB 13872
			doWaitForObject PCNB 13872 1     ;#PCNB = "V6"
			TlWrite PCNC 12336
			doWaitForObject PCNC 12336 1      ;#PCNC = "00"
			#set CLI to max value ( value automatically set to max possible possible compared to the drive reference
			TlWrite CLI 65535

			doStoreEEPROM
			doWaitMs 10000
			DeviceOff $ActDev 1
			doWaitMs 5000
			DeviceOn $ActDev
			doWaitMs 10000
		}
	}
	if { [GetDevFeat "Altivar"] || [GetDevFeat "MVK"]} {
		if {![GetSysFeat "PACY_APP_NERA"]} {
			TlWrite OPL .NO
			doWaitForObject OPL .NO 1
			TlWrite BRA .NO
			doWaitForObject BRA .NO 1
			doStoreEEPROM
		}
		doStoreEEPROM
		ATVWriteRunCFG MODE 0x5250
	}
	doWaitMs 2000
	if {[GetDevFeat "COPLA40_CMPT_FW_SPI" ]} {
		TlWrite PRFC 1
		doWaitForObject PRFC 1 1
	}
	if {[GetDevFeat "COPLA40_NORM_FW_SPI" ]} {
		TlWrite PRFC 0
		doWaitForObject PRFC 0 1
	}
	
        if {[GetDevFeat "FW_ATVPredict" ]} {
        	ATVPredictCommissioning
        }
	
	# store all parameters in EEPROM
	doStoreEEPROM
	if { $reboot  } {
		if { [GetDevFeat "MVK"] } { doWaitMs 10000 } ;# Waittime needed for MVK 
		DeviceOff $ActDev 1
		if { [GetDevFeat "MVK"] } { doWaitMs 5000 } ;# Waittime needed for MVK 
		set DevAdr($ActDev,MOD) $ActAdr
		DeviceOn $ActDev
		if { [GetDevFeat "MVK"] } { doWaitMs 1000 } ;# Waittime needed for MVK 
	} else {
		set DevAdr($ActDev,MOD) $ActAdr
	}
	TlPrint "Actual internal Modbus address: $DevAdr($ActDev,MOD)"
	# Return in previous interface
	doSetCmdInterface $FBInterface
	#wait for state 2=RDY or 3=NST, otherwise don't wait
	switch $state {
		2 -
		"RDY" {
			;# rtso = Ready to switch on
			doFaultReset "rtso" "MOD"
			doWaitForState .RDY 2         ;# GEDEC00176294 is closed
		}
		3 -
		"NST" {
			;# sod = Switch on disabled
			doFaultReset "sod" "MOD"
			doWaitForState .NST 2         ;# GEDEC00176294 is closed
		}
	}
}  ;# doSetDefaults

# Doxygen Tag:
##Function description : write encoder configuration from ini file to the drive  
#
# ## History :
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2024/08/29 | ASY  | proc created 
# 09/11/2024 | BC   | update with ActDev instead of ActDevConf
#
proc WriteEncoderConfiguration { } {
    global encoderParameters lstEncoderParam
    global theNERAParaNameRecord
    global ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteEncoderConfiguration {} - Write encoder configuration "

    foreach Param $lstEncoderParam {
	if { [info exists encoderParameters($ActDev,$Param)] } {
	    set rc [catch { set retVal $theNERAParaNameRecord($Param) }]
	    if { $rc == 0} {
		doPrintObject     $Param                                 ;# print state before
		TlWrite           $Param $encoderParameters($ActDev,$Param)    ;# write new value
	    }
	}
    }
	TlPrint "-end----------------------------------------------------"
}

# Doxygen Tag:
## Function description : Function used to write control law with encoder in open and closed loop
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2024/09/13 | BC  | proc created
#
# \param[in] Loop : boolean that is the image of the encoder looping ( 0 open / 1 closed )
#
proc WriteControlLaw { loop } {
	
    TlPrint "--------------------------------------------------------"
    TlPrint "WriteControlLaw {loop} - Write control law"
	
    if {[GetDevFeat "Fortis"] || [GetDevFeat "Opal"]} {
	#Handling the open loop configuration
	if { !$loop } {
	    if { [GetDevFeat "MotASM"] } { ;# Asynchronous motor configuration
		TlWrite CTT .VVC
		doWaitForObject CTT .VVC 1
	    } else { ;# Synchronous motor configuration
		TlWrite CTT .SYN
		doWaitForObject CTT .SYN 1
	    }
	    #Encoder configuration in open loop
	    TlWrite ENU  .SEC         ;# Encoder use:  SEC=Security only, REG=Security and regulation
	    doWaitForObject ENU .SEC 1
	} else { ;#closed loop
	    if { [GetDevFeat "MotASM"] } { ;# Asynchronous motor configuration
		TlWrite CTT .FVC
		doWaitForObject CTT .FVC 1
	    } else { ;# Synchronous motor configuration
		TlWrite CTT .FSY
		doWaitForObject CTT .FSY 1
	    }
	    #Encoder configuration in closed loop
	    TlWrite ENU  .REG         ;# Encoder use:  SEC=Security only, REG=Security and regulation
	    doWaitForObject ENU .REG 1
	}
    } else {
	TlError "Encoder & Closed loop are not supported in this product"
    }
    TlPrint "-end----------------------------------------------------"
}

proc ATVWriteRunCFG {Object Value} {
	set DataParam     [GetParaAttributes $Object]
	set LogAdr        [lindex $DataParam 0]
	global DevAdr ActDev
	set MBAdr $DevAdr($ActDev,MOD)
	set TxFrame [format "%02X06%04X%04X"             $MBAdr $LogAdr $Value]
	mbDirect $TxFrame 1
	TlPrint "ATVWriteRunCFG $DevAdr($ActDev,MOD) $Object $Value"
}

# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Restore default parameters using FRY mask
#
# ----------HISTORY----------
# WANN   WER      WAS
# 170912 lefef    proc created
# 150414 ockeg    use WaitForEEPROMFinished
#
#END----------------------------------------------------------------
proc doAdjustDefaults { {SetMask 1} {RP 0} } {
	global ActDev DevAdr
	set ActAdr $DevAdr($ActDev,MOD)
	TlPrint "Change modbus address to broadcast (0xF8)"
	set DevAdr($ActDev,MOD) 0xF8                                ;#will be restored in below
	TlWrite FRY $SetMask
	if {[doReadObject OBP] != 0} {
		checkObjectMask FRY $SetMask 0x809B
	} else {
		checkObjectMask FRY $SetMask 0x009B
	}
	TlPrint "Reset factory settings with FRY mask: 0x%04X" $SetMask
	TlWrite CGTY .CUS            ;# customer factory setting -> delete System:/Conf/OEM
	doWaitForEEPROMFinished 20
	checkModObject CGTY .CUS
	TlWrite CMI 1
	doWaitForEEPROMStarted  1
	doWaitForEEPROMFinished 10 0  ;# no mintime!
	doWaitForObject HMIS .RDY 5
	WriteAdr $ActAdr MOD
	doStoreEEPROM
	doWaitForObject HMIS .RDY 5
	if { $RP } {
		DeviceOff $ActDev 1
		set DevAdr($ActDev,MOD) $ActAdr
		DeviceOn $ActDev 0 "2"
	} else {
		set DevAdr($ActDev,MOD) $ActAdr
	}
}

proc read_ble_file { filename } {
	global globAbbruchFlag
	TlPrint ""
	set NameF [glob $filename]
	TlPrint "BLE File laden: $NameF"
	set file [open $NameF]
	while { ! [eof $file] } {
		set line [gets $file]
		# Ignore comment lines
		if [regexp "^write" $line] {
			set line [RemoveSpaceFromList $line]
			set wordList [split $line]
			set value1 [lindex $wordList 1]
			if [regexp {^[0-9]} $value1] {
				# numerical operation of Index and Subindex, e.g. "11 9"
				set idx   [lindex $wordList 1]
				set six   [lindex $wordList 2]
				set obj   "$idx.$six"      ;# it is hence e.g. "11.9"
				set value [lindex $wordList 3]
			} else {
				# symbolic operation, e.g. "MAND.NAME1"
				set obj   [lindex $wordList 1]
				set value [lindex $wordList 2]
			}
			set actual_value [ModTlRead $obj]
			if { ($obj == 1.10) || ($obj == 1.11) || ($obj == 4.3) } { continue }
			set diff [expr $value - $actual_value]
			if { $diff == 0 } {
				TlPrint "$obj  soll: %10s  Ist: %10s  ok" $actual_value $value
			} else {
				TlPrint "$obj  soll: %10s  Ist: %10s  Diff %10s" $actual_value $value $diff
			}
		}
		if {([CheckBreak] == 1)} {
			break
		}
	}
	close $file
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : Detect error text of delivered error code
# TYPE        : Library
# AUTHOR      : Wurtr
# DESCRIPTION :
#END-------------------------------------------------------------------
proc GetErrorText { errCode } {
	global ErrorText
	set key [format "%04X" $errCode]
	if [info exists ErrorText($key)] {
		set errTxt $ErrorText($key)
	} else {
		if { $errCode } {
			set errTxt "unknown errortext"
		} else {
			set errTxt "No error code"
		}
	}
	return $errTxt
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# OBSOLETE: use instead "theLXMLimitCheckFile"!
#
# Detect the Limit-File from Program number and Version number
#
# Example:
# limits\lim080200_00404.txt
#           ----            Program number   MAND.PRGNR Highword
#               --          Program variant MAND.PRGNR Lowword
#                  --       Version number   MAND.VERSION Highword
#                    ---    Revision nr.     MAND.VERSION Lowword
# format "..\\limits\\lim%04d%02d_%02d%03d.txt"
#
#END----------------------------------------------------------------
proc GetFilename {} {
	global theLimitCheckPath
	#   set Prg_Rev_Nr [TlRead MAND.PRGNR]
	#   set Ver_Rev_Nr [TlRead MAND.VERSION]
	#   if { ($Prg_Rev_Nr == "") || ($Ver_Rev_Nr == "") } then {
	#     TlError "received unvalid RxFrame"
	#     return ""
	#   }
	#   set PrgNr [expr $Prg_Rev_Nr >> 1]
	#   set PrgVarNr [expr $Prg_Rev_Nr & 0x0000000f]
	#   set VerNr [expr $Ver_Rev_Nr >> 16]
	#   set VerRevNr [expr $Ver_Rev_Nr & 0x0000ffff]
	#   toDo
	#   set result [format $theLimitCheckPath/lim%04d%02d_%02d%03d.txt $PrgNr $PrgVarNr $VerNr
	# $VerRevNr]
	set result [format $theLimitCheckPath/lim_00001.txt]
	#   set result [format $theLimitCheckPath/lim084000_test.txt]
	return $result
} ;#GetFilename

#-----------------------------------------------------------------------
proc doRefREF {{Status ""}} {
	if {$Status == "ENABLE" } {
		set WasEnabled 1
	} else {
		set WasEnabled 0
	}
	set STATUS [getBlState]
	if { !( $STATUS == 6) } {
		if { $STATUS > 6} {
			doFaultReset
			doEnableLim
			set WasEnabled 1
		} else {
			doEnableLim
			doFaultReset
		}
	} else {
		set WasEnabled 1
	}
	TlPrint "Reference run on LIMN to establish a defined starting position."
	TlWrite HOME.START 17                        ;# Reference run on LIMN
	doWaitForAckEnd 60                           ;# because of linear motor, need from start to end about 50 sec.
	doPrintObject MONC.PREF
	doPrintObject MONC.PACT
	doPrintObject MONC.PREFUSR
	doPrintObject MONC.PACTUSR
	TlPrint "Reference run on REF to establish a defined starting position."
	TlWrite HOME.START 23                        ;# Reference run on REF
	doWaitForAckEnd 60
	doPrintObject MONC.PREF
	doPrintObject MONC.PACT
	doPrintObject MONC.PREFUSR
	doPrintObject MONC.PACTUSR
	if { !$WasEnabled } {
		doDisable
	}
}

#-----------------------------------------------------------------------
proc doRefLIMN {{Status ""}} {
	if {$Status == "ENABLE" } {
		set WasEnabled 1
	} else {
		set WasEnabled 0
	}
	set STATUS [getBlState]
	if { !( $STATUS == 6) } {
		if { $STATUS > 6} {
			doFaultReset
			doEnableLim
			set WasEnabled 1
		} else {
			doEnableLim
		}
	} else {
		set WasEnabled 1
	}
	TlPrint "Reference run on LIMN to establish a defined starting position."
	TlWrite HOME.START 17              ;# Reference run on LIMN
	doWaitForAckEnd 20
	if { !$WasEnabled } {
		doDisable
	}
}

#-----------------------------------------------------------------------
proc doRefLIMP {{Status ""}} {
	if {$Status == "ENABLE" } {
		set WasEnabled 1
	} else {
		set WasEnabled 0
	}
	set STATUS [getBlState]
	if { !( $STATUS == 6) } {
		if { $STATUS > 6} {
			doFaultReset
			doEnableLim
			set WasEnabled 1
		} else {
			doEnableLim
		}
	} else {
		set WasEnabled 1
	}
	TlPrint "Reference run on LIMN to establish a defined starting position."
	TlWrite HOME.START 18               ;# Reference run on LIMP
	doWaitForAckEnd 20
	if { !$WasEnabled } {
		doDisable
	}
}

# stores configuration to EEPROM and waits for store end
# see also comments in doFactorySetting
proc doStoreEEPROM { } {
	global globAbbruchFlag
	if {[GetDevFeat "MVK"]& [GetSysFeat "MVKTower2"]} {
		doWaitMs 5000
	}
	TlPrint "--------------------------------------------------------"
	TlPrint "doStoreEEPROM {} - Save configuration data to EEPROM"
	#do not interrupt saving!!
	set globAbbruchFlag_save $globAbbruchFlag
	set globAbbruchFlag 0
	doWaitForEEPROMFinished 20 0  ;# mintime 1 sec still valid for CMI=2, even in CS05
	ModTlWrite CMI 2           ;# Bit1 = 1 : Memorize current configuration in EEPROM
	doWaitForEEPROMStarted  1
	doWaitForEEPROMFinished 50 1  ;# mintime 1 sec still valid for CMI=2, even in CS05
	set globAbbruchFlag $globAbbruchFlag_save
	TlPrint "-end----------------------------------------------------"
	if {[GetDevFeat "MVK"]& [GetSysFeat "MVKTower2"]} {
		doWaitMs 5000
	}
}

#-------------------------------------------------------------------------------------------------
# waitfor EEPS!=0 within timeout (in sec)
# see comment in WaitForEEPROMFinished
#
# History:
# 140414 ockeg created
# 080415 weiss include object ETI
proc doWaitForEEPROMStarted { timeout {NoErrPrint 0} } {
	global Debug_NERA_Storing
	TlPrint "--------------------------------------------------------"
	TlPrint "doWaitForEEPROMStarted {}"
	set eeps_ok   0
	set eti_ok    0
	set tryNumber 0
	set starttime [clock clicks -milliseconds]
	set timeout   [expr $timeout * 1000]
	while {1} {
		set waittime [expr [clock clicks -milliseconds] - $starttime]
		if { [CheckBreak] } { return 0 }
		set eeps [doReadModObject EEPS]
		set eti  [doReadModObject ETI]
		if { ($eeps == "")} then {
			TlError "illegal RxFrame received"
			return 0
		}
		incr tryNumber
		if { ([expr $eeps & 0x0003] > 0) || ([expr $eti & 0x0001] > 0) } {     ;# MotorControl or Application
			if { $Debug_NERA_Storing && !$eeps_ok } {
				NeraDebugStoring EEPS 3 $eeps $waittime $tryNumber
			}
			TlPrint "EEPROM access startet after %d ms (%d cycles)" $waittime $tryNumber
			return 1
		}
		if { $waittime > $timeout } {
			if { $Debug_NERA_Storing } {
				NeraDebugStoring NOSTART 0 0 $waittime $tryNumber
			}
			if { $NoErrPrint == 0 } {
				TlPrint "EEPROM storing procedure not started after $timeout ms (eeps=%04X)" $eeps
			}
			return 0
		}
		doWaitMsSilent 600
	}
	TlPrint "-end----------------------------------------------------"
}

#--------------------------------------------------------------------
# waitfor CMI=0, ETI=2, EEPS=0
# within mintime and timeout (timeout and mintime in sec)
#
# CMI (Internal command register)
#   Bit0 = 1 : Factory setting asked
#     (Return to 0 after traitment. Active only if drive is stopped : ETI.4 = ETI.5 = 0)
#   Bit1 = 1 : Memorize current configuration in EEPROM
#     (Return to 0 after traitment.
#     During memorization (ETI.0 = 1) it's not authorized to write parameters)
#   Bit2 = 1 : Read current configuration in EEPROM
#     (Active on transition 0-1 (don't return to 0 after traitment),
#     and active only if drive is stopped : ETI.4 = ETI.5 = 0)
#
# ETI (Internal status register)
#   Bit0 = 1 : EEPROM access running
#   Bit1 = 1 : Parameter consistency checked
#
# EEPS (EEPROM status)
#   Bit0 = 1 : MotorControl EEPROM access in progress
#   Bit1 = 1 : Application EEPROM access in progress
#   Bit2 = 1 : Default on MotorControl EEPROM
#   Bit3 = 1 : Default on Application EEPROM
#
# History:
# 140414 ockeg created
# 150414 ockeg mintime was in ms, but must be in sec
# 160414 ockeg mintime no more used in CS05, EEPROM access is sometimes quite fast
# 141014 serio extend mintime to ms, modify rc, add TTid param
# 080415 weiss status of objects EEPS, CMI and ETI cleared at each try
proc doWaitForEEPROMFinished { timeout {mintime 0} {TTId ""} } {
	global Debug_NERA_Storing
	TlPrint "--------------------------------------------------------"
	TlPrint "doWaitForEEPROMFinished {}"
	#eliminated 140414, must be done before with WaitForEEPROMStated
	#doWaitMs  100   ;# otherwise one could read the 0 state of the PRECEEDING storing sequence
	set tryNumber 0
	set rc 0
	set starttime [clock clicks -milliseconds]
	set timeout   [expr $timeout * 1000]
	set mintime   [expr int ($mintime * 1000)]
	#set mintime   0  ;# mintime should be tested, even in CS05, at least for StoreEEPROM
	while {1} {
		set waittime [expr [clock clicks -milliseconds] - $starttime]
		if { [CheckBreak] } { return 0 }
		set eeps_ok 0
		set cmi_ok  0
		set eti_ok  0
		set eeps    [doReadModObject EEPS]
		set cmi     [doReadModObject CMI]
		set eti     [doReadModObject ETI]
		if { ($eeps == "") || ($cmi == "") || ($eti == "") } then {
			TlError "illegal RxFrame received"
			return 0
		}
		incr tryNumber
		if { [expr $eeps & 0x0002] == 0 } {
			if { $Debug_NERA_Storing && !$eeps_ok } {
				NeraDebugStoring EEPS 0 $eeps $waittime $tryNumber
			}
			set eeps_ok 1
		}
		if { [expr $cmi & 0x0003] == 0 } {
			if { $Debug_NERA_Storing && !$cmi_ok } {
				NeraDebugStoring CMI 0 $cmi $waittime $tryNumber
			}
			set cmi_ok 1
		}
		if { [expr $eti & 0x0003] == 2 } {
			if { $Debug_NERA_Storing && !$eti_ok } {
				NeraDebugStoring ETI 2 $eti $waittime $tryNumber
			}
			set eti_ok 1
		}

		if { $eeps_ok && $cmi_ok && $eti_ok } {
			if { ($mintime > 0) && ($waittime < $mintime) } {
				if { $Debug_NERA_Storing } {
					NeraDebugStoring TOOSHORT 0 0 $waittime $tryNumber
				}
				if {$TTId == ""} {
					# TlError "*GEDEC00179058* EEPROM storing procedure was too short (%dms) (%d cycles)" $waittime $tryNumber
					doWaitMs 10000  ;# Yes is necessary, the "innocent write" below is not 100% sure
				} else {
					#		  TlError "*$TTId* EEPROM storing procedure was too short (%dms) (%d cycles)" $waittime $tryNumber
				}
				set rc 2
				break
			} else {
				if { $Debug_NERA_Storing } {
					NeraDebugStoring OK 0 0 $waittime $tryNumber
				}
				TlPrint "EEPROM access finished after %d ms (%d cycles)" $waittime $tryNumber
				set rc 0
				break
			}
		}
		if { $waittime > $timeout } {
			if { $Debug_NERA_Storing } {
				NeraDebugStoring TIMEOUT 0 0 $waittime $tryNumber
			}
			if {$TTId == ""} {
				#	       TlError "*GEDEC00183972* EEPROM storing procedure not finished after $timeout ms (eeps=%04X) (cmi=%04X) (eti=%04X)" $eeps $cmi $eti
			} else {
				#	       TlError "*$TTId* EEPROM storing procedure not finished after $timeout ms (eeps=%04X) (cmi=%04X) (eti=%04X)" $eeps $cmi $eti
			}
			set rc 1
			break
		}

		if {  [GetSysFeat "PACY_COM_PROFINET"]} {
			doWaitMsSilent 1000
		} else {
			doWaitMsSilent 600
		}
	} ;# while 1

	#TlPrint "when EEPROM access finished, an innocent write request must be possible:"
	#otherwise wait some additional sec, maybe the eeprom access is still not finished
	#set acc [ModTlRead ACC]
	#set write_result [ModTlWrite ACC $acc 1 "GEDEC00177854"]
	#if { [string first "9004" $write_result] >= 0 } { doWaitMs 10000 } ;#abortcode 4 = Server device
	# failure
	TlPrint "-end----------------------------------------------------"
	return $rc
} ;# doWaitForEEPROMFinished

#-----------------------------------------------------------------
proc CheckAndRestoreIPConfig {ActAdr} {
	TlPrint "--------------------------------------------------------"
	TlPrint "CheckAndRestoreIPConfig {} - ActAdr = $ActAdr"
	set adr     [GetDevAdrFB]
	set ttid    "GEDEC00164808"
	set timeout 5
	set mask    0xFFFF
	for {set i 0} {$i < 5} {incr i} {
		set resultok 1
		#check also the Modbus address
		if {![checkObject ADD $ActAdr]} {
			set resultok 0
		}
		# doWaitForObject is not suitable here because in case of a timoeout it returens "0"
		if {       [doWaitForObjectNoError IPM .MANU $timeout $mask $ttid] != [Enum_Value IPM MANU] } {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPC1 192  $timeout $mask $ttid] != 192} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPC2 168  $timeout $mask $ttid] != 168} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPC3 100  $timeout $mask $ttid] != 100} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPC4 $adr $timeout $mask $ttid] != $adr} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPM1 255  $timeout $mask $ttid] != 255} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPM2 255  $timeout $mask $ttid] != 255} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPM3 255  $timeout $mask $ttid] != 255} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPM4 0    $timeout $mask $ttid] != 0} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPG1 0    $timeout $mask $ttid] != 0} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPG2 0    $timeout $mask $ttid] != 0} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPG3 0    $timeout $mask $ttid] != 0} {
			set resultok 0
		} elseif { [doWaitForObjectNoError IPG4 0    $timeout $mask $ttid] != 0} {
			set resultok 0
		}
		if { $resultok == 1 } {
			return 1
		} else {
			WriteAdr $ActAdr MOD
			doStoreEEPROM
		}
	}
	TlPrint "-end----------------------------------------------------"
	return 0
}

#-----------------------------------------------------------------------
# Read an object with Error Check and display the value as needed,
# when an empty string of TlRead occurs, a default value can be returned.
# The global error handling is also considered.
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 161121 MPS	Solved communication issue with NERA drive
#-----------------------------------------------------------------------
proc doReadObject { Object {default 0} {print 0} {noErrPrint 0} {TTId ""}} {
	global ActDev DevAdr
	global ActInterface
	set actual [TlRead $Object 1 $TTId]
	#MP/AS : add while loop to avoid empty string issue when RX buffer is blocked, 20 try are done with error inhibition and if the frame is still empty after an error occur
	set emptyframeCounter 0
	while {$actual == ""} {
		set actual [TlRead $Object 1 $TTId]
		incr emptyframeCounter
		if {$emptyframeCounter > 20} {
			break
		}
	}
	switch $ActInterface {
		"SPB_STD" -
		"SPB_IO" {
			set Interface "SPB"
		}
		"PN_STD" -
		"PN_IO" {
			set Interface "PN"
		}
		"MODTCP_OptionBoard" {
			set Interface "OptBrdIP"
		}
		default {
			set Interface $ActInterface
		}
	}
	if { $actual == "" } {
		if {$noErrPrint == 0} {
			TlError "[subst $Interface]-Read(Adr(%s)) Object: $Object: empty string" $DevAdr($ActDev,$Interface)
		}
		return  $default
	} else {
		if {$print} {
			TlPrint "[subst $Interface]-Read(Adr(%s)) Object: %-22s actual=0x%08X, (%d)" $DevAdr($ActDev,$Interface) $Object $actual $actual
		}
		return  $actual
	}
}

#-----------------------------------------------------------------------
# Read an object with Error Check over Modbus and
# displays the value as needed,
# when an empty string of TlRead occurs, a default value can be returned.
# The global error handling is also considered.~
# 2021/11/22 Modification in order to handle the slow response from NERA and avoid the "Empty String" error
#-----------------------------------------------------------------------
proc doReadModObject { Object {default 0} {print 0} {noErrPrint 0} {TTId ""}} {
	global ActDev DevAdr
	global ActInterface
	set actual [ModTlRead $Object 1]
	#MP/AS : add while loop to avoid empty string issue when RX buffer is blocked, 20 try are done with error inhibition and if the frame is still empty after an error occur
	set emptyframeCounter 0
	while {$actual == ""} {
		set actual [ModTlRead $Object 1]
		incr emptyframeCounter
		if {$emptyframeCounter > 20} {
			break
		}
	}
	if { $actual == "" } {
		TlError "Mod-Read(Adr(%s)) Object: $Object empty string" $DevAdr($ActDev,MOD)
		return  $default
	} else {
		if {$print} {
			TlPrint "Mod-Read(Adr(%s)) Object: %-22s actual=0x%08X, (%d)" $DevAdr($ActDev,MOD) $Object $actual $actual
		}
		return  $actual
	}
}

#-----------------------------------------------------------------------
# Read an object with Error Check over Modbus and displays the value
#-----------------------------------------------------------------------
proc doPrintObject { Object } {
	global ActDev DevAdr
	global ActInterface
	if {[string first "O_SFTY" $Object] != -1} {
		# read safety module object
		set  actual [ModTlReadSafety $Object ]   ;# via modbus
	} else {
		set actual [TlRead $Object]
	}
	switch $ActInterface {
		"SPB_STD" -
		"SPB_IO" {
			set Interface "SPB"
		}
		"PN_STD" -
		"PN_IO" {
			set Interface "PN"
		}
		"MODTCP_OptionBoard" -
		"MODTCP_OptionBoard_UID251" {
			if { [GetSysFeat "ATLAS"] } {
				set Interface $ActInterface
			} else {
				set Interface "OptBrdIP"
			}
		}
		default {
			set Interface $ActInterface
		}
	}
	if { $actual == "" } {
		TlError "[subst $Interface]-Read(Adr(%s)) Object: $Object actual= $actual" $DevAdr($ActDev,$Interface)
		return  0
	} else {
		TlPrint "[subst $Interface]-Read(Adr(%s)) Object: %-5s actual=0x%08X (%d) (%s)" \
			$DevAdr($ActDev,$Interface) $Object $actual $actual [Enum_Name $Object $actual]
		return  $actual
	}
}

#-----------------------------------------------------------------------
# Read an object with Error Check over Modbus and displays the value
#-----------------------------------------------------------------------
proc doPrintModObject { Object } {
	global ActDev DevAdr
	set actual [ModTlRead $Object]
	if { $actual == "" } {
		TlError "Mod-Read(Adr(%s)) Object: $Object actual= $actual" $DevAdr($ActDev,MOD)
		return  0
	} else {
		TlPrint "Mod-Read(Adr(%s)) Object: %-5s actual=0x%08X (%d) (%s)" \
			$DevAdr($ActDev,MOD) $Object $actual $actual [Enum_Name $Object $actual]
		return  $actual
	}
}

#DESCRIPTION
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 050304 pfeig proc created
#
#END----------------------------------------------------------------
proc doAddr { Addr } {
	TlPrint "Addressing device with address: $Addr "
	set answer [TlSend "#0$Addr"]
	if {$answer != "#0$Addr"} {
		TlError "Addressing failed, answer: $answer"
	}
}

#-----------------------------------------------------------------
# switch drive to the demanded state:
#  state 2 or sod  = switch on disabled
#  state 3 or rtso = ready to switch on
#  state 4 or so   = switched on
#  state 5 or oe   = operation enabled
#  state 6 or qs   = quick stop active
#  state 7 or fra  = fault reaction active (temporary for about 5 sec)
#  state 8 or f    = fault
#
#  state 5 is reached without movement (LFR=0)
#  state 6 is reached by a quick stop (bit2=0 in CMD)
#  state 7 is reached by a external fault via LI4
#           while moving generate a External fault from LI4, external fault reaction EPL = ramp
#           during the (slow) deceleration state 7 must be active for about 5 sec
#           IMPORTANT: state 7 is only a temporary state and not reported in ETA
#  state 8 is reached by a external fault via LI4
#           while moving generate a External fault from LI4, external fault reaction EPL = fast stop
#           wait until state 8 (FAULT) is active
#
# History:
#  031213 ockeg   adapted for NERA.
#                 Up to now only for cmdchannel (CD1) = MDB or CAN/NET; IO not yet imlemented
#  070314 ockeg   use ModTlRead in cmdchannel "MDB"
#  210314 ockeg   LRSx Status are now integrated in Alarm Status ALRx.
#                 That means that Alarm bit ETA.7 comes very often.
#                 So check ETA with Mask FF is no more useful.
#                 Can now be defined via global CHECK_ETA_WITH_ALARMBIT
#
#-----------------------------------------------------------------
proc doChangeState { state {cmdchannel "MDB"} } {
	global CHECK_ETA_WITH_ALARMBIT
	set eta_mask 0x007F
	if { [info exists CHECK_ETA_WITH_ALARMBIT] } {
		if { $CHECK_ETA_WITH_ALARMBIT } {
			set eta_mask 0x00FF
		}
	}
	if { ![string is integer $state] } {
		set state [string tolower $state]
		switch -regexp $state {
			"sod"  { set state 2 }
			"rtso" { set state 3 }
			"so"   { set state 4 }
			"oe"   { set state 5 }
			"qs"   { set state 6 }
			"fra"  { set state 7 }
			"f"    { set state 8 }
			default {
				TlError "invalid state $state"
				return
			}
		}
	}
	set mode [doPrintModObject CHCF]
	set mode [Enum_Name CHCF $mode]
	if { $mode == "IO" } {
		TlError "CHCF=IO, this mode is not yet implemented"
		return
	}
	TlPrint "switch to state %s" [getStateName $state]
	#-------------------------------------------------------
	if {$cmdchannel == "MDB"} {
		#first do a fault reset and go to state ready to switch on
		ModTlWrite           CMD   0x0000                  ;# to generate a rising edge
		doWaitMs             100
		ModTlWrite           CMD   0x0080                  ;# fault reset
		doWaitMs             100
		doWaitForModObject   ETA   0x0050 1 $eta_mask      ;# wait for switch on disabled
		ModTlWrite           CMD   0x0006                  ;# ready to switch on
		doWaitForModObject   ETA   0x0031 1 $eta_mask      ;# wait for ready to switch on
		# now the demanded state
		switch $state {
			2 { ;# sod = Switch on disabled
				ModTlWrite           CMD   0x0000
				doWaitForModObject   ETA   0x0050 1 $eta_mask
			}
			3 { ;# rtso = Ready to switch on
				ModTlWrite           CMD   0x0006
				doWaitForModObject   ETA   0x0031 1 $eta_mask
			}
			4 { ;# so = Switched on
				ModTlWrite           CMD   0x0007
				doWaitForModObject   ETA   0x0033 1 $eta_mask
			}
			5 { ;# oe = Operation enabled
				ModTlWrite           LFR   0                 ;# set Speed reference to 0 Hz
				ModTlWrite           CMD   0x000F
				doWaitForModObject   ETA   0x0037 1 $eta_mask
			}
			6 { ;# qs = Quick stop active
				# reset bit 2 in CMD
				ModTlWrite           LFR   0                 ;# set Speed reference to 0 Hz
				ModTlWrite           CMD   0x000F            ;# switch to RUN
				doWaitMs             500
				ModTlWrite           CMD   0x000B            ;# Bit 2=0: Quick Stop
				doWaitForModObject   ETA   0x0017 1 $eta_mask
			}
			7 { ;# fra = Fault reaction active
				# while moving generate a External fault from LI4, external fault reaction EPL = ramp
				# during the (slow) deceleration state 7 (fra) must be active for about 5 sec
				ModTlWrite           ACC   10                ;# 1 sec acceleration to 50 Hz
				ModTlWrite           DEC   100               ;# 10 sec deceleration from 50 Hz
				ModTlWrite           ETF   .LI4              ;# external fault from LI4
				ModTlWrite           EPL   .RMP              ;# fault reaction: ramp
				ModTlWrite           LFR   250               ;# speed reference is 25 Hz
				doWaitForState       .RDY  1                 ;# wait for macro config to be finished
				ModTlWrite           CMD   0x000F            ;# operation enable
				doWaitForModObject   ETA   0x0037 1 $eta_mask   ;# wait for operation enabled
				doWaitForModObject   HMIS  .RUN  3           ;# wait for constant speed
				setDI                4 "H"                   ;# activate external fault
				doWaitForModObject   HMIS  .DEC  1           ;# now deceleration is in process
				setDI                4 "L"                   ;# deactivate external fault
				doWaitForModObject   ETA   0x0037 1 $eta_mask   ;# state 7 is not reported in ETA
				#ModTlWrite          ETF   .NO               ;# not possible while moving! later!
			}
			8 { ;# f = Fault
				# while moving generate a External fault from LI4, external fault reaction EPL = fast
				# stop
				# wait until state 8 (f) is active
				ModTlWrite           ACC   10                ;# 1 sec acceleration
				ModTlWrite           DEC   10                ;# 1 sec deceleration
				ModTlWrite           ETF   .LI4              ;# external fault from LI4
				ModTlWrite           EPL   .FST              ;# fault reaction: Fast stop
				ModTlWrite           LFR   100               ;# speed reference is 10Hz
				doWaitForState       .RDY  1
				ModTlWrite           CMD   0x000F            ;# operation enable
				doWaitForModObject   HMIS  .RUN  3           ;# wait for constant speed
				setDI                4 "H"                   ;# set external fault active
				doWaitForModObject   ETA   0x0008 1 0x0008   ;# fault
				setDI                4 "L"                   ;# activate external fault
				ModTlWrite           ETF   .NO               ;# clear external fault reaction
			}
			default {
				TlError "invalid state $state"
				return
			}
		}
		#-------------------------------------------------------
	} elseif { ($cmdchannel == "CAN") || ($cmdchannel == "NET") } {
		#first do a fault reset and go to state ready to switch on
		DriveCom_Profile_SendFrame       0x0000            ;# to generate a rising edge
		doWaitMs  100
		DriveCom_Profile_SendFrame       0x0080            ;# fault reset
		doWaitMs  100
		DriveCom_Profile_doWaitForStatus 0x0050 $eta_mask     ;# wait for switch on disabled
		DriveCom_Profile_SendFrame       0x0006            ;# ready to switch on
		DriveCom_Profile_doWaitForStatus 0x0031 $eta_mask     ;# wait for ready to switch on
		# now the demanded state
		switch $state {
			2 { ;# sod = Switch on disabled
				DriveCom_Profile_SendFrame       0x0000
				DriveCom_Profile_doWaitForStatus 0x0050 $eta_mask
			}
			3 { ;# rtso = Ready to switch on
				DriveCom_Profile_SendFrame       0x0006
				DriveCom_Profile_doWaitForStatus 0x0031 $eta_mask
			}
			4 { ;# so = Switched on
				DriveCom_Profile_SendFrame       0x0007
				DriveCom_Profile_doWaitForStatus 0x0033 $eta_mask
			}
			5 { ;# oe = Operation enabled
				DriveCom_Profile_SendFrame       0x000F 0    ;# set Speed reference to 0 Hz
				DriveCom_Profile_doWaitForStatus 0x0037 $eta_mask
			}
			6 { ;# qs = Quick stop active
				# reset bit 2 in CMD
				DriveCom_Profile_SendFrame       0x000F 0    ;# Operation enable and Speed reference to 0 Hz
				doWaitMs  500
				DriveCom_Profile_SendFrame       0x000B 0    ;# Bit 2=0: Quick Stop
				DriveCom_Profile_doWaitForStatus 0x0017 $eta_mask
			}
			7 { ;# fra = Fault reaction active
				# while moving generate a External fault from LI4, external fault reaction EPL = ramp
				# during the (slow) deceleration state 7 (fra) must be active for about 5 sec
				TlWrite           ACC   10                      ;# 1 sec acceleration to 50 Hz
				TlWrite           DEC   100                     ;# 10 sec deceleration from 50 Hz
				TlWrite           ETF   .LI4                    ;# external fault from LI4
				TlWrite           EPL   .RMP                    ;# fault reaction: ramp
				DriveCom_Profile_SendFrame       0x000F 1500    ;# operation enable and speed reference to 1500 rpm (25 Hz)
				DriveCom_Profile_doWaitForStatus 0x0037 $eta_mask  ;# operation enabled
				doWaitForObject   HMIS  .RUN  3                 ;# wait for constant speed
				setDI             4 "H"                         ;# activate external fault
				doWaitForObject   HMIS  .DEC  1                 ;# now deceleration is in process
				setDI             4 "L"                         ;# deactivate external fault
				DriveCom_Profile_doWaitForStatus 0x0037 $eta_mask  ;# operation enabled
				#TlWrite          ETF   .NO                     ;# not possible while moving! later!
			}
			8 { ;# f = Fault
				# while moving generate a External fault from LI4, external fault reaction EPL = fast
				# stop
				# wait until state 8 (f) is active
				TlWrite           ACC   10                      ;# 1 sec acceleration
				TlWrite           DEC   10                      ;# 1 sec deceleration
				TlWrite           ETF   .LI4                    ;# external fault from LI4
				TlWrite           EPL   .FST                    ;# fault reaction: Fast stop
				DriveCom_Profile_SendFrame 0x000F 100           ;# operation enable and speed reference to 10 Hz
				doWaitForObject   HMIS  .RUN  3                 ;# wait for constant speed
				setDI             4 "H"                         ;# set external fault active
				DriveCom_Profile_doWaitForStatus 0x0008 0x0008  ;# fault
				setDI             4 "L"                         ;# activate external fault
				TlWrite           ETF   .NO                     ;# clear external fault reaction
			}
			default {
				TlError "invalid state $state"
				return
			}
		}
		#-------------------------------------------------------
	} else {
		TlError "invalid cmdchannel $cmdchannel (allowed: MDB or CAN or NET)"
		return
	}
}

#-----------------------------------------------------------------
#  do a fault reset and switch to demanded state:
#    state 2 or sod  : Switch on disabled
#    state 3 or rtso : Ready to switch on
#
#  041213 ockeg adapted for NERA. Up to now only for mode = MOD and NET; IO not yet imlemented
#  210314 ockeg   LRSx Status are now integrated in Alarm Status ALRx.
#                 That means that Alarm bit ETA.7 comes very often.
#                 So check ETA with Mask FF is no more useful.
#                 Can now be defined via global CHECK_ETA_WITH_ALARMBIT
#
proc doFaultReset { state {mode "MOD"} } {
	global CHECK_ETA_WITH_ALARMBIT
	set eta_mask 0x007F
	if { [info exists CHECK_ETA_WITH_ALARMBIT] } {
		if { $CHECK_ETA_WITH_ALARMBIT } {
			set eta_mask 0x00FF
		}
	}
	TlPrint "Fault reset via $mode and final state $state ------------------"
	if { ![string is integer $state] } {
		set state [string tolower $state]
		switch -regexp $state {
			"sod"  { set state 2 }
			"rtso" { set state 3 }
			default {
				TlError "invalid state $state only sod and rtso possible"
				return
			}
		}
	}
	switch $state {
		2 { ;# sod = Switch on disabled
			set cmd 0x0000
			set eta 0x0050
		}
		3 { ;# rtso = Ready to switch on
			set cmd 0x0006
			set eta 0x0031
		}
		default {
			TlError "invalid state $state only sod and rtso possible"
			return
		}
	}
	# do the fault reset
	if {($mode == "MOD") || ($mode == "MODTCP")} {
		TlWrite           CMD   $cmd
		doWaitMs          100
		TlWrite           CMD   [expr $cmd | 0x0080]       ;# fault reset
		doWaitMs          100
		TlWrite           CMD   $cmd                       ;# switch to demanded state
		#doWaitForObject   ETA   $eta 2 $eta_mask             ;# do not wait, depends on active channel
		#---------------------------------------------
	} elseif {($mode == "NET") || ($mode == "CAN")} {
		DriveCom_Profile_SendFrame $cmd
		doWaitMs 100
		DriveCom_Profile_SendFrame [expr $cmd | 0x0080]       ;# fault reset
		doWaitMs 100
		DriveCom_Profile_SendFrame $cmd                       ;# switch to demanded state
		#DriveCom_Profile_doWaitForStatus $eta $eta_mask 2       ;# do not wait, depends on active
		# channel
		#---------------------------------------------
	} elseif {$mode == "IO"} {
		TlError "mode IO not yet implemented"
		return
	} elseif {$mode == "TER"} {
		#Reset fault via RSF function (assigned to LI4 as default setting)
		setDI 4 "L"
		setDI 4 "H"                                           ;#fault reset
		doWaitMs 100
		setDI 4 "L"                                           ;#Switch off input
	} else {
		TlError "invalid mode $mode (allowed: MOD NET CAN or IO)"
		return
	}
}

#-----------------------------------------------------------------
#  state 1 or nrtso = not ready to switch on
#  state 2 or sod   = switch on disabled
#  state 3 or rtso  = ready to switch on
#  state 4 or so    = switched on
#  state 5 or oe    = operation enabled
#  state 6 or qs    = quick stop active
#  state 7 or fra   = fault reaction active (is only a temporary state)
#  state 8 or f     = fault
#
#  031213 ockeg   created for NERA
#  210314 ockeg   LRSx Status are now integrated in Alarm Status ALRx.
#                 That means that Alarm bit ETA.7 comes very often.
#                 So check ETA with Mask FF is no more useful.
#                 Can now be defined via global CHECK_ETA_WITH_ALARMBIT
#  030414 ockeg   nrtso and fra detected
#
#-----------------------------------------------------------------
proc checkState { state {waittime 1} } {
	global CHECK_ETA_WITH_ALARMBIT
	set eta_mask1 0x004F    ;# power stage disabled
	set eta_mask2 0x006F    ;# power stage enabled
	if { [info exists CHECK_ETA_WITH_ALARMBIT] } {
		if { $CHECK_ETA_WITH_ALARMBIT } {
			set eta_mask1 [expr $eta_mask1 | 0x0080]
			set eta_mask2 [expr $eta_mask2 | 0x0080]
		}
	}
	if { ![string is integer $state] } {
		set state [string tolower $state]
		switch -regexp $state {
			"nrtso" { set state 1 }
			"sod"   { set state 2 }
			"rtso"  { set state 3 }
			"so"    { set state 4 }
			"oe"    { set state 5 }
			"qs"    { set state 6 }
			"fra"   { set state 7 }
			"f"     { set state 8 }
			default {
				TlError "invalid state $state"
				return
			}
		}
	}
	switch $state {
		1 { doWaitForObject ETA 0x0000 $waittime $eta_mask1 } ;# "1 not ready to switch on"
		2 { doWaitForObject ETA 0x0040 $waittime $eta_mask1 } ;# "2 switch on disabled"
		3 { doWaitForObject ETA 0x0021 $waittime $eta_mask2 } ;# "3 ready to switch on"
		4 { doWaitForObject ETA 0x0023 $waittime $eta_mask2 } ;# "4 switched on"
		5 { doWaitForObject ETA 0x0027 $waittime $eta_mask2 } ;# "5 operation enabled"
		6 { doWaitForObject ETA 0x0007 $waittime $eta_mask2 } ;# "6 quick stop active"
		7 { doWaitForObject ETA 0x000F $waittime $eta_mask1 } ;# "7 fault reaction active"
		8 { doWaitForObject ETA 0x0008 $waittime $eta_mask1 } ;# "8 fault"
		default { TlError "invalid state $state" }
	}
}

#-----------------------------------------------------------------
# return full name of CIA402 states:
#   "state 1: nrtso = not ready to switch on"
#   "state 2: sod = switch on disabled"
#   "state 3: rtso = ready to switch on"
#   "state 4: so = switched on"
#   "state 5: oe = operation enabled"
#   "state 6: qs = quick stop active"
#   "state 7: fra = fault reaction active"
#   "state 8: f = fault"
#
# accepted input parameter state: "1" .. "8" or "nrtso" .. "f"
#
#  031213 ockeg   created for NERA
#  030414 ockeg   nrtso and fra detected
#
#-----------------------------------------------------------------
proc getStateName { state } {
	if { ![string is integer $state] } {
		set state [string tolower $state]
		switch -regexp $state {
			"nrtso" { set state 1 }
			"sod"   { set state 2 }
			"rtso"  { set state 3 }
			"so"    { set state 4 }
			"oe"    { set state 5 }
			"qs"    { set state 6 }
			"fra"   { set state 7 }
			"f"     { set state 8 }
			default {
				TlError "invalid state $state"
				return
			}
		}
	}
	switch $state {
		1 { return "state 1: nrtso = not ready to switch on" }
		2 { return "state 2: sod = switch on disabled" }
		3 { return "state 3: rtso = ready to switch on" }
		4 { return "state 4: so = switched on" }
		5 { return "state 5: oe = operation enabled" }
		6 { return "state 6: qs = quick stop active" }
		7 { return "state 7: fra = fault reaction active" }
		8 { return "state 8: f = fault" }
		default { TlError "invalid state $state" }
	}
}

#----------------------------------------------------------------------------------------------------
#   Statusword             state
#   xxxx xxxx x0xx 0000b   Not ready to switch on
#   xxxx xxxx x1xx 0000b   Switch on disabled
#   xxxx xxxx x01x 0001b   Ready to switch on
#   xxxx xxxx x01x 0011b   Switched on
#   xxxx xxxx x01x 0111b   Operation enabled
#   xxxx xxxx x00x 0111b   Quick stop active
#   xxxx xxxx x0xx 1111b   Fault reaction active
#   xxxx xxxx x0xx 1000b   Fault
proc getETAStateName { ETAState } {
	if {       [expr $ETAState & 0x004F] == 0x0000 } {
		return [getStateName "nrtso"] ;# not ready to switch on
	} elseif { [expr $ETAState & 0x004F] == 0x0040 } {
		return [getStateName "sod"]   ;# switch on disabled"
	} elseif { [expr $ETAState & 0x006F] == 0x0021 } {
		return [getStateName "rtso"]  ;# ready to switch on"
	} elseif { [expr $ETAState & 0x006F] == 0x0023 } {
		return [getStateName "so"]    ;# switched on"
	} elseif { [expr $ETAState & 0x006F] == 0x0027 } {
		return [getStateName "oe"]    ;# operation enabled"
	} elseif { [expr $ETAState & 0x006F] == 0x0007 } {
		return [getStateName "qs"]    ;# quick stop active"
	} elseif { [expr $ETAState & 0x004F] == 0x000F } {
		return [getStateName "fra"]   ;# fault reaction active"
	} elseif { [expr $ETAState & 0x004F] == 0x0008 } {
		return [getStateName "f"]     ;# fault"
	} else {
		return "ambiguous State $ETAState"
	}
}

#-----------------------------------------------------------------------
# Measure time until read object receives a specific value
#-----------------------------------------------------------------------
# object:   symbolic Name, e.g. SYSTEM.DEFAULTEND
# sollwert: desired value which leads to end
# timeout:  in s
# return:   time in ms until object receives the desired value
#
proc doTimeForObject { objekt sollWert timeout {bitmaske 0xffffffff}} {
	set startZeit [clock clicks -milliseconds]
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set wartezeit [expr [clock clicks -milliseconds] - $startZeit ]
		set istWert [doReadObject $objekt]
		if [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] {
			TlPrint "Objekt $objekt ok: TargetValue=ActualValue=0x%08X , (%d) , wait time (%dms) " $sollWert $sollWert $wartezeit
			return $wartezeit
		}
		if {$wartezeit >= [expr $timeout * 1000] } {
			TlError "doTimeForObject $objekt: TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d)" $sollWert $sollWert $istWert  $istWert
			return $wartezeit
		}
	}
}

#-----------------------------------------------------------------------
# Measure time until not read object receives a specific value
#-----------------------------------------------------------------------
# object:   symbolic Name, e.g. SYSTEM.DEFAULTEND
# sollwert: desired value which leads to end
# timeout:  in s
# return:   time in ms until object receives the desired value
#
proc doTimeNotForObject { objekt sollWert timeout {bitmaske 0xffffffff}} {
	set startZeit [clock clicks -milliseconds]
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set wartezeit [expr [clock clicks -milliseconds] - $startZeit ]
		set istWert [doReadObject $objekt]
		if {$wartezeit >= [expr $timeout * 1000] } {
			TlPrint "doTimeForObject $objekt: TargetValue=0x%08X , (%d) ActualValue=0x%08X , (%d)" $sollWert $sollWert $istWert  $istWert
			return $wartezeit
		} else {
			if [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] {
				TlError "Objekt $objekt ok: TargetValue=ActualValue=0x%08X , (%d) , wait time (%dms) " $sollWert $sollWert $wartezeit
				return $wartezeit
			}
		}
	}
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {
	global Debug_NERA_Storing
	if { $keypadchannel == 1 && [TlRead CCC] ==4} {
		InitKeypad 0
	}
	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}
	set DebugTimeStart [clock clicks -milliseconds]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		if { $keypadchannel == 1 && [TlRead CCC] ==4} {
			InitKeypad 0
		}
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			#  TlPrint "doWaitForNotObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			#TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
			TlPrint " doWaitForNotObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			if {$noErrPrint} {
				TlPrint "$TTId doWaitForNotObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				if { $bitmaske  == 0xffffffff } {
					TlError "$TTId doWaitForNotObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				} else {
					TlError "$TTId doWaitForNotObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
				}
			}
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#It is forced to use Modbus RTU to read the parameter.
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 120122 Yahya    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotModObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {
	global Debug_NERA_Storing
	if { $keypadchannel == 1 && [TlRead CCC] ==4} {
		InitKeypad 0
	}
	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}
	set DebugTimeStart [clock clicks -milliseconds]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		if { $keypadchannel == 1 && [ModTlRead CCC] ==4} {
			InitKeypad 0
		}
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadModObject $objekt]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			#  TlPrint "doWaitForNotModObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			#TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
			TlPrint " doWaitForNotModObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [ModTlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			if {$noErrPrint} {
				TlPrint "$TTId doWaitForNotModObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				if { $bitmaske  == 0xffffffff } {
					TlError "$TTId doWaitForNotModObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				} else {
					TlError "$TTId doWaitForNotModObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
				}
			}
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value is not between  exp - tolerance   and exp + tolerance
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {
	set NameValue   ""
	set ListOfValue [split $sollWert {}]
	set timeout     [expr int ($timeout*1000)] ;#in ms
	set TTId [Format_TTId $TTId]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] { return }
	}
	set startZeit [clock clicks -milliseconds]
	set tryNumber 0
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set istWert [doReadObject $objekt]
		set  duration [expr [clock clicks -milliseconds] - $startZeit]
		incr tryNumber
		if { $istWert != "" } then {
			set diff [expr $istWert - $sollWert]
			if {[expr abs($diff)] > $tolerance} {
				TlPrint "doWaitForNotObjectTol %s exp is not =%d with tol=%d ,act=%d  diff=%d waittime=%d ms requests=%d" \
					$objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
				break
			}
		}
		if { $duration >= $timeout } {
			if { $istWert == "" } {
				TlError "$TTId doWaitForNotObjectTol $objekt: no response after waittime=%d ms" $duration
			} else {
				TlError "$TTId doWaitForNotObjectTol %s exp shall not be =%d with tol=%d, act=%d  diff=%d TO=$timeout ms WT=%d ms requests=%d" \
					$objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
				if { $show_status } { ShowStatus }
			}
			break
		}
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#

#END----------------------------------------------------------------
proc doWaitForNotObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {
	global Debug_NERA_Storing
	if { $keypadchannel == 1 && [TlRead CCC] ==4} {
		InitKeypad 0
	}
	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}
	set DebugTimeStart [clock clicks -milliseconds]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		if { $keypadchannel == 1 && [TlRead CCC] ==4} {
			InitKeypad 0
		}
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			#  TlPrint "doWaitForNotObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			#TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
			TlPrint " doWaitForNotObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			if {$noErrPrint} {
				TlPrint "$TTId doWaitForNotObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				if { $bitmaske  == 0xffffffff } {
					TlError "$TTId doWaitForNotObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				} else {
					TlError "$TTId doWaitForNotObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
				}
			}
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value  is different to exp value
#It is forced to use Modbus RTU to read the parameter.
#
# \param[in] objekt: parameter to read
# \param[in] sollWert: expected value
# \param[in] timeout: maximum wait time before tripping in error (seconds)
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 120122 Yahya    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotModObject { objekt sollWert  timeout  {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} {keypadchannel 0}  } {
	global Debug_NERA_Storing
	if { $keypadchannel == 1 && [TlRead CCC] ==4} {
		InitKeypad 0
	}
	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}
	set DebugTimeStart [clock clicks -milliseconds]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		if { $keypadchannel == 1 && [ModTlRead CCC] ==4} {
			InitKeypad 0
		}
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadModObject $objekt]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			#  TlPrint "doWaitForNotModObject $objekt exp!=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			#TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
			TlPrint " doWaitForNotModObject $objekt    act=0x%08X (%d$ResEnum) is different to  0x%08X (%d$ExpEnum) ,diff=0x%08X, waittime (%dms / %d requests)"  $istWert $istWert $sollWert $sollWert $diff $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [ModTlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			if {$noErrPrint} {
				TlPrint "$TTId doWaitForNotModObject $objekt exp shall be different to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				if { $bitmaske  == 0xffffffff } {
					TlError "$TTId doWaitForNotModObject $objekt exp  shall be diferent to 0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				} else {
					TlError "$TTId doWaitForNotModObject $objekt exp shall be diferent to 0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske shall be diffrent to  [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
				}
			}
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#check objet's value is not between  exp - tolerance   and exp + tolerance
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 041020 kaidi    proc created
#
#END----------------------------------------------------------------
proc doWaitForNotObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {
	set NameValue   ""
	set ListOfValue [split $sollWert {}]
	set timeout     [expr int ($timeout*1000)] ;#in ms
	set TTId [Format_TTId $TTId]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] { return }
	}
	set startZeit [clock clicks -milliseconds]
	set tryNumber 0
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set istWert [doReadObject $objekt]
		set  duration [expr [clock clicks -milliseconds] - $startZeit]
		incr tryNumber
		if { $istWert != "" } then {
			set diff [expr $istWert - $sollWert]
			if {[expr abs($diff)] > $tolerance} {
				TlPrint "doWaitForNotObjectTol %s exp is not =%d with tol=%d ,act=%d  diff=%d waittime=%d ms requests=%d" \
					$objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
				break
			}
		}
		if { $duration >= $timeout } {
			if { $istWert == "" } {
				TlError "$TTId doWaitForNotObjectTol $objekt: no response after waittime=%d ms" $duration
			} else {
				TlError "$TTId doWaitForNotObjectTol %s exp shall not be =%d with tol=%d, act=%d  diff=%d TO=$timeout ms WT=%d ms requests=%d" \
					$objekt $sollWert $tolerance $istWert  $diff $duration $tryNumber
				if { $show_status } { ShowStatus }
			}
			break
		}
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObject
# TYPE        : util
# AUTHOR      : pfeig
# DESCRIPTION : Wait until read object receives a specific value (via actual interface)
#  object:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  bitmask:  to check only specified bits
#
# 141113 ockeg Enum_Value added
# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
# 100614 serio modify output to show diff
# 100415 serio enhance timeout to ms precision
#
#END-------------------------------------------------------------------
proc doWaitForObject { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	global Debug_NERA_Storing
	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}
	set DebugTimeStart [clock clicks -milliseconds]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {
			TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			if {$noErrPrint} {
				TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			}
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectStable
# TYPE        : util
# AUTHOR      : serio
# DESCRIPTION : Wait until read object receives a specific value (via actual
#		interface). and stays at this value during some time to consider
#		the value as stable. The value must stable before timeout value
#		is reached.
#  objekt:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  stabletime : milliseconds
#  bitmaske:  to check only specified bits
#
# 260315 serio creation of proc
# 100415 serio enhance timeout to ms precision
# 020523 ASY   update so the timeout will always have the priority
# 090623 ASY   update so the timeout will never have the priority on the expected state
# 130723 EDM   update so the proc is now usable with 0s timeout
#
#END-------------------------------------------------------------------
proc doWaitForObjectStable { objekt sollWert timeout stabletime {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	set istWert ""
	set changeFlag 0
	while {1} {
		after 2   ;# wait 2 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $waittime > $timeout] && !$changeFlag} {
			if {$tryNumber!=1} {
				set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
				TlError "$TTId doWaitForObjectStable $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				if {$noErrPrint == 0} { ShowStatus }
				return 0
			}
		}
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {
			if { !$changeFlag } {
				set startZeit2 [clock clicks -milliseconds]
				set changeFlag 1
				TlPrint "target value reached after [expr $startZeit2 - $startZeit] ms"
			}
			set waittime2 [expr [clock clicks -milliseconds] - $startZeit2]
			if { [expr $waittime2 > $stabletime] } {
				TlPrint "doWaitForObjectStable $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert [expr $waittime ] $tryNumber
				return 1
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)]  & $changeFlag} {
			set changeFlag 0
			TlPrint "$objekt changed from $sollWert to $istWert at $waittime ms after $waittime2 ms of stability"
		}

		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectList
# TYPE        : util
# AUTHOR      : serio
# DESCRIPTION : Wait until read object receives a value (via actual interface)
#               included in the list of possible values
#  objekt:   symbolic name, e.g. ETA
#  darfWerts: list of possible values
#  timeout:  seconds
#  bitmaske:  to check only specified bits
#
# 080415 serio creation of proc
# 100415 serio enhance timeout to ms precision
#
#END-------------------------------------------------------------------
proc doWaitForObjectList { objekt darfWerts timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnumList ""
	set ResEnum ""
	set NameValue ""
	foreach sollWert $darfWerts {
		set ListOfValue [split $sollWert {}]
		if {[lindex $ListOfValue 0] == "."} {
			set NameValue [lrange $ListOfValue 1 end]
			set NameValue [join $NameValue ""]
			set sollWert  [Enum_Value $objekt $NameValue]
			if [regexp {[^0-9]} $sollWert] {
				TlError "Something wrong in list of expected values $darfWerts"
				return
			}
			lappend allowedValues [expr $sollWert & $bitmaske]
			lappend ExpEnumList   "$NameValue"
		}
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnumList != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		set searchindex [lsearch $allowedValues [expr ($istWert & $bitmaske)]]
		if { $searchindex != -1 } {
			set ExpEnum [lindex $ExpEnumList $searchindex]
			TlPrint "doWaitForObjectList $objekt act=0x%04X (%d$ResEnum) part of $darfWerts, waittime (%dms / %d requests)" $istWert $istWert $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			TlError "$TTId doWaitForObjectList $objekt act=0x%08X (%d$ResEnum) not part of $darfWerts, waittime (%dms)" $istWert $istWert $waittime
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForModObjectList
# TYPE        : util
# AUTHOR      : Yahya
# DESCRIPTION : Wait until read object receives a value (via Modbus SL interface)
#               included in the list of possible values
#  objekt:   symbolic name, e.g. ETA
#  darfWerts: list of possible values
#  timeout:  seconds
#  bitmaske:  to check only specified bits
#
# 150923 Yahya creation of proc
#
#END-------------------------------------------------------------------
proc doWaitForModObjectList { objekt darfWerts timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnumList ""
	set ResEnum ""
	set NameValue ""
	foreach sollWert $darfWerts {
		set ListOfValue [split $sollWert {}]
		if {[lindex $ListOfValue 0] == "."} {
			set NameValue [lrange $ListOfValue 1 end]
			set NameValue [join $NameValue ""]
			set sollWert  [Enum_Value $objekt $NameValue]
			if [regexp {[^0-9]} $sollWert] {
				TlError "Something wrong in list of expected values $darfWerts"
				return
			}
			lappend allowedValues [expr $sollWert & $bitmaske]
			lappend ExpEnumList   "$NameValue"
		}
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadModObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnumList != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		set searchindex [lsearch $allowedValues [expr ($istWert & $bitmaske)]]
		if { $searchindex != -1 } {
			set ExpEnum [lindex $ExpEnumList $searchindex]
			TlPrint "doWaitForModObjectList $objekt act=0x%04X (%d$ResEnum) part of $darfWerts, waittime (%dms / %d requests)" $istWert $istWert $waittime $tryNumber
			break
		} elseif { [expr $waittime > $timeout] } {
			TlError "$TTId doWaitForModObjectList $objekt act=0x%08X (%d$ResEnum) not part of $darfWerts, waittime (%dms)" $istWert $istWert $waittime
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectTol
# TYPE        : util
# AUTHOR      : rothf
# DESCRIPTION : wait until value becomes target (with tolerance)
#               read via actual interface
#
# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
# 090514 ockeg show actual waittime
# 100415 serio enhance timeout to ms precision
#
#END-------------------------------------------------------------------
proc doWaitForObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {
	set NameValue   ""
	set ListOfValue [split $sollWert {}]
	set timeout     [expr int ($timeout*1000)] ;#in ms
	set TTId [Format_TTId $TTId]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] { return }
	}
	set startZeit [clock clicks -milliseconds]
	set tryNumber 0
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set istWert [doReadObject $objekt]
		set  duration [expr [clock clicks -milliseconds] - $startZeit]
		incr tryNumber
		if { $istWert != "" } then {
			set diff [expr $istWert - $sollWert]
			if {[expr abs($diff)] <= $tolerance} {
				TlPrint "doWaitForObject %s exp=%d act=%d tol=%d diff=%d waittime=%d ms requests=%d" \
					$objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
				break
			}
		}
		if { $duration >= $timeout } {
			if { $istWert == "" } {
				TlError "$TTId doWaitForObject $objekt: no response after waittime=%d ms" $duration
			} else {
				TlError "$TTId doWaitForObject %s exp=%d act=%d tol=%d diff=%d TO=$timeout ms WT=%d ms requests=%d" \
					$objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
				if { $show_status } { ShowStatus }
			}
			break
		}
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# DESCRIPTION :
# Wait until read object (via Modbus) receives a specific value
# Special library which will not print an error in case when no response received
# just wait until response is received and received value is equal the
# examples:
# doWaitForObjectNoError HMIS >=2  5
# doWaitForObjectNoError HMIS .FLT 5
# doWaitForObjectNoError ETI  0x02 5 0x03
#
# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
# 100415 serio enhance timeout to ms precision
#
#END-------------------------------------------------------------------
proc doWaitForObjectNoError { object value timeout {bitmask 0xffffffff} {TTId ""}} {
	global Debug_NERA_Storing
	set TTId [Format_TTId $TTId]
	set DebugTimeStart [clock clicks -milliseconds]
	TlPrint "Wait for object $object $value"
	#decode enum list
	if {[string index $value 0] == "."} {
		set value [Enum_Value $object [string range $value 1 end]]
		if [regexp {[^0-9]} $value] {
			return
		}
	}
	set timeout   [expr int ($timeout*1000)] ;# in ms
	set startTime [clock clicks -milliseconds]
	set tryNumber 1
	while {1} {
		set duration [expr [clock clicks -milliseconds] - $startTime]
		set actual [ModTlRead $object 1]  ;# No Error Print
		#TlPrint "actual=$actual"
		if { $actual != "" } then {
			set actual [expr $actual & $bitmask]
			if { [regexp {[<>=]} $value]  } {
				if { ([expr $actual $value]) } {
					TlPrint "$object is $value after $duration ms / $tryNumber requests"
					set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
					break
				}
			} else {
				if { ([expr $actual == $value]) } {
					TlPrint "$object is $value after $duration ms / $tryNumber requests"
					set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
					break
				}
			}
		}
		if { $duration >= $timeout } {
			if { $actual != "" } then {
				TlError "$TTId Timeout: value received $actual is not $value after t=$duration ms"
				#ShowStatus
			} else {
				TlError "$TTId no response from device after t=$duration ms"
			}
			break
		}
		doWaitMsSilent 100
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $actual
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForModObject
# TYPE        : util
# AUTHOR      : pfeig
# DESCRIPTION : same as doWaitForObject but only over Modbus even if CAN or other FB are switched
#  object:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  bitmask:  to check only specified bits
#
#
# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
#
#END-------------------------------------------------------------------
proc doWaitForModObject { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0} } {
	global Debug_NERA_Storing
	set DebugTimeStart [clock clicks -milliseconds]
	set TTId [Format_TTId $TTId]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr $timeout * 1000]
	set tryNumber 1
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		set istWert [doReadModObject $objekt ""]
		if { $istWert == "" } then {
			TlError "illegal RxFrame received"
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {
			TlPrint "doWaitForModObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests), \
	 bitmask = 0x%08X "  $sollWert $sollWert $waittime $tryNumber $bitmaske
			break
		} elseif { [expr $waittime > $timeout] } {
			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet
				if {( $sollWert != 23) && ( $istWert == 23)} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}
				}
			}
			TlError "$TTId doWaitForModObject $objekt exp=0x%04X (%d$ExpEnum), act=0x%04X (%d$ResEnum), \
	    waittime (%dms), bitmask = 0x%04X" $sollWert $sollWert $istWert $istWert $waittime $bitmaske
			if {$noErrPrint == 0} { ShowStatus }
			return 0
		}
		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForModObjectTol
# TYPE        : util
# AUTHOR      : cordc
# DESCRIPTION : wait until value becomes target (with tolerance)
#               read via actual interface
#
#
#END-------------------------------------------------------------------
proc doWaitForModObjectTol { objekt sollWert timeout tolerance {TTId ""} {show_status 1} } {
	set NameValue   ""
	set ListOfValue [split $sollWert {}]
	set timeout     [expr int ($timeout*1000)] ;#in ms
	set TTId [Format_TTId $TTId]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] { return }
	}
	set startZeit [clock clicks -milliseconds]
	set tryNumber 0
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set istWert [doReadModObject $objekt]
		set  duration [expr [clock clicks -milliseconds] - $startZeit]
		incr tryNumber
		if { $istWert != "" } then {
			set diff [expr $istWert - $sollWert]
			if {[expr abs($diff)] <= $tolerance} {
				TlPrint "doWaitForObject %s exp=%d act=%d tol=%d diff=%d waittime=%d ms requests=%d" \
					$objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
				break
			}
		}
		if { $duration >= $timeout } {
			if { $istWert == "" } {
				TlError "$TTId doWaitForObject $objekt: no response after waittime=%d ms" $duration
			} else {
				TlError "$TTId doWaitForObject %s exp=%d act=%d tol=%d diff=%d TO=$timeout ms WT=%d ms requests=%d" \
					$objekt $sollWert $istWert $tolerance $diff $duration $tryNumber
				if { $show_status } { ShowStatus }
			}
			break
		}
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DOC-------------------------------------------------------------------
#
# proc waits for answer of device, special function for device with
# 5V power supply over modbus connector
#
#
#END-------------------------------------------------------------------
proc doWaitForModDeviceAnswer {{timeout 1} {TTId ""}} {
	global glb_Error PrgNr
	set TTId [Format_TTId $TTId]
	set timeout [expr $timeout*1000] ;# in ms
	set startZeit [clock clicks -milliseconds]
	set sollZustand $PrgNr
	while {1} {
		set dauer [expr [clock clicks -milliseconds] - $startZeit]
		set istZustand [ModTlRead MAND.PRGNR 1]
		if { $istZustand != "" } then {
			if { ( $istZustand == $sollZustand) } {
				TlPrint "State is $istZustand after $dauer ms"
				break
			}
		}
		if { $dauer >= $timeout } {
			if { $istZustand != "" } then {
				TlError "$TTId Response from drive is not ($sollZustand) but remains ($istZustand) after t=$dauer ms  ($glb_Error)"
				if { $glb_Error != 0 } {
					TlPrint ""
					TlPrint "!!! WARNING !!!  Global Error is set ($glb_Error)"
					TlPrint ""
				}
			} else {
				TlError "$TTId no response from device after t=$dauer ms"
			}
			break
		}
		if {[CheckBreak]} {break}
	}
	return $istZustand
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForState
# TYPE        : util_ATV
# AUTHOR      : pfeig
# DESCRIPTION : wait for state
#  Values     : 2-9
#  timeout    : seconds
#  TTId: Testtrac entry
#
# measures now the reached time until state
#
# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
#
#END-------------------------------------------------------------------
proc doWaitForState { nominal_state {timeout 1} {TTId ""}} {
	global EthernetBus glb_Error ActDev ActInterface
	global Debugger_StopParaRead theTestProcList
	global theTestTclFilename theTestcaseID theTestDescription
	global TestsBlocked
	set TTId [Format_TTId $TTId]
	TlPrint " Wait for state $nominal_state via $ActInterface, Timeout $timeout s"
	#decode enum list
	if {[string index $nominal_state 0] == "."} {
		set nominal_state [Enum_Value HMIS [string range $nominal_state 1 end]]
		if {![GetDevFeat "MVK"]} {
			if [regexp {[^0-9]} $nominal_state] {
				return
			}
		} else {
			if [regexp {[^0-51]} $nominal_state] {
				return
			}
		}
	}
	set timeout [expr $timeout*1000] ;# in ms
	set startTime [clock clicks -milliseconds]
	while {1} {
		set duration [expr [clock clicks -milliseconds] - $startTime]
		set current_state [TlRead HMIS 1]  ;# No Error Print
		if { $current_state != "" } then {
			set current_state [expr $current_state & 0x3f]
			if {( $current_state != 11 ) || ( $nominal_state == 11 )} {
				if { [regexp {[!<>=]} $nominal_state]  } {
					if { ([expr $current_state $nominal_state]) } {
						TlPrint "State is $current_state after $duration ms"
						set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
						break
					}
				} else {
					if { ([expr $current_state == $nominal_state]) } {
						TlPrint "State is $current_state after $duration ms"
						set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
						break
					}
				}
			}
		}
		if { $duration >= $timeout } {
			if { $current_state != "" } then {
				if {$current_state == 23} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							set TTId [Format_TTId "GEDEC00203810"]
						}
						68 {
							# INF6
							set TTId [Format_TTId "GEDEC00203492"]
						}
						69 {
							# INFE
							set TTId [Format_TTId "GEDEC00201702"]
						}
						153 {
							# INFM
							set TTId [Format_TTId "GEDEC00203425"]
						}
					}
				}
				TlError "$TTId State is not ($nominal_state) but remains ($current_state) after t=$duration ms  ($glb_Error)"
				if { $glb_Error != 0 } {
					TlPrint ""
					TlPrint "!!! WARNING !!!  Global Error is set ($glb_Error)"
					TlPrint ""
				}
				ShowStatus
			} else {
				TlError "$TTId no response from device after t=$duration ms"
				#            doWaitMs 5000
				#            ShowStatus
				#            if {[lindex $theTestProcList 0] == "TC_0Init_TestfileStart"} {
				#               TlPrint "Do not remove TCs if in TC0Init"
				#            } else {
				#               TlPrint "The rest of file TC will be removed. Next Proc: TestFileStop"
				#               set TestsBlocked 1
				#               set LoadActive [LoadRead STD.STATUSWORD 1]
				#               if {$LoadActive != ""} {LoadOff}
				#               set TestStopPos [expr [llength $theTestProcList] - 1]
				#               # get all left TCs
				#               foreach TcID $theTestProcList {
				#                  if { $TcID == $theTestcaseID } {
				#                     catch {unset removedTCs}
				#                  } else {
				#                     lappend removedTCs $TcID
				#                  }
				#               }
				#               #execute in catch block, if no entries in removedTCs (i.e. actual TC is
				# TestfileStop)
				#               catch {
				#                  # remove TestfileStop
				#                  set removedTCs [lrange $removedTCs 0 end-1 ]
				#
				#                  set OldID $theTestcaseID
				#                  set OldDesc $theTestDescription
				#
				#                  # make an block entry for each removed TC
				#                  foreach TcID $removedTCs {
				#                     TlTestCase $theTestTclFilename $TcID "Blocked"
				#                     TlBlock "removed because of Error in $OldID"
				#                  }
				#               }
				#               set theTestProcList [lindex $theTestProcList $TestStopPos]
				#               puts $theTestProcList
				#            }
			}
			break
		}
		doWaitMsSilent 30
		if {[CheckBreak]} {break}
	}
	return $current_state
} ;# doWaitForState

# 030414 serio returns if Enum_Value returns the name instead of the value(digits)
proc doWaitForModState { nominal_state {timeout 1} {TTId ""}} {
	global EthernetBus glb_Error ActDev
	global Debugger_StopParaRead theTestProcList
	set TTId [Format_TTId $TTId]
	TlPrint "Wait for state $nominal_state via MDB, Timeout $timeout s"
	#decode enum list
	if {[string index $nominal_state 0] == "."} {
		set nominal_state [Enum_Value HMIS [string range $nominal_state 1 end]]
		if [regexp {[^11]} $nominal_state] {
			return
		}
	}
	set timeout [expr $timeout*1000] ;# in ms
	set startTime [clock clicks -milliseconds]
	while {1} {
		set duration [expr [clock clicks -milliseconds] - $startTime]
		set current_state [ModTlRead HMIS 1]  ;# No Error Print
		if { $current_state != "" } then {
			set current_state [expr $current_state & 0x3f]
			if {( $current_state != 11 ) || ( $nominal_state == 11 )} {
				if { [regexp {[!<>=]} $nominal_state]  } {
					if { ([expr $current_state $nominal_state]) } {
						TlPrint "State is $current_state after $duration ms"
						set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
						break
					}
				} else {
					if { ([expr $current_state == $nominal_state]) } {
						TlPrint "State is $current_state after $duration ms"
						set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
						break
					}
				}
			}
		}
		if { $duration >= $timeout } {
			if { $current_state != "" } then {
				if {$current_state == 11} {
					break
				}
				if {$current_state == 23} {
					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							set TTId [Format_TTId "GEDEC00203810"]
						}
						68 {
							# INF6
							set TTId [Format_TTId "GEDEC00203492"]
						}
						69 {
							# INFE
							set TTId [Format_TTId "GEDEC00201702"]
						}
						153 {
							# INFM
							set TTId [Format_TTId "GEDEC00203425"]
						}
					}
				}
				TlError "$TTId State is not ($nominal_state) but remains ($current_state) after t=$duration ms  ($glb_Error)"
				if { $glb_Error != 0 } {
					TlPrint ""
					TlPrint "!!! WARNING !!!  Global Error is set ($glb_Error)"
					TlPrint ""
				}
				ShowStatus
			} else {
				TlError "$TTId no response from device after t=$duration ms"
				#Automatic remove of testcases deactiveted, same as done in doWaitForState in V229
				#            if {[lindex $theTestProcList 0] == "TC_0Init_TestfileStart"} {
				#               TlPrint "Do not remove TCs if in TC0Init"
				#            } else {
				#               TlPrint "The rest of file TC will be remove. Next Proc: TestFileStop"
				#               #no Load device for KALA
				#               #set LoadActive [LoadRead STD.STATUSWORD 1]
				#               #if {$LoadActive != ""} {LoadOff}
				#               set TestStopPos [expr [llength $theTestProcList] - 1]
				#               set theTestProcList [lindex $theTestProcList $TestStopPos]
				#               puts $theTestProcList
				#            }
			}
			break
		}
		doWaitMsSilent 30
		if {[CheckBreak]} {break}
	}
	return $current_state
} ;# doWaitForModState

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForResponse
# TYPE        : util_ATV
# AUTHOR      : pfeig
# DESCRIPTION : wait for response from the drive
#  timeout    : seconds
#  TTId: Testtrac Entry
#
# measures now the reached time until state
#END-------------------------------------------------------------------
proc doWaitForResponse { {timeout 1} {TTId ""}} {
	global EthernetBus glb_Error ActDev
	global Debugger_StopParaRead
	set TTId [Format_TTId $TTId]
	set timeout [expr $timeout*1000] ;# in ms
	set startTime [clock clicks -milliseconds]
	while {1} {
		set duration [expr [clock clicks -milliseconds] - $startTime]
		set current_state [TlRead HMIS 1]  ;# No Error Print
		if { $current_state != "" } then {
			set current_state [expr $current_state & 0x3f]
			TlPrint "State is $current_state after $duration ms"
			set Debugger_StopParaRead 0  ;# Allow access for Tcl_Debugger to Read ServoDrive Parameters
			return $current_state
		}
		if { $duration >= $timeout } {
			if { $current_state != "" } then {
				TlError "$TTId State is not ($nominal_state) but remains ($current_state) after t=$duration ms  ($glb_Error)"
				if { $glb_Error != 0 } {
					TlPrint ""
					TlPrint "!!! WARNING !!!  Global Error is set ($glb_Error)"
					TlPrint ""
				}
				ShowStatus
			} else {
				TlError "$TTId no response from device after t=$duration ms"
				set R1 [wc_Check_DQx $ActDev 0 "L"]                      ;#R1 output is low by defaut in case of fault present (e.g. CFF)
				if {$R1 == "H"} {
					TlPrint "Drive is not in fault, see input cable or drive output connection"
				}
				TlPrint "Do a configuration factory setting to clear CFF fault"
				doAdjustDefaults 2
				TlWrite RP .YES
			}
			break
		}
		doWaitMsSilent 30
		if {[CheckBreak]} {break}
	}
}

proc doWaitForOff { {timeout 1} {TTId ""} {ShowError 1}} {
	global GLOB_LAST_DRIVE_REBOOT
	set TTId [Format_TTId $TTId]
	#without that the while loop will always take 5 sec
	ModSetTimeout 40 200 200
	set timeout   [expr $timeout*1000] ;# in ms
	set startZeit [clock clicks -milliseconds]
	while {1} {
		set istZustand [ModTlRead "HMIS" 1]  ;# No Error Print
		set dauer [expr [clock clicks -milliseconds] - $startZeit]
		if { $istZustand == "" } then {
			TlPrint "Device is off after $dauer ms"
			break
		}
		if { $dauer >= $timeout } {
			if {$ShowError} {
				TlError "$TTId always response from device after t=$dauer ms"
			} else {
				TlPrint "always response from device after t=$dauer ms"
				if {[GetDevFeat "Modul_SM1"] } {
					TlError "RP not done then wrong safety configuration"
					DeviceOff $ActDev
					doWaitMs 5000
					DeviceOn $ActDev
				}
			}
			break
		}
		if {[CheckBreak]} {break}
		after 50
	}
	ModDefaultTimeout ;# restore
	set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]
	return $istZustand
}

proc doWaitForPosMove { timeout {TTId ""} } {
	global AW_NACT_P
	set TTId [Format_TTId $TTId]
	set startZeit  [clock clicks -milliseconds]
	set timeout    [expr $timeout * 1000] ;# Conversion in millisec.
	while {1} {
		if { [CheckBreak] } {
			return 1
		}
		set istZustand [expr [doReadObject ST06] & 0x0008]       ;#Bit3 : motor running in forward
		if { $istZustand == 0x0008 } {
			TlPrint "Drive rotates clockwise after %d ms " [expr [clock clicks -milliseconds] - $startZeit]
			return 0
		}
		if {[expr [clock clicks -milliseconds] - $startZeit >= $timeout] } {
			TlError "$TTId Drive doesn't rotate clockwise after $timeout ms"
			ShowStatus  ;# Display diagnostic
			return 1
		}
		if {[CheckBreak]} {break}
	}
}

proc doWaitForNegMove { timeout {TTId ""} } {
	global AW_NACT_N
	set TTId [Format_TTId $TTId]
	set startZeit  [clock clicks -milliseconds]
	set timeout    [expr $timeout * 1000] ;# Conversion in millisec.
	while {1} {
		if { [CheckBreak] } {
			return 1
		}
		set istZustand [expr [doReadObject ST06] & 0x0010]       ;#Bit4 : motor running in reverse
		if { $istZustand == 0x0010 } {
			TlPrint "Drive rotates counterclockwise after %d ms " [expr [clock clicks -milliseconds] - $startZeit]
			return 0
		}
		if {[expr [clock clicks -milliseconds] - $startZeit >= $timeout] } {
			TlError "$TTId Drive doesn't rotate counterclockwise after $timeout ms"
			ShowStatus  ;# Display diagnostic
			return 1
		}
		if {[CheckBreak]} {break}
	}
}

proc changeATVprofile {profile Ref1Channel {Cmd1Channel "TER"} {Ref1BChannel "NO"} {Ref2Channel "NO"} {Cmd2Channel "MDB"} } {
	global GLOB_LAST_DRIVE_REBOOT
	set profile       [string toupper $profile]
	set Ref1Channel   [string toupper $Ref1Channel]
	set Ref1BChannel  [string toupper $Ref1BChannel]
	set Ref2Channel   [string toupper $Ref2Channel]
	set Cmd1Channel   [string toupper $Cmd1Channel]
	set Cmd2Channel   [string toupper $Cmd2Channel]
	TlPrint "Change profile (CHCF) to $profile"
	TlPrint "with Ref1Channel=$Ref1Channel, Ref1BChannel=$Ref1BChannel, Ref2Channel=$Ref2Channel, Cmd1Channel=$Cmd1Channel and Cmd2Channel=$Cmd2Channel"
	doWaitForEEPROMFinished 10 0     ;#profile changes may take EEPROM access time
	doWaitMs 7000
	if {[info exists GLOB_LAST_DRIVE_REBOOT]} {
		# wait at least 8 seconds after switching on
		set WaitAfterOn [expr 8000 - ([clock clicks -milliseconds] - $GLOB_LAST_DRIVE_REBOOT)]
		if {$WaitAfterOn > 0} {
			TlPrint "SwitchOn was only some seconds before, wait at least a total of 8 seconds"
			doWaitMs $WaitAfterOn
		}
	}
	ModTlWrite CHCF   .$profile
	doWaitForEEPROMFinished 10       ;#profile changes may take EEPROM access time
	# just to be sure there is really everything finished...
	# sporadic issues without this waittime
	# 1s is not working, OK with 2s
	doWaitMs 2000
	ModTlWrite FR1    .$Ref1Channel
	ModTlWrite CD1    .$Cmd1Channel
	ModTlWrite FR1B   .$Ref1BChannel
	ModTlWrite FR2    .$Ref2Channel
	ModTlWrite CD2    .$Cmd2Channel
	#   ModTlRead CHCF  .$profile
	#   ModTlRead FR1   .$Ref1Channel
	#   ModTlRead CD1   .$Cmd1Channel
	#   ModTlRead FR1B  .$Ref1BChannel
	#   ModTlRead FR2   .$Ref2Channel
	#   ModTlRead CD2   .$Cmd2Channel
	doWaitForObject CHCF .$profile 5
	doWaitForObject FR1 .$Ref1Channel 5
	doWaitForObject CD1 .$Cmd1Channel 5
	doWaitForObject FR1B .$Ref1BChannel 5
	doWaitForObject FR2 .$Ref2Channel 5
	doWaitForObject CD2 .$Cmd2Channel 5
	# just to be sure there is really everything finished...
	# sporadic issues without this waittime
	doWaitMs 1000
}

proc showATVprofile { } {
	TlPrint " Channel configuration..(CHCF)..... %s"   [Enum_Name CHCF   [ModTlRead CHCF 1] ]
	TlPrint " Reference source 1..(FR1)......... %s"   [Enum_Name FR1    [ModTlRead FR1  1] ]
	TlPrint " Channel 1 command source..(CD1)... %s"   [Enum_Name CD1    [ModTlRead CD1  1] ]
	TlPrint " Reference source 1B..(FR1B)....... %s"   [Enum_Name FR1B   [ModTlRead FR1B 1] ]
	TlPrint " Reference source 2..(FR2)......... %s"   [Enum_Name FR2    [ModTlRead FR2  1] ]
	TlPrint " Channel 2 command source..(CD2)... %s"   [Enum_Name CD2    [ModTlRead CD2  1] ]
}

#-----------------------------------------------------------------------
# Pause
#-----------------------------------------------------------------------
proc doWaitMs { timeout_ms } {
	global globAbbruchFlag
	## Don't allow Tcl_Debugger to Read ServoDrive Parameters during working on procedure doWaitMs
	global Debugger_StopParaRead
	set aktDebugger_StopParaRead $Debugger_StopParaRead
	set Debugger_StopParaRead 1
	## Don't allow Tcl_Debugger to Read ServoDrive Parameters during working on procedure doWaitMs
	set timeout_ms [expr round($timeout_ms)]
	TlPrint "wait for $timeout_ms ms"
	if {[CheckBreak]} {set globAbbruchFlag 1}
	if {$globAbbruchFlag} {return}
	set Start [clock clicks -milliseconds]
	set Ende [clock clicks -milliseconds]
	if { $timeout_ms <= 50} {
		after $timeout_ms
		update idletasks
		set Ende [clock clicks -milliseconds]
	} elseif { $timeout_ms <= 500 } {
		after [expr $timeout_ms / 2]
		update idletasks
		after [expr ($Start + $timeout_ms) - [clock clicks -milliseconds]]
		update idletasks
		set Ende [clock clicks -milliseconds]
	} else {
		set divisor 10
		set waittime [expr $timeout_ms / $divisor]
		for {set i 0} {$i < $divisor} {incr i} {
			if { $Ende >= [expr $Start + $timeout_ms ] } {
				break
			}
			if {[CheckBreak]} {
				set globAbbruchFlag 1
				break
			}
			set remaintime [expr ($Start + $timeout_ms) - [clock clicks -milliseconds]]
			if { $remaintime < $waittime } {
				set waittime $remaintime
			}
			after $waittime
			update idletasks
			set Ende [clock clicks -milliseconds]
		}
	}
	#   TlPrint "waited ms= [expr $Ende - $Start]"
	#   if { $Ende > [expr $Start + $timeout_ms + 100] } {
	#      TlPrint "**********************************************************"
	#      TlError "Problem with doWaitMsSilent Nom:$timeout_ms waited=[expr $Ende - $Start] "
	#      TlPrint "Start= $Start Ende= $Ende "
	#      TlPrint "**********************************************************"
	#   }
	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by
	# other procedures
	if {!$aktDebugger_StopParaRead} {set Debugger_StopParaRead 0}
	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by
	# other procedures
} ;# doWaitMs

#-----------------------------------------------------------------------
# Pause
#-----------------------------------------------------------------------
# Copy of doWaitMs without time display
proc doWaitMsSilent { timeout_ms } {
	global globAbbruchFlag
	## Don't allow Tcl_Debugger to Read ServoDrive Parameters during working on procedure
	# doWaitMsSilent
	global Debugger_StopParaRead
	set aktDebugger_StopParaRead $Debugger_StopParaRead
	set Debugger_StopParaRead 1
	## Don't allow Tcl_Debugger to Read ServoDrive Parameters during working on procedure
	# doWaitMsSilent
	set timeout_ms [expr round($timeout_ms)]
	#   TlPrint "wait for $timeout_ms ms"
	if {[CheckBreak]} {set globAbbruchFlag 1}
	if {$globAbbruchFlag} {return}
	set Start [clock clicks -milliseconds]
	set Ende [clock clicks -milliseconds]
	if { $timeout_ms <= 50} {
		after $timeout_ms
		update idletasks
		set Ende [clock clicks -milliseconds]
	} elseif { $timeout_ms <= 500 } {
		after [expr $timeout_ms / 2]
		update idletasks
		after [expr ($Start + $timeout_ms) - [clock clicks -milliseconds]]
		update idletasks
		set Ende [clock clicks -milliseconds]
	} else {
		set divisor 10
		set waittime [expr $timeout_ms / $divisor]
		for {set i 0} {$i < $divisor} {incr i} {
			if { $Ende >= [expr $Start + $timeout_ms ] } {
				break
			}
			if {[CheckBreak]} {
				set globAbbruchFlag 1
				break
			}
			set remaintime [expr ($Start + $timeout_ms) - [clock clicks -milliseconds]]
			if { $remaintime < $waittime } {
				set waittime $remaintime
			}
			after $waittime
			update idletasks
			set Ende [clock clicks -milliseconds]
		}
	}
	#   TlPrint "silent waited ms= [expr $Ende - $Start]"
	#   if { $Ende > [expr $Start + $timeout_ms + 100] } {
	#      TlPrint "**********************************************************"
	#      TlError "Problem with doWaitMsSilent Nom:$timeout_ms waited=[expr $Ende - $Start] "
	#      TlPrint "Start= $Start Ende= $Ende "
	#      TlPrint "**********************************************************"
	#   }
	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by
	# other procedures
	if {!$aktDebugger_StopParaRead} {set Debugger_StopParaRead 0}
	## Do only  allow access to Read ServoDrive Parameters by Tcl_Debugger if he is not blocked by
	# other procedures
} ;# doWaitMsSilent

# Doxygen Tag:
# Function description :  # Wait a given amount of time from a given timestamp
# WHEN  | WHO  | WHAT
# -----| -----| -----
#2023/10/18 | ASY | proc created
# \n
# \param[in] timeout : duration to wait in ms
# \param[in] date : date from which to wait given as the return of the [clock clicks -milliseconds] function
# E.g. use < doWaitMsFromDate 1500 [clock clicks -milliseconds]>

proc doWaitMsFromDate { timeout_ms date }  {
	set timeout_ms [expr round($timeout_ms)]
	set endDate [expr $date + $timeout_ms]
	set deltaTime [expr $endDate - [clock click -milliseconds]]
	TlPrint "Waiting $timeout_ms from starting point. Remaining time $deltaTime ms"
	while { $deltaTime >= 0 } {
		set deltaTime [expr $endDate - [clock click -milliseconds]]
		after 10
		update idletasks
		if {[CheckBreak]} { return }
	}
}

#-------------------------------------------------------------
# append a test to the testlist, depending on
# the features defined and the logical operators
#
# example on a device with feature "f1" and "f2":
#
# append_test theTestList Test1 { f1  f2  f3}
# append_test theTestList Test2 {!f1  f2  f3}
# append_test theTestList Test3 {&f1 &f2 &f3}
# append_test theTestList Test4 { f1 &f2 !f3}
#
# if there are features without operator at least one of them has to be in device
# if there are features with & all of them have to be in device
# if there are features with ! no of them may be in device
# if the robustness feature is present it must begin with a "-". In this specific campaign only robustness test cases will be launched
#
# => Test1 and Test4 will be appended
proc append_test {testlist test featurelist} {
	global reducedTestExecution theTestSuite executeTestSuite
	upvar $testlist ptrlist
	set ListOR {}
	set ListAND {}
	set ListNOT {}
	set robustnessFlag 0
	# sort arguments depending on their logic operator
	foreach feature $featurelist {
		switch -regexp [string index $feature 0] {
			"!" { lappend ListNOT [string range $feature 1 end] }
			"&" { lappend ListAND [string range $feature 1 end] }
			"-" { set robustnessFlag 1}
			default {lappend ListOR $feature}
		}
	}
	# priority 1
	# check all NOT features
	# skip test if one of them is in device
	foreach feature $ListNOT {
		if { [GetSysFeat $feature] } {return}
	}
	# priority 2
	# check if one of the OR features is in device
	set InDev 0
	foreach feature $ListOR {
		if { [GetSysFeat $feature] } {
			set InDev 1
			break
		}
	}
	if {$InDev == 0} {return}
	# priority 3
	# check if all of the AND features is are device
	set InDev 1
	foreach feature $ListAND {
		if { [GetSysFeat $feature] != 1 } {
			set InDev 0
			break
		}
	}
	if {$InDev == 0} {return}
	if {![GetDevFeat "Robustness"]} {
		lappend ptrlist $test
	} else { 
		if { $robustnessFlag } {
			lappend ptrlist $test
		}
	}
	#If reduced test execution is selected,
	#check if execution of test is valid this time.
	#If there is no test in category (resp. only TesifileStart
	#and TestfileStop available), test category will not be executed
	#sequence for reduced test execution SkipLot:
	# - if actual testCaseId is *TestFileStart, save name of TestSuite
	# - if actual testCaseId is *TestFileStop, check if test Suite has to be
	#     executed this time
	if {($reducedTestExecution) && ($testlist == "theTestProcList") } {
		if {[regexp {TestfileStart} $test] } {
			#name of actual test suite is testCaseId without '_TestfileStart'
			set theTestSuite [string map {"_TestfileStart" ""} $test]
		}
		if {[regexp {TestfileStop} $test] } {
			#check if testSuite has to be executed
			if {[getExecutionState $theTestSuite] == 0} {
				#if test suite will no be executed, increment test counter
				#for each test case of test suite and delete list with
				#test cases --> no test of category will be executed
				foreach testCase $ptrlist {
					TlStatistics $testCase "OK"
				}
				set ptrlist {}
			}
		}
	}
} ;# append_test

#
#check whether test suite has to be executed ( SkipLot)
proc getExecutionState { TestSuiteId } {
	global theTestStatisticsFileName
	global startTimeOfTest
	global CreateLog
	if { !$CreateLog } {
		TlPrint " #info:getExecutionState: create log file is switched off"
		return
	}
	set filehandle [ini::open $theTestStatisticsFileName "r+"]
	set section "TestSuiteExecutionCounter"
	set actCount [ini::value $filehandle $section $TestSuiteId "ndef"]
	TlPrint "actCount: $actCount"
	if {$actCount == "ndef"} {
		set actCount 0
	}
	if {$actCount < 10} {
		#if test suite counter is < 10, execute suite always
		set execute 1
	} elseif {[expr ($actCount - 10) % 5] == 0} {
		#if test suite counter is > 10, execute suite every 5th time
		set execute 1
	} else {
		#else do not execute test suite
		set execute 0
	}
	ini::close $filehandle
	return $execute
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Calculate the check sum of given string and give it back
#
#
#END----------------------------------------------------------------
proc doCheckSum { tstring } {
	global ActDev
	# Calculate check sum
	binary scan $tstring c* bytes
	set sum 0
	foreach byte $bytes {
		incr sum [expr {$byte & 0xff}]
	}
	return $sum
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Provide to logic parameter names the corresponding Index, Subindex and Datentyp
# Ex1:
#   set Address [getIndex MOTION.UPRAMP0]   ;#-> give "6 10 4"
#   set idx  [lindex $Address 0]   ;# index 6
#   set six  [lindex $Address 1]   ;# subindex 10
#   set data [lindex $Address 2]   ;# datalength 4
# Ex2:
#   set Address [getIndex 6.10]             ;#-> give "6 10 4"
#   set idx  [lindex $Address 0]   ;# index 6
#   set six  [lindex $Address 1]   ;# subindex 10
#   set data [lindex $Address 2]   ;# datalength 4
#----------------------------------------------------------------------------
proc getLXMIndex {objString} {
	global theLXMObjDataTyptable theLXMObjHashtable theLXMVARHashtable errorInfo
	if {[regexp {0x6*} $objString] || [regexp {0x1*} $objString]} {
		# numerical operation, e.g. "0x6040.0"
		set objList [split $objString .]
		set idx [lindex $objList 0]
		set six [lindex $objList 1]
	} elseif [regexp {[0-9]+\.[0-9]+} $objString] {
		# numerical operation, e.g. "11.9"
		set objList [split $objString .]
		set idx [lindex $objList 0]
		set six [lindex $objList 1]
	} else {
		if { [string match "*_*" $objString] } {
			# Conversion of objString's through Hashtable in Index/SubIndex
			if { [catch { set index $theLXMVARHashtable($objString) }]  != 0 } {
				TlError "TCL-Error message: $errorInfo : Object: $objString"
				return 0
			}
		} else {
			# Conversion of objString's through Hashtable in Index/SubIndex
			if { [catch { set index $theLXMObjHashtable($objString) }]  != 0 } {
				TlError "TCL-Error message: $errorInfo : Object: $objString"
				return 0
			}
		}
		set idx [lindex [split $index .] 0]
		set six [lindex [split $index .] 1]
	}
	set DataLength 0
	catch {set DataLength $theLXMObjDataTyptable($idx.$six)}
	if {$DataLength == 0 } {
		if { $idx <= 127 } {
			# Data type is only important for every user parameter
			# Every Parameter > 127 are regulated over Peek/Poke Access
			TlPrint "getIndex: Obj=$objString unknown Data length, accept 4 Bytes"
			# not any TlError, one wants to correspond a not existing object
			# then TlRead must give the error, not getIndex
		}
		set DataLength 4
	}
	return "$idx $six $DataLength"
} ;# getIndex

#-------------------------------------------------------------------------------------------------------------
# Calculate from the BL Ix.Six Adress the corresponding Modbus Address:
#    Modbusadress = BlIndex*256 + BlSubindex*2
#
# The Profibus Address is calculated by this way!
proc getModbusAdr { obj } {
	set Address    [getIndex $obj]
	if { $Address == 0 } {
		# error from getIndex
		return 0
	}
	set idx        [lindex $Address 0]
	set six        [lindex $Address 1]
	set DataLength [lindex $Address 2]
	return [format "0x%04X" [expr ($idx<<8) + ($six<<1)]]
}

#-------------------------------------------------------------------------------------------------------------
# see getModbusAdr
proc getPBAdr { obj } {
	return [getModbusAdr $obj]
}

#DOC-------------------------------------------------------------------
#DESCRIPTION
# Try all combinations:
#    Baudrate:   9600, 19200, 38400
#    Format:     1 = 8Bit NoParity 1Stop (8n1)
#                2 = 8Bit EvenParity 1Stop (8e1)
#                3 = 8Bit OddParity 1Stop (8o1)
#                4 = 8Bit NoParity 2Stop (8n2)
#
# provide the detected combination as string, e.g. "9600,8,n,1"
# or empty string if no communication was possible
#
#END-------------------------------------------------------------------
proc TryAllModbusFormats {  } {
	global DevAdr ActDev
	global theSerialPort theSerialBaud
	ModSetTimeout 40 1000 1000
	set DevAdr($ActDev,MOD) 0xF8
	set VerbindungOK 0
	for {set b 0} {$b <= 3} {incr b} {
		set Baudrate [expr round(4800 * pow(2,$b))]
		for {set Format 1} {$Format <= 4} {incr Format} {
			switch $Format {
				1 { set FormatString ",8,n,1"
					set Parity   0
					set StopBits 1
				}
				2 { set FormatString ",8,e,1"
					set Parity   1
					set StopBits 1
				}
				3 { set FormatString ",8,o,1"
					set Parity   2
					set StopBits 1
				}
				4 { set FormatString ",8,n,2"
					set Parity   0
					set StopBits 2
				}
			}
			if { [CheckBreak] } { return }
			TlPrint ""
			TlPrint "Configure PC interface on $Baudrate$FormatString"
			ModClose
			ModOpen $theSerialPort $Baudrate $StopBits $Parity
			ModSetTimeout 40 1000 1000
			set Parameter 0
			set Parameter [ModTlRead C1CT 1]
			TlPrint "ModTlRead C1CT returned: $Parameter"
			if {( $Parameter != 0 ) && ( $Parameter != "" )} {
				set VerbindungOK 1
				break
			} else {
				TlPrint "no return message from device with $Baudrate$FormatString"
			}
		} ;# for format
		if { $VerbindungOK } { break }
	} ;# for baudrate
	if { $VerbindungOK } {
		ReadConfigValues
		set ModAddrTmp $DevAdr($ActDev,MOD)
		set DevAdr($ActDev,MOD) 0xF8
		ModTlWrite ADD $ModAddrTmp
		doWaitForModObject ADD $ModAddrTmp 5
		ModTlWrite TBR .$theSerialBaud
		doWaitForModObject TBR .$theSerialBaud 5
		ModTlWrite TFO .8E1
		doWaitForModObject TFO .8E1 5
		doStoreEEPROM
		ModDefaultTimeout
		ModClose
		ModOpen $theSerialPort $theSerialBaud 1 1 ;#Re-open MDB com
		set DevAdr($ActDev,MOD) $ModAddrTmp
		DeviceOff $ActDev 1
		if { [GetDevFeat "Nera"] } {
			wc_NeraOnOff $ActDev "H"
		} elseif {[GetDevFeat "Beidou"] } {
			wc_BeidouOnOff $ActDev "H"
		} else {
			TlError "unknown device"
			return 0
		}
		doWaitForModState ">=0" 30    ;# wait for any modbus communication
		checkModObject ADD $DevAdr($ActDev,MOD)
		return 1
	} else {
		TlError "no connection possible to device at all!"
		ReadConfigValues
		ModDefaultTimeout
		ModClose
		ModOpen $theSerialPort $theSerialBaud 1 1 ;#Re-open MDB com
		return 0
	}
}

#-----------------------------------------------------------------------
# Display 32 Bit IP-Address in point form
# or vice versa, depending on what is transfered
# Ex  getIPadr 0xC0A86401     -> result = 192.168.100.1
# Ex  getIPadr 192.168.100.1  -> result = 0xC0A86401
proc getIPadr { ip_adr {print 0} } {
	if [regexp {[0-9]+\.[0-9]+} $ip_adr] {
		# Conversion of 192.168.100.1 -> 0xC0A86401
		set bytes [split $ip_adr .]
		set byte3 [lindex $bytes 0]
		set byte2 [lindex $bytes 1]
		set byte1 [lindex $bytes 2]
		set byte0 [lindex $bytes 3]
		set result [format "0x%02X%02X%02X%02X" $byte3 $byte2 $byte1 $byte0]
	} else {
		# Conversion of 0xC0A86401 -> 192.168.100.1
		set result {}
		append result [format "%d." [expr ($ip_adr >> 24) & 0xFF]]
		append result [format "%d." [expr ($ip_adr >> 16) & 0xFF]]
		append result [format "%d." [expr ($ip_adr >>  8) & 0xFF]]
		append result [format "%d"  [expr ($ip_adr      ) & 0xFF]]
	}
	if { $print } { TlPrint "$result" }
	return $result
}

#-----------------------------------------------------------------------
# read out the IP Address from a Drive or from the configuration file
# src can be "drive" or "config".
# "drive": Values will be read from the the drive
# "config" Values will be read from the "config_DExxxx.ini"
proc readOutIPadrOptn { { nipple 0 } {src "drive"} } {
	global DevAdr ActDev
	if {$src == "drive"} {
		if { $nipple > 0 } {
			if {$nipple > 4} {
				TlError "Wrong value: $nipple for nipple in readOutIPadrOptn. Max. value is 4"
				set ip_adr 0
				return -1
			}
			set ip_adr [ModTlRead IPC$nipple]
		} else {
			set ip_adr 0
			catch {
				set ip_adr [expr $ip_adr + ([ModTlRead IPC1] << 24)]
				set ip_adr [expr $ip_adr + ([ModTlRead IPC2] << 16)]
				set ip_adr [expr $ip_adr + ([ModTlRead IPC3] <<  8)]
				set ip_adr [expr $ip_adr + ([ModTlRead IPC4]      )]
			}
			set ip_adr [format "0x%08X" $ip_adr]
		}
	} else {
		if { $nipple > 0} {
			if {$nipple > 4} {
				TlError "Wrong value: $nipple for nipple in readOutIPadrOptn. Max. value is 4"
				set ip_adr 0
				return -1
			}
			set ip_adr $DevAdr($ActDev,OptBrdIP)
			set parts [split $ip_adr "."]
			set ip_adr [lindex $parts [expr $nipple -1]]
		} else {
			set ip_adrConf $DevAdr($ActDev,OptBrdIP)
			set ip_adr 0
			set parts [split $ip_adrConf "."]
			set ip_adr [expr $ip_adr + ([lindex $parts 0] << 24)]
			set ip_adr [expr $ip_adr + ([lindex $parts 1] << 16)]
			set ip_adr [expr $ip_adr + ([lindex $parts 2] <<  8)]
			set ip_adr [expr $ip_adr + ([lindex $parts 3]      )]
			set ip_adr [format "0x%08X" $ip_adr]
		}
	}
	return $ip_adr
}

proc readOutIPadrBasic { { nipple 0 } } {
	if { $nipple > 0 } {
		set ip_adr [ModTlRead IC0$nipple]
	} else {
		set ip_adr 0
		catch {
			set ip_adr [expr $ip_adr + ([ModTlRead IC01] << 24)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC02] << 16)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC03] <<  8)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC04]      )]
		}
		set ip_adr [format "0x%08X" $ip_adr]
	}
	return $ip_adr
}

proc readOutIPadrAdv { { nipple 0 } } {
	if { $nipple > 0 } {
		set ip_adr [ModTlRead IC1$nipple]
	} else {
		set ip_adr 0
		catch {
			set ip_adr [expr $ip_adr + ([ModTlRead IC11] << 24)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC12] << 16)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC13] <<  8)]
			set ip_adr [expr $ip_adr + ([ModTlRead IC14]      )]
		}
		set ip_adr [format "0x%08X" $ip_adr]
	}
	return $ip_adr
}

#DOC--------------------------------------------------------------------------------
# DESCRIPTION
#
# set cmdInterface to that one of the global Fieldbus
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 090714 ockeg    created
#
#END--------------------------------------------------------------------------------
proc doRestoreCmdInterface { } {
	global Fieldbus
	doSetCmdInterface $Fieldbus
}

#DOC--------------------------------------------------------------------------------
# DESCRIPTION
#
# Load the corresponding file cmd_tlxxx with source command
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 050808 ockeg    created
# 010409 ockeg    EIP implemented, ECAT and EPL deleted
#
#END--------------------------------------------------------------------------------
proc doSetCmdInterface { interface {option ""}} {
	global libpath
	global ActInterface
	switch $interface {
		"DVN" {
			TlPrint "Switch bus interface to DeviceNet via: cmd_DevNet_ATV_tlxxx"
			source  "$libpath/cmd_DevNet_ATV_tlxxx.tcl"
		}
		"EIP" -
		"EIP_OptionBoard" {
			if {[GetSysFeat "ATLAS"] || [GetSysFeat "PACY_SFTY_FIELDBUS"]} {
				TlPrint "Switch bus interface to Ethernet-IP via: cmd_EIP_SEPLC"
				source  "$libpath/cmd_EIP_SEPLC.tcl"
				set ActInterface $interface
			} else {
				TlPrint "Switch bus interface to Ethernet-IP via: cmd_EIP_ATV_tlxxx"
				source  "$libpath/cmd_EIP_ATV_tlxxx.tcl"
			}
		}
		"MODTCP" -
		"MODTCP_OptionBoard" -
		"MODTCP_PNV2" -
		"MODTCP_OptionBoard_UID251" {
			if { ( $interface in {"MODTCP" "MODTCP_OptionBoard" "MODTCP_PNV2" } ) && [GetSysFeat "ATLAS"]} {
				TlPrint "Switch bus interface to $interface via: cmd_MDBTCP_SEPLC.tcl"
				source "$libpath/cmd_MDBTCP_SEPLC.tcl"
				TlPrint "actual businterface: $interface"
				set ActInterface $interface
			} else {
				TlPrint "Switch bus interface to $interface via: cmd_Mod2_ATV_tlxxx"
				source  "$libpath/cmd_Mod2_ATV_tlxxx.tcl"
				TlPrint "actual businterface: $interface"
				set ActInterface $interface
			}
		}
		"MODTCPioScan" -
		"MODTCPioScan_OptionBoard" {
			TlPrint "Switch bus interface to Modbus-TCP IO-Scanner via: cmd_MOD2_tlxxx_io"
			source  "$libpath/cmd_MOD2_tlxxx_io.tcl"
		}
		"SPB_IO" {
			TlPrint "Switch bus interface to ProfiBUS-IO via: cmd_SPB_ATV_tlxxx_io"
			source  "$libpath/cmd_SPB_ATV_tlxxx_io.tcl"
		}
		"SPB_STD" { 
            if {![GetSysFeat "ATLAS"] } {
                if { $option == "COMP" } {
                    setProfidriveCompMode
                } elseif { $option == "COMM" } {
                    setProfidriveCommMode
                } elseif { $option == "" } {
                    setProfidriveCommMode     ;# default
                } else {
                    TlError "unknown option: $option (allowed COMP or COMM<default>)"
                    return
                }
                TlPrint "Switch bus interface to ProfiBUS-STD via: cmd_Profidrive_tlxxx AND cmd_PB_PN_common"
                source  "$libpath/cmd_Profidrive_tlxxx.tcl"
                source  "$libpath/cmd_PB_PN_common.tcl"
            } else {
                TlPrint "Switch bus interface to ProfiBUS-STD via : cmd_PBS_PNT_ATLAS.tcl"
                source "$libpath/cmd_PBS_PNT_ATLAS.tcl"
            }
		}
		"CAN" {
			if {![GetSysFeat "ATLAS"]} {
				TlPrint "Switch bus interface to CAN via: cmd_can_ATV_tlxxx"
				source  "$libpath/cmd_can_ATV_tlxxx.tcl"
			} else {
				TlPrint "Switch bus interface to CAN via : cmd_CAN_ATLAS_tlxxx"
				source "$libpath/cmd_can_ATLAS_tlxxx.tcl"
			}
		}
		"ECAT" {
			TlPrint "Switch bus interface to EtherCAT via: cmd_ECAT_H_tlxxx"
			source  "$libpath/cmd_ECAT_H_tlxxx.tcl"
		}
		"MOD" {
			TlPrint "Switch bus interface to Modbus-RS485 with Altivar via: cmd_MOD_ATV_tlxxx"
			source  "$libpath/cmd_MOD_ATV_tlxxx.tcl"
		}
		"MODCAN" {
			TlPrint "Switch bus interface to Modbus-RS485 over CANopen tunnel via: cmd_cantunnel_tlxxx"
			source  "$libpath/cmd_cantunnel_tlxxx.tcl"
		}
		"PN_IO" {
			TlPrint "Switch bus interface to ProfiNET-IO via: cmd_Profinet_tlxxx_io"
			source  "$libpath/cmd_Profinet_tlxxx_io.tcl"
		}
		"PN_STD" {
			if {![GetDevFeat "BusPNV2"] } {
				if { $option == "COMP" } {
					setProfidriveCompMode
				} elseif { ($option == "COMM") || ($option == "") } {
					setProfidriveCommMode
				} else {
					TlError "unknown option: $option (allowed COMP or COMM<default>)"
					return
				}
				TlPrint "Switch bus interface to ProfiNET-STD ( $option ) via: cmd_Profidrive_tlxxx"
				source  "$libpath/cmd_Profidrive_tlxxx.tcl"
			} else {
				TlPrint "Switch bus interface to ProfiNETV2 via: cmd_Profinet_V2_tlxxx.tcl"
				source  "$libpath/cmd_ProfinetV2_tlxxx.tcl"
			}
		}
		"PNV2" - "PNV2_PKW" {
                	if { [GetSysFeat "ATLAS"] } {
                	    TlPrint "Switch bus interface to ProfiNETV2 via: cmd_PBS_PNT_ATLAS.tcl"
			    source "$libpath/cmd_PBS_PNT_ATLAS.tcl"
                	} else {
                	    TlPrint "Switch bus interface to ProfiNETV2 via: cmd_Profinet_V2_tlxxx.tcl"
                	    source  "$libpath/cmd_ProfinetV2_tlxxx.tcl"
                	}
		}
		"PNV2_PNU" {
			TlPrint "Switch bus interface to ProfiNETV2 via: cmd_Profinet_V2_PNU_tlxxx.tcl"
			source  "$libpath/cmd_ProfinetV2_PNU_tlxxx.tcl"
		}
		default {
			TlError "bus interface type not defined: $interface"
		}
	}
}

#DOC--------------------------------------------------------------------------------
# DESCRIPTION
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 030714 ockeg    created
#
#END--------------------------------------------------------------------------------
proc doGetCmdInterface { } {
	global ActInterface
	TlPrint "ActInterface=$ActInterface"
	return $ActInterface
}

#======================================================================
# DOC----------------------------------------------------------------
# DESCRIPTION
#
# return the DevAdr of ActDev for the installed fieldbus
#
# ----------HISTORY----------
# WANN   WER      WAS
# 160114 ockeg    proc created
#
#END----------------------------------------------------------------
proc GetDevAdrFB { } {
	global DevAdr ActDev
	if { [GetDevFeat "BusCAN"] } {
		return $DevAdr($ActDev,CAN)
	} elseif { [GetDevFeat "BusDevNet"] } {
		return $DevAdr($ActDev,DVN)
	} elseif { [GetDevFeat "BusPBdev"] } {
		return $DevAdr($ActDev,SPB)
	} elseif { [GetDevFeat "BusPN"] } {
		return $DevAdr($ActDev,PN)
	} elseif { [GetDevFeat "BusECAT"] } {
		return $DevAdr($ActDev,ECAT)
	} elseif { [GetDevFeat "BusMBTCP"] } {
		return $DevAdr($ActDev,MODTCP)
	} elseif { [GetDevFeat "BusMBTCPioScan"] } {
		return $DevAdr($ActDev,MODTCPioScan)
	} elseif { [GetDevFeat "BusEIP"] } {
		return $DevAdr($ActDev,EIP)
	} else {
		return 0
	}
}

#------------------------------------------------------------
proc ConvertToHz { rpm } {
	#in fact the return value will be in 0.1 Hz
	set PolePairs [doPrintModObject PPN]
	# todet 310316: PPN is now correct for NERA and Fortis,
	# will be fixed in upcomming releases for OPAL, Beidou as well.
	if {![GetDevFeat "Nera"] && ![GetDevFeat "Fortis"] && ![GetDevFeat "Opal"]} {
		set PolePairs [expr $PolePairs/2]   ;# KALA drives report the number of poles in PPN instead of pole pairs
	}
	set frequency [expr int(($rpm / 60.0 * $PolePairs) * 10.0)]
	return $frequency  ;# in 0.1 Hz
}

#------------------------------------------------------------
proc ConvertToRpm { freq } {
	#freq in 0.1 Hz
	set PolePairs [doPrintModObject PPN]
	# todet 310316: PPN is now correct for NERA and Fortis,
	# will be fixed in upcomming releases for OPAL, Beidou as well.
	if {[GetDevFeat "Altivar"]} {
		set PolePairs [expr $PolePairs/2]   ;# KALA drives report the number of poles in PPN instead of pole pairs
	}
	set rpm [expr int($freq / 10.0 * 60.0 / $PolePairs)]
	return $rpm
}

proc NeraDebugStoring {Param Target Act Time Try} {
	global Debug_NERA_Storing_Path
	global COMPUTERNAME Loop
	catch {
		set Testcase "[lindex [info level -2] 0];[lindex [info level -3] 0];[lindex [info level -4] 0]"
		set Path "$Debug_NERA_Storing_Path/$COMPUTERNAME Run$Loop.csv"
		set fipo [open $Path a+]
		puts $fipo "$Param;$Time;$Try;$Target;$Act;$Testcase;[clock format [clock seconds] -format %d.%m.%Y] [clock format [clock seconds] -format %H:%M:%S]"
		close $fipo
	}
}

proc NeraEvaluateStoringCSV { Folder { Param "EEPS" } } {
	while {[gets $fipo line] > -1} {
		set line [split $line ";"]
		if {[lindex $line 0] == $Param} {
			lappend Times [lindex $line 1]
			incr average [lindex $line 1]
		}
		set File "Evaluation_$Param.csv"
		set Filename "$Folder$File"
		set rc [catch { set fipo [open "$Filename" w+]}]
		if {$rc != 0} {
			TlError "File not opened ($Filename)"
			return 0
		}
		puts $fipo "Evaluation of waittimes for Parameter $Param"
		puts $fipo "PC;Run;Time Min;Time Average;Time Max;Too low;OK;Too high"
		foreach File [glob -nocomplain -type {f  r} -path $Folder *] {
			if {[lindex [split $File "."] end] == "csv"} {
				if {[string first "Evaluation" $File] != -1} {continue}
				set result [NeraReadStoringCSV "$File" $Param]
				set line ""
				foreach element $result {
					set line "$line;$element"
				}
				puts $fipo [string range $line 1 end]
			}
		}
		close $fipo
	}
}

proc NeraReadStoringCSV { Filename { Param "EEPS" }}  {
	foreach Time $Times {
		if {$Time < $BorderMin} {
			incr below
		} elseif {$Time > $BorderMax} {
			incr above
		} else {
			incr inside
		}
	}
	if {[llength $Times] > 0} {
		set PercentBelow [expr int(100.0*$below.0/[llength $Times].0)]
		set PercentAbove [expr int(100.0*$above.0/[llength $Times].0)]
		set PercentInside [expr int(100.0*$inside.0/[llength $Times].0)]
	} else {
		set PercentBelow 0
		set PercentAbove 0
		set PercentInside 0
	}
	set rc [catch { set fipo [open "$Filename" r]}]
	if {$rc != 0} {
		TlError "File not opened ($Filename)"
		return 0
	}
	set File [lindex [split $Filename "/" ] end ]
	set Run [lindex [split $File " " ] 1]
	set Run [lindex [split $Run "." ] 0]
	set PC [lindex [split $File " " ] 0]
	#if {$Run == ""} {return}
	set Times {}
	set average 0
	while {[gets $fipo line] > -1} {
		set line [split $line ";"]
		if {[lindex $line 0] == $Param} {
			lappend Times [lindex $line 1]
			incr average [lindex $line 1]
		}
	}
	close $fipo
	set Times [lsort -integer $Times]
	if {[llength $Times] > 0} {
		set average [expr $average / [llength $Times]]
	} else {
		set average 0
	}
	set TimeMin [lindex $Times 0]
	set TimeMax [lindex $Times end]
	set BorderMin [expr int($average.0 * 0.5)]
	set BorderMax [expr int($average.0 * 2.0)]
	set below 0
	set inside 0
	set above 0
	foreach Time $Times {
		if {$Time < $BorderMin} {
			incr below
		} elseif {$Time > $BorderMax} {
			incr above
		} else {
			incr inside
		}
	}
	if {[llength $Times] > 0} {
		set PercentBelow [expr int(100.0*$below.0/[llength $Times].0)]
		set PercentAbove [expr int(100.0*$above.0/[llength $Times].0)]
		set PercentInside [expr int(100.0*$inside.0/[llength $Times].0)]
	} else {
		set PercentBelow 0
		set PercentAbove 0
		set PercentInside 0
	}
	TlPrint ""
	TlPrint "#################################################"
	TlPrint "File $File"
	TlPrint "PC $PC"
	TlPrint "Run $Run"
	TlPrint "Parameter $Param"
	TlPrint "-------------------------------------------------"
	TlPrint "Count  : [llength $Times]"
	TlPrint "Min    : $TimeMin ms"
	TlPrint "Average: $average ms"
	TlPrint "Max    : $TimeMax ms"
	TlPrint "-------------------------------------------------"
	TlPrint "Below $BorderMin ms: $below ($PercentBelow%)"
	TlPrint "Above $BorderMax ms: $above ($PercentAbove%)"
	TlPrint "Inside borders: $inside ($PercentInside%)"
	TlPrint "#################################################"
	return [list $PC $Run $TimeMin $average $TimeMax $below $inside $above]
}

proc PingIP {IP {Trys 1} {NoError 0} {NoPrint 0}} {
	set result 0
	# todet 010814:
	# Sporadic the script was freezing, if 'ping' was started with 'exec' command.
	# Probably Windows is changing the CPU affinity of 'ping' during its execution
	# 'exec' might have some problems with this behavior, no longer beeing able
	# to catch the end of 'ping' process and then waiting forever.
	#
	# solution: start 'ping' as IO stream using the 'open' command.
	# then read the output of the stream until the process terminates.
	# The termination of the process can be evaluated by checking for "End of file" (eof) on the
	# stream
	# This can be done with a timeout, so even if the process is freezing or the channel gets invalid
	# the script will continue afterwards.
	# If in blocking mode, the 'close' command on the channel will determine, whether the 'ping'
	# was executed successfull (answer) or not successfull (no answer).
	# This is not working in non-blocking mode, so search the Output stream of Ping for a line that
	# contains the string "Reply from xxx.xxx.xxx.xxx:"
	if {[GetSysFeat "MVKTower1"]||[GetSysFeat "MVKTower2"]} {
		set rc [catch {set result [exec ping -n $Trys -w 250 $IP]}]
		if {$rc != 0} {
			if {$NoError} {
				if {$NoPrint == 0} {
					TlPrint "No answer from $IP"
				}
			} else {
				TlError "No answer from $IP"
			}
			return 0
		} else {
			if {$NoPrint == 0} {
				set result [split $result "\n"]
				foreach line $result {
					if {$line != ""} {TlPrint $line}
				}
			}
			doWaitMs 30000
			return 1
		}
	} else {
		set rc [catch {set result [open "|ping -n $Trys -w 250 $IP" r]}]
		if {$rc == 0} {
			fconfigure $result -translation binary
			# use non-blocking mode while checking for end of ping.exe
			# otherwise script will blok on 'read' command
			fconfigure $result -blocking 0
			set Output ""
			set startTime [clock clicks -milliseconds]
			while {![eof $result]} {
				# wait a maximum of 1 second per try
				if {[expr [clock clicks -milliseconds] - $startTime] > [expr $Trys * 1000]} {break}
				lappend Output [read $result]
				#after 10
			}
			set Output [join $Output]
			set rc [catch {close $result}]
			# check whether 'ping' was executed successfully or not
			if {([string first "Reply from $IP:" $Output] == -1) && ([string first "Antwort von $IP:" $Output] == -1) && ([string first "ponse de $IP" $Output] == -1)} {
				if {$NoError} {
					if {$NoPrint == 0} {
						TlPrint "No answer from $IP"
					}
				} else {
					TlError "No answer from $IP"
				}
				return 0
			} else {
				return 1
			}
		} else {
			TlError "Not able to execute Ping command"
		}
	}
}

proc doWaitForPing {IP Timeout {ErrorInfo 1} {show_status 1} {TTId ""}} {
	set startZeit [clock clicks -milliseconds]
	set trys 0
	set TTId [Format_TTId $TTId]
	TlPrint "Wait for Ping response of $IP"
	while {1} {
		#after 1   ;# wait 1 mS
		#update idletasks
		doWaitMsSilent 500
		set result [PingIP $IP 1 1 1]
		incr trys
		if {$result} {
			TlPrint  "Answer from $IP after [expr [clock clicks -milliseconds] - $startZeit]ms ($trys trys)"
			return 1
		}
		if {[expr ([clock clicks -milliseconds] - $startZeit)  >= $Timeout] } {
			if {$ErrorInfo} {
				TlError  "$TTId No answer from IP=$IP after t=[expr [clock clicks -milliseconds] - $startZeit]ms ($trys trys)"
				if { $show_status } { ShowStatus }
			} else {
				TlPrint  "No answer from $IP after [expr [clock clicks -milliseconds] - $startZeit]ms ($trys trys)"
			}
			return 0
		}
		if {[CheckBreak]} {return 0}
	}
}

proc writeIpOpt {IP Mask Gate} {
	global ActDev DevAdr
	set IP [split $IP "."]
	set Mask [split $Mask "."]
	set Gate [split $Gate "."]
	set LogAdr [Param_Index "IPC1"]
	set IPC [format "%04X%04X%04X%04X" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%04X%04X%04X%04X" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%04X%04X%04X%04X" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	set sendstring [format "%02X10%04X000C18%s%s%s" $DevAdr($ActDev,MOD) $LogAdr $IPC $IPM $IPG]
	set IPC [format "%03d.%03d.%03d.%03d" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%03d.%03d.%03d.%03d" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%03d.%03d.%03d.%03d" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	set rc [catch { set result [mbDirect $sendstring 1]}]
	TlPrint "sent    : $sendstring"
	TlPrint "          FC16 Write   |      IPCx     |      IPMx     |      IPGx     |"
	TlPrint "          12 Register  |$IPC|$IPM|$IPG|"
	TlPrint ""
	if {$rc != 0} {
		TlError "Failed to write IP Address, no answer"
	} else {
		TlPrint "received: $result"
		if {[string range $result 2 3] != "10"} {
			TlError "Failed to write IP Address, ModBus exception: 0x[string range $result 4 5]"
		} else {
			doWaitMs 10000
		}
	}
}

proc writeIpAdv {IP Mask Gate {Init 0}} {
	global ActDev DevAdr
	set IP [split $IP "."]
	set Mask [split $Mask "."]
	set Gate [split $Gate "."]
	if { $Init == 1 } {
		set LogAdr [Param_Index "IM10"]
	} else {
		set LogAdr [Param_Index "IC11"]
	}
	set IPC [format "%04X%04X%04X%04X" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%04X%04X%04X%04X" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%04X%04X%04X%04X" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	if { $Init == 1 } {
		set sendstring [format "%02X10%04X000D1A%04X%s%s%s" $DevAdr($ActDev,MOD) $LogAdr [Enum_Value IM10 MANU] $IPC $IPM $IPG]
	} else {
		set sendstring [format "%02X10%04X000C18%s%s%s" $DevAdr($ActDev,MOD) $LogAdr $IPC $IPM $IPG]
	}
	set IPC [format "%03d.%03d.%03d.%03d" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%03d.%03d.%03d.%03d" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%03d.%03d.%03d.%03d" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	set rc [catch { set result [mbDirect $sendstring 1]}]
	TlPrint "sent    : $sendstring"
	if { $Init == 1 } {
		TlPrint "          FC16 Write   |IM10|      IC1x     |      IM1x     |      IG1x     |"
		TlPrint "          13 Register  |MANU|$IPC|$IPM|$IPG|"
	} else {
		TlPrint "          FC16 Write   |      IC1x     |      IM1x     |      IG1x     |"
		TlPrint "          12 Register  |$IPC|$IPM|$IPG|"
	}
	TlPrint ""
	if {$rc != 0} {
		TlError "Failed to write IP Address, no answer"
	} else {
		TlPrint "received: $result"
		if {[string range $result 2 3] != "10"} {
			TlError "Failed to write IP Address, ModBus exception: 0x[string range $result 4 5]"
		} else {
			doWaitMs 3000
		}
	}
}

proc writeIpBas {IP Mask Gate {Init 0}} {
	global ActDev DevAdr
	set IP [split $IP "."]
	set Mask [split $Mask "."]
	set Gate [split $Gate "."]
	doWaitMs 2000
	if {$Init ==1 } {
		set LogAdr [Param_Index "IM00"]
	} else {
		set LogAdr [Param_Index "IC01"]
	}
	set IPC [format "%04X%04X%04X%04X" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%04X%04X%04X%04X" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%04X%04X%04X%04X" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	if {$Init == 1 } {
		set sendstring [format "%02X10%04X000D1A%04X%s%s%s" $DevAdr($ActDev,MOD) $LogAdr [Enum_Value IM00 MANU] $IPC $IPM $IPG]
	} else {
		set sendstring [format "%02X10%04X000C18%s%s%s" $DevAdr($ActDev,MOD) $LogAdr $IPC $IPM $IPG]
	}
	set IPC [format "%03d.%03d.%03d.%03d" [lindex $IP 0] [lindex $IP 1] [lindex $IP 2] [lindex $IP 3]]
	set IPM [format "%03d.%03d.%03d.%03d" [lindex $Mask 0] [lindex $Mask 1] [lindex $Mask 2] [lindex $Mask 3]]
	set IPG [format "%03d.%03d.%03d.%03d" [lindex $Gate 0] [lindex $Gate 1] [lindex $Gate 2] [lindex $Gate 3]]
	set rc [catch { set result [mbDirect $sendstring 1]}]
	TlPrint "sent    : $sendstring"
	if {$Init == 1 } {
		TlPrint "          FC16 Write   |IM00|      IC0x     |      IM0x     |      IG0x     |"
		TlPrint "          12 Register  |MANU|$IPC|$IPM|$IPG|"
	} else {
		TlPrint "          FC16 Write   |      IC0x     |      IM0x     |      IG0x     |"
		TlPrint "          12 Register  |$IPC|$IPM|$IPG|"
	}
	TlPrint ""
	if {$rc != 0} {
		TlError "Failed to write IP Address, no answer"
	} else {
		TlPrint "received: $result"
		if {[string range $result 2 3] != "10"} {
			TlError "Failed to write IP Address, ModBus exception: 0x[string range $result 4 5]"
		} else {
			doWaitMs 3000
		}
	}
}

proc writeAppName {Name} {
	global ActDev DevAdr
	TlPrint ""
	TlPrint "Write ProductApplicationName '$Name' in PANx Registers"
	set LogAdr [Param_Index "PAN0"]
	# split into chars
	set Name [split $Name {}]
	# convert chars to hex-string
	set UserAppNameASCII ""
	foreach char $Name {
		set UserAppNameASCII [format "%s%s" $UserAppNameASCII [format %02X [scan $char %c]]]
	}
	# fill with zeros
	set UserAppNameASCIIchars [string length $UserAppNameASCII]
	if {$UserAppNameASCIIchars < 28} {
		set UserAppNameASCII [format "%s%0[expr 28 - $UserAppNameASCIIchars]d" $UserAppNameASCII 0]
	}
	# write hex values to PANx
	set sendstring [format "%02X10%04X00070E%s" $DevAdr($ActDev,MOD) $LogAdr $UserAppNameASCII]
	set rc [catch { set result [mbDirect $sendstring 1]}]
	TlPrint "sended  : $sendstring"
	TlPrint "          FC16 Write   |$Name"
	TlPrint ""
	if {$rc != 0} {
		TlError "Failed to write IP Address, no answer"
	} else {
		TlPrint "received: $result"
		if {[string range $result 2 3] != "10"} {
			TlError "Failed to write PAN, ModBus exception: 0x[string range $result 4 5]"
		}
	}
}

#======================================================================
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set value of resistor for AIx
# All combinations and mask for resistor values are for 2wires "2W" and 3wires "3W":
#      134   0xFC  84 0x3C
#      139   0xF8  89 0x38
#      144   0xF4  94 0x34
#      149   0xF0  99 0x30
#      188   0xEC  138   0x2C
#      198   0xE8  148   0x28
#      208   0xE4  158   0x24
#      220   0xE0  170   0x20
#      347   0xDC  297   0x1C
#      380   0xD8  330   0x18
#      420   0xD4  370   0x14
#      470   0xD0  420   0x10
#      1333  0xCC  1283  0xC
#      2000  0xC8  1950  0x8
#      4000  0xC4  3950  0x4
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 130314 serio    proc created
# 140414 serio    add print for log
# 170714 serio	   move function to util / check at beginning if tower compatible / add return value
# 230715 serio    adapt to integrated inputs
#
#END----------------------------------------------------------------
proc SetResistorNetworkAIx { input resistor wires } {
    if { [GetDevFeat "Modul_IO_R" ] } {
	set list_2wires_resistors {134 139 144 149 188 198 208 220 347 380 420 470 1329 1333 2000 4000}
	set list_2wires_masks {0xFC 0xF8 0xF4 0xF0 0xEC 0xE8 0xE4 0xE0 0xDC 0xD8 0xD4 0xD0 0xCC 0xCC 0xC8 0xC4}
	set list_3wires_resistors {84 89 94 99 138 148 158 170 297 330 370 420 1283 1950 1970 3950}
	set list_3wires_masks {0x3C 0x38 0x34 0x30 0x2C 0x28 0x24 0x20 0x1C 0x18 0x14 0x10 0xC 0x8 0x8 0x4}
	switch $wires {
	    "2W" {
		set list_resistors $list_2wires_resistors
		set list_masks $list_2wires_masks
	    }
	    "3W" {
		set list_resistors $list_3wires_resistors
		set list_masks $list_3wires_masks
	    }
	    default {
		TlError "Wire mode should be 2W or 3W"
		return 0
	    }
	}
	set index [lsearch $list_resistors $resistor]
	if {$index != -1 } {
	    set bitmask [lindex $list_masks $index]
	} else {
	    TlError "value of resistor : $resistor not configurable, please refer to doc"
	    return 0
	}
	#wago bit for switching between input4 and 5 is on bit position 0
	switch $input {
	    "4" {set bitmask [expr $bitmask & 0xFE] }
	    "5" {set bitmask [expr $bitmask | 0x1] }
	    default {
		TlError "AI$input not supported"
		return 0
	    }
	}
	#reset all bits before setting the new mask :
	wc_SetDigital 12 0xFF L
	doWaitMsSilent 20
	wc_SetDigital 12 $bitmask H
	TlPrint "Set resistor $resistor ohm on input $input"
	doWaitMs 300
	return $resistor
    } else {
	TlError "Tower not supported for the setting of resistor value of AI$input"
    }
}

#======================================================================
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Set default value of resistor for AIx in order to be fault free in thermal mode
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 130314 serio    proc created
# 170714 serio	   move function to util / check at beginning if tower compatible / add return value
# 230715 serio    adapt to integrated inputs
#
#END----------------------------------------------------------------
proc SetGoodResistorAIx { input mode } {
	if { [GetDevFeat "Modul_IO_R" ] } {
		switch $mode {
			"1PT2" {
				set resistor 139
				set wires "2W"
			}
			"PTC" -
			"KTY" -
			"1PT3" {
				set resistor 1333
				set wires "2W"
			}
			"3PT2" {
				set resistor 420
				set wires "2W"
			}
			"3PT3" {
				set resistor 4000
				set wires "2W"
			}
			"1PT23" {
				set resistor 138
				set wires "3W"
			}
			"1PT33" {
				set resistor 1283
				set wires "3W"
			}
			"3PT23" {
				set resistor 420
				set wires "3W"
			}
			"3PT33" {
				set resistor 3950
				set wires "3W"
			}
			default {
				TlError "$mode not supported as thermal sensor"
				return 0
			}
		}
		return [SetResistorNetworkAIx $input $resistor $wires]
	} else {
		TlError "Tower not supported for the setting of resistor value of AI$input"
	}
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Printout the current priority of the Interpreter
# PRECONDITIONS: - library twapi is existing on the local machine
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 171014 gelbg Proc created
#END------------------------------------------------------------------------------------------------
proc GetPrio {} {
	if { [catch "package require twapi_process" Msg] } {

		TlError " #info:GetPrio: Execution failed due to: $Msg"
		return
	}
	global PrioDef
	set PID [twapi::get_current_process_id]
	set PrioClass [twapi::get_priority_class $PID]
	switch $PrioClass {
		256 {
			TlPrint "GetPrio: Current PriorityClass: Realtime"
		}
		128 {
			TlPrint "GetPrio: Current PriorityClass: High"
		}
		32768 {
			TlPrint "GetPrio: Current PriorityClass: AboveNormal"
		}
		32 {
			TlPrint "GetPrio: Current PriorityClass: Normal"
		}
		16384 {
			TlPrint "GetPrio: Current PriorityClass: BelowNormal"
		}
		64 {
			TlPrint "GetPrio: Current PriorityClass: Low"
		}
		default { }
	}
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Set the priority of the Interpreter
# PRECONDITIONS: - library twapi is existing on the local machine
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 171014 gelbg Proc created
#END------------------------------------------------------------------------------------------------
proc SetPrio { {PrioClass "High"} } {
	if { [catch "package require twapi_process" Msg] } {

		TlError " #info:GetPrio: Execution failed due to: $Msg"
		return
	}
	global PrioDef
	set PID [twapi::get_current_process_id]
	switch $PrioClass {
		"Realtime" {
			twapi::set_priority_class $PID $PrioDef(Realtime)
			TlPrint "SetPrio: PriorityClass: Realtime"
		}
		"High" {
			twapi::set_priority_class $PID $PrioDef(High)
			TlPrint "SetPrio: PriorityClass: High"
		}
		"AboveNormal" {
			twapi::set_priority_class $PID $PrioDef(AboveNormal)
			TlPrint "SetPrio: PriorityClass: AboveNormal"
		}
		"Normal" {
			twapi::set_priority_class $PID $PrioDef(Normal)
			TlPrint "SetPrio: PriorityClass: Normal"
		}
		"BelowNormal" {
			twapi::set_priority_class $PID $PrioDef(BelowNormal)
			TlPrint "SetPrio: PriorityClass: BelowNormal"
		}
		"Low" {
			twapi::set_priority_class $PID $PrioDef(Low)
			TlPrint "SetPrio: PriorityClass: Low"
		}
		default {
			TlError "SetPrio: Wrong param! Choose: Realtime, High, AboveNormal, Normal, BelowNormal, Low"
		}
	}
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Unassign all previous functions to the designated logical input
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 171214 serio Proc created
# 260115 serio base on list of param values
# 170315 serio add case for Nera
#END------------------------------------------------------------------------------------------------
proc UnassignLIx {input} {
	#define generic names
	append LIx LI $input
	append LxL L $input L
	#define list of functions that can be assigned and list of parameters names for the assignment
	set AssignmentList { LIRUN LIFRD LIRRS LIRPS LIJOG LIUSP LIDSP LIPS2 LIPS4 LIPS8 LIRFC LINST LIDCI LIFST LIFLO LIRSF LITUL LISPM LIFLI LIPAU LIPIS LIPR2 LIPR4 LITLA LIETF LICNF1 LICNF2 LICHA1 LICHA2 LITLC LITSS LITSD LICCS LIINH LIPS16 LILC2 LILAF LILAR LIRCB LIBCI LISAF LISAR LIDAF LIDAR LICLS LILES LIRPA LISH2 LISH4 IDLS R1 R2 R3 R4 R5 R6 DO1 DO11 DO12 FNJOG FNPS1 FNPS2 FNPR1 FNPR2 FNUSP NDSP LIUSI LIDSI LITRI }
	if {[GetDevFeat "Fortis"]} {
		set ParameterList { RUN FRD RRS RPS JOG USP DSP PS2 PS4 PS8 RFC NST DCI FST FLO RSF TUL SPM FLI PAU PIS PR2 PR4 TLA ETF CNF1 CNF2 CHA1 CHA2 TLC TSS TSD CCS INH PS16 LC2 LAF LAR RCB BCI SAF SAR DAF DAR CLS LES RPA SH2 SH4 IDLS R1 R2 R3 R4 R5 R6 DO1 DO11 DO12 FJOG FPS1 FPS2 FPR1 FPR2 FUSP FDSP USI DSI TRI }
	} elseif {[GetDevFeat "MVK"]} {
		set ParameterList { RUN FRD RRS RPS JOG USP DSP PS2 PS4 PS8 RFC NST FLO RSF TUL SPM FLI PAU PIS PR2 PR4 TLA ETF CNF1 CNF2 CHA1 CHA2 TLC TSS TSD CCS INH PS16 LC2 RCB BCI RPA R1 R2 R3 R4 R5 R6 DO1 DO11 DO12 USI DSI TRI }
	} elseif {[GetDevFeat "Opal"] } {
		set ParameterList { RUN FRD RRS RPS JOG USP DSP PS2 PS4 PS8 RFC NST DCI FST FLO RSF TUL SPM FLI PAU PIS PR2 PR4 TLA ETF CNF1 CNF2 CHA1 CHA2 TLC TSS TSD CCS INH PS16 LC2 LAF LAR RCB BCI SAF SAR DAF DAR CLS LES RPA SH2 SH4 R1 R2 R4 R5 R6 DO1 DO11 DO12 FJOG FPS1 FPS2 FPR1 FPR2 FUSP FDSP USI DSI TRI }
	} elseif {[GetDevFeat "Nera"] } {
		set ParameterList { RUN FRD RRS RPS USP DSP PS2 PS4 PS8 RFC NST DCI FST FLO RSF TUL PAU PIS PR2 PR4 TLA ETF CHA1 CHA2 CCS INH PS16 RCB LES RPA IDLS R1 R2 R3 R4 R5 R6 DO11 DO12 FPS1 FPS2 FPR1 FPR2 FUSP FDSP VSP OPPW SLPW PFEC JETC DRYW PLFW PPWA MPI1 MPI2 MPI3 MPI4 MPI5 MPI6 LCW1 LCW2 LCW3 LCW4 LCW5 LCW6 LCWL LCWH  }
	} elseif {[GetDevFeat "K2"] } {
		set ParameterList { RUN FRD RRS RPS USP DSP PS2 PS4 PS8 RFC NST DCI FST FLO RSF TUL PAU PIS PR2 PR4 TLA ETF CHA1 CHA2 CCS INH PS16 RCB LES RPA IDLS R1 R2 R3 R4 R5 R6 DO11 DO12 FPS1 FPS2 FPR1 FPR2 FUSP FDSP OPPW SLPW DRYW PLFW MPI1 MPI2 MPI3 MPI4 MPI5 MPI6 RPCO RPI1 RPI2 THWA}
	}
	foreach param $ParameterList {
		if { [Enum_Name $param [TlRead $param]] == $LIx || [Enum_Name $param [TlRead $param]] == $LxL } {
			set CHCF [ Enum_Name CHCF [TlRead CHCF]]
			set TCC [ Enum_Name TCC [TlRead TCC]]
			switch $param {
				RUN {
					if { $CHCF == "IO" } {
						if {$TCC == "3C" } {
							set noparam CD00
						} else {
							set noparam NO
						}
					} else {
						if {$TCC == "3C" } {
							set noparam LI1
						} else {
							set noparam NO
						}
					}
				}
				FRD {
					if { $CHCF == "IO" } {
						if {$TCC == "2C" } {
							set noparam CD00
						} elseif {$TCC == "3C" } {
							set noparam CD01
						} else {
							set noparam NO
						}
					} else {
						if {$TCC == "2C" } {
							set noparam LI1
						} elseif {$TCC == "3C"} {
							set noparam LI2
						} else  {
							set noparam NO
						}
					}
				}
				RCB -
				RFC {
					set noparam FR1
				}
				TLC {
					set noparam YES
				}
				CCS {
					set noparam CD1
				}
				TRI {
					set noparam TR1
				}
				default {
					set noparam NO
				}
			}
			TlWrite $param .$noparam
			doWaitForObject $param .$noparam 1
		}
	}
	#   while { [Enum_Name $LxH [TlRead $LxH]] != NO } {
	#
	#      #find index from first list to assign parameter from second list to NO
	#
	#      set tempindex  [lsearch $AssignmentList [Enum_Name $LxH [TlRead $LxH]]]
	#      set tempparam [lindex $ParameterList $tempindex]
	#
	#      TlWrite $tempparam .NO
	#      doWaitForObject $tempparam .NO 1
	#
	#   }
	#
	#   while { [Enum_Name $LxL [TlRead $LxL]] != NO } {
	#
	#      #find index from first list to assign parameter from second list to NO
	#
	#      set tempindex  [lsearch $AssignmentList [Enum_Name $LxL [TlRead $LxL]]]
	#      set tempparam [lindex $ParameterList $tempindex]
	#
	#      TlWrite $tempparam .NO
	#      doWaitForObject $tempparam .NO 1
	#
	#   }
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Assign all listed functions and states to the designated logical input
# procedure parameters are the following
# input : number of the LI concerned
# FunctionsList : list of functions to assign to the desired LI
# example : AssignLIx 1 {PAR1 PAR2 PAR3}
# StatesList : optional list of states for which the function should be active H : active one high, L
# : active on low
# example : AssignLIx 1 {PAR1 PAR2 PAR3} {H L H}
# A single parameter can be given when wanting to assign with just one function on state high :
# example : AssignLIx 1 PAR1
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 171214 serio Proc created
# 270415 serio Add TTId parameter
#END------------------------------------------------------------------------------------------------
proc AssignLIx {input FunctionsList {StatesList ""} {TTId ""} } {
	#unassign first all values
	UnassignLIx $input
	#define generic names
	append LIx LI $input
	append LxL L $input L
	#define how many Functions to be assigned
	set maxindex [llength $FunctionsList]
	#set a loop to assign all functions with the logical input
	for {set i 0} {$i < $maxindex} {incr i} {
		# assign tempnames
		set tempparam [lindex $FunctionsList $i]
		set tempstate [lindex $StatesList $i]
		switch $tempstate {
			"L" {
				TlWrite $tempparam .$LxL
				doWaitForObject $tempparam .$LxL 1 0xffffffff $TTId
			}
			"H" -
			default {
				TlWrite $tempparam .$LIx
				doWaitForObject $tempparam .$LIx 1 0xffffffff $TTId
			}
		}
	}
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Procedure to set time in device.
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 040315 weiss proc created
#END------------------------------------------------------------------------------------------------
proc ATVSetTime {Year Month Day Hour Minute Ms } {
	TlPrint "Write time to device: [format "%02d/%02d/%02d %02d:%02d:%02d:%03d" $Day $Month $Year $Hour $Minute \
   [expr $Ms / 1000] [expr $Ms % 1000]]"
	set Frame [format "0000%02X%02X%02X%02X%02X%04X" $Year $Month $Day $Hour $Minute $Ms]
	FC43SendReceive 0x10 $Frame
};#ATVSetTime

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Procedure to get time from device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 040315 weiss proc created
#END------------------------------------------------------------------------------------------------
proc ATVGetTime { } {
	set Frame "0044"
	set RxFrame [FC43SendReceive 0x0F $Frame]
	set HexaValueYear  "0x[string range $RxFrame 8 9]"
	set  actualValueYear [expr $HexaValueYear]
	set HexaValueMonth  "0x[string range $RxFrame 10 11]"
	set  actualValueMonth [expr $HexaValueMonth]
	set HexaValueDay  "0x[string range $RxFrame 12 13]"
	set  actualValueDay [expr $HexaValueDay & 0x001F ]
	set HexaValueHour  "0x[string range $RxFrame 14 15]"
	set  actualValueHour [expr $HexaValueHour]
	set HexaValueMinute "0x[string range $RxFrame 16 17]"
	set  actualValueMinute [expr $HexaValueMinute]
	set HexaValueMs "0x[string range $RxFrame 18 21]"
	set  actualValueMs [expr $HexaValueMs]
	set result [format "%02d/%02d/%02d %02d:%02d:%02d:%03d" $actualValueDay $actualValueMonth $actualValueYear \
		$actualValueHour $actualValueMinute [expr $actualValueMs / 1000] [expr $actualValueMs % 1000]]
	TlPrint "Read time from device: $result"
	return $result
};#ATVGetTime

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Procedure to write actual time in device.
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 040315 weiss proc created
#END------------------------------------------------------------------------------------------------
proc ATVSetTimeActual {} {
	scan [clock format [clock seconds] -format %y] "%u" "Year"
	scan [clock format [clock seconds] -format %m] "%u" "Month"
	scan [clock format [clock seconds] -format %d] "%u" "Day"
	scan [clock format [clock seconds] -format %H] "%u" "Hour"
	scan [clock format [clock seconds] -format %M] "%u" "Minute"
	scan [clock format [clock seconds] -format %S] "%u" "Sec"
	TlPrint "Write actual time to device: [format "%02d/%02d/%02d %02d:%02d:%02d" $Day $Month \
   $Year $Hour $Minute $Sec]"
	set Frame [format "0000%02X%02X%02X%02X%02X%04X" $Year $Month $Day $Hour $Minute [expr $Sec*1000]]
	FC43SendReceive 0x10 $Frame
};#ATVSetTime

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Set Parameter BitMask to value with other bits remaining the same
# arguments
# object : string, the parameter name
# mask : hex, the mask for bits to be set at value
# value : 0 or 1, value to set bits from mask
# timeout :dec in s,allowed time until object changes
# mdb : 0 or 1, if set to 1 force to use modbus channel, default 1
# TTId : reference to a GEDEC if necessary
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 020415 serio    Proc created
# 070415 serio    correction : ~ instead of ^
# 060224 Yahya	  Added TTId parameter to set reference to GEDEC if there is any to mention (Issue #1690)
#END------------------------------------------------------------------------------------------------
proc doChangeMask {object mask value {timeout 1} {mdb 1} {TTId ""} } {
	if { $mdb == 1 } {
		set object0 [ModTlRead $object]
	} elseif {$mdb == 0} {
		set object0 [TlRead $object]
	} else {
		TlError "last argument mdb shoud be 0 or 1 but is : $mdb"
		return
	}
	if {$value == 0 } {
		set object1 [expr ~$mask & $object0]
	} elseif { $value == 1 } {
		set object1 [expr $mask | $object0]
	} else {
		TlError "argument value shoud be 0 or 1 but is : $value"
		return
	}
	if { $mdb == 1 } {
		ModTlWrite $object $object1
		doWaitForModObject $object $object1 $timeout 0xffffffff $TTId
	} else {
		TlWrite $object $object1
		doWaitForObject $object $object1 $timeout 0xffffffff $TTId
	}
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Returns for the parameter its Index, Subindex und Datentyp
# Bsp1:
#   set Address [getIndex MOTION.UPRAMP0]   ;#-> liefert "6 10 4"
#   set idx  [lindex $Address 0]   ;# index 6
#   set six  [lindex $Address 1]   ;# subindex 10
#   set data [lindex $Address 2]   ;# datalength 4
# Bsp2:
#   set Address [getIndex 6.10]             ;#-> liefert "6 10 4"
#   set idx  [lindex $Address 0]   ;# index 6
#   set six  [lindex $Address 1]   ;# subindex 10
#   set data [lindex $Address 2]   ;# datalength 4
#----------------------------------------------------------------------------
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 080615 serio proc created
#END------------------------------------------------------------------------------------------------
proc getIndex {objString} {
	global theLXMObjDataTyptable theLXMObjHashtable theLXMVARHashtable errorInfo
	if {[regexp {0x6*} $objString] || [regexp {0x1*} $objString]} {
		# format to number, z.B. "0x6040.0"
		set objList [split $objString .]
		set idx [lindex $objList 0]
		set six [lindex $objList 1]
	} elseif [regexp {[0-9]+\.[0-9]+} $objString] {
		# format to number, z.B. "11.9"
		set objList [split $objString .]
		set idx [lindex $objList 0]
		set six [lindex $objList 1]
	} else {
		if { [string match "*_*" $objString] } {
			# Change of objstring with Hashtable in Index/SubIndex
			if { [catch { set index $theLXMVARHashtable($objString) }]  != 0 } {
				TlError "TCL-Fehlermeldung: $errorInfo : Objekt: $objString"
				return 0
			}
		} else {
			# Change of objstring with Hashtable in Index/SubIndex
			if { [catch { set index $theLXMObjHashtable($objString) }]  != 0 } {
				TlError "TCL-Fehlermeldung: $errorInfo : Objekt: $objString"
				return 0
			}
		}
		set idx [lindex [split $index .] 0]
		set six [lindex [split $index .] 1]
	}
	set DataLength 0
	catch {set DataLength $theLXMObjDataTyptable($idx.$six)}
	if {$DataLength == 0 } {
		if { $idx <= 127 } {
			# type of data is only important for user parameters
			# all parameters > 127 will be ruled by Peek/Poke access
			TlPrint "getIndex: Obj=$objString unbekannte Datenlaenge, Annahme 4 Bytes"
			#no TlError, since we want to address a non existant onject as well
			#the proc TlRead should return the fault, not getIndex
		}
		set DataLength 4
	}
	return "$idx $six $DataLength"
} ;# getIndex

proc CopyEthernetSlotCConfigFile { } {
	global mainpath
	set ConfigFilePath "Proc:/Mod/Conf/C/ADV/IPCL/Config.eth"
	set MD5FilePath "Proc:/Mod/Conf/C/ADV/IPCL/Config.sig"
	package require md5

	#open IPCLConfig File
	set FileName "$mainpath/ObjektDB/IPCLConfig.eth"
	if { [file exists $FileName] == 1 } {
		TlPrint "**** Open file: $FileName"
		set File [open $FileName r]
		fconfigure $File -translation binary -encoding binary
		while { ! [eof $File] } {
			set line [gets $File]
			append EthConfigData $line
		}
		TlPrint "**** Close file: $FileName"
		close $File
		#Data from IPCLConfigFile
		set EthIPCLConfigHexData [str2hex $EthConfigData ]
	}
	#TlPrint $EthIPCLConfigHexData
	set ConfigDataNew [string range $EthIPCLConfigHexData 5336 5532]
	#	TlPrint $ConfigDataNew
	#Take the current ethernet config File
	if {[FileManagerOpenSession]} {
		set EthConfigHexData [FileManagerGetFile $ConfigFilePath 0 5]
		# replace config data of original file with new data
		set EthConfigHexData [string replace $EthConfigHexData 5342 5538 $ConfigDataNew]
		#calculation of CRC
		set EthConfigHeader [string range $EthConfigHexData 0 111]
		set EthConfigData [string range $EthConfigHexData 112 end]
		set CRC [format %08X [GetCrc32 $EthConfigData]]
		# replace CRC in original header
		# CRC is located in bytes 24..27
		set EthConfigHeader [string replace $EthConfigHeader 48 49 [string range $CRC 6 7]]
		set EthConfigHeader [string replace $EthConfigHeader 50 51 [string range $CRC 4 5]]
		set EthConfigHeader [string replace $EthConfigHeader 52 53 [string range $CRC 2 3]]
		set EthConfigHeader [string replace $EthConfigHeader 54 55 [string range $CRC 0 1]]
		# build new file from header and data
		set EthConfigHexData ""
		append EthConfigHexData $EthConfigHeader
		append EthConfigHexData $EthConfigData
		# calculate MD5 checksum
		set MD5 [md5::md5 -hex $EthConfigData]
		# send the new files to the drive
		FileManagerWriteFile $ConfigFilePath $EthConfigHexData
		FileManagerWriteFile $MD5FilePath $MD5
	} else {
		TlError "FileManagerOpenSession failed"
		return -1
	}
} ;#CopyEthernetConfigFile

proc str2hex { str } {
	binary scan $str H* hex
	return $hex
}

#Doxygen Tag
##Function Description : Reboots the drive
#
## ##HISTORY
## WHEN  |  WHO  |  WHAT
# -------|-------|--------
# xxxx/xx/xx| cc&ad | Proc created
# 2022/04/13| ASY   | updated the time-handling mechanism. Now uses SAFETY_WAITTIME_BOOTUP global var
# 2023/04/03| ASY   | merged the three versions of the function
# 2023/06/12| ASY   | increasing the timeout in the doWaitForOff instruction
proc doRP { }  {
	global SAFETY_WAITTIME_BOOTUP
	TlWrite RP .YES
	doWaitForOff 10
	if {[GetSysFeat "ATLAS"]} {
		doWaitForState ">=2" 30
	} else {
		doWaitForState ">=2" 5
	}
	if { [GetSysFeat "PACY_SFTY_OPAL"] || [GetSysFeat "PACY_SFTY_FORTIS"] || [GetDevFeat "FW_CIPSFTY"]} {
		if { [info exists SAFETY_WAITTIME_BOOTUP]} {
			doWaitMs $SAFETY_WAITTIME_BOOTUP
		} else {
			doWaitMs 10000
		}
	}
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 280814 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVGetObject {Object} {
	global DevAdr ActDev
	set MBAdr $DevAdr($ActDev,MOD)
	set TxFrame [format "%02X33040808000000040001%06X"             $MBAdr $Object]
	#TlPrint "TX: $TxFrame"
	set RxFrame [mbDirect $TxFrame 1]
	#TlPrint "RX: $RxFrame"
	set HexaLength "0x[string range $RxFrame 28 29]"
	set  actualLength [expr $HexaLength]
	set HexaValue "[string range $RxFrame 30 [expr (30+2*$actualLength)] ]"
	return "$HexaValue"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the status of all leds
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 280814 cordc    proc created
#
#END----------------------------------------------------------------
proc ATVGetLEDstatus { } {
	set LEDstatus [ATVGetObject 0x402]
	set HexaLed "0x[string range $LEDstatus 0 1]"
	set  QuantityLed [expr $HexaLed]
	#TlPrint "$QuantityLed"
	for {set a 0} {$a < $QuantityLed} {incr a} {
		TlPrint "LED ID : 0x[string range $LEDstatus [ expr 1+((6*$a)+1)] [ expr 2+((6*$a)+1)]] COLOR ID : 0x[string range $LEDstatus [ expr 3+((6*$a)+1)] [ expr 4+((6*$a)+1)]] STATUS : 0x[string range $LEDstatus [ expr 5+((6*$a)+1)] [ expr 6+((6*$a)+1)]] "
	}
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the status of all leds
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 280814 cordc    proc created
# Led 0: Led Drive status
# led 1: Led Warnig/fault
# led 2 : Led Safety
# Color 0x00: Off
# Color 0x01: Green
# Color 0x02:Orange
# Color 0x03:Red
# State 0x00:Off
# State 0x01:Fixed
# State 0x02:Blinking
#END----------------------------------------------------------------
proc CheckLEDstatus { led color status } {
	array set led_color { 0x00 "off" 0x01 "green" 0x02 "orange" 0x03 "red" }
	array set led_state { 0x00 "off" 0x01 "fixed" 0x02 "blinking" }
	array set led_name { 0 "DriveStatus" 1 "Warning/Fault" 2 "ASF" }
	set LEDstatus [ATVGetObject 0x402]
	set HexaLed "0x[string range $LEDstatus 0 1]"
	set  QuantityLed [expr $HexaLed]
	#TlPrint "$QuantityLed"
	if { $led < 0 || $led > $QuantityLed  } {
		TlError " not existing led"
	} else {
		TlPrint "LED ID : 0x[string range $LEDstatus [ expr 1+((6*$led)+1)] [ expr 2+((6*$led)+1)]] COLOR ID : 0x[string range $LEDstatus [ expr 3+((6*$led)+1)] [ expr 4+((6*$led)+1)]] STATUS : 0x[string range $LEDstatus [ expr 5+((6*$led)+1)] [ expr 6+((6*$led)+1)]] "
		set colorled 0x[string range $LEDstatus [ expr 3+((6*$led)+1)] [ expr 4+((6*$led)+1)]]
		set statusled  0x[string range $LEDstatus [ expr 5+((6*$led)+1)] [ expr 6+((6*$led)+1)]]
		if { $colorled == $color && $statusled == $status  } {
			TlPrint " color and status led is correct"
		}
		if { $colorled != $color  } {
			TlError "Color of $led_name($led) led is $led_color($colorled) instead of $led_color($color) ($colorled / $color)"
		}
		if { $statusled != $status  } {
			TlError "Status of $led_name($led) led is $led_state($statusled) instead of $led_state($status) ( $statusled / $status)"
		}
	}
}
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Waits for a given led to reach a given status within a timeout
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 131124 ASY      proc created
# Led 0: Led Drive status
# led 1: Led Warnig/fault
# led 2 : Led Safety
# Color 0x00: Off
# Color 0x01: Green
# Color 0x02:Orange
# Color 0x03:Red
# State 0x00:Off
# State 0x01:Fixed
# State 0x02:Blinking
#END----------------------------------------------------------------
proc doWaitForLEDstatus { led color status timeout {TTid ""}} {
	array set led_color { 0x00 "off" 0x01 "green" 0x02 "orange" 0x03 "red" }
	array set led_state { 0x00 "off" 0x01 "fixed" 0x02 "blinking" }
	array set led_name { 0 "DriveStatus" 1 "Warning/Fault" 2 "ASF" }

    set startTime [clock click -milliseconds]
    while {1} {
        if {[CheckBreak]} { break}
        set deltaTime [expr [clock click -milliseconds] - $startTime]
        set LEDstatus [ATVGetObject 0x402]
        set HexaLed "0x[string range $LEDstatus 0 1]"
        set  QuantityLed [expr $HexaLed]
        #TlPrint "$QuantityLed"
        if { $led < 0 || $led > $QuantityLed  } {
            TlError " not existing led"
        } else {
            set colorled 0x[string range $LEDstatus [ expr 3+((6*$led)+1)] [ expr 4+((6*$led)+1)]]
            set statusled  0x[string range $LEDstatus [ expr 5+((6*$led)+1)] [ expr 6+((6*$led)+1)]]
            if { $colorled == $color && $statusled == $status  } {
                TlPrint " color and status of led $led_name($led) is correct after $deltaTime ms ($led_color($color),$led_state($status))"
                return 1
            }
            if {$deltaTime > [expr $timeout * 1000]} {
                set errorMessage "Expected LED status not reach after $deltaTime ms : " 
                if { $colorled != $color  } {
                    append errorMessage "color of $led_name($led) led is $led_color($colorled) instead of $led_color($color)"
                }
                if { $statusled != $status  } {
                    append errorMessage " status of $led_name($led) led is $led_state($statusled) instead of $led_state($status)"
                }
                TlError "$errorMessage" 
                return 0
            }
        }
    }
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the status of all leds
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 120517 aduboc     proc created

#END----------------------------------------------------------------
proc CheckBuildAvailability {  } {
	global theObjektDBPath ActDev DevType theRefVersionTable
	set version ""
	set BuildPath $theObjektDBPath
	append BuildPath  "/build"
	set DriveType [ string toupper  $DevType($ActDev,Type)   ]
	set targetFolder ""
	set buildFileList { }
	# Search build file
	foreach build [glob $BuildPath/$DriveType*] {
		lappend buildFileList  [list [file tail $build]   [clock format [file mtime $build]] ]
	}
	# Search the latest version launched in the campain in file version.txt
	set RefFile [open "$BuildPath/last_version.txt" ]
	while {[gets $RefFile line ]>=0} {
		set deviceREfList [ split $line "|"]
		#TlPrint $deviceREfList
		set theRefVersionTable([lindex $deviceREfList 0 ]) [list [lindex $deviceREfList 1 ] [lindex $deviceREfList 2 ] ]
	}
	close $RefFile
	set rc [catch { set retVal $theRefVersionTable($DriveType) }]
	set lastDate [ lindex $retVal 1]
	foreach dateBuild $buildFileList {
		#		TlPrint "test lastDate1 : [lindex $dateBuild 1]"
		if { [ clock scan  [lindex $dateBuild 1]] >  [ clock scan $lastDate ] } {
			set lastDate [ lindex $dateBuild 1]
			#TlPrint "test lastDate : $lastDate"
			set targetFolder [ lindex $dateBuild 0]
		}
	}
	TlPrint " targetFolder : $targetFolder "
	if { $targetFolder != "" } {
		set FirstVersionChar [string first "_V" $targetFolder]
		set version [ string range $targetFolder [expr {$FirstVersionChar + 1}] 18 ]
		set altilabKopFile  "AltiLab_KOP_$DevType($ActDev,Type)_CS_$version.xml"
		set versionFile  "$DevType($ActDev,Type)_version_$version.txt"
		#		TlPrint "altilabKopFile : $altilabKopFile "
		if { $DevType($ActDev,Type) != "Opal" } {
			file copy -force "$BuildPath/$targetFolder/Gen/$altilabKopFile" "$theObjektDBPath/AltiLab_KOP_$DevType($ActDev,Type).xml"
		} else {
			file copy -force "$BuildPath/$targetFolder/Gen/$altilabKopFile" "$theObjektDBPath/AltiLab_KOP_OPAL_CS.xml"
		}
		file copy -force "$BuildPath/$targetFolder/$versionFile" "$theObjektDBPath/$DevType($ActDev,Type)_$version.txt"
		if {[GetSysFeat "PACY_COM_CANOPEN"]} { ;#CANopen
			switch  $DriveType {
				"FORTIS" {set edsFile "FORTIS_SEATV9x0_CANopen.eds"}
				"OPAL"   {set edsFile "OPAL_SEATV3x0_CANopen.eds"}
				"NERA"   {set edsFile "NERA_SEATV6x0_CANopen.eds"}
				"MVK"   {set edsFile "MVK_SEATV60x0_CANopen.eds"}
				"ATV320"   {set edsFile "ATV320_SEATV320_CANopen.eds"}
			}
			file copy -force "$BuildPath/$targetFolder/*.eds" $edsFile
		}
		#TlPrint " $DevType($ActDev,Type) | $version | $lastDate "
		set theRefVersionTable($DriveType) [list $version $lastDate ]
		set rc [catch { set retVal $theRefVersionTable($DriveType) }]
		set lastDate [ lindex $retVal 1]
		set keys  [array names theRefVersionTable ]
		set RefFile [open "$BuildPath/last_version.txt" w ]
		foreach key $keys {
			set rc [catch { set retVal $theRefVersionTable($DevType($ActDev,Type)) }]
			set line "$key|[ lindex $retVal 0]|[ lindex $retVal 1]"
			puts $RefFile $line
		}
		close $RefFile
	}
	return $version
}

#MERGE 0002 : from ethercat tower. Functions created by AD for campaign launching

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Give the status of all leds
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 080621 cc     proc created
# 211012 ASY      Started the documentation
# 211125 ASY 	  Modified the input parameter version. Now takes a full path name
# 220119 VTIE	  KalaFlashTool handles cybersecurity since v1.4.?.?. Works with modbus RTU and TCP (tested on fortis + opal)
# 220208 VTIE	  update: correction "incr counter" becomes "incr counter"
#		  added path to other installation path of KFT -> Temporary before uniformization
#END----------------------------------------------------------------
proc UpdateFirmwareCurrentBuild { fileName { modMDB 0 } { mdbAddress 0 } } {
	global mainpath ActDev DevAdr theSerialPort theSerialBaud StopBits Parity
	#turn on the device => changer le check d'etat #proc DeviceOn {DevNr {checkData 1} {State ">=2"} {timeout 30} {TTId ""}}  => change pour ">=0" afin de flasher dans tous les cas. Peut être ne pas flasher si drive en erreur? (<23 ?). le ">=0" ne marche pas. pourquoi? Mis en commentaire en attendant. Il semble que le state 11 "NLP" soit un cas particulier
	DeviceOn $ActDev 1 ">0"
	TlPrint "--- delay to let the drive starts fully before trying to update ---"
	doWaitMsSilent 5000
	set FWpackage $fileName
	TlPrint "Package to flash : $FWpackage"
	#Drive assistant must be installed with a valid licence. Licence granted for a computer no matter which user is loged in. Contact Nicolas Andre
	TlPrint "====================================================== "
	TlPrint "=======          KalaFlashTool Status         ======== "
	TlPrint "====================================================== "
	#Set the correct folder for KalaFlashTool as it can be either installed in DriveAssistant or KalaFlashTool directory
	#Once kala is deployed according to internal rules, suppress the useless lines.
	set kalaNotInstalled [ catch { set kftPath [ glob -path "c:/Program\ Files\ (x86)/Schneider\ Electric/DriveAssistant/" "KalaFlashTool.exe" ] } ]
	if {$kalaNotInstalled} {
		set kalaNotInstalled [ catch { set kftPath [ glob -path "c:/Program\ Files\ (x86)/Schneider\ Electric/KalaFlashTool/" "KalaFlashTool.exe" ] } ]
	}
	if {$kalaNotInstalled} {
		set kalaNotInstalled [ catch { set kftPath [ glob -path "c:/Program\ Files\ (x86)/KalaFlashTool/" "KalaFlashTool.exe" ] } ]
	}
	if {$kalaNotInstalled} {
		set kalaNotInstalled [ catch { set kftPath [ glob -path "C:\\Unifast\\Soft\\KalaFlashTool\\KalaFlashTool.exe" "KalaFlashTool.exe" ] } ]
	}
	#TODO : check the error display
	if {$kalaNotInstalled} {return -code error "KalaFlashTool is not installed"}
	#glob returns a list, convert back this list into a string
	set kftPath [lindex $kftPath 0]
	if { $modMDB == 2 } {
		#before trying to flash, check that the drive is responding
		#TODO : check if the timing is sufficient for drive to start up
		if {![doWaitForPing $mdbAddress 3000]} { return -code error "No answer from drive. Check connection or drive parameters" }
		set kftClosed [exec $kftPath --hmi false --package $FWpackage --script loader_FT_default.py --communication "IPV4, $mdbAddress, 502, 248" --msgbox false &]
		#Wait for KFT to be closed, polling on process IDs
		#TODO : check if improvement necessary for loop break handling
		while { [regexp -all "$kftClosed" [exec tasklist]] } { continue }
	} elseif { $modMDB == 1 } {
		#TODO:suggestion: use the proc TryAllModbusFormats if ever you want to be sure to start in a correct way and not assume that the basic configuration is already set in the drive
		#Close modbus RTU communication to liberate the COM port for KFT
		ModClose
		set kftClosed [exec $kftPath --hmi false --package $FWpackage --script loader_FT_default.py --communication "SERIAL, $theSerialBaud, 8, E, 1, 248, COM$theSerialPort" --msgbox false &]
		#Wait for KFT to be closed, polling on process IDs
		while { [regexp -all "$kftClosed" [exec tasklist]] } { continue }
		#reopen the modbus RTU connexion
		ModOpen $theSerialPort $theSerialBaud "1" "1"
	} else { return -code error "/********** modbus mode not defined **********/" }
	#KalaFlashTool loops on 2 lines to refresh the status of the flash, but 11 lines are displayed and are not removed. the following lines allow to skip those lines to display following information correctly
	TlPrint "\n\n\n\n\n\n\n\n\n\n\n\n"
	#Wait for the firmware to be ready to apply
	if {[GetSysFeat "ATLAS"]} {

		if { [doWaitForObject FWST .NO 100] == [Enum_Value FWST .NO]} {

			return 0
		}
	} else {

		TlPrint "====================================================== "
		TlPrint "===== Waiting for drive to be ready to update... ===== "
		TlPrint "====================================================== "
		if { [doWaitForObject FWST .RDY 600 0xffffffff "" 1] != [Enum_Value FWST .RDY] } {return -code error "Upload of the update files has failed!"}
		#Go to mode TP and apply firmware
		TlPrint "====================================================== "
		TlPrint "======= Start the update within the drive...  ======== "
		TlPrint "====================================================== "
		TlWrite MODE .TP
		TlWrite FWCD .APPLY
		#Some drives (e.g. Nera) sets the mdb address to "OFF". Set the address of UniFAST to 248 (broadcast) to be sure to retrieve the communication
		set DevAdr($ActDev,MOD) 248
		TlPrint "====================================================== "
		TlPrint "====== Wait for the drive to finish the update ======= "
		TlPrint "====================================================== "
		set doLoop 1
		set updIsInstalled 0
		set counter 0
		while { $doLoop && $counter < 10 } {
			if { [doWaitForObject FWST .SUCCD 100 0xffffffff "" 1] == [Enum_Value FWST .SUCCD] } {
				set doLoop 0
				set updIsInstalled 1
			} else {
				TlPrint "Drive still updating! Please wait..."
				incr counter
			}
			if { $counter > 10 } { return -code error "Upload took too long, an issue must have occured" }
		}
		TlPrint "====================================================== "
		TlPrint "======     Firmware updated successfully !     ======= "
		TlPrint "====================================================== "
		#Clear the firmware once it is applied
		TlPrint "====================================================== "
		TlPrint "======  Clean the update files from the drive  ======= "
		TlPrint "====================================================== "
		TlWrite MODE .TP
		TlWrite FWCD .CLEAR
		#check if device has cleared all pending update files and if the update has been done correctly and return the status accordingly
		if { [doWaitForObject FWST .NO 100] == [Enum_Value FWST .NO] && $updIsInstalled } {
			return 0
		}
	}
	return 1
	#TODO: Implement a version checking mechanism (C1SV C1SB C1SC)
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# return list features of ini file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 020721 ad     proc created

#END----------------------------------------------------------------
proc FeatureIniFile {  } {
	package require inifile

	global mainpath ActDev COMPUTERNAME  theConfigIniFile
	if { [catch {set filehandle [ini::open $theConfigIniFile "r"]} fid] } {
		puts "Could not open $configDefaultFile for writing\n$fid"
		if { [catch {set filehandle [ini::open $configDefaultFile "r"]} fid] } {
			puts "Could not open $configDefaultFile for writing\n$fid"
			puts " ATTENTIONErr: Please contact either your admin or check out the config_default.ini file"
			exit 1
		} else {
			puts " \nATTENTIONInfo: Interpreter has started with default config file. Restrictions:"
			puts " - The Interpreter is restricted for 2 Devices "
			puts " - Communication establishment is not guaranteed \n"
		}
	}
	#Check how many devices are defined in the ini file
	set section [ini::sections $filehandle]
	set sectionFeatDev "FeaturesDev$ActDev"
	TlPrint $sectionFeatDev
	set listFeaturesINI [ini::get $filehandle $sectionFeatDev ]
	TlPrint "listFeatures : $listFeaturesINI "
	ini::close $filehandle
	set listFeaturesOfIni ""
	set lengthFeatureIni [ llength $listFeaturesINI ]
	for {set i 0 } {$i <= $lengthFeatureIni  } {incr i} {
		#	  	TlPrint [ lindex $listFeaturesIHM $i ]
		lappend feat [ lindex $listFeaturesINI $i ]
		if { [ expr $i % 2 ] == 1 } {
			lappend	listFeaturesOfIni $feat
			set feat ""
		}
	}
	return $listFeaturesOfIni
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# write features of ini file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 020721 ad     proc created

#END----------------------------------------------------------------
proc WriteIniFile {iniFile section feature value } {
	package require inifile

	global mainpath ActDev theConfigIniFile
	set filehandle [ini::open $iniFile "r+"]
	ini::set $filehandle $section $feature $value
	ini::commit $filehandle
	ini::close $filehandle
}

proc ReadIniFile {iniFile section feature } {
	package require inifile

	global mainpath ActDev
	set filehandle [ini::open $iniFile "r+"]
	set FeatureValue [ ini::value $filehandle $section $feature ]
	ini::close $filehandle
	return $FeatureValue
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# HMI for choose feature
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 020721 ad     proc created

#END----------------------------------------------------------------
proc chooseFeatureByIHM { drive } {
	global AutoIt libpath mainpath DevType ActDev
	source $libpath/AutoIt_lib.tcl
	#    $DevType($ActDev,Type)
	if { [catch { exec $mainpath/ObjektDB/build/SelectionInterface.exe $drive } results  ] } {
		set listFeaturesIHM  [split $results "|" ]
		set listFeaturesForIni ""
		set lengthFeatureIHM [ llength $listFeaturesIHM ]
		for {set i 0 } {$i <= $lengthFeatureIHM } {incr i} {
			#	  	TlPrint [ lindex $listFeaturesIHM $i ]
			lappend feat [ lindex $listFeaturesIHM $i ]
			if { [ expr $i % 2 ] == 1 } {
				lappend	listFeaturesForIni $feat
				set feat ""
			}
		}
	}
	return $listFeaturesForIni
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Write feature on ini fie and copy en /0Init
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 050721 ad     proc created

#END----------------------------------------------------------------
proc ManageIniFile { } {
	global AutoIt libpath mainpath DevType ActDev COMPUTERNAME theConfigIniFile theObjektDBPath
	set configDefaultINIFile $mainpath/ObjektDB/build/config_$COMPUTERNAME.ini
	file copy -force $configDefaultINIFile $theConfigIniFile
	file copy -force $theObjektDBPath/build/FeaturesSelection.ini $theObjektDBPath/FeaturesSelection.ini
	set listFeatureForIniFile [ chooseFeatureByIHM $DevType($ActDev,Type) ]
	foreach feature $listFeatureForIniFile {
		if { [lindex $feature 0] != "Safety" } {
			WriteIniFile $theConfigIniFile "FeaturesDev$ActDev" [lindex $feature 0] [lindex $feature 1]
			WriteIniFile "$theObjektDBPath/FeaturesSelection.ini" "Features" [lindex $feature 0] [lindex $feature 1]
		} else {
			if { [lindex $feature 1] != "1" } {
				WriteIniFile $theConfigIniFile "Device$ActDev" "OptBd3" "SAFPRE"
			}
		}
	}
}

proc ReplaceWithArchive {OriginalFile ODBFile} {
	global theObjektDBPath
	set OLD_ODBFile $theObjektDBPath/OLD_$ODBFile
	if {[ file exists $theObjektDBPath/OLD_$ODBFile ] == 1} {
		file delete -force $theObjektDBPath/OLD_$ODBFile
	}
	if {[ file exists $theObjektDBPath/$ODBFile ] == 1} {
		file rename -force $theObjektDBPath/$ODBFile $theObjektDBPath/OLD_$ODBFile
	}
	file copy -force $OriginalFile $theObjektDBPath/$ODBFile
}

proc CampaignFilesCopy {BuildFolder version} {
	package require inifile

	global theObjektDBPath ActDev DevType theConfigIniFile
	set DriveType [ string toupper  $DevType($ActDev,Type)   ]
	#AltilabKop file
	if { $DevType($ActDev,Type) == "Opal" } {
		ReplaceWithArchive "$BuildFolder/Gen/AltiLab_KOP_$DevType($ActDev,Type)_CS_$version.xml" "AltiLab_KOP_OPAL_CS.xml"
	} elseif { $DevType($ActDev,Type) != "Altivar" } {
		ReplaceWithArchive "$BuildFolder/Gen/AltiLab_KOP_$DevType($ActDev,Type)_CS_$version.xml" "AltiLab_KOP_$DriveType.xml"
	}
	#ATV320 files
	if {$DevType($ActDev,Type) == "Altivar"} {
		ReplaceWithArchive $BuildFolder/ATV320_EnumParametersDescription_$version.xml R3Dev_EnumParametersDescription.xml
		ReplaceWithArchive $BuildFolder/ATV320_PrmUnifiedMappingSimulatorGen_$version.sim R3Dev_PrmUnifiedMappingSimulatorGen.sim
	}
	#Version File
	if { $DevType($ActDev,Type) != "Altivar" } {
		ReplaceWithArchive $BuildFolder/$DevType($ActDev,Type)_version_$version.txt [ append ODB_versionFile $DriveType "_version.txt" ]
	}
	#Water files deletion
	if { $DevType($ActDev,Type) == "Nera" } {
		file delete -force "$theObjektDBPath/ConfPackageFiles"
		file mkdir "$theObjektDBPath/ConfPackageFiles"
	}
	#eds file for CANOPEN
	if {[GetSysFeat "PACY_COM_CANOPEN"]} { ;#CANopen
		switch  $DriveType {
			"FORTIS" {
				set edsVersion "FORTIS_SEATV9x0_CANopen.eds"}
			"OPAL"   {
				set edsVersion "OPAL_SEATV3x0_CANopen.eds"}
			"NERA"   {
				set edsVersion "NERA_SEATV6x0_CANopen.eds"}
			"MVK"   {
				set edsVersion "MVK_SEATV60x0_CANopen.eds"}
			"ATV320"   {
				set edsVersion "ATV320_SEATV320_CANopen.eds"}
		}
		ReplaceWithArchive [ glob -path $BuildFolder/Comm/ *.eds ] $edsVersion
	}
	#Safety Files
	if {$DevType($ActDev,Type) == "Opal" || $DevType($ActDev,Type) == "Fortis"} {
		if {[ catch {set SafetyModuleFolder [ glob -path $theObjektDBPath/build /SafetyModule_* ]} fid]} {
			TlPrint "Safety module folder missing"
		} else {
			if {[ReadIniFile "$theObjektDBPath/FeaturesSelection.ini" "Features" "Modul_SM1" ] == 1} {
				set SafetyModuleFolder [ glob -path $theObjektDBPath/build /SafetyModule_* ]
				ReplaceWithArchive $SafetyModuleFolder/map_files/CPUA_Fw.map CPUA_Fw.map
				ReplaceWithArchive $SafetyModuleFolder/map_files/CPUB_Fw.map CPUB_Fw.map
				ReplaceWithArchive $SafetyModuleFolder/sources/SafetyParameters4TestTowers.csv SafetyParameters4TestTowers.csv
				ReplaceWithArchive $SafetyModuleFolder/sources/SafetyErrors.xml SafetyErrors.xml
				ReplaceWithArchive $SafetyModuleFolder/sources/SafetyParameters.xml SafetyParameters.xml
			}
		}
	}
}

#DESCRIPTION
# function used to set particular bits of a word to a given value
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20220623   ASY    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description :  function used to set particular bits of a word to a given value
# Takes as input parameters the register to write to and two lists. The first one is the list of bits to write. Numbers must be included between 0 and 15 in *decimal* representation.
# The second one is the register containing the values to assign to each of the previously mentionned bits. Those values must be only 0 and 1. The length of the two lists must be identical
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2021/01/07 | ASY | proc created
#
# /param[in] objString : representation of the parameter to write to
# /param[in] lBits : list of the bits to write
# /param[in] lValues : list of the values to write to each of the bits.
# /param[in] timeout : timeout in seconds to check that the value was applied
# /param[in] mdb : force the write through modbus, otherwise uses the current communication channel
# /param[in] NoErrPrint : Default value 0 deactivates error print
# /param[in] TTId : default value "" string to display in case of error
# E.g. use < TlSetBit CMD  {0 1 2 3} {1 1 1 1} > to set CMD to 0bxxxx xxxx xxxx 1111
proc TlSetBits {objString lBits lValues {timeout 1} {mdb 0} {NoErrPrint 0} {TTId ""}} {
	#Check that the lists have the same length
	if {!$NoErrPrint && [llength $lBits] != [llength $lValues]} {
		TlError "Inputs lists size are different"
		return -1
	}
	#Check that lBits list contains only numbers
	if {!$NoErrPrint && [lsearch -regexp  $lBits "\[^\[:digit:\]\]"] != -1 } {
		TlError "Bits to set list does not contain only numbers"
		return -1
	}
	#Check that lBits does not contain duplicates
	if {!$NoErrPrint && [llength [lsort -unique $lBits]] != [llength $lBits] } {
		TlError "Bits to set list contains duplicates"
		return -1
	}
	#Check that lValue contains only 0 and 1
	if {!$NoErrPrint && [lsearch -regexp  $lValues "\[^\[:digit:\]\]|\[2-9\]|.\{2,\}"] != -1 } {
		TlError "Values to write do not contain only 0 and 1"
		return -1
	}
	#calculate the mask and value to use
	set mask 0
	set value 0
	for {set i 0} {$i < [llength $lBits]} {incr i} {
		set mask [expr $mask + round(pow(2,[lindex $lBits $i]))]
		set value [expr $value + round(pow(2,[lindex $lBits $i])) * [lindex $lValues $i] ]
	}
	#get the current value of the word
	if { $mdb } {
		set currentWordValue [ModTlRead $objString]
	} else {
		set currentWordValue [TlRead $objString]
	}
	#calculate the new value to write
	#new value is equal to : ValueToWrite AND Mask OR CurrentValue AND NOT Mask
	#use XOR with 0xFFFF to get the NOT(MASK)
	set newWordValue [ expr $value & $mask | [expr $mask ^ 0xFFFF] & $currentWordValue]
	#Write the new value
	TlWrite $objString $newWordValue $NoErrPrint $TTId
}

#----------------------------------------------------------------------------------------------------
# warte bis Object < oder > sollwert wird
# objekt:   symbolischer Name, z.B. MONC.PACTUSR
# operator: vergleich zb. ">" oder "<"
# sollWert: gewuenschter Wert der zum Ende fuehrt
# timeout:  sekunden
#
proc doWaitForObjectOp { object operator sollwert timeout {TTId ""}} {
	if {$TTId != "" } { set TTId "*$TTId*" }
	set startZeit [clock clicks -milliseconds]
	while { 1 } {
		if {[CheckBreak]} {break}
		set istwert [doReadObject $object 0]
		set timeDiff [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $istwert $operator $sollwert] } {
			TlPrint "doWaitForObjectOp: $object is $operator $sollwert after $timeDiff ms"
			return 1
		}
		if {$timeDiff >= [expr $timeout * 1000] } {
			TlError "$TTId doWaitForObjectOp: Timeout, $object is not $operator $sollwert in $timeout s"
			return 0
		}
	}
}

#DESCRIPTION
# compares two values taking a mask into account. Only the bits set to 1 of the mask will have an impact in the comparison
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20220705   ASY    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : compares two values taking a mask into account.
# Only the bits set to 1 of the mask will have an impact in the comparison
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2022/07/05 | ASY | proc created
#
# compares word with setpoing according to mask
# E.g. use < compareWithMask $word $setpoint $mask >
proc compareWithMask { value setpoint mask {errorPrint 1}} {
	if { [expr $value & $mask] == [expr $setpoint & $mask]} {
		return 1
	} else {
		set nSetpoint [expr $setpoint ^ 0xFFFF]
		set nValue [expr $value ^ 0xFFFF]
		if {$errorPrint} {
			TlError "Value different from expected : [expr [expr $value & $mask] ^ [expr $setpoint & $mask]]"
			TlPrint "bits high instead of low : [expr $value & $nSetpoint] "
			TlPrint "bits low instead of hight : [expr $setpoint & $nValue] "
		}
		return 0
	}
}

#DESCRIPTION
# Write a word to the PLC according to a mask over Modbus TCP
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20220609   ASY    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : Write a word (16bits) to the PLC according to a mask over Modbus TCP
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2022/06/09 | ASY | proc created
#
# /param[in] index : address of the word to write to
# /param[in] mask : mask for the write ==> only the bits set to 1 will be modified
# /param[in] value : value to write
# E.g. use < se_TCP_writeWordMask 4 1 0 > to set to 0 the bit 1 of word 4 of the PLC
proc se_TCP_writeWordMask { index mask value } {

	#First read the word to write to
	set currentWordValue [ wc_TCP_ReadWord $index 1]
	#    TlPrintDebug "currentWordValue : $currentWordValue"
	#limit the mask to 16bits
	set mask [expr $mask & 0xFFFF]
	#    TlPrintDebug "mask : $mask"
	#calculate the new value to write
	#new value is equal to : ValueToWrite AND Mask OR CurrentValue AND NOT Mask
	#use XOR with 0xFFFF to get the NOT(MASK)
	set newWordValue [ expr $value & $mask | [expr $mask ^ 0xFFFF] & $currentWordValue]
	#    TlPrintDebug "newWordValue : $newWordValue"
	#write value to the PLC
	wc_TCP_WriteWord $index $newWordValue
}

#DESCRIPTION
# converts a bitfield value to the highest index of is high bits
#
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 20230329   ASY    proc created
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description :  converts a bitfield value to the highest index of is high bits
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/03/29 | ASY | proc created
#
# E.g. use < set DCC [bitfieldIndex [TlRead CCC] ]> to get the CCC bitfield reprensentation in DCC variable
proc bitfieldIndex { value} {
	return [expr round(log($value)/log(2))]
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForModObjectStable
# TYPE        : util
# AUTHOR      : MLT
# DESCRIPTION : Wait until read object receives a specific value (via Modbus interface)
#               and stays at this value during some time to consider the value as stable
#  objekt:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  stabletime : milliseconds
#  bitmaske:  to check only specified bits
#
# 22052023 MLT creation of proc based on doWaitForObjectStable
#2023/10/08 IC Update
#END-------------------------------------------------------------------
proc doWaitForModObjectStable { objekt sollWert timeout stabletime {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	set istWert ""
	set changeFlag 0
	while {1} {
		after 2   ;# wait 2 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $waittime > $timeout] && !$changeFlag} {
			if {$tryNumber!=1} {
				set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]
				TlError "$TTId doWaitForModObjectStable $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				if {$noErrPrint == 0} { ShowStatus }
				return 0
			}
		}
		set istWert [doReadModObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {
			if { !$changeFlag } {
				set startZeit2 [clock clicks -milliseconds]
				set changeFlag 1
				TlPrint "target value reached after [expr $startZeit2 - $startZeit] ms"
			}
			set waittime2 [expr [clock clicks -milliseconds] - $startZeit2]
			if { [expr $waittime2 > $stabletime] } {
				TlPrint "doWaitForModObjectStable $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert [expr $waittime ] $tryNumber
				return 1
			}
		}
		if { [expr ($istWert & $bitmaske) != ($sollWert & $bitmaske)]  & $changeFlag} {
			set changeFlag 0
			TlPrint "$objekt changed from $sollWert to $istWert at $waittime ms after $waittime2 ms of stability"
		}

		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

#DESCRIPTION
# get the index (logical address) of first register in a sequence of N contiguous registers
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description :  get the index (logical address) of first register in a sequence of N contiguous registers
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < set index [indexContinuousParametersRegisters 10] > to get the index (logical address) of first register in a sequence of 10 contiguous registers
proc indexContinuousParametersRegisters { N } {
	global theNERAParaIndexRecord theATVParaIndexTable

	if { $N < 2} {
		TlError "N should be greater than 2"
		return -1 }

	if {[GetDevFeat "Altivar"]} {
		#TlPrint " ok mais : $theATVParaIndexTable "
		set IndexList [array names theATVParaIndexTable]
		set IndexList [lreplace $IndexList 0 0]
	} else {
		set IndexList [array names theNERAParaIndexRecord]
	}

	set SortedIndexList [lsort -integer -increasing $IndexList]

	set maxindex [expr [llength $SortedIndexList] - $N + 1 ]

	if { $maxindex <= 0 } {
		TlError "not enough elements in array"
		return -1
	}

	for {set i 0} { $i < $maxindex } { incr i } {

		set i_N [expr $i + $N - 1]
		set element_i [lindex $SortedIndexList $i]
		set element_i_N [lindex $SortedIndexList $i_N]

		if { $element_i_N == [expr $element_i + $N - 1] } {

			for {set j $i} { $j < $maxindex } {incr j} {

				set j_N [expr $j + $N -1]
				set element_j [lindex $SortedIndexList $j]
				set element_j_N [lindex $SortedIndexList $j_N]

				if { $element_j_N == [expr $element_j + $N - 1] } {
					set element $element_j

				} else {
					return $element
				}
			}
		}
	}

	return -1
}

#DESCRIPTION
# get the index (logical address) of first register for which the next N elements are not contiguous
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : get the index (logical address) of first register for which the next N elements are not contiguous
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < set index [indexNotContinuousParametersRegisters 10] > to get the index (logical address) of first register for which the next 10 elements are not contiguous
proc indexNotContinuousParametersRegisters { N } {
	global theNERAParaIndexRecord theATVParaIndexTable

	if { $N < 2} {
		TlError "N should be greater than 2"
		return -1
	}

	if {[GetDevFeat "Altivar"]} {
		set IndexList [array names theATVParaIndexTable]
	} else {
		set IndexList [array names theNERAParaIndexRecord]
	}

	set SortedIndexList [lsort -integer -increasing $IndexList]

	set maxindex [expr [llength $SortedIndexList] - $N + 1 ]

	if { $maxindex <= 0 } {
		TlError "not enough elements in array"
		return -1
	}

	for {set i 0} { $i < $maxindex } { incr i } {

		set i_N [expr $i + $N - 1]
		set element_i [lindex $SortedIndexList $i]
		set element_i_N [lindex $SortedIndexList $i_N]

		if { $element_i_N != [expr $element_i + $N - 1] } {return $element_i }
	}

	return -1
}

#DESCRIPTION
# get the maximum size of a sequence of contiguous registers in the device less than or equal to N
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : get the maximum size of a sequence of contiguous registers in the device less than or equal to N
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < set maxRegisters [maxContinuousRegister 10] > to get the maximum size of a sequence of contiguous registers in the device less than or equal to 10
proc maxContinuousRegister { N } {

	set MaxCount -1

	if { $N < 2} {
		TlError "N should be greater than 2"
		return -1
	}

	for {set i 2} { $i <= $N } { incr i } {
		set tempCount [indexContinuousParametersRegisters $i]
		if {$tempCount != -1} {
			set MaxCount $i
		}
	}

	return $MaxCount
}

#DESCRIPTION
# check that returned response of Modbus FC3 is positive (not a response with exception) for reading N registers
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : check that returned response of Modbus FC3 is positive (not a response with exception) for reading N registers
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < checkFC3Positive $RxFrame 2 > check that RxFrame is a positive response to a Modbus FC3 request with values of 2 read registers
proc checkFC3Positive { RxFrame N } {

	set feedback 1

	if {[string index $RxFrame 3] != "" } { set AnswerCodeFC3 [string range $RxFrame 2 3] } else { set feedback 0 }
	if {[string index $RxFrame 5] != "" } { set NumberBytesFC3 "0x[string range $RxFrame 4 5]" } else { set feedback 0 }
	set substring3 [string index $RxFrame [expr 5 + 4*$N]]
	set substring4 [string index $RxFrame [expr 6 + 4*$N]]

	if { $feedback == 0 } {
		TlError "FC3 response has not the correct amount of characters  expected 03 (1byte) ($N * 2 bytes) : found $RxFrame"

	} else {
		if { [checkValue AnswerCodeFC3 $AnswerCodeFC3 03] != 1 } { set feedback 0 }
		if { [checkValue NumberBytesFC3 $NumberBytesFC3 [expr 2*$N] ] != 1 } {set feedback 0 }
	}

	if { $substring3 == "" } {
		TlError "Size of FC3 response is too short"
		set feedback 0
	}

	if { $substring4 != "" } {
		TlError "Size of FC3 response is too long"
		set feedback 0
	}

	if { $feedback == 1 } { TlPrint "FC3 response has the correct format" }

	return $feedback
}

#DESCRIPTION
# check that returned response of Modbus FC4 is positive (not a response with exception) for reading N registers
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : check that returned response of Modbus FC4 is positive (not a response with exception) for reading N registers
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < checkFC4Positive $RxFrame 2 > check that RxFrame is a positive response to a Modbus FC4 request with values of 2 read registers
proc checkFC4Positive { RxFrame N } {

	set feedback 1

	if {[string index $RxFrame 3] != "" } { set AnswerCodeFC4 [string range $RxFrame 2 3] } else { set feedback 0 }
	if {[string index $RxFrame 5] != "" } { set NumberBytesFC4 "0x[string range $RxFrame 4 5]" } else { set feedback 0 }
	set substring3 [string index $RxFrame [expr 5 + 4*$N]]
	set substring4 [string index $RxFrame [expr 6 + 4*$N]]

	if { $feedback == 0 } {
		TlError "FC4 response has not the correct amount of characters  expected 04 (1byte) ($N * 2 bytes) : found $RxFrame"

	} else {
		if { [checkValue AnswerCodeFC4 $AnswerCodeFC4 04] != 1 } { set feedback 0 }
		if { [checkValue NumberBytesFC4 $NumberBytesFC4 [expr 2*$N] ] != 1 } {set feedback 0 }
	}

	if { $substring3 == "" } {
		TlError "Size of FC4 response is too short"
		set feedback 0
	}

	if { $substring4 != "" } {
		TlError "Size of FC4 response is too long"
		set feedback 0
	}

	if { $feedback == 1 } { TlPrint "FC4 response has the correct format" }

	return $feedback

}

#DESCRIPTION
# check that returned response of Modbus FC16 is positive (not a response with exception) for writing N registers
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : check that returned response of Modbus FC16 is positive (not a response with exception) for writing N registers
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < checkFC16Positive $RxFrame $StartIndex 5 > check that RxFrame is a positive response to a Modbus FC16 request for writing 5 contiguous registers starting from index 'StartIndex'
proc checkFC16Positive { RxFrame StartingAddress N {GEDEC ""}} {

	set feedback 1

	if {$GEDEC != ""} {set GEDEC "*$GEDEC* "}

	if {[string index $RxFrame 3] != "" } { set AnswerCodeFC16 [string range $RxFrame 2 3] } else { set feedback 0 }
	if {[string index $RxFrame 7] != "" } { set StartingAddressFC16 "0x[string range $RxFrame 4 7]" } else { set feedback 0 }
	if {[string index $RxFrame 11] != "" } { set QuantityOfRegistersFC16 "0x[string range $RxFrame 8 11]" } else { set feedback 0 }

	if { $feedback == 0 } {
		TlError "$GEDEC FC16 response has not the correct amount of characters : expected 10 $StartingAddress (2bytes) $N * 2 (2 bytes) : found $RxFrame"

	} else {
		if { [checkValue AnswerCodeFC16 $AnswerCodeFC16 10] != 1 } { set feedback 0 }
		if { [checkValue StartingAddressFC16 $StartingAddressFC16 $StartingAddress ] != 1 } {set feedback 0 }
		if { [checkValue QuantityOfRegistersFC16 $QuantityOfRegistersFC16 $N ] != 1 } {set feedback 0 }
	}

	if { $feedback == 1 } { TlPrint "FC16 response has the correct format" }

	return $feedback
}

#DESCRIPTION
# check that returned response of Modbus FC23 is positive (not a response with exception) for reading x registers and writing N registers
#
#
# ----------HISTORY----------
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
#END----------------------------------------------------------------
# Doxygen Tag:
##Function description : check that returned response of Modbus FC23 is positive (not a response with exception) for reading x registers and writing N registers
# WHEN       |  WHO  | WHAT
# -----------| ----- | -----
# 2023/06/16 | Yahya | Moved and documented function (see Github issue #765 for details)
#
# E.g. use < checkFC23Positive $RxFrame 5 > check that RxFrame is a positive response to a Modbus FC23 request for writing x registers and reading 5 registers
proc checkFC23Positive { RxFrame N } {

	set feedback 1

	if {[string index $RxFrame 3] != "" } { set AnswerCodeFC23 "0x[string range $RxFrame 2 3]" } else { set feedback 0 }
	if {[string index $RxFrame 5] != "" } { set NumberBytesFC23 "0x[string range $RxFrame 4 5]" } else { set feedback 0 }
	set substring3 [string index $RxFrame [expr 5 + 4*$N]]
	set substring4 [string index $RxFrame [expr 6 + 4*$N]]

	if { $RxFrame == "" } {
		TlError "response is $RxFrame, we got no response"
	}

	if { $feedback == 0 } {
		TlError "FC23 response has not the correct amount of characters  expected 03 (1byte) ($N * 2 bytes) : found $RxFrame"

	} else {
		if { [checkValue AnswerCodeFC23 $AnswerCodeFC23 23] != 1 } { set feedback 0 }
		if { [checkValue NumberBytesFC23 $NumberBytesFC23 [expr 2*$N] ] != 1 } {set feedback 0 }
	}

	if { $substring3 == "" } {
		TlError "Size of FC23 response is too short"
		set feedback 0
	}

	if { $substring4 != "" } {
		TlError "Size of FC23 response is too long"
		set feedback 0
	}

	if { $feedback == 1 } { TlPrint "FC23 response has the correct format" }

	return $feedback
}

#DOC----------------------------------------------------------------
#DESCRIPTION
# Diagnostic Code Clear Counters
#END----------------------------------------------------------------
proc Clear_Diagnostic_Counter {} {
	global MBAdr

	set FC  8

	set TxFrame  [format "%02X%02X000A0000"  $MBAdr $FC]
	TlPrint "Diagnostic Code Clear Counters"
	TlSend $TxFrame 1

} ;# Clear_Diagnostic_Counter

#DOC----------------------------------------------------------------
# DESCRIPTION
# FC8: read Diagnostic Counter 'Code'
#END----------------------------------------------------------------
proc Read_Diagnostic_Counter {Code {Title ""} } {
	global MBAdr

	set FC    8
	set Data  0

	TlPrint $Title
	set TxFrame [format "%02X%02X%04X%04X"    $MBAdr $FC $Code $Data]
	set RxFrame [TlSend $TxFrame 1]
	if { ($RxFrame == "") || ([string length $RxFrame] < 11) } then {
		set result "0"
	} else {
		#For ProfiNet the format of the response differs. Value is 4 byte long
		if {[GetDevFeat "BusPN"]} {
			set result "0x[string range $RxFrame 8 15]"
		} else {
			set result "0x[string range $RxFrame 8 11]"
		}
	}

} ;# Read_Diagnostic_Counter

#DOC----------------------------------------------------------------
#DESCRIPTION
# FC3-Read Multiple Registers with CRC error -> no response
#END----------------------------------------------------------------
proc Gen_CRC_Error {{address 0x1606} } {
	global MBAdr

	set FC  3

	set TxFrame  [format "%02X%02X%04X0004"  $MBAdr $FC $address]
	set TxCRC    [MakeCRC  $TxFrame]

	TlPrint "Send wrong CRC, device must not send an answer"
	set TxFrame1 [format "$TxFrame%01X" [expr $TxCRC + 1]]
	TlSendNoResponse $TxFrame1 0

} ;# Gen_CRC_Error

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForObjectWaittime
# TYPE        : util
# AUTHOR      : kaidi
# DESCRIPTION : Wait until read object receives a specific value (via actual interface) and return the wait time
#  object:   symbolic name, e.g. ETA
#  sollWert: desired value which leads to end
#  timeout:  seconds
#  bitmask:  to check only specified bits
#

#
#END-------------------------------------------------------------------
proc doWaitForObjectWaittime { objekt sollWert timeout {bitmaske 0xffffffff} {TTId ""} {noErrPrint 0}} {
	global Debug_NERA_Storing

	set TTId [Format_TTId $TTId]
	#if {$noErrPrint} {TlPrint "!!!!!doWaitForObject started for: $objekt without error
	# printing!!!!!Timeout: $timeout s"}

	set DebugTimeStart [clock clicks -milliseconds]

	set ExpEnum ""
	set ResEnum ""
	set NameValue ""

	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]

		if [regexp {[^0-9]} $sollWert] {
			return
		}

		set ExpEnum   "=$NameValue"
	}

	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]

	set tryNumber 1
	while {1} {
		after 2   ;# wait 1 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]

		set istWert [doReadModObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			break
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}

		if { [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] } {

			TlPrint "doWaitForObject $objekt exp=act=0x%04X (%d$ExpEnum), waittime (%dms / %d requests)" $sollWert $sollWert $waittime $tryNumber
			#TlPrint  " doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X), waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]   $waittime
			break

		} elseif { [expr $waittime > $timeout] } {

			set diff [expr ($istWert & $bitmaske) ^ ($sollWert  & $bitmaske)]

			if {$objekt == "HMIS"} {
				# Error infos for actual sporadic faults in the testcabinet

				if {( $sollWert != 23) && ( $istWert == 23)} {

					set DP0_Tmp [TlRead "DP0" 1]
					switch $DP0_Tmp {
						27 {
							# INF2
							TlError "*GEDEC00203810* INF2 Fault"
						}
						68 {
							# INF6
							TlError "*GEDEC00203492* INF6 Fault"
						}
						69 {
							# INFE
							TlError "*GEDEC00201702* INFE Fault"
						}
						153 {
							# INFM
							TlError "*GEDEC00203425* INFM Fault"
						}
					}

				}

			}

			if {$noErrPrint} {
				TlPrint "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
			} else {
				if { $bitmaske  == 0xffffffff } {
					TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum), act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				} else {
					TlError "$TTId doWaitForObject $objekt exp=0x%08X (%d$ExpEnum)([ HexToBin $sollWert]), exp&maske= [ HexToBin [expr $sollWert & $bitmaske]]  (0x%08X)  ,   act=0x%08X (%d$ResEnum)([ HexToBin $istWert]), act&maske =  [ HexToBin  [expr $istWert & $bitmaske]] (0x%08X),  diff=0x%08X, waittime (%dms)" $sollWert $sollWert   [expr $sollWert & $bitmaske]  $istWert $istWert [expr $istWert & $bitmaske]  $diff $waittime
				}
			}

			if {$noErrPrint == 0} { ShowStatus }

			return
		}

		incr tryNumber

		if {[CheckBreak]} {break}
	}

	return $waittime
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : doWaitForBooleanFunctionStable
# TYPE        : util
# AUTHOR      : ASY
# DESCRIPTION : Wait until read object receives a specific value and stays at this value during some time to consider
#		the value as stable. The value must stable before timeout value
#		is reached.
#  function :   name of the function to call (casse sensitive)
#  sollWert: desired value 1/0
#  timeout:  seconds
#  stabletime : milliseconds
#
# 2023/08/11 ASY creation of proc
#
#END-------------------------------------------------------------------
proc doWaitForFunctionStable { function sollWert timeout stabletime {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set level $sollWert
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	set istWert ""
	set changeFlag 0
	while {1} {
		after 2   ;# wait 2 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $waittime > $timeout] && !$changeFlag} {
			if {$tryNumber!=1} {
				TlError "$TTId doWaitForFunctionStable $function exp=$level, act=$istWert, waittime (%dms)" $waittime
				if {$noErrPrint == 0} { ShowStatus }
				return 0
			}
		}
		set istWert [eval $function]

		if { [expr $istWert  == $level] } {
			if { !$changeFlag } {
				set startZeit2 [clock clicks -milliseconds]
				set changeFlag 1
				TlPrint "target value reached after [expr $startZeit2 - $startZeit] ms"
			}
			set waittime2 [expr [clock clicks -milliseconds] - $startZeit2]
			if { [expr $waittime2 > $stabletime] } {
				TlPrint "doWaitForFunctionStable $function exp=act=$level , waittime (%dms / %d requests)"  [expr $waittime ] $tryNumber
				return 1
			}
		}
		if { [expr $istWert  != $level]  & $changeFlag} {
			set changeFlag 0
			TlPrint "$function changed from $level to $istWert at $waittime ms after $waittime2 ms of stability"
		}

		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

# Doxygen Tag:
##Function description : For each couple of param/value given as argument, writes and check that the value is taken into acount using modbus.
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/08/23 | ASY | proc created
# \param[in] inputList : list of the parameters and values to write. Start with parameter followed by value to be written. If value to be written is a member of an enumeration, include the . (dot) in the value
# \n
# This function takes a list as argument. Each odd element of the list will be treated as a parameter name and each even element represents the value to be writen using modbus.
# According to this, the number of elements in the list must be even
# This function will return a list containing the couples param/value that were present before the execution.
# Passing this list as argument to the function again will therefore perform a restoration of the original values.
# E.g. use < set initialValues [writeDUTParameters {ACC 30 DEC 30 CHCF .SIM} ]> to write ACC = 30; DEC = 30 and CHCF = .SIM. Store the initial values in variable _initialValues_.
# use < writeDUTParameters $initialValues > to restore initial values.
proc writeDUTParameters { inputList } {
	# check the number of arguments :
	if {[expr [llength $inputList] % 2] == 1} {
		TlError "Incorrect length of data. inputList should have an even number of values"
		return -1
	}
	set memList ""
	#memorization of the inital values
	foreach { param value} $inputList {
		lappend memList $param
		lappend memList [ModTlRead $param]
	}

	#write the values
	foreach {param value} $inputList {
		ModTlWrite $param $value
		doWaitForObject $param $value 1
	}

	#return the original values
	return $memList

}

# Doxygen Tag:
##Function description : This function take a drive parameter ($objekt) and check for it's value ($sollWert)
# the value must stay in a range defined by ($sollWert+$tolerance)&($sollWert-$tolerance)
# and this during a specific duration ($stabletime), before the timeout ($timeout)
# is reached
#
# ## History :
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/08/25 | EDM | proc created
#
# \param[in] objekt : symbolic name, e.g. RFR
# \param[in] sollWert: desired value which leads to end
# \param[in] timeout:  seconds
# \param[in] stabletime : milliseconds
# \param[in] tolerance: will define the range of possible values
# \n
#E.g. use: doWaitForObjectStableRange RFR 500 [expr [TlRead FRH]*[TlRead ACC]/[TlRead FRS]] 1000 20

proc doWaitForObjectStableRange { objekt sollWert timeout stabletime tolerance {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	set istWert ""
	set changeFlag 0
	while {1} {
		after 2   ;# wait 2 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $waittime > $timeout] && !$changeFlag} {
			if {$tryNumber!=1} {
				set diff [expr ($istWert) ^ ($sollWert)]
				TlError "$TTId doWaitForObjectStableRange $objekt exp=0x%08X (%d$ExpEnum), tol= +/- $tolerance, act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				if {$noErrPrint == 0} { ShowStatus }
				return 0
			}
		}
		set istWert [doReadObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		set diff [expr $istWert - $sollWert]
		if {[expr abs($diff)] <= $tolerance} {
			if { !$changeFlag } {
				set startZeit2 [clock clicks -milliseconds]
				set changeFlag 1
				TlPrint "target value reached after [expr $startZeit2 - $startZeit] ms"
			}
			set waittime2 [expr [clock clicks -milliseconds] - $startZeit2]
			if { [expr $waittime2 > $stabletime] } {
				TlPrint "doWaitForObjectStableRange $objekt has been stable between %d and %d, waittime (%dms / %d requests)" [expr ($sollWert-$tolerance)] [expr ($sollWert+$tolerance)] [expr $waittime ] $tryNumber
				return 1
			}
		}
		if {[expr abs($diff)] > $tolerance  & $changeFlag} {
			set changeFlag 0
			TlPrint "$objekt changed from $sollWert to $istWert at $waittime ms after $waittime2 ms of stability"
		}

		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

# Doxygen Tag:
##Function description : This function take a drive parameter ($objekt) and check for it's value ($sollWert)
# the value must stay in a range defined by ($sollWert+$tolerance)&($sollWert-$tolerance)
# and this during a specific duration ($stabletime), before the timeout ($timeout)
# is reached. All reads commands will be done by MOD.
#
# ## History :
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/08/25 | EDM | proc created
#
# \param[in] objekt : symbolic name, e.g. RFR
# \param[in] sollWert: desired value which leads to end
# \param[in] timeout:  seconds
# \param[in] stabletime : milliseconds
# \param[in] tolerance: will define the range of possible values
# \n
#E.g. use: doWaitForModObjectStableRange RFR 500 [expr [TlRead FRH]*[TlRead ACC]/[TlRead FRS]] 1000 20

proc doWaitForModObjectStableRange { objekt sollWert timeout stabletime tolerance {TTId ""} {noErrPrint 0}} {
	set TTId [Format_TTId $TTId]
	set ExpEnum ""
	set ResEnum ""
	set NameValue ""
	set ListOfValue [split $sollWert {}]
	if {[lindex $ListOfValue 0] == "."} {
		set NameValue [lrange $ListOfValue 1 end]
		set NameValue [join $NameValue ""]
		set sollWert  [Enum_Value $objekt $NameValue]
		if [regexp {[^0-9]} $sollWert] {
			return
		}
		set ExpEnum   "=$NameValue"
	}
	set startZeit [clock clicks -milliseconds]
	set timeout   [expr int ($timeout * 1000)]
	set tryNumber 1
	set istWert ""
	set changeFlag 0
	while {1} {
		after 2   ;# wait 2 mS
		update idletasks
		set waittime [expr [clock clicks -milliseconds] - $startZeit]
		if { [expr $waittime > $timeout] && !$changeFlag} {
			if {$tryNumber!=1} {
				set diff [expr ($istWert) ^ ($sollWert)]
				TlError "$TTId doWaitForModObjectStableRange $objekt exp=0x%08X (%d$ExpEnum), tol= +/- $tolerance, act=0x%08X (%d$ResEnum),diff=0x%08X, waittime (%dms)" $sollWert $sollWert $istWert $istWert $diff $waittime
				if {$noErrPrint == 0} { ShowStatus }
				return 0
			}
		}
		set istWert [doReadModObject $objekt "" 0 $noErrPrint $TTId]
		if { $istWert == "" } then {
			if {$noErrPrint == 0} {
				TlError "illegal RxFrame received"
			}
			return 0
		} else {
			if { $ExpEnum != "" } {
				set ResEnum [Enum_Name $objekt $istWert]
				set ResEnum "=$ResEnum"
			} else {
				set ResEnum ""
			}
		}
		set diff [expr $istWert - $sollWert]
		if {[expr abs($diff)] <= $tolerance} {
			if { !$changeFlag } {
				set startZeit2 [clock clicks -milliseconds]
				set changeFlag 1
				TlPrint "target value reached after [expr $startZeit2 - $startZeit] ms"
			}
			set waittime2 [expr [clock clicks -milliseconds] - $startZeit2]
			if { [expr $waittime2 > $stabletime] } {
				TlPrint "doWaitForModObjectStableRange $objekt has been stable between %d and %d, waittime (%dms / %d requests)" [expr ($sollWert-$tolerance)] [expr ($sollWert+$tolerance)] [expr $waittime ] $tryNumber
				return 1
			}
		}
		if {[expr abs($diff)] > $tolerance  & $changeFlag} {
			set changeFlag 0
			TlPrint "$objekt changed from $sollWert to $istWert at $waittime ms after $waittime2 ms of stability"
		}

		incr tryNumber
		if {[CheckBreak]} {break}
	}
	return $istWert
}

# Doxygen Tag:
##Function description : Returns the value of the global variable "theTestTclFilename"
## WHEN      |  WHO  | WHAT
# -----------| ------| -----
# 2023/10/10 | Yahya | proc created
# \n
# This function is used to get the value of the global variable "theTestTclFilename" without any risk of altering its value
# use < getTheTestTclFilename > to get the value of the global variable "theTestTclFilename".
proc getTheTestTclFilename { } {
	global theTestTclFilename

	return $theTestTclFilename
}

# Doxygen Tag:
##Function description : Returns the name of the ALTILAB_KOP file to use
## WHEN      |  WHO  | WHAT
# -----------| ------| -----
# 2023/10/25 | ASY | proc created
# \n
# This function is used to get the ALTILAB KOP filename
# use < getTheAltilabKOPFilename > to get the value of the altilab kop file to use with ReadParaFile_Altilab
proc getTheAltilabKOPFilename { } {

	global DevType ActDev mainpath
	set theAltiLabParameterFile ""
	switch $DevType($ActDev,Type) {

		"ATS48P" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_ATS48P.xml"
		}
		"OPTIM" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_OPTIM.xml"
		}
		"BASIC" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_BASIC.xml"
		}

		"Altivar" {
			append theAltiLabParameterFile  $mainpath "/ObjektDB/R3Dev_PrmUnifiedMappingSimulatorGen.sim"

		}
		"Opal" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_OPAL_CS.xml"
		}
		"Nera" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_NERA.xml"
		}
		"Beidou" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_BEIDOU.xml"
		}
		"Fortis" {
			if {[GetDevFeat "ShadowOffer"]} {
				append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_SHADOWF.xml"
			} else {
				append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_Fortis.xml"
			}
		}
		"MVK" {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_MVK.xml"
		}

		default {
			append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_$DevType($ActDev,Type).xml"
		}
	}
	return $theAltiLabParameterFile
}

# Doxygen Tag:
##Function description : Function to check on PACY_APP_FLEX tower that the connectors are pluged to the proper device.
## WHEN      |  WHO  | WHAT
# -----------| ------| -----
# 2024/01/25 | ASY | proc created
# \n
# This function is used to check that the connectors are pluged to the proper device for the PACY_APP_FLEX tower
# use < checkPlug >
proc checkPlug { } {
	global DevType
	global sePLC
	if {![GetSysFeat "PACY_APP_FLEX"]} {
		#function usable only on PACY_APP_FLEX tower
		TlError "checkPlug Function not available on this tower"
		return -1
	}
	#Find the expected value according to the device type
	array set checkValues {
		"Altivar" 1
		"Opal"    2
		"Nera"    3
		"Fortis"  4
		1   "Altivar"
		2   "Opal"
		3   "Nera"
		4   "Fortis"
	}
	if { [catch {set checkValue $checkValues($DevType(1,Type))} ]} {
		#DeviceType not in the array, not handled
		TlError "Device $DevType(1,Type) not supported"
		return -1
	}

	set plugValue [wc_TCP_ReadWord [expr  $sePLC(towerStructureOffset) + 6 ] 1] ;# read word from the plc
	if { $checkValue != $plugValue } {
		TlPrint "========================================================================================================="
		TlError " Incorrect device pluged expected : $DevType(1,Type) , pluged $checkValues($plugValue)"
		TlPrint "========================================================================================================="
	}
}

# Doxygen Tag:
##Function description :Function that returns the motor synchronism speed
## WHEN      |  WHO  | WHAT
# -----------| ------| -----
# 2024/07/04 | ASY   | proc created
# 2024/08/12 | ASY   | update to handle synchronous motors issue #2619
# \n
# use < set speed [sys_getSynchSpeed] >
proc sys_getSynchSpeed { } {
    global ActDev MotParam MotSMParam
    #check if the data is set in the ini file.
    if {[GetDevFeat "MotASM"]} {;# in case of asynchronous motor 
        #if yes use the value from the ini file, otherwise use 1 pair of poles which is the most common value
        if { [info exists MotParam($ActDev,PolePairs)] } {
            return [expr 3000 / $MotParam($ActDev,PolePairs)]
        } else {
            return [expr 3000 / 1]
        }
    } else {
        return $MotSMParam($ActDev,NSPS)
    }
}

# Doxygen Tag:
##Function description :Function that returns time needed for acceleration / deceleration / Stop
## WHEN      |  WHO  | WHAT
# -----------| ------| -----
#/param[in] movementType : movement type (possible values : ACC / DEC / STOP)
#/param[in] tolerance : tolerance in % that is added to the calculated time
# 2025/02/26 | Yahya | proc created
# \n
# use < doWaitForObject HMIS .RUN [calculateTimeout] >
proc calculateTimeout { movementType {tolerance 10} } {

    set timeout 0

    switch $movementType {
	"ACC" {
	    if {[GetDevFeat "MotASM"]} {;# in case of asynchronous motor 
		set timeout [expr abs(double([TlRead FRH]-[TlRead RFR]))*[TlRead ACC]/[TlRead FRS] * (0.1 + $tolerance / 1000.0)] ;#Time needed for acc
	    } else { ;# in case of synchronous motor 
		set timeout [expr abs(double([TlRead FRH]-[TlRead RFR]))*[TlRead ACC]/[TlRead FRSS] * (0.1 + $tolerance / 1000.0)] ;#Time needed for acc
	    }
	}
	"DEC" {
	    if {[GetDevFeat "MotASM"]} {;# in case of asynchronous motor 
		set timeout [expr abs(double([TlRead FRH]-[TlRead RFR]))*[TlRead DEC]/[TlRead FRS] * (0.1 + $tolerance / 1000.0)] ;#Time needed for dec
	    } else { ;# in case of synchronous motor 
		set timeout [expr abs(double([TlRead FRH]-[TlRead RFR]))*[TlRead DEC]/[TlRead FRSS] *  (0.1 + $tolerance / 1000.0)];#Time needed for dec
	    }
	}
	"STOP" {
	    if {[GetDevFeat "MotASM"]} {;# in case of asynchronous motor 
		set timeout [expr abs(double([TlRead RFR]))*[TlRead DEC]/[TlRead FRS] * (0.1 + $tolerance / 1000.0)] ;#Time needed for stop
	    } else { ;# in case of synchronous motor 
		set timeout [expr abs(double([TlRead RFR]))*[TlRead DEC]/[TlRead FRSS] *  (0.1 + $tolerance / 1000.0)];#Time needed for stop
	    }
	}
	default {
	    TlError "movementType $movementType is not taken into account, it should be : ACC / DEC / STOP"
	}
    }

    return $timeout
}


# Doxygen Tag:
## Function description : Workaround to avoid BRA set to YES due to function not implemented in early phase of K2 project 
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2024/10/02| ASY  | proc created
# 2025/01/16| ASY  | update due date 
proc BRA_WorkaroundUntilDate_GitHubIssue_2876 { } {
    set expectedFixDate "31/03/2025"
    set todayDate [clock format [clock seconds] -format "%d/%m/%Y"]
    	#Handle cases where device is not K2
	if {![GetDevFeat "K2"]} { return }
	
	if {[clock scan $todayDate -format "%d/%m/%Y" ] > [clock scan $expectedFixDate -format "%d/%m/%Y" ]} {
	    TlError "expected fix date is passed ==> check if issue 2876 is closed to remove this workaround or update fixDate"
	} else {
	    TlWrite BRA .NO 
	    doWaitForObject BRA .NO 1
	    doStoreEEPROM
	}
}

# Doxygen Tag:
## Function description : Checks the defaults value of a parameter.
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2024/10/02| ASY  | proc created
proc dut_checkDefaultValue {Param DefaultValue {FacSetting 1} {TTid ""} } {

    TlPrint "______________________________________"
    TlPrint "== Check default value             ==="
    TlPrint "______________________________________"
    #Check parameter factory setting
    if {$FacSetting ==1 } {
        doSetDefaults 1
    } 
    doWaitForObject $Param $DefaultValue 1 0xFFFFFFFF $TTid

}

# Doxygen Tag:
## Function description : Checks that the values given as arguments can be set to the parameter.
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2024/10/02| ASY  | proc created
proc dut_checkPermittedValues { Param ListOfValues {TTid ""}} {
    foreach value $ListOfValues {

        TlPrint "______________________________________"
        TlPrint "== Check $Param can be set to $value             ==="
        TlPrint "______________________________________"
        TlWrite $Param $value 
        doWaitForObject $Param $value 1 0xffffffff $TTid
	doWaitForNotObject HMIS .FLT 1 0xFFFF $TTid
    }
}
# Doxygen Tag:
## Function description : Checks that the writing of the value to the parameter generates a CFI.
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2024/10/02| ASY  | proc created
proc dut_checkCFITriggered { Param Value {TTid ""}} {

    TlPrint "______________________________________"
    TlPrint "== Check writing $Value to $Param generated CFI       ==="
    TlPrint "______________________________________"
    set memValue [TlRead $Param]
    TlWrite $Param $Value 
    doWaitForObject HMIS .FLT 1 0xffff $TTid
    doWaitForObject DP0 .CFI 1 0xffff $TTid
    TlPrint "______________________________________"
    TlPrint "== Check writing correct value to $Param resets CFI       ==="
    TlPrint "______________________________________"
    TlWrite $Param $memValue 
    doWaitForObject $Param $memValue 1 0xffff $TTid
    doWaitForNotObject HMIS .FLT 1 0xFFFF $TTid 
}

# Doxygen Tag:
## Function description : Checks a parameter default, min and max values, write in run and memorization.
#
# WHEN	    | WHO  | WHAT
# ----------| -----| -----
# 2024/10/02| ASY  | proc created
proc dut_checkParam {Param DefaultValue MinValue MaxValue Type {FacSetting 1} {TTId ""} } {

    global ActDev
    set memParamValue [TlRead $Param]
    set DataParam [GetParaAttributes $Param]
    set ParaType  [lindex $DataParam 3]
    dut_checkDefaultValue $Param $DefaultValue $FacSetting $TTId



    TlPrint "______________________________________"
    TlPrint "== Check min and max values        ==="
    TlPrint "______________________________________"
    #Check Min max
    TlWrite $Param $MinValue
    doWaitForObject $Param $MinValue 1 0xffffffff $TTId  
    TlWrite $Param $MaxValue
    doWaitForObject $Param $MaxValue 1 0xffffffff $TTId 

    TlPrint "______________________________________"
    TlPrint "== Check min - 1 when possible     ==="
    TlPrint "______________________________________"
    #Check min - 1 when possible 
    if { $MinValue != 0 } { 
        TlWrite $Param [ expr ($MinValue-1)]
        doWaitForObject $Param $MinValue 1 0xffffffff $TTId 
        if { $Type == "CONF"} {
            doWaitForObject HMIS .FLT 1
            doWaitForObject LFT .CFI 1
            TlWrite $Param $MinValue
        }
    } else {
		TlPrint "Min value is 0, min - 1 not possible"
	}

    TlPrint "______________________________________"
    TlPrint "== Check max + 1 when possible     ==="
    TlPrint "______________________________________"
    #Check max + 1 when possible 
    if { $MaxValue != 65535 } { 
        TlWrite $Param [ expr ($MaxValue+1)]
        doWaitForObject $Param $MaxValue 1 0xffffffff $TTId 
        if { $Type == "CONF"} {
            doWaitForObject HMIS .FLT 1
            doWaitForObject LFT .CFI 1
            TlWrite $Param $MaxValue
			doWaitForNotObject HMIS .FLT 1
        }
    } else {
		TlPrint "Max value is 65535, max + 1 not possible"
	}


    TlPrint "______________________________________"
    TlPrint "== Check write in run              ==="
    TlPrint "______________________________________"
	#Reset parameter to initial value 
	TlWrite $Param $memParamValue
    #Check Run modification
    doWaitForObject HMIS .RDY 1
    setDI 1 H
    doWaitForModState ">=4" 20       ;# expected values: RUN, ACC, DEC...
    doWaitForObjectStable HMIS .RUN 20 1
    if {$Type == "CONF" } {
        TlWriteAbort $Param $MinValue 
        doWaitForObject $Param $MaxValue 1
    } else {
        TlWrite $Param $MinValue
        doWaitForObject $Param $MinValue 1 0xffffffff $TTId
    }
    setDI 1 L

    #Check EEprom memo

    TlPrint "______________________________________"
    TlPrint "== Check memorization             ==="
    TlPrint "______________________________________"
    DeviceOff $ActDev 1
    DeviceOn $ActDev 1 

    doWaitForModState .RDY 60
    doWaitForObject $Param $DefaultValue 1 0xffffffff $TTId
    TlWrite $Param $MinValue
    doWaitForObject $Param $MinValue 1 0xffffffff $TTId
    doStoreEEPROM

    DeviceOff $ActDev 1
    DeviceOn $ActDev 1 
    doWaitForModState .RDY 20
    doWaitForObject $Param $MinValue 1 0xffffffff $TTId

    TlPrint "_______________________________________"
    TlPrint "== End of test, restore init value   =="
    TlPrint "_______________________________________"
    TlWrite $Param $memParamValue 
    doWaitForObject $Param $memParamValue 1
	doStoreEEPROM

    TlPrint "_______________________________________"
    TlPrint "== End of dut_checkParam             =="
    TlPrint "_______________________________________"

}

# Doxygen Tag:
##Function description : Sets a function to a virtual bit according to the bus in use 
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/07/06 | ASY | proc created
# \n
# E.g. use < setVirtualBit RCB 15 > to set RCB to C315 or C515 according to the bus in use. \n 
# if the currentBus is _PNV2_ then RCB will be set to C315. If currentBus is EIP then RCB will be set to C515.
proc setVirtualBit { param bit} {
    if {![string is integer $bit] } {
        TlError "virtual bit to link to $param is not an integer" 
        return -1
    }
    if { $bit < 11 || $bit > 15 } {
        TlError "Virtual bit ($bit) out of the permitted range (11..15) to link to the $param function"
        return -2
    }
    #check if this function is used in the GNGRules context 
    if {[info exists GNGRULES::currentBus] && $GNGRULES::currentBus != ""} {
        switch $GNGRULES::currentBus {
            "PNV2" {
                set virtualBit "C3$bit"
            }

            "EIP" { 
                set virtualBit "C5$bit"
            }

            default {  
                TlError "Bus $GNGRULES::currentBus not yet supported for function setVirtualBit" 
                return -1 
            }
        }
    } else {
        if {[GetDevFeat "BusProfisafe"] } {
            set virtualBit "C3$bit"
        } elseif {[GetDevFeat "BusCIPSafety"] } {
            set virtualBit "C5$bit"
        } else {
	    TlError "Bus is not yet supported for function setVirtualBit" 
	    return -1
        }
    }
    TlWrite $param .$virtualBit 
    doWaitForObject $param .$virtualBit 1
    return 1
}

# Doxygen Tag:
##Function description : Sets the drive's parameter given as argument to a value according to the bus in use. 
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2024/10/04 | ASY | proc created
# \n
# E.g. use < setParamToComInterface CD1 > to set CD1 to NET or ETH according to the bus in use. \n 
# if the currentBus is _PNV2_ then CD1 will be set to NET. If currentBus is EIP then CD1 will be set to ETH.
proc setParamToComInterface { param } {
    if {[info exists GNGRULES::currentBus] && $GNGRULES::currentBus != ""} {
        switch $GNGRULES::currentBus {
            "PNV2" {
                TlWrite $param .NET
                doWaitForObject $param .NET 1
            }


            "EIP" { 
                if {[GetDevFeat "Card_AdvEmbedded"] || [GetDevFeat "BusCIPSafety"]} {
                    TlWrite $param .ETH 
                    doWaitForObject $param .ETH 1

                } else {
                    TlWrite $param .NET
                    doWaitForObject $param .NET 1	
                }
            }

            default {  
                TlError "Bus $GNGRULES::currentBus not yet supported for function setParamToComInterface" 
                return -1 
            }
        }
    } else { ;# handling cipsafety/profisafe
        if {[GetDevFeat "BusCIPSafety"] } {
            TlWrite $param .ETH 
            doWaitForObject $param .ETH 1
        } elseif {[GetDevFeat "BusProfisafe"]} {
            TlWrite $param .NET 
            doWaitForObject $param .NET 1
        } else {
            TlError "Bus not yet supported for function setParamToComInterface"
            return -1
        }
    }

    return 1
}

# Doxygen Tag:
##Function description : This proc is used for ATVPredict commissioning (see Issue #3262)
# WHEN       | WHO   | WHAT
# -----------| ------| -----
# 2024/12/06 | Yahya | proc created (see Issue #3262)
# 2025/01/16 | SES	 | proc updated (see Issue #3473)
# \n
proc ATVPredictCommissioning { } {
	#Activate ATV predict
    TlWrite APM .YES
    doWaitForObject APM .YES 1
	#Initialize VSD RUL 
	TlWrite VRUL 130	;# Value different from default
	doWaitForObject VRUL 130 1
	TlWrite LFRS 3
	doWaitForObject LFRS 0 1 ;# The LFRS values are not saved Instead checked in the follwing instruction
	doWaitForObject XVL 130 1 ;# For VRUL = 130
	TlWrite PRUL 120	;# Value different from default
	doWaitForObject PRUL 120 1
	TlWrite LFRS 1
	doWaitForObject LFRS 0 1 ;# The LFRS values are not saved Instead checked in the follwing instruction
	doWaitForObject XPL 120 1 ;# For PRUL = 120
	
    #Setting drive params 
    TlWrite PS1A 1
    doWaitForObject PS1A 1 1
    TlWrite PS2A 2
    doWaitForObject PS2A 2 1
    TlWrite FS1A 3
    doWaitForObject FS1A 3 1
    TlWrite FS2A 3
    doWaitForObject FS2A 3 1
    TlWrite AI1T 1
    doWaitForObject AI1T 1 1
    TlWrite AI1K 3000
    doWaitForObject AI1K 3000 1
    TlWrite AI1J -1000
    doWaitForObject AI1J -1000 1
    TlWrite AI2T 1
    doWaitForObject AI2T 1 1
    TlWrite AI2K 6000
    doWaitForObject AI2K 6000 1
    TlWrite AI2J 0
    doWaitForObject AI2J 0 1
    TlWrite AI3T 1
    doWaitForObject AI3T 1 1
    TlWrite AI3K 800
    doWaitForObject AI3K 800 1
    TlWrite AI3J 0
    doWaitForObject AI3J 0 1

    #Setting pump params
	TlWrite PCM 4
	doWaitForObject PCM 4 1
    TlWrite PCBQ 200
    doWaitForObject PCBQ 200 1
    TlWrite PCBP 542
    doWaitForObject PCBP 542 1
    TlWrite PCBH 4422
    doWaitForObject PCBH 4422 1
    TlWrite PCSP 2900
    doWaitForObject PCSP 2900 1
    TlWrite PCQ1 20
    doWaitForObject PCQ1 20 1
    TlWrite PCQ2 80
    doWaitForObject PCQ2 80 1
    TlWrite PCQ3 140
    doWaitForObject PCQ3 140 1
    TlWrite PCQ4 200
    doWaitForObject PCQ4 200 1
    TlWrite PCQ5 240
    doWaitForObject PCQ5 240 1
    TlWrite PCH1 5304
    doWaitForObject PCH1 5304 1
    TlWrite PCH2 5325
    doWaitForObject PCH2 5325 1
    TlWrite PCH3 5044
    doWaitForObject PCH3 5044 1
    TlWrite PCH4 4450
    doWaitForObject PCH4 4450 1
    TlWrite PCH5 3665
    doWaitForObject PCH5 3665 1
    TlWrite PCP1 312
    doWaitForObject PCP1 312 1
    TlWrite PCP2 397
    doWaitForObject PCP2 397 1
    TlWrite PCP3 482
    doWaitForObject PCP3 482 1
    TlWrite PCP4 542
    doWaitForObject PCP4 542 1
    TlWrite PCP5 578
    doWaitForObject PCP5 578 1
    TlWrite PCR1 51
    doWaitForObject PCR1 51 1
    TlWrite PCR2 72
    doWaitForObject PCR2 72 1
    TlWrite PCR3 119
    doWaitForObject PCR3 119 1
    TlWrite PCR4 186
    doWaitForObject PCR4 186 1
    TlWrite PCR5 264
    doWaitForObject PCR5 264 1
    TlWrite SUPR 1
    doWaitForObject SUPR 1 1
    TlWrite SUFR 10
    doWaitForObject SUFR 10 1
	TlWrite PCBQ 200
	doWaitForObject PCBQ 200 1
	TlWrite PCA 1
	doWaitForObject PCA 1 1
	TlWrite APCS 2
	doWaitForObject APCS 2 1
	TlWrite CMI 2
	doWaitForEEPROMFinished 10
}
