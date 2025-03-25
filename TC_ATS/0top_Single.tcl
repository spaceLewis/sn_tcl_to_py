# Top-Script for ATS Function categorie
#

# ----------HISTORY----------
# WHEN   WHO   WATH
# 011020 KAIDI created file

#
global ActDevCurr glbProductType libpath mainpath
source $mainpath/TC_ATS/ATS_lib.tcl
source $libpath/Keypad_lib.tcl

set theTestFileList {}


append_test theTestFileList FFT041_FaultStopMode.tcl			{ ATS48P OPTIM BASIC }
