class RecommendationCache
  include Mongoid::Document
  include Mongoid::Timestamps

  field :recommended_item, type: String
  field :recommended_by, type: Array

  def self.get_recommended_by(rec_item)
    rec_cache_items = RecommendationCache.where(recommended_item: rec_item)
    if rec_cache_items.length == 0
      return []
    else
      return rec_cache_items.first.recommended_by
    end
  end

  def self.build_cache
    handled = 0
    r_snap_count = RecommendationSnapshot.count
    RecommendationSnapshot.each do |r_snap|
      handled += 1
      if handled % 100 == 0
        puts "Handled #{handled} / #{r_snap_count}"
      end

      if !r_snap.account.is_master
        rec_item = r_snap.get_recommended()
        rec_cache_item = RecommendationCache.where(recommended_item: rec_item)
        if rec_cache_item == []
          rec_cache_item = RecommendationCache.new
          rec_cache_item.recommended_item = rec_item
          rec_cache_item.recommended_by = []
        else
          rec_cache_item = rec_cache_item.first
        end
        if !rec_cache_item.recommended_by.include?(r_snap.get_recommended_by())
          rec_cache_item.recommended_by.push(r_snap.get_recommended_by())
        end
        rec_cache_item.save
      end
    end
  end

  def self.clear_cache
    RecommendationCache.destroy_all
  end

end
