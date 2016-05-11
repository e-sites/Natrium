#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'digest/md5'

module Esites
  class BuildEnvironment
    attr_accessor :environments
    attr_accessor :environment
    attr_accessor :config
    attr_accessor :plistfile
    attr_accessor :baseClass
    attr_accessor :dirName
    attr_accessor :tabs
    attr_accessor :customVariableLines
    attr_accessor :printLogs
    attr_accessor :xcconfigContentLines

    def setup
      @environments = [ 'Staging', 'Production' ]
      @environment = nil
      @config = nil
      @plistfile = nil
      @baseClass = "Config"
      @tabs = " " * 4
      @customVariableLines = []
      @printLogs = []
      @xcconfigContentLines = []
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

      ymlFile = "#{@dirName}/build-config.yml"

      if not File.file?(ymlFile)
        error "Cannot find configuration file #{ymlFile}"
      end

      yaml_items = YAML::load_file(ymlFile)

      # Check if anything changed since the previous build
      md5String = Digest::MD5.hexdigest("#{@dirName} #{@plistfile} #{@config} #{@environment}") + Digest::MD5.hexdigest(yaml_items.to_s)
      md5HashFile = "#{absPath}/.__md5checksum"
      if File.file?(md5HashFile)
        if File.read(md5HashFile) == md5String
          print("Nothing changed")
          abort
        end
      end

      @printLogs << "Parsing build-config.yml:"
      yaml_items.each do |key, item|
          if key == "baseClass"
            @baseClass = item
          elsif key == "environments"
            @environments = item
          end
      end

      if not @environments.include? @environment
        error "Invalid environment (#{@environment})\nAvailable environments: #{@environments.to_s}"
      end

      @xcconfigContentLines << "ENVIRONMENT = #{@environment}"

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
          @printLogs << "  [#{key}] " + infoplistkey + " = " + value.to_s
          if key == "infoplist"
            exists = `/usr/libexec/PlistBuddy -c "Print :#{infoplistkey}" "#{@dirName}/#{@plistfile}" 2>/dev/null || printf 'na'`
            if exists == "na"
              system("/usr/libexec/PlistBuddy -c \"Add :#{infoplistkey} string #{value}\" \"#{@dirName}/#{@plistfile}\"")
            else
              system("/usr/libexec/PlistBuddy -c \"Set :#{infoplistkey} #{value}\" \"#{@dirName}/#{@plistfile}\"")
            end

          elsif key == "xcconfig"
            @xcconfigContentLines << "#{infoplistkey} = #{value}"

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
              @customVariableLines << variable(infoplistkey, type, value)
            end
          end
        end
      end

      @swiftLines = []
      # Write to ProjectEnvironment.swift
      @swiftLines << "import Foundation\n"
      @swiftLines << "public class #{@baseClass} {"

      @swiftLines << "#{tabs}public enum EnvironmentType {"
      @swiftLines << @environments.map { |env| "#{tabs}#{tabs}case #{env}" }
      @swiftLines << "#{tabs}}\n"

      @swiftLines << variable("environment", "EnvironmentType", ".#{@environment}")
      @swiftLines << ""
      @swiftLines << @customVariableLines
      @swiftLines << "}"

      filename = "#{absPath}/ProjectEnvironment.swift"
      # Write .swift file
      File.open(filename, 'w') { |file| file.write(@swiftLines.join("\n")) }
      system("touch #{filename}")

      # Write xcconfig file
      filename = "#{absPath}/ProjectEnvironment.xcconfig"
      File.open(filename, 'w') { |file| file.write(@xcconfigContentLines.join("\n")) }
      system("touch #{filename}")

      File.open(md5HashFile, 'w') { |file| file.write(md5String) }

      print(@printLogs.join("\n") + "\n")
    end

    def error(message)
      print "Error: #{message}\n"
      abort
    end

    def variable(name, type, value)
      return "#{tabs}public static let #{name}:#{type} = #{value}"
    end
  end
end
Esites::BuildEnvironment.new.run
