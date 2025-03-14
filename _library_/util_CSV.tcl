# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  Yahya    proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Retrieve data from a CSV file that is converted from an Excel file originally.
# In other words, starting from an Excel file, save it as CSV (via 'Save As' in Excel application)
# This gives a CSV file as output. Then to retrieve data from this Excel file, we can use this proc.
#
# \param[in] csvFilePath : path to CSV file to read
# \param[in] numberOfBlankRows : number of blank rows (no data inside) at the top of the original Excel file
# \param[in] numberOfBlankColumns : number of blank columns (no data inside) at the left-most of the original Excel file
#
# Returns a list of lists (each list represent data of a row)
#
# E.G. use < set csvData [getDataFromCSVConvertedFromExcel $csvFilePath 0 0] > to retrieve data from 'csvFilePath' and store it as list of lists (rows) in csvData
proc getDataFromCSVConvertedFromExcel { csvFilePath numberOfBlankRows numberOfBlankColumns } {

    #Package to read csv file
    package require csv

    # Open the CSV file
    set csvFile [open $csvFilePath "r"]

    # Read the CSV data
    set csvData [read $csvFile]

    # Close the file
    close $csvFile

    set csvData [split $csvData "\n"]

    #For the parts in CSV corresponding to empty cells, set them to "EMPTY_FIELD"
    set emptyFieldsPlaceholder "EMPTY_FIELD"
    for {set i 0} { $i < [llength $csvData] } {incr i} {
	set row [lindex $csvData $i]
	if { [regexp {^,} $row] } { ;#Empty field at the beginning of the row
	    set row ${emptyFieldsPlaceholder}${row}
	}

	#Empty fields in the middle of the row
	while { [regexp {,,} $row] } {
	    set row [string map { ",," ",EMPTY_FIELD," } $row]
	}

	if { [regexp {,$} $row] } { ;#Empty field at the end of the row
	    set row ${row}${emptyFieldsPlaceholder}
	}

	set csvData [lreplace $csvData $i $i $row]
    }

    #Reconstruct CSV data by putting back the new lines 
    set reconstructCSV ""
    foreach row $csvData {
	append reconstructCSV $row "\n"
    }

    set csvData $reconstructCSV

    #This part is to handle the multiline cells in original Excel file 
    #Actually, when saving an Excel file as CSV, each cell containing multiple lines
    #generates a new line in the output CSV file, which is altering the structure of the original file
    #Also, when data in a cell contains a comma (,), the data in CSV file is put inside double quotes
    #Here we replace the new line by whitespace for multiline cells
    #And we replace the comma characters that are part of the data by a marker '_CommaPartOfData_'
    set csvData [string map {"\n" "_MyCustomSeparator_"} $csvData] ;#Put all data in one long string
    set matchList [regexp -all -inline -- {\"[^"]+\"} $csvData ] ;#Match all parts of that string starting and ending with double quotes

    foreach statement $matchList {
	set modifiedStatement [string map { "_MyCustomSeparator_" " " } $statement]
	set modifiedStatement [string map { "," "_CommaPartOfData_" } $modifiedStatement]
	set csvData [string map [list $statement $modifiedStatement] $csvData ] 
    }

    set csvData [split $csvData ","]
    for {set i 0} { $i < [llength $csvData] } {incr i} {
	set csvData [lreplace $csvData $i $i [string trim [lindex $csvData $i] ]]
    }

    for {set i 0} { $i < [llength $csvData] } {incr i} {
	if { [regexp {^\"(.*)\"$} [lindex $csvData $i] matchingString matchingStringSubGroup] } {
	    set matchingStringSubGroup [string map { "_MyCustomSeparator_" " " } $matchingStringSubGroup]
	    set csvData [lreplace $csvData $i $i $matchingStringSubGroup]
	}

	if { [ regexp {(.*)_MyCustomSeparator_\"(.*)\"$} [lindex $csvData $i] matchingString matchingStringSubGroup1 matchingStringSubGroup2 ] } {
	    set csvData [lreplace $csvData $i $i $matchingStringSubGroup2]
	    set csvData [linsert $csvData $i ${matchingStringSubGroup1}_MyCustomSeparator_ ]
	}
    }

    set csvData [string map {"_CommaPartOfData_" ","} $csvData]
    set csvData [string map {"_MyCustomSeparator_" "\n"} $csvData]
    set csvData [split $csvData "\n"]

    #When an excel sheet has blank rows at the top and/or blank columns at left 
    #When it is saved as CSV, these blank rows and columns are ignored in the output file
    #Here we add the blank rows & columns to csvData to conserve the same format as the original Excel sheet
    if { $numberOfBlankRows > 0 } {
	for {set i 0} { $i < $numberOfBlankRows } {incr i} {
	    set csvData [linsert $csvData 0 [list "EMPTY_FIELD"] ]
	}
    }

    if { $numberOfBlankColumns > 0 } {
	for {set i 0} { $i < [llength $csvData]} {incr i} {
	    set row [lindex $csvData $i]

	    for {set j 0} { $j < $numberOfBlankColumns } {incr j} {
		set row [linsert $row 0 "EMPTY_FIELD" ]
	    }
	    set csvData [lreplace $csvData $i $i $row]
	}
    }

    return $csvData
}


# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  Yahya    proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Converts a number to corresponding Excel column letter
#
# \param[in] colNum : column number
#
# Returns the Excel column letter corresponding to column number 'colNum'
#
# E.G. use < excelColumnNumberToLetter 2 > returns 'B' (as the letter corresponding to 2nd column in an Excel file is 'B')
proc excelColumnNumberToLetter {colNum} {
    set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    set result ""

    while {$colNum > 0} {
	set remainder [expr {$colNum % 26}]
	if {$remainder == 0} {
	    set remainder 26
	}
	set result [string index $alphabet [expr {$remainder - 1}]]$result
	set colNum [expr {int(($colNum - $remainder) / 26)}]
    }

    return $result
}


# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  Yahya    proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Converts an Excel column letter to corresponding number
#
# \param[in] colNum : column number
#
# Returns the column number corresponding to Excel column letter 'colLetter'
#
# E.G. use < excelColumnLetterToNumber 'C' > returns 3 (as the 'C' corresponds to the 3rd column in an Excel file)
proc excelColumnLetterToNumber {colLetter} {
    set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    set colNumber 0
    set len [string length $colLetter]

    # Input validation
    if {$len == 0 || $len > 3} {
	TlError "Invalid column letter: $colLetter"
	return
    }
    foreach char [split [string toupper $colLetter] ""] {
	if {[string first $char $alphabet] == -1} {
	    TlError "Invalid column letter: $colLetter"
	    return
	}
    }


    for {set i 0} {$i < $len} {incr i} {
	set char [string index $colLetter $i]
	set position [expr {[string first $char $alphabet] + 1}]
	set colNumber [expr {$colNumber * 26 + $position}]
    }

    return $colNumber
}

     
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  Yahya    proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Converts an Excel column letter to corresponding number
#
# \param[in] allCellsData : all data read from CSV file as list of rows (the return value of proc getDataFromCSVConvertedFromExcel)
# \param[in] rowIndex : index of row we want to get data from
# \param[in] columnLetter : column letter (as it is in Excel file) of the column we want to get data from
#
# Returns the data from a specific cell in Excel file
#
# E.G. use < getCellValue 1 'C' > returns the data inside cell C1 (1st row, column C) in the original Excel file     
proc getCellValue { allCellsData rowIndex columnLetter } {

    set rowData [lindex $allCellsData [expr $rowIndex - 1] ]
    set columnIndex [excelColumnLetterToNumber $columnLetter]
    set cellValue [lindex $rowData [expr $columnIndex - 1] ]

    return $cellValue
}
     
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  ASY  proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Return a list that contains lines of you csv file
#
# \param[in] inputFile : The path to the csv from the mainpath (Testturm2.0)
#
#
proc importCSVData { inputFile } {
    global mainpath 
    set rootPath "$mainpath\\"
    set inputFileName "$rootPath$inputFile"
    set f [open $inputFileName r]
    set inputData [split [read $f] "\n"]
    close $f
    set outputData [list]
    foreach line $inputData {
	lappend outputData [split $line  ","]
    }
    return $outputData 

}
   
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  ASY  proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Function will compare two csv file
#
# \param[in] masterFile : The path to the first csv from the mainpath 
# \param[in] compareFile : The path to the second csv from the mainpath (Testturm2.0)
# \param[in] columnList : list of column you don't want to compare, by default it will compare all
# \param[in] detailedView :setting this parameter to 1 will display a second time both line but it will replace matching
# char by a blank and display only not matching one
#
# Will generate an error if files are not matching.
# Will display each lines not matching
# For the detailed view, will use the smallest of both line
#
proc compareCSVFiles { masterFile compareFile {columnList "ALL"} {detailedView 0} } {
    global mainpath 
    set rootPath "$mainpath\\"
    set masterFileName "$rootPath$masterFile"
    set compareFileName "$rootPath$compareFile"
    set f [open $masterFileName r]
    set masterData [split [read $f] "\n"]
    close $f
    set g [open $compareFileName r]
    set compareData [split [read $g] "\n"]
    close $g
    set tempString1 ""
    set tempString2 ""
    set espaceString " "
    set errorFlag 0
	set errorSize 0
	if { [llength $masterData] != [llength $compareData]} {
		incr errorSize 
		incr errorFlag
	}
    for {set j 0} {$j < [expr min([llength $masterData], [llength $compareData])]} {incr j} {
	    
	set masterLine [split [lindex $masterData $j] ","]
	set compareLine [split [lindex $compareData $j] ","]
	if {  [llength $masterLine] != [llength $compareLine] } {
		incr errorFlag
		TlPrint "____________________________"
		TlPrint "Line : [expr $j + 1], Master length: [llength $masterLine] , Compare length: [llength $compareLine]  "
		TlPrint "____________________________"
	}
	for {set currentCol 0} {$currentCol < [llength $masterLine]} {incr currentCol } {
	    
	    if { $columnList != "ALL" } {
		if { [lsearch $columnList [expr $currentCol+1]] != -1} {
		    continue
		}
	    }
	    set masterCol [lindex $masterLine $currentCol]
	    set compareCol [lindex $compareLine $currentCol]
	    if { $compareCol != $masterCol} {
		incr errorFlag
		set tempString1 ""
		set tempString2 ""
		TlPrint "____________________________"
		TlPrint "Line : [expr $j + 1], [expr $currentCol + 1] Master : $masterCol"
		TlPrint "Line : [expr $j + 1], [expr $currentCol + 1] Compare: $compareCol"
		if {$detailedView } {
		    set minCharCount [expr min([string length $masterCol], [string length $compareCol])]
		    for {set i 0} {$i < $minCharCount} {incr i} {
			if { [string index $masterCol $i] == [string index $compareCol $i]} {
			    set tempString1  "$tempString1$espaceString"
			    set tempString2  "$tempString2$espaceString"
			} else {
			    set tempString1 "$tempString1[string index $masterCol $i]"
			    set tempString2 "$tempString2[string index $compareCol $i]"
			}
		    }
		    TlPrint "Line : [expr $j + 1], [expr $currentCol + 1] Master : $tempString1"
		    TlPrint "Line : [expr $j + 1], [expr $currentCol + 1] Compare: $tempString2"
		    puts "____________________________"
		} ;# end detailedView
	    } ;# end if compareCol != masterCol
	} ;# end for accross all columns
    } ;# end for accross all lines of the files
    if { $errorFlag != 0} {
	set sizeString ""
	set errorString "CSV files ($masterFile / $compareFile) are different ($errorFlag differences found when parsing all columns "
	if {$columnList != "ALL"} {
	    set tempString "but numbers [join $columnList] )"
	} else {
	    set tempString ")"
	}
	if {$errorSize != 0} {
		set sizeString "\nBoth csv files were not same size"
	} 
	set errorString $errorString$tempString$sizeString
	TlError $errorString 
    } else {
	TlPrint "No difference seen between both files"
    }
}
 
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 290324  ASY   proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Will return a list of the lines requested from a csv file
#
# \param[in] inputFile: path to the file
# \param[in] linesList : a list of lines you wanna get from the csv
# call exemples: set sys_lines [importCSVLines xxxx/xxxx/xxxx.csv {1 3 5}]
# The function will return in sys_lines var, the lines 1,3,5 of my csv file     
proc importCSVLines { inputFile linesList } {
    global mainpath 
    set rootPath "$mainpath\\"
    set inputFileName "$rootPath$inputFile"
    set f [open $inputFileName r]
    set inputData [split [read $f] "\n"]
    close $f
    set outputData [list]
    set errorFlag 0
    #Check that the line required is present in the file. just display an error but keep executing
    foreach lineNumber $linesList {
	if { $lineNumber > [llength $inputData] } {incr errorFlag}
    }
    if {$errorFlag > 0 } {
	TlError "Error : $errorFlag lines required are outside of file's boundaries"
    }

    for {set i 0} {$i < [llength $inputData]} {incr i } {
	if {[lsearch $linesList [expr $i +1]] != -1 } {
	    lappend outputData [split [lindex $inputData $i]  ","]
	}
    }
    return $outputData 

}
     
# ----------HISTORY--------------------------------------------------------------------------------------------------------
# WHEN    WHO      WHAT
# 060824  EDM   proc created
#
# -------------------------------------------------------------------------------------------------------------------------
# Doxygen Tag :
##Function description : Will return a list of the columns requested from a csv file
#
# \param[in] inputFile: path to the file
# \param[in] linesList : a list of columns you wanna get from the csv
# call exemples: set sys_cols [importCSVColumns xxxx/xxx/xxxx.csv {1 3 5}]
# The function will return in sys_cols var, the lines 1,3,5 of my csv file
     
proc importCSVColumns { inputFile columnsList } {
    global mainpath 
    set rootPath "$mainpath\\"
    set inputFileName "$rootPath$inputFile"
    set f [open $inputFileName r]
    set inputData [split [read $f] "\n"]
    close $f
    set result [list]
    set maxColumns [expr {[llength [split [lindex $inputData 0] ","]] - 1}] ;# Calculate the maximum available column index

    foreach line $inputData {
	set fields [split $line ,]
	set rowData [list]
	foreach col $columnsList {
	    if {$col > $maxColumns} {
		TlError "Column index $col is out of range. Max column index is $maxColumns"
	    }
	    lappend rowData [lindex $fields $col]
	}
	lappend result $rowData
    }
    return $result
}

