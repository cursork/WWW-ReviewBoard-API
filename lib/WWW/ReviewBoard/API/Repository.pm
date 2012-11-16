use strict;
use warnings;

package WWW::ReviewBoard::API::Repository;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key        { 'repository' }
sub raw_key_plural { 'repositories' }

sub url_path { 'repositories' }

__PACKAGE__->raw_fields(qw/
		name
		path
		tool
	/);

1
