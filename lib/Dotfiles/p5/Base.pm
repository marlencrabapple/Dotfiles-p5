use Object::Pad ':experimental(:all)';

package Dotfiles::p5::Base;
role Dotfiles::p5::Base;

use utf8;
use v5.40;

use List::Util qw'first any';
use Const::Fast::Exporter;
use Syntax::Keyword::Dynamically;
use Time::Piece;

our $DEBUG => ( any { $_ } @ENV{qw(DOTFILESP5_DEBUG DEBUG)} ) || 0;
const our $TRIM_RE => qr/\s*(.+)\s*\n*/i;

field $debug : mutator : param : inheritable = $DEBUG;

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

method slugify : common ( $in, %opt ) {
    $opt{replace} //= ( $ENV{SLUGIFY_REPLACE} // '_' );
    ( $in =~ s/[^a-z0-9_.+=-]+/$opt{replace}/gir );
}
