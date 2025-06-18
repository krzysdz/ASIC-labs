##########################
### Makefile for Task0 ###
##########################

help:
	@echo ""
	@echo " To printing usage: 			make help "
	@echo " To run Lab1 with Fusion Compiler:	make run "
	@echo " To clean working area:			make clean "
	@echo ""

run:
	test -d ./logs	|| mkdir ./logs
	fc_shell  -no_log -f ../scripts/task0.tcl | tee ./logs/task0.log 

clean:
	rm -rf default* *.dlib fc.log HDL* CLIBs fc* check* lm_command.log work* logs/*
	rm -rf ../../../results/*.dlib
	rm -rf ../../../results/*.v
	rm -rf ../../../solution/*.dlib
	rm -rf ../../../solution/*.v
