#!/usr/bin/env perl
package Dotfiles::p5::Test::Test;
use Devel::Trace;
$Devel::Trace::TRACE = 1;

use utf8;
use v5.40;

use lib 'lib';

use Test::More;
use Data::Dumper;
use Syntax::Keyword::Try;

foreach my $package ( __PACKAGE__, qw(Dotfiles::p5 Dotfiles::p5::Base) ) {

    warn $package;
    my $usepkg = $package ne __PACKAGE__ ? "use $package;" : '';
    my $eval   = qq{$usepkg %} . $package . '::';
    my %debug  = (

        eval $eval,
        eval   => $eval,    #qq{eval '%' . "$package::"},
        usepkg => $usepkg
    );

    #%debug = eval "use $usepkg %debug = ( %$package:: )";
    warn Dumper( \%debug );

    # try {
    #     my $eval = "$package::dmsg(\%debug)";
    #     warn $eval;
    #     eval "&$eval"
    # }
    # catch ($e) {
    #     warn Dumper( { e => $e } )
    # }
}
