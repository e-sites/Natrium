#!/usr/bin/env ruby
require_relative './appicon_ribbon'
require 'optparse'
require 'yaml'
require 'digest/md5'
require 'FileUtils'

module Esites
  class BuildEnvironment
    attr_accessor :environments
    attr_accessor :environment
    attr_accessor :config
    attr_accessor :plistfile
    attr_accessor :baseClass
    attr_accessor :files
    attr_accessor :dirName
    attr_accessor :tabs
    attr_accessor :customVariableLines
    attr_accessor :buildConfigFile
    attr_accessor :printLogs
    attr_accessor :target
    attr_accessor :appIconRibbon
    attr_accessor :natriumVariables
    attr_accessor :xcconfigContentLines
    attr_accessor :haswarning

    def setup
      @environments = [ 'Staging', 'Production' ]
      @environment = nil
      @config = nil
      @haswarning = false
      @plistfile = nil
      @natriumVariables = {}
      @target = nil
      @files = {}
      @baseClass = "Config"
      @buildConfigFile = "build-config.yml"
      @tabs = " " * 4
      @customVariables = {}
      @printLogs = []
      @appIconRibbon = { "ribbon" => nil, "original" => nil, "appiconset" => nil }
      @xcconfigContentLines = {}
    end

    def run
      setup
      absPath = File.dirname(__FILE__)

      ARGV << '-h' if ARGV.empty?
      OptionParser.new do |opts|
        opts.banner = "Usage: " + File.basename($0) + " [options]"
        opts.on('-p', '--project_dir DIRECTORY', 'Project dir') { |v| @dirName = v }
        opts.on('-i', '--infoplist_file FILE', 'Info.plist file location') { |v| @plistfile = v }
        opts.on('-c', '--configuration NAME', 'Configuration name') { |v| @config = v }
        opts.on('-e', '--environment NAME', 'Environment') { |v| @environment = v }
        opts.on('-t', '--target NAME', 'Target') { |v| @target = v }
      end.parse!

      if @config == nil
        error "Missing configuration (--configuration)"
      end

      if @environment == nil
        error "Missing environment (--environment)"
      end

      if @dirName == nil
        error "Missing project dir (--project_dir)"
      end


      if @plistfile == nil
        error "Missing Info.plist file location"
      elsif not File.file?("#{@dirName}/#{@plistfile}")
        error "Cannot find Info.plist file at location #{@dirName}/#{@plistfile}"
      end

      ymlFile = "#{@dirName}/#{@buildConfigFile}"

      if not File.file?(ymlFile)
        error "Cannot find configuration file #{ymlFile}"
      end

      begin
        yaml_items = YAML::load_file(ymlFile)
      rescue Exception => e
        error "Error parsing #{@buildConfigFile}: #{e}"
      end

      # Check if anything changed since the previous build
      md5String = Digest::MD5.hexdigest("#{@dirName} #{@plistfile} #{@config} #{@environment} #{@target}") + Digest::MD5.hexdigest(yaml_items.to_s)
      md5HashFile = "#{absPath}/.__md5checksum"
      if File.file?(md5HashFile)
        if File.read(md5HashFile) == md5String
          print("Nothing changed")
          abort
        end
      end

      @printLogs << "Parsing #{@buildConfigFile}:"
      yaml_items.each do |key, item|
          if key == "environments"
            @environments = item
          end
      end

      if not @environments.include? @environment
        error "Invalid environment (#{@environment})\nAvailable environments: #{@environments.to_s}"
      end
      @xcconfigContentLines["ENVIRONMENT"] = @environment
      iterateYaml(yaml_items, true)
      iterateYaml(yaml_items, false)

      targetSpecific = yaml_items["target_specific"]
      if targetSpecific != nil
        targetYaml = targetSpecific[@target]
        if targetYaml != nil
          iterateYaml(targetYaml)
        end
      end

      @swiftLines = []
      # Write to Config.swift
      @swiftLines << "import Foundation\n"
      @swiftLines << "public class #{@baseClass} {"

      @swiftLines << "#{tabs}public enum EnvironmentType {"
      @swiftLines << @environments.map { |env| "#{tabs}#{tabs}case #{env}" }
      @swiftLines << "#{tabs}}\n"

      @swiftLines << variable("environment", "EnvironmentType", ".#{@environment}")
      @swiftLines << ""
      @customVariables.each do |key,tv|
        @swiftLines << variable(key, tv["type"], tv["value"])
      end
      @swiftLines << "}"

      file_write("#{absPath}/Config.swift", @swiftLines.join("\n"))

      # Write xcconfig file
      xcconfigLines = []
      @xcconfigContentLines.each do |key,value|
        xcconfigLines << "#{key} = #{value}"
      end
      file_write("#{absPath}/ProjectEnvironment.xcconfig", xcconfigLines.join("\n"))

      files = Dir.glob("#{@dirName}/Pods/Target Support Files/Pods-*/*.xcconfig")
      files.concat Dir.glob("#{@dirName}/Pods/Target Support Files/Pods/*.xcconfig")
      xcConfigLine = "\#include \"../../Natrium/Natrium/ProjectEnvironment.xcconfig\""
      files.each do |file|
        podXcConfigContents = File.read(file)
        if not podXcConfigContents.include? xcConfigLine
          file_write(file, "#{xcConfigLine}\n\n#{podXcConfigContents}")
        end
      end

      if @appIconRibbon["ribbon"] != nil && @appIconRibbon["original"] != nil && @appIconRibbon["appiconset"] != nil
        ribbon = Esites::IconRibbon.new
        if ribbon.imagemagick_installed
          ribbon.generate(@dirName + "/" + @appIconRibbon["original"], @dirName + "/" + @appIconRibbon["appiconset"], @appIconRibbon["ribbon"])
        else
          warning "ImageMagick is not installed on this machine, cannot create icon ribbon"
        end
      end

      file_write(md5HashFile, md5String)
      if !@haswarning
          print(@printLogs.join("\n") + "\n")
        end
    end

    def iterateYaml(yaml_items, natrium_variables)
      # Iterate over the .yml file
      yaml_items.each do |key, item|
        if not item.is_a? Hash
          next
        end
        item.each do |infoplistkey, infoplistkeyitem|
          value = nil
          if infoplistkeyitem.is_a? Hash
            infoplistkeyitem.each do |key2, item2|
              if not key2.split(',').include? @environment
                next
              end
              if item2.is_a? Hash
                item2.each do |key3, item3|
                  if not key3.split(',').include? @config
                    next
                  end
                  value = item3
                  break
                end
              else
                value = item2
              end
              break
            end
          else
            value = infoplistkeyitem
          end

          if key == "natrium_variables" && natrium_variables == true
            @natriumVariables[infoplistkey] = value
            next
          end

          if natrium_variables == true
            return
          end

          if value != nil
            @natriumVariables.each do |nk,nv|
              if value.is_a? String
                value.gsub! "\#\{#{nk}\}", "#{nv}"
              end
            end
          end

          @printLogs << "  [#{key}] " + infoplistkey + " = " + value.to_s

          if key == "infoplist"
            write_plist("#{@dirName}/#{@plistfile}", infoplistkey, value)

          elsif key.end_with?(".plist")
            f = "#{@dirName}/#{key}"
            if not File.file?(f)
              error("Cannot find file '#{f}'")
            end
            write_plist(f, infoplistkey, value)

          elsif key == "xcconfig"
            @xcconfigContentLines[infoplistkey] = value

          elsif key == "appicon"
            @appIconRibbon[infoplistkey] = value

          elsif key == "files"
            file = "#{@dirName}/#{value}"
            if not File.file?(file)
              error("Cannot find file '#{file}'")
            end
            @files["#{@dirName}/#{infoplistkey}"] = file

          elsif key == "variables"
            type = nil
            if value.is_a? String
              value = "\"#{value}\""
              type = "String"

            elsif [true, false].include? value
              type = "Bool"

            elsif value.is_a? Integer
              type = "Int"

            elsif value.is_a? Float
              type = "Double"
            end
            if type != nil
              @customVariables[infoplistkey] = { "type" => type, "value" => value}
            end
          end
        end
      end
      @files.each do |key,file|
        FileUtils.cp(file, key)
      end
    end

    def error(message)
      print "Error: [Natrium] #{message}\n"
      abort
    end

    def warning(message)
      if @haswarning
        return
      end
      @haswarning = true
      print "warning: [Natrium] #{message}\n"
    end

    def write_plist(file, key, value)
      exists = `/usr/libexec/PlistBuddy -c "Print :#{key}" "#{file}" 2>/dev/null || printf 'na'`
      if exists == "na"
        system("/usr/libexec/PlistBuddy -c \"Add :#{key} string #{value}\" \"#{file}\"")
      else
        system("/usr/libexec/PlistBuddy -c \"Set :#{key} #{value}\" \"#{file}\"")
      end
    end

    def file_write(filename, content)
      if File.file?(filename)
        system("/bin/chmod 7777 \"#{filename}\"")
      end
      File.open(filename, 'w') { |file| file.write(content) }
      system("touch \"#{filename}\"")
    end

    def variable(name, type, value)
      return "#{tabs}public static let #{name}:#{type} = #{value}"
    end
  end
end
Esites::BuildEnvironment.new.run
