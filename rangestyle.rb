module RangeStyle
  extend self

  VERSION = 2.0

  DIR = {
    raw: File.join('!style', 'range'),
    out: File.join('public', 'dat.style', 'range')
  }

  ## Styles
  # A list of styles by site
  # Wide and Slim are the type of width
  STYLES = {
    what: {
      current: %w[wide slim],
      classic: %w[wide slim],
      sommar: %w[wide],
      summer: %w[wide],
    },
    ptp: {
      current: %w[wide],
    },
    it: {
      current: %w[wide],
    }
  }

  def version
    VERSION
  end

  def styles
    STYLES
  end

  def compile
    # Range SCSS compiler
    # outputs the compiled css in dat.style/range/what.ever.size.css
    # result/eg: range/what.current.wide.css
    require 'sass'
    compass_config
    range = { base: scss_engine('range') }
    STYLES.each do |site, hash|
      range[:site] = scss_engine '__site_' + site.to_s

      hash.each do |style, type|
        range[:style] = scss_engine '__style_' + style.to_s

        type.each do |size|
          range[:size] = scss_engine '__size_' + size
          self::Write.new(range, DIR[:out] + '/' + [site, style, size, 'css'].join('.')).out
        end
      end
    end
  end

  private
  
  def scss_engine(file)
    Sass::Engine.for_file(File.open(File.join('.', DIR[:raw], file + '.scss')), Compass.sass_engine_options)
  end
  
  def compass_config
    # Configures Compass to process the various forms of Range
    # This is not part of the main site, but the Range SCSS
    # http://compass-style.org/help/tutorials/configuration-reference/

    require 'compass'
    Compass.configuration do |c|
      c.preferred_syntax = :scss
      c.output_style = :compressed
      c.relative_assets = true

      c.project_path = '.'
      c.http_path = '/'
      c.css_path = DIR[:out]
      c.http_stylesheets_path = '/dat.style/range'
      c.sass_path = DIR[:raw]
      c.images_path = DIR[:raw] + '/img'
      c.http_images_path = ''
      c.generated_images_path = DIR[:out] + '/i'
      c.http_generated_images_path = '/dat.style/range/i'
      c.sass_options = { cache_location: DIR[:raw] + '/.sass-cache', syntax: :scss }

      # c.watch File.join(c.sass_path, '*') do
        # puts 'change'
      # end
    end
    Compass.configure_sass_plugin!
  end

  class Write
    def initialize(sass_engines, path)
      @engines = sass_engines
      @filepath = path
    end

    def out
      puts 'Writing: ' + @filepath
      File.open @filepath, 'w' do |file|
        @engines.each_value { |e| file.write e.render.chomp }
      end
    end
  end
end