use strict;
use warnings;

use WWW::ReviewBoard::API::Test tests => 2;

use_ok 'WWW::ReviewBoard::API::ReviewRequest';

my @reviews = rb_api->review_requests;
ok scalar @reviews, 'Got 1 or more review requests';
