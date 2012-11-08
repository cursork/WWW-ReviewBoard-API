use strict;
use warnings;

package WWW::ReviewBoard::API::Base;
use Moose;

# Everything can use api and url

has api => (
	is => 'ro'
);

has url => (
	is      => 'rw',
	lazy    => 1,
	default => sub { shift->raw->{links}->{self}->{href} }
);

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		die 'No API or URL, can\'t auto-populate self' unless $self->api && $self->url;

		return $self->api->get($self->url)->{$self->raw_key};
	}
);

sub raw_key {
	die 'raw_key not implemented for class ' . ref(shift);
}

1
