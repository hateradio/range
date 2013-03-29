require 'compass'
require 'bootstrap-sass'
require 'sprockets'
require 'sprockets-sass'
require 'sass'
require 'uglifier'
require 'sinatra'
require 'sinatra/base'
require './rangestyle'

class RangeApp < Sinatra::Base
  # The little Range application

  before do
    @title = 'Home'
    $host = 'https://' + request.env['HTTP_HOST'] # request.env['rack.url_scheme']
  end

  set :production, ENV['RACK_ENV'] == 'production'
  set :app_root, File.realdirpath('.')

  # routes
  error do
    @title = 'Error'
    erb :'errors/500'
  end

  not_found do
    @title = '404 / Missing'
    erb :'errors/404'
  end

  get '/' do
    erb :index #, :locals => {:u => 'bar'}
  end

  get '/about/?' do
    @title = 'About'
    erb :about
  end

  get '/customize/?' do
    @title = 'Cutomize'
    erb :customize
  end

  get '/preview/?:section?' do
    @section = RangeApp::SDB.find_section(params[:section] || '') || 'double'
    @style = RangeApp::SDB.find_style(params[:style]) || 'what.current.wide'
    erb :"preview/#{@section}.html", layout: :layout_preview
  end

  module SDB
    extend self

    SECTIONS = {
      double: 'Main, two-column layout',
      description: 'Record information',
      forum: 'Forum index'
    }

    def sections
      SECTIONS
    end

    def find_section(section)
      begin
        section if SECTIONS.has_key? section.to_sym
      rescue
      end
    end

    def find_style(style)
      begin
        parts = style.split '.'
        style if RangeStyle.styles[parts[0].to_sym][parts[1].to_sym].include? parts[2]
      rescue
      end
    end
  end

  module Sprock
    # Sprokets Stuff
    # require 'compass'
    # require 'bootstrap-sass'
    # require 'sprockets'
    # require 'sprockets-sass'
    # require 'sass'
    # require 'uglifier'
    extend self

    def get(minify = nil)
      environment = Sprockets::Environment.new File.realdirpath('.')
      environment.append_path 'app/js'
      environment.append_path 'app/css'

      minification environment if minify
      helper environment
      environment
    end

    private
    
    def minification(env)
      env.js_compressor = Uglifier.new
      Sprockets::Sass.options[:style] = :compressed
    end
    
    def helper(env)
      Sprockets::Helpers.configure do |config|
        config.environment = env
        config.prefix      = '/assets'
        config.digest      = true
      end
    end
  end
  
  # class Sprok < Sprockets::Environment
    # include Singleton

    # def initialize
      # super File.realdirpath '.'

      # append_path 'app/js'
      # append_path 'app/css'
    # end
    
    # def minify
    # end
  # end

end