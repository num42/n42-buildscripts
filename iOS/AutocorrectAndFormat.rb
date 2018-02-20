#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require 'xcodeproj'

version = "0.2.0"

scriptFile = "AutocorrectAndFormat.rb"
scriptSource = "https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/#{scriptFile}"

options = OpenStruct.new

options.update = false

OptionParser.new do |opts|

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

# Here begins the actual script

project = Xcodeproj::Project.open(ENV["PROJECT_FILE_PATH"])

input_files = project.targets.select { |target| target.name.eql? ENV["TARGETNAME"] }.first.source_build_phase.files.to_a.map do |pbx_build_file|
  pbx_build_file.file_ref.real_path.to_s
end.select do |path|
  path.end_with?(".swift")
end.select do |path|
  not path.include?("GeneratedCode")
end

hash = {}

input_files.each_with_index do | filename, index |
hash["SCRIPT_INPUT_FILE_#{index}"] = filename
end

hash["SCRIPT_INPUT_FILE_COUNT"] = input_files.count.to_s

system(hash, "swiftlint autocorrect --use-script-input-files")

system("swiftformat --disable redundantSelf --cache ignore --indent 2 --wraparguments beforefirst --wrapelements beforefirst --header ignore --patternlet inline --stripunusedargs closure-only --disable blankLinesBetweenScopes --disable blankLinesAroundMark --commas inline #{input_files.join(" ")}")

system(hash, "swiftlint lint --quiet --use-script-input-files")
