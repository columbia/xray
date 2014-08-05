---
layout: default
title: XRay
---

<p class="message" align="right">
  <i>New tool to increase the Web's transparency.</i>
</p>


### The Problem

Many of the Web services, mobile apps, and third parties we interact with
daily collect immense amounts of information about us -- every location,
click, search, and site that we visit. They mine our emails and documents.
Occasionally, they share our information with third parties.  All of this
happens *without our knowledge or consent*. This <font color="blue">lack of
transparency</font> exposes us to unforeseen risks and abusive uses of our
data.

For example, did you know that credit companies [might be adjusting loan
offers](http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/)
based on your Facebook data?   Or that certain travel companies [used to
discriminate prices](http://online.wsj.com/news/articles/SB10001424052702304458604577488822667325882)
based on user profile and location?  Or that some companies [target ads on
illness-related emails]({{ site.baseurl }}/findings#observations), and if you click on them, you can leak sensitive information to them?  Maybe you already knew these
things in the abstract, but do you always know when such things are happening
to *you*?  Not always, we bet.

A common approach to increasing privacy is to *prevent services' use of our data*.
If you talk to a security expert, s/he might tell you to install an ad blocker,
never click on recommendations, and encrypt your emails.  But these defenses all
come with downsides.  Many of us love our recommendations for new music and
movies to watch; if we encrypt our emails we cannot search for them; and the
services we all use for free are funded, for better or worse, through this data.

Our approach to privacy is to <font color="blue">*increase transparency*</font>
of how our data is being used by the various Web services that collect it, and
enable the end users, and more importantly, auditors to judge the propriety of
personal data use on a case-by-case basis.  For example, wouldn't it be great
if we knew which emails trigger which ads so we can avoid clicking on those
that might reveal sensitive data? Or which prior purchases trigger which prices?
Or whether our services share our data with third parties, and then how *those*
parties use the data?  We believe that such visibility would be valuable for
users but also to auditors, such as researchers, journalists, or regulators,
who can serve as watchdogs of this data-driven world.

Unfortunately, revealing data use in the uncontrolled Web is incredibly difficult,
and hardly any tools exist to do so.   The science of doing so is also largely
non-existent.  The Web is a complex world, with immense scale and as many diverse
data uses as Web services.  Our research, then, aims to build both the tools and
the scientific building blocks necessary to reveal data use on the Web.



### XRay

Today, we are releasing <font color="blue"><b><i>XRay</i></b></font>, our first
transparency system for the Web.  It reveals which specific data inputs (such as
emails) are used to target which outputs (such as ads).  It is general and can
track targeting both within and across arbitrary Web services.  The key idea
behind XRay is to *detect targeting through black-box input/output correlation*.
XRay populates a series of extra accounts with subsets of the inputs and then
looks at the differences and commonalities between the outputs that they get
in order to obtain correlation.  This mechanism is effective at detecting
certain types of data uses, though not all.  For its details, please refer
to our [research paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf), which
will appear in August at USENIX Security 2014, a top systems security conference.

Scientifically, the big breakthrough in XRay is its <font color="blue">*service-independent,
accurate, and scalable correlation engine*</font>, which can be used as a
building block for revealing targeting on many services.  We initially built
XRay to correlate ads to the emails they target in Gmail, and then applied its
correlation engine *as-is* to correlate recommendations in YouTube and Amazon
based on various inputs.  Across these very different services, XRay predicted
targeting with 80-90% accuracy without a single change in its code or parameters.
Moreover, XRay scales surprisingly well, requiring only a modest number of extra
accounts to track use of a large number of inputs (logarithmic).

We know of no other system that comes close to XRay's generality, accuracy,
or scale.  We thus deem XRay as a *major new step toward <font color="blue">increased
transparency</font> in this data-driven Web*.


### Using XRay

While our long-term plans for XRay and Web transparency are ambitious, our
prototype is still in a research stage.  Many difficult challenges remain open
for revealing data use in this complex Web world, including robustness in face
of malicious services, usability, and ease of instantiation on more services.

To spur further progress in this important, and largely unexplored, area of Web
transparency, we are releasing three artifacts:

1. A <a href="{{ site.baseurl }}/gmail-demo/"><font color="blue">demo service</font></a>,
which wraps our XRay Gmail prototype and can be used by researchers, journalists, and
investigators to gain visibility into Gmail's ad ecosystem.  Using this service, we
found some pretty interesting correlations, such as lots of ads targeting
depression, cancer, and other illnesses; clothing ads targeting pregnancy; and lots
of subprime loan ads for used cars that targeted the debt and broke keywords users'
inboxes. Our <a href="{{ site.baseurl }}/findings/"><font color="blue">Gmail Findings</font></a>
page includes more results.

2. Our prototype's <a href="https://github.com/MatLecu/xray/"><font color="blue">source
code</font></a>, which can be used by researchers to both improve XRay and
instantiate new tools on it to reveal data targeting on new Web services.

3. Our upcoming <a href="{{ site.baseurl }}/public/usenix14lecuyer.pdf">
<font color="blue">USENIX Security paper</font></a>, which gives the necessary
details to understand our system's design, quirks, and limitations.  It should be
read before using our prototype!

