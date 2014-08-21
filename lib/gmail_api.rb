class GmailAPI
  class AuthError < RuntimeError; end

  def self.test
    acc = { login: "", passwd: "" }
    api = self.new(acc)
    api.login
    api.get_ads_for("the email id")
  end

  class CookieJar < Faraday::Middleware
    def initialize(app)
      super
      @cookies = {}
    end

    def pprint_meta(env, type)
      return if true

      case type
      when :request; color = :green; header = env[:request_headers]
      when :response; color = :red; header = env[:response_headers]
      end

      puts
      puts "request".send(color)
      puts "url ".send(color) + env[:url].to_s
      puts "verb ".send(color) + env[:method].to_s
      puts env[:body].to_s if type == :request && env[:method] == :post
      puts "headers ".send(color) + header.to_s
    end

    def call(env)
      set_meta(env)
      set_cookies(env)
      pprint_meta(env, :request)

      parse_cookies(env)
    end

    def cookies_for_host(env)
      @cookies ||= {}
    end

    def set_meta(env)
      env[:request_headers]['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.132 Safari/537.36'
    end

    def set_cookies(env)
      env[:request_headers]["cookie"] = cookies_for_host(env).map { |k,v| "#{k}=#{v}"}.join("; ")
    end

    def parse_cookies(env)
      response = @app.call(env)
      response.on_complete do |e|
        pprint_meta(env, :response)

        raw_array = (e[:response_headers]['set-cookie'] || "").split(",")
        array = []
        skip = false

        raw_array.each do |item|
          unless skip
            array << item
          end
          if (item =~ /(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/)
            skip = true
          else
            skip = false
          end
        end

        cookies = array.select { |x| x =~ /=/ }.map { |x| x.split(';').first.strip.split('=', 2) }
        cookies_for_host(e).merge!(Hash[cookies])
      end
      response
    end

    Faraday.register_middleware :request, :cookie_jar => lambda { self }
  end

  attr_accessor :conn

  def initialize(account)
    @conn = Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :follow_redirects, :limit => 20
      faraday.request  :cookie_jar
      faraday.adapter  :net_http_persistent
    end
    account = account.attributes unless account.class.name == "Hash"
    @acc = Hash[account.map { |k,v| [k.to_s, v] }]
  end

  def login
    response = @conn.get "https://accounts.google.com/ServiceLogin"
    raise "oops" if response.status != 200

    n = Nokogiri::HTML(response.body)
    galx = n.css('form input[name="GALX"]').attr('value').to_s

    response = @conn.post "https://accounts.google.com/ServiceLoginAuth", {
      "GALX"             => galx,
      "Email"            => @acc['login'],
      "Passwd"           => @acc['passwd'],
      "PersistentCookie" => "yes",
      "signIn" => "Sign in",
    }
    raise AuthError if response.body =~ /incorrect/
    return self
  end

  def hashify(data)
    Hash[data.map { |v| [v[0], v[1..-1]] }]
  end

  def get_ads_for(mid)
    r = @conn.get("https://mail.google.com/mail/?view=ad&th=#{mid}&search=inbox")
    ads = ExecJS.eval "eval(#{r.body[6..-1].force_encoding('UTF-8')})"
    ads = hashify(ads.first)
    items = []
    items.add  ads['fb'][0][2] rescue nil
    items.add  ads['abc'][0][0] rescue nil
    items.concat  [*ads['ads'][0]] rescue nil
    items.compact.map { |v| { :full_id     => v[7],
                              :campaign_id => v[7].split('_')[0],
                              :name        => v[0..2].join(" "),
                              :click       => v[3],
                              :url         => v[4]} }
  rescue => e
    puts "[GmailAPI] get_ads error"
    raise e
  end
end
