WEMIN=$1
WEMAX=$2
RMFDELTAE=$3
GENWMAP=$4
GENSPEC=$5
GENRMF=$6
CLOB=$7
STOWEDFLAG=$8
FS_EBOUNDFLAG=$9
EV2FITS=${10}
FORVF=${11}
SCRIPT_DIR=${12}
TEMPMOD_DIR_STEM=${13}
OUTMODEL=${14}

for CCD in 0 1 2 3 5 6 7; do
if [ "$GENWMAP" -eq 1 ]; then
echo -e "Processing CCD${CCD}.\n  Creating weight map..."
punlearn dmextract
dmextract wmap="[energy=${WEMIN}:${WEMAX}][bin chipx=1:1024:32,chipy=1:1024:32]" mode=h verbose=0 infile="temp_evt_regfil.evt[ccd_id=${CCD}][bin pi=1:1024:1]" outfile=temp_ccd${CCD}_energy${WEMIN}to${WEMAX}.fits clobber="$CLOB" >/dev/null
${ACISPBACK_PYTHON} ${SCRIPT_DIR}/make_weightmap.py temp_ccd${CCD}_energy${WEMIN}to${WEMAX}.fits >temp_weightmap_ccd${CCD}_energy${WEMIN}to${WEMAX}.dat
echo -e "  Created."
fi
done

