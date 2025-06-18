#####################################################################
#####                          Task 0                           #####
#####################################################################

#### Sourcing main setup script
source -echo  ../../../setup/main_setup.tcl

#### Sourcing project specyfic setup script
source -echo  ${SetupDir}/design_setup.tcl

#####################################################################
#### Creating Design Library
if {[string equal frame_timing ${RefNdmType}]} {
	if {[string equal tf ${TechFlowType}]} {
		create_lib ${ResultsDir}/${DesignLibrary} -technology $TechFile -ref_libs ${RefLib}
	} elseif {[string equal ndm ${TechFlowType}]} {
		lappend RefLib ${TechNdm}
		create_lib ${ResultsDir}/${DesignLibrary} -use_technology_lib ${TechNdm} -ref_libs ${RefLib} 
	} else {
		echo "Error: Valid values for the 'TechFlowType' variable are 'tf' or 'ndm'. Please correct the variable value."
	}
} elseif {[string equal frame_only ${RefNdmType}]} {
	#### Specifying the link libraries
	set_app_var link_library "${DB_FF} ${DB_TT} ${DB_SS}"
	create_lib ${ResultsDir}/${DesignLibrary} -technology $TechFile -ref_libs ${RefLib}
} else {
	echo "Error: Valid values for the 'RefNdmType' variable are 'frame_timing' or 'frame_only'. Please correct the variable value."
}

#### Reporting reference libraries
report_ref_libs

#### Reading RTL

# Analyze the HDL

# Suppress known warnings 
##suppress_message VER-130

if {[string equal sverilog ${HDL}]} {
	analyze -format sverilog [glob ${SystemVerilogDir}/*.svh]
	analyze -format sverilog [glob ${SystemVerilogDir}/*.sv]
} elseif {[string equal verilog ${HDL}]} {
	analyze -format verilog [glob ${VerilogDir}/*.v]	
} elseif {[string equal vhdl ${HDL}]} {
	analyze -format vhdl [glob ${VhdlDir}/*.vhd]
} else {
	echo "Error: HDL variable's value is neither 'sverilog' nor 'verilog' nor 'vhdl'. Please correct the variable value."
}
# Unsuppress after analyze stage
##unsuppress_message VER-130

# Elaborate
elaborate ${DesignName}

# Set top module in the design
set_top_module ${DesignName}

# Save block after RTL analysis and ealboration
save_block -as ${DesignName}/rtl_read

get_blocks -all
list_blocks

save_block
save_lib
copy_lib -to_lib ${SolutionDir}/${DesignLibrary}
close_blocks
close_lib
#####################################################################

exit

