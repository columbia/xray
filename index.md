---
layout: default
title: Overview
---

<p class="message" align="right">
  <i>What are <font color="red">"They"</font> doing with my
     <font color="green">Data</font>?</i>
</p>

### Toward a Transparent Web

We live in a data-driven world, in which many of the Web services, mobile
apps, and third parties we interact with daily are collecting immense amounts
of information about us -- every location, click, and site that we visit.
They're mining our emails and documents. And they're using all of this
information for various purposes; at times, they even share the data with
third-parties -- {\em all without our knowledge or consent}.
For example, did you know that some companies target ads on illness-related emails,
and if you click on them, and then authenticate to buy something, you leak out
potentially sensitive personal health information?  Or that credit companies [might
use](http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/) your
Facebook data to decide whether to give out a loan?  Or that certain travel
companies [discriminate](XXX) their prices based on user profile and location?
Maybe you already knew these things -- you probably read the news just like we do. 
But the question is: do you know when such things happen to {\em you}? Probably
not always.

In light of these problems, one question arises: is there a way to tell what
Web services do with our data?  Just like Web services track our data, we wish
to monitor their use of it.  For example, wouldn't it be great if we knew which
emails trigger which ads, which prior purchases trigger which recommendations
or prices?  Or whether our services share our data with third parties, and then
how *those* parties use the data?  It would be great if we had such visibility,
right?

At Columbia, we are building precisely such a system, which we call *XRay*.
It adds a level of transparency hitherto unavailable.  It tracks the use of
personal data on the Web.  It tells you which specific data items trigger which
outputs, such as ads, and it can track data both within and across arbitrary web
services.  How do we do that?  The details are complex, but the high-level
idea is intuitive:  XRay monitors inputs into the services (like emails),
the outputs that the services return (like ads), and then it *correlates* them.
To do so, it populates a series of extra accounts with subsets of the inputs and
then looks at the differences and commonalities between
the outputs that they get versus your own outputs, and that's how we can tell
correlation.  And the great thing is that we can do this surprisingly accurately:
80-90% precision and recall for all three services we've applied XRay to thus far,
Gmail, YouTube, and Amazon.  Moreover, it can do so while requiring extremely
few extra accounts (*logarithmic* in terms of number of tracked inputs).
We know of no other system that can achieve this level of accuracy and scale.
Read about the XRay's design and evaluation in our research
[paper]({{ site.baseurl }}/public/xray.pdf), which will appear at USENIX Security
2014 in August.

While our end goal is to enable transparency for the end users, our prototype is
still in early research stages.  The challenges of tracking data use in the 
uncontrolled and complex Web environment are extremely difficult, and while we've
made the first significant few advancements, we still have a long way to go.
In particular, our system can be manipulated.
Thus, at this time, we are making available our prototype and data from our
evaluation to researchers and other investigators, who can start using certain
parts of the system and improve upon others.

You can access the source code of our prototype on
[GitHub](https://github.com/MatLecu/xray). You can access the data we are gathering
about ad targeting in Gmail on our [demo page]({{ site.baseurl }}/demo/). 


