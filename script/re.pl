#!/usr/bin/env perl
package CRABAPP::repl;

use utf8;
use v5.40;

use lib 'lib';

use Devel::REPL;

our @plugins =
qw(History LexEnv Colors Commands DDS Packages ShowClass Timing CompletionDriver::Globals DumpHistory OutputCache Nopaste Peek FancyPrompt FindVariable Completion CompletionDriver::INC CompletionDriver::LexEnv CompletionDriver::Keywords CompletionDriver::Methods MultiLine::PPI);

# sub repl($repl //= Devel::REPL->new) {
our $repl = Devel::REPL->new;
  $repl->load_plugin($_) for @plugins;

  $repl->lexical_environment->do(<<'crabappenv');
use Object::Pad ':experimental(:all)';

package CRABAPP::PERL::REPL;

class CRABAPP::PERL::REPL;

use utf8;
use v5.40;

use Path::Tiny;
use List::Util;
use Cwd;
use Digest::SHA;
use Tie::File;
use List::SomeUtils;
use List::UtilsBy;
use Const::Fast;
use JSON::MaybeXS;
use TOML::Tiny;
use Net::SSLeay;
use HTTP::Tinyish;

use IPC::Nosh;
use IPC::Nosh::IO;

our $asdf = "fdsa";
$ENV{DEBUG} = 1;
dmsg( \%:: );

package main;
my $aaa = "123";
our $bbb = "321";
crabappenv

$repl->run;

# repl
