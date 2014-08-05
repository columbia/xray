---
layout: page
title: Demo
---

<p class="message" align="right">
  <i>Revealing targeting of <font color="red">Gmail ads</font></i>
</p>

We wrapped XRay's Gmail implementation into a demo service, which
continuously collects ads and reports those strongly correlated with
some topics in a dictionary of topics.  Right now, the service
tracks ads for only 20 or so topics (including various diseases, pregnancy,
race, sexual orientation, divorce, debt, etc.), but we plan to extend
that soon to track hundreds of topics.  The service creates one email
for each topic, consisting of keywords closely related to that topic
(e.g., the depression-related email included <i>depression</i>, <i>depressed</i>,
and <i>sad</i>; the pregnancy email included <i>pregnancy</i> and <i>pregnant</i>).

Using our service, we've already found some pretty interesting associations,
about which you can read on our <a href="{{ site.baseurl }}/findings/">
<font color="blue">Results</font></a> page.
For example, we've seen ads correlating with various illnesses and
lots of subprime loan ads for used cars that correlate strongly with
the presence of the *debt* or *broke* keywords users' inboxes.

We are convinced that there are many more interesting things to be gleaned
from this data, so we invite researchers, journalists, and other
investigators to take a look at our service.  However, before you do so,
please be sure you read at least the following caveats on data
interpretation, if not our [technical paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf).

<center>
  <a href="http://data.lec.io/">
    <font size="5pt" color="blue"><b>XRay Demo Service</b></font>
  </a>
</center>

<h3 id="caveats">Limitations and Caveats</h3>

In interpreting the data from our service, one must take several aspects
into account, which we explain next in layman's terms.  See our
[paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf) for more formal treatment.

1. All targeting information comes from our correlation method, which is
inherently probabilistic and can have false positives.  While our service
is configured to only reveal correlation when it is quite strong, we
recommend that you consult the confidence data that we make available for
every ad to verify that it meets your requirement for certainty.  To interpret
that data,you need some background in statistics.

2. XRay reports *correlation* between emails and ads, but it cannot
report *causality*.  Just because a particular ad correlates with a particular
email does not mean that the advertiser himself/herself caused that correlation.
Other aspects, such as Gmail's own algorithms for ad placement, could have
created a correlation that an advertiser might not even have thought about.

3. The data we report right now is small in scale.  We track only about 20
topics. We plan to increase that significantly in the near future, to
track hundreds of topics.  For the time being, please use the data merely to
create intuition, and not claim definite conclusions.

4. All results come from an in-progress research prototype.  Although we
have tested our system extensively, it is conceivable that yet undiscovered
bugs in our code affect our results.

<font color="red">Given the above limitations, please use XRay's data to
gain intuition and *not* as absolute truth!</font>

