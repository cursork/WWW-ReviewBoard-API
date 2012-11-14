use strict;
use warnings;

package WWW::ReviewBoard::API::ReviewRequest::Review;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'review' }

sub path { 'reviews' }

__PACKAGE__->raw_fields(qw/
		body_bottom
		body_top
		public
		ship_it
		timestamp
	/);

1
