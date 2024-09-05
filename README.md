Readme
================

- [Data Sources](#data-sources)
- [Results](#results)
- [Technical Details](#technical-details)
- [Plots](#plots)
- [Replicating my results](#replicating-my-results)
- [Erratum](#erratum)

# Data Sources

I’m buying a hard drive for backups, and I want to buy a drive that’s
not going to fail. I’m going to use data from
[BackBlaze](https://www.backblaze.com/b2/hard-drive-test-data.html#downloading-the-raw-hard-drive-test-data)
to assess drive reliability. Backblaze [did their own
analysis](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/)
of drive failures, but I don’t like their approach for 2 reasons:  
1. Their “annualized failure rate” `Drive Failures / (Drive Days / 365)`
assumes that failure rates are constant over time. E.g. this assumption
means that observing 1 drive for 100 days gives you the exact same
information as observing 100 drives for 1 day. If drives fail at a
constant rate over time, this is fine, but I suspect that drives
actually fail at a higher rate early in their lives. So their analysis
is biased against newer drives.  
2. I want to compute a confidence interval of some kind, so I can select
a drive that both has a low failure rate, but also enough observations
to make me confident in this failure rate. For example, if I have a
drive that’s been observed for 1 day with 0 failures, I probably don’t
want to buy it, despite it’s zero percent failure rate. [This blog
post](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html)
has some good details on why confidence intervals are useful for sorting
things.

# Results

I chose to order the drives by their expected 5 year survival rate. I
calculated a 95% confidence interval on the 5-year survival rate, and I
used that interval to sort the drives. Based on this analysis, the wdc
wuh721816ale6l4 is the most reliable drive model in our data, with an
estimated 5-year survival rate that is at least 97.46%.

The top 25 drives from this analysis are:

| model | capacity_tb | N | drive_days | failures | years_97pct | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:---|:---|---:|---:|---:|:---|:---|:---|:---|
| wdc wuh721816ale6l4 | 16 | 26602 | 11616742 | 102 | 5.7 | 97.46% | 97.91% | 98.28% |
| wdc wuh721414ale6l4 | 14 | 8603 | 10867094 | 113 | 5.6 | 97.43% | 97.86% | 98.22% |
| wdc hms5c4040ale640 | 04 | 8716 | 18224627 | 253 | 5.4 | 97.30% | 97.61% | 97.89% |
| wdc huh721212ale600 | 12 | 2673 | 4483664 | 61 | 4.8 | 96.80% | 97.50% | 98.05% |
| wdc wuh721816ale6l0 | 16 | 3069 | 2772374 | 37 | 4.0 | 96.02% | 97.10% | 97.89% |
| wdc hds5c4040ale630 | 04 | 2837 | 4790383 | 95 | 3.8 | 95.61% | 96.40% | 97.04% |
| st6000dx000 | 06 | 1939 | 4330559 | 100 | 3.6 | 95.25% | 96.09% | 96.78% |
| wdc hds5c3030ala630 | 03 | 4664 | 6934573 | 150 | 3.5 | 95.18% | 95.88% | 96.48% |
| st16000nm001g | 16 | 34293 | 22614411 | 480 | 3.4 | 94.88% | 95.32% | 95.72% |
| toshiba mg07aca14ta | 14 | 39365 | 51123732 | 1376 | 3.1 | 94.40% | 94.69% | 94.96% |
| st12000nm001g | 12 | 13627 | 16705713 | 434 | 3.1 | 94.31% | 94.82% | 95.27% |
| wdc huh721212ale604 | 12 | 13519 | 15607978 | 392 | 3.1 | 94.28% | 94.81% | 95.30% |
| wdc huh728080ale600 | 08 | 1218 | 2609201 | 73 | 3.0 | 94.18% | 95.34% | 96.28% |
| toshiba mg08aca16tey | 16 | 5347 | 4846164 | 125 | 2.7 | 93.48% | 94.51% | 95.37% |
| st8000dm002 | 08 | 10307 | 27580788 | 1111 | 2.7 | 93.41% | 93.79% | 94.15% |
| wdc huh721212aln604 | 12 | 11422 | 20559877 | 882 | 2.3 | 92.06% | 92.55% | 93.01% |
| toshiba mg08aca16ta | 16 | 39184 | 12456523 | 361 | 2.2 | 91.88% | 92.67% | 93.39% |
| toshiba mg08aca16te | 16 | 6130 | 5737006 | 192 | 2.2 | 91.84% | 92.89% | 93.81% |
| toshiba md04aba400v | 04 | 150 | 378365 | 11 | 2.2 | 91.74% | 95.32% | 97.39% |
| st14000nm001g | 14 | 11177 | 13299198 | 504 | 2.2 | 91.68% | 92.36% | 92.98% |
| st8000nm0055 | 08 | 15680 | 36632508 | 1893 | 2.1 | 91.46% | 91.84% | 92.20% |
| st16000nm002j | 16 | 468 | 259866 | 4 | 2.0 | 90.91% | 96.45% | 98.66% |
| wdc hds722020ala330 | 02 | 4774 | 5675646 | 235 | 1.9 | 90.53% | 91.62% | 92.60% |
| st12000nm0008 | 12 | 20955 | 31032423 | 1615 | 1.8 | 89.96% | 90.42% | 90.87% |
| wdc wuh722222ale6l4 | 22 | 13244 | 1279877 | 42 | 1.8 | 89.85% | 92.40% | 94.36% |

- **model** is the drive model
- **capacity_tb** is the size of the drive
- **N** is the number of unique drives in the analysis
- **drive_days** is the total number of days that we’ve observed for
  drives of this model in the sample
- **failures** is the number of failures observed so far
- **years_97pct** is the expected number of years 97% of these drives
  will last
- **surv_5yr_lo** is the lower bound of the 95% confidence interval of
  the 5-year survival rate
- **surv_5yr** is the 5-year survival rate
- **surv_5yr_hi** is the upper bound of the 95% confidence interval of
  the 5-year survival rate

| model | capacity_tb | N | drive_days | failures | years_97pct | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:---|:---|---:|---:|---:|:---|:---|:---|:---|
| wdc wuh721816ale6l4 | 16 | 26602 | 11616742 | 102 | 5.7 | 97.46% | 97.91% | 98.28% |
| wdc wuh721414ale6l4 | 14 | 8603 | 10867094 | 113 | 5.6 | 97.43% | 97.86% | 98.22% |
| wdc hms5c4040ale640 | 04 | 8716 | 18224627 | 253 | 5.4 | 97.30% | 97.61% | 97.89% |
| wdc huh721212ale600 | 12 | 2673 | 4483664 | 61 | 4.8 | 96.80% | 97.50% | 98.05% |
| st6000dx000 | 06 | 1939 | 4330559 | 100 | 3.6 | 95.25% | 96.09% | 96.78% |
| wdc hds5c3030ala630 | 03 | 4664 | 6934573 | 150 | 3.5 | 95.18% | 95.88% | 96.48% |
| wdc huh728080ale600 | 08 | 1218 | 2609201 | 73 | 3.0 | 94.18% | 95.34% | 96.28% |
| wdc hds722020ala330 | 02 | 4774 | 5675646 | 235 | 1.9 | 90.53% | 91.62% | 92.60% |
| wdc wuh722222ale6l4 | 22 | 13244 | 1279877 | 42 | 1.8 | 89.85% | 92.40% | 94.36% |
| st10000nm0086 | 10 | 1304 | 2924650 | 202 | 1.5 | 87.58% | 89.09% | 90.44% |

All of these drives have a very high 5-year survival rate, and I’d feel
pretty confident buying any of them.

# Technical Details

Survival analysis is a little weird, because you don’t observe the full
distribution of your data. This makes some traditional statistics
impossible to calculate. For example, until you observe every hard drive
in the sample fail, you can’t know the mean time to failure. (If you
have one drive left that hasn’t failed yet, and becomes an outlier in
survival time, that might have a big impact on mean survival time.)

Here’s the thing: these drives are **so reliable**, that even after 5+
years of observation, we’ve barely observed the distribution of
failures! (This is a good thing, but it makes it hard to chose between
drives!).

I fit a [Cox Proportional Hazard
model](https://en.wikipedia.org/wiki/Proportional_hazards_model) to this
data, which enabled me to estimate 5 years survival rates for all of the
drives, as well as a confidence interval on that rate. The confidence
interval narrows as you observe more drives and as you observe those
drives for a longer time.

The Cox model is semi-parametric. It assumes a non-parametric, baseline
hazard rate that is the same for all drives. It then fits a single
parameter for each drive that is a multiple on that baseline hazard
rate. So every drive has the same “shape” for its survival curve, but
multiplied by a fixed coefficient per model that makes that “shape”
steeper or shallower.

# Plots

Here is a plot of the survival for each of the best drive models. Each
curve ends with the oldest drive we’ve observed (these are called
[Kaplan–Meier](https://en.wikipedia.org/wiki/Kaplan%E2%80%93Meier_estimator)
curves):

<img src="README_files/figure-gfm/km_curves-1.png" width="4200" />

The “proportional hazards” assumption from the Cox model allows us to
extend these curves and estimate survival times at 5 years for all of
the drives:

<img src="README_files/figure-gfm/cox_curves-1.png" width="4200" />

This plot doesn’t have the confidence intervals, which are wider for the
drives with less data.

# Replicating my results

[drive_dates.csv](results/drive_dates.csv) has the cleaned up data from
backblaze, with each drive, its model, when it was installed, when it
failed (NA for drives that have not failed) and when it was last
observed.

[README.Rmd](README.Rmd) has the code to run this analysis and generate
this [README.md](README.md) file you are reading right now. Use
[RStudio](https://rstudio.com/products/rstudio/download/) to `knit` the
`Rmd` file into a `md` file, which github will then render nicely for
you.

If you want to get the raw data before it was cleaned up into
[all_data.csv](results/all_data.csv), you’ll need at least 70GB of free
hard drive space. I also suggest opening
[backblaze_analysis.Rproj](backblaze_analysis.Rproj) in RStudio.  
1. Run [1_download_data.R](code/1_download_data.R) to download the data
(almost 10.5 GB).  
2. Run [2_unzip_data.R](code/2_unzip_data.R) to unzip the data (almost
55 GB).  
3. Run [3_assemble_data.R](code/3_assemble_data.R) to “compress” the
data, which generates [all_data.csv](all_data.csv).  
4. Run [4_survival_analysis.R](code/4_survival_analysis.R) to calculate
5 year survival.

An interesting note about this data: It’s 55GB uncompressed, and
contains a whole bunch of irrelevant information. It was very
interesting to me that I could compress a 55GB dataset to NA Mb, while
still keeping **all** of the relevant information for modeling. (In
other words, this dataset was 4,000x larger than it needed to be). I
think this is another example of how good data structures are essential
for data science is.

# Erratum

I’m probably way over-thinking this, but it was fun to analyze the data.
Any of the top 25 drives are likely safe to buy, and are very unlikely
to fail.

There are some drives in this data I plan to avoid. For example, the
st3000dm001 has a 5 year survival of 18.9%. This is honestly probably
fine for my purposes, but maybe I’d be a little nervous to buy a drive
with a 1-in-1 chance of dying within 5 years.

<figure>
<img src="https://imgs.xkcd.com/comics/nerd_sniping.png"
alt="I nerd sniped myself" />
<figcaption aria-hidden="true">I nerd sniped myself</figcaption>
</figure>
