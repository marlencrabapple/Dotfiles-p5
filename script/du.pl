#/usr/bin/env perl
#
use Object::Pad ':experimental(:all)';

package Dotfiles::p5::DiskUsage;

class Dotfiles::p5::DiskUsage;
use utf8;
use v5.42;

use Path::Tiny;
use Getopt::Long;
use List::Util 'uniq';
use IPC::Run3;
use parent 'Exporter';

field $argv   : reader : param //= @ARGV;
field $cliopt : param(dest);
field $size   : param = undef;
field $type   : param = undef;
field $searchptn = qr/./;
field @searchdir = path(Cwd);

ADJUST : params (:$clispec) {

  }

  method getopt_init( $constructor_href, %opt ) {
    GetOptionsFromArray( $argv, 'size=s', 'type=s',
        'search-pattern|search|pattern|searchptn=s',
        'search-dir=s@' );
}

method $run {
  
}

method run : common ($argv = \@ARGV, $clidest = {}, $clispec = [], %opt) {
    my $self = $class->new( argv => $argv, );
    $self->$run
}

package main;

Dotfiles::p5::DiskUsage->run( \@ARGV )
