#####################################################################
#####     Task 1 - Auto Floorplan Creation
#####################################################################

set DesignStage auto_floorplan

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/rtl_read -to ${DesignName}/auto_floorplan
open_block ${DesignName}/auto_floorplan

# Source tech setup script
source -echo ${SetupDir}/technology_setup.tcl

# Read the constraints
read_sdc -echo ${SdcFile}

# MCMM setup
source -echo ${SetupDir}/mcmm_setup.tcl

# Setup application options
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name compile.auto_floorplan.enable            -value true

# Check the design before compile_fusion
compile_fusion -check_only

#### Initial auto floorplan creation
compile_fusion -to logic_opto

#### Analyze the design
redirect -file ${ReportsDir}/${DesignStage}_report_congestion.rpt {report_congestion -rerun_global_router}
generateReports ${DesignStage}

#### Auto floorplan tuning

set DesignStage tuned_auto_floorplan

set_auto_floorplan_constraints \
    -control_type core \
    -core_utilization ${CoreUtilization} \
    -core_offset ${CoreOffset} \
    -shape ${CoreShape} \
    -side_ratio ${CoreSideRatio} \
    -flip_first_row ${FlipFirstRow}

report_auto_floorplan_constraints

set_app_options -name compile.auto_floorplan.place_pins -value all

# Pin placement constraints
set ports [remove_from_collection [get_ports] {VDD VSS}]

set_block_pin_constraints -self \
    -allowed_layers ${BlockPinLayers} \
    -sides ${BlockPinSides} \
    -pin_spacing_distance ${BlockPinSpacing} \
    -width ${BlockPinWidth} \
    -length ${BlockPinLength}

set_individual_pin_constraints \
    -ports [get_ports ${ClockName}] \
    -sides ${ClockPinSides} \
    -allowed_layers ${ClockPinLayers}

report_block_pin_constraints -self

# Place pins
place_pins -self -ports ${ports}

#### Tuned auto floorplan creation
set_lib_cell_purpose -include none {*/*_AO21* */*V2LP*}
compile_fusion -to logic_opto

#### Insert Boundary and TAP cells in the design
# source -echo ../scripts/insert_special_physical_cells.tcl

#### Analyze the design
redirect -file ${ReportsDir}/${DesignStage}_report_congestion.rpt {report_congestion -rerun_global_router}
generateReports ${DesignStage}

#### Write out the created floorplan 
write_floorplan -output ${ResultsDir}/auto_floorplan_files -exclude {cells nets} 

#### Write DEF for created floorplan
write_def -exclude {cells nets} ${ResultsDir}/auto_floorplan.def

get_blocks -all
save_block
save_lib

close_blocks
close_lib

exit
