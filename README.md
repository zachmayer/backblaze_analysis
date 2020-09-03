Data Sources
============

I did this analysis using data from:
[BackBlaze](https://www.backblaze.com/b2/hard-drive-test-data.html#downloading-the-raw-hard-drive-test-data).

I used all the data they had available. Here are some links to example
files:  
[2020 Data,
Q2](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q2_2020.zip)  
[2020 Data,
Q1](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q1_2020.zip)  
[2019 Data,
Q4](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q4_2019.zip)  
[2019 Data,
Q3](https://f001.backblazeb2.com/file/Backblaze-Hard-Drive-Data/data_Q3_2019.zip)

Download the files, unzip them, and put all the raw files in `data/`

Some background on how to look at this data can be found on the
[backblaze
blog](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/).
However, their formula to annualize failure rates is wrong:
`Drive Failures / (Drive Days / 365)`. The correct probability
calculation is `1-(1-Drive Failures / Drive Days)^365`. The difference
is tiny, but it bothers me, so here we are.

Simple Analysis: assuming a constant failure rate
=================================================

AKA Poisson probability
-----------------------

We’re going to use the binomial distribution to understand this data:
each day, each drive either fails or doesn’t fail. We encode failure as
1, and not failing as 0.

We then use R’s exact binomial test to get a 95% confidence interval on
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
<th style="text-align: right;">No</th>
<th style="text-align: right;">Yes</th>
<th style="text-align: left;">bi_prob_mean</th>
<th style="text-align: left;">bi_prob_95_upper</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040BLE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">21866832</td>
<td style="text-align: right;">274</td>
<td style="text-align: left;">0.46%</td>
<td style="text-align: left;">0.51%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">4893482</td>
<td style="text-align: right;">65</td>
<td style="text-align: left;">0.48%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">12187701</td>
<td style="text-align: right;">179</td>
<td style="text-align: left;">0.53%</td>
<td style="text-align: left;">0.62%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALE600</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">669194</td>
<td style="text-align: right;">8</td>
<td style="text-align: left;">0.44%</td>
<td style="text-align: left;">0.86%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">4401763</td>
<td style="text-align: right;">88</td>
<td style="text-align: left;">0.73%</td>
<td style="text-align: left;">0.90%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">6641409</td>
<td style="text-align: right;">150</td>
<td style="text-align: left;">0.82%</td>
<td style="text-align: left;">0.96%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">977248</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.63%</td>
<td style="text-align: left;">1.01%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: right;">1222571</td>
<td style="text-align: right;">25</td>
<td style="text-align: left;">0.74%</td>
<td style="text-align: left;">1.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST8000DM002</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">13572222</td>
<td style="text-align: right;">393</td>
<td style="text-align: left;">1.05%</td>
<td style="text-align: left;">1.16%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">3058528</td>
<td style="text-align: right;">88</td>
<td style="text-align: left;">1.05%</td>
<td style="text-align: left;">1.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0008</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">2351487</td>
<td style="text-align: right;">66</td>
<td style="text-align: left;">1.02%</td>
<td style="text-align: left;">1.30%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">15779249</td>
<td style="text-align: right;">518</td>
<td style="text-align: left;">1.19%</td>
<td style="text-align: left;">1.30%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: right;">14.0</td>
<td style="text-align: right;">1797185</td>
<td style="text-align: right;">55</td>
<td style="text-align: left;">1.11%</td>
<td style="text-align: left;">1.44%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">252420</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">0.72%</td>
<td style="text-align: left;">1.67%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">5306276</td>
<td style="text-align: right;">235</td>
<td style="text-align: left;">1.60%</td>
<td style="text-align: left;">1.82%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">27501156</td>
<td style="text-align: right;">1678</td>
<td style="text-align: left;">2.20%</td>
<td style="text-align: left;">2.31%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1429593</td>
<td style="text-align: right;">73</td>
<td style="text-align: left;">1.85%</td>
<td style="text-align: left;">2.32%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">56003832</td>
<td style="text-align: right;">3976</td>
<td style="text-align: left;">2.56%</td>
<td style="text-align: left;">2.64%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate SSD</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">34967</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">3.78%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MD04ABA500V</td>
<td style="text-align: right;">5.0</td>
<td style="text-align: right;">66868</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">1.09%</td>
<td style="text-align: left;">3.87%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM001G</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">137921</td>
<td style="text-align: right;">8</td>
<td style="text-align: left;">2.10%</td>
<td style="text-align: left;">4.09%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS724040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">58072</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">1.25%</td>
<td style="text-align: left;">4.44%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">112393</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">2.25%</td>
<td style="text-align: left;">4.58%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">685538</td>
<td style="text-align: right;">72</td>
<td style="text-align: left;">3.76%</td>
<td style="text-align: left;">4.72%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPCX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">77044</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">1.88%</td>
<td style="text-align: left;">4.74%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD40EFRX</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">76824</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">1.88%</td>
<td style="text-align: left;">4.75%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate BarraCuda SSD ZA250CM10002</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">64633</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">1.68%</td>
<td style="text-align: left;">4.83%</td>
</tr>
<tr class="even">
<td style="text-align: left;">DELLBOSS VD</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">25739</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">5.10%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">1161343</td>
<td style="text-align: right;">153</td>
<td style="text-align: left;">4.70%</td>
<td style="text-align: left;">5.48%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1271595</td>
<td style="text-align: right;">174</td>
<td style="text-align: left;">4.87%</td>
<td style="text-align: left;">5.63%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">568665</td>
<td style="text-align: right;">75</td>
<td style="text-align: left;">4.70%</td>
<td style="text-align: left;">5.86%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">342133</td>
<td style="text-align: right;">43</td>
<td style="text-align: left;">4.49%</td>
<td style="text-align: left;">6.00%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000BPKT</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">42537</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">1.70%</td>
<td style="text-align: left;">6.01%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA DT01ACA300</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">74170</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">3.39%</td>
<td style="text-align: left;">6.86%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">222556</td>
<td style="text-align: right;">31</td>
<td style="text-align: left;">4.96%</td>
<td style="text-align: left;">6.97%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">370441</td>
<td style="text-align: right;">64</td>
<td style="text-align: left;">6.11%</td>
<td style="text-align: left;">7.74%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST9320325AS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">36560</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">2.95%</td>
<td style="text-align: left;">8.39%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1600AAJS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">126921</td>
<td style="text-align: right;">20</td>
<td style="text-align: left;">5.59%</td>
<td style="text-align: left;">8.50%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM005</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">47795</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">3.75%</td>
<td style="text-align: left;">8.53%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST500LM021</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">14308</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">8.99%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EACS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">60943</td>
<td style="text-align: right;">8</td>
<td style="text-align: left;">4.68%</td>
<td style="text-align: left;">9.01%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUS726040ALE610</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">29502</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">3.65%</td>
<td style="text-align: left;">10.29%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD30EZRX</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">123552</td>
<td style="text-align: right;">25</td>
<td style="text-align: left;">7.12%</td>
<td style="text-align: left;">10.33%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST31500541AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">1444820</td>
<td style="text-align: right;">397</td>
<td style="text-align: left;">9.55%</td>
<td style="text-align: left;">10.48%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST6000DM001</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">11931</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">10.68%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST9250315AS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">85119</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">7.03%</td>
<td style="text-align: left;">11.02%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3160316AS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">64805</td>
<td style="text-align: right;">12</td>
<td style="text-align: left;">6.54%</td>
<td style="text-align: left;">11.14%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA HDWF180</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">16725</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">2.16%</td>
<td style="text-align: left;">11.46%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH721010ALE600</td>
<td style="text-align: right;">10.0</td>
<td style="text-align: right;">10879</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">11.65%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DX000</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">293479</td>
<td style="text-align: right;">81</td>
<td style="text-align: left;">9.59%</td>
<td style="text-align: left;">11.77%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD20EFRX</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">67407</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">7.81%</td>
<td style="text-align: left;">12.54%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST32000542AS</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">119276</td>
<td style="text-align: right;">33</td>
<td style="text-align: left;">9.61%</td>
<td style="text-align: left;">13.23%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MQ01ABF050</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">559462</td>
<td style="text-align: right;">201</td>
<td style="text-align: left;">12.30%</td>
<td style="text-align: left;">13.98%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS723030BLE640</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">13231</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">2.72%</td>
<td style="text-align: left;">14.26%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST250LM004 HN</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">48468</td>
<td style="text-align: right;">12</td>
<td style="text-align: left;">8.65%</td>
<td style="text-align: left;">14.61%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST16000NM001G</td>
<td style="text-align: right;">16.0</td>
<td style="text-align: right;">12306</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">2.92%</td>
<td style="text-align: left;">15.24%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM030</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">129667</td>
<td style="text-align: right;">44</td>
<td style="text-align: left;">11.65%</td>
<td style="text-align: left;">15.33%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD2500BPVT</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">11571</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">3.11%</td>
<td style="text-align: left;">16.13%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM001</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">96085</td>
<td style="text-align: right;">34</td>
<td style="text-align: left;">12.12%</td>
<td style="text-align: left;">16.52%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000DM005</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">17435</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">6.09%</td>
<td style="text-align: left;">16.78%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3160318AS</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">49183</td>
<td style="text-align: right;">16</td>
<td style="text-align: left;">11.20%</td>
<td style="text-align: left;">17.55%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Seagate BarraCuda SSD ZA500CM10002</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">10128</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">3.54%</td>
<td style="text-align: left;">18.20%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EADX</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">15593</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">8.94%</td>
<td style="text-align: left;">21.33%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST31500341AS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">330215</td>
<td style="text-align: right;">216</td>
<td style="text-align: left;">21.25%</td>
<td style="text-align: left;">23.88%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA HDWE160</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">4888</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">24.09%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST3000DM001</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">2203428</td>
<td style="text-align: right;">1720</td>
<td style="text-align: left;">24.80%</td>
<td style="text-align: left;">25.83%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate BarraCuda 120 SSD ZA250CM10003</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">4481</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">25.97%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD800BB</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">23644</td>
<td style="text-align: right;">12</td>
<td style="text-align: left;">16.92%</td>
<td style="text-align: left;">27.65%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDT721010SLA360</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">4159</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">27.67%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS723020BLA642</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">9617</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">10.77%</td>
<td style="text-align: left;">28.32%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD3200BEKX</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">12680</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">13.41%</td>
<td style="text-align: left;">28.54%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS724040ALE640</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">3753</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">30.16%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">SAMSUNG HD103UJ</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">3710</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">30.45%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EARS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">3442</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">32.39%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD2500AAJS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">4530</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">7.75%</td>
<td style="text-align: left;">36.18%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MG08ACA16TA</td>
<td style="text-align: right;">16.0</td>
<td style="text-align: right;">2940</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">36.76%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5002ABYS</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">5542</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">12.35%</td>
<td style="text-align: left;">37.88%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST1500DM003</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">2827</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">37.91%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD3200AAJS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">5449</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">12.54%</td>
<td style="text-align: left;">38.38%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD800JB</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">10376</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">21.83%</td>
<td style="text-align: left;">39.80%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EARX</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">2528</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">41.31%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST320LT007</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">72941</td>
<td style="text-align: right;">89</td>
<td style="text-align: left;">35.94%</td>
<td style="text-align: left;">42.19%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST2000VN000</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">4436</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">15.18%</td>
<td style="text-align: left;">44.83%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD5003ABYX</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">2254</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">45.00%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD800AAJS</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">14688</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">31.12%</td>
<td style="text-align: left;">45.93%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD800AAJB</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">11007</td>
<td style="text-align: right;">11</td>
<td style="text-align: left;">30.57%</td>
<td style="text-align: left;">47.94%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate BarraCuda SSD ZA2000CM10002</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">1907</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">50.66%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD30EZRS</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">4421</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">21.95%</td>
<td style="text-align: left;">51.52%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD3200LPVX</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">1808</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">52.54%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1600AAJB</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">5751</td>
<td style="text-align: right;">6</td>
<td style="text-align: left;">31.67%</td>
<td style="text-align: left;">56.35%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS5C3030BLE630</td>
<td style="text-align: right;">3.0</td>
<td style="text-align: right;">1415</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">61.41%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST2000DM001</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">2113</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">15.87%</td>
<td style="text-align: left;">61.82%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST6000DM004</td>
<td style="text-align: right;">6.0</td>
<td style="text-align: right;">1372</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">62.54%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD1001FALS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">1366</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">62.71%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST1500DL001</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">1314</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">64.13%</td>
</tr>
<tr class="even">
<td style="text-align: left;">SAMSUNG HD154UI</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">1971</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">16.91%</td>
<td style="text-align: left;">64.38%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST320005XXXX</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">5025</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">39.86%</td>
<td style="text-align: left;">64.92%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD15EARS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">1279</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">65.13%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD3200AAJB</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">1929</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">17.25%</td>
<td style="text-align: left;">65.17%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST1000LM024 HN</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">1255</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">65.82%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD3200AAKS</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">1188</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">67.83%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDT725025VLA380</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">1154</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">68.89%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD2500BEVT</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">1140</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">69.33%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST1500DL003</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">30823</td>
<td style="text-align: right;">90</td>
<td style="text-align: left;">65.52%</td>
<td style="text-align: left;">72.99%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD1600BPVT</td>
<td style="text-align: right;">0.2</td>
<td style="text-align: right;">2490</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">44.36%</td>
<td style="text-align: left;">77.71%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DX002</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">2319</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">46.71%</td>
<td style="text-align: left;">80.04%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST250LT007</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">3584</td>
<td style="text-align: right;">9</td>
<td style="text-align: left;">59.99%</td>
<td style="text-align: left;">82.43%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD800LB</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">1154</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">27.12%</td>
<td style="text-align: left;">82.84%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST8000DM004</td>
<td style="text-align: right;">8.0</td>
<td style="text-align: right;">2354</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">53.93%</td>
<td style="text-align: left;">83.61%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD2500AAJB</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">1115</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">27.92%</td>
<td style="text-align: left;">83.87%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST3500320AS</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">991</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">30.81%</td>
<td style="text-align: left;">87.16%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HMS5C4040BLE641</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">609</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">89.06%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD10EALS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">532</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">92.05%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD3200BEKT</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">781</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">37.33%</td>
<td style="text-align: left;">92.60%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD800JD</td>
<td style="text-align: right;">0.1</td>
<td style="text-align: right;">762</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">38.06%</td>
<td style="text-align: left;">93.07%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST2000DL001</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">1442</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">71.75%</td>
<td style="text-align: left;">94.77%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000AAJS</td>
<td style="text-align: right;">0.5</td>
<td style="text-align: right;">327</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">98.38%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST2000DL003</td>
<td style="text-align: right;">2.0</td>
<td style="text-align: right;">1229</td>
<td style="text-align: right;">8</td>
<td style="text-align: left;">90.65%</td>
<td style="text-align: left;">99.06%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0117</td>
<td style="text-align: right;">12.0</td>
<td style="text-align: right;">716</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">92.13%</td>
<td style="text-align: left;">99.73%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD15EADS</td>
<td style="text-align: right;">1.5</td>
<td style="text-align: right;">139</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">99.99%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Samsung SSD 850 EVO 1TB</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">224</td>
<td style="text-align: right;">10</td>
<td style="text-align: left;">100.00%</td>
<td style="text-align: left;">100.00%</td>
</tr>
<tr class="even">
<td style="text-align: left;">00MD00</td>
<td style="text-align: right;">4.0</td>
<td style="text-align: right;">14</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">100.00%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD1000FYPS</td>
<td style="text-align: right;">1.0</td>
<td style="text-align: right;">20</td>
<td style="text-align: right;">0</td>
<td style="text-align: left;">0.00%</td>
<td style="text-align: left;">100.00%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD2500JB</td>
<td style="text-align: right;">0.3</td>
<td style="text-align: right;">38</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">99.99%</td>
<td style="text-align: left;">100.00%</td>
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
