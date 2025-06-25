#!/usr/bin/env bash

A=80_000_000
B=50_000_000
L=10
S=0
R=0

echo -e "A=$A B=$B\nL=$L\nS=$S R=$R"

A_T=$(( 1000000000 / ${A//_/} ))
RST_T=$(( 3 * $A_T ))
echo "RST_T=$RST_T"

# -q       - quiet
# -R       - run executable after compiling
# -no_save - disables $save and allows running with ASLR

pushd fifo/ > /dev/null
MOD=fifo_tb
vcs -q -f fifo.f \
    -pvalue+$MOD.CLK_a_F_HZ=$A -pvalue+$MOD.CLK_b_F_HZ=$B \
    -pvalue+$MOD.SYM_LENGHT=$L \
    -pvalue+$MOD.MIN_DELAY_VALID_A=$S -pvalue+$MOD.MAX_DELAY_VALID_A=$S \
    -pvalue+$MOD.MIN_DELAY_READY_B=$R -pvalue+$MOD.MAX_DELAY_READY_B=$R > /dev/null
FIFO_LAST=$(./simv -q -no_save | grep -oP 'recived in domain B \(Val in hex\):\s+[0-9A-Fa-f]+, at Time:\s+\K\d+' | tail -n1)
FIFO_T=$(( $FIFO_LAST - $RST_T ))
popd > /dev/null
pushd req_ack > /dev/null
MOD=req_ack_tb
vcs -q -f req_ack.f \
    -pvalue+$MOD.CLK_a_F_HZ=$A -pvalue+$MOD.CLK_b_F_HZ=$B \
    -pvalue+$MOD.SYM_LENGHT=$L \
    -pvalue+$MOD.MIN_DELAY_VALID_A=$S -pvalue+$MOD.MAX_DELAY_VALID_A=$S \
    -pvalue+$MOD.MIN_DELAY_READY_B=$R -pvalue+$MOD.MAX_DELAY_READY_B=$R > /dev/null
RA_LAST=$(./simv -q -no_save | grep -oP 'recived in domain B \(Val in hex\):\s+[0-9A-Fa-f]+, at Time:\s+\K\d+' | tail -n1)
RA_T=$(( $RA_LAST - $RST_T ))
popd > /dev/null

echo -e "Raw FIFO\t$FIFO_LAST\nRaw Req-Ack\t$RA_LAST"
echo -e "FIFO\t$FIFO_T\nReq-Ack\t$RA_T"
