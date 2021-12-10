#!/usr/bin/env Rscript

source("generate_data.R")

# generate collection of run configurations for benchmarking
main <- function() {
    args <- commandArgs(trailingOnly=TRUE)
    if(length(args) < 2) {
      stop("Usage: generate_configs.R <base dir> <config file name>")
    }

    base.dir <- args[1]
    config.file <- args[2]

    # generate data
    create.configurations(base.dir, config.file)
}

main()