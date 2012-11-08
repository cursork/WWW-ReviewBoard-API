use strict;
use warnings;

package WWW::ReviewBoard::API::User;
use Moose;

has api => (
	is => 'ro'
);

has url => (
	is => 'rw'
);

has email => (
	is  => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		return $self->raw->{email};
	}
);

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		die 'No API or URL, can\'t auto-populate self' unless $self->api && $self->url;

		return $self->api->get($self->url)->{user};
	}
);

1
