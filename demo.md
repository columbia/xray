---
layout: page
title: Demo
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

[Below]({{ site.baseurl }}/demo#observations) we discuss a few example
results, which illustrate XRay's potential.  If you're interested in our
latest data, please visit our <a href="http://data.lec.io/"><font color="blue"><b>live
XRay ad service</b></font></a>, which is continuously collecting ads targeted
on a number of topics.

_Disclaimer_:  All results below are focused on Gmail's ad ecosystem
because that is where we have experience.  However, we stress that
the lack of transparency is common to all Web services, mobile apps, and
third-parties involved in this data-driven Web world.  Complete
transparency is also a difficult thing to achieve.  In showing our results,
our goal is *not* to point fingers at specific service providers; rather,
we aim to illustrate with concrete examples the dangers raised by the lack
of transparency and hopefully bolster a conversation about how we might
go about improving this situation over time.


<h3 id="table">Example Results</h3>

We created emails focused on topics such as cancer, Alzheimer's, depression,
race, homosexuality, pregnancy, divorce, and debt.  Each email consisted
of keywords closely related to one topic (e.g., the depression-related email
included <i>depression</i>, <i>depressed</i>, and <i>sad</i>; the pregnancy
email included <i>pregnancy</i> and <i>pregnant</i>).
We then launched XRay to collect and diagnose ads shown for these emails.

The table below shows sample ads that XRay associated with each topic.
Conservatively, we only show here ads where XRay computed very high confidence
scores. Below the table we discuss several [observations]({{ site.baseurl }}/demo#observations)
from this data. Our <a href="http://data.lec.io/"><font color="blue"><b>XRay ad
service</b></font></a> contains more data, along with associated confidence levels.
Note that all findings we describe are results from correlation analyses
and do not imply causality.

<font size="3.5pt">

| Topic               | Ad Text                                                          |
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


<h3 id="observations">Observations</h3>

While larger-scale experience with more topics is needed to reach statistically
meaningful, quantitative conclusions, we next formulate five high-level observations:

1. <font color="red"><b>It is possible to target sensitive topics in users'
inboxes:</b></font>
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
homosexuality email.  This obscurity, coupled with the ability to target very
sensitive aspects, opens users to subtle dangers and show-cases an urgent need
for increased transparency in ad targeting, particularly for sensitive targeting.
If no keyword in the ad suggests relation with sensitive topics, a user clicking
on the ad may not realize that they could be disclosing private information to
advertisers.

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
examples of ineffective advertising.  Regardless, this finding suggests that increased
transparency may be valuable not just for users, but also for advertisers.

4. <font color="red"><b>XRay has surprisingly broad applicability:</b></font>
Looking at the ad data, we realized that XRay's potential is even greater
than providing transparency to end users.  Using it, we found a pretty interesting
form of targeting: <font color="blue"><b>subprime targeting</b></font>.  According to a
[recent NYT article](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/), our society is undergoing a new subprime loan bubble, this
time for used cars.  We were able to witness a projection of this
trend in the ads we collected.  We saw a significant number of car loan
ads that promised 100% acceptance without credit score or backing, and
which targeted specifically keywords such as *loan*, *borrow*, or *debt*.
We also saw a car dealership ad that enticed users to take a Toyota test drive
for a $50 gift card; that ad was targeting the *debt* keyword.  This suggests
that lenders don't just advertise the availability of easy loans to the general
public, they explicitly try to target population that lacks credit solvence.

5. <font color="red"><b>Targeting does not imply bad intentions:</b></font>
We believe it is important to always keep a positive attitude, hence we
wish to end by pointing out that targeting sensitive topics does not necessarily
imply bad intentions.  In our results, we have seen ads for various support
groups trying to reach relevant users through targeting (e.g., an ad for a
campaign against breast cancer targeted the keyword cancer; a number of ads
for legal counsel to deal with racial slurs at the office, etc.).  Imagine a
non-profit depression support group posted an ad on Gmail; targeting of those
users might end up reaching the vulnerable users more effectively, and perhaps
helping improve their lives sooner.  Our question is then: *In this data-driven
world, how do we think about good vs. bad uses of personal data?*  We cannot
provide such answers; instead, we provide the technology to empower users and
auditors alike to judge on a case by case basis.


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

XRay as a framework is very general and can track use of data for targeting well
beyond ads.  Read about other potential use cases in our
[research paper]({{ site.baseurl }}/public/xray.pdf) and feel free to use our
[source code](https://github.com/MatLecu/xray/) to investigate your own ideas.
Time permitting, we'd be happy to help with any customization you may need to do.

