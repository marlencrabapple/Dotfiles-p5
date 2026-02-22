#!/usr/bin/env perl;
use Object::Pad ':experimental(:all)';

package Dotfiles::p5::fdlist;

class Dotfiles::p5::fdlist;

use utf8;
use v5.40;

use Getopt::Long
  qw(GetOptionsFromArray :config no_ignore_case bundling auto_abbrev);

use IPC::Run3;
use Path::Tiny;

field $fdcmd;
field $outcmd;
field $outpath;

method $run {
}

method run( $argv, %opt ) {
    GetOptionsFromArray( $argv, 'run|cmd|exec|x=s', 'outfile|outpath=s' );
		$outpath = path($outpath);
    die Dumper( argv => $argv );
    run3(
        $argv,
        \undef,
        sub {
            eval
'use v5.40; use utf8; package outcmd; class outcmdrun; method run { path(')'
              . $outcmd
              . ' }; package runoutcmd; $outcmd->run($outpath);'
        }
    );

}

package main;
Dotfiles::p5::fdlist->new->run( \@ARGV )

