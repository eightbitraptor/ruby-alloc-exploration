# Ruby Allocation Analysis

This repo contains an RMarkdown report that displays information about the
memory allocation of a Ruby process. It consumes information provided by
`malloc_history`
(https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/FindingPatterns.html),
and so currently only works on macOS.

## Dependencies

- R. install this with `brew install r`
- Ruby

**Note** The scripts in this repo require knowledge about how Ruby has been
compiled in order to parse the stack traces from `malloc_history` correctly. If
your Ruby has been compiled with `--enable-shared` you'll need to change
`process_malloc.rb` to look for the dynamic library name in the stack trace, as
currently it looks for the Ruby binary name.

## Running the report

1. Run your Ruby process with `MallocStackLoggingNoCompact=1` to configure
   `malloc` to start logging allocations. eg.
   ```
   MallocStackLoggingNoCompact=1 ./bin/rails runner 'puts Process.pid; $stdin.gets'
   ```
2. Use `malloc_history` to push the data to a log file
   ```
   malloc_history <pid of Ruby process> -allBySize > malloc.log
   ```
3. Transform the log file into a CSV
   ```
   ./process_malloc.rb malloc.log
   ```
4. Generate the report
   ```
   R -e "rmarkdown::render('RubyAllocationAnalysis.Rmd',output_file='RubyAllocationAnalysis.html')"
   ```
5. Open in your browser
   ```
   open RubyAllocationAnalysis.html
   ```
