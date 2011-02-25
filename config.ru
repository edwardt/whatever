require 'rubygems'
$: << File.expand_path("#{Dir.pwd}/lib")

require 'beeta'

app = Beeta::App.new
builder = Rack::Builder.new {
	use Rack::Reloader, 1
	use Rack::ShowExceptions
	run app
}.to_app
run builder
