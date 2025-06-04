#####################################################################
#####                          Task 2                           #####
#####################################################################

#### Sourcing main setup script
source -echo  ../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

# Create and compile library
set_app_var link_library "${DB_FF} ${DB_TT} ${DB_SS}"
create_lib ${ResultsDir}/${DesignLibrary}  -technology ${TechFile} -ref_libs ${RefLib}
report_ref_libs

# Analyze and elaborate
analyze -format sverilog [glob ${SystemVerilogDir}/*.{svh,sv}]
elaborate ${DesignName}
set_top_module ${DesignName}

# Save as rtl_read and close
save_block -as ${DesignName}/rtl_read
list_blocks
close_blocks -force

# Save lib and close
save_lib
close_lib

copy_lib -from_lib ${ResultsDir}/${DesignLibrary} -to_lib "${SolutionDir}/${DesignLibrary}"

exit
