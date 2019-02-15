#!/usr/bin/env python3

import os

FILE_NAMES = [f[:-8] for f in os.listdir("gnomad_vcf") if f.endswith("head.vcf.bgz")]

freq_annot = expand("gnomad_annotated/{fn}.annotated.csv", fn = FILE_NAMES)


rule all:
    input:
        freq_annot

rule merge_freq_annotations:
    input:
        freq_in="gnomad_freqs/{fn}.freq.tsv",
        anno_in="gnomad_annovar/{fn}.hg19_multianno.csv"
    output:
        "gnomad_annotated/{fn}.annotated.csv"
    shell:
        "Rscript --vanilla "
        " scripts/merge_freq_and_annotatios.R"
        " {input.freq_in}"
        " {input.anno_in}"

rule run_annovar:
    input:
        "gnomad_variants/{fn}.varlist.tsv"
    output:
        "gnomad_annovar/{fn}.hg19_multianno.csv"
    shell:
        "scripts/annotate_gnomad.sh"
        " {input}"
        " gnomad_annovar/{wildcards.fn}"

rule creat_freq_and_snplist:
    input:
        "gnomad_vcf/{fn}.vcf.bgz"
    output:
        "gnomad_variants/{fn}.varlist.tsv",
        "gnomad_freqs/{fn}.freq.tsv"
    shell:
        "Rscript --vanilla "
        " scripts/make_gnomad_freq_and_varlist.R"
        " {input}"


