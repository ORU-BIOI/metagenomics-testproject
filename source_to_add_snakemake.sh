#export PATH=/proj/b2010008/nobackup/brynjar/hmp_map/miniconda/bin:$PATH
export OLD_PATH=$PATH
export PATH=$(pwd)/miniconda/bin:$(pwd)/bin:$PATH
source activate sci3

function conda_remove () {
	source deactivate
	export PATH=$OLD_PATH
}

## WORKSHOPENV LOAD MODULES
module load bioinfo-tools
module load prodigal/2.60
module load bowtie2/2.2.3
module load picard/1.127
module load velvet/1.2.10
module load samtools/1.1
module load Ray/2.3.1-mpiio
module load gnuparallel/20140222

#RUN picard with: java -jar $PICARD MarkDuplicates
export PICARD="/sw/apps/bioinfo/picard/1.127/milou/picard.jar"
