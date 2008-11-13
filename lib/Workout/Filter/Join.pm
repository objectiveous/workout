package Workout::Filter::Join;

=head1 NAME

Workout::Filter::Join - Join blocks within Workout data

=head1 SYNOPSIS

  $src = Workout::Store::SRM->read( "foo.srm" );
  $join = Workout::Filter::Join->new( $src );
  while( my $chunk = $join->next ){
  	# do something
  }

=head1 DESCRIPTION

Iterator that automagically fills the gaps between individual data blocks
with fake chunks.

=cut

use 5.008008;
use strict;
use warnings;
use base 'Workout::Filter::Base';
use Carp;

our $VERSION = '0.01';

=head2 new( $src, $arg )

new iterator

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new( @_ );
	$self->{queued} = undef;
	$self->{prev} = undef;
	$self;
}

=head2 next

get next data chunk

=cut

sub next {
	my( $self ) = @_;

	if( $self->{queued} ){
		$self->{prev} = $self->{queued};
		$self->{queued} = undef;
		$self->{cntout}++;
		return $self->{prev};
	}

	my $i = $self->src->next
		or return;
	$self->{cntin}++;

	my $prev = $self->{prev};
	my $o = $i->clone;

	my $ltime = $i->time - $i->dur;
	if( $prev && (my $dur = $ltime - $prev->time) > 0.1){
		$self->debug( "inserting ". $dur ."sec at ". $ltime);
		# on block boundaries: 
		#   queue current chunk and insert fake chunk
		$self->{queued} = $o;

		$o = Workout::Chunk->new( {
			time    => $ltime,
			dur     => $dur,
			prev	=> $prev,
		} );
		$self->{queued}->prev( $o );

	} else {
		$o->prev( $prev );
	}

	$self->{prev} = $o;
	$self->{cntout}++;
	return $o;
}


1;
__END__

=head1 SEE ALSO

Workout::Filter::Base

=head1 AUTHOR

Rainer Clasen

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Rainer Clasen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
