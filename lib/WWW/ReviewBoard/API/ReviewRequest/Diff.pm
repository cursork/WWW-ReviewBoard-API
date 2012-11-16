use strict;
use warnings;

package WWW::ReviewBoard::API::ReviewRequest::Diff;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'diff' }

sub url_path { 'diffs' }

__PACKAGE__->raw_fields(qw/
		name
		revision
		timestamp
	/);

1
