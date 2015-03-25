#!/bin/bash

basep=$(dirname $(readlink -f miniconda.sh))
pref=$basep/miniconda 
p=$PATH
export PATH="$pref/bin:$PATH"

if [[ -f miniconda.sh ]]; then
	echo "Using previously downloaded miniconda.sh"
else
	python INSTALL.py | xargs wget -O miniconda.sh
	chmod u+x miniconda.sh
fi

if [[ -d $pref ]]; then
	echo "Using current miniconda installation at $pref."
else
	./miniconda.sh -b -p $pref
        conda create -n sci2 python=2 pip argcomplete numpy scipy scikit-learn pandas ipython-notebook matplotlib binstar biopython seaborn cython decorator pysam
        conda create -n sci3 python=3 pip argcomplete numpy scipy scikit-learn pandas ipython-notebook matplotlib binstar biopython seaborn cython decorator

fi
mkdir $basep/opt && cd $basep/opt
wget http://archive.lbzip2.org/lbzip2-2.5.tar.gz && tar -xvf lbzip2-2.5.tar.gz  && cd lbzip2-2.5 && ./configure && make check && make && cd ..
git clone https://github.com/inodb/metassemble.git
git clone https://github.com/BinPro/CONCOCT && cd CONCOCT && git checkout f4cb9fcb && cd .. 
wget https://github.com/broadinstitute/picard/releases/download/1.129/picard-tools-1.129.zip && unzip picard-tools-1.129.zip
git clone https://github.com/inodb/masmvali.git
git clone https://github.com/chapmanb/bcbb.git

mkdir $basep/bin && cd $basep/bin
ln -s $basep/opt/lbzip2-2.5/src/lbzip2 . 
cp /proj/g2014113/metagenomics/virt-env/mg-workshop/bin/shuffleSequences_fastq.pl .
cd $basep

source activate sci2
pip install ipdb
pip install opt/CONCOCT
pip install opt/masmvali
pip install opt/bcbb/gff
source deactivate

source activate sci3
pip install ipdb
pip install snakemake
source deactivate

export PATH=$p
