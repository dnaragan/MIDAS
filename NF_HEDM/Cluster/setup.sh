#!/bin/bash

LOCAL_DIR=$( pwd )/Cluster
CHART=/
NF_MIDAS_DIR=${LOCAL_DIR%$CHART*}
BINFOLDER=${NF_MIDAS_DIR}/bin

##### Put correct folder paths
configdir=${HOME}/.MIDAS
configfile=${configdir}/pathsNF
echo "BINFOLDER=${BINFOLDER}/" > ${configfile}
echo "PFDIR=${LOCAL_DIR}/" >> ${configfile}
echo "SWIFTDIR=${HOME}/.MIDAS/swift-0.95-RC6/bin/" >> ${configfile}
echo "MACHINE_NAME=${1}" >> ${configfile}
ln -s ${LOCAL_DIR}/runSingleLayer.sh ${configdir}/MIDAS_V3_NearFieldSingleLayer.sh
ln -s ${LOCAL_DIR}/runMultipleLayers.sh ${configdir}/MIDAS_V3_NearFieldMultipleLayers.sh
ln -s ${LOCAL_DIR}/runNFParameters.sh ${configdir}/MIDAS_V3_NearFieldParameters.sh

echo "Congratulations, you can now use MIDAS to run NeField analysis"
echo "Go to ${HOME}/.MIDAS folder, there is MIDAS_V3_NearField.....sh files for running analysis"
