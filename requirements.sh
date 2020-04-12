#!/bin/bash
sudo apt install build-essential g++ python python-pip numactl
sudo pip install --upgrade pip
sudo pip install pandas

# add to bashrc/profile
export PATH=$PATH:/opt/intel/bin
