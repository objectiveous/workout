=head1 NAME

Workout::Store::Gpx - read/write GPS tracks in XML format

=head1 SYNOPSIS

  $src = Workout::Store::Gpx->new( "foo.gpx" );
  while( $chunk = $src->next ){
  	...
  }

=head1 DESCRIPTION

Interface to read/write GPS files

=cut

package Workout::Store::Gpx::Iterator;
use 5.008008;
use strict;
use warnings;
use base 'Workout::Iterator';
use Carp;

sub new {
	my( $class, $store, $a ) = @_;

	my $self = $class->SUPER::new( $store, $a );
	$self->{ctrack} = 0;
	$self->{cseg} = 0;
	$self->{cpt} = 0;
	$self->{lpt} = undef;
	$self;
}


=head2 next

=cut

sub next {
	my( $self ) = @_;
	
	my $tracks = $self->store->{tracks};
	while( $self->{ctrack} < @$tracks ){
		my $track = $tracks->[$self->{ctrack}];

		# next track?
		if( @{$track->{segments}} <= $self->{cseg} ){
			$self->{ctrack}++;
			$self->{cseg} = 0;
			$self->{cpt} = 0;
			$self->{lpt} = undef;
			next;
		}
		my $seg = $track->{segments}[$self->{cseg}];

		# next segment?
		if( @{$seg->{points}} <= $self->{cpt} ){
			$self->{cseg}++;
			$self->{cpt} = 0;
			$self->{lpt} = undef;
			next;
		}

		# next point!
		my $pt = $seg->{points}[$self->{cpt}++];
		$pt->{dur} = $self->calc->dur( $pt, $self->{lpt} );
		$self->{lpt} = $pt;
		return $pt if $pt->{dur};
	}
	return;
}



package Workout::Store::Gpx;
use 5.008008;
use strict;
use warnings;
use base 'Workout::Store::File';
use Carp;
use Geo::Gpx;

our $VERSION = '0.01';

our @fsupported = qw( ele lon lat ); # TODO
our @frequired = qw( lon lat );

sub filetypes {
	return "gpx";
}

sub new {
	my( $class, $fname, $a ) = @_;

	my $self = $class->SUPER::new( $fname, $a );

	push @{$self->{fsupported}}, @fsupported;
	push @{$self->{frequired}}, @frequired;
	$self->{blocks} = undef; # list with data block offsets
	$self->{chunk} = 0; # chunks read in current block
	$self;
}

=head2 iterate

=cut

sub iterate {
	my( $self ) = @_;

	if( ! $self->{tracks} ){
		my $gpx = Geo::Gpx->new( input => $self->fh )
			or croak "cannot read file: $!";

		$self->{tracks} = $gpx->tracks;
	};

	Workout::Store::Gpx::Iterator->new( $self );
}

# TODO: block_add
# TODO: chunk_add
# TODO: flush

1;
__END__

=head1 SEE ALSO

Workout::Store::File

=head1 AUTHOR

Rainer Clasen

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Rainer Clasen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut