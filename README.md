# Artifact Evaluation Submission for pBox [SOSP '23]

**paper**: Pushing Performance Isolation Boundaries into Application with pBox

This documentation is written to use the pBox and reproduce the experiment result in our paper. All the experiments are evaluated on the [Cloudlab Infrastructure](https://www.clemson.cloudlab.us/portal/show-nodetype.php?type=c6420)

## Contents
- [Overview](#overview)
     - [Usage pattern of pbox](#usage-pattern-of-pbox)
- [Getting Started & Installing pBox Kernel](#getting-started--installing-pbox-kernel-30-human-minutes--40-compute-minutes)
- [Running Basic Microbenchmark Experiment](#running-basic-microbenchmark-experiment-5-minutes)
- [Build Applications & Test Frameworks](#build-applications--test-frameworks-approximately-30-minutes)
- [Running the Mitigation Experiment for Figure 11](#running-the-mitigation-experiment-for-figure-11-30-human-minutes-and-approximately-8-compute-hours)
     - [Running the pbox mitigation experiment on each real-world case](#running-the-pbox-mitigation-experiment-on-each-real-world-case)
     - [Running the comparison experiment on Partis and Retro](#running-the-comparison-experiment-on-partis-and-retro)
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

## Requirements

pBox can be used in recent Linux systems (tested on Debian 10.9, Ubuntu 18.04, and Ubuntu 20.04). For development and exploration of pBox, we recommend the usage of a VM or QEMU. For performance measurements, pBox should be used in a physical machine.

To ensure consistency for the artifact evaluation, we run pBox on **physical nodes in CloudLab**. The following instructions describe the usage for this environment.

**Hardware:** 

* The experiments require a total of **four nodes**:
  * We will use one **Utah xl170** node in CloudLab to run the pBox kernel and applications.
  * To run the experiments for Apache and Varnish, we will three additional clients nodes. These nodes can be of any type.
* Please make sure such four nodes are [available](https://www.cloudlab.us/resinfo.php) before you start.

## Getting Started & Installing pBox Kernel (30 human-minutes + 40 compute-minutes)

1. Instantiate a CloudLab node.
    * [Login to Cloudlab](https://www.cloudlab.us/login.php).
    * Instantiate a node with our [cloudlab profile](https://www.cloudlab.us/p/FailureDetection/pbox).

2. Login to the node using ssh

3. Create a pBox user account.
     * run `sudo useradd -m -s $(which bash) -d /data/pbox -G sudo pbox` to create the account
     * run `sudo passwd pbox` to create the password for pbox account
     * Switch to pbox account `sudo su pbox`
     * change into home directory `cd ~`
     * **Note**: you may want to add your ssh public key in pbox user account if you want to ssh to the machine.

4. Clone [pbox](https://github.com/OrderLab/pBox.git) and its submodules.
    * `git clone --recursive https://github.com/OrderLab/pBox.git pbox`

5. Build pBox kernel.

    ```bash
    cd ~/pbox/psandbox-kernel
    ./setup_pbox_kernel.sh
    ```

    * If successful,  the pBox kernel image (`linux-*-5.4.0-my-k*.deb` files) will be built and installed.
      * **Note**⚠️: the script will ask for your confirmation before installing the pBox kernel, please enter `Y`.

6. Boot the machine to switch to the pBox image.
   * `sudo reboot`
   * The machine would choose the pBox image by default

7. Install the pBox user library.

   ```bash
   cd ~/pbox/psandbox-userlib
   ./setup_pbox_lib.sh
   ```

   * If successful, the pBox user library (`build/libs/libpsandbox.so`) will be built.
   * Set the environment variable by `source ~/.bashrc`

## Running Basic Microbenchmark Experiment (5 minutes) 

1. Follow the installing the pBox instructions above.
2. In the `pbox` directory, run the command `./script/run_experiment.py -i script/microbenchmark`. This will run the microbenchmark experiment in Figure 10. Each microbenchmark operation would run 100K times. The raw data should be output in `result/eval_micro.csv`.
3. Plot the figure by running the `./script/microbenchmark/plot.sh` command. The CloudLab node does not contain GUI environment, so to view the figure, it needs to be copied to your own machine first.

## Build Applications & Test Frameworks (approximately 30 minutes)
1. Download and build all applications used for the experiments.
   * Source the bash file `source ~/.bashrc`
   
   * `cd ~/pbox/software`
   
   * Download and build the applications:
   
     ```bash
     ./download_all.sh
     ./compile_all.sh
     ```
   
     * The first script downloads five applications (MySQL, PostgreSQL, Apache, Varnish, and Memcached) and their benchmark tools in the `software` directory. The second script compiles the five applications.
     * It takes around 25 mins for the downloading and building to finish. 
   
   * Source the bash file `source ~/.bashrc`
   
     * **Note**⚠️: important since the previous scripts would update the environment variables in `.bashrc`.
   
2. Build the benchmark tools for the applications:
   * Source the bash file `source ~/.bashrc`
   * `cd ~/pbox/software`
   * `./compile_benchmark.sh`
   * Source the bash file `source ~/.bashrc`
   
3. Node setup for Apache and Varnish
    * For Apache and Varnish experiment, we will create three additional clients nodes.
    * Instantiate the three nodes with our [cloudlab profile](https://www.cloudlab.us/p/FailureDetection/client).
    * In each client machine, run `sudo apt install apache2-utils` to install a benchmarking tool.
    * In the server machine,
        1. set the SSH configuration file(`~/.ssh/config`) with client machine information
            * Example of the config file:
              ```bash
              Host client1
                   HostName c220g5-110906.wisc.cloudlab.us
                   User pbox
              Host client2
                   HostName c220g5-110907.wisc.cloudlab.us
                   User pbox
              Host client3
                   HostName c220g5-110908.wisc.cloudlab.us
                   User pbox
              ```
            * **Note**⚠️: the host name must be `client1`, `client2` and `client3`. A different name would cause failures when running the experiments on Apache and Varnish.
            * **Note**⚠️: please copy the ssh public key from the server node to the clients' node. This can be done by `ssh` into each client from your own machine and add the server node's public key to the `~/.ssh/authorized_keys` file.
            * **Note**⚠️: please make sure that client1|2|3 are in known_hosts. This can be done by manually `ssh` into each client once from the server machine before running scripts
        2. set the environment variable `SERVER_NODE` to store the server machine's public IP for clients to connect
            * Example: `echo 'export SERVER_NODE=c220g5-110990.wisc.cloudlab.us >> ~/.bashrc'`
            * **Note**⚠️: its value is passed remotely to clients. You only need to set it in the server machine.
    

## Running the mitigation experiment for Figure 11 (30 human minutes and approximately 8 compute hours)
This experiment measures the effectiveness of pBox on 16 cases in paper's table 3 and compares pBox with four performance interference mitigation solutions: cgroup, PARTIES, Retro and DARC. The experiment reproduces the result in Figure 11. 

### Running the pbox mitigation experiment on each real-world case

1. Running the vanilla Linux, pbox and cgroup.
    * `cd ~/pbox`
    * To run all the cases, use `/script/run_mitigate.py` 
      * To run one case, use `./script/run_mitigate.py -i <case_id>`
    * The raw data will be in `result/data/mitigation_pbox.csv`

2. Plot the figure by running `./script/cases/plot_eval_mitigation_pbox.py result/data/mitigation_pbox.csv -o fig11_half.pdf`

### Running the comparison experiments with Parties and Retro

1. Running the Parties and Retro.
    * `cd ~/pbox`
    * To run all the cases, use `/script/run_mitigate.py -t 1`. 
      * To run one case, use `./script/run_mitigate.py -t 1 -i <case_id>`
    * The raw data will be in `result/data/eval_mitigation.csv.`
2. Plot the figure by running `./script/cases/plot_eval_mitigation_comparsion.py result/data/eval_mitigation.csv -o fig11_half.pdf` 

**Note**⚠️: Some test results may differ from the paper's figure due to the system's performance variance. If you encounter the issue, try the following debugging process: 

* Check the raw data in the `result/data/mitigation_pbox.csv` or `result/data/eval_mitigation.csv` to find the problematic data point and its cases number
* Regenerate data point by running `./script/log_analyzer.py -i result/cases -o result/data/mitigation_pbox.csv -d 2 -t 2` for pbox mitigation experiment or `./script/log_analyzer.py -i result/cases -o result/data/eval_mitigation.csv -d 2 -t 5` for comparison experiment.
* If the data is still incorrect, rerun the problematic case by running `./script/run_mitigate.py -t 1 -i <case_id>`.

## Running the Sensitivity Experiment for Figure 12 (approximately 2 hours)

This experiment measures the sensitivity of isolation goals when creating a pbox. The experiment reproduces the result in Figure 12.
1. Running the experiment
    * `cd ~/pbox`
    * To run all the cases, use `./script/run_sensitivity.py -i 0`. 
      * To specify one case, use `./script/run_mitigate.py -i <case_id>`
    * The raw data is in `result/data/eval_sensitivity.csv`
2. Plot the figure by running `./script/sensitivity/plot_eval_rule_sensitivity.py result/data/eval_sensitivity.csv -o fig12.pdf`
3. **Note**⚠️: Some cases' results may differ from the paper's figure due to performance variance. If you encounter the issues, follow the debugging process above. The command to regenerate data for sensitivity experiment is `./script/log_analyzer.py -i result/sensitivity -o result/data/eval_sensitivity.csv -d 2 -t 3`

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
2. Plot the figure by running the script `./script/overhead/plot_eval_overhead.py result/data/eval_overhead.csv -o fig12.pdf`
3. **Note**⚠️: Some test results may differ greatly from the paper's figure due to performance variance. If you encounter the issue, please follow the debugging process above. The command to regenerate data for overhead experiment is `./script/log_analyzer.py -i result/overhead -o result/data/eval_overhead.csv -d 2 -t 7`
