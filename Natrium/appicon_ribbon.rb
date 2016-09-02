require 'fileutils'
require 'optparse'
require 'json'

module Esites
  class IconRibbon
    def run
      iconOriginal = nil
      appiconsetDir = nil
      text = nil
      legacy = false

      ARGV << '-h' if ARGV.empty?
      OptionParser.new do |opts|
        opts.banner = "Usage: " + File.basename($0) + " [options]"
        opts.on('-o', '--original PATH', 'Path to the original (clear) file') { |v| iconOriginal = v }
        opts.on('-i', '--appicon PATH', 'Path to the .appiconset file') { |v| appiconsetDir = v }
        opts.on('-l', '--label TEXT', 'The label on the ribbon') { |v| text = v }
      end.parse!
      generate(iconOriginal, appiconsetDir, text, legacy)
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

    def generate(iconOriginal, appiconsetDir, text, legacy)
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

      FileUtils.rm_rf Dir.glob("#{appiconsetDir}/*")

      dimensions = []
      tmpFile = "tmp_180x180.png"
      asset = {
        :iphone => [
          [29, [2,3]],
          [40, [2,3]],
          [60, [2,3]]
        ],
        :ipad => [
          [29, [1,2]],
          [40, [1,2]],
          [76, [1,2]],
          [83.5, [2]]
        ]
      }
      if !legacy
        asset[:iphone] << [20, [2,3]]
        asset[:ipad] << [20, [1,2]]
      end

      assetExport = {
        :images => [],
        :info => {
          :version => 1,
          :author => "xcode"
        },
        :properties => {
          :'pre-rendered' => true
        }
       }

      asset[:iphone].each do |a|
        write_asset("iphone", a, assetExport, dimensions)
      end

      asset[:ipad].each do |a|
        write_asset("ipad", a, assetExport, dimensions)
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
      dimensions.each do |w|
        s = w.split(":")
        c = s[1].to_i
        dimension = "#{s[0]}x#{s[0]}"
        if c == 1
          file = "#{s[0]}.png"
        else
          file = "#{s[0]}@#{c}x.png"
        end
        print(" - #{dimension} > #{file}\n")
        system("convert \"#{tmpFile}\" -resize #{dimension} \"#{appiconsetDir}/#{file}\"")
      end

       json_contents = JSON.pretty_generate(assetExport)
       FileUtils.rm(tmpFile)
       File.open("#{appiconsetDir}/Contents.json", 'w') { |file| file.write(json_contents) }
    end

    def write_asset(idiom, a, assetExport, dimensions)
      a[1].each do |l|
        c = "#{a[0]}:#{l}"
        if l == 1
          f = "#{a[0]}.png"
        else
          f = "#{a[0]}@#{l}x.png"
        end
        assetExport[:images] << {
          :size => "#{a[0]}x#{a[0]}",
          :idiom => idiom,
          :filename => f,
          :scale => "#{l}x"
        }
        if not dimensions.include? c
          dimensions << c
        end
      end
    end

    def error(message)
      print "Error: #{message}\n"
      abort
    end
  end
end
