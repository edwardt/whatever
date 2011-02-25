require 'json'

module Beeta
	module Config
		ConfigFile = %W(
			#{ENV['BEETA_CONF']}
			./beeta.json
			#{ENV['HOME']}/.beeta.json
			/etc/beeta.json
		).select { |fn| File.exist? fn }.first
		
		class << self; attr_accessor :config, :loaded; end

		def self.load(fn = nil, force = false)
			fn ||= ConfigFile
			return false if(fn.nil? || (!force && loaded))

			self.config = JSON.parse File.read(fn)
			config.each { |k,v|
				class << self; self; end.module_eval {
					define_method(k) { v }
				}
			}

			self.loaded = true
		end
	end
end

Beeta::Config.load
