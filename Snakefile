localrules: all, hmp_all_csv, hmp_body_csv, hmp_body_assembly_md5
import os
import json
import pandas as pd
from glob import glob
from requests import get

hmp_base_url = "http://{}hmpdacc.org/{}"

def mkdir(path_to_dir):
    """Create a directory if it does not exist, otherwise do nothing"""
    if not os.path.isdir(path_to_dir):
        os.makedirs(path_to_dir)



rule qc:
    input: 
        "{sample}.fastq"
    output: 
        qcout  = "{sample}_fastqc.html",
        zipout = "{sample}_fastqc.html"
    params:
        modules   = "module load bioinfo-tools FastQC",
        threads   = "16",
        noextract = "--noextract"
    run:
        abspath = os.path.abspath(output.qcout)
        outdir  = os.path.dirname(abspath)
        mkdir(outdir)
        shell("""fastqc --outdir {outdir} {params.noextract} --threads {params.threads} {input}""")

rule cutadapt:
    input: 
        "{sample}.fastq"
    output:
        cutout = "cutadapt/{sample}.fastq"
    params:
        cutadatp_exec = "/pica/h1/brynjar/miniconda/envs/sci2/bin/cutadapt",
        cut           = "5",
        qual_cutoff   = "20",
        adapter       = "AGATCGGAAGAGC",
        min_len       = "20",
    run:
        mkdir(os.path.dirname(output.cutout))
        shell("""{params.cutadatp_exec} --adapter {params.adapter} --minimum-length {params.min_len} --cut {params.cut} --quality-cutoff {params.qual_cutoff} --output {output.cutout} {input}""")

rule trimming_fastq:
    """sickle - A windowed adaptive trimming tool for FASTQ files using quality
        https://github.com/najoshi/sickle"""
    input:
        r1  = "{file}.1.fastq",
        r2  = "{flie}.2.fastq"
    output:
        r1  = "{file}.1.sickle_trimmed.fq.gz",
        r2  = "{file}.2.sickle_trimmed.fq.gz",
        s   = "{file}.sickle_single.fq.gz",
        log = "{file}.sickle.log"
    shell:
        """
        sickle pe -t sanger -g -f {input.r1} -r {input.r2} -o {output.r1} -p {output.r2} -s {output.s} > {output.log}
        """


###########################Untar and gzip fastq files#########################

rule untar:
    input: ["hmasm/stool/test/{}/".format(s.split("/")[-1].split(".")[0]) for s in glob("hmasm/stool/test/*.tar.bz2")]
    

rule untar_to_gz:
    input:
        "hmasm/stool/test/{base}.tar.bz2"
    output:
        dir = "hmasm/stool/test/{base}/",
    shell:
        """
        tar -I lbzip2 -xvf {input} --to-command='mkdir -p {output.dir} && pigz > {output.dir}/$(basename $TAR_FILENAME).gz'
        """



################################Download data#################################
rule hmp_stool_data:
    input: 
        dynamic("hmasm/stool/{samples}.bz2"),

rule hmp_body_download:
    input:
        md5 = "{dataset}/{bodysite}/{sample}.bz2.md5",
        url = "{dataset}/{bodysite}/{sample}.bz2.url"
    output:
        sample = "{dataset}/{bodysite}/{sample}.bz2",
    params:
        path = "{dataset}/{bodysite}/"
    run:
        with open(input.url) as fh:
            postfix = fh.read().strip()
        url = hmp_base_url.format("downloads.",postfix)
        md5 = os.path.basename(input.md5)
        shell("wget -O {output.sample} {url}; touch {output.sample}; cd {params.path} && md5sum -c {md5}")

rule hmp_body_md5:
    input:
        body = "{dataset}_{bodysite}.csv"
    output:
        md5 = dynamic("{dataset}/{bodysite}/{samples}.bz2.md5"),
        url = dynamic("{dataset}/{bodysite}/{samples}.bz2.url")
    params:
        path = "{dataset}/{bodysite}/"
    run:
        body = pd.read_csv(input.body)  
        mkdir(params.path)

        def parse_row(r,base,md5):
            f_base = params.path+os.path.basename(base)
            f_md5 = f_base + ".md5"
            f_url = f_base + ".url"
            t_md5 = "{}  {}".format(md5,os.path.basename(base))

            if os.path.isfile(f_md5):
                with open(f_md5) as fh:
                    if fh.read().strip() == t_md5.strip():
                        return

            print(t_md5,file=open(f_md5,"x"))
            print("/".join(base.split("/")[1:]),file=open(f_url,"x"))

        for i,r in body.iterrows():
            parse_row(r,r.pga_base,r.pga_md5)
            if i > 10:
                continue
            parse_row(r,r.wgs_base,r.wgs_md5)


rule hmp_body_csv:
    input:
        all = "hmasm_all.csv",
    output:
        body = "{dataset}_{bodysite}.csv",
        body_nulls = "{dataset}_{bodysite}_nulls.csv",
    run:
        all_data = pd.read_csv(input.all)
        body = all_data[all_data.body_site == wildcards.bodysite]
        
        
        nulls = body.replace({"":None}).isnull().any(axis=1)
        body[~nulls].to_csv(output.body,sep=",",index=False)
        body[nulls].to_csv(output.body_nulls,sep=",",index=False)

rule hmp_all_csv:
    output:
        all = "{dataset}_all.csv",
    run:
        hmp_json = json.loads(get(hmp_base_url.format("","/ajax/"+wildcards.dataset+".php")).text)["records"]
        all_data = pd.read_json(json.dumps(hmp_json))
        
        all_data.to_csv(output.all,sep=",",index=False)

rule clean:
    shell:
        "rm -rf hmasm*"