# Artifact Evaluation Submission for pBox [SOSP '23]

**paper**: Pushing Performance Isolation Boundaries into Application with pBox

This documentation is written to use the pBox and reproduce the experiment result in our paper. All the experiments are evaluated on the [Cloudlab Infrastructure](https://www.clemson.cloudlab.us/portal/show-nodetype.php?type=c6420)

## Contents
- [Overview](#overview)
     - [Usage pattern of pbox](#usage-pattern-of-pbox)
- [Getting Started & Installing pBox Kernel](#getting-started--installing-pbox-kernel-30-human-minutes--40-compute-minutes)
- [Running Basic Microbenchmark Experiment](#running-basic-microbenchmark-experiment-5-minutes)
- [Build Applications & Test Frameworks](#build-applications--test-frameworks-approximately-30-minutes)
- [Running the Mitigation Experiment for Figure 11](#running-the-mitigation-experiment-for-figure-11-30-human-minutes-and-approximately-12-compute-hours)
- [Running the Sensitivity experiment for Figure 12](#running-the-sensitivity-experiment-for-figure-12-approximately-2-hours)
- [Running the Performance Overhead Experiment for Figure 13](#running-the-performance-overhead-experiment-for-figure-13-approximately-15-hours)

## Overview

Directory structure:
```
🏠 pbox
┣ psandbox-kernel   (git submodule, source code of pbox kernel part)
┣ psandbox-userlib  (git submodule, source code of pbox user library)
┣ 📄 script         (a set of script for running the experiment)
┣ 🖼️ software       (softwares for the experiment)
```

### Usage pattern of pbox

pbox is an OS abstraction that allows developers to achieve performance isolation
within an application. It exposes a set of APIs for developers to specify the isolation goal and the 
scope of isolation.  Figure 8 in the paper shows an example of how the developer uses pbox in MySQL.
After the instrumentation, the application just runs as normally, and pbox would automatically mitigate performance 
interference, which the end-to-end performance can observe.

## Getting Started & Installing pBox Kernel (30 human-minutes + 40 compute-minutes)

This instruction describes how to use pbox on Cloudlab. We will use Utah xl170 machines in Cloudlab. Please make sure that some are [available](https://www.cloudlab.us/resinfo.php) before you start.

1. Instantiate a cloudlab node.
    * [Login to Cloudlab](https://www.cloudlab.us/login.php).
    * Instantiate an node with our [cloudlab profile](https://www.cloudlab.us/p/FailureDetection/pbox).
1. Login to the node using ssh
1. Create a pbox user account.
     * run `sudo useradd -m -s $(which bash) -d /data/pbox -G sudo pbox` to create the account
     * run `sudo passwd pbox` to create the password for pbox account
     * Switch to pbox account `sudo su pbox`
     * change into home directory `cd ~`
     * **Note**: you may want to add your ssh public key in pbox user account if you want to ssh to the machine.
1. Clone [pbox](https://github.com/OrderLab/pBox.git) and its submodules.
    * `git clone --recursive https://github.com/OrderLab/pBox.git pbox`
1. Build pbox kernel.
    * `cd ~/pbox/psandbox-kernel`
    * In psandbox-kernel directory, run the command `./setup_pbox_kernel.sh` to build the pbox kernel
    * This command produces a pbox kernel image(`.deb` files) and installs it on the machine.
1. Boot the machine to switch to the pbox image.
   * `sudo reboot`
   * The machine would choose the pbox image by default
1. Install the pbox user lib.
   * change into `psandbox-userlib` directory: `cd ~/pbox/psandbox-userlib`
   * In psandbox-userlib directory, run the command `./setup_pbox_lib.sh` to build the pbox user library
   * Set the environment variable by `source ~/.bashrc`

## Running Basic Microbenchmark Experiment (5 minutes) 
1. Follow the installing the pbox instructions above.
1. In the pbox directory, run the command `./script/run_experiment.py -i script/microbenchmark`. This will run the microbenchmark experiment in Figure 10. Each microbenchmark operation would run 100K times. The raw data should be output in `result/eval_micro.csv`.
1. Plot the figure by running the `./script/microbenchmark/plot.sh` command. The Cloudlab does not contain GUI environment, so to view the figure, it needs to be copied to your own machine first.

## Build Applications & Test Frameworks (approximately 30 minutes)
1. Download and build all applications used for the experiments.
   * Source the bash file `source ~/.bashrc`
   * `cd ~/pbox/software`
   * Download all the applications: `./download_all.sh`
   * Build all the applications: `./compile_all.sh`
   * Source the bash file `source ~/.bashrc`
   * This script downloads the five applications: MySQL, PostgreSQL, apache, varnish, Memcache and their benchmark tool in the software folder. It takes around 25 mins to download and build the applications. Remember to source the bashrc file again after the compilation, as the pbox would update the environment variable in the bashrc file.
1. Build all test frameworks:
   * Source the bash file `source ~/.bashrc`
   * `cd ~/pbox/software`
   * `./compile_benchmark.sh`
   * Source the bash file `source ~/.bashrc`
1. Client node setup for Apache and varnish
    * For Apache and varnish experiment, we will create three additional clients node.
    * Instantiate a node with our [cloudlab profile](https://www.cloudlab.us/p/FailureDetection/client).
    * In each client machine, run `sudo apt install apache2-utils`
    * In the server machine, set the SSH configuration file(`~/.ssh/config`) with client machine information.
        * Example of the config file:
          ```bash
          Host client1
               HostName c220g5-110906.wisc.cloudlab.us
               User pbox
          Host client2
               HostName c220g5-110906.wisc.cloudlab.us
               User pbox
          Host client2
               HostName c220g5-110906.wisc.cloudlab.us
               User pbox
           ```
         * **Note**: the host name must be client1, client2 and client3. A different name would cause failure when running the experiment on Apache and varnish
    

## Running the mitigation experiment for Figure 11 (30 human minutes and approximately 12 compute hours)
This experiment measures the effectiveness of pbox on 16 cases in paper's table 3 and compares pbox with four performance interference
mitigation solutions: cgroup, PARTIES, Retro and DARC. The experiment reproduces the result in Figure 11. 

### Running the pbox mitigation experiment on each real-world case
1. Running the vanilla Linux, pbox and cgroup.
    * `cd ~/pbox`
    * To run all the cases, use `/script/run_mitigate.py.` To specify one case, use `./script/run_mitigate.py -i _case_id_`
    * The raw data is in `result/data/mitigation_pbox.csv`
1. Plot the figure by running 
### Running the comparison experiment on Partis and Retro
1. Running the parties.
    * `cd ~/pbox`
    * To run all the cases, use `/script/run_mitigate.py -t 1`. To specify one case, use `./script/run_mitigate.py -t 1 -i _case_id_`
    * The raw data is in `result/data/mitigation_parties.csv.`
1. Running the Retro.
    * `cd ~/pbox`
    * To run all the cases, use `/script/run_mitigate.py -t 2`. To specify one case, use `./script/run_mitigate.py -t 2 -i _case_id_`
    * The raw data is in `result/data/mitigation_retro.csv.`

**Note**: Some test results may differ a lot from the paper's figure due to performance variance. If you encounter a result different from the paper's figure, please check the raw data in the `result/data/eval_overhead.csv.` to find the problematic setting and rerun it instead of rerun the whole experiment.



## Running the Sensitivity Experiment for Figure 12 (approximately 2 hours)
This experiment measures the sensitivity of isolation goals when creating a pbox. The experiment reproduces the result in Figure 12.
1. Running the experiment
    * `cd ~/pbox`
    * To run all the cases, use `./script/run_sensitivity.py -i 0`. To specify one case, use `./script/run_mitigate.py -i _case_id_`
    * The raw data is in `result/data/eval_sensitivity.csv`
1. Plot the figure by running `./script/sensitivity/plot_eval_rule_sensitivity.py result/data/eval_sensitivity.csv -o fig12.eps`
1. **Note**: Sometimes, the result for some cases may differ from the paper's figure due to performance variance. If you see some case's result is different from the paper's figure, please rerun the specified case instead of rerun the whole experiment.
   
## Running the Performance Overhead Experiment for Figure 13 (approximately 1.5 hours)
This experiment measures the end-to-end throughput of pbox for all five systems under the standard workload. The experiment reproduces the result in Figure 13.
1. Running the experiment.
    * `cd ~/pbox`
    * To run all the applications, use `./script/run_overhead.py -n all`.
    * `./script/run_overhead.py` has four parameters:
      ```bash
         -n NAME, --name NAME;  the tested application name
         -t THREADS, --threads THREADS; the number of thread to run concurrently
         -r ISREAD, --isread; whether the workload is read-intensive (only work for MySQL, PostgreSQL and Memcached)
                                       0: write-intensive, 1: read-intensive
         -p ISPBOX, --ispbox ISPBOX; whether the pbox is running
                                  0: no pbox, 1: pbox

      ```
    * To run one setting, use `./script/run_mitigate.py -n app_name -t threads -p 0 -r 0`
    * The raw data is in `result/data/` folder. The overall result is `result/data/eval_overhead.csv.` The result for each application is `overhead_appname.csv`
1. Plot the figure by running the script `./script/sensitivity/plot_eval_overhead.py result/data/eval_overhead.csv -o fig12.eps`
1. **Note**: Some test results may differ a lot from the paper's figure due to performance variance. If you encounter a result different from the paper's figure, please check the raw data in the `result/data/eval_overhead.csv.` to find the problematic setting and rerun it instead of rerun the whole experiment.


