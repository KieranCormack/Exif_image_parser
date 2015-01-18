require 'csv'
require 'exifr'
require 'terminal-table'

class Run

  def create
    f = File.open("image_info.csv", "w")
    @img_hash.each do |img, gps_data|
      f.puts "#{img}, #{gps_data[0]}, #{gps_data[1]}"
    end
    f.close
  end 

  def data_grab 
    @img_hash = {}
    if File.exists?('image_info.csv')
      f = File.open('image_info.csv', 'r').readlines
      f.each do |line|
        info = line.split(',')
        @img_hash[info[0]] = [info[1], info[2]]
      end
    end
    Dir["gps_images/**/*.jpg"].each do |img|
      unless @img_hash[img]
        unless EXIFR::JPEG.new(img).gps == nil
          lat = EXIFR::JPEG.new(img).gps.latitude
          long = EXIFR::JPEG.new(img).gps.longitude
          @img_hash[img] = [lat, long]
        else 
          @img_hash[img] = ['no gps data']
        end
      end
    end
  end

end

run = Run.new
run.data_grab
run.create

puts "Would you like to view your Image_data now? (Y/N)"
answer = gets.chomp.downcase

if answer == 'y'
  rows = []
  File.open("image_info.csv", "r").readlines.each do |line|   
    info = line.split(',')
    rows << [info[0], info[1], info[2]]
  end
    table = Terminal::Table.new :headings => ['IMAGE','Latitude', 'Longitude'], :rows => rows
    puts table
else
  puts "Thanks for using your friendly neighbourhood image parser"
end


