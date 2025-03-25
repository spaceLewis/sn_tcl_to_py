# CPD Testumgebung

#
# Description  : Kommandos um BLE Files einzulesen und an ein CPD zu übertragen
#
# Filename     : ble_parser.tcl
#
#
# ----------HISTORY----------
# WANN      WER      WAS
# ?         wurtr    Datei angelegt
# 081024    pfeig    globAbbruchFlag
# 011009    pfeig    CRC16 calculation hinzugefügt
#

# TCL - Script for CRC16 calculation
#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#package require crc16
source "$libpath\\crc16_reflected.tcl"


proc WriteBleCRC {} {
   global mainpath

   set output 1
   set pfad  "$mainpath\\ble\\BLE_eSM\\eSM_Device1_default.ble"
   
   set cnt_array_a      0
   set param_array_a(1) 0
   set wert_array_a(1)  0
   set flash_array_a(1) 0
   set addr_array_a(1)  0
   set sort_array_a(1)  0
   
   set cnt_array_b      0
   set param_array_b(1) 0
   set wert_array_b(1)  0
   set flash_array_b(1) 0
   set addr_array_b(1)  0
   set sort_array_b(1)  0
   
   #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   # Öffnen der BLE-Datei
   if [catch {open $pfad r} f] { ;# <Abfangen eines Fehlers beim öffnen der Datei
      puts "Die Datei konnte nicht geöffnet werden\n$f"           ;# <Wenn die Datei nicht geöffnet werden kann liefert catch ein TRUE
   } else {                                           ;# <Dateiinhalt wird in die Variable INHALT eingelesen
      set inhalt [read -nonewline $f]           
      close $f                                        ;# <Datei wird wieder geschlossen
   
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Einlesen der Parameter und Werte für die CRC16-Berechnung
      foreach zeile [split $inhalt \n] {                    ;# <Der INHALT wird Zeile für Zeile zu einer Liste zerlegt
         if [regexp {SFTYAC.} $zeile] {               ;# <Der INHALT wird nach den relevanten Zeilen für CPU-A abgesucht
            incr cnt_array_a                          ;# <Indezx-Zähler des Arrays  
            set tmp_cnt 0                             ;# <Zähler für die "gespliteten" Teile einer Zeile
            foreach part [split $zeile \ .\ .^\#] {            ;# <Splitet die Zeilen und übergibt sie an die Variable part
               if {$part != ""} {
                  incr tmp_cnt
                  if {$tmp_cnt == 3} {
                     set param_array_a($cnt_array_a) $part} ;# <Übergibt den Parameter dem Array (param_array)
                  if {$tmp_cnt == 4} {
                     set wert_array_a($cnt_array_a) $part   ;# <Übergibt den Wert dem Array (wert_array)
                     # liefert FEHLER, wenn ein Parameter ohne Wert steht:
                     if [catch {expr $wert_array_a($cnt_array_a) + 1 } z] {
                        puts "\nFEHLER: Der Wert für den Parameter \"$param_array_a($cnt_array_a)\" (CPU-A) fehlt nicht!\n"
                        return 0
                     } ;#else {return 1}
                  }
               }
            }
            if [string match "*SFTYAC.CRCREMPARA*" $zeile] {
               set crc_line_alt_a $zeile                 ;# <"crc_line_a" ist die Zeile in die die berechnete CRC-Summe für CPU-A geschrieben wird
            }
         }
         if [regexp {SFTYBC.} $zeile] {               ;# <Der INHALT wird nach den relevanten Zeilen für CPU-B ab gesucht
            incr cnt_array_b                          ;# <Indezx Zähler des Arrays  
            set tmp_cnt 0                             ;# <Zählt die "gespliteten" Teile einer Zeile
            foreach part [split $zeile \ .\ .^\#] {            ;# <Zerlegt die Zeilen und übergibt sie an die Variable part
               if {$part != ""} {
                  incr tmp_cnt
                  if {$tmp_cnt == 3} {
                     set param_array_b($cnt_array_b) $part} ;# <Übergibt den Parameter dem Array (param_array)
                  if {$tmp_cnt == 4} {
                     set wert_array_b($cnt_array_b) $part   ;# <Übergibt den Wert dem Array (wert_array)
                     # liefert FEHLER, wenn ein Parameter ohne Wert steht:
                     if [catch {expr $wert_array_b($cnt_array_b) + 1 } z] {
                        puts "\nFEHLER: Der Wert für den Parameter \"$param_array_b($cnt_array_b)\" (CPU-B) fehlt nicht!\n" 
                        return 0
                     } ;#else {return 1}
                  }
               }
            }
            if [string match "*SFTYBC.CRCREMPARA*" $zeile] {
               set crc_line_alt_b $zeile}                   ;# <"crc_line_b" ist die Zeile in die die berechnete CRC-Summe für CPU-B geschrieben wird
         }     
      }
   
      
      # Ausgabe der eingelesenen Parameter
      if {$output == 1} {
         puts "\nEingelesene Werte CPU-A:\n"
         for {set i 1} {$i <= 9} {incr i} {
            puts "[format "  %-13s %-10s" $param_array_a($i) $wert_array_a($i)]"}
         puts "\nEingelesene Werte CPU-B:\n"
         for {set i 1} {$i <= 9} {incr i} {
            puts "[format "  %-13s %-10s" $param_array_b($i) $wert_array_b($i)]"}
      }
         
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Erstellen eines addr_array für beide CPU
         # WERT:     Inhalt des wert_array
         # INDEX: Inhalt des param_array
      for {set i 1} {$i <= 9} {incr i} {
         set addr_array_a($param_array_a($i)) $wert_array_a($i)
         set addr_array_b($param_array_b($i)) $wert_array_b($i)
         }
         
      
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Erstellen des sort_array
      # !Fügt die einegelesenen Werte in der richtigen Reihenfolge in in das sort_array ein!
      
      if [catch {expr $addr_array_a(MODEOUT1) + 1 } z] {puts "FEHLER: Parameter \"MODEOUT1 (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(1) $addr_array_a(MODEOUT1)}           
      if [catch {expr $addr_array_a(MODEOUT2) + 1 } z] {puts "FEHLER: Parameter \"MODEOUT2 (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(2) $addr_array_a(MODEOUT2)}
      if [catch {expr $addr_array_a(DECNC) + 1 } z] {puts "FEHLER: Parameter \"DECNC (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(3) $addr_array_a(DECNC)}
      if [catch {expr $addr_array_a(DECQSTOP) + 1 } z] {puts "FEHLER: Parameter \"DECQSTOP (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(4) $addr_array_a(DECQSTOP)}
      if [catch {expr $addr_array_a(TNCDEL) + 1 } z] {puts "FEHLER: Parameter \"TNCDEL (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(5) $addr_array_a(TNCDEL)}
      if [catch {expr $addr_array_a(TRELAYDELAY) + 1 } z] {puts "FEHLER: Parameter \"TRELAYDELAY (CPU-A)\" exestiert nicht!"; return 0 
         } else {set sort_array_a(6) $addr_array_a(TRELAYDELAY)}
      if [catch {expr $addr_array_a(MISCMODES) + 1 } z] {puts "FEHLER: Parameter \"MISCMODES (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(7) $addr_array_a(MISCMODES)}
      if [catch {expr $addr_array_a(VELMAXRED) + 1 } z] {puts "FEHLER: Parameter \"VELMAXRED (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(8) $addr_array_a(VELMAXRED)}
      if [catch {expr $addr_array_a(VELMAXABS) + 1 } z] {puts "FEHLER: Parameter \"VELMAXABS (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_a(9) $addr_array_a(VELMAXABS)}
      
      if [catch {expr $addr_array_b(MODEOUT1) + 1 } z] {puts "FEHLER: Parameter \"MODEOUT1 (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(1) $addr_array_b(MODEOUT1)}  
      if [catch {expr $addr_array_b(MODEOUT2) + 1 } z] {puts "FEHLER: Parameter \"MODEOUT2 (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(2) $addr_array_b(MODEOUT2)}
      if [catch {expr $addr_array_b(DECNC) + 1 } z] {puts "FEHLER: Parameter \"DECNC (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(3) $addr_array_b(DECNC)}
      if [catch {expr $addr_array_b(DECQSTOP) + 1 } z] {puts "FEHLER: Parameter \"DECQSTOP (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(4) $addr_array_b(DECQSTOP)}
      if [catch {expr $addr_array_b(TNCDEL) + 1 } z] {puts "FEHLER: Parameter \"TNCDEL (CPU-A)\" exestiert nicht!";  return 0
         } else {set sort_array_b(5) $addr_array_b(TNCDEL)}
      if [catch {expr $addr_array_b(TRELAYDELAY) + 1 } z] {puts "FEHLER: Parameter \"TRELAYDELAY (CPU-A)\" exestiert nicht!";  return 0   
         } else {set sort_array_b(6) $addr_array_b(TRELAYDELAY)}
      if [catch {expr $addr_array_b(MISCMODES) + 1 } z] {puts "FEHLER: Parameter \"MISCMODES (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(7) $addr_array_b(MISCMODES)}
      if [catch {expr $addr_array_b(VELMAXRED) + 1 } z] {puts "FEHLER: Parameter \"VELMAXRED (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(8) $addr_array_b(VELMAXRED)}
      if [catch {expr $addr_array_b(VELMAXABS) + 1 } z] {puts "FEHLER: Parameter \"VELMAXABS (CPU-A)\" exestiert nicht!"; return 0
         } else {set sort_array_b(9) $addr_array_b(VELMAXABS)}
      
   #  # Ausgabe der sort_array (!einelesen!) auf dem Bildschirm
   #     puts "\nSORT_ARRAY_A (eingelesen):\n"
   #     for {set i 1} {$i <=9} {incr i} {puts "sort_array_a ($i) : $sort_array_a($i)"}
   #     puts "\nSORT_ARRAY_B (eingelesen):\n"
   #     for {set i 1} {$i <= 9} {incr i} {puts "sort_array_b ($i) : $sort_array_b($i)"}
      
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Ein flash_array mit 24 Plätzen erstellen und mit 00000000 füllen
      
      for {set i 1} {$i <= 24} {incr i} {
         set flash_array_a($i) 0000
         set flash_array_b($i) 0000
      }
      
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # flash_array_a mit den Werten des CPU-A füllen (gegebenenfalls dez. in hex. umwandeln)
      # Einlesen aus dem sort_array_a :
      # Verarbeitung der 32-bit Zahlen (die ersten 4 Werte)
      for {set i 1} {$i <= 4} {incr i} {
         if [regexp {0x} $sort_array_a($i)] {                     ;# <Prüft ob der Wert in hex steht oder nicht!
            # >> WERT STEHT IN HEX
            set sort_array_b($i) [format "0x%08X" $sort_array_b($i)] ;# <falls notwendig, den Wert auf 4-bit formatieren
         } else {
            # >> UMWANDELN IN HEX
            set hex [format "0x%08X" 0x[format %x [string range $sort_array_a($i) 0 end]]]
            set sort_array_a($i) $hex
         }                          ;# <Formatierte und in hex umgewandelte Zahl wieder in sort_array schreiben
         set 1_nibble [string range $sort_array_a($i) 6 9]           ;# <Vertauschen der Bits des ersten Nibbels
         set 1_bit_01 [string range $1_nibble 0 1]                ;# <...
         set 1_bit_23 [string range $1_nibble 2 3]                ;# <...
         set 1_nibble [append 1_bit_23 "$1_bit_01"]                  ;# <...
         #append 1_nibble "0000"                               ;# <Auffüllen des ersten Nibbels mit 0000
         set flash_array_a([expr [expr $i*2]+1]) $1_nibble           ;# <Den neuen Wert ins flash_array schreiben          
         set 2_nibble [string range $sort_array_a($i) 2 5]           ;# <Vertauschen der Bits des zweiten Nibbels
         set 2_bit_01 [string range $2_nibble 0 1]                ;# <...
         set 2_bit_23 [string range $2_nibble 2 3]                ;# <...
         set 2_nibble [append 2_bit_23 "$2_bit_01"]                  ;# <...
         #append 2_nibble "0000"                               ;# <Aüffülen des zweiten Nibbles mit 0000
         set flash_array_a([expr [expr $i*2]+2]) $2_nibble           ;# <Den neuen Wert ins flash_array schreiben 
      }
      # Verarbeitung der 16-bit Zahlen (die ersten 4 Zahlen)
      for {set i 5} {$i <= 9} {incr i} {                          ;# << !! **ENDBEDINGUNG PRÜFEN** !! >>
         if {[regexp {0x} $sort_array_a($i)]} {                   ;# <Prüft ob der Wert in hex steht oder nicht!
            # >> WERT STEHT IN HEX
            set sort_array_a($i) [format "0x%04X" $sort_array_a($i)] ;# <falls notwendig, den Wert auf 4-bit formatieren
         } else {
            # >> UMWANDELN IN HEX
            set hex [format "0x%04X" 0x[format %x [string range $sort_array_a($i) 0 end]]]
            set sort_array_a($i) $hex
         }                          ;# <Formatierte und in hex umgewandelte Zahl wieder in sort_array schreiben
         set nibble [string range $sort_array_a($i) 2 5]             ;# <Ausschneiden des Wertes
         set bit_01 [string range $nibble 0 1]                    ;# <Vertauschen der Bits
         set bit_23 [string range $nibble 2 3]                    ;# <...
         set nibble [append bit_23 "$bit_01"]                     ;# <...
         #append nibble "0000"                                 ;# <Auffüllen mit 0000
         set flash_array_a([expr $i+6]) $nibble                   ;# <Den neuen Wert ins flash_array schreiben
      }
      
      
      #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # flash_array_b mit den Werten des CPU-B füllen
      # Einlesen aus dem sort_array_b
      # Verarbeitung der 32-bit Zahlen (die ersten 4 Werte)
      for {set i 1} {$i <= 4} {incr i} {
         if [regexp {0x} $sort_array_b($i)] {                     ;# <Prüft ob der Wert in hex steht oder nicht!
            # >> WERT STEHT IN HEX
                  set sort_array_b($i) [format "0x%08X" $sort_array_b($i)] ;# <falls notwendig, den Wert auf 4-bit formatieren
         } else {
            # >> UMWANDELN IN HEX
            set hex [format "0x%08X" 0x[format %x [string range $sort_array_b($i) 0 end]]]
            set sort_array_b($i) $hex                          ;# <Formatierte und in hex umgewandelte Zahl wieder in sort_array schreiben
         }
         set 1_nibble [string range $sort_array_b($i) 6 9]           ;# <Vertauschen der Bits des ersten Nibbels
         set 1_bit_01 [string range $1_nibble 0 1]                ;# <...
         set 1_bit_23 [string range $1_nibble 2 3]                ;# <...
         set 1_nibble [append 1_bit_23 "$1_bit_01"]                  ;# <...
         #append 1_nibble "0000"                               ;# <Auffüllen des ersten Nibbels mit 0000
         set flash_array_b([expr [expr $i*2]+1]) $1_nibble           ;# <Den neuen Wert ins flash_array schreiben          
         set 2_nibble [string range $sort_array_b($i) 2 5]           ;# <Vertauschen der Bits des zweiten Nibbels
         set 2_bit_01 [string range $2_nibble 0 1]                ;# <...
         set 2_bit_23 [string range $2_nibble 2 3]                ;# <...
         set 2_nibble [append 2_bit_23 "$2_bit_01"]                  ;# <...
         #append 2_nibble "0000"                               ;# <Aüffülen des zweiten Nibbles mit 0000
         set flash_array_b([expr [expr $i*2]+2]) $2_nibble           ;# <Den neuen Wert ins flash_array schreiben 
      }
      # Verarbeitung der 16-bit Zahlen (die ersten 4 Zahlen)
      for {set i 5} {$i <= 9} {incr i} {                          ;# << !! **ENDBEDINGUNG PRÜFEN** !! >>
         if {[regexp {0x} $sort_array_b($i)]} {                   ;# <Prüft ob der Wert in hex steht oder nicht!
            # >> WERT STEHT IN HEX
            set sort_array_b($i) [format "0x%04X" $sort_array_b($i)] ;# <falls notwendig, den Wert auf 4-bit formatieren
         } else {
            # >> UMWANDELN IN HEX
            set hex [format "0x%04X" 0x[format %x [string range $sort_array_b($i) 0 end]]]
            set sort_array_b($i) $hex                          ;# <Formatierte und in hex umgewandelte Zahl wieder in sort_array schreiben
         }
         set nibble [string range $sort_array_b($i) 2 5]             ;# <Ausschneiden des Wertes
         set bit_01 [string range $nibble 0 1]                    ;# <Vertauschen der Bits
         set bit_23 [string range $nibble 2 3]                    ;# <...
         set nibble [append bit_23 "$bit_01"]                     ;# <...
         #append nibble "0000"                                 ;# <Auffüllen mit 0000
         set flash_array_b([expr $i+6]) $nibble                   ;# <Den neuen Wert ins flash_array schreiben
      }
         
      
      #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   #  # Ausgabe der sort_array (!umgewandelt!) auf dem Bildschirm
   #     puts "\nSORT_ARRAY_A:\n"
   #     for {set i 1} {$i <= 9} {incr i} {puts "sort_array_a ($i) : $sort_array_a($i)"} 
   #     puts "\nSORT_ARRAY_B:\n"
   #     for {set i 1} {$i <= 9} {incr i} {puts "sort_array_b ($i) : $sort_array_b($i)"}
   #  # Ausgabe der flash_array auf dem Bildschirm
   #     puts "\nFLASH_ARRAY_A :\n"
   #     for {set i 1} {$i <= $flash_length} {incr i} {puts "flash_array_a ($i) :   $flash_array_a($i)"}
   #     puts "\nFLASH_ARRAY_b :\n"
   #     for {set i 1} {$i <= $flash_length} {incr i} {puts "flash_array_b: $i   $flash_array_b($i)"}
      
      
      #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # CRC berechnen
      
      # CRC für CPU-A berechnen:
      for {set i  1} {$i  <= 24} {incr i} {
         set byte1 [format %c 0x[string range $flash_array_a($i) 0 1]]
         set byte2 [format %c 0x[string range $flash_array_a($i) 2 3]]
          append line_a $byte1
         append line_a $byte2
      }
      set flash_a_crc16 [crc::crc16 -format %04X $line_a]                  ;# <CRC-16
      set flash_a_crc_ccitt [crc::crc-ccitt -format %04X $line_a]          ;# <CRC-CCITT
      set crc_a 0x
      append crc_a $flash_a_crc_ccitt
      append crc_a $flash_a_crc16
      # puts "flash_a_crc16 : $flash_a_crc16"
      # puts "flash_a_crc_ccitt : $flash_a_crc_ccitt"
      # puts "\nCRC CPU-A: $crc_a"
      
      # CRC für CPU-B berechnen:
      for {set i  1} {$i  <= 24} {incr i} {
         set byte1 [format %c 0x[string range $flash_array_b($i) 0 1]]
         set byte2 [format %c 0x[string range $flash_array_b($i) 2 3]]
          append line_b $byte1
         append line_b $byte2
      }
      set flash_b_crc16 [crc::crc16 -format %04X $line_b]                  ;# <CRC-16
      set flash_b_crc_ccitt [crc::crc-ccitt -format %04X $line_b]          ;# <CRC-CCITT
      set crc_b 0x
      append crc_b $flash_b_crc_ccitt
      append crc_b $flash_b_crc16
      # puts "flash_b_crc16 : $flash_b_crc16"
      # puts "flash_b_crc_ccitt : $flash_b_crc_ccitt"
      # puts "CRC CPU-B: $crc_b\n"
         
      
      #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      # Schreiben der CRC Summe ins BLE-File
      
      set crc_line_a [format "%-32s%-16s%-10s" "write SFTYAC.CRCREMPARA" $crc_a "# CRC"]
      set crc_line_b [format "%-32s%-16s%-10s" "write SFTYBC.CRCREMPARA" $crc_b "# CRC"]
      # Schreiben der CRC-Summe in die eingelesene BLE-Datei
      set f [open $pfad w]
      regsub $crc_line_alt_a $inhalt $crc_line_a inhalt
      regsub $crc_line_alt_b $inhalt $crc_line_b inhalt
      puts -nonewline $f $inhalt
      close $f
      
      # Ausgabe der CRC Werte
      if {$output == 1} {
         puts "\nCRC CPU-A: $crc_a"
         puts "CRC CPU-B: $crc_b\n"
      }
      
   }  ;# esle (!Öffnen der BLE-Datei!)

}
#--------------------------------------------------------------------------------------------------------------
# End of: Script for CRC16 calculation
#--------------------------------------------------------------------------------------------------------------


proc RemoveSpaceFromList { ListStr } {

   set NewList {} ;# empty List

   foreach item $ListStr {
      if { $item != "" } {
         lappend NewList $item
      }
   }

   return $NewList
}

#--------------------------------------------------------------------------------------------------------------
#
#   Kommandos zum einlesen eine BLE-Files
#
#--------------------------------------------------------------------------------------------------------------
# Syntax:
#
# write Index Subindex Wert beliebigeKommentare
# write Kuerzel1.Kuerzel2 Wert beliebigeKommentare

proc execute_ble_file { filename } {
   global globAbbruchFlag

   TlPrint ""
   set NameF [glob $filename]
   TlPrint "BLE File laden: $NameF"

   set file [open $NameF]

   while { ! [eof $file] } {
        set line [gets $file]

      # Kommentarzeilen ignorieren
        if [regexp "^write" $line] {

         set line [RemoveSpaceFromList $line]
         set wordList [split $line]
#         TlPrint "WortListe: $wordList"
         set value1 [lindex $wordList 1]

         if [regexp {^[0-9]} $value1] {
            # numerische Uebergabe von Index und Subindex, z.B. "11 9"
            set idx   [lindex $wordList 1]
            set six   [lindex $wordList 2]
            set obj   "$idx.$six"      ;# daraus wird z.B. "11.9"
            set value [lindex $wordList 3]
         } else {
            # symbolische Uebergabe, z.B. "MAND.NAME1"
            set obj   [lindex $wordList 1]
            set value [lindex $wordList 2]
         }

#         TlPrint "ble-write: $obj $value"
         ModTlWrite $obj $value
      }

      if {([CheckBreak] == 1)} {
         break
      }

   }

   close $file
}
