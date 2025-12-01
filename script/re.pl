#!/usr/bin/env perl

package CRABAPP::repl;

#
# TODO: Replace with profile for Devel::REPL
#
#
use utf8;
use v5.40;

use Object::Pad ':experimental(:all)';
use Path::Tiny;
use List::Util;
use Cwd;
use Digest::SHA;
use File::Find;
use Tie::File;
use List::SomeUtils;
use List::UtilsBy;
use Const::Fast;
use JSON::MaybeXS;
use Data::Dumper;
use Data::Printer;
use IPC::Run3;
use lib 'lib';

#use Dotfiles::p5::Base 'dmsg';
use Devel::REPL;

our $repl = Devel::REPL->new;
our @plugins =
  qw(History LexEnv Colors Commands DDS Packages ShowClass Timing  CompletionDriver::Globals DumpHistory OutputCache Nopaste Peek FancyPrompt FindVariable)
  ;    #ReadlineHistory);

# Dotfiles::p5::Base::dmsg( { repl => $repl } );

$repl->load_plugin($_) for @plugins;

# Dotfiles::p5::Base::dmsg( { repl => $repl, load_plugin => \@plugins } );

our $ret = $repl->run;

# Dotfiles::p5::Base::dmsg( { repl => $repl, run_ret => $ret } );
