#!/bin/sh

AN_PATH=$HOME/tools/annovar
TABLE_IN=$1
TABLE_OUT=$2

$AN_PATH/table_annovar.pl \
  $TABLE_IN \
  $AN_PATH/humandb/ \
  -buildver hg19 \
  -out $TABLE_OUT \
  -remove \
  -protocol refGene,cytoBand,avsnp150,dbnsfp35c,revel,cadd,dann,eigen \
  -operation g,r,f,f,f,f,f,f \
  -nastring "" \
  -csvout \
  -polish 
