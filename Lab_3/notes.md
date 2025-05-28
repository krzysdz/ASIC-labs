read_sdc must be executed after `current_mode`, because constraints are tied to modes
`current_mode` is set in mcmm_setup, so the line with `read_sdc` must be placed AFTER `source mcmm_setup`

This will, however, cause the following warning when saving, because the constraints won't apply to the _'default'_ mode (which we aren't using, because we have _Normal_):

> fc_shell> save_lib
> Saving library 'dut_toplevel.dlib'
> Warning: No valid clocks available in mode 'default'. Setting clock frequency to 1 GHz. (POW-034)
