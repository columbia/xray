FactoryGirl.define do
  sequence(:ad_snapshot_inner_id)
  sequence(:email_snapshot_id)

  factory :ad do
  end

  factory :ad_snapshot do
    ignore do
      email_sn    { create(:email_snapshot) }
      ad_sn_inner_id { generate(:ad_snapshot_inner_id) }
    end

    account     { email_sn.account }
    context { email_sn }
    signatures  { [ "#{ad_sn_inner_id}" ] }
  end

  factory :email_snapshot do
    ignore do
      email_snapshot_id { generate(:email_snapshot_id) }
      title    { "title #{email_snapshot_id}" }
    end

    account
    exp_e_id { email_snapshot_id }
    subject { title }
  end

  factory :account_group do
  end

  factory :account do
  end

  #Amazon specific factories.
  sequence(:product_snapshot_id)
  factory :product_snapshot do
    ignore do
      product_id { generate(:product_snapshot_id) }
    end
    account
    object {{
      "url" => "http://www.amazon#{product_id}.com",
      "title" => "product#{product_id}"
    }}
  end

  sequence(:recomendation_snapshot_id)
  sequence(:product_gen_id)
  factory :recommendation_snapshot do
    ignore do
      product_id { generate(:product_gen_id) }
      recommendation_id { generate(:recommendation__snapshot_id) }
    end
    account
    object {{
      "comment" => "product#{product_id}",
      "recommended" => "recommended#{recommendation_id}"
    }}
  end

end
