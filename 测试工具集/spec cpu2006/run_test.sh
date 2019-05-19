#!/bin/bash
export PATH=/root/numa-test/:$PATH
. ./shrc

/root/numa-test/numastat;/root/numa-test/numactl --cpunodebind=0-7 --localalloc runspec -c ft-rate.cfg -T base -n 1 -r 64 -I -i ref int

