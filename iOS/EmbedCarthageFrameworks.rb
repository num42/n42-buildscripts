#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

version = "0.0.5"

scriptFile = "EmbedCarthageFrameworks.rb"
scriptSource = "https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/#{scriptFile}"

options = OpenStruct.new

options.frameworkFileName = nil
options.update = false

OptionParser.new do |opts|

  opts.on("-f", "--frameworks [Filename]", "Run 'carthage copy-frameworks' for all lines in this file") do |frameworkFileName|
    options.frameworkFileName = frameworkFileName
  end

  opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
  end

  opts.on("-u", "--[no-]update", "Update Script") do |v|
    options.update = v
  end

  opts.on_tail("--version", "Show version") do
     puts version
     exit
  end
   
end.parse!

if options.update
  puts "updating"
  exec("curl -L #{scriptSource}?$(date +%s) -o #{File.basename($0)}")
end

unless options.frameworkFileName
  puts "No frameworkFileName specified"
  exit 1
end

frameworks = File.readlines "#{ENV["SRCROOT"]}/#{options.frameworkFileName}"

hash = {}

frameworks.each_with_index do | framework, index |
    hash["SCRIPT_INPUT_FILE_#{index}"] = "#{ENV["SRCROOT"]}/#{framework.strip}"
    hash["SCRIPT_OUTPUT_FILE_#{index}"] = "#{ENV["BUILT_PRODUCTS_DIR"]}/#{ENV["FRAMEWORKS_FOLDER_PATH"]}/#{framework.strip}"
end

puts hash
hash["SCRIPT_INPUT_FILE_COUNT"] = frameworks.count.to_s

system(hash, "/usr/local/bin/carthage copy-frameworks")
