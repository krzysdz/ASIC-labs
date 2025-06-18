#####################################################################
#####     Task 1 - Creating power and ground network                           
#####################################################################

set DesignStage create_pg_network

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Open the design library
open_lib ${ResultsDir}/${DesignLibrary}

# Copy and open block
copy_block -from ${DesignName}/rtl_read -to ${DesignName}/final_floorplan
open_block ${DesignName}/final_floorplan

# Source tech setup script
source -echo ${SetupDir}/technology_setup.tcl

# Read the constraints
read_sdc -echo ${SdcFile}

# MCMM setup
source -echo ${SetupDir}/mcmm_setup.tcl

#### Read floorplan from DEF
read_def ${ResultsDir}/manual_floorplan.def

#### Insert Boundary and TAP cells in the design
source -echo ../scripts/insert_special_physical_cells.tcl

#### Create Power/Ground Network
source -echo ../scripts/create_pg_network.tcl

#### Analyze the design
generateReports ${DesignStage}

save_block
save_lib

close_blocks
close_lib

exit

