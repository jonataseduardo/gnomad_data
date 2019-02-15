library(data.table)
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

#input_annot <- "../gnomad_annovar/gnomad.exomes.r2.1.sites.chr22.head.hg19_multianno.csv"
#input_freqs <- "../gnomad_freqs/gnomad.exomes.r2.1.sites.chr22.head.freq.tsv"

input_freqs = args[1]
input_annot = args[2]

in_split <- unlist(strsplit(input_freqs, "/"))

file_name <- in_split[length(in_split)]
prefix <- gsub("([^.+])\\.freq\\.tsv$", "\\1", file_name)

library(data.table)

freq_dt <- fread(input_freqs)
annot_dt <- fread(input_annot)

setkeyv(annot_dt, c("Chr", "Start", "End", "Ref", "Alt"))
setkeyv(freq_dt, c("Chr", "Start", "End", "Ref", "Alt"))

system("mkdir -p ./gnomad_annotated")
p_ant <- paste0("./gnomad_annotated/", prefix, ".annotated.csv")
fwrite(freq_dt[annot_dt], p_ant)

