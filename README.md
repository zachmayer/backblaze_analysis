Readme
================

- [Data Sources](#data-sources)
- [Results](#results)
- [Technical Details](#technical-details)
- [Plots](#plots)
- [Cost effectiveness](#cost-effectiveness)
- [Full Data](#full-data)
- [Replicating my results](#replicating-my-results)
- [Erratum](#erratum)

# Data Sources

I’m buying a hard drive for backups, and I want to buy a drive that’s
not going to fail. I’m going to use data from
[BackBlaze](https://www.backblaze.com/b2/hard-drive-test-data.html#downloading-the-raw-hard-drive-test-data)
to assess drive reliability. Backblaze [did their own
analysis](https://www.backblaze.com/blog/backblaze-drive-stats-for-q2-2024/)
of drive failures, but I don’t like their approach for 2 reasons:

1.  Their “annualized failure rate”
    `Drive Failures / (Drive Days / 365)` assumes that failure rates are
    constant over time. E.g. this assumption means that observing 1
    drive for 100 days gives you the exact same information as observing
    100 drives for 1 day. If drives fail at a constant rate over time,
    this is fine, but I suspect that drives actually fail at a higher
    rate early in their lives. So their analysis is biased against newer
    drives.  
2.  I want to compute a confidence interval, so I can select a drive
    where we have enough observations to be very confident in a low
    failure rate. For example, if I have a model drive that’s been
    observed for one drive for 1 day with 0 failures, I probably don’t
    want to buy it, despite it’s zero percent failure rate. I’d rather
    buy a drive model thats been observed for 100 drives for 1000 days
    with one failure. [This blog
    post](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html)
    has some good details on why confidence intervals are useful for
    sorting things.

# Results

I chose to order the drives by their expected 5 year survival rate. I
calculated a 95% confidence interval on the 5-year survival rate, and I
used that interval to sort the drives. Based on this analysis, the wdc
wuh721816ale6l4 is the most reliable drive model in our data, with an
estimated 5-year survival rate that is at least 97.46%. (In other words
we are 95% confident that the wdc wuh721816ale6l4 will last at least
97.46% years).

Here are the top drives from this analysis, by size. (for example, many
manufacturers have drives in the 16TB range that are very reliable, but
I’m only showing the single best model in this size range).

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
| st18000nm000j | 18 | 70 | 82370 | 10 | 0.5 | 63.65% | 77.91% | 87.67% |

Data details:

- **model** is the drive model.  
- **capacity_tb** is the size of the drive.  
- **N** is the number of unique drives in the analysis.  
- **drive_days** is the total number of days that we’ve observed for
  drives of this model in the sample.  
- **failures** is the number of failures observed so far.  
- **years_97pct** Is the 97th percentile survival time for the drives.
  97% of the drives will last at least this long.  
- **surv_5yr_lo** is the lower bound of the 95% confidence interval of
  the 5-year survival rate.  
- **surv_5yr** is the 5-year survival rate.  
- **surv_5yr_hi** is the upper bound of the 95% confidence interval of
  the 5-year survival rate.

# Technical Details

Survival analysis is a little weird, because you don’t observe the full
distribution of the data. This makes some traditional statistics
impossible to calculate. For example, until you observe every hard drive
in the sample fail, you can’t know the mean time to failure: if you have
one drive left that hasn’t failed, and becomes an outlier in survival
time, that might have a big impact on mean survival time. To find the
median survival time, you need to wait for half of the drives in your
sample fail, which can take a decade or more!

Modern hard drives are **so reliable**, that even after 5+ years of
observation, we’ve barely observed the distribution of failures! (This
is a good thing, but it makes it hard to chose between drives!).

To compare models with different observational periods (e.g. 22 TB vs
4TB drives), I fit a [Cox Proportional Hazard
model](https://en.wikipedia.org/wiki/Proportional_hazards_model). This
enabled me to estimate 5 years survival rates for all of the drives, as
well as a confidence interval on that rate. The confidence interval
narrows as you observe more drives and as you observe those drives for a
longer time.

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

Note that the curves all have the same shape, but each model has a
different slope. Compare this plot to the Kaplan-Meier plot above: The
proportional hazards assumption works pretty well, but isn’t perfect.

# Cost effectiveness

I manually gatherted some [hard drive prices](prices.csv) from ebay and
amazon. I limited this search to drives with \>70% expected 5 years
survival, as I want to buy drives that are unlikely to fail on me. I can
then use the price data to calculate the cost to store 1TB of data for 5
years for each drive. Note that these prices could be wrong, and also
not that only one drive may be available at the given price.

According to this analysis, the most cost effective drive is the
st14000nm001g, which costs 119.99 and has a 5 year survival rate of
9168.1%. This drive costs \$8.57 per TB, and \$9.35 to store 1 TB for 5
years.

Again, the price data is probably incorrect, but its still an
interesting analysis.

# Full Data

Here are the full results for all drives. (I excluded drives that are
less than 2TB).

| model | capacity_tb | N | drive_days | failures | years_97pct | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:---|:---|---:|---:|---:|:---|:---|:---|:---|
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 26602 | 11616742 | 102 | 5.7 | 97.46% | 97.91% | 98.28% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 8603 | 10867094 | 113 | 5.6 | 97.43% | 97.86% | 98.22% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 8716 | 18224627 | 253 | 5.4 | 97.30% | 97.61% | 97.89% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 2673 | 4483664 | 61 | 4.8 | 96.80% | 97.50% | 98.05% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 3069 | 2772374 | 37 | 4.0 | 96.02% | 97.10% | 97.89% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 2837 | 4790383 | 95 | 3.8 | 95.61% | 96.40% | 97.04% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 06 | 1939 | 4330559 | 100 | 3.6 | 95.25% | 96.09% | 96.78% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 4664 | 6934573 | 150 | 3.5 | 95.18% | 95.88% | 96.48% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 34293 | 22614411 | 480 | 3.4 | 94.88% | 95.32% | 95.72% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 39365 | 51123732 | 1376 | 3.1 | 94.40% | 94.69% | 94.96% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 13627 | 16705713 | 434 | 3.1 | 94.31% | 94.82% | 95.27% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 13519 | 15607978 | 392 | 3.1 | 94.28% | 94.81% | 95.30% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 1218 | 2609201 | 73 | 3.0 | 94.18% | 95.34% | 96.28% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 5347 | 4846164 | 125 | 2.7 | 93.48% | 94.51% | 95.37% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 10307 | 27580788 | 1111 | 2.7 | 93.41% | 93.79% | 94.15% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 11422 | 20559877 | 882 | 2.3 | 92.06% | 92.55% | 93.01% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 39184 | 12456523 | 361 | 2.2 | 91.88% | 92.67% | 93.39% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 6130 | 5737006 | 192 | 2.2 | 91.84% | 92.89% | 93.81% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 150 | 378365 | 11 | 2.2 | 91.74% | 95.32% | 97.39% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 11177 | 13299198 | 504 | 2.2 | 91.68% | 92.36% | 92.98% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 15680 | 36632508 | 1893 | 2.1 | 91.46% | 91.84% | 92.20% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 468 | 259866 | 4 | 2.0 | 90.91% | 96.45% | 98.66% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 4774 | 5675646 | 235 | 1.9 | 90.53% | 91.62% | 92.60% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 20955 | 31032423 | 1615 | 1.8 | 89.96% | 90.42% | 90.87% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 22 | 13244 | 1279877 | 42 | 1.8 | 89.85% | 92.40% | 94.36% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 1048 | 1495337 | 73 | 1.6 | 88.62% | 90.84% | 92.65% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 37040 | 81347421 | 5770 | 1.6 | 88.51% | 88.83% | 89.14% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 738 | 692480 | 28 | 1.6 | 88.22% | 91.69% | 94.20% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 249 | 128292 | 1 | 1.5 | 88.20% | 98.18% | 99.74% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 10 | 1304 | 2924650 | 202 | 1.5 | 87.58% | 89.09% | 90.44% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 38842 | 36947060 | 2173 | 1.5 | 87.48% | 88.00% | 88.51% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 45 | 64934 | 2 | 1.0 | 79.20% | 94.08% | 98.51% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 55 | 69213 | 3 | 1.0 | 79.16% | 92.49% | 97.56% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 50 | 77099 | 4 | 0.9 | 77.59% | 90.65% | 96.44% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 06 | 499 | 692834 | 72 | 0.9 | 77.55% | 81.68% | 85.20% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 27 | 53730 | 3 | 0.8 | 75.01% | 90.77% | 96.99% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 1335 | 1365902 | 174 | 0.8 | 73.54% | 76.71% | 79.61% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 60 | 78820 | 7 | 0.6 | 70.16% | 84.05% | 92.19% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 90 | 95987 | 11 | 0.6 | 69.16% | 81.19% | 89.25% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 1690 | 1951778 | 317 | 0.6 | 68.21% | 70.99% | 73.62% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 351 | 241851 | 31 | 0.6 | 66.53% | 74.90% | 81.75% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 18 | 70 | 82370 | 10 | 0.5 | 63.65% | 77.91% | 87.67% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 69 | 65254 | 9 | 0.4 | 60.88% | 76.61% | 87.33% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 482 | 74238 | 7 | 0.4 | 60.47% | 77.96% | 89.10% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 98 | 77317 | 10 | 0.4 | 59.18% | 74.76% | 85.82% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 500 | 149891 | 22 | 0.3 | 54.14% | 66.31% | 76.65% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 222 | 305172 | 81 | 0.3 | 52.70% | 59.57% | 66.08% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 167 | 88330 | 15 | 0.3 | 52.05% | 66.77% | 78.81% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 10 | 29 | 23056 | 2 | 0.3 | 50.56% | 82.44% | 95.57% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 385 | 147014 | 33 | 0.2 | 46.35% | 57.43% | 67.81% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 10 | 14225 | 1 | 0.2 | 45.21% | 87.06% | 98.21% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 80 | 52551 | 12 | 0.2 | 41.31% | 59.29% | 75.08% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 20 | 13505 | 1 | 0.1 | 38.97% | 84.33% | 97.84% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 20 | 13248 | 1 | 0.1 | 38.39% | 84.05% | 97.81% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 14 | 143 | 26784 | 5 | 0.1 | 33.15% | 60.27% | 82.27% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 425 | 95868 | 34 | 0.1 | 25.86% | 37.26% | 50.29% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 4 | 6645 | 1 | 0.1 | 24.80% | 75.70% | 96.71% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 11 | 9985 | 3 | 0.1 | 18.89% | 52.09% | 83.54% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 4707 | 2463925 | 1708 | 0.1 | 17.25% | 18.88% | 20.62% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 30 | 13805 | 7 | 0.1 | 14.78% | 36.11% | 64.81% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 10 | 4920 | 2 | 0.0 | 6.48% | 37.76% | 84.15% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 18 | 5421 | 2 | 0.0 | 5.53% | 35.29% | 83.55% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 8 | 2510 | 1 | 0.0 | 1.92% | 33.21% | 92.67% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 18 | 6256 | 7 | 0.0 | 0.50% | 4.96% | 35.21% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 7 | 2337 | 4 | 0.0 | 0.02% | 1.53% | 49.92% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 08 | 7 | 2823 | 7 | 0.0 | 0.01% | 0.35% | 19.01% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 12 | 1556 | 5 | 0.0 | 0.00% | 0.09% | 29.71% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 02 | 17 | 1278 | 8 | 0.0 | 0.00% | 0.00% | 1.24% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 19 | 4483 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 62 | 15848 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 12 | 5 | 2031 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 16 | 26 | 33182 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 03 | 1 | 1477 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 06 | 15 | 17510 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 06 | 3 | 2761 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 06 | 10 | 10437 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 10 | 20 | 40104 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| [wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 04 | 1 | 2070 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |

Note that some drives have a very low sample size, which gives them a
very wide confidence interval. More data are needed for these drives to
draw conclusions about their survival rates.

# Replicating my results

[results/drive_dates.csv](results/drive_dates.csv) has the cleaned up
data from backblaze, with each drive by serial number, its model, when
it was installed, when it was last observed, and whether it failed.

| serial_number  | capacity_tb | model               | min_date   | max_date   | failed |
|:---------------|------------:|:--------------------|:-----------|:-----------|-------:|
| PL1311LAG2AULH |           4 | wdc hds5c4040ale630 | 2013-04-10 | 2024-06-30 |      0 |
| W300B5H1       |           4 | st4000dm000         | 2013-06-27 | 2024-06-30 |      0 |
| W300CK7H       |           4 | st4000dm000         | 2013-06-27 | 2024-06-30 |      0 |
| W300BA76       |           4 | st4000dm000         | 2013-06-28 | 2024-06-30 |      0 |
| Z300GPBY       |           4 | st4000dm000         | 2013-07-23 | 2024-06-30 |      0 |
| Z300GYP2       |           4 | st4000dm000         | 2013-07-23 | 2024-06-30 |      0 |
| W300B2WJ       |           4 | st4000dm000         | 2013-07-25 | 2024-06-30 |      0 |
| W300B37Q       |           4 | st4000dm000         | 2013-07-25 | 2024-06-30 |      0 |
| PK1331PAJ2V6WS |           4 | wdc hds724040ale640 | 2013-10-15 | 2024-06-30 |      0 |
| W300460J       |           4 | st4000dm000         | 2013-10-15 | 2024-06-30 |      0 |

I use a [Makefile](Makefile) to automate the analysis. Run `make help`
for more info, or just run `make all` to download the data, unzip and
combine it, run the survival analysis and generate the
[README.md](README.md). The download is 50+ GB, so it takes a while, but
you only need to do it once.

An interesting note about this data: It’s 55GB uncompressed, and
contains a whole bunch of irrelevant information. It was very
interesting to me that I could compress a 55GB dataset to 22 Mb, while
still keeping **all** of the relevant information for modeling. (In
other words, this dataset was thousands of times larger than it needed
to be!). I think this is another example of how good data structures are
essential for data science.

# Erratum

I’m probably way over-thinking this, but it was fun to analyze the data.

There are some drives in this data I plan to avoid. For example, the
st3000dm001 has a 5 year survival of 18.9%. I’d be a little nervous to
buy this drive.
[Backblaze](https://www.backblaze.com/blog/3tb-hard-drive-failure/) has
a good analysis of issues with 3TB drives on their blog.

[![I nerd sniped
myself](https://imgs.xkcd.com/comics/nerd_sniping.png)](https://xkcd.com/356/)
