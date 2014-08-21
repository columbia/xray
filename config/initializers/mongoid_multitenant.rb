module Mongoid
  class << self; attr_accessor :tenant_mutex; end
  self.tenant_mutex = Mutex.new

  def self.tenant_name
    Thread.current[:database] || Mongoid.default_session.options[:database]
  end

  def self.with_tenant(*args, &block)
    # self.tenant_mutex.synchronize do
      self._with_tenant(*args, &block)
    # end
  end

  def self._with_tenant(name, &block)
    name = Rails.env.test? ? "#{name}_test" : name
    old_db, Thread.current[:database] = Thread.current[:database], name
    block.call
  ensure
    Thread.current[:database] = old_db
  end

  def self.create_indexes_everywhere
    Mongoid.session(:default)
           .with(database: :admin)
           .command({listDatabases:1})['databases']
           .each do |db|
             Mongoid.override_database(db['name'])
             Rails::Mongoid.create_indexes
           end
  ensure
    Mongoid.override_database(nil)
  end

  def self.create_db_indexes(db_name)
    Mongoid.override_database(db_name)
    Rails::Mongoid.create_indexes
  ensure
    Mongoid.override_database(nil)
  end
end

module Mongoid::Document
  # a store_in in the model will overwrite
  # which is good
  included do
    store_in database: ->{ Mongoid.tenant_name }
  end
end
