#!/usr/bin/perl

use warnings;
use English '-no_match_vars';
use strict;
use feature qw(say switch);
use XML::LibXML;
use Readonly;

our $VERSION = 1.3;
Readonly::Scalar my $PROGRAM_NAME => 'Kalulu';
Readonly::Scalar my $EMPTY        => q{};
Readonly::Scalar my $SPACE        => q{ };
Readonly::Scalar my $DIE_MESSAGE  => 'Invalid XML';
Readonly::Scalar my $RANK_LINE    => "+---+---+---+---+---+---+---+---+\n";
Readonly::Scalar my $DASH         => q{-};
Readonly::Scalar my $SLASH        => q{/};
Readonly::Scalar my $SPACES       => $SPACE x 100;
Readonly::Scalar my $MOVETAB      => 9;
Readonly::Scalar my $FALSE        => 0;
Readonly::Scalar my $TRUE         => 1;

my $doc;
my $root;
my $rc;
my @options;

## no critic (ProhibitPostfixControls, ProhibitMagicNumbers, ProhibitExcessComplexity)

$doc = get_input();

$rc = print "$PROGRAM_NAME (v.$VERSION)\n\n";

$root = $doc->getDocumentElement();

do_diagram();

$rc = print "\nSolution\n";
$rc = print "--------\n";

do_setplay();
do_tryplay();
do_actualplay();
do_solvingtime();
do_parameters();
do_footer();

exit 0;

sub get_input {
    my $inxml = $EMPTY;

    while (<>) {
        s/\s//gxsm;
        $inxml .= $_;
    }

    my $locdoc = XML::LibXML->load_xml( string => $inxml );

    return $locdoc;
}

sub get_fen {

    my ( $fors, $stip, $castling, $ep ) = @_;
    my $fen = '(' . $fors;

    if ( $stip =~ /^H/xsm ) {
        $fen .= ' b ';
    }
    else {
        $fen .= ' w ';
    }

    if ( ( defined $castling ) && ( length $castling > 0 ) ) {
        $fen .= $castling;
    }
    else {
        $fen .= $DASH;
    }

    if ( ( defined $ep ) && ( length $ep > 0 ) ) {
        $fen .= $ep;
    }
    else {
        $fen .= ' -';
    }

    $fen .= ' 0 1)';

    return $fen;
}

sub do_diagram {
    my $white = 0;
    my $black = 0;
    my %squares;
    my @cells;
    my @diag;
    my @cast;
    my @stp;
    my @mv;
    my @enpassant;
    my $kings;
    my $gbr;
    my $pos;
    my $text;
    my $sq;
    my $l;
    my $c;
    my $stip;
    my $castling;
    my $ep;

    $squares{a8} = 0;
    $squares{b8} = 1;
    $squares{c8} = 2;
    $squares{d8} = 3;
    $squares{e8} = 4;
    $squares{f8} = 5;
    $squares{g8} = 6;
    $squares{h8} = 7;
    $squares{a7} = 8;
    $squares{b7} = 9;
    $squares{c7} = 10;
    $squares{d7} = 11;
    $squares{e7} = 12;
    $squares{f7} = 13;
    $squares{g7} = 14;
    $squares{h7} = 15;
    $squares{a6} = 16;
    $squares{b6} = 17;
    $squares{c6} = 18;
    $squares{d6} = 19;
    $squares{e6} = 20;
    $squares{f6} = 21;
    $squares{g6} = 22;
    $squares{h6} = 23;
    $squares{a5} = 24;
    $squares{b5} = 25;
    $squares{c5} = 26;
    $squares{d5} = 27;
    $squares{e5} = 28;
    $squares{f5} = 29;
    $squares{g5} = 30;
    $squares{h5} = 31;
    $squares{a4} = 32;
    $squares{b4} = 33;
    $squares{c4} = 34;
    $squares{d4} = 35;
    $squares{e4} = 36;
    $squares{f4} = 37;
    $squares{g4} = 38;
    $squares{h4} = 39;
    $squares{a3} = 40;
    $squares{b3} = 41;
    $squares{c3} = 42;
    $squares{d3} = 43;
    $squares{e3} = 44;
    $squares{f3} = 45;
    $squares{g3} = 46;
    $squares{h3} = 47;
    $squares{a2} = 48;
    $squares{b2} = 49;
    $squares{c2} = 50;
    $squares{d2} = 51;
    $squares{e2} = 52;
    $squares{f2} = 53;
    $squares{g2} = 54;
    $squares{h2} = 55;
    $squares{a1} = 56;
    $squares{b1} = 57;
    $squares{c1} = 58;
    $squares{d1} = 59;
    $squares{e1} = 60;
    $squares{f1} = 61;
    $squares{g1} = 62;
    $squares{h1} = 63;

    foreach my $i ( 0 .. 63 ) {
        push @cells, $SPACE;
    }

    @diag = $root->getChildrenByTagName('Diagram');
    die "$DIE_MESSAGE\n" unless ( scalar @diag == 1 );
    $text = $diag[0]->firstChild()->textContent();
    ( $kings, $gbr, $pos ) = split /:/xsm, $text;

    # White king.
    $sq = substr $kings, 0, 2;
    $cells[ $squares{$sq} ] = 'K';
    $white++;

    # Black king.
    $sq = substr $kings, 2, 2;
    $cells[ $squares{$sq} ] = 'k';
    $black++;

    $l = 0;

    # White queens
    $c = substr $gbr, 0, 1;

    while ( ( $c % 3 ) != 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'Q';
        $c--;
        $l += 2;
        $white++;
    }

    # Black queens
    while ( $c >= 3 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'q';
        $c -= 3;
        $l += 2;
        $black++;
    }

    # White rooks
    $c = substr $gbr, 1, 1;

    while ( ( $c % 3 ) != 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'R';
        $c--;
        $l += 2;
        $white++;
    }

    # Black rooks
    while ( $c >= 3 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'r';
        $c -= 3;
        $l += 2;
        $black++;
    }

    # White bishops
    $c = substr $gbr, 2, 1;

    while ( ( $c % 3 ) != 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'B';
        $c--;
        $l += 2;
        $white++;
    }

    # Black bishops
    while ( $c >= 3 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'b';
        $c -= 3;
        $l += 2;
        $black++;
    }

    # White knights
    $c = substr $gbr, 3, 1;

    while ( ( $c % 3 ) != 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'S';
        $c--;
        $l += 2;
        $white++;
    }

    # Black knights
    while ( $c >= 3 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 's';
        $c -= 3;
        $l += 2;
        $black++;
    }

    # White pawns

    $c = substr $gbr, 5, 1;

    while ( $c > 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'P';
        $c--;
        $l += 2;
        $white++;
    }

    # Black pawns

    $c = substr $gbr, 6, 1;

    while ( $c > 0 ) {
        $sq = substr $pos, $l, 2;
        $cells[ $squares{$sq} ] = 'p';
        $c--;
        $l += 2;
        $black++;
    }

    # Calculate FEN string and print before diagram.
    @options = $root->getChildrenByTagName('options');
    die "$DIE_MESSAGE\n" unless ( scalar @options == 1 );
    @stp = $options[0]->getChildrenByTagName('stip');
    die "$DIE_MESSAGE\n" unless ( scalar @stp == 1 );
    $stip = $stp[0]->firstChild()->textContent();
    @cast = $options[0]->getChildrenByTagName('castling');
    die "$DIE_MESSAGE\n" unless ( scalar @cast == 1 );

    if ( defined( $cast[0]->firstChild() ) ) {
        $castling = $cast[0]->firstChild()->textContent();
    }
    else {
        $castling = $EMPTY;
    }

    @enpassant = $options[0]->getChildrenByTagName('ep');
    die "$DIE_MESSAGE\n" unless ( scalar @enpassant == 1 );

    if ( defined( $enpassant[0]->firstChild() ) ) {
        $ep = $enpassant[0]->firstChild()->textContent();
    }
    else {
        $ep = $EMPTY;
    }

    @mv = $options[0]->getChildrenByTagName('moves');
    die "$DIE_MESSAGE\n" unless ( scalar @mv == 1 );
    $stip .= $mv[0]->firstChild()->textContent();

    my $forsythe = $EMPTY;

    foreach my $i ( 0, 8, 16, 24, 32, 40, 48, 56 ) {

        if ( $i != 0 ) {
            $forsythe .= $SLASH;
        }

        my $number = 0;
        my $ct     = 0;

        foreach my $j ( 0 .. 7 ) {
            my $a = $cells[ $j + $i ];

            if ( $a eq $SPACE ) {
                if ( $number == 0 ) {
                    $number = 1;
                    $ct     = 1;
                }
                else {
                    $ct++;
                }

                if ( $j == 7 ) {
                    $forsythe .= $ct;
                }
            }
            else {
                if ( $number == 1 ) {
                    $forsythe .= $ct;
                    $forsythe .= $a;
                    $number = 0;
                }
                else {
                    $forsythe .= $a;
                    $number = 0;
                }
            }
        }

    }

    my $fen = get_fen( $forsythe, $stip, $castling, $ep );
    $rc = print "$fen\n";

    $rc = print $RANK_LINE;

    foreach my $i ( 0, 8, 16, 24, 32, 40, 48, 56 ) {

        foreach my $j ( 0 .. 7 ) {
            $rc = print "| $cells[$j + $i] ";
        }

        $rc = print "|\n$RANK_LINE";
    }

    # Print stipulation and piece counts under diagram.

    my $pc = sprintf '(%d + %d)', $white, $black;
    my $gap = 33 - ( length $stip ) - ( length $pc );
    printf "%s%s%s\n", $stip, ( substr $SPACES, 0, $gap ), $pc;

    return;
}

sub do_setplay {
    my $rd;

    $rd = print "\nSet play";

    my @sets = $root->getChildrenByTagName('Set');

    if ( scalar @sets == 1 ) {
        my $i   = 1;
        my @bms = $sets[0]->getChildrenByTagName('bm');

        foreach my $bm (@bms) {
            do_black_move( $bm, 1, $i );
            $i++;
        }
    }

    $rd = print "\n";

    return;
}

sub do_tryplay {
    my $re;

    $re = print "\nTry play\n";

    my @tries = $root->getChildrenByTagName('Tries');

    if ( scalar @tries == 1 ) {
        my @wms = $tries[0]->getChildrenByTagName('wm');

        my $i = 0;

        foreach my $wm (@wms) {
            $re = print "\n";
            do_white_move( $wm, 1, $i );
            $i++;
        }
    }

    $re = print "\n";

    return;
}

sub do_actualplay {
    my $rf;

    $rf = print "\nActual play\n";

    my @keys = $root->getChildrenByTagName('Keys');

    if ( scalar @keys == 1 ) {
        my @wms = $keys[0]->getChildrenByTagName('wm');

        my $i = 0;

        foreach my $wm (@wms) {
            $rf = print "\n";
            do_white_move( $wm, 1, $i );
            $i++;
        }
    }

    $rf = print "\n";

    return;
}

sub do_white_move {
    my ( $wm, $mno, $lno ) = @_;
    my $text = $wm->firstChild()->textContent();
    my $ra;
    my $threats = $FALSE;
    my $i;

    if ( $lno > 0 ) {
        $ra = print "\n";
        $ra = print substr $SPACES, 0, ( $mno - 1 ) * 2 * $MOVETAB;
    }

    $ra = printf '%-9s', $text;

    my @thrs = $wm->getChildrenByTagName('thr');

    if ( scalar @thrs > 0 ) {

        my @wms = $thrs[0]->getChildrenByTagName('wm');

        $ra = printf '%-9s', 'thr';

        $i = 0;

        foreach my $nwm (@wms) {
            do_white_move( $nwm, $mno + 1, $i );
            $i++;
        }

        $threats = $TRUE;
    }

    my @bms = $wm->getChildrenByTagName('bm');

    if ( scalar @bms > 0 ) {

        $i = 1;
        foreach my $bm (@bms) {
            do_black_move( $bm, $mno, $i, $threats );
            $i++;
        }
    }

    return;
}

sub do_black_move {
    my ( $bm, $bmno, $lno, $thr ) = @_;
    my $text = $bm->firstChild()->textContent();
    my $rb;
    my $i;

    $text =~ s/[.][.][.]/../xsm;

    if ( $bmno == 1 ) {
        $rb = print "\n";

        if ( $lno == 1 ) {
            $rb = print "\n";
        }

        $rb = print substr $SPACES, 0, 9;
    }
    else {
        if ( $thr == $TRUE ) {
            $rb = print "\n";
            $rb = print substr $SPACES, 0, ( $bmno + ( $bmno - 1 ) ) * $MOVETAB;
        }
        else {
            if ( $lno > 1 ) {
                $rb = print "\n";
                $rb = print substr $SPACES, 0, ( $bmno + ( $bmno - 1 ) ) * $MOVETAB;
            }
        }
    }

    $rb = printf '%-9s', $text;

    my @wms = $bm->getChildrenByTagName('wm');

    if ( scalar @wms > 0 ) {
        $i = 0;
        foreach my $wm (@wms) {
            do_white_move( $wm, $bmno + 1, $i );
            $i++;
        }
    }

    return;
}

sub do_solvingtime {
    my $rg;
    my @stime = $root->getChildrenByTagName('SolvingTime');
    die "$DIE_MESSAGE\n" unless ( scalar @stime == 1 );
    my $st = $stime[0]->firstChild()->textContent();

    $rg = print "\nSolving time: $st seconds\n";

    return;
}

sub do_parameters {
    my $rb;

    $rb = print "\nSolving Parameters\n";
    $rb = print "------------------\n";

    # sols
    my @sols = $options[0]->getChildrenByTagName('sols');
    die "$DIE_MESSAGE\n" unless ( scalar @sols == 1 );
    my $text = $sols[0]->firstChild()->textContent();

    $rb = print "\nIntended solutions: $text,";

    # set
    my @sets = $options[0]->getChildrenByTagName('set');
    die "$DIE_MESSAGE\n" unless ( scalar @sets == 1 );
    $text = $sets[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Set play: $text,";

    # tries
    my @trys = $options[0]->getChildrenByTagName('tries');
    die "$DIE_MESSAGE\n" unless ( scalar @trys == 1 );
    $text = $trys[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Try play: $text\n";

    # refuts
    my @refs = $options[0]->getChildrenByTagName('refuts');
    die "$DIE_MESSAGE\n" unless ( scalar @refs == 1 );
    $text = $refs[0]->firstChild()->textContent();
    $rb   = print "Refutations: $text,";

    # trivialtries
    my @ttrys = $options[0]->getChildrenByTagName('trivialtries');
    die "$DIE_MESSAGE\n" unless ( scalar @ttrys == 1 );
    $text = $ttrys[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Trivialtries: $text,";

    # actual
    my @acts = $options[0]->getChildrenByTagName('actual');
    die "$DIE_MESSAGE\n" unless ( scalar @acts == 1 );
    $text = $acts[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Actual play: $text\n";

    # threats
    my @thr = $options[0]->getChildrenByTagName('threats');
    die "$DIE_MESSAGE\n" unless ( scalar @thr == 1 );
    $text = $thr[0]->firstChild()->textContent();
    $rb   = print "Threats: $text,";

    # fleck
    my @fleck = $options[0]->getChildrenByTagName('fleck');
    die "$DIE_MESSAGE\n" unless ( scalar @fleck == 1 );
    $text = $fleck[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Fleck: $text,";

    # shortvars
    my @sv = $options[0]->getChildrenByTagName('shortvars');
    die "$DIE_MESSAGE\n" unless ( scalar @sv == 1 );
    $text = $sv[0]->firstChild()->textContent();
    $text = ( $text eq 'true' ) ? 'on' : 'off';
    $rb   = print " Shortvars: $text\n";

    return;
}

sub do_footer {

    my $ra;
    my $t = localtime;
    my $tim;

    if ( $t =~ m/(\d\d:\d\d:\d\d)/xsm ) {
        $tim = $1;
    }
    else {
        die "localtime call failed!\n";
    }

    $t =~ s/\d\d:\d\d:\d\d.//xsm;
    $ra = print "\nSolved by $PROGRAM_NAME version $VERSION on $t at $tim\n";

    return;
}

## use critic
