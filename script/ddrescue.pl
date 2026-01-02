#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package ddrescuepl;

class ddrescuepl;

use utf8;
use v5.40;

use Const::Fast;
use Getopt::Long;

const our $ddrescue => 'ddrescue';

# field $argv :param;
field $ssize        : param = $ENV{SECTORSIZE};
field $indev        : param;
field $outpath      : param;
field $rescuemap    : param = "rescue-" . time . '.map';
field $reverse      : param = 1;
field $ignoreerrors : param = 1;

field @ioarg = ( $indev, $outpath, $rescuemap );

field @round {
    (
        {
            cmd => [
                $ddrescue, qw'--force --noscrape',
                @ioarg, ( $ssize ? "--sector-size=$ssize" : () )
            ]
        },

        {
            cmd =>
              [ $ddrescue, qw'--force --noscrape --idirect --retry-passes=3' ],
            fatal => {
                cond => sub ($status) { $status > 0 },
                cb   => sub {
                    say STDERR
                      "Error encountered. If it takes the form of 'ddrescue: "
                      . "$indev: Unaligned read error...' run this script again "
                      . "with the following additional options:";

                    my $ss;
                    run3( [ qw'blockdev --getss', $indev ], \undef, \$ss );
                    chomp $ss;

                    say STDERR "`"
                      . ( join " ", $0, "--ss=$ss", map { qq{"$_"} } @ioarg )
                      . "`";
                }
            }
        },
        {
            cmd => [
                $ddrescue,
                ( $ssize ? "--sector-size=$ssize" : () ),
                qw'--force --idirect --retry-passes=1 --reverse', @ioarg
            ],
            cond => sub { $reverse }
        },
        {
            cmd => [
                [ $ddrescue,   qw'--force --idirect --retry-passes=3', @ioarg ],
                [ qw(fsck -f), $outpath ]
            ]
        },
        {
            cmd => [ $ddrescue, qw'--force --verify', @ioarg ]
        }
    )
};

method $run {
    my $i = 1;

    foreach my $round (@round) {
        say "Round #$i:";

        foreach
          my $cmd ( $$round{cmd} isa 'ARRAY' ? $$round{cmd}->@* : $$round{cmd} )
        {
            if ( $$round{cond} && $$round{cond} isa 'CODE' ) {
                next unless $$round{cond}->();
            }

            run3( $cmd, \undef, );
            my $status = $?;

            if ( $$round{fatal} && $round->{fatal}{cond}->($status) ) {
                my $ret = $round->{fatal}{cb}->();
                die( $ret // $status );
            }
        }

        $i++;
    }
}

method run : common ($argv = \@ARGV) {
    my %clidest;
    GetOptionsFromArray( $argv, \%clidest, 'sectorsize|ssize|ss=i',
        'input|indev=s', 'output|outdev=s', 'reverse!', 'ignore-errors' );
    my $self = $class->new(%clidest);
    $self->$run;
}

package main;

ddrescuepl->run( \@ARGV )
