source -echo  ../../../setup/main_setup.tcl
source -echo  ${SetupDir}/design_setup.tcl

open_lib -read ${ResultsDir}/${DesignLibrary}

set TaskPrefix "task1_"

proc make_layout_screenshot {suffix} {
    variable TaskPrefix
    variable LabDir
    set ScreenshotsDir "${LabDir}/screenshots"

    gui_start
    set top [gui_create_window -type TopLevel]
    set layout [gui_create_window -type Layout -parent $top]
    gui_show_window -window $top -show_state {maximized}
    gui_show_window -window $layout -show_state {maximized}
    gui_write_window_image -window $layout -clip -file ${ScreenshotsDir}/${TaskPrefix}floorplan_layout_${suffix}.png
    gui_stop
}

foreach floorplan_type {auto manual final} {
    open_block -read ${DesignName}/${floorplan_type}_floorplan
    make_layout_screenshot ${floorplan_type}
    close_blocks
}

close_lib
exit
