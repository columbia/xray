---
layout: page
title: Demo
---

<div class = "message">
    <i>"Shamanic healing over the phone" ad targets the depression email?!</i>
</div>

As a show-case experiment, we've used XRay to observe ads attracted
by various topics, such as various diseases, sexual orientation,
pregnancy, race, divorce, etc.  We've found some pretty interesting
associations:  a ``Shamanic healing'' ad appeared exclusively in
accounts containing emails about depression; a number of big store
brands correlate strongly with the presence of pregnancy-related
emails in a user's inbox; and a car dealership ad correlates strongly
with debt-related emails.  A few more examples are included
<a href="#examples">below</a>.

We thought that others might be interested in such data, so we built
an <a href=""><b>XRay-based service</b></a> that continuously collects and
diagnoses ads related to a particular set of topics.  If you're interested
in our latest data, please refer to our <a href="">service</a>.  If
you'd like to ad some more topics for us to track, please
<a href="">contact us</a>.


<h3 id="examples">Example Findings</h3>

We created emails focused on topics such as cancer, Alzheimer, depression,
race, homosexuality, pregnancy, divorce, and debt.  Each email consisted
of keywords closely related to one topic (e.g., the depression-related email
included <i>depression</i>, <i>depressed</i>, and <i>sad</i>; the homosexuality
email included <i>gay</i>, <i>homosexual</i>, and <i>lesbian</i>).
We then launched XRay to collect and diagnose ads shown for these emails.

The table below shows ads that XRay associated with each topic, along with its
confidence scores.  One thing to always keep in mind is that our mechanisms
are probabilistic, hence confidence levels must be considered when interpreting
results from XRay.  Conservatively, we only show here ads with very high scores.
We make two observations:

<ol>

<li><i>It is possible to target sensitive topics in users' inboxes.</i>
Many of our disease-related emails are strongly correlated with
a number of ads.  A ``Shamanic healing'' ad appears exclusively in accounts
containing the depression-related email, and many times in its context; ads for
assisted living services target the Alzheimer email; and a Ford campaign to
fight breast cancer targets the cancer email.
Race, homosexuality, pregnancy, divorce, and debt also attract plenty of ads.
For example, the pregnancy email is strongly targeted by an ad for baby-shower
invitations (shown in the figure), maternity- and lactation-related ads (not shown),
and, interestingly, a number of ads for general-purpose clothing (shown).
As another example, the debt email is strongly targeted by a car dealership ad that
entices the targeted users to take a Toyota test drive using a $50 gift offering.
</li>

<li><i>Targeting is often obscure and may be dangerous.</i>
For many of the ads we show in the table, the association with the targeted email
is not obvious at all.  Nothing in the ``Shamanic healing'' ad suggests targeting
against depression; nothing in the general-purpose clothing ads suggest targeting
against pregnancy; and nothing in the ``Cedars hotel'' ad suggests an orientation
toward the homosexuality email.
This obscurity opens users to subtle dangers and, we believe, show-cases an urgent
need for increased transparency in ad targeting. If no keyword in the ad suggests
relation with sensitive topics, a user clicking on the ad may not realize that
they could be disclosing private information to advertisers.

<!--
Imagine an insurance company wanted to gain insight into pre-existing conditions of
its customers before signing them up. It could create two ad campaigns -- one that
targets cancer and another youth -- and assign different URLs to each campaign.
It could then offer higher premium quotes to visitors who come through the
cancer-related ads to discourage them from signing up while offering lower premium
quotes to those who come through youth-related ads.  We believe that the potential
for this attack illustrates the urgent need for increased transparency in ad targeting.
-->
</li>

</ol>


| Topic         | Ad                           | Confidence  | Raw Data   |
|:------------- |:---------------------------- |:-----------:|:----------:| 
| Alzheimer     | Black Mold Allergy Symptoms? |    0.99     | 9/9, 61/198|



