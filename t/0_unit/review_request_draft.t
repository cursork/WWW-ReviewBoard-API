use strict;
use warnings;

use Test::Most tests => 7;
use Test::MockObject;

use WWW::ReviewBoard::API::ReviewRequest;

use_ok 'WWW::ReviewBoard::API::ReviewRequest::Draft';

my $mock_api = Test::MockObject->new;

my $rr = WWW::ReviewBoard::API::ReviewRequest->new(
	id  => 123,
	api => $mock_api
);

my $draft;
lives_ok sub { $draft = $rr->draft }, 'Getting draft lives';

isa_ok $draft, 'WWW::ReviewBoard::API::ReviewRequest::Draft',
	'Is a ...ReviewRequest::Draft object';

ok !$mock_api->called('put'), 'API put NOT called before commit';
$draft->commit;
ok $mock_api->called('put'), 'API put called on commit';

ok !$mock_api->called('delete'), 'API delete NOT called before discard';
$draft->discard;
ok $mock_api->called('delete'), 'API delete called on discard';
