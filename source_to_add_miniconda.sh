#export PATH=/proj/b2010008/nobackup/brynjar/hmp_map/miniconda/bin:$PATH
export OLD_PATH=$PATH
export PATH=$(pwd)/miniconda/bin:$PATH
source activate sci3

function conda_remove () {
	source deactivate
	export PATH=$OLD_PATH
}
