#!/usr/bin/env perl
use Object::Pad ':experimental(:all)';

package srv;

class srv : does(Frame::Base);

use utf8;
use v5.40;

use Cwd;
use Path::Tiny;
use Const::Fast;
use Data::Dumper;
use File::Basename;
use Plack::Builder;
use Plack::App::File;
use Plack::App::Directory;
use Plack::Middleware::Static;
use Syntax::Keyword::Dynamically;
use Plack::Middleware::Auth::Basic;
use Crypt::Argon2 qw(argon2id_pass argon2_verify);

const our $DEBUG   => $ENV{DEBUG};
const our $MOUNTRE => qr/^(.+)(?:\:(.+))?$/;

our ( $srvpath, $mount ) = $ARGV[-1] =~ $MOUNTRE;

say Dumper( $srvpath, $mount, \@ARGV, ( $ARGV[-1] =~ $MOUNTRE ) ) if $DEBUG;

our $builder = Plack::Builder->new;

#method callstack : common {
#    my @callstack;
#    my $i = 0;

#    while ( my @caller = caller $i ) {
#        {
#            no strict 'refs';
#            push @caller, \%{"$caller[0]\::"};
#            push @caller, $caller[0]->META() if ${"$caller[0]\::"}{META}
#        }

#        push @callstack, \@caller;
#    }
#    continue { $i++ }

#    @callstack;
#}

sub valid_user ( $user, $pass, $env ) {
    $user eq $ENV{SRV_USER}
      && argon2_verify( $ENV{SRVPATH_PWHASH}, $pass );
}

sub serve_directory ( $path, %args ) {
    (
        Plack::App::Directory->new( { root => $path } )->to_app,
        $args{uri} // '/',

    );
}

sub serve_file ( $file, %args ) {
    (
        Plack::App::File->new( file => $file )->to_app,
        map { s/^([^\/]{1}.+)$/\/$1/r } ( $args{uri} // basename($file) ),

    );
}

sub init ( $path = path( $srvpath // getcwd ), $uri = $mount // undef ) {
    say Dumper( $path, $uri, \@ARGV, ( $ARGV[-1] =~ $MOUNTRE ) ) if $DEBUG;

    my ( $app, $mount ) =
        -f $path ? serve_file( $path, uri => $uri )
      : -d $path ? serve_directory( $path, uri => $uri )
      :   die "Path '$path' does not appear to be a file or directory.";

    Frame::Base::dmsg( mount => $mount, app => $app );

    $builder->mount( $mount => $app );
}

$builder->add_middleware(
    'Auth::Basic',
    authenticator => sub (@args) {
        valid_user(@args);
    }
) unless $ENV{SRVPATH_NOLOGIN};

$builder->add_middleware('Debug') if $ENV{DEVELOPMENT};
$builder->app_middleware('REPL')  if $ENV{REPLWARNING};

unless (caller) {
    require Plack::Runner;

    my $runner = Plack::Runner->new;
    $runner->parse_options( qw(-s Frame::Server), @ARGV );
    $runner->run( init->to_app );

    exit( $? // 0 );
}

init
