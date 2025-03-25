# TCT Testturm-Umgebung
# Globale Konstanten

# ----------HISTORY----------
# WANN      WER   WAS
# ?         ?     Datei angelegt
# 090103    pfeig Kommentare
# 240303    pfeig neue Konstante f�r Wartezeit nach einem Pos.Cmd.
# 080403    pfeig Wartezeit nach einem Pos.Cmd von 100 auf 150ms erh�ht
# 130603    pfeig Globale Tol. f�r SpeedCheck
# 260603    pfeig Globale Variable f�r Programmnummer
# 280703    wurtr Warnung Positionsabweichung bei Disable (IFE)
# 101203    pfeig Globale f�r Wago833
# 190504    pfeig Aktionswort an CPD angepasst
# 010704    pfeig Schritte pro Umdrehung bei CPD
# 220704    pfeig globale Variable f�r ERRCHANGE
# 060904    pfeig globale Variablen f�r Systemcheck
# 041104    pfeig Variablen f�r Uwe angelegt
# 171104    ockeg Toleranz_NrefEA definiert
# 270105    pfeig Globale Deklaration von ActDev nach ganz vorne verschoben
# 180705    pfeig PrgNr PrgVer PrgDat
# 101105    pfeig MaxDev (Anzahl der zu benutzenden Ger�te)
# 211106    pfeig ChannelsNumberPointsPer Global gesetzt
# 180107    ockeg aufger�umt
# 050207    rothf Enable_Counter hinzugef�gt
# 290607    ockeg GEBER_AUFLOESUNG eliminiert, wurde nirgends benutzt und gibts bei Servo so eh nicht
#                 Enc_Faktor wird in setDefs gesetzt
# 100714    hmwang The computer name of IOCC UniFAST is WXCN002SHZJ3878, which will fix dedicated Wago PLC IP address
# 171014    gelbg Add constants identifying a priority class, - see also Windows SDK
# 290415    serio Raise Tol_RFRanalog and Tol_RFRDanalog
# 24/10/2024 EDM Update PACY_COM_PROFINET Plc adresse from 192.168.100.xxx to 192.168.101.xxx #1815

array set PrioDef {
    Realtime     256
    High         128
    AboveNormal  32768
    Normal       32
    BelowNormal  16384
    Low          64
}

set reducedTestExecution 0 			;#define whether test execution amount will be reduced
set theTestSuiteFailed 0			;#remembers is a test suite is failed
set TraceStatistics 1

# global ActDev
if {![info exists ActDev]} {
    set ActDev 0

}

set version_eSM 0

if { ![info exists FlexIO_TestActive] } {
    global FlexIO_TestActive
    set FlexIO_TestActive 0
}
if { ![info exists FlexIOM_TestActive] } {
    global FlexIOM_TestActive
    set FlexIOM_TestActive 0
}

set EtherBusList { EPL ECAT MBTCP EIP}

set CanNetOpen 0 ;# false

#Array mit der Angabe, wie oft die einzelnen Ger�te im letzten Durchlauf Enabled wurden
array set Enable_Counter {
    1  0
    2  0
    3  0
    4  0
}

#Array to check if Device is on or not
array set Dev_On  {
    1  0
    2  0
    3  0
    4  0
}

#Array to check if ModBus TCP Port is open or not
array set MBTCPPort  {
    1  {}
    2  {}
    3  {}
    4  {}
}

# Konstanten fuer die Geraeteadressen auf dem Profibus
#global PB_WAGO752 PB_WP311 PB_TWINLINE PB_WAGO833 PB_WP311_2
set PB_WAGO752      5
set PB_WP311        4
set PB_TWINLINE     3
set PB_WAGO833      6
set PB_WP311_2      7

# Ethernet-Adresse des Wago-Controllers
global Wago_IPAddress Wago_Type
global BW_IPAddress  M241_IPAddress
switch -regexp $COMPUTERNAME {

    "WS004729"
    {
	set Wago_Type "Profibus"
	set PB_WAGO833      6

    }

    "WXCN002SHZJ3878"
    {
	set Wago_Type "Ethernet"
	set Wago_IPAddress 192.168.2.100
	set LocalInterface_IPAddress 192.168.2.101
    }
    "ATV310-PC"
    {
	set Wago_Type "Ethernet"
	set Wago_IPAddress 192.168.2.100
	set BW_IPAddress 192.168.2.200
	set M241_IPAddress 192.168.2.150
	set LocalInterface_IPAddress 192.168.2.101
    }

    "ATV610-PC"
    {
	set Wago_Type "Ethernet"
	# set Wago_IPAddress 10.177.73.246
	# set LocalInterface_IPAddress 10.177.73.245
	set Wago_IPAddress 192.168.2.100
	set LocalInterface_IPAddress 192.168.2.103
    }

    "WTFRLVSE205811D" {
	set Wago_IPAddress 192.168.10.2
	set LocalInterface_IPAddress 192.168.10.60
    }
	"WTFRLVSE186119D"  { 
	set Wago_Type "Ethernet"
	#Due to issue #1815 PLC has been removed from main switch, to get directly wired
	#from computer on PACY_COM_PROFINET. Since we still have the 192.168.100.xxx network used for MBTCP
	#we changed the network for PLC from 100 to 101 in this specific case
		
	set Wago_IPAddress 192.168.101.200
	set LocalInterface_IPAddress 192.168.101.51
	}
    default  {
	set Wago_Type "Ethernet"

	set Wago_IPAddress 192.168.100.200
	set LocalInterface_IPAddress 192.168.100.50

    }
}

#Definition of Bits of warning word (STD.WARNSIG/WARNSIGSR)
set WARNSIG_Gen         0x00000001   ;#General warning (see _LastWarning)
set WARNSIG_LIM         0x00000002   ;#Limit switches (LIMP/LIMN/REF)
set WARNSIG_SWLIM       0x00000004   ;#Out of range (SW limit switches, tuning)

set WARNSIG_OpMode      0x00000010   ;#Acitve operating mode
set WARNSIG_RS485       0x00000020   ;#Commissioning interface (RS485)
set WARNSIG_FBintern    0x00000040   ;#Onboard fieldbus

set WARNSIG_Tracking    0x00000100   ;#Tracking warning limit reached
set WARNSIG_STOZero     0x00000400   ;#STO_A and/or STO_B

set WARNSIG_DCBusLow    0x00002000   ;#Low voltage DC bus

set WARNSIG_MotEnc      0x00010000   ;#Onboard motor or machine encoder
set WARNSIG_TempMot     0x00020000   ;#Temperature of motor high
set WARNSIG_TempAmp     0x00040000   ;#Temperature of power amplifier high

set WARNSIG_MemCard     0x00100000   ;#Momory card
set WARNSIG_FBmodule    0x00200000   ;#Optional fieldbus module
set WARNSIG_EncModule   0x00400000   ;#Optional encoder module
set WARNSIG_SafeModule  0x00800000   ;#Optional safety module

set WARNSIG_I2tRes      0x20000000   ;#Braking resistor overload (I�t)
set WARNSIG_I2tAmp      0x40000000   ;#Power amplifier overload (I�t)
set WARNSIG_I2tMot      0x80000000   ;#Motor overload (I�t)

#Definition of Bits of error word (STD.SIG/SIGSR)
set SIG_Gen             0x00000001   ;#General fault
set SIG_LIM             0x00000002   ;#Limit switches (LIMP/LIMN/REF)
set SIG_SWLIM           0x00000004   ;#Out of range (SW limit switches, system tuning)
set SIG_QStop           0x00000008   ;#Quickstop via fieldbus
set SIG_OpMode          0x00000010   ;#Fault in active operating mode
set SIG_RS485           0x00000020   ;#Commissioning interface fault (RS485)
set SIG_FBintern        0x00000040   ;#Onboard fieldbus fault

set SIG_Tracking        0x00000100   ;#Tracking error

set SIG_STOZero         0x00000400   ;#Inputs STO are 0
set SIG_STODiff         0x00000800   ;#Inputs STO different

set SIG_DCBusLow        0x00002000   ;#Low voltage DC bus
set SIG_DCBusHigh       0x00004000   ;#High voltage DC bus
set SIG_MainsMiss       0x00008000   ;#Mains phase missing
set SIG_MotEnc          0x00010000   ;#Onboard motor or machine encoder fault
set SIG_TempMot         0x00020000   ;#Overtemperature (motor)
set SIG_TempAmp         0x00040000   ;#Overtemperature (power amplifier)

set SIG_MemCard         0x00100000   ;#Momory card
set SIG_FBmodule        0x00200000   ;#Optional fieldbus module fault
set SIG_EncModule       0x00400000   ;#Optional encoder module fault
set SIG_SafeModule      0x00800000   ;#Optional safety module fault

set SIG_MotConn         0x04000000   ;#Motor connection fault
set SIG_MotOverCurr     0x08000000   ;#Motor overcurrent/short circuit
set SIG_RS422TooHigh    0x10000000   ;#Frequency of reference signal too high
set SIG_EEPROM          0x20000000   ;#EEPROM fault
set SIG_Boot            0x40000000   ;#System booting (Hardware fault or parameter error)
set SIG_System          0x80000000   ;#System error (e.g. watchdog)

#Definition of some Bits of status word (STD.CTRLWORD)
set STDCTRL_Disable     0x0001
set STDCTRL_Enable      0x0002
set STDCTRL_QuickStop   0x0004
set STDCTRL_FaultReset  0x0008
set STDCTRL_Halt        0x0020
set STDCTRL_ClearHalt   0x0040
set STDCTRL_Continue    0x0080

#Definition of some Bits of status word (DCOM.CTRLWORD)....
set DCOMCTRL_Son         0x0001
set DCOMCTRL_EnaVolt     0x0002
set DCOMCTRL_QuickStop   0x0004
set DCOMCTRL_EnaOp       0x0008
set DCOMCTRL_FaultRes    0x0080
set DCOMCTRL_Halt        0x0100
#.... and combined Bits for STD.CTRLWORD compability
set DCOM_Disable     [expr $DCOMCTRL_EnaVolt + $DCOMCTRL_QuickStop]
set DCOM_Enable      [expr $DCOMCTRL_Son + $DCOMCTRL_EnaVolt + $DCOMCTRL_QuickStop + $DCOMCTRL_EnaOp]
set DCOM_Quickstop   $DCOMCTRL_EnaVolt
set DCOM_FaultReset  $DCOMCTRL_FaultRes
set DCOM_Halt        [expr $DCOM_Enable + $DCOMCTRL_Halt]
set DCOM_ClearHalt   $DCOM_Enable

#Definition of some Bits of status word (STD.STATUSWORD)
set STA_StateMachine    0x0000000F
set STA_StateNotReady   0x00000002
set STA_StateDisabled   0x00000003
set STA_StateReady      0x00000004
set STA_StateSwitchedOn 0x00000005
set STA_StateEnabled    0x00000006
set STA_StateQuickStop  0x00000007
set STA_StateFaultReact 0x00000008
set STA_StateFault      0x00000009

set STA_ErrorActive     0x00000040
set STA_WarningActive   0x00000080
set STA_HaltRequest     0x00000100

set STA_AxisAddInfo2    0x00001000
set STA_AxisAddInfo     0x00002000
set STA_AxisEnd         0x00004000
set STA_AxisInfo        0x00008000

set STA_RefOK           0x00200000
set STA_PosOverrun      0x00800000

#Definition of some Bits of DCOM status word (DCOM.STATUSWORD)
set DCOMSTA_Halt           0x00000100
set DCOMSTA_TargetReached  0x00000400
set DCOMSTA_Bit12          0x00001000
set DCOMSTA_Error          0x00002000
set DCOMSTA_End            0x00004000
set DCOMSTA_RefOk          0x00008000

#meaning of Axis infos:
#       # STA_AxisAddInfo2 # STA_AxisAddInfo    # STA_AxisEnd # STA_AxisInfo
#-------------------------------------------------------------------------
#TRQPRF # --               # target_reached     # x_end       # x_err
#VELPRF # --               # target_reached     # x_end       # x_err
#POSPRF # blended_active   # target_reached     # x_end       # x_err
#GEAR   # --               # --                 # x_end       # x_err
#HOME   # --               # --                 # x_end       # x_err
#MANU   # --               # --                 # x_end       # x_err
#DATSET # --               # sequence finished  # x_end       # x_err
#MTUNE  # --               # --                 # x_end       # x_err
#ATUNE  # --               # processing         # x_end       # x_err

#=========================================================================
# Konstanten im Actionword
# SPG = Software ProfilGenerator
# 0 = Sollgeschwindigkeit Null
# U = Geschwindigkeitsrampe im Zustand "UP" (Beschleunigen)
# D = Geschwindigkeitsrampe im Zustand "DOWN" (Verz�gern)
# C = Geschwindigkeitsrampe im Zustand "CONSTANT" (konstante Geschw.)

set AW_FK0      0x0001    ;# Bit0: Error class 0
set AW_FK1      0x0002    ;# Bit1: Error class 1
set AW_FK2      0x0004    ;# Bit2: Error class 2
set AW_FK3      0x0008    ;# Bit3: Error class 3
set AW_FK4      0x0010    ;# Bit4: Error class 4

set AW_NACT_0   0x0040    ;# Bit6: Drive is at standstill (Istdrehzahl _n_act [1/min] < 9 )
set AW_NACT_P   0x0080    ;# Bit7: Drive rotates clockwise
set AW_NACT_N   0x0100    ;# Bit8: Drive rotates counter-clockwise

set AW_SPG_0    0x0800    ;# Bit11: Profile generator idle (reference speed is 0)
set AW_SPG_D    0x1000    ;# Bit12: Profile generator decelerates
set AW_SPG_U    0x2000    ;# Bit13: Profile generator accelerates
set AW_SPG_C    0x4000    ;# Bit14: Profile generator moves at constant speed

# Sonderfall fuer Warnung "Positionsabweichung bei Disable"
# Diese Funktion gibt es nur beim EC-Motor.
# Um die Testfaelle fuer alle Motorarten einheitlich zu halten sind
# die Bits hier 0 und werden beim Einschalten des Antriebs gesetzt
# falls es ein IFE ist.
set AW_WARN_POSDEV   0x0000   ;# Aktionswort Bit0: Warnung (0 bei Schrittmotor)
set SW_WARN_POSDEV   0x0000   ;# Statuswort  Bit7: Warnung (0 bei Schrittmotor)

#========================================================
# Motoraufloesung
# werden im Baustein "setDefs" (siehe unten) auf den jeweiligen Pr�fling angepasst
set INC_PRO_1U          131072     ;# bei CPD (Default)
set INC_PRO_10U         [expr $INC_PRO_1U * 10]
set INC_PRO_100U        [expr $INC_PRO_1U * 100]
set MAX_TURNS           [expr round(pow(2,31)/$INC_PRO_1U)]

set Enc_Faktor  1
#Auswahl der Quelle zur Pulserzeugung
set pulse_source "Wago_Stepper"

# Kennung wird f�r IclA-NT-Testurm gebraucht, da hier beide Motorvarianten wechselweise eingebaut werden
# wird im jetzt aus Ger�t ausgelesen (DEVCFG.SENSTYPE) in TC_0Init und mit GetDevFeat "MultiTurn" abgefragt
#set Gebertyp "Singleturn"
#array set Gebertyp {
#   1 "ndef"
#   2 "ndef"
#   3 "ndef"
#   4 "ndef"
#}

#========================================================
# Motor_EEProm

set gChkSum              0            ;# Checksumme
set DataFieldSize0     112            ;# Anzahl genutzter Byte in Datenfeld 0
set DataFieldSize1      64            ;# Anzahl genutzter Byte in Datenfeld 1
set DataFieldSize2      80            ;# Anzahl genutzter Byte in Datenfeld 2
set DataFieldSize3      96            ;# Anzahl genutzter Byte in Datenfeld 3
set DataFieldSize4      32            ;# Anzahl genutzter Byte in Datenfeld 4
set DataFieldSize5      16            ;# Anzahl genutzter Byte in Datenfeld 5
set DataFieldSize6      32            ;# Anzahl genutzter Byte in Datenfeld 6

#========================================================
# FastScope
set LimitPoints ""
#========================================================
# HMI LED- und Dotanzeige
#
#      LEDs:  FLT _  EDT_  VAL_ UNIT_
#                |_|   |_|   |_|   |_|
#
#    LED_OP   o   -     -     -     -   o  LED_HI
#                | |   | |   | |   | |
#    LED_MON  o   -     -     -     -
#                | |   | |   | |   | |
#    LED_CON  o   -  o  -  o  -  o  -   o
#
#                     \     \   /      /
#                      ----Kommas------

set HMI_LED_OP     0x0001             ;# Dot-Anzeige im Display
set HMI_LED_MON    0x0002             ;# Dot-Anzeige im Display
set HMI_LED_CON    0x0004             ;# Dot-Anzeige im Display
set HMI_LED_HI     0x0008             ;# Dot-Anzeige im Display
set HMI_LED_OP_B   0x0100             ;# Dot-Anzeige im Display blinkt
set HMI_LED_MON_B  0x0200             ;# Dot-Anzeige im Display blinkt
set HMI_LED_CON_B  0x0400             ;# Dot-Anzeige im Display blinkt
set HMI_LED_HI_B   0x0800             ;# Dot-Anzeige im Display blinkt
set HMI_LED_FLT    0x0010             ;# LED-Anzeige �ber Display
set HMI_LED_EDT    0x0020             ;# LED-Anzeige �ber Display
set HMI_LED_VAL    0x0040             ;# LED-Anzeige �ber Display
set HMI_LED_UNIT   0x0080             ;# LED-Anzeige �ber Display
set HMI_LED_FLT_B  0x1000             ;# LED-Anzeige �ber Display blinkt
set HMI_LED_EDT_B  0x2000             ;# LED-Anzeige �ber Display blinkt
set HMI_LED_VAL_B  0x4000             ;# LED-Anzeige �ber Display blinkt
set HMI_LED_UNIT_B 0x8000             ;# LED-Anzeige �ber Display blinkt
set HMI_Comma      0x0080             ;# LED-Anzeige �ber Display

set waitButton     310                ;# Zeitangabe von J�rgen
set Break_HMITree  0

#========================================================
# sonstige Konstanten
set MaxMainTime               0
set MaxMax62Time              0
set MaxMax250Time             0
set MaxMaxMsTime              0
set MaxMaxFBTime              0
set MaxStackSize              0
set MinStackFree              100000
set MinStackFreeInProz        100
#set Max_iCommutMaxCatch       0
set Min_iqSinCosMinCatch      0x7FFFFFFF
set Max_iqEpsE_b_DiffCatch    0x7FFFFFFF

set BreakPoint 0   ;#Variable und Code um Modbusfehler aufzusp�ren: deaktiviert

set TimeBlock 0    ;#Zeit f�r blockieren des Motors 2

# Auto Tuning Test initialisieren, sorgt daf�r das pro Testdurchlauf
set    ATU_TestDev     0   ;# nur ein Ger�t getuned wird, aber abwechselnd alle

set    glb_AccessExcl  0

set    ActErrChange 0

#Globales Error-Flag (Erkennung von Kommunikationsfehlern, etc.)
set    glb_Error 0

set    prgNum  0   ;# Programmnummer

set    ActInterface 0

set    TestModus "Singel"

set    WAIT_IN_CHECKPACTxx  250  ;# Wartezeit (ms) vor jedem checkPACT, checkPACTUSR

set    ChannelsNumberPointsPer 0   ;# setzen, falls FScope nicht triggert

set    MaxDev 1

set    PrgNr  0
set    PrgVer 0
set    PrgRev 0
set    PrgDat 0
set    ComModul 0
set    ComModulPrgNr 0
set    ComModulFWver 0
set    ComModulRev 0
set    ATVapplVer 0
set    ATVapplBuild 0
set    ATVmotVer 0
set    ATVmotBuild 0
set    ATVbootVer 0
set    ATVbootBuild 0
set    ATVmodVer 0
set    ATVmodBuild 0

set    OPC_servername      0

#========================================================
# Toleranzen
# werden im Baustein "setDefs" (siehe unten) auf den jeweiligen Pr�fling angepasst

# Toleranz fuer PACT in intIncr
set    TOL_POSITION           50    ;# hier Defaultwert, angepasst in setDefs

# in Usr, gilt nur bei 16384Usr/Umdr
set    Toleranz_Lage          10    ;# hier Defaultwert, angepasst in setDefs

# relative Toleranz in % bei Sollwert != 0
set    Toleranz_Nact          0.07  ;# hier Defaultwert, angepasst in setDefs
# absolute Toleranz in U/min bei Sollwert 0
set    Toleranz_Nact_Null     15    ;# hier Defaultwert, angepasst in setDefs

# relative Toleranz in % bei Sollwert != 0
set    Toleranz_Nref          0     ;# hier Defaultwert, angepasst in setDefs
# absolute Toleranz in U/min bei Sollwert 0
set    Toleranz_Nref_Null     1     ;# hier Defaultwert, angepasst in setDefs

# relative Toleranz in % bei Sollwert != 0
set    Toleranz_NrefEA        0.1   ;# hier Defaultwert, angepasst in setDefs
# absolute Toleranz in U/min bei Sollwert 0
set    Toleranz_NrefEA_Null   25    ;# hier Defaultwert, angepasst in setDefs

# absolute Toleranz in U/min bei Sollwert 0
set    Toleranz_NPref         0     ;# hier Defaultwert, angepasst in setDefs
# relative Toleranz in % bei Sollwert != 0
set    Toleranz_NPref_Null    1     ;# hier Defaultwert, angepasst in setDefs

set    Toleranz_Strom         7     ;# ?

set    Toleranz_Iact 25                ;# 0.025A

set    MinNact             600   ;# bei EC Motor sind kleinere Geschwindigkeiten nicht sinnvoll zu testen

set    Tol_Analog0V         40       ;# 40mV f�r OV-Abgleich, 18.05.2009 kloef
set    Tol_Analog           35       ;# mV f�r Analogeing�nge

set    MAX_POS_INCR   2147483647  ;# system limit position in internal increments
set    MAX_VEL_RPM         26400  ;# system limit speed in rpm
set    MAX_ACC_RPMPS     3000000  ;# system limit acceleration in rpm/s

set    MAX_DINT       2147483647
set    MIN_DINT      -2147483648

set    Tolerance_NAct_ASM   15

#definition of timeouts (can be defined global if duration of according function changes)
set timeout_ParamDefaults   4         ;#timeout for PARAM.DEFAULTS in seconds
set timeout_ParamEepromini 15         ;#timeout for PARAM.EEPROMINI in seconds

#=====================================================================
proc setDefs { } {
    #DOC----------------------------------------------------------------
    #DESCRIPTION
    # abh�ngig von Ger�tetyp einige Konstanten definieren, z.B. INC_PRO_1U
    # Aufruf in doPrintDeviceInfos
    #END----------------------------------------------------------------
    global INC_PRO_1U  INC_PRO_10U  INC_PRO_100U
    global COMPUTERNAME
    global MAX_TURNS
    global TOL_POSITION
    global Toleranz_Lage
    global Toleranz_Nact
    global Toleranz_Nact_Null
    global Toleranz_Nref
    global Toleranz_Nref_Null
    global Toleranz_NrefEA
    global Toleranz_NrefEA_Null
    global Toleranz_NPref
    global Toleranz_NPref_Null
    global MinNact
    global Enc_Faktor
    global Tol_Analog0V
    global Tol_Analog
    global Tol_Speed
    global Tol_RFRanalog
    global Tol_RFRDanalog

    # interne Incremente pro Umdrehung
    set INC_PRO_1U  131072

    set INC_PRO_10U         [expr $INC_PRO_1U * 10]
    set INC_PRO_100U        [expr $INC_PRO_1U * 100]

    # max m�glicher Fahrbereich von 0 weg in eine Richtung
    set MAX_TURNS [expr round(pow(2,31)/$INC_PRO_1U)]  ;# in Motorumdrehungen

    #Speef tolerance for reading

    if {[GetDevFeat MVK] } {
	set Tol_Speed       10
	set Tol_RFRanalog  50  ;# for RFR in 0.1 Hz when commanded via AI1
	set Tol_RFRDanalog 100  ;# for RFRD in rpm when commanded via AI1
    } else {
	set Tol_Speed       10
	set Tol_RFRanalog  15  ;# for RFR in 0.1 Hz when commanded via AI1
	set Tol_RFRDanalog 15  ;# for RFRD in rpm when commanded via AI1
    }
    # Pact und PactModulo werden in internen Incrementen zur�ckgeliefert
    # allerdings muss dabei das Messsystem (Geber) ber�cksichtigt werden,
    # es k�nnen ja nicht alle internen Incremente auch tats�chlich angefahren
    # werden:
    #               intIncr/U   GeberIncr/U   intIncr/GeberIncr
    #               -------     -----------   -----------------
    # bei Lex-AC:   131072      131072        1
    # bei Lex-SM:   131072      4000          32,768
    # bei Icla-AC:  32768       32768         1
    # bei Icla-SM:  32768       4000          8,192
    # bei Icla-EC:  32768       12            2730,666
    # bei BLP14     32768       24            1365,333
    if {       [GetDevFeat "MotAC"] } {
	# Faktor 6 ist empirisch ermittelt!
	set TOL_POSITION        [expr round(6   * $INC_PRO_1U/16384)]
    } 
	
    # Toleranz fuer PACTUSER
    # Aber ACHTUNG: das h�ngt nat�rlich davon ab welche Positionsnormierung verwendet wird
    # wenn ein Test andere Normierungen verwendet, muss er eigene Toleranzen definieren
    if { [GetDevFeat "MotAC"] } {
	set Toleranz_Lage       10       ;# in Usr, gilt nur bei 16384 Usr/Umdr!
    } 
	
    # Toleranz f�r NACT
    # es wird unterschieden zwischen drehender Achse und Stillstand
    if { [GetDevFeat "MotAC"] } {
	set Toleranz_Nact       0.07     ;# in % von der Sollgeschwindigkeit, bei Sollwert != 0
	set Toleranz_Nact_Null  15       ;# absolute Toleranz in U/min bei Sollwert 0
	set MinNact             15       ;# kleinere Geschwindigkeiten sind nicht sinnvoll zu testen
    } 

    # Toleranz f�r NREF (Lageregler Ausgang -> Sollgeschwindigkeit f�r Drehzahlregler)
    # Eigentlich m�sste auch beim AC eine Toleranz zugelassen werden. Wenn mit Profilgenerator gefahren
    # wird, dann kann NREF durchaus etwas schwanken, wird ja vom Lageregler berechnet! (230207 ockeg)
    if { [GetDevFeat "MotAC"] } {
	set Toleranz_Nref       0        ;# in % von der Sollgeschwindigkeit, bei Sollwert != 0
	set Toleranz_Nref_Null  1        ;# absolute Toleranz in U/min bei Sollwert 0
    } 

    # Toleranz f�r NREF bei analoger Sollwertvorgabe
    # es wird unterschieden zwischen drehender Achse und Stillstand
    if { [GetDevFeat "MotAC"] } {
	set Toleranz_NrefEA       0.1    ;# in % von der Sollgeschwindigkeit, bei Sollwert != 0
	set Toleranz_NrefEA_Null  25     ;# absolute Toleranz in U/min bei Sollwert 0
    } 

    # Toleranz f�r NPREF (Ausgang vom Profilgenerator)
    # es wird unterschieden zwischen drehender Achse und Stillstand
    if { [GetDevFeat "MotAC"] } {
	set Toleranz_NPref       0       ;# in % von der Sollgeschwindigkeit, bei Sollwert != 0
	set Toleranz_NPref_Null  1       ;# absolute Toleranz in U/min bei Sollwert 0
    } 
	
    # Encoderfaktor f�r die T�rme die an Pr�fling1 nur einen externen 512er Encoder haben (statt 4096er)
    switch -regexp $COMPUTERNAME {
	"WS003287" -
	"WS004780" {
	    # ext. Encoder mit 512 Strichen und Grenzfrequenz 150kHz
	    # bei Servo1-TT und CPD-CAN-TT2
	    # Faktor = 4096 / 512 fuer Positionsberechnung
	    set Enc_Faktor  8
	}
	default {
	    # ext. Encoder mit 4096 Strichen
	    set Enc_Faktor  1
	}
    }

} ;# setDefs

# Tolerances for Nera

global Tolerance_SPD_Rel
global Tolerance_SPD_Min

# SPD (Motor speed in RPM)
set Tolerance_SPD_Rel 0.0        ;# tolerance relative to actual speed
set Tolerance_SPD_Min 2          ;# tolerance minimum

# Log time needed for EEPS / CMI / ETI to get 0
global Debug_NERA_Storing
global Debug_NERA_Storing_Path

set Debug_NERA_Storing 0
set Debug_NERA_Storing_Path "C:/Temp"
