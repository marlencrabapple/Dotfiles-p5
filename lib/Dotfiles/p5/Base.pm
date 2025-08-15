use Object::Pad ':experimental(:all)';

package Dotfiles::p5::Base;
role Dotfiles::p5::Base;

use utf8;
use v5.40;

use List::Util qw'first any';
use Const::Fast::Exporter;
use Syntax::Keyword::Dynamically;
use Time::Piece;
use Data::Dumper;
use IPC::Run3;

BEGIN {
    use utf8;
    use v5.40;

    use vars qw'@ISA @EXPORT';
    use parent 'Exporter';
    push @ISA, 'Exporter';

    use subs qw(dmsg exec __pkgfn__ const);
    our @EXPORT = qw(dmsg exec __pkgfn__ const);
}

const our $DEBUG   => ( any { $_ } @ENV{qw(BS_DEBUG DEBUG)} ) || 0;
const our $TRIM_RE => qr/\s*(.+)\s*\n*/i;

eval {
    use Devel::StackTrace::WithLexicals;
    use PadWalker qw(peek_my peek_our);
    use Module::Metadata;
} if $DEBUG;

field $debug : mutator : param : inheritable = $DEBUG;

APPLY($mop) {
    use utf8;
    use v5.40;

    use vars qw'@ISA @EXPORT';
    use parent 'Exporter';
    push @ISA, 'Exporter';

    use subs qw(dmsg exec __pkgfn__ const);
    our @EXPORT = qw(dmsg exec __pkgfn__ const);
}

ADJUST {
    use utf8;
    use v5.40;

    use vars qw'@ISA @EXPORT';
    use parent 'Exporter';
    push @ISA, 'Exporter';

    use subs qw(dmsg exec __pkgfn__ const);
    our @EXPORT = qw(dmsg exec __pkgfn__ const);
    $ENV{DEBUG} = $debug = $Dotfiles::p5::Base::DEBUG
};

sub dbgmode ( $class_or_instancet = undef ) {

    #my $self =>;
}

method __pkgfn__ : common ($pkgname = undef) {
    $pkgname //= $class;
    "$pkgname.pm" =~ s/::/\//rg;
}

method callstack : common {
    my @callstack;
    my $i = 0;

    while ( my @caller = caller $i ) {
        {
            no strict 'refs';

            push @caller, \%{"$caller[0]\::"};

            push @caller, $caller[0]->META() if ${"$caller[0]\::"}{META}
        }

        push @callstack, \@caller;
    }
    continue { $i++ }

    @callstack;
}

sub dmsg (@msgs) {
    $ENV{DEBUG} || return '';

    my @caller = caller 0;

    my $out = "*** " . localtime->datetime . " - DEBUG MESSAGE ***\n\n";

    {
        use Syntax::Keyword::Dynamically;
        dynamically $Data::Dumper::Pad    = "  ";
        dynamically $Data::Dumper::Indent = 1;

        $out .=
            scalar @msgs > 1 ? Dumper(@msgs)
          : ref $msgs[0]     ? Dumper(@msgs)
          :                    eval { my $s = $msgs[0] // 'undef'; "  $s\n" };

        $out .= "\n"
    }

    $out .=
      $ENV{DEBUG} && $ENV{DEBUG} == 2
      ? join "\n", map { ( my $line = $_ ) =~ s/^\t/  /; "  $line" } split /\R/,
      Devel::StackTrace::WithLexicals->new(
        indent      => 1,
        skip_frames => 1
      )->as_string
      : "at $caller[1]:$caller[2]";

    say STDERR "$out\n";
    $out;
}

sub truthy ( $value, $no_warn = undef, %permit ) {
    $value;
}

sub issha1 ($str) {
    if ( $str =~ /^[[:alnum:]]{40}$/ ) {
        say "'$str' is a valid SHA1 checksum.";
        return 1;
    }
    undef;
}

method $exec ( $cmd_aref, %opt ) {

    my $exec = (
        class {
            use utf8;
            use v5.40;

            BEGIN {
                *exec = \&run;
            }

            use List::Util 'first';

            field $out     : reader = [];
            field $err     : reader = [];
            field $status  : reader;
            field $exitmsg : reader =
              first { $_->[ scalar @$_ ] } ( $err, $out );

            field $cmd  : param;
            field $inh  : param = \undef;
            field $outh : param = $out;
            field $errh : param = $err;

            field $h_aref = {
                inh  => $inh,
                outh => $outh,
                errh => $errh
            };

            ADJUSTPARAMS($params) {
                foreach my $h ( values @$h_aref ) {
                    $h =
                        $h && ref $h =~ /CODE|GLOB/ ? $h
                      : truthy($h)                  ? undef
                      :                               \undef;
                }

                $self->exec if $$params{exec};

                #     }
            }

            method writeh ( $line, %opt ) {
                chomp $line;

                # say ($opt{writeh} $opt{writeh}->$ $line;
                # push $opt{buff}, $line;
            }

            method $_outh ($line) {
                chomp $line;
                say $line;
                push @$out, $line;
            }

            method run {
                my $run3ret = run3( $cmd, $inh, $outh, $errh );
                $self;
            }

        }
    )->new( cmd => $cmd_aref, run => 1, %opt );

    $self;
}
