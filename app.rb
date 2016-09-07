require 'sinatra'
require 'RMagick'
include Magick

get '/' do
    html :index
end

def html(view)
      File.read(File.join('public', "#{view.to_s}.html"))
end

get '/:meme/:text' do
    content_type 'image/jpg'

    text = word_wrap params['text']
    filename = params['meme']
    text_customization = extract_text_customization(params)
    write_in_image(text, "public/static/pictures/#{filename}.jpg", text_customization)
end

def write_in_image(text, img_path, text_customization)
    img = Magick::Image.read(img_path).first
    drawing = Magick::Draw.new

    text.split("\n").each do |row|
        drawing.annotate(img, 0, 0, 0, 0, row) do
            text_customization.each do |property, value|
              self.send("#{property.to_s}=", value)
            end
        end
    end

    img.format = 'jpg'
    img.to_blob
end

def extract_text_customization(params)
  {
    font_family: params.fetch('font-family', 'verdana'),
    pointsize: params.fetch('font-size', '30').to_i,
    stroke: params.fetch('stroke', 'transparent'),
    fill: params.fetch('font-color', 'white'),
    font_style: load_const(params.fetch('font-style', 'normal'), 'Style'),
    font_weight: load_const(params.fetch('font-weight', 'bold'), 'Weight'),
    gravity: load_const(params.fetch('gravity', 'north_west'), 'Gravity')
  }
end

def load_const(value, type)
  Magick.const_get("#{camelize(value)}#{type}")
end

def camelize(text)
  text.split('_').map(&:capitalize).join
end

def word_wrap(text, columns = 40)
  text.split("\n").collect do |line|
    line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
  end * "\n"
end
