module JSONHelpers
  %w(get post delete option).each do |method|
    define_method(method) do |url, params={}|
      super(url, params.to_json,
            { "CONTENT_TYPE" => "application/json"})
    end
  end
end
