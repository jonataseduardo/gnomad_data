#!/usr/bin/env python3

import os

FILE_NAMES = [f[:-8] for f in os.listdir("gnomad_vcf") if f.endswith(".vcf.bgz")]

freq_annot = expand("gnomad_annotated/{fn}.annotated.csv", fn = FILE_NAMES)

rule all:
    input:
        freq_annot

rule merge_freq_annotations:
    input:
        freq_in="gnomad_freqs/{fn}.{chr}.freq.tsv",
        anno_in="gnomad_annovar/{fn}.{chr}.hg19_multianno.csv"
    output:
        "gnomad_annotated/{fn}.{chr}.annotated.csv"
    shell:
        "Rscript --vanilla "
        " scripts/merge_freq_and_annotatios.R"
        " {input.freq_in}"
        " {input.anno_in}"

rule run_annovar:
    input:
        "gnomad_variants/{fn}.{chr}.varlist.tsv"
    output:
        "gnomad_annovar/{fn}.{chr}.hg19_multianno.csv"
    shell:
        "scripts/annotate_gnomad.sh"
        " {input}"
        " gnomad_annovar/{wildcards.fn}.{wildcards.chr}"

rule creat_freq_and_snplist:
    input:
        gad = "gnomad_vcf/{fn}.{chr}.vcf.bgz",
        vep = "vep_data/homo_sapiens-{chr}.vcf.gz"
    output:
        "gnomad_variants/{fn}.{chr}.varlist.tsv",
        "gnomad_freqs/{fn}.{chr}.freq.tsv"
    shell:
        "Rscript --vanilla "
        " scripts/make_gnomad_freq_and_varlist.R"
        " {input.gad}"
        " {input.vep}"

