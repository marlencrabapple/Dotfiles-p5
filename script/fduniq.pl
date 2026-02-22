#!/usr/bin/env perl

use Object::Pad ':experimental(:all)';
class fduniq;

use v5.40;

use DBIx::Connector;
use DBD::SQLite;
use List::Util 'uniq';
use Path::Tiny;
use TOML::Tiny;
use JSON::MaybeXS;
use Getopt::Long 'GetOptionsFromArray';

use IPC::Nosh;
use IPC::Nosh::IO;

field $in :param;
field $reportpath : param;
field $dbpath : param;

field $conn { DBIx::Connector->new("SQLite:$dbpath")};

field %seen;
field @working;
field @flat;
field @unique;

method flatten ($path) {
  my @flat;
  
  if ($path->is_dir) {
    push @flat, $self->flatten($_) for $path->children;
  }
  else {
    push @flat, $path
  }

  \@flat
}

method $run {
  foreach my $in (@$in) {
    push @flat, $self->flatten($in)->@*
  }

  foreach my $file (uniq map { "" . $_->abs_path } @flat) {
    my $digest = $file->digest;
    $seen{$digest} //= [];
    push $seen{$digest}->@*, $file->abs_path;
    
    if (scalar $seen{$digest}->@* == 1) {
      msg($file);
      push @unique, $file
    }
  }
}

method cli : common ($argv) {
    my %clidest = ( input => [] );

    GetOptionsFromArray(
        $argv,
        \%clidest,
        'input=s{,}',
        #'',
        '<>' => sub ($barearg) {
            my $file = path($barearg);
            push $clidest{input}->@*, $file if $file->exists;
        }
    );

    my $self = fduniq->new(%clidest);
    $self->$run;
}

package main;
fduniq->cli(\@ARGV)
