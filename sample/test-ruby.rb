#!/usr/bin/ruby -rubygems

# TestFS for RFuse-ng

require "rfuse_ng"

class MyDir < Hash
  attr_accessor :name, :mode , :actime, :modtime, :uid, :gid
  def initialize(name,mode)
    @uid=0
    @gid=0
    @actime=0     #of couse you should use now() here!
    @modtime=0    # -''-
    @xattr=Hash.new
    @name=name
    @mode=mode | (4 << 12) #yes! we have to do this by hand
  end
  def listxattr()
    @xattr.each {|key,value| list=list+key+"\0"}
  end
  def setxattr(name,value,flag)
    @xattr[name]=value #TODO:don't ignore flag
  end
  def getxattr(name)
    return @xattr[name]
  end
  def removexattr(name)
    @xattr.delete(name)
  end
  def dir_mode
    return (@mode & 170000)>> 12 #see dirent.h
  end
  def size
    return 48 #for testing only
  end
  def isdir
    true
  end
  def insert_obj(obj,path)
    d=self.search(File.dirname(path))
    if d.isdir then
      d[obj.name]=obj
    else
      raise Errno::ENOTDIR.new(d.name)
    end
    return d
  end
  def remove_obj(path)
    d=self.search(File.dirname(path))
    d.delete(File.basename(path))
  end
  def search(path)
    p=path.split('/').delete_if {|x| x==''}
    if p.length==0 then
      return self
    else
      return self.follow(p)
    end
  end
  def follow (path_array)
    if path_array.length==0 then
      return self
    else
      d=self[path_array.shift]
      if d then
        return d.follow(path_array)
      else
        raise Errno::ENOENT.new
      end
    end
  end
  def to_s
    return "Dir: " + @name + "(" + @mode.to_s + ")"
  end
end

class MyFile
  attr_accessor :name, :mode, :actime, :modtime, :uid, :gid, :content
  def initialize(name,mode,uid,gid)
    @actime=0
    @modtime=0
    @xattr=Hash.new
    @content=""
    @uid=uid
    @gid=gid
    @name=name
    @mode=mode
  end
  def listxattr() #hey this is a raw interface you have to care about the \0
    list=""
    @xattr.each {|key,value| 
      list=list+key+"\0"}
    return list
  end
  def setxattr(name,value,flag)
    @xattr[name]=value #TODO:don't ignore flag
  end
  def getxattr(name)
    return @xattr[name]
  end
  def removexattr(name)
    @xattr.delete(name)
  end
  def size
    return content.size
  end 
  def dir_mode
    return (@mode & 170000) >> 12
  end
  def isdir
    false
  end
  def follow(path_array)
    if path_array.length != 0 then
      raise Errno::ENOTDIR.new
    else
      return self
    end
  end
  def to_s
    return "File: " + @name + "(" + @mode.to_s + ")"
  end
end

#TODO: atime,mtime,ctime...nicer classes not only fixnums
class Stat
  attr_accessor :uid,:gid,:mode,:size,:atime,:mtime,:ctime 
  attr_accessor :dev,:ino,:nlink,:rdev,:blksize,:blocks
  def initialize(uid,gid,mode,size,atime,mtime,ctime,rdev,blocks,nlink,dev,ino,blksize)
    @uid=uid
    @gid=gid
    @mode=mode
    @size=size
    @atime=atime
    @mtime=mtime
    @ctime=ctime
    @dev=dev
    @ino=ino
    @nlink=nlink
    @rdev=rdev
    @blksize=blksize
    @blocks=blocks
  end
end #class Stat

class MyFuse < RFuse::Fuse

  def initialize(mnt,kernelopt,libopt,root)
    super(mnt,kernelopt,libopt)
    @root=root
  end

  # The old, deprecated way: getdir
  #def getdir(ctx,path,filler)
  #  d=@root.search(path)
  #  if d.isdir then
  #    d.each {|name,obj| 
  #      # Use push_old to add this entry, no need for Stat here
  #      filler.push_old(name, obj.mode, 0)
  #    }
  #  else
  #    raise Errno::ENOTDIR.new(path)
  #  end
  #end

  # The new readdir way, c+p-ed from getdir
  def readdir(ctx,path,filler,offset,ffi)
    d=@root.search(path)
    if d.isdir then
      d.each {|name,obj| 
        stat=Stat.new(obj.uid,obj.gid,obj.mode,obj.size,obj.actime,obj.modtime,
        0,0,0,0,0,0,0)
        filler.push(name,stat,0)
      }
    else
      raise Errno::ENOTDIR.new(path)
    end
  end

  def getattr(ctx,path)
    d=@root.search(path)
    stat=Stat.new(d.uid,d.gid,d.mode,d.size,d.actime,d.modtime,
      0,0,0,0,0,0,0)
    return stat
  end #getattr

  def mkdir(ctx,path,mode)
    @root.insert_obj(MyDir.new(File.basename(path),mode),path)
  end #mkdir

  def mknod(ctx,path,mode,dev)
    @root.insert_obj(MyFile.new(File.basename(path),mode,ctx.uid,ctx.gid),path)
  end #mknod

  #def open(ctx,path,ffi)
  #end

  #def release(ctx,path,fi)
  #end

  #def flush(ctx,path,fi)
  #end

  def chmod(ctx,path,mode)
    d=@root.search(path)
    d.mode=mode
  end

  def chown(ctx,path,uid,gid)
    d=@root.search(path)
    d.uid=uid
    d.gid=gid
  end

  def truncate(ctx,path,offset)
    d=@root.search(path)
    d.content = d.content[0..offset]
  end

  def utime(ctx,path,actime,modtime)
    d=@root.search(path)
    d.actime=actime
    d.modtime=modtime
  end

  def unlink(ctx,path)
    @root.remove_obj(path)
  end

  def rmdir(ctx,path)
    @root.remove_obj(path)
  end

  #def symlink(ctx,path,as)
  #end

  def rename(ctx,path,as)
    d = @root.search(path)
    @root.remove_obj(path)
    @root.insert_obj(d,path)
  end

  #def link(ctx,path,as)
  #end

  def read(ctx,path,size,offset,fi)
    d = @root.search(path)
    if (d.isdir) 
      raise Errno::EISDIR.new(path)
      return nil
    else
      return d.content[offset..offset + size - 1]
    end
  end

  def write(ctx,path,buf,offset,fi)
    d=@root.search(path)
    if (d.isdir) 
      raise Errno::EISDIR.new(path)
    else
      d.content[offset..offset+buf.length - 1] = buf
    end
    return buf.length
  end

  def setxattr(ctx,path,name,value,size,flags)
    d=@root.search(path)
    d.setxattr(name,value,flags)
  end

  def getxattr(ctx,path,name,size)
    d=@root.search(path)
    if (d) 
      value=d.getxattr(name)
      if (!value)
        value=""
        #raise Errno::ENOENT.new #TODO raise the correct error :
        #NOATTR which is not implemented in Linux/glibc
      end
    else
      raise Errno::ENOENT.new
    end
    return value
  end

  def listxattr(ctx,path,size)
    d=@root.search(path)
    value= d.listxattr()
    return value
  end

  def removexattr(ctx,path,name)
    d=@root.search(path)
    d.removexattr(name)
  end

  #def opendir(ctx,path,ffi)
  #end

  #def releasedir(ctx,path,ffi)
  #end

  #def fsyncdir(ctx,path,meta,ffi)
  #end

end #class Fuse

fo = MyFuse.new("/tmp/fuse",["allow_other"],["debug"], MyDir.new("",493));
#kernel:  default_permissions,allow_other,kernel_cache,large_read,direct_io
#         max_read=N,fsname=NAME
#library: debug,hard_remove

Signal.trap("TERM") do
  fo.exit
  fo.unmount
end

begin
  fo.loop
rescue
  f=File.new("/tmp/error","w+")
  f.puts "Error:" + $!
  f.close
end
