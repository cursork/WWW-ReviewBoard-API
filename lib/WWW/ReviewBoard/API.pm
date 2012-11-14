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

my @resources = qw/ User ReviewRequest /;
foreach my $res (@resources) {
	no strict 'refs';
	my $module = "WWW::ReviewBoard::API::$res";
	eval "use $module";
	die $@ if $@;

	*{$module->raw_key} = sub {
		my ($self, $id_or_url) = @_;

		my %opts = ( url => $id_or_url );
		if ($id_or_url =~ /^\d+$/) {
			%opts = ( id => $id_or_url );
		} elsif (!defined $id_or_url) {
			%opts = ();
		}

		return $module->new(api => $self, %opts);
	};

	*{$module->raw_key_plural} = sub {
		my ($self, %opts) = @_;

		my $items = $self->get($module->path, %opts)->{$module->raw_key_plural};
		return map {
			$module->new(api => $self, raw => $_)
		} @$items;
	};
}

sub get {
	my ($self, $path, %opts) = @_;

	my $query_string = '';
	if (%opts) {
		$query_string = '?' . CGI->new(\%opts)->query_string;
	}

	my $response = $self->ua->get($self->make_url($path) . $query_string);
	if (!$response->is_success) {
		die 'Failed to fetch resource: ' . $response->content;
	}

	return JSON::decode_json($response->content);
}

sub post {
	my ($self, $path, $opts) = @_;

	my $response = $self->ua->post($self->make_url($path), $opts);
	if (!$response->is_success) {
		die 'Failed to create resource: ' . $response->content;
	}

	return JSON::decode_json($response->content);
}

sub make_url {
	my ($self, $path, @parts) = @_;

	if (@parts) {
		$path .= '/' . join('/', @parts);
	}

	my $url = $self->url;
	if ($path =~ /^http:/) {
		# It's already fully qualified
		return $path;
	}

	# Hackish!
	$url .= '/' . $path;
	$url =~ s{//+}{/}g;
	$url =~ s{http:/}{http://}g;
	return $url;
}

1
__END__
=head1 NAME

WWW::ReviewBoard::API

=head1 SYNOPSIS

    my $rb = WWW::ReviewBoard::API->new(
        url      => 'http://reviews.mydomain.com/api',
        username => 'admin',
        password => 'myp4ss'
    );
    my $review = $rb->review_request(45);
    say $review->summary;

=head1 DESCRIPTION

Object-oriented interface to Review Board's API (v2).

=head1 A NOTE ON EXCEPTIONS

All resources are fetched lazily where possible. As a result, if a resource is
not available, you will not know until you attempt to access an attribute.

For example:

    my $review = $rb->review_request(40); # Stub review request
    say $rb->summary;                     # Forces fetch of resource
    my $users = $review->target_people;   # Stubs the list of users
    say $_->fullname for @$users;         # Fetches user resources one at a time

In the above script, if the review request does not exist, it will die at line
#2. Similarly, if a user does not exist, it will die at line #4.

=head1 SUBROUTINES/METHODS

=head1 DEPENDENCIES

Moose!

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

No deduplication of objects in memory is done. i.e. if you call...

    my $review = $rb->review_requests(1);
    my $user   = $review->submitter;
    my @users_reviews;
    push @users_reviews, $_ foreach @{$user->review_requests};

... there will be two objects representing review request #1 in memory and
updates to one will not be reflected in the other.

This may change in a future version but currently it is expected that this
package will mostly be used for 'read' actions, and duplicating objects avoids
circular references.

