---
layout: default
title: Overview
---

<p class="message" align="right">
  <i>What are <font color="red">"they"</font> doing with
     <font color="red">my data</font>?</i>
</p>

### Tools for a Transparent Web

We live in a data-driven world. Most Web services, mobile apps, and
third parties we interact with daily are collecting immense amounts of
information about us -- every location, click, or site that we visit.
They are mining our emails and documents.  And they are using all of this
information for various purposes; at times, they even share the data with
third-parties -- <font color="blue">*all without our knowledge or consent*</font>.

For example, did you know that credit companies [might be adjusting loan offers](http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/) based on your Facebook
data?   Or that certain travel companies [discriminated prices](http://online.wsj.com/news/articles/SB10001424052702304458604577488822667325882)
based on user profile and location?
Or that some companies [target ads on illness-related emails]({{ site.baseurl }}/demo/),
and if you click on them, you can leak sensitive information to them?
Maybe you already knew these things in the abstract, but the question is: *Do
you know when such things are happening to you*?  Not always, we bet.

At Columbia, we have been pondering over the past several years on the following
related question:  <font color="blue">*Can we build tools that reveal what Web
services are doing with our data*</font>?  If Web services are tracking our data,
we wish in turn to track their use of it.  For example, wouldn't it be great if we
knew which emails trigger which ads, which prior purchases trigger which
recommendations or prices?  Or whether our services share our data with third
parties, and then how *those* parties use the data?  We believe that it would be
great to have such visibility.

Today we are releasing <font color="blue"><b>XRay</b></font>, a new tool that
brings an unprecedented level of transparency to today's data-driven Web by
enabling answers to such questions.  XRay tracks the use of personal data
on the Web and discerns which specific data inputs (such as emails or searches)
are used to produce which outputs (such as ads or prices).  It is very general
and can track data use both within and across arbitrary Web services.
The key idea behind XRay is quite intuitive, although its details are complex.
<font color="blue">*XRay detects data use by correlating data inputs with
outputs*</font>. It populates a series of extra accounts with subsets of the
inputs and then looks at the differences and commonalities between the outputs
that they get in order to obtain correlation.  This mechanism is effective
at detecting certain types of data uses, though not all.  For its details,
please refer to our [research paper]({{ site.baseurl }}/public/xray.pdf),
which will appear in August at USENIX Security 2014, a top systems security
conference.

The big breakthrough in XRay is its <font color="blue">*robust, accurate, 
and scalable correlation engine*</font> that applies to many services.
We initially built XRay to correlate ads to the emails they target in Gmail,
and then applied its correlation engine *as-is* to correlate recommendations
in YouTube and Amazon based on various inputs.  Across these very different
services, XRay predicted targeting with 80-90% accuracy without a single change in
its code or parameters.  Moreover, we discovered that revealing certain forms
of data use only requires a modest number of extra accounts (*logarithmic*
in terms of number of tracked inputs).  We know of no other system that
comes close to XRay's accuracy, scale, or robustness.  We thus deem XRay
as a major new step toward making the data-driven Web a more transparent place.

While our long-term plans for XRay and Web transparency are ambitious, our
prototype is still in a research stage.  Many difficult challenges remain open
for tracking data in this complex data-driven Web.  A major challenge, on which
we are working now, is to ensure XRay's robustness against Web services that
might wish to evade its monitoring.  Usability and ease of instantiation for a
new service also remain challenging.  Finally, our current prototype can detect
specific forms of data targeting, but not all.

To spur further progress in this important, and largely unexplored, area of Web
transparency, we are making our prototype available open-source on
[GitHub](https://github.com/MatLecu/xray).  We have also packaged our XRay Gmail
prototype into a <a href="{{ site.baseurl }}/demo/"><font color="blue">demo
service</font></a>, which can already give
a unique level of visibility into Gmail's targeted ad environment to researchers
and journalists interested in this topic.  For example, using this service,
we found some pretty interesting targeting cases, such as a Shamanic healer
targeting depression, clothing ads targeting pregnancy, and lots of subprime
loan ads to buy used cars targeted at users with debt or broke. Please see our
<a href="{{ site.baseurl }}/demo/"><font color="blue">demo page</font></a> for
more examples.

