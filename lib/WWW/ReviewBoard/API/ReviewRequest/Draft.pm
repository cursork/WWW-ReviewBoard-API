use strict;
use warnings;

package WWW::ReviewBoard::API::ReviewRequest::Draft;
use Moose;
extends 'WWW::ReviewBoard::API::DraftBase';

sub draft_for { 'WWW::ReviewBoard::API::ReviewRequest' }

1
