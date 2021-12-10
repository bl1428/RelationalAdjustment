#!/usr/bin/env Rscript

source("generate_data.R")

# Generate a set of benchmark data for comparison with other estimation methods.
main <- function() {
    args <- commandArgs(trailingOnly=TRUE)
    if(length(args) < 2) {
      stop("Usage: generate_benchmark_dataset.R <config ID> <config file path>")
    }

    config_id <- as.numeric(args[1])
    config_file <- args[2]

    # generate data
    configs <- read.csv(config_file)
    config <- configs[config_id, ]
    random.seed <- config$random.seed
    gendata <- generate.by.index(configs, config_id, random.seed=random.seed, noise.sd=1)
    gendata %>% save(file = 'gendata.RData')
}

main()