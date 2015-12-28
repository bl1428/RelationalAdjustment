
function ht(exposure, outcome, exposure_probs)
    # Given a pool of N subjects, calculates the mean and variance 
    # of outcome under each of a number of exposure conditions
    # Arguments:
    #   exposure -- Length N array, representing realized exposure status for each subject
    #   outcome -- Length N array, representing realized outcome for each subject
    #   exposure_probs -- A dictionary keyed by exposure status.  Each entry is an NxN matrix with off-diagonal entries (i, j) 
    #                       representing the probability that i and j both experience the exposure specified by the key. 
    #                       Diagonal entries (i, i) represent the probability that subject i experiences the given exposure condition.

    n_subjects = size(exposure, 1)
    subject_ids = 1:n_subjects
    unique_exposures = unique(exposure)

    exposure_outcomes = Dict()
    exposure_variances = Dict()
    for(cur_exposure in unique_exposures)
        eprobs = exposure_probs[cur_exposure]

        # find subjects in this exposure condition and 
        # count all subjects that have non-zero probability
        subjects = filter(s-> exposure[s] == cur_exposure, subject_ids)
        subject_eprobs = Real[eprobs[i, i] for i = subjects]
        subject_outcomes = Real[outcome[i] for i = subjects]
        n_cur_subjects = size(subjects, 1)
        n_valid_subjects = sum(diag(eprobs) .> 0)

        exposure_outcomes[cur_exposure] = 1/n_valid_subjects * sum(filter(v -> isfinite(v), subject_outcomes ./ subject_eprobs))

        pairwise_probs = zeros(n_cur_subjects, n_cur_subjects)
        for(i in 1:n_cur_subjects)
            for(j in 1:n_cur_subjects)
                if i != j
                    pairwise_probs[i, j] = eprobs[subjects[i], subjects[j]]
                end
            end
        end

        corr_comp = ((pairwise_probs - subject_eprobs * subject_eprobs') ./ pairwise_probs) .* ((subject_outcomes ./ subject_eprobs) * (subject_outcomes ./ subject_eprobs)')
        corr_comp[diagind(corr_comp)] = 0

        exposure_variances[cur_exposure] = 1/(n_valid_subjects^2) .* (sum((1 - subject_eprobs) .* (subject_outcomes ./ subject_eprobs) .^ 2) + sum(corr_comp .* isfinite(corr_comp)))

        # need to correct the variance if there are zero-valued off-diagonal pairwise probabilities
        (rows, cols, probs) = findnz((pairwise_probs + eye(n_cur_subjects)) .== 0)
        bias_correction = 0
        for(i in 1:size(rows, 1))
            row = rows[i]
            col = cols[i]
            bias_correction += (exposure[row] == cur_exposure)*outcome[row]^2/(2 * eprobs[row,row]) + (exposure[col] == cur_exposure) * outcome[col]^2 / (2 * eprobs[col, col])
        end
        exposure_variances[cur_exposure] = exposure_variances[cur_exposure] + bias_correction

    end
    
    return(exposure_outcomes, exposure_variances)
end



