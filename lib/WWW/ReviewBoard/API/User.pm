use strict;
use warnings;

package WWW::ReviewBoard::API::User;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'user' }

has email => (
	is  => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		return $self->raw->{email};
	}
);

1
