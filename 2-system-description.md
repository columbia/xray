---
layout: page
title: XRay
---

<p class="message" align="right">
  <i>New tool to increase the Web's <font color="red">transparency</font></i>
</p>


### The Problem

We live in a data-driven world. Many of the Web services, mobile apps, and third parties we interact with daily are collecting immense amounts of information about us -- every location, click, search, email, document, and site that we visit. And they are using all of this information for various purposes. Some uses of these uses might be beneficial for us (e.g., recommendations for new videos or songs to see); other uses may not be as beneficial. The problem is that we have <font color="blue"><i>limited visibility</i></font> into how our data is being used, and hence we are vulnerable to potential abuses.

For example, did you know that credit companies <a href="http://money.cnn.com/2013/08/26/technology/social/facebook-credit-score/" target="_blank">might be adjusting loan
offers</a>
based on your Facebook data?   Or that certain travel companies <a href="http://online.wsj.com/news/articles/SB10001424052702304458604577488822667325882" target="_blank">used to
discriminate prices</a>
based on user profile and location?  Or that some companies <a href="{{ site.baseurl }}/3-use-cases#findings" target="_blank">target ads on illness-related emails</a>, and if you click on them, you can leak sensitive information to them?  Maybe you already knew these
things in the abstract, but do you always know when such things are happening
to *you*?  Not always, we bet.

At Columbia, we have been pondering over the past several years on the following
related question: <i>Can we build tools that <font color="blue">increase visibility</font>
into what Web services are doing with users' data?</i> If Web services are tracking
our data, we wish in turn to track their use of it. For example, wouldn't it be great
if we knew which emails trigger which ads, which prior purchases trigger which
recommendations or prices? Or whether our services share our data with third parties,
and then how those parties use the data? We believe that such visibility would be
valuable for users but also to auditors, such as researchers, journalists, or
regulators, who can serve as watchdogs of this data-driven world.

Unfortunately, revealing data use in the uncontrolled Web is incredibly difficult,
and hardly any tools exist to do so.   Worse, the scientific foundations -- the
algorithms, mechanisms, and protocols -- for doing so are largely non-existent.
While some tools (e.g., <a href="https://www.eff.org/privacybadger" target="_blank">this</a>,
<a href="https://www.mozilla.org/en-US/lightbeam/" target="_blank">this</a>,
<a href="https://citp.princeton.edu/webtransparency/" target="_blank">this</a>)
exist for revealing data *collection* by Web services, none of them can reveal data *use*.
Our research, then, aims to build both the <font color="blue"><i>tools</i></font>
and the <font color="blue"><i>scientific building blocks</i></font> necessary to
reveal data use on the Web.


### XRay

Today, we are releasing <font color="blue">XRay</font>, the first tool for revealing
personal data use on the Web.  It reveals which specific data inputs (such as emails)
are used to target which outputs (such as ads).  It is general and can
track data use both within and across arbitrary Web services.  The key idea behind
XRay is to *detect targeting through black-box input/output correlation*.
XRay populates a series of extra accounts with subsets of the inputs and then
looks at the differences and commonalities between the outputs that they get
in order to obtain correlation.  This mechanism is effective at detecting
certain types of data uses, though not all.  For its details, please refer
to our [research paper]({{ site.baseurl }}/public/usenix14lecuyer.pdf), which
will appear in August at USENIX Security 2014, a top systems security conference.

Our current XRay prototype works with Gmail, YouTube, and Amazon.  It can correlate
ads in Gmail to the emails they target, and recommendations in YouTube and
Amazon based on previously viewed videos and products, respectively.  However, XRay's
correlation mechanism -- its *"brain"* -- is *service-agnostic* and can be reused
as a building block to construct future tools that reveal targeting in other services.

We evaluated XRay across the three services it currently supports.  Unlike Amazon and
YouTube, Gmail does not provide detailed explanations of its targeting, so we manually
validated XRay's correlations.  For all these very different services, XRay predicted
targeting with 80-90% accuracy without requiring a single change in its correlation
mechanisms.  Moreover, XRay we have proven both theoretically and experimentally that
XRay scales surprisingly well, requiring only a modest number of extra accounts to
track use of a large number of inputs.

We know of no other system that comes close to XRay's generality, accuracy, or
scale at detecting targeting on the Web.  We hope that its reusable components can
bolster the creation of a new generation of auditing tools that will help lift the
curtain on how personal data is being used.  We thus deem XRay as a *major new step
toward <font color="blue">increased transparency</font> in this data-driven Web*.


### What We Release

While our long-term plans for XRay and Web transparency are ambitious, our prototype is still in a research stage. Many difficult challenges remain open for revealing data use in this complex Web world, including robustness in face of malicious services, usability, and ease of instantiation on more services.
More about our prototype's limitations [here]({{ site.baseurl }}/4-gmail-demo#caveats).

To spur further progress in this important, and largely unexplored, area of Web transparency, we are releasing several artifacts:

1. A <a href="{{ site.baseurl }}/4-gmail-demo/"><font color="blue">demo service</font></a>,
which wraps our XRay Gmail prototype and can be used by researchers, journalists, and
investigators to gain visibility into Gmail's ad ecosystem.  Our experience using it
reveals some interesting associations, which we describe in [Use Cases]({{ site.baseurl }}/3-use-cases#findings).

2. Our prototype's <a href="https://github.com/matlecu/xray/"><font color="blue">source
code</font></a>, which can be used by researchers to both improve XRay and
instantiate new tools on it to reveal data targeting on new Web services.

3. Our upcoming <a href="{{ site.baseurl }}/public/usenix14lecuyer.pdf">
<font color="blue">USENIX Security paper</font></a>, which gives the necessary
details to understand our system's design, quirks, and limitations.  It should be
read before using our prototype!

