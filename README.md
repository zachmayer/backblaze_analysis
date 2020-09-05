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
<th style="text-align: left;">annual_drive_failure_rate</th>
<th style="text-align: left;">annual_drive_failure_rate_95</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040BLE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">0.46%</td>
<td style="text-align: left;">0.52%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: left;">0.49%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">0.54%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALE600</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: left;">0.44%</td>
<td style="text-align: left;">0.86%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">0.73%</td>
<td style="text-align: left;">0.90%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">0.82%</td>
<td style="text-align: left;">0.97%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: left;">0.64%</td>
<td style="text-align: left;">1.02%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: left;">0.75%</td>
<td style="text-align: left;">1.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST8000DM002</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: left;">1.06%</td>
<td style="text-align: left;">1.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: left;">1.05%</td>
<td style="text-align: left;">1.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0008</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: left;">1.03%</td>
<td style="text-align: left;">1.30%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: left;">1.20%</td>
<td style="text-align: left;">1.31%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: right;">14.0</td>
<td style="text-align: left;">1.12%</td>
<td style="text-align: left;">1.45%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">0.72%</td>
<td style="text-align: left;">1.69%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: left;">1.62%</td>
<td style="text-align: left;">1.84%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: left;">2.23%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">1.86%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">2.59%</td>
<td style="text-align: left;">2.67%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate SSD</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">3.85%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA500V</td>
<td style="text-align: right;">5.0</td>
<td style="text-align: left;">1.09%</td>
<td style="text-align: left;">3.95%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM001G</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: left;">2.12%</td>
<td style="text-align: left;">4.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS724040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">1.26%</td>
<td style="text-align: left;">4.54%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">2.27%</td>
<td style="text-align: left;">4.69%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: left;">3.84%</td>
<td style="text-align: left;">4.83%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPCX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">1.90%</td>
<td style="text-align: left;">4.85%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD40EFRX</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">1.90%</td>
<td style="text-align: left;">4.87%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate BarraCuda SSD ZA250CM10002</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">1.70%</td>
<td style="text-align: left;">4.95%</td>
</tr>
<tr class="even">
<td style="text-align: left;">DELLBOSS VD</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">5.23%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">4.81%</td>
<td style="text-align: left;">5.64%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">5.00%</td>
<td style="text-align: left;">5.80%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">4.82%</td>
<td style="text-align: left;">6.04%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">4.59%</td>
<td style="text-align: left;">6.18%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000BPKT</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">1.72%</td>
<td style="text-align: left;">6.20%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA DT01ACA300</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">3.45%</td>
<td style="text-align: left;">7.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">5.09%</td>
<td style="text-align: left;">7.22%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: left;">6.31%</td>
<td style="text-align: left;">8.06%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST9320325AS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">3.00%</td>
<td style="text-align: left;">8.76%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1600AAJS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: left;">5.75%</td>
<td style="text-align: left;">8.89%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM005</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">3.82%</td>
<td style="text-align: left;">8.92%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM021</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">9.42%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EACS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: left;">4.79%</td>
<td style="text-align: left;">9.45%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUS726040ALE610</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">3.71%</td>
<td style="text-align: left;">10.85%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD30EZRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">7.39%</td>
<td style="text-align: left;">10.91%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST31500541AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: left;">10.03%</td>
<td style="text-align: left;">11.07%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST6000DM001</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">11.29%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST9250315AS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">7.29%</td>
<td style="text-align: left;">11.68%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3160316AS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: left;">6.76%</td>
<td style="text-align: left;">11.81%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA HDWF180</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: left;">2.18%</td>
<td style="text-align: left;">12.17%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH721010ALE600</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">12.38%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DX000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">10.08%</td>
<td style="text-align: left;">12.53%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD20EFRX</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: left;">8.13%</td>
<td style="text-align: left;">13.40%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST32000542AS</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: left;">10.10%</td>
<td style="text-align: left;">14.19%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MQ01ABF050</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">13.12%</td>
<td style="text-align: left;">15.06%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS723030BLE640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: left;">2.76%</td>
<td style="text-align: left;">15.38%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST250LM004 HN</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">9.04%</td>
<td style="text-align: left;">15.79%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST16000NM001G</td>
<td style="text-align: right;">16.0</td>
<td style="text-align: left;">2.97%</td>
<td style="text-align: left;">16.54%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM030</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">12.39%</td>
<td style="text-align: left;">16.63%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD2500BPVT</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: left;">3.16%</td>
<td style="text-align: left;">17.59%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM001</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: left;">12.92%</td>
<td style="text-align: left;">18.05%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000DM005</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: left;">6.28%</td>
<td style="text-align: left;">18.36%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3160318AS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: left;">11.88%</td>
<td style="text-align: left;">19.29%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Seagate BarraCuda SSD ZA500CM10002</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: left;">3.61%</td>
<td style="text-align: left;">20.09%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EADX</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: left;">9.37%</td>
<td style="text-align: left;">23.98%</td>
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
