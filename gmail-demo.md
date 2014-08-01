---
layout: page
title: Demo Service
---

We wrapped XRay's Gmail implementation into a demo service, which
continuously collects ads and reports those strongly correlated with
some topics in a list of about a hundred topics.  Topics include
various diseases, pregnancy, race, sexual orientation, divorce, debt, etc.
Our service creates one email for each topic, consisting of keywords closely
related to that topic (e.g., the depression-related email included <i>depression</i>,
<i>depressed</i>, and <i>sad</i>; the pregnancy email included <i>pregnancy</i>
and <i>pregnant</i>).

Using our service, we've already found some pretty interesting associations,
about which you can read on our [Findings]({{ site.baseurl }}/findings/) page.
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
inherently probabilistic and could err.  While our service is configured
to only reveal correlation when it is quite sure of it, we strongly suggest
that you consult the confidence data that we make available for every ad
to verify that it meets your requirement for certainty.  To interpret that
data, you need decent background in statistics.

2. Correlation, which XRay reports, does not always imply causality.  For
example, it is conceivable that the strong correlation between an ad and
a particular email is caused by some other, obscure effect instead of
explicit targeting or Gmail placement algorithms. Since our accounts
are extremely clean and controlled, we believe that this is unlikely,
and hence in our own analyses we often make the leap from correlation
to targeting.  We do acknowledge this limitation, however.

3. All results come from an in-progress research prototype.  Although we
have tested our system extensively, it is conceivable that yet undiscovered
bugs in our code affect our results.

<font color="red">Given the above limitations, please use XRay's data to
gain intuition and *not* as absolute truth!</font>

