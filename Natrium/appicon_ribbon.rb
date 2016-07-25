require 'FileUtils'
require 'optparse'

module Esites
  class IconRibbon
    def run
      iconOriginal = nil
      appiconsetDir = nil
      text = nil

      ARGV << '-h' if ARGV.empty?
      OptionParser.new do |opts|
        opts.banner = "Usage: " + File.basename($0) + " [options]"
        opts.on('-o', '--original PATH', 'Path to the original (clear) file') { |v| iconOriginal = v }
        opts.on('-i', '--appicon PATH', 'Path to the .appiconset file') { |v| appiconsetDir = v }
        opts.on('-l', '--label TEXT', 'The label on the ribbon') { |v| text = v }
      end.parse!
      generate(iconOriginal, appiconsetDir, text)
    end

    def imagemagick_installed
      begin
        imagemagick = `convert --version`
        if not imagemagick.include? "ImageMagick"
          return false
        end
      rescue
        return false
      end
      return true
    end

    def generate(iconOriginal, appiconsetDir, text)
      appiconsetDir = appiconsetDir.gsub(/\/$/, '')
      if !imagemagick_installed
        error "Imagemagick is not installed"
      end

      if iconOriginal == nil
        error "Missing --original"
      elsif appiconsetDir == nil
        error "Missing --appicon"
      end

      if not File.file?(iconOriginal)
        error "Cannot find original icon: #{iconOriginal}"
      end

      if not File.directory?(appiconsetDir)
        error "Cannot find app icon asset directory: #{appiconsetDir}"
      end

      tmpFile = "tmp_180x180.png"
      dimensions = Hash.new
      Dir.glob("#{appiconsetDir}/*.png") do |file|
        size = `identify -format "%[fx:w]x%[fx:h]" "#{file}"`
        dimensions[file] = size
      end

      system("convert \"#{iconOriginal}\" -resize 180x180 \"#{tmpFile}\"")
      if text != nil && text != ""
        h = 44
        system("convert -size 180x180 xc:skyblue -gravity South\
          -draw \"image over 0,0 0,0 \'#{tmpFile}\'\"\
          -draw \"fill black fill-opacity 0.5 rectangle 0,#{180 - h} 180,180\"\
          -pointsize 24\
          -draw \"fill white text 0,#{h / 5} \'#{text}\'\"\
          \"#{tmpFile}\"")
        end
      print("Generating icons:\n")
      dimensions.each do |file, dimension|
        print(" - #{file} : #{dimension}\n")
        system("convert \"#{tmpFile}\" -resize #{dimension} \"#{file}\"")
      end

      FileUtils.rm(tmpFile)
    end

    def error(message)
      print "Error: #{message}\n"
      abort
    end
  end
end
