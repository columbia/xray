# XRay: increasing the web's transparency

XRay is a research project from Columbia University that aims to improve
transparency of data usage on the web. You can learn more on our
[website](http://xray.cs.columbia.edu).

We release XRay's code as a first building block for researchers and auditors
to use and build on.  Please keep in mind that XRay is a reasearch prototype.
We release it as-is and under Apache 2.0 license.

## NOTE

We're in the process of major refactoring and code clean-up right now.  If you
plan to use our code, please consider waiting till early September to download it,
when the code will be much cleaner.

## Install and use XRay

Here are some guidelines to install and use XRay. Some things are probably outdated,
don't hesitate to shoot us an email in case of problems. We'll be revising these

### Install the necessary software on a linux machine

```
// passwd

// packages you'll need (plus some useful stuff)
sudo apt-get install zsh
sudo apt-get install git
sudo apt-get install libqt4-dev
sudo apt-get install openssl
sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev
sudo apt-get install nodejs

// install configs you like
// relog

// install redis
wget http://download.redis.io/releases/redis-2.8.5.tar.gz
tar xzf redis-2.8.5.tar.gz
cd redis-2.8.5
make
sudo make install

// install rbenv (adapt if you use bash)
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source .zshrc
// install ruby
rbenv install 1.9.3-p484
rbenv rehash
rbenv global 1.9.3-p484
rbenv shell 1.9.3-p484
rbenv rehash

//install mongodb (yes...)
http://docs.mongodb.org/manual/installation/

// clone xray
git clone git@github.com:matlecu/xray.git
gem install bundle
rbenv rehash
// install gems
bundle install

// launch mongo on the config port in config/mongoid.yml
mongod --dbpath=/home/mathias/mongodata/xray/db_data --port the_port
```

### Run an experiment

* Start Redis: `redis-server`
* Start the rails app: `rails server`
    * Use `-d` to daemonize
* Start sidekiq workers to send: `sidekiq -p <queue_name>`
    * Will launch 25 workers.
    * The queue name is `email` for sending and the experiment name for scraping.
    * You can view the sidekiq control panel at: `host:3000/sidekiq`
* Start Mongod: `mongod`
* Open a rails console: `rails c`

* Instantiate an experiment:
    ```
    exp = Experiment.create({
            # Name of the experiment.
            :name => "name",

            # Type of experiment.
            :type => "gmail",

            # Number of accounts (not counting master)
            :account_number => 10,

            # Fraction of accounts to which an email will be sent.
            :e_perc_a => 0.5})
    ```
* Assign Accounts: `exp.get_accounts`
* Add Emails: `exp.emails = EmailPool.disjoint_emails`
    * This can also be done at instantiation time or with another set of emails.
* Assign Emails: `exp.assign_emails`
* Send Emails: `exp.send_emails(true)`
    * Passing true to send emails will daemonize the process through sidekiq.
    * Passing false will block.
* Wait for a few days.
* Start sidekiq workers to scrape: `sidekiq -p <experiment_name>`
* Scrape Accounts and Measure: `exp.start_measurement(5, true)`
    * Scrape the accounts with 5 reloads asynchronously.

### Analyse data:

```
# you can check prepare_data in experiment.rb
Mongoid.with_tenant('exp_name') { EmailSnapshot.map_emails_to_exp }  # for gmail
Mongoid.with_tenant('exp_name') { Cluster.do_clustering }  # for all clusters (eg Ad and Email)
Mongoid.with_tenant('exp_name') { TargSnapshot.set_context_clusters }  # for all targeted items (eg AdSnapshot)
Mongoid.with_tenant('exp_name') { TargCluster.set_master_item }  # for all targeted clusters (eg Ad)

# if you want to auto-learn the params
Mongoid.with_tenant('exp_name') { TargCluster.compute_context_distrs }  # for all targeted clusters (eg Ad)
Mongoid.with_tenant('exp_name') { TargCluster.compute_behavior_distrs }  # for all targeted clusters (eg Ad)
Mongoid.with_tenant('exp_name') { TargCluster.compute_parameters(:type) }  # type is :behavior or :context
# set_params with the results in ad.rb or equivalent

# compute scores
Mongoid.with_tenant('exp_name') { TargCluster.recompute_scores([:behavior, :context]) }
# now you can call item.targeting_items([:behavior, :context]) to get the guesses
```
