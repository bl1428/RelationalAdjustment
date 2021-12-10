# Fork of Relational Causal Adjustment for Benchmarking

Original work by:
Arbour, D., Garant, D., & Jensen, D. (2016). Inferring Network Effects from Observational Data. In Proceedings of the 22nd ACM SIGKDD international conference on Knowledge discovery and data mining. ACM.

This repository is a modification to the implementation of Arbour et al. for the purposes of benchmark comparison against other methods for causal effect estimation under network interference.

## How to Use
Using RScript:

1. Run `generate_configs.R` to produce a CSV file containing experimental configurations
1. Run `generate_benchmark_dataset.R` to produce an assortment of dataset files for use in benchmarking experiments
1. Run `run_instance.R` to run experiments according to the provided experimental configuration(s), using the provided dataset

Attempting to run these files without supplying the required command line parameters will display a help message outlining the required parameters.