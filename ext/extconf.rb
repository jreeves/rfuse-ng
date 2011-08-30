require 'mkmf'

$CFLAGS << ' -Wall'
$CFLAGS << ' -D_FILE_OFFSET_BITS=64'
$CFLAGS << ' -DFUSE_USE_VERSION=26'

unless have_library('fuse') || have_library("fuse4x")
  puts "No FUSE install available"
  exit
end

have_header('sys/statvfs.h')
have_header('sys/statfs.h')
have_header('linux/stat.h')

create_makefile('rfuse_ng')
