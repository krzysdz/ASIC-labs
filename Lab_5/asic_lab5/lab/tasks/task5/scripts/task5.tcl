#####################################################################
###        Task 5 Signoff
#####################################################################

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing design-specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/routing -to ${DesignName}/signoff
open_block ${DesignName}/signoff

#### Filler cell insertion
set FillerCells [get_object_name [sort_collection -descending \
 [get_lib_cells */*_FILL* -filter "name !~ *Y2* AND name !~ *SPACER*"] area]]

## create_stdcell_fillers -lib_cells ${FILLER_CELLS} 
create_stdcell_fillers -lib_cells ${FillerCells} 

# Remove placement blockage
remove_placement_blockages -all

## create_stdcell_fillers -lib_cells ${FILLER_CELLS}
create_stdcell_fillers -lib_cells ${FillerCells}

check_legality

#### Connect PG nets
connect_pg_net -net VDD [get_pins -hierarchical  */VDD]
connect_pg_net -net VSS [get_pins -hierarchical  */VSS]

save_block

#### ICV In-Design Run
set_host_options -target ICV -max_cores 12

set_app_options -name signoff.check_drc.runset -value ${DrcRunsetFile}
set_app_options -name signoff.check_drc.max_errors_per_rule -value 2000
set_app_options -name signoff.check_drc.run_dir -value "./signoff_drc_run/"
set_app_options -name signoff.physical.layer_map_file -value ${GdsMapFile}

save_block

# Run ICV DRC 
signoff_check_drc

# DRC fix
signoff_fix_drc

save_block

# Run ICV DRC to check the results 
signoff_check_drc

#### Metal Fill
set_app_options -name signoff.create_metal_fill.runset -value ${MetalFillRunsetFile}
signoff_report_metal_density -output pre_metal_fill_density.rpt
signoff_create_metal_fill -select_layers {M2 M3 M4 M5 M6}
signoff_report_metal_density -output post_metal_fill_density.rpt

#### Analyze the design
check_legality 
report_congestion 
report_utilization
generateReports signoff 

#### Write Out Design Data
source -echo ../scripts/write_design_data.tcl

get_blocks -all
list_blocks

save_block
save_block -as ${DesignName}
save_lib

exit
