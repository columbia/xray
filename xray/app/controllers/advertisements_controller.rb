class AdvertisementsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @advertisements = Advertisement.all
  end

  def new
    @advertisement = Advertisement.new
  end

  def create
    @advertisement = Advertisement.new(params[:advertisement])

    url = params['advertisement']['link']

    # binding.pry

    sn_cand = AdSnapshot.where( :url => url ).first

    if !sn_cand
      render :text => "Not found"
    else
      e_cand = sn_cand.snapshot_cluster.targeting_items([:context, :behavior])
      e_cand_titles = e_cand.map { |eid| Email.where( id: eid ).first.snapshots.first.subject }
      if e_cand_titles.empty?
        render :text => "Non-targeted:::Good news! This ad is not targeted by your personal content."
      else
        retVal = ''
        e_cand_titles.each {
          |t|
          if retVal != ''
            retVal = "#{retVal}, #{t}"
          else
            retVal = t
          end
        }
        render :text => "Targeted:::You are seeing this ad because you have emails that discuss the following topics: #{retVal}"
      end
    end
  end

  def edit
    @advertisement = Advertisement.find(params[:id])
  end

  def destroy
    @advertisement = Advertisement.find(params[:id])
    @advertisement.destroy

    redirect_to advertisements_path
  end

  def update
    @advertisement = Advertisement.find(params[:id])

    if @advertisement.update(params[:advertisement].permit(:title, :text, :link))
      redirect_to @advertisement
    else
      render 'edit'
    end
  end

  def show
    @advertisement = Advertisement.find(params[:id])
  end

  private

  def advertisement_params
    params.require(:advertisement).permit(:title, :text, :link)
  end
end
