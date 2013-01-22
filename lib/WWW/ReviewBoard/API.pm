use strict;
use warnings;

use LWP::UserAgent;
use MIME::Base64;
use JSON;
use CGI;

use WWW::ReviewBoard::API::DummyLogger;

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

has log => (
	is      => 'rw',
	default => sub {
		return WWW::ReviewBoard::API::DummyLogger->new;
	}
);

my @resources = qw/ User ReviewRequest Repository /;
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

		return $module->new(%opts, api => $self, log => $self->log);
	};

	*{$module->raw_key_plural} = sub {
		my ($self, %opts) = @_;

		my $items = $self->get($module->url_path, %opts)->{$module->raw_key_plural};
		return map {
			$module->new(api => $self, raw => $_, log => $self->log)
		} @$items;
	};
}

sub get {
	my ($self, $path, %opts) = @_;

	my $query_string = '';
	if (%opts) {
		$query_string = '?' . CGI->new(\%opts)->query_string;
	}

	my $request = $self->make_url($path) . $query_string;
	$self->log->info("Sending HTTP request: $request");

	my $response = $self->ua->get($request);
	if (!$response->is_success) {
		die 'Failed to fetch resource: ' . $response->content;
	}

	$self->log->debug('Response status = '.$response->code.". Content: ".$response->content);

	return JSON::decode_json($response->content);
}

sub post {
	my ($self, $path, $opts) = @_;

	my $response = $self->ua->post($self->make_url($path), $opts);
	if (!$response->is_success) {
		die 'Failed to create resource: ' . $response->content;
	}

	$self->log->debug('Response status = '.$response->code.". Content: ".$response->content);

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

Many resources are fetched lazily when possible. As a result, if a resource is
not available, you will not know until you attempt to access an attribute.

For example:

    my $review = $rb->review_request(40); # Stub review request
    say $rb->summary;                     # Forces fetch of resource

In the above script, if the review request does not exist, it will die at line
#2.

=head1 SUBROUTINES/METHODS

=over

=item * new()

Constructor. Accepted arguments:

=over

=item * url (required)

Location of ReviewBoard API.

=item * username (required)

Username to act on behalf of.

=item * password (required)

Password of above user.

=item * log (optional)

If supplied, this must be an instantiated logger object. The object must
expose the following four methods: debug(), info(), warn() and error().
L<Log::Any>, L<Log::Dispatch> or L<Log::Log4perl> should all be fine.

By default, no logging happens at all.

=back

=back

=head1 DEPENDENCIES

=over

=item * JSON

=item * LWP::UserAgent

=item * Moose

=item * Test::Most

=item * Test::MockObject

=back

=head1 BUGS AND LIMITATIONS

No deduplication of objects in memory is done. i.e. if you call...

    my $review = $rb->review_requests(1);
    my $user   = $review->submitter;
    my @users_reviews;
    push @users_reviews, $_ foreach @{$user->review_requests};

... there will be two objects representing review request #1 in memory and
updates to one will B<not> be reflected in the other.

This may change in a future version but currently it is expected that this
package will mostly be used for 'read' actions, and duplicating objects avoids
circular references.

