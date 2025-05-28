source -echo ../../setup/main_setup.tcl
source -echo ${SetupDir}/design_setup.tcl

create_lib ${ResultsDir}/${DesignLibrary} -technology $TechFile -ref_libs ${RefLib}
report_ref_libs

analyze -format sverilog [glob ${SystemVerilogDir}/*.{svh,sv}]
elaborate ${DesignName}
set_top_module ${DesignName}

save_block -as ${DesignName}/rtl_read

# start_gui

compile_fusion -to initial_map

report_timing
report_power
report_area
