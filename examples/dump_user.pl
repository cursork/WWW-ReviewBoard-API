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

my $rb = WWW::ReviewBoard::API->new(
	url      => $url,
	username => $user,
	password => $pass,
);

my $u = WWW::ReviewBoard::API::User->new(
	api => $rb,
	url => '/users/' . $ARGV[0]
);

print Data::Dumper->Dump([$u->raw]);
