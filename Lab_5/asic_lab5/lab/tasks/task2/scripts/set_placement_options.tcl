# Setup application options
set_app_options -name place.coarse.continue_on_missing_scandef -value true
set_app_options -name place_opt.final_place.effort -value high
set_app_options -name place_opt.place.congestion_effort -value high
set_app_options -name opt.common.user_instance_name_prefix -value place_opt

set_lib_cell_purpose -include none {*/*_AO21* */*V2LP*}
