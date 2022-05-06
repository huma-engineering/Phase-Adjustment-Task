# Phase-Adjustment-Task

An Open Source release from Huma Therapeutics labs, which lets you measure interoception (awareness of body signal) from a research participant, using the camera on an iphone to capture heartbeats and, interactively with the user, ascertain how accurately they perceive them.

# Data Analysis
How to use the PAT analysis script:
Ensure collected PAT data .json is in the same folder as the .Rmd analysis script. Ensure that:
data <- rjson::fromJSON(file =”YOUR_PAT_DATA.json”
In the second code chunk points to your PAT data .json file.
Then you can run the entire script, or use rMarkdown to knit the file to an HTML or PDF report.
If you want to ensure that a certain number of trials are required and used, change the n_needed_trials value to your desired number of trials (default 16, max 20). If changing this value, you will also need to change the number of selected values from the random distribution on line 295 in this bit of code (default is 16 to match the number of required trials):
similarities_random20 <- purrr::map_dbl(1:max_iter, function(i) {
  n <- 16
  periods <- runif(n, 0.5, 1.5)
  delays <- purrr::map_dbl(periods, function(p) runif(1, 0, p))
  calc_similarity(delays, periods)
})
