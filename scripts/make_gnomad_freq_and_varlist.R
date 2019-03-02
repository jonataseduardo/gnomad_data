args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} 

input_vcf = args[1]
vep_vcf = args[2]

library(VariantAnnotation)
library(data.table)

#input_vcf <- "../gnomad_vcf/gnomad.exomes.r2.1.sites.chr22.head.vcf.bgz"
#vep_vcf <- "/scratch/jonatas/vep_ancestral_alleles_vcf/homo_sapiens-chr22.vcf.gz"

in_split <- unlist(strsplit(input_vcf, "/"))

file_name <- in_split[length(in_split)]
prefix <- gsub("([^.+])\\.vcf\\.bgz$", "\\1", file_name)

gad <- expand(readVcf(input_vcf), row.names = TRUE)
vep <- expand(readVcf(vep_vcf), row.names = TRUE)

info_gad <- info(gad)
snps_gad <- rowRanges(gad)
ID_gad <- make.names(names(rowRanges(gad)), unique = TRUE)

snps_dt <- as.data.table(snps_gad)
snps_dt[, rsid := ID_gad]

annovar_order <- 
  c("seqnames",
    "start",
    "end", 
    "REF", 
    "ALT",
    "rsid", 
    "width", 
    "strand", 
    "paramRangeID", 
    "QUAL", 
    "FILTER")

setcolorder(snps_dt, annovar_order)

pop_cols <-
  grep("(nfe$)|(afr$)|(sas$)|(eas$)|(amr$)", 
       grep("^A[NCF]", names(info_gad), value = TRUE), 
       value = TRUE)
pops_gad <- as.data.table(info_gad[pop_cols])

snps_dt[, idx := .I]
pops_gad[, idx := .I]

system("mkdir -p ./gnomad_variants")
n_varlist <- paste0("./gnomad_variants/", prefix, ".varlist.tsv")
fwrite(snps_dt[, 1:5], n_varlist, sep = "\t", col.names = FALSE)

pop_freqs <- merge(snps_dt, pops_gad, by = "idx")
pop_freqs[, idx := NULL]
pop_freqs[, paramRangeID := NULL]

setnames(pop_freqs, 
        c("seqnames", "start", "end", "REF", "ALT"),
        c("Chr", "Start", "End", "Ref", "Alt")
        )

info_vep <- as.data.table(info(vep))
snps_vep <- as.data.table(rowRanges(vep))

info_vep[, idx := .I]
snps_vep[, idx := .I]
vep <- merge(snps_vep, info_vep[,.(AA, idx)], by = "idx")
vep[, c('idx', 'width', 'strand', 
        'paramRangeID', 'QUAL', 'FILTER') := NULL]

setnames(vep, 
        c("seqnames", "start", "end", "REF", "ALT"),
        c("Chr", "Start", "End", "Ref", "Alt")
        )

setkeyv(vep, c("Chr", "Start", "End", "Ref", "Alt"))
setkeyv(pop_freqs, c("Chr", "Start", "End", "Ref", "Alt"))

system("mkdir -p ./gnomad_freqs")
n_popinfo <- paste0("./gnomad_freqs/", prefix, ".freq.tsv")
fwrite(vep[pop_freqs], n_popinfo, sep = "\t", col.names = TRUE)
