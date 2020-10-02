require 'pathname'

def ensure_cmd(command)
  system(command) or fail("Failed: #{command}")
end

unless Pathname("./test-app").exist?
  puts "building test rails app"

  ensure_cmd("rails new test-app --without-bundler")
  ensure_cmd("cd test-app && bundle install")
  ensure_cmd("cd test-app && ./bin/spring binstub --remove --all")
end

unless Pathname("./liquid").exist?
  puts "cloning liquid"
  ensure_cmd("git clone git://github.com/shopify/liquid")
  ensure_cmd("cd liquid && bundle install")
end

unless Pathname("./optcarrot").exist?
  puts "cloning Optcarrot"
  ensure_cmd("git clone git://github.com/mame/optcarrot")
  ensure_cmd("cd optcarrot && bundle install")
end

dtrace_cmd = "sudo dtrace"
dtrace_args = "-x bufsize=128m -s allocs.d"

cmds = {
  "basic" => "-e 'String.new'",
  "liquid" => "liquid/performance/memory_profile.rb",
  "rails" => "test-app/bin/rails runner 'Rails.environment'",
  "optcarrot" => "optcarrot/bin/optcarrot"
}

rubies = Pathname.new("~/.rubies")
  .expand_path
  .children
  .map { |rdir| rdir.join('bin/ruby') }

def outfile_name(test_type, data_type, version)
  "out/#{test_type}.#{version}.#{data_type}"
end

def report_name(version)
  "reports/ruby_allocations.#{version}.html"
end

rubies.each do |ruby_bin|
  version = `#{ruby_bin} -v`.split[1]

  %w{basic liquid rails optcarrot}.each do |test_name|
    dtrace_o = outfile_name(test_name, "dtrace", version)
    csv_o = outfile_name(test_name, "csv", version)

    `#{dtrace_cmd} #{dtrace_args} -c "#{ruby_bin} #{cmds[test_name]}" -o #{dtrace_o}`
    `sudo chmod 755 #{dtrace_o}`

    puts "Process dtrace output"
    `ruby process_malloc.rb #{test_name} #{csv_o} #{dtrace_o}`
  end

  csv_files = Dir["out/*.#{version}.csv"]

  %x(
    R -e "rmarkdown::render('RubyAllocationAnalysis.Rmd',output_file='#{report_name(version)}', params=list(ruby_version = '#{version}'))"
  )
end