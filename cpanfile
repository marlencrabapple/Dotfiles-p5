requires 'perl', 'v5.40';

requires 'Path::Tiny';
requires 'Getopt::Long';
requires 'List::AllUtils';
requires 'App::cpm';
requires 'Carp';
requires 'IPC::Run3';
requires 'Path::Tiny';
requires 'Getopt::Long';
requires 'Text::Markdown::Hoedown';
requires 'Data::Printer';
requires 'DBI';
requires 'DBD::SQLite';
requires 'DBIx::Connector';
requires 'Inline';
requires 'Inline::C';
requires 'Object::Pad';
requires 'Time::HiRes';
requires 'Syntax::Keyword::Try';
requires 'Syntax::Keyword::Defer';
requires 'Syntax::Keyword::MultiSub';
requires 'Syntax::Keyword::Dynamically';
requires 'Data::Printer';
requires 'Getopt::Long';
requires 'Pod::Usage';
requires 'Path::Tiny';
requires 'File::chdir';
requires 'IPC::Run3';
requires 'IO::Socket::SSL';
requires 'Net::SSLeay';
requires 'List::AllUtils';
requires 'Path::Tiny';
requires 'HTTP::Tinyish';
requires 'JSON::MaybeXS';
requires 'TOML::Tiny';
requires 'Struct::Dumb';
requires 'Future::AsyncAwait';
requires 'IO::Async';
requires 'IO::Async::SSL';
requires 'Const::Fast';

requires 'FFmpeg::Inline',
  url => "file://$ENV{HOME}/FFmpeg-Inline/FFmpeg-Inline-0.01.tar.gz",
  dist => 'CRABAPP/FFmpeg-Inline-0.01-TRIAL.tar.gz';

on 'test' => sub {
  requires 'Test::More', '0.98';
  requires 'Test::CPAN::Meta', '0.25',
  requires 'Test::PAUSE::Permissions';
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
  requires 'ExtUtils::MakeMaker'
};

on 'build' => DEV_PREREQS;
on 'develop' => DEV_PREREQS;

