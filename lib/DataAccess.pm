package DataAccess;
use strict;
use warnings;
use Class::Accessor::Lite
    rw => [ qw(
        tables
    ) ];
use DataAccess::Util;

our $VERSION = '0.01';


sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;

    bless {
	tables => {},
	%args,
    }, $class;
}

sub insert {
    my ($self, $table, $data) = @_;

    my @reg = $self->_sort_data($table, $data);

    my $file_path = $self->_file_path($table);
    my @rows = DataAccess::Util::openfile2array($file_path);
    push @rows, join("\t", @reg);

    $self->_update_file($table, join("\n", @rows));
    $self;
}

sub update_by_id {
    my ($self, $table, $data, $id) = @_;

    my $pk = $self->tables->{$table}->{pk};
    my @new_rows;
    for my $row ($self->get_rows($table)) {
	if ($row->{$pk} eq $id) {
	    while (my ($key, $value) = each %$row) {
		if (defined $data->{$key}) {
		    $row->{$key} = $data->{$key};
		}
	    }
	}

	push @new_rows, join("\t", $self->_sort_data($table, $row));
    }

    $self->_update_file($table, join("\n", @new_rows));
    $self;
}

sub delete_by_id {
    my ($self, $table, $id) = @_;

    my $pk = $self->tables->{$table}->{pk};
    my @new_rows;
    for my $row ($self->get_rows($table)) {
	if ($row->{$pk} ne $id) {
	    push @new_rows, join("\t", $self->_sort_data($table, $row));
	}
    }

    $self->_update_file($table, join("\n", @new_rows));
    $self;
}

sub search_by_id {
    my ($self, $table, $id) = @_;

    my $pk = $self->tables->{$table}->{pk};
    my $ret;
    for my $row ($self->get_rows($table)) {
	if ($row->{$pk} eq $id) {
	    $ret = $row;
	    last;
	}
    }

    return $ret;
}

sub get_rows {
    my ($self, $table) = @_;

    my $file_path = $self->_file_path($table);
    my @cols = @{$self->tables->{$table}->{columns}};

    my @rows;
    for my $row ( DataAccess::Util::openfile2array($file_path) ) {
	my @d = split(/\t/, $row);

	my %hash;
	for (my $i = 0; $i <= $#d; $i++) {
	    $hash{ $cols[ $i ] } = $d[ $i ];
	}

	push @rows, \%hash;
    }

    return @rows;
}

sub _file_path {
    my ($self, $table) = @_;
    return $self->{data_dir} . $table . ".dat";
}

sub _sort_data {
    my ($self, $table, $data) = @_;

    my @cols = @{$self->tables->{$table}->{columns}};
    my @reg;
    for my $col (@cols) {
	push @reg, DataAccess::Util::esc_data($data->{$col}) || '';
    }

    return @reg;
}

sub _update_file {
    my ($self, $table, $data) = @_;

    my $file_path = $self->_file_path($table);
    open my $fh, '>', $file_path or die "Can't open file '$file_path': $!";
    flock($fh, 2);
    truncate($fh, 0);
    seek($fh, 0, 0);
    print {$fh} $data;
    close $fh;
}


1;
__END__

=head1 NAME

DataAccess -

=head1 SYNOPSIS

  use DataAccess;

=head1 DESCRIPTION

DataAccess is

=head1 AUTHOR

memememomo E<lt>memememomo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
