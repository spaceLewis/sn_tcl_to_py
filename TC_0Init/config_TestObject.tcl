# Filename     :  confTestObject.tcl
#
# Configuration of testdevice:
# - BLE-File Download
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# xxxxxx rothf file from CPD adapted
# 300708 pfeig WriteBleFile switched to MOD in writeall
# 251113 serio Add call to function initialization
# 160614 serio Adapt testfilestart for Beidou Project
# 181214 serio remove proc setP24Supply
# 280115 serio Write complete device name to PCN parameters
# 040315 serio Add GEDEC00193249
# 170315 serio add Fortis case to WriteAdr for embedded ethernet
# 300315 serio modify WriteAdr to use writeIpBas
# 240415 serio include Calibration in TC0Init for statistic purposes
# 280415 serio remove Calibration in TC0Init

# TlDebugLevel 0

global TestModus
global ConfigBLE
global COMPUTERNAME
global ActDev
global PrgNr
# Ver Dat

if { ![info exists EthernetBus] } {

    set EthernetBus  ""
}

append_test theTestProcList TC_0Init_TestfileStart       {DevAll !OPTIM !ATS48P !BASIC -Robustness}
append_test theTestProcList TC_0Init_InitAllDevices      {DevAll !OPTIM !ATS48P !BASIC -Robustness}
append_test theTestProcList TC_0Init_TestfileStop        {DevAll !OPTIM !ATS48P !BASIC -Robustness}
append_test theTestProcList TC_0Init_ATSInit		{ OPTIM ATS48P BASIC -Robustness}

append_test theTestProcList InitAfterFlash               {!OPTIM !ATS48P !BASIC}

# Doxygen Tag :
##Function description : Restore tower to initial setting
#Call the clear before night function
# ## HISTORY
# WHEN  | WHO  | WATH
# -----| -----| -----
# 2021/10/04 |  ASY  | created file
# 2024/09/03 | Yahya | Added TlTestCase in proc TC_0Init_ATSInit (Issue #2737)
proc TC_0Init_ATSInit {} {

    TlTestCase "TC_0Init_ATSInit"
    ATS_ClearBeforeNight
    initDBLogCampaignHeader
}

append_test theTestProcList InitAfterFlash               {}

#----------------------------------------------------------------------------------------------------
# Switch on device
proc TC_0Init_TestfileStart {} {
   global ActDev DevAdr DevType
   global GlobErr
   global theTestDevList theDevList
   global ATVapplVer  ATVapplBuild
   global ATVplatVer  ATVplatBuild
   global ATVmotVer   ATVmotBuild
   global ATVbootVer  ATVbootBuild
   global ATVdspVer   ATVdspBuild
   global ATVcpldVer  ATVcpldBuild
   global ATVembdType ATVembdVer ATVembdBuild
   global ATVmodType  ATVmodVer  ATVmodBuild
   global ATVmod2Type ATVmod2Ver ATVmod2Build
   global ATVmod3Type ATVmod3Ver ATVmod3Build
   global theNERAParaNameRecord

   TlTestCase "Start test file"

   #switch off all digital outputs of wago controller at the very beginning of tests
   wc_ResetDigiOuts
	
   #STO management for CIP safety firmware
	if {[GetDevFeat "FW_CIPSFTY"]} {
		wc_SetSTOex 1 "H"	
	}
#Reset the power supply of components (PLC/switches) according to tower and campaign needs	
    if {[GetSysFeat "thirdPartyPLC"]} {
        if {[GetSysFeat "PACY_SFTY_FIELDBUS"]} {
            if {[GetDevFeat "BusProfisafe"] || [GetDevFeat "BusPNV2"]} {
                plcPowerSupply 5 H
                plcPowerSupply 4 L
                switchPowerSupply 2 L 
                switchPowerSupply 3 H
            } elseif {[GetDevFeat "BusCIPSafety"]} {
                global CIPSafetyComIndex
                plcPowerSupply 5 L
                plcPowerSupply 4 H
                switchPowerSupply 2 H 
                switchPowerSupply 3 L
                doWaitForPing $CIPSafetyComIndex(CIPSafetyPLC_address) 120000
                set rc [catch {mb2Open TCP $CIPSafetyComIndex(CIPSafetyPLC_address) 1}]
                if {$rc != 0 } {
                    TlError "Impossible to open connection towards CIPSafety PLC"
                } else {
                    set CIPSafetyComIndex(CIPSafetyPLC_openConnection) 1
                }
            }
        }
    }

    if {[GetSysFeat "MotorSelection"]} {
	    selectMotor $DevType($ActDev,MotorIndex) 
    }
   #Restart the communication on the Ethercat Tower
   fieldbusInterruptConnection l 0
   #Display and check versions of all devices present in list
   set ActDevOld $ActDev         ;#Initial address
	
   foreach ActDev $theDevList {
	   
      TlPrint ""
      TlPrint ""
      TlPrint "##############################################################"
      TlPrint " TC_0Init_TestfileStart    start Dev $ActDev"
      TlPrint "##############################################################"

      set ActAdr $DevAdr($ActDev,MOD)

      #TlPrint "Switch on Device $ActDev with address $ActAdr"
      TlPrint "Change modbus address to 0xF8"
      set DevAdr($ActDev,MOD) 0xF8

      TlPrint "Switch on Device $ActDev"
      DeviceOn $ActDev 0 ">=0" 90

      if {[GetDevFeat "Altivar"]} {
         set ATVplatVer   [format "%04X" [doReadObject C1SV]]
         set ATVplatBuild [format "%04X" [doReadObject C1SB]]
         set ATVdspVer    [format "%04X" [doReadObject C2SV]]
         set ATVdspBuild  [format "%04X" [doReadObject C2SB]]
         set ATVcpldVer   [format "%04X" [doReadObject C2SV]]
         set ATVcpldBuild [format "%04X" [doReadObject C2SB]]
      }

      if { [doPrintObject C1SV] } {
         doPrintObject ADD
         WriteReportHead
      } else {
         TlError "No connection to device"
         return
      }

      #----------------------------------------
      # Error entry to determine the number of runs

      set GlobErr 0

      TlPrint ""

         set VersionString0 [format "Dummy Err of Program $theTestDevList V%X.%Xie%02X B%02X b%02X, OptionBoard1 V%X.%Xie%02X B%02X b%02X"   \
            "0x[string range $ATVapplVer 0 0]" "0x[string range $ATVapplVer 1 1]" "0x[string range $ATVapplVer 2 3]" "0x[string range $ATVapplBuild 0 1]" "0x[string range $ATVapplBuild 2 3]" \
            "0x[string range $ATVmodVer  0 0]" "0x[string range $ATVmodVer  1 1]" "0x[string range $ATVmodVer  2 3]" "0x[string range $ATVmodBuild  0 1]" "0x[string range $ATVmodBuild 2 3]"]


      set VersionStringP [format "Platform                                     : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVplatVer 0 0]" "0x[string range $ATVplatVer 1 1]" "0x[string range $ATVplatVer 2 3]" "0x[string range $ATVplatBuild 0 1]" "0x[string range $ATVplatBuild 2 3]"]
      set VersionString1 [format "Application (M3 SwVersion)                   : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVapplVer 0 0]" "0x[string range $ATVapplVer 1 1]" "0x[string range $ATVapplVer 2 3]" "0x[string range $ATVapplBuild 0 1]" "0x[string range $ATVapplBuild 2 3]"]
      set VersionString2 [format "Motor control (CpuPower SwVersion)           : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVmotVer  0 0]" "0x[string range $ATVmotVer  1 1]" "0x[string range $ATVmotVer  2 3]" "0x[string range $ATVmotBuild  0 1]" "0x[string range $ATVbootBuild 2 3]"]
      set VersionString3 [format "Boot version                                 : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVbootVer 0 0]" "0x[string range $ATVbootVer 1 1]" "0x[string range $ATVbootVer 2 3]" "0x[string range $ATVbootBuild 0 1]" "0x[string range $ATVbootBuild 2 3]"]
      set VersionString4 [format "DSP version (C28 SwVersion)                  : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVdspVer  0 0]" "0x[string range $ATVdspVer  1 1]" "0x[string range $ATVdspVer  2 3]" "0x[string range $ATVdspBuild  0 1]" "0x[string range $ATVbootBuild 2 3]"]
      set VersionString5 [format "CPLD version (CPLD SwVersion)                : V%X.%Xie%02X B%02X b%02X" "0x[string range $ATVcpldVer 0 0]" "0x[string range $ATVcpldVer 1 1]" "0x[string range $ATVcpldVer 2 3]" "0x[string range $ATVcpldBuild 0 1]" "0x[string range $ATVbootBuild 2 3]"]

      if {[GetDevFeat "Nera"] || [GetDevFeat "Fortis"] || [GetDevFeat "MVK"] || ([GetDevFeat "Opal"] && [GetDevFeat "Card_AdvEmbedded"])} {
         set VersionString6 [format "Ethernet Embedded (EmbEth compatibility): CT=%s V%X.%Xie%02X B%02X b%02X" $ATVembdType                  "0x[string range $ATVembdVer 0 0]" "0x[string range $ATVembdVer 1 1]" "0x[string range $ATVembdVer 2 3]" "0x[string range $ATVembdBuild 0 1]" "0x[string range $ATVbootBuild 2 3]"]
      } else {
         set VersionString6 ""
      }

      set VersionString7 [format "Option Board 1                               : CT=%s V%X.%Xie%02X B%02X b%02X" [Enum_Name O1CT $ATVmodType ] "0x[string range $ATVmodVer  0 0]" "0x[string range $ATVmodVer  1 1]" "0x[string range $ATVmodVer  2 3]" "0x[string range $ATVmodBuild  0 1]" "0x[string range $ATVbootBuild 2 3]"]

      if {![GetDevFeat "Beidou"] & ![GetDevFeat "Altivar"] } {
         set VersionString8 [format "Option Board 2                               : CT=%s V%X.%Xie%02X B%02X b%02X" [Enum_Name O2CT $ATVmod2Type] "0x[string range $ATVmod2Ver 0 0]" "0x[string range $ATVmod2Ver 1 1]" "0x[string range $ATVmod2Ver 2 3]" "0x[string range $ATVmod2Build 0 1]" "0x[string range $ATVbootBuild 2 3]"]
      } else {
         set VersionString8 ""
      }

      if {[info exists theNERAParaNameRecord(O3CT)]} {
         set VersionString9 [format "Option Board 3                               : CT=%s V%X.%Xie%02X B%02X b%02X" [Enum_Name O3CT $ATVmod3Type] "0x[string range $ATVmod3Ver 0 0]" "0x[string range $ATVmod3Ver 1 1]" "0x[string range $ATVmod3Ver 2 3]" "0x[string range $ATVmod3Build 0 1]" "0x[string range $ATVbootBuild 2 3]"]
      } else {
         set VersionString9 ""
      }

	set args ""
	TlPrintIntern E "$VersionString0                </br>$VersionString1</br>$VersionStringP</br>$VersionString2</br>$VersionString3</br>$VersionString4</br>$VersionString5</br>$VersionString6</br>$VersionString7</br>$VersionString8</br>$VersionString9" args

      TlPrint ""

      TlPrint $VersionString1
      TlPrint $VersionStringP
      TlPrint $VersionString2
      TlPrint $VersionString3
      TlPrint $VersionString4
      TlPrint $VersionString5
      TlPrint $VersionString6
      TlPrint $VersionString7
      TlPrint $VersionString8
      TlPrint $VersionString9

	TlPrint ""

	#Check all versions of device and option boards
	set GlobErr 0
	if {![GetDevFeat "Altivar"] && ![GetDevFeat "K2"]} {
		checkVersion
	}
	

	TlPrint ""
	TlPrint ""

	TlPrint "Change modbus address to $ActAdr"
	set DevAdr($ActDev,MOD) $ActAdr

	DeviceOff $ActDev 1
    }
    set ActDev $ActDevOld      ;#Reset initial address

}  ;#TestfileStart

#----------------------------------------------------------------------------------------------------
# Switch off Device(s)
proc TC_0Init_TestfileStop {} {
    global ActDev DevAdr

    TlTestCase "Stop test file"

} ;#TestfileStop

#======================================================================
proc TC_0Init_InitAllDevices { {Bus ""} } {
    global ActDev theDevList
    global theSafetyParamFile theSafetyErrorFile

    #Ini files call before starting init
    TlPrint "Ini file call to reinitialize all values like at interpreter startup"
    ReadConfigValues

    # switch to Modbus for universal addressing work
    TlPrint "use Tl commands with modbus interface"
    doSetCmdInterface "MOD"

    set ActDevOld $ActDev

    foreach ActDev $theDevList {

	TlPrint ""
	TlPrint ""
	TlPrint "##############################################################"
	TlPrint " TC_0Init_InitAllDevices    initialize Dev $ActDev"
	TlPrint "##############################################################"

	InitActDevice $Bus

    }

    set ActDev $ActDevOld
    if {[GetDevFeat "Altivar"] } {
	ReadParaFile_ATV [getTheAltilabKOPFilename]
    } else {
	ReadParaFile_AltiLab [getTheAltilabKOPFilename]
    }
    if {[GetDevFeat "Modul_SM1"]} {
	ReadParaFile_Safety     $theSafetyParamFile
	ReadErrorFile_Safety    $theSafetyErrorFile
	SM_ReadMappingFiles
    }
    if {[GetDevFeat "BusCIPSafety"]} {
	ReadErrorFile_Safety    $theSafetyErrorFile
    }
    if {[GetDevFeat "FortisLoad"]} {
	LoadOn 
	doWaitMs 2500
	initFortisLoad
	LoadOff 
	doWaitMs 10000
    }
}

#======================================================================
proc InitActDevice { {Bus ""} } {
    global ActDev DevAdr DevID ParamList IOScanConf
    global theSafetyParamFile theSafetyErrorFile
	
    if {[GetDevFeat "Altivar"] } {
	ReadParaFile_ATV [getTheAltilabKOPFilename]
    } else {
	ReadParaFile_AltiLab [getTheAltilabKOPFilename]
    }
    if {[GetDevFeat "Modul_SM1"]} {
	ReadParaFile_Safety     $theSafetyParamFile
	ReadErrorFile_Safety    $theSafetyErrorFile
	SM_ReadMappingFiles
    }
    if {[GetDevFeat "BusCIPSafety"]} {
	ReadErrorFile_Safety    $theSafetyErrorFile
    }
    set ActAdr $DevAdr($ActDev,MOD)
    TlPrint "Switch on device $ActDev with address $ActAdr"
    TlPrint "Change modbus address to broadcast (0xF8)"
    set DevAdr($ActDev,MOD) 0xF8        ;#will be restored in below
    #DeviceFastOffOn $ActDev 1 ">=1"
    DeviceOn $ActDev 1 ">=2"

    #this is a debugging output if CFF error occurs (COPLA00000040)
    doPrintObject CIC
    TlPrint "0x0AD2 [mbDirect F8470AD20001 1]"
    TlPrint "0x0AD4 [mbDirect F8470AD40001 1]"

    set DevAdr($ActDev,MOD) $ActAdr

    set DevAdr($ActDev,MOD) 0xF8        ;#will be restored in below

    if {[GetDevFeat "MVK"]} {
	set IOScanConf 0
	Write_MVK_DriveRating

    } else {
	# Configure Drive Rating
	WriteDriveRating
    }
    if {! [GetSysFeat "Gen2Tower"]} {
	# Write all analog offsets and gains
	WriteAnalogOffset

	# Write the Product Serial Number
	WriteProdSerial
    }

    if {![GetDevFeat "MVK"]} {
	WriteProdName
    }
    # Write actual time in device
    ATVSetTimeActual

    # Clear error memory
    ClearLFT

    if {[GetDevFeat "Modul_SM1"] && ![GetSysFeat "PACY_SFTY_FIELDBUS"]} {
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

	doWaitMs 5000
	TlWrite MODE .TP
	doChangeMask DBGF 0x4000 1 1

	#	SM_SetParaDefault "all"
	#	SM_WriteSafetyConfig
	setDefaultSftyParam
	doConfigurationTest

    }
    doStoreEEPROM

    TlPrint "Actual internal Modbus address: $DevAdr($ActDev,MOD)"

    DeviceOff $ActDev 1

    DeviceOn $ActDev 0 ">=0"

    doSetDefaults 0
    set DevAdr($ActDev,MOD) $ActAdr
    TlPrint "DevAdr $DevAdr($ActDev,MOD)"

    #Update the IOScanner mapping in case of EAE_Slave
    if { [GetDevFeat "EAE_Slave"] } {

	if {[GetDevFeat "Altivar"]} {
	    SetModTcpMapping_Altivar {CMD LFRD} {ETA RFRD RFR HMIS CCC ETI}
	    doStoreEEPROM
	} else {
	    SetModTcpMapping {ETA RFRD RFR LCR OTR OPR HMIS LFT LALR CCC TUS ETI IL1R IL1I OL1I AI1C AI2C AI3C AI4C AI5C} {CMD LFRD OL1R AO1C AO2C}
	}
    }
    DeviceOff $ActDev 1

}

#======================================================================
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 160415 serio add DVN to Fortis

proc WriteAdr {ModAdr {Bus ""}} {
    global theSerialBaud DevAdr ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteAdr {} - (ModBus adress to %d)" $ModAdr

    for {set i 1} {$i <= 5} {incr i} {
	set write_result [ModTlWrite ADD $ModAdr]
	ModTlWrite CMI 2
	doWaitForEEPROMStarted 1 1
	doWaitForEEPROMFinished 10

	set act_adr      [doWaitForModObject ADD $ModAdr 1]
	if { ([string first "9004" $write_result] >= 0) || ( $act_adr != $ModAdr ) } {
	    ;#abortcode 4 = Server device failure
	    doWaitMs 1000  ;# try again, max 5 times
	} else {
	    break ;# and now?
	}
    }

    ModTlWrite TBR .$theSerialBaud
    doWaitForModObject TBR .$theSerialBaud 5

    if {[GetDevFeat "Altivar"]} {
	if {[GetDevFeat "BusMBTCP"]} {
	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)
	}
	if {[GetDevFeat "Board_Profinet"] } {
	    TlPrint "--- Start INI OptionBoard ---"

	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)

	}
	if {[GetDevFeat "BusDevNet"] } {
	    ModTlWrite ADRC $DevAdr($ActDev,DVN)      ;#Set DevNet drive address
	    ModTlWrite BDR .AUTO
	    ModTlWrite CIOA .100                      ;#Set drive Configured Assembly to 100/101
	}
	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	    ModTlWrite BDCO .1M                       ;#BaudRate of CAN set to 1M
	}
    }

    if {[GetDevFeat "Nera"]} {
	if {[GetDevFeat "Board_Profinet"] } {
	    TlPrint "--- Start INI OptionBoard ---"

	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)

	}

	if {[GetDevFeat "Card_EthBasic"]  || [GetDevFeat "Card_AdvEmbedded"]} {
	    TlPrint "--- Start INI Module_EthernetBasic ---"

	    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1

	    getIPadr [readOutIPadrBasic] 1

	}

	if {[GetDevFeat "Board_EthAdvanced"] } {
	    TlPrint "--- Start INI Board_EthernetAdvanced ---"

	    writeIpAdv $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1

	}

	if {[GetDevFeat "BusDevNet"] } {
	    ModTlWrite ADRC $DevAdr($ActDev,DVN)      ;#Set DevNet drive address
	    ModTlWrite BDR .AUTO
	    ModTlWrite CIOA .100                      ;#Set drive Configured Assembly to 100/101
	}

	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	    ModTlWrite BDCO .1M                       ;#BaudRate of CAN set to 1M
	}

    } elseif {[GetDevFeat "Fortis"]} {
	if {[GetDevFeat "Board_Profinet"] } {
	    TlPrint "--- Start INI OptionBoard ---"

	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)

	}

	if {[GetDevFeat "Card_EthBasic"]  || [GetDevFeat "Card_AdvEmbedded"]} {
	    TlPrint "--- Start INI Module_EthernetBasic ---"

	    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1

	    getIPadr [readOutIPadrBasic] 1

	}

	if {[GetDevFeat "BusDevNet"] } {
	    ModTlWrite ADRC $DevAdr($ActDev,DVN)      ;#Set DevNet drive address
	    ModTlWrite BDR .AUTO
	    ModTlWrite CIOA .100                      ;#Set drive Configured Assembly to 100/101
	}

	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	    ModTlWrite BDCO .1M                       ;#BaudRate of CAN set to 1M
	}

    } elseif {[GetDevFeat "MVK"]} {

	if {[GetDevFeat "Board_Profinet"] } {
	    TlPrint "--- Start INI OptionBoard ---"

	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)

	}

	if {[GetDevFeat "AdaptationBoard"] } {
	    TlPrint "--- Start INI Board_EthernetAdvanced ---"

	    writeIpAdv $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) "0.0.0.0" 1

	}

	if {[GetDevFeat "Card_EthBasic"]  || [GetDevFeat "Card_AdvEmbedded"]} {
	    TlPrint "--- Start INI Module_EthernetBasic ---"

	    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1

	    getIPadr [readOutIPadrBasic] 1

	}

	if {[GetDevFeat "BusDevNet"] } {
	    ModTlWrite ADRC $DevAdr($ActDev,DVN)      ;#Set DevNet drive address
	    ModTlWrite BDR .AUTO
	    ModTlWrite CIOA .100                      ;#Set drive Configured Assembly to 100/101
	}

	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	    ModTlWrite BDCO .1M                       ;#BaudRate of CAN set to 1M
	}

    } elseif {[GetDevFeat "Opal"]} {
	if {[GetDevFeat "Board_Profinet"] } {
	    TlPrint "--- Start INI OptionBoard ---"

	    ModTlWrite IPM .MANU
	    doWaitMs 3000

	    writeIpOpt $DevAdr($ActDev,OptBrdIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE)

	}
	if {[GetDevFeat "Card_EthBasic"]  || [GetDevFeat "Card_AdvEmbedded"]} {
	    TlPrint "--- Start INI Module_EthernetBasic ---"

	    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1

	    getIPadr [readOutIPadrBasic] 1

	}
	#	if {[GetDevFeat "Card_AdvEmbedded"] } {
	#	    TlPrint "--- Start INI Card_AdvEmbedded ---"
	#
	#	    writeIpBas 192.168.100.$DevAdr($ActDev,EIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1
	#
	#	}

	if {[GetDevFeat "BusDevNet"] } {
	    ModTlWrite ADRC $DevAdr($ActDev,DVN)      ;#Set DevNet drive address
	    ModTlWrite BDR .AUTO
	    ModTlWrite CIOA .100                      ;#Set drive Configured Assembly to 100/101
	}

	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	    ModTlWrite BDCO .1M                       ;#BaudRate of CAN set to 1M
	}

    } elseif {[GetDevFeat "ATS48P"] || [GetDevFeat "OPTIM"]} {
	if {[GetDevFeat "BusCAN"] } {
	    ModTlWrite ADCO $DevAdr($ActDev,CAN)      ;#Set CANopen address
	}
    }

    if {[GetDevFeat "BusPBdev"] } {
	ModTlWrite ADRC $DevAdr($ActDev,SPB)      ;#Set Profibus address
    }

    #ToDo: for other fieldbus interfaces the restoring of communication parameters may follow
    TlPrint "-end----------------------------------------------------"
}

#======================================================================

#======================================================================

proc WriteAnalogOffset { } {

    global AnaOffset lstAnaOffset
    global ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteDriveRating {} - Write Analog adjustment for device $ActDev "

    if { ![GetDevFeat "Altivar"]} {
	TlWrite MODE .TP
	doWaitForObject MODE .TP 1
    } else {
	set lstAnaOffset   [list "GU" "GV" "GW" "GVB" "OUP1" "GUP1" "OUP2" "GUP2" "OCP3" "GCP3" "O1OU" "O1GU" "O1OC" "O1GC" ]
	ATVWriteRunCFG MODE 0x5450
    }
    doWaitForEEPROMFinished 10
    doWaitMs 4000

    foreach Param $lstAnaOffset {
	if {[info exists AnaOffset($ActDev,$Param)]} {

	    if {$Param == "OUN1" || $Param == "GUN1" } {

		TlError "*GEDEC00193249* : AI1 and AI2 inverted, $Param not available"

	    } else {

		TlWrite $Param $AnaOffset($ActDev,$Param)
		doWaitForObject $Param $AnaOffset($ActDev,$Param) 1
	    }
	} else {
	    TlPrint "No value for $Param in .ini file"
	}

    }

    if { ![GetDevFeat "Altivar"]} {
	TlWrite MODE .OK
	doWaitForObject MODE .OK 1
    } else {
	ATVWriteRunCFG MODE 0x4F4B
    }
    doWaitMs 4000
    TlPrint "-end----------------------------------------------------"
}

#-----------------------------------------------------------------------
# Check all defined Motor parameters (NPR, FRS etc)
# return 0: at least one parameter has not the value defined in MotASMParam
# return 1: all parameters are ok
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# ?      ?     proc created
# 280114 ockeg check the new values separately after all values have been written
#-----------------------------------------------------------------------
proc WriteMotorData { } {
    global MotASMParam lstMotASMParam
    global MotSMParam lstMotSMParam
    global ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteMotorData {} - Write motor data "

    if {[GetDevFeat "MotASM"] } {
	#Asynchronous motor
	foreach Param $lstMotASMParam {
	    if { [info exists MotASMParam($ActDev,$Param)] } {
		doPrintObject     $Param                                 ;# print state before
		TlWrite           $Param $MotASMParam($ActDev,$Param)    ;# write new value
		doWaitForObject   $Param $MotASMParam($ActDev,$Param) 1 ;# check the new value
	    } else {
		TlPrint "No value for $Param in .ini file"
		set globAbbruchFlag 1
		set theTestSuite ""
		return 1
	    }
	}
    } elseif {[GetDevFeat "MotAC"]} {
	#Synchronous motor
	foreach Param $lstMotSMParam {
	    if { [info exists MotSMParam($ActDev,$Param)] } {
		doPrintObject     $Param                                 ;# print state before
		TlWrite           $Param $MotSMParam($ActDev,$Param)     ;# write new value
		doWaitForObject   $Param $MotSMParam($ActDev,$Param) 1  ;# check the new value
	    } else {
		TlPrint "No value for $Param in .ini file"
		set globAbbruchFlag 1
		set theTestSuite ""
		return 1
	    }
	}
    }  elseif {[GetDevFeat "MotSM"] } {
	    #Asynchronous motor
	    foreach Param $lstMotSMParam {
		if { [info exists MotSMParam($ActDev,$Param)] } {
		    doPrintObject     $Param                                 ;# print state before
		    TlWrite           $Param $MotSMParam($ActDev,$Param)    ;# write new value
		    doWaitForObject   $Param $MotSMParam($ActDev,$Param) 1 ;# check the new value
		} else {
		    TlPrint "No value for $Param in .ini file"
		    set globAbbruchFlag 1
		    set theTestSuite ""
		    return 1
		}
	    }
    } 
	

    set rc [CheckMotorData]       ;# better to do completely after the values have been written
    TlPrint "-end----------------------------------------------------"
    return $rc
}

#-----------------------------------------------------------------------
# Check all defined Motor parameters (NPR, FRS etc)
# return 0: at least one parameter has not the value defined in MotASMParam
# return 1: all parameters are ok
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 280114 ockeg proc created
#-----------------------------------------------------------------------
proc CheckMotorData { } {
    global MotASMParam lstMotASMParam
    global MotSMParam lstMotSMParam
    global ActDev

    set result 1
    TlPrint "CheckMotorData"

    if {[GetDevFeat "MotASM"]} {
	#Asynchronous motor
	foreach Param $lstMotASMParam {
	    if { [info exists MotASMParam($ActDev,$Param)] } {
		if { [checkModObject $Param $MotASMParam($ActDev,$Param) "" 0] == 0 } {
		    set result 0
		}
	    }
	};#end foreach
    } elseif {[GetDevFeat "MotAC"]} {
	#Synchronous motor
	foreach Param $lstMotSMParam {
	    if { [info exists MotSMParam($ActDev,$Param)] } {
		if { [checkModObject $Param $MotSMParam($ActDev,$Param) "" 0] == 0 } {
		    set result 0
		}
	    }
	};#end foreach
    };#end if
    return $result
}

#-----------------------------------------------------------------------
proc WriteDriveRating { } {

    global DevType
    global ActDev
    global globAbbruchFlag
    global reducedTestExecution TraceStatistics theTestSuite

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteDriveRating {} - Write the drive rating "

    if { ![GetDevFeat "Altivar"]} {
	TlWrite MODE .TP
	doWaitForObject MODE .TP 1
    } else {
	ATVWriteRunCFG MODE 0x5450
    }

    if { [info exists DevType($ActDev,Supply)] } {
	set Supply $DevType($ActDev,Supply)
	if {$Supply != "UNKNOWN"} {
	    TlWrite           VCAL ".$Supply"
	    doWaitForObject   VCAL ".$Supply" 1
	} else {
	    TlError "No value for Supply in .ini file"
	    set globAbbruchFlag 1
	    set theTestSuite ""
	    return 1
	}
    } else {
	TlError "No value for Supply in .ini file"
	set globAbbruchFlag 1
	set theTestSuite ""
	return 1
    }

    doWaitMs 3000
    if { [info exists DevType($ActDev,Rate)] } {
	set Rate $DevType($ActDev,Rate)
	if {$Rate != "UNKNOWN"} {
	    TlWrite           NCV ".$Rate"
	    doWaitForObject   NCV ".$Rate" 1
	} else {
	    TlError "No value for Rate in .ini file"
	    set globAbbruchFlag 1
	    set theTestSuite ""
	    return 1
	}
    } else {
	TlError "No value for Rate in .ini file"
	set globAbbruchFlag 1
	set theTestSuite ""
	return 1
    }
    doWaitMs 3000

    if { [info exists DevType($ActDev,Type)] } {
	set Type [string toupper $DevType($ActDev,Type)]
	if {$Type != "UNKNOWN"} {
	    # Fortis powerstage only knows type "INDUST"
	    if {$Type == "FORTIS"} {set Type "INDUST"}
	    if {$Type == "ATS"} {set Type "NERA"}
	    if {$Type == "MVK"} {set Type "MVK2Q"}
	    if {$Type == "ALTIVAR"} {set Type "R3B"}
	    if {$Type == "K2"} {set Type "HVACK2" }
	    TlWrite           PWT ".$Type"
	    doWaitForObject   PWT ".$Type" 1
	} else {
	    TlError "No value for Type in .ini file"
	    set globAbbruchFlag 1
	    set theTestSuite ""
	    return 1
	}
    } else {
	TlError "No value for Type in .ini file"
	set globAbbruchFlag 1
	set theTestSuite ""
	return 1
    }
    doWaitMs 3000

    if {[GetDevFeat "Fortis"]} {
	# Bit4 = 0x0010  : 1=Activation of hardware brake transistor
	TlWrite           PWVU 0x10
	doWaitForObject   PWVU 0x10 1
    } else {
	if { ![GetDevFeat "Altivar"]} {
	    TlWrite           PWVU 0
	    doWaitForObject   PWVU 0 1
	} else {
	    TlWrite           PWVU 0x803F
	    doWaitForObject   PWVU 0x803F 1
	}

    }

    doWaitMs 3000
    if { ![GetDevFeat "Altivar"]} {
	TlWrite MODE .OK
    } else {
	ATVWriteRunCFG MODE 0x4F4B
    }
    TlPrint "-end----------------------------------------------------"
}

proc WriteProdName { } {

    global DevID ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteProdName {} - Write the product name "

    if { ![GetDevFeat "Altivar"]} {
	    TlWrite MODE .TP
	    doWaitForObject MODE .TP 1
    } else {
	ATVWriteRunCFG MODE 0x5450
    }
    doWaitMs 2000

    #write string into braces to parameters PCN0 to PCNF

    set str Schneider
    append str " "                      ;#append space character
    append str Electric
    append str [format %c 0]            ;#append NULL character

    append str $DevID($ActDev,ModelName) ;# append complete device name

    WriteAsciiToPar $str PCN0 PCN1 PCN2 PCN3 PCN4 PCN5 PCN6 PCN7 PCN8 PCN9 PCNA PCNB PCNC PCND PCNE PCNF PCNG PCNH

    #add value of PRT

    if {[GetDevFeat "Fortis"]} {
	# Bit7 "New Hardware for motor voltage measurement" set
	TlWrite PRT 0x81
	doWaitForObject PRT 0x81 1
    } else {
	TlWrite PRT 0
	doWaitForObject PRT 0 1
    }

    TlPrint "-end----------------------------------------------------"
}

proc WriteProdSerial { } {

    global DevID ActDev

    TlPrint "--------------------------------------------------------"
    TlPrint "WriteProdSerial {} - Write the product serial number "

    if { ![GetDevFeat "Altivar"]} {
	    TlWrite MODE .TP
	    doWaitForObject MODE .TP 1
    } else {
	ATVWriteRunCFG MODE 0x5450
    }
    doWaitMs 2000

    #write string into braces to parameters C1P1 to C1PA

    set str ""
    append str $DevID($ActDev,SN) ;# append complete device name
    if { ![GetDevFeat "Altivar"]} {
	WriteAsciiToPar $str C1P1 C1P2 C1P3 C1P4 C1P5 C1P6 C1P7 C1P8 C1P9 C1PA
    } else {
	WriteAsciiToPar $str C1P1 C1P2 C1P3 C1P4
    }

    TlPrint "-end----------------------------------------------------"
}

proc ClearLFT { } {
    TlPrint "--------------------------------------------------------"
    TlPrint "ClearLFT {} - Clear error memory "

    if { ![GetDevFeat "Altivar"]} {
	    TlWrite MODE .TP
	    doWaitForObject MODE .TP 1
    } else {
	ATVWriteRunCFG MODE 0x5450
    }
    TlWrite RAZI 0x0004     ;#Bit2 : reset of LFT
    if { ![GetDevFeat "Altivar"]} {
	TlWrite MODE .OK
    } else {
	ATVWriteRunCFG MODE 0x4F4B
    }

    TlPrint "-end----------------------------------------------------"
}

# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Initialize a Nera/Beidou/Fortis drive after flashing
#
# ----------HISTORY----------
# WANN   WER   WAS
# 041214 todet original procedure only working for actual device, make a new one executed for a set of devices
#
# END----------------------------------------------------------------
proc InitAfterFlash {{HardCore 0} {Power ""} {Supply ""} {ProdType ""}} {
    global theDevList ActDev DevAdr ParamList

    set ActDevOld $ActDev

    TlTestCase "Initialize Drive after flash update"

    foreach ActDev $theDevList {

	InitAfterFlash_ActDev $HardCore $Power $Supply $ProdType

	DeviceOn $ActDev 0

	if {[GetDevFeat "Modul_SM1"]} {
	    doWaitMs 5000
	    #SM_WriteSafetyConfig 1
	    setDefaultSftyParam
	    doConfigurationTest
	}

	doWaitMs 10000

	FileManagerExtractConfig "default"

	if { [GetSysFeat "MVKTower1"]||[GetSysFeat "MVKTower2"] } {
	    DeviceOn $ActDev

	    doWaitMs 10000
	    MasterOff H
	    doWaitMs 2500
	    set ActDev 2
	    SlaveOnOff 1 H
	    doWaitMs 2500
	    set DevAdr($ActDev,MOD) 0xF8

	    Write_MVK_DriveRating
	    #		    TlWrite CMI 2
	    #
	    doWaitMs 10000
	    #
	    #		    TlWrite MODE .RP
	    #		    doWaitMs 20000
	    TlWrite ADD $ActDev
	    doWaitForModObject ADD $ActDev 5

	    TlWrite IM00 .MANU
	    writeIpBas "192.168.100.22" "255.255.255.0" "0.0.0.0"
	    doStoreEEPROM
	    doWaitMs 10000
	    TlWrite MODE .RP
	    doWaitMs 5000
	    SlaveOnOff 1 L

	    doWaitMs 2500
	    set ActDev 3
	    SlaveOnOff 2 H
	    doWaitMs 2500
	    set DevAdr($ActDev,MOD) 0xF8
	    Write_MVK_DriveRating

	    doWaitMs 10000
	    TlWrite ADD $ActDev
	    doWaitForObject ADD $ActDev 1
	    TlWrite IM00 .MANU
	    writeIpBas "192.168.100.23" "255.255.255.0" "0.0.0.0"
	    doStoreEEPROM
	    doWaitMs 10000
	    TlWrite MODE .RP
	    doWaitMs 2500
	    SlaveOnOff 2 L

	    set ActDev 1
	    set DevAdr($ActDev,MOD) $ActDev

	    MasterOff L

	}

	DeviceOff $ActDev

    }

    set ActDev $ActDevOld

}

# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Initialize a Nera/Beidou drive after flashing
#
# I don't think PVAL value are in the dsl gp, please find  here is the list of PVAL request:
#   PVAL_REQ_NONE                     = 0x0000, // "No Request to Power      "
#   PVAL_REQ_SAVE                     = 0x0001, // "Request Power to save EEPROM      "
#   PVAL_REQ_RST_CALIBRATION          = 0x0002, // "Request Power to reset Gain/Offset      "
#   PVAL_REQ_RST_CURRENT_OFFSET       = 0x0003, // "Request Power to reset Offset current      "
#   PVAL_REQ_RST_CURRENT_GAIN         = 0x0004, // "Request Power to reset Gain curent      "
#   PVAL_REQ_RST_GVB                  = 0x0005, // "Request Power to reset Vbus Gain Vbus CPLD    "
#   PVAL_REQ_RST_GVBP                 = 0x0006, // "Request Power to reset Vbus Gain Vbus Power      "
#   PVAL_REQ_RST_MOTOR_VOLTAGE_OFFSET = 0x0007, // "Request Power to reset Offset motor voltage      "
#   PVAL_REQ_RST_MOTOR_VOLTAGE_GAIN   = 0x0008, // "Request Power to reset Gain motor voltage     "
#   PVAL_REQ_RST_VOLTAGE_GVMAINS      = 0x0009, // Request Power to reset  Gain mains GVL1 GVL2 GVL3
#   PVAL_REQ_RST_INDUS_FILE           = 0x0010, // "Request a reset of the indus zone in Control Storage      "
#   PVAL_REQ_RST_POWER_COUNTER        = 0x0011, // "Request a reset of all power counters datas Storage    "
#   PVAL_REQ_RST_POWER_STORAGE        = 0x0200, // "Request Power to reset Power storage    "
#
# RAZI: Reset some internal values
#   Bit0 : Reserved
#   Bit1 : Reserved
#   Bit2 = 1 : Reset of LFT
#   Bit3 = 1 : Power calibration area default values
#   Bit4 : Reserved
#   Bit5 : Reserved
#   Bit6 = 1 : Application calibration area default values
#   Bit7 : Reserved
#   Bit8 = 1 : Reset to factory settings
#   Bit9 = 1 : First Power Up (operating after power off or software reset)
#   Bit10 : Reserved
#   Bit11 : Reserved
#   Bit12 : Reserved
#   Bit13 : Reserved
#   Bit14 : Reserved
#   Bit15 : Reserved
#
#
#  Options to be used in following cases
#  0 : if modification of DSP/ARM or CPLD fw
#  1 : if modification of Power CPU fw
#  2 : if any of the above failed to reinit the system properly
#
#
# ----------HISTORY----------
# WANN   WER   WAS
# 190913 todet  proc erstellt
# 160714 serio  ProdName check through proc call
# 041214 todet  procedure only working for actual device, make a new one executed for a set of devices
#
# END----------------------------------------------------------------
proc InitAfterFlash_ActDev {{HardCore 0} {Power ""} {Supply ""} {ProdType ""}} {

    global DevType ActDev DevAdr
    global DevID

    if {$ProdType == ""} {
	if {[GetDevFeat "Nera"]} {
	    set ProdType "NERA"
	} elseif {[GetDevFeat "Beidou"]} {
	    set ProdType "BEIDOU"
	} elseif {[GetDevFeat "Fortis"]} {
	    set ProdType "INDUST"
	} elseif {[GetDevFeat "MVK"]} {
	    set ProdType "MVK2Q"

	} elseif {[GetDevFeat "Opal"]} {
	    set ProdType "OPAL"
	} else {
	    TlError "Device Type not known"
	    return
	}
    }

    if {$Supply == ""} {
	set Supply $DevType($ActDev,Supply)
    }

    if {$Power == ""} {
	set Power $DevType($ActDev,Rate)
    }

    TlPrint "Initialize $ProdType drive with supply type $Supply and power type $Power"

    doSetCmdInterface "MOD"
    set ActAdr $DevAdr($ActDev,MOD)
    TlPrint "Change modbus address to broadcast (0xF8)"
    set DevAdr($ActDev,MOD) 0xF8        ;#will be restored in below

    TlPrint "Switch on device $ActDev"
    DeviceOn $ActDev 0 ">= 2" 90

    if {$HardCore == 1} {
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite PVAL 0x0200  ;# delete all power cpu persistent vars
	doWaitMs 10000
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite RAZI 0x0008
	# flash will be erased after reboot, so wait here (triggered by 'TlWrite RAZI 8')
	doWaitMs 10000
	DeviceFastOffOn $ActDev 1 ">=2" 60
	doWaitMs 10000
	doWaitForObject EEPS 0 50

	DeviceFastOffOn $ActDev 1 ">=2" 60
	doWaitMs 7000

	TlWrite MODE .TP

	TlWrite PWT ".$ProdType"
	doWaitMsSilent 3000
	TlWrite NCV ".$Power"
	doWaitMsSilent 3000
	TlWrite VCAL ".$Supply"
	doWaitMsSilent 3000
	if {[GetDevFeat "Fortis"]} {
	    # Bit4 = 0x0010  : 1=Activation of hardware brake transistor
	    TlWrite           PWVU 0x10
	} else {
	    TlWrite           PWVU 0
	}
	doWaitMsSilent 3000

	#TlWrite FCS .INI
	#doWaitMs 20000
    }  elseif {$HardCore == 2} {
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite PVAL 0x0200  ;# delete all power cpu persistent vars
	doWaitMs 10000
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite CVAL 0x0200  ;# delete all power cpu persistent vars
	doWaitMs 10000
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite RAZI 0x0348
	#TlWrite RAZI 0xFFFF   ;# "Volldampf" is better!
	# flash will be erased after reboot, so wait here (triggered by 'TlWrite RAZI 584')
	doWaitMs 10000
	DeviceFastOffOn $ActDev 1 ">=2" 60
	doWaitMs 10000
	doWaitForObject RAZI 0 20
	doWaitForObject EEPS 0 50

	DeviceFastOffOn $ActDev 1 ">=2" 60
	doWaitMs 7000

	DeviceFastOffOn $ActDev 1 ">=2" 25
	doWaitMs 7000

	TlWrite MODE .TP

	TlWrite PWT ".$ProdType"
	doWaitMsSilent 3000
	TlWrite NCV ".$Power"
	doWaitMsSilent 3000
	TlWrite VCAL ".$Supply"
	doWaitMsSilent 3000
	if {[GetDevFeat "Fortis"]} {
	    # Bit4 = 0x0010  : 1=Activation of hardware brake transistor
	    TlWrite           PWVU 0x10
	} else {
	    TlWrite           PWVU 0
	}
	doWaitMsSilent 3000

	#TlWrite FCS .INI
	#doWaitMs 20000
    } elseif {$HardCore == -1} {
	TlWrite MODE .TP
	doWaitMs 2000
	TlWrite RAZI 0x0200
	doWaitMs 2000
	TlWrite MODE .OK
	doWaitMs 2000

	DeviceFastOffOn $ActDev 1 ">=2" 25

	doWaitMs 50000

	DeviceFastOffOn $ActDev 1 ">=2" 25

	TlWrite FCS .INI
	doWaitForEEPROMFinished 30 0
	TlWrite MODE .TP
    } else {
	TlWrite MODE .TP
	#      doWaitMs 2000
	#      TlWrite CVAL 1
	#      doWaitMs 5000
	#      doWaitForObject CVAL 0 10
	#      TlWrite MODE .OK
	#      doWaitMs 2000
	#      DeviceFastOffOn $ActDev 1 ">=2" 25
	#
	#      TlWrite MODE .TP
	#      doWaitMs 2000
	#      TlWrite PVAL 1
	#      doWaitMs 5000
	#      doWaitForObject PVAL 0 10
	#      TlWrite MODE .OK
	#      doWaitMs 2000
	#      DeviceFastOffOn $ActDev 1 ">=2" 25
	#
	#      TlWrite MODE .TP
	#      doWaitMs 2000
	#      TlWrite RAZI 0x0248 1
	#      doWaitForObject EEPS 0 10 0xFFFF "" 1
	#      TlWrite MODE .OK
	#      doWaitMs 2000
	#
	#      DeviceFastOffOn $ActDev 1 ">=2" 25
	#      doWaitMs 5000
	#      DeviceFastOffOn $ActDev 1 ">=2" 25

	TlWrite FCS .INI
	doWaitForEEPROMFinished 30 0
	TlWrite MODE .TP
    }
    if {![GetDevFeat "MVK"]} {
	WriteProdName
    }
    TlWrite MODE .OK

    doWaitMsSilent 1000

    DeviceFastOffOn $ActDev 1 ">=2" 60

    doWaitMs 5000

    if {[GetDevFeat "MVK"]} {
	Write_MVK_DriveRating

    }

    checkObject NCV  ".$Power"    "" "" 0
    checkObject VCAL ".$Supply"   "" "" 0
    if {[GetDevFeat "Fortis"]} {
	# Bit4 = 0x0010  : 1=Activation of hardware brake transistor
	checkObject PWVU 0x10         "" "" 0
    } else {
	checkObject PWVU 0            "" "" 0
    }
    checkObject PWT  ".$ProdType" "" "" 0

    #Check Product Name

    if {![GetDevFeat "MVK"]} {
	set str Schneider
	append str " "                      ;#append space character
	append str Electric
	append str [format %c 0]            ;#append NULL character

	append str $DevID($ActDev,ModelName) ;# append complete device name

	CheckAsciiInPar $str PCN0 PCN1 PCN2 PCN3 PCN4 PCN5 PCN6 PCN7 PCN8 PCN9 PCNA PCNB PCNC PCND PCNE PCNF PCNG PCNH
    }

    TlPrint "restore ModBus Address to $ActAdr"
    set DevAdr($ActDev,MOD) $ActAdr

    doSetDefaults 0

    DeviceOff $ActDev

}

#-----------------------------------------------------------------------
# load all necessary fieldbus libraries and check fieldbus is installed
#-----------------------------------------------------------------------
proc InitializeFieldbus {  } {
    global libpath mainpath
    global Fieldbus
    global testconfig_FileName
    global theCANObjectListFile theNeraCANObjectFile theAltivarCANObjectFile theFortisCANObjectFile theOpalCANObjectFile theMVKCANObjectFile
	global DevType ActDev
    #--------------------------------------------------------------------
    if { [GetDevFeat "BusDevNet"] } {

	source "$libpath/cmd_DeviceNet.tcl"
	if { ![DevNetOpen 1] } {
	    TlError "DeviceNet interface could not be activated"
	    doSetCmdInterface MOD
	} else {
	    doSetCmdInterface $Fieldbus   ;# out of batch file
	}
	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusEIP"] } {         ;# EtherNet-IP

	source "$libpath/cmd_EIP.tcl"
	source "$libpath/cmd_DevNet.tcl"          ;# DevNet commands also necessary for EIP

	if { ![EIP_Open] } {
	    TlError "Hilscher Ethernet IP interface could not be activated"
	    doSetCmdInterface MOD
	} else {
	    #close communication if Modbus selected through batch file
	    if {$Fieldbus == "MOD"} {
		EIP_Close
	    }
	    doSetCmdInterface $Fieldbus   ;# out of batch file

	}

	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusPBdev"] } {       ;# ProfiBus

	#source "$libpath/cmd_simaticPB.tcl"       ;# Simatic Profibus Treiber
	source "$libpath/cmd_Profibus.tcl"        ;# functions for Hilscher Profibus interface
	source "$libpath/cmd_PB_PN_common.tcl"    ;# common functions for Profibus and Profinet
	source "$libpath/cmd_Profidrive_tlxxx.tcl"
	doSetCmdInterface "MOD"
	#      #try to open ProfiBus interface
	#      if { [PB_OpenTelegram  "Telegram101"] != 0 } {
	#         TlError "PN_OpenTelegram with Telegram101 not possible"
	#         doSetCmdInterface "MOD"
	#
	#      } else {
	#
	#         #close communication if Modbus selected through batch file
	#         if { $Fieldbus == "MOD" } {
	#
	#            PB_PN_Telegram_Close
	#
	#         }
	#         doSetCmdInterface $Fieldbus   ;# out of batch file
	#
	#      }

	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusPN"] } {          ;# ProfiNet

	source "$libpath/cmd_Profinet.tcl"        ;# functions for Hilscher Profinet interface
	source "$libpath/cmd_PB_PN_common.tcl"    ;# common functions for Profibus and Profinet
	source "$libpath/cmd_Profidrive_tlxxx.tcl"

	#try to open Profinet interface
	PB_PN_SetGetTelegram "Telegram101"
	if { [Profinet::openConnection "Telegram101"] !=0 } {
	    TlError "PN_OpenTelegram with Telegram101 not possible"
	    doSetCmdInterface "MOD"

	} else {
	    Profinet::changeAPI 0x0000
	    #close communication if Modbus selected through batch file
	    if { $Fieldbus == "MOD" } {
		Profinet::closeConnection
	    }
	    doSetCmdInterface $Fieldbus   ;# out of batch file

	}

	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusPNV2"] } {          ;# ProfiNet

	source "$libpath/cmd_ProfinetV2.tcl"        ;# functions for ProfinetV2 interface
	source "$libpath/cmd_PB_PN_common.tcl"    ;# common functions for Profibus and Profinet
	source "$libpath/cmd_ProfinetV2_tlxxx.tcl"
	source "$libpath/cmd_GNGRules.tcl"      ;# Loading the GNGRULES namespace declaration
	doSetCmdInterface MOD
	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusECAT"] } {        ;# EtherCAT

	source "$libpath/cmd_ECAT_H.tcl"          ;# special commands for Hilscher EtherCAT interface
	source "$libpath/cmd_CIA301.tcl"          ;# special commands for CIA 301 Communication Profile
	source "$libpath/cmd_DS402.tcl"           ;# interface layer for switching between CANopen and CoE

	if { ![ECAT_H_Open "Default"] } {
	    TlError "ECAT interface could not be activated"
	    doSetCmdInterface "MOD"

	} else {
	    #EtherCAT_SetMasterState "OP"
	    #EtherCAT_WaitForMasterState "OP"
	    doSetCmdInterface $Fieldbus   ;# out of batch file
	    ECAT_H_Close
	}

	#--------------------------------------------------------------------
    } elseif { [GetDevFeat "BusCAN"] } {         ;# CANopen
	    if {![GetSysFeat "ATLAS"]} {
		    source "$libpath/cmd_CAN.tcl"             ;# CAN commands
		    source "$libpath/cmd_CIA301.tcl"          ;# special commands for CIA 301 Communication Profile
		    source "$libpath/cmd_DS402.tcl"           ;# interface layer for switching between CANopen and CoE
		    
		    #Read CAN objects from EDS file of corresponding device
		    if {[GetDevFeat "Nera"]} {
			    set theCANObjectListFile $theNeraCANObjectFile
		    } elseif {[GetDevFeat "Fortis"]} {
			    set theCANObjectListFile $theFortisCANObjectFile
		    } elseif {[GetDevFeat "MVK"]} {
			    set theCANObjectListFile $theMVKCANObjectFile
		    } elseif {[GetDevFeat "Altivar"]} {
			    set theCANObjectListFile $theAltivarCANObjectFile
		    } else {
			    set theCANObjectListFile $theOpalCANObjectFile
		    }
		    
		    ReadCANObjectListFile   $theCANObjectListFile
		    
		    #open CAN interface
		    if { [doOpenCAN "TestNet"] != 1 } {
			    TlError "CAN interface could not be activated"
			    doSetCmdInterface "MOD"
		    } else {
			    #close communication if Modbus selected through batch file
			    if { $Fieldbus == "MOD" } {
				    doCloseCAN "TestNet"
			    }
			    doSetCmdInterface $Fieldbus   ;# out of batch file
			    
		    }

		    } else {
			    #source "$libpath/cmd_CAN_ATLAS.tcl"
			    doSetCmdInterface MOD
		    
		    }
		    
		    #--------------------------------------------------------------------
	    }  elseif { $Fieldbus == "MODTCP" || $Fieldbus == "MODTCPioScan"} {
		    # Schneider Modbus-TCP can only be opened if at least one device is online
	# for this reason here will only the interface be activated
	doSetCmdInterface $Fieldbus

    } elseif { [GetDevFeat "BusPB_ATLAS"] || [GetDevFeat "BusPN_ATLAS"] } {
	#source $libpath/PBS_PNT_ATLAS.tcl
	doSetCmdInterface "MOD"
    } else {
	doSetCmdInterface "MOD"
    }

    #======================= necessary? ======================================
    if {[GetSysFeat "PACY_APP_NERA"]} {
	#      # start Hilscher controler
	#      #   TlError "Fieldbus == EIP is not configured"
	#      if { ![EIP_Open] } {
	#         TlError "Hilscher Ethernet IP interface could not be activated"
	#      } else {
	doSetCmdInterface $Fieldbus
	#      }
	   }
    #======================= necessary? ======================================
    if {[GetSysFeat "thirdPartyPLC"]} {
        if {[GetSysFeat "PACY_SFTY_FIELDBUS"]} {
            if {[GetDevFeat "BusProfisafe"] || [GetDevFeat "BusPNV2"]} {
                plcPowerSupply 5 H
                plcPowerSupply 4 L
                switchPowerSupply 2 L 
                switchPowerSupply 3 H
            } elseif {[GetDevFeat "BusCIPSafety"]} {
                global CIPSafetyComIndex
                plcPowerSupply 5 L
                plcPowerSupply 4 H
                switchPowerSupply 2 H 
                switchPowerSupply 3 L
                doWaitForPing $CIPSafetyComIndex(CIPSafetyPLC_address) 120000
                set rc [catch {mb2Open TCP $CIPSafetyComIndex(CIPSafetyPLC_address) 1}]
                if {$rc != 0 } {
                    TlError "Impossible to open connection towards CIPSafety PLC"
                } else {
                    set CIPSafetyComIndex(CIPSafetyPLC_openConnection) 1
                }
            }
        }
    }

    if {[GetSysFeat "MotorSelection"]} {
	    selectMotor $DevType($ActDev,MotorIndex) 
    }
}

proc Write_MVK_DriveRating { } {

    global ActDev DevAdr DevID
    set test $DevID($ActDev,ModelName)
    TlPrint "Check of the ATV6000 drive product identification with Reference : $test"

    #TlPrint "Switch on Device $ActDev with address $ActAdr"

    TlWrite MODE 0x5450
    TlWrite PWVU 0x0000
    TlWrite PWT .MVK2Q

    TlPrint "set identification drive parameters corresponding to XML file"

    TlWrite PRT2 [Find_MVK_PRT2 $test]
    doWaitForObject PRT2 [Find_MVK_PRT2 $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite PIMV [Find_MVK_PIMV $test]
    doWaitForObject PIMV [Find_MVK_PIMV $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite VCAL [Find_MVK_VCAL $test]
    doWaitForObject VCAL [Find_MVK_VCAL $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite POCT [Find_MVK_POCT $test]
    doWaitForObject POCT [Find_MVK_POCT $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite PRT [Find_MVK_PRT $test]
    doWaitForObject PRT [Find_MVK_PRT $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite POCV [Find_MVK_POCV $test]
    doWaitForObject POCV [Find_MVK_POCV $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite POCC [Find_MVK_POCC $test]
    doWaitForObject POCC [Find_MVK_POCC $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite POCN [Find_MVK_POCN $test]
    doWaitForObject POCN [Find_MVK_POCN $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite NCV [Find_MVK_NCV $test]
    doWaitForObject NCV [Find_MVK_NCV $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite PIMC [Find_MVK_PIMC $test]
    doWaitForObject PIMC [Find_MVK_PIMC $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite PITP [Find_MVK_PITP $test]
    doWaitForObject PITP [Find_MVK_PITP $test] 1
    doWaitForObject EEPS 0 10
    doWaitMs 600
    TlWrite RAZI 512
    TlWrite MODE 0x5250
    doWaitMs 20000          ;#modification olivier : 15/02 : sometimes drive not started after 14sec then 20sec ( equal to "debug pump" )
    TlWrite MODE .TP
    doWaitMs 500
    if {[GetDevFeat "SimuMode"]   } {
	TlWrite OCT3 2
	doWaitForObject OCT3 2 1
	if { [GetDevFeat "AdaptationBoard"]  } {
	    TlWrite SIMM .SIM2
	    doWaitForObject SIMM .SIM2 1
	    doStoreEEPROM
	} else {
	    TlWrite SIMM .SIM1
	    doWaitForObject SIMM .SIM1 1
	    doStoreEEPROM
	}
    }
}
