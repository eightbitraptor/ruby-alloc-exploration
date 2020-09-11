#!/Users/mattvh/src/ruby/install/bin/ruby

require 'csv'

start_processing = false

csv = CSV.open('allocation_data.csv', 'wb')

csv << %w{
  bytes_requested
  count
  caller
  filename
  line_number
}

ARGF.each_line do |line|
  if line =~ /----/
    start_processing = true
    next
  end

  next unless start_processing
  next if line.empty?

  data, trace = line.split(':', 2).map(&:strip)

  count, bytes = 0

  next if data.nil? || trace.nil?

  data.match(/(?<count>\d+) calls? for (?<bytes>\d+) bytes/) do |m|
    count = m[:count].to_i
    bytes = m[:bytes].to_i
  end

  next if bytes.nil?

  trace = trace.split('|').map do |frame|
    matches = frame.match(%r{
      (?<address>0x[0-9a-f]+)\s        # hex memory address
      \((?<libname>.*)\)\s             # a libname in parens
      (?<method>[\w?]+)                # a method name
      (\s+                             # and if it's present
        (?<fname>[\w\.]*):(?<lnum>\d+) # filename.ext:linenumber
      )?
    }x)
  end

  # The latest frame in the trace that is inside the ruby binary but not a
  # malloc function. This should give a reasonable approximation of the function
  # that called one of Ruby's malloc wrappers
  #
  # NOTE: This works because I have compiled a custom ruby so I can control the
  # library names and the presence of debug symbols. If you are using a system
  # installed ruby you may have to change the value of the `ruby` libname to a
  # dylib or so specific to your architecture and build settings or your callee
  # information will be wrong.
  malloc_re = /[mc]alloc/
  require 'pry'
  callsite_idx = trace.rindex { |f|
    f && f[:libname].include?('ruby') && !f[:method].match?(malloc_re)
  }

  if callsite_idx.nil?
    callsite_idx = trace.rindex { |f|
      f && f[:libname] == 'dyld' && f[:method] != 'dyld'
    }
  end

  if callsite_idx.nil?
    binding.pry
  end

  caller = trace[callsite_idx]

  csv << [bytes, count, caller[:method], caller[:fname], caller[:lnum]]
end

