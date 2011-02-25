require 'beeta/model'

# TODO:  These are all pretty short, but will get bigger and should be split.
# While most resources are under 10 lines, though, this is a little easier.
module Beeta::Resource
	include Beeta

	class Generic < Watts::Resource
		include Beeta

		# TODO:  
		
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
			json_resp 'apps' => '/app'
		}
	end

	class App < Generic
		get { |name| Models::App[:name => name].to_json }
		put { |name|
			a = Models::App[:name => name]
			return error_404 unless a
			a.set json_body
			return json_resp(a) if a.save
			# TODO:  Restart the app.
		}
	end

	class AppList < Generic
		get { json_resp Model::App.all }

		post {
			unless json_body
				return json_error('No body provided, or could not parse body.')
			end

			a = Model::App.new json_body
			if !a.valid?
			end
			return json_resp(a) if a.save
			# TODO:  Provide git URI.
		}
	end
end
