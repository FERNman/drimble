# Have an easy way to get the root of the project
def root_path
  Dir.pwd.sub(/.*\Kfastlane/, '').sub(/.*\Kandroid/, '').sub(/.*\Kios/, '').sub(/.*\K\/\//, '')
end

# Have an easy way to run flutter tasks on the root of the project
lane :run_cmd do |options|
  command = options[:command]
  sh("cd #{root_path} && #{command}")
end
