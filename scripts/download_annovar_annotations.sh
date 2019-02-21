#!/bin/sh

AN_PATH=$HOME/tools/annovar

for annot in ensGene dbnsfp35c avsnp150 revel eigen cadd dann 
  do
  $AN_PATH/annotate_variation.pl \
    -buildver hg19 \
    -downdb -webfrom annovar $annot $AN_PATH/humandb/
  done

$AN_PATH/annotate_variation.pl -buildver hg19 -downdb cytoBand $AN_PATH/humandb/
