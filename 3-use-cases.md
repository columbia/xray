---
layout: page
title: Use Cases
---

<p class = "message" align="right">
    <i><font color="red">"Shamanic healing"</font> ad targets
       <font color="red">depression</font> keyword in my inbox?!</i>
</p>

XRay can be used to increase user awareness about how their data is being used,
as well as provide much needed tools for auditors seeking to keep that use under
scrutiny (e.g., FTC investigators, researchers, or journalists).  You can find
some powerful example use cases we envision XRay supporting in the future
[here]({{ site.baseurl }}/scenarios/).

This page shows some example associations and some of their high-level implications.
Our purpose is to illustrate through examples the great potential inherent in the
targeting data XRay is gathering.


<h3 id="findings">Example Associations</h3>

The table [below](#table) shows examples of topic/ad correlations XRay
made.  For each topic, we were tracking targeting of an email containing
keywords related to that topic (e.g., the depression-related email
included *depression*, *depressed*, and *sad*).  We used XRay to
detect correlation between emails and ads. Conservatively, we only
show here correlations that were very strong.
We think we can already formulate some example-driven observations:

**Obs. 1: It is definitely possible to target sensitive topics in users' inboxes:**
Most of the topics we tracked could be considered sensitive (e.g., various
diseases, pregnancy, race, sexual orientation, divorce, loans, etc.); they all
got ads.  A shamanic healing ad appears exclusively in accounts containing the
depression-related email, and many times in its context; ads for assisted living
services strongly correlates with the Alzheimer email; and a Ford campaign to
fight breast cancer correlates with the cancer email.  See other examples in
the [table](#table).

**Obs. 2: Targeting is often obscure and potentially dangerous:**
Look at many of the ads in the table; is their targeting obvious to you?
We don't think so. For example, nothing in the shamanic healing ad suggests
association with the depression keyword. In such cases, users might click
on an ad not realizing they might be disclosing private information to
advertisers. Imagine an insurance company wanting to learn about pre-existing
conditions of its customers before signing them up. The company could create
two ad campaigns, one targeting cancer and the other youth, and assign
different URLs to each campaign. It could then offer higher premium
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

As an example, we have seen signs of what could be <font color="blue">subprime
targeting</font>.  According to a recent
<a href="http://dealbook.nytimes.com/2014/07/19/in-a-subprime-bubble-for-used-cars-unfit-borrowers-pay-sky-high-rates/?_php=true&_type=blogs&_r=0" target="_top">NYT article</a>,
our society is undergoing a subprime loan bubble for used cars.
In our dataset, we've come across a number of loan ads for buying used
cars that promised 100% acceptance without credit checks. Many of these
strongly correlated with the presence of keywords such as *debt*, *borrow*, or
*loan* in user inboxes.  For example, in the table below, you can see a car
dealership ad that entices users to take a Toyota test drive for $50 strongly;
that ad correlates with the *debt* keyword.  XRay cannot confirm whether
the ad correlations with debt-related keywords were the result of intentional
targeting of debt-ridden populations by the lenders,
however the example does illustrate how XRay can be used to discover interesting
trends and help obtain quantitative support for them.

<a name="table"></a>**The Table:**

<font size="3.5pt">

<table style="width:100%">
  <tr>
    <th>Topic</th>
    <th>Ad Text</th> 
  </tr>
  <tr>
    <td>Alzheimer</td>
    <td>Black Mold Allergy Symptoms? Expert to remove Black Mold.</td> 
  </tr>
  <tr>
    <td>Alzheimer</td>
    <td>Adult Assisted Living. Affordable assisted Living.</td> 
  </tr>
  <tr>
    <td>Cancer</td>
    <td>Ford Warriors in Pink. Join the fight.</td> 
  </tr>
  <tr>
    <td>Cancer</td>
    <td>Rosen Method Bodywork for physical or emotional pain.</td> 
  </tr>
  <tr>
    <td>Depression</td>
    <td>Shamanic healing over the phone.</td> 
  </tr>
  <tr>
    <td>Depression</td>
    <td>Text Coach - Get the girl you want and desire.</td> 
  </tr>
  <tr>
    <td>African American</td>
    <td>Racial Harassment? Learn your rights now.</td> 
  </tr>
  <tr>
    <td>African American</td>
    <td>Racial Harassment. Hearing racial slurs?</td> 
  </tr>
  <tr>
    <td>Homosexuality</td>
    <td>SF Gay Pride Hotel. Luxury Waterfront.</td> 
  </tr>
  <tr>
    <td>Homosexuality</td>
    <td>Cedars Hotel Loughborough. 36 Bedrooms, restaurant, bar.</td> 
  </tr>
  <tr>
    <td>Pregnancy</td>
    <td>Find Baby Shower Invitations. Get up to 60% off here!</td> 
  </tr>
  <tr>
    <td>Pregnancy</td>
    <td>Ralph Lauren Apparel.  Official online store.</td> 
  </tr>
  <tr>
    <td>Pregnancy</td>
    <td>Bonobos Official Site. Your closet will thank you.</td> 
  </tr>
  <tr>
    <td>Pregnancy</td>
    <td>Clothing Label-USA. Best custom woven labels.</td> 
  </tr>
  <tr>
    <td>Divorce</td>
    <td>Law Attorneys specializing in special needs kids education.</td> 
  </tr>
  <tr>
    <td>Divorce</td>
    <td>Cerbone Law Firm. Helping good people thru bad times.</td> 
  </tr>
  <tr>
    <td>Debt/broke</td>
    <td>Take a New Toyota Test Drive. Get a $50 gift card on the spot.</td> 
  </tr>
  <tr>
    <td>Debt/broke</td>
    <td>Great Credit Card Search.  Apply for VISA, Mastercard...</td> 
  </tr>
  <tr>
    <td>Loan</td>
    <td>Car Loan without Cosigner 100% Accepted. [...].</td> 
  </tr>
  <tr>
    <td>Loan</td>
    <td>Car Loans w/ Bad Credit 100% Acceptance! [...].</td> 
  </tr>
</table>

</font>

Note: We report these examples results *not* to point fingers at Gmail
or any advertisers; indeed, the lack of transparency is a pervasive and
difficult problem.  Rather, we aim to illustrate the dangers raised
by the lack of transparency in targeted ad placement and hopefully bolster
a conversation about how to go about improving this situation over time.
