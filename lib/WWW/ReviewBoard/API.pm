use strict;
use warnings;

use LWP::UserAgent;
use MIME::Base64;
use JSON;
use CGI;

use WWW::ReviewBoard::API::ReviewRequest;

package WWW::ReviewBoard::API;
use Moose;

has url => (
	is       => 'ro',
	required => 1,
	trigger  => sub {
		my ($self) = @_;
		if ($self->url !~ m{/api/?$}) {
			die "URL supplied does not end with '/api'. URL was: " . $self->url;
		}
	}
);

has username => (
	is       => 'ro',
	required => 1
);

has password => (
	is       => 'ro',
	required => 1
);

has ua => (
	is      => 'ro',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		my $ua = LWP::UserAgent->new;
		$ua->default_header(
			'Authorization' => 'Basic ' . MIME::Base64::encode_base64(
				$self->username . ':' . $self->password));
		return $ua;
	}
);

sub review_requests {
	my ($self, $opts) = @_;
	$opts ||= {};

	my $requests = $self->get('/review-requests', $opts)->{review_requests};
	return [
		map {
			WWW::ReviewBoard::API::ReviewRequest->new(api => $self, raw => $_)
		} @$requests
	];
}

sub get {
	my ($self, $path, $opts) = @_;

	my $query_string = CGI->new($opts)->query_string;

	my $response = $self->ua->get($self->_make_url($path) . "?$query_string");
	if (!$response->is_success) {
		die 'Failed to fetch resource: ' . $response->content;
	}

	return JSON::decode_json($response->content);
}

sub post {
	my ($self, $path, $opts) = @_;

	my $response = $self->ua->post($self->_make_url($path), $opts);
	if (!$response->is_success) {
		die 'Failed to create resource: ' . $response->content;
	}

	return JSON::decode_json($response->content);
}

sub _make_url {
	my ($self, $path) = @_;

	my $url = $self->url;
	if ($path =~ /^\Q$url\E/) {
		# It's already fully qualified
		return $path;
	}

	return $url . $path;
}

1
