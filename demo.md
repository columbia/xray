---
layout: page
title: XRay Demo
---

We wrapped XRay's Gmail implementation into a demo service, which
continuously collects ads, reverses their targeting, and reports
any ads strongly correlated with one or a combination of a hundred
or so topics.  Topics include various diseases, pregnancy, race,
sexual orientation, divorce, debt, etc.  Using it, we've already
found some pretty interesting associations, such as ads targeting
various illnesses, and lots of subprime loan ads for used cars that
targeted *debt* or *broke* keywords users' inboxes.  More results
on an early dataset are described in on our
[Findings]({{ site.baseurl }}/findings/) page.

We are convinced that there are many more interesting things to be learned
from this data, so we invite researchers, journalists, and other
investigators to take a look at our service.  However, before you do so,
please be sure you read at least the following caveats on data
interpretation, if not our [technical paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf).

<center>
  <a href="http://data.lec.io/">
    <font size="5pt" color="blue"><b>XRay Demo Service</b></font>
  </a>
</center>

<h3 id="caveats">Interpreting the Data</h3>

In interpreting the data from our service, one must take several aspects
into account, which we explain next in layman's terms.  See our
[paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf) for more formal treatment.

1. All targeting information comes from our correlation method, which is
inherently probabilistic.  While our service is configured to only reveal
correlation when it is quite sure of it, we strongly suggest that you
consult the confidence data that we make available for every ad to verify
that it meets your requirement for certainty.  To interpret that data,
you need decent background in statistics.

2. Correlation, which XRay exclusively reports, does not always imply
causality.  For example, it is conceivable that the association of the
Shamanic healing ad to the depression email was done entirely by some
automatic ad placement algorithm within Google and not intentionally by
the advertiser.  We believe this is unlikely, however we do warn that this
caveat might invalidate some, though not all, of our
[findings]({{ site.baseurl }}/findings).

3. All results come from an in-progress research prototype.  Although we
have tested our system extensively, it is conceivable that yet undiscovered
bugs in our code affect our results.

<font color="red">Given the above limitations, please use XRay's data to
gain intuition and *not* as absolute truth!</font>

