#!/usr/bin/env perl

use Object::Pad ':experimental(:all)';

package Find::pl;
class Find::pl    #:isa(Dotfiles::p5);

  use utf8;
use v5.40;

use lib 'lib';

use Cwd 'abs_path';
use File::Basename;
use File::Copy;
use File::Find;
use Getopt::Long qw':config bundling auto_abbrev';
use Time::HiRes 'gettimeofday';
use List::AllUtils qw(any first uniq);
use Const::Fast;
use Data::Dumper;
use Syntax::Keyword::Try;
use Syntax::Keyword::Dynamically;
use Path::Tiny;
use Pod::Usage;

use Dotfiles::p5;

use subs qw'cp epoch dmsg';

const our $DEBUG => $ENV{DEBUG} // 0;

const our $FILETYPE_ISFILE => 'f';
const our $FILETYPE_ISDIR  => 'd';
const our $WANTEDALL_RE    => qr/.*/;

field $argv : reader : param = \@ARGV;

field $cliopts : param = {

    #type      => [],
    #extension => [],
    #exclude   => [],
};

field $wanted     : param = $WANTEDALL_RE;
field $searchdirs : param = ();

#ADJUSTPARAMS($params) {

#}

method epoch : common ( $sep = '' ) {
    join $sep, gettimeofday;
}

method cp ( $src, $dest ) {
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

method file_ext_match ( $basename, $testexts, $opts ) {
    state %exttest_re = ();
    return 1 unless $testexts && ref $testexts eq 'ARRAY';
    any {
        $exttest_re{$_} = qr/^.*\.$_$/;
        $basename =~ $exttest_re{$_}
    } $testexts->@*;
}

method path_match( $path, $wanted //= $self->wanted ) {
    $path =~ $wanted;
}

method filter_by_type ( $path, @types ) {
    const my $typeallow_re => qr/^([efdlxsr]{1})$/;
    const my $isfiledir_re => qr/^([fd]{1})$/;

    dmsg( { path => $path, types => \@types } );
    return 1 unless scalar @types;

    my $file_allowed = 0;

    #state %allow_types =
    #$file_allowed = eval "-$_ $path";

# TODO: Totally map out logic for filetype filtering (i.e. `-f || -d` vs
# `-f && -l`, the former being an error (a fnode cannot be both a directory and
# regular file) unless we are to make an exception for this (and possibly
# other) cases
# - does whether or not we "follow" a symlink matter? we will run into matches
# that are also links to directories
# - mark with some sort of modifier?
#   = -t "type1|[|]type2|[||...]"
# - think each combination through and hopefully find a pattern that already exists to copy/implement
# - ...
#
    my $filetype;

    foreach my $type (
        @types = grep {
            dmsg( { type => $_, } );
            $_ =~ $typeallow_re
        } uniq grep { $_ =~ $isfiledir_re } @types,
        @types
      )
    {
        my $filetest_evalstr = "-$type \$path ? '$type' : undef";
        dmsg(
            {
                type             => $type,
                type_valid       => [ $type =~ $typeallow_re ],
                filetest_eval    => [ eval $filetest_evalstr ],
                filetest_evalstr => $filetest_evalstr
            }
        );

        if ( $file_allowed = eval $filetest_evalstr ) {
            if ( $type =~ $isfiledir_re ) {
                $filetype = $1;

                dmsg {
                    type         => $type,
                    filetype     => $filetype,
                    file_allowed => $file_allowed,
                    path         => $path
                };
            }
            last;
        }
    }

    return undef unless $file_allowed;
    $filetype;
}

method wanted ( $basename //= $_ ) {
    my ( $filename, $fname, $name, $base ) = ($basename) x 5;
    state %run_stash = ();

    my $filetype =
      $self->filter_by_type( $File::Find::name, $$cliopts{type}->@* )
      || return 0;

    if ( $filetype eq 'f' ) {
        return 0
          unless $self->file_ext_match( $basename, $$cliopts{extension},
            $cliopts );
    }

    return 0 unless $self->path_match( $File::Find::name, $wanted );

    my %stash = ( 'return' => [] );
    my ( $abs, $file, $path ) = ($File::Find::name) x 3;
    my ( $cwd, $pwd ) = ($File::Find::dir) x 2;

    foreach my $exec ( $$cliopts{'execute'}->@* ) {
        state $firstrun //= 1;
        $firstrun
          && warn
"Warning: -x is currently implemented in such a way that is unsafe for executing arbitrary code!";
        my ( $HOME, $home ) = ( $ENV{HOME} ) x 2;
        my $epoch = __PACKAGE__->epoch;

        # Lazy loaded file contents decoded as utf8 string
        state sub text {
            dmsg { caller => [ caller 0 ] };
            path($File::Find::name)->slurp_utf8;
        }

        if ( my ($ret) = eval "use subs 'text'; $exec" ) {
            push $stash{'return'}->@*, $ret;
        }

        warn $@ if scalar $@;
    }

    1;
}

method run ( $argv = $self->argv, %caller_opts ) {
    dmsg(
        {
            argv       => \@ARGV,
            cliopts    => $cliopts,
            caller     => \%caller_opts,
            wanted     => $wanted,
            searchdirs => $searchdirs
        }
    );

    Getopt::Long::GetOptionsFromArray(
        $argv,
        $cliopts,
        'depth=i',         # TODO: Unimplemented
        'unrestricted',    # TODO: Unimplemented
        'recursive!',      # TODO: Unimplemented
        'type|t=s@',
        'extension|e=s@',
        'exclude|E=s@',
        'execute|x=s@',    # TODO: Note in pod one can use backticks to execute
                           # code in shell rather than as Perl
        'one-file-system',
        'version' => sub { VersionMessage() },
        'help'    => sub { HelpMessage() },
        '<>'      => sub ($bare) {
            if ( $wanted && $wanted ne $WANTEDALL_RE ) {
                push @$searchdirs, $bare if -d $bare;
            }
            else {
                $wanted = qr;$bare;;
            }
        }
    );

    dynamically $wanted = $caller_opts{wanted} // $wanted;

    foreach my $can_csv (qw(extension type exclude)) {
        next unless $$cliopts{$can_csv} isa 'ARRAY';
        $$cliopts{$can_csv} =
          [ split( /,/, join ',', $$cliopts{$can_csv}->@* ) ];
    }

    dmsg(
        {
            argv       => \@ARGV,
            cliopts    => $cliopts,
            caller     => \%caller_opts,
            wanted     => $wanted,
            searchdirs => $searchdirs
        }
    );

    find(
        { wanted => sub { $self->wanted($_) } },
        scalar @$searchdirs ? @$searchdirs : '.'
    );
}

1;

package main;

use utf8;
use v5.40;

#use Find::pl;

Find::pl->new( argv => \@ARGV )->run
