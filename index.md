---
layout: default
title: Overview
---

<p class="message" align="right">
  <i>What are <font color="red">"They"</font> doing with my
     <font color="green">Data</font>?</i>
</p>

### Tools for a Transparent Web

We live in a data-driven world. Many of the Web services, mobile apps, and
third parties we interact with daily are collecting immense amounts of
information about us -- every location, every click, every site that we visit.
They're mining our emails and documents.  And they're using all of this
information for various purposes; at times, they even share the data with
third-parties -- *all without our knowledge or consent*.

For example, did you know that some companies target ads on illness-related emails,
and if you click on them, and then authenticate to buy something, you leak out
potentially sensitive personal health information?  Or that credit companies [might
use](http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/) your
Facebook data to decide whether to give out a loan?  Or that certain travel
companies [discriminate](XXX) their prices based on user profile and location?
Maybe you already knew these things -- you probably read the news just like we do. 
But the question is: do you know when such things are happening to *you*?
Not always, we bet.

At Columbia, we have been pondering over the past several years on the following
related question:  *Can we build tools that reveal what Web services are doing
with our data*?  Just like Web services track our data, we wish to track their use
of it in turn.  For example, wouldn't it be great if we knew which emails trigger
which ads, which prior purchases trigger which recommendations or prices?  Or
whether our services share our data with third parties, and then how *those*
parties use the data?  It would be great to have such visibility, right?

We have been making great progress at building precisely such tools that are capable
of revealing how user data is being used across the various services they interact
with.  Today we are releasing our first tool, called *XRay*.  It tracks the use
of personal data on the Web and reveals it to auditors.  It can tell which specific
data items trigger which outputs, and it can track data both *within and across
arbitrary Web services*.  How do we do that?  The details are complex, but the
high-level idea is intuitive:  XRay abstracts away the complexities by looking at
Web services, and networks of collaborating Web services, as black boxes that
receive user inputs (like emails or searches) and return some outputs to the users
(like ads or prices).  XRay monitors inputs into the services, the outputs that
the services return, and then it *correlates* them.  To do so, it populates a
series of extra accounts with subsets of the inputs and then looks at the
differences and commonalities between the outputs that they get versus your
own outputs, and that's how we can tell correlation.

The big breakthrough in XRay is its robust and scalable correlation engine, which
can achieve surprisingly good accuracy for correlation on multiple services.
We've used XRay to track specific data uses on three services thus far: Gmail (reveals
which emails are used to trigger which ads), YouTube (reveals which prior
videos are used to trigger which recommendations), and Amazon (reveals which items in
a wish list are used to trigger which product recommendations).  Across all of
these very different services, our predictions are invariably 80-90% accurate
(both precision and recall).  Moreover, we discovered that tracking many forms of
targeting correlation only requires a small number of extra accounts (*logarithmic*
in terms of number of tracked inputs). We know of no other system that can achieve
this level of accuracy and scale across multiple services.  We thus deem XRay as a
major new step toward enabling Web transparency compared to the state of the art.
Read about the XRay's design and evaluation in our research
[paper]({{ site.baseurl }}/public/xray.pdf), which will appear at USENIX Security
2014 in August.

While our dreams for XRay and Web transparency are big, our prototype is still in
a research stage.  Many difficult challenges remain open for tracking data this
complex data-driven Web. A major challenge, on which we are working now, is to
ensure XRay's robustness against Web services that might wish to evade its monitoring.
Usability and ease of instantiation for a new service also remain challenging.

To spur further progress in this important, and largely unexplored, area of Web
transparency, we are making our prototype available open-source on
[GitHub](https://github.com/MatLecu/xray).  We have also packaged our XRay Gmail
prototype into a [demo service]({{ site.baseurl }}/demo/), which can already give
a unique level of transparency into Gmail's targeted ad environment to researchers
and journalists interested in this topic. For example, if you're interested in
seeing ads related to sensitive topics, such as cancer, depression, or race, visit
our [demo service]({{ site.baseurl }}/demo/.


