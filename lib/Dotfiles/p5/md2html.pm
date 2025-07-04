use Object::Pad ':experimental(:all)';

package Dotfiles::p5::md2html;
role Dotfiles::p5::md2html;

use utf8;
use v5.42;

use Encode qw(encode decode);
use Path::Tiny;
use Const::Fast;
use Data::Dumper;
use Text::Markdown::Hoedown;

use Dotfiles::p5;

field $queue :param = [];
field $opts :param = {};

method md2html :common ( $mdin = undef, %args ) {
    my ( $mdfile, $mdstr, $out );

    const state $SEPRE => qr/^\s*-{1}\s*$/;

    if ( -e $mdin ) {
        $mdfile = path($mdin);
        $mdstr  = $mdfile->slurp_utf8;
        Dotfiles::p5::dmsg( { mdin => $mdin, mdfile => $mdfile } );
    }
    
    if ( $mdin =~ s/$SEPRE// ) {
        if ( my @mdarr = <<>> ) {
            $mdstr = join "\n", map { chomp $_; $_ } (@mdarr);
        }

        Dotfiles::p5::dmsg({ mdin => $mdin, mdstr => $mdstr });
    }

    if ( $args{css} ) {
        $out =
          -e $args{css}
          ? path( $args{css} )->slurp_utf8
          : "<style>$args{css}</style>";
    }

    const our $FILEEXT_RE => qr/\.(md|mkd)$/i;

    if ( !$mdfile || $mdin =~ $FILEEXT_RE ) {
        $out .= markdown(
            encode( 'UTF-8', $mdstr // $mdin ),
            html_options => HOEDOWN_HTML_HARD_WRAP | HOEDOWN_HTML_ESCAPE,
            extensions   => HOEDOWN_EXT_TABLES | HOEDOWN_EXT_FENCED_CODE |
              HOEDOWN_EXT_FOOTNOTES | HOEDOWN_EXT_AUTOLINK |
              HOEDOWN_EXT_STRIKETHROUGH | HOEDOWN_EXT_UNDERLINE |
              HOEDOWN_EXT_HIGHLIGHT | HOEDOWN_EXT_QUOTE |
              HOEDOWN_EXT_SUPERSCRIPT | HOEDOWN_EXT_MATH
        );
    }
    else {
        ($out) = map { "<pre>$_</pre>" } ( $mdstr // $mdin );
    }

    $args{out}
      ? sub { path( $args{out} )->spew_utf8($out); exit $? }
      ->()
      : $out;
}
