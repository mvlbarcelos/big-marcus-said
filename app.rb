require 'sinatra'
require 'RMagick'
include Magick

get '/angry/:text' do
    content_type 'image/jpg'

    text = word_wrap params['text']
    write_in_image(text, "static/pictures/angry.jpg")
end

get '/happy/:text' do
    content_type 'image/jpg'

    text = word_wrap params['text']
    write_in_image(text, "static/pictures/happy.jpg")
end

def write_in_image(text, img_path)

    img = Magick::Image.read(img_path).first
    drawing = Magick::Draw.new

    position = 0
    text.split("\n").each do |row|
        drawing.annotate(img, 0, 0, 1, position += 30, row) do
            self.font = 'Verdana'
            self.pointsize = 30
            self.fill = 'white'
            self.font_weight = Magick::BoldWeight
        end
    end

    img.format = 'jpg'
    img.to_blob  
end


def word_wrap(text, columns = 40)
  text.split("\n").collect do |line|
    line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
  end * "\n"
end