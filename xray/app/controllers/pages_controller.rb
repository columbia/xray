class PagesController < ApplicationController
  # protect_from_forgery with: :exception
  # before_filter :authenticate_user!

  def list_kw
    @list_kw_exp = AdController.get_list_kw_exp
    name_exp = ""
    if params[:p]
      name_exp = params[:p][:selectExp]
    end

    if name_exp != ""
      temp = Hash.new(nil)
      temp["exp_name"] = name_exp
      temp["exp"] = AdController.get_info_exp(name_exp)
      temp["list"] = AdController.get_list_kw(name_exp)
      @list_kw = temp
    end
  end

  def search_kw
    @list_kw_exp = AdController.get_list_kw_exp
    name_exp = ""
    if params[:eid]
      name_exp = params[:p][:selectExp]
      results = {"email" => AdController.get_email(name_exp, params[:eid])}
      if eid != "" && name_exp != ""
        results["exp_name"] = name_exp
        results["ads"] = AdController.get_ads(name_exp, eid)
      end
      @list_ads = results
    end
  end

  def list_ads_by_kw
    if params[:subject]
      s = params[:subject]
      name_exp = params[:exp_name]
      results = {"email" => AdController.get_email(name_exp, s)}
      if s != "" && name_exp != ""
        results["exp"] = AdController.get_info_exp(name_exp)
        results["ads"] = AdController.get_ads(name_exp, s)
      end
      @params = results
    end
  end

  def search_url
    @list_kw_exp = AdController.get_list_kw_exp
    name_exp = ""

    if params[:url]
      url = params[:url]
      name_exp = params[:p][:selectExp]
      results = {"url" => params[:url]}
      if url != "" && name_exp != ""
        results["exp_name"] = name_exp
        results["ad"], results["id"], results["kw"] = AdController.get_ad_target(name_exp, url)
      end
      @list_ads = results
    end
  end

  def info_ad
    if params[:exp_name] && params[:id]
      results = {"exp_name" => params[:exp_name]}
      if params[:exp_name] != "" && params[:id] != "" && params[:email] != ""
        name_exp = Experiment.where(name: params[:exp_name]).first.recurrent_exp.base_name
        results["exp"] = AdController.get_info_exp(name_exp)
        results["email"] = AdController.get_email(name_exp, params[:email])
        results["data"] = AdController.get_info_ad(params[:exp_name], params[:id])
      end
      @info = results
    end
  end
end
