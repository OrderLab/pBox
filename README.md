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
1. Create a pbox user account
     * run 'sudo useradd -m -s $(which bash) -d /data/pbox -G sudo pbox' to create the account
     * run 'sudo passwd pbox' to create the password for pbox account
     * Switch to pbox account 'sudo su pbox'
     * change into home directory 'cd ~'
     * Note You may want to add your ssh public key into pbox account if you use ssh to access cloudlab node.
1. Clone [pbox](https://github.com/XXX/XXXX) and its submodules.
    * `git clone --recursive https://github.com/XXX/XXXX`
    * `psandbox-kernel` directory includes source code for pbox kernel.
1. Change into `psandbox-kernel` directory.
    * `cd ~/psandbox-kernel`
1. In psandbox-kernel directory, run the command `./setup_pbox_kernel.sh` to build the pbox kernel
   * This command produces a new kernel images with pbox abstraction(`.deb` files) and install them.
1. Booting the pbox Kernel on CloudLab
   * `sudo reboot`
1. Install the pbox user lib
   * change into `psandbox-userlib` directory: `cd ~/pbox/psandbox-userlib`
   * In psandbox-userlib directory, run the command 'setup_pbox_lib.sh'

### Import disk image

We also provide a default disk image with pbox kernel and userlib install. You can import it.

	