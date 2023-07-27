#!/bin/bash
LOG_DIR="$(pwd)/../../result/eval_micro.csv"

echo "operation,latency" > $LOG_DIR 
$PSANDBOXDIR/build/tests/create_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/release_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/activate_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/freeze_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/bind_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/unbind_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/update_benchmark >> $LOG_DIR
$PSANDBOXDIR/build/tests/update_heavy >> $LOG_DIR
$PSANDBOXDIR/build/tests/get_pid >> $LOG_DIR
$PSANDBOXDIR/build/tests/pthread_create >> $LOG_DIR
