require 'mechanize'
require 'nokogiri'

class AmazonSession
  @@session_id = 0
  @@recommendation_refreshes = 70
  @@mozilla_agent = "Linux Mozilla"
  @@amazon_home = "http://www.amazon.com"
  @@wish_list_creation_url = "http://www.amazon.com/gp/registry/wishlist"
  @@wish_list_url = "http://www.amazon.com/gp/registry/wishlist/"
  @@recommendation_url = "http://www.amazon.com/gp/yourstore/recs/"
  @@recommendation_sleep_sec = 5

  def initialize(username, password)
    @username = username
    @password = password
    @id = @@session_id
    @@session_id += 1
    setup_mech(@id)
    @logged_in = false
  end

  def setup_mech(session_id)
    @mech = Mechanize.new
    @mech.user_agent_alias = @@mozilla_agent
    @mech.log = Logger.new AmazonSession.get_amazon_log(session_id)
  end

  def login()
    attempts = 0
    attempts_limit = 10
    while !@logged_in && attempts < attempts_limit
      attempts += 1
      puts "Logging in to #{@username}."
      home_page = @mech.get(@@amazon_home)
      sign_in_link = home_page.links.select{|x| x.to_s.index("Sign in") != nil}.first
      sign_in_page = sign_in_link.click()
      sign_in_form = sign_in_page.forms.select{|x| x.name == "signIn"}.first
      @mech.cookie_jar.save "/tmp/cookies1"
      sign_in_form["email"] = @username
      sign_in_form["password"] = @password
      signed_in_page = sign_in_form.submit()
      confirmed = confirm_login(signed_in_page)
      @mech.cookie_jar.save "/tmp/cookies2"
      @logged_in = true
      if !confirmed
        signed_in_page.save("/tmp/sign_in_failure.html")
      end
      return confirmed
    end
  end

  def confirm_login(signed_in_page)
    captcha_reg = /To better protect your account/
    signed_in_content = signed_in_page.content
    signed_in_match = captcha_reg.match(signed_in_content)
    if signed_in_match == nil
      return true
    else
      puts "Failed to log in due to captcha."
      return false
    end
  end

  def create_wish_list()
    login()
    begin
      puts "creating wish list."
    wish_list_creation_page = @mech.get(@@wish_list_creation_url)
    submit_form = wish_list_creation_page.form_with(:action => "/gp/registry/wishlist/ref=cm_wl_rl-create-pub-list")
    wish_list_created_page = submit_form.click_button()
    rescue
      puts "Failed to create wish list."
      wish_list_creation_page.save("/tmp/wish_list_fail.html")
      delete_wishlist()
    end
  end

  def get_recommendation_url(index)
    page_id = index * 15 + 1
    rec_url = "http://www.amazon.com/gp/yourstore/ref=pd_ys_next_16?ie=UTF8&listOffset=#{page_id}&nodeID=&parentID=&rOffset=#{page_id}&tsOffset=1&viewID=recs"
    return rec_url
  end

  def parse_recommendations(rec_page, account, tenant)
    # TODO: Fix hacky regex parsing because it is a very bad idea.
    return_recommendations = []
    rec_page_content = rec_page.content()
    strong_regex = /<strong>(.*?)<\/strong>/
    index = 0
    rec_scan = rec_page_content.scan(strong_regex).select{|x| x[0].index("Price:") == nil && x[0].index("Sale:") == nil}
    if rec_scan.length == 30
      while index < rec_scan.length
        recommendation = {"recommended" => rec_scan[index][0], "comment" => rec_scan[index + 1][0]}
        #Mongoid.with_tenant(tenant) do
        begin
          r_snap = RecommendationSnapshot.new(comment: recommendation["comment"],
                                              recommended: recommendation["recommended"],
                                              account: account,
                                              object: recommendation,
                                              iteration: 1)
          r_snap.save!
          account.snapshots.push(r_snap)
          return_recommendations.push(r_snap)
        rescue Encoding::UndefinedConversionError
          #puts "Failed to encode recommendation."
          #puts "Found #{RecommendationSnapshot.count} recommendations.\n"
        end
        index += 2
        #end
      end
    else
    end
    return return_recommendations
  end

  def get_recommendations(account, tenant)
    puts "Finding recommendations"
    login()
    recommendations = Array.new(@@recommendation_refreshes){|i| []}
    rec_page = @mech.get(@@recommendation_url)
    (0..(@@recommendation_refreshes - 1)).to_a.each do |x|
      rec_url = get_recommendation_url(x)
      begin
        rec_page = @mech.get(rec_url)
        parsed_recommendations = parse_recommendations(rec_page, account, tenant)
        recommendations[x] = parsed_recommendations
      rescue Mechanize::ResponseCodeError
        puts "Response code error fetching: #{rec_url}"
        rec_page.save("/tmp/rec_code_error.html")
      end

    end
    return recommendations.flatten
  end

  def get_wish_list_button2(product_page)
    begin
      wish_list_form = nil
      wish_list_button = nil
      found = false
      wish_list_forms = product_page.forms_with(:action => /aw_bb_novar/)

      wish_list_forms.each do |wlf|
        button = wlf.button_with(:value => /Add to Wish/)
        if button != nil && !found
          wish_list_form = wlf
          wish_list_button = button
          found = true
        end
      end
      return wish_list_form, wish_list_button
    rescue
      return nil, nil
    end
  end

  def get_wish_list_button1(product_page)
    begin
      wish_list_form = product_page.form_with(:id => /addToWishlist/)
      wish_list_button = wish_list_form.button_with(:name => /wishlistSubmit/)
      return wish_list_form, wish_list_button
    rescue
      product_page.save("/tmp/failed_product_page.html")
      puts "get wish list button 1 failed."
      return nil, nil
    end
  end

  def get_wish_list_button(product_page)
    wish_list_add = get_wish_list_button1(product_page)
    #if wish_list_add[0] == nil || wish_list_add[1] == nil
    #  return get_wish_list_button2(product_page)
    #end
    return wish_list_add
  end

  def get_desktop_url_from_mobile(mobile_url)
    url_reg = /http:\/\/www.amazon.com\/gp\/aw\/d\/(.+)$/
    match_url = url_reg.match(mobile_url)
    base_url = "http://www.amazon.com/gp/product/"
    if match_url != nil
      p_url = "#{base_url}#{match_url[1]}"
    else
      p_url = base_url
    end
    return p_url
  end

  def add_item_to_wishlist(product)
    login()
    begin
      #puts "adding: #{product.title}"
      product_page = @mech.get(product.url)
      wish_list_add = get_wish_list_button(product_page)
      wish_list_form = wish_list_add[0]
      wish_list_button = wish_list_add[1]

      wish_list_form.click_button(wish_list_button)
      return true
    rescue
      puts "Failed to add #{product.url}."
      product_page.save!("/tmp/#{product.title.gsub(" ", "")}_failed.html")
      return false
    end
  end

  def self.extract_title(rec)
    if rec.include?("span")
      span_reg = /<\s*span\s+title\s*=\s*"(.*)"/
      span_match = span_reg.match(rec)
      if span_match != nil
        return span_match[0]
      else
        return rec
      end
    else
      return rec
    end
  end

  def self.get_product_recommendations(product_page, div_id)
    return_recs = Set.new
    session_div = product_page.search("//div[@id='#{div_id}']")
    li = session_div.search("//li")
    view_recs = li.search("//div[starts-with(@class, 'new-faceout')]")[0..5].map{|vr| vr.element_children().first()}
    view_recs.each do |vr|
      rec = extract_title(vr.to_s.split("\n").last.gsub(/^\s*/, "").gsub(/\s*<\/a>\s*$/, ""))
      return_recs.add(rec)
    end
    return return_recs
  end

  def get_view_recommendations(product_page)
    return AmazonSession.get_product_recommendations(product_page, "sessionShvl")
  end

  def push_next_button(product_page)
    next_link = product_page.link_with(:class => "next-button")
    next_page = next_link.click()
    return next_page
  end

  def get_buy_recommendations(product_page)
    refreshes = 10
    return_recs = []
    (1..refreshes).to_a.each do |x|
      return_recs += AmazonSession.get_product_recommendations(product_page,
                                                              "purchaseShvl").to_a
      #product_page = push_next_button(product_page)
      sleep 5
    end
    return return_recs
  end

  def collect_product_page_recommendations(product, account, p_snap)
    refreshes = 1
    login()
    product_url = get_desktop_url_from_mobile(product.url)
    (1..refreshes).to_a.each do |x|
      product_page = @mech.get(product_url)
      buy_recommendations = get_buy_recommendations(product_page)
      view_recommendations = get_view_recommendations(product_page)
      puts "Found #{buy_recommendations.count} buy recs."
      buy_recommendations.each do |buy_rec|
        br = BuyRecommendation.new(viewed_product_title: product.title,
                                   recommended_product_title: buy_rec,
                                   account: account, iteration: 1,
                                   object: buy_rec,
                                   context: p_snap)
        br.save!
      end
      view_recommendations.each do |view_rec|
        vr = ViewRecommendation.new(viewed_product_title: product.title,
                                   recommended_product_title: view_rec,
                                   account: account, iteration: 1,
                                   object: view_rec,
                                   context: p_snap)
        vr.save!
      end
    end
  end

  def delete_wishlist(title, url)
    puts "Deleing wish list"
    login()
    puts "Fetching wish list page."
    wish_list_page = @mech.get(@@wish_list_url)
    
    deletions = 0
    puts "Getting wish list links."
    wish_list_page.links_with(:text => /Delete item/).each do |delete_link|
      puts "Deleting item: #{deletions}"
      delete_link.click()
      deletions += 1
    end

    wish_list_page = @mech.get(@@wish_list_url)
    manage_list_link = wish_list_page.link_with(:text => /Manage this/)
    manage_list_page = manage_list_link.click()
    delete_list_link = manage_list_page.link_with(:text => /Delete this list/)
    deletion_confirmation_page = delete_list_link.click()
    deletion_confirmation_link = deletion_confirmation_page.link_with(:href => /confirmed/)
    deletion_confirmation_link.click()
  end

  def get_wishlist_items()
  end

  def self.get_amazon_log(session_id)
    return File.join(Rails.root, "log", "amazon_#{session_id}.log")
  end

  def self.get_amazon_cookie_file(session_id)
    return File.join(Rails.root, "log", "amazon_#{session_id}_cookies.html")
  end

end
