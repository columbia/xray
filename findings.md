---
layout: page
title: Results
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="red">depression</font> keyword in my inbox?!</i>
</p>

We analyzed data from an early deployment of our [XRay demo service]({{ site.baseurl }}/gmail-demo/).  While our data is too small scale to reach definite conclusions,
we did observe some pretty interesting associations.
For example, a <font color="red">"Shamanic healing"</font> ad appeared
exclusively in accounts containing emails about <font color="red">depression</font>;
a number of <font color="green">clothing brand ads</font> correlate strongly
with the presence of <font color="green">pregnancy-related emails</font>
in a user's inbox; and <font color="magenta">used car ads</font> correlate
strongly with <font color="magenta">debt-related emails</font>, suggesting
subprime targeting.

This page shows some example associations we found, and some high-level
observations we draw from them.


<h3 id="table">Example Associations</h3>

The table below shows examples of topic/ad correlations XRay made.
For each topic, we were tracking targeting of an email containing
keywords related to that topic (e.g., the depression-related email
included *depression*, *depressed*, and *sad*).  We used XRay to
detect correlation between emails and ads. Conservatively, we only
show here correlations that were very strong. We next derive
[higher-level observations]({{ site.baseurl }}/findings#observations)
based on our data.

We've just started to peek into the service's data and we've already
seen a lot of interesting things.  While thorough investigations are
needed in order to reach scientific conclusions, we think we can already
formulate some example-driven observations:

**Obs. 1: It is definitely possible to target sensitive topics in users' inboxes:**
Most of the topics we tracked could be considered sensitive (e.g., various
diseases, pregnancy, race, sexual orientation, divorce, loans, etc.); they all
got ads.  A shamanic healing ad appears exclusively in accounts containing the
depression-related email, and many times in its context; ads for assisted living
services strongly correlates with the Alzheimer email; and a Ford campaign to
fight breast cancer correlates with the cancer email.  See other examples in
the table.

**Obs. 2: Targeting is often obscure and potentially dangerous:**
For many ads, targeting was extremely obscure and, we believe, non-obvious to 
end-users. For example, nothing in the shamanic healing ad suggests association
with the depression keyword; nothing in the clothing-related ads suggest association
with pregnancy. In such cases, users might click on an ad not realizing they might be
disclosing private information to advertisers. Imagine an insurance company wanting
to learn about pre-existing conditions of its customers before signing them up.
The company could create two ad campaigns, one targeting cancer and the other youth,
and assign  different URLs to each campaign. It could then offer higher premium
quotes to users coming  in from the cancer-related ads to discourage them from
signing up while offering lower premium quotes to people coming in from the
youth-related ads.

**Obs. 3: XRay can signal potential data abuses:**
We all know that obscurity can breed abuse.  Thus far, revealing data abuse
in large systems like Gmail's ad ecosystem has been next to impossible, because
society lacked tools for revealing such abuse.  Our experience with XRay
suggests that it can help change this situation by enabling investigators to
obtain quantified hints for data abuses, which they can then use as grounds
for full-fledged investigations.  Just by peeking at the targeting data we
have seen some signs of abuse, whereby vulnerable populations being targeted
with ads for questionable services.

As an example, we have seen signs of what could be *subprime targeting*.
According to a recent [New York Times article](http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/?_php=true&_type=blogs&_r=0),
our society is undergoing a subprime loan bubble for used cars.
In our dataset, we've come across a number of loan ads for buying used
cars that promised 100% acceptance without credit checks. Many of these
strongly correlated with the presence of keywords such as *debt*, *borrow*, or
*loan* in user inboxes.  For example, in the table below, you can see a car
dealership ad that entices users to take a Toyota test drive for $50 strongly;
that ad correlates with the *debt* keyword.  XRay alone cannot confirm whether
the ad correlations with debt-related keywords were the result of intentional
targeting of debt-ridden populations by the lenders, however the example
does illustrate how XRay can be used to discover interesting trends and help
obtain some quantification of them.



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


### Interested in Ad Data?  Visit our Demo Service

The above observations were reached from an early look at XRay's data.
Our <a href="{{ site.baseurl }}/gmail-demo/"><font color="blue"><b>XRay demo
service</b></font></a> has since been collecting much more data, which we
invite you to visit to draw your own observations about Gmail's ad ecosystem.

If you have an idea for a new topic that would be interesting to track ad
targeting for, please [send us an email]({{ site.baseurl }}/team/).  We'll try to
incorporate your topic of interest into our service and make the ads
targeting that topic available to you.  Due to the volume of emails we receive,
we may not be able to respond directly to all requests.

