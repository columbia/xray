class AdSnapshot < Snapshot
  field :url
  field :name
  field :click
  field :account_id
  field :campaign_id
  field :full_id

  index({ campaign_id: 1 })
  index({ url: 1 })

  has_context :email_snapshot

  def redirect_url
    uri = URI.parse(CGI.parse(self["click"])["adurl"].first)
    "http://#{uri.host}#{uri.path}"
  rescue nil
  end

  def signatures
    return super if super
    [
      # self.campaign_id == "0" ? nil : self.campaign_id,
      # self.name,
      self.url,
    ].compact
  end

  def self.clean
    AdSnapshot.each { |ad| ad.destroy if ad.signatures.length == 0 }
  end
end
