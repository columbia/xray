---
layout: default
title: Overview
---

<p class="message" align="right">
  <i>What are <font color="red">"They"</font> doing with my
     <font color="green">Data</font>?</i>
</p>

### Tools for a Transparent Web

We live in a data-driven world. Most Web services, mobile apps, and
third parties we interact with daily are collecting immense amounts of
information about us -- every location, every click, every site that we visit.
They are mining our emails and documents.  And they are using all of this
information for various purposes; at times, they even share the data with
third-parties -- <font color="red">*all without our knowledge or consent*</font>.

For example, did you know that some companies target ads on illness-related emails,
and if you click on them, you can leak out sensitive information to them?
Or that credit companies [might use](http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/) your Facebook data to decide whether to give out a loan? 
Or that certain travel companies [discriminate](http://online.wsj.com/news/articles/SB10001424052702304458604577488822667325882) their prices based on
user profile and location?  Maybe you already knew these things in the abstract
-- you probably read the news just like we do.  But the question is: do you know
when such things are happening to *you*?  Not always, we bet.

At Columbia, we have been pondering over the past several years on the following
related question:  *Can we build tools that reveal what Web services are doing
with our data*?  If Web services are tracking our data, we wish in turn to track
their use of it.  For example, wouldn't it be great if we knew which emails trigger
which ads, which prior purchases trigger which recommendations or prices?  Or
whether our services share our data with third parties, and then how *those*
parties use the data?  It would be great to have such visibility, right?

Our research has resulted in great progress toward creating tools that can
answer precisely such questions and provide an unprecedented level of
transparency for this data-driven Web.

Today we are releasing our first tool,
<font color="green"><b>XRay</b></font>, which tracks the use of personal data
on the Web and reveals it to users or auditors. It can tell which specific
data items trigger which outputs, and it can track data both *within and across
arbitrary Web services*.  How do we do that? The details are complex, but the
high-level idea is intuitive:  XRay monitors data inputs into the services
(like emails or searches), the outputs that the services return (such as ads or
prices), and then it *correlates* them. To do so, it populates a series of extra
accounts with subsets of the inputs and then looks at the differences and
commonalities between the outputs that they get versus your own outputs, and
that's how it can diagnose the outputs you're seeing.  For more details,
please refer to our [research paper]({{ site.baseurl }}/public/xray.pdf),
which will appear in August at USENIX Security 2014, a top systems security
conference.

The big breakthrough in XRay is its <font color="green">*robust and scalable
correlation engine*</font>, whose correlations are surprisingly accurate on
many services.  We initially built XRay to correlate ads to the emails they
target in Gmail, and then applied its correlation engine *as-is* to correlate
recommendations in YouTube and Amazon based on various inputs.  Across these
very different services, XRay predicted targeting with 80-90% accuracy
without a single change in its code or parameters.
Moreover, we discovered that revealing many forms of data use only
requires a small number of extra accounts (*logarithmic* in terms of number of
tracked inputs). We know of no other system that can achieve this level of
accuracy and scale across multiple services.
We thus deem XRay as a major new step toward making the data-driven Web a more
transparent place.

While our dreams for XRay and Web transparency are grand, our prototype is still
in a research stage.  Many difficult challenges remain open for tracking data in
this complex data-driven Web.  A major challenge, on which we are working now, is to
ensure XRay's robustness against Web services that might wish to evade its monitoring.
Usability and ease of instantiation for a new service also remain challenging.

To spur further progress in this important, and largely unexplored, area of Web
transparency, we are making our prototype available open-source on
[GitHub](https://github.com/MatLecu/xray).  We have also packaged our XRay Gmail
prototype into a [demo service]({{ site.baseurl }}/demo/), which can already give
a unique level of visibility into Gmail's targeted ad environment to researchers
and journalists interested in this topic.  For example, if you're interested in
seeing ads targeting very sensitive topics in users' inboxes, such as cancer,
depression, or race, visit our [demo service]({{ site.baseurl }}/demo/).

