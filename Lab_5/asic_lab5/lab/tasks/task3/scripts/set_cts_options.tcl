# Setup application options
set_app_options -name cts.common.max_fanout -value 20
set_app_options -name cts.compile.enable_cell_relocation -value timing_aware
set_app_options -name cts.compile.size_pre_existing_cell_to_cts_references -value true
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt

# Improve routability
set_app_options    -name route.common.wire_on_grid_by_layer_name   -value {{M1 true } {M2 true} {M3 true}}
set_app_options    -name route.common.via_on_grid_by_layer_name    -value {{VIA1 false} {VIA2 true}}
