Data Sources
============

I did this analysis using data from:
[BackBlaze](https://www.backblaze.com/b2/hard-drive-test-data.html#downloading-the-raw-hard-drive-test-data).

I used all the data they had available. Here is a link to an example
file: [2020 Data,
Q2](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2020.zip)

Download the files, unzip them, and put all the raw files in `data/`

Some background on how to look at this data can be found on the
[backblaze
blog](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/).
They use the followiong formula to annualize failure rates:
`Drive Failures / (Drive Days / 365)`. This is correct if we assume that
failure rates do not change at all over time. They also calculate a 95%
confidence interval, but I wanted to be sure to use a poisson
distribution to calculate an upper 95% interval and then sort by ut

Simple Analysis: assuming a constant failure rate
=================================================

AKA Poisson probability
-----------------------

We’re going to use the poisson distribution to understand this data:
each year, a certain number of drives fail. We can model this as a
poisson process, which assumes a constant failure rate for all drives
over time.

We then use R’s exact poisson test to get a 95% confidence interval on
that failure rate. Specifically, we look at the upper confidence
interval, as we want to pick drives that are least likely to have a high
failure rate. (Another way of saying this is that we want drives that
were observed for long periods of time with low failure rates).

In other words, we have 2 goals in this analysis: 1. Holding observation
time constant, we want lower failure rates (lower failure rate is
better). 2. olding failure rate constant we want longer observation time
(this gives us more confidence in the failure rate).

Using the binomial confidence interval is a good way to achieve both
goals.

For a lot more detail on why a binomial confidence interval is what we
want to use here, read Evan Miller’s blog post [How Not To Sort By
Average
Rating](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html).

This statistic is the daily failure rate, but we’re not gonna use these
drives for 1 day. We’re gonna use them for years, so we “annualize” the
failure rate.

Let’s say a drive has a 0.5% daily failure rate. This means it has a
99.5% daily passing rate. We want to know the odds it will survive 1
year, which are .995^365 = 0.1604813. So 0.5% daily failure rate is
really bad, and is equivalent to an annual failure rate of 100-16 = 84%.
You wouldn’t buy a drive with an 84% chance of failing in 1 year!

Here’s the results of our analysis. The HGST HMS5C4040BLE640 is the most
reliable drive in our sample of data:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">model</th>
<th style="text-align: right;">capacity_tb</th>
<th style="text-align: right;">Failures</th>
<th style="text-align: right;">Drive_Years</th>
<th style="text-align: left;">annual_drive_fail_rate</th>
<th style="text-align: left;">ci_95</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040BLE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">274</td>
<td style="text-align: right;">59870.1</td>
<td style="text-align: left;">0.46%</td>
<td style="text-align: left;">0.52%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">65</td>
<td style="text-align: right;">13398.1</td>
<td style="text-align: left;">0.49%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">179</td>
<td style="text-align: right;">33369.3</td>
<td style="text-align: left;">0.54%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALE600</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">1832.2</td>
<td style="text-align: left;">0.44%</td>
<td style="text-align: left;">0.86%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">88</td>
<td style="text-align: right;">12051.9</td>
<td style="text-align: left;">0.73%</td>
<td style="text-align: left;">0.90%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">150</td>
<td style="text-align: right;">18184.0</td>
<td style="text-align: left;">0.82%</td>
<td style="text-align: left;">0.97%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">17</td>
<td style="text-align: right;">2675.7</td>
<td style="text-align: left;">0.64%</td>
<td style="text-align: left;">1.02%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: right;">25</td>
<td style="text-align: right;">3347.4</td>
<td style="text-align: left;">0.75%</td>
<td style="text-align: left;">1.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST8000DM002</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">393</td>
<td style="text-align: right;">37160.6</td>
<td style="text-align: left;">1.06%</td>
<td style="text-align: left;">1.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">88</td>
<td style="text-align: right;">8374.2</td>
<td style="text-align: left;">1.05%</td>
<td style="text-align: left;">1.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0008</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">66</td>
<td style="text-align: right;">6438.3</td>
<td style="text-align: left;">1.03%</td>
<td style="text-align: left;">1.30%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">518</td>
<td style="text-align: right;">43203.5</td>
<td style="text-align: left;">1.20%</td>
<td style="text-align: left;">1.31%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: right;">14.0</td>
<td style="text-align: right;">55</td>
<td style="text-align: right;">4920.7</td>
<td style="text-align: left;">1.12%</td>
<td style="text-align: left;">1.45%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">691.1</td>
<td style="text-align: left;">0.72%</td>
<td style="text-align: left;">1.69%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">235</td>
<td style="text-align: right;">14528.7</td>
<td style="text-align: left;">1.62%</td>
<td style="text-align: left;">1.84%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">1678</td>
<td style="text-align: right;">75300.2</td>
<td style="text-align: left;">2.23%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">73</td>
<td style="text-align: right;">3914.3</td>
<td style="text-align: left;">1.86%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">3976</td>
<td style="text-align: right;">153344.2</td>
<td style="text-align: left;">2.59%</td>
<td style="text-align: left;">2.67%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate SSD</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">95.7</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">3.85%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA500V</td>
<td style="text-align: right;">5.0</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">183.1</td>
<td style="text-align: left;">1.09%</td>
<td style="text-align: left;">3.95%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM001G</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">377.6</td>
<td style="text-align: left;">2.12%</td>
<td style="text-align: left;">4.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS724040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">159.0</td>
<td style="text-align: left;">1.26%</td>
<td style="text-align: left;">4.54%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">307.7</td>
<td style="text-align: left;">2.27%</td>
<td style="text-align: left;">4.69%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">72</td>
<td style="text-align: right;">1877.1</td>
<td style="text-align: left;">3.84%</td>
<td style="text-align: left;">4.83%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPCX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">211.0</td>
<td style="text-align: left;">1.90%</td>
<td style="text-align: left;">4.85%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD40EFRX</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">210.3</td>
<td style="text-align: left;">1.90%</td>
<td style="text-align: left;">4.87%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate BarraCuda SSD ZA250CM10002</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">177.0</td>
<td style="text-align: left;">1.70%</td>
<td style="text-align: left;">4.95%</td>
</tr>
<tr class="even">
<td style="text-align: left;">DELLBOSS VD</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">70.5</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">5.23%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">153</td>
<td style="text-align: right;">3180.1</td>
<td style="text-align: left;">4.81%</td>
<td style="text-align: left;">5.64%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">174</td>
<td style="text-align: right;">3482.0</td>
<td style="text-align: left;">5.00%</td>
<td style="text-align: left;">5.80%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">75</td>
<td style="text-align: right;">1557.2</td>
<td style="text-align: left;">4.82%</td>
<td style="text-align: left;">6.04%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">43</td>
<td style="text-align: right;">936.8</td>
<td style="text-align: left;">4.59%</td>
<td style="text-align: left;">6.18%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000BPKT</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">2</td>
<td style="text-align: right;">116.5</td>
<td style="text-align: left;">1.72%</td>
<td style="text-align: left;">6.20%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA DT01ACA300</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">203.1</td>
<td style="text-align: left;">3.45%</td>
<td style="text-align: left;">7.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">31</td>
<td style="text-align: right;">609.4</td>
<td style="text-align: left;">5.09%</td>
<td style="text-align: left;">7.22%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">64</td>
<td style="text-align: right;">1014.4</td>
<td style="text-align: left;">6.31%</td>
<td style="text-align: left;">8.06%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST9320325AS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">100.1</td>
<td style="text-align: left;">3.00%</td>
<td style="text-align: left;">8.76%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1600AAJS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">20</td>
<td style="text-align: right;">347.6</td>
<td style="text-align: left;">5.75%</td>
<td style="text-align: left;">8.89%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM005</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">130.9</td>
<td style="text-align: left;">3.82%</td>
<td style="text-align: left;">8.92%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM021</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">39.2</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">9.42%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EACS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">166.9</td>
<td style="text-align: left;">4.79%</td>
<td style="text-align: left;">9.45%</td>
</tr>
</tbody>
</table>

Complicated Analysis: allow for a variable failure rate (between serial numbners, and over time)
================================================================================================

AKA Survival Analysis
---------------------

Erratum
=======

![I nerd sniped myself](https://imgs.xkcd.com/comics/nerd_sniping.png)
