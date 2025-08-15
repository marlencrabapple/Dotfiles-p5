use utf8;
use v5.40;

use Devel::Trace;
use Test::More;

$Devel::Trace::TRACE = 1 if $ENV{DEVEL_TRACE};

use_ok $_ for qw(
  Dotfiles::p5
);

done_testing
