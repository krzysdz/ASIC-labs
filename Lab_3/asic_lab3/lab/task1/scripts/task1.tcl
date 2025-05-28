source -echo ../../setup/main_setup.tcl
source -echo ${SetupDir}/design_setup.tcl

create_lib ${ResultsDir}/${DesignLibrary} -technology $TechFile -ref_libs ${RefLib}
report_ref_libs
