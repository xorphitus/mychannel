task :travis do
  # TODO jasmine -> failed. because of jasmine-jquery
  # TODO cucumber is not used yet
  #["rspec spec", "rake jasmine:ci", "rake cucumber"].each do |cmd|
  ["rspec spec"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end