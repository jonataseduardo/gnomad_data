#!/usr/bin/env python3

import os

FILE_NAMES = [f[:-8] for f in os.listdir("gnomad_vcf") if f.endswith("head.vcf.bgz")]

vcf = expand("gnomad_vcf/{fn}.vcf.bgz", fn = FILE_NAMES) 
variants = expand("gnomad_variants/{fn}.varlist.tsv", fn = FILE_NAMES) 
freqs = expand("gnomad_freqs/{fn}.freq.tsv", fn = FILE_NAMES) 
annot_outprefix = expand("gnomad_annovar/{fn}", fn = FILE_NAMES) 
annot_out = expand("gnomad_annovar/{fn}.hg19_multianno.csv", fn = FILE_NAMES) 

rule creat_freq_and_snplist:
    input:
        vcf = expand("gnomad_vcf/{fn}.vcf.bgz", fn = FILE_NAMES) 
    output:
        variants,
        freqs
    shell:
        "Rscript --vanilla "
        " scripts/make_gnomad_freq_and_varlist.R"
        " {input.vcf}"

rule run_annovar:
    input:
        table_in = variants,
        table_out = annot_outprefix
    output:
        annot_out
    shell:
        "scripts/scripts/annotate_gnomad.sh "
        "{input.table_in} "
        "{input.table_out}"

        

