require './app'

$stdout.sync = true

if ENV['RACK_ENV'] == 'development'
  map '/assets' do
    run RangeApp::Sprock.get true
  end
end

map '/' do
  run RangeApp #Sinatra::Application
end