package DataAccess::Builder;
use strict;
use warnings;
use base qw(Exporter);
use DataAccess;

our @EXPORT = qw(
    add_table
);

my %tables;
my $obj;

sub add_table {
    my %args = @_;
    $tables{$args{name}} = \%args;
}

sub build {
    my %args = @_;
    unless ($obj) {
	$obj = DataAccess->new(
	    tables => \%tables,
	    %args,
	);
    }

    return $obj;
}

1;
