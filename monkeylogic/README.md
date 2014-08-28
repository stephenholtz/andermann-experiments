DAQ Assignments
=====================
* Should be true for all condition setups, but might need to be set up

* To get the daq assignments to play nicely together need to separate ports / channels
    * Reward (Reward) = AO1
    * Punishment (TTL1) = Port0/Line0
    * LED/Laser Opto (TTL2) = Port2/Line5
    * Behavioral Codes = Port1/Line1:6
    * Behavioral Strobe = Port1/Line7

* In the newer version of monkeylogic I had to hack the initio.m function to assign correct ports
    * Older versions should be fine though...
