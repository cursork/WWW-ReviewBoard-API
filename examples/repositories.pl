use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Term::Prompt;
use WWW::ReviewBoard::API;
use Carp::Always;

GetOptions(
	'url=s'  => \(my $url),
	'user=s' => \(my $user),
	'pass=s' => \(my $pass),
);

my ($id) = @ARGV;

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

my $repo;
if ($id) {
	# Grab the first one that comes to hand...
	$repo = $rb->repository($id);
} else {
	$repo = ($rb->repositories)[0];
}

foreach (qw/ id name path tool /) {
	print ucfirst($_), ': ', $repo->$_, "\n";
}

