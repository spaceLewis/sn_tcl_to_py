/* Automatically generated - do not change here */

#ifndef _OBJDEFS_H_
#define _OBJDEFS_H_

#define OBJDB_VERSION 0x00010032 /* V1.050 */

#define IX(a)  ((UINT16)(a & 0xFFFF))
#define SIX(a) ((UINT16)((a >> 16) & 0xFF))
#define MAKE_OBJ_ID(ix,six) ((((UINT32)ix) | ((UINT32)six << 16)))
#define MAKE_MB_ADR(a) ((UINT16)((a << 8) | (a >> 15)))

/*INDEX_DESCRIPTION  1  MAND  66  Identification / login */
#define O_MAND                    0x00000001L
#define O_MAND_PRGNR              0x00010001L   /* 1 - Firmware number of device */
#define O_MAND_VERSION            0x00020001L   /* 2 - Firmware version of device */
#define O_MAND_DATE               0x00030001L   /* 3 - Firmware build date of device */
#define O_MAND_REVISION           0x00040001L   /* 4 - Firmware revision of device */
#define O_MAND_CFGPRGNR           0x00050001L   /* 5 - Configuration compatibility program number */
#define O_MAND_CFGVERSCUR         0x00060001L   /* 6 - Configuration compatibility version */
#define O_MAND_FLASHCOMPAT        0x00070001L   /* 7 - Compatibility for flash update */
#define O_MAND_OBJDBVERSION       0x00080001L   /* 8 - Version and revision of object database */
#define O_MAND_CFGVERSOLD         0x00090001L   /* 9 - Configuration backward compatibility version */
#define O_MAND_LOGIN              0x000A0001L   /* 10 - Login for external tools */
#define O_MAND_ACCESSLEVEL        0x000B0001L   /* 11 - Access rights */
#define O_MAND_ACCESSINFO         0x000C0001L   /* 12 - Current access channel */
#define O_MAND_ACCESSEXCL         0x000D0001L   /* 13 - Get exclusive access to access channel */
#define O_MAND_ACCESSLOCK         0x000E0001L   /* 14 - Locking other access channels */
#define O_MAND_CONFIGLOCK         0x000F0001L   /* 15 - Configuration transfer lock */
#define O_MAND_PNAME1             0x00120001L   /* 18 - Product name */
#define O_MAND_PNAME2             0x00130001L   /* 19 - Product name part 2 */
#define O_MAND_PNAME3             0x00140001L   /* 20 - Product name part 3 */
#define O_MAND_PNAME4             0x00150001L   /* 21 - Product name part 4 */
#define O_MAND_SERNUM1            0x00160001L   /* 22 - Device serial number */
#define O_MAND_SERNUM2            0x00170001L   /* 23 - Device serial number part 2 */
#define O_MAND_SERNUM3            0x00180001L   /* 24 - Device serial number part 3 */
#define O_MAND_SERNUM4            0x00190001L   /* 25 - Device serial number part 4 */
#define O_MAND_FLASHREQUEST       0x001A0001L   /* 26 - Flash programming request */
#define O_MAND_STARTUPMSG         0x001C0001L   /* 28 - Start-up message */
#define O_MAND_CPURESET           0x001D0001L   /* 29 - Warmstart */
#define O_MAND_VENDOR1            0x001E0001L   /* 30 - Vendor name */
#define O_MAND_VENDOR2            0x001F0001L   /* 31 - Vendor name part 2 */
#define O_MAND_VENDOR3            0x00200001L   /* 32 - Vendor name part 3 */
#define O_MAND_VENDOR4            0x00210001L   /* 33 - Vendor name part 4 */
#define O_MAND_VENDOR5            0x00220001L   /* 34 - Vendor name part 5 */
#define O_MAND_MNAME1             0x00230001L   /* 35 - Model name */
#define O_MAND_MNAME2             0x00240001L   /* 36 - Model name part 2 */
#define O_MAND_MNAME3             0x00250001L   /* 37 - Model name part 3 */
#define O_MAND_MNAME4             0x00260001L   /* 38 - Model name part 4 */
#define O_MAND_UNAME1             0x00270001L   /* 39 - User-defined application name */
#define O_MAND_UNAME2             0x00280001L   /* 40 - User-defined application name part 2 */
#define O_MAND_UNAME3             0x00290001L   /* 41 - User-defined application name part 3 */
#define O_MAND_UNAME4             0x002A0001L   /* 42 - User-defined application name part 4 */
#define O_MAND_PRODUCTCODE1       0x002B0001L   /* 43 - Product code EAN number */
#define O_MAND_PRODUCTCODE2       0x002C0001L   /* 44 - Product code EAN number part 2 */
#define O_MAND_PRODUCTCODE3       0x002D0001L   /* 45 - Product code EAN number part 3 */
#define O_MAND_PRODUCTCODE4       0x002E0001L   /* 46 - Product code EAN number part 4 */
#define O_MAND_PRGNRCOM           0x002F0001L   /* 47 - Firmware number of communication module */
#define O_MAND_VERSCOM            0x00300001L   /* 48 - Firmware version of communication module */
#define O_MAND_REVCOM             0x00310001L   /* 49 - Firmware revision of communication module */
#define O_MAND_DEVICEFEATURES     0x00320001L   /* 50 - Device features */
#define O_MAND_LOADERNR           0x00330001L   /* 51 - Firmware number of update loader */
#define O_MAND_LOADERVERS         0x00340001L   /* 52 - Firmware version of update loader */
#define O_MAND_LOADERDATE         0x00350001L   /* 53 - Firmware build date of update loader */
#define O_MAND_LOADERREV          0x00360001L   /* 54 - Firmware revision of update loader */
#define O_MAND_PUBLICKEY1         0x00370001L   /* 55 - Public Key part 1 / 2 */
#define O_MAND_PUBLICKEY2         0x00380001L   /* 56 - Public Key part 2 / 2 */
#define O_MAND_CUSTCODEREAD       0x00390001L   /* 57 - Customer code */
#define O_MAND_CUSTCODEWRITE      0x003A0001L   /* 58 - Customer code used by SoMove only for protection */
#define O_MAND_SERNUMBMI1         0x003B0001L   /* 59 - BMIserial number part1 */
#define O_MAND_SERNUMBMI2         0x003C0001L   /* 60 - BMIserial number part2 */
#define O_MAND_SERNUMBMI3         0x003D0001L   /* 61 - BMIserial number part3 */
#define O_MAND_SERNUMBMI4         0x003E0001L   /* 62 - BMIserial number part4 */
#define O_MAND_BMICODE1           0x003F0001L   /* 63 - Product code EAN number BMI part1 */
#define O_MAND_BMICODE2           0x00400001L   /* 64 - Product code EAN number BMI part2 */
#define O_MAND_BMICODE3           0x00410001L   /* 65 - Product code EAN number BMI part3 */
#define O_MAND_BMICODE4           0x00420001L   /* 66 - Product code EAN number BMI part4 */

/*INDEX_DESCRIPTION  2  DEVCFG  35  Device configuration */
#define O_DEVCFG                  0x00000002L
#define O_DEVCFG_IDCPU            0x00010002L   /* 1 - Controller board identification */
#define O_DEVCFG_IDPOWER          0x00020002L   /* 2 - Power stage identification */
#define O_DEVCFG_IDMODCOM         0x00030002L   /* 3 - Communication-module identification */
#define O_DEVCFG_IDMODENC         0x00040002L   /* 4 - Encoder-module identification */
#define O_DEVCFG_IDMODSAM         0x00050002L   /* 5 - Safety-module identification */
#define O_DEVCFG_IDCUSTOM         0x00060002L   /* 6 - Customer specific identification */
#define O_DEVCFG_IDHBRAKE         0x00070002L   /* 7 - reserved: Holding brake identification */
#define O_DEVCFG_IDMGEAR          0x00080002L   /* 8 - reserved: Mechanical gear identification */
#define O_DEVCFG_IDMOTORENC       0x00090002L   /* 9 - reserved: Motor encoder identification */
#define O_DEVCFG_IDPOWERCFG       0x000A0002L   /* 10 - Power stage ID for configuration compatibility */
#define O_DEVCFG_MODCOMVER        0x000B0002L   /* 11 - Communication-module firmware version */
#define O_DEVCFG_MOTNAME1         0x000C0002L   /* 12 - Motorname part 1/5 */
#define O_DEVCFG_MOTNAME2         0x000D0002L   /* 13 - Motorname part 2/5 */
#define O_DEVCFG_MOTNAME3         0x000E0002L   /* 14 - Motorname part 3/5 */
#define O_DEVCFG_MOTNAME4         0x000F0002L   /* 15 - Motorname part 4/5 */
#define O_DEVCFG_MOTNAME5         0x00100002L   /* 16 - Motorname part 5/5 */
#define O_DEVCFG_HWTYPECPU        0x00110002L   /* 17 - Hardware type of cpu */
#define O_DEVCFG_HWVERSCPU        0x00120002L   /* 18 - Hardware version of cpu */
#define O_DEVCFG_HWTYPEAMP        0x00130002L   /* 19 - Hardware type of power amplifier */
#define O_DEVCFG_HWVERSAMP        0x00140002L   /* 20 - Hardware Version of power ampilfier */
#define O_DEVCFG_HWTYPESLOT1      0x00150002L   /* 21 - Hardware type of slot 1 */
#define O_DEVCFG_HWVERSSLOT1      0x00160002L   /* 22 - Hardware version of slot 1 */
#define O_DEVCFG_PRGNRSLOT1       0x00170002L   /* 23 - Firmware number of slot 1 */
#define O_DEVCFG_FWVERSSLOT1      0x00180002L   /* 24 - Firmware version of slot 1 */
#define O_DEVCFG_FWREVSLOT1       0x00190002L   /* 25 - Firmware revision of slot 1 */
#define O_DEVCFG_HWTYPESLOT2      0x001A0002L   /* 26 - Hardware type of slot 2 */
#define O_DEVCFG_HWVERSSLOT2      0x001B0002L   /* 27 - Hardware version of slot 2 */
#define O_DEVCFG_PRGNRSLOT2       0x001C0002L   /* 28 - Firmware number of slot 2 */
#define O_DEVCFG_FWVERSSLOT2      0x001D0002L   /* 29 - Firmware version of slot 2 */
#define O_DEVCFG_FWREVSLOT2       0x001E0002L   /* 30 - Firmware revision of slot 2 */
#define O_DEVCFG_HWTYPESLOT3      0x001F0002L   /* 31 - Hardware type of slot 3 */
#define O_DEVCFG_HWVERSSLOT3      0x00200002L   /* 32 - Hardware version of slot 3 */
#define O_DEVCFG_PRGNRSLOT3       0x00210002L   /* 33 - Firmware number of slot 3 */
#define O_DEVCFG_FWVERSSLOT3      0x00220002L   /* 34 - Firmware version of slot 3 */
#define O_DEVCFG_FWREVSLOT3       0x00230002L   /* 35 - Firmware revision of slot 3 */

/*INDEX_DESCRIPTION  4  PARAM  25  Device parameter management */
#define O_PARAM                   0x00000004L
#define O_PARAM_STORE             0x00010004L   /* 1 - Save parameter values to EEPROM */
#define O_PARAM_DEFAULTS          0x00020004L   /* 2 - Restore factory settings (default values) */
#define O_PARAM_MSTORE            0x00030004L   /* 3 - Fertigungsdaten in EEPROM-Speicher sichern */
#define O_PARAM_EEPROMINI         0x00040004L   /* 4 - Formatierung des kompletten CPU-EEPROMs */
#define O_PARAM_PASSW             0x00050004L   /* 5 - Zugangscode */
#define O_PARAM_PROTECTION        0x00060004L   /* 6 - Zugriffschutz (reserviert) */
#define O_PARAM_CTRLRES           0x00070004L   /* 7 - Reset controller parameters */
#define O_PARAM_PARUSERRESET      0x00080004L   /* 8 - Reset user parameters */
#define O_PARAM_BLOCKINITUP       0x00090004L   /* 9 - File transfer initiate upload */
#define O_PARAM_BLOCKINITDOWN     0x000A0004L   /* 10 - File transfer: initiate download */
#define O_PARAM_BLOCKLENGTH       0x000B0004L   /* 11 - File transfer: file length */
#define O_PARAM_BLOCKDATA         0x000C0004L   /* 12 - File transfer: data */
#define O_PARAM_FLASHACTION       0x000D0004L   /* 13 - Flash-Aktion */
#define O_PARAM_FLASHDATA         0x000E0004L   /* 14 - Flash-Daten */
#define O_PARAM_STOREBLOCK        0x000F0004L   /* 15 - Save parameter values to EEPROM by block */
#define O_PARAM_MOTCONFIG         0x00100004L   /* 16 - Handling of the motor configuration */
#define O_PARAM_MEMCARDMNG        0x00110004L   /* 17 - Memory card management */
#define O_PARAM_COMRESET          0x00130004L   /* 19 - Fieldbus communication reset */
#define O_PARAM_USRRESCALECMD     0x00140004L   /* 20 - Recalculation of parameters with user-defined units */
#define O_PARAM_USRRESCALEINFO    0x00150004L   /* 21 - Status of recalculation of the parameters with user-defined units */
#define O_PARAM_USRRESCALERRINFO  0x00160004L   /* 22 - Additional information on error during recalculation */
#define O_PARAM_FWUPDATEADMIN     0x00170004L   /* 23 - FwUpdateAdmin */
#define O_PARAM_FWUPDATEINFO      0x00180004L   /* 24 - FwUpdateInfo */
#define O_PARAM_STOREPOWER        0x00190004L   /* 25 - Handling of power stage parameter */

/*INDEX_DESCRIPTION  5  DEVICE  53  Device settings */
#define O_DEVICE                  0x00000005L
#define O_DEVICE_DEVCONTROL       0x00010005L   /* 1 - Specification of the control mode */
#define O_DEVICE_RS422IOMODE      0x00020005L   /* 2 - Selection of signal type for PTI interface */
#define O_DEVICE_REFEXT           0x00030005L   /* 3 - Operating mode */
#define O_DEVICE_IOENABLEMODE     0x00040005L   /* 4 - Enable the power stage as defined in IO_AutoEnable also after error */
#define O_DEVICE_SUPCOMM          0x00050005L   /* 5 - Commutation monitoring */
#define O_DEVICE_RINHIBIT         0x00060005L   /* 6 - Enabling the power stage at PowerOn */
#define O_DEVICE_ADDTBRAKEOFF     0x00070005L   /* 7 - Additional time delay for releasing the holding brake */
#define O_DEVICE_ADDTBRAKEON      0x00080005L   /* 8 - Additional time delay for applying the holding brake */
#define O_DEVICE_BALLAST          0x00090005L   /* 9 - Selection of type of braking resistor */
#define O_DEVICE_ERRVOLT          0x000A0005L   /* 10 - Error response to missing mains phase */
#define O_DEVICE_FLTPDIFF         0x000B0005L   /* 11 - Error response to following error */
#define O_DEVICE_ACTIVEDEVCTRL    0x000C0005L   /* 12 - current selection of device comand interface */
#define O_DEVICE_MOTTYPE          0x000D0005L   /* 13 - Configured motor type */
#define O_DEVICE_PWM              0x000E0005L   /* 14 - Switching frequency of power stage */
#define O_DEVICE_MAINSMON         0x000F0005L   /* 15 - Detection and monitoring of mains phases */
#define O_DEVICE_GNDSHORTMON      0x00100005L   /* 16 - Ground fault monitoring */
#define O_DEVICE_DTBALEXT         0x00110005L   /* 17 - Maximum permissible switch-on time of external braking resistor */
#define O_DEVICE_PBALEXT          0x00120005L   /* 18 - Nominal power of external braking resistor */
#define O_DEVICE_RBALEXT          0x00130005L   /* 19 - Resistance value of external braking resistor */
#define O_DEVICE_ESIMSCALE        0x00150005L   /* 21 - Resolution of encoder simulation */
#define O_DEVICE_SETENC1POSABSUSR 0x00160005L   /* 22 - Adjustment of absolute position of encoder 1 */
#define O_DEVICE_IOGEARMODE       0x00170005L   /* 23 - Processing mode for operating mode Electronic Gear */
#define O_DEVICE_IOJOGMODE        0x00180005L   /* 24 - Selection of jog method */
#define O_DEVICE_SPVFLTACTIME     0x00190005L   /* 25 - Max. allowed break time of mains supply */
#define O_DEVICE_SETENCPOSACK     0x001A0005L   /* 26 - State of directly set the motor encoder position */
#define O_DEVICE_ESIMACTIVATE     0x001F0005L   /* 31 - Type of usage of PTO interface */
#define O_DEVICE_MAINSCHOKE       0x00200005L   /* 32 - Mains reactor */
#define O_DEVICE_SHIFTENCWRKRG    0x00210005L   /* 33 - Shifting of the encoder working range */
#define O_DEVICE_ERRI2TBAL        0x00220005L   /* 34 - Error response to 100% I2t braking resistor */
#define O_DEVICE_QUASIABS         0x00230005L   /* 35 - Simulation of absolute position at power cycling */
#define O_DEVICE_SETENC2POSABSUSR 0x00240005L   /* 36 - Adjustment of absolute position of encoder 2 */
#define O_DEVICE_ABSPOSENCSOURCE  0x00250005L   /* 37 - Source for setting absolute encoder position */
#define O_DEVICE_DCBUSCOMP        0x00260005L   /* 38 - DC bus compatibility LXM32 and ATV32 */
#define O_DEVICE_MECHVAR1         0x00270005L   /* 39 - Mechanic used for scaling - variable 1 */
#define O_DEVICE_MECHVAR2         0x00280005L   /* 40 - Mechanic used for scaling - variable 2 */
#define O_DEVICE_MECHVAR3         0x00290005L   /* 41 - Mechanic used for scaling - variable 3 */
#define O_DEVICE_MECHVAR4         0x002A0005L   /* 42 - Mechanic used for scaling - variable 4 */
#define O_DEVICE_MECHVAR5         0x002B0005L   /* 43 - Mechanic used for scaling - variable 5 */
#define O_DEVICE_MECHVAR6         0x002C0005L   /* 44 - Mechanic used for scaling - variable 6 */
#define O_DEVICE_MECHVAR7         0x002D0005L   /* 45 - Mechanic used for scaling - variable 7 */
#define O_DEVICE_MECHVAR8         0x002E0005L   /* 46 - Mechanic used for scaling - variable 8 */
#define O_DEVICE_PTIPULSEFILTER   0x002F0005L   /* 47 - Filter time for input signals at the PTI interface */
#define O_DEVICE_LXMATVUDCBAL     0x00300005L   /* 48 - DC bus level for brake resistor switching LXM - ATV (1~ devices) */
#define O_DEVICE_LXMATVUDCMAX     0x00310005L   /* 49 - max allowed DC bus voltage LXM - ATV (1~ devices) */
#define O_DEVICE_ESIMSCALEHIGH    0x00320005L   /* 50 - Encoder simulation: High resolution */
#define O_DEVICE_ESIMPHASESHIFT   0x00330005L   /* 51 - Encoder simulation: Phase shift for pulse output */
#define O_DEVICE_ADDFAULTRESET    0x00340005L   /* 52 - Additional 'Fault Reset' for the signal input function 'Enable' */
#define O_DEVICE_SETOFFENC2PACT   0x00350005L   /* 53 - Offset for actual position value 2 */

/*INDEX_DESCRIPTION  6  MOTION  70  Motion settings */
#define O_MOTION                  0x00000006L
#define O_MOTION_SYMRAMP          0x00010006L   /* 1 - Acceleration and deceleration of the motion profile for velocity */
#define O_MOTION_RAMPDATOPT       0x00020006L   /* 2 - Acceleration and deceleration for the Drive Profile Lexium */
#define O_MOTION_ENASWLIM         0x00030006L   /* 3 - Monitoring of software limit switches */
#define O_MOTION_SWLIMP           0x00040006L   /* 4 - Positive position limit for software limit switch */
#define O_MOTION_SWLIMN           0x00050006L   /* 5 - Negative position limit for software limit switch */
#define O_MOTION_SIGLIMMODE       0x00060006L   /* 6 - Response to active limit switch during enabling of power stage */
#define O_MOTION_NORMPOSDENOM     0x00070006L   /* 7 - Position scaling: Denominator */
#define O_MOTION_NORMPOSNUM       0x00080006L   /* 8 - Position scaling: Numerator */
#define O_MOTION_SPEEDLIMPROF     0x00090006L   /* 9 - Maximum velocity of the motion profile for velocity */
#define O_MOTION_UPRAMP0          0x000A0006L   /* 10 - Acceleration of the motion profile for velocity */
#define O_MOTION_DOWNRAMP0        0x000B0006L   /* 11 - Deceleration of the motion profile for velocity */
#define O_MOTION_INVDIR           0x000C0006L   /* 12 - Inversion of direction of movement */
#define O_MOTION_JERKFILTER       0x000D0006L   /* 13 - Jerk limitation of the motion profile for velocity */
#define O_MOTION_SIGMODEREF       0x000E0006L   /* 14 - Signal evaluation for reference switch */
#define O_MOTION_SIGMODELIMN      0x000F0006L   /* 15 - Signal evaluation for negative limit switch */
#define O_MOTION_SIGMODELIMP      0x00100006L   /* 16 - Signal evaluation for positive limit switch */
#define O_MOTION_DISHWLIM         0x00110006L   /* 17 - Temporary deactivation of hardware limit switches */
#define O_MOTION_QUSTOPRAMP       0x00120006L   /* 18 - Deceleration ramp for Quick Stop */
#define O_MOTION_IGNOREQUSCODE    0x00130006L   /* 19 - Ignore Quick Stop option code */
#define O_MOTION_SPEEDWIN         0x00140006L   /* 20 - Velocity window, permissible deviation */
#define O_MOTION_SPEEDWINTIME     0x00150006L   /* 21 - Velocity window, time */
#define O_MOTION_HOMINGREQ        0x00160006L   /* 22 - Absolute positioning only after homing */
#define O_MOTION_HALTREACTION     0x00170006L   /* 23 - Halt option code */
#define O_MOTION_QSTOPREACTION    0x00180006L   /* 24 - Quick Stop option code */
#define O_MOTION_SPVPOSDEVIAT     0x00190006L   /* 25 - Monitoring of position deviation */
#define O_MOTION_SPVSPDDEVIAT     0x001A0006L   /* 26 - Monitoring of velocity deviation */
#define O_MOTION_SPVSPDVAL        0x001B0006L   /* 27 - Monitoring of velocity threshold */
#define O_MOTION_SPVCURRVAL       0x001C0006L   /* 28 - Monitoring of current threshold */
#define O_MOTION_SPVCHKWINTIME    0x001D0006L   /* 29 - Monitoring of time window */
#define O_MOTION_SPEEDLIMVAR2     0x001E0006L   /* 30 - Velocity limitation via input */
#define O_MOTION_BLENDTYPE        0x001F0006L   /* 31 - Auswahl des Typs der überblendeten Bewegung */
#define O_MOTION_BLENDABSPOS      0x00200006L   /* 32 - Absolutposition für Bearbeitung der überlagerten Bewegung */
#define O_MOTION_SCALSPEEDDENOM   0x00210006L   /* 33 - Velocity scaling: Denominator */
#define O_MOTION_SCALSPEEDNUM     0x00220006L   /* 34 - Velocity scaling: Numerator */
#define O_MOTION_PDIFMAX          0x00230006L   /* 35 - Maximum load-dependent position deviation (following error) */
#define O_MOTION_POSWIN           0x00240006L   /* 36 - Standstill window, permissible control deviation */
#define O_MOTION_POSWINTM         0x00250006L   /* 37 - Standstill window, time */
#define O_MOTION_PWINTOUT         0x00260006L   /* 38 - Timeout time for standstill window monitoring */
#define O_MOTION_CURRLIMVAR2      0x00270006L   /* 39 - Current limitation via input */
#define O_MOTION_SPEEDZEROCLAMP   0x00280006L   /* 40 - Velocity limit for Zero Clamp */
#define O_MOTION_PDIFWARN         0x00290006L   /* 41 - Maximum load-dependent position deviation (warning) */
#define O_MOTION_RAMPCURRCTRL     0x002A0006L   /* 42 - Slope setting of the motion profile for torque */
#define O_MOTION_ENASPEEDPROFILE  0x002B0006L   /* 43 - Activation of the motion profile for velocity */
#define O_MOTION_ENACURRPROFILE   0x002C0006L   /* 44 - Activation of the motion profile for torque */
#define O_MOTION_TORQWIN          0x002D0006L   /* 45 - Torque window, permissible deviation */
#define O_MOTION_TORQWINTIME      0x002E0006L   /* 46 - Torque window, time */
#define O_MOTION_MODESWITCH       0x002F0006L   /* 47 - Operating mode for signal input function Operating Mode Switch */
#define O_MOTION_SCALRAMPDENOM    0x00300006L   /* 48 - Ramp scaling: Denominator */
#define O_MOTION_SCALRAMPNUM      0x00310006L   /* 49 - Ramp scaling: Numerator */
#define O_MOTION_USRPMF           0x00320006L   /* 50 - Position scaling: Multiplication factor */
#define O_MOTION_USRPPU           0x00330006L   /* 51 - Position scaling: Physical unit */
#define O_MOTION_USRVMF           0x00340006L   /* 52 - Velocity scaling: Multiplication factor */
#define O_MOTION_USRVPU           0x00350006L   /* 53 - Velocity scaling: Physical unit */
#define O_MOTION_USRAMF           0x00360006L   /* 54 - Ramp scaling: Multiplication factor */
#define O_MOTION_USRAPU           0x00370006L   /* 55 - Ramp scaling: Physical unit */
#define O_MOTION_AXISTYPE         0x00380006L   /* 56 - Activation of Modulo */
#define O_MOTION_MODRNGMIN        0x00390006L   /* 57 - Minimum position of modulo range */
#define O_MOTION_MODRNGMAX        0x003A0006L   /* 58 - Maximum position of modulo range */
#define O_MOTION_MODABSHND        0x003B0006L   /* 59 - Direction of absolute movement with Modulo */
#define O_MOTION_MODMOVOVR        0x003C0006L   /* 60 - Multiple ranges for absolut movement with Modulo */
#define O_MOTION_COMPSYNCMOT      0x003D0006L   /* 61 - Compatibility parameter sync operating modes */
#define O_MOTION_PDIFMAXUSR       0x003E0006L   /* 62 - Maximum load-dependent position deviation (following error) */
#define O_MOTION_SPVPOSDEVIATUSR  0x003F0006L   /* 63 - Monitoring of position deviation */
#define O_MOTION_POSWINUSR        0x00400006L   /* 64 - Standstill window, permissible control deviation */
#define O_MOTION_BACKLASHSTART    0x00410006L   /* 65 - Processing mode of backlash compensation */
#define O_MOTION_BLSHCORRPOS      0x00420006L   /* 66 - Position value for backlash compensation */
#define O_MOTION_CPFASTSPEEDLIM   0x00430006L   /* 67 - Activation fast Velocity limitation via input */
#define O_MOTION_BLSHCORRTIME     0x00440006L   /* 68 - Processing time for backlash compensation */
#define O_MOTION_MCHALTRAMP       0x00450006L   /* 69 - Deceleration ramp for Halt request by motion controller */
#define O_MOTION_MCSTOPRAMP       0x00460006L   /* 70 - Deceleration ramp for Stop request by motion controller */

/*INDEX_DESCRIPTION  7  IOF  14  IO functions */
#define O_IOF                     0x00000007L
#define O_IOF_FUNCDI0             0x00010007L   /* 1 - Function Input DI0 */
#define O_IOF_FUNCDI1             0x00020007L   /* 2 - Function Input DI1 */
#define O_IOF_FUNCDI2             0x00030007L   /* 3 - Function Input DI2 */
#define O_IOF_FUNCDI3             0x00040007L   /* 4 - Function Input DI3 */
#define O_IOF_FUNCDI4             0x00050007L   /* 5 - Function Input DI4 */
#define O_IOF_FUNCDI5             0x00060007L   /* 6 - Function Input DI5 */
#define O_IOF_FUNCDI6             0x00070007L   /* 7 - Function Input DI6 */
#define O_IOF_FUNCDI7             0x00080007L   /* 8 - Function Input DI7 */
#define O_IOF_FUNCDQ0             0x00090007L   /* 9 - Function Output DQ0 */
#define O_IOF_FUNCDQ1             0x000A0007L   /* 10 - Function Output DQ1 */
#define O_IOF_FUNCDQ2             0x000B0007L   /* 11 - Function Output DQ2 */
#define O_IOF_FUNCDQ3             0x000C0007L   /* 12 - Function Output DQ3 */
#define O_IOF_FUNCDQ4             0x000D0007L   /* 13 - Function Output DQ4 */
#define O_IOF_FUNCDQ5             0x000E0007L   /* 14 - Function Output DQ5 */

/*INDEX_DESCRIPTION  8  IO  38  Digital inputs/outputs */
#define O_IO                      0x00000008L
#define O_IO_IOACT                0x00010008L   /* 1 - Physical status of the digital inputs and outputs */
#define O_IO_POSRS422IN           0x00050008L   /* 5 - Actual position at PTI interface */
#define O_IO_VELRS422IN           0x00060008L   /* 6 - Actual velocity at PTI interface */
#define O_IO_RS422INVERT          0x00070008L   /* 7 - Inversion of direction of counting at PTI interface */
#define O_IO_SIMURS422            0x00090008L   /* 9 - Simulation Gebergeschwindigkeit an RS422-Schnittstelle */
#define O_IO_BRAKECTRL            0x000A0008L   /* 10 - Processing of holding brake */
#define O_IO_BRAKESTATE           0x000B0008L   /* 11 - Status of holding brake */
#define O_IO_DINAVAIL             0x000C0008L   /* 12 - Vorhandene logische Signaleingänge */
#define O_IO_DOUTAVAIL            0x000D0008L   /* 13 - Vorhandene logische Signalausgänge */
#define O_IO_DINGET               0x000F0008L   /* 15 - Status of digital inputs */
#define O_IO_DOUTGET              0x00100008L   /* 16 - Status of digital outputs */
#define O_IO_DOUTSET              0x00110008L   /* 17 - Setting the digital outputs directly */
#define O_IO_DININV               0x00120008L   /* 18 - Inversion of digital inputs */
#define O_IO_DOUTINV              0x00130008L   /* 19 - Inversion of digital outputs */
#define O_IO_DINFORCECNF          0x001A0008L   /* 26 - Forcebarkeit Eingänge */
#define O_IO_DOUTFORCECNF         0x001B0008L   /* 27 - Forcebarkeit Ausgänge */
#define O_IO_DINFORCEMSK          0x001C0008L   /* 28 - Forcemaske Eingänge */
#define O_IO_DOUTFORCEMSK         0x001D0008L   /* 29 - Forcemaske Ausgänge */
#define O_IO_DINFORCEVAL          0x001E0008L   /* 30 - Forcewert Eingänge */
#define O_IO_DOUTFORCEVAL         0x001F0008L   /* 31 - Forcewert Ausgänge */
#define O_IO_DI0DEBOUNCE          0x00200008L   /* 32 - Debounce time of DI0 */
#define O_IO_DI1DEBOUNCE          0x00210008L   /* 33 - Debounce time of DI1 */
#define O_IO_DI2DEBOUNCE          0x00220008L   /* 34 - Debounce time of DI2 */
#define O_IO_DI3DEBOUNCE          0x00230008L   /* 35 - Debounce time of DI3 */
#define O_IO_DI4DEBOUNCE          0x00240008L   /* 36 - Debounce time of DI4 */
#define O_IO_DI5DEBOUNCE          0x00250008L   /* 37 - Debounce time of DI5 */
#define O_IO_DPOWINGET            0x00260008L   /* 38 - Status of the inputs for the safety function STO */

/*INDEX_DESCRIPTION  9  ANALOG  27  Analog inputs */
#define O_ANALOG                  0x00000009L
#define O_ANALOG_VALSC1           0x00010009L   /* 1 - Analog 1: Value of input voltage */
#define O_ANALOG_TAUANA1          0x00020009L   /* 2 - Analog 1: Filter time constant */
#define O_ANALOG_FORCEACT1        0x00030009L   /* 3 - Analog 1: Force activation */
#define O_ANALOG_FORCEVAL1        0x00040009L   /* 4 - Analog 1: Force value */
#define O_ANALOG_VALSC2           0x00050009L   /* 5 - Analog 2: Value of input voltage */
#define O_ANALOG_FORCEACT2        0x00070009L   /* 7 - Analog 2: Force activation */
#define O_ANALOG_FORCEVAL2        0x00080009L   /* 8 - Analog 2: Force value */
#define O_ANALOG_WINANA1          0x00090009L   /* 9 - Analog 1: Zero voltage window */
#define O_ANALOG_WINANA2          0x000A0009L   /* 10 - Analog 2: Zero voltage window */
#define O_ANALOG_OFFSETANA1       0x000B0009L   /* 11 - Analog 1: Offset voltage */
#define O_ANALOG_OFFSETANA2       0x000C0009L   /* 12 - Analog 2: Offset voltage */
#define O_ANALOG_VALANA1AND2      0x000D0009L   /* 13 - Spannungswerte AI1 und AI2 */
#define O_ANALOG_ANA1MODE         0x000E0009L   /* 14 - Analog 1: Type of usage */
#define O_ANALOG_ANA1LIMCURR      0x000F0009L   /* 15 - Analog 1: Limitation of current at 10 V */
#define O_ANALOG_ANA1LIMSPEED     0x00100009L   /* 16 - Analog 1: Limitation of velocity at 10 V */
#define O_ANALOG_NSC1             0x00110009L   /* 17 - Analog 1: Target velocity at 10 V in operating mode Profile Velocity */
#define O_ANALOG_ISC1             0x00120009L   /* 18 - Analog 1: Target torque at 10 V in operating mode Profile Torque */
#define O_ANALOG_ANA2MODE         0x00130009L   /* 19 - Analog 2: Type of usage */
#define O_ANALOG_ANA2LIMCURR      0x00140009L   /* 20 - Analog 2: Limitation of current at 10 V */
#define O_ANALOG_ANA2LIMSPEED     0x00150009L   /* 21 - Analog 2: Limitation of velocity at 10 V */
#define O_ANALOG_NSC2             0x00160009L   /* 22 - Analog 2: Target velocity at 10 V in operating mode Profile Velocity */
#define O_ANALOG_ISC2             0x00170009L   /* 23 - Analog 2: Target torque at 10 V in operating mode Profile Torque */
#define O_ANALOG_TAUANA2          0x00180009L   /* 24 - Analog 2: Filter time constant */
#define O_ANALOG_ANA2WINTIME      0x00190009L   /* 25 - Analog 2: Voltage window time */
#define O_ANALOG_ANA2WIN          0x001A0009L   /* 26 - Analog 2: Voltage window */
#define O_ANALOG_ANA2ACCMINLIM    0x001B0009L   /* 27 - Analog 2: min. voltage for acceleration/deceleration limitation */

/*INDEX_DESCRIPTION  10  CAPT  42  Fast position capture */
#define O_CAPT                    0x0000000AL
#define O_CAPT_CAPSTATUS          0x0001000AL   /* 1 - Status of the capture inputs */
#define O_CAPT_CAP1CONFIG         0x0002000AL   /* 2 - Capture input 1 configuration */
#define O_CAPT_CAP2CONFIG         0x0003000AL   /* 3 - Capture input 2 configuration */
#define O_CAPT_CAP1ACTIVATE       0x0004000AL   /* 4 - Capture input 1 start/stop */
#define O_CAPT_CAP2ACTIVATE       0x0005000AL   /* 5 - Capture input 2 start/stop */
#define O_CAPT_CAP1POSUSR         0x0006000AL   /* 6 - Capture input 1 captured position */
#define O_CAPT_CAP2POSUSR         0x0007000AL   /* 7 - Capture input 2 captured position */
#define O_CAPT_CAP1COUNTER        0x0008000AL   /* 8 - Capture input 1 event counter */
#define O_CAPT_CAP2COUNTER        0x0009000AL   /* 9 - Capture input 2 event counter */
#define O_CAPT_CAP1SOURCE         0x000A000AL   /* 10 - Capture input 1 encoder source */
#define O_CAPT_CAP2SOURCE         0x000B000AL   /* 11 - Capture input 2 encoder source */
#define O_CAPT_CAP1POSINT         0x000F000AL   /* 15 - Capture input 1 captured position (internal units) */
#define O_CAPT_CAP2POSINT         0x0010000AL   /* 16 - Capture input 2 captured position (internal units) */
#define O_CAPT_CAP3CONFIG         0x0011000AL   /* 17 - Capture input 3 configuration */
#define O_CAPT_CAP3ACTIVATE       0x0012000AL   /* 18 - Capture input 3 start/stop */
#define O_CAPT_CAP3POSUSR         0x0013000AL   /* 19 - Capture input 3 captured position */
#define O_CAPT_CAP3COUNTER        0x0014000AL   /* 20 - Capture input 3 event counter */
#define O_CAPT_CAP3SOURCE         0x0015000AL   /* 21 - Capture input 3 encoder source */
#define O_CAPT_CAP3POSINT         0x0016000AL   /* 22 - Capture input 3 captured position (internal units) */
#define O_CAPT_CAP1CNTCONS        0x0017000AL   /* 23 - Capture input 1 event counter (consistent) */
#define O_CAPT_CAP1POSUSRCONS     0x0018000AL   /* 24 - Capture input 1 captured position (consistent) */
#define O_CAPT_CAP2CNTCONS        0x0019000AL   /* 25 - Capture input 2 event counter (consistent) */
#define O_CAPT_CAP2POSUSRCONS     0x001A000AL   /* 26 - Capture input 2 captured position (consistent) */
#define O_CAPT_CAP3CNTCONS        0x001B000AL   /* 27 - Capture input 3 event counter (consistent) */
#define O_CAPT_CAP3POSUSRCONS     0x001C000AL   /* 28 - Capture input 3 captured position (consistent) */
#define O_CAPT_CAPCONTROL         0x001E000AL   /* 30 - Capture controlword */
#define O_CAPT_CAPSTATUSLIST      0x001F000AL   /* 31 - Capture status */
#define O_CAPT_CAPDIFF1           0x0021000AL   /* 33 - Capture difference probing 1 */
#define O_CAPT_CAPDIFF2           0x0022000AL   /* 34 - Capture difference probing 2 */
#define O_CAPT_CAPDIFFVAL1        0x0023000AL   /* 35 - Capture input 1 captured difference value */
#define O_CAPT_CAPDIFFVAL2        0x0024000AL   /* 36 - Capture input 2 captured difference value */
#define O_CAPT_CAPVAL1POSEDGE     0x0025000AL   /* 37 - Capture input 1 captured position at rising edge */
#define O_CAPT_CAPVAL1NEGEDGE     0x0026000AL   /* 38 - Capture input 1 captured position at falling edge */
#define O_CAPT_CAPVAL2POSEDGE     0x0027000AL   /* 39 - Capture input 2 captured position at rising edge */
#define O_CAPT_CAPVAL2NEGEDGE     0x0028000AL   /* 40 - Capture input 2 captured position at falling edge */
#define O_CAPT_CAP1TIMEFILTER     0x0029000AL   /* 41 - Capture input 1 Time Filter configuration */
#define O_CAPT_CAP2TIMEFILTER     0x002A000AL   /* 42 - Capture input 2 Time Filter configuration */

/*INDEX_DESCRIPTION  11  PREG  22  Position register */
#define O_PREG                    0x0000000BL
#define O_PREG_STATUS             0x0001000BL   /* 1 - Status of the position register channels */
#define O_PREG_CH1START           0x0002000BL   /* 2 - Start/stop of position register channel 1 */
#define O_PREG_CH2START           0x0003000BL   /* 3 - Start/stop of position register channel 2 */
#define O_PREG_CH1MODE            0x0004000BL   /* 4 - Selection of comparison criterion for position register channel 1 */
#define O_PREG_CH2MODE            0x0005000BL   /* 5 - Selection of comparison criterion for position register channel 2 */
#define O_PREG_CH1SOURCE          0x0006000BL   /* 6 - Selection of source for position register channel 1 */
#define O_PREG_CH2SOURCE          0x0007000BL   /* 7 - Selection of source for position register channel 2 */
#define O_PREG_CH1PA              0x0008000BL   /* 8 - Comparison value A for position register channel 1 */
#define O_PREG_CH1PB              0x0009000BL   /* 9 - Comparison value B for position register channel 1 */
#define O_PREG_CH2PA              0x000A000BL   /* 10 - Comparison value A for position register channel 2 */
#define O_PREG_CH2PB              0x000B000BL   /* 11 - Comparison value B for position register channel 2 */
#define O_PREG_CH3START           0x000C000BL   /* 12 - Start/stop of position register channel 3 */
#define O_PREG_CH4START           0x000D000BL   /* 13 - Start/stop of position register channel 4 */
#define O_PREG_CH3MODE            0x000E000BL   /* 14 - Selection of comparison criterion for position register channel 3 */
#define O_PREG_CH4MODE            0x000F000BL   /* 15 - Selection of comparison criterion for position register channel 4 */
#define O_PREG_CH3SOURCE          0x0010000BL   /* 16 - Selection of source for position register channel 3 */
#define O_PREG_CH4SOURCE          0x0011000BL   /* 17 - Selection of source for position register channel 4 */
#define O_PREG_CH3PA              0x0012000BL   /* 18 - Comparison value A for position register channel 3 */
#define O_PREG_CH3PB              0x0013000BL   /* 19 - Comparison value B for position register channel 3 */
#define O_PREG_CH4PA              0x0014000BL   /* 20 - Comparison value A for position register channel 4 */
#define O_PREG_CH4PB              0x0015000BL   /* 21 - Comparison value B for position register channel 4 */
#define O_PREG_GROUPSTART         0x0016000BL   /* 22 - Start/stop of position register channels */

/*INDEX_DESCRIPTION  13  MOTACS  41  Servo motor */
#define O_MOTACS                  0x0000000DL
#define O_MOTACS_SERIAL           0x0001000DL   /* 1 - Motor serial number */
#define O_MOTACS_MOTTYPE          0x0002000DL   /* 2 - Motor type */
#define O_MOTACS_SENSTYPE         0x0003000DL   /* 3 - Encoder type of motor */
#define O_MOTACS_NMAXMOTOR        0x0004000DL   /* 4 - Maximum permissible speed of rotation/velocity of motor */
#define O_MOTACS_NNOM             0x0005000DL   /* 5 - Nominal speed of rotation/velocity of motor */
#define O_MOTACS_IMAX             0x0006000DL   /* 6 - Maximum current of motor */
#define O_MOTACS_INOM             0x0007000DL   /* 7 - Nominal current of motor */
#define O_MOTACS_TQNOM            0x0008000DL   /* 8 - Nominal torque/force of motor */
#define O_MOTACS_TQMAX            0x0009000DL   /* 9 - Maximum torque of motor */
#define O_MOTACS_UNOM             0x000A000DL   /* 10 - Nominal voltage of motor */
#define O_MOTACS_KE               0x000B000DL   /* 11 - Voltage constant kE of motor */
#define O_MOTACS_JMOT             0x000C000DL   /* 12 - Moment of inertia of motor */
#define O_MOTACS_RMOT             0x000D000DL   /* 13 - Winding resistance of motor */
#define O_MOTACS_LQ               0x000E000DL   /* 14 - Inductance q component of motor */
#define O_MOTACS_LD               0x000F000DL   /* 15 - Inductance d component of motor */
#define O_MOTACS_TMOTMAX          0x0010000DL   /* 16 - Maximum temperature of motor */
#define O_MOTACS_I2TDT            0x0011000DL   /* 17 - Maximum permissible time for maximum current of motor */
#define O_MOTACS_PTCNTC           0x0012000DL   /* 18 - Type of temperature sensor */
#define O_MOTACS_I0               0x0013000DL   /* 19 - Continuous stall current of motor */
#define O_MOTACS_PPAIRMOT         0x0014000DL   /* 20 - Number of pole pairs of motor */
#define O_MOTACS_TMOTWARN         0x0015000DL   /* 21 - Temperature warning threshold of motor */
#define O_MOTACS_TQU0             0x0016000DL   /* 22 - Continuous stall torque of motor */
#define O_MOTACS_BRAKEUHOLD       0x0017000DL   /* 23 - Bremse Haltespannung */
#define O_MOTACS_DOM              0x0018000DL   /* 24 - Fertigungsdatum Motor */
#define O_MOTACS_UMAX             0x0019000DL   /* 25 - Maximum voltage of motor */
#define O_MOTACS_PWMFCHOP         0x001A000DL   /* 26 - Optimale Schaltfrequenz der Endstufe */
#define O_MOTACS_SERIAL1          0x001B000DL   /* 27 - Motor serial number part 1/5 */
#define O_MOTACS_SERIAL2          0x001C000DL   /* 28 - Motor serial number part 2/5 */
#define O_MOTACS_SERIAL3          0x001D000DL   /* 29 - Motor serial number part 3/5 */
#define O_MOTACS_SERIAL4          0x001E000DL   /* 30 - Motor serial number part 4/5 */
#define O_MOTACS_SERIAL5          0x001F000DL   /* 31 - Motor serial number part 5/5 */
#define O_MOTACS_BRAKE            0x0020000DL   /* 32 - Holding brake identification */
#define O_MOTACS_BRAKECOUPLING    0x0021000DL   /* 33 - Holding brake application time */
#define O_MOTACS_BRAKEDISCONNECT  0x0022000DL   /* 34 - Holding brake release time */
#define O_MOTACS_PPAIRPITCH       0x0023000DL   /* 35 - Pole pair pitch of motor */
#define O_MOTACS_MOTORTYPE        0x0024000DL   /* 36 - Motortype */
#define O_MOTACS_HWINDEX1         0x0025000DL   /* 37 - Motor Hardware Index part 1/5 */
#define O_MOTACS_HWINDEX2         0x0026000DL   /* 38 - Motor Hardware Index part 2/5 */
#define O_MOTACS_HWINDEX3         0x0027000DL   /* 39 - Motor Hardware Index part 3/5 */
#define O_MOTACS_HWINDEX4         0x0028000DL   /* 40 - Motor Hardware Index part 4/5 */
#define O_MOTACS_HWINDEX5         0x0029000DL   /* 41 - Motor Hardware Index part 5/5 */

/*INDEX_DESCRIPTION  16  PA  10  Power stage */
#define O_PA                      0x00000010L
#define O_PA_INOM                 0x00010010L   /* 1 - Nominal current of power stage */
#define O_PA_IMAX                 0x00020010L   /* 2 - Maximum current of power stage */
#define O_PA_UKZMAX               0x00030010L   /* 3 - Maximum permissible DC bus voltage */
#define O_PA_UKZMIN               0x00040010L   /* 4 - Minimum permissible DC bus voltage */
#define O_PA_DEFPWM               0x00050010L   /* 5 - Switching frequency of power stage */
#define O_PA_TWARN                0x00060010L   /* 6 - Temperature warning threshold of power stage */
#define O_PA_TMAX                 0x00070010L   /* 7 - Maximum power stage temperature */
#define O_PA_RBALINT              0x00080010L   /* 8 - Resistance value of internal braking resistor */
#define O_PA_PBALINT              0x00090010L   /* 9 - Nominal power of internal braking resistor */
#define O_PA_UKZMINSTOP           0x000A0010L   /* 10 - DC bus voltage low threshold for Quick Stop */

/*INDEX_DESCRIPTION  17  CTRLG  37  Controller parameter common */
#define O_CTRLG                   0x00000011L
#define O_CTRLG_KPID              0x00010011L   /* 1 - Current controller d component P gain */
#define O_CTRLG_TNID              0x00020011L   /* 2 - Current controller d component integral action time */
#define O_CTRLG_KPIQ              0x00030011L   /* 3 - Current controller q component P gain */
#define O_CTRLG_TNIQ              0x00040011L   /* 4 - Current controller q component integral action time */
#define O_CTRLG_NPIDDTIME         0x00050011L   /* 5 - PID velocity controller: Time constant of D term smoothing filter */
#define O_CTRLG_NPIDDPART         0x00060011L   /* 6 - PID velocity controller: D gain */
#define O_CTRLG_ZEROCONREF        0x00070011L   /* 7 - Nullstellenkoeffiziente des Nref-Filters */
#define O_CTRLG_TAUNACT           0x00080011L   /* 8 - Filter time constant to smooth velocity of motor */
#define O_CTRLG_SPDFRIC           0x00090011L   /* 9 - Speed of rotation up to which the friction compensation is linear */
#define O_CTRLG_KFACC             0x000A0011L   /* 10 - Acceleration feed-forward control */
#define O_CTRLG_IMAX              0x000C0011L   /* 12 - Current limitation */
#define O_CTRLG_IMAXQSTOP         0x000D0011L   /* 13 - Current value for Quick Stop */
#define O_CTRLG_IMAXHALT          0x000E0011L   /* 14 - Current value for Halt */
#define O_CTRLG_IMAXFW            0x000F0011L   /* 15 - Maximum current for field weakening (d component) */
#define O_CTRLG_NMAX              0x00100011L   /* 16 - Velocity limitation */
#define O_CTRLG_TPARASWITCH       0x00140011L   /* 20 - Period of time for parameter switching */
#define O_CTRLG_GLOBGAIN          0x00150011L   /* 21 - Global gain factor (affects parameter set 1) */
#define O_CTRLG_PARASETCOPY       0x00160011L   /* 22 - Controller parameter set copying */
#define O_CTRLG_PARASETINFO       0x00170011L   /* 23 - Active controller parameter set */
#define O_CTRLG_PARASETCMDPERS    0x00180011L   /* 24 - Selection of controller parameter set at power up */
#define O_CTRLG_PARASETCMD        0x00190011L   /* 25 - Selection of controller parameter set (non-persistent) */
#define O_CTRLG_PARASWITCHCOND    0x001A0011L   /* 26 - Condition for parameter set switching */
#define O_CTRLG_PARASETWINTIME    0x001B0011L   /* 27 - Time window for parameter set switching */
#define O_CTRLG_PARASETPDIF       0x001C0011L   /* 28 - Position deviation for parameter set switching */
#define O_CTRLG_PARASETSPD        0x001D0011L   /* 29 - Velocity threshold for parameter set switching */
#define O_CTRLG_TNN100            0x001E0011L   /* 30 - Speed controller integral term at 100% Global Gain */
#define O_CTRLG_KPN100            0x001F0011L   /* 31 - Speed controller P-term at 100% Global Gain */
#define O_CTRLG_TAUNREF100        0x00200011L   /* 32 - Filter time constant ref.value filter of the ref. speed value */
#define O_CTRLG_KPP100            0x00210011L   /* 33 - Position controller P-term at 100% Global Gain */
#define O_CTRLG_SPDOBSACTIVE      0x00220011L   /* 34 - Activation of velocity observer */
#define O_CTRLG_SPDOBSDYNAMIC     0x00230011L   /* 35 - Dynamics of velocity observer */
#define O_CTRLG_SPDOBSINERTIA     0x00240011L   /* 36 - Inertia value for velocity observer */
#define O_CTRLG_PARASETPDIFUSR    0x00250011L   /* 37 - Position deviation for parameter set switching */

/*INDEX_DESCRIPTION  18  CTRL1  16  Controller parameter set 1 */
#define O_CTRL1                   0x00000012L
#define O_CTRL1_KPN               0x00010012L   /* 1 - Velocity controller P gain */
#define O_CTRL1_TNN               0x00020012L   /* 2 - Velocity controller integral action time */
#define O_CTRL1_KPP               0x00030012L   /* 3 - Position controller P gain */
#define O_CTRL1_TAUNREF           0x00040012L   /* 4 - Filter time constant of the reference velocity value filter */
#define O_CTRL1_CURRFOL           0x00050012L   /* 5 - Filter time constant of the reference current value filter */
#define O_CTRL1_KFPP              0x00060012L   /* 6 - Velocity feed-forward control */
#define O_CTRL1_NOTCH1D           0x00080012L   /* 8 - Notch filter 1: Damping */
#define O_CTRL1_NOTCH1F           0x00090012L   /* 9 - Notch filter 1: Frequency */
#define O_CTRL1_NOTCH1BW          0x000A0012L   /* 10 - Notch filter 1: Bandwidth */
#define O_CTRL1_NOTCH2D           0x000B0012L   /* 11 - Notch filter 2: Damping */
#define O_CTRL1_NOTCH2F           0x000C0012L   /* 12 - Notch filter 2: Frequency */
#define O_CTRL1_NOTCH2BW          0x000D0012L   /* 13 - Notch filter 2: Bandwidth */
#define O_CTRL1_SPEEDOSUPDAMP     0x000E0012L   /* 14 - Overshoot suppression filter: Damping */
#define O_CTRL1_SPEEDOSUPDLAY     0x000F0012L   /* 15 - Overshoot suppression filter: Time delay */
#define O_CTRL1_KFRIC             0x00100012L   /* 16 - Friction compensation: Gain */

/*INDEX_DESCRIPTION  19  CTRL2  16  Controller parameter set 2 */
#define O_CTRL2                   0x00000013L
#define O_CTRL2_KPN               0x00010013L   /* 1 - Velocity controller P gain */
#define O_CTRL2_TNN               0x00020013L   /* 2 - Velocity controller integral action time */
#define O_CTRL2_KPP               0x00030013L   /* 3 - Position controller P gain */
#define O_CTRL2_TAUNREF           0x00040013L   /* 4 - Filter time constant of the reference velocity value filter */
#define O_CTRL2_CURRFOL           0x00050013L   /* 5 - Filter time constant of the reference current value filter */
#define O_CTRL2_KFPP              0x00060013L   /* 6 - Velocity feed-forward control */
#define O_CTRL2_NOTCH1D           0x00080013L   /* 8 - Notch filter 1: Damping */
#define O_CTRL2_NOTCH1F           0x00090013L   /* 9 - Notch filter 1: Frequency */
#define O_CTRL2_NOTCH1BW          0x000A0013L   /* 10 - Notch filter 1: Bandwidth */
#define O_CTRL2_NOTCH2D           0x000B0013L   /* 11 - Notch filter 2: Damping */
#define O_CTRL2_NOTCH2F           0x000C0013L   /* 12 - Notch filter 2: Frequency */
#define O_CTRL2_NOTCH2BW          0x000D0013L   /* 13 - Notch filter 2: Bandwidth */
#define O_CTRL2_SPEEDOSUPDAMP     0x000E0013L   /* 14 - Overshoot suppression filter: Damping */
#define O_CTRL2_SPEEDOSUPDLAY     0x000F0013L   /* 15 - Overshoot suppression filter: Time delay */
#define O_CTRL2_KFRIC             0x00100013L   /* 16 - Friction compensation: Gain */

/*INDEX_DESCRIPTION  22  SER  15  Serial interface / ModbusRTU */
#define O_SER                     0x00000016L
#define O_SER_BAUDRATE            0x00030016L   /* 3 - Modbus baud rate */
#define O_SER_ADDRESS             0x00040016L   /* 4 - Modbus address */
#define O_SER_FORMAT              0x00050016L   /* 5 - Modbus data format */
#define O_SER_NGUARD              0x00060016L   /* 6 - Modbus Node Guarding */
#define O_SER_MBWORD              0x00070016L   /* 7 - Modbus word order for double words (32 bit values) */
#define O_SER_MONACCESS           0x00080016L   /* 8 - Fast Monitoring number of parameters */
#define O_SER_MONBLOCK            0x00090016L   /* 9 - Fast Monitoring Block access */
#define O_SER_MBPARADR            0x000A0016L   /* 10 - Modbus Peek/Poke Adresse */
#define O_SER_MBPARDAT            0x000B0016L   /* 11 - Modbus Peek/Poke Daten */
#define O_SER_EFMCONFIG           0x000C0016L   /* 12 - Configuration of the variable part of Enhanced Fast Monitoring */
#define O_SER_EFMDATA             0x000D0016L   /* 13 - Enhanced Fast Monitoring Block access */
#define O_SER_EFMSTATUS           0x000E0016L   /* 14 - Status of the Enhanced Fast Monitoring */
#define O_SER_EFMTIME             0x000F0016L   /* 15 - Timestamp for the Enhanced Fast Monitoring */

/*INDEX_DESCRIPTION  25  SERC2  73  Sercos Profile */
#define O_SERC2                   0x00000019L
#define O_SERC2_MASCON            0x00010019L   /* 1 - Master control word */
#define O_SERC2_DRVSTAT           0x00020019L   /* 2 - Drive status word */
#define O_SERC2_PRIMOMODE         0x00030019L   /* 3 - Primary operating mode */
#define O_SERC2_SECOMODE1         0x00040019L   /* 4 - Secondary operating mode 1 */
#define O_SERC2_VELDATSCALFAC     0x00050019L   /* 5 - Velocity data scaling factor */
#define O_SERC2_VELDATSCALEXP     0x00060019L   /* 6 - Velocity data scaling exponent */
#define O_SERC2_INTERFACESTAT     0x00080019L   /* 8 - Interface status */
#define O_SERC2_AMPTMPSTAT        0x000A0019L   /* 10 - Power stage overtemperature warning */
#define O_SERC2_MOTTMPSTAT        0x000B0019L   /* 11 - Motor overtemperature warning */
#define O_SERC2_TRGTRNGSTAT       0x000C0019L   /* 12 - Target position outside of movement range */
#define O_SERC2_TORQLIMSTAT       0x000D0019L   /* 13 - Torque limit exceeded */
#define O_SERC2_VELLIMSTAT        0x000E0019L   /* 14 - Velocity limit exceeded */
#define O_SERC2_INPOSSTAT         0x000F0019L   /* 15 - In position */
#define O_SERC2_HOMESTAT          0x00100019L   /* 16 - Signal state of reference switch */
#define O_SERC2_PRB1STAT          0x00110019L   /* 17 - Signal state of capture input 1 */
#define O_SERC2_PRB2STAT          0x00120019L   /* 18 - Signal state of capture input 2 */
#define O_SERC2_POSFVALSTAT       0x00130019L   /* 19 - Valid zero point after successful homing */
#define O_SERC2_PRB1POSSTAT       0x00140019L   /* 20 - Capture input 1 rising edge detected */
#define O_SERC2_PRB1NEGSTAT       0x00150019L   /* 21 - Capture input 1 falling edge detected */
#define O_SERC2_PRB2POSSTAT       0x00160019L   /* 22 - Capture input 2 rising edge detected */
#define O_SERC2_PRB2NEGSTAT       0x00170019L   /* 23 - Capture input 2 falling edge detected */
#define O_SERC2_RTCBIT1ALLOC      0x00190019L   /* 25 - Assignment of real-time control bit 1 */
#define O_SERC2_RTCBIT2ALLOC      0x001B0019L   /* 27 - Assignment of real-time control bit 2 */
#define O_SERC2_RTSBIT1           0x001C0019L   /* 28 - Real-time status bit 1 */
#define O_SERC2_RTSBIT1ALLOC      0x001D0019L   /* 29 - Assignment of real-time status bit 1 */
#define O_SERC2_RTSBIT2           0x001E0019L   /* 30 - Real-time status bit 2 */
#define O_SERC2_RTSBIT2ALLOC      0x001F0019L   /* 31 - Assignment of real-time status bit 2 */
#define O_SERC2_POSPOL            0x00200019L   /* 32 - Inversion of sign of position data and setting of software limit switches */
#define O_SERC2_MANUC1D           0x00210019L   /* 33 - Manufacturer class 1 diagnostics */
#define O_SERC2_MANUC2D           0x00220019L   /* 34 - Manufacturer class 2 diagnostics */
#define O_SERC2_MANUC3D           0x00230019L   /* 35 - Manufacturer class 3 diagnostics */
#define O_SERC2_MASKC2D           0x00240019L   /* 36 - Mask class 2 diagnostics */
#define O_SERC2_MASKC3D           0x00250019L   /* 37 - Mask class 3 diagnostics */
#define O_SERC2_C1DIAGNOSTIC      0x00260019L   /* 38 - Class 1 diagnostics (C1D) */
#define O_SERC2_C2DIAGNOSTIC      0x00270019L   /* 39 - Class 2 diagnostics (C2D) */
#define O_SERC2_C3DIAGNOSTIC      0x00280019L   /* 40 - Class 3 diagnostics (C3D) */
#define O_SERC2_PRB1ENABLE        0x00290019L   /* 41 - Capture input 1 enable */
#define O_SERC2_PRB2ENABLE        0x002A0019L   /* 42 - Capture input 2 enable */
#define O_SERC2_VELSCAL           0x002D0019L   /* 45 - Velocity data scaling type */
#define O_SERC2_POSSCAL           0x002F0019L   /* 47 - Position data scaling type */
#define O_SERC2_TORQSCAL          0x00300019L   /* 48 - Torque data scaling type */
#define O_SERC2_HOMEPARAM         0x00310019L   /* 49 - Homing */
#define O_SERC2_POSRES            0x00320019L   /* 50 - Rotational position resolution */
#define O_SERC2_PRBCNTRL          0x00330019L   /* 51 - Capture input configuration */
#define O_SERC2_LI0               0x00340019L   /* 52 - Level of digital input DI0 */
#define O_SERC2_LI1               0x00350019L   /* 53 - Level of digital input DI1 */
#define O_SERC2_LI2               0x00360019L   /* 54 - Level of digital input DI2 */
#define O_SERC2_LI3               0x00370019L   /* 55 - Level of digital input DI3 */
#define O_SERC2_LI4               0x00380019L   /* 56 - Level of digital input DI4 */
#define O_SERC2_LI5               0x00390019L   /* 57 - Level of digital input DI5 */
#define O_SERC2_LIO0              0x003A0019L   /* 58 - Level of digital output DQ0 */
#define O_SERC2_LIO1              0x003B0019L   /* 59 - Level of digital output DQ1 */
#define O_SERC2_LIO2              0x003C0019L   /* 60 - Level of digital output DQ2 */
#define O_SERC2_PRBDIFFCTRL       0x003D0019L   /* 61 - Configuration of difference value capturing */
#define O_SERC2_PRBENABLE         0x00400019L   /* 64 - Capture inputs 1 and 2 enable */
#define O_SERC2_PRBENABLECONF     0x00410019L   /* 65 - Type of enabling of capture inputs 1 and 2 */
#define O_SERC2_BIPACCLIM         0x00420019L   /* 66 - Acceleration/deceleration limitation */
#define O_SERC2_ACCSCAL           0x00430019L   /* 67 - Type of scaling for acceleration data */
#define O_SERC2_CONTENTOFIDN51    0x00460019L   /* 70 - Specification of content of IDN51 */
#define O_SERC2_MOTORFEEDBACK     0x00470019L   /* 71 - Actual position value 1 */
#define O_SERC2_CONTENTOFIDN53    0x00480019L   /* 72 - Specification of content of IDN53 */
#define O_SERC2_EXTERNALFEEDBACK  0x00490019L   /* 73 - Actual position value 2 */

/*INDEX_DESCRIPTION  26  PRODRV  20  PROFIdrive profile parameters */
#define O_PRODRV                  0x0000001AL
#define O_PRODRV_STW1             0x0003001AL   /* 3 - PROFIdrive control word 1 */
#define O_PRODRV_STW2             0x0004001AL   /* 4 - PROFIdrive control word 2 */
#define O_PRODRV_ZSW1             0x0005001AL   /* 5 - PROFIdrive status word 1 */
#define O_PRODRV_ZSW2             0x0006001AL   /* 6 - PROFIdrive status word 2 */
#define O_PRODRV_NSOLLA           0x0007001AL   /* 7 - PROFIdrive speed setpoint A */
#define O_PRODRV_NSOLLB           0x0008001AL   /* 8 - PROFIdrive speed setpoint B */
#define O_PRODRV_SATZANW          0x0009001AL   /* 9 - PROFIdrive transversing block selection */
#define O_PRODRV_AKTSATZ          0x000A001AL   /* 10 - PROFIdrive actual traversing block */
#define O_PRODRV_NISTA            0x000B001AL   /* 11 - PROFIdrive speed actual value A */
#define O_PRODRV_NISTB            0x000C001AL   /* 12 - PROFIdrive speed actual value B */
#define O_PRODRV_REF1             0x000D001AL   /* 13 - PROFIdrive reference value 1 */
#define O_PRODRV_REF2             0x000E001AL   /* 14 - PROFIdrive reference value 2 */
#define O_PRODRV_XISTA            0x000F001AL   /* 15 - PROFIdrive position actual value A */
#define O_PRODRV_MDITARPOS        0x0010001AL   /* 16 - PROFIdrive MDI target position */
#define O_PRODRV_MDIVEL           0x0011001AL   /* 17 - PROFIdrive MDI velocity */
#define O_PRODRV_MDIACC           0x0012001AL   /* 18 - PROFIdrive MDI acceleration */
#define O_PRODRV_MDIDEC           0x0013001AL   /* 19 - PROFIdrive MDI deceleration */
#define O_PRODRV_MDIMOD           0x0014001AL   /* 20 - PROFIdrive MDI mode */

/*INDEX_DESCRIPTION  27  DCOM  59  Device control profiles */
#define O_DCOM                    0x0000001BL
#define O_DCOM_CTRLWORD           0x0001001BL   /* 1 - DriveCom control word */
#define O_DCOM_STATUSWORD         0x0002001BL   /* 2 - DriveCom status word */
#define O_DCOM_OPMODE             0x0003001BL   /* 3 - Operating mode */
#define O_DCOM_OPMODEDISP         0x0004001BL   /* 4 - Active operating mode */
#define O_DCOM_SHIFTFACTOR        0x0005001BL   /* 5 - Bit shift for RefA16 for Drive Profile Lexium */
#define O_DCOM_DECLASSFAULT       0x0006001BL   /* 6 - Error response to data error (DE bit) */
#define O_DCOM_MECLASSFAULT       0x0007001BL   /* 7 - Error response to mode error (ME bit) */
#define O_DCOM_BLDEFMAP           0x0008001BL   /* 8 - Activation of Drive Profile Lexium */
#define O_DCOM_REFMANUAL          0x0009001BL   /* 9 - Activation of operating mode Jog */
#define O_DCOM_MOTSEQDATNUM       0x000A001BL   /* 10 - Selection of a data set to be started for operating mode Motion Sequence */
#define O_DCOM_HOMEMETHOD         0x000C001BL   /* 12 - Homing method */
#define O_DCOM_REFPROFVEL         0x000D001BL   /* 13 - Target velocity for operating mode Profile Velocity */
#define O_DCOM_TARGETPOS          0x000E001BL   /* 14 - Target position for operating mode Profile Position */
#define O_DCOM_TARGETVEL          0x000F001BL   /* 15 - Target velocity for operating mode Profile Position */
#define O_DCOM_TARGETTORQ         0x0010001BL   /* 16 - Target torque for operating mode Profile Torque */
#define O_DCOM_REFGEAR            0x0012001BL   /* 18 - Processing mode for operating mode Electronic Gear */
#define O_DCOM_SMCOMP             0x0013001BL   /* 19 - DS402 state machine: State transition from 3 to 4 */
#define O_DCOM_DRIVEMODES         0x0014001BL   /* 20 - Supported operating modes as per DSP402 */
#define O_DCOM_PROFILETYPE        0x0015001BL   /* 21 - Motion profile */
#define O_DCOM_HOMESETPOS         0x0016001BL   /* 22 - Position for Position Setting */
#define O_DCOM_CONST2             0x0017001BL   /* 23 - Anzahl Einträge für Wertepaare */
#define O_DCOM_POSOPTION          0x0018001BL   /* 24 - Options for operating mode Profile Position */
#define O_DCOM_MODEERROR          0x0019001BL   /* 25 - Error code for synchronous errors (ME bit) */
#define O_DCOM_DATAERROR          0x001B001BL   /* 27 - Error code for synchronous errors (DE bit) */
#define O_DCOM_MODEERRORINFO      0x001C001BL   /* 28 - Additional error information of a ModeError (ME bit) */
#define O_DCOM_DATAERRORINFO      0x001D001BL   /* 29 - Additional error information of a DataError (DE bit) */
#define O_DCOM_INTLIMACTIVE       0x001E001BL   /* 30 - DS402 status word: Setting for bit 11 (internal limit) */
#define O_DCOM_DMCONTROL          0x001F001BL   /* 31 - Drive Profile Lexium dmControl */
#define O_DCOM_REFA32             0x0020001BL   /* 32 - Drive Profile Lexium RefA32 */
#define O_DCOM_REFB32             0x0021001BL   /* 33 - Drive Profile Lexium RefB32 */
#define O_DCOM_REFA16             0x0022001BL   /* 34 - Drive Profile Lexium RefA16 */
#define O_DCOM_PCTRLMS            0x0023001BL   /* 35 - parameter channel control (master - slave) */
#define O_DCOM_PVMS               0x0024001BL   /* 36 - parameter value (master - slave) */
#define O_DCOM_DRIVESTAT          0x0025001BL   /* 37 - Drive Profile Lexium driveStat */
#define O_DCOM_MFSTAT             0x0026001BL   /* 38 - Drive Profile Lexium mfStat */
#define O_DCOM_MOTIONSTAT         0x0027001BL   /* 39 - Drive Profile Lexium motionStat */
#define O_DCOM_DRIVEINPUT         0x0028001BL   /* 40 - Drive Profile Lexium driveInput */
#define O_DCOM_PCTRLSM            0x0029001BL   /* 41 - parameter channel control (slave - master) */
#define O_DCOM_PVSM               0x002A001BL   /* 42 - parameter value (slave - master) */
#define O_DCOM_SUPPRESSHALT       0x002B001BL   /* 43 - Suppress halt bit  in DCOM Status */
#define O_DCOM_CYCLETIME          0x002C001BL   /* 44 - Interpolation time period value */
#define O_DCOM_TIMEINDEX          0x002D001BL   /* 45 - Interpolation time index */
#define O_DCOM_DATRECFIRSTSP      0x002E001BL   /* 46 - Position reference value for operating mode Interpolated Position */
#define O_DCOM_DATCONFMAXBUF      0x002F001BL   /* 47 - Interpolation data configuration maximum buffer size */
#define O_DCOM_DATCONFACTBUF      0x0030001BL   /* 48 - Interpolation data configuration actual buffer size */
#define O_DCOM_DATCONFBUFORG      0x0031001BL   /* 49 - Interpolation data configuration buffer organization */
#define O_DCOM_DATCONFBUFPOS      0x0032001BL   /* 50 - Interpolation data configuration buffer position */
#define O_DCOM_DATCONSIZEDR       0x0033001BL   /* 51 - Interpolation data configuration size of data record */
#define O_DCOM_DATCONBUFCLE       0x0034001BL   /* 52 - Interpolation data configuration buffer clear */
#define O_DCOM_STATUSMAPPING      0x0035001BL   /* 53 - Setting for bit 9 of _DPL_motionStat and _actionStatus */
#define O_DCOM_DATRECNUMSIX       0x0036001BL   /* 54 - Interpolation data record Highest Subindex */
#define O_DCOM_DATCONFNUMSIX      0x0037001BL   /* 55 - Interpolation data configuration Highest Subindex */
#define O_DCOM_REFTORQ            0x0038001BL   /* 56 - Reference value source for operating mode Profile Torque */
#define O_DCOM_REFVEL             0x0039001BL   /* 57 - Reference value source for operating mode Profile Velocity */
#define O_DCOM_TOUCHPROBECFG      0x003A001BL   /* 58 - Touch probe function */
#define O_DCOM_TOUCHPROBESTATUS   0x003B001BL   /* 59 - Touch probe status */

/*INDEX_DESCRIPTION  28  STD  42  Device status */
#define O_STD                     0x0000001CL
#define O_STD_CTRLWORD            0x0001001CL   /* 1 - Steuerwort (Herstellerspezifisch) */
#define O_STD_STATUSWORD          0x0002001CL   /* 2 - Statuswort für den Betriebszustand */
#define O_STD_AXISMODE            0x0003001CL   /* 3 - akt. Achsbetriebsart mit  Zusatzinformation */
#define O_STD_ACTIONWORD          0x0004001CL   /* 4 - Action word */
#define O_STD_STOPFAULT           0x0005001CL   /* 5 - Error causing a stop (error classes 1 to 4) */
#define O_STD_INVALIDPARAM        0x0006001CL   /* 6 - Modbus address of parameter with invalid value */
#define O_STD_SIGACT              0x0007001CL   /* 7 - Current status of monitoring signals */
#define O_STD_SIGSR               0x0008001CL   /* 8 - Saved status of monitoring signals */
#define O_STD_LASTWARNING         0x0009001CL   /* 9 - Number of last warning (error class 0) */
#define O_STD_OPHOURS             0x000A001CL   /* 10 - Operating hours counter */
#define O_STD_WARNSIGACT          0x000B001CL   /* 11 - Active warnings, bit-coded */
#define O_STD_WARNSIGSR           0x000C001CL   /* 12 - Saved warnings, bit-coded */
#define O_STD_POWACT              0x000D001CL   /* 13 - Current output power */
#define O_STD_POWMEAN             0x000E001CL   /* 14 - Mean output power */
#define O_STD_UZ                  0x000F001CL   /* 15 - Voltage at DC bus */
#define O_STD_TLE                 0x0010001CL   /* 16 - Current power stage temperature */
#define O_STD_TMOT                0x0011001CL   /* 17 - Current motor temperature */
#define O_STD_TCPU                0x0012001CL   /* 18 - Current device temperature */
#define O_STD_I2TRESACT           0x0013001CL   /* 19 - Current overload of braking resistor (I2t) */
#define O_STD_LOADFACTORRES       0x0014001CL   /* 20 - Current load of braking resistor */
#define O_STD_I2TRESPEAK          0x0015001CL   /* 21 - Maximum value of overload of braking resistor */
#define O_STD_I2TPAACT            0x0016001CL   /* 22 - Current overload of power stage (I2t) */
#define O_STD_LOADFACTORPA        0x0017001CL   /* 23 - Current load of power stage */
#define O_STD_OVERLOADPAPEAK      0x0018001CL   /* 24 - Maximum value of overload of power stage */
#define O_STD_I2TMOTACT           0x0019001CL   /* 25 - Current overload of motor (I2t) */
#define O_STD_LOADFACTORMOT       0x001A001CL   /* 26 - Current load of motor */
#define O_STD_I2TMOTPEAK          0x001B001CL   /* 27 - Maximum value of overload of motor */
#define O_STD_DRIVESUPVINFO       0x001C001CL   /* 28 - Spezielle Bewegungsüberwachungen, bitcodiert */
#define O_STD_MAXCURRPERCENT      0x001E001CL   /* 30 - Maximum possible value for operating mode Profile Torque */
#define O_STD_STOPFAULTINFO       0x001F001CL   /* 31 - Additional info of last error */
#define O_STD_STOPFAULTCLASS      0x0020001CL   /* 32 - Error class of last error */
#define O_STD_STOPFAULTTIME       0x0021001CL   /* 33 - Time stamp of last error */
#define O_STD_OTCHIPPAACT         0x0022001CL   /* 34 - Current overload of power stage (chip temperature) */
#define O_STD_POW2PAACT           0x0023001CL   /* 35 - Current overload of power stage (power squared) */
#define O_STD_OVERLOADPAACT       0x0024001CL   /* 36 - Current overload of power stage */
#define O_STD_TENC                0x0025001CL   /* 37 - Current encoder temperature */
#define O_STD_CONDSTATE4          0x0026001CL   /* 38 - Conditions for transition to operating state Ready To Switch On */
#define O_STD_IMAXSYS             0x0027001CL   /* 39 - Current limitation of the system */
#define O_STD_IMAXACT             0x0028001CL   /* 40 - Currently effective current limitation */
#define O_STD_NMAXACT             0x0029001CL   /* 41 - Currently effective velocity limitation */
#define O_STD_STOPFAULTBIT        0x002A001CL   /* 42 - Information on error bits of last error */

/*INDEX_DESCRIPTION  30  MONC  43  Monitoring of controller */
#define O_MONC                    0x0000001EL
#define O_MONC_IACTQ              0x0001001EL   /* 1 - Actual motor current (q component, generating torque) */
#define O_MONC_IACTD              0x0002001EL   /* 2 - Actual motor current (d component, field weakening) */
#define O_MONC_IACTDQ             0x0003001EL   /* 3 - Total motor current */
#define O_MONC_UREFQ              0x0004001EL   /* 4 - Reference motor voltage q component */
#define O_MONC_UREFD              0x0005001EL   /* 5 - Reference motor voltage d component */
#define O_MONC_UREFDQ             0x0006001EL   /* 6 - Total motor voltage (vector sum d components and q components) */
#define O_MONC_NREF               0x0007001EL   /* 7 - Reference speed of rotation */
#define O_MONC_NACT               0x0008001EL   /* 8 - Actual speed of rotation */
#define O_MONC_PREF               0x0009001EL   /* 9 - Reference position in internal units */
#define O_MONC_PACT               0x000A001EL   /* 10 - Actual position in internal units */
#define O_MONC_PDIF               0x000B001EL   /* 11 - Regelabweichung des Lagereglers */
#define O_MONC_PREFUSR            0x000C001EL   /* 12 - Reference position */
#define O_MONC_PACTUSR            0x000D001EL   /* 13 - Actual position */
#define O_MONC_PACTMODULO         0x000E001EL   /* 14 - Absolute position with reference to internal resolution in internal units */
#define O_MONC_PABSMODWORKUSR     0x000F001EL   /* 15 - Absolute position with reference to the encoder range */
#define O_MONC_IREFQ              0x0010001EL   /* 16 - Reference motor current (q component, generating torque) */
#define O_MONC_IREFD              0x0011001EL   /* 17 - Reference motor current (d component, field weakening) */
#define O_MONC_PDIFNORM           0x0012001EL   /* 18 - Current position deviation including dynamic position deviation */
#define O_MONC_VOLTUTIL           0x0013001EL   /* 19 - Degree of utilization of DC bus voltage */
#define O_MONC_PDIFNORMUSR        0x0014001EL   /* 20 - Current position deviation including dynamic position deviation */
#define O_MONC_PDIFPEAKUSR        0x0015001EL   /* 21 - Maximum value of the load-dependent position deviation */
#define O_MONC_PDIFCOMPNORMUSR    0x0016001EL   /* 22 - Current load-dependent position deviation between reference and actual position */
#define O_MONC_SPDANDCURRVAL      0x0017001EL   /* 23 - Actual speed of rotation and actual current */
#define O_MONC_ENCMACHPOSDIFF     0x0018001EL   /* 24 - Current deviation of encoder positions */
#define O_MONC_ENC2PACT           0x0019001EL   /* 25 - Actual position of encoder 2 (module) in internal units */
#define O_MONC_ENC2PACTUSR        0x001A001EL   /* 26 - Actual position of encoder 2 (module) */
#define O_MONC_PDIFPEAK           0x001B001EL   /* 27 - Maximum value of the load-dependent position deviation */
#define O_MONC_PDIFCOMPNORM       0x001C001EL   /* 28 - Current load-dependent position deviation between reference and actual position */
#define O_MONC_ENC2PUREPACT       0x001D001EL   /* 29 - Actual position of encoder 2 without internal offset */
#define O_MONC_ENC2NACT           0x001E001EL   /* 30 - Actual speed of rotation of encoder 2 (module) */
#define O_MONC_VREF               0x001F001EL   /* 31 - Reference velocity */
#define O_MONC_VACT               0x0020001EL   /* 32 - Actual velocity */
#define O_MONC_VREFSHIFT          0x0021001EL   /* 33 - Data optimized reference speed of speed controller in usr_v */
#define O_MONC_VACTSHIFT          0x0022001EL   /* 34 - Data optimized actual speed control loop in velocity user units */
#define O_MONC_ENC2VACT           0x0023001EL   /* 35 - Actual velocity of encoder 2 (module) */
#define O_MONC_TORQACT            0x0024001EL   /* 36 - Actual torque value */
#define O_MONC_ENC2RAWINC         0x0025001EL   /* 37 - Actual raw increment value of encoder 2 */
#define O_MONC_ENC1PACT           0x0026001EL   /* 38 - Actual position of encoder 1 in internal units */
#define O_MONC_ENC1PACTUSR        0x0027001EL   /* 39 - Actual position of encoder 1 */
#define O_MONC_ENC1NACT           0x0028001EL   /* 40 - Actual speed of rotation of encoder 1 */
#define O_MONC_ENC1VACT           0x0029001EL   /* 41 - Actual velocity of encoder 1 */
#define O_MONC_EPSE               0x002A001EL   /* 42 - Electrical angle related to one pole pair */
#define O_MONC_POSCTRLPREFMOD     0x002B001EL   /* 43 - Internal ref position to PosCtrlLoop incl. one rev modulo processing */

/*INDEX_DESCRIPTION  31  MONT  13  Monitoring of motion generation */
#define O_MONT                    0x0000001FL
#define O_MONT_POSTARGUSR         0x0001001FL   /* 1 - Target position of profile generator */
#define O_MONT_POSPROFUSR         0x0002001FL   /* 2 - Actual position of profile generator */
#define O_MONT_POSADDGEAR         0x0003001FL   /* 3 - Initial position electronic gear */
#define O_MONT_SPEEDPROFTAR       0x0005001FL   /* 5 - Target velocity of profile generator */
#define O_MONT_SPEEDPROFACT       0x0006001FL   /* 6 - Actual velocity of profile generator */
#define O_MONT_SPEEDPREF          0x0007001FL   /* 7 - Velocity of reference value for velocity feed-forward control */
#define O_MONT_ACCPREFUSR         0x0009001FL   /* 9 - Acceleration of reference value for acceleration feed-forward control */
#define O_MONT_USRPOSMAX          0x000A001FL   /* 10 - Maximum user-defined value for positions */
#define O_MONT_USRVELMAX          0x000B001FL   /* 11 - Maximum user-defined value for velocities */
#define O_MONT_USRRAMPMAX         0x000C001FL   /* 12 - Maximum user-defined value for accelerations and decelerations */
#define O_MONT_POSDIFFGEAR        0x000D001FL   /* 13 - Current position deviation in operating mode Electronic Gear */

/*INDEX_DESCRIPTION  32  TRQPRF  3  Operating mode Profile Torque */
#define O_TRQPRF                  0x00000020L
#define O_TRQPRF_START            0x00010020L   /* 1 - Start profile torque operation mode */
#define O_TRQPRF_ACK              0x00020020L   /* 2 - Status of Profile Torque Mode */
#define O_TRQPRF_TORQTARGET       0x00030020L   /* 3 - Target torque for operating mode Profile Torque */

/*INDEX_DESCRIPTION  33  VELPRF  3  Operating mode Profile Velocity */
#define O_VELPRF                  0x00000021L
#define O_VELPRF_START            0x00010021L   /* 1 - Start profile velocity operation mode */
#define O_VELPRF_ACK              0x00020021L   /* 2 - Status of Profile Velocity Mode */
#define O_VELPRF_PRFVELTARGET     0x00030021L   /* 3 - Target velocity for operating mode Profile Velocity */

/*INDEX_DESCRIPTION  34  CSPSYN  6  Operating mode Cyclic Synchronous Position */
#define O_CSPSYN                  0x00000022L
#define O_CSPSYN_START            0x00010022L   /* 1 - Start cycle sync operation mode csp */
#define O_CSPSYN_ACK              0x00020022L   /* 2 - Status of cycle sync operation mode */
#define O_CSPSYN_SYNCTOLERC       0x00040022L   /* 4 - Synchronization tolerance */
#define O_CSPSYN_STARTSYNC        0x00050022L   /* 5 - Activation of synchronization mechanism */
#define O_CSPSYN_SYNCSTATUS       0x00060022L   /* 6 - Status of synchronization mechanism */

/*INDEX_DESCRIPTION  35  POSPRF  17  Operating mode Profile Position */
#define O_POSPRF                  0x00000023L
#define O_POSPRF_STARTABSPOS      0x00010023L   /* 1 - Target position absolute of operating mode profile position */
#define O_POSPRF_ACK              0x00020023L   /* 2 - Quittung: PTP-Positionierung */
#define O_POSPRF_STARTRELPREF     0x00030023L   /* 3 - Target position relative to the current target position */
#define O_POSPRF_STARTCONT        0x00040023L   /* 4 - Fortsetzen einer abgebrochenen Positionierung */
#define O_POSPRF_SPDTARGETUSR     0x00050023L   /* 5 - Target velocity for operating mode Profile Position */
#define O_POSPRF_STARTRELPACT     0x00060023L   /* 6 - Target position relative to current motor position */
#define O_POSPRF_ENAABSPOSOV      0x00070023L   /* 7 - Absolute movement beyond movement range */
#define O_POSPRF_SPDTARUSRNEXT    0x00080023L   /* 8 - Vorbereitung Solldrehzahl für nächsten Auftrag */
#define O_POSPRF_OPMCHGTYPE       0x00090023L   /* 9 - Change to operating mode Profile Position during movements */
#define O_POSPRF_SPDTARGETUSRRPM  0x000A0023L   /* 10 - Target velocity for operating mode Profile Position in rpm. */
#define O_POSPRF_DISTSTOPSTART    0x000C0023L   /* 12 - Activation of relative movement after capture */
#define O_POSPRF_DISTSTOPPOSITION 0x000D0023L   /* 13 - Target position of relative movement after capture */
#define O_POSPRF_DISTSTOPVELOCITY 0x000E0023L   /* 14 - Velocity of relative movement after capture */
#define O_POSPRF_DISTSTOPREACTION 0x000F0023L   /* 15 - Response if target postion is overtraveld */
#define O_POSPRF_DISTSTOPSIGNAL   0x00100023L   /* 16 - Edge of capture signal for relative movement after capture */
#define O_POSPRF_DISTSTOPACTIVE   0x00110023L   /* 17 - Status of relative movement after capture */

/*INDEX_DESCRIPTION  36  CSVSYN  2  Operating mode Cyclic Synchronous Velocity */
#define O_CSVSYN                  0x00000024L
#define O_CSVSYN_START            0x00010024L   /* 1 - Start cycle sync operation mode csv */
#define O_CSVSYN_ACK              0x00020024L   /* 2 - Status of cycle sync operation mode */

/*INDEX_DESCRIPTION  37  CSTSYN  2  Operating mode Cyclic Synchronous Torque */
#define O_CSTSYN                  0x00000025L
#define O_CSTSYN_START            0x00010025L   /* 1 - Start cycle sync operation mode cst */
#define O_CSTSYN_ACK              0x00020025L   /* 2 - Status of cycle sync operation mode cst */

/*INDEX_DESCRIPTION  38  GEAR  14  Operating mode Electronic Gear */
#define O_GEAR                    0x00000026L
#define O_GEAR_START              0x00010026L   /* 1 - Processing mode electronic gear processing */
#define O_GEAR_ACK                0x00020026L   /* 2 - Quittung: Getriebebearbeitung */
#define O_GEAR_DENOMINATOR        0x00030026L   /* 3 - Denominator of gear ratio */
#define O_GEAR_NUMERATOR          0x00040026L   /* 4 - Numerator of gear ratio */
#define O_GEAR_DIRENABLE          0x00050026L   /* 5 - Enabled movement direction of gear processing */
#define O_GEAR_RESGEAR            0x00060026L   /* 6 - Selection of predefined gear ratios */
#define O_GEAR_JERKFILTERUSAGE    0x00070026L   /* 7 - Activation of jerk limitation */
#define O_GEAR_VELOUTMAX          0x00090026L   /* 9 - Velocity limitation for the method Position Synchronization */
#define O_GEAR_POSCHGMODE         0x000B0026L   /* 11 - Consideration of position changes with inactive power stage */
#define O_GEAR_DENOMINATOR2       0x000C0026L   /* 12 - Denominator of gear ratio number 2 */
#define O_GEAR_NUMERATOR2         0x000D0026L   /* 13 - Numerator of gear ratio number 2 */
#define O_GEAR_SELECTRATIO        0x000E0026L   /* 14 - Gear ratio selection */

/*INDEX_DESCRIPTION  39  GEAOFF  12  Offset in operating mode Electronic Gear */
#define O_GEAOFF                  0x00000027L
#define O_GEAOFF_STARTABSPOS      0x00010027L   /* 1 - Start absolute offset movement */
#define O_GEAOFF_ACK              0x00020027L   /* 2 - State of offset movement */
#define O_GEAOFF_STARTRELPOS      0x00030027L   /* 3 - Start relative offset movement */
#define O_GEAOFF_VELTARGET        0x00040027L   /* 4 - Target velocity for offset movement */
#define O_GEAOFF_SETPOS           0x00050027L   /* 5 - Set offset position */
#define O_GEAOFF_RAMP             0x00060027L   /* 6 - Acceleration and deceleration for offset movement */
#define O_GEAOFF_OFFSETPOS1       0x00080027L   /* 8 - Relative offset position 1 for offset movement */
#define O_GEAOFF_OFFSETPOS2       0x000A0027L   /* 10 - Relative offset position 2 for offset movement */
#define O_GEAOFF_ACTIVATEOFFSET   0x000B0027L   /* 11 - Offset movement with relative offset position */
#define O_GEAOFF_OFFSPOSACT       0x000C0027L   /* 12 - Actual offset position */

/*INDEX_DESCRIPTION  40  HOME  15  Operating mode Homing */
#define O_HOME                    0x00000028L
#define O_HOME_START              0x00010028L   /* 1 - Homing method */
#define O_HOME_ACK                0x00020028L   /* 2 - Quittung: Referenzierung */
#define O_HOME_STARTSETPOS        0x00030028L   /* 3 - Position for Position Setting */
#define O_HOME_SPEEDTOREF         0x00040028L   /* 4 - Target velocity for searching the switch */
#define O_HOME_SPEEDOUTREF        0x00050028L   /* 5 - Target velocity for moving away from switch */
#define O_HOME_POSOUTREF          0x00060028L   /* 6 - Maximum distance for search for switching point */
#define O_HOME_POSDISTREF         0x00070028L   /* 7 - Distance from switching point */
#define O_HOME_SAVEHOMEMETHOD     0x000A0028L   /* 10 - Preferred homing method */
#define O_HOME_REFAPPPOS          0x000B0028L   /* 11 - Position at reference point */
#define O_HOME_PDIFINDEXREF       0x000C0028L   /* 12 - Distance from switching point to index pulse */
#define O_HOME_POSSRCHLIMMAX      0x000D0028L   /* 13 - Maximum search distance after overtravel of switch */
#define O_HOME_INTSTATEINFO       0x000E0028L   /* 14 - For Test only: Internal State of Homing */
#define O_HOME_PDIFINDEXREFUSR    0x000F0028L   /* 15 - Distance from switching point to index pulse */

/*INDEX_DESCRIPTION  41  MANPOS  8  Operating mode Jog */
#define O_MANPOS                  0x00000029L
#define O_MANPOS_START            0x00010029L   /* 1 - Activation of jog */
#define O_MANPOS_ACK              0x00020029L   /* 2 - acknowledge manual positon */
#define O_MANPOS_JOGMETHOD        0x00030029L   /* 3 - Selection of jog method */
#define O_MANPOS_SPEEDSLOW        0x00040029L   /* 4 - Velocity for slow movement */
#define O_MANPOS_SPEEDFAST        0x00050029L   /* 5 - Velocity for fast movement */
#define O_MANPOS_STEPPOSDIST      0x00070029L   /* 7 - Distance for step movement */
#define O_MANPOS_STEPWAITTIME     0x00080029L   /* 8 - Wait time for step movement */

/*INDEX_DESCRIPTION  43  IPMODE  2  Operating mode Interpolated Position */
#define O_IPMODE                  0x0000002BL
#define O_IPMODE_START            0x0001002BL   /* 1 - Start interpolated position mode */
#define O_IPMODE_ACK              0x0002002BL   /* 2 - Status of interpolated position mode */

/*INDEX_DESCRIPTION  45  DATSET  30  Operating mode Motion Sequence */
#define O_DATSET                  0x0000002DL
#define O_DATSET_START            0x0001002DL   /* 1 - MSM start object */
#define O_DATSET_ACK              0x0002002DL   /* 2 - Acknowledge of MSM */
#define O_DATSET_STARTDATASET     0x0003002DL   /* 3 - Start data set */
#define O_DATSET_STARTMOTIONSEQ   0x0004002DL   /* 4 - Start motion sequence */
#define O_DATSET_SETNUM           0x0005002DL   /* 5 - Selection of a data set to be started */
#define O_DATSET_ACTNUM           0x0006002DL   /* 6 - Current data set number */
#define O_DATSET_NEXTNUM          0x0007002DL   /* 7 - Next data set to be triggered */
#define O_DATSET_GLOBALCOND       0x0008002DL   /* 8 - Start condition for the start of a sequence via a signal input */
#define O_DATSET_LEAVENOTRANS     0x0009002DL   /* 9 - Selection of the data set number after the end of a sequence */
#define O_DATSET_TEACHIN          0x000A002DL   /* 10 - Take over current user position (TeachIn) */
#define O_DATSET_NUMFINISHED      0x000B002DL   /* 11 - Number of data set that was active when a movement was interrupted */
#define O_DATSET_STOPSINGLEDAT    0x000C002DL   /* 12 - Response to falling edge at signal input for 'Start Signal Data Set' */
#define O_DATSET_FLTROW           0x000D002DL   /* 13 - Number of the data set in which an error has been detected */
#define O_DATSET_FLTCOLUMN        0x000E002DL   /* 14 - Field of the data set in which an error has been detected */
#define O_DATSET_AVAILCNT         0x000F002DL   /* 15 - Number of available data sets */
#define O_DATSET_SELENTRY         0x0010002DL   /* 16 - Selection of data set number in data set table */
#define O_DATSET_DATATYPE         0x0011002DL   /* 17 - Data set type */
#define O_DATSET_PARAMINFO1       0x0012002DL   /* 18 - Setting A */
#define O_DATSET_PARAMINFO2       0x0013002DL   /* 19 - Setting B */
#define O_DATSET_PARAMINFO3       0x0014002DL   /* 20 - Setting C */
#define O_DATSET_PARAMINFO4       0x0015002DL   /* 21 - Setting D */
#define O_DATSET_PROFILETYPE      0x0016002DL   /* 22 - Transition type */
#define O_DATSET_DATANEXT         0x0017002DL   /* 23 - Subsequent data set */
#define O_DATSET_TRANSCOND1       0x0018002DL   /* 24 - Transition condition 1 */
#define O_DATSET_TRANSVAL1        0x0019002DL   /* 25 - Value for transition condition 1 */
#define O_DATSET_COMBINATION      0x001A002DL   /* 26 - Logical operator */
#define O_DATSET_TRANSCOND2       0x001C002DL   /* 28 - Transition condition 2 */
#define O_DATSET_TRANSVAL2        0x001D002DL   /* 29 - Value for transition condition 2 */
#define O_DATSET_IMMEDIATE        0x001E002DL   /* 30 - Start mode for data set processing without sequence */

/*INDEX_DESCRIPTION  46  MTUNE  12  Manual tuning */
#define O_MTUNE                   0x0000002EL
#define O_MTUNE_START             0x0001002EL   /* 1 - Steuerung interne Führungsgröße */
#define O_MTUNE_ACK               0x0002002EL   /* 2 - Quittung: interne Führungsgröße */
#define O_MTUNE_MAXDISTANCE       0x0003002EL   /* 3 - Maximum permissible distance */
#define O_MTUNE_SIGNALTYPE        0x0004002EL   /* 4 - Führungsgrößentyp */
#define O_MTUNE_REFPOSEDGE        0x0005002EL   /* 5 - Positive Flanke der Führungsgröße */
#define O_MTUNE_PERIOD            0x0006002EL   /* 6 - Periodendauer der Führungsgröße */
#define O_MTUNE_AMPLITUDE         0x0007002EL   /* 7 - Amplitude der Führungsgröße */
#define O_MTUNE_OFFSET            0x0008002EL   /* 8 - Offset der Führungsgröße */
#define O_MTUNE_CONTROLTYPE       0x0009002EL   /* 9 - Auswahl des Regler der stimuliert wird */
#define O_MTUNE_MAXDISTANCEUSR    0x000A002EL   /* 10 - Maximum permissible distance */
#define O_MTUNE_AMPLITUDEUSR      0x000B002EL   /* 11 - Amplitude der Führungsgröße in usr units */
#define O_MTUNE_OFFSETUSR         0x000C002EL   /* 12 - Offset der Führungsgröße in usr units */

/*INDEX_DESCRIPTION  47  ATUNE  20  Autotuning */
#define O_ATUNE                   0x0000002FL
#define O_ATUNE_AUTOTUNE          0x0001002FL   /* 1 - Autotuning start */
#define O_ATUNE_AUTOSTAT          0x0002002FL   /* 2 - Autotuning status */
#define O_ATUNE_POSRANGE          0x0003002FL   /* 3 - Movement range for Autotuning */
#define O_ATUNE_ROTSENSE          0x0004002FL   /* 4 - Direction of movement for Autotuning */
#define O_ATUNE_STIMCURRENT       0x0005002FL   /* 5 - Motorstrom bei der Bestimmung des Trägheitsmoments */
#define O_ATUNE_ROTSPEED          0x0006002FL   /* 6 - Jump of speed of rotation for Autotuning */
#define O_ATUNE_FRICTIONMOMENT    0x0007002FL   /* 7 - Friction torque of the system */
#define O_ATUNE_MOMENT            0x0008002FL   /* 8 - Constant load torque */
#define O_ATUNE_WAIT              0x0009002FL   /* 9 - Waiting time between Autotuning steps */
#define O_ATUNE_OPTIMIZE          0x000A002FL   /* 10 - Adaptation of control parameters (harder/softer) */
#define O_ATUNE_PROGRESS          0x000B002FL   /* 11 - Progress of Autotuning */
#define O_ATUNE_INERTIA           0x000C002FL   /* 12 - Moment of inertia of the entire system */
#define O_ATUNE_SPEEDTOL          0x000D002FL   /* 13 - Drehzahltoleranz bei der Bestimmung des Parametersatzes */
#define O_ATUNE_COUPLING          0x000E002FL   /* 14 - Type of coupling of the system */
#define O_ATUNE_OPTMAX            0x000F002FL   /* 15 - Härtester Reglerparametersatz der akzeptiert wird */
#define O_ATUNE_INFO1             0x0010002FL   /* 16 - Fehlerdiagnose durch den Kundendienst */
#define O_ATUNE_INFO2             0x0011002FL   /* 17 - Fehlerdiagnose durch den Kundendienst */
#define O_ATUNE_POSRANGEUSR       0x0012002FL   /* 18 - Movement range for Autotuning */
#define O_ATUNE_ROTVEL            0x0013002FL   /* 19 - Jump of velocity for Autotuning */
#define O_ATUNE_VELTOL            0x0014002FL   /* 20 - Geschwindigkeitstoleranz bei der Bestimmung des Parametersatzes */

/*INDEX_DESCRIPTION  48  OSCI  12  Simple oscilloscope IclA */
#define O_OSCI                    0x00000030L
#define O_OSCI_CONTROL            0x00010030L   /* 1 - Start und Status der Oszilloskopfunktion */
#define O_OSCI_MAXCNT             0x00020030L   /* 2 - Anzahl der max. aufzeichenbaren Messwerte */
#define O_OSCI_DATACNT            0x00030030L   /* 3 - Anzahl der aufgezeichneten Datenwerte */
#define O_OSCI_UPLOAD             0x00040030L   /* 4 - Upload der Daten */
#define O_OSCI_TIMEBASE           0x00050030L   /* 5 - Zeitbasis */
#define O_OSCI_TRIGDELAY          0x00060030L   /* 6 - Trigger-Verzögerung */
#define O_OSCI_TRIGCOND           0x00070030L   /* 7 - Trigger-Bedingung */
#define O_OSCI_TRIGCONST          0x00080030L   /* 8 - Trigger-Konstante */
#define O_OSCI_TRIGMASK           0x00090030L   /* 9 - Trigger-Maske */
#define O_OSCI_OBJTRIG            0x000A0030L   /* 10 - Trigger-Objekt */
#define O_OSCI_OBJCH1             0x000B0030L   /* 11 - Auswahl für Kanal 1 */
#define O_OSCI_OBJCH2             0x000C0030L   /* 12 - Auswahl für Kanal 2 */

/*INDEX_DESCRIPTION  49  SSCOPE  15  Slow oscilloscope */
#define O_SSCOPE                  0x00000031L
#define O_SSCOPE_COMMAND          0x00010031L   /* 1 - start/stop of function slow scope */
#define O_SSCOPE_NUMCHANNEL       0x00020031L   /* 2 - Anzahl der unterstützten Kanäle bei slow scope */
#define O_SSCOPE_VERSION          0x00030031L   /* 3 - Version vom slow scope */
#define O_SSCOPE_TIMEBASE         0x00040031L   /* 4 - Minimale Aufzeichnungszeit */
#define O_SSCOPE_LOADR1           0x00050031L   /* 5 - Logische Adresse vom Kanal 1 */
#define O_SSCOPE_LOADR2           0x00060031L   /* 6 - Logische Adresse vom Kanal 2 */
#define O_SSCOPE_LOADR3           0x00070031L   /* 7 - Logische Adresse vom Kanal 3 */
#define O_SSCOPE_LOADR4           0x00080031L   /* 8 - Logische Adresse vom Kanal 4 */
#define O_SSCOPE_LOADRTRI         0x00090031L   /* 9 - Logische Adresse vom Trigger */
#define O_SSCOPE_TRIGGDATE        0x000A0031L   /* 10 - Datum von der Aufzeichnung */
#define O_SSCOPE_DATA1            0x000B0031L   /* 11 - Daten vom Kanal 1 */
#define O_SSCOPE_DATA2            0x000C0031L   /* 12 - Daten vom Kanal 2 */
#define O_SSCOPE_DATA3            0x000D0031L   /* 13 - Daten vom Kanal 3 */
#define O_SSCOPE_DATA4            0x000E0031L   /* 14 - Daten vom Kanal 4 */
#define O_SSCOPE_TRIGGDATA        0x000F0031L   /* 15 - Daten vom Triggerkanal */

/*INDEX_DESCRIPTION  50  FSCOPE  23  Fast oscilloscope */
#define O_FSCOPE                  0x00000032L
#define O_FSCOPE_COMMAND          0x00010032L   /* 1 - start/stop of function fast scope */
#define O_FSCOPE_NUMCHANNEL       0x00020032L   /* 2 - Maximale Anzahl von verfügbaren Aufzeichnungskanälen */
#define O_FSCOPE_VERSION          0x00030032L   /* 3 - Version vom fast scope */
#define O_FSCOPE_TIMEBASE         0x00040032L   /* 4 - Sampling time from fast scope */
#define O_FSCOPE_STATUS           0x00050032L   /* 5 - Scope Status */
#define O_FSCOPE_THM              0x00060032L   /* 6 - Anzahl von Aufzeichnungsparameter zum Triggerzeitpunkt */
#define O_FSCOPE_BUFFERSIZE       0x00070032L   /* 7 - Puffergröße */
#define O_FSCOPE_TRIGOP           0x00080032L   /* 8 - Triggeroperation */
#define O_FSCOPE_FILTERTIME       0x00090032L   /* 9 - Filter Time Constant */
#define O_FSCOPE_DELAYTRIG        0x000A0032L   /* 10 - Trigger Verzögerung */
#define O_FSCOPE_TRIGMASK1        0x000B0032L   /* 11 - Trigger Maske 1 */
#define O_FSCOPE_TRIGMASK2        0x000C0032L   /* 12 - Trigger Maske 2 */
#define O_FSCOPE_TRIGVAL1         0x000D0032L   /* 13 - Trigger Wert 1 */
#define O_FSCOPE_TRIGVAL2         0x000E0032L   /* 14 - Trigger Wert 2 */
#define O_FSCOPE_LOADR1           0x000F0032L   /* 15 - Logische Adresse vom Kanal 1 */
#define O_FSCOPE_LOADR2           0x00100032L   /* 16 - Logische Adresse vom Kanal 2 */
#define O_FSCOPE_LOADR3           0x00110032L   /* 17 - Logische Adresse vom Kanal 3 */
#define O_FSCOPE_LOADR4           0x00120032L   /* 18 - Logische Adresse vom Kanal 4 */
#define O_FSCOPE_LOADRTRI         0x00130032L   /* 19 - Logische Adresse vom Trigger */
#define O_FSCOPE_V1L              0x00140032L   /* 20 - Logische Adresse vom Parameter 1 */
#define O_FSCOPE_V2L              0x00150032L   /* 21 - Logische Adresse vom Parameter 2 */
#define O_FSCOPE_V3L              0x00160032L   /* 22 - Logische Adresse vom Parameter 3 */
#define O_FSCOPE_DATATRANSFER     0x00170032L   /* 23 - Trace Daten Transfer */

/*INDEX_DESCRIPTION  51  PLIST  6  Position list */
#define O_PLIST                   0x00000033L
#define O_PLIST_INDEX             0x00010033L   /* 1 - Aktueller Index auf die Positionsliste */
#define O_PLIST_VALUE             0x00020033L   /* 2 - Positionslistenwert für/aus der Positionsliste */
#define O_PLIST_START             0x00030033L   /* 3 - Aktivieren der Positionsliste */
#define O_PLIST_SELECTED          0x00040033L   /* 4 - Anzahl der zu berücksichtigenden Listeneinträge */
#define O_PLIST_INTERVAL          0x00050033L   /* 5 - Intervall innerhalb der Positionsliste */
#define O_PLIST_SOURCE            0x00060033L   /* 6 - Selection of source */

/*INDEX_DESCRIPTION  58  HMI  5  HMI */
#define O_HMI                     0x0000003AL
#define O_HMI_PROTECTED           0x0001003AL   /* 1 - Lock HMI */
#define O_HMI_SUPERVISION         0x0002003AL   /* 2 - HMI display when motor moves */
#define O_HMI_LANGUAGE            0x0003003AL   /* 3 - Dialog language of ext. HMI */
#define O_HMI_HMIUNAME            0x0004003AL   /* 4 - User application name HMI, part4 */
#define O_HMI_ETHFSUSUPPRESS      0x0005003AL   /* 5 - Ethernet FSU suppress */

/*INDEX_DESCRIPTION  59  ERRADM  14  Error memory administration */
#define O_ERRADM                  0x0000003BL
#define O_ERRADM_ERRCHANGE        0x0001003BL   /* 1 - Fehlerspeicher Änderung */
#define O_ERRADM_POWONNUM         0x0002003BL   /* 2 - Number of power on cycles */
#define O_ERRADM_MEMNUM           0x0003003BL   /* 3 - Anzahl verfügbarer Fehlereinträge */
#define O_ERRADM_DELALL           0x0004003BL   /* 4 - Clear error memory */
#define O_ERRADM_ERRMEMRESET      0x0005003BL   /* 5 - Reset error memory read pointer */
#define O_ERRADM_SPVSELERR1       0x0006003BL   /* 6 - First number for the signal output function Selected Error */
#define O_ERRADM_SPVSELERR2       0x0007003BL   /* 7 - Second number for the signal output function Selected Error */
#define O_ERRADM_SPVSELWARN1      0x0008003BL   /* 8 - First number for the signal output function Selected Warning */
#define O_ERRADM_SPVSELWARN2      0x0009003BL   /* 9 - Second number for the signal output function Selected Warning */
#define O_ERRADM_ERRCLASS0CONFIG  0x000A003BL   /* 10 - Bitmask to change an error to a warning */
#define O_ERRADM_ERRGEN           0x000B003BL   /* 11 - Fieldbus module error notification */
#define O_ERRADM_CHNLNOTIFY       0x000C003BL   /* 12 - Fieldbus module channel notification */
#define O_ERRADM_MOCRESET         0x000D003BL   /* 13 - Error Memory of Motorconfiguration: Reset */
#define O_ERRADM_MOCREADPARAM     0x000E003BL   /* 14 - Error Memory of Motorconfiguration: Param Address */

/*INDEX_DESCRIPTION  60  ERRMEM  11  Error memory */
#define O_ERRMEM                  0x0000003CL
#define O_ERRMEM_ERRNUM           0x0001003CL   /* 1 - Error number */
#define O_ERRMEM_ERRCLASS         0x0002003CL   /* 2 - Error class */
#define O_ERRMEM_ERRTIME          0x0003003CL   /* 3 - Error time */
#define O_ERRMEM_ERRQUAL          0x0004003CL   /* 4 - Error additional information */
#define O_ERRMEM_ERRAMPCYC        0x0005003CL   /* 5 - Number of cycles of enabling the power stage at error time */
#define O_ERRMEM_ERRAMPTIME       0x0006003CL   /* 6 - Time between enabling of power stage and occurrence of the error */
#define O_ERRMEM_ERRUZ            0x0007003CL   /* 7 - DC bus voltage at error time */
#define O_ERRMEM_ERRNACT          0x0008003CL   /* 8 - Motor velocity at error time */
#define O_ERRMEM_ERRIACTDQ        0x0009003CL   /* 9 - Motor current at error time */
#define O_ERRMEM_ERRTLE           0x000A003CL   /* 10 - Temperature of power stage at error time */
#define O_ERRMEM_ERRTCPU          0x000B003CL   /* 11 - Temperature of device at error time */

/*INDEX_DESCRIPTION  63  DIAG  87  Service and diagnose */
#define O_DIAG                    0x0000003FL
#define O_DIAG_HEAPSIZEH0         0x0001003FL   /* 1 - Heapgröße RAMH0 */
#define O_DIAG_HEAPFREEH0         0x0002003FL   /* 2 - Freier Heapbereich RAMH0 */
#define O_DIAG_STACKSIZE          0x0003003FL   /* 3 - Stackgröße */
#define O_DIAG_STACKFREE          0x0004003FL   /* 4 - Freier Stackbereich */
#define O_DIAG_MEMADR             0x0005003FL   /* 5 - Speicherzugriff Adresse */
#define O_DIAG_MEMTYPE            0x0006003FL   /* 6 - Speicherzugriff Typ */
#define O_DIAG_MEMACCESS          0x0007003FL   /* 7 - Speicherzugriff durchführen */
#define O_DIAG_WATCHDOG           0x0008003FL   /* 8 - Watchdog Test */
#define O_DIAG_MAXMAINTIME        0x0009003FL   /* 9 - Max. Bearbeitungszeit der Mainloop */
#define O_DIAG_ERRCLEARALL        0x000A003FL   /* 10 - Unterdrücken von Fehlern */
#define O_DIAG_ERRGEN             0x000B003FL   /* 11 - Erzeugen eines beliebigen Fehlereintrages */
#define O_DIAG_EEPROMACC          0x000F003FL   /* 15 - Speicherzugriff EEPROM durchführen */
#define O_DIAG_MAX62TIME          0x0012003FL   /* 18 - Max. Bearbeitungszeit der 62.5 µs Task */
#define O_DIAG_MAX250TIME         0x0013003FL   /* 19 - Max. Bearbeitungszeit der 250 µs Task */
#define O_DIAG_MAXMSTIME          0x0014003FL   /* 20 - Max. Bearbeitungszeit der 1ms Task */
#define O_DIAG_MAXFBTIME          0x0015003FL   /* 21 - Max. Bearbeitungszeit FB-Service-Routine */
#define O_DIAG_MSTIMER            0x0016003FL   /* 22 - freilaufender Millisekundenzähler */
#define O_DIAG_INTHMIEVENT        0x0017003FL   /* 23 - internal hmi send keyboard event */
#define O_DIAG_INTHMIDISP         0x0018003FL   /* 24 - internal HMI string (4 characters) */
#define O_DIAG_INTHMIDOT          0x0019003FL   /* 25 - internal HMI current active dots / LEDs */
#define O_DIAG_DA2SCAL            0x001A003FL   /* 26 - Skalierungsfaktor DA-Wandler 2 */
#define O_DIAG_DA1OFFSET          0x001B003FL   /* 27 - Offset DA-Wandler 1 */
#define O_DIAG_DA2OFFSET          0x001C003FL   /* 28 - Offset DA-Wandler 2 */
#define O_DIAG_STARTUPTIME        0x001E003FL   /* 30 - Startup Time (PowerOn -> Start MainLoop) */
#define O_DIAG_ENABLETIME         0x001F003FL   /* 31 - ENABLE-time */
#define O_DIAG_TRIGTEST           0x0020003FL   /* 32 - Triggertest */
#define O_DIAG_TRIGTESTNOM        0x0021003FL   /* 33 - Triggertest Normierung */
#define O_DIAG_TRIGTESTDEN        0x0022003FL   /* 34 - Triggertest Denominator */
#define O_DIAG_ENCVALCOS          0x0023003FL   /* 35 - Encodervalue Cosinus */
#define O_DIAG_ENCVALSIN          0x0024003FL   /* 36 - Encodervalue Sinus */
#define O_DIAG_XEND0CNTCYCFAST    0x0027003FL   /* 39 - Zyklenzähler des letzten Zyklus mit x_end EQ 0 (in n * 250 µs) */
#define O_DIAG_POSBLENDCONDFND    0x002E003FL   /* 46 - Reale interne Umschaltposition bei überlagerter Bewegung */
#define O_DIAG_ACTSPGSTATECHK     0x0030003FL   /* 48 - Aktivierung Aufzeichnung bei Bewegungszustandsänderung */
#define O_DIAG_POSSPGCHGACC       0x0031003FL   /* 49 - Interne SPG-Position bei Übergang in Beschleunigung */
#define O_DIAG_TIMESPGCHGACC      0x0032003FL   /* 50 - Zeitstempel bei Übergang des SPGs in Beschleunigung */
#define O_DIAG_POSSPGCHGCNST      0x0033003FL   /* 51 - Interne SPG-Position bei Übergang in Konstantfahrt */
#define O_DIAG_TIMESPGCHGCNST     0x0034003FL   /* 52 - Zeitstempel bei Übergang des SPGs in Konstantfahrt */
#define O_DIAG_POSSPGCHGDEC       0x0035003FL   /* 53 - Interne SPG-Position bei Übergang in Verzögerung */
#define O_DIAG_TIMESPGCHGDEC      0x0036003FL   /* 54 - Zeitstempel bei Übergang des SPGs in Verzögerung */
#define O_DIAG_POSSPGCHGSTAND     0x0037003FL   /* 55 - Interne SPG-Position bei Übergang in Stillstand */
#define O_DIAG_TIMESPGCHGSTAND    0x0038003FL   /* 56 - Zeitstempel bei Übergang des SPGs in Stillstand */
#define O_DIAG_MAXIQREFTIME       0x0039003FL   /* 57 - Max. Bearbeitungszeit bis iqref berechnet */
#define O_DIAG_MIN62TIME          0x003B003FL   /* 59 - Min. Bearbeitungszeit der 62.5 µs Task */
#define O_DIAG_AVER62TIME         0x003C003FL   /* 60 - Mittlere Bearbeitungszeit der 62.5 µs Task */
#define O_DIAG_MIN250TIME         0x003D003FL   /* 61 - Min. Bearbeitungszeit der 250 µs Task */
#define O_DIAG_AVER250TIME        0x003E003FL   /* 62 - Mittlere Bearbeitungszeit der 250 µs Task */
#define O_DIAG_MINMSTIME          0x003F003FL   /* 63 - Min. Bearbeitungszeit der 1ms Task */
#define O_DIAG_AVERMSTIME         0x0040003FL   /* 64 - Mittlere Bearbeitungszeit der 1 ms Task */
#define O_DIAG_MINMAINTIME        0x0041003FL   /* 65 - Min. Bearbeitungszeit der Mainloop */
#define O_DIAG_AVERMAINTIME       0x0042003FL   /* 66 - Mittlere Bearbeitungszeit der Mainloop */
#define O_DIAG_LOADCTRL           0x0043003FL   /* 67 - Aktivieren der Systemlastmessung */
#define O_DIAG_DISIRQMAX          0x0044003FL   /* 68 - IRQ disable : max. time */
#define O_DIAG_DISIRQADR          0x0045003FL   /* 69 - IRQ disable : address */
#define O_DIAG_MINFBTIME          0x0046003FL   /* 70 - Min. Bearbeitungszeit der FB-task */
#define O_DIAG_AVERFBTIME         0x0047003FL   /* 71 - Mittlere Bearbeitungszeit der FB Task */
#define O_DIAG_CPUFEATURE         0x0048003FL   /* 72 - formerly: CPU board feature bits */
#define O_DIAG_BRESBURNIN         0x0049003FL   /* 73 - burn in of braking resistor */
#define O_DIAG_GETNEWINFO         0x004A003FL   /* 74 - Information about system memory occupancy */
#define O_DIAG_GETEPRINFO         0x004B003FL   /* 75 - Actual EEPROM file mapping */
#define O_DIAG_MEMCARDACC         0x004C003FL   /* 76 - Speicherzugriff Speicherkarte durchführen */
#define O_DIAG_MAXPOSCTRLTIME     0x004D003FL   /* 77 - Max. Bearbeitungszeit Start 62,5µs Task bis Ende Positionsregler */
#define O_DIAG_MINFBMAINTIME      0x004E003FL   /* 78 - Min. Bearbeitungszeit der FB mainloop */
#define O_DIAG_AVERFBMAINTIME     0x004F003FL   /* 79 - Mittlere Bearbeitungszeit der FB mainloop */
#define O_DIAG_MAXFBMAINTIME      0x0050003FL   /* 80 - Max. Bearbeitungszeit FB mainloop */
#define O_DIAG_FATALERRCTRL       0x0051003FL   /* 81 - System reaction in case of fatal errors */
#define O_DIAG_UNITTEST           0x0052003FL   /* 82 - Unit Test Parameter */
#define O_DIAG_SIMULATEPLD        0x0053003FL   /* 83 - Simulation of old hardware (PLD) */
#define O_DIAG_PRGNR              0x0054003FL   /* 84 - Dummy program number */
#define O_DIAG_VERSION            0x0055003FL   /* 85 - Dummy program version  number */
#define O_DIAG_REVISION           0x0056003FL   /* 86 - Dummy program revision number */
#define O_DIAG_SPEEDDOMINANCE     0x0057003FL   /* 87 - Setting speed in operating mode SpeedGear */

/*INDEX_DESCRIPTION  64  FBUS  67  Common fieldbus interface parameters */
#define O_FBUS                    0x00000040L
#define O_FBUS_IODATAMS01         0x00010040L   /* 1 - I/O parameter data Master to Slave - parameter 01 */
#define O_FBUS_IODATAMS02         0x00020040L   /* 2 - I/O parameter data Master to Slave - parameter 02 */
#define O_FBUS_IODATAMS03         0x00030040L   /* 3 - I/O parameter data Master to Slave - parameter 03 */
#define O_FBUS_IODATAMS04         0x00040040L   /* 4 - I/O parameter data Master to Slave - parameter 04 */
#define O_FBUS_IODATAMS05         0x00050040L   /* 5 - I/O parameter data Master to Slave - parameter 05 */
#define O_FBUS_IODATAMS06         0x00060040L   /* 6 - I/O parameter data Master to Slave - parameter 06 */
#define O_FBUS_IODATAMS07         0x00070040L   /* 7 - I/O parameter data Master to Slave - parameter 07 */
#define O_FBUS_IODATAMS08         0x00080040L   /* 8 - I/O parameter data Master to Slave - parameter 08 */
#define O_FBUS_IODATAMS09         0x00090040L   /* 9 - I/O parameter data Master to Slave - parameter 09 */
#define O_FBUS_IODATAMS10         0x000A0040L   /* 10 - I/O parameter data Master to Slave - parameter 10 */
#define O_FBUS_IODATAMS11         0x000B0040L   /* 11 - I/O parameter data Master to Slave - parameter 11 */
#define O_FBUS_IODATAMS12         0x000C0040L   /* 12 - I/O parameter data Master to Slave - parameter 12 */
#define O_FBUS_IODATAMS13         0x000D0040L   /* 13 - I/O parameter data Master to Slave - parameter 13 */
#define O_FBUS_IODATAMS14         0x000E0040L   /* 14 - I/O parameter data Master to Slave - parameter 14 */
#define O_FBUS_IODATAMS15         0x000F0040L   /* 15 - I/O parameter data Master to Slave - parameter 15 */
#define O_FBUS_IODATAMS16         0x00100040L   /* 16 - I/O parameter data Master to Slave - parameter 16 */
#define O_FBUS_IOMAPMS01          0x00110040L   /* 17 - I/O parameter mapping Master to Slave - parameter 01 */
#define O_FBUS_IOMAPMS02          0x00120040L   /* 18 - I/O parameter mapping Master to Slave - parameter 02 */
#define O_FBUS_IOMAPMS03          0x00130040L   /* 19 - I/O parameter mapping Master to Slave - parameter 03 */
#define O_FBUS_IOMAPMS04          0x00140040L   /* 20 - I/O parameter mapping Master to Slave - parameter 04 */
#define O_FBUS_IOMAPMS05          0x00150040L   /* 21 - I/O parameter mapping Master to Slave - parameter 05 */
#define O_FBUS_IOMAPMS06          0x00160040L   /* 22 - I/O parameter mapping Master to Slave - parameter 06 */
#define O_FBUS_IOMAPMS07          0x00170040L   /* 23 - I/O parameter mapping Master to Slave - parameter 07 */
#define O_FBUS_IOMAPMS08          0x00180040L   /* 24 - I/O parameter mapping Master to Slave - parameter 08 */
#define O_FBUS_IOMAPMS09          0x00190040L   /* 25 - I/O parameter mapping Master to Slave - parameter 09 */
#define O_FBUS_IOMAPMS10          0x001A0040L   /* 26 - I/O parameter mapping Master to Slave - parameter 10 */
#define O_FBUS_IOMAPMS11          0x001B0040L   /* 27 - I/O parameter mapping Master to Slave - parameter 11 */
#define O_FBUS_IOMAPMS12          0x001C0040L   /* 28 - I/O parameter mapping Master to Slave - parameter 12 */
#define O_FBUS_IOMAPMS13          0x001D0040L   /* 29 - I/O parameter mapping Master to Slave - parameter 13 */
#define O_FBUS_IOMAPMS14          0x001E0040L   /* 30 - I/O parameter mapping Master to Slave - parameter 14 */
#define O_FBUS_IOMAPMS15          0x001F0040L   /* 31 - I/O parameter mapping Master to Slave - parameter 15 */
#define O_FBUS_IOMAPMS16          0x00200040L   /* 32 - I/O parameter mapping Master to Slave - parameter 16 */
#define O_FBUS_IODATASM01         0x00210040L   /* 33 - I/O parameter data Slave to Master - parameter 01 */
#define O_FBUS_IODATASM02         0x00220040L   /* 34 - I/O parameter data Slave to Master - parameter 02 */
#define O_FBUS_IODATASM03         0x00230040L   /* 35 - I/O parameter data Slave to Master - parameter 03 */
#define O_FBUS_IODATASM04         0x00240040L   /* 36 - I/O parameter data Slave to Master - parameter 04 */
#define O_FBUS_IODATASM05         0x00250040L   /* 37 - I/O parameter data Slave to Master - parameter 05 */
#define O_FBUS_IODATASM06         0x00260040L   /* 38 - I/O parameter data Slave to Master - parameter 06 */
#define O_FBUS_IODATASM07         0x00270040L   /* 39 - I/O parameter data Slave to Master - parameter 07 */
#define O_FBUS_IODATASM08         0x00280040L   /* 40 - I/O parameter data Slave to Master - parameter 08 */
#define O_FBUS_IODATASM09         0x00290040L   /* 41 - I/O parameter data Slave to Master - parameter 09 */
#define O_FBUS_IODATASM10         0x002A0040L   /* 42 - I/O parameter data Slave to Master - parameter 10 */
#define O_FBUS_IODATASM11         0x002B0040L   /* 43 - I/O parameter data Slave to Master - parameter 11 */
#define O_FBUS_IODATASM12         0x002C0040L   /* 44 - I/O parameter data Slave to Master - parameter 12 */
#define O_FBUS_IODATASM13         0x002D0040L   /* 45 - I/O parameter data Slave to Master - parameter 13 */
#define O_FBUS_IODATASM14         0x002E0040L   /* 46 - I/O parameter data Slave to Master - parameter 14 */
#define O_FBUS_IODATASM15         0x002F0040L   /* 47 - I/O parameter data Slave to Master - parameter 15 */
#define O_FBUS_IODATASM16         0x00300040L   /* 48 - I/O parameter data Slave to Master - parameter 16 */
#define O_FBUS_IOMAPSM01          0x00310040L   /* 49 - I/O parameter mapping Slave to Master - parameter 01 */
#define O_FBUS_IOMAPSM02          0x00320040L   /* 50 - I/O parameter mapping Slave to Master - parameter 02 */
#define O_FBUS_IOMAPSM03          0x00330040L   /* 51 - I/O parameter mapping Slave to Master - parameter 03 */
#define O_FBUS_IOMAPSM04          0x00340040L   /* 52 - I/O parameter mapping Slave to Master - parameter 04 */
#define O_FBUS_IOMAPSM05          0x00350040L   /* 53 - I/O parameter mapping Slave to Master - parameter 05 */
#define O_FBUS_IOMAPSM06          0x00360040L   /* 54 - I/O parameter mapping Slave to Master - parameter 06 */
#define O_FBUS_IOMAPSM07          0x00370040L   /* 55 - I/O parameter mapping Slave to Master - parameter 07 */
#define O_FBUS_IOMAPSM08          0x00380040L   /* 56 - I/O parameter mapping Slave to Master - parameter 08 */
#define O_FBUS_IOMAPSM09          0x00390040L   /* 57 - I/O parameter mapping Slave to Master - parameter 09 */
#define O_FBUS_IOMAPSM10          0x003A0040L   /* 58 - I/O parameter mapping Slave to Master - parameter 10 */
#define O_FBUS_IOMAPSM11          0x003B0040L   /* 59 - I/O parameter mapping Slave to Master - parameter 11 */
#define O_FBUS_IOMAPSM12          0x003C0040L   /* 60 - I/O parameter mapping Slave to Master - parameter 12 */
#define O_FBUS_IOMAPSM13          0x003D0040L   /* 61 - I/O parameter mapping Slave to Master - parameter 13 */
#define O_FBUS_IOMAPSM14          0x003E0040L   /* 62 - I/O parameter mapping Slave to Master - parameter 14 */
#define O_FBUS_IOMAPSM15          0x003F0040L   /* 63 - I/O parameter mapping Slave to Master - parameter 15 */
#define O_FBUS_IOMAPSM16          0x00400040L   /* 64 - I/O parameter mapping Slave to Master - parameter 16 */
#define O_FBUS_IOCINHIBITTIME     0x00410040L   /* 65 - Inhibit time for internal IOC scanner input data */
#define O_FBUS_PDOMASK            0x00420040L   /* 66 - Deactivate receive PDO */
#define O_FBUS_ERRNUMFBPARSVC     0x00430040L   /* 67 - Last error number of fieldbus parameter services */

/*INDEX_DESCRIPTION  65  CAN  16  CANopen interface */
#define O_CAN                     0x00000041L
#define O_CAN_NODEID              0x00020041L   /* 2 - CANopen address (node number) */
#define O_CAN_BAUDRATE            0x00030041L   /* 3 - CANopen baud rate */
#define O_CAN_CANDIAG             0x00060041L   /* 6 - CANopen diagnosis word */
#define O_CAN_MANUSDOABORT        0x000A0041L   /* 10 - CANopen Manufacturer-specific SDO Abort Code */
#define O_CAN_PDO1EVENT           0x000B0041L   /* 11 - PDO 1 event mask */
#define O_CAN_PDO2EVENT           0x000C0041L   /* 12 - PDO 2 event mask */
#define O_CAN_PDO3EVENT           0x000D0041L   /* 13 - PDO 3 event mask */
#define O_CAN_PDO4EVENT           0x000E0041L   /* 14 - PDO 4 event mask */
#define O_CAN_DIPNODEID           0x000F0041L   /* 15 - CANopen address (node number) set via DIP switches */
#define O_CAN_DIPBAUDRATE         0x00100041L   /* 16 - CANopen baud rate set via DIP switches */

/*INDEX_DESCRIPTION  66  DEVNET  5  DeviceNet interface */
#define O_DEVNET                  0x00000042L
#define O_DEVNET_MACID            0x00010042L   /* 1 - DeviceNet node address (MAC ID) */
#define O_DEVNET_DEVBAUDRATE      0x00020042L   /* 2 - DeviceNet baud rate */
#define O_DEVNET_BUSPOWER         0x00030042L   /* 3 - Monitoring of DeviceNet bus power supply */
#define O_DEVNET_IODATAIN         0x00040042L   /* 4 - DeviceNet I/O data input */
#define O_DEVNET_IODATAOUT        0x00050042L   /* 5 - DeviceNet I/O data output */

/*INDEX_DESCRIPTION  67  PROFI  4  ProfibusDP interface */
#define O_PROFI                   0x00000043L
#define O_PROFI_PBIDENT           0x00010043L   /* 1 - PNO Identnummer */
#define O_PROFI_ADDRESS           0x00020043L   /* 2 - Profibus address */
#define O_PROFI_PROFILE           0x00030043L   /* 3 - Profibus drive profile */
#define O_PROFI_BAUDRATE          0x00040043L   /* 4 - Profibus baud rate */

/*INDEX_DESCRIPTION  68  ETHNET  107  Ethernet interface */
#define O_ETHNET                  0x00000044L
#define O_ETHNET_MODE             0x00010044L   /* 1 - Protocol */
#define O_ETHNET_RATESET          0x00020044L   /* 2 - Transmission rate setting */
#define O_ETHNET_RATEL            0x00030044L   /* 3 - Transmission rate port A */
#define O_ETHNET_RATER            0x00040044L   /* 4 - Transmission rate port B */
#define O_ETHNET_IPMODE           0x00050044L   /* 5 - Type of obtaining IP address */
#define O_ETHNET_WEBSERVER        0x00060044L   /* 6 - Ethernet webserver */
#define O_ETHNET_IPCARD1          0x00070044L   /* 7 - IP address Ethernet module, byte 1 */
#define O_ETHNET_IPCARD2          0x00080044L   /* 8 - IP address Ethernet module, byte 2 */
#define O_ETHNET_IPCARD3          0x00090044L   /* 9 - IP address Ethernet module, byte 3 */
#define O_ETHNET_IPCARD4          0x000A0044L   /* 10 - IP address Ethernet module, byte 4 */
#define O_ETHNET_IPMASK1          0x000B0044L   /* 11 - IP address subnet mask, byte 1 */
#define O_ETHNET_IPMASK2          0x000C0044L   /* 12 - IP address subnet mask, byte 2 */
#define O_ETHNET_IPMASK3          0x000D0044L   /* 13 - IP address subnet mask, byte 3 */
#define O_ETHNET_IPMASK4          0x000E0044L   /* 14 - IP address subnet mask, byte 4 */
#define O_ETHNET_IPGATE1          0x000F0044L   /* 15 - IP address gateway, byte 1 */
#define O_ETHNET_IPGATE2          0x00100044L   /* 16 - IP address gateway, byte 2 */
#define O_ETHNET_IPGATE3          0x00110044L   /* 17 - IP address gateway, byte 3 */
#define O_ETHNET_IPGATE4          0x00120044L   /* 18 - IP address gateway, byte 4 */
#define O_ETHNET_IPCARDACT1       0x00130044L   /* 19 - Current IP address Ethernet module, byte 1 */
#define O_ETHNET_IPCARDACT2       0x00140044L   /* 20 - Current IP address Ethernet module, byte 2 */
#define O_ETHNET_IPCARDACT3       0x00150044L   /* 21 - Current IP address Ethernet module, byte 3 */
#define O_ETHNET_IPCARDACT4       0x00160044L   /* 22 - Current IP address Ethernet module, byte 4 */
#define O_ETHNET_IPMASKACT1       0x00170044L   /* 23 - Current IP address subnet mask, byte 1 */
#define O_ETHNET_IPMASKACT2       0x00180044L   /* 24 - Current IP address subnet mask, byte 2 */
#define O_ETHNET_IPMASKACT3       0x00190044L   /* 25 - Current IP address subnet mask, byte 3 */
#define O_ETHNET_IPMASKACT4       0x001A0044L   /* 26 - Current IP address subnet mask, byte 4 */
#define O_ETHNET_IPGATEACT1       0x001B0044L   /* 27 - Current IP address gateway, byte 1 */
#define O_ETHNET_IPGATEACT2       0x001C0044L   /* 28 - Current IP address gateway, byte 2 */
#define O_ETHNET_IPGATEACT3       0x001D0044L   /* 29 - Current IP address gateway, byte 3 */
#define O_ETHNET_IPGATEACT4       0x001E0044L   /* 30 - Current IP address gateway, byte 4 */
#define O_ETHNET_MAC1             0x001F0044L   /* 31 - MAC address Ethernet module, byte 1 */
#define O_ETHNET_MAC2             0x00200044L   /* 32 - MAC address Ethernet module, byte 2 */
#define O_ETHNET_MAC3             0x00210044L   /* 33 - MAC address Ethernet module, byte 3 */
#define O_ETHNET_MAC4             0x00220044L   /* 34 - MAC address Ethernet module, byte 4 */
#define O_ETHNET_MAC5             0x00230044L   /* 35 - MAC address Ethernet module, byte 5 */
#define O_ETHNET_MAC6             0x00240044L   /* 36 - MAC address Ethernet module, byte 6 */
#define O_ETHNET_ERROR            0x00250044L   /* 37 - Ethernet error */
#define O_ETHNET_MBSCANNER        0x00280044L   /* 40 - Modbus TCP I/O scanning */
#define O_ETHNET_IPMASTER1        0x00290044L   /* 41 - IP address master, byte 1 */
#define O_ETHNET_IPMASTER2        0x002A0044L   /* 42 - IP address master, byte 2 */
#define O_ETHNET_IPMASTER3        0x002B0044L   /* 43 - IP address master, byte 3 */
#define O_ETHNET_IPMASTER4        0x002C0044L   /* 44 - IP address master, byte 4 */
#define O_ETHNET_MBSCANTIMEOUT    0x002D0044L   /* 45 - Modbus TCP I/O scanning timeout */
#define O_ETHNET_MBSCANOUT1       0x002E0044L   /* 46 - Optionally mapped output parameter 1 (PLC to drive) */
#define O_ETHNET_MBSCANOUT2       0x002F0044L   /* 47 - Optionally mapped output parameter 2 (PLC to drive) */
#define O_ETHNET_MBSCANOUT3       0x00300044L   /* 48 - Optionally mapped output parameter 3 (PLC to drive) */
#define O_ETHNET_MBSCANINP1       0x00340044L   /* 52 - Optionally mapped input parameter 1 (drive to PLC) */
#define O_ETHNET_MBSCANINP2       0x00350044L   /* 53 - Optionally mapped input parameter 2 (drive to PLC) */
#define O_ETHNET_MBSCANINP3       0x00360044L   /* 54 - Optionally mapped input parameter 3 (drive to PLC) */
#define O_ETHNET_IPFDR1           0x003C0044L   /* 60 - Current IP address FDR server, byte 1 */
#define O_ETHNET_IPFDR2           0x003D0044L   /* 61 - Current IP address FDR server, byte 2 */
#define O_ETHNET_IPFDR3           0x003E0044L   /* 62 - Current IP address FDR server, byte 3 */
#define O_ETHNET_IPFDR4           0x003F0044L   /* 63 - Current IP address FDR server, byte 4 */
#define O_ETHNET_FDRENABLE        0x00400044L   /* 64 - FDR service */
#define O_ETHNET_FDRLOCALCFG      0x00410044L   /* 65 - FDR local configuration */
#define O_ETHNET_ERRORMGT         0x00420044L   /* 66 - FDR error management */
#define O_ETHNET_FDRACTION        0x00430044L   /* 67 - FDR action */
#define O_ETHNET_FDRTIME          0x00440044L   /* 68 - FDR autosave time */
#define O_ETHNET_FDRSTATUS        0x00450044L   /* 69 - FDR status */
#define O_ETHNET_FDRERROR         0x00460044L   /* 70 - FDR last error code */
#define O_ETHNET_FDRCNTSAVE       0x00470044L   /* 71 - FDR save counter */
#define O_ETHNET_FDRCNTREST       0x00480044L   /* 72 - FDR restore counter */
#define O_ETHNET_FDRCNTDEL        0x00490044L   /* 73 - FDR delete counter */
#define O_ETHNET_ASMIN            0x004B0044L   /* 75 - Input assembly */
#define O_ETHNET_ASMOUT           0x004C0044L   /* 76 - Output assembly */
#define O_ETHNET_MBIPSWAP1        0x00500044L   /* 80 - IP address of master for Modbus word swap, byte 1 */
#define O_ETHNET_MBIPSWAP2        0x00510044L   /* 81 - IP address of master for Modbus word swap, byte 2 */
#define O_ETHNET_MBIPSWAP3        0x00520044L   /* 82 - IP address of master for Modbus word swap, byte 3 */
#define O_ETHNET_MBIPSWAP4        0x00530044L   /* 83 - IP address of master for Modbus word swap, byte 4 */
#define O_ETHNET_CFGCHANGE        0x00550044L   /* 85 - Module parameter change notification */
#define O_ETHNET_CFGDEFAULT       0x00560044L   /* 86 - Reset module parameters to default */
#define O_ETHNET_STATTCPOPEN      0x005A0044L   /* 90 - Open TCP connections */
#define O_ETHNET_STATMBRCV        0x005B0044L   /* 91 - Received Modbus TCP message */
#define O_ETHNET_STATMBSND        0x005C0044L   /* 92 - Sent Modbus TCP message */
#define O_ETHNET_STATMBERR        0x005D0044L   /* 93 - Modbus errors messages */
#define O_ETHNET_STATMBSCANRCV    0x005E0044L   /* 94 - Modbus TCP I/O scans received */
#define O_ETHNET_STATMBSCANSND    0x005F0044L   /* 95 - Modbus TCP I/O scans transmitted */
#define O_ETHNET_STATMBSCANERR    0x00600044L   /* 96 - Modbus TCP I/O scanning errors */
#define O_ETHNET_STATFRAMEFMT     0x00610044L   /* 97 - Ethernet frame format */
#define O_ETHNET_STATFRAMERCV     0x00620044L   /* 98 - Frame received OK */
#define O_ETHNET_STATFRAMESND     0x00630044L   /* 99 - Frame transmitted OK */
#define O_ETHNET_STATCRCERR       0x00640044L   /* 100 - CRC errors */
#define O_ETHNET_STATCOLL         0x00650044L   /* 101 - Collisions */
#define O_ETHNET_STATCARRERR      0x00660044L   /* 102 - Carrier sense errors */
#define O_ETHNET_STATCOLLE        0x00670044L   /* 103 - Excessive collisions */
#define O_ETHNET_STATCOLLL        0x00680044L   /* 104 - Late collisions */
#define O_ETHNET_STATPORTR        0x00690044L   /* 105 - Link status: Port B */
#define O_ETHNET_STATPORTL        0x006A0044L   /* 106 - Link status: Port A */
#define O_ETHNET_FDRAUTOSAVE      0x006B0044L   /* 107 - FDR autosave enable */

/*INDEX_DESCRIPTION  69  ETHCAT  12  EtherCAT interface */
#define O_ETHCAT                  0x00000045L
#define O_ETHCAT_MSTSTATE         0x00010045L   /* 1 - EtherCAT master state request */
#define O_ETHCAT_SLVSTATE         0x00020045L   /* 2 - EtherCAT slave state */
#define O_ETHCAT_SYNCTYPE         0x00030045L   /* 3 - EtherCAT synchronization type */
#define O_ETHCAT_CYCLETIME        0x00040045L   /* 4 - EtherCAT PDO cycle time */
#define O_ETHCAT_INPSHIFTTIME     0x00050045L   /* 5 - EtherCAT input latch shift time */
#define O_ETHCAT_SLAVEADRSET      0x00060045L   /* 6 - Value for an EtherCAT Identification */
#define O_ETHCAT_SLAVEADRACT      0x00070045L   /* 7 - Actual EtherCAT address */
#define O_ETHCAT_LEDMODE          0x00080045L   /* 8 - EtherCAT led debug mode */
#define O_ETHCAT_DIAGADR          0x00090045L   /* 9 - EtherCAT diagnose size and address */
#define O_ETHCAT_DIAGDATA         0x000A0045L   /* 10 - EtherCAT diagnose data */
#define O_ETHCAT_SLAVEDIPSET      0x000B0045L   /* 11 - EtherCAT Identification value set via DIP switches */
#define O_ETHCAT_SLAVEADRPRIO     0x000C0045L   /* 12 - Currently set value of the EtherCAT Identification */

/*INDEX_DESCRIPTION  70  SRCS2  7  Sercos II */
#define O_SRCS2                   0x00000046L
#define O_SRCS2_SLKN              0x00010046L   /* 1 - Sercos address */
#define O_SRCS2_BAUDRATE          0x00020046L   /* 2 - Indication of supported baud rates */
#define O_SRCS2_TRANSPEEDCONF     0x00030046L   /* 3 - Setting of baud rate */
#define O_SRCS2_LEDPOWDEF         0x00050046L   /* 5 - Cable length */
#define O_SRCS2_RINGPHASESTATUS   0x00060046L   /* 6 - Phase status of sercos ring */
#define O_SRCS2_SLKNREAL          0x00070046L   /* 7 - Sercos address read value */

/*INDEX_DESCRIPTION  72  PNIO  3  ProfiNET IO interface */
#define O_PNIO                    0x00000048L
#define O_PNIO_FLASHMODE          0x00010048L   /* 1 - ProfiNET IO enable flash mode */
#define O_PNIO_PROFILE            0x00030048L   /* 3 - ProfiNET IO drive profile */

/*INDEX_DESCRIPTION  74  SFTYA  26  Safety CPU-A */
#define O_SFTYA                   0x0000004AL
#define O_SFTYA_SIXLENSAM         0x0001004AL   /* 1 - eSM number of parameter CPU-A/B */
#define O_SFTYA_SIXLENSAMREM      0x0002004AL   /* 2 - eSM number of parameter  CPU-A/B CFG */
#define O_SFTYA_SAMPWD1           0x0003004AL   /* 3 - eSM password (first part) */
#define O_SFTYA_SAMPWD2           0x0004004AL   /* 4 - eSM password (second part) */
#define O_SFTYA_SERIALNUMBER      0x0005004AL   /* 5 - eSM Drive serial number */
#define O_SFTYA_HWREVISION        0x0006004AL   /* 6 - eSM HW Revision / Serial Number */
#define O_SFTYA_DRIVECONFIG       0x0007004AL   /* 7 - eSM configuration */
#define O_SFTYA_FAULTRESET        0x0008004AL   /* 8 - eSM Fault Reset */
#define O_SFTYA_READCONFIG        0x0009004AL   /* 9 - eSM object attributes */
#define O_SFTYA_ENCRES            0x000A004AL   /* 10 - eSM encoder resolution */
#define O_SFTYA_TRACEOBJ          0x000B004AL   /* 11 - eSM trace object */
#define O_SFTYA_MONITOROBJ        0x000C004AL   /* 12 - eSM monitor object address */
#define O_SFTYA_RESERVED3         0x000D004AL   /* 13 - eSM reserved */
#define O_SFTYA_MONITORVAL        0x000E004AL   /* 14 - eSM monitor object data */
#define O_SFTYA_SWREVISION        0x000F004AL   /* 15 - eSM revision ObjectDB / Software */
#define O_SFTYA_PRGNR             0x0010004AL   /* 16 - eSM program number */
#define O_SFTYA_CHECK             0x0011004AL   /* 17 - eSM activate check sequence */
#define O_SFTYA_IWORD0            0x0012004AL   /* 18 - eSM digital inputs channel A */
#define O_SFTYA_IWORD0ACT         0x0013004AL   /* 19 - eSM digital inputs channel A mask */
#define O_SFTYA_QWORD0            0x0014004AL   /* 20 - eSM digital outputs channel A */
#define O_SFTYA_QWORD0ACT         0x0015004AL   /* 21 - eSM digital outputs channel A mask */
#define O_SFTYA_STATESAM          0x0016004AL   /* 22 - eSM statusword */
#define O_SFTYA_OPMODE            0x0017004AL   /* 23 - eSM operating mode */
#define O_SFTYA_DIAGNOSE          0x0018004AL   /* 24 - eSM diagnostic */
#define O_SFTYA_POSITION          0x0019004AL   /* 25 - eSM act. Position of CPU-A (encoder) */
#define O_SFTYA_SAMDISABLE        0x001A004AL   /* 26 - eSM Disable */

/*INDEX_DESCRIPTION  75  SFTYAC  17  Safety CPU-A CFG */
#define O_SFTYAC                  0x0000004BL
#define O_SFTYAC_CRCREMPARA       0x0001004BL   /* 1 - eSM configuratiom checksum */
#define O_SFTYAC_SAMPWD1          0x0002004BL   /* 2 - eSM persistent password (part 1) */
#define O_SFTYAC_SAMPWD2          0x0003004BL   /* 3 - eSM persistent password (part 2) */
#define O_SFTYAC_MODEOUT1         0x0004004BL   /* 4 - eSM function of status output AUXOUT1 */
#define O_SFTYAC_MODEOUT2         0x0005004BL   /* 5 - eSM function of status output AUXOUT2 */
#define O_SFTYAC_DECNC            0x0006004BL   /* 6 - eSM deceleration ramp */
#define O_SFTYAC_DECQSTOP         0x0007004BL   /* 7 - eSM deceleration ramp for Quick Stop */
#define O_SFTYAC_TNCDEL           0x0008004BL   /* 8 - eSM delay time until start of monitored deceleration */
#define O_SFTYAC_TRELAYDELAY      0x0009004BL   /* 9 - eSM deactivation of output RELAY */
#define O_SFTYAC_MISCMODES        0x000A004BL   /* 10 - eSM basic settings */
#define O_SFTYAC_VELMAXRED        0x000B004BL   /* 11 - eSM speed limit for machine operating mode Setup Mode */
#define O_SFTYAC_VELMAXABS        0x000C004BL   /* 12 - eSM speed limit for machine operating mode Automatic Mode */
#define O_SFTYAC_VELMAXREDNEG     0x000D004BL   /* 13 - eSM speed limit negative direction machine operating mode Setup Mode */
#define O_SFTYAC_NEWMODES         0x000E004BL   /* 14 - eSM switches for functions */
#define O_SFTYAC_RESERVED3        0x000F004BL   /* 15 - eSM Reserved3 */
#define O_SFTYAC_RESERVED4        0x0010004BL   /* 16 - eSM Reserved4 */
#define O_SFTYAC_RESERVED5        0x0011004BL   /* 17 - eSM Reserved5 */

/*INDEX_DESCRIPTION  76  SFTYB  26  Safety CPU-B */
#define O_SFTYB                   0x0000004CL
#define O_SFTYB_SIXLENSAM         0x0001004CL   /* 1 - eSM number of parameter CPU-A/B */
#define O_SFTYB_SIXLENSAMREM      0x0002004CL   /* 2 - eSM number of parameter  CPU-A/B CFG */
#define O_SFTYB_SAMPWD1           0x0003004CL   /* 3 - eSM password (first part) */
#define O_SFTYB_SAMPWD2           0x0004004CL   /* 4 - eSM password (second part) */
#define O_SFTYB_SERIALNUMBER      0x0005004CL   /* 5 - eSM Drive serial number */
#define O_SFTYB_HWREVISION        0x0006004CL   /* 6 - eSM HW Revision / Serial Number */
#define O_SFTYB_DRIVECONFIG       0x0007004CL   /* 7 - eSM configuration */
#define O_SFTYB_FAULTRESET        0x0008004CL   /* 8 - eSM Fault Reset */
#define O_SFTYB_READCONFIG        0x0009004CL   /* 9 - eSM object attributes */
#define O_SFTYB_ENCRES            0x000A004CL   /* 10 - eSM encoder resolution */
#define O_SFTYB_TRACEOBJ          0x000B004CL   /* 11 - eSM trace object */
#define O_SFTYB_MONITOROBJ        0x000C004CL   /* 12 - eSM monitor object address */
#define O_SFTYB_RESERVED3         0x000D004CL   /* 13 - eSM reserved */
#define O_SFTYB_MONITORVAL        0x000E004CL   /* 14 - eSM monitor object data */
#define O_SFTYB_SWREVISION        0x000F004CL   /* 15 - eSM revision of firmware */
#define O_SFTYB_PRGNR             0x0010004CL   /* 16 - eSM program number */
#define O_SFTYB_CHECK             0x0011004CL   /* 17 - eSM activate check sequence */
#define O_SFTYB_IWORD0            0x0012004CL   /* 18 - eSM digital inputs channel B */
#define O_SFTYB_IWORD0ACT         0x0013004CL   /* 19 - eSM digital inputs channel B mask */
#define O_SFTYB_QWORD0            0x0014004CL   /* 20 - eSM digital outputs channel B */
#define O_SFTYB_QWORD0ACT         0x0015004CL   /* 21 - eSM digital outputs channel B mask */
#define O_SFTYB_STATESAM          0x0016004CL   /* 22 - eSM state */
#define O_SFTYB_OPMODE            0x0017004CL   /* 23 - eSM function */
#define O_SFTYB_DIAGNOSE          0x0018004CL   /* 24 - eSM diagnostic */
#define O_SFTYB_POSITION          0x0019004CL   /* 25 - eSM act. Position of CPU-B (SPI) */
#define O_SFTYB_SAMDISABLE        0x001A004CL   /* 26 - eSM disable */

/*INDEX_DESCRIPTION  77  SFTYBC  17  Safety CPU-B CFG (copy of CPU-A CFG) */
#define O_SFTYBC                  0x0000004DL
#define O_SFTYBC_CRCREMPARA       0x0001004DL   /* 1 - eSM configuratiom checksum */
#define O_SFTYBC_SAMPWD1          0x0002004DL   /* 2 - eSM persistent password (part 1) */
#define O_SFTYBC_SAMPWD2          0x0003004DL   /* 3 - eSM persistent password (part 2) */
#define O_SFTYBC_MODEOUT1         0x0004004DL   /* 4 - eSM function of status output AUXOUT1 */
#define O_SFTYBC_MODEOUT2         0x0005004DL   /* 5 - eSM function of status output AUXOUT2 */
#define O_SFTYBC_DECNC            0x0006004DL   /* 6 - eSM deceleration ramp */
#define O_SFTYBC_DECQSTOP         0x0007004DL   /* 7 - eSM deceleration ramp for Quick Stop */
#define O_SFTYBC_TNCDEL           0x0008004DL   /* 8 - eSM delay time until start of monitored deceleration */
#define O_SFTYBC_TRELAYDELAY      0x0009004DL   /* 9 - eSM deactivation of output RELAY */
#define O_SFTYBC_MISCMODES        0x000A004DL   /* 10 - eSM basic settings */
#define O_SFTYBC_VELMAXRED        0x000B004DL   /* 11 - eSM speed limit for machine operating mode Setup Mode */
#define O_SFTYBC_VELMAXABS        0x000C004DL   /* 12 - eSM speed limit for machine operating mode Automatic Mode */
#define O_SFTYBC_VELMAXREDNEG     0x000D004DL   /* 13 - eSM speed limit negative direction machine operating mode Setup Mode */
#define O_SFTYBC_NEWMODES         0x000E004DL   /* 14 - eSM switches for functions */
#define O_SFTYBC_RESERVED3        0x000F004DL   /* 15 - eSM Reserved3 */
#define O_SFTYBC_RESERVED4        0x0010004DL   /* 16 - eSM Reserved4 */
#define O_SFTYBC_RESERVED5        0x0011004DL   /* 17 - eSM Reserved5 */

/*INDEX_DESCRIPTION  78  SFTYBS  19  Safety boot strap */
#define O_SFTYBS                  0x0000004EL
#define O_SFTYBS_ERRORRESPONSE    0x0001004EL   /* 1 - Error response of safety boot strap */
#define O_SFTYBS_FLASHRDA         0x0002004EL   /* 2 - Read Flash CPU_A */
#define O_SFTYBS_FLASHRDB         0x0003004EL   /* 3 - Read Flash CPU_B */
#define O_SFTYBS_FLASHERASEA      0x0004004EL   /* 4 - Erase flash row CPU_A and increment address for row fill */
#define O_SFTYBS_FLASHERASEB      0x0005004EL   /* 5 - Erase flash row CPU_B and increment address for row fill */
#define O_SFTYBS_FLASHFILLA       0x0006004EL   /* 6 - Fill flash row CPU_A */
#define O_SFTYBS_FLASHFILLB       0x0007004EL   /* 7 - Fill flash row CPU_B */
#define O_SFTYBS_FLASHWRA         0x0008004EL   /* 8 - Write flash row CPU_A */
#define O_SFTYBS_FLASHWRB         0x0009004EL   /* 9 - Write flash row CPU_B */
#define O_SFTYBS_EEPROMRDA        0x000A004EL   /* 10 - Read EEPROM CPU_A */
#define O_SFTYBS_EEPROMRDB        0x000B004EL   /* 11 - Read EEPROM CPU_B */
#define O_SFTYBS_EEPROMERASEA     0x000C004EL   /* 12 - Erase EEPROM of CPU_A */
#define O_SFTYBS_EEPROMERASEB     0x000D004EL   /* 13 - Erase EEPROM of CPU_B */
#define O_SFTYBS_EEPROMFILLA      0x000E004EL   /* 14 - Fill EEPROM block CPU_A */
#define O_SFTYBS_EEPROMFILLB      0x000F004EL   /* 15 - Fill EEPROM block CPU_B */
#define O_SFTYBS_EEPROMWRA        0x0010004EL   /* 16 - Write EEPROM block CPU_A */
#define O_SFTYBS_EEPROMWRB        0x0011004EL   /* 17 - Write EEPROM block CPU_B */
#define O_SFTYBS_BOOTREQUEST      0x0012004EL   /* 18 - Boot Request eSM module */
#define O_SFTYBS_UMASBUSY         0x0013004EL   /* 19 - UMAS transfer is busy */

/*INDEX_DESCRIPTION  79  IOM  102  IO module */
#define O_IOM                     0x0000004FL
#define O_IOM_VALSC1              0x0001004FL   /* 1 - IOM1 Value of input voltage of AI11 */
#define O_IOM_TAUANA1             0x0002004FL   /* 2 - IOM1 Filter time constant of AI11 */
#define O_IOM_FORCEACT1           0x0003004FL   /* 3 - IOM1 Force activation of AI11 */
#define O_IOM_FORCEVAL1           0x0004004FL   /* 4 - IOM1 Force value of AI11 */
#define O_IOM_VALSC2              0x0005004FL   /* 5 - IOM1 Value of input voltage of AI12 */
#define O_IOM_FORCEACT2           0x0007004FL   /* 7 - IOM1 Force activation of AI12 */
#define O_IOM_FORCEVAL2           0x0008004FL   /* 8 - IOM1 Force value of AI12 */
#define O_IOM_WINANA1             0x0009004FL   /* 9 - IOM1 Zero voltage window of AI11 */
#define O_IOM_WINANA2             0x000A004FL   /* 10 - IOM1 Zero voltage window of AI12 */
#define O_IOM_OFFSETANA1          0x000B004FL   /* 11 - IOM1 Offset voltage of AI11 */
#define O_IOM_OFFSETANA2          0x000C004FL   /* 12 - IOM1 Offset voltage of AI12 */
#define O_IOM_VALANA1AND2         0x000D004FL   /* 13 - IOM1 Value of input voltage of AI11 and AI12 */
#define O_IOM_ANA1MODE            0x000E004FL   /* 14 - IOM1 Type of usage of AI11 */
#define O_IOM_ANA1LIMCURR         0x000F004FL   /* 15 - IOM1 Limitation of current at 10 V of AI11 */
#define O_IOM_ANA1LIMSPEED        0x0010004FL   /* 16 - IOM1 Limitation of velocity at 10 V of AI11 */
#define O_IOM_NSC1                0x0011004FL   /* 17 - IOM1 Target velocity at 10 V in operating mode Profile Velocity of AI11 */
#define O_IOM_ISC1                0x0012004FL   /* 18 - IOM1 Target torque at 10 V in operating mode Profile Torque of AI11 */
#define O_IOM_ANA2MODE            0x0013004FL   /* 19 - IOM1 Type of usage of AI12 */
#define O_IOM_ANA2LIMCURR         0x0014004FL   /* 20 - IOM1 Limitation of current at 10 V of AI12 */
#define O_IOM_ANA2LIMSPEED        0x0015004FL   /* 21 - IOM1 Limitation of velocity at 10 V of AI12 */
#define O_IOM_NSC2                0x0016004FL   /* 22 - IOM1 Target velocity at 10 V in operating mode Profile Velocity of AI12 */
#define O_IOM_ISC2                0x0017004FL   /* 23 - IOM1 Target torque at 10 V in operating mode Profile Torque of AI12 */
#define O_IOM_TAUANA2             0x0018004FL   /* 24 - IOM1 Filter time constant of AI12 */
#define O_IOM_FLTANAOUT           0x001F004FL   /* 31 - IOM1 Error response to overload of analog outputs */
#define O_IOM_AOTYPE              0x0020004FL   /* 32 - IOM1 Type of usage of analog outputs */
#define O_IOM_AO11MODE            0x0021004FL   /* 33 - IOM1 Function of AQ11 */
#define O_IOM_AO11CURRSET         0x0022004FL   /* 34 - IOM1 Range of current of AQ11 */
#define O_IOM_AO11INVERT          0x0023004FL   /* 35 - IOM1 Inversion of AQ11 */
#define O_IOM_AO11VALUE           0x0024004FL   /* 36 - IOM1 Fixed value for AQ11 */
#define O_IOM_AO11FORCEACT        0x0025004FL   /* 37 - IOM1 Force activation of AQ11 */
#define O_IOM_AO11FORCEVALUE      0x0026004FL   /* 38 - IOM1 Force value of AQ11 */
#define O_IOM_AO11REF             0x0027004FL   /* 39 - IOM1 Value of AQ11 */
#define O_IOM_AO12MODE            0x002B004FL   /* 43 - IOM1 Function of AQ12 */
#define O_IOM_AO12CURRSET         0x002C004FL   /* 44 - IOM1 Range of current of AQ12 */
#define O_IOM_AO12INVERT          0x002D004FL   /* 45 - IOM1 Inversion of AQ12 */
#define O_IOM_AO12VALUE           0x002E004FL   /* 46 - IOM1 Fixed value for AQ12 */
#define O_IOM_AO12FORCEACT        0x002F004FL   /* 47 - IOM1 Force activation of AQ12 */
#define O_IOM_AO12FORCEVALUE      0x0030004FL   /* 48 - IOM1 Force value of AQ12 */
#define O_IOM_AO12REF             0x0031004FL   /* 49 - IOM1 Value of AQ12 */
#define O_IOM_DI1XAVAIL           0x0033004FL   /* 51 - IOM1 Vorhandene logische Signaleingänge */
#define O_IOM_DQ1XAVAIL           0x0034004FL   /* 52 - IOM1 Vorhandene logische Signalausgänge */
#define O_IOM_DI1XGET             0x0035004FL   /* 53 - IOM1 Status of digital inputs */
#define O_IOM_DQ1XGET             0x0036004FL   /* 54 - IOM1 Status of digital outputs */
#define O_IOM_DQ1XSET             0x0037004FL   /* 55 - IOM1 Setting the digital outputs directly */
#define O_IOM_DI1XINV             0x0038004FL   /* 56 - IOM1 Inversion of digital inputs */
#define O_IOM_DQ1XINV             0x0039004FL   /* 57 - IOM1 Inversion of digital outputs */
#define O_IOM_DI1XFORCECNF        0x003A004FL   /* 58 - IOM1 Forcebarkeit Eingänge */
#define O_IOM_DQ1XFORCECNF        0x003B004FL   /* 59 - IOM1 Forcebarkeit Ausgänge */
#define O_IOM_DI1XFORCEMSK        0x003C004FL   /* 60 - IOM1 Forcemaske Eingänge */
#define O_IOM_DQ1XFORCEMSK        0x003D004FL   /* 61 - IOM1 Forcemaske Ausgänge */
#define O_IOM_DI1XFORCEVAL        0x003E004FL   /* 62 - IOM1 Forcewert Eingänge */
#define O_IOM_DQ1XFORCEVAL        0x003F004FL   /* 63 - IOM1 Forcewert Ausgänge */
#define O_IOM_DI10DEBOUNCE        0x0040004FL   /* 64 - IOM1 Debounce time of DI10 */
#define O_IOM_DI11DEBOUNCE        0x0041004FL   /* 65 - IOM1 Debounce time of DI11 */
#define O_IOM_DI12DEBOUNCE        0x0042004FL   /* 66 - IOM1 Debounce time of DI12 */
#define O_IOM_DI13DEBOUNCE        0x0043004FL   /* 67 - IOM1 Debounce time of DI13 */
#define O_IOM_FUNCDI10            0x0050004FL   /* 80 - IOM1 Function Input DI10 */
#define O_IOM_FUNCDI11            0x0051004FL   /* 81 - IOM1 Function Input DI11 */
#define O_IOM_FUNCDI12            0x0052004FL   /* 82 - IOM1 Function Input DI12 */
#define O_IOM_FUNCDI13            0x0053004FL   /* 83 - IOM1 Function Input DI13 */
#define O_IOM_FUNCDQ10            0x005A004FL   /* 90 - IOM1 Function Output DQ10 */
#define O_IOM_FUNCDQ11            0x005B004FL   /* 91 - IOM1 Function Output DQ11 */
#define O_IOM_IOMSERIAL           0x0060004FL   /* 96 - IOM1 Serial number */
#define O_IOM_IOMSWVERSION        0x0061004FL   /* 97 - IOM1 Software version */
#define O_IOM_IOMHWVERSION        0x0062004FL   /* 98 - IOM1 Hardware version */
#define O_IOM_IOMERROR            0x0063004FL   /* 99 - IOM1 Error message */
#define O_IOM_MEMADRIOM           0x0064004FL   /* 100 - IOM1 Speicherzugriff Adressinfo */
#define O_IOM_MEMTYPEIOM          0x0065004FL   /* 101 - IOM1 Speicherzugriff Typ */
#define O_IOM_MEMACCESSIOM        0x0066004FL   /* 102 - IOM1 Speicherzugriff durchführen */

/*INDEX_DESCRIPTION  80  ENCGLB  14  Second encoder module common */
#define O_ENCGLB                  0x00000050L
#define O_ENCGLB_ENCCONTROL       0x00010050L   /* 1 - Type of usage of encoder 2 (module) */
#define O_ENCGLB_MODEENCMACH      0x00020050L   /* 2 - Selection of mode of machine encoder */
#define O_ENCGLB_ENC2TYPE         0x00030050L   /* 3 - Type of encoder at encoder 2 (module) */
#define O_ENCGLB_ENCMACHDENOM     0x00050050L   /* 5 - Resolution of encoder 2, denominator */
#define O_ENCGLB_ENCMACHNUM       0x00060050L   /* 6 - Resolution of encoder 2, numerator */
#define O_ENCGLB_ENCMACHPOSLIM    0x00070050L   /* 7 - Max. permissible deviation of encoder positions */
#define O_ENCGLB_INVDIRMACHENC    0x00080050L   /* 8 - Inversion of direction of machine encoder */
#define O_ENCGLB_COMMUTOFFIDENT   0x00090050L   /* 9 - Commutation offset identification */
#define O_ENCGLB_STEPPERSPEED     0x000A0050L   /* 10 - speed at stepper test mode */
#define O_ENCGLB_SETSTEPPERMODE   0x000B0050L   /* 11 - activate stepper test mode */
#define O_ENCGLB_POSOFF2          0x000C0050L   /* 12 - position offset 2 (within one revolution) */
#define O_ENCGLB_POSOFF2REV       0x000D0050L   /* 13 - position offset 2 (number of revolutions) */
#define O_ENCGLB_WAKESGAIN        0x000E0050L   /* 14 - Gain for wake and shake */

/*INDEX_DESCRIPTION  81  ENCANA  4  Analog encoder module */
#define O_ENCANA                  0x00000051L
#define O_ENCANA_HALLOFFSET       0x00010051L   /* 1 - formerly: Hall offset */
#define O_ENCANA_POWERSUPPLY      0x00020051L   /* 2 - Power supply encoder module ANA (analog interface) */
#define O_ENCANA_HALLSTATE        0x00030051L   /* 3 - Hall sensor state of analog encoder */
#define O_ENCANA_SINCOSMAXTRAVEL  0x00040051L   /* 4 - Maximum distance for search for index pulse for SinCos encoder */

/*INDEX_DESCRIPTION  82  ENCDIG  11  Digital encoder module */
#define O_ENCDIG                  0x00000052L
#define O_ENCDIG_SSIRESSINGLE     0x00010052L   /* 1 - SSI singleturn resolution */
#define O_ENCDIG_SSIRESMULTI      0x00020052L   /* 2 - SSI multiturn resolution */
#define O_ENCDIG_SSICODING        0x00030052L   /* 3 - Position coding of SSI encoder */
#define O_ENCDIG_POWERSUPPLY      0x00040052L   /* 4 - Power supply encoder module DIG (digital interface) */
#define O_ENCDIG_SSIMAXFREQ       0x00050052L   /* 5 - SSI maximum transfer frequency */
#define O_ENCDIG_ABIMAXFREQ       0x00060052L   /* 6 - ABI maximum frequency */
#define O_ENCDIG_ABIMAXIXTRAVEL   0x00070052L   /* 7 - ABI maximum distance for index pulse search */
#define O_ENCDIG_BISSRESSINGLE    0x00080052L   /* 8 - BISS singleturn resolution */
#define O_ENCDIG_BISSRESMULTI     0x00090052L   /* 9 - BISS multiturn resolution */
#define O_ENCDIG_BISSCODING       0x000A0052L   /* 10 - Position coding of BISS encoder */
#define O_ENCDIG_RESMULTIUSED     0x000B0052L   /* 11 - Number of bits of the multiturn resolution used of the encoder */

/*INDEX_DESCRIPTION  90  HIP  19  Hiperface command interface */
#define O_HIP                     0x0000005AL
#define O_HIP_ADDRESS             0x0001005AL   /* 1 - Hiperface address of the encoder */
#define O_HIP_SNDCMD              0x0002005AL   /* 2 - Sendedaten Kommando */
#define O_HIP_SNDTELADR           0x0003005AL   /* 3 - Sendedaten Datenbyte Adresse */
#define O_HIP_SNDTELDAT           0x0004005AL   /* 4 - Sendedaten Datenbyte Datum */
#define O_HIP_SNDTELLEN           0x0005005AL   /* 5 - Sendedaten Telegramm senden (Telegrammlänge) */
#define O_HIP_RECCMD              0x0006005AL   /* 6 - Empfangsdaten Kommandobyte */
#define O_HIP_RECTELADR           0x0007005AL   /* 7 - Empfangsdaten Datenbyte Adresse */
#define O_HIP_RECTELDAT           0x0008005AL   /* 8 - Empfangsdaten Datenbyte Datum */
#define O_HIP_RECTELLEN           0x0009005AL   /* 9 - Empfangsdaten Telegrammlänge */
#define O_HIP_ACTIVATE            0x000A005AL   /* 10 - Funktion aktivieren */
#define O_HIP_DEACTIVATE          0x000B005AL   /* 11 - Funktion deaktivieren */
#define O_HIP_RESET               0x000C005AL   /* 12 - reset encoder serial number */
#define O_HIP_HIDDENMTP           0x000D005AL   /* 13 - activating of the hidden motor type on power on */
#define O_HIP_PHASINGOFFSET       0x000E005AL   /* 14 - via wake & shake estimated phasing offset */
#define O_HIP_MOTENCSER1          0x000F005AL   /* 15 - Serial number of the Motor Encoder 1/5 */
#define O_HIP_MOTENCSER2          0x0010005AL   /* 16 - Serial number of the Motor Encoder 2/5 */
#define O_HIP_MOTENCSER3          0x0011005AL   /* 17 - Serial number of the Motor Encoder 3/5 */
#define O_HIP_MOTENCSER4          0x0012005AL   /* 18 - Serial number of the Motor Encoder 4/5 */
#define O_HIP_MOTENCSER5          0x0013005AL   /* 19 - Serial number of the Motor Encoder 5/5 */

/*INDEX_DESCRIPTION  91  MOCID  27  Motor configuration identfication */
#define O_MOCID                   0x0000005BL
#define O_MOCID_MOTORTYPE         0x0002005BL   /* 2 - Motortype */
#define O_MOCID_NAME1             0x0003005BL   /* 3 - Motor name part 1 */
#define O_MOCID_NAME2             0x0004005BL   /* 4 - Motor name part 2 */
#define O_MOCID_NAME3             0x0005005BL   /* 5 - Motor name part 3 */
#define O_MOCID_NAME4             0x0006005BL   /* 6 - Motor name part 4 */
#define O_MOCID_NAME5             0x0007005BL   /* 7 - Motor name part 5 */
#define O_MOCID_SERIAL1           0x0008005BL   /* 8 - Motor serial number part 1 */
#define O_MOCID_SERIAL2           0x0009005BL   /* 9 - Motor serial number part 2 */
#define O_MOCID_SERIAL3           0x000A005BL   /* 10 - Motor serial number part 3 */
#define O_MOCID_SERIAL4           0x000B005BL   /* 11 - Motor serial number part 4 */
#define O_MOCID_SERIAL5           0x000C005BL   /* 12 - Motor serial number part 5 */
#define O_MOCID_HWINDEX1          0x000D005BL   /* 13 - Motor Hardware Index part 1 */
#define O_MOCID_HWINDEX2          0x000E005BL   /* 14 - Motor Hardware Index part 2 */
#define O_MOCID_HWINDEX3          0x000F005BL   /* 15 - Motor Hardware Index part 3 */
#define O_MOCID_HWINDEX4          0x0010005BL   /* 16 - Motor Hardware Index part 4 */
#define O_MOCID_HWINDEX5          0x0011005BL   /* 17 - Motor Hardware Index part 5 */
#define O_MOCID_FILENAME          0x0017005BL   /* 23 - Motor file name */
#define O_MOCID_DBVERSION         0x0018005BL   /* 24 - Version of motor data base */
#define O_MOCID_MOTFILEVERSION    0x0019005BL   /* 25 - Version of complete motorfile */
#define O_MOCID_PARTLIST          0x001A005BL   /* 26 - Part list date */
#define O_MOCID_DOM               0x001B005BL   /* 27 - DOM (Date of Manufacture) */

/*INDEX_DESCRIPTION  92  MOCED  24  Motor configuration encoder data */
#define O_MOCED                   0x0000005CL
#define O_MOCED_ENCTYPE           0x0001005CL   /* 1 - Encoder type */
#define O_MOCED_PONSPEED          0x0002005CL   /* 2 - Power On Speed */
#define O_MOCED_MAXSPEED          0x0003005CL   /* 3 - maximal allowed speed */
#define O_MOCED_MAXACC            0x0004005CL   /* 4 - maximal allowed acceleration */
#define O_MOCED_MINSUPPLY         0x0006005CL   /* 6 - Minimal encoder supply */
#define O_MOCED_MAXSUPPLY         0x0007005CL   /* 7 - Maximal encoder supply */
#define O_MOCED_NOMCURR           0x0008005CL   /* 8 - nominal encoder current */
#define O_MOCED_RATIO             0x0009005CL   /* 9 - Encoder Ratio */
#define O_MOCED_MAXTEMP           0x000A005CL   /* 10 - maximal encoder temperature */
#define O_MOCED_NUMERTURNS        0x000B005CL   /* 11 - Number of soluble turns */
#define O_MOCED_STEPS             0x000C005CL   /* 12 - Absolute steps per revolution */
#define O_MOCED_LINES             0x000D005CL   /* 13 - Periods per revolution */
#define O_MOCED_LIMUPPER          0x000E005CL   /* 14 - upper position limit */
#define O_MOCED_LIMLOWER          0x000F005CL   /* 15 - lower position limit */
#define O_MOCED_PERIODLEN         0x0010005CL   /* 16 - Periode Lenght */
#define O_MOCED_ABSSTEPS          0x0011005CL   /* 17 - Absolute step length */
#define O_MOCED_FILTERCOEFF1      0x0012005CL   /* 18 - Filter coefficient a1 of the position correction */
#define O_MOCED_FILTERCOEFF2      0x0013005CL   /* 19 - Filter coefficient a2 of the position correction */
#define O_MOCED_TEMPSENSOR        0x0014005CL   /* 20 - Temperatur of the Encoder can be read */
#define O_MOCED_POLES             0x0015005CL   /* 21 - Number of pole pairs */
#define O_MOCED_STIMFREQ          0x0016005CL   /* 22 - Stimulation frequency */
#define O_MOCED_TRAFO             0x0017005CL   /* 23 - Transformation ratio */
#define O_MOCED_LINESLINEAR       0x0018005CL   /* 24 - Periods per pole pair pitch */

/*INDEX_DESCRIPTION  93  MOCWD  25  Motor configuration winding data */
#define O_MOCWD                   0x0000005DL
#define O_MOCWD_NNOM              0x0001005DL   /* 1 - Rated speed */
#define O_MOCWD_UNOM              0x0002005DL   /* 2 - nominal motor phase voltage */
#define O_MOCWD_PEAKCURR          0x0003005DL   /* 3 - Maximum motor current */
#define O_MOCWD_NOMCURR           0x0004005DL   /* 4 - Rated current */
#define O_MOCWD_CONTCURR          0x0005005DL   /* 5 - Cont. stall current */
#define O_MOCWD_INSULATION        0x0006005DL   /* 6 - Max. line voltage */
#define O_MOCWD_POLEPAIR          0x0007005DL   /* 7 - Pole pairs */
#define O_MOCWD_CONTTORQUE        0x0008005DL   /* 8 - Cont. stall torque */
#define O_MOCWD_PEAKTORQUE        0x0009005DL   /* 9 - peak torque */
#define O_MOCWD_TREFCONT          0x000A005DL   /* 10 - reference temperature of continous stall torque */
#define O_MOCWD_TREFPEAK          0x000B005DL   /* 11 - reference temperature of peak torque */
#define O_MOCWD_TMAG              0x000C005DL   /* 12 - temperature constant of magnets */
#define O_MOCWD_RESERVED          0x000D005DL   /* 13 - reserved for future use */
#define O_MOCWD_RESIST            0x000E005DL   /* 14 - Phase resistance (line to line) */
#define O_MOCWD_LQ                0x000F005DL   /* 15 - L (q-direction, line to line) */
#define O_MOCWD_LD                0x0010005DL   /* 16 - L (d-direction, line to line) */
#define O_MOCWD_LQSAT1            0x0011005DL   /* 17 - Lq-saturation table 1*I0 */
#define O_MOCWD_LQSAT2            0x0012005DL   /* 18 - Lq-saturation table 2*I0 */
#define O_MOCWD_LQSAT3            0x0013005DL   /* 19 - Lq-saturation table 3*I0 */
#define O_MOCWD_LQSAT4            0x0014005DL   /* 20 - Lq-saturation table 4*I0 */
#define O_MOCWD_LQSAT5            0x0015005DL   /* 21 - Lq-saturation table 5*I0 */
#define O_MOCWD_PWM               0x0016005DL   /* 22 - optimal PWM frequency */
#define O_MOCWD_FIELD             0x0017005DL   /* 23 - Rot. field dir. right */
#define O_MOCWD_EMK               0x0018005DL   /* 24 - EMF */
#define O_MOCWD_POLEPAIRPITCH     0x0019005DL   /* 25 - Pole pair pitch */

/*INDEX_DESCRIPTION  94  MOCTD  30  Motor configuration thermal data */
#define O_MOCTD                   0x0000005EL
#define O_MOCTD_I2T               0x0001005EL   /* 1 - Max. time I peak */
#define O_MOCTD_TMAX              0x0002005EL   /* 2 - maximal rated motor temperature */
#define O_MOCTD_RESIST00          0x0003005EL   /* 3 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST01          0x0004005EL   /* 4 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST02          0x0005005EL   /* 5 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST03          0x0006005EL   /* 6 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST04          0x0007005EL   /* 7 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST05          0x0008005EL   /* 8 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST06          0x0009005EL   /* 9 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST07          0x000A005EL   /* 10 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST08          0x000B005EL   /* 11 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST09          0x000C005EL   /* 12 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST10          0x000D005EL   /* 13 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST11          0x000E005EL   /* 14 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST12          0x000F005EL   /* 15 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST13          0x0010005EL   /* 16 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST14          0x0011005EL   /* 17 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST15          0x0012005EL   /* 18 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST16          0x0013005EL   /* 19 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST17          0x0014005EL   /* 20 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST18          0x0015005EL   /* 21 - caracteristic of the temperature sensor */
#define O_MOCTD_RESIST19          0x0016005EL   /* 22 - caracteristic of the temperature sensor */
#define O_MOCTD_SENSORTYPE        0x0017005EL   /* 23 - Type of temperature sensor */
#define O_MOCTD_MODELC2           0x0018005EL   /* 24 - temperature model: C2 */
#define O_MOCTD_MODELC1           0x0019005EL   /* 25 - temperature model: C1 */
#define O_MOCTD_MODELA12          0x001A005EL   /* 26 - temperature model: A12 */
#define O_MOCTD_MODELA2           0x001B005EL   /* 27 - temperature model: A2 */
#define O_MOCTD_MODELBETA         0x001C005EL   /* 28 - temperature model: Beta */
#define O_MOCTD_MODELDELTAA       0x001D005EL   /* 29 - temperature model: DeltaA */
#define O_MOCTD_MODELDELTAB       0x001E005EL   /* 30 - temperature model: DeltaB */

/*INDEX_DESCRIPTION  95  MOCMD  10  Motor configuration mechanical data */
#define O_MOCMD                   0x0000005FL
#define O_MOCMD_NMAX              0x0001005FL   /* 1 - Max. speed */
#define O_MOCMD_INERTIA           0x0002005FL   /* 2 - Inertia (or mass) */
#define O_MOCMD_BRAKEUHOLD        0x0003005FL   /* 3 - brake holding voltage */
#define O_MOCMD_BRAKEOVEREX       0x0004005FL   /* 4 - brake overexcitation time */
#define O_MOCMD_BRAKE             0x0005005FL   /* 5 - Mechanical brake */
#define O_MOCMD_BRAKEUMIN         0x0006005FL   /* 6 - minimal brake supply */
#define O_MOCMD_BRAKEUMAX         0x0007005FL   /* 7 - maximal brake supply */
#define O_MOCMD_BRAKECURR         0x0008005FL   /* 8 - nominal brake current */
#define O_MOCMD_BRAKECOUPLING     0x0009005FL   /* 9 - Enable delay */
#define O_MOCMD_BRAKEDISCON       0x000A005FL   /* 10 - Release delay */

/*INDEX_DESCRIPTION  96  MOCAD  4  Motor configuration adjustment data */
#define O_MOCAD                   0x00000060L
#define O_MOCAD_DONE              0x00010060L   /* 1 - No calculation of phas. offset */
#define O_MOCAD_TOOL              0x00020060L   /* 2 - adjustment tool */
#define O_MOCAD_OFFSET            0x00030060L   /* 3 - Phasing offset adjustment value */
#define O_MOCAD_HALLOFFSET        0x00040060L   /* 4 - Hall Offset */

/*INDEX_DESCRIPTION  99  END  1  Last index */
#define O_END                     0x00000063L
#define O_END_SAVEPARDVN          0x00010063L   /* 1 - Save parameter to EEPROM with DeviceNet */

/*INDEX_DESCRIPTION  129  EXTHMI  14  Menue structure for external HMI */
#define O_EXTHMI                  0x00000081L
#define O_EXTHMI_PASSWORDSTATE    0x00010081L   /* 1 - State of password */
#define O_EXTHMI_PINCODE1         0x00020081L   /* 2 - Pin Code 1 */
#define O_EXTHMI_PINCODE2         0x00030081L   /* 3 - Pin Code 2 */
#define O_EXTHMI_HOMINGOPERATION  0x00040081L   /* 4 - Homing operation */
#define O_EXTHMI_ATUNESTAT        0x00050081L   /* 5 - Autotuning status */
#define O_EXTHMI_TORQUE           0x00060081L   /* 6 - Profile torque operation */
#define O_EXTHMI_POSABS           0x00070081L   /* 7 - Profile positioning absolute operation */
#define O_EXTHMI_POSREL           0x00080081L   /* 8 - Profile positioning relative operation */
#define O_EXTHMI_VELOCITY         0x00090081L   /* 9 - Profile velocity operation */
#define O_EXTHMI_MSMSINGLESET     0x000A0081L   /* 10 - MSM single set operation */
#define O_EXTHMI_MSMSEQUENCE      0x000B0081L   /* 11 - MSM sequence operation */
#define O_EXTHMI_FAULTRESET       0x000C0081L   /* 12 - Fault reset */
#define O_EXTHMI_VIEWERRORHISTORY 0x000D0081L   /* 13 - View error history */
#define O_EXTHMI_STATUS2          0x000E0081L   /* 14 - Status 2 */

/*INDEX_DESCRIPTION  130  MTEST  59  Manufacture test */
#define O_MTEST                   0x00000082L
#define O_MTEST_PROCTRACE         0x00010082L   /* 1 - Process taceability word */
#define O_MTEST_CARDID            0x00020082L   /* 2 - CARDID board type values */
#define O_MTEST_RAMTEST           0x00030082L   /* 3 - RAMTEST internal */
#define O_MTEST_FLASHCRC          0x00040082L   /* 4 - FLASHTEST external */
#define O_MTEST_IO                0x00050082L   /* 5 - DIGITAL I/O Test */
#define O_MTEST_EEPROMTEST        0x00060082L   /* 6 - EEPROM Test */
#define O_MTEST_KEYB              0x00070082L   /* 7 - IHM keyboard Test */
#define O_MTEST_WHEEL             0x00080082L   /* 8 - IHM wheel test */
#define O_MTEST_DISP              0x00090082L   /* 9 - IHM display test */
#define O_MTEST_DISPDOT           0x000A0082L   /* 10 - IHM display dot test */
#define O_MTEST_IOFFSETADJ        0x000B0082L   /* 11 - Phase current offset adjustment */
#define O_MTEST_IUVMEASURE        0x000C0082L   /* 12 - Phase current measurement */
#define O_MTEST_IU                0x000D0082L   /* 13 - Phase current Iu */
#define O_MTEST_IV                0x000E0082L   /* 14 - Phase current Iv */
#define O_MTEST_BURST             0x000F0082L   /* 15 - Braking resistor test I2T */
#define O_MTEST_DCDISCHARGE       0x00100082L   /* 16 - Discharge DC-Bus */
#define O_MTEST_BINICONT          0x00110082L   /* 17 - Burn in test continious current */
#define O_MTEST_BINIPEAK          0x00120082L   /* 18 - Burn in test peak current */
#define O_MTEST_BINICONTT         0x00130082L   /* 19 - Burn in test continious current time */
#define O_MTEST_BINIPEAKT         0x00140082L   /* 20 - Burn in test peak current time */
#define O_MTEST_BINBREAKT         0x00150082L   /* 21 - Burn in test brake resistor active time */
#define O_MTEST_BINTLEMAX         0x00160082L   /* 22 - Burn in limit TLE temperature */
#define O_MTEST_BINTCPUMAX        0x00170082L   /* 23 - Burn in limit CPU temperature */
#define O_MTEST_BINSPEEDMIN       0x00180082L   /* 24 - Burn in speed min */
#define O_MTEST_BINSPEEDMAX       0x00190082L   /* 25 - Burn in speed max */
#define O_MTEST_PROCSTAT          0x001A0082L   /* 26 - process status word */
#define O_MTEST_FANONOFF          0x001B0082L   /* 27 - fan on/off */
#define O_MTEST_ENC1CALIB         0x001C0082L   /* 28 - ENC1 calibration */
#define O_MTEST_ANA12CALIB        0x001D0082L   /* 29 - Analog 1and2 calibration */
#define O_MTEST_MEMCARDTEST       0x001E0082L   /* 30 - MemCard Slot Test */
#define O_MTEST_ENC1OFFSETLIM     0x001F0082L   /* 31 - Encoder1 Offsetlimit */
#define O_MTEST_ENC1GAINLIM       0x00200082L   /* 32 - Encoder1 Gainlimit */
#define O_MTEST_ANAOFFSETLIM      0x00210082L   /* 33 - analog input 1/2 offsetlimit */
#define O_MTEST_ANAGAINLIM        0x00220082L   /* 34 - analog input 1/2 gainlimit */
#define O_MTEST_EXTVALIUV         0x00230082L   /* 35 - extern measured current value Iu,Iv */
#define O_MTEST_STO               0x00240082L   /* 36 - Safe Torque Operation Test */
#define O_MTEST_RCHOKE            0x00250082L   /* 37 - choke resistance value */
#define O_MTEST_LCHOKE            0x00260082L   /* 38 - choke inductance value */
#define O_MTEST_UVL1              0x00270082L   /* 39 - L1 phase voltage effective */
#define O_MTEST_UVL2              0x00280082L   /* 40 - L2 phase voltage effective */
#define O_MTEST_UVL3              0x00290082L   /* 41 - L3 phase voltage effective */
#define O_MTEST_BREAKRESACTIVATE  0x002A0082L   /* 42 - Braking resistor activation function */
#define O_MTEST_SHORTSTEST        0x002B0082L   /* 43 - short test (motor to earth, motor to phase) */
#define O_MTEST_PROCTRACE2        0x002C0082L   /* 44 - Process taceability word 2 */
#define O_MTEST_PROCSTAT2         0x002D0082L   /* 45 - process status word 2 */
#define O_MTEST_DIPSWITCH         0x002E0082L   /* 46 - Value of the DIP switch */
#define O_MTEST_LEDCONTROL        0x002F0082L   /* 47 - control type of the LEDs */
#define O_MTEST_LEDSTATE          0x00300082L   /* 48 - state of the LEDs */
#define O_MTEST_CALIBBOARD        0x00310082L   /* 49 - Board which has to be calibrated */
#define O_MTEST_STEPPERMODECURR   0x00320082L   /* 50 - Stepper Mode: used current */
#define O_MTEST_STEPPERMODEVEL    0x00330082L   /* 51 - Stepper Mode: used velocity */
#define O_MTEST_IGBTCONTROL       0x00340082L   /* 52 - control mode of the IGBT module */
#define O_MTEST_SERC2CONTROL      0x00350082L   /* 53 - Controlword for Sercos2 test */
#define O_MTEST_SERC2STATUS       0x00360082L   /* 54 - Statusword for Sercos2 test */
#define O_MTEST_STEPPERMODESTART  0x00370082L   /* 55 - Stepper Mode: activate mode */
#define O_MTEST_INRUSHRELAIS      0x00380082L   /* 56 - Inrush Relais test */
#define O_MTEST_NP30API           0x00390082L   /* 57 - NP30API */
#define O_MTEST_NP30DPRAM         0x003A0082L   /* 58 - NP30 DPRam test */
#define O_MTEST_NP30SERIAL        0x003B0082L   /* 59 - deactivate communication between the dsp to the NP30 */

/*INDEX_DESCRIPTION  8000  EEPROM  0  Memory access EEPROM */
#define O_EEPROM                  0x00001F40L
#define O_EEPROM_DIRECT           0x00001F40L   /* 0 - Direkter Speicherzugriff auf EEPROM */

/*INDEX_DESCRIPTION  9045  DATST2  27  Motion sequence mode */
#define O_DATST2                  0x00002355L
#define O_DATST2_START            0x00012355L   /* 1 - Aktivierung der Betriebsart Bewegungssequenz */
#define O_DATST2_ACK              0x00022355L   /* 2 - Quittung: Betriebsart Bewegungssequenz */
#define O_DATST2_STARTREQUEST     0x00032355L   /* 3 - Start request for processing of a data set */
#define O_DATST2_ACTNUM           0x00042355L   /* 4 - Current data set number */
#define O_DATST2_NEXTNUM          0x00052355L   /* 5 - Next data set to be triggered */
#define O_DATST2_SETNUM           0x00062355L   /* 6 - Selection of a data set to be started */
#define O_DATST2_MODE             0x00072355L   /* 7 - Processing mode */
#define O_DATST2_GLOBALCOND       0x00082355L   /* 8 - Global transition condition */
#define O_DATST2_CURNEXTCOND      0x00092355L   /* 9 - Current transition condition */
#define O_DATST2_TEACHIN          0x000A2355L   /* 10 - Take over current user position (TeachIn) */
#define O_DATST2_FEATURE          0x000B2355L   /* 11 - Special setting */
#define O_DATST2_AVAILCNT         0x000F2355L   /* 15 - Number of available data sets */
#define O_DATST2_SELENTRY         0x00102355L   /* 16 - Selection of data set number in data set table */
#define O_DATST2_DATATYPE         0x00112355L   /* 17 - Selection of movement type */
#define O_DATST2_DATATARGET       0x00122355L   /* 18 - Target value of movement type */
#define O_DATST2_DATASPEED        0x00132355L   /* 19 - Speed */
#define O_DATST2_DATAACC          0x00142355L   /* 20 - Acceleration */
#define O_DATST2_DATADEC          0x00152355L   /* 21 - Deceleration */
#define O_DATST2_DATADELAY        0x00162355L   /* 22 - Wait time */
#define O_DATST2_DATANEXTCOND     0x00172355L   /* 23 - Transition condition */
#define O_DATST2_DATANEXT         0x00182355L   /* 24 - Number of subsequent data set */
#define O_DATST2_DATAOUTSTRT      0x00192355L   /* 25 - Output processing when a data set is started */
#define O_DATST2_DATAOUTEND       0x001A2355L   /* 26 - Output processing when processing of a data set is finished */
#define O_DATST2_DATAVALCHANGE    0x001B2355L   /* 27 - Änderungsmerker */

/*INDEX_DESCRIPTION  9128  MDATAP  45  Manufacture data power amplifier */
#define O_MDATAP                  0x000023A8L
#define O_MDATAP_NAME             0x000123A8L   /* 1 - Kennzeichnung Endstufe */
#define O_MDATAP_DEADBAND         0x000223A8L   /* 2 - Totzeit Halbbrücken */
#define O_MDATAP_THMR1R2          0x000323A8L   /* 3 - Thermisches Modell R1+R2 */
#define O_MDATAP_THMR3            0x000423A8L   /* 4 - Thermisches Modell R3 */
#define O_MDATAP_THMTAU3          0x000523A8L   /* 5 - Thermisches Modell Tau3 */
#define O_MDATAP_THMR4            0x000623A8L   /* 6 - Thermisches Modell R4 */
#define O_MDATAP_THMTAU4          0x000723A8L   /* 7 - Thermisches Modell Tau4 */
#define O_MDATAP_THMPLOS4         0x000823A8L   /* 8 - Thermisches Modell Verlustleistung bei Strom @4KHz */
#define O_MDATAP_THMPLOS8         0x000923A8L   /* 9 - Thermisches Modell Verlustleistung bei Strom @8KHz */
#define O_MDATAP_PNOM             0x000A23A8L   /* 10 - Dauerleistung */
#define O_MDATAP_PMAXDT           0x000B23A8L   /* 11 - Zeit doppelte Leistung */
#define O_MDATAP_TABTHS1          0x000C23A8L   /* 12 - Temperaturkennlinie Wert 1 */
#define O_MDATAP_TABTHS2          0x000D23A8L   /* 13 - Temperaturkennlinie Wert 2 */
#define O_MDATAP_TABTHS3          0x000E23A8L   /* 14 - Temperaturkennlinie Wert 3 */
#define O_MDATAP_TABTHS4          0x000F23A8L   /* 15 - Temperaturkennlinie Wert 4 */
#define O_MDATAP_TABTHS5          0x001023A8L   /* 16 - Temperaturkennlinie Wert 5 */
#define O_MDATAP_TABTHS6          0x001123A8L   /* 17 - Temperaturkennlinie Wert 6 */
#define O_MDATAP_TABTHS7          0x001223A8L   /* 18 - Temperaturkennlinie Wert 7 */
#define O_MDATAP_TABTHS8          0x001323A8L   /* 19 - Temperaturkennlinie Wert 8 */
#define O_MDATAP_TABUHS1          0x001423A8L   /* 20 - Spannungskennlinie Wert 1 */
#define O_MDATAP_TABUHS2          0x001523A8L   /* 21 - Spannungskennlinie Wert 2 */
#define O_MDATAP_TABUHS3          0x001623A8L   /* 22 - Spannungskennlinie Wert 3 */
#define O_MDATAP_TABUHS4          0x001723A8L   /* 23 - Spannungskennlinie Wert 4 */
#define O_MDATAP_TABUHS5          0x001823A8L   /* 24 - Spannungskennlinie Wert 5 */
#define O_MDATAP_TABUHS6          0x001923A8L   /* 25 - Spannungskennlinie Wert 6 */
#define O_MDATAP_TABUHS7          0x001A23A8L   /* 26 - Spannungskennlinie Wert 7 */
#define O_MDATAP_TABUHS8          0x001B23A8L   /* 27 - Spannungskennlinie Wert 8 */
#define O_MDATAP_TNTC             0x001C23A8L   /* 28 - Temperatursensor NTC/PTC */
#define O_MDATAP_TBAL             0x001D23A8L   /* 29 - Ballastkurzschluss */
#define O_MDATAP_IUSC             0x001E23A8L   /* 30 - Skalierung Strommessung Phase U */
#define O_MDATAP_IUVSC            0x001F23A8L   /* 31 - Skalierung Strommessung U zu V */
#define O_MDATAP_UKZSC            0x002023A8L   /* 32 - Skalierung Zwischenkreismessung (UKZ) */
#define O_MDATAP_UKZOFFS          0x002123A8L   /* 33 - Offset Zwischenkreismessung (UKZ) */
#define O_MDATAP_PHASELINE        0x002223A8L   /* 34 - Phasenzahl Netzanschluss */
#define O_MDATAP_I2TBALMAX        0x002323A8L   /* 35 - max. zul. Einschaltzeit interner Ballastwiderstand */
#define O_MDATAP_UBALON           0x002423A8L   /* 36 - Ballast Einschaltspannung */
#define O_MDATAP_UBALOFF          0x002523A8L   /* 37 - Ballast  Abschaltspannung */
#define O_MDATAP_I2TLEDT          0x002623A8L   /* 38 - max. Zeit für max. Strom bei hoher Geschw. */
#define O_MDATAP_IMAX4KHZ         0x002723A8L   /* 39 - Maximalstrom des Gerätes bei 4KHz PWM Frequenz */
#define O_MDATAP_INOM4KHZ         0x002823A8L   /* 40 - Nennstrom des Gerätes bei 4KHz PWM Frequenz */
#define O_MDATAP_IMAX8KHZ         0x002923A8L   /* 41 - Maximalstrom des Geräts bei 8KHz PWM Frequenz */
#define O_MDATAP_INOM8KHZ         0x002A23A8L   /* 42 - Nennstrom des Geräts bei 8KHz PWM Frequenz */
#define O_MDATAP_UMAINSL          0x002B23A8L   /* 43 - Phasenüberwachung untere Grenze */
#define O_MDATAP_UMAINSH          0x002C23A8L   /* 44 - Phasenüberwachung obere Grenze */
#define O_MDATAP_SERIALCOPY       0x002D23A8L   /* 45 - Kopie der Seriennummer */

/*INDEX_DESCRIPTION  9129  MDATAC  28  Manufacture data CPU board */
#define O_MDATAC                  0x000023A9L
#define O_MDATAC_HWINFMAIN        0x000123A9L   /* 1 - HW Info Mainboard */
#define O_MDATAC_HWINFPA          0x000223A9L   /* 2 - HW Info Endstufe */
#define O_MDATAC_HWINFFILT        0x000323A9L   /* 3 - HW Info Mains Filter */
#define O_MDATAC_HWINFBRES        0x000423A9L   /* 4 - HW Info Braking Resistor */
#define O_MDATAC_HWINFHOUSING     0x000523A9L   /* 5 - HW Info Housing */
#define O_MDATAC_HWINFOBOARD      0x000623A9L   /* 6 - HW Info Option Board */
#define O_MDATAC_HWINFCUSTOMER    0x000723A9L   /* 7 - HW Info Customer Settings */
#define O_MDATAC_TCPUMAX          0x000A23A9L   /* 10 - CPU Temperatur Max */
#define O_MDATAC_TNTC             0x000B23A9L   /* 11 - Temperatursensor NTC/PTC */
#define O_MDATAC_TABTHS1          0x000C23A9L   /* 12 - Temperaturkennlinie Wert 1 */
#define O_MDATAC_TABTHS2          0x000D23A9L   /* 13 - Temperaturkennlinie Wert 2 */
#define O_MDATAC_TABTHS3          0x000E23A9L   /* 14 - Temperaturkennlinie Wert 3 */
#define O_MDATAC_TABTHS4          0x000F23A9L   /* 15 - Temperaturkennlinie Wert 4 */
#define O_MDATAC_TABTHS5          0x001023A9L   /* 16 - Temperaturkennlinie Wert 5 */
#define O_MDATAC_TABTHS6          0x001123A9L   /* 17 - Temperaturkennlinie Wert 6 */
#define O_MDATAC_TABTHS7          0x001223A9L   /* 18 - Temperaturkennlinie Wert 7 */
#define O_MDATAC_TABTHS8          0x001323A9L   /* 19 - Temperaturkennlinie Wert 8 */
#define O_MDATAC_TABUHS1          0x001423A9L   /* 20 - Spannungskennlinie Wert 1 */
#define O_MDATAC_TABUHS2          0x001523A9L   /* 21 - Spannungskennlinie Wert 2 */
#define O_MDATAC_TABUHS3          0x001623A9L   /* 22 - Spannungskennlinie Wert 3 */
#define O_MDATAC_TABUHS4          0x001723A9L   /* 23 - Spannungskennlinie Wert 4 */
#define O_MDATAC_TABUHS5          0x001823A9L   /* 24 - Spannungskennlinie Wert 5 */
#define O_MDATAC_TABUHS6          0x001923A9L   /* 25 - Spannungskennlinie Wert 6 */
#define O_MDATAC_TABUHS7          0x001A23A9L   /* 26 - Spannungskennlinie Wert 7 */
#define O_MDATAC_ANA1OFFS         0x001B23A9L   /* 27 - Offset Abgleich Analog1 */
#define O_MDATAC_ANA2OFFS         0x001C23A9L   /* 28 - Offset Abgleich Analog2 */

/*INDEX_DESCRIPTION  9998  CANCOM  10  CANopen6000 parameter */
#define O_CANCOM                  0x0000270EL

/*INDEX_DESCRIPTION  9999  TRASH  105  Trash */
#define O_TRASH                   0x0000270FL
#define O_TRASH_RESERVED1         0x0003270FL   /* 3 - Reserved */
#define O_TRASH_IOFORCEVAL        0x0004270FL   /* 4 - Forcewert Digitale Eingänge/Ausgänge */
#define O_TRASH_MOTTYPE           0x000A270FL   /* 10 - Motortyp */
#define O_TRASH_SENSTYPE          0x000B270FL   /* 11 - Motorgeber */
#define O_TRASH_LQSAT1            0x000F270FL   /* 15 - Lq-saturation table 1*I0 */
#define O_TRASH_ESIMPINDEX        0x0014270FL   /* 20 - Reserviert: Encodersimulation: Position des Indexpulses */
#define O_TRASH_POLEPAIR          0x0015270FL   /* 21 - pair of poles of resolver */
#define O_TRASH_FREQ              0x0016270FL   /* 22 - resolver excitation frequency */
#define O_TRASH_RATIO             0x0017270FL   /* 23 - resolver transformation ratio */
#define O_TRASH_EFMPARAMCOUNT     0x001E270FL   /* 30 - Count of configured parameters */
#define O_TRASH_EFMHEADER         0x001F270FL   /* 31 - Count of the fixed parameters */
#define O_TRASH_EFMCFGCHANNEL     0x0020270FL   /* 32 - channel which has configured the EFM */
#define O_TRASH_EFMCHANGECOUNT    0x0021270FL   /* 33 - Count how often has benn changed the configuration */
#define O_TRASH_EFMCONFIG01       0x0022270FL   /* 34 - Configuration of the variable part of Enhanced Fast Monitoring */
#define O_TRASH_EFMCONFIG36       0x0023270FL   /* 35 - Configuration of the variable part of Enhanced Fast Monitoring */
#define O_TRASH_MACHENCTYPE       0x0028270FL   /* 40 - Configuration of the machine encoder type */
#define O_TRASH_AVERFBTIME        0x0048270FL   /* 72 - Mittlere Bearbeitungszeit der FB Task */
#define O_TRASH_DISP              0x0066270FL   /* 102 - HMI Display */
#define O_TRASH_DPOINT            0x0067270FL   /* 103 - HMI Display Punkte */
#define O_TRASH_MTERROR           0x0069270FL   /* 105 - Fehlerspeicher */

#endif
