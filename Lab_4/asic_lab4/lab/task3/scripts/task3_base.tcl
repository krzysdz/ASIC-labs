#####################################################################
#####                          Task 3                           #####
#####################################################################

#### Sourcing main setup script
source -echo  ../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/rtl_read -to ${DesignName}/mcmm_and_logic_opto_${opt_type}
open_block ${DesignName}/mcmm_and_logic_opto_${opt_type}

# Source tech setup script
source -echo ${SetupDir}/technology_setup.tcl

# Read the constraints
read_sdc -echo ${SdcFile}

# MCMM setup
source -echo ${SetupDir}/mcmm_setup.tcl

if {[info exists opt_setting]} {
    set_app_options -name compile.flow.${opt_setting} -value ${opt_value}
}
report_app_options -non_default

# Initial mapping
compile_fusion -to logic_opto

# Collecting the reports
set TargetName "logic_opto_${opt_type}"
generateReports ${TargetName}

# Gate level netlist generation
write_verilog ${ResultsDir}/${DesignName}_${TargetName}.v

# Save layout image
# gui_start
# set window [gui_get_current_window -mru -type Layout]
gui_start
set top [gui_create_window -type TopLevel]
set layout [gui_create_window -type Layout -parent $top]
gui_show_window -window $top -show_state {maximized}
gui_show_window -window $layout -show_state {maximized}
gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/layout_${TargetName}.png
gui_stop

# Saving block and library
current_block
get_blocks -all
list_blocks
save_block
save_lib
close_blocks
close_lib

exit

