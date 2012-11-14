use strict;
use warnings;

package WWW::ReviewBoard::API::User;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'user' }

sub path { 'users' }

__PACKAGE__->raw_fields(qw/
		avatar_url
		email
		first_name
		fullname
		last_name
		username
	/);

1
