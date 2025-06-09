#!/usr/bin/env perl
use Object::Pad;

package Find::pl;

class Find::pl;

use utf8;
use v5.40;

#...;

package main;

use utf8;
use v5.40;

use lib 'lib';

use Cwd 'abs_path';
use File::Basename;
use File::Copy;
use File::Find;
use Getopt::Long;
use Time::HiRes 'gettimeofday';
use List::AllUtils qw(any first);
use Const::Fast;
use Data::Dumper;
use Syntax::Keyword::Try;
use Path::Tiny;

use subs qw'cp epoch';

const our $DEBUG => $ENV{DEBUG} // 0;

our %opts = (

    #type      => [],
    #extension => [],
    #exclude   => [],
);

our $wanted;
our @searchdirs;

sub epoch ( $sep = '' ) {
    join $sep, gettimeofday;
}

sub cp ( $src, $dest ) {
    ( $src, $dest ) = map { $_ isa 'ARRAY' ? $_ : [$_] } ( $src, $dest );

    foreach my $srcf (@$src) {
        foreach my $destf (@$dest) {
            try {
                die "File not found: $srcf" unless -e $srcf;

                if (   ( -e $destf && !-w $destf )
                    || ( !-d dirname($destf) ) )
                {
                    die "Cannot write to path: $destf";

                    #unless -w $destf || -d $destf;
                }
            }
            catch ($e) {
                warn "Error copying $srcf to $destf: $e";
                next;
            };

            copy( $srcf, $destf );
        }
    }
}

sub file_ext_match ( $basename, $testexts, $opts ) {
    state %exttest_re = ();
    return 1 unless $testexts && ref $testexts eq 'ARRAY';
    any {
        $exttest_re{$_} = qr/^.*\.$_$/;
        $basename =~ $exttest_re{$_}
    } $testexts->@*;
}

sub path_match ( $path, $wanted ) {
    $path =~ $wanted;
}

sub filter_by_type ( $path, @types ) {
    const my $typeallow_re => qr/^[efdlxsr]{1}$/;

    $DEBUG && warn Dumper( { path => $path, types => \@types } );
    return 1 unless scalar @types;

    my $file_allowed = 0;

    #state %allow_types =
    #$file_allowed = eval "-$_ $path";

# TODO: Totally map out logic for filetype filtering (i.e. `-f || -d` vs
# `-f && -l`, the former being an error (a fnode cannot be both a directory and
# regular file) unless we are to make an exception for this (and possibly
# other) cases
# - mark with some sort of modifier?
#   = -t "type1|[|]type2|[||...]"
# - think each combination through and hopefully find a pattern that already exists to copy/implement
# - ...
#
    my $is_file      = undef;
    my $is_directory = undef;

    foreach my $type (
        @types = grep {
            $DEBUG
              && warn Dumper( { type => $_, } );
            $typeallow_re
        } @types
      )
    {
        $DEBUG
          && warn Dumper(
            { type => $type, type_valid => $type =~ /^f|d$/ ? 1 : 0 } );

        if ( $type =~ /^f|d$/ ) {
            $file_allowed = $type eq 'f' ? $is_file =
              1 : $type eq 'd' ? $is_directory = 1 : undef;
        }

        if ( ($file_allowed) = "-$_ $path" ) {
            last;
        }
    }

    undef unless $file_allowed;
}

sub wanted ( $basename = $_ ) {
    my ( $filename, $fname, $name, $base ) = ($basename) x 5;
    state %run_stash = ();

    return 0
      unless file_ext_match( $basename, $opts{extension}, \%opts );

    return 0 unless path_match( $File::Find::name, $wanted );

    return 0 unless filter_by_type( $File::Find::name, $opts{type}->@* );

    my %stash = ( 'return' => [] );
    my ( $abs, $file, $path ) = ($File::Find::name) x 3;
    my ( $cwd, $pwd ) = ($File::Find::dir) x 2;

    foreach my $exec ( $opts{'execute'}->@* ) {
        my ( $HOME, $home ) = ( $ENV{HOME} ) x 2;
        my $epoch = epoch;

        if ( my ($ret) = eval $exec ) {
            push $stash{'return'}->@*, $ret;
        }

        warn $@ if scalar $@;
    }

    1;
}

sub run {
    GetOptions(
        \%opts,
        'depth=i',
        'unrestricted',
        'type|t=s@',
        'extension|e=s@',
        'exclude|E=s@',
        'execute|x=s@',
        'one-file-system',
        '<>' => sub ($bare) {
            if ($wanted) {
                push @searchdirs, $bare if -d $bare;
            }
            else {
                $wanted = qr;$bare;;
            }
        }
    );

    @searchdirs = ('.') unless scalar @searchdirs;
    $wanted //= qr'.+';

    foreach my $can_csv (qw(extension type exclude)) {
        next unless $opts{$can_csv} isa 'ARRAY';
        $opts{$can_csv} = [ split( /,/, join ',', $opts{$can_csv}->@* ) ];
    }

    $DEBUG && warn Dumper(
        {
            argv       => \@ARGV,
            cliopts    => \%opts,
            wanted     => $wanted,
            searchdirs => \@searchdirs
        }
    );

    find( { wanted => \&wanted }, @searchdirs );
}

run
