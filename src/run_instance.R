#!/usr/bin/env Rscript

source("3-net.R")
source("estimators.R")
source("generate_data.R")

main <- function() {
    args <- commandArgs(trailingOnly=TRUE)
    if(length(args) < 5) {
      stop("Usage: run_instance.R <config ID> <all config file> <output file> <data file name> <number of trials>")
    }

    config_id <- as.numeric(args[1])
    config_file <- args[2]
    output_file <- args[3]
    data_file <- args[4]
    num_trials <- as.numeric(args[5])

    for(trial in 1:num_trials) {
      cat(paste0("Running instance ", config_id, " trial ", trial, " from configuration file  ", config_file, "\n"))
      cat(paste0("Output file: ", output_file, "\n"))

      estimates <- run.one(config_file, config_id, data_file, trial)

      # synchronize access to the results file
      system(paste0("lockfile results.lock"))
      append <- FALSE
      if(file.exists(output_file) && file.info(output_file)$size > 0) {
        append <- TRUE
      }
      write.table(estimates, output_file, append=append, col.names=!append, row.names=FALSE, sep=",")
      file.remove("results.lock")
    }
}

run.one <- function(config_file, config_id, data_file, trial) {
  # read config & data
  configs <- read.csv(config_file)
  config <- configs[config_id, ]
  # random.seed <- config$random.seed * trial
  # gendata <- generate.by.index(configs, config_id, random.seed=random.seed, noise.sd=1)
  # gendata %>% save(file = 'gendata.RData')
  gendata <- miceadds::load.Rdata2(filename = data_file)
  
  # estimate effects
  methods <- list("Actual"=function(junk1, junk2) gendata$outcome.function, 
                      "Obs-GBM-Sufficient"=obs.gbm.sufficient)
  
  estimates <- data.frame(method=names(methods), config=config_id, trial=trial)
  # fit each of the models
  outcome.funcs <- alply(names(methods), 1, function(name) {
      cat("Fitting ", name, "\n")
      return(methods[[name]](gendata$adj.mat, gendata$data))
  })
  names(outcome.funcs) <- names(methods)

  cat("Getting estimates\n")
  # sweep across friend configurations if the design calls for it
    hyp.friends.values <- seq(0, 1, length.out=11)
    for(hyp.friends in hyp.friends.values) {
      est.outcomes <- aaply(names(methods), 1, function(name) {
          return(outcome.funcs[[name]](friendt=hyp.friends))
      })
      estimates[, paste0("mf_", hyp.friends)] <- est.outcomes
    }
      
    estimates$mt_0 <- aaply(names(methods), 1, function(name) outcome.funcs[[name]](myt=0))
    estimates$mt_1 <- aaply(names(methods), 1, function(name) outcome.funcs[[name]](myt=1))

  estimates$global_treatment <- aaply(names(methods), 1, function(name) outcome.funcs[[name]](myt=1, friendt=1))
  estimates$global_control <- aaply(names(methods), 1, function(name) outcome.funcs[[name]](myt=0, friendt=0))
  
  return(estimates)
}

main()
