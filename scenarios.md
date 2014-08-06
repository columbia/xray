---
layout: default
---

# XRay Use Cases

<p class="message">
  <i>"On a simplistic level, it is true that there are two versions on
  Facebook: the one you obsessively tend, and the hidden, deepest secret in the
  world, which is the data about you that is used to sell access to you to third
  parties like advertisers.  You will <font color="red">never see</font> that
  second kind of data about you."
  </i>
  <br />
  --- J. Lanier, <a href="http://www.amazon.com/Who-Owns-Future-Jaron-Lanier/dp/1451654960">
  Who Owns the Future?</a>
</p>

Could we ever see the hidden data that Lanier is talking about? Let's look
at four scenarios to see XRay's value added in tracing Lanier's "chain
of custody of data."

**Scenario 1: Why This Ad?**  Ann often finds her Gmail ads to be a
convenient way to discover new retail offerings.  Recently, she discussed her
ad-clicking practices with her friend Tom, a computer security expert.  Tom
warned her about potential privacy implications of clicking on ads without
knowing what data they target.  For example, if she clicks on an ad targeting
the keyword ``gay'' and then authenticates to purchase something from that
vendor, she is unwittingly volunteering potentially sensitive information to the
vendor.  Tom tells Ann that she has two options to protect her privacy.
She can either disable the ads altogether (using a system like AdBlock), or
install the XRay Gmail plugin, which uncovers targeting against her data.
Unwilling to give up ads altogether, Ann chooses the latter.  XRay clearly
annotates the ads in the Gmail UI with their target email or
combination, if any. Ann now inspects this targeting before clicking on an ad and
avoids clicking if highly sensitive emails are being targeted.

**Scenario 2: They're Targeting _What_?**
Bob, an FTC investigator, uses the XRay Gmail plugin for a different purpose:
to study sensitive-data targeting practices by advertisers. He suspects a
potentially unfair practice whereby companies use Google's ad network to
collect sensitive information about their customers. Therefore, Bob creates a
number of emails containing keywords such as "cancer," "AIDS,"
"bankruptcy," and "unemployment." He refreshes the Gmail page many
times, each time recording the targeted ads and XRay's explanations for them.
The experiment reveals an interesting result: an online insurance company,
TrustInUs.com, has targeted multiple ads against his illness-related emails.
Bob hypothesizes that the company might use the data to set higher premiums for
users reaching their site through a disease-targeted ad.  He uses XRay
results as initial evidence to open an investigation of TrustInUs.com.

**Scenario 3: What's With The New Policy?**
In Feb. 2014, it was [revealed](http://safegov.org/2014/1/31/google-admits-data-mining-student-emails-in-its-free-education-apps) based on court documents that Google could
have used institutional emails to target ads in personal accounts.
In May 2014, Google [committed](http://www.techtimes.com/articles/6334/20140502/google-we-promise-not-to-spy-on-student-email-accounts-to-deliver-ads.htm) to disable
that feature. This scenario presents an XRay-based, hypothetical approach
to investigate the original allegation.  Our goal is *not* to finger point
at Google, but rather to illustrate how XRay could be used with a concrete
example that actually happened in the past.

Carla, an investigative journalist, has set up a watcher on privacy policies
for major Web services, such as Google, Amazon, and Facebook. When a change
occurs, the watcher notifies her of the difference.  Recently, an important
sentence in Google's privacy policy has been scrapped: <i>"If you are using
Google Apps (free edition), email is scanned so we can display conceptually
relevant advertising in some circumstances. <s>Note that there is no ad-related
scanning or processing in Google Apps for Education or Business with ads
disabled.</s>"</i>

To investigate scientifically whether this omission represents a
shift in implemented policy, she obtains institutional accounts, connects them
to personal accounts, and uses XRay to detect the correlation between emails
in the institutional account and the ads witnessed by the corresponding
personal accounts.  Finding via XRay a strong correlation, Carla writes an
article to expose the policy change and its implications.

**Scenario 4: Does Delete Mean Delete?**  Dan, a CS researcher, has seen
the latest news that Snapchat, an ephemeral-image sharing Website, does not
destroy users' images after the requested timeout but instead just unlinks
them~\cite{Snapc0:Online}.  He wonders whether the reasons for this are purely
technical as the company has declared (e.g., flash wearing levels, undelete
support, spam filtering)~\cite{snapchatblog, snapchatblog2} or whether these
photos, or metadata drawn from them, are mined to target ads or other products
on the Website.  The answer will influence his decision about whether to
continue using the service. Dan instantiates XRay to track the correlation
between his expired Snapchat photos and ads.

