#!/usr/bin/env perl

package Dotfiles::p5::Mount;

use v5.40;

use TOML::Tiny;
use IPC::Nosh;
use IPC::Nosh::Common;

our @mountarg = (
    [qw(--bind /mnt/newroot/bs /bs)],
    [qw( --bind /mnt/newroot/.bschroot/ /bs/chroot )],
    [qw( --bind /bs/cgit/pennylinux/pkgbuild /bs/pkgbuild )],
    [qw( --bind /bs/src /bs/cgit/pennylinux/srccache )],
    [qw( --bind /home/nameless/mnt/taargus@pi4u2.d/bs/repo /bs/repo )],
    [qw( --bind /mnt/newroot/.bschroot/ /bs/chroot)]
);

foreach my $arg_aref (@mountarg) {
    my $run = run( [ 'mount', @$arg_aref ] );
    dmsg $run;
}
