#!/usr/bin/env perl

package Dotfiles::p5::concat;

use utf8;
use v5.40;

use lib 'lib';

use List::Util qw'uniq shuffle';
use Path::Tiny;
use Cwd 'abs_path';
use Getopt::Long 'GetOptionsFromArray';
use Digest::SHA;
use Syntax::Keyword::Try;

use Dotfiles::p5::Base 'dmsg';

use subs qw'fopen';

# sub dmsg ( $msg, %opts ) {
#     warn Dumper($msg) . "\n ($0:__LINE__)";
# }

our %digest = ();
our @input;
our @out;

sub fopen ( $pathto, %opts ) {
    my $file;

    try {
        $file = path($pathto)->assert( sub { $_->exists } )
    }
    catch ($e) {
        warn "Error opening '$pathto': $e"
    }
    finally {
        $file //= path("/$pathto")
    }

    $file;
}

sub add_file ( $file, %opts ) {
    my $path   = path( abs_path($_) );
    my $digest = Digest::SHA::sha512_hex( $path->slurp_raw );
    $digest{$digest} //= [];
    $digest{$digest} = [ uniq( $digest{$digest}->@*, $path ) ];
    $path;
}

our %runopts = ( join => "\n", delim => "\n", unique => 1 );

sub run ( $argv = \@ARGV, %opts ) {
    push $opts{dest}->@*, %runopts;

    GetOptionsFromArray(
        $argv,
        $opts{dest},
        'join=s',
        'outfile=s',
        'unique',
        'shuffle',
        'input-pattern|regexp=s',
        'fmtstr|out-format=s',
        '<>' => sub ($barearg) {
            dmsg( { ARGV => $argv, runopts => \%runopts } );

            $barearg = path( abs_path($barearg) );

            if ( -f $barearg ) {
                push @input, $barearg;
            }
        }
    );

    foreach my $file (@$argv) {
        my $abspath = abs_path($file);
        my $path    = path($abspath);
        push @out, map {
            chomp $_;
            $_
        } $path->lines_utf8;
    }

    say join "\n", @out = uniq @out;
}

run( \@ARGV )
