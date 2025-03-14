# 
#
#
# Description  : Top-Script fuer ein Testverzeichnis
#
# Filename     : 0top_Single.tcl
#
# 
#
# ----------HISTORY----------
# WANN   WER   WAS
# 110603 wurtr Datei erstellt
# 111203 pfeig Anpassung CPD
# 
#
#


#

global TestModus


set theTestFileList {}


append_test theTestFileList config_TestObject.tcl     { DevAll -Robustness}