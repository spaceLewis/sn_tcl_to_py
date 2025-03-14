# Spezific commands for Tcl4Tower
#
#
# Opal  Testtower

# Filename     : cmd_tower.tcl
#
#
# ----------HISTORY# ----------HISTORY----------
# WHEN   WHO   WHAT
# 090704 pfeig file created
# 181214 serio correct switch cases for Fortis
# 080615 serio add showLoadStatus in case of Load issue

global HandMade

proc Display_Varlist {} {
   #Gibt im Gegensatz zu ReadVARListFile den tatsächlichen Inhalt der Arrays aus
    global theLXMVARHashtable theVARNrHashtable theLXMVARListFile

    ReadVARListFile $theLXMVARListFile 0  ;# 0=ohne Ausgabe der Variablenliste auf Bildschirm

    set array_name_list [lsort [array names theVARNrHashtable]]

    #TlPrint "$array_name_list"
    foreach i $array_name_list {
	TlPrint "%-60s -> %-20s" $theVARNrHashtable($i) $theLXMVARHashtable($theVARNrHashtable($i))
    }
};#Display_Varlist

proc Display_Objectlist {} {

    global theLXMObjHashtable theObjNrHashtable

    set array_name_list [array names theLXMObjHashtable]
    set array_Nr_list [lsort -real [array names theObjNrHashtable]]
    #   TlPrint "$array_name_list"
    #   TlPrint "$array_Nr_list"
    foreach i $array_Nr_list {
	TlPrint "%-40s -> %-20s" $theObjNrHashtable($i) $theLXMObjHashtable($theObjNrHashtable($i))
    }
};#Display_Objectlist

# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Read XML to know the good list of each parameter value
# Convert the value in number reading TXT file
# Store all informations in global array
#
# ----------HISTORY----------
# WANN      WER      WAS
# 230412    lefef    proc creation
# 070912    lefef    Add reverse operation number->value
#
# END----------------------------------------------------------------
proc Enum_number_init {} {
    #define arrays as global variable
    global AssociatedList mainpath
    global ListValue ListNumber ValuesList
    #use the package to read and parse xml files
    package require tdom

    #open and parse xml configuration file
    set EnumParametersXML $mainpath/ObjektDB/R3Dev_EnumParametersDescription_A1.3IE05_B03.xml
    set OpenEnumParameters [open $EnumParametersXML]
    set ReadEnumParameters [read $OpenEnumParameters]
    set doc [dom parse $ReadEnumParameters]
    set root [$doc documentElement]
    #take all parameters
    set parameterID [$root selectNodes /EnumParameters/EnumParameter/@paramID]
    #define the corresponding list of each parameter
    foreach ID_Param $parameterID {
	set ID [lindex $ID_Param 1]      ;#take just the ID number
	set  AssociatedList($ID) [$root selectNodes "string(/EnumParameters/EnumParameter\[@paramID='$ID'\]/@associatedListID)"]
	#puts "$ID : $AssociatedList($ID)"
    }
    #open and parse txt configuration file
    set ValueParametersTXT $mainpath/ObjektDB/R3Dev_RS3_DRIV_dsl_Gp_Generated_A1.3IE05_B03.txt
    set ValueParameters [open $ValueParametersTXT r]
    #for each list, puts each parameters of this list
    foreach line [split [read $ValueParameters] \n] {
	if {[lindex $line 1] == "always" || [lindex $line 1] == "never"} {      ;#way to find a news list line
	    set currentList [lindex $line 0]                                     ;#define a new list
	}  elseif {[lindex $line 0] != "List" && [lindex $line 0] != ""} {      ;#don't use uninteresting line
	    set Value [lindex $line 0]
	    set ListValue($currentList,$Value) [lindex $line 1]            ;#define the corresponding number of a value
	    set Number [lindex $line 1]
	    set ListNumber($currentList,$Number) [lindex $line 0]          ;#define the corresponding number of a value
	    lappend ValuesList($currentList) [lindex $line 1]
	    #   puts $ValuesList($currentList)
	}
    }

    close $OpenEnumParameters
    #  parray  ListValue
    #  parray  ListNumber
    #  parray  ValuesList

}

#DOC-------------------------------------------------------------------
# PROCEDURE   : read Variablelist from a file in hashtable
# TYPE        : Library
# AUTHOR      : pfeig
# DESCRIPTION :
#
# ----------HISTORY----------
# WANN      WER      WAS
# 220905    pfeig    ReadVARListFile Variablen übernahme mit Prefix versehen
# 110507    ockeg    Parameter "Print" für Ausgabe auf Bildschirm
# 310507    rothf    Auslesen der Parameter aus 0MAIN.txt verallgemeinert
# 111110    rothf    generate also modbus address for e.g. FastScope trace
#
#END-------------------------------------------------------------------
proc ReadVARListFile { FileName {Print 0} } {
    global theLXMVARHashtable theVARNrHashtable

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set var_file [open $FileName r]

	# ersten D-Bereich suchen
	while { [gets $var_file line] >= 0 } {
	    if {[CheckBreak]} {break}

	    #Header
	    if { [string match "D*" $line] == 1 } {
		set line [RemoveSpaceFromList $line]
		set wordList [split $line]
		set PreFix [lindex $wordList 2]

		#Variablen etc.
	    } elseif { [string match "E*" $line] == 1 } {

		switch -regexp $PreFix {
		    "DSP-Register" {#D 0 DSP-Register
                  #Wenn DSP-Register benötigt werden, hier anlegen
			continue
		    }

		    "Variablen" {#D -1 Variablen
			set line [RemoveSpaceFromList $line]
			set wordList [split $line]
			set ValList [split [lindex $wordList 2] "_"]
			set name ""
			append name $PreFix [lindex $wordList 1] "_" [lindex $ValList 0]

		    }

		    default {#alle anderen: D 1 - D xx
			set line [RemoveSpaceFromList $line]
			set wordList [split $line]
			set name ""

                  #ToDo: hier besteht noch Überarbeitungsbedarf. Im 0MAIN.txt sind einige
			#Variablen angelegt, die mit einem "$"-Zeichen beginnen. Da "$" in TCL einen
			#Variablenzugriff einleitet, wird ein $-String als Liste interpretiert und
			#dementsprechend mit geschweiften klammern ausgegeben.
			#SOLL: XXXXX_$xxx
			#IST:  XXXXX_{$xxx}
			#dots (.) in list will be replaced by underscore (_)
			append name  $PreFix "_" [string map {"$" "\$" "." "_"} [lindex $wordList 1]]

		    }
		};#switch

		set idx   [lindex $wordList 3]
		set six   [lindex $wordList 4]
		set obj   "$idx.$six"

		set theLXMVARHashtable($name)  $obj
		set theVARNrHashtable($obj) $name
		if { $Print } { TlPrint "$name  <- $obj" }      ;#optionale Ausgabe

	    };#if
	};#while

	TlPrint "**** Close file: $FileName"
	close $var_file
    } else {
	TlError "File $FileName not available!"
    }
};#ReadVARListFile

#DOC-------------------------------------------------------------------
# PROCEDURE   : read objectlist from a file in hashtable
# TYPE        :  Library
# AUTHOR      : HogeS
# DESCRIPTION :
#    ObjectList = Path + objdefs.h
#
# 070125 rothf Einlesen der objdefs.h verallgemeinert
#
#END-------------------------------------------------------------------
proc ReadLXMObjectListFile { FileName } {
    global theLXMObjHashtable theLXMObjNrHashtable

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Oeffne Datei: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    if { [string match "* O_*" $line] == 1 } {

		set line [RemoveSpaceFromList $line]
		set wordList [split $line]
		set ValList [split [lindex $wordList 1] "_"]
		set name ""
		append name [lindex $ValList 1] "." [lindex $ValList 2]

		set indexList [split [lindex $wordList 2] "L"]
		set index [expr [lindex $indexList 0] & 0x0000FFFF]
		set subindex [expr [lindex $indexList 0] >> 16]
		set subindex [expr $subindex & 0x0000FFFF]

		#notwendig. um die Hauptkategorien zu entfernen (z.B: MAND.   )
		if {[llength [split $name .]] == 2} {
		    set ObjectNr "$index.$subindex"
		    set theLXMObjHashtable($name)  $ObjectNr
		    set theLXMObjNrHashtable($ObjectNr) $name
		}
	    }
	}
	TlPrint "**** Schliesse Datei: $FileName"
	close $file
    } else {
	TlError "File $FileName not available!"
    }
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : read objectlist from a file in hashtable
# TYPE        :  Library
# AUTHOR      : HogeS
# DESCRIPTION :
#    ObjectList = Path + objdefs.h
#
# 120710   rothf    proc created
#
#END-------------------------------------------------------------------
proc ReadParameterFile_ATV_old { FileName } {
    global theATVParaNameTable theATVParaIndexTable

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    if { [string match "/*" $line] == 1 } {
		continue
	    }
	    set line [RemoveSpaceFromList $line]
	    set wordList [split $line]
	    set theATVParaNameTable([lindex $wordList 0]) [lindex $wordList 1]
	    set theATVParaIndexTable([lindex $wordList 1]) [lindex $wordList 0]

	    TlPrint "theATVParaNameTable([lindex $wordList 0]) = $theATVParaNameTable([lindex $wordList 0])"

	}
	TlPrint "**** Close file: $FileName"
	close $file
    } else {
	TlError "File $FileName not available!"
	exit
    }
}

#DOC-------------------------------------------------------------------
# PROCEDURE   : read objectlist from a file in hashtable
# TYPE        : Library
# AUTHOR      : pfeig
# DESCRIPTION :
#
#
# 130712   pfeig    proc created
# 310713   todet    seperate arrays for 'parameter to enum-list' and 'enum-list to value' assignment
#END-------------------------------------------------------------------
proc ReadParaFile_ATV { FileName } {
    global theATVParaNameTable theATVParaIndexTable theATVenumListTable theATVenumValueTable theATVenumNameTable

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    if { [string match "/*" $line] == 1 } {
		if { [string match "//@ AddressEnd" $line] == 1 } {
		    break
		}
		continue
	    }
	    set line [RemoveSpaceFromList $line]
	    set wordList [split $line]
	    set theATVParaNameTable([lindex $wordList 0]) [lindex $wordList 2]
	    set theATVParaIndexTable([lindex $wordList 2]) [lindex $wordList 0]

	    # TlPrint "theATVParaNameTable([lindex $wordList 0]) = $theATVParaNameTable([lindex $wordList 0])"
	    if {[CheckBreak] == 1} {break}
	}
	set theATVenumTypeList {}
	array unset theATVenumTypeArr
	array unset theATVenumValArr

	set actualList ""

	while { [gets $file line] >= 0 } {
	    #puts "$line"
	    if { ([string match "// *" $line] == 1) ||  [string length $line] < 1 } {
		continue
	    } elseif { [string match "// All numeric types" $line] == 1 } {
		#TlPrint "Hello1: $line"
		break

	    } elseif { [string match "//@ List :*" $line] == 1 } {
		set actualList [string range $line 11 end]
		#TlPrint $actualList
		continue

	    } elseif { [string match "//@ Param :*" $line] == 1 } {

		#TlPrint "Hello3: $line"
		set line [RemoveSpaceFromList $line]
		set wordList [split $line]
		set ParamName [lindex $wordList 3]

		if {$actualList == ""} {continue}
		set theATVenumListTable($ParamName) $actualList
		continue

	    } elseif { [string match "//@ ListEnd*" $line] == 1 } {

		set actualList ""
		continue
	    }

	    set line [RemoveSpaceFromList $line]
	    # TlPrint "Hello4: $line"
	    set wordList [split $line]

	    if {[lindex $wordList 0] == "//@"} {continue}

	    set StrgStart [expr [string first "//" $line] + 3]
	    set StrgEnd [string length $line]
	    set Info [string range $line $StrgStart $StrgEnd]
	    set EnumName [string range [lindex $wordList 0] [expr [string length $actualList] + 1] end ]
	    set EnumValue [lindex $wordList 2]

	    set theATVenumValueTable($actualList,$EnumName,Value) $EnumValue
	    set theATVenumValueTable($actualList,$EnumName,Info) $Info
	    set theATVenumNameTable($actualList,$EnumValue) $EnumName

	    if {[CheckBreak] == 1} {break}
	}
	TlPrint "**** Close file: $FileName"
	close $file

    } else {
	TlError "File $FileName not available!"
	exit
    }
}

#DOC-------------------------------------------------------------------
# read in Safety parameter CSV
#
#
# 030216   todet    proc created
#END-------------------------------------------------------------------
proc ReadParaFile_Safety { FileName } {
    global theNERAParaNameRecord theNERAParaIndexRecord theNERAParaTypeRecord theNERAParaLengthRecord

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    if { [string match "/*#" $line] == 1 } {
		continue
	    }
	    set wordList [split $line ";"]
	    set theNERAParaNameRecord([lindex $wordList 1]) [lindex $wordList 0]
	    set theNERAParaIndexRecord([lindex $wordList 0]) [lindex $wordList 1]
	    switch -exact [lindex $wordList 2] {
		"S16" {
		    set theNERAParaTypeRecord([lindex $wordList 1]) "INT16"
		    set theNERAParaLengthRecord([lindex $wordList 1]) 2
		}
		"U16" {
		    set theNERAParaTypeRecord([lindex $wordList 1]) "UINT16"
		    set theNERAParaLengthRecord([lindex $wordList 1]) 2
		}
		"S32" {
		    set theNERAParaTypeRecord([lindex $wordList 1]) "INT32"
		    set theNERAParaLengthRecord([lindex $wordList 1]) 4
		}
		"U32" {
		    set theNERAParaTypeRecord([lindex $wordList 1]) "UINT32"
		    set theNERAParaLengthRecord([lindex $wordList 1]) 4
		}
		default {
		    set theNERAParaTypeRecord([lindex $wordList 1]) "UINT16"
		    set theNERAParaLengthRecord([lindex $wordList 1]) 2
		}
	    }

	    if {[CheckBreak] == 1} {break}
	}

	TlPrint "**** Close file: $FileName"
	close $file

    } else {
	TlError "File $FileName not available!"
	exit
    }
}

#DOC-------------------------------------------------------------------
# read in Safety Error XML
#
#
# 090216   todet    proc created
#END-------------------------------------------------------------------
proc ReadErrorFile_Safety { FileName } {
    global theSafetyErrorList

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set File [open $FileName r]

	set ReadParameters [read $File]
	set doc [dom parse $ReadParameters]
	set root [$doc documentElement]

	set theSafetyErrorList {}

	foreach collection [$root childNodes] {

	    set NodeName [$collection nodeName]

	    if {$NodeName == "SafetyErrors"} {

		foreach item [$collection childNodes] {

		    if {[$item nodeName] == "item"} {

			set ErrorNumber ""
			set ErrorClass ""
			set ErrorName ""
			set ErrorDescription ""
			set ErrorRootCause ""
			set ErrorIsResetable ""
			set AtvFaultRegister ""

			foreach element [$item childNodes] {

			    set E_name [$element nodeName]
			    if {[$element childNodes] != ""} {
				set E_value [[$element childNodes] nodeValue]
			    }

			    set $E_name $E_value

			}

			lappend theSafetyErrorList [list $ErrorNumber $ErrorClass $ErrorName $ErrorDescription $ErrorRootCause $ErrorIsResetable $AtvFaultRegister]

		    }
		}

	    } ;#if {$NodeName == "SafetyErrors"}

	} ;# foreach collection

	TlPrint "**** Close file: $FileName"
	close $File

    } else {
	TlError "File $FileName not available!"
	exit
    }
}

# create global array of parameter address relation
#
# ----------HISTORY----------
# when   who   what
# 170713 pfeig proc creation
# 310713 todet seperate arrays for 'parameter to enum-list' and 'enum-list to value' assignment
#
#END-------------------------------------------------------------------
proc ReadParaFile_NERA { FileName } {
    global theNERAParaNameTable theNERAParaIndexTable theNERAenumListTable theNERAenumValueTable theNERAenumNameTable

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $FileName r]

	while { [gets $file line] >= 0 } {
	    if { [string match "/*" $line] == 1 } {
		if { [string match "//@ AddressEnd" $line] == 1 } {
		    break
		}
		continue
	    }
	    set line [RemoveSpaceFromList $line]
	    set wordList [split $line]
	    set theNERAParaNameTable([lindex $wordList 0]) [lindex $wordList 2]
	    set theNERAParaIndexTable([lindex $wordList 2]) [lindex $wordList 0]

	    #  TlPrint "theNERAParaNameTable([lindex $wordList 0]) = $theNERAParaNameTable([lindex $wordList 0])"
	    if {[CheckBreak] == 1} {break}
	}
	set theNERAenumTypeList {}
	array unset theNERAenumTypeArr
	array unset theNERAenumValArr

	set actualList ""

	while { [gets $file line] >= 0 } {
	    #puts "$line"
	    if { ([string match "// *" $line] == 1) ||  [string length $line] < 1 } {
		continue
	    } elseif { [string match "// All numeric types" $line] == 1 } {
		#TlPrint "Hello1: $line"
		break

	    } elseif { [string match "//@ List :*" $line] == 1 } {
		set actualList [string range $line 11 end]
		#TlPrint $actualList
		continue

	    } elseif { [string match "//@ Param :*" $line] == 1 } {

		#TlPrint "Hello3: $line"
		set line [RemoveSpaceFromList $line]
		set wordList [split $line]
		set ParamName [lindex $wordList 3]

		if {$actualList == ""} {continue}
		set theNERAenumListTable($ParamName) $actualList
		continue

	    } elseif { [string match "//@ ListEnd*" $line] == 1 } {

		set actualList ""
		continue
	    }

	    set line [RemoveSpaceFromList $line]
	    # TlPrint "Hello4: $line"
	    set wordList [split $line]

	    if {[lindex $wordList 0] == "//@"} {continue}

	    set StrgStart [expr [string first "//" $line] + 3]
	    set StrgEnd [string length $line]
	    set Info [string range $line $StrgStart $StrgEnd]
	    set EnumIdent [split [lindex $wordList 0] "_"]
	    set EnumValue [lindex $wordList 2]

	    set EnumList [lindex $EnumIdent 0]
	    set EnumName [lindex $EnumIdent 1]

	    set theNERAenumValueTable($EnumList,$EnumName,Value) $EnumValue
	    set theNERAenumValueTable($EnumList,$EnumName,Info) $Info
	    set theNERAenumNameTable($actualList,$EnumValue) $EnumName

	    if {[CheckBreak] == 1} {break}
	}
	TlPrint "**** Close file: $FileName"
	close $file

    } else {
	TlError "File $FileName not available!"
	exit
    }

}

# create global array of parameter address relation
#
# ----------HISTORY----------
# when   who   what
# 310713 todet proc creation
# 261023 asy   update to clear variables at loading of the file
#
#END-------------------------------------------------------------------

proc ReadParaFile_AltiLab {FileName} {

    global theNERAParaNameRecord theNERAParaIndexRecord theNERAParaTypeRecord theNERAParaLengthRecord theNERAParaModifiableRecord
    global theNERAenumListRecord theNERAenumValueRecord theNERAenumNameRecord
    # only for comparsion:
    global theNERAParaNameTable theNERAParaIndexTable theNERAenumListTable theNERAenumValueTable theNERAenumNameTable

    # for internal variables
    global theNERAIntVarNameRecord theNERAIntVarIndexRecord theNERAIntVarTypeRecord theNERAIntVarLengthRecord theNERAIntVarCpuRecord

    #Reset the global variables  
    set variableList [list theNERAParaNameRecord theNERAParaIndexRecord theNERAParaTypeRecord theNERAParaLengthRecord theNERAParaModifiableRecord theNERAenumListRecord theNERAenumValueRecord theNERAenumNameRecord \
			   theNERAIntVarNameRecord theNERAIntVarIndexRecord theNERAIntVarTypeRecord theNERAIntVarLengthRecord theNERAIntVarCpuRecord ]
    foreach globVar $variableList {
	    if { [info exists $globVar] } { unset $globVar }
    }
    # CRC of firmware
    global theAltilabXML_ARM_CRC theAltilabXML_DSP_CRC

    set theAltilabXML_ARM_CRC 0
    set theAltilabXML_DSP_CRC 0

    #define arrays as global variable
    global AssociatedList mainpath
    global ListValue ListNumber ValuesList
    #use the package to read and parse xml files
    package require tdom

    #open and parse xml configuration file
    if { ![file exists $FileName] } {
	TlPrint ""
	TlPrint "==> ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR      not existent parameter database                  ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR      %-30s                   ERROR" [file tail $FileName]
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR                                                       ERROR"
	TlPrint "==> ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR"
	TlPrint ""
	TlInput "ENTER to continue..." ""
	return 0
    }
    TlPrint "open parameter database: $FileName"
    set OpenParameters [open $FileName]
    set ReadParameters [read $OpenParameters]
    #puts "ReadParameters: $ReadParameters"
    set doc [dom parse $ReadParameters]
    set root [$doc documentElement]

    #array unset dummy

    # set to 1, if values of theNERA...Record and theNERA...Table shall be compared
    set compare 0

    foreach collection [$root childNodes] {

	set NodeName   [$collection nodeName]

	if {$NodeName == "dataobjectcollection"} {

	    set ColGroup   [$collection getAttribute defaultgroupname "EMPTY"]
	    set ColID      [$collection getAttribute id "EMPTY"]
	    set ColName    [$collection getAttribute name "EMPTY"]
	    set CPU        0

	    switch -exact $ColID {
		"PARAM" {

		    # get chlid nodes
		    foreach sublist [$collection childNodes] {

			set SubNodeName   [$sublist nodeName]

			if {$SubNodeName == ""} {continue}

			switch -exact $SubNodeName {

			    "choicetypelist" {
				foreach choicetype [$sublist childNodes] {

				    set ObjectName   [$choicetype nodeName]

				    if {$ObjectName == ""} {continue}

				    # skip comment lines
				    if {$ObjectName != "choicetype"} {continue}

				    foreach element [$choicetype childNodes] {

					set ElementName   [$element nodeName]
					if {$ElementName != "choice"} {continue}

					#get text of node (first child of element)
					set enum [$element firstChild]

					if {$enum == ""} {continue}

					set Parameter [$choicetype getAttribute id "EMPTY"]
					set EnumName [$enum nodeValue]
					set EnumValue [$element getAttribute value "0"]

					#puts "$Parameter . $EnumName = $EnumValue"

					set theNERAenumValueRecord($Parameter,$EnumName,Value) $EnumValue
					set theNERAenumValueRecord($Parameter,$EnumName,Info) "empty"
					set theNERAenumNameRecord($Parameter,$EnumValue) $EnumName

				    } ;#foreach element

				} ;#foreach choicetype

			    }

			    "dataobjectlist" {

				foreach dataobject [$sublist childNodes] {

				    set ObjectName   [$dataobject nodeName]

				    if {$ObjectName == ""} {continue}

				    # skip comment lines
				    if {$ObjectName != "dataobject"} {continue}

				    set shortname ""
				    set longname ""
				    set address ""
				    set bytesize ""
				    set modifiable ""
				    set datatype ""
				    set family ""
				    set choicetype ""

				    foreach element [$dataobject childNodes] {

					set ElementName   [$element nodeName]
					if {$ElementName == ""} {continue}

					#get text of node (first child of element)
					set element [$element firstChild]

					if {$element == ""} {continue}

					switch -exact $ElementName {

					    "shortname"    { set shortname   [$element nodeValue]}
					    "address"      { set address     [$element nodeValue]}
					    "datatype"     { set datatype    [$element nodeValue]}
					    "choicetype"   { set choicetype  [$element nodeValue]}
					    "bytesize"     { set bytesize    [$element nodeValue]}
					    #"longname"     { set longname    [$element nodeValue]}
					    "modifiable"   { set modifiable  [$element nodeValue]}
					    #"family"       { set family      [$element nodeValue]}

					    default {}

					};# switch ElementName

				    } ;#foreach element

				    #set dummy($shortname,"longname") $longname
				    #set dummy($shortname,"address") $address
				    #set dummy($shortname,"bytesize") $bytesize
				    #set dummy($shortname,"modifiable") $modifiable
				    #set dummy($shortname,"family") $family
				    set theNERAParaModifiableRecord($shortname) $modifiable
				    set theNERAParaNameRecord($shortname) $address
				    set theNERAParaIndexRecord($address) $shortname
				    set theNERAParaLengthRecord($shortname) $bytesize

				    if {$choicetype != ""} {
					set theNERAenumListRecord($shortname) $choicetype
				    }

				    if { ([string index $datatype 0] == "U") || ([string index $datatype 0] == "B") } {
					#set dummy($shortname,"datatype") [string replace $datatype 0 0 "UINT"]
					#set theNERAenumTypeRecord($shortname) [string replace $datatype 0 0 "UINT"]
					set theNERAParaTypeRecord($shortname) [string replace $datatype 0 0 "UINT"]
				    } else {
					#set dummy($shortname,"datatype") [string replace $datatype 0 0 "INT"]
					#set theNERAenumTypeRecord($shortname) [string replace $datatype 0 0 "INT"]
					set theNERAParaTypeRecord($shortname) [string replace $datatype 0 0 "INT"]
				    }

				} ;#foreach dataobject

			    }

			    default { }
			};# switch SubNodeName

		    } ;# foreach sublist

		}

		"ARMV" -
		"ARMR" -
		"ARMS" -
		"DSPV" -
		"DSPR" -
		"ENCR" -
		"CTRLV" -
		"CTRLR" -
		"CTRLS" -
		"PWRV" {
		    # get chlid nodes

		    set CPU    [$collection getAttribute cpu "0"]

		    foreach sublist [$collection childNodes] {

			set SubNodeName   [$sublist nodeName]

			if {$SubNodeName == ""} {continue}

			switch -exact $SubNodeName {

			    "dataobjectlist" {

				foreach dataobject [$sublist childNodes] {

				    set ObjectName   [$dataobject nodeName]

				    if {$ObjectName == ""} {continue}

				    # skip comment lines
				    if {$ObjectName != "dataobject"} {continue}

				    set shortname ""
				    set address ""
				    set bytesize ""
				    set datatype ""

				    foreach element [$dataobject childNodes] {

					set ElementName   [$element nodeName]
					if {$ElementName == ""} {continue}

					#get text of node (first child of element)
					set element [$element firstChild]

					if {$element == ""} {continue}

					switch -exact $ElementName {

					    "shortname"    { 
						    if { $ColID == "PWRV"} {
							set shortname   "PWR_[$element nodeValue]"
						    } else {
						    	set shortname   [$element nodeValue]
						    }
					    }
					    "address"      { set address     [$element nodeValue]}
					    "datatype"     { set datatype    [$element nodeValue]}
					    "bytesize"     { set bytesize    [$element nodeValue]}

					    default {}

					};# switch ElementName

				    } ;#foreach element

				    regsub -all {\[} $shortname {(} shortname
				    regsub -all {\]} $shortname {)} shortname

				    set theNERAIntVarNameRecord($shortname) [string tolower $address]
				    set theNERAIntVarIndexRecord([string tolower $address]) $shortname
				    set theNERAIntVarLengthRecord($shortname) $bytesize
				    set theNERAIntVarCpuRecord($shortname) $CPU

				    if { ([string index $datatype 0] == "U") || ([string index $datatype 0] == "B") } {
					#set dummy($shortname,"datatype") [string replace $datatype 0 0 "UINT"]
					#set theNERAenumTypeRecord($shortname) [string replace $datatype 0 0 "UINT"]
					set theNERAIntVarTypeRecord($shortname) [string replace $datatype 0 0 "UINT"]
				    } else {
					#set dummy($shortname,"datatype") [string replace $datatype 0 0 "INT"]
					#set theNERAenumTypeRecord($shortname) [string replace $datatype 0 0 "INT"]
					set theNERAIntVarTypeRecord($shortname) [string replace $datatype 0 0 "INT"]
				    }

				} ;#foreach dataobject

			    }

			    "checkcrc" {

				set valueCRC 0

				foreach dataobject [$sublist childNodes] {

				    set ElementName   [$dataobject nodeName]

				    if {$ElementName == ""} {continue}

				    set element [$dataobject firstChild]

				    if {$element == ""} {continue}

				    switch -exact $ElementName {

					"value"    { set valueCRC   [$element nodeValue]}
					"accessid" {
					    if {$ColID == "ARMV"} {
						set theAltilabXML_ARM_CRC $valueCRC
					    } elseif {$ColID == "DSPV"} {
						set theAltilabXML_DSP_CRC $valueCRC
					    }
					}

					default {}

				    };# switch ElementName

				} ;#foreach dataobject

			    }

			    default { }
			};# switch SubNodeName

		    } ;# foreach sublist

		}

		default { }
	    } ;# switch ColID

	} ;#if {$NodeName == "dataobjectcollection"}

    } ;# foreach collection

    if {$compare == 1} {

	set RecordNames [array names theNERAParaNameRecord]
	set TableNames [array names theNERAParaNameTable]

	set MissingInRecordCount 0
	set MissingInTableCount 0
	set MissmatchParaName 0
	set RecordCount [llength $RecordNames]
	set TableCount  [llength $TableNames]

	set MissingInRecordCount2 0
	set MissingInTableCount2 0
	set MissmatchParaName2 0

	set MissingInRecordCount3 0
	set MissingInTableCount3 0
	set MissmatchParaName3 0

	foreach name $RecordNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAParaNameTable($name)}] } {
		#puts "$name not in theNERAParaNameTable"
		incr MissingInTableCount
	    } else {
		if {$theNERAParaNameRecord($name) != $theNERAParaNameTable($name)} {
		    puts "missmatch ($name): $theNERAParaNameRecord($name) vs. $theNERAParaNameTable($name)"
		    incr MissmatchParaName
		}
	    }
	}

	puts ""

	foreach name $TableNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAParaNameRecord($name)}] } {
		#puts "$name not in theNERAParaNameRecord"
		incr MissingInRecordCount
	    }
	}

	puts ""

	set RecordNames [array names theNERAenumValueRecord]
	set TableNames [array names theNERAenumValueTable]

	set RecordCount2 [llength $RecordNames]
	set TableCount2  [llength $TableNames]

	foreach name $RecordNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAenumValueTable($name)}] } {
		#puts "$name not in theNERAenumTypeArr"
		incr MissingInTableCount2
	    } else {
		if {$theNERAenumValueRecord($name) != $theNERAenumValueTable($name)} {
		    if {[string first ",Info" $name] == -1} {
			puts "missmatch ($name): theNERAenumValueRecord($theNERAenumValueRecord($name)) vs. theNERAenumValueTable($theNERAenumValueTable($name))"
			incr MissmatchParaName2
		    }
		}
	    }
	}

	puts ""

	foreach name $TableNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAenumValueRecord($name)}] } {
		#puts "$name not in theNERAenumTypeRecord"
		incr MissingInRecordCount2
	    }
	}

	set RecordNames [array names theNERAenumListRecord]
	set TableNames [array names theNERAenumListTable]

	set RecordCount3 [llength $RecordNames]
	set TableCount3  [llength $TableNames]

	foreach name $RecordNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAenumListTable($name)}] } {
		#puts "$name not in theNERAenumListTable"
		incr MissingInTableCount3
	    } else {
		if {$theNERAenumListRecord($name) != $theNERAenumListTable($name)} {
		    puts "missmatch ($name): theNERAenumListRecord($theNERAenumListRecord($name)) vs. theNERAenumListTable($theNERAenumListTable($name))"
		    incr MissmatchParaName3
		}
	    }
	}

	puts ""

	foreach name $TableNames {
	    if {$name == ""} {continue}
	    if {[CheckBreak]} {break}
	    if { [catch {set dummy $theNERAenumListRecord($name)}] } {
		#puts "$name not in theNERAenumListRecord"
		incr MissingInRecordCount3
	    }
	}

	puts ""
	puts "##########################################"
	puts "Parameter names:"
	puts " $MissingInTableCount entrys missing in theNERAParaNameTable ($TableCount)"
	puts " $MissingInRecordCount entrys missing in theNERAParaNameRecord ($RecordCount)"
	puts " $MissmatchParaName missmatches"
	puts ""
	puts "Enumerations:"
	puts " $MissingInTableCount2 entrys missing in theNERAenumValueTable ($TableCount2)"
	puts " $MissingInRecordCount2 entrys missing in theNERAenumValueRecord ($RecordCount2)"
	puts " $MissmatchParaName2 missmatches"
	puts ""
	puts "Enumeration List:"
	puts " $MissingInTableCount3 entrys missing in theNERAenumListTable ($TableCount3)"
	puts " $MissingInRecordCount3 entrys missing in theNERAenumListRecord ($RecordCount3)"
	puts " $MissmatchParaName3 missmatches"
	puts "##########################################"

    }

    close $OpenParameters

}

# Read global array to write the value
# of a parameter enumaration type
#
# ----------HISTORY----------
# when   who   what
# 170713 pfeig proc creation
# 310713 todet adaption to new implemented parameter/enum lists
# 111013 todet execute in catch block, to avoid script abortion
# 120214 serio add TTId parameter
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------
proc Enum_Name {Parameter Value {TTId ""}} {
    global theATVenumListTable theATVenumNameTable
    global theNERAenumListRecord theNERAenumNameRecord
    global ActDev DevType

    set TTId [Format_TTId $TTId]

    if { [string is integer $Value] } {
	set rc [catch { set Value [format "%d" $Value] }]
    } else {
	TlError "not an integer: $Value"
	return ""
    }

    set retVal $Value
    set EnumList ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"ATS48P" -
	"OPTIM" -
	"BASIC" -
	"Opal" -
	"Nera" {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in

	    #if {$rc != 0} {TlError "$Parameter not existing in theNERAenumListRecord"}
	    if {$rc != 0} {

		set rc [catch { set EnumList $theNERAenumListRecord( [FindUnifiedMapping_ATS  $Parameter 4 1]) }]
	    #if {$rc != 0} {TlError "$Parameter not existing in theNERAenumListRecord"}

	    }
	    set rc [catch { set retVal $theNERAenumNameRecord($EnumList,$Value) }] ;#return the name of the value

	    #if {$rc != 0} {TlError "$EnumList,$Value not existing in theNERAenumNameRecord"}
	}
	"ATV310" - 
	"ATV310L" -
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set EnumList $theATVenumListTable($Parameter) }] ;#get the enum list to search in
	    #if {$rc != 0} {TlError "$Parameter not existing in theATVenumListTable"}
	    set rc [catch { set retVal $theATVenumNameTable($EnumList,$Value) }] ;#return the name of the value
	    #if {$rc != 0} {TlError "$EnumList,$Value not existing in theATVenumNameTable"}
	}

	default {
	    #Value for DeviceType has to be set in .ini file -> Type=....
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    set rc [catch { set retVal $theNERAenumNameRecord($EnumList,$Value) }] ;#return the name of the value
	}
    }

    return $retVal

}

# Read global array to write the value
# of a parameter enumaration type
#
# ----------HISTORY----------
# when   who   what
# 170713 pfeig proc creation
# 310713 todet adaption to new implemented parameter/enum lists
# 111013 todet execute in catch block, to avoid script abortion
# 120214 serio add TTId parameter
# 070514 ockeg discard a leading "." out of Name
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------
proc Enum_Value {Parameter Name {TTId ""}} {
    global theATVenumListTable theATVenumValueTable
    global theNERAenumListRecord theNERAenumValueRecord
    global ActDev DevType

    set retVal $Name
    set EnumList ""

    set TTId [Format_TTId $TTId]

    if { [string index $Name 0 ] == "." } {
	set Name  [string range $Name 1 end]
    }

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"ATS48P" -
	"OPTIM" -
	"BASIC" -
	"Opal" -
	"Nera" {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		set rc [catch { set EnumList $theNERAenumListRecord([FindUnifiedMapping_ATS  $Parameter 4 1]) }]
	    }
	    if {$rc != 0} {TlError "$TTId $Parameter and [FindUnifiedMapping_ATS  $Parameter 4] not existing in theNERAenumListRecord"}
	    set rc [catch { set retVal $theNERAenumValueRecord($EnumList,$Name,Value) }] ;#return the name of the value
	    if {$rc != 0} {TlError "$TTId enum $Name not existing in theNERAenumValueRecord"}
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set EnumList $theATVenumListTable($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {TlError "$TTId $Parameter not existing in theATVenumListTable"}
	    set rc [catch { set retVal $theATVenumValueTable($EnumList,$Name,Value) }] ;#return the name of the value
	    if {$rc != 0} {TlError "$TTId enum $Name not existing in theATVenumValueTable"}
	}
	default {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		    TlError "$TTId $Parameter not existing in theNERAenumListRecord"
		    return $retVal
	    }
	    set rc [catch { set retVal $theNERAenumValueRecord($EnumList,$Name,Value) }] ;#return the name of the value
	    if {$rc != 0} {TlError "$TTId enum $Name not existing in theNERAenumValueRecord"}
	}
    }

    return $retVal

}

#Read global array to return sorted list of possible values of a parameter enumeration type
#
# ----------HISTORY----------
# when   who   what
# 181213 serio proc creation
# 240214 serio adapted proc to remove duplicates returned by the global lists
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------

proc Enum_List_Values {Parameter} {

    global theATVenumListTable theATVenumValueTable
    global theNERAenumListRecord theNERAenumValueRecord
    global ActDev DevType

    set retVal {}
    set EnumList ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"ATS48P" -
	"OPTIM" -
	"BASIC" -
	"Opal" -
	"Nera" {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theNERAenumListRecord"
	    } else {
		foreach {name value} [array get theNERAenumValueRecord *$EnumList*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -integer -increasing $retVal]
	    }
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set EnumList $theATVenumListTable($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theATVenumListTable"
	    } else {
		foreach {name value} [array get theATVenumValueTable *$EnumList*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -integer -increasing $retVal]
	    }
	}

	default {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theNERAenumListRecord"
	    } else {
		foreach {name value} [array get theNERAenumValueRecord *$EnumList*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -integer -increasing $retVal]
	    }
	}
    }
}

#Read global array to return sorted list of possible names of a parameter enumeration type
#
# ----------HISTORY----------
# when   who   what
# 181213 serio proc creation
# 240214 serio adapted proc to remove duplicates returned by the global lists
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------

proc Enum_List_Names {Parameter} {

    global theATVenumListTable theATVenumNameTable
    global theNERAenumListRecord theNERAenumNameRecord
    global ActDev DevType

    set retVal {}
    set EnumList ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"ATS48P" -
	"OPTIM" -
	"BASIC" -
	"Opal" -
	"Nera" {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theNERAenumListRecord"
	    } else {
		foreach {name value} [array get theNERAenumNameRecord $EnumList,*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -ascii -increasing $retVal]
	    }
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set EnumList $theATVenumListTable($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theATVenumListTable"
	    } else {
		foreach {name value} [array get theATVenumNameTable *$EnumList*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -ascii -increasing $retVal]
	    }
	}
	default {
	    set rc [catch { set EnumList $theNERAenumListRecord($Parameter) }] ;#get the enum list to search in
	    if {$rc != 0} {
		TlError "$Parameter not existing in theNERAenumListRecord"
	    } else {
		foreach {name value} [array get theNERAenumNameRecord $EnumList,*] {
		    if {($value != "empty") && ([lsearch $retVal $value] == -1)} { lappend retVal $value }
		}
		set retVal [lsort -ascii -increasing $retVal]
	    }
	}
    }
}

# Read global array to get the name of a parameter out of it's index
# TCL>  ? Param_Name 9001
# Output : ACC
#
# ----------HISTORY----------
# when   who   what
# 111013 todet proc creation
# 301013 lefef NoErrorPrint argument
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------
proc Param_Name {ParameterIndex {NoErrorPrint 0}} {

    global theATVParaNameTable theATVParaIndexTable
    global theNERAParaNameRecord theNERAParaIndexRecord
    global ActDev DevType

    set retVal ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"Opal" -
	"Nera" {
	    set rc [catch { set retVal $theNERAParaIndexRecord($ParameterIndex) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterIndex not existing in theNERAParaIndexRecord Param-Name"
		return 0
	    }
	}
	"ATS48P" -
	"BASIC" -
	"OPTIM" {
	    set rc [catch { set retVal $theNERAParaIndexRecord($ParameterIndex) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {

		TlError "$ParameterIndex not existing in theNERAParaIndexRecord Param-name 2 $ParameterIndex"
		return 0
	    }
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set retVal $theATVParaIndexTable($ParameterIndex) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterIndex not existing in theATVParaIndexTable"
		return 0
	    }
	}
	default {
	    set rc [catch { set retVal $theNERAParaIndexRecord($ParameterIndex) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterIndex not existing in theNERAParaIndexRecord Param-Name"
		return 0
	    }
	}
    }
    return $retVal
}

# Read global array to get the Index of a parameter out of it's name
# TCL>  ? Param_Index ACC
# Output : 9001
#
# ----------HISTORY----------
# when   who   what
# 111013 todet proc creation
# 301013 lefef NoErrorPrint argument
# 240315 serio add TTId argument
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------
proc Param_Index {ParameterName {NoErrorPrint 0} {TTId ""}} {
    global theATVParaNameTable theATVParaIndexTable
    global theNERAParaNameRecord theNERAParaIndexRecord
    global ActDev DevType
    global ATSUnifiedMapping_Table

    set retVal ""

    set TTId [Format_TTId $TTId]

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"Opal" -
	"Nera" {
	    set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$TTId $ParameterName not existing in theNERAParaNameRecord KALA"
		return 0
	    }
	}
	"ATS48P" -
	"BASIC" -
	"OPTIM" {
		set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
		if {$rc != 0} {
		    #set retVal [Param_Index [FindUnifiedMapping_ATS $ParameterName 4]]
		    set rc2 [catch {set retVal $theNERAParaNameRecord([FindUnifiedMapping_ATS $ParameterName 4 ])} ]
		    if {(!$NoErrorPrint)&& ($rc2 != 0)} {
			TlError "$TTId $ParameterName not not existing in theNERAParaNameRecord ATLAS"
			return 0
		    } else {
			return $retVal
		    }
		} else {
		    return $retVal
		}
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set retVal $theATVParaNameTable($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$TTId $ParameterName not existing in theATVParaNameTable"
		return 0
	    }
	}
	default {
	    set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$TTId $ParameterName not existing in theNERAParaNameRecord KALA"
		return 0
	    }
	}
    }
    return $retVal
}

# Read global array to get when the parameter can be modified 
#TCL>  ? Param_Modifiable ACC
#Output : always#
# ----------HISTORY----------
# when   who   what
# 060524 asy  remove the switch because all the products have the same behaviour, including generic ones 
#
#-------------------------------------------------------------------------------------------------------
proc Param_Modifiable {ParameterName {NoErrorPrint 0} {TTId ""}} {
	global theATVParaNameTable theATVParaIndexTable
	global theNERAParaNameRecord theNERAParaIndexRecord theNERAParaModifiableRecord
	global ActDev DevType

	set retVal ""

	set TTId [Format_TTId $TTId]

	set rc [catch { set retVal $theNERAParaModifiableRecord($ParameterName) }]
	if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$TTId $ParameterName not existing in theNERAParaModifiableRecord"
		return 0
	}

	return $retVal

}

# Read global array to get the type of a parameter
# TCL>  ? Param_Type ACC
# Output : UINT16
#
# ----------HISTORY----------
# when   who   what
# 111013 todet proc creation
# 301013 lefef NoErrorPrint argument
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#-------------------------------------------------------------------------------------------------------
proc Param_Type {ParameterName {NoErrorPrint 0}} {
    global theNERAParaTypeRecord theATVParaTypeTable
    global ActDev DevType

    set retVal ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"Opal" -
	"Nera" {
	    set rc [catch { set retVal $theNERAParaTypeRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAParaTypeRecord"
		return 0
	    }
	}
	"ATS48P" -
	"OPTIM" -
	"BASIC" {
	    set rc [catch { set retVal $theNERAParaTypeRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		set rc2 [catch {set retVal $theNERAParaTypeRecord([FindUnifiedMapping_ATS $ParameterName 4 ])} ]
		if {(!$NoErrorPrint)&& ($rc2 != 0)} {
		    TlError "$ParameterName not existing in theNERAParaTypeRecord"
		    return 0
		} else {
		    return $retVal
		}
	    }
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set retVal $theATVParaTypeTable($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theATVParaTypeTable"
		return 0
	    }
	}
	default {
	    set rc [catch { set retVal $theNERAParaTypeRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAParaTypeRecord"
		return 0
	    }
	}
    }
    return $retVal
}


# Read global array to get the length in bytes of a parameter
# TCL>  ? Param_Length TBR2
# Output : 1
#
# ----------HISTORY----------
# when   who   what
# 181213 ockeg proc creation
# 060524 asy   remove error mechanism, nera behaviour instead to allow generic and new kind of devices
#
#----------------------------------------------------------------------------------------------------
proc Param_Length {ParameterName {NoErrorPrint 0}} {

    global theNERAParaLengthRecord theATVParaLengthTable
    global ActDev DevType

    set retVal ""

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"Opal" -
	"Nera" {
	    set rc [catch { set retVal $theNERAParaLengthRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAParaLengthRecord"
		return 0
	    }
	}
	"ATS48P" -
	"OPTIM" -
	"BASIC" {
	    set rc [catch { set retVal $theNERAParaLengthRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAParaLengthRecord"
		return 0
	    }
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set retVal $theATVParaLengthTable($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theATVParaLengthTable"
		return 0
	    }
	}
	default {
	    set rc [catch { set retVal $theNERAParaLengthRecord($ParameterName) }]
	    if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAParaLengthRecord"
		return 0
	    }
	}
    } 
    return $retVal
}

# Read global array to get the description of a parameter
# TCL>  ? Param_Desc HMIS
# Output : Product status
#
# ----------HISTORY----------
# When   Who   What
# 160714 weiss proc creation
#
#-------------------------------------------------------------------------------------------------------
proc Param_Desc {ParameterName {NoErrorPrint 0}} {
    global theAltiLabParameterFile

    # get longname
    set     SearchList {}
    lappend SearchList device
    lappend SearchList [list dataobjectcollection [list Attr id=PARAM]]
    lappend SearchList dataobjectlist
    lappend SearchList [list dataobject [list Attr id=$ParameterName]]
    lappend SearchList longname
    set longname [ParseXmlFile $theAltiLabParameterFile $SearchList]
    #TlPrint "longname=$longname"

    regsub -all "%" $longname "pcent" longname   ;#Caracter "%" not allowed in strings

    return $longname
};#Param_Desc

# Read global array to see if a parameter is available in currently loaded product 
# TCL>  ? Param_Exists ACC
# Output : 1
#
# ----------HISTORY----------
# when   who   what
# 2024/07/02 ASY proc created 
#-------------------------------------------------------------------------------------------------------
proc Param_Exists {ParameterName {NoErrorPrint 0} {TTId "" } } {
    global theATVParaNameTable theATVParaIndexTable
    global theNERAParaNameRecord theNERAParaIndexRecord
    global ActDev DevType
    global ATSUnifiedMapping_Table

    set retVal ""

    set TTId [Format_TTId $TTId]

    switch -exact $DevType($ActDev,Type) {
	"Beidou" -
	"Fortis" -
	"MVK" -
	"Opal" -
	"Nera" {
	    set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
	    if {($rc != 0)} {
		TlPrint "$ParameterName not existing in theNERAParaNameRecord KALA"
		return 0
	    }
	}
	"ATS48P" -
	"BASIC" -
	"OPTIM" {
		set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
		if {$rc != 0} {
		    #set retVal [Param_Index [FindUnifiedMapping_ATS $ParameterName 4]]
		    set rc2 [catch {set retVal $theNERAParaNameRecord([FindUnifiedMapping_ATS $ParameterName 4 ])} ]
		    if {($rc2 != 0)} {
			TlPrint "$ParameterName not not existing in theNERAParaNameRecord ATLAS"
			return 0
		    } else {
			return 1
		    }
		} else {
		    return 1
		}
	}
	"ATV310" - 
	"ATV310L" - 
	"ATV310E" - 
	"Altivar" {
	    set rc [catch { set retVal $theATVParaNameTable($ParameterName) }]
	    if {($rc != 0)} {
		TlPrint "$ParameterName not existing in theATVParaNameTable"
		return 0
	    }
	}
	default {
	    set rc [catch { set retVal $theNERAParaNameRecord($ParameterName) }]
	    if {($rc != 0)} {
		TlPrint "$TTId $ParameterName not existing in theNERAParaNameRecord KALA"
		return 0
	    }
	}
    }
    return 1
}
# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
# 060524 asy   remove switch, all the products including generic behave the same 
#
#-------------------------------------------------------------------------------------------------------
proc IntVar_Index {ParameterName {NoErrorPrint 0}} {
	# for internal variables
	global theNERAIntVarNameRecord 

	set retVal ""

	set rc [catch { set retVal $theNERAIntVarNameRecord($ParameterName) }]
	if {(!$NoErrorPrint)&& ($rc != 0)} {
		TlError "$ParameterName not existing in theNERAIntVarNameRecord"
		return 0
	}

	return $retVal
}

# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
# 060524 asy   remove switch, all the products including generic behave the same 
#
#-------------------------------------------------------------------------------------------------------
proc IntVar_Name {ParameterIndex {NoErrorPrint 0}} {
    # for internal variables
    global theNERAIntVarIndexRecord

    set retVal ""

    set ParameterIndex [format "0x%08X" $ParameterIndex]
    set ParameterIndex [string tolower $ParameterIndex]

    set rc [catch { set retVal $theNERAIntVarIndexRecord($ParameterIndex) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	    TlError "$ParameterIndex not existing in theNERAIntVarIndexRecord"
	    return 0
    }

    return $retVal
}

# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
# 060524 asy   remove switch, all the products including generic behave the same 
#
#-------------------------------------------------------------------------------------------------------
proc IntVar_Type {ParameterName {NoErrorPrint 0}} {
    # for internal variables
    global theNERAIntVarTypeRecord 

    set retVal ""

    set rc [catch { set retVal $theNERAIntVarTypeRecord($ParameterName) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	    TlError "$ParameterName not existing in theNERAIntVarTypeRecord"
	    return 0
    }

    return $retVal
}

# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
# 060524 asy   remove switch, all the products including generic behave the same 
#
#-------------------------------------------------------------------------------------------------------
proc IntVar_Length {ParameterName {NoErrorPrint 0}} {
    # for internal variables
    global theNERAIntVarLengthRecord 

    set retVal ""

    set rc [catch { set retVal $theNERAIntVarLengthRecord($ParameterName) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	    TlError "$ParameterName not existing in theNERAIntVarLengthRecord"
	    return 0
    }

    return $retVal
}

# ----------HISTORY----------
# when   who   what
# 140414 todet proc creation
# 060524 asy   remove switch, all the products including generic behave the same 
#
#-------------------------------------------------------------------------------------------------------
proc IntVar_CPU {ParameterName {NoErrorPrint 0}} {
    # for internal variables
    global theNERAIntVarCpuRecord

    set retVal ""

    set rc [catch { set retVal $theNERAIntVarCpuRecord($ParameterName) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	    TlError "$ParameterName not existing in theNERAIntVarCpuRecord"
	    return 0
    }

    return $retVal
}

#DOC-------------------------------------------------------------------------------------------------
# DESCRIPTION
#
# Common function for Altivar/Nera/Opal to get the
# attributes of a parameter:  {MBAdr CanIx CanSix DataType DataLength ShortName}
#
#  Example
#   <dataobject id="FR1">
#   <shortname>FR1</shortname>
#   <longname>Reference source 1</longname>
#   <address type="modbus">8413</address>
#   <bytesize>2</bytesize>
#   <modifiable>gatingOff</modifiable>
#   <datatype>U16</datatype>
#   <choicetype>PSA</choicetype>
#   <family>configuration</family>
#   </dataobject>
#
#   TCL>  ? GetParaAttributes FR1
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
#   TCL>  ? GetParaAttributes 8413
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
#   TCL>  ? GetParaAttributes 0x2036.E
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
#   TCL>  ? GetParaAttributes 0x20DD
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
#   TCL>  ? GetParaAttributes 139.1.14
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
#   TCL>  ? GetParaAttributes 0x8B.1.E
#   Output : {8413 0x2036 E UINT16 2 FR1}
#
# ----------HISTORY----------
# WANN   WER       WAS
# 181213 ockeg     proc created
# 240315 serio     add TTId argument
#
#END-------------------------------------------------------------------------------------------------
proc GetParaAttributes { objString {TTId ""}} {

    set TTId [Format_TTId $TTId]

    switch -regexp $objString {
	^[0-9]+$ -
	^0x[0-9A-Fa-f]+$ { ;#Decimal or Hexadecimal Modbus address like 0x20DD
	    set mdbAdr     [format "%d" $objString]                                 ;#Build decimal Modbus address

	    if {$objString == "0x0000"} {

		return {0 0 0 0 0 0}

	    }
	}

	^[0-9A-Z_]+$ -
	^[0-9A-Z]+$ { ;#Object name like FR1

	    if {$objString == "0x0000"} {

		return {0 0 0 0 0 0}

	    } else {

		if {[Param_Index $objString 0 $TTId] != 0 } {
		    set mdbAdr [Param_Index $objString 1]                                  ;#Name -> decimal address

		} else {
		    return {0 0 0 0 0 0}
		}
	    }
	}

	^[0-9]+\.[1]\.[0-9]+$ {   ;# Object given as EIP decimal
	    set objList    [split $objString "."]
	    set class_id   [lindex $objList 0]
	    set attr_id    [lindex $objList 2]
	    set mdbAdr     [expr ($class_id - 0x70) * 200 + $attr_id - 1 + 3000]

	}

	^0x[0-9A-F]+\.[1]\.[0-9A-F]+$ {   ;# Object given as EIP hexa
	    set objList    [split $objString "."]
	    set class_id   [lindex $objList 0]
	    set attr_id    "0x[lindex $objList 2]"
	    set mdbAdr     [expr ($class_id - 0x70) * 200 + $attr_id - 1 + 3000]

	}

	^0x[0-9A-Fa-f]+\.[0-9A-Fa-f]+$ { ;#Object given as CANopen index like 0x2036.E
	    if { [GetDevFeat "BusCAN"] || [GetDevFeat "BusECAT"] } {
		set objList   [split $objString "."]
		set index     [lindex $objList 0]                                    ;#CANopen index
		set subindex  "0x[lindex $objList 1]"                                ;#CANopen subindex
		set mdbAdr     0                                                     ;#not defined for CIA 6000 objects
		set DataType   [CANParam_Type       $objString]                      ;#Datatype
		set DataLength [CANParam_TypeByte   $objString]                      ;#DataLength in bytes
		set DataName   [CANParam_Name			$objString]								;#Name of parameter

		#Return values
		set result {}
		lappend result [format "%d"      $mdbAdr]
		lappend result [format "0x%04X"  $index]
		lappend result [format "%X"      $subindex]
		lappend result $DataType
		lappend result $DataLength
		lappend result $DataName
		return $result

	    } else {
		TlError "$TTId $objString only defined in CAN and ECAT"
		return {0 0 0 0 0 0}
	    }
	}

	default   {
	    TlError "$TTId unknown parameter $objString"
	    return {0 0 0 0 0 0}
	}
    }

    if {[Param_Name $mdbAdr] == 0 } {
	return {0 0 0 0 0 0}
    }

    set index      [expr 0x2000 + int($mdbAdr / 100) - 30]                  		;#Modbus -> CANopen index
    set subindex   [expr ($mdbAdr % 100) + 1]                               		;#Modbus -> CANopen subindex
    set DataType   [Param_Type [Param_Name $mdbAdr]]                        		;#Datatype
    set DataLength [Param_Length [Param_Name $mdbAdr]]                      		;#DataLength in bytes
    set DataName   [Param_Name $mdbAdr]						                      		;#DataLength in bytes

    set result {}
    lappend result [format "%d"      $mdbAdr]
    lappend result [format "0x%04X"  $index]
    lappend result [format "%X"      $subindex]
    lappend result $DataType
    lappend result $DataLength
    lappend result $DataName
    return $result
}

#DOC-------------------------------------------------------------------
#
# Take parameter type from limitcheckfile
#
# 130605   lefef    proc created
# 181213   ockeg    LengthTable created
#
#END-------------------------------------------------------------------
proc ReadParaTypeFile_ATV { FileName } {
    global theLimitCheckFile glbProductType theAltivarLimitCheckFile
    global theATVParaTypeTable theATVParaLengthTable

    if { [GetDevFeat "Altivar"] } {
	TlPrint " $theAltivarLimitCheckFile "
	set theLimitCheckFile  $theAltivarLimitCheckFile
    }

    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"
	set file [open $theLimitCheckFile]

	while { ! [eof $file] } {

	    set line [gets $file]
	    if { ([regexp "^#" $line]) | [regexp "^$" $line] } { continue }

	    set wordList [split $line "|"]
	    set shortname  [lindex $wordList 1]
	    set datatype   [lindex $wordList 3]

	    set theATVParaTypeTable($shortname) $datatype

	    switch -exact $datatype {
		"UINT08"  { set theATVParaLengthTable($shortname) 2 }
		"INT08"   { set theATVParaLengthTable($shortname) 2 }
		"UINT16"  { set theATVParaLengthTable($shortname) 2 }
		"INT16"   { set theATVParaLengthTable($shortname) 2 }
		"UINT32"  { set theATVParaLengthTable($shortname) 4 }
		"INT32"   { set theATVParaLengthTable($shortname) 4 }
		default   { set theATVParaLengthTable($shortname) 2 }
	    }

	}

	#TlPrint "**** Close file: $FileName"
	close $file
	set glbProductType "ALTIVAR"

    } else {
	TlError "File $FileName not available!"
	exit
    }
}

proc GetObjNr { ObjStr Nr ObjectNr} {
    #DOC-------------------------------------------------------------------
   # PROCEDURE   : Hilfsroutine für ReadCANObjectListFile
    # TYPE        : Library
    # AUTHOR      : Gunter Pfeiffer
    # DESCRIPTION :
    #
    #END-------------------------------------------------------------------
    upvar $Nr CANNr
    upvar $ObjectNr ObjectNummer

    set ObjNr [string range [string trim $ObjStr] 2 9]
    # 6000 er CAN Index
    set CANNr [string range $ObjNr 0 3]
    # ModBus Parameter
    set Obj [string range $ObjNr 4 7]

    set index      [expr 0x[string range $Obj 0 1] & 0x3F]
    set subindex   [expr 0x[string range $Obj 2 3]]

    set ObjectNummer "$index.$subindex"

}

##DOC-------------------------------------------------------------------
## PROCEDURE   : read CAN objectlist from a file in hashtable
## TYPE        :  Library
## AUTHOR      : Gunter Pfeiffer
## DESCRIPTION :
##    ObjectList = Path + objdefs.h
##    Geht so nicht und macht momentan auch keinen Sinn
##    Entwicklung von dieser Procedur deshalb vorerst eingestellt
##END-------------------------------------------------------------------
#proc ReadCANObjectListFile { FileName } {
#   global theCANObjHashtable
#
#   if { [file exists $FileName] == 1 } {
#      TlPrint "**** Oeffne Datei: $FileName"
#      set file [open $FileName r]
#      set Nr 0
#      set ObjectNr 0
#      set CANNr1 0
#      set CANNr2 0
#      set SubIndex 0
#
#      while { [gets $file line] >= 0 } {
#         # Kommentarzeilen ignorieren
#         if { ([string match "/*" [string range $line 0 1]]) } {
#            TlPrint "Kommentarzeile: $line"
#            continue
#         }
#         if { [string match "0x*" [string trim $line]] == 1 } {
#            GetObjNr $line Nr ObjectNr
#            set CANNr1 $Nr
#            if { $CANNr1 == $CANNr2 } {
#               incr SubIndex
#            } else {
#               set SubIndex 0
#            }
#            lappend theCANObjHashtable($ObjectNr)  0x$Nr $SubIndex
#            TlPrint "$ObjectNr - $theCANObjHashtable($ObjectNr)"
#
#
#            while { [gets $file line] >= 0 } {
#               if { [string match "0x*" [string trim $line]] == 1 } {
#                     GetObjNr $line Nr ObjectNr
#                     set CANNr2 $Nr
#                     if { $CANNr1 == $CANNr2 } {
#                        incr SubIndex
#                     } else {
#                        set SubIndex 0
#                     }
#                     lappend theCANObjHashtable($ObjectNr)  0x$Nr $SubIndex
#                     TlPrint "$ObjectNr - $theCANObjHashtable($ObjectNr)"
#               }
#            }
#
#
#         }
#      }
#
#
#
#      TlPrint "**** Schliesse Datei: $FileName"
#      close $file
#   } else {
#      TlError "Datei $FileName nicht vorhanden!"
#      exit
#   }
#}

#DOC-------------------------------------------------------------------
# PROCEDURE   : read objectlist from a file in hashtable
# TYPE        :  Library
# AUTHOR      : HogeS
# DESCRIPTION :
#    ObjectList = Path + objdefs.h
#
# 280708 rothf theObjDataTypeSigned created
#
#END-------------------------------------------------------------------
proc ReadLXMLimitCheckFile { FileName } {
    global theLXMObjDataTyptable
    global theObjDataTypeSigned         ;#defines if signed or unsigned datatype

    if { [file exists $FileName] == 1 } {
	set file [open $FileName r]
	TlPrint "**** open file: $FileName"
	while { [gets $file line] >= 0 } {

	    # Kommentarzeilen ignorieren
	    if { ([regexp "^#" $line]) | [regexp "^$" $line] } {
		#            TlPrint "Kommentarzeile: $line"
		continue
	    }

	    # Zeile in Liste splitten
	    set wordList [split $line "|"]

	    set index         [lindex $wordList 0]
	    set subindex      [lindex $wordList 1]
	    set Datentyp      [lindex $wordList 6]
	    #         set writeable     [lindex $wordList 7]
	    #         set persistent    [lindex $wordList 8]
	    #         set MinWert       [lindex $wordList 9]
	    #         set MaxWert       [lindex $wordList 10]
	    #         set Defaultwert   [lindex $wordList 11]
	    #         set Grenzwerttest [lindex $wordList 12]

	    set ObjectNr "$index.$subindex"

	    switch $Datentyp {
		"INT8" {
		    set theObjDataTypeSigned($ObjectNr) 1
		    set theLXMObjDataTyptable($ObjectNr) 1 }
		"UINT8" {
		    set theObjDataTypeSigned($ObjectNr) 0
		    set theLXMObjDataTyptable($ObjectNr) 1 }

		"INT16" {
		    set theObjDataTypeSigned($ObjectNr) 1
		    set theLXMObjDataTyptable($ObjectNr) 2 }
		"UINT16" {
		    set theObjDataTypeSigned($ObjectNr) 0
		    set theLXMObjDataTyptable($ObjectNr) 2 }

		"INT32" {
		    set theObjDataTypeSigned($ObjectNr) 1
		    set theLXMObjDataTyptable($ObjectNr) 4 }
		"UINT32" {
		    set theObjDataTypeSigned($ObjectNr) 0
		    set theLXMObjDataTyptable($ObjectNr) 4 }

		default  { TlError "Unzulaessiger Datentyp : $Datentyp" }
	    }

	    #TlPrint "Gelesenes Objekt: $ObjectNr  Datentyp: $Datentyp  Laenge: $theLXMObjDataTyptable($ObjectNr)"

	}
	TlPrint "**** close file: $FileName"
	close $file
    } else {
	TlError "File <$FileName> not available !"
    }

}

#---------------------------------------------------------------
proc PrintCANObjectListFile { } {
    global theCANObjectList
    global theCANObjectParameterName
    global theCANObjectType
    global theCANObjectDataType
    global theCANObjectAccessType
    global theCANObjectPDOMapping
    global theCANObjectLowLimit
    global theCANObjectHighLimit
    global theCANObjectDefaultValue

    #   TlPrint ""
    #   TlPrint "print theCANObjectList"
    #   foreach item [lsort [array names theCANObjectList]] {
    #      if { [string first "0x6" $item] < 0 } { continue }
    #      TlPrint [format "%s %-30s" $item $theCANObjectList($item)]
    #   }

    TlPrint ""
    TlPrint "theCANObjectParameterName"
    foreach item [lsort [array names theCANObjectParameterName]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectParameterName($item)]
    }

    #   TlPrint ""
    #   TlPrint "theCANObjectType"
    #   foreach item [lsort [array names theCANObjectType]] {
    #      if { [string first "0x6" $item] < 0 } { continue }
    #      TlPrint [format "%s %-30s" $item $theCANObjectType($item)]
    #   }

    TlPrint ""
    TlPrint "theCANObjectDataType"
    foreach item [lsort [array names theCANObjectDataType]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %s" $item [CANParam_Type $item] ]
    }

    TlPrint ""
    TlPrint "theCANObjectAccessType"
    foreach item [lsort [array names theCANObjectAccessType]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectAccessType($item)]
    }

    TlPrint ""
    TlPrint "theCANObjectPDOMapping"
    foreach item [lsort [array names theCANObjectPDOMapping]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectPDOMapping($item)]
    }

    TlPrint ""
    TlPrint "theCANObjectLowLimit"
    foreach item [lsort [array names theCANObjectLowLimit]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectLowLimit($item)]
    }

    TlPrint ""
    TlPrint "theCANObjectHighLimit"
    foreach item [lsort [array names theCANObjectHighLimit]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectHighLimit($item)]
    }

    TlPrint ""
    TlPrint "theCANObjectDefaultValue"
    foreach item [lsort [array names theCANObjectDefaultValue]] {
	if { [string first "0x6" $item] < 0 } { continue }
	TlPrint [format "%s %-30s" $item $theCANObjectDefaultValue($item)]
    }

}

#DOC-------------------------------------------------------------------
#
# Reads CAN objects from EDS file and gets datas into global arrays.
#
# 280510 rothf proc created, we need data length for 6000er objects
# 281113 weiss proc extended with use of datas from EDS-file
#
#END-------------------------------------------------------------------
proc ReadCANObjectListFile { FileName } {
    global theCANObjectList
    global theCANObjectParameterName
    global theCANObjectType
    global theCANObjectDataType
    global theCANObjectAccessType
    global theCANObjectPDOMapping
    global theCANObjectLowLimit
    global theCANObjectHighLimit
    global theCANObjectDefaultValue

    TlPrint "\n--------------------------------------------------------"
    TlPrint "Read CANopen data from EDS-file"

    #CLEAR list before (re)build a new list
    if {[info exists theCANObjectList] } {
	unset theCANObjectList
    }
    #CLEAR all arrays before (re)build new arrays
    lappend KeyList ParameterName Type DataType AccessType PDOMapping LowLimit HighLimit DefaultValue
    foreach item $KeyList {
	if {[info exists "theCANObject$item"] } {
	    unset "theCANObject$item"
	}
    }

    #OPEN EDS file
    if { [file exists $FileName] == 1 } {
	TlPrint "**** Open file: $FileName"

	set CANfilehandle [ini::open $FileName "r"]

	#Count all sections in file
	set lstSections [ini::sections $CANfilehandle]

	#Read each section and puts required datas in arrays
	foreach item $lstSections {
	    if {([CheckBreak] == 1)} {
		break
	    }

	    if {[ini::exists $CANfilehandle $item ObjectType]} {
		#ObjectType = 7 : existing objects
		if {[ini::value $CANfilehandle $item ObjectType] == 7 } {
		    #Convert section names to CAN format "0xIndex.SubIndex"
		    if {[regexp {^[A-Fa-f0-9]+$} $item] } {
			set ObjectIdxSix "0x[string toupper $item].0"
		    } elseif {[regexp {[sub]} $item] } {
			set ObjectIdxSix "0x[string toupper [string map {sub .} $item]]"
		    }

		    #Add object in a list
		    lappend theCANObjectList $ObjectIdxSix
		    #Set each attribute of object in the corresponding list

		    #Description of parameter
		    if {[ini::exists $CANfilehandle $item ParameterName]} {
			set theCANObjectParameterName($ObjectIdxSix) [join [ini::value $CANfilehandle $item ParameterName] "_"]
		    }

		    #Type of object (0x07=var, 0x08=array, 0x09=record)
		    if {[ini::exists $CANfilehandle $item ObjectType]} {
			set theCANObjectType($ObjectIdxSix) [ini::value $CANfilehandle $item ObjectType]
		    }

		    #Datatype of object (UINT16,INT16,etc...)
		    if {[ini::exists $CANfilehandle $item DataType]} {
			set theCANObjectDataType($ObjectIdxSix) [ini::value $CANfilehandle $item DataType]
		    }

		    #Read/Write access
		    if {[ini::exists $CANfilehandle $item AccessType]} {
			set theCANObjectAccessType($ObjectIdxSix) [ini::value $CANfilehandle $item AccessType]
		    }

		    #PDOMapping possibility
		    if {[ini::exists $CANfilehandle $item PDOMapping]} {
			set theCANObjectPDOMapping($ObjectIdxSix) [ini::value $CANfilehandle $item PDOMapping]
		    }

		    #Low limit
		    if {[ini::exists $CANfilehandle $item LowLimit]} {
			set theCANObjectLowLimit($ObjectIdxSix) [ini::value $CANfilehandle $item LowLimit]
		    }

		    #High limit
		    if {[ini::exists $CANfilehandle $item HighLimit]} {
			set theCANObjectHighLimit($ObjectIdxSix) [ini::value $CANfilehandle $item HighLimit]
		    }

		    #Default value
		    if {[ini::exists $CANfilehandle $item DefaultValue]} {
			set theCANObjectDefaultValue($ObjectIdxSix) [join [ini::value $CANfilehandle $item DefaultValue] ""]
		    }
		} else {
		    #ObjectType != 7 : only description of object group
		    if {[regexp {[A-Fa-f0-9]+} $item] } {
			set ObjectIdxSix "0x[string toupper $item]"
		    }
		    #Add object in a list
		    lappend theCANObjectList $ObjectIdxSix
		    #Add object description in a list
		    #Description of a parameter
		    if {[ini::exists $CANfilehandle $item ParameterName]} {
			set theCANObjectParameterName($ObjectIdxSix) [join [ini::value $CANfilehandle $item ParameterName] "_"]
		    }

		    #Type of object (0x07=var, 0x08=array, 0x09=record)
		    if {[ini::exists $CANfilehandle $item ObjectType]} {
			set theCANObjectType($ObjectIdxSix) [ini::value $CANfilehandle $item ObjectType]
		    }
		}
	    } else { continue }																					;#Ignore sections which are not a CAN object
	}

	#End of analyse
	TlPrint "**** Close file: $FileName"
	ini::close $CANfilehandle
    } else {
	TlError "File $FileName not available!"
    }
    TlPrint "-end----------------------------------------------------"
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# 230 V Relais einschalten (On='H') oder ausschalten (On='L')
#
# ----------HISTORY----------
# WANN   WER       WAS
# 190404 ockenfuss proc erstellt
# 060505 ockenfuss warten bis Unterpannungsgrenzwert erreicht
# 081208 rothf     timeout changed from 20 to 30 s
#
#END----------------------------------------------------------------
proc PowerOnOff {Dev_Nr On {wait 1}} {
    global DevAdr

    set TimeOut  30  ;# in s

    switch -exact $On {
	"h" - "H" {
	    TlPrint "Switch on power supply of Device $Dev_Nr" }
	"l" - "L" {
	    TlPrint "Switch off power supply of Device $Dev_Nr" }
	default {
	    TlError "Switch on-off: invalid Parameter On=$On"
	    return }
    }

    switch $Dev_Nr {
	"1" { wc_SetDigital 1 0x01 $On }
	"2" { wc_SetDigital 1 0x0E $On }
	"3" { wc_SetDigital 1 0x20 $On }
	"4" { wc_SetDigital 1 0x40 $On }
	default  {
	    TlError "Invalid Device No $Dev_Nr"
	    return
	}
    }

    set ukzmin [doReadObject PA.UKZMIN]
    if {$wait} {
	if { $On == "H" } {
	    doWaitForObjectOp STD.UZ >= $ukzmin 10
	} else {
	    # bei off laenger warten bis ZK-Spannung weg ist
	    # ZK-spannung muss auf den Min Grenzwert ueberprueft werden
	    if {[doWaitForObjectOp STD.UZ < $ukzmin $TimeOut] == 0} {
		set ukz [doReadObject STD.UZ]
		TlError "Timeout ($TimeOut s) Undervoltage DC-Bus"
		TlPrint "DC-Bus not < $ukzmin, voltage is $ukz"
	    }
	}
    }

} ;#PowerOnOff

#----------not used any more -> use FastOffOn instead ------------------
#proc DeviceOffOn {DevNr {NoInfo 1} {State ">=2"} {timeout 18}} {
#   #DOC----------------------------------------------------------------
#   #DESCRIPTION
#   #
#   # Testgeräte einschalten
#   #
#   # ----------HISTORY----------
#   # WANN   WER    WAS
#   # 311006 pfeig  proc erstellt
#   # 091106 pfeig  erweiter auf CPD
#   # 250106 grana  State fuer cpdSwitchOn, timeout eingefuegt
#   # 260107 grana  Aenderung von Default-State 0 auf 4 fuer CPD + gleichzeitiges abfragen
#   #               der Wago-Eingaenge bei State 4.
#   #
#   #END----------------------------------------------------------------
#   if { [GetDevFeat "Nera"] } {
#      Nera_Off $DevNr $NoInfo
#      Nera_On  $DevNr $State $timeout
#
#   } elseif { [GetDevFeat "Beidou"] } {
#         Beidou_Off $DevNr $NoInfo
#         Beidou_On  $DevNr $State $timeout
#
#   } else {
#      TlError "Unexpected DevFeat"
#      return 0
#   }
#
#   return 1
#
#} ;# DeviceOffOn

#----------------------------------------------------------------------------
# Doxygen Tag:
##Function description : power cycle the DUT
# WHEN  | WHO  | WHAT
# -----| -----| -----
# xxxx/xx/xx | ??? | proc created
# 2023/12/13 | ASY | proc updated for generic devices
proc DeviceFastOffOn {DevNr {NoInfo 1} {State ">=2"} {timeout 30}} {
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
   # Testgeräte Aus- Einschalten
    #
    # ----------HISTORY----------
    # WANN    WER    WAS
    #
    #END----------------------------------------------------------------
    if {[GetDevFeat "Altivar"]} {
	Altivar_Off $DevNr $NoInfo
	Altivar_On  $DevNr $State $timeout
    } elseif {[GetDevFeat "Nera"]} {
	Nera_Off $DevNr $NoInfo
	Nera_On  $DevNr $State $timeout
    } elseif {[GetDevFeat "Beidou"]} {
	Beidou_Off $DevNr $NoInfo
	Beidou_On  $DevNr $State $timeout
    } elseif {[GetDevFeat "Fortis"]} {
	Fortis_Off $DevNr $NoInfo
	Fortis_On  $DevNr $State $timeout
    } elseif {[GetDevFeat "Opal"]} {
	Opal_Off $DevNr $NoInfo
	Opal_On  $DevNr $State $timeout
    } elseif {[GetDevFeat "MVK"]} {
	MVK_Off $DevNr $NoInfo
	#      MVK_On  $DevNr $State $timeout
	#      set i 0
	#      while {([ModTlRead HMIS == ""]) && ( $i <=3) } {
	#         MVK_On  $DevNr $State $timeout
	#         incr i
	#      }
	#      if { $i >= 3 } { TlError "MVK_On instruction KO " }

	for {set i 0} {$i<=3} {incr i} {
	    MVK_On  $DevNr $State $timeout
	    doWaitMs 5000
	    set stopMVK_On [ModTlRead HMIS 1]
	    if {$stopMVK_On != "" } {
		TlPrint "MVK correctly ON"
		break}
	    if {$i == 3} {
		TlError "MVK not correctly ON after 3 try"
		break}
	}
    } elseif { [GetSysFeat "Gen2Tower"]} {
	genericDevice_Off $DevNr 
	genericDevice_On $DevNr $State $timeout 
    } else {
	TlError "Unexpected DevFeat"
	return 0
    }

    return 1

} ;# DeviceFastOffOn

# ----------HISTORY----------
# WHEN   WHO   WHAT
# 090704 pfeig file created
# 040215 serio/grola Workaround for Com option board towers
# 131223 ASY update for generic devices 
# 130324 ASY add devices 12 & 13 for NERA and 11 & 14 for ATS
# 050424 YGH removed devices 12 & 13 for NERA and added them to FORTIS (Issue #1883)
# DESCRIPTION
#
# switch on test device
proc DeviceOn {DevNr {checkData 1} {State ">=2"} {timeout 30} {TTId ""}} {

    global TestsBlocked
    global ActDev DevAdr

    ;

    if {  ([GetDevFeat "Opal"] || [GetDevFeat "Altivar"])} {

	if {[GetDevFeat "Opal"]} {
	    switch $DevNr {
            1 - 2 - 3 - 4 - 21 - 23 - 5 {
		    Opal_On $DevNr $State $timeout $TTId
		}
		default {
		    TlError "Unexpected Opal DevNr $DevNr"
		}
	    }

	} elseif {[GetDevFeat "Altivar"]} {

	    switch $DevNr {
		1 - 4 - 5 {
		    Altivar_On $DevNr $State $timeout $TTId
		}
		default {
		    TlError "Unexpected Altivar DevNr $DevNr"
		}
	    }

	}
    }  elseif {[GetDevFeat "Nera"]} {
	switch $DevNr {
         1 - 2 - 3 {
		set ComOK [Nera_On $DevNr $State $timeout $TTId]
		if { ( $checkData == 1 ) && ( $TestsBlocked != 1 ) && ( $ComOK == 1 ) } {
		    if { [CheckMotorData] == 0 } {
			#todo this check is for the FCS problematic. Should be removed when bug is fixed
			doSetDefaults 0  ;# one more try, no reboot
			# set address to 0xF8 for second test. just in case...
			set DevAdrOld $DevAdr($ActDev,MOD)
			set DevAdr($ActDev,MOD) 0xF8
			if { [CheckMotorData] == 0 } {
			    # hier bleiben wir stehen, hat so keinen Sinn weiter zu machen
			    TlPrint "\n\n========================================================"
			    TlPrint "Motor data are not as expected at power on! -> Test Stop"
			    Nera_Off $DevNr
			    if {[bp "Debugger"]} {
				return 0
			    }
			}
			set DevAdr($ActDev,MOD) $DevAdrOld
		    }
		}
	    }

	    default {
		TlError "Unexpected Nera DevNr $DevNr"
	    }
	}
    } elseif {[GetDevFeat "Beidou"]} {
	switch $DevNr {
	    4 {
		Beidou_On $DevNr $State $timeout $TTId
	    }
	    default {
		TlError "Unexpected Beidou DevNr $DevNr"
	    }
	}
    } elseif {[GetDevFeat "Fortis"]} {
	switch $DevNr {
	    1 -
	    2 -
	    3 -
	    5 -
	    8 -
	    9 -
	    12 -
	    13 -
	    15 {
		Fortis_On $DevNr $State $timeout $TTId
	    }
	    default {
		TlError "Unexpected Fortis DevNr $DevNr"
	    }
	}
    } elseif {[GetDevFeat "MVK"]} {
	switch $DevNr {
	    1 -
	    2 -
	    3 -
	    6 -
	    5 {
		MVK_On $DevNr $State $timeout $TTId
	    }
	    default {
		TlError "Unexpected MVK DevNr $DevNr"
	    }
	}
	} elseif { [GetDevFeat "ATS48P"]} {
		switch $DevNr {
		11 - 14 {
			ATS_On $DevNr $State $timeout $TTId
		}
	    default {
		TlError "Unexpected ATS DevNr $DevNr"
	    }
	}
    } elseif { [GetSysFeat "Gen2Tower"]} {
	genericDevice_On $DevNr $State $timeout $TTId
    } else {
	TlError "Unexpected DevFeat in DeviceOn"
	return 0
    }

    if {[GetSysFeat "PACY_COM_PROFINET2"]} {
	    doWaitMs 30000
    }
    ##If the ServoDrive is switched on allow access to Tcl_Debugger to Read ServoDrive Paramaters
    global Debugger_StopParaRead
    set Debugger_StopParaRead 0
    ##If the ServoDrive is switched on allow access to Tcl_Debugger to Read ServoDrive Paramaters


    if {[GetDevFeat "FW_CIPSFTY"]} {
	#Temporization Safety campaign : to let PLC communication running after Poff/Pon : wait "STO raise by PLC"
	doWaitForNotObject HMIS 30 30
    }



    return 1

}

# ----------HISTORY----------
# WHEN   WHO   WHAT
# 090704 pfeig file created
# 040215 serio/grola Workaround for Com option board towers
# 131223 ASY update for generic devices 
# 130324 ASY add devices 12 & 13 for NERA and 11 & 14 for ATS
# 050424 YGH removed devices 12 & 13 for NERA and added them to FORTIS (Issue #1883)
# DESCRIPTION
#
# switch off test device
proc DeviceOff {DevNr {NoInfo 0} } {

    TlPrint "Switch off device $DevNr"

    ##If the ServoDrive is switched off deny access to Tcl_Debugger to Read ServoDrive Paramaters
    global Debugger_StopParaRead
    set Debugger_StopParaRead 1
    ##If the ServoDrive is switched off deny access to Tcl_Debugger to Read ServoDrive Paramaters

    if { ([GetDevFeat "Opal"]||[GetDevFeat "Altivar"])} {
	if {[GetDevFeat "Opal"]} {
	    switch $DevNr {
            1 - 2 - 3 - 4 - 21 - 23 {
		    Opal_Off $DevNr $NoInfo
		}
		default {
		    TlError "Unexpected Opal DevNr $DevNr"
		}
	    }

	} elseif {[GetDevFeat "Altivar"]} {

	    switch $DevNr {
		1 - 4 - 5 {
		    Altivar_Off $DevNr $NoInfo
		}
		default {
		    TlError "Unexpected Opal DevNr $DevNr"
		}
	    }

	}

    } elseif {[GetDevFeat "Nera"]} {
	switch $DevNr {
         1 - 2 - 3 {
		Nera_Off $DevNr $NoInfo
	    }
	    default {
		TlError "Unexpected Nera DevNr"
	    }
	}
    } elseif {[GetDevFeat "Beidou"]} {
	switch $DevNr {
	    4 {
		Beidou_Off $DevNr $NoInfo
	    }
	    default {
		TlError "Unexpected Beidou DevNr"
	    }
	}
    } elseif {[GetDevFeat "Fortis"]} {
	switch $DevNr {
	    1 -
	    2 -
	    3 -
	    5 -
	    8 -
	    9 -
	    12 -
	    13 -
	    15 {
		Fortis_Off $DevNr $NoInfo
	    }
	    default {
		TlError "Unexpected Fortis DevNr"
	    }
	}
    } elseif {[GetDevFeat "MVK"]} {
	switch $DevNr {
	    1 -
	    2 -
	    3 -
	    6 -
	    5 {
		MVK_Off $DevNr $NoInfo
	    }
	    default {

		TlError "Unexpected MVK DevNr"
	    }
	}
    } elseif {[GetDevFeat "ATS48P"]} {
	switch $DevNr {
	    11 -
	    14 
	     {
		ATS_Off $DevNr $NoInfo
	    }
	    default {

		TlError "Unexpected ATS DevNr"
	    }
	}
    } elseif { [GetSysFeat "Gen2Tower"]} {
	genericDevice_Off $DevNr 
    } else {
	TlError "Unexpected DevFeat"
	return 0
    }

}

#-----------------------------------------------------------------------
# Auf Zustand x des Lastgerätes warten
proc LoadWaitForState { sollZustand timeout {maske 0x000F} {ErrPrint 1}} {
    global ActDev DevAdr

    TlPrint " Wait for state $sollZustand on load device"

    set startZeit [clock seconds]
    set startChange [clock clicks -milliseconds]
    set fehler     0
    set istZustand 0
    while {1} {
	set istZustand [LoadRead STD.STATUSWORD 1]  ;# No Error Print
	if { $istZustand != "" } then {
	    set istZustand [expr $istZustand & $maske]
	    if {[regexp {[!<>=]} $sollZustand]} {
		if { [expr $istZustand $sollZustand] } {
		    TlPrint " state is $sollZustand after [expr [clock clicks -milliseconds] - $startChange]ms"
		    break
		}
	    } else {
		if { $istZustand == $sollZustand } {
		    TlPrint " state is $sollZustand after [expr [clock clicks -milliseconds] - $startChange]ms"
		    break
		}
	    }
	}
	if { $timeout != 0 && [expr [clock seconds] - $startZeit > $timeout] } {
	    set fehler [LoadRead STD.STOPFAULT]
	    if { ($fehler != "") && ($istZustand != "") } then {
		TlError "state loaddevice will not be $sollZustand but stays at $istZustand, STOPFAULT=0x%04X->%s" $fehler [GetErrorText $fehler]
		if {$ErrPrint == 1} { ShowLoadStatus }
	    } else {
		TlError "No communication from loaddevice"
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $istZustand
} ;# LoadWaitForState

#--------------------------------------------------------------------------
proc LoadWaitForStand {{timeout 5} {ErrPrint 1}} {
    global ActDev DevAdr

    TlPrint " Warte auf Stillstand der Last (<9Umin)"

    set startZeit [clock seconds]
    set fehler     0
    set istZustand 0
    while {1} {
	set istZustand [LoadRead STD.ACTIONWORD 1]  ;# No Error Print
	if { $istZustand != "" } then {
	    set istZustand [expr $istZustand & 0x0040]
	    if { $istZustand == 0x0040 } { break }
	} else {
	    TlError "no Reply from Load"
	    set istZustand 0
	    break
	}
	if { $timeout != 0 && [expr [clock seconds] - $startZeit > $timeout] } {
	    set fehler [ModTlRead STD.STOPFAULT]
	    if { $fehler != "" } then {
		TlError "Load still not in standstill (<9Umin), STOPFAULT=0x%04X->%s" $fehler [GetErrorText $fehler]
		if {$ErrPrint == 1} { ShowLoadStatus }
	    } else {
		TlError "no Reply from Load"
	    }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $istZustand
} ;# LoadWaitForStand

#--------------------------------------------------------------------------
proc LoadWaitForObject {objekt sollWert timeout {bitmaske 0xffffffff} {ErrPrint 1}} {
    global ActDev DevAdr

    set startZeit [clock clicks -milliseconds]

    set fehler     0
    set istWert    0
    while {1} {
	set istWert [LoadRead $objekt 1]
	if { $istWert == "" } then {
	    TlError "keine Rueckmeldung vom Lastgeraet"
	    set istWert 0
	    break
	}
	if [expr ($istWert & $bitmaske) == ($sollWert & $bitmaske)] {
	    TlPrint "Objekt $objekt ok: Sollwert=Istwert=0x%08X , (%d) , Wartezeit (%dms) " $sollWert $sollWert [expr [clock clicks -milliseconds] - $startZeit ]
	    break
	}
	if { $timeout != 0 && [expr (([clock clicks -milliseconds] - $startZeit) / 1000)  > $timeout] } {
	    TlError "LoadWaitForObject $objekt: Sollwert=0x%08X , (%d) Istwert=0x%08X , (%d)" $sollWert $sollWert $istWert  $istWert
	    if {$ErrPrint == 1} { ShowLoadStatus }
	    break
	}
	if {[CheckBreak]} {break}
    }

    return $istWert
} ;# LoadWaitForObject

#----------------------------------------------------------------------------------------------------
# warte bis Object < oder > sollwert wird
# objekt:   symbolischer Name, z.B. MONC.PACTUSR
# operator: vergleich zb. ">" oder "<"
# sollWert: gewuenschter Wert der zum Ende fuehrt
# timeout:  sekunden
#
proc LoadWaitForObjectOp { object operator sollwert timeout {TTId ""} {ErrPrint 1}} {
    set TTId [Format_TTId $TTId]

    set startZeit [clock clicks -milliseconds]
    while { 1 } {
	if {[CheckBreak]} {break}
	set istwert [LoadRead $object 0]
	set timeDiff [expr [clock clicks -milliseconds] - $startZeit]
	if { [expr $istwert $operator $sollwert] } {
	    TlPrint "LoadWaitForObjectOp: $object is $operator $sollwert after $timeDiff ms"
	    return 1
	}
	if {$timeDiff >= [expr $timeout * 1000] } {
	    TlError "$TTId LoadWaitForObjectOp: Timeout, $object is not $operator $sollwert in $timeout s"
	    if {$ErrPrint == 1} { ShowLoadStatus }
	    return 0
	}
    }

}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät enablen und auf Blockierung schalten
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 281106 pfeig proc erstellt
# 121206 ockeg erweitert auf CPD Testturm
# 140708 rothf adapted to Servo3
#
#END----------------------------------------------------------------
proc LoadBlock { } {
    global ActDev DevAdr
    global TimeBlock

    TlPrint ""
    TlPrint "Load device $ActDev: Block on, device Enable"
    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    set TimeBlock [clock clicks -milliseconds]
    TlPrint "Load device PACTUSR: [LoadRead MONC.PACTUSR]"

} ;# LoadBlock

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät disablen
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# Time output by indication from state for blocking Motor.
#
# ----------HISTORY----------
# WANN   WER   WAS
# 281106 pfeig proc erstellt
# 121206 ockeg erweitert auf CPD Testturm
#
#END----------------------------------------------------------------
proc LoadUnBlock { {state ""} } {
    global HandMade
    global ActDev DevAdr
    global TimeBlock

    TlPrint ""
    TlPrint "Load device $ActDev: Block off, device disable"

    LoadWrite STD.CTRLWORD 0x01   ;# Disable

    if { $state != ""} {
	LoadWaitForState $state 15
	set TimeBlockStop  [clock clicks -milliseconds]
	set Time$ActDev    [expr abs( $TimeBlockStop - $TimeBlock)]
	TlPrint "Duration of blocking: [subst $[subst Time$ActDev]]ms"

    }

}  ;# LoadUnBlock

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgeräte einschalten
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 241106 pfeig proc erstellt
# 121206 ockeg erweitert auf CPD Testturm
# 080208 rothf state als optionaler Übergabeparameter
# 100708 rothf adapted to Servo3
# 300115 serio add case for Load initialization
#
#END----------------------------------------------------------------
proc LoadOn { {State 4} {ErrPrint 1} } {
    global ActDev
    global TimeBlock

    set TimeBlock 0
    set LoadDevNr [expr $ActDev + 10]

    TlPrint ""
    TlPrint "Switch on load device $LoadDevNr"

    wc_Servo3OnOff $LoadDevNr "H"          ;#Set device on
    doWaitMs 1000                          ;#to compensate for switch delays
    if {![GetDevFeat "FortisLoad"]} {
        switch -regexp $State {
            {[<>=1-9]} {
                #Waiting for state
                LoadWaitForState $State 10
            }
            "None" {
                #ignore state in this case : used for modbus address initialization
            }
            0 -
            default {
                if {$ErrPrint == 1} { ShowLoadStatus }
                TlError "Parameter State( $State ) nicht definiert"
            }
        }

	#Added in order to get exclusive control of the load machine. Otherwise impossible to start it
	if {[LoadRead MAND.ACCESSEXCL] != 1} {
	    LoadWrite MAND.ACCESSEXCL 1
	}
	    
        # deactivate commutation monitoring
        LoadWrite DEVICE.SUPCOMM 0

        return $LoadDevNr
    } else {
	    doWaitForLoadObject HMIS .NST 5
    }

} ;# LoadOn

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgeräte ausschalten
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 241106 pfeig proc erstellt
# 121206 ockeg erweitert auf CPD Testturm
# 010408 ockeg UserParaReset und CtrlReset auch beim Lastgerät
# 100708 rothf adapted to Servo3
#
#END----------------------------------------------------------------
proc LoadOff { {waittime 2000} } {
    global ActDev DevAdr

    set LoadDevNr $DevAdr($ActDev,Load)    ;# this is not a address, its only a nr.	
    TlPrint ""
    TlPrint "Switch off load device $LoadDevNr"
    wc_Servo3OnOff $LoadDevNr "L"
    if {[GetDevFeat "FortisLoad"] } {
        set waittime [expr $waittime * 5]
    }
    doWaitMs  $waittime

    return
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät in CurCtrl schalten mit einem parametrierbaren Sollstrom
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# SollStrom != 0 :  Endstufe enable und Stromregelung einschalten
# SollStrom == 0 :  Stromregelung ausschalten und Endstufe disable
#
# ----------HISTORY----------
# WANN   WER   WAS
# 200607 ockeg erstellt
# 090908 grana adapted to Servo3
# 100812 rothf adapted to OPAL project (load device is LXM32)
#
#END----------------------------------------------------------------
proc LoadTorque { Target_Torque_Percent {speedLimitation 3000} } {
    global HandMade
    global ActDev DevAdr
    if {![GetDevFeat "FortisLoad"]} {
        LoadWrite CTRLG.IMAX 1000

        set ContTorque [LoadRead MOTACS.TQU0]

        #limit speed to ensure no damage of Asynchronous motor due to overspeed if load test is failed
        LoadWrite CTRLG.NMAX $speedLimitation

        LoadWrite CTRLG.IMAX 1000

        if { $Target_Torque_Percent != 0 } {
            TlPrint ""
            TlPrint "Load device $ActDev: Torque control with %.1f %%  (%.2f Nm) of Cont. stall torque" [expr $Target_Torque_Percent/10.0] [expr $ContTorque/100.0]
            LoadWrite TRQPRF.TORQTARGET $Target_Torque_Percent
            LoadWrite STD.CTRLWORD      0x02         ;# Enable
            LoadWaitForState 6 5
            LoadWrite TRQPRF.START      1
        } else {
            TlPrint "Load device $ActDev: Torque control off"
            LoadWrite TRQPRF.TORQTARGET 0
            #      ModTlWrite TRQPRF.START      0
            #      doWaitForAckEnd 5
            LoadWrite STD.CTRLWORD      0x08         ;# FaultReset
            LoadWrite STD.CTRLWORD      0x01         ;# Disable
            LoadWaitForState 4 5
        }
    } else {
        fortisLoad_loadVelocity 150 $Target_Torque_Percent

    }

};# LoadCurrCtrl

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät Drehzahlreglerbetrieb mit Drehzahl N_Ref
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 121206 ockeg proc erstellt
# 100708 rothf adapted to Servo3
# 070912 lefef Rename from LoadSpeed to LoadVelocity and adapt to new parameter names
#
#END----------------------------------------------------------------
proc LoadVelocity { N_Ref {IMAX 300} { Ramp 6000 } {ErrPrint 1}} {
    global HandMade
    global ActDev DevAdr

    TlPrint ""
    TlPrint "Load device $ActDev: Speed profile with $N_Ref rpm"
    if { ![GetDevFeat "FortisLoad"] } {
        LoadWrite CTRLG.IMAX $IMAX

        if { $N_Ref != "NO" } {

            LoadWrite VELPRF.PRFVELTARGET $N_Ref
            LoadWrite STD.CTRLWORD 0x08          ;# FaultReset

            LoadWrite MOTION.UPRAMP0   $Ramp
            LoadWrite MOTION.DOWNRAMP0 $Ramp
            LoadWrite MOTION.SYMRAMP $Ramp

            if {[LoadRead MOTION.ENASPEEDPROFILE] != 1} {
                LoadWrite MOTION.ENASPEEDPROFILE 1
            }

            if {([LoadRead STD.STATUSWORD] & 0x000F) != 6} {
                #        if {$ErrPrint == 1} { ShowLoadStatus }
                LoadWrite STD.CTRLWORD 0x02          ;# Enable
                LoadWaitForState 6 5
                LoadWrite VELPRF.START 1
            }

        } else {
            #      ModTlWrite VELPRF.PRFVELTARGET $N_Ref
            #      ModTlWrite MOTION.UPRAMP0   $Ramp
            #      ModTlWrite MOTION.DOWNRAMP0 $Ramp
            LoadWrite STD.CTRLWORD 0x08          ;# FaultReset
            LoadWrite STD.CTRLWORD 0x01          ;# Disable
            LoadWaitForState 4 5

        }
    } else { 
        fortisLoad_loadVelocity $N_Ref $IMAX

    }
}
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät relativ bewegen im POSPRF
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 120307 ockeg erstellt
#
#
#END----------------------------------------------------------------
proc LoadMoveRel { dist {nref 1000} } {
    global ActDev DevAdr Toleranz_Lage

    TlPrint ""
    TlPrint "Load device $ActDev: Position profile relative with $dist Usr and $nref rpm"

    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    doWaitMs 500                   ;# auf sicheren Stillstand des Motors warten
    set PosStart [LoadRead MONC.PACTUSR]
    LoadWrite MOTION.UPRAMP0   2000
    LoadWrite MOTION.DOWNRAMP0 2000
    LoadWrite POSPRF.SPDTARGETUSR  $nref
    LoadWrite POSPRF.STARTRELPREF  $dist

    # warte auf x_end oder x_err
    while {1} {
	if { [CheckBreak] } { break }
	set istZustand [LoadRead STD.STATUSWORD]
	if { $istZustand != "" } then {
	    if { $istZustand & 0xC000 } {
		set result 1
		break
	    }
	} else {
	    set result 0
	    break
	}
    }

   # Da x_end von PRef abhängt, müssen wir noch auf die richtige aktuelle Position warten.
   # Abhängig von der Drehrichtung ist die Toleranz_Lage berücksichtigt.
    if { $dist < 0} {
	set dir  1
    } else {
	set dir -1
    }
    if { [expr ($PosStart + $dist) ] > $PosStart } {
	LoadWaitForObjectOp MONC.PACTUSR > [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    } else {
	LoadWaitForObjectOp MONC.PACTUSR < [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    }

    TlPrint "Load device PACTUSR: [LoadRead MONC.PACTUSR]"

    return $result
}

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät absolut bewegen im POSPRF
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 190110 pfeig erstellt
#
#
#END----------------------------------------------------------------
proc LoadMoveAbs { dist {nref 1000} } {
    global ActDev DevAdr Toleranz_Lage

    TlPrint ""
    TlPrint "Load device $ActDev: Position profile absolut to $dist Usr with $nref rpm"

    LoadWrite STD.CTRLWORD 0x08   ;# FaultReset
    LoadWrite STD.CTRLWORD 0x02   ;# Enable
    LoadWaitForState 6 5
    set PosStart [LoadRead MONC.PACTUSR]
    LoadWrite MOTION.UPRAMP0   2000
    LoadWrite MOTION.DOWNRAMP0 2000
    LoadWrite POSPRF.SPDTARGETUSR  $nref
    LoadWrite POSPRF.STARTABSPOS  $dist

    # warte auf x_end oder x_err
    while {1} {
	if { [CheckBreak] } { break }
	set istZustand [LoadRead STD.STATUSWORD]
	if { $istZustand != "" } then {
	    if { $istZustand & 0xC000 } {
		set result 1
		break
	    }
	} else {
	    set result 0
	    break
	}
    }

   # da x_end von PRef abhängt, müssen wir noch auf die richtige aktuelle Position warten
    if { $dist < 0} {
	set dir  1
    } else {
	set dir -1
    }
    if { [expr ($PosStart + $dist) ] > $PosStart } {
	LoadWaitForObjectOp MONC.PACTUSR > [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    } else {
	LoadWaitForObjectOp MONC.PACTUSR < [expr ($PosStart + $dist) + ($Toleranz_Lage * $dir)] 30
    }

    return $result
}

#--------------------------------------------------------------------------
#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Warten auf Stillstand ( NACT < 9 Umdr ) des Lastgerätes
#
# ----------HISTORY----------
# WANN    WER    WAS
# 300610  grana  proc erstellt
#
#END----------------------------------------------------------------
proc LoadStand { timeout {CCId ""} } {
    global ActDev DevAdr
    global AW_NACT_0

    if {$CCId != "" } { set TTId "*$CCId*" }

    set startZeit  [clock clicks -milliseconds]
    set timeout    [expr $timeout * 1000] ;# umwandlung in Millisec.

    while {1} {
	set istZustand [expr [LoadRead STD.ACTIONWORD]& $AW_NACT_0 ]
	if { $istZustand == $AW_NACT_0 } {
	    TlPrint "Load Device is standstill after %d ms " [expr [clock clicks -milliseconds] - $startZeit]
	    break
	}

	if {[expr [clock clicks -milliseconds] - $startZeit > $timeout] } {
	    TlError "$CCId Load Device is not standstill after $timeout ms"
	    break
	}
	if {[CheckBreak]} {break}
    }

    set ActDev $ActDevCurr

} ;# LoadStand

#--------------------------------------------------------------------------
proc LoadRead { obj {ErrPrint 0} } {
    global ActDev DevAdr

    #DOC----------------------------------------------------------------
    #DESCRIPTION
    #
   # Lesen eines Parameters aus dem Lastgerät
   # CPD-Testturm : Gerät 2 oder 4
   # Icla Testturm: Gerät 11, 12 oder 13
    #
    # ----------HISTORY----------
    # WANN   WER   WAS
    # 220107 ockeg proc erstellt
    # 260115 serio replace proc call by ModTlReadForLoad
    #
    #END----------------------------------------------------------------

    if {![info exists DevAdr($ActDev,Load)]} {
	TlError "Load not available"
	return ""
    }

    set result [ModTlReadForLoad $obj $ErrPrint]

    if { ($result == "") && ($ErrPrint == 0) } {
	TlError "keine Rueckmeldung vom Lastgeraet"
    }

    return $result

} ;# LoadRead

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Schreiben eines Parameters in ein Lastgerät
# CPD-Testturm : Gerät 2 oder 4
# Icla Testturm: Gerät 11, 12 oder 13
#
# ----------HISTORY----------
# WANN   WER   WAS
# 130307 ockeg proc erstellt
# 260115 serio replace proc call by ModTlWriteForLoad
#
#END----------------------------------------------------------------
proc LoadWrite { obj value {ErrPrint 0}} {
    global ActDev DevAdr

    set result [ModTlWriteForLoad $obj $value $ErrPrint]

    return $result

} ;# LoadRead

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Lastgerät konfigurieren
#
#
# ----------HISTORY----------
# WANN    WER   WAS
# 301008  grana adapt to Servo3
#
#END----------------------------------------------------------------
proc LoadConfig { } {

    # Parameters after AutoTune
    LoadWrite CTRL1.KPN         92
    LoadWrite CTRL1.TNN       1184
    LoadWrite CTRL1.KPP        211
    LoadWrite CTRL1.KFPP         0
    LoadWrite CTRL1.TAUNREF   1184

    LoadWrite CTRLG.POSWIN      10
    LoadWrite CTRLG.POSWINTM     0

    LoadWrite PARAM.STORE        1
    LoadWaitForObject  PARAM.STORE   0 2

} ;# LoadConfig

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on Opal device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 190116 pfeig proc created
#
#END----------------------------------------------------------------
proc Opal_On {DevNr {State 2} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActDev
    global ActInterface
    global MBTCPCom
    global CanNetOpen
    global ECAT_H_IsOpen
    global GLOB_LAST_DRIVE_REBOOT

    set TTId [Format_TTId $TTId]
    set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
	4 -
	21 -
	23 -
	5 { TlPrint "Switch on Opal Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after a restart

    if { [ GetDevFeat "BusSys"] } {

	switch -exact $DevNr {

	    1 - 21 {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "H"
		    SM_SetESMSTART "H"
		    SM_SetGUARD_X "AB" "H"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
		wc_SetSTO "H"
	    }
	 2 - 
	 23 - 
	 3 - 
	 4 - 
	 5 {
		wc_SetSTO "H"
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	if {(($ActInterface == "CAN") || ($ActInterface == "MODCAN")) && !$CanNetOpen} {
	    doOpenCAN "TestNet"
	}

	#Opal ON
	wc_OpalOnOff $DevNr "H"                                   ;#Turn on device
	TlPrint "ActInterface: $ActInterface"
	
	if {[GetDevFeat "FW_CIPSFTY"]} {
	    #timeout 8sec to manage safety behavior (On just before) 
	    doWaitMs 8000

	}   
	
	set stateAct [doWaitForModState ">=0" $timeout $TTId]    ;# wait for any modbus communication
	if { $stateAct == 23 } {
	    set dp0 [ModTlRead DP0 0]
	    if { ($dp0 == 69) } {
		TlError "*GEDEC00184571* INFE error at power on"
		TlPrint "SFFault_u16DiagnoseFaultReq=%s"        [ModTlReadIntern "SFFault_u16DiagnoseFaultReq" 1]
		TlPrint "DbgAssert_u16Id=%s"                    [ModTlReadIntern "DbgAssert_u16Id" 1]
		TlPrint "SFATAP_u16PublicInternalFaults=%s"     [ModTlReadIntern "SFATAP_u16PublicInternalFaults" 1]
		TlPrint "SFFault_u16PublicDiagFaultStatus=%s"   [ModTlReadIntern "SFFault_u16PublicDiagFaultStatus" 1]
		ShowStatus
	    }
	}

	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                      ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-9]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		if {$ECAT_H_IsOpen != 1} {
		    ECAT_H_Open "Default"
		}
		EtherCAT_SetMasterState "OP"
		EtherCAT_WaitForMasterState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	    "MODTCP" -
	    "MODTCP_OptionBoard" -
	    "MODTCP_OptionBoard_UID251" {
		set PingOK 0
		#Open a new connection with the configuration of the last opened Modbus connection
		if {$ActInterface == "MODTCP"} {
		    if {[doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000 1 0 "GEDEC00204802"]} {
			set PingOK 1
		    }
		} else {
		    if {[doWaitForPing $DevAdr($ActDev,OptBrdIP)   30000 1 0 "GEDEC00183576"]} {
			set PingOK 1
		    }
		}

		if {$PingOK != 1} {
		    TlPrint "Write IP again and reboot drive to solve GEDEC00204802"
		    ShowStatus
		    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1
		    doStoreEEPROM
		    wc_OpalOnOff $ActDev "L"
		    doWaitForOff 10
		    TlPrint "Switch Opal device $ActDev on"
		    wc_SetSTO "H"
		    wc_OpalOnOff $ActDev "H"
		    doWaitMs 7500
		    if {$ActInterface == "MODTCP"} {
			doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000
		    } else {
			doWaitForPing $DevAdr($ActDev,OptBrdIP) 30000
		    }
		}

		doWaitMs 1000

		Mod2Open $ActInterface
	    }
	    "DVN" {
		AddDevNetDevice $ActDev                ;#Add device to the net
	    }
	    "SPB_IO" -
	    "SPB_STD" -
	    "PN_IO" -
	    "PN_STD" {
		#Reopen the last used telegram
		PB_PN_OpenTelegram [PB_PN_SetGetTelegram]
		PB_PN_ResetBytes
		# todo: Rework this. The status of the ProfiNet bus should be independant
		# of drive switching on or off
	    }
	    "MOD" {
		#For the case the Profinet Hilscher interface is online and the TCL interface is Modbus
		if {[GetDevFeat "BusPN"]} {
		    if {[Profinet::isChannelOpen]} {
			Profinet::waitForSlave "25000"
			#doWaitMs 2000 ;#removed in V0.3ie07 B09 b00, see GEDEC00177854
		    }
		}
	    }
	    "CAN" -
	    "MODCAN" {
		#doWaitForObject NMTS .BOOT 1                          ;#NMT in BootUp state
		CheckNMTMessage $DevAdr($ActDev,$ActInterface) 0      ;#BootUp message
		ReadOutEMCYMessage $DevAdr($ActDev,$ActInterface) 1   ;#EMCY sent at start
		ServNMT $DevAdr($ActDev,$ActInterface) 0x01 0         ;#Start node
		doWaitForObject NMTS .OPE 1                           ;#NMT in state "operational"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }

    #   #Workaround for Wago 750-456 issue
    #
    #   if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"] } {
    #      wc_SetDigital 3 0x18 L
    #      wc_SetDigital 3 0x60 H
    #   } else {
    #      wc_SetDigital 14 0x18 L
    #      wc_SetDigital 14 0x60 H
    #   }

    set ActDev $ActDevCurr
    return $ComOK
} ;# Opal_On

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off Opal device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 190116 pfeig proc created
#
#
#END----------------------------------------------------------------
proc Opal_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface MBTCPioCom

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
      4 -
	21 -
	23 -
	5 { TlPrint "Switch off Opal Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    switch -exact $ActInterface {
	"ECAT" {
	    ECAT_H_Close
	}
	"MODTCP" -
	"MODTCP_OptionBoard" -
	"MODTCP_OptionBoard_UID251" {
	    #Close all connections to the drive but not the Wago controller connection
	    Mod2Close 0
	}

	"DVN" {
	    RemoveDevNetDevice $ActDev
	}
	"CAN" -
	"MODCAN" {
	    ServNMT $DevAdr($ActDev,$ActInterface) 0x02 0      ;#Stop node
	    doWaitForModObject NMTS .STOP 1                    ;#NMT in state "stopped"
	}
    }

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_OpalOnOff $DevNr L
	#     wc_DCDischarge $DevNr
	#      if {[GetDevFeat "DCDischarge"]} {
	#         if {[doWaitForOff 3] != ""} {
	#            doWaitForOff 30
	#         }
	#      } else {
	#      }

	switch $DevNr {
	    1 - 21 {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "L"
		    SM_SetESMSTART "L"
		    SM_SetGUARD_X "AB" "L"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
		wc_SetSTO "L"
	    }
	    2 - 
	    23 - 
	    3 - 
	    4 - 
	    5 {
		wc_SetSTO "L"
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	doWaitForOff 30
	doWaitMs 5000
    } else {
	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr

    #Workaround for Wago 750-456 issue
    #   if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"] } {
    #      wc_SetDigital 3 0x18 L
    #      wc_SetDigital 3 0x60 L
    #   } else {
    #      wc_SetDigital 14 0x18 L
    #      wc_SetDigital 14 0x60 L
    #   }

    set MBTCPioCom 0

} ;# Opal_Off


#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on Nera device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 050813 todet proc created from Altivar_On
# 090514 serio change default State to 2, correct HMIS check for stateAct instead of RDY
# 080415 weiss drive initialization directly checked at switch on
# 130324 ASY add devices 12 & 13 
# 050424 YGH removed devices 12 & 13 (Issue #1883)
#END----------------------------------------------------------------
proc Nera_On {DevNr {State 2} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr DevAdr
    global ActInterface
    global MBTCPCom
    global CanNetOpen
    global GLOB_LAST_DRIVE_REBOOT

    set TTId [Format_TTId $TTId]
    set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
      1 - 2 - 3 { TlPrint "Switch on Nera Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after a restart

    if { [ GetDevFeat "BusSys"] } {

	switch -exact $DevNr {
         "1" - "2" - "3" {
	    # TO FIX : waiting STO wiring on EAE tower !
	    if {![GetSysFeat "EAETower1"]} {
		wc_SetSTO "H"
	    }
         }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	if {(($ActInterface == "CAN") || ($ActInterface == "MODCAN")) && !$CanNetOpen} {
	    doOpenCAN "TestNet"
	}

	#Nera ON
	wc_NeraOnOff $DevNr "H"                                   ;#Turn on device
	TlPrint "ActInterface: $ActInterface"

	set stateAct [doWaitForModState ">=0" $timeout $TTId]    ;# wait for any modbus communication
	if { $stateAct == 23 } {
	    set dp0 [ModTlRead DP0 0]
	    if { ($dp0 == 69) } {
		TlError "*GEDEC00184571* INFE error at power on"
		TlPrint "SFFault_u16DiagnoseFaultReq=%s"        [ModTlReadIntern "SFFault_u16DiagnoseFaultReq" 1]
		TlPrint "DbgAssert_u16Id=%s"                    [ModTlReadIntern "DbgAssert_u16Id" 1]
		TlPrint "SFATAP_u16PublicInternalFaults=%s"     [ModTlReadIntern "SFATAP_u16PublicInternalFaults" 1]
		TlPrint "SFFault_u16PublicDiagFaultStatus=%s"   [ModTlReadIntern "SFFault_u16PublicDiagFaultStatus" 1]
		ShowStatus
	    }
	}

	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                      ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-9]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		ECAT_H_Open "Default"
		EtherCAT_SetMasterState "OP"
		EtherCAT_WaitForMasterState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	    "MODTCP" -
	    "MODTCP_OptionBoard" -
	    "MODTCP_OptionBoard_UID251" {
		set PingOK 0
		#Open a new connection with the configuration of the last opened Modbus connection
		if {$ActInterface == "MODTCP"} {
		    if {[doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000 1 0 "GEDEC00183576"]} {
			set PingOK 1
		    }
		} else {
		    if {[doWaitForPing $DevAdr($ActDev,OptBrdIP)   30000 1 0 "GEDEC00183576"]} {
			set PingOK 1
		    }
		}

		if {$PingOK != 1} {
		    TlPrint "Reboot drive to solve GEDEC00183576"
		    ShowStatus
		    DeviceOff $ActDev 1
		    doWaitMs 1000
		    TlPrint "Switch NERA device $ActDev on"
		    wc_SetSTO "H"
		    wc_NeraOnOff $ActDev "H"
		    doWaitMs 7500
		    if {$ActInterface == "MODTCP"} {
			doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000
		    } else {
			doWaitForPing $DevAdr($ActDev,OptBrdIP) 30000
		    }
		}
		doWaitMs 2000
		Mod2Open $ActInterface
	    }
	    "DVN" {
		AddDevNetDevice $ActDev                ;#Add device to the net
	    }
	    "SPB_IO" -
	    "SPB_STD" -
	    "PN_IO" -
	    "PN_STD" {
		#Reopen the last used telegram
		PB_PN_OpenTelegram [PB_PN_SetGetTelegram]
		PB_PN_ResetBytes
		# todo: Rework this. The status of the ProfiNet bus should be independant
		# of drive switching on or off
	    }
	    "MOD" {
		#For the case the Profinet Hilscher interface is online and the TCL interface is Modbus
		if {[GetDevFeat "BusPN"]} {
		    if {[Profinet::isChannelOpen]} {
			Profinet::waitForSlave "25000"
			#doWaitMs 2000 ;#removed in V0.3ie07 B09 b00, see GEDEC00177854
		    }
		}
	    }
	    "CAN" -
	    "MODCAN" {
		doWaitForObject NMTS .BOOT 1                          ;#NMT in BootUp state
		CheckNMTMessage $DevAdr($ActDev,$ActInterface) 0      ;#BootUp message
		ReadOutEMCYMessage $DevAdr($ActDev,$ActInterface) 1   ;#EMCY sent at start
		ServNMT $DevAdr($ActDev,$ActInterface) 0x01 0       	;#Start node
		doWaitForObject NMTS .OPE 1                           ;#NMT in state "operational"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }

    set ActDev $ActDevCurr
    return $ComOK
} ;# Nera_On

proc Altivar_On {DevNr {State ">=2"} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActInterface
    global MBTCPCom

    set TTId [Format_TTId $TTId]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	4 -
	5 { TlPrint "Switch on Altivar Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

   set ActDevCurr $ActDev ;# notwendig für doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Merker ob Bus Kommunikation nach einem Neustart noch geht

    if { [ GetDevFeat "BusSys"] } {

	if {![GetSysFeat "Gen2Tower"] } {
	    switch -exact $DevNr {
		"1" -
		"2" {
		    wc_SetSTOex $DevNr "H"
		}
		"4" {
		    TlPrint "Dev 4"
		}
	 "5" {
	    TlPrint "Dev 5"
	 }
		default  {
		    TlError "Unexpected device No. $DevNr"
		    return
		}
	    }
	} else {
	    wc_SetSTOex $DevNr "H"
	}
	wc_AltivarOnOff $DevNr "H"                ;#Switch on device
	doWaitMs 5000
	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -exact $ActInterface {
	    "ECAT" {
		ECAT_H_Open "Default"
		EtherCAT_SetMasterState "OP"
		EtherCAT_WaitForMasterState "OP"
		EtherCAT_WaitForSlaveState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	    "MODTCP" -
	    "MODTCP_OptionBoard" -
	    "MODTCP_OptionBoard_UID251" {
		#Open a new connection to the drive with the configuration of the last opened Modbus connection
		Mod2Open $ActInterface
	    }
	    "PN_IO" -
	    "PN_STD" {
		#Reopen the last used telegram
		PB_PN_OpenTelegram [PB_PN_SetGetTelegram]
		PB_PN_ResetBytes
		# todo: Rework this. The status of the ProfiNet bus should be independant
		# of drive switching on or off
	    }
	    "DVN" {
		AddDevNetDevice $ActDev                ;#Add device to the net
	    }
	    "CAN" -
	    "MODCAN" {
		if {![info exists NetName] } {
		    set NetName "TestNet"
		}
		TlPrint " NetName  : $NetName    "
		doOpenCAN $NetName                              ;#Open CANopen interface
		doWaitMs 2000                                   ;#Waiting time until interface initialized
		ServNMT $DevAdr($ActDev,$ActInterface) 0x01     ;#Start node
	    }
	}

	switch -regexp $State {
	    {[<>=1-9]} {
		#TlPrint " Wait for state $State"
		if {[doWaitForState $State $timeout $TTId] == 0} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Device $DevNr von Hand einschalten : Profibus nicht aktiv"
	    TlInput "Weiter mit Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    set ActDev $ActDevCurr
    return $ComOK

} ;# Altivar_On

# Doxygen Tag:
##Function description : Turns on an ATS device 
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2024/03/13 | ASY | proc created
#
# Function to be called from DeviceOn 
proc ATS_On {DevNr {State ">=2"} {timeout 10} {TTId ""}} {
    global DevAdr 
    global theTestcaseID HandMade
    global ActDev 
    global MBAdr ActInterface
    global MBTCPCom

    set TTId [Format_TTId $TTId]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	11 -
	14 { TlPrint "Switch on ATS Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

   set ActDevCurr $ActDev ;# notwendig für doWaitForState
    set ActDev $DevNr

    if { [ GetDevFeat "BusSys"] } {

	wc_ATSOnOff $DevNr "H"                ;#Switch on device
	doWaitMs 5000
	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-9]} {
		#TlPrint " Wait for state $State"
		if {[doWaitForState $State $timeout $TTId] == 0} {
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Device $DevNr von Hand einschalten : Profibus nicht aktiv"
	    TlInput "Weiter mit Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    set ActDev $ActDevCurr

} ;# ATS_On
# Doxygen Tag:
##Function description : Turns off an ATS device 
## WHEN  | WHO  | WHAT
# -----| -----| -----
# 2024/03/13 | ASY | proc created
#
# Function to be called from DeviceOff 
proc ATS_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface

    set ActDevCurr $ActDev
    set ActDev $DevNr

    TlPrint "----------------------------"
    switch $DevNr {
	11 - 14 { TlPrint "Switch off ATS Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set SwitchOffInterface $ActInterface

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_ATSOnOff $DevNr L
	doWaitForOff 17     ;# 15
    } else {
	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr

} ;# ATS_Off	

proc Altivar_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface

    set ActDevCurr $ActDev
    set ActDev $DevNr

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	[1-5] { TlPrint "Switch off Altivar Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set SwitchOffInterface $ActInterface
    switch -exact $ActInterface {
	"ECAT" {
	    ECAT_H_Close
	}
	"MODTCP" {
	    #Close all connections to the drive but not the Wago controller connection
	    Mod2Close 0
	}
	"DVN" {
	    RemoveDevNetDevice $ActDev
	}
	"CAN" -
	"MODCAN" {
	    ServNMT $DevAdr($ActDev,$ActInterface) 0x02 0      ;#Stop node
	    doWaitForModObject NMTS .STOP 1                    ;#NMT in state "stopped"
	}
    }

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_AltivarOnOff $DevNr L
	doWaitForOff 17     ;# 15
	if {![GetSysFeat "Gen2Tower"] } {
	    switch $DevNr {
		"1" -
		"2" {
		    wc_SetSTOex $DevNr "L"
		}
		"4" {
		    TlPrint "Dev 4"
		}
	 "5" {
	    TlPrint "Dev 5"
	 }
		default  {
		    TlError "Unexpected device No. $DevNr"
		    return
		}
	    }
	} else {
	    wc_SetSTOex $DevNr "L"
	}
    } else {

	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr

} ;# Altivar_Off

proc wc_AltivarOnOff { DevNr Level } {
    global Dev_On sePLC

    switch $Level {
	"l" -
	"L" -
	"h" -
	"H" { set Level [string toupper $Level] }
	"0" { set Level "L" }
	"1" { set Level "H" }
	default  {
	    TlError "invalid Level $Level"
	    return 0
	}
    }
    if { $Level == "H" } {
	set value 1
    } else {
	set value 0
    }
    if { ![GetSysFeat "Gen2Tower"] } {
	switch $DevNr {
	    "1" {
		wc_SetDigital 1 0x07 $Level         ;# Power on Device N1
		set Dev_On(1) $value
	    }
	    "2" {
		wc_SetDigital 1 0x70 $Level         ;# Power on Device N3
		set Dev_On(2) $value
	    }
	    "4" {

		wc_SetDigital 9 0x38 $Level
		set Dev_On(4) $value
	    }
      "5" {
	 if {[GetSysFeat "EAETower1"]} {
	     wc_SetDigital_EAE 303 5 $value
	     # Power on motor for Device 2
	     wc_SetDigital_EAE 303 15 $value
	 }
      }
	    default  {
		TlError "Unexpected device No. $DevNr"
		return 0
	    }
	}
    } else {
	se_TCP_writeWordMask [expr ($DevNr - 1) * $sePLC(structureSize) + $sePLC(mainPower_offset)] 0x00FF $value
	set Dev_On($DevNr) $value
    }

    return 1

} ;# wc_AltivarOnOff

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on Fortis device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 141112 pfeig proc created
# 220115 serio add Workaround for Wago 750-456 issue
# 180315 serio add PACY_SFTY_OPAL
# 080415 weiss drive initialization directly checked at switch on
# 050424 YGH   added devices 12 & 13 (Issue #1883)
#END----------------------------------------------------------------
proc Fortis_On {DevNr {State 2} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActDev
    global ActInterface
    global MBTCPCom
    global CanNetOpen
    global ECAT_H_IsOpen
    global GLOB_LAST_DRIVE_REBOOT

    set TTId [Format_TTId $TTId]
    set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
	5 -
	8 -
	9 -
	12 -
	13 { if { [ GetDevFeat "ShadowOffer"] } {
		TlPrint "Switch on ShadowOffer Dev$DevNr"
	    } else {
		TlPrint "Switch on FORTIS Dev$DevNr" 
	    }
	}
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after a restart

    if { [ GetDevFeat "BusSys"] } {

	switch -exact $DevNr {

	    1 -
	    8   {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "H"
		    SM_SetESMSTART "H"
		    SM_SetGUARD_X "AB" "H"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
		wc_SetSTO "H"
	    }
	    2 -
	    9 -
	    12 -
	    13 {
            # TO FIX : waiting STO wiring on EAE tower !
            if {![GetSysFeat "EAETower1"]} {
		wc_SetSTO "H"
            }
	}
	    3 - 
	    5 - 
	    15 {
		wc_SetSTO "H"
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	if {(($ActInterface == "CAN") || ($ActInterface == "MODCAN")) && !$CanNetOpen} {
	    doOpenCAN "TestNet"
	}

	#Fortis ON
	wc_FortisOnOff $DevNr "H"                                   ;#Turn on device
	TlPrint "ActInterface: $ActInterface"

	if {[GetDevFeat "FW_CIPSFTY"]} {
	    #timeout 8sec to manage safety behavior (On just before) 
	    doWaitMs 8000   

	}


	set stateAct [doWaitForModState ">=0" $timeout $TTId]    ;# wait for any modbus communication
	if { $stateAct == 23 } {
	    set dp0 [ModTlRead DP0 0]
	    if { ($dp0 == 69) } {
		TlError "*GEDEC00184571* INFE error at power on"
		TlPrint "SFFault_u16DiagnoseFaultReq=%s"        [ModTlReadIntern "SFFault_u16DiagnoseFaultReq" 1]
		TlPrint "DbgAssert_u16Id=%s"                    [ModTlReadIntern "DbgAssert_u16Id" 1]
		TlPrint "SFATAP_u16PublicInternalFaults=%s"     [ModTlReadIntern "SFATAP_u16PublicInternalFaults" 1]
		TlPrint "SFFault_u16PublicDiagFaultStatus=%s"   [ModTlReadIntern "SFFault_u16PublicDiagFaultStatus" 1]
		ShowStatus
	    }
	}

	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                      ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-9]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		if {$ECAT_H_IsOpen != 1} {
		    ECAT_H_Open "Default"
		}
		EtherCAT_SetMasterState "OP"
		EtherCAT_WaitForMasterState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	    "MODTCP" -
	    "MODTCP_OptionBoard" -
	    "MODTCP_OptionBoard_UID251" {
		set PingOK 0
		#Open a new connection with the configuration of the last opened Modbus connection
		if {$ActInterface == "MODTCP"} {
		    if {[doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000 1 0 "GEDEC00204802"]} {
			set PingOK 1
		    }
		} else {
		    if {[doWaitForPing $DevAdr($ActDev,OptBrdIP)   30000 1 0 "GEDEC00183576"]} {
			set PingOK 1
		    }
		}

		if {$PingOK != 1} {
		    TlPrint "Write IP again and reboot drive to solve GEDEC00204802"
		    ShowStatus
		    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1
		    doStoreEEPROM
		    wc_FortisOnOff $ActDev "L"
		    doWaitForOff 10
		    if { [ GetDevFeat "ShadowOffer"] } {
		    	TlPrint "Switch ShadowOffer device $ActDev on"
		    } else {
		    	TlPrint "Switch FORTIS device $ActDev on"
		    }
		    wc_SetSTO "H"
		    wc_FortisOnOff $ActDev "H"
		    doWaitMs 7500
		    if {$ActInterface == "MODTCP"} {
			doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000
		    } else {
			doWaitForPing $DevAdr($ActDev,OptBrdIP) 30000
		    }
		}
		doWaitMs 2000
		Mod2Open $ActInterface
	    }
	    "DVN" {
		AddDevNetDevice $ActDev                ;#Add device to the net
	    }
	    "SPB_IO" -
	    "SPB_STD" -
	    "PN_IO" -
	    "PN_STD" {
		#Reopen the last used telegram
		PB_PN_OpenTelegram [PB_PN_SetGetTelegram]
		PB_PN_ResetBytes
		# todo: Rework this. The status of the ProfiNet bus should be independant
		# of drive switching on or off
	    }
	    "MOD" {
		#For the case the Profinet Hilscher interface is online and the TCL interface is Modbus
		if {[GetDevFeat "BusPN"]} {
		    if {[Profinet::isChannelOpen]} {
			Profinet::waitForSlave "25000"
			#doWaitMs 2000 ;#removed in V0.3ie07 B09 b00, see GEDEC00177854
		    }
		}
	    }
	    "CAN" -
	    "MODCAN" {
		doWaitForObject NMTS .BOOT 1                          ;#NMT in BootUp state
		CheckNMTMessage $DevAdr($ActDev,$ActInterface) 0      ;#BootUp message
		ReadOutEMCYMessage $DevAdr($ActDev,$ActInterface) 1   ;#EMCY sent at start
		ServNMT $DevAdr($ActDev,$ActInterface) 0x01 0         ;#Start node
		doWaitForObject NMTS .OPE 1                           ;#NMT in state "operational"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }

    if { ![GetSysFeat "Gen2Tower"] } {
	#Workaround for Wago 750-456 issue

	if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"] } {
	    wc_SetDigital 3 0x18 L
	    wc_SetDigital 3 0x60 H
   } elseif {![GetSysFeat "EAETower1"]} {
	    wc_SetDigital 14 0x18 L
	    wc_SetDigital 14 0x60 H
	}
    }

    set ActDev $ActDevCurr
    return $ComOK
} ;# Fortis_On

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off Fortis device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 141112 pfeig proc created
# 220115 serio add Workaround for Wago 750-456 issue
# 040215 serio/grola Workaround for Com option board towers
# 180315 serio add PACY_SFTY_OPAL
# 050424 YGH   added devices 12 & 13 (Issue #1883)
#
#END----------------------------------------------------------------
proc Fortis_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface MBTCPioCom

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
	5 -
	8 -
	9 -
	12 -
	13 -
	15 { 	
		if { [ GetDevFeat "ShadowOffer"] } {
			TlPrint "Switch off ShadowOffer Dev$DevNr"
		} else {
			TlPrint "Switch off FORTIS Dev$DevNr"
		}
	}
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    switch -exact $ActInterface {
	"ECAT" {
	    ECAT_H_Close
	}
	"MODTCP" -
	"MODTCP_OptionBoard" -
	"MODTCP_OptionBoard_UID251" {
	    #Close all connections to the drive but not the Wago controller connection
	    Mod2Close 0
	}

	"DVN" {
	    RemoveDevNetDevice $ActDev
	}
	"CAN" -
	"MODCAN" {
	    ServNMT $DevAdr($ActDev,$ActInterface) 0x02 0      ;#Stop node
	    doWaitForModObject NMTS .STOP 1                    ;#NMT in state "stopped"
	}
    }

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_FortisOnOff $DevNr L
	wc_DCDischarge $DevNr
	if {[GetDevFeat "DCDischarge"]} {
	    if {[doWaitForOff 3] != ""} {
		doWaitForOff 30
	    }
	} else {
	    doWaitForOff 30
	}

	switch $DevNr {
	    1 -
	    8 {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "L"
		    SM_SetESMSTART "L"
		    SM_SetGUARD_X "AB" "L"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
		wc_SetSTO "L"
	    }
	    2 -
	    9 -
	    12 -
	    13 {
	    # TO FIX : waiting STO wiring on EAE tower !
	    if {![GetSysFeat "EAETower1"]} {
		wc_SetSTO "L"
		}
	    }
	    3 - 
	    5 - 
	    15 {
		wc_SetSTO "L"
	    }
	
	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	doWaitMs 5000

    } else {
	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr

    if { ![GetSysFeat "Gen2Tower"] } {
	#Workaround for Wago 750-456 issue
	if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"] } {
	    wc_SetDigital 3 0x18 L
	    wc_SetDigital 3 0x60 L
   } elseif {![GetSysFeat "EAETower1"]} {
	    wc_SetDigital 14 0x18 L
	    wc_SetDigital 14 0x60 L
	}

    }

    set MBTCPioCom 0

} ;# Fortis_Off

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on MVK device
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 140217 cordc proc created
#
#END----------------------------------------------------------------
proc MVK_On {DevNr {State 2} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActDev
    global ActInterface
    global MBTCPCom
    global CanNetOpen
    global ECAT_H_IsOpen
    global GLOB_LAST_DRIVE_REBOOT

    set timeout [expr (5*$timeout)]
    set TTId [Format_TTId $TTId]
    set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
	6 -
	5 { TlPrint "Switch on MVK Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after a restart

    if { [ GetDevFeat "BusSys"] } {

	switch -exact $DevNr {

	    1 {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "H"
		    SM_SetESMSTART "H"
		    SM_SetGUARD_X "AB" "H"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
	    }
	    5 - 
	    6 {
		wc_SetSTO "H"
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}

	if {(($ActInterface == "CAN") || ($ActInterface == "MODCAN")) && !$CanNetOpen} {
	    doOpenCAN "TestNet"
	}

	#MVK ON
	wc_MVKOnOff $DevNr "H"                                   ;#Turn on device
	TlPrint "ActInterface: $ActInterface"

	set stateAct [doWaitForModState ">=0" $timeout $TTId]    ;# wait for any modbus communication
	if { $stateAct == 23 } {
	    set dp0 [ModTlRead DP0 0]
	    if { ($dp0 == 69) } {
		TlError "*GEDEC00184571* INFE error at power on"
		TlPrint "SFFault_u16DiagnoseFaultReq=%s"        [ModTlReadIntern "SFFault_u16DiagnoseFaultReq" 1]
		TlPrint "DbgAssert_u16Id=%s"                    [ModTlReadIntern "DbgAssert_u16Id" 1]
		TlPrint "SFATAP_u16PublicInternalFaults=%s"     [ModTlReadIntern "SFATAP_u16PublicInternalFaults" 1]
		TlPrint "SFFault_u16PublicDiagFaultStatus=%s"   [ModTlReadIntern "SFFault_u16PublicDiagFaultStatus" 1]
		ShowStatus
	    }
	}

	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                      ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-51]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		if {$ECAT_H_IsOpen != 1} {
		    ECAT_H_Open "Default"
		}
		EtherCAT_SetMasterState "OP"
		EtherCAT_WaitForMasterState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	    "MODTCP" -
	    "MODTCP_OptionBoard" -
	    "MODTCP_OptionBoard_UID251" {
		set PingOK 0
		#Open a new connection with the configuration of the last opened Modbus connection
		if {$ActInterface == "MODTCP"} {
		    if {[doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000 1 0 "GEDEC00204802"]} {
			set PingOK 1
		    }
		} else {
		    if {[doWaitForPing $DevAdr($ActDev,OptBrdIP)   30000 1 0 "GEDEC00183576"]} {
			set PingOK 1
		    }
		}

		if {$PingOK != 1} {
		    TlPrint "Write IP again and reboot drive to solve GEDEC00204802"
		    ShowStatus
		    writeIpBas $DevAdr($ActDev,BasicEthIP) $DevAdr($ActDev,MASK) $DevAdr($ActDev,GATE) 1
		    doStoreEEPROM
		    wc_MVKOnOff $ActDev "L"
		    doWaitForOff 10
		    TlPrint "Switch MVK device $ActDev on"
		    #wc_SetSTO "H"
		    wc_MVKOnOff $ActDev "H"
		    doWaitMs 7500
		    if {$ActInterface == "MODTCP"} {
			doWaitForPing $DevAdr($ActDev,BasicEthIP) 30000
		    } else {
			doWaitForPing $DevAdr($ActDev,OptBrdIP) 30000
		    }
		}
		doWaitMs 2000
		Mod2Open $ActInterface
	    }
	    "DVN" {
		AddDevNetDevice $ActDev                ;#Add device to the net
	    }
	    "SPB_IO" -
	    "SPB_STD" -
	    "PN_IO" -
	    "PN_STD" {
		#Reopen the last used telegram
		PB_PN_OpenTelegram [PB_PN_SetGetTelegram]
		PB_PN_ResetBytes
		# todo: Rework this. The status of the ProfiNet bus should be independant
		# of drive switching on or off
	    }
	    "MOD" {
		#For the case the Profinet Hilscher interface is online and the TCL interface is Modbus
		if {[GetDevFeat "BusPN"]} {
		    if {[Profinet::isChannelOpen]} {
			Profinet::waitForSlave "25000"
			#doWaitMs 2000 ;#removed in V0.3ie07 B09 b00, see GEDEC00177854
		    }
		}
	    }
	    "CAN" -
	    "MODCAN" {
		doWaitForObject NMTS .BOOT 1 0xFFFF "" 1               ;#NMT in BootUp state
		CheckNMTMessage $DevAdr($ActDev,$ActInterface) 0      ;#BootUp message
		ReadOutEMCYMessage $DevAdr($ActDev,$ActInterface) 1   ;#EMCY sent at start
		ServNMT $DevAdr($ActDev,$ActInterface) 0x01 0         ;#Start node
		doWaitForObject NMTS .OPE 1                           ;#NMT in state "operational"
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }

    #Workaround for Wago 750-456 issue

    if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"]} {
	wc_SetDigital 3 0x18 L
	wc_SetDigital 3 0x60 H

    } elseif {![GetSysFeat "MVKTower1"] && ![GetSysFeat "MVKTower2"] && ![GetSysFeat "PACY_COM_PROFINET2"]} {
	wc_SetDigital 14 0x18 L
	wc_SetDigital 14 0x60 H
    }

    set HMIS_INI [TlRead HMIS]
    if { [GetDevFeat "MVK"] && [GetDevFeat "AdaptationBoard"] } {
	doWaitForNotObject HMIS .INI 200
    } else {
    	if { $HMIS_INI == 54 } { doWaitForObjectList HMIS {.RDY .NST .NLP} 80 }    
    }

    set ActDev $ActDevCurr
    return $ComOK
} ;# MVK_On

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off MVK device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 140217 cordc proc created
#
#END----------------------------------------------------------------
proc MVK_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface MBTCPioCom

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 -
	2 -
	3 -
	6 -
	5 { TlPrint "Switch off MVK Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    switch -exact $ActInterface {
	"ECAT" {
	    ECAT_H_Close
	}
	"MODTCP" -
	"MODTCP_OptionBoard" -
	"MODTCP_OptionBoard_UID251" {
	    #Close all connections to the drive but not the Wago controller connection
	    Mod2Close 0
	}

	"DVN" {
	    RemoveDevNetDevice $ActDev
	}
	"CAN" -
	"MODCAN" {
	    ServNMT $DevAdr($ActDev,$ActInterface) 0x02 0      ;#Stop node
	    doWaitForModObject NMTS .STOP 1                    ;#NMT in state "stopped"
	}
    }

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_MVKOnOff $DevNr L
	#wc_DCDischarge $DevNr
	if {[GetDevFeat "DCDischarge"]} {
	    if {[doWaitForOff 3] != ""} {
		doWaitForOff 30
	    }
	} else {
	    doWaitForOff 30
	}

	switch $DevNr {
	    1 {
		if {[GetDevFeat "Modul_SM1"]} {
		    SM_SetESTOP_X "AB" "L"
		    SM_SetESMSTART "L"
		    SM_SetGUARD_X "AB" "L"
		    SM_SetSETUPENABLE_X "AB" "L"
		    SM_SetSETUPMODE_X "AB" "L"
		    SM_SetINTERLOCK_IN "L"
		}
	    }
	    5 - 
	    6 {
		wc_SetSTO "L"
	    }

	    default  {
		TlError "Unexpected device No. $DevNr"
		return
	    }
	}
	doWaitMs 5000
    } else {
	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr

    #Workaround for Wago 750-456 issue
    if {[GetSysFeat "PACY_SFTY_FORTIS"] || [GetSysFeat "PACY_APP_FORTIS"] || [GetSysFeat "PACY_SFTY_OPAL"]} {
	wc_SetDigital 3 0x18 L
	wc_SetDigital 3 0x60 L
    } elseif { ![GetSysFeat "MVKTower1"] && ![GetSysFeat "MVKTower2"] && ![GetSysFeat "PACY_COM_PROFINET2"]}  {
	wc_SetDigital 14 0x18 L
	wc_SetDigital 14 0x60 L
    }

    set MBTCPioCom 0

} ;# MVK_Off

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off Nera device
#
#
# ----------HISTORY----------
# WANN   WER   WAS
# 050813 todet proc created from Altivar_Off
# 040215 serio/grola Workaround for Com option board towers
# 130324 ASY add devices 12 & 13
# 050424 YGH removed devices 12 & 13 (Issue #1883)
#END----------------------------------------------------------------
proc Nera_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface

    #   TlPrint ""
    #   TlPrint "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    #   TlPrint "Workaround, remove again if no more problems with ping to AdvEth"
    #
    #   TlWrite MODE .TP
    #   TlWrite DBGF 65
    #
    #   set Timestamp [clock format [clock seconds] -format {%d%m%Y_%H%M%S}]
    #
    #   set File "System:/Conf/Modules/Conf/A/ADV/IPCL/Config.eth"
    #
    #   if {[FileManagerOpenSession]} {
    #      set Buffer [FileManagerGetFile $File 0 10]
    #      FileManagerDumpHexToFile "C:/EthernetProblems/Config$Timestamp.cfg" $Buffer
    #      set Length [string length $Buffer]
    #      TlPrint "Length of 'System:/Conf/Modules/Conf/A/ADV/IPCL/Config.eth': $Length"
    #   }
    #
    #   TlPrint "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    TlPrint "----------------------------"
	TlPrint "Device number = $DevNr \n"
    switch -regexp $DevNr {
      1 - 2 - 3 { TlPrint "Switch off Nera Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    switch -exact $ActInterface {
	"ECAT" {
	    ECAT_H_Close
	}
	"MODTCP" -
	"MODTCP_OptionBoard" -
	"MODTCP_OptionBoard_UID251" {
	    #Close all connections to the drive but not the Wago controller connection
	    Mod2Close 0
	}

	"DVN" {
	    RemoveDevNetDevice $ActDev
	}
	"CAN" -
	"MODCAN" {
	    ServNMT $DevAdr($ActDev,$ActInterface) 0x02 0   	;#Stop node
	    doWaitForModObject NMTS .STOP 1                    ;#NMT in state "stopped"
	}
    }

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_NeraOnOff $DevNr L
	wc_DCDischarge $DevNr
	if {[GetDevFeat "DCDischarge"]} {
	    if {[doWaitForOff 3] != ""} {
		doWaitForOff 30
	    }
	} else {
	    doWaitForOff 30
	}

      # TO FIX : waiting STO wiring on EAE tower !
      if {![GetSysFeat "EAETower1"]} {
	wc_SetSTO "L"
      }
	doWaitMs 2000
    } else {
	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr
} ;# Nera_Off

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on Nera device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 140813 todet proc created from Nera_On
# 240614 weiss adaptation according to structure from Nera_On
# 070714 serio wait until EEPROM is ready before returning
# 080415 weiss drive initialization directly checked at switch on
#END----------------------------------------------------------------
proc Beidou_On {DevNr {State 2} {timeout 10} {TTId ""}} {

    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActInterface
    global GLOB_LAST_DRIVE_REBOOT

    set TTId [Format_TTId $TTId]
    set GLOB_LAST_DRIVE_REBOOT [clock clicks -milliseconds]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	4 { TlPrint "Switch on Beidou Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after restart

    if { [ GetDevFeat "BusSys"] } {
	#Beidou ON
	wc_BeidouOnOff $DevNr "H"                 ;#Switch on device
	TlPrint "ActInterface: $ActInterface"

	doWaitForModState ">=0" $timeout $TTId    ;# wait for any modbus communication

	TlPrint "----------------------------"
	TlPrint "Initialization"
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30                ;#Wait that configuration is completely loaded
	TlPrint "----------------------------"

	switch -regexp $State {
	    {[<>=1-9]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		EtherCAT_WaitForSlaveState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }
    doWaitForEEPROMFinished 10 ;#wait for EEPROM to be ok before writing/storing parameters
    set ActDev $ActDevCurr
    return $ComOK

} ;# Beidou_On

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off Beidou device
#
#
# ----------HISTORY----------
# WANN   WER   WAS
# 140813 todet proc created from Nera_Off
# 240614 weiss adaptation according to structure from Nera_Off
# 300714 hmwang set DC discharge time from 3s to 5s
#END----------------------------------------------------------------
proc Beidou_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	4 { TlPrint "Switch off Beidou Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_BeidouOnOff $DevNr L
	wc_DCDischarge $DevNr
	if {[GetDevFeat "DCDischarge"]} {
	    doWaitForOff 5
	} else {
	    doWaitForOff 30
	}

	doWaitMs 2000
    } else {

	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr
} ;# Beidou_Off

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch on ATV310 device
#
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 090819 Alan proc created from Beidou_On
#END----------------------------------------------------------------
proc ATV310_On {DevNr {State 2} {timeout 10} {TTId ""}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev devnetconfig_FileName
    global MBAdr ActInterface

    set TTId [Format_TTId $TTId]

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 { TlPrint "Switch on ATV310 Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    set ActDevCurr $ActDev ;# necessary for doWaitForState
    set ActDev $DevNr
    set ComOK 1 ;# Marker if bus communication is yet available after restart

    if { [ GetDevFeat "BusSys"] } {
	#ATV310 ON
	wc_ATV310OnOff $DevNr "H"                 ;#Switch on device
	TlPrint "ActInterface: $ActInterface"
	doWaitForModState ">=0" $timeout $TTId    ;# wait for any modbus communication

	switch -regexp $State {
	    {[<>=1-9]} {
		set stateAct [doWaitForModState $State $timeout $TTId]
		if { ( $stateAct == 0) || ( $stateAct == "")} {
		    # Timeout
		    set ComOK 0
		}
	    }
	    default {
		TlError "Parameter State( $State ) not defined"
		return
	    }
	}

	switch -exact $ActInterface {
	    "ECAT" {
		EtherCAT_WaitForSlaveState "OP"
	    }
	    "EIP" {
		EIP_WaitForSlaveInterfaceState
	    }
	}

    } else {

	if {$HandMade} {
	    TlPrint "Switch device $DevNr manually"
	    TlInput "Continue with Return" "" 0
	} else {
	    #TlPrint " Wait for state $State"
	    doWaitForState $State $timeout
	}
    } ;# else handmade

    if {$ComOK != 1} {
	set ComOK [TryAllModbusFormats]
    }

    doWaitForEEPROMFinished 10 ;#wait for EEPROM to be ok before writing/storing parameters

    set ActDev $ActDevCurr
    puts "here"
    return $ComOK
} ;# Beidou_On

#DOC----------------------------------------------------------------
#DESCRIPTION
#
# Switch off ATV310 device
#
#
# ----------HISTORY----------
# WANN   WER   WAS
# WHEN   WHO   WHAT
# 090819 Alan proc created from Beidou_On
#END----------------------------------------------------------------
proc ATV310_Off {DevNr {NoInfo 0}} {
    global Protocol
    global theSerialPort prgNum
    global DevAdr glb_AccessExcl
    global theTestcaseID HandMade
    global ActDev ActInterface

    set ActDevCurr $ActDev
    set ActDev $DevNr
    set SwitchOffInterface $ActInterface

    TlPrint "----------------------------"
    switch -regexp $DevNr {
	1 { TlPrint "Switch off ATV310 Dev$DevNr" }
	default  {
	    TlError "Unexpected device No. $DevNr"
	    return
	}
    }
    TlPrint "----------------------------"

    if {$SwitchOffInterface != "MOD"} {
	#use Tl commands with MOD
	doSetCmdInterface "MOD"
    }

    if { [ GetDevFeat "BusSys"] } {
	wc_BeidouOnOff $DevNr L
	wc_DCDischarge $DevNr
	if {[GetDevFeat "DCDischarge"]} {
	    doWaitForOff 5
	} else {
	    doWaitForOff 30
	}

	doWaitMs 2000
    } else {

	doReset
    }

    if {$SwitchOffInterface != "MOD"} {
	doSetCmdInterface $SwitchOffInterface
    }

    set ActDev $ActDevCurr
} ;# Beidou_Off

# DOC----------------------------------------------------------------
# DESCRIPTION
#
# Read the configuration values for object under test
# from the ini file defined values
#
# ----------HISTORY----------
# WHEN   WHO   WHAT
# 250608 rothf  proc created
# 260614 serio  extend serial parameters to identification
# 220115 serio  extend lstAnaOffset
# 300115 serio  add LoadDev parameters
# 050315 serio  modify lstAnaOffset
# 120315 serio  add NET feature to lstFeatures
# 260315 serio  add MotorCableManip to lstFeatures
# 160415 serio  remove NET feature from lstFeatures
# 220715 serio  add lstTSP TSP_Data
# 201015 savry	add lstEncoderParam and encoderParameters global var to handle the different encoder resolutions amongst the towers
# 060723 savry  add feature modbusToggle. Ability of the tower to toggle from modbus bottom port to keypad port
# 300524 savry  add features BusProfisafe & BusCIPSafety & thirdPartyPLC
# 310524 savry  add system feature MotorSelection and device feature MotorIndex
# 120624 savry  add lstCIPSafetyComIndex and CIPSafetyComIndex to handle PLC memory address match for cipsafety 
# 170624 MLT    Delete MotorCableManip to lstFeatures
# 040724 ASY    Reassigned the MotParam global var. will now be used to store motor specific information such as pole pair numbers
# 150724 ASY    Added the SafetyConfiguration variable and its handling 
# 180924 ASY    Added the FortisLoad feature, to be used when a fortis drive is used as LoadMachine
# 181024 ASY    Added the configuration list for Load machines 
# 251024 Yahya  Added feature "BusPN_ATLAS" for profinet on ATLAS
# 131124 ASY    Added the ComPLC addresses handling 
# 211124 ASY    Added feature "SHANGHAI_APP_KY" for Kaiyuan project
# 211124 ASY    Added device type KAIYUAN
# 231224 KBO    Added feature "multipleCom"
# END----------------------------------------------------------------
proc ReadConfigValues {} {
    global theConfigIniFile theCfgDefaultIniFile theConfigXMLFile
    global MotParam MotACParam MotECParam MotSMParam MotASMParam DevID
    global ConfigBLE DevAdr DevAdr_Orig AnaOffset ADCOffset DevType DevOptBd
    global lstMotParam lstMotECParam lstMotSMParam lstMotASMParam lstBleFiles lstFieldbus lstEncoderParam
    global lstAnaOffset lstADCOffset lstDevSN lstDevType lstTSP TSP_Data
    global DigiOut_Offset DigiIn_Offset
    global Timer1Out_Offsett Timer1In_Offsett
    global Enc_In_Offset1 Enc_In_Offset2
    global Enc_Out_Offset1 Enc_Out_Offset2
    global Data_In_Offset Data_Out_Offset           ;# ! WARNING ! -> From the point of view of the Masters (PC)
    global Merker_Offset
    global PD_Mapping_In_Offset PD_Mapping_Out_Offset  ;# Offset for the Mapping of relais datas
    global Enc_Acc                                  ;# Encoder resolution (extern)
    global IncEncClamp_Resolution                   ;# Data size of the Incremental Encoder relais
    global Ana_Out_offset Ana_In_offset
    global StepperIn_Offset StepperOut_Offset
    global lstNERAindusVARS NERAindusVARS
    global cHANDMADE cSERIAL_PORT cSERIAL_BAUD cCAN_BAUD cPROTOCOL cFIELDBUS cErrCodeIni
    global lstFeatures SystemFeatureList DeviceFeatureList coCREATE_LOG coUSE_DB
    global LoadDev
    global SafetyConfiguration
    global ComPLC_Address lstComPLC
    # data to configure from the ini file related to =S= PLC
    global sePLC
    #data to configure the PLC addresses used for CIPSafety exchanges 
    global lstCIPSafetyComIndex CIPSafetyComIndex
    # array contaning the encoder parameters for each device
    global encoderParameters 				
    #list containing the load configuration parameters 
    global lstLoadParameters LoadParameters
	


    #Parameterlisten
    set lstDevID       [list "SN" "ModelName"]
    set lstDevType     [list "Altivar" "Nera" "Beidou" "Fortis" "Opal" "MVK" "ATS48P" "BASIC" "OPTIM" "K2" "K2_LHP" "K2_HHP" "KAIYUAN" ]
    set lstMotParam    [list "PolePairs"]
    #TAG
    #list of all the encoder parameters possible in ini files
    set lstEncoderParam [list "UECP"  "ENM" "ENRI" "ENS" "ENSP" "ENTR" "ENU" "PDI" "PGI" "REFQ" "RPPN" "SSCD" "SSCP" "SSFS" "TRES" "UECV" "UELC" "ABMF" ]
    set lstMotACParam  [list "MOTSERIAL"]
    set lstMotECParam  [list "MOTTYPE" "SENSTYPE"]
    set lstMotSMParam  [list "CTT" "NCRS" "CLI" "NSPS" "TQS" "PPNS" "TFR" "HSP" "AST" "SPG" "PHS" "LDS" "LQS" "SFR" "EN3" "EN4" "CRB" "CRDR"]
    set lstMotASMParam [list "NPR" "FRS" "UNS" "NCR" "NSP" "COS" "ITH" "CLI" "IDC" "SDC1" "SDC2" "CTT" "SFR" "RSA"]
    set lstBleFiles    [list "ble_DeviceName" "ble_Controller" "ble_Powerstage"]
    set lstBleFileESM  [list "ble_eSM" ]
    set lstBleFileMot  [list "ble_Motor" "ble_Motor2"]
    # set lstFieldbus    [list "MOD" "CAN" "SPB" "EthBasicTCP" "EthAdvTCP" "MASK" "GATE" "DVN" "Load" "ECAT" "PN"]
    set lstFieldbus    [list "MOD" "CAN" "SPB" "SPB_STD" "SPB_IO" "MODTCP" "MODTCPioScan" "BasicEthIP" "OptBrdIP" "MODTCP_OptionBoard" "EIP_OptionBoard" "AdvBrdIP" "MASK" "GATE" "EIP" "DVN" "Load" "ECAT" "PN" "PN_STD" "PN_IO" "EoE" "DefaultIPAddr" "DefaultIPAddr_emb"\
	"PNV2MAC,1" "PNV2MAC,2" "PNV2MAC,3" "PNV2MAC,4" "PNV2MAC,5" "PNV2MAC,6" "LoadIndex" "CIPSafetyIndex"
    ]

    set lstAnaOffset   [list "GU" "GV" "GW" "GVB" "OUP1" "GUP1" "OCP1" "GCP1" "OUP2" "GUP2" "OCP2" "GCP2" "OUP3" "GUP3" "OCP3" "GCP3" "O1OU" "O1GU" "O1OC" "O1GC" "O2OU" "O2GU" "O2OC" "O2GC" "OUN2" "GUN2"]
    set lstTSP         [list "1PT2I" "1PT3I" "KTYI" "PTCI" "1PT2M" "1PT3M" "KTYM" "3PT2M" "3PT3M" "1PT23M" "1PT33M" "3PT23M" "3PT33M"]
    set lstADCOffset   [list "IuOffset" "IvOffset" "SinCosGain" "SinOffset" "CosOffset" \
	"SinCosGain2" "SinOffset2" "CosOffset2" "Iu_usr_sc" "I_sc_uv"]
    set lstWagoPLC     [list "DigiIn_Offset" "DigiOut_Offset" "Ana_Out_offset" "Ana_In_offset" \
	"Enc_In_Offset1" "Enc_Out_Offset1" "Enc_In_Offset2" "Enc_Out_Offset2" "Data_In_Offset" \
	"Data_Out_Offset" "PD_Mapping_In_Offset" "PD_Mapping_Out_Offset" "Merker_Offset" \
	"Enc_Acc" "IncEncClamp_Resolution" "StepperIn_Offset" "StepperOut_Offset"]
	set lstSEPLC [list "structureSize" "AIConf_offset" "AQConf_offset" "AITension_offset" "AICurrent_offset" "AQTension_offset" "AQCurrent_offset" "DI_offset" "DO_offset" "mainPower_offset" "towerStructureOffset" "AQTensionConf_offset" "AQCurrentConf_offset" "CANOPEN_PDORead_Offset" "CANOPEN_PDOWrite_Offset" "towerAuto" "LoadOffset" "DownstreamPhaseLossOffset" "UpstreamPhaseLossOffset" "CableDisconnectionOffset" "MotorSelection" "SwitchPowerSupply" "PLCPowerSupply" "PLCSelectorInput" "ResetIO_offset" ]
    set lstTTCfg       [list "cHANDMADE" "cSERIAL_PORT" "cSERIAL_BAUD" "cCAN_BAUD" "cPROTOCOL" \
	"cFIELDBUS" "cErrCodeIni" "coCREATE_LOG" "coUSE_DB"]
    set lstDevType     [list "Type" "Rate" "Supply" "MotorIndex"]
    set lstDevOptBd    [list "OptBd1" "OptBd2" "OptBd3"]

    set lstFeatures [list "Kala" "Fortis" "Nera" "Nera_200V" "Opal" "Beidou" "MVK" "ATV320" "K2" "K2_LHP" "K2_HHP" "KAIYUAN" \
	"Altivar" "PACY_COM_DEVICENET" "PACY_COM_PROFIBUS" "PACY_APP_OPAL" "PACY_COM_PROFINET" "MVKTower1" "MVKTower2" "Jenkins" \
	"PACY_COM_ETHERCAT" "PACY_COM_CANOPEN" "PACY_APP_NERA" "DevAll" "DevNone" "MotAC" "FortisHW" "EAE" "EAETower1" "AdaptationBoard" "ATS48P" "BASIC" "OPTIM" \
	"MotASM" "MotSM" "BusCAN" "BusDevNet" "BusPBdev" "BusPB_ATLAS" "BusPN_ATLAS" "BusPN" "BusECAT" "cybersecurity" "ShadowOffer" \
	"BusMBTCP" "BusMBTCPioScan" "BusEIP" "BusSys" "Modul_IO" "Modul_Relais" \
	"Modul_IO_D" "Modul_IO_S" "Modul_IO_R" "Modul_Relais_D" "Card_EthBasic" \
	"Modul_SM1" "Board_EthAdvanced" "Board_Profinet" "DCDischarge" \
	"PACY_SFTY_FORTIS" "PACY_APP_FORTIS" "PACY_SFTY_OPAL" "ModiconPLC" "NoComOption" "Load" \
	"Card_AdvEmbedded" "SimuMode" "AdaptationBoard" \
	"PACY_COM_PROFINET2" "Gen2Tower" "BusPNV2"\
	"COPLA40_NORM_FW_SPI" "COPLA40_CMPT_FW_SPI" "PACY_ATLAS_ETHERNET" "PACY_ATLAS_PROFINET" "PACY_ATLAS_CANOPEN" "PACY_ATLAS_PROFIBUS" "ATLAS"\
	"FW_CIPSFTY" "FW_ATVPredict" "modbusToggle" "DevDesk" "EAE_Slave" "SHANGHAI_APP_K2" "PACY_APP_FLEX" "PACY_APP_K2" "PACY_SFTY_FIELDBUS" "PACY_ATLAS_CI"\
    "BusProfisafe" "BusCIPSafety" "thirdPartyPLC" "MotorSelection" "INDIA_APP_ATV320"\
    "PACY_K2_BACNET" "PACY_K2_ETHERNET" "PACY_K2_PROFINET" "FortisLoad" "SHANGHAI_APP_KY" "Robustness" "multipleCom"]


    set lstLoadDevParam [list "SN" "KPN" "TNN" "KPP" "TAUNREF" "CURRFOL" "KFPP" "NOTCH1D" "NOTCH1F" "NOTCH1BW" "NOTCH2D" "NOTCH2F" "NOTCH2BW" "SPEEDOSUPDAMP" "SPEEDOSUPDLAY" "KFRIC" "SinCosGain" "SinOffset" "CosOffset" "SinCosGain2" "SinOffset2" "CosOffset2" "IuOffset" "IvOffset" "Iu_usr_sc" "I_sc_uv" "Ana1Offset" "Ana2Offset" "Ana1Gain" "Ana2Gain"]


    set lstCIPSafetyComIndex [list "ie_InOffset" "ie_OutOffset" "write_CtrlIn" "write_CtrlOut" "write_STO" "read_RestartRequired" "read_SafetyFault" "read_TorqueDisabled" "write_ResetFault" "read_Health" "DeviceMemoryLength" "DeviceStartOffset" "CIPSafetyPLC_address" "CIPSafetyPLC_openConnection" "read_CtrlIn" "read_CtrlOut" "read_SafetyStatus" ]
	
    set lstSafetyConfiguration [list "encoderType" "encoderResolution" "encoderInversion"]

    set lstLoadParameters [list "Load_BFR" "Load_NPR" "Load_UNS" "Load_NCR" "Load_FRS" "Load_NSP" ]

    set lstComPLC [list "EIP" "PNT"]

    if { [catch {set filehandle [ini::open $theConfigIniFile "r"]} fid] } {
	puts "Could not open $theConfigIniFile for writing\n$fid"

	if { [catch {set filehandle [ini::open $theCfgDefaultIniFile "r"]} fid] } {
	    puts "Could not open $theConfigIniFile for writing\n$fid"
	    puts " ATTENTIONErr: Please contact either your admin or check out the config_default.ini file"
	    exit 1
	} else {
	    puts " \nATTENTIONInfo: Interpreter has started with default config file. Restrictions:"
	    puts " - The Interpreter is restricted for 2 Devices "
	    puts " - Communication establishment is not guaranteed \n"
	}
    }

    #Check how many devices are defined in the ini file
    set lstDevices [ini::sections $filehandle]

    #Read Parameter for each device
    foreach device $lstDevices {
	#Check DeviceNr from the section
	set DevNr [string trim $device "Device"]

	# Identification Device
	foreach parameter $lstDevID {
	    if {[ini::exists $filehandle $device $parameter]} {
		set DevID($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	# Device Type
	foreach parameter $lstDevType {
	    if {[ini::exists $filehandle $device $parameter]} {
		set DevType($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	# Controller parameter (general)
	foreach parameter $lstMotParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set MotParam($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	# Value ADC_Offset
	foreach parameter $lstADCOffset {
	    if {[ini::exists $filehandle $device $parameter]} {
		set ADCOffset($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Encoder parameters
	foreach parameter $lstEncoderParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set encoderParameters($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Motor parameter AC-Motors
	foreach parameter $lstMotACParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set MotACParam($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Motor parameter EC-Motors
	foreach parameter $lstMotECParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set MotECParam($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Motor parameter SM-Motors
	foreach parameter $lstMotSMParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set MotSMParam($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Motorparameter ASM-Motors
	foreach parameter $lstMotASMParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set MotASMParam($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#ble-Files
	foreach parameter $lstBleFiles {
	    if {[ini::exists $filehandle $device $parameter]} {
		set ConfigBLE($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}

	#ble-File eSM
	foreach parameter $lstBleFileESM {
	    if {[ini::exists $filehandle $device $parameter]} {
		set ConfigBLE($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}

	#ble-File secondEncoder
	foreach parameter $lstBleFileMot {
	    if {[ini::exists $filehandle $device $parameter]} {
		set ConfigBLE($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}

	#fieldbus-addresses
	foreach parameter $lstFieldbus {
	    if {[ini::exists $filehandle $device $parameter]} {
		set DevAdr($DevNr,$parameter) [ini::value $filehandle $device $parameter]
		set DevAdr_Orig($DevNr,$parameter) $DevAdr($DevNr,$parameter)
	    }
	}
	#Analogue offsets
	foreach parameter $lstAnaOffset {
	    if {[ini::exists $filehandle $device $parameter]} {
		set AnaOffset($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}
	#Device types
	foreach parameter $lstDevType {
	    if {[ini::exists $filehandle $device $parameter]} {
		set DevType($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    } else {
		set DevType($DevNr,$parameter) "UNKNOWN"
	    }
	}
	#Option board card type
	foreach parameter $lstDevOptBd {
	    if {[ini::exists $filehandle $device $parameter]} {
		set DevOptBd($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    } else {
		set DevOptBd($DevNr,$parameter) "NO"
	    }
	}

	#Load Device Parameters

	foreach parameter $lstLoadDevParam {
	    if {[ini::exists $filehandle $device $parameter]} {
		set LoadDev($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    } else {
		set LoadDev($DevNr,$parameter) "NO"
	    }
	}

	#Thermal sensor protection datas for analog inputs
	foreach parameter $lstTSP {
	    if {[ini::exists $filehandle $device $parameter]} {
		set TSP_Data($DevNr,$parameter) [ini::value $filehandle $device $parameter]
	    }
	}

	#SAFETY_CONFIGURATION
	foreach parameter $lstSafetyConfiguration {
		if {[ini::exists $filehandle $device $parameter]} {
			set SafetyConfiguration($DevNr,$parameter) [ini::value $filehandle $device $parameter]
		}
	}

    } ;#foreach device

    #Wago PLC system configuration
    foreach parameter $lstWagoPLC {
	if {[ini::exists $filehandle "WagoPLC" $parameter]} {
	    set [subst $parameter] [ini::value $filehandle "WagoPLC" $parameter]
	}
    }

    #SE PLC system configuration
    foreach parameter $lstSEPLC {
	if {[ini::exists $filehandle "SE_PLC" $parameter]} {
	    #	    set [subst $parameter] [ini::value $filehandle "SE_PLC" $parameter]
	    set sePLC($parameter) [ini::value $filehandle "SE_PLC" $parameter]
	}
    }
    #CIPSafety with SE PLC index configuration
    foreach parameter $lstCIPSafetyComIndex {
	if {[ini::exists $filehandle "CIPSAFETY_COMINDEX" $parameter]} {
	    set CIPSafetyComIndex($parameter) [ini::value $filehandle "CIPSAFETY_COMINDEX" $parameter]
	}
    }
    #List of load Parameters 
	foreach parameter $lstLoadParameters {
		if {[ini::exists $filehandle $device $parameter]} {
			set LoadParameters($DevNr,$parameter) [ini::value $filehandle $device $parameter]
		}
	}
    #TestTower common configuration
    foreach parameter $lstTTCfg {
	if {[ini::exists $filehandle "TTCfg" $parameter]} {
	    set RdOut [ini::value $filehandle "TTCfg" $parameter]
	    set $parameter [ini::value $filehandle "TTCfg" $parameter]
	}
    }
	
    #COM PLC address configuration
    foreach parameter $lstComPLC {
        if {[ini::exists $filehandle "COMPLC" $parameter]} {
    	set ComPLC_Address($parameter) [ini::value $filehandle "COMPLC" $parameter]
        }
    }
    # Device and System Features
    if {[info exists DeviceFeatureList]} {unset DeviceFeatureList}
    set SystemFeatureList {}
    foreach section $lstDevices {
	# search for FeatureList sections inside the ini file
	if {[string first "Features" $section] == 0} {
	    if {[string first "Sys" $section] > 0} {
		foreach IniKey [ini::keys $filehandle $section] {
		    if {[ini::value $filehandle $section $IniKey] != 0} {
			lappend SystemFeatureList $IniKey
		    }
		}
	    }
	    if {[string first "Dev" $section] > 0} {
		set DevNumber [string range $section 11 end]
		foreach IniKey [ini::keys $filehandle $section] {
		    if {[ini::value $filehandle $section $IniKey] != 0} {
			lappend DeviceFeatureList($DevNumber) $IniKey
		    }
		}
	    }
	}
    }

    ini::close $filehandle

    #   #for Debugging
    #   foreach index [array names MotParam] {
    #      TlPrint "$index: $MotParam($index)"
    #   }
    #   foreach index [array names MotECParam] {
    #      TlPrint "$index: $MotECParam($index)"
    #   }
    #   foreach index [array names MotSMParam] {
    #      TlPrint "$index: $MotSMParam($index)"
    #   }
    #   foreach index [array names MotASMParam] {
    #      TlPrint "$index: $MotASMParam($index)"
    #   }
    #   foreach index [array names ConfigBLE] {
    #      TlPrint "$index: $ConfigBLE($index)"
    #   }
    #   foreach index [array names DevAdr] {
    #      TlPrint "$index: $DevAdr($index)"
    #   }
    #   foreach index [array names AnaOffset] {
    #      TlPrint "$index: $AnaOffset($index)"
    #   }

    #      foreach index [array names ADCOffset] { TlPrint "$index: $ADCOffset($index)" }
global ActDevConf
 if {[info exist ActDevConf]} {
 updateActDevValues
 }
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc ImportMVKRef {} {

    global mainpath
    global  MVK_Ref_Table MVK_PIMV_Table MVK_PIMC_Table MVK_PITP_Table MVK_POCT_Table MVK_POCV_Table MVK_POCC_Table
    global  MVK_POCN_Table MVK_VCAL_Table MVK_NCV_Table MVK_PRT_Table MVK_PRT2_Table MVK_PRT3_Table MVK_INV_Table
    global MVK_CLI_Table MVK_CLIMax_Table MVK_IDCMax_Table MVK_Num_Table

    #Package to use Excel
    package require tcom

    set i 0
    # Set the path to your excel file.
    set excelFilePath "$mainpath/ObjektDB/KalaPlatform_Soft_IntHwSwMcMvk.xlsx"

    #create a link to excel application
    set excelApp [::tcom::ref createobject Excel.Application]
    set workbooks [$excelApp Workbooks]

    # open the Interface HW SW workbooks
    set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
    set worksheets [$workbook Worksheets]

    #Sheets("NCV_Vs_Transfo").select
    set worksheet [$worksheets Item [expr 4]]

    #Check the name of selected worksheet
    if { [$worksheet Name]=="NCV_Vs_Transfo" } {

	set cells [$worksheet Cells]
	set loopCpt 0
	set Row_list {4 3 3 3 3 3 3 3 3 3 26}
	#    set Column_list {CX DP EH EZ FR GJ HB HT HT}
	set Column_list {126 144 162 180 198 216 234 252 270 288 288}

	foreach Column $Column_list {

	    # Read all the values in column CX
	    set rowCount [lindex $Row_list $loopCpt]

	    set columnCount $Column
	    set end 0
	    while { $end == 0 } {
		set celluleValue [[$cells Item $rowCount [ expr $columnCount]] Value]
		if { $celluleValue == ""} {
		    set end 1
		    continue
		}
		set BasicRef  $celluleValue
		set PIMV   [Enum_Value "PIMV" [[$cells Item $rowCount [expr $columnCount+1]] Value]]
		set PIMC   [Enum_Value "PIMC" [format "%04u" [expr round([[$cells Item $rowCount [expr $columnCount+2]] Value])]]]
		set PITP   [expr round ([[$cells Item $rowCount [expr $columnCount+3]] Value] )]
		set POCT   [expr round ([[$cells Item $rowCount [expr $columnCount+4]] Value] )]
		set POCV   [Enum_Value "POCV" [[$cells Item $rowCount [expr $columnCount+5]] Value]]
		set POCC   [Enum_Value "POCC" [format "%04u" [expr round ([[$cells Item $rowCount [expr $columnCount+6]] Value] )]]]
		set POCN   [expr round ([[$cells Item $rowCount [expr $columnCount+7]] Value] )]
		set VCAL   [Enum_Value "VCAL" [[$cells Item $rowCount [expr $columnCount+8]] Value]]
		set NCV    [Enum_Value "NCV" [[$cells Item $rowCount [expr $columnCount+9]] Value]]
		set PRT    [expr round ([[$cells Item $rowCount [expr $columnCount+10]] Value] )]
		set PRT2   [expr round ([[$cells Item $rowCount [expr $columnCount+11]] Value] )]
		set PRT3   [expr round ([[$cells Item $rowCount [expr $columnCount+12]] Value] )]
		set INV    [expr round ([[$cells Item $rowCount [expr $columnCount+13]] Value] )]
		set CLI    [expr round ([[$cells Item $rowCount [expr $columnCount+14]] Value] )]
		set CLIMax [expr round ([[$cells Item $rowCount [expr $columnCount+15]] Value] )]
		set IDCMax [expr round ([[$cells Item $rowCount [expr $columnCount+16]] Value] )]

		# TlPrint "$BasicRef |$PIMV | $PIMC | $PITP |$POCT |$POCV"

		set MVK_Ref_Table($i) $BasicRef
		set MVK_Num_Table($BasicRef) $i
		set MVK_PIMV_Table($BasicRef) $PIMV
		set MVK_PIMC_Table($BasicRef) $PIMC
		set MVK_PITP_Table($BasicRef) $PITP
		set MVK_POCT_Table($BasicRef) $POCT
		set MVK_POCV_Table($BasicRef) $POCV
		set MVK_POCC_Table($BasicRef) $POCC
		set MVK_POCN_Table($BasicRef) $POCN
		set MVK_VCAL_Table($BasicRef) $VCAL
		set MVK_NCV_Table($BasicRef) $NCV
		set MVK_PRT_Table($BasicRef) $PRT
		set MVK_PRT2_Table($BasicRef) $PRT2
		set MVK_PRT3_Table($BasicRef) $PRT3
		set MVK_INV_Table($BasicRef) $INV
		set MVK_CLI_Table($BasicRef) $CLI
		set MVK_CLIMax_Table($BasicRef) $CLIMax
		set MVK_IDCMax_Table($BasicRef) $IDCMax

		incr rowCount
		incr i
	    }
	    incr loopCpt
	}
    }
    $workbook Close 0
    $excelApp Quit
};#ExportMVKRef

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PITP {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PITP_Table
    set rc [catch { set retVal $MVK_PITP_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PITP_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PRT2 {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PRT2_Table
    set rc [catch { set retVal $MVK_PRT2_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PRT2_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PRT3 {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PRT2_Table
    set rc [catch { set retVal $MVK_PRT2_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PRT2_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PIMC {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PIMC_Table
    set rc [catch { set retVal $MVK_PIMC_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PIMC_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PIMV {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PIMV_Table
    set rc [catch { set retVal $MVK_PIMV_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PIMV_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_VCAL {MVK_Ref {NoErrorPrint 0}} {
    global MVK_VCAL_Table
    set rc [catch { set retVal $MVK_VCAL_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_VCAL_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_POCT {MVK_Ref {NoErrorPrint 0}} {
    global MVK_POCT_Table
    set rc [catch { set retVal $MVK_POCT_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_POCT_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_PRT {MVK_Ref {NoErrorPrint 0}} {
    global MVK_PRT_Table
    set rc [catch { set retVal $MVK_PRT_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_PRT_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_POCV {MVK_Ref {NoErrorPrint 0}} {
    global MVK_POCV_Table
    set rc [catch { set retVal $MVK_POCV_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_POCV_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_NPR {MVK_Ref {NoErrorPrint 0}} {
    global MVK_NPR_Table
    set rc [catch { set retVal $MVK_NPR_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_NPR_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_POCC {MVK_Ref {NoErrorPrint 0}} {
    global MVK_POCC_Table
    set rc [catch { set retVal $MVK_POCC_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_POCC_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_POCN {MVK_Ref {NoErrorPrint 0}} {
    global MVK_POCN_Table
    set rc [catch { set retVal $MVK_POCN_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_POCN_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_NCV {MVK_Ref {NoErrorPrint 0}} {
    global MVK_NCV_Table
    set rc [catch { set retVal $MVK_NCV_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_NCV_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_INV {MVK_Ref {NoErrorPrint 0}} {
    global MVK_INV_Table
    set rc [catch { set retVal $MVK_INV_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_INV_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_CLI {MVK_Ref {NoErrorPrint 0}} {
    global MVK_CLI_Table
    set rc [catch { set retVal $MVK_CLI_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_CLI_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_CLIMax {MVK_Ref {NoErrorPrint 0}} {
    global MVK_CLIMax_Table
    set rc [catch { set retVal $MVK_CLIMax_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_CLIMax_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_IDCMax {MVK_Ref {NoErrorPrint 0}} {
    global MVK_IDCMax_Table
    set rc [catch { set retVal $MVK_IDCMax_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVK_IDCMax_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_ref {MVK_Ref {NoErrorPrint 0}} {
    global MVK_Ref_Table
    set rc [catch { set retVal $MVK_Ref_Table($MVK_Ref) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$MVK_Ref not existing in MVKRefTable"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from KalaPlatform_Soft_IntHwSwMcMvk.xls file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------

proc Find_MVK_num {num {NoErrorPrint 0}} {
    global MVK_Num_Table
    set rc [catch { set retVal $MVK_Num_Table($num) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "$num not existing in MVK_Num_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc ReadXlsDefaultMotorValue {} {

    global mainpath MVK_BFR_Table MVK_NPR_Table MVK_UNS_Table MVK_FRS_Table MVK_NSP_Table MVK_NCR_Table MVK_COS_Table MVK_RSA_Table MVK_LFA_Table MVK_IDA_Table MVK_TRA_Table MVK_L0A_Table MVK_LA_Table MVK_INRC_Table MVK_INRP_Table MVK_INRR_Table MVK_INRL_Table MVK_INRT_Table MVK_INTI_Table MVK_TQS_Table MVK_PPNS_Table MVK_NSPS_Table MVK_NCRS_Table MVK_RSAS_Table MVK_LDS_Table MVK_LQS_Table MVK_PHS_Table

    #Package to use Excel
    package require tcom

    # Set the path to your excel file.
    set excelFilePath "$mainpath/ObjektDB/Desp_SoftMc_MotParam.xlsx"

    #create a link to excel application
    set excelApp [::tcom::ref createobject Excel.Application]
    $excelApp Visible
    set workbooks [$excelApp Workbooks]

    # open the Interface HW SW workbooks
    set workbook [$workbooks Open [file nativename [file join [pwd] $excelFilePath] ] ]
    set worksheets [$workbook Worksheets]

    #Sheets("DESPAsyn").select
    set worksheet [$worksheets Item [expr 8]]
    # TlPrint "[$worksheet Name]"
    #Check the name of selected worksheet
    if { [$worksheet Name]=="DESPAsyn" } {

	set cells [$worksheet Cells]
	set loopCpt 0
	#set Column_list { D E F G H I J K L M N O P Q R S T U V W X Y  AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EC ED EE EF EG EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ FA FB FC FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FT FU FV FW FX FY FZ GA GB GC GD GE GF GG GH GI GJ GK GL GM GN GO GP GQ GR GS GT GW GX GY GZ HA HB HC HD HE HF HG HH HI HJ HK HL HM HN HO HP HQ HR HS HT HU HV HW HX HY HZ }
	set Column_list { DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EE EF EG EH EI EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ FA FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FR FS FT FU FV FW FX FY FZ GA GB GC GF GG GH GI GJ GK GL GM GN GO GP GQ GR GS GT GU GV GW GX GY GZ HA HB HC HD HE HF HI HJ HK HL HM HN HO HP HQ HR HS HT HU HV HW HX HY HZ IA IB IC ID IE IF IG IH II IL IM IN IO IP IQ IR IS IT IU IV IW IX IY IZ JA JB JC JD JE JF JG JH JI JJ JK JL JM JP JQ JR JS JT JU JV JW JX JY JZ KA KB KC KD KE KF KG KH KI KJ KK KL KM KN KO KP KQ KT KU KV KW KX KY KZ LA LB LC LD LE LF LG LH LI LJ LK LL LM LN LO LP LQ LR LS LT LU LV LW LX LY LZ MA MD ME MF MG MH MI MJ MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NB NC ND NG NH NI NJ NK NL NM NN NO NP NQ NR NS NT NU NV NW NX NY NZ OA OB OC OD OE OF OG OH OI OJ}
	foreach Column $Column_list {
	    # Read all the values in column CX
	    set rowCount 2
	    set columnCount $Column
	    #	    set NCV  [Enum_Value "NCV" [[$cells Item [expr $rowCount] $columnCount] Value]]
	    #	    set VCAL [Enum_Value "VCAL" [[$cells Item [expr ($rowCount+1)] $columnCount] Value]]
	    set COS [expr round ([[$cells Item [expr ($rowCount+12)] $columnCount] Value] )]
	    set NPR [expr round ([[$cells Item [expr ($rowCount+30)] $columnCount] Value] )]
	    set UNS [expr round ([[$cells Item [expr ($rowCount+31)] $columnCount] Value] )]
	    set FRS [expr round ([[$cells Item [expr ($rowCount+32)]  $columnCount] Value] )]
	    set NSP [expr round ([[$cells Item [expr ($rowCount+33)] $columnCount] Value] )]
	    set NCR [expr round ([[$cells Item [expr ($rowCount+34)] $columnCount] Value] )]
	    set RSA [expr round ([[$cells Item [expr ($rowCount+35)] $columnCount] Value] )]
	    set LFA [expr round ([[$cells Item [expr ($rowCount+36)] $columnCount] Value] )]
	    set IDA [expr round ([[$cells Item [expr ($rowCount+37)] $columnCount] Value] )]
	    set TRA [expr round ([[$cells Item [expr ($rowCount+38)] $columnCount] Value] )]
	    set L0A [expr round ([[$cells Item [expr ($rowCount+39)] $columnCount] Value] )]
	    set LA [expr round ([[$cells Item [expr ($rowCount+40)] $columnCount] Value] )]
	    set BFR 50
	    #      	    TlPrint "[Find_MVK_ref $loopCpt] | $COS | $NPR "

	    set MVK_BFR_Table([Find_MVK_ref $loopCpt]) $BFR
	    set MVK_NPR_Table([Find_MVK_ref $loopCpt]) $NPR
	    set MVK_UNS_Table([Find_MVK_ref $loopCpt]) $UNS
	    set MVK_FRS_Table([Find_MVK_ref $loopCpt]) $FRS
	    set MVK_NSP_Table([Find_MVK_ref $loopCpt]) $NSP
	    set MVK_NCR_Table([Find_MVK_ref $loopCpt]) $NCR
	    set MVK_COS_Table([Find_MVK_ref $loopCpt]) $COS
	    set MVK_RSA_Table([Find_MVK_ref $loopCpt]) $RSA
	    set MVK_LFA_Table([Find_MVK_ref $loopCpt]) $LFA
	    set MVK_IDA_Table([Find_MVK_ref $loopCpt]) $IDA
	    set MVK_TRA_Table([Find_MVK_ref $loopCpt]) $TRA
	    set MVK_L0A_Table([Find_MVK_ref $loopCpt]) $L0A
	    set MVK_LA_Table([Find_MVK_ref $loopCpt]) $LA

	    #TlPrint "$loopCpt | [Find_MVK_ref $loopCpt] |$NCV | $VCAL | $INV "
	    incr loopCpt
	}
    }
    #Sheets("DESPSyn").select
    set worksheet [$worksheets Item [expr 11]]
    # TlPrint "[$worksheet Name]"
    #Check the name of selected worksheet
    if { [$worksheet Name]=="DESPSyn" } {

	set cells [$worksheet Cells]
	set loopCpt 0
	#set Column_list { D E F G H I J K L M N O P Q R S T U V W X Y  AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EC ED EE EF EG EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ FA FB FC FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FT FU FV FW FX FY FZ GA GB GC GD GE GF GG GH GI GJ GK GL GM GN GO GP GQ GR GS GT GW GX GY GZ HA HB HC HD HE HF HG HH HI HJ HK HL HM HN HO HP HQ HR HS HT HU HV HW HX HY HZ }
	set Column_list { DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EE EF EG EH EI EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ FA FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FR FS FT FU FV FW FX FY FZ GA GB GC GF GG GH GI GJ GK GL GM GN GO GP GQ GR GS GT GU GV GW GX GY GZ HA HB HC HD HE HF HI HJ HK HL HM HN HO HP HQ HR HS HT HU HV HW HX HY HZ IA IB IC ID IE IF IG IH II IL IM IN IO IP IQ IR IS IT IU IV IW IX IY IZ JA JB JC JD JE JF JG JH JI JJ JK JL JM JP JQ JR JS JT JU JV JW JX JY JZ KA KB KC KD KE KF KG KH KI KJ KK KL KM KN KO KP KQ KT KU KV KW KX KY KZ LA LB LC LD LE LF LG LH LI LJ LK LL LM LN LO LP LQ LR LS LT LU LV LW LX LY LZ MA MD ME MF MG MH MI MJ MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NB NC ND NG NH NI NJ NK NL NM NN NO NP NQ NR NS NT NU NV NW NX NY NZ OA OB OC OD OE OF OG OH OI OJ}
	foreach Column $Column_list {
	    # Read all the values in column CX
	    set rowCount 2
	    set columnCount $Column
	    #      set NCV  [Enum_Value "NCV" [[$cells Item [expr $rowCount] $columnCount] Value]]
	    #      set VCAL [Enum_Value "VCAL" [[$cells Item [expr ($rowCount+1)] $columnCount] Value]]
	    set INRC [expr round ([[$cells Item [expr ($rowCount+21)] $columnCount] Value] )]
	    set INRP [expr round ([[$cells Item [expr ($rowCount+22)] $columnCount] Value] )]
	    set INRR [expr round ([[$cells Item [expr ($rowCount+25)] $columnCount] Value] )]
	    set INRL [expr round ([[$cells Item [expr ($rowCount+24)]  $columnCount] Value] )]
	    set INRT [expr round ([[$cells Item [expr ($rowCount+23)] $columnCount] Value] )]
	    set INTI [expr round ([[$cells Item [expr ($rowCount+26)] $columnCount] Value] )]
	    set TQS [expr round ([[$cells Item [expr ($rowCount+28)] $columnCount] Value] )]
	    set PPNS [expr round ([[$cells Item [expr ($rowCount+29)] $columnCount] Value] )]
	    set NSPS [expr round ([[$cells Item [expr ($rowCount+30)] $columnCount] Value] )]
	    set NCRS [expr round ([[$cells Item [expr ($rowCount+31)] $columnCount] Value] )]
	    set RSAS [expr round ([[$cells Item [expr ($rowCount+32)] $columnCount] Value] )]
	    set LDS [expr round ([[$cells Item [expr ($rowCount+33)] $columnCount] Value] )]
	    set LQS [expr round ([[$cells Item [expr ($rowCount+34)] $columnCount] Value] )]
	    set PHS [expr round ([[$cells Item [expr ($rowCount+35)] $columnCount] Value] )]

	    #            TlPrint "[Find_MVK_ref $loopCpt] | $COS | $NPR "

	    set MVK_INRC_Table([Find_MVK_ref $loopCpt]) $INRC
	    set MVK_INRP_Table([Find_MVK_ref $loopCpt]) $INRP
	    set MVK_INRR_Table([Find_MVK_ref $loopCpt]) $INRR
	    set MVK_INRL_Table([Find_MVK_ref $loopCpt]) $INRL
	    set MVK_INRT_Table([Find_MVK_ref $loopCpt]) $INRT
	    set MVK_INTI_Table([Find_MVK_ref $loopCpt]) $INTI
	    set MVK_TQS_Table([Find_MVK_ref $loopCpt]) $TQS
	    set MVK_PPNS_Table([Find_MVK_ref $loopCpt]) $PPNS
	    set MVK_NSPS_Table([Find_MVK_ref $loopCpt]) $NSPS
	    set MVK_NCRS_Table([Find_MVK_ref $loopCpt]) $NCRS
	    set MVK_RSAS_Table([Find_MVK_ref $loopCpt]) $RSAS
	    set MVK_LDS_Table([Find_MVK_ref $loopCpt]) $LDS
	    set MVK_LQS_Table([Find_MVK_ref $loopCpt]) $LQS
	    set MVK_PHS_Table([Find_MVK_ref $loopCpt]) $PHS

	    #TlPrint "$loopCpt | [Find_MVK_ref $loopCpt] |$NCV | $VCAL | $INV "
	    incr loopCpt
	}
    }

    $workbook Save
    $workbook Close
    $excelApp Quit
};#ReadXlsDefaultMotorValue

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_BFR {MVKRef {NoErrorPrint 0}} {
    global MVK_BFR_Table
    set rc [catch { set retVal $MVK_BFR_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_BFR_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_RSA {MVKRef {NoErrorPrint 0}} {
    global MVK_RSA_Table
    set rc [catch { set retVal $MVK_RSA_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_RSA_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_LFA {MVKRef {NoErrorPrint 0}} {
    global MVK_LFA_Table
    set rc [catch { set retVal $MVK_LFA_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_LFA_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_IDA {MVKRef {NoErrorPrint 0}} {
    global MVK_IDA_Table
    set rc [catch { set retVal $MVK_IDA_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_IDA_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_TRA {MVKRef {NoErrorPrint 0}} {
    global MVK_TRA_Table
    set rc [catch { set retVal $MVK_TRA_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_TRA_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_L0A {MVKRef {NoErrorPrint 0}} {
    global MVK_L0A_Table
    set rc [catch { set retVal $MVK_L0A_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_L0A_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_LA {MVKRef {NoErrorPrint 0}} {
    global MVK_LA_Table
    set rc [catch { set retVal $MVK_LA_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_LA_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_UNS {MVKRef {NoErrorPrint 0}} {
    global MVK_UNS_Table
    set rc [catch { set retVal $MVK_UNS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_UNS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_FRS {MVKRef {NoErrorPrint 0}} {
    global MVK_FRS_Table
    set rc [catch { set retVal $MVK_FRS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_FRS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_NSP {MVKRef {NoErrorPrint 0}} {
    global MVK_NSP_Table
    set rc [catch { set retVal $MVK_NSP_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_NSP_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_NCR {MVKRef {NoErrorPrint 0}} {
    global MVK_NCR_Table
    set rc [catch { set retVal $MVK_NCR_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_NCR_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO   	WHAT
# 210217 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_COS {MVKRef {NoErrorPrint 0}} {
    global MVK_COS_Table
    set rc [catch { set retVal $MVK_COS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_COS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INRC {MVKRef {NoErrorPrint 0}} {
    global MVK_INRC_Table
    set rc [catch { set retVal $MVK_INRC_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INRC_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INRP {MVKRef {NoErrorPrint 0}} {
    global MVK_INRP_Table
    set rc [catch { set retVal $MVK_INRP_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INRP_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INRR {MVKRef {NoErrorPrint 0}} {
    global MVK_INRR_Table
    set rc [catch { set retVal $MVK_INRR_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INRR_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INRL {MVKRef {NoErrorPrint 0}} {
    global MVK_INRL_Table
    set rc [catch { set retVal $MVK_INRL_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INRL_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INRT {MVKRef {NoErrorPrint 0}} {
    global MVK_INRT_Table
    set rc [catch { set retVal $MVK_INRT_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INRT_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_INTI {MVKRef {NoErrorPrint 0}} {
    global MVK_INTI_Table
    set rc [catch { set retVal $MVK_INTI_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_INTI_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_TQS {MVKRef {NoErrorPrint 0}} {
    global MVK_TQS_Table
    set rc [catch { set retVal $MVK_TQS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_TQS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_PPNS {MVKRef {NoErrorPrint 0}} {
    global MVK_PPNS_Table
    set rc [catch { set retVal $MVK_PPNS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_PPNS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_NSPS {MVKRef {NoErrorPrint 0}} {
    global MVK_NSPS_Table
    set rc [catch { set retVal $MVK_NSPS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_NSPS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_NCRS {MVKRef {NoErrorPrint 0}} {
    global MVK_NCRS_Table
    set rc [catch { set retVal $MVK_NCRS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_NCRS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_RSAS {MVKRef {NoErrorPrint 0}} {
    global MVK_RSAS_Table
    set rc [catch { set retVal $MVK_RSAS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_RSAS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_LDS {MVKRef {NoErrorPrint 0}} {
    global MVK_LDS_Table
    set rc [catch { set retVal $MVK_LDS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_LDS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_LQS {MVKRef {NoErrorPrint 0}} {
    global MVK_LQS_Table
    set rc [catch { set retVal $MVK_LQS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_LQS_Table"
	return 0
    }
    return $retVal
}

#DOC------------------------------------------------------------------------------------------------
#DESCRIPTION
#
# Extract Data from Desp_SoftMc_MotParam.xlsx file
#
# ----------HISTORY----------
# WHEN   WHO      WHAT
# 290518 cordc    proc creation
#END------------------------------------------------------------------------------------------------
proc Find_MVK_PHS {MVKRef {NoErrorPrint 0}} {
    global MVK_PHS_Table
    set rc [catch { set retVal $MVK_PHS_Table($MVKRef) }]
    if {(!$NoErrorPrint)&& ($rc != 0)} {
	TlError "data not existing in MVK_PHS_Table"
	return 0
    }
    return $retVal
}

proc ConnectM241 { } {
    global PortM241 M241IP
    set Bus "TCP"
    set TCP_Port 0
    set M241IP "192.168.1.1"
    TlPrint "Open Modbus TCP port %s to M241 " $M241IP
    set rc [catch { set PortM241 [mb2Open $Bus $M241IP 1] }]
    if {$rc != 0} {
	TlError "Impossible to connect"
	mb2Close $PortM241
	return 0
    }
}

proc WriteM241Address { LogAdr Value } {
    global PortM241 M241IP
    set TxFrame [format "06%04X%04x" $LogAdr $Value]
    set rc [catch { set result [mb2Direct $M241IP:$PortM241 $TxFrame] }]
    if {$rc != 0} {
	TlError "Impossible to Write"
	return 0
    }
    return $result
}

proc DisconnectM241 { } {
    global PortM241 M241IP
    mb2Close $PortM241
}

proc ReadM241Address { LogAdr } {
    global PortM241 M241IP
    set TxFrame [format "03%04X0001" $LogAdr ]
    set rc [catch { set result [mb2Direct $M241IP:$PortM241 $TxFrame] }]
    if {$rc != 0} {
	TlError "Impossible to read"
	return 0
    } else {

	if {[string range $result 0 1] == "03"} {
	    set value [ expr  [format "0x[string range $result 4 7]" ] ]
	    return $value
	}

    }
}

proc SlaveOnOff { Port Level } {
    global ActDev

    TlPrint "Set Slave_$Port $Level "

    if { ![GetSysFeat "MVKTower1"] && ![GetSysFeat "MVKTower2"]} {

	ConnectM241
	set value [ ReadM241Address 51 ]
	TlPrint " value : $value"
	set Mask [expr round(pow(2,[ expr ( $Port - 1  )])) << 2]
	TlPrint " Mask : $Mask"
	set augm [expr ( $Mask & $value) ]
	TlPrint "$augm"
	if { (( $Level == "H") || ( $Level == "h")) && ( [expr ( $Mask & $value) ] == 0 ) } {
	    WriteM241Address 51 [ expr ($value + $Mask)]

	} elseif { (( $Level == "L") || ( $Level == "l")) && ( [expr ( $Mask & $value) ]== $Mask) } {
	    WriteM241Address 51 [ expr ($value - $Mask)]

	}
	DisconnectM241
    } else {
	wc_SetDigital 3 [format "0x%02X0" $Port] $Level
    }

}

proc MasterOff {  Level } {
    global ActDev

    TlPrint "Set Master $Level "
    if { ![GetSysFeat "MVKTower1"] && ![GetSysFeat "MVKTower2"]} {
	ConnectM241
	set value [ ReadM241Address 51 ]
	TlPrint " value : $value"
	set Mask [expr round(pow(2,[ expr ( 3 - 1  )])) << 2]

	set augm [expr ( $Mask & $value) ]

	if { (( $Level == "H") || ( $Level == "h")) && ( [expr ( $Mask & $value) ] == 0 ) } {
	    WriteM241Address 51 [ expr ($value + $Mask)]

	} elseif { (( $Level == "L") || ( $Level == "l")) && ( [expr ( $Mask & $value) ]== $Mask) } {
	    WriteM241Address 51 [ expr ($value - $Mask)]

	}
	DisconnectM241
    } else {
	if { (( $Level == "H") || ( $Level == "h")) } {
	    wc_SetDigital 3 0x8 L
	}
	if { (( $Level == "L") || ( $Level == "l")) } {
	    wc_SetDigital 3 0x8 H
	}

    }
}

# Doxygen Tag:
##Function description :   Updates the value from ini file in case the configuration number and the actual device value do not match
#Updates the following fields \n 
#- DevID \n 
#- DevAdr \n 
#- DevAdr_Orig \n
#- DeviceFeatureList \n 
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/07/11 | ASY | proc created
# 2024/04/04 | ASY | update the list of the globals impacted by this functions
# 2024/07/02 | ASY | added all the relevant global variables to the mecanism
# 2024/09/11 | BC  | added the feature encoderParameters and SafetyConfiguration for PROFIsafe project
# \n
# E.g. use < updateActDevValues > to update the actual values 

proc updateActDevValues { } {
	global DevID DevAdr DevAdr_Orig DeviceFeatureList DevType
    global CIPSafetyComIndex AnaOffset TSP_Data DevoptBd MotSMParam MotASMParam
	global ActDev ActDevConf SafetyConfiguration encoderParameters
    global MotParam
	#backup the values 
	set arrayList [list DevID DevAdr DevAdr_Orig DeviceFeatureList DevType CIPSafetyComIndex AnaOffset TSP_Data DevoptBd MotSMParam MotASMParam MotParam SafetyConfiguration encoderParameters]

	foreach arr $arrayList {
		global [subst $arr]mem
		foreach ele [array names $arr] {
			set [subst $arr]mem($ele) [subst $[subst $arr]($ele)]
		}
	}
	#Get the device number for which the configuration has to be updated
	#only one device supported at the moment because of the menu.Tcl file 
	#that function is already ready for multiple devices configuration switch 
	#use set physicalActDevList [list 1 5] and set configurationActDevList [list 15 15] 
	#to overwrite configuration of device 1 and 5 with configuration of device 15
	set physicalActDevList $ActDev
	set configurationActDevList $ActDevConf
	if {[llength $physicalActDevList] != [llength $configurationActDevList]} {
		TlError " Lists dimension inconsistent in function updateActDevValues "
		return -1 
	}
	foreach physicalActDev $physicalActDevList configurationActDev $configurationActDevList { 
		TlPrint "physicalActDev : $physicalActDev "
		TlPrint "configurationActDev : $configurationActDev"
		foreach arr $arrayList {
			array unset $arr "$physicalActDev*"	

			foreach ele [array names [subst $arr]mem -glob "$configurationActDev*"] {
				regsub "$configurationActDev" $ele "$physicalActDev" newEle
				set [subst $arr]($newEle) [subst $[subst $arr]mem($ele)]
			}
		}

	}
}

# Doxygen Tag:
##Function description : basic handling of device off for gen2 towers
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/12/13 | ASY | proc created
#
# Turns device off and STO off as well 
# Returns once the device has stopped communicating over modbus RTU
proc genericDevice_Off { DevNr } {
#Check that tower is Gen2 and returns if not 
	if {! [GetSysFeat "Gen2Tower"] } {
		TlError "Function not compatible with tower"
		return -1 
	}
	TlPrint "Generic DeviceOff for device $DevNr"
	#turn off device
	se_MainPower $DevNr L
	#turn off STO 
	wc_SetSTOex $DevNr L
	#wait for modbus communication loss 
	doWaitForOff 40
}

# Doxygen Tag:
##Function description : basic handling of device on for gen2 towers
# WHEN  | WHO  | WHAT
# -----| -----| -----
# 2023/12/13 | ASY | proc created
#
# Turns device on and STO on as well 
# Returns once modbus communication is working and once device initialization is over
proc genericDevice_On { DevNr {State 2} {timeout 10} {TTId ""} } {
#Check that tower is Gen2 and returns if not 
	if {! [GetSysFeat "Gen2Tower"] } {
		TlError "Function not compatible with tower"
		return -1 
	}
	TlPrint "Generic DeviceOn for device $DevNr"
	#turn on device
	se_MainPower $DevNr H
	#turn on STO 
	wc_SetSTOex $DevNr H
	#wait for modbus communication  
	doWaitForModState $State $timeout $TTId
	doWaitForEEPROMStarted  2 1
	doWaitForEEPROMFinished 30 
}
