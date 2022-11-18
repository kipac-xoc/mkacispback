EV2FITS_MAIN=$1
REGIONFILE=$2

dmextract infile="${EV2FITS_MAIN}[energy=9000:11500][bin sky=region(${REGIONFILE})]" outfile=counts.fits opt=generic clobber=yes 
dmkeypar counts.fits COUNTS echo+ > counts_9-11.5.txt

count=$(cat "counts_9-11.5.txt")

#1/sqrt(N) fractional uncertainty
stat_uncer=$(echo "$count" | awk '{print 1/sqrt($1)}') 
echo ${stat_uncer} > stats_uncertainty.txt

#0.05 + 1/sqrt(N) combined uncertainty
echo "${stat_uncer}" | awk '{print sqrt(0.05^2+$1^2)}' > all_uncertainty.txt
