require 'sequel/model'

module Beeta::Model
	class User < Sequel::Model
		set_dataset :user
	end

	class App < Sequel::Model
		set_dataset :app
	end

	class Bee < Sequel::Model
		set_dataset :bee
	end
end
