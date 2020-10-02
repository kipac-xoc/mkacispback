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

if [ "$GENSPEC" -eq 1 ]; then
echo -e "Extracting spectrum..."
punlearn dmextract
dmextract wmap="[energy=9000:11500][bin tdet=32]" mode=h verbose=0 infile="temp_evt_regfil.evt[bin pi=1:1024:1]" outfile=temp_spec.pi clobber=$CLOB >/dev/null
#fimgtrim infile=temp_spec.pi const_lo=0 outfile=temp.wmap const_up=1 threshup=0.5 threshlo=1 type=a clobber=$CLOB >/dev/null
echo -e "Extracted."
fi
if [ "$GENRMF" -eq 1 ]; then
echo -e "Creating rmf..."
punlearn mkacisrmf
mkacisrmf chantype=PI channel=1:1024:1 wmap=temp_spec.pi outfile=temp.rmf energy=0.243:12.0:${RMFDELTAE} verbose=1 infile=CALDB asolfile=NONE gain=CALDB clobber=$CLOB >/dev/null
echo -e "Created."
fi

