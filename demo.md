---
layout: page
title: Demo
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="green">depression</font> keyword in my inbox?!</i>
</p>


### Example Use Case:  Revealing Ad Targeting

As a show-case experiment, we created an [XRay demo service](xxx) that
continuously collects and diagnoses Gmail ads related to a particular
set of topics, including various diseases, pregnancy, race, sexual
orientation, divorce, debt, etc.  We've found some interesting
associations: a <font color="red">"Shamanic healing"</font> ad appeared
exclusively in accounts containing emails about <font color="green">depression</font>;
a number of big clothing brand ads correlate strongly with the presence of
pregnancy-related emails in a user's inbox; and a car dealership ad correlates
strongly with debt-related emails, indicating subprime targeting.

Below we discuss a few sample findings, which illustrate XRay's potential.
If you're interested in our latest data, please refer to our
[XRay demo service](xxx).


### Example Findings

We created emails focused on topics such as cancer, Alzheimer's, depression,
race, homosexuality, pregnancy, divorce, and debt.  Each email consisted
of keywords closely related to one topic (e.g., the depression-related email
included <i>depression</i>, <i>depressed</i>, and <i>sad</i>; the pregnancy
email included <i>pregnancy</i> and <i>pregnant</i>).
We then launched XRay to collect and diagnose ads shown for these emails.

The table below shows sample ads that XRay associated with
each topic.  Conservatively, we only show here ads where XRay computed very high
confidence scores.  Our [demo service](xxx) contains more data, along with
associated confidence levels.  Scroll down for  observations from our
data.

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



We make several observations:

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
ads, we developed an [attack](#attack) that illustrates the dangers of
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
we found that surprisingly many used car ads targeted the <i>debt</i> and <i>loan</i>
emails.  For example, a car dealership ad that entices the targeted users to take
a Toyota test drive using a $50 gift offering; it clearly targets the keyword
"debt" in our inbox.  Other such examples are included in the table above.
Given the recent reports about
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


<h3 id="attack"> A Potential Attack </h3>

Our realization that it is possible to target ads against sensitive topics,
including various diseases, sexual orientation, personal financial situation, etc.,
made us think about a particular attack.  Imagine an insurance company wanted to
gain insight into pre-existing conditions of its customers before signing them up.
It could create two ad campaigns -- one that targets cancer and another youth -- and
assign different URLs to each campaign.  It could then offer higher premium quotes to
visitors who come through the cancer-related ads to discourage them from signing up
while offering lower premium quotes to those who come through youth-related ads.
We believe that the potential for this attack illustrates the urgent need for increased
transparency in ad targeting.

<!--
To verify that this attack is possible, we implemented an innocuous version of it.
We created some ad campaigns, each targeted against various sensitive topics, including
cancer, depression, pregnancy, sexuality, race, etc.  Our ads clearly stated their
research-related purpose and the fact that clicking on them would leak out potentially
sensitive information about them to us.  Upon clicking on an ad, the user would be
redirected to a page that revealed to them what we knew about them from just this click.
We then asked them to fill in a form to relate their level of surprise at realizing what
we knew about them.  We retained no personally identifiable information (e.g., IP,
location, cookies, etc.) associated with the responses. -->

<!--
The table below shows our impressions, clicks, and form fill-ins for each
ad campaign, along with a few example .  XXX (1) It is possible to customize
the service to the campaign.  (2) It would be trivial to collect this
information using PII .  (3) Users are extremely surprised at realizing that they
are being targeted with various emails. XXX
-->


### Interested in Ad Targeting?  What To Do

The above findings are examples of observations one can make using XRay.
They come from our limited and somewhat ad-hoc experience with using XRay to reverse ad
targeting in Gmail for a few specific topics that we thought were interesting.  Over the
next period, we plan to run larger scale experiments to quantify some of our example-driven
observations from above.

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

