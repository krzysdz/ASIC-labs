##########################
### Makefile for Task1 ###
##########################

.PHONY: help run_af run_mf run_pg all clean screenshots complete

help:
	@echo ""
	@echo " To printing usage: 								make help "
	@echo " To run Task1 - Auto Floorplan Crreation with Fusion Compiler:			make run_af "
	@echo " To run Task1 - Manual Floorplan Creation with Fusion Compiler:			make run_mf "
	@echo " To run Task1 - Creating Power and Ground Network with Fusion Compiler:		make run_pg "
	@echo " To clean working area:								make clean "
	@echo ""

run_af:
	test -d ./logs	|| mkdir ./logs
	fc_shell  -no_log -f ../scripts/task1af.tcl | tee ./logs/task1af.log

run_mf:
	test -d ./logs	|| mkdir ./logs
	fc_shell  -no_log -f ../scripts/task1mf.tcl | tee ./logs/task1mf.log

run_pg:
	test -d ./logs	|| mkdir ./logs
	fc_shell  -no_log -f ../scripts/task1pg.tcl | tee ./logs/task1pg.log

all: run_af run_mf run_pg

screenshots:
	fc_shell -no_log -f ../scripts/task1_screenshots.tcl | tee ./logs/task1_screenshots.log

complete: all screenshots

clean:
	rm -rf default* *.dlib fc.log HDL* CLIBs fc* check* lm_command.log work* logs/*
	rm -rf ../../../results/*.dlib
	rm -rf ../../../results/*.v
	rm -rf ../../../results/*floorplan*
	rm -rf ../../../results/*.def
	rm -rf ../../../results/*.spef*
	rm -rf ../../../results/*.sdc
	rm -rf ../../../results/*.gds
	rm -rf ../../../reports/*.rpt
	cp -rf ../../../solution/*.dlib ../../../results

