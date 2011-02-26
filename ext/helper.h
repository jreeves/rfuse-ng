#include <sys/stat.h>
#include <sys/statvfs.h>
#include <ruby.h>
#include <fuse.h>

#ifndef _RHUSE_HELPER_H
#define _RHUSE_HELPER_H

void rstat2stat(VALUE rstat,struct stat *statbuf);
void rstatvfs2statvfs(VALUE rstatvfs,struct statvfs *statvfsbuf);
void rfuseconninfo2fuseconninfo(VALUE rfuseconninfo,struct fuse_conn_info *fuseconninfo);
struct fuse_args * rarray2fuseargs(VALUE rarray);

#define STR2CSTR(X) StringValuePtr(X) 


#endif
