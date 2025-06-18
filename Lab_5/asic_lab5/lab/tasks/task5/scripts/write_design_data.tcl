#####################################################################
###        Write data
#####################################################################

write_verilog \
	-include {pg_objects pg_netlist} \
	${ResultsDir}/${DesignName}.pg.v

write_verilog -exclude {physical_only_cells} ${ResultsDir}/${DesignName}.v

#### Write Constraints
write_sdc -output ${ResultsDir}/${DesignName}.sdc

#### Write Parasitics
write_parasitics -format SPEF -output ${ResultsDir}/${DesignName}.spef

write_gds -design ${DesignName} \
	  -layer_map ${GdsMapFile} \
	  -keep_data_type \
	  -fill include \
	  -output_pin all \
	  -merge_files ${GdsFile} \
	  -long_names \
	  -lib_cell_view frame\
	  ${ResultsDir}/${DesignName}.gds
