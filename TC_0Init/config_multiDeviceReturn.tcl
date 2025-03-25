#!/bin/sh
# config_multiDevice.tcl \
exec tclsh "$0" ${1+"$@"}


global Geraeteliste DevType ActDev
set theAltiLabParameterFile ""
if {[GetSysFeat "EAETower1"]} {
	source "$mainpath/TC_ATV320/Altivar_lib.tcl"
	ReadParaFile_ATV    "$mainpath/ObjektDB/R3Dev_PrmUnifiedMappingSimulatorGen.sim"
	ReadParaTypeFile_ATV    "$mainpath/ObjektDB/R3Dev_PrmUnifiedMappingSimulatorGen.sim"
	set theAltiLabParameterFile ""	
}
switch $DevType($ActDev,Type) {

    "ATS48P" {
	#source $mainpath/TC_ATS/ATS_lib.tcl
	#ReadParaFile_ATS "$mainpath/TC_ATS/ATS48_mapping.xlsx"
	#ReadParaFile_ATV "$mainpath/TC_ATS/ATS48P.sim"
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_ATS48P.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
	ReadUnifiedMapping_ATS
        FFT146_AlarmManagement_Init
	    
	#Check the last time the definitionFilesHirstory.txt was updated
	#checkLastDefinitionFileHistoryCheck
    }
    "OPTIM" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_OPTIM.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
	ReadUnifiedMapping_ATS
	FFT146_AlarmManagement_Init
    }
    "BASIC" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_BASIC.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
	ReadUnifiedMapping_ATS
	FFT146_AlarmManagement_Init
    }

    "Altivar" {
	source "$mainpath/TC_ATV320/Altivar_lib.tcl"
	ReadParaFile_ATV    "$mainpath/ObjektDB/R3Dev_PrmUnifiedMappingSimulatorGen.sim"

    }
    "Opal" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_OPAL_CS.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
    }
    "Nera" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_NERA.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
    }
    "Beidou" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_BEIDOU.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
    }
    "Fortis" {
        if {[GetDevFeat "ShadowOffer"]} {
        	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_SHADOWF.xml"
        	ReadParaFile_AltiLab $theAltiLabParameterFile
        } else {
        	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_Fortis.xml"
        	ReadParaFile_AltiLab $theAltiLabParameterFile
        }
    }
    "MVK" {
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_MVK.xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
	ImportMVKRef
	ReadXlsDefaultMotorValue
	set IOScanConf 1
    }

    default {
	TlPrint " INFO : AltiLab_KOP file built based on Device Type in ini file ($DevType($ActDev,Type))" 
	append theAltiLabParameterFile $mainpath "/ObjektDB/AltiLab_KOP_" [string toupper $DevType($ActDev,Type)] ".xml"
	ReadParaFile_AltiLab $theAltiLabParameterFile
    }
}

# Program number is now known
setDefs

#Definition of path where tcl packages can be found
global auto_path
lappend auto_path "$mainpath/PACKAGES/"

# load all necessary fieldbus libraries and check fieldbus is installed
InitializeFieldbus

if {[GetDevFeat "Modul_SM1"]} {
    ReadParaFile_Safety     $theSafetyParamFile
    ReadErrorFile_Safety    $theSafetyErrorFile
    SM_ReadMappingFiles
}

if {[GetDevFeat "BusCIPSafety"]} {
    ReadErrorFile_Safety    $theSafetyErrorFile
}

if {![GetDevFeat "Altivar"]} {
    source "$libpath/Keypad_lib.tcl"      ;# keypad commands
} else {
    source "$libpath/Keypad320_lib.tcl"      ;# keypad commands
}

if {[GetDevFeat "BusPN_ATLAS"]} {
    package require dcp
    dcp::getNetworkInterface
}

if {[GetDevFeat "BusPNV2"] } {
    if {[GetSysFeat "PACY_SFTY_FIELDBUS"]} {
    	plcPowerSupply 5 H
	switchPowerSupply 3 H
	TlPrint "Waiting for the PLC to be on"
	doWaitForPing "192.168.100.1" 165000
    }
    package require opcua

    opcua::openConnection "192.168.100.1"

    package require dcp

    dcp::getNetworkInterface
if {[GetSysFeat "PACY_COM_PROFINET2"]} {
    modbusInterruptConnection L
}
}
# if {[GetSysFeat "ATLAS"]} {
	# package require PLC
# }
if {[GetSysFeat "PACY_APP_FLEX" ]} {
    checkPlug
}

set i [expr $answer - 1]

return [lindex $Geraeteliste $i]

