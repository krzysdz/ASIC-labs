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

write_verilog ${ResultsDir}/${DesignName}_initial_synthesis.v

current_block
save_block
save_block -as ${DesignName}/initial_synthesis

get_blocks -all
list_blocks

save_lib

copy_block -from ${DesignName}/rtl_read -to ${DesignName}/compile_flow
open_block ${DesignName}/compile_flow

source -echo ${SetupDir}/technology_setup.tcl
read_sdc -echo ${SdcFile}
source -echo ${SetupDir}/mcmm_setup.tcl
read_sdc -echo ${SdcFile}

set_lib_cell_purpose -include none {*/*_AO21* */*V2LP*}
set_app_options -name place.coarse.continue_on_missing_scandef -value true

compile_fusion -check_only

proc compile_and_report {StageName {nofrom "a"}} {
    if {$nofrom eq "-nofrom"} {
        compile_fusion -to $StageName
    } else {
        compile_fusion -from $StageName -to $StageName
    }
    generateReports $StageName
}

compile_and_report initial_map -nofrom
compile_and_report logic_opto
compile_and_report initial_place
compile_and_report initial_drc
compile_and_report initial_opto
compile_and_report final_place
compile_and_report final_opto

check_legality

save_block
save_lib

close_blocks
close_lib

exit
