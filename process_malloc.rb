#!/Users/mattvh/src/ruby/install/bin/ruby

require 'csv'

start_processing = false

csv = CSV.open('allocation_data.csv', 'wb')

csv << %w{
  allocator
  timestamp
  bytes_requested
  caller
}


def reset
  @counter = 0
  @stack = []
  @entry = []
end
reset

trace_regex = /(?<library>\S*)`(?<method>\S*)\+?/

ARGF.each_with_object([]) do |line, dtrace_entry|
  line.strip!

  if line.empty?
    @stack = @stack.map do |frame|
      x = frame.split('`')
      x[1] = x[1].split('+')[0]
      x
    end

    if @stack[1].first != "ruby"
      $stderr.puts "#@stack"
      reset
      next
    else
      @entry << @stack.find do |lib, meth|
        lib == "ruby" &&
        !(meth.include?("malloc") ||
        meth.include?("calloc") ||
        meth.include?("xrealloc"))
      end.last
    end

    csv << @entry

    reset
    next
  end

  if @counter < 3
    @entry << line
    @counter += 1
  else
    @stack << line
  end
end

