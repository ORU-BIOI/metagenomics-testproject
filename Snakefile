localrules: all, hmp_all_csv, hmp_body_csv, hmp_body_assembly_md5
import os
import json
import pandas as pd
from requests import get

hmp_base_url = "http://{}hmpdacc.org/{}"

def mkdir(path_to_dir):
    """Create a directory if it does not exist, otherwise do nothing"""
    if not os.path.isdir(path_to_dir):
        os.makedirs(path_to_dir)

rule hmp_stool_reads_data:
    input: 
        dynamic("hmasm/stool/{samples}.tar.bz2"),

rule hmp_stool_assembly_data:
    input: 
        dynamic("hmasm/stool/{samples}.f.?a.bz2"),

rule hmp_body_download:
    input:
        md5 = "{dataset}/{bodysite}/{sample}.bz2.md5",
        url = "{dataset}/{bodysite}/{sample}.bz2.url"
    output:
        sample = protected("{dataset}/{bodysite}/{sample}.bz2"),
    params:
        path = "{dataset}/{bodysite}/"
    run:
        with open(input.url) as fh:
            postfix = fh.read().strip()
        url = hmp_base_url.format("downloads.",postfix)
        md5 = os.path.basename(input.md5)
        shell("wget -O {output.sample} {url}; touch {output.sample}; cd {params.path} && md5sum -c {md5}")

rule hmp_body_reads_md5:
    input:
        body = "{dataset}_{bodysite}.csv"
    output:
        md5 = dynamic("{dataset}/{bodysite}/{samples}.bz2.md5"),
        url = dynamic(temp("{dataset}/{bodysite}/{samples}.bz2.url"))
    params:
        path = "{dataset}/{bodysite}/"
    run:
        body = pd.read_csv(input.body).iloc[:10,:]
        mkdir(params.path)
        for i,r in body.iterrows():
            filename = params.path+os.path.basename(r.wgs_base)
            f_md5 = filename + ".md5"
            f_url = filename + ".url"
            t_md5 = "{}  {}".format(r.wgs_md5,os.path.basename(filename))

            if os.path.isfile(f_md5):
                with open(f_md5) as fh:
                    if fh.read().strip() == t_md5.strip():
                        continue

            print(t_md5,file=open(f_md5,"x"))
            print("/".join(r.wga_base.split("/")[1:]),file=open(f_url,"x"))

rule hmp_body_assembly_md5:
    input:
        body = "{dataset}_{bodysite}.csv"
    output:
        md5 = dynamic("{dataset}/{bodysite}/{samples}.bz2.md5"),
        url = dynamic(temp("{dataset}/{bodysite}/{samples}.bz2.url"))
    params:
        path = "{dataset}/{bodysite}/"
    run:
        body = pd.read_csv(input.body)  
        mkdir(params.path)
        for i,r in body.iterrows():
            filename = params.path+os.path.basename(r.pga_base)
            f_md5 = filename + ".md5"
            f_url = filename + ".url"
            t_md5 = "{}  {}".format(r.pga_md5,os.path.basename(filename))

            if os.path.isfile(f_md5):
                with open(f_md5) as fh:
                    if fh.read().strip() == t_md5.strip():
                        continue

            print(t_md5,file=open(f_md5,"x"))
            print("/".join(r.pga_base.split("/")[1:]),file=open(f_url,"x"))

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

