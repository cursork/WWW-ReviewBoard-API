use strict;
use warnings;

package WWW::ReviewBoard::API::User;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'user' }

__PACKAGE__->raw_fields(qw/ email /);

1
