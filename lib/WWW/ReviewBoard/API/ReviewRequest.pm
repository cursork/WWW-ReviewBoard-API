use strict;
use warnings;

use WWW::ReviewBoard::API::User;

package WWW::ReviewBoard::API::ReviewRequest;
use Moose;

has api => (
	is => 'ro'
);

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		if (!$self->{api} || !$self->{url}) {
			die 'No API or URL, can\'t auto-populate review request';
		}

		my $raw = $self->api->get($self->url)->{review_request};
		return $raw;
	},
);

has url => (
	is      => 'rw',
	lazy    => 1,
	default => sub { shift->raw->{links}->{self}->{href} }
);

has submitter => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		my %api;
		$api{api} = $self->api if $self->api;
		WWW::ReviewBoard::API::User->new({
				url => $self->raw->{links}->{submitter}->{href},
				%api
			})
	}
);

has target_people => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		my %api;
		$api{api} = $self->api if $self->api;

		return [
			map {
				WWW::ReviewBoard::API::User->new({ url => $_->{href}, %api })
			} @{ $self->{raw}->{target_people} }
		];
	}
);

has summary => (
	is      => 'rw',
	lazy    => 1,
	default => sub { shift->raw->{summary} }
);

1
