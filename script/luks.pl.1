#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package Crypt::LUKS::Util;
class Crypt::LUKS::Util;

use utf8;
use v5.40;

use List::Util 'first';
use Data::Dumper;
use IPC::Run3;
use Path::Tiny;

#NAME      FSTYPE      FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
#
#nvme0n1p2 crypto_LUKS 2                3e8be5f6-1088-4351-b4d8-62496a1afcfd                
#nvme0n1p3 crypto_LUKS 2                08cb0b82-67af-49ba-875e-0795b3a672f7                
#nvme1n1p7 crypto_LUKS 2                f7dd1a11-b54e-4fec-a901-52f874cb1a46                

sub cryptsetup ($diskinfo, $openname = undef, %opts) {
  $openname //= $diskinfo->%[qw(label uuid name)];
  my $devpath = "/dev/disk/by-uuid/$$diskinfo{uuid}";

  run3([ qw(cryptsetup open), "/dev/disk/by-uuid/$$diskinfo{uuid}", $openname ]
       , undef);

  return undef if $? != 0;
  
  say "Successfully unlocked '$devpath'. Device is available at /dev/mapper/$openname.";
  "/dev/mapper/$openname"
}

sub mount ($src, $dest, %opts) {
  my @cmd = qw(mount);

  push @cmd, '--bind' if $opts{bind};
  push @cmd, grep { $_ }
             map { 
	       $_ => $opts{$_} == 1
	         ? undef
		 : $opts{$_}
	     } keys %opts;
 
  push @cmd, $dest;
  my $ret = run3(\@cmd, \undef);
  
  die "Fatal error occured trying to run:\n\t" . (join ' ', @cmd) if $ret;
  say "Successfully mounted $src => $dest!";
  
  path($dest)
}


# TODO: Look up slice equivalent of destructuring 
sub run () {
  #...

	my @lsblk = grep { $$_{fstype} eq 'crypto_LUKS' } map { chomp $_; split /[\s]+/, $_ } `lsblk -lf`)
 

  my @field = (split /[\s]+/, shift @lsblk);
  
  #my @disk =map { } grep { $$_{fstype} eq 'crypto_LUKS' } @lsblk;
  
  my @disk =- ();
  foreach my $field (@field) {
    my %disk = ();
    $disk{field} eq 
  }

  while
 
  foreach my $disk
           map { 
	     my %fsinfo = ();
	     #@fsinfo{qw(name fstype fsver label uuid fsavail fuse mountpoints)} = split /\s+/, $_;
	     
	     foreach my $key (qw(name fstype fsver lable uuid fsavail fsuse mountpoints) {


	     \%fsinfo
	   }
	   map { chomp $_; $_ } (`lsblk -lf`);

  say STDERR Dumper({ disk => \@disk }) if $ENV{DEBUG};

  my @mountpts = ();

  foreach my $disk (@disk) {
    my $openname = first { $_ } $disk->@[qw(label uuid name)];
    my $mntsrc = cryptsetup($disk, $openname);

    say STDERR "Could not open disk with the given passphrase."
             , "Attempting next LUKS partition."
                  && next unless $mntsrc;
    
    if (!$ENV{NOMOUNT}) {
      my $path = mount($mntsrc, "/mnt/$openname")
	      or say STDERR "Could not mount disk:\n$! ($?)";
      push @mountpts, $path
    }
  }
}

run()
