#!/usr/bin/env perl
use utf8;
use v5.40;

sub unwrap (@lines) {
    my @nowrap = ();

    for my $line ( map { $_ =~ s/^\s*# //; $_ } @lines ) {
        state $curr //= "";

        if ( !$curr || ( $line =~ /^(\s*- .*)?$/g ) ) {
            $curr =~ s/\s{2,}/ /g;
            push @nowrap, $curr;
            $curr = $line;
        }
        else { $curr .= ( $line =~ s/^[\s\t]*(.+)[\s\t]*$/$1/rg ); }
    }

    say join "\n", @nowrap;
}
