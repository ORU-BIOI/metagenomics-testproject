#!/bin/bash

if [[ -f miniconda.sh ]]; then
	echo "Using previously downloaded miniconda.sh"
else
	python INSTALL.py | xargs wget -O miniconda.sh
	chmod u+x miniconda.sh
fi

pref=$(dirname $(readlink -f miniconda.sh))/miniconda 

if [[ -d $pref ]]; then
	echo "Using current miniconda installation at $pref."
else
	./miniconda.sh -b -p $pref
fi
p=$PATH
export PATH="$pref/bin:$PATH"

conda create -n sci2 python=2 pip argcomplete numpy scipy scikit-learn pandas ipython-notebook matplotlib binstar biopython seaborn
conda create -n sci3 python=3 pip argcomplete numpy scipy scikit-learn pandas ipython-notebook matplotlib binstar biopython seaborn

source activate sci2
pip install ipdb
source deactivate

source activate sci3
pip install ipdb
pip install snakemake
source deactivate

export PATH=$p
