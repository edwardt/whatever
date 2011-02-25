%w(
	watts
	json
	sequel
).each &method(:require)

module Beeta
	def self.init
		# First off, we need to load the configuration file:
		Beeta::Config.load

		# Before the models are loaded, we need to connect to the DB:
		Sequel::Model.db = Sequel.connect Beeta::Config.db
	end
end

require 'beeta/config'
Beeta.init

%w(
	beeta/resource
	beeta/model
).each &method(:require)

class Beeta::App < Watts::App
	include Beeta::Resource

	resource('/', Discovery) {
		resource("app", AppList) { resource(/^[-0-9a-z]$/i, App) }
	}
end
