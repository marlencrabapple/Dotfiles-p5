#!/usr/bin/env perl

use utf8;
use v5.40;

no warnings 'experimental';

use feature 'defer';
use feature 'try';

use IPC::Run3; # TODO: Try and safely capture output after execution of input
use Const::Fast;
use Getopt::Long 'GetOptionsFromArray';
use List::Util 'uniq';

const our $DEBUG => $ENV{DEBUG} // 0;

# This really should be improved with backreferences...
const our $SHVAR_PTN => qr!
  (?:\$\{)?
    ([A-Z_]{1}
     [A-Z0-9_]+)
  \}?
  (?:([+=\-]{1,2})
  ((["'])?
    ([.]+)
  (["'])?)?)?
!x;

sub run ($argv, $len = scalar @$argv) {
  my @queue;
  my %cliopts = ();
  
  GetOptionsFromArray($argv, \%cliopts
	  , 'line-numbers'
	  , 'values'
	  , 'format|fmtstr|printf'
	  , 'current_values'
	  , 'run_values=s%' # incremental,block,run
	  , 'file_values',
	  , '<>' => sub ($barearg) {
	      	push @queue, $barearg if -f $barearg;
	     });
  
  foreach my $file (@queue) {
    my @file_env;

    open my $fh, "<:encoding(UTF-8)", $file or die "$?: $!";
    
    defer { close $fh; $DEBUG
        && warn "Closing file handle '$fh' for '$file'" };
    my $i = 0;
    defer { $i = 0 };
    
    while (my $line = <$fh>) {
      $i++;
      chomp $line;
      
      if (my (@matched) = ($line =~ $SHVAR_PTN)) {
        my $envvar = $matched[0];

        warn Dumper({ envvar => $envvar, matched => \@matched }) if $DEBUG;
        
        if ($ENV{$envvar}) {
          $envvar = "$envvar ( =\"$ENV{$envvar}\" )"
        }

        push @file_env, "$i: $envvar"
  
      }
    }

    return map {
      $cliopts{format} ? sprintf "", $_ : $_
    } uniq @file_env
  }
}

say join "\n", run(\@ARGV)
