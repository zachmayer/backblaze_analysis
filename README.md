# Data Sources

I’m buying a hard drive to backup my data at home, and I want to buy a
drive that’s not going to fail. [BackBlaze has shared all of their data
on hard drives and drive
failures.](https://www.backblaze.com/b2/hard-drive-test-data.html#downloading-the-raw-hard-drive-test-data),
and I’m going to use their data to try to assess drive reliability.

Backblaze [did their own
analysis](https://www.backblaze.com/blog/backblaze-hard-drive-stats-q1-2020/)
of drive failures, but I don’t like their approach for 2 reasons:  
1. Their “annualized failure rate”
(`Drive Failures / (Drive Days / 365)`) assumes that failure rates are
constant over time. E.g. this assumption means that observing 1 drive
for 100 days gives you the exact same information as observing 100
drives for 1 day. If drives fail at a constant rate over time, this is
fine, but I suspect that drives actually fail at a higher rate early in
their lives.  
2. I want to compute a confidence interval of some kind, so I can select
a drive that both has a low failure rate, but also enough observations
to make me confident in this failure rate. For example, if I have a
drive that’s been observed for 1 day with 0 failures, I probably don’t
want to buy it, despite it’s zero percent failure rate. This blog post
has some good details on why confidence intervals are useful for sorting
things you want to buy [How Not To Sort By Average
Rating](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html).

# Results

I chose to order the drives by their expected 5 year survival rate. I
calculated a 95% confidence interval on the 5-year survival rate, and I
used that interval to sort the drives.

Based on this analysis, the WDC WUH721414ALE6L4 is the most reliable
drive model in our sample of data, with a 5-year survival rate that is
at least 99.65%.

The top 50 drives from this analysis are:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">model</th>
<th style="text-align: left;">size</th>
<th style="text-align: right;">N</th>
<th style="text-align: right;">drive_days</th>
<th style="text-align: right;">failures</th>
<th style="text-align: left;">surv_5yr_lower</th>
<th style="text-align: left;">surv_5yr</th>
<th style="text-align: left;">surv_5yr_upper</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">WDC WUH721414ALE6L4</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">7694</td>
<td style="text-align: right;">650370</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">99.65%</td>
<td style="text-align: left;">99.95%</td>
<td style="text-align: left;">99.99%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">10944</td>
<td style="text-align: right;">8840451</td>
<td style="text-align: right;">105</td>
<td style="text-align: left;">99.60%</td>
<td style="text-align: left;">99.67%</td>
<td style="text-align: left;">99.72%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">8723</td>
<td style="text-align: right;">14215303</td>
<td style="text-align: right;">192</td>
<td style="text-align: left;">99.54%</td>
<td style="text-align: left;">99.60%</td>
<td style="text-align: left;">99.65%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALE600</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">2619</td>
<td style="text-align: right;">1629567</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">99.50%</td>
<td style="text-align: left;">99.69%</td>
<td style="text-align: left;">99.81%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH721212ALE604</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">10792</td>
<td style="text-align: right;">1376575</td>
<td style="text-align: right;">18</td>
<td style="text-align: left;">99.31%</td>
<td style="text-align: left;">99.57%</td>
<td style="text-align: left;">99.73%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C4040ALE630</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">2719</td>
<td style="text-align: right;">4636586</td>
<td style="text-align: right;">88</td>
<td style="text-align: left;">99.31%</td>
<td style="text-align: left;">99.44%</td>
<td style="text-align: left;">99.55%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WUH721414ALE6L4</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">8421</td>
<td style="text-align: right;">1630664</td>
<td style="text-align: right;">20</td>
<td style="text-align: left;">99.31%</td>
<td style="text-align: left;">99.56%</td>
<td style="text-align: left;">99.71%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">4664</td>
<td style="text-align: right;">6934573</td>
<td style="text-align: right;">150</td>
<td style="text-align: left;">99.27%</td>
<td style="text-align: left;">99.38%</td>
<td style="text-align: left;">99.48%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: left;">8 TB</td>
<td style="text-align: right;">1163</td>
<td style="text-align: right;">1368895</td>
<td style="text-align: right;">24</td>
<td style="text-align: left;">99.25%</td>
<td style="text-align: left;">99.50%</td>
<td style="text-align: left;">99.66%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MG07ACA14TA</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">32199</td>
<td style="text-align: right;">9653721</td>
<td style="text-align: right;">209</td>
<td style="text-align: left;">99.19%</td>
<td style="text-align: left;">99.29%</td>
<td style="text-align: left;">99.38%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM001G</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">10620</td>
<td style="text-align: right;">2885329</td>
<td style="text-align: right;">52</td>
<td style="text-align: left;">99.16%</td>
<td style="text-align: left;">99.36%</td>
<td style="text-align: left;">99.51%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST8000DM002</td>
<td style="text-align: left;">8 TB</td>
<td style="text-align: right;">10241</td>
<td style="text-align: right;">17182411</td>
<td style="text-align: right;">507</td>
<td style="text-align: left;">99.05%</td>
<td style="text-align: left;">99.14%</td>
<td style="text-align: left;">99.21%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST12000NM0008</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">20601</td>
<td style="text-align: right;">9290813</td>
<td style="text-align: right;">244</td>
<td style="text-align: left;">99.05%</td>
<td style="text-align: left;">99.16%</td>
<td style="text-align: left;">99.26%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: left;">6 TB</td>
<td style="text-align: right;">1939</td>
<td style="text-align: right;">3410511</td>
<td style="text-align: right;">88</td>
<td style="text-align: left;">99.03%</td>
<td style="text-align: left;">99.21%</td>
<td style="text-align: left;">99.36%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST8000NM0055</td>
<td style="text-align: left;">8 TB</td>
<td style="text-align: right;">15112</td>
<td style="text-align: right;">21072469</td>
<td style="text-align: right;">690</td>
<td style="text-align: left;">98.99%</td>
<td style="text-align: left;">99.07%</td>
<td style="text-align: left;">99.14%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: left;">10 TB</td>
<td style="text-align: right;">1263</td>
<td style="text-align: right;">1663652</td>
<td style="text-align: right;">44</td>
<td style="text-align: left;">98.99%</td>
<td style="text-align: left;">99.25%</td>
<td style="text-align: left;">99.44%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MG08ACA16TEY</td>
<td style="text-align: left;">16 TB</td>
<td style="text-align: right;">1431</td>
<td style="text-align: right;">227941</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">98.90%</td>
<td style="text-align: left;">99.84%</td>
<td style="text-align: left;">99.98%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: left;">2 TB</td>
<td style="text-align: right;">4774</td>
<td style="text-align: right;">5675646</td>
<td style="text-align: right;">235</td>
<td style="text-align: left;">98.65%</td>
<td style="text-align: left;">98.81%</td>
<td style="text-align: left;">98.96%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MD04ABA400V</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">150</td>
<td style="text-align: right;">289927</td>
<td style="text-align: right;">6</td>
<td style="text-align: left;">98.59%</td>
<td style="text-align: left;">99.36%</td>
<td style="text-align: left;">99.71%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Seagate BarraCuda SSD ZA250CM10002</td>
<td style="text-align: left;">250 GB</td>
<td style="text-align: right;">563</td>
<td style="text-align: right;">261645</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">98.54%</td>
<td style="text-align: left;">99.39%</td>
<td style="text-align: left;">99.75%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST14000NM001G</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">8412</td>
<td style="text-align: right;">1590919</td>
<td style="text-align: right;">52</td>
<td style="text-align: left;">98.46%</td>
<td style="text-align: left;">98.83%</td>
<td style="text-align: left;">99.10%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST12000NM0007</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">38748</td>
<td style="text-align: right;">35477372</td>
<td style="text-align: right;">1911</td>
<td style="text-align: left;">98.38%</td>
<td style="text-align: left;">98.47%</td>
<td style="text-align: left;">98.55%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS723030ALA640</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">1048</td>
<td style="text-align: right;">1495337</td>
<td style="text-align: right;">73</td>
<td style="text-align: left;">98.26%</td>
<td style="text-align: left;">98.62%</td>
<td style="text-align: left;">98.90%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST16000NM001G</td>
<td style="text-align: left;">16 TB</td>
<td style="text-align: right;">4876</td>
<td style="text-align: right;">422804</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">98.07%</td>
<td style="text-align: left;">98.80%</td>
<td style="text-align: left;">99.25%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST4000DM000</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">37037</td>
<td style="text-align: right;">63454747</td>
<td style="text-align: right;">4271</td>
<td style="text-align: left;">97.90%</td>
<td style="text-align: left;">97.99%</td>
<td style="text-align: left;">98.08%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Seagate BarraCuda 120 SSD ZA250CM10003</td>
<td style="text-align: left;">250 GB</td>
<td style="text-align: right;">754</td>
<td style="text-align: right;">151571</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">97.55%</td>
<td style="text-align: left;">99.07%</td>
<td style="text-align: left;">99.65%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Seagate SSD</td>
<td style="text-align: left;">250 GB</td>
<td style="text-align: right;">109</td>
<td style="text-align: right;">74382</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">97.32%</td>
<td style="text-align: left;">99.62%</td>
<td style="text-align: left;">99.95%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS5C4040ALE630</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">118</td>
<td style="text-align: right;">122982</td>
<td style="text-align: right;">6</td>
<td style="text-align: left;">96.88%</td>
<td style="text-align: left;">98.58%</td>
<td style="text-align: left;">99.36%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MD04ABA500V</td>
<td style="text-align: left;">5 TB</td>
<td style="text-align: right;">47</td>
<td style="text-align: right;">67138</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">96.69%</td>
<td style="text-align: left;">99.16%</td>
<td style="text-align: left;">99.79%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD5000LPCX</td>
<td style="text-align: left;">500 GB</td>
<td style="text-align: right;">57</td>
<td style="text-align: right;">96801</td>
<td style="text-align: right;">5</td>
<td style="text-align: left;">96.42%</td>
<td style="text-align: left;">98.49%</td>
<td style="text-align: left;">99.37%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD60EFRX</td>
<td style="text-align: left;">6 TB</td>
<td style="text-align: right;">499</td>
<td style="text-align: right;">689765</td>
<td style="text-align: right;">72</td>
<td style="text-align: left;">96.29%</td>
<td style="text-align: left;">97.05%</td>
<td style="text-align: left;">97.66%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HDS724040ALE640</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">42</td>
<td style="text-align: right;">60069</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">96.27%</td>
<td style="text-align: left;">99.05%</td>
<td style="text-align: left;">99.76%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD40EFRX</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">50</td>
<td style="text-align: right;">77099</td>
<td style="text-align: right;">4</td>
<td style="text-align: left;">96.08%</td>
<td style="text-align: left;">98.50%</td>
<td style="text-align: left;">99.44%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EACS</td>
<td style="text-align: left;">1 TB</td>
<td style="text-align: right;">109</td>
<td style="text-align: right;">109398</td>
<td style="text-align: right;">8</td>
<td style="text-align: left;">95.89%</td>
<td style="text-align: left;">97.92%</td>
<td style="text-align: left;">98.95%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD30EFRX</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">1335</td>
<td style="text-align: right;">1365902</td>
<td style="text-align: right;">174</td>
<td style="text-align: left;">95.82%</td>
<td style="text-align: left;">96.39%</td>
<td style="text-align: left;">96.89%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD10EADS</td>
<td style="text-align: left;">1 TB</td>
<td style="text-align: right;">550</td>
<td style="text-align: right;">549212</td>
<td style="text-align: right;">64</td>
<td style="text-align: left;">95.82%</td>
<td style="text-align: left;">96.71%</td>
<td style="text-align: left;">97.42%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">TOSHIBA MG07ACA14TEY</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">427</td>
<td style="text-align: right;">76221</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">95.69%</td>
<td style="text-align: left;">98.58%</td>
<td style="text-align: left;">99.54%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD5000LPVX</td>
<td style="text-align: left;">500 GB</td>
<td style="text-align: right;">350</td>
<td style="text-align: right;">600939</td>
<td style="text-align: right;">71</td>
<td style="text-align: left;">95.51%</td>
<td style="text-align: left;">96.43%</td>
<td style="text-align: left;">97.17%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST500LM012 HN</td>
<td style="text-align: left;">500 GB</td>
<td style="text-align: right;">807</td>
<td style="text-align: right;">1310717</td>
<td style="text-align: right;">180</td>
<td style="text-align: left;">95.29%</td>
<td style="text-align: left;">95.93%</td>
<td style="text-align: left;">96.49%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST33000651AS</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">351</td>
<td style="text-align: right;">241851</td>
<td style="text-align: right;">31</td>
<td style="text-align: left;">94.96%</td>
<td style="text-align: left;">96.43%</td>
<td style="text-align: left;">97.48%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD5000BPKT</td>
<td style="text-align: left;">500 GB</td>
<td style="text-align: right;">24</td>
<td style="text-align: right;">46490</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">94.81%</td>
<td style="text-align: left;">98.66%</td>
<td style="text-align: left;">99.67%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA DT01ACA300</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">60</td>
<td style="text-align: right;">78820</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">94.80%</td>
<td style="text-align: left;">97.48%</td>
<td style="text-align: left;">98.79%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST14000NM0138</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">1686</td>
<td style="text-align: right;">295867</td>
<td style="text-align: right;">32</td>
<td style="text-align: left;">94.61%</td>
<td style="text-align: left;">96.16%</td>
<td style="text-align: left;">97.27%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST4000DM005</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">90</td>
<td style="text-align: right;">61895</td>
<td style="text-align: right;">6</td>
<td style="text-align: left;">93.79%</td>
<td style="text-align: left;">97.15%</td>
<td style="text-align: left;">98.71%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">WDC WD1600AAJS</td>
<td style="text-align: left;">160 GB</td>
<td style="text-align: right;">125</td>
<td style="text-align: right;">137259</td>
<td style="text-align: right;">20</td>
<td style="text-align: left;">93.64%</td>
<td style="text-align: left;">95.84%</td>
<td style="text-align: left;">97.31%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MQ01ABF050M</td>
<td style="text-align: left;">500 GB</td>
<td style="text-align: right;">451</td>
<td style="text-align: right;">483934</td>
<td style="text-align: right;">94</td>
<td style="text-align: left;">93.39%</td>
<td style="text-align: left;">94.57%</td>
<td style="text-align: left;">95.56%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST9320325AS</td>
<td style="text-align: left;">320 GB</td>
<td style="text-align: right;">25</td>
<td style="text-align: right;">36331</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">92.94%</td>
<td style="text-align: left;">97.64%</td>
<td style="text-align: left;">99.24%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUS726040ALE610</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">41</td>
<td style="text-align: right;">36031</td>
<td style="text-align: right;">3</td>
<td style="text-align: left;">92.85%</td>
<td style="text-align: left;">97.61%</td>
<td style="text-align: left;">99.23%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST31500541AS</td>
<td style="text-align: left;">2 TB</td>
<td style="text-align: right;">2188</td>
<td style="text-align: right;">1655558</td>
<td style="text-align: right;">397</td>
<td style="text-align: left;">92.68%</td>
<td style="text-align: left;">93.36%</td>
<td style="text-align: left;">93.99%</td>
</tr>
<tr class="even">
<td style="text-align: left;">WDC WD30EZRX</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">500</td>
<td style="text-align: right;">149878</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">92.15%</td>
<td style="text-align: left;">94.75%</td>
<td style="text-align: left;">96.52%</td>
</tr>
</tbody>
</table>

-   model is the drive model
-   size is the size of the drive
-   N is the number of unique drives in the analysis
-   drive\_days is the total number of days that we’ve observed for
    drives of this model in the sample
-   failures is the number of failures observed so far
-   surv\_5yr\_lower is the lower bound of the 95% confidence interval
    of the 5-year survival rate
-   surv\_5yr is the 5-year survival rate
-   surv\_5yr\_upper is the upper bound of the 95% confidence interval
    of the 5-year survival rate

To narrow down the data, we can just look at the best drive by size,
excluding models that have fewer than 1000 in the dataset:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">model</th>
<th style="text-align: left;">size</th>
<th style="text-align: right;">N</th>
<th style="text-align: right;">drive_days</th>
<th style="text-align: right;">failures</th>
<th style="text-align: left;">surv_5yr_lower</th>
<th style="text-align: left;">surv_5yr</th>
<th style="text-align: left;">surv_5yr_upper</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">WDC WUH721414ALE6L4</td>
<td style="text-align: left;">14 TB</td>
<td style="text-align: right;">7694</td>
<td style="text-align: right;">650370</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">99.65%</td>
<td style="text-align: left;">99.95%</td>
<td style="text-align: left;">99.99%</td>
</tr>
<tr class="even">
<td style="text-align: left;">HGST HUH721212ALN604</td>
<td style="text-align: left;">12 TB</td>
<td style="text-align: right;">10944</td>
<td style="text-align: right;">8840451</td>
<td style="text-align: right;">105</td>
<td style="text-align: left;">99.60%</td>
<td style="text-align: left;">99.67%</td>
<td style="text-align: left;">99.72%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HMS5C4040ALE640</td>
<td style="text-align: left;">4 TB</td>
<td style="text-align: right;">8723</td>
<td style="text-align: right;">14215303</td>
<td style="text-align: right;">192</td>
<td style="text-align: left;">99.54%</td>
<td style="text-align: left;">99.60%</td>
<td style="text-align: left;">99.65%</td>
</tr>
<tr class="even">
<td style="text-align: left;">Hitachi HDS5C3030ALA630</td>
<td style="text-align: left;">3 TB</td>
<td style="text-align: right;">4664</td>
<td style="text-align: right;">6934573</td>
<td style="text-align: right;">150</td>
<td style="text-align: left;">99.27%</td>
<td style="text-align: left;">99.38%</td>
<td style="text-align: left;">99.48%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">HGST HUH728080ALE600</td>
<td style="text-align: left;">8 TB</td>
<td style="text-align: right;">1163</td>
<td style="text-align: right;">1368895</td>
<td style="text-align: right;">24</td>
<td style="text-align: left;">99.25%</td>
<td style="text-align: left;">99.50%</td>
<td style="text-align: left;">99.66%</td>
</tr>
<tr class="even">
<td style="text-align: left;">ST6000DX000</td>
<td style="text-align: left;">6 TB</td>
<td style="text-align: right;">1939</td>
<td style="text-align: right;">3410511</td>
<td style="text-align: right;">88</td>
<td style="text-align: left;">99.03%</td>
<td style="text-align: left;">99.21%</td>
<td style="text-align: left;">99.36%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ST10000NM0086</td>
<td style="text-align: left;">10 TB</td>
<td style="text-align: right;">1263</td>
<td style="text-align: right;">1663652</td>
<td style="text-align: right;">44</td>
<td style="text-align: left;">98.99%</td>
<td style="text-align: left;">99.25%</td>
<td style="text-align: left;">99.44%</td>
</tr>
<tr class="even">
<td style="text-align: left;">TOSHIBA MG08ACA16TEY</td>
<td style="text-align: left;">16 TB</td>
<td style="text-align: right;">1431</td>
<td style="text-align: right;">227941</td>
<td style="text-align: right;">1</td>
<td style="text-align: left;">98.90%</td>
<td style="text-align: left;">99.84%</td>
<td style="text-align: left;">99.98%</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hitachi HDS722020ALA330</td>
<td style="text-align: left;">2 TB</td>
<td style="text-align: right;">4774</td>
<td style="text-align: right;">5675646</td>
<td style="text-align: right;">235</td>
<td style="text-align: left;">98.65%</td>
<td style="text-align: left;">98.81%</td>
<td style="text-align: left;">98.96%</td>
</tr>
</tbody>
</table>

All of these drives have a very high 5-year survival rate, and I’d feel
pretty confident buying any of them for home backups.

# Technical Details

Survival analysis is a little weird, because you don’t observe the full
distribution of your data. This makes some traditional statistics
impossible to calculate. For example, until you observe every hard drive
in the sample fail, you can’t know the mean time to failure. (If you
have one drive left that hasn’t failed yet, and becomes an outlier in
survival time, that might have a big impact on mean survival time.)

Here’s the thing: these drives are **so reliable** even after 5 years of
data, we’ve barely observed the distribution of failures. (This is a
good thing, but it makes it hard to chose between drives!).

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

    ## Warning: Removed 4 row(s) containing missing values (geom_path).

    ## Warning: Removed 4 row(s) containing missing values (geom_path).

![](README_files/figure-markdown_strict/km_curves-1.png) Note that we
haven’t even observed 1 year’s worth of data yet for the 14 and 16TB
drives, but they seem to have a very low failure rate relative to the
other drives during their first year of life.

The “proportional hazards” assumption from the Cox model allows us to
extend these curves and estimate survival times at 5 years for all of
the drives:

    ## Warning: Removed 426 row(s) containing missing values (geom_path).

    ## Warning: Removed 426 row(s) containing missing values (geom_path).

![](README_files/figure-markdown_strict/cox_curves-1.png)

# Replicating my results

[drive\_dates.csv](drive_dates.csv) has the cleaned up data from
backblaze, with each drive, its model, when it was installed, when it
failed (NA for drives that have not failed) and when it was last
observed.

[README.Rmd](README.Rmd) has the code to run this analysis and generate
this [README.md](README.md) file you are reading right now. Use
[RStudio](https://rstudio.com/products/rstudio/download/) to `knit` the
`Rmd` file into a `md` file, which github will then render nicely for
you.

If you want to get the raw data before it was cleaned up into
[all\_data.csv](all_data.csv), you’ll need at least 70GB of free hard
drive space. I also suggest opening
[backblaze\_analysis.Rproj](backblaze_analysis.Rproj) in RStudio.  
1. Run [1\_download\_data.R](1_download_data.R) to download the data
(almost 10.5 GB).  
2. Run [2\_unzip\_data.R](2_unzip_data.R) to unzip the data (almost 55
GB).  
3. Run [3\_assemble\_data.R](3_assemble_data.R) to “compress” the data,
which generates [all\_data.csv](all_data.csv). 4. Run
[4\_survival\_analysis.R](4_survival_analysis.R) to calculate 5 year
survival.

An interesting note about this data: It’s 55GB uncompressed, and
contains a whole bunch of irrelevant information. It was very
interesting to me that I could compress a 55GB dataset to 14 Mb, while
still keeping **all** of the relevant information for modeling. (In
other words, this dataset was 4,000x larger than it needed to be). I
think this is another example of how “good data structures” are
essential for effective engineering, and data science is, at its core,
engineering.

# Erratum

I’m probably way over-thinking this, but it was fun to analyze the data.
Any of the top 50 drives are likely safe to buy, and are very unlikely
to fail as I use them for a backup drive.

There are some drives in this data I plan to avoid. For example, the
ST3000DM001 has a 5 year survival of 80.9%. This is honestly probably
fine for my purposes, but maybe I’d be a little nervous to buy a drive
with a 1-in-5 chance of dying within 5 years.

![I nerd sniped myself](https://imgs.xkcd.com/comics/nerd_sniping.png)
