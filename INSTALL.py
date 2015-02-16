#!/usr/bin/env python
from __future__ import print_function
import re
import sys
#Get Python Version
version = sys.version_info[0]
if version == 2:
	from urllib import urlopen
elif version == 3:
	from urllib.request import urlopen

miniconda_base = "http://repo.continuum.io/miniconda/"
miniconda = "Miniconda{0}-\d+\.\d+\.\d+-Linux-x86_64.sh".format('' if version == 2 else version)

r = urlopen(miniconda_base)
text = r.read().decode("utf-8")
r.close()

versions = re.findall(miniconda,text)

dl = miniconda_base + versions[-1]
print(dl,file=sys.stdout)
sys.exit(0)
