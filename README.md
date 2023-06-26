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
actually fail at a higher rate early in their lives.  
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
wuh721816ale6l0 is the most reliable drive model in our data, with an
estimated 5-year survival rate that is at least 99.71%.

The top 25 drives from this analysis are:

| model                   | size  |     N | drive_days | failures | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:------------------------|:------|------:|-----------:|---------:|:------------|:---------|:------------|
| wdc wuh721816ale6l0     | 16 TB |  2705 |    1448470 |        6 | 99.71%      | 99.87%   | 99.94%      |
| wdc wuh721414ale6l4     | 14 TB |  8468 |    7002255 |       56 | 99.70%      | 99.77%   | 99.82%      |
| hgst huh721212ale600    | 12 TB |  2636 |    3292866 |       27 | 99.67%      | 99.77%   | 99.85%      |
| wdc wuh721816ale6l4     | 16 TB | 14117 |    2500419 |       19 | 99.59%      | 99.74%   | 99.83%      |
| hgst hms5c4040ale640    | 4 TB  |  8723 |   17134325 |      247 | 99.57%      | 99.62%   | 99.67%      |
| hgst huh721212ale604    | 12 TB | 13287 |    9585261 |      131 | 99.52%      | 99.60%   | 99.66%      |
| hgst huh721212aln604    | 12 TB | 11006 |   15741965 |      291 | 99.44%      | 99.50%   | 99.56%      |
| hitachi hds5c4040ale630 | 4 TB  |  2719 |    4642205 |       89 | 99.37%      | 99.49%   | 99.59%      |
| toshiba mg08aca16tey    | 16 TB |  5335 |    2444992 |       36 | 99.36%      | 99.54%   | 99.67%      |
| hitachi hds5c3030ala630 | 3 TB  |  4664 |    6934573 |      150 | 99.32%      | 99.42%   | 99.51%      |
| st12000nm001g           | 12 TB | 13040 |   10722329 |      226 | 99.31%      | 99.39%   | 99.47%      |
| st6000dx000             | 6 TB  |  1939 |    3987495 |       97 | 99.24%      | 99.38%   | 99.49%      |
| toshiba mg07aca14ta     | 14 TB | 39096 |   33737764 |      858 | 99.22%      | 99.27%   | 99.32%      |
| hgst huh728080ale600    | 8 TB  |  1209 |    2102738 |       47 | 99.20%      | 99.40%   | 99.55%      |
| st16000nm001g           | 16 TB | 22206 |    9699369 |      223 | 99.16%      | 99.26%   | 99.35%      |
| st8000dm002             | 8 TB  | 10300 |   23335336 |      820 | 99.01%      | 99.08%   | 99.15%      |
| toshiba mg08aca16ta     | 16 TB |  5215 |    1087766 |       20 | 99.00%      | 99.35%   | 99.58%      |
| st14000nm001g           | 14 TB | 11021 |    8388898 |      260 | 98.98%      | 99.10%   | 99.21%      |
| st8000nm0055            | 8 TB  | 15678 |   30251397 |     1308 | 98.78%      | 98.86%   | 98.93%      |
| st12000nm0008           | 12 TB | 20674 |   22115130 |      898 | 98.78%      | 98.87%   | 98.94%      |
| hitachi hds722020ala330 | 2 TB  |  4774 |    5675646 |      235 | 98.69%      | 98.85%   | 98.99%      |
| toshiba mg08aca16te     | 16 TB |  6042 |    3022140 |      110 | 98.58%      | 98.82%   | 99.02%      |
| st10000nm0086           | 10 TB |  1304 |    2419470 |      120 | 98.42%      | 98.68%   | 98.90%      |
| st12000nm0007           | 12 TB | 38838 |   36400069 |     2040 | 98.34%      | 98.42%   | 98.49%      |
| st4000dm000             | 4 TB  | 37039 |   75716460 |     5260 | 98.15%      | 98.23%   | 98.31%      |

- **model** is the drive model
- **size** is the size of the drive
- **N** is the number of unique drives in the analysis
- **drive_days** is the total number of days that we’ve observed for
  drives of this model in the sample
- **failures** is the number of failures observed so far
- **surv_5yr_lo** is the lower bound of the 95% confidence interval of
  the 5-year survival rate
- **surv_5yr** is the 5-year survival rate
- **surv_5yr_hi** is the upper bound of the 95% confidence interval of
  the 5-year survival rate

To narrow down the data, we can just look at the best drive by size
(excluding models that have fewer than 1200):

| model                   | size  |    N | drive_days | failures | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:------------------------|:------|-----:|-----------:|---------:|:------------|:---------|:------------|
| wdc wuh721816ale6l0     | 16 TB | 2705 |    1448470 |        6 | 99.71%      | 99.87%   | 99.94%      |
| wdc wuh721414ale6l4     | 14 TB | 8468 |    7002255 |       56 | 99.70%      | 99.77%   | 99.82%      |
| hgst huh721212ale600    | 12 TB | 2636 |    3292866 |       27 | 99.67%      | 99.77%   | 99.85%      |
| hgst hms5c4040ale640    | 4 TB  | 8723 |   17134325 |      247 | 99.57%      | 99.62%   | 99.67%      |
| hitachi hds5c3030ala630 | 3 TB  | 4664 |    6934573 |      150 | 99.32%      | 99.42%   | 99.51%      |
| st6000dx000             | 6 TB  | 1939 |    3987495 |       97 | 99.24%      | 99.38%   | 99.49%      |
| hgst huh728080ale600    | 8 TB  | 1209 |    2102738 |       47 | 99.20%      | 99.40%   | 99.55%      |
| hitachi hds722020ala330 | 2 TB  | 4774 |    5675646 |      235 | 98.69%      | 98.85%   | 98.99%      |
| st10000nm0086           | 10 TB | 1304 |    2419470 |      120 | 98.42%      | 98.68%   | 98.90%      |

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

![](README_files/figure-gfm/km_curves-1.png)<!-- -->

Note that we haven’t even observed 1 year’s worth of data yet for the 14
and 16TB drives, but they seem to have a very low failure rate relative
to the other drives during their first year of life.

The “proportional hazards” assumption from the Cox model allows us to
extend these curves and estimate survival times at 5 years for all of
the drives:

![](README_files/figure-gfm/cox_curves-1.png)<!-- -->

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
st3000dm001 has a 5 year survival of 80.4%. This is honestly probably
fine for my purposes, but maybe I’d be a little nervous to buy a drive
with a 1-in-5 chance of dying within 5 years.

<figure>
<img src="https://imgs.xkcd.com/comics/nerd_sniping.png"
alt="I nerd sniped myself" />
<figcaption aria-hidden="true">I nerd sniped myself</figcaption>
</figure>
