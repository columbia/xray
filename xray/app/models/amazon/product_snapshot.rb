class ProductSnapshot < Snapshot

  field :title
  field :url
  field :tmp_match_group

  def signatures
    return super if super
    if self.tmp_match_group
      return [self.tmp_match_group.to_s]
    else
      return [self.url]
    end
    #[self.tmp_match_group.to_s || self.url]
  end

  def get_product_snapshots_with_account(acc)
    ret_snapshots = []
    Mongoid.with_tenant(Amazon.amazon_db) do 
      ProductSnapshot.each do |ps|
        if ps.account == acc
          ret_snapshots.push(ps)
        end
      end
    end
    return ret_snapshots
  end

  def get_product_title()
    return object["title"]
  end
end

