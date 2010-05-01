require 'mkmf'

$CFLAGS << ' -Wall'
$CFLAGS << ' -Werror'
$CFLAGS << ' -D_FILE_OFFSET_BITS=64'
$CFLAGS << ' -DFUSE_USE_VERSION=22'

if have_library('fuse')
  create_makefile('fusefs-ng')
else
  puts "No FUSE install available"
end
