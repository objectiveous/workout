#
# Copyright (c) 2008 Rainer Clasen
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

=head1 NAME

Workout::Filter::Base - Base Class to filter Workout chunks

=head1 DESCRIPTION

Base Class for modifying and filtering the Chunks of a Workout. Inherits
from Workout::Iterator.

=cut

package Workout::Filter::Base;

use 5.008008;
use strict;
use warnings;
use base 'Workout::Iterator';
use Carp;

our $VERSION = '0.01';

=head1 CONSTRUCTOR

=head2 new( $src, \%arg )

creates the filter.

=cut

sub new {
	my( $class, $iter, $a ) = @_;

	$iter->isa( 'Workout::Iterator' )
		or $iter = $iter->iterate( $a );

	$a ||= {};
	$class->SUPER::new( $iter, {
		%$a,
		queue	=> [],
	});
}

# TODO: POD

sub _push {
	my $self = shift;
	push @{$self->{queue}}, @_;
}

sub _pop {
	my $self = shift;
	pop @{$self->{queue}};
}

sub _fetch {
	my( $self ) = @_;

	if( my $r = $self->_pop ){
		return $r;
	}

	if( my $r = $self->src->next ){
		$self->{cntin}++;
		return $r;
	}

	return;
}


1;
__END__

=head1 SEE ALSO

Workout::Iterator

=head1 AUTHOR

Rainer Clasen

=cut

