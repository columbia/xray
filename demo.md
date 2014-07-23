---
layout: page
title: Demo
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="green">depression</font> keyword in my inbox?!</i>
</p>


### Example Use Case:  Revealing Ad Targeting

As a show-case experiment, we've used XRay to observe Gmail ads attracted
by various topics, such as various diseases, sexual orientation,
pregnancy, race, divorce, debt, etc.  We've found some pretty interesting
associations:  a <font color="red">"Shamanic healing"</font> ad appeared
exclusively in accounts containing emails about
<font color="green">depression</font>; a number of big clothing brand ads
correlate strongly with the presence of pregnancy-related emails in a user's
inbox; and a car dealership ad correlates strongly with debt-related emails,
indicating subprime targeting.

We thought that others might be interested in such data, so we built
an [<b>XRay-based service</b>](xxx) that continuously collects and
diagnoses ads related to a particular set of topics.  If you're interested
in our latest data, please refer to our [service](xxx).  If
you'd like to add some more topics for us to track, please
[contact us]({{ site.baseurl }}/team/).

To seed the discussion we present a few sample associations next.


### Example Findings

We created emails focused on topics such as cancer, Alzheimer's, depression,
race, homosexuality, pregnancy, divorce, and debt.  Each email consisted
of keywords closely related to one topic (e.g., the depression-related email
included <i>depression</i>, <i>depressed</i>, and <i>sad</i>; the homosexuality
email included <i>gay</i>, <i>homosexual</i>, and <i>lesbian</i>).
We then launched XRay to collect and diagnose ads shown for these emails.

The [table](#table) below shows sample ads that XRay associated with
each topic.  Conservatively, we only show here ads where XRay computed very high
confidence scores.  We make several observations:

1. <b>It is possible to target sensitive topics in users' inboxes:</b>
Many of our disease-related emails are strongly correlated with
a number of ads.  A "Shamanic healing" ad appears exclusively in accounts
containing the depression-related email, and many times in its context; ads for
assisted living services target the Alzheimer email; and a Ford campaign to
fight breast cancer targets the cancer email.
Race, homosexuality, pregnancy, divorce, and debt also attract plenty of ads.

2. <b>Targeting is often obscure and may be dangerous:</b>
For many of the ads in the table, the association with the targeted email
is not obvious at all.  Nothing in the "Shamanic healing" ad suggests targeting
against depression; nothing in the general-purpose clothing ads suggest targeting
against pregnancy; and nothing in the "Cedars hotel" ad suggests an orientation
toward the homosexuality email.
This obscurity opens users to subtle dangers and, we believe, show-cases an urgent
need for increased transparency in ad targeting.  If no keyword in the ad suggests
relation with sensitive topics, a user clicking on the ad may not realize that
they could be disclosing private information to advertisers.  Inspired by these
ads, we developed an [attack]({{ site.baseurl }}/attack/) that illustrates the dangers of
obscure targeting.

3. <b>Targeting sometimes misses the point:</b>
One might think that ad targeting is always precise and sophisticated.  However,
we found quite a few cases where targeting seemed to be done through very basic
keyword matching and completely missed the semantic meaning of the email.
For example, an email about divorce, which happened to contain the keyword "marriage"
in its body (in the format "end of marriage"), attracted not only divorce-related ads,
but also several ads related to wedding planning and invitations.  As another example,
an email about TV shows was targeted by ads related to various brands of watches just
because it contained the word "watch" (as in "watch TV") in its body. We wonder, then,
whether those were the placements intended by the advertisers, or whether they are
examples of ineffective advertising.


4. <b>There's lots of subprime targeting:</b>
We observed that different topics were targeted more frequently than others.
For example, while disease-related emails were targeted rarely, the debt, loan,
pregnancy, and divorce emails were targeted very frequently.  Most notably,
we found that surprisingly many used car ads targeted the <i>debt</i> email.
For example, a used car dealership ad that entices the targeted users to take
a Toyota test drive using a $50 gift offering; it clearly targets the keyword
"debt" in our inbox.  Other such examples are included in the
[table](#table).  Given the recent reports about
[subprime bubble for used cars](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/),  we wonder
whether some advertisers are targeting users who they believe fit the subprime
category.  We plan to investigate subprime targeting at larger scale in the
near future.



<!-- 
Finally, lots of ads about stock investments were targeted against an email about debt
and personal bankruptcy.  Incidentally, searching for "end of marriage" in Google
yields only divorce-related results, suggesting that search may be more semantic
than ad targeting in this particular case.
Regardless, this finding suggests that increased transparency may be valuable
not just for users, but also for advertisers, who may wish to know how their ads
are actually being placed. -->

<!-- For example, the pregnancy email is strongly targeted by an ad for baby-shower
invitations, maternity- and lactation-related ads, and, interestingly, a number
of ads for general-purpose clothing.  As another example, the debt email
is strongly targeted by a car dealership ad that entices the targeted users to take
a Toyota test drive using a $50 gift offering. -->



### The Ad Targeting Data [table]

The table below gives examples of ads targeting various topics in users' inboxes.
We handpicked examples with high XRay confidence scores and that seemed interesting
to us.  Our [demo service](xxx) contains more data, along with the
associated confidence levels.

<font size="3.5pt">

| Topic               | Ad                                                               |
| -------------------:|:---------------------------------------------------------------- |
| **Alzheimer**       | *Black Mold Allergy Symptoms? Expert to remove Black Mold.*      |
| **Alzheimer**       | *Adult Assisted Living. Affordable assisted Living.*             |
| **Cancer**          | *Ford Warriors in Pink. Join the fight.*                         |
| **Cancer**          | *Rosen Method Bodywork for physical or emotional pain.*          |
| **Depression**      | *Shamanic healing over the phone.*                               |
| **Depression**      | *Text Coach - Get the girl you want and desire.*                 |
| **African American**| *Racial Harrassment? Learn your rights now.*                     |
| **African American**| *Racial Harrassment. Hearing racial slurs?*                      |
| **Homosexuality**   | *SF Gay Pride Hotel. Luxury Waterfront.*                         |
| **Homosexuality**   | *Cedars Hotel Loughborough. 36 Bedrooms, restaurant, bar.*       |
| **Pregnancy**       | *Find Baby Shower Invitations. Get up to 60% off here!*          |
| **Pregnancy**       | *Ralph Lauren Apparel.  Official online store.*                  |
| **Pregnancy**       | *Bonobos Official Site. Your closet will thank you.*             |
| **Pregnancy**       | *Clothing Label-USA. Best custom woven labels.*                  |
| **Divorce**         | *Law Attorneys specializing in special needs kids education.*    |
| **Divorce**         | *Cerbone Law Firm. Helping good people thru bad times.*          |
| **Debt**            | *Take a New Toyota Test Drive. Get a $50 gift card on the spot.* |
| **Debt**            | *Great Credit Card Search.  Apply for VISA, Mastercard...*       |
| **Loan**            | *Car Loan without Cosigner 100% Accepted. [...]*|
| **Loan**            | *Car Loans w/ Bad Credit 100% Acceptance! [...]*|

</font>


### Interested in Ad Targeting?  What To Do

The above findings are examples of the kinds of observations one can make using XRay.
They come from our limited and somewhat ad-hoc experience with using XRay to reverse ad
targeting in Gmail for a few specific topics that we thought were interesting.  Over the
next period, we plan to run larger scale experiments to quantify some of our example
driven-observations from above.

There are undoubtedly many more other hypotheses to try (e.g., topics to track, hypotheses
to formulate from our existing data).  If you have an idea for a topic that would be
interesting to track ad targeting for, please [send us an email]({{ site.baseurl }}/team/).
We'll try to incorporate your topic of interest into our [XRay service](xxx)
and make the ads targeting that topic available to you.

XRay as a framework is very general and can track use of data for targeting well beyond
ads.  Read about other potential use cases in our
[research paper]({{ site.baseurl }}/public/xray.pdf).
If you have an idea for some other form of targeting, please feel free to use our
[prototype source code](https://github.com/MatLecu/xray) to investigate it.
Time permitting, we'd be happy to help with any customization you may need to do.

