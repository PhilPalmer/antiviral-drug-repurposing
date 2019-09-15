#!/usr/bin/env Rscript
###################################
# Converts input CSV of genes to top over and under expressed genes (for clue.io)
# Requires:
# input CSV eg `diffexpr-results.csv` containing columns `Gene`, `log2FoldChange` & `padj`
###################################

library(tidyverse)
library(biomaRt)

# define helper functions
ensembl_to_hgnc <- function(genes_list) {
  getBM(attributes='hgnc_symbol', 
        filters = 'ensembl_gene_id', 
        values = genes_list, 
        mart = ensembl)
}
# load the top genes from the differential expresion analysis
args = commandArgs(trailingOnly=TRUE)
genes <- read.csv(args[1],
                  header           = TRUE, 
                  stringsAsFactors = FALSE, 
                  check.names      = FALSE,
                  row.names        = 1)
genes <- as_tibble(genes)

# filter based on adjusted p-value
top_genes <- top_n(genes, 150, padj)

# save top over & underexpressed genes
over <- top_genes[(top_genes$log2FoldChange>0),]
under <- top_genes[(top_genes$log2FoldChange<0),]

# keep just the gene names
over <- over$Gene
under <- under$Gene

# convert ensembl gene ids to hgnc
ensembl = useMart("ensembl",dataset="hsapiens_gene_ensembl")
over <- ensembl_to_hgnc(over)
under <- ensembl_to_hgnc(under)

# save to files
write.table(over, "over_expressed.txt", quote = FALSE, sep = "\n", row.names = FALSE)
write.table(under, "under_expressed.txt", quote = FALSE, sep = "\n", row.names = FALSE)