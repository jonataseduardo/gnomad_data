#!/usr/bin/env bash

url_p="https://storage.googleapis.com/gnomad-public/release/2.1/vcf/exomes/gnomad.exomes.r2.1.sites.chr"

for chr in {1..22} 
do
   echo "fetching chr$chr"
   curl $url_p$chr.vcf.bgz -O -s &
   curl $url_p$chr.vcf.bgz.tbi -O -s &
done
wait
