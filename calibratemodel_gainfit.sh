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
XCM=${15}
LMODNAME=${16}
LMODCALC=${17}
LMODCPP=${18}
LMODOUTCPP=${19}
LMODDAT=${20}
GAINFIT=${21}
MONAME=${22}
LOG="calbpbackmodel.log"
LOG2="calbpbackmodel_entireErange.log"
IMG="pbackmodel_fit.ps"
PACKLOG="packagegen.log"

emin=9.0
emax=11.5
[ -e spectrum_emin.txt ] && {
    read emin < spectrum_emin.txt
}
[ -e spectrum_emax.txt ] && {
    read emax < spectrum_emax.txt
}
echo "Emin Emax = $emin $emax"
if [ "${GAINFIT}" -ne 1 ]; then
    channels="$(dmlist temp.rmf"[EBOUNDS]" data,raw | awk -v emin=$emin -v emax=$emax '$2<=emin&&$3>emin{ch1=$1;printf ch1" "}$2<=emax&&$3>=emax{ch2=$1;print ch2,ch2-ch1+1}')"
    echo "grppha channel spec: $channels"
fi

if [ "$CLOB" = "yes" ] || [ "$CLOB" = "no" -a ! -e "$LMODDAT" -a ! -e "$LMODOUTCPP" ]; then
    echo "${MONAME} 0 0. 1e5 c_acispback add 0 1" >$LMODDAT
    echo "// created at $(date)" >$LMODOUTCPP
    while read line; do
        if [ $(echo "$line" | grep -c "TEMPORAL1") -eq 1 ]; then line="std::ifstream ifs(\"$(pwd)/flux.dat\");"; fi
        if [ $(echo "$line" | grep -c "TEMPORAL2") -eq 1 ]; then line="std::ifstream ifs2(\"$(pwd)/emin.dat\");"; fi
        echo $line >>$LMODOUTCPP
    done <${SCRIPT_DIR}/acispback_model_template.cpp
    rm *pkgFunctionMap.* lpack_*pkg.cxx Makefile pkgIndex.tcl ${LMODNAME}.o lpack_*pkg.o $LMODCPP 2>/dev/null
    initpackage ${MONAME}_pkg $LMODDAT . >$PACKLOG 2>&1
    hmake >>$PACKLOG 2>&1
    rm temp_spec_grp.pi 2>/dev/null
else
    echo "clobber error while making $LMODDAT & $LMODOUTCPP."
    exit 1
fi

if [ "$CLOB" = "yes" ] || [ "$CLOB" = "no" -a ! -e "$XCM" ]; then
    echo -e "Calibrating the spectral model...\n"
        echo "Fitting energy range: $emin-$emax keV"
    echo "cpd /null" >$XCM # echo "cpd /xs" >$XCM
    echo "setp e" >>$XCM
    echo "setp com cs 1.3" >>$XCM
    echo "statistic cstat" >>$XCM
    echo "query yes" >>$XCM
    echo "setp com la t OBSID: " $(dmkeypar ${EV2FITS} OBS_ID echo+) >>$XCM
    echo "setp com lw 1 on 1..10000" >>$XCM
    echo "setp com r x 0.25 11.8" >>$XCM
    echo "setp com r y 1e-2 1e0" >>$XCM
    echo "setp com log x off 1 2" >>$XCM
    echo "setp com r y2 0. 2." >>$XCM
    echo "setp com wind 1" >>$XCM
    echo "setp com view 0.1 0.3 0.9 0.9" >>$XCM
    echo "setp com wind 2" >>$XCM
    echo "setp com view 0.1 0.1 0.9 0.3" >>$XCM

    if [ "${GAINFIT}" -eq 1 ]; then    
        echo "data 1:1 temp_spec.pi" >>$XCM
        echo "backgrnd none" >>$XCM
    else
        echo "test -f temp_spec_grp.pi && rm temp_spec_grp.pi" >>$XCM
	echo "grppha temp_spec.pi temp_spec_grp.pi comm='group "$channels" & exit'" >>$XCM #genspec=no
        echo "data 1:1 temp_spec_grp.pi" >>$XCM
        echo "backgrnd none" >>$XCM
    fi 
    echo "resp 1 temp.rmf" >>$XCM
    echo "ig **:**" >>$XCM
    echo "no **:$emin-$emax" >>$XCM
    if [ "${GAINFIT}" -eq 1 ]; then
        echo "gain fit" >>$XCM
        echo "1 0.0001" >>$XCM
        echo "0 0.0001" >>$XCM
    fi
    echo "lmod ${MONAME}_pkg ./" >>$XCM
    echo "mo ${MONAME}" >>$XCM
    echo "1 0.001" >>$XCM
    echo "pl ld ra" >>$XCM
    echo "setp com r y1" >>$XCM
    echo "pl ld ra" >>$XCM
    echo "fit" >>$XCM
    echo "log ${LOG}" >>$XCM
    if [ "${GAINFIT}" -eq 1 ]; then
        echo "error 1.0 1" >>$XCM  #error line
    fi
    echo "sho data" >>$XCM
    echo "sho param" >>$XCM
    echo "sho fit" >>$XCM
    echo "log none" >>$XCM
    echo "ig **:**" >>$XCM
    echo "no **:0.25-$emax" >>$XCM
    echo "setp rebin 5 50" >>$XCM
    echo "setp com r y1" >>$XCM
    echo "pl ld ra" >>$XCM

    echo "no **:0.25-$emax" >>$XCM
    echo "setp com ti of" >>$XCM
    echo "cpd ${IMG}/cps" >>$XCM
    echo "pl ld ra" >>$XCM
    echo "cpd none" >>$XCM
    #echo "cpd /xs" >>$XCM
    #echo "pl ld ra" >>$XCM
    echo "save mo ${OUTMODEL}" >>$XCM

    echo "log ${LOG2}" >>$XCM
    echo "sho data" >>$XCM
    echo "sho param" >>$XCM
    echo "sho fit" >>$XCM
    echo "log none" >>$XCM

    rm ${OUTMODEL} 2>/dev/null
    xspec >/dev/null <<EOF
@$XCM
EOF
else echo "clobber error while making xcm for calibration."; fi

NORMALIZATION=$(cat ${LOG} | grep "#   1    1" | grep -oE "[0-9][.][0-9E.+-]+" | grep -m1 -oE "[0-9][.][0-9E.+-]+")
echo "normalization = ${NORMALIZATION}"
#Added-Taweewat-8/31/22------------------
rm norm_error.cat
if [ "${GAINFIT}" -eq 1 ]; then
    cat ${LOG} |grep  "#     1" | grep -oE "[0-9][.][0-9eE.+-]+" | head -4 | tr "\n" " " > norm_error.cat
else
    echo ${NORMALIZATION} > norm_error.cat
fi
###------------------
rm acispback_lmod_temp.cpp 2>/dev/null
while read line; do
    if [ $(echo "$line" | grep -c "flux\[i\]=flux_temp2") -eq 1 ]; then line="flux[i]=flux_temp2 *$NORMALIZATION;"; fi
    echo $line >>acispback_lmod_temp.cpp
done <$LMODOUTCPP
cp acispback_lmod_temp.cpp $LMODOUTCPP
rm acispback_lmod_temp.cpp
rm *pkgFunctionMap.* lpack_*pkg.cxx Makefile pkgIndex.tcl ${LMODNAME}.o lpack_*pkg.o $LMODCPP 2>/dev/null
initpackage ${MONAME}_pkg $LMODDAT . >>$PACKLOG 2>&1
hmake >>$PACKLOG 2>&1

if [ "${GAINFIT}" -eq 1 ]; then
    echo "gain slope= " $(cat ${LOG} | grep -E "(gain)\s+(slope)+\s+" | grep -oE "[0-9\-]+.([0-9E\-]+|[0-9E\+]+)\s+(\+/\-)\s+[0-9\-]+.([0-9E\-]+|[0-9E\+]+)")
    echo "gain offset= " $(cat ${LOG} | grep -E "(gain)\s+(offset)+\s+" | grep -oE "[0-9\-]+.([0-9E\-]+|[0-9E\+]+)\s+(\+/\-)\s+[0-9\-]+.([0-9E\-]+|[0-9E\+]+)")
fi

CSTAT=$(cat ${LOG} | grep -E "(C-Statistic)\s+" | grep -oE "([0-9]+[\.][0-9E\+]+)" | head -1)
DOF=$(cat ${LOG} | grep -oE -m 1 "([0-9]+\s(degrees of freedom))" | grep -oE "[0-9]+[0-9E\+]+")
echo -e "C-Statistic/d.o.f.= ${CSTAT}/${DOF} \n"
if [ $(($(perl -e "print ${CSTAT}/${DOF} > 2.0") + 0)) -eq 1 ]; then
    echo -e "Warning !! Spectral model may be inappropriate with C-Statistic/d.o.f. > 2.0 !! \n"
fi
echo -e "Done. \n"
