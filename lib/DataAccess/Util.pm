package DataAccess::Util;
use strict;
use warnings;


my $esc_br = '__<<BR>>__';
my $esc_tab = '__<<TAB>>__';


sub openfile2array {
    my ($filepath) = @_;


    die "Not found file '$filepath'" unless -e $filepath;

    open my $fh, '<', $filepath or die "Can't open file '$filepath': $!";
    flock($fh, 1);
    my @data_org = <$fh>;
    close $fh;

    my @data;
    for (@data_org) {
	$_ =~ s/\r\n//g;
	$_ =~ s/\r//g;
	$_ =~ s/\n//g;
	if($_){
	    push @data, $_;
	}
    }

    return @data;
}


sub br2str {
    my $text = shift;
    return $text unless $text;
    $text =~ s/\r\n|\r|\n/$esc_br/g;
    $text;
}

sub str2br {
    my $text = shift;
    return $text unless $text;
    $text =~ s/$esc_br/\n/;
    $text;
}


sub tab2str {
    my $text = shift;
    return $text unless $text;
    $text =~ s/\t/$esc_tab/g;
    $text;
}

sub str2tab {
    my $text = shift;
    return $text unless $text;
    $text =~ s/$esc_tab/\t/g;
    $text;
}

sub esc_data {
    my $text = shift;
    $text = tab2str($text);
    $text = br2str($text);
    $text;
}

sub unesc_data {
    my $text = shift;
    $text = str2tab($text);
    $text = str2br($text);
    $text;
}

1;
