#!/bin/bash

#
# Copyright (c) 2014, UChicago Argonne, LLC
# See LICENSE file.
#

source ${HOME}/.MIDAS/paths

paramfile=$1 # always relative path
layernr=$2
DOPEAKSEARCH=$3
seedfolder=$( awk '$1 ~ /^SeedFolder/ { print $2 }' ${paramfile} )
startfilenrfirstlayer=$( awk '$1 ~ /^StartFileNrFirstLayer/ { print $2 } ' ${paramfile} )
nrfilesperlayer=$( awk '$1 ~ /^NrFilesPerSweep/ { print $2 } ' ${paramfile} )
filestem=$( awk '$1 ~ /^FileStem/ { print $2 } ' ${paramfile} )
startfilenr=$((${startfilenrfirstlayer}+$((${nrfilesperlayer}*$((${layernr}-1))))))
ide=$( date +%Y_%m_%d_%H_%M_%S )
outfolder=${seedfolder}/${filestem}_Layer${layernr}_Analysis_Time_${ide}
mkdir -p ${outfolder}
cd ${outfolder}
${BINFOLDER}/GetHKLList ${paramfile}
pfname=${outfolder}/Layer${layernr}_MultiRing_${paramfile}
cp ${paramfile} ${pfname}
finalringtoindex=$( awk '$1 ~ /^OverAllRingToIndex/ { print $2 }' ${paramfile} )
echo "LayerNr ${layernr}" >> ${pfname}
echo "RingToIndex ${finalringtoindex}" >> ${pfname}
echo "Folder ${outfolder}" >> ${pfname}
ringnrsfile=${outfolder}/Layer${layernr}_RingInfo.txt
rm -rf ${ringnrsfile}
paramfnstem=${outfolder}/Layer${layernr}_Ring
NewType=$( awk '$1 ~ /^NewType/ { print $2 }' ${paramfile} )
Thresholds=($( awk '$1 ~ /^RingThresh/ { print $3 }' ${paramfile} ))
i=0
SNr=$( awk '$1 ~ /^StartNr/ { print $2 }' ${paramfile} )
ENr=$( awk '$1 ~ /^EndNr/ { print $2 }' ${paramfile} )
RingNrs=$( awk '$1 ~ /^RingThresh/ { print $2 }' ${paramfile} )
echo "${outfolder}" >> ${seedfolder}/FolderNames.txt
echo "${pfname}" >> ${seedfolder}/PFNames.txt
if [[ ${DOPEAKSEARCH} == 1 ]];
then
	for RINGNR in ${RingNrs}
	do
		ThisParamFileName=${outfolder}/Layer${layernr}_Ring${RINGNR}_${paramfile}
		cp ${paramfile} ${ThisParamFileName}
		Fldr=${outfolder}/Ring${RINGNR}
		mkdir -p $Fldr/Temp
		mkdir -p $Fldr/PeakSearch
		cp hkls.csv $Fldr
		echo "Folder $Fldr" >> ${ThisParamFileName}
		echo "RingToIndex $RINGNR" >> ${ThisParamFileName}
		echo "RingNumbers $RINGNR" >> ${ThisParamFileName}
		echo "LowerBoundThreshold ${Thresholds[$i]}" >> ${ThisParamFileName}
		echo "LayerNr ${layernr}" >> ${ThisParamFileName}
		echo "StartFileNr $startfilenr" >> ${ThisParamFileName}
		echo "RingNumbers $RINGNR" >> $PFName
		echo $RINGNR >> ${ringnrsfile}
		i=$((i+1))
		echo "${ThisParamFileName}" >> ${outfolder}/ParamFileNames.txt
	done
	cp ${ringnrsfile} ${seedfolder}/RingInfo.txt
elif [[ ${DOPEAKSEARCH} == 0 ]];
then
	cd ${seedfolder}
	FolderStem=${filestem}_Layer${layernr}_Analysis_Time_
	oldoutfolder=$( python ${PFDIR}/getFolder.py ${paramfile} ${layernr} ${FolderStem} )
	outfldr=${seedfolder}/${oldoutfolder}/
	for RINGNR in $RingNrs
	do
		cp ${outfldr}/Radius_StartNr_${SNr}_EndNr_${ENr}_RingNr_${RINGNR}.csv ${outfolder}/
		ThisParamFileName=${outfolder}/Layer${layernr}_Ring${RINGNR}_${paramfile}
		cp ${paramfile} ${ThisParamFileName}
		Fldr=${outfolder}/Ring${RINGNR}
		mkdir -p $Fldr
		cp hkls.csv $Fldr
		mkdir -p ${Fldr}/PeakSearch/${filestem}_${layernr}/
		cp ${outfolder}/Radius_StartNr_${SNr}_EndNr_${ENr}_RingNr_${RINGNR}.csv ${Fldr}/PeakSearch/${filestem}_${layernr}/ 
		echo "Folder $Fldr" >> ${ThisParamFileName}
		echo "RingToIndex $RINGNR" >> ${ThisParamFileName}
		echo "RingNumbers $RINGNR" >> ${ThisParamFileName}
		echo "LowerBoundThreshold ${Thresholds[$i]}" >> ${ThisParamFileName}
		echo "LayerNr $layernr" >> ${ThisParamFileName}
		echo "StartFileNr $startfilenr" >> ${ThisParamFileName}
		echo "RingNumbers $RINGNR" >> $PFName
		echo $RINGNR >> ${ringnrsfile}
		${BINFOLDER}/FitTiltBCLsdSample ${ThisParamFileName}
		cp ${Fldr}/PeakSearch/${filestem}_${layernr}/paramstest.txt ${outfolder}/paramstest_RingNr${RINGNR}.txt
		mv ${ThisParamFileName} ${outfolder}
		i=$((i+1))
	done
	${BINFOLDER}/MergeMultipleRings ${pfname}
fi