require 'pathname'

rubies = Pathname.new("~/.rubies")
  .expand_path
  .children
  .map { |rdir| rdir.join('bin/ruby') }

rubies.each do |ruby_bin|
  version = `#{ruby_bin} -v`.split[1]
  dtrace_outfile = "out/dtrace.#{version}.out"
  csv_outfile = "out/allocations.#{version}.csv"
  report_file = "out/allocation_report.#{version}.html"

  puts "Generating dtrace output for #{version}"
  `sudo dtrace -x bufsize=128m -s ~/tmp/allocs.d -c "#{ruby_bin} -e 'String.new'" -o #{dtrace_outfile}`
  `sudo chmod 755 #{dtrace_outfile}`

  puts "Process dtrace output"
  `ruby process_malloc.rb #{csv_outfile} #{dtrace_outfile}`

  puts "Generating report..."

  %x(
    R -e "rmarkdown::render(
        'RubyAllocationAnalysis.Rmd',
        output_file='#{report_file}',
        params=list(datafile = '#{csv_outfile}'))"
  )
end