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
	chomp $pass;
}

my $rb = WWW::ReviewBoard::API->new(
	url      => $url,
	username => $user,
	password => $pass,
);

my $req = ($rb->review_requests)[0];
print $req->id, "\n";

print Data::Dumper->Dump([$req]);
