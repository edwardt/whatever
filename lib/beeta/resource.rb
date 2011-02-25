require 'beeta/model'

# TODO:  These are all pretty short, but will get bigger and should be split.
# While most resources are under 10 lines, though, this is a little easier.
module Beeta::Resource
	include Beeta

	# The Generic resource, with some utility methods for the other Beeta
	# resources.
	class Generic < Watts::Resource
		include Beeta

		def error_404
			@error_404 ||= json_resp({'error'=>'Not Found'}, 404)
		end

		# Returns the body given with the request, as with a POST or PUT.
		def req_body
			@req_body ||= env['rack.input'].read
		end

		# Returns the req_body, run through the JSON parser.  Returns nil if we
		# can't parse it.
		def json_body
			@json_body ||=
				begin
					JSON.parse(req_body)
				rescue JSON::ParserError
					nil
				end
		end

		def json_resp body, status = 200
			js = JSON.unparse body
			[status,
				{ 'Content-Type' => 'application/json',
				  'Content-Length' => js.size.to_s,
				},
			 [js]]
		end

		def json_error str, status = 400
			json_resp({'error' => str}, status)
		end
	end

	class Discovery < Generic
		get { |*_|
			json_resp 'apps' => '/app', 'users' => '/users'
		}
	end

	# TODO:  These are all pretty similar; maybe a CRUD and a CRUDList
	# superclass, but that depends on if we call gitolite from the models (I'm
	# leaning towards yes) or we manage that through an intermediary, and also
	# on auth.  We'll be using SSO ideally, although we may skip that for now.

	class App < Generic
		get { |name| json_resp Models::App[:name => name] }
		put { |name|
			# TODO:  Authorization.
			a = Models::App[:name => name]
			return error_404 unless a
			a.set json_body
			return json_resp(a) if a.save
			# TODO:  Restart the app.
		}
	end

	class AppList < Generic
		get { json_resp Model::App.all }

		# Not particularly married to POSTing to the app list, as a name must
		# be supplied anyway, so just a PUT to /app/name might be more
		# appropriate.
		post {
			# TODO:  Authentication, tagging the App as owned by the user that
			# is posting the data.
			unless json_body
				return json_error('No body provided, or could not parse body.')
			end

			a = Model::App.new json_body
			if !a.valid?
				# TODO:  409 when the name is taken.
				return json_resp(a.errors, 400)
			end
			return json_resp(a) if a.save
			# TODO:  Provide git URI.
		}
	end

	class UserList < Generic
		get { |name| json_resp Models::User.all }
		# TODO:  Use SSO.
	end

	class User < Generic
		get { |name| json_resp Models::User[:name => name] }
		put { |name|
			a = Models::App[:name => name]
			return error_404 unless a
			a.set json_body
			return json_resp(a) if a.save
			# TODO:  Restart the app.
		}
	end
end
