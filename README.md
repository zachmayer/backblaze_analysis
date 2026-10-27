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
analysis](https://www.backblaze.com/blog/backblaze-drive-stats-for-q2-2026/)
of drive failures, but I don’t like their approach for 2 reasons:

1.  Their “annualized failure rate”
    `Drive Failures / (Drive Days / 365)` assumes that failure rates are
    constant over time. E.g. this assumption means that observing 1
    drive for 100 days gives you the exact same information as observing
    100 drives for 1 day. If drives fail at a constant rate over time,
    this is fine, but I suspect that drives actually fail at a higher
    rate early in their lives. So their analysis is biased against newer
    drives.\
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
hms5c4040ale640 is the most reliable model in our data, with an
estimated 5-year survival rate that is at least 97.48%. (In other words
we are 95% confident that at least 97.48% of the wdc hms5c4040ale640’s
will last at least 5 years).

Here are the top drives from this analysis, by size. (for example, many
manufacturers have drives in the 16TB range that are very reliable, but
I’m only showing the single best model in this size range).

| model | capacity_tb | N | drive_days | failures | years_97pct | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:---|:---|---:|---:|---:|:---|:---|:---|:---|
| wdc hms5c4040ale640 | 04 | 8716 | 18335148 | 254 | 5.6 | 97.48% | 97.77% | 98.02% |
| wdc wuh721414ale6l4 | 14 | 8871 | 17138717 | 253 | 5.1 | 97.12% | 97.45% | 97.74% |
| wdc huh721212ale600 | 12 | 2697 | 6387092 | 110 | 4.8 | 96.79% | 97.33% | 97.78% |
| wdc wuh721816ale6l4 | 16 | 27309 | 31010101 | 474 | 4.5 | 96.55% | 96.84% | 97.11% |
| wdc wuh722222ale6l4 | 22 | 46039 | 26689897 | 421 | 4.0 | 96.02% | 96.38% | 96.71% |
| st6000dx000 | 06 | 1939 | 4330559 | 100 | 3.8 | 95.63% | 96.40% | 97.03% |
| wdc hds5c3030ala630 | 03 | 4664 | 6934573 | 150 | 3.5 | 95.18% | 95.88% | 96.48% |
| toshiba mg11aca24te | 24 | 9630 | 1691866 | 23 | 3.4 | 94.99% | 96.64% | 97.76% |
| toshiba mg10aca20te | 20 | 25410 | 9313363 | 201 | 3.0 | 94.18% | 94.92% | 95.57% |
| st8000nm000a | 08 | 250 | 306995 | 3 | 3.0 | 94.08% | 98.03% | 99.36% |
| wdc wuh722626ale6l4 | 26 | 7217 | 739121 | 17 | 2.2 | 91.90% | 94.88% | 96.80% |
| wdc hds722020ala330 | 02 | 4774 | 5675646 | 235 | 1.9 | 90.53% | 91.62% | 92.59% |
| st10000nm0086 | 10 | 1304 | 3684617 | 328 | 1.4 | 86.26% | 87.59% | 88.80% |
| st18000nm000j | 18 | 79 | 127026 | 11 | 0.8 | 76.42% | 85.97% | 92.05% |

Data details:

- **model** is the drive model.\
- **capacity_tb** is the size of the drive.\
- **N** is the number of unique drives in the analysis.\
- **drive_days** is the total number of days that we’ve observed for
  drives of this model in the sample.\
- **failures** is the number of failures observed so far.\
- **years_97pct** Is the 97th percentile survival time for the drives.
  97% of the drives will last at least this long.\
- **surv_5yr_lo** is the lower bound of the 95% confidence interval of
  the 5-year survival rate.\
- **surv_5yr** is the 5-year survival rate.\
- **surv_5yr_hi** is the upper bound of the 95% confidence interval of
  the 5-year survival rate.

# Technical Details

Survival analysis is a little weird, because you don’t observe the full
distribution of the data. This makes some traditional statistics
impossible to calculate. For example, until you observe every hard drive
in the sample fail, you can’t know the mean time to failure: if you have
one drive left that hasn’t failed, and becomes an outlier in survival
time, that might have a big impact on mean survival time. You won’t know
the true mean until that last drive fails.

Similarly, to find the median survival time, you need to wait for half
of the drives in your sample fail, which can take a decade or more!

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

<img src="README_files/figure-gfm/km_curves-1.png" alt="" width="4200" />

The “proportional hazards” assumption from the Cox model allows us to
extend these curves and estimate survival times at 5 years for all of
the drives:

<img src="README_files/figure-gfm/cox_curves-1.png" alt="" width="4200" />

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

| model | price | capacity_tb | surv_5yr_lower | cost_per_tb | cost_per_tb_5yr |
|:---|---:|:---|---:|---:|---:|
| [st16000nm001g](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st16000nm001g&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 165.0 | 16 | 96.2 | 10.3 | 10.7 |
| [st12000nm001g](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st12000nm001g&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 126.0 | 12 | 95.0 | 10.5 | 11.1 |
| [st12000nm0008](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st12000nm0008&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 122.0 | 12 | 90.5 | 10.2 | 11.2 |
| [st14000nm001g](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st14000nm001g&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 149.9 | 14 | 93.1 | 10.7 | 11.5 |
| [wdc huh721212ale600](https://www.ebay.com/sch/i.html?_from=R40&_nkw=huh721212ale600&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 148.8 | 12 | 96.8 | 12.4 | 12.8 |
| [wdc wuh721414ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721414ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 179.0 | 14 | 97.1 | 12.8 | 13.2 |
| [toshiba mg08aca16te](https://www.ebay.com/sch/i.html?_from=R40&_nkw=mg08aca16te&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 200.0 | 16 | 93.2 | 12.5 | 13.4 |
| [st4000dm000](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st4000dm000&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 48.0 | 04 | 89.1 | 12.0 | 13.5 |
| [wdc huh728080ale600](https://www.ebay.com/sch/i.html?_from=R40&_nkw=huh728080ale600&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 101.2 | 08 | 93.5 | 12.6 | 13.5 |
| [wdc wuh721816ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 209.0 | 16 | 96.5 | 13.1 | 13.5 |
| [wdc hds722020ala330](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hds722020ala330&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 25.1 | 02 | 90.5 | 12.6 | 13.9 |
| [st8000nm0055](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st8000nm0055&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 109.0 | 08 | 92.0 | 13.6 | 14.8 |
| [st6000dx000](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st6000dx000&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 85.0 | 06 | 95.6 | 14.2 | 14.8 |
| [st8000nm000a](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st8000nm000a&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 111.8 | 08 | 94.1 | 14.0 | 14.9 |
| [st16000nm002j](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st16000nm002j&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 225.0 | 16 | 93.9 | 14.1 | 15.0 |
| [wdc wuh721816ale6l0](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh721816ale6l0&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 229.9 | 16 | 93.3 | 14.4 | 15.4 |
| [st10000nm0086](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st10000nm0086&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 133.0 | 10 | 86.3 | 13.3 | 15.4 |
| [st12000nm0007](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st12000nm0007&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 162.0 | 12 | 87.2 | 13.5 | 15.5 |
| [wdc hus726040ale610](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hus726040ale610&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 50.1 | 04 | 80.6 | 12.5 | 15.5 |
| [st8000dm002](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st8000dm002&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 119.7 | 08 | 93.8 | 15.0 | 16.0 |
| [wdc hds5c3030ala630](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hds5c3030ala630&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 45.7 | 03 | 95.2 | 15.2 | 16.0 |
| [toshiba mg08aca16tey](https://www.ebay.com/sch/i.html?_from=R40&_nkw=mg08aca16tey&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 229.9 | 16 | 87.6 | 14.4 | 16.4 |
| [wdc huh721212ale604](https://www.ebay.com/sch/i.html?_from=R40&_nkw=huh721212ale604&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 199.0 | 12 | 91.2 | 16.6 | 18.2 |
| [wdc wuh722222ale6l4](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wuh722222ale6l4&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 450.0 | 22 | 96.0 | 20.5 | 21.3 |
| [toshiba dt01aca300](https://www.ebay.com/sch/i.html?_from=R40&_nkw=dt01aca300&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 45.5 | 03 | 70.1 | 15.2 | 21.6 |
| [wdc hds724040ale640](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hds724040ale640&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 69.0 | 04 | 79.4 | 17.2 | 21.7 |
| [wdc hds723030ala640](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hds723030ala640&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 59.8 | 03 | 88.6 | 19.9 | 22.5 |
| [wdc wd30efrx](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wd30efrx&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 54.0 | 03 | 73.5 | 18.0 | 24.5 |
| [wdc wd40efrx](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wd40efrx&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 79.5 | 04 | 77.5 | 19.9 | 25.6 |
| [wdc hms5c4040ale640](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hms5c4040ale640&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 102.0 | 04 | 97.5 | 25.5 | 26.2 |
| [wdc wd60efrx](https://www.ebay.com/sch/i.html?_from=R40&_nkw=wd60efrx&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 125.0 | 06 | 77.6 | 20.8 | 26.9 |
| [toshiba mg08aca16ta](https://www.ebay.com/sch/i.html?_from=R40&_nkw=mg08aca16ta&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 415.0 | 16 | 93.5 | 25.9 | 27.7 |
| [wdc huh721212aln604](https://www.ebay.com/sch/i.html?_from=R40&_nkw=huh721212aln604&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 418.0 | 12 | 89.8 | 34.8 | 38.8 |
| [wdc hds5c4040ale630](https://www.ebay.com/sch/i.html?_from=R40&_nkw=hds5c4040ale630&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 180.0 | 04 | 95.6 | 45.0 | 47.1 |
| [st8000dm005](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st8000dm005&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500) | 603.8 | 08 | 82.7 | 75.5 | 91.3 |

According to this analysis, the most cost effective drive is the
[st16000nm001g](https://www.ebay.com/sch/i.html?_from=R40&_nkw=st16000nm001g&_sacat=0&LH_BIN=1&_sop=15&rt=nc&LH_ItemCondition=1000%7C1500),
which costs \$165 and has a 5 year survival rate of 96.2%. This drive
costs \$10.72 to store 1 TB for 5 years (this price includes the
probability of failure).

Again, the price data is probably incorrect, but its still an
interesting analysis.

# Full Data

Here are the full results for all drives, excluding drives that are less
than 2TB:

| model | capacity_tb | N | drive_days | failures | years_97pct | surv_5yr_lo | surv_5yr | surv_5yr_hi |
|:---|:---|---:|---:|---:|:---|:---|:---|:---|
| wdc hms5c4040ale640 | 04 | 8716 | 18335148 | 254 | 5.6 | 97.48% | 97.77% | 98.02% |
| wdc wuh721414ale6l4 | 14 | 8871 | 17138717 | 253 | 5.1 | 97.12% | 97.45% | 97.74% |
| wdc huh721212ale600 | 12 | 2697 | 6387092 | 110 | 4.8 | 96.79% | 97.33% | 97.78% |
| wdc wuh721816ale6l4 | 16 | 27309 | 31010101 | 474 | 4.5 | 96.55% | 96.84% | 97.11% |
| st16000nm001g | 16 | 36025 | 47546818 | 871 | 4.2 | 96.22% | 96.46% | 96.69% |
| wdc wuh722222ale6l4 | 22 | 46039 | 26689897 | 421 | 4.0 | 96.02% | 96.38% | 96.71% |
| st6000dx000 | 06 | 1939 | 4330559 | 100 | 3.8 | 95.63% | 96.40% | 97.03% |
| wdc hds5c4040ale630 | 04 | 2837 | 4790778 | 95 | 3.8 | 95.61% | 96.39% | 97.04% |
| wdc hds5c3030ala630 | 03 | 4664 | 6934573 | 150 | 3.5 | 95.18% | 95.88% | 96.48% |
| toshiba mg11aca24te | 24 | 9630 | 1691866 | 23 | 3.4 | 94.99% | 96.64% | 97.76% |
| st12000nm001g | 12 | 13877 | 26340951 | 721 | 3.4 | 94.98% | 95.33% | 95.65% |
| toshiba mg07aca14ta | 14 | 39387 | 78477023 | 2291 | 3.4 | 94.90% | 95.10% | 95.30% |
| toshiba mg10aca20te | 20 | 25410 | 9313363 | 201 | 3.0 | 94.18% | 94.92% | 95.57% |
| st8000nm000a | 08 | 250 | 306995 | 3 | 3.0 | 94.08% | 98.03% | 99.36% |
| st16000nm002j | 16 | 474 | 597349 | 10 | 2.9 | 93.87% | 96.64% | 98.18% |
| st8000dm002 | 08 | 10319 | 33747252 | 1415 | 2.8 | 93.75% | 94.08% | 94.40% |
| wdc huh728080ale600 | 08 | 1218 | 3297082 | 125 | 2.7 | 93.51% | 94.52% | 95.39% |
| toshiba mg08aca16ta | 16 | 41061 | 41611935 | 1215 | 2.7 | 93.48% | 93.84% | 94.17% |
| wdc wuh721816ale6l0 | 16 | 3070 | 4949556 | 157 | 2.7 | 93.26% | 94.20% | 95.02% |
| toshiba mg08aca16te | 16 | 6665 | 10150167 | 341 | 2.6 | 93.19% | 93.86% | 94.46% |
| st14000nm001g | 14 | 11268 | 21009394 | 794 | 2.6 | 93.07% | 93.52% | 93.94% |
| toshiba md04aba400v | 04 | 150 | 378365 | 11 | 2.4 | 92.32% | 95.65% | 97.58% |
| st8000nm0055 | 08 | 15680 | 46370057 | 2514 | 2.3 | 92.00% | 92.32% | 92.63% |
| wdc wuh722626ale6l4 | 26 | 7217 | 739121 | 17 | 2.2 | 91.90% | 94.88% | 96.80% |
| wdc huh721212ale604 | 12 | 14351 | 25290602 | 1223 | 2.0 | 91.19% | 91.65% | 92.08% |
| wdc hds722020ala330 | 02 | 4774 | 5675646 | 235 | 1.9 | 90.53% | 91.62% | 92.59% |
| st12000nm0008 | 12 | 21037 | 44810471 | 2610 | 1.9 | 90.47% | 90.82% | 91.16% |
| st12000nm000j | 12 | 1116 | 730949 | 22 | 1.8 | 90.03% | 93.30% | 95.55% |
| wdc huh721212aln604 | 12 | 11438 | 27849271 | 1857 | 1.8 | 89.83% | 90.28% | 90.70% |
| st4000dm000 | 04 | 37040 | 81504860 | 5790 | 1.7 | 89.13% | 89.42% | 89.70% |
| toshiba mg07aca14tey | 14 | 1059 | 1329809 | 64 | 1.7 | 89.09% | 91.34% | 93.17% |
| wdc hds723030ala640 | 03 | 1048 | 1495337 | 73 | 1.6 | 88.65% | 90.85% | 92.67% |
| toshiba mg08aca16tey | 16 | 5352 | 8506543 | 549 | 1.5 | 87.60% | 88.54% | 89.41% |
| st12000nm0007 | 12 | 38842 | 37685971 | 2303 | 1.5 | 87.21% | 87.72% | 88.20% |
| st10000nm0086 | 10 | 1304 | 3684617 | 328 | 1.4 | 86.26% | 87.59% | 88.80% |
| toshiba mg09aca16te | 16 | 915 | 169591 | 6 | 1.1 | 82.95% | 91.81% | 96.28% |
| st8000dm005 | 08 | 27 | 70454 | 3 | 1.1 | 82.70% | 93.89% | 98.02% |
| st14000nm000j | 14 | 514 | 258574 | 13 | 1.1 | 81.89% | 88.95% | 93.47% |
| wdc hus726040ale610 | 04 | 55 | 71089 | 3 | 1.0 | 80.58% | 93.06% | 97.74% |
| wdc hds724040ale640 | 04 | 45 | 65106 | 2 | 0.9 | 79.41% | 94.15% | 98.53% |
| st24000nm002h | 24 | 9900 | 3654406 | 302 | 1.0 | 79.36% | 81.37% | 83.23% |
| wdc wd60efrx | 06 | 499 | 692834 | 72 | 0.9 | 77.57% | 81.70% | 85.21% |
| wdc wd40efrx | 04 | 50 | 77099 | 4 | 0.9 | 77.50% | 90.60% | 96.43% |
| st18000nm000j | 18 | 79 | 127026 | 11 | 0.8 | 76.42% | 85.97% | 92.05% |
| wdc wd30efrx | 03 | 1335 | 1365902 | 174 | 0.7 | 73.50% | 76.67% | 79.57% |
| st16000nm000j | 16 | 183 | 84456 | 5 | 0.7 | 73.11% | 87.40% | 94.66% |
| st14000nm0138 | 14 | 1690 | 2890289 | 463 | 0.7 | 73.04% | 75.06% | 76.97% |
| st10000nm001g | 10 | 29 | 42766 | 2 | 0.6 | 71.54% | 91.45% | 97.85% |
| toshiba dt01aca300 | 03 | 60 | 78820 | 7 | 0.6 | 70.13% | 84.03% | 92.18% |
| st4000dm005 | 04 | 90 | 96159 | 11 | 0.6 | 70.00% | 81.75% | 89.59% |
| toshiba hdwf180 | 08 | 69 | 105019 | 13 | 0.6 | 69.11% | 80.39% | 88.25% |
| st33000651as | 03 | 351 | 241851 | 31 | 0.5 | 66.40% | 74.78% | 81.66% |
| wdc huh728080ale604 | 08 | 98 | 134298 | 21 | 0.4 | 63.03% | 73.69% | 82.14% |
| wdc hus728t8tale6l4 | 08 | 20 | 26946 | 1 | 0.4 | 62.68% | 92.78% | 98.99% |
| st14000nm0018 | 14 | 80 | 98822 | 17 | 0.4 | 58.30% | 71.02% | 81.12% |
| wdc wd30ezrx | 03 | 500 | 149891 | 22 | 0.3 | 55.76% | 67.65% | 77.62% |
| st4000dx000 | 04 | 222 | 305172 | 81 | 0.3 | 52.56% | 59.43% | 65.95% |
| wdc wd20efrx | 02 | 167 | 88330 | 15 | 0.3 | 52.33% | 67.00% | 78.96% |
| st32000542as | 02 | 385 | 147014 | 33 | 0.2 | 47.10% | 58.10% | 68.35% |
| wdc hds723030ble640 | 03 | 10 | 14225 | 1 | 0.2 | 45.19% | 87.05% | 98.21% |
| st4000dm004 | 04 | 20 | 13694 | 1 | 0.1 | 39.44% | 84.56% | 97.87% |
| seagate barracuda ssd za2000cm10002 | 02 | 4 | 8186 | 1 | 0.1 | 34.43% | 82.00% | 97.53% |
| st4000dm001 | 04 | 425 | 95868 | 34 | 0.1 | 27.98% | 39.49% | 52.30% |
| st14000nm002j | 14 | 26 | 8772 | 1 | 0.1 | 23.49% | 74.64% | 96.58% |
| st12000nm0117 | 12 | 30 | 18774 | 9 | 0.1 | 22.49% | 43.24% | 66.66% |
| wdc hds723020bla642 | 02 | 11 | 9985 | 3 | 0.1 | 18.84% | 52.03% | 83.51% |
| st3000dm001 | 03 | 4707 | 2463925 | 1708 | 0.1 | 17.65% | 19.24% | 20.93% |
| wdc wuh722016cle6l4 | 16 | 66 | 3582 | 1 | 0.0 | 10.36% | 59.03% | 94.72% |
| st16000nm000g | 16 | 17 | 4416 | 1 | 0.0 | 8.18% | 54.77% | 94.27% |
| st2000vn000 | 02 | 10 | 4920 | 2 | 0.0 | 6.65% | 38.15% | 84.24% |
| wdc wd30ezrs | 03 | 18 | 5421 | 2 | 0.0 | 6.28% | 37.25% | 84.02% |
| st16000nm002h | 16 | 33 | 2208 | 1 | 0.0 | 3.39% | 40.67% | 93.06% |
| st2000dm001 | 02 | 8 | 2510 | 1 | 0.0 | 2.22% | 35.01% | 92.74% |
| st320005xxxx | 02 | 18 | 6256 | 7 | 0.0 | 0.60% | 5.54% | 36.23% |
| st4000dx002 | 04 | 7 | 2337 | 4 | 0.0 | 0.03% | 1.67% | 50.11% |
| st8000dm004 | 08 | 7 | 2823 | 7 | 0.0 | 0.01% | 0.35% | 19.09% |
| st2000dl001 | 02 | 12 | 1556 | 5 | 0.0 | 0.00% | 0.10% | 30.08% |
| st2000dl003 | 02 | 17 | 1278 | 8 | 0.0 | 0.00% | 0.00% | 1.55% |
| st12000nm002h | 12 | 3 | 227 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| toshiba mg11aca16te | 16 | 78 | 5709 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| wdc hus726040aln610 | 04 | 19 | 4515 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| samsung ssd 870 evo 2tb | 02 | 1 | 436 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| samsung ssd 860 pro 2tb | 02 | 3 | 1119 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| st12000nm003g | 12 | 29 | 14832 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| wdc hds5c3030ble630 | 03 | 1 | 1477 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| st6000dm004 | 06 | 3 | 2761 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| st6000dm001 | 06 | 15 | 17510 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| toshiba hdwe160 | 06 | 10 | 10437 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| st16000nm005g | 16 | 26 | 51432 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| wdc hms5c4040ble641 | 04 | 1 | 2174 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |
| wdc huh721010ale600 | 10 | 20 | 54704 | 0 | 0.0 | 0.00% | 100.00% | 100.00% |

Note that some drives have a very low sample size, which gives them a
very wide confidence interval. More data are needed for these drives to
draw conclusions about their survival rates.

# Replicating my results

[results/drive_dates.csv](results/drive_dates.csv) has the cleaned up
data from backblaze, with each drive by serial number, model, when it
was installed, when it was last observed, and whether it failed.

| serial_number   | capacity_tb | model          | min_date   | max_date   | failed |
|:----------------|------------:|:---------------|:-----------|:-----------|-------:|
| WD-WX21E42RW537 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WX81A82J6604 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WXA1E42VAT12 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WXA1E42VAV48 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WXC1A8277330 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WXK1E72CZDF1 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WXK1E72CZNX5 |         0.5 | wdc wd5000bpkt | 2014-02-14 | 2026-06-30 |      0 |
| WD-WX71EB3H9024 |         0.5 | wdc wd5000lpvx | 2014-03-08 | 2026-06-30 |      0 |
| WD-WX11AA3F9680 |         0.5 | wdc wd5000lpvx | 2014-03-12 | 2026-06-30 |      0 |
| WD-WXQ1E93MUVJ3 |         0.5 | wdc wd5000lpvx | 2014-03-13 | 2026-06-30 |      0 |

I use a [Makefile](Makefile) to automate the analysis. Run `make help`
for more info, or just run `make all` to download the data, unzip and
combine it, run the survival analysis and generate the
[README.md](README.md). The download is 30+ GB, so it takes a while, but
you only need to do it once.

An interesting note about this data: It’s 250+ GB uncompressed, and
contains a whole bunch of irrelevant information. It was very
interesting to me that I could compress a 250+ GB dataset to 27 Mb,
while still keeping **all** of the relevant information for modeling.
(In other words, this dataset was thousands of times larger than it
needed to be!). I think this is another example of how good data
structures are essential for data science.

# Erratum

I’m probably way over-thinking this, but it was fun to analyze the data.

There are some drives in this data I plan to avoid. For example, the
st3000dm001 has a 5 year survival of 19.2%. I’d be a little nervous to
buy this drive.
[Backblaze](https://www.backblaze.com/blog/3tb-hard-drive-failure/) has
a good analysis of issues with 3TB drives on their blog.

[![I nerd sniped
myself](https://imgs.xkcd.com/comics/nerd_sniping.png)](https://xkcd.com/356/)
