mkacispback
=======================  
A software to generate spectral models for Chandra ACIS particle-induced background.  
Version: 2020-09-30  
Author: Hiromasa Suzuki (The University of Tokyo)  
hiromasa050701 (at) gmail.com  


### Requirements:
- c++11 compiler (ver. 4.2.1, 4.8.5 tested)
- python (ver. 3.0 or later reguired, 3.5.4, 3.6.8 tested) with "astropy" library
- CIAO (ver. 4.10, 4.11 tested)
- HEAsoft (ver. 6.20, 6.26.1 tested)


### How to use the software:
1. Set three environment variables as below:

       export ACISPBACK=</path/to/this directory>
       export ACISPBACK_PYTHON=</path/to/python**>   # python with astropy library (ex. "export ACISPBACK_PYTHON=/usr/local/bin/python3.7")
       export ACISPBACK_GXX=</path/to/g++**>   # g++ which supports c++11 (ex. "export ACISPBACK_GXX=/usr/local/bin/g++-9")

2. Copy the executable file "mkacispback" to /usr/local/bin (or somewhere in the $PATH).
3. Initialize HEAsoft and CIAO before running this command. The environment variable $CALDB must point at the CIAO CALDB.
4. After running the command, it generates a directory "acispback" (default), which contains the output spectral model "acispback" (default).
5. Run "mkacispback --h" to see the usage.


### Test platforms
- MacOS 10.14, 10.15
- CentOS 7


### References
- To be published
