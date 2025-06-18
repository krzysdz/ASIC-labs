#####################################################################
#####     Task 1 - Manual Floorplan Creation                          
#####################################################################

set DesignStage manual_floorplan

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/auto_floorplan -to ${DesignName}/manual_floorplan
open_block ${DesignName}/manual_floorplan

#### Initialize the floorplan
initialize_floorplan  \
	-control_type core \
	-core_utilization ${CoreUtilization} \
	-core_offset ${CoreOffset} \
	-shape ${CoreShape} \
	-side_ratio ${CoreSideRatio} \
	-flip_first_row ${FlipFirstRow}

#### Set pin placement constraints
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
	
	
place_pins -self -ports ${ports}

#### Insert Boundary and TAP cells in the design
source -echo ../scripts/insert_special_physical_cells.tcl

#### Analyze the design
generateReports ${DesignStage}

#### Write out the created floorplan 
write_floorplan -output ${ResultsDir}/manual_floorplan_files -exclude {cells nets} 

#### Wrtl_readrite DEF for created floorplan
write_def -exclude {cells nets} ${ResultsDir}/manual_floorplan.def

get_blocks -all
save_block
save_lib

close_blocks
close_lib

exit
