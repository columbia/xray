---
layout: page
title: Demo Service
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="red">depression</font> keyword in my inbox?!</i>
</p>


### Use Case:  Revealing Gmail Ad Targeting

As a show-case experiment, we created an XRay demo service that
continuously collects and diagnoses Gmail ads related to a particular
set of topics, including various diseases, pregnancy, race, sexual
orientation, divorce, debt, etc.  We've found some interesting
associations: a <font color="red">"Shamanic healing"</font> ad appeared
exclusively in accounts containing emails about <font color="red">depression</font>;
a number of <font color="green">clothing brand ads</font> correlate strongly
with the presence of <font color="green">pregnancy-related emails</font>
in a user's inbox; and <font color="magenta">used car ads</font> correlate
strongly with <font color="magenta">debt-related emails</font>, suggesting
subprime targeting.

Below we discuss a few example findings, which illustrate XRay's potential.
If you're interested in our latest data, please visit our
<a href="http://data.lec.io/"><font color="blue"><b>live XRay ad service</b></font></a>,
which is continuously collecting ads targeted on over a hundred topics.


### Example Findings

We created emails focused on topics such as cancer, Alzheimer's, depression,
race, homosexuality, pregnancy, divorce, and debt.  Each email consisted
of keywords closely related to one topic (e.g., the depression-related email
included <i>depression</i>, <i>depressed</i>, and <i>sad</i>; the pregnancy
email included <i>pregnancy</i> and <i>pregnant</i>).
We then launched XRay to collect and diagnose ads shown for these emails.

The table below shows sample ads that XRay associated with each topic.
Conservatively, we only show here ads where XRay computed very high confidence scores.
 Under the table, we discuss four observations from this data. Our
<a href="http://data.lec.io/"><font color="blue"><b>XRay ad service</b></font></a>
contains much more data, along with associated confidence levels.

<font size="3.5pt">

| Topic               | Ad                                                               |
| -------------------:|:---------------------------------------------------------------- |
| **Alzheimer**       | *Black Mold Allergy Symptoms? Expert to remove Black Mold.*      |
| **Alzheimer**       | *Adult Assisted Living. Affordable assisted Living.*             |
| **Cancer**          | *Ford Warriors in Pink. Join the fight.*                         |
| **Cancer**          | *Rosen Method Bodywork for physical or emotional pain.*          |
| **Depression**      | *Shamanic healing over the phone.*                               |
| **Depression**      | *Text Coach - Get the girl you want and desire.*                 |
| **African American**| *Racial Harassment? Learn your rights now.*                     |
| **African American**| *Racial Harassment. Hearing racial slurs?*                      |
| **Homosexuality**   | *SF Gay Pride Hotel. Luxury Waterfront.*                         |
| **Homosexuality**   | *Cedars Hotel Loughborough. 36 Bedrooms, restaurant, bar.*       |
| **Pregnancy**       | *Find Baby Shower Invitations. Get up to 60% off here!*          |
| **Pregnancy**       | *Ralph Lauren Apparel.  Official online store.*                  |
| **Pregnancy**       | *Bonobos Official Site. Your closet will thank you.*             |
| **Pregnancy**       | *Clothing Label-USA. Best custom woven labels.*                  |
| **Divorce**         | *Law Attorneys specializing in special needs kids education.*    |
| **Divorce**         | *Cerbone Law Firm. Helping good people thru bad times.*          |
| **Debt/broke**      | *Take a New Toyota Test Drive. Get a $50 gift card on the spot.* |
| **Debt/broke**      | *Great Credit Card Search.  Apply for VISA, Mastercard...*       |
| **Loan**            | *Car Loan without Cosigner 100% Accepted. [...]*                 |
| **Loan**            | *Car Loans w/ Bad Credit 100% Acceptance! [...]*                 |

</font>


### Example Insights

Based on our data, we make four observations:

1. <font color="red"><b>It is possible to target sensitive topics in users' inboxes:</b></font>
Many of our disease-related emails are strongly correlated with
a number of ads.  A "Shamanic healing" ad appears exclusively in accounts
containing the depression-related email, and many times in its context; ads for
assisted living services target the Alzheimer email; and a Ford campaign to
fight breast cancer targets the cancer email.
Race, homosexuality, pregnancy, divorce, and debt also attract plenty of ads.

2. <font color="red"><b>Targeting is often obscure and potentially dangerous:</b></font>
For many of the ads in the table, the association with the targeted email
is not obvious at all and would likely be indiscernable to the users.
Nothing in the "Shamanic healing" ad suggests targeting against depression;
nothing in the general-purpose clothing ads suggest targeting against pregnancy;
and nothing in the "Cedars hotel" ad suggests an orientation toward the
homosexuality email.
This obscurity, coupled with the ability to target very sensitive aspects, opens
users to subtle dangers and show-cases an urgent need for increased transparency
in ad targeting.  If no keyword in the ad suggests relation with sensitive topics,
a user clicking on the ad may not realize that they could be disclosing private
information to advertisers.

3. <font color="red"><b>Targeting sometimes misses the point:</b></font>
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
Regardless, this finding suggests that increased transparency may be valuable
not just for users, but also for advertisers.

4. <font color="red"><b>XRay has surprisingly broad applicability:</b></font>
Looking at the ad data, we realized that XRay's potential is even greater
than providing transparency to end users.  Using it, we found a pretty interesting
form of targeting: *subprime targeting*.  According to a [recent NYT
article](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/), our society is undergoing a new subprime loan bubble, this
time for used cars.  We were able to witness a projection of this
trend in the ads we collected.  We saw a significant number of car loan
ads that promised 100% acceptance without credit or backing, and which
targeted specifically keywords such as *loan*, *borrow*, or *debt*.
We also saw a car dealership ad that enticed users to take a Toyota test drive
for a $50 gift card, being targeted against *debt*.
So these lenders don't just advertise the availability of easy loans, they
explicitly target population that lacks credit solvence.

<!-- We've also seen a car dealership ad correlated strongly with the *debt*
keyword; it enticed the targeted users to take a Toyota test drive by
offering a $50 gift. -->

<!--These examples made us reflect on a new use for XRay: if
advertising is an integral part of our society, our hypothesis is that
revealing ad targeting might enable new, interesting ways to quantify trends
within the society (e.g., economic trends, political campaigns, etc.).
We leave investigation of this hypothesis for future work.-->


<!--Inspired by these ads, we developed an
[attack](#attack) that illustrates the dangers of obscure targeting.-->

<!-- 
Finally, lots of ads about stock investments were targeted against an email about debt
and personal bankruptcy.  Incidentally, searching for "end of marriage" in Google
yields only divorce-related results, suggesting that search may be more semantic
than ad targeting in this particular case.
Regardless, this finding suggests that increased transparency may be valuable
not just for users, but also for advertisers, who may wish to know how their ads
are actually being placed.
-->


<!--
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
-->

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


### Interested in Ad Targeting?  What You Can Do

The above findings are examples of observations one can make using XRay.
They come from our limited and somewhat ad-hoc experience using XRay to reverse ad
targeting in Gmail for a few specific topics that we thought were interesting.  Over the
next period, we plan to run larger scale experiments to quantify some of our
example-driven observations from above.

There are undoubtedly many more other things to try using our <a href="http://data.lec.io/">
<font color="blue">XRay ad service</font></a>
(e.g., topics on which to collect ads, observations to make from our existing data).
If you have an idea for a topic that would be interesting to track ad targeting for,
please [send us an email]({{ site.baseurl }}/team/).  We'll try to incorporate your
topic of interest into our <a href="http://data.lec.io/">
<font color="blue">XRay ad service</font></a> and make the ads targeting that topic
available to you.  Due to the volume of emails we receive, we may not be able to
respond directly to all requests.

XRay as a framework is very general and can track use of data for targeting well beyond
ads.  Read about other potential use cases in our
[research paper]({{ site.baseurl }}/public/xray.pdf).
If you have an idea for some other form of targeting to verify with it, please feel
free to use our [prototype source code](https://github.com/MatLecu/xray) to investigate
it.  Time permitting, we'd be happy to help with any customization you may need to do.

