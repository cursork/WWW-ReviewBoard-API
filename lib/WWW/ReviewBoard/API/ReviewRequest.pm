use strict;
use warnings;

use WWW::ReviewBoard::API::User;
use WWW::ReviewBoard::API::ReviewRequest::Diff;

package WWW::ReviewBoard::API::ReviewRequest;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'review_request' }

sub path { 'review-requests' }

__PACKAGE__->raw_fields(qw/
		branch
		bugs_closed
		changenum
		description
		last_updated
		public
		status
		summary
		testing_done
		time_added
	/);


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

sub diffs {
	my ($self, %opts) = @_;

	if (!$self->api) {
		die 'No API provided in instantiation. Can not fetch diffs';
	}

	return [
		map {
			WWW::ReviewBoard::API::ReviewRequest::Diff->new(raw => $_, api => $self->api)
		} @{ $self->api->get($self->url . '/diffs', %opts)->{'diffs'} }
	];
}

1
