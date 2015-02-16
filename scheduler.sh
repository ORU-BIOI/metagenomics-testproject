snakemake -j 350000 --debug --immediate-submit --cluster './scheduler.py {dependencies}' $*
