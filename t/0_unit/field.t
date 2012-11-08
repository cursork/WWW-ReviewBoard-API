use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

package Raw;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		{
			foo => 'default foo',
			bar => 'default bar'
		}
	}
);

__PACKAGE__->raw_fields('foo', { baz => 'bar' });

package main;

my $raw = Raw->new;
is $raw->foo, 'default foo', 'Default foo found';

lives_ok { $raw->foo(27) } 'Can set foo to 27';

is $raw->foo, 27, 'Foo is read-write';

ok !$raw->can('bar'), 'Bar mutator has not been added';
ok $raw->can('baz'), 'Baz mutator exists';

is $raw->baz, 'default bar', 'Baz returns bar';


