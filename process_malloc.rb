#!/Users/mattvh/src/ruby/install/bin/ruby

require 'csv'

start_processing = false

test_type = ARGV.shift
csv = CSV.open(ARGV.shift, 'wb')

csv << %w{
  allocator
  timestamp
  bytes_requested
  caller
  test_type
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

    if @stack.empty? || @stack[1].first != "ruby"
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

    @entry << test_type

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

