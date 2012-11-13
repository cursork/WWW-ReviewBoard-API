use strict;
use warnings;

package WWW::ReviewBoard::API::Test;
use WWW::ReviewBoard::API;
use Test::Most;

sub import {
	my ($class, %opts) = @_;

	# Plan (or don't plan) number of tests depending on environment
	if (!$opts{tests}) {
		die 'Must specify a number of tests on import.';
	}

	rb_plan(%opts);

	# Install rb_api and Test::Most functions
	my $package = caller;
	{
		no strict 'refs';
		*{$package.'::rb_api'} = \&rb_api;

		eval "package $package; Test::Most->import();";
		die $@ if $@;
	}
}

sub rb_plan {
	my (%opts) = @_;

	plan($ENV{REVIEWBOARD_URL} && $ENV{REVIEWBOARD_USER} && $ENV{REVIEWBOARD_PASS}
	     ? %opts : (skip_all => 'No ReviewBoard instance'));
}

my $rb_api;
sub rb_api {
	$rb_api ||= WWW::ReviewBoard::API->new(
		url      => $ENV{REVIEWBOARD_URL},
		username => $ENV{REVIEWBOARD_USER},
		password => $ENV{REVIEWBOARD_PASS},
	);
	return $rb_api;
}

1
