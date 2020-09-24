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

counter = 0
stack = []
entry = []

ARGF.each_with_object([]) do |line, dtrace_entry|
  line.strip!

  if line.empty?
    entry << stack.find { |frame|
      frame.start_with?("ruby")
    }&.split('`')&.last&.split('+')&.first
    csv << entry

    stack = []
    counter = 0
    entry = []

    next
  end

  if counter < 3
    entry << line
    counter += 1
  else
    stack << line
  end
end

