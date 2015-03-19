## metagenomics-workflow ##
A workflow for metagenomics analysis

###Install###
Running [INSTALL.sh](https://bitbucket.org/orebro-ngbi/microbiome-workflow/raw/master/INSTALL.sh) should create two virtual python environments, sci2 and sci3 which are python2 and python3 environments respectively. Snakemake requires python3.

###Snakemake###
To use snakemake one needs to add the sci3 environment to the PATH. The simplest way to do that is to source the file [source_to_add_snakemake.sh](https://bitbucket.org/orebro-ngbi/microbiome-workflow/raw/master/source_to_add_snakemake.sh)

###Download stool assemblies###
To download the published stool assemblies from the [HMP](http://hmpdacc.org/resources/data_browser.php) project you run snakemake so:

```
#!bash
snakemake -j 4 hmp_stool_data
```
or to run it parallel on clusters
```
#!bash
./scheduler.sh hmp_stool_data
```
This is possible since the rule has been defined in the [config](https://bitbucket.org/orebro-ngbi/microbiome-workflow/raw/master/scheduler.conf) file for the snakemake scheduler.

###Convert .tar.bz2 to .fastq.gz files, which are inputs to workflow###
The reads from a sample are in .tar.bz2 files. Each such files contains *strand_1*.fastq, *strand_2*.fastq and *singletons*.fastq. So to uncompress and untar them and to compress them again, run rule untar:

```
#!bash
./scheduler.sh untar
```

