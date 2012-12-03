use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Term::Prompt;
use WWW::ReviewBoard::API;

GetOptions(
	'url=s'  => \(my $url),
	'user=s' => \(my $user),
	'pass=s' => \(my $pass),
);

if ($url !~ m{api/?$}) {
	$url .= '/api/';
}

if (!$pass) {
	$pass = prompt('x', 'Password?', '', '');
}

my $review_id = $ARGV[0];
if (!$review_id) {
	$review_id = prompt('x', 'Review Request ID?', '', '');
}

package PrintLogger;
# Print everything but debug

sub new { return bless({}, shift) }
sub error { print $_[1], "\n" }
{
	no strict 'refs';
	*{"PrintLogger::$_"} = \&error for (qw/ info warn /);
}
sub debug { }

package main;

my $rb = WWW::ReviewBoard::API->new(
	url      => $url,
	username => $user,
	password => $pass,
	log => PrintLogger->new
);

my $rr = $rb->review_request($review_id);
print Data::Dumper->Dump([map { $_->fields_changed } @{ $rr->changes }]);
