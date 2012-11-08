use strict;
use warnings;

use Test::Most tests => 4;
use Test::MockObject;

use WWW::ReviewBoard::API::User;

my $mock_api = Test::MockObject->new;
$mock_api->mock('get', sub {{ user => { email => 'alice@alice.alice' } }});

my $user = WWW::ReviewBoard::API::User->new(
	api => $mock_api,
	url => 'http://nosuch/api/users/alice'
);

ok !$mock_api->called('get'),  'API get has not been called';
ok !$mock_api->called('post'), 'API post has not been called';

is $user->email, 'alice@alice.alice', 'Email matches';
ok $mock_api->called('get'), 'API get was called to retrieve email';
