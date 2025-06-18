#####################################################################
#####     Utilities for Fusion Compiler Lab
#####################################################################

proc generateReports {StageName} {
	
	global ReportsDir
	
	echo "Generating reports for the design stage: ${StageName} ..."

	redirect -file ${ReportsDir}/${StageName}_report_power.rpt {report_power -scenarios [all_scenarios]}
	redirect -file ${ReportsDir}/${StageName}_report_timing_setup.rpt {report_timing -scenarios [all_scenarios] -delay_type max}
	redirect -file ${ReportsDir}/${StageName}_report_timing_hold.rpt  {report_timing -scenarios [all_scenarios] -delay_type min}
	redirect -file ${ReportsDir}/${StageName}_report_area.rpt {report_area}
	redirect -file ${ReportsDir}/${StageName}_report_qor.rpt  {report_qor}
	redirect -file ${ReportsDir}/${StageName}_report_design.rpt  {report_design}

	echo "Reports have been generated for the design stage: ${StageName}."
}

