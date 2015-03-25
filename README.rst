==========================================
Simple metagenomic workflow
==========================================
:date: 2015-03-24 00:00
:summary: Metagenomics workflow for binning contigs from reads
:adapted_from: Ino De Bruijn (https://github.com/inodb/2014-05-mdopson-viral)

Install Snakemake
===================
`Snakemake <https://bitbucket.org/johanneskoester/snakemake/wiki/Home>`_ has been used to make the analysis reproducible. Snakemake uses python3, and to make it simple to set up python3 with all packages that are required, running the `INSTALL.sh <https://github.com/ORU-NGBI/metagenomics-workflow/blob/master/INSTALL.sh>`_ script will create two virtual python environments from `Anaconda <https://store.continuum.io/cshop/anaconda/>`_, sci2 and sci3 which are python2 and python3 environments respectively. 

.. code-block:: bash

    ./INSTALL.sh

After running the INSTALL.sh script, there should be a file, `source_to_add_snakemake.sh <https://github.com/ORU-NGBI/metagenomics-workflow/blob/master/source_to_add_snakemake.sh>`_ that activates the snakemake environment when sourced: 

.. code-block:: bash

    source source_snakemake.sh


You can deactivate the environment again with:

.. code-block:: bash

    source deactivate
    
Running Snakemake
=================
Most rules can be run locally or submitted through sbatch. For a local run, taking the rule ``fastqc_all`` as an 
example one would do:

.. code-block:: bash

    snakemake -j 16 --debug -p --debug fastqc_all
    
for a run scheduled through sbatch:

.. code-block:: bash

    ./scheduler.sh fastqc_all

You can always do a dry-run to just print the commands that will
be run with ``-n``:

.. code-block:: bash

    snakemake -j 16 --debug -np --debug fastqc_all
    ./scheduler.sh -n fastqc_all

FastQC
=====================

FastQC on all reads:

.. code-block:: bash

    ./scheduler.sh fastqc_all

Generate report with:

.. code-block:: bash

    snakemake -j 1 -p --debug --rerun-incomplete fastqc_report report
    

Trimmomatic
===========
Removed adapters with trimmomatic through sbatch. Same as before just change the rule name to trimmomatic_all:

.. code-block:: bash

    ./scheduler.sh trimmomatic_all

Assemblies
==============
Assemblies with Ray through sbatch over kmers 31 to 81 with a stepsize of 10 on milou:

.. code-block:: bash

    ray_assembly_all
    
Merge the assemblies with Newbler:

.. code-block:: bash

    merge_newbler_all

Generate report locally:

.. code-block:: bash

    assembly_report

Mapping bowtie2
===============
After assembly, mapping all the reads back with bowtie2. Also cut up all assemblies in chunks of 10K
and mapped the reads back, because this is necessary for CONCOCT. One rule does both:

.. code-block::

    concoct_map_10K_all

Generate the report:

.. code-block::

    mapping_report

Run CONCOCT and annotation
==========================
Run CONCOCT through sbatch on milou with contigs bigger than 500, 700, 1000, 2000 and 3000:

.. code-block::

    concoct_run_10K_all

Predict proteins with prodigal:

.. code-block::
    
    prodigal_run_all

Align the predicted proteins against the COG database:

.. code-block::

    rpsblast_run_all

CONCOCT binning evaluation
==========================
Generate Single Copy Gene plots for each bin

.. code-block::
    
    concoct_eval_cog_plot_all

.. _POG: http://www.ncbi.nlm.nih.gov/COG/
.. _metassemble: https://github.com/inodb/metassemble
.. _complete example: https://concoct.readthedocs.org/en/latest/complete_example.html
