#!/usr/bin/env rake
require 'bundler/setup'
require './rangestyle'

# Asset pipeline (Sprockets)
namespace :assets do
  desc 'Pre-compile assets'
  task :precompile do
    require './app'
    env = RangeApp::Sprock.get true
    %w[js css].each do |ext|
      file = 'application.' + ext
      env[file].write_to 'public/assets/' + file
    end
  end
end

namespace :style do
  namespace :range do
    desc 'Compile all Range styles'
    task :compile do
      RangeStyle.compile
    end
  end
end