#use Object::Pad ':experimental(:all)';

package Dotfiles::p5;

#class Dotfiles::p5 : abstract;

use utf8;
use v5.40;

our $VERSION = "0.01";

use Data::Dumper;
use Const::Fast;
use Const::Fast::Exporter;
use Syntax::Keyword::Dynamically;
use Time::Moment;
use Time::Piece;

use Exporter qw(import);

BEGIN {
    our @EXPORT = qw(dmsg);
}

our $DEBUG = $ENV{DEBUG} // 0;

eval { use Devel::StackTrace::WithLexicals } if $DEBUG;

use subs 'dmsg';

$DEBUG && dmsg INC => \@INC;

sub dmsg (@msgs) {
    $DEBUG || return '';

    my @caller = caller 0;

    my $out = "*** " . localtime->datetime . " - DEBUG MESSAGE ***\n\n";

    {
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

__END__

=encoding utf-8

=head1 NAME

Dotfiles::p5 - It's new $module

=head1 SYNOPSIS

    use Dotfiles::p5;

=head1 DESCRIPTION

Dotfiles::p5 is ...

=head1 LICENSE

Copyright (C) Ian P Bradley.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ian P Bradley E<lt>ian.bradley@studiocrabapple.comE<gt>

=cut
