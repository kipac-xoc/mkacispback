mkacispback
=======================  
A software to generate spectral models for Chandra ACIS particle-induced background.  
Version: 2021-07-15
Author: Hiromasa Suzuki (The University of Tokyo)  
hiromasa050701 (at) gmail.com  


### Requirements:
- c++11 compiler (ver. 4.2.1, 4.8.5 tested)
- python (ver. 3.0 or later reguired, 3.5.4, 3.6.8, 3.8.5 tested) with "astropy" library
- CIAO (ver. 4.10, 4.11, 4.12 tested)
- HEAsoft (ver. 6.20, 6.26, 6.27 tested)


### How to use the software:
1. Set three environment variables as below:

       export ACISPBACK=</path/to/this directory>
       export ACISPBACK_PYTHON=</path/to/python**>   # python with astropy library (ex. "export ACISPBACK_PYTHON=/usr/local/bin/python3.7")
       export ACISPBACK_GXX=</path/to/g++**>   # g++ which supports c++11 (ex. "export ACISPBACK_GXX=/usr/local/bin/g++-9")

2. Copy the executable file "mkacispback" to /usr/local/bin (or somewhere in the $PATH).
3. Initialize HEAsoft and CIAO before running this command. The environment variable $CALDB must point at the CIAO CALDB.
4. Run "mkacispback --h" to see the usage.


### Note:
- By default, mkacispback newly creates an rmf file corresponding to the input source region and this takes some time. To prevent this, provide a prepared rmf file by "genrmf=no" and "rmffile=INFILE".


### Test platforms:
- MacOS 10.14, 10.15
- CentOS 7


### Reference:
- Under review, to be published in A&A
