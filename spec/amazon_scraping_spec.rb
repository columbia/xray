require 'spec_helper'
require 'mechanize'

describe "Amazon scraping" do
  let(:a_session) { AmazonSession.new("user", "password") }
  let(:mech) do
    Mechanize.new.tap { |mech| mech.user_agent_alias = "Linux Mozilla" }
  end

  it "scrapes buy recommendations correctly" do
    ProductPool.distinct_products.each do |p_pool|
      puts "Testing #{p_pool["title"]}"
      url = session.get_desktop_url_from_mobile(p_pool["url"])
      product_page = mech.get(url)
      buy_recs = session.get_buy_recommendations(product_page)
      puts buy_recs.length
      buy_recs.length.should > -1
    end
  end

  it "scrapes view recommendations correctly" do
    ProductPool.distinct_products.each do |p_pool|
      puts "Testing #{p_pool["title"]}"
      url = a_session.get_desktop_url_from_mobile(p_pool["url"])
      product_page = mech.get(url)
      view_recs = a_session.get_view_recommendations(product_page)
      puts view_recs.length
      rec_length = view_recs.length
      rec_length.should > -1
    end
  end
end
