use strict;
use warnings;

package WWW::ReviewBoard::API::ReviewRequest::Review::DiffComment;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'diff_comment' }

sub url_path { 'diff-comments' }

__PACKAGE__->raw_fields(qw/
		first_line
		issue_opened
		issue_status
		num_lines
		public
		text
		timestamp
	/);

1
