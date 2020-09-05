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
distribution to calculate an upper 95% interval and then sort by it.

Simple Analysis: assuming a constant failure rate
=================================================

AKA Poisson probability
-----------------------

For this analysis, we only look at drive models where at least 100
drives lasted at least 1 year.

We’re going to use the poisson distribution to understand this data:
each year, a certain number of drives fail. We can model this as a
poisson process, which assumes a constant failure rate for all drives
over time.

We then use R’s exact poisson test to get a 95% confidence interval on
that failure rate. Specifically, we look at the upper confidence
interval, as we want to pick drives that are least likely to have a high
failure rate. (Another way of saying this is that we want drives that
were observed for long periods of time with low failure rates).

In other words, we have 2 goals in this analysis:  
1. Holding observation time constant, we want lower failure rates (lower
failure rate is better).  
2. olding failure rate constant we want longer observation time (this
gives us more confidence in the failure rate).

Using the binomial confidence interval is a good way to achieve both
goals.

For a lot more detail on why a confidence interval is what we want to
use here, read Evan Miller’s blog post [How Not To Sort By Average
Rating](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html).

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
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">518</td>
<td style="text-align: right;">43203.5</td>
<td style="text-align: left;">1.20%</td>
<td style="text-align: left;">1.31%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: right;">14.0</td>
<td style="text-align: right;">55</td>
<td style="text-align: right;">4920.7</td>
<td style="text-align: left;">1.12%</td>
<td style="text-align: left;">1.45%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">691.1</td>
<td style="text-align: left;">0.72%</td>
<td style="text-align: left;">1.69%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">235</td>
<td style="text-align: right;">14528.7</td>
<td style="text-align: left;">1.62%</td>
<td style="text-align: left;">1.84%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">1678</td>
<td style="text-align: right;">75300.2</td>
<td style="text-align: left;">2.23%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">73</td>
<td style="text-align: right;">3914.3</td>
<td style="text-align: left;">1.86%</td>
<td style="text-align: left;">2.34%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">3976</td>
<td style="text-align: right;">153344.2</td>
<td style="text-align: left;">2.59%</td>
<td style="text-align: left;">2.67%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">307.7</td>
<td style="text-align: left;">2.27%</td>
<td style="text-align: left;">4.69%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">72</td>
<td style="text-align: right;">1877.1</td>
<td style="text-align: left;">3.84%</td>
<td style="text-align: left;">4.83%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">153</td>
<td style="text-align: right;">3180.1</td>
<td style="text-align: left;">4.81%</td>
<td style="text-align: left;">5.64%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">174</td>
<td style="text-align: right;">3482.0</td>
<td style="text-align: left;">5.00%</td>
<td style="text-align: left;">5.80%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">75</td>
<td style="text-align: right;">1557.2</td>
<td style="text-align: left;">4.82%</td>
<td style="text-align: left;">6.04%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">43</td>
<td style="text-align: right;">936.8</td>
<td style="text-align: left;">4.59%</td>
<td style="text-align: left;">6.18%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">31</td>
<td style="text-align: right;">609.4</td>
<td style="text-align: left;">5.09%</td>
<td style="text-align: left;">7.22%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">64</td>
<td style="text-align: right;">1014.4</td>
<td style="text-align: left;">6.31%</td>
<td style="text-align: left;">8.06%</td>
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
<td style="text-align: left;">ST31500541AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">397</td>
<td style="text-align: right;">3956.9</td>
<td style="text-align: left;">10.03%</td>
<td style="text-align: left;">11.07%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DX000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">81</td>
<td style="text-align: right;">803.7</td>
<td style="text-align: left;">10.08%</td>
<td style="text-align: left;">12.53%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD20EFRX</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">15</td>
<td style="text-align: right;">184.6</td>
<td style="text-align: left;">8.13%</td>
<td style="text-align: left;">13.40%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST32000542AS</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">33</td>
<td style="text-align: right;">326.7</td>
<td style="text-align: left;">10.10%</td>
<td style="text-align: left;">14.19%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MQ01ABF050</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">201</td>
<td style="text-align: right;">1532.3</td>
<td style="text-align: left;">13.12%</td>
<td style="text-align: left;">15.06%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM030</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">355.1</td>
<td style="text-align: left;">12.39%</td>
<td style="text-align: left;">16.63%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST31500341AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">216</td>
<td style="text-align: right;">904.7</td>
<td style="text-align: left;">23.88%</td>
<td style="text-align: left;">27.28%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST3000DM001</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1720</td>
<td style="text-align: right;">6037.5</td>
<td style="text-align: left;">28.49%</td>
<td style="text-align: left;">29.87%</td>
</tr>
</tbody>
</table>

Complicated Analysis: allow for a variable failure rate (between serial numbners, and over time)
================================================================================================

AKA Survival Analysis
---------------------

    ## 
    ## Attaching package: 'survival'

    ## The following object is masked from 'package:epitools':
    ## 
    ##     ratetable

For this analysis, we only look at drive models where at least 100
drives lasted at least 1 year.

Unlike the poisson model, this analysis does not assume a constant
failure rate. Very frequently, drives fail at a higher rate when they
are new, and the rate of failures levels off over time.

This analysis allows different drive models to have different failure
“curves.” This analysis looks for drive models where many individual
drives lasted &gt;1 year.

It is a little less biased toward drive models with smaller samples of
data. If a small data sample has many drive make it to 1 year, this
analysis will give them credit.

Here’s the results of our analysis. The HGST HUH721212ALN604 is the most
reliable drive in our sample of data:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">model</th>
<th style="text-align: right;">capacity_tb</th>
<th style="text-align: right;">N</th>
<th style="text-align: left;">annual_drive_fail_rate</th>
<th style="text-align: left;">ci_95</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">10914</td>
<td style="text-align: left;">0.42%</td>
<td style="text-align: left;">0.55%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALE600</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">2609</td>
<td style="text-align: left;">0.40%</td>
<td style="text-align: left;">0.69%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: right;">1246</td>
<td style="text-align: left;">0.40%</td>
<td style="text-align: left;">0.76%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HMS5C4040BLE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">16346</td>
<td style="text-align: left;">0.68%</td>
<td style="text-align: left;">0.81%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">4664</td>
<td style="text-align: left;">0.77%</td>
<td style="text-align: left;">1.02%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: right;">14.0</td>
<td style="text-align: right;">8825</td>
<td style="text-align: left;">0.85%</td>
<td style="text-align: left;">1.17%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">8723</td>
<td style="text-align: left;">0.99%</td>
<td style="text-align: left;">1.19%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">14991</td>
<td style="text-align: left;">1.07%</td>
<td style="text-align: left;">1.23%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">1085</td>
<td style="text-align: left;">0.75%</td>
<td style="text-align: left;">1.27%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000DM002</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">10187</td>
<td style="text-align: left;">1.09%</td>
<td style="text-align: left;">1.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">4774</td>
<td style="text-align: left;">1.09%</td>
<td style="text-align: left;">1.39%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">807</td>
<td style="text-align: left;">1.00%</td>
<td style="text-align: left;">1.68%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">38692</td>
<td style="text-align: left;">1.57%</td>
<td style="text-align: left;">1.69%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">350</td>
<td style="text-align: left;">0.86%</td>
<td style="text-align: left;">1.82%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">2719</td>
<td style="text-align: left;">1.40%</td>
<td style="text-align: left;">1.84%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1048</td>
<td style="text-align: left;">1.34%</td>
<td style="text-align: left;">2.03%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">1939</td>
<td style="text-align: left;">1.50%</td>
<td style="text-align: left;">2.03%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DX000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">222</td>
<td style="text-align: left;">0.90%</td>
<td style="text-align: left;">2.14%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">37035</td>
<td style="text-align: left;">2.37%</td>
<td style="text-align: left;">2.53%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">150</td>
<td style="text-align: left;">2.00%</td>
<td style="text-align: left;">4.22%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">451</td>
<td style="text-align: left;">2.79%</td>
<td style="text-align: left;">4.34%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MQ01ABF050</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">589</td>
<td style="text-align: left;">4.62%</td>
<td style="text-align: left;">6.30%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">550</td>
<td style="text-align: left;">4.57%</td>
<td style="text-align: left;">6.31%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1600AAJS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">125</td>
<td style="text-align: left;">3.25%</td>
<td style="text-align: left;">6.34%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">118</td>
<td style="text-align: left;">3.44%</td>
<td style="text-align: left;">6.70%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">499</td>
<td style="text-align: left;">5.41%</td>
<td style="text-align: left;">7.38%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1335</td>
<td style="text-align: left;">7.71%</td>
<td style="text-align: left;">9.16%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">351</td>
<td style="text-align: left;">6.60%</td>
<td style="text-align: left;">9.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD20EFRX</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">167</td>
<td style="text-align: left;">5.90%</td>
<td style="text-align: left;">9.59%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST32000542AS</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">385</td>
<td style="text-align: left;">7.42%</td>
<td style="text-align: left;">10.35%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST31500541AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">2188</td>
<td style="text-align: left;">9.74%</td>
<td style="text-align: left;">11.00%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM030</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">282</td>
<td style="text-align: left;">11.18%</td>
<td style="text-align: left;">14.88%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3000DM001</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">4707</td>
<td style="text-align: left;">15.13%</td>
<td style="text-align: left;">16.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST31500341AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">787</td>
<td style="text-align: left;">21.07%</td>
<td style="text-align: left;">24.19%</td>
</tr>
</tbody>
</table>

Erratum
=======

![I nerd sniped myself](https://imgs.xkcd.com/comics/nerd_sniping.png)
