# eval_script
## Run Microbenchmark Experiment
./run_experiment.py -i script/microbenchmark 

## Run cases experiment
./run_experiment.py -i script/cases/c2/  -p 3 -f 

-p 1: run the interference case; 2: run the interference case with cgroup; 3:
run the interference case with psandbox; 4. collect the noisy neighbor performance with psandbox; 5.collect the noisy neighbor performance without psandbox;

## Run overhead experiment

./run_experiment.py -i script/overhead/postgresql/  -p 0 0 64 1 60 -f

## Run sensitivity experiment 

./run_experiment.py -i script/sentivity/c1/  -f

## Run comparison experiment
### PARTIES
./run_experiment.py -i script/cases/c1/ -d 1  -p 6 -f 



## Bash
export PATH=$HOME/software/apache/dist/bin:$HOME/software/mysql/dist/bin:$HOME/software/memcached/benchmark/bin:$HOME/software/memcached/mutilate:$HOME/software/memcached/dist/bin:$HOME/software/postgresql/dist/bin:$HOME/software/sysbench/eval_dist/bin:$HOME/software/varnish/dist/bin:$PATH
export LD_LIBRARY_PATH=$HOME/software/psandbox-userlib/build/libs:$HOME/software/mysql/dist/lib:$HOME/software/postgresql/dist/lib
export PSANDBOXDIR=$HOME/software/psandbox-userlib
export PSANDBOX_POSTGRES_DIR=$HOME/software/postgresql/dist
export POSTGRES_SYSBENCH_DIR=$HOME/software/sysbench-post/dist
export SYSBEN_DIR=$HOME/software/sysbench/dist/share/sysbench/
export PSANDBOX_MYSQL_DIR=$HOME/software/mysql/dist/
export PSANDBOX_APACHE_DIR=$HOME/software/apache/dist
export PSANDBOX_VARNISH_DIR=$HOME/software/varnish/dist

