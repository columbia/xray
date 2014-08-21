class SnapshotsController < ApplicationController
  def snapshot_klass!(snpsht)
    snapshot_klass = "#{snpsht.delete(:type)}_snapshot".downcase.camelize.constantize
    snapshot_klass < Snapshot ? snapshot_klass : (raise ArgumentError)
  end

  def snapshot_klass
    snapshot_klass = "#{params[:type]}_snapshot".downcase.camelize.constantize
    snapshot_klass < Snapshot ? snapshot_klass : (raise ArgumentError)
  end

  def index
    @snapshots = snapshot_klass.page(params[:page])
    @params = params
  end

  def create
    snapshot_klass!(params).create!(params)
    head :ok
  rescue
    head :not_acceptable
  end

  def create_with_context
    context = snapshot_klass!(params['context']).create!(params['context'])
    params['snapshots'].each do |s|
      snpsht = snapshot_klass!(s).create!(s)
      snpsht.context = context
      snpsht.save
    end
    head :ok
  rescue
    head :not_acceptable
  end
end
