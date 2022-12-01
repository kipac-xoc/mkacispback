#! /bin/sh

### default parameter values
WEMIN=9000                        # Emin for weight map
WEMAX=11500                       # Emin for weight map
RMFDELTAE=0.005                   # delta E of rmf
GENWMAP=1                         # generate weight map or use already existing one
GENSPEC=1                         # generate data spectrum or use already existing one
GENRMF=1                          # generate rmf or use already existing one
CLOB="no"                         # overwrite files or not
FS_EBOUNDFLAG=1                   # 0: calculate "framestore lines" from each data, 1: use default
STOWEDFLAG=0                      # 0: usual observation, 1: ACIS "stowed" observation
GAINFIT=1                         # 1: fit with free gain parameters, 0: with fixed gain (slope=1.0, offset=0.0)
OUTMODEL="out_acispback_model.mo" # output model file name
MONAME="acispback"                # output XSPEC model name
DIRNAME="acispback"               # output directory name which contains output spectral model
RM_TEMP=0                         # remove temporal files

##New parameter-Taweewat
NORMFIT=0					     # whether we want to fit the high energy total normalization or not.
FAKEEVT=0					     # set to make use of the fake event for very small regions
####----

XCM="temp_makemodel.xcm"
LMODNAME="acispback_lmod"
LMODCALC="acispback_calc"
LMODCPP="${LMODCALC}.cpp"
LMODOUTCPP="${LMODNAME}.cpp"
LMODDAT="${LMODNAME}.dat"
SCRIPT_DIR="$ACISPBACK"
INDATAMODE="none"
###

### input values
EV2FITS=$1
REGIONFILE=$2
EV2FITS_MAIN=$(echo "${EV2FITS}" | awk -F'[\[]' '{print $1}' 2>/dev/null)
if [ $(echo "$@" | grep -cE "(\-\-h|\-help)") -eq 1 ]; then
	cat ${SCRIPT_DIR}/help
	exit 0
fi
if [ $(echo "$@" | grep -c "genwmap=") -eq 1 ]; then GENWMAP=$(echo "$@" | grep -cE "genwmap=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "genspec=") -eq 1 ]; then GENSPEC=$(echo "$@" | grep -cE "genspec=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "genrmf=") -eq 1 ]; then GENRMF=$(echo "$@" | grep -cE "genrmf=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "rmffile=") -eq 1 ]; then
	RMFFILE=$(echo "$@" | grep -oE "(rmffile=.+)" | awk -F'[ ]' '{print $1}' | awk -F'[=]' '{print $2}')
	GENRMF=0
fi
if [ $(echo "$@" | grep -c "wemin=") -eq 1 ]; then WEMIN=$(echo "$@" | grep -oE "wemin=[0-9]+" | grep -oE "[0-9]+"); fi
if [ $(echo "$@" | grep -c "wemax=") -eq 1 ]; then WEMAX=$(echo "$@" | grep -oE "wemax=[0-9]+" | grep -oE "[0-9]+"); fi
if [ $(echo "$@" | grep -c "egrid=") -eq 1 ]; then RMFDELTAE=$(echo "$@" | grep -oE "egrid=[0-9]+.[0-9]+" | grep -oE "[0-9]+.[0-9]+"); fi
if [ $(echo "$@" | grep -c "clobber=") -eq 1 ]; then CLOB=$(echo "$@" | grep -oE "clobber=(yes|\"yes\"|\'yes\'|no|\"no\"|\'no\')" | grep -oE "(yes|no)"); fi
if [ $(echo "$@" | grep -c "gainfit=") -eq 1 ]; then GAINFIT=$(echo "$@" | grep -cE "gainfit=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "outdir=") -eq 1 ]; then DIRNAME=$(echo "$@" | grep -oE "(outdir=.+)" | awk -F'[ ]' '{print $1}' | awk -F'[=]' '{print $2}'); fi
if [ $(echo "$@" | grep -c "name=") -eq 1 ]; then MONAME=$(echo "$@" | grep -oE "(name=.+)" | awk -F'[ ]' '{print $1}' | awk -F'[=]' '{print $2}'); fi
if [ $(echo "$@" | grep -c "datamode=") -eq 1 ]; then INDATAMODE=$(echo "$@" | grep -oE "(datamode=.+)" | awk -F'[ ]' '{print $1}' | awk -F'[=]' '{print $2}'); fi
if [ $(echo "$@" | grep -c "clean=") -eq 1 ]; then RM_TEMP=$(echo "$@" | grep -cE "clean=(yes|\"yes\"|\'yes\')"); fi

## Edit Taweewat 9/14/2022-------
if [ $(echo "$@" | grep -c "normfit=") -eq 1 ]; then NORMFIT=$(echo "$@" | grep -cE "normfit=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "fakeevt=") -eq 1 ]; then FAKEEVT=$(echo "$@" | grep -cE "fakeevt=(yes|\"yes\"|\'yes\')"); fi
if [ $(echo "$@" | grep -c "specfile=") -eq 1 ]; then
	SPECFILE=$(echo "$@" | grep -oE "(specfile=.+)" | awk -F'[ ]' '{print $1}' | awk -F'[=]' '{print $2}')
	GENSPEC=0
fi
##---------------

FORVF=$(dmhistory ${EV2FITS} acis_process_events 2>/dev/null | grep -oE "check_vf_pha=[\"noyes]+" | grep -oE "(no|yes)")
FORVF=$(echo $FORVF | grep -oE "(no|yes)$")
if [ "$FORVF" = "no" ]; then FORVF=faint; fi
if [ "$FORVF" = "yes" ]; then FORVF=vfaint; fi
if [ "$INDATAMODE" = "faint" -o "$INDATAMODE" = "vfaint" ]; then FORVF=$INDATAMODE; fi
TEMPMOD_DIR="${SCRIPT_DIR}/template_models_${FORVF}"
###

if [ ! "$(echo "${EV2FITS_MAIN}" | grep -oE . | head -n 1)" = "/" -a ! "$(echo "${EV2FITS_MAIN}" | grep -oE . | head -n 1)" = "~" ]; then EV2FITS_MAIN="../${EV2FITS_MAIN}"; fi
ARGS="${WEMIN} ${WEMAX} ${RMFDELTAE} ${GENWMAP} ${GENSPEC} ${GENRMF} ${CLOB} ${STOWEDFLAG} ${FS_EBOUNDFLAG} ${EV2FITS_MAIN} ${FORVF} ${SCRIPT_DIR} ${TEMPMOD_DIR} ${OUTMODEL} ${XCM} ${LMODNAME} ${LMODCALC} ${LMODCPP} ${LMODOUTCPP} ${LMODDAT} ${GAINFIT} ${MONAME} $2 $3"

ARGS_NEW="${REGIONFILE} ${WEMIN} ${WEMAX} ${RMFDELTAE} ${GENWMAP} ${GENSPEC} ${GENRMF} ${CLOB} ${STOWEDFLAG} ${FS_EBOUNDFLAG} ${EV2FITS_MAIN} ${FORVF} ${SCRIPT_DIR} ${TEMPMOD_DIR} ${OUTMODEL} ${XCM} ${LMODNAME} ${LMODCALC} ${LMODCPP} ${LMODOUTCPP} ${LMODDAT} ${GAINFIT} ${MONAME} $2 $3"

### print some setup parameters
OBSID=$(dmkeypar "${EV2FITS}" OBS_ID echo+)
if [ $(echo "$OBSID" | grep -cE "([0-9]+|Merged)") -eq 0 -o $(echo "$FORVF" | grep -cE "(faint|vfaint)") -eq 0 ]; then
	echo -e "\nInput parameter error !! Exiting... \n"
	cat ${SCRIPT_DIR}/help
	exit 1
fi
if [ $(echo "${MONAME}" | grep -cE [0-9]) -gt 0 ]; then
	echo -e "\nError in model name !! It contains a number !! Exiting... \n"
	exit 1
fi

echo "OBSID: $OBSID"
echo -e "data mode= ${FORVF} \n"
###

### make a working directory
if [ ! -e "${DIRNAME}" ]; then mkdir "${DIRNAME}"; fi

### create region-selected event file
if [ $((GEMSPEC + GENWMAP + GENRMF)) -gt 0 ]; then
	dmcopy "${EV2FITS}" ${DIRNAME}/temp_evt_regfil.evt option=all clobber="$CLOB" >/dev/null
	if [ $? -gt 0 ]; then
		echo "Exiting due to an error..."
		exit 1
	fi
fi

cd "$DIRNAME"

### make 32x32-binned weight map corresponding to input region, and deltaE curves for frame store lines
bash ${SCRIPT_DIR}/makewmap.sh $ARGS_NEW $FAKEEVT
if [ $? -gt 0 ]; then
	echo "Exiting due to an error..."
	exit 1
fi

### extract spectrum and rmf from input region
if [ "$GENRMF" -eq 0 -a $(echo "$@" | grep -c "rmffile=") -eq 1 ]; then cp ../$RMFFILE ./temp.rmf; fi
if [ "$GENSPEC" -eq 0 -a $(echo "$@" | grep -c "specfile=") -eq 1 ]; then 
	cp ../$SPECFILE ./temp_spec_original.pi; 
	test -f temp_spec.pi && rm temp_spec.pi;
	grppha temp_spec_original.pi temp_spec.pi comm='reset grouping & exit'; #reset the grouping in our spectrum
fi
bash ${SCRIPT_DIR}/makespecandrmf.sh $ARGS
if [ $? -gt 0 ]; then
	echo "Exiting due to an error..."
	exit 1
fi

### take weighed-sum over template models
if [ "$FORVF" = "faint" ]; then
	bash ${SCRIPT_DIR}/makemodelfunction_faint.sh $ARGS
	if [ $? -gt 0 ]; then
		echo "Exiting due to an error..."
		exit 1
	fi
fi
if [ "$FORVF" = "vfaint" ]; then
	bash ${SCRIPT_DIR}/makemodelfunction_vfaint.sh $ARGS
	if [ $? -gt 0 ]; then
		echo "Exiting due to an error..."
		exit 1
	fi
fi

### calibrate the output spectral model
if [ "$NORMFIT" -gt 0 ]; then
	bash ${SCRIPT_DIR}/calibratemodel_gainfit.sh $ARGS
else
	bash ${SCRIPT_DIR}/calibratemodel_gainfit_nofit.sh $ARGS
fi
if [ $? -gt 0 ]; then
	echo "Exiting due to an error..."
	exit 1
fi

### remove temporal files
if [ "$RM_TEMP" -eq 1 ]; then
	echo -e "Removing temporal files...\n"
	rm temp*
fi

bash ${SCRIPT_DIR}/extracting_highcount.sh ${EV2FITS_MAIN} "../${REGIONFILE}"
echo "finished estimating uncertainty"

### reporting the norm/area/weight added Taweewat 10/6/22
## GAINFIT is representing whether the data is grouped to 1 bin (GAINFIT=1: no group, GAINTFIT=0: group)
cd ../
${ACISPBACK_PYTHON} ${SCRIPT_DIR}/calculate_norm_area_weight.py ${REGIONFILE} ${DIRNAME} 
if [ $? -gt 0 ]; then
	echo "Exiting due to an error at the reporting norm step"
	exit 1
fi

echo -e "All done.\n"
# cd ../
