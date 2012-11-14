use strict;
use warnings;

use Data::Dumper;
use WWW::ReviewBoard::API::Test tests => 11;

use_ok 'WWW::ReviewBoard::API::User';

my @reviews = rb_api->users;
ok scalar @reviews, 'Got 1 or more review requests';

# We know the user defined in the environment exists!
my $username = $ENV{REVIEWBOARD_USER};
my ($user) = rb_api->users(username => $username);
ok $user, 'Got user';
is $user->username, $username, "...with username '$username'";

ok defined $user->fullname, 'Got full name';
ok defined $user->email, 'Got email address';

my $id = $user->id;
like $id, qr/^\d+$/, 'Got numeric ID';

my $url = $user->url;
like $url, qr/^http/, 'Got URL-like URL';

my $by_id = rb_api->user($id);
is $by_id->id, $id, 'Got user back by ID';

my $by_url = rb_api->user($url);
is $by_url->url, $url, 'Got user back by URL';

my $by_partial = rb_api->user("/users/$username");
is $by_partial->username, $username, 'Got user by partial URL';
