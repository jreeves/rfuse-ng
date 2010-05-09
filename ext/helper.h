#include <sys/stat.h>
#include <sys/statvfs.h>
#include <ruby.h>
#include <fuse.h>

#ifndef _RHUSE_HELPER_H
#define _RHUSE_HELPER_H

void rstat2stat(VALUE rstat,struct stat *statbuf);
void rstatvfs2statvfs(VALUE rstatvfs,struct statvfs *statvfsbuf);
struct fuse_args * rarray2fuseargs(VALUE rarray);

#endif
