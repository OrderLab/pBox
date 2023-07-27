# Artifact Evaluation Submission for pBox [SOSP '23]

**paper**: Pushing Performance Isolation Boundaries into Application with pBox

This documentation is written to use the pBox and reproduce the experiment result in our paper. All the experiments are evaluated on a XXX machine on the [Cloudlab Infrastructure](https://www.clemson.cloudlab.us/portal/show-nodetype.php?type=c6420)

## Contents

## Overview

## Getting Started && Installing pBox kernel 

The pBox experiment is conducted on a native machine. To keep the same setting, we provide an instruction to set up a cloudlab node and install pbox kernel. There are two way to build the environment: Manually setup or using our disk image. **Note** This is a performance work. Different hardware setting may cause performance variance.

### Manual setup (30 human-minutes + 40 compute-minutes)
1. Set up a cloudlab node.
    * Create an account on Cloudlab and login.
    * Create an experiment profile by selecting `Experiments > Create Experiment profile`
    * Select `Git Repo` and use this repository. The profile comes a node with the same setting in paper's section 6.
    ``` https://github.com/pbox/pbox-profiles```
   * Populate the name field and click `Create`. If successful, instantiate the created profile by clicking `Instantiate` button on the left pane.
   * You can access the cloudlab node through ssh command
1. Create a pbox user account.
     * run `sudo useradd -m -s $(which bash) -d /data/pbox -G sudo pbox` to create the account
     * run `sudo passwd pbox` to create the password for pbox account
     * Switch to pbox account `sudo su pbox`
     * change into home directory `cd ~`
     * **Note**: you may want to add your ssh public key into pbox account if you use ssh to access cloudlab node.
1. Clone [pbox](git@github.com:OrderLab/pBox.git) and its submodules.
    * `git clone --recursive git@github.com:OrderLab/pBox.git`
    * `psandbox-kernel` directory includes source code for pbox kernel.
1. Change into `psandbox-kernel` directory.
    * `cd ~/pbox/psandbox-kernel`
1. In psandbox-kernel directory, run the command `./setup_pbox_kernel.sh` to build the pbox kernel
   * This command produces a new kernel images with pbox abstraction(`.deb` files) and install them.
1. Booting the pbox Kernel on CloudLab.
   * `sudo reboot`
1. Install the pbox user lib.
   * change into `psandbox-userlib` directory: `cd ~/pbox/psandbox-userlib`
   * In psandbox-userlib directory, run the command 'setup_pbox_lib.sh'
1. Environment variable setup.
  The pbox experiments would require the testing applications to use different versions of pbox userlib.
  * Set the root directory of psandbox-userlib to `PSANDBOXDIR` variable. For example, `export PSANDBOXDIR=$HOME/pbox/psandbox-userlib`
  * Set the directory of pbox's lib to `LD_LIBRARY_PATH`. For example, `export LD_LIBRARY_PATH=$HOME/pbox/psandbox-userlib/build/libs:$LD_LIBRARY_PATH`

### Import disk image

We also provide a default disk image with pbox kernel and userlib install. You can import it.

## Running Basic Microbenchmark Experiment（2 minutes） 
1. Follow the installing the pbox instructions above.
1. In the pbox directory, run the command `./script/run_experiment.py -i script/microbenchmark`. This will run the microbenchmark experiment in section 10. Each microbenchmark operation would run 100K times.
1. The result should output in `result/script` directory. Plot the figure by running ./script/microbenchmark/plot.sh. The cloudlab does not contain GUI environment, so to view the figure, it needs to be copied out first.

## Running the major experiment

### Build applications && test frameworks (approximately 30 minutes)
1. In the software directory, run the script to download and compile all application versions for the experiments automatically:
   * Source the bash file `source ~/.bashrc`
   * `cd ~/pbox/software`
   * `./download_all.sh`
   * `./compile_all.sh`
   * Source the bash file `source ~/.bashrc`
   * This script downloads the five applications: MySQL, PostgreSQL, apache, varnish, Memcache and their benchmark tool in the software folder. It takes around 25 mins to download and build the applications. Remember to source the bashrc file again after the compilation, as the pbox would update the environment variable in the bashrc file.
     
1. In the software directory, run the script to compile all test frameworks automatically:
   * Source the bash file `source ~/.bashrc`
   * `cd ~/pbox/software`
   * `./compile_benchmark.sh`
   * Source the bash file `source ~/.bashrc`

1. Experiment setup for apache and varnish

### Running the mitigation experiment in Section 6.2 and Section 6.3 (30 human minutes and approximately 8 compute hours)
This experiment measures the effectiveness of pbox on 16 cases in Table 3 and compares pbox with four performance interference
mitigation solutions: cgroup, PARTIES, Retro and DARC. The experiment reproduces the result in Figure 11. Running the experiment on apache and varnish as well as running the DARC, requires different settings. We provide the following instructions for them. (Note: The execution time for all the experiments is extra high. We recommend  running each real-world case individually to validate the result.)



#### Running the pbox on each real-world case
1. In the pbox directory, run the script to run pbox.
    * `cd ~/pbox`
    * Run all the cases with `./script/run_mitigate.py -t 0`. To run one case, specify the case id by running `./script/run_mitigate.py -t 0 -i 1`
1. Plot the figure by running the script

#### Running parties on each real-world case
1. In the pbox directory, run the script to run pbox.
    * `cd ~/pbox`
    * Run all the cases with `./script/run_mitigate.py -t 1`. To run one case, specify the case id by running `./script/run_mitigate.py -t 1 -i 1`
1. Plot the figure by running the script

#### Running Retro on each real-world case
1. In the pbox directory, run the script to run pbox.
    * `cd ~/pbox`
    * Run all the cases with `./script/run_mitigate.py -t 2`. To run one case, specify the case id by running `./script/run_mitigate.py -t 2 -i 1`
1. Plot the figure by running the script
   
#### Running DARC on 16 cases

### Running the sensitivity experiment (approximately 20 minutes)
This experiment measures the end-to-end throughput of pbox for all five systems under the standard workload. The experiment reproduces the result in Figure 12.
1. In the pbox directory, run the script to run pbox.
    * `cd ~/pbox`
    * Run all the cases with `./script/run_sensitivity.py -i 0`. To run one case, specify the case id by running `./script/run_mitigate.py -i 1`
1. Plot the figure by running the script
   
### Run the performance overhead experiment in Section 6.5 (approximately 1.5 hour)
This experiment measures the end-to-end throughput of pbox for all five systems under the standard workload. The experiment reproduces the result in Figure 13.
1. In the pbox directory, run the script to run pbox.
    * `cd ~/pbox`
    * Run all the cases with `./script/run_overhead.py -n all`. To run one case, specify the case id by running `./script/run_mitigate.py -n MySQL`
1. Plot the figure by running the script


