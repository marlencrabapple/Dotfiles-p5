use utf8;
use v5.40;

requires 'perl', 'v5.40';

requires 'Object::Pad';
requires 'Const::Fast';
requires 'Path::Tiny';
requires 'Getopt::Long';
requires 'List::AllUtils';
requires 'App::cpm';
requires 'Carp';
requires 'IPC::Run3';
requires 'Text::Markdown::Hoedown';
requires 'DBI';
requires 'DBD::SQLite';
requires 'DBIx::Connector';
requires 'Inline';
requires 'Inline::C';
requires 'Time::HiRes';
requires 'Syntax::Keyword::Try';
requires 'Syntax::Keyword::Defer';
requires 'Syntax::Keyword::Dynamically';
requires 'Data::Printer';
requires 'Pod::Usage';
requires 'File::chdir';
requires 'IPC::Run3';
requires 'IO::Socket::SSL';
requires 'Net::SSLeay';
requires 'HTTP::Tinyish';
requires 'JSON::MaybeXS';
requires 'TOML::Tiny';
requires 'Struct::Dumb';
requires 'Future::AsyncAwait';
requires 'IO::Async';
requires 'IO::Async::SSL';
requires 'Devel::Trace';
requires 'Devel::REPL';

use constant CPAN_MIRROR => ( mirror => 'https://ppan.softsrv.net/~CRABAPP' );

sub { requires shift, CPAN_MIRROR }
  ->($_) for qw(Frame FFmpeg::Inline IPC::Nosh App::md2html);

#requires 'Frame';
#requires 'FFmpeg::Inline';
#requires 'App::md2html';
#requires 'IPC::Nosh';

on 'test' => sub {
    requires 'Test::More';
    requires 'Test::CPAN::Meta';
    requires 'Test::Spellunker';
    requires 'Test::MinimumVersion::Fast';
};

use constant DEV_PREREQS => sub {
    requires 'App::cpm';
    requires 'Minilla';
    requires 'Minilla::Profile::ModuleBuildTiny';
    requires 'Perl::Critic';
    requires 'Perl::Tidy';
    requires 'App::perlimports';
    requires 'Perl::Critic::Community';
    requires 'Inline';
    requires 'Inline::C';
    requires 'Inline::MakeMaker';
    requires 'ExtUtils::MakeMaker';
};

on 'build' => DEV_PREREQS;
on 'develop' => DEV_PREREQS
