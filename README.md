# Ruby Allocation Analysis

This repo contains an RMarkdown report that displays information about the
memory allocation of a Ruby process. Information is captured using `dtrace`
probes that fire when we enter a function that allocates memory

## Dependencies

- R. install this with `brew install r`
- Ruby
- DTrace

## Generating the raw data

Run your program under `dtrace` using the `dtrace` script `allocs.d` contained
in this repo. For a Rails application running under a custom build of Ruby this
might look like:

```
sudo dtrace -x bufsize=50m -s ~/allocs.d -c "/Users/mattvh/src/ruby/ruby/ruby ./bin/rails runner 'Rails.env'" -o dtrace.out
```

*NOTES:*

- For macOS, if you're not using a custom built Ruby, you may need to open a
  hole in System Integrity Protection in order for `dtrace` to work properly,
  this is because most Ruby binstubs use `/usr/bin/env` to find the correct Ruby
  interpreter. This is because `/usr/bin/env` is a restricted binary.

  You can find out if a binary is restricted with `ls -lO /path/to/bin`

  To disable SIP for `dtrace` reboot into Recovery mode with `⌘-R`, open a
  terminal from the `Utilities` menu and run this command:

  ```
  csrutil disable && csrutil enable --without dtrace
  ```
- You may need to adjust the buffersize depending on your system and how many
  times the application that you're running fires it's probes. If you're
  `dtrace` reports Drops:

  ```
  dtrace: 1767 drops on CPU 0
  dtrace: 5251 drops on CPU 2
  dtrace: 2687 drops on CPU 4
  dtrace: 20123 drops on CPU 6
  dtrace: 32358 drops on CPU 0
  ```

  Then increase the `bufsize` parameter until they go away

## Parsing the dtrace output

## Running the report

1. Generate the report
   ```
   R -e "rmarkdown::render('RubyAllocationAnalysis.Rmd',output_file='RubyAllocationAnalysis.html')"
   ```
2. Open in your browser
   ```
   open RubyAllocationAnalysis.html
   ```
