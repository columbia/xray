class GmailLogin
  include Capybara::DSL

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  attr_accessor :gmail
  attr_accessor :voice
  def initialize
    # Capybara.default_wait_time = 30
    @gmail = Capybara::Session.new(:selenium)    
  end

  def unblock_account(account)
    login!(@gmail, account)
    @gmail.click_on 'Skip' rescue nil
    @gmail.find('div.T-I.J-J5-Ji.T-I-atl.L3', :text => 'Okay').click rescue nil
    @gmail.find('div#ok', :text => 'Okay, got it!').click rescue nil
  end

  def login!(session, account)
    session.visit('https://gmail.com')
    session.within("form#gaia_loginform") do
      session.fill_in 'Email', :with => account[:login]
      session.fill_in 'Passwd', :with => account[:passwd]
    end
    session.click_on 'Sign in'
  end

  def clean_gmail
    @gmail.driver.browser.manage.delete_all_cookies
    @gmail.reset!
  end

  def self.unblock_all_accounts
    Mongoid.with_tenant('fishy_kw') do
    GoogleAccount.each do |acc|

      # GoogleAccount.each do |acc|
        # next if acc.checked
      begin
        i = self.new
        i.unblock_account(acc)
        sleep 1
        i.clean_gmail
      rescue
        puts acc.to_s
      end
        # acc.checked = true
        # acc.save
      end
    end
  end
end
