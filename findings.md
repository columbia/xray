---
layout: page
title: Gmail Findings
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="red">depression</font> keyword in my inbox?!</i>
</p>

We analyzed data from an early deployment of our [XRay demo service]({{ site.baseurl }}/gmail-demo/)
and found some pretty interesting associations, which we describe here.
For example, a <font color="red">"Shamanic healing"</font> ad appeared
exclusively in accounts containing emails about <font color="red">depression</font>;
a number of <font color="green">clothing brand ads</font> correlate strongly
with the presence of <font color="green">pregnancy-related emails</font>
in a user's inbox; and <font color="magenta">used car ads</font> correlate
strongly with <font color="magenta">debt-related emails</font>, suggesting
subprime targeting.

This page first shows some [example associations]({{ site.baseurl }}/findings#table)
and then presents a few [high-level observations]({{ site.baseurl }}/findings#observations)
we were able to make from our early data.  We report our results *not* to point fingers at
Gmail; indeed, the lack of transparency is a pervasive and difficult to address problem.
Rather, we aim to illustrate the dangers raised by the lack of transparency and hopefully
bolster a conversation about how to go about improving this situation over time.
All results must be considered in the context of our prototype's
[limitations]({{ site.baseurl }}/gmail-demo#caveats).


<h3 id="table">Example Associations</h3>

The table below shows examples of topic/ad correlations XRay made.
For each topic, we were tracking an email containing keywords related to
that topic (e.g., the depression-related email included *depression*, *depressed*,
and *sad*).  We used XRay to detect correlation between emails and ads.
Conservatively, we only show here correlations that were very strong. Below the
table we derive [higher-level observations]({{ site.baseurl }}/findings#observations)
based on our data.


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

While a larger-scale experiment is required to reach statistically
meaningful, quantitative conclusions,  we would like to make here a few
high-level, example-driven observations:

1. <font color="blue"><b>It is possible to target sensitive topics in users'
inboxes:</b></font>
Many of our disease-related emails are strongly correlated with
a number of ads.  A "Shamanic healing" ad appears exclusively in accounts
containing the depression-related email, and many times in its context; ads for
assisted living services target the Alzheimer email; and a Ford campaign to
fight breast cancer targets the cancer email.
Race, homosexuality, pregnancy, divorce, and debt also attract plenty of ads.

2. <font color="blue"><b>Targeting is often obscure and potentially dangerous:</b></font>
For many of the ads in the table, the association with the targeted email
is not obvious at all and would likely be indiscernable to the users. Nothing
in the "Shamanic healing" ad suggests targeting against depression; nothing in
the general-purpose clothing ads suggest targeting against pregnancy.
This obscurity, coupled with the ability to target very sensitive aspects, opens
users to subtle dangers and show-cases an urgent need for increased transparency
in ad targeting, particularly for sensitive targeting.  If no keyword in the ad
suggests relation with sensitive topics, a user clicking on the ad may not
realize that they could be disclosing private information to advertisers.

3. <font color="blue"><b>XRay has surprisingly broad applicability:</b></font>
 Looking at the ad data, we were surprised to notice what we believe is
 a projection of a general economic trend in our society.  According to a
 [recent NYT article](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/), our society is undergoing a new subprime loan bubble,
 this time for used cars.  We saw a significant number of subprime
 ads for used cars that promised 100% acceptance without credit backing.
 Some of these ads correlated strongly with keywords such as *loan*, *borrow*,
 or *debt*.  We also saw a car dealership ad that enticed users to take a
 Toyota test drive for a $50 gift card; that ad was strongly correlated with
 the *debt* keyword.

4. <font color="blue"><b>Targeting sometimes misses the point:</b></font>
One might think that ad targeting is always precise.  However, we found quite a
few cases where targeting seemed to be done through very basic keyword matching
and completely missed the semantic meaning of the email.  For example, an email
about divorce, which happened to contain the keyword "marriage" in its body (in
the format "end of marriage"), attracted not only divorce-related ads, but also
several ads related to wedding planning and invitations.  As another example,
an email about TV shows was targeted by ads related to various brands of watches just
because it contained the word "watch" (as in "watch TV") in its body. We wonder whether
those were the placements intended by the advertisers, or whether they are examples
of ineffective advertising.


<!--
3. <font color="red"><b>Evidence of subprime targeting:</b></font>
Looking at XRay's associations, we observed what we believe could be classified as
subprime targeting.  According to a [recent NYT article](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/), our society is undergoing a new subprime loan bubble, this
time for used cars.  We were able to witness a projection of this trend in
the ads we collected.  We saw a significant number of car loan ads that promised
100% acceptance without credit score or backing, and which targeted specifically
keywords such as *loan*, *borrow*, or *debt*.  We also saw a car dealership ad
that enticed users to take a Toyota test drive for a $50 gift card; that ad was
targeting the *debt* keyword.  This suggests that these ads don't just advertise
the availability of easy loans to the general public, they explicitly seek out
population that lacks credit solvence.

4. <font color="blue"><b>Targeting does not imply bad intentions:</b></font>
We believe it is important to always keep a positive attitude, hence we
wish to point out that targeting sensitive topics does not necessarily
imply bad intentions.  In our results, we have seen ads for various support
groups trying to reach relevant users through targeting (e.g., an ad for a
campaign against breast cancer targeted the keyword cancer; a number of ads
for legal counsel to deal with racial slurs at the office, etc.).  Imagine a
non-profit depression support group posted an ad on Gmail; targeting of those
users might end up reaching the vulnerable users more effectively, and perhaps
help improve their lives sooner.
-->

### Interested in Ad Data?  Visit our Demo Service

The above observations were reached from an early, small-scale deployment of
our system.  Our
<a href="{{ site.baseurl }}/gmail-demo/"><font color="blue"><b>XRay demo service</b></font></a>
has since been collecting much more data, which we invite you to visit to
draw your own observations about Gmail's ad ecosystem.

If you have an idea for a new topic that would be interesting to track ad
targeting for, please [send us an email]({{ site.baseurl }}/team/).  We'll try to
incorporate your topic of interest into our service and make the ads
targeting that topic available to you.  Due to the volume of emails we receive,
we may not be able to respond directly to all requests.

