use strict;
use warnings;

package WWW::ReviewBoard::API::Base;
use Moose;

# Everything uses api, url and raw

has api => (
	is => 'ro'
);

has url => (
	is      => 'rw',
	lazy    => 1,
	default => sub { shift->raw->{links}->{self}->{href} }
);

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		die 'No API or URL, can\'t auto-populate self' unless $self->api && $self->url;

		return $self->api->get($self->url)->{$self->raw_key};
	}
);

sub raw_key {
	die 'raw_key not implemented for class ' . ref(shift);
}

sub raw_fields {
	my ($class, @fields) = @_;

	my $sub = $class->can('has');

	if (!$sub) {
		die "Calling class '$class' doesn't implement 'has()'";
	}
	my $add_field = sub {
		my ($field, $mutator) = @_;
		$sub->($mutator,
			is      => 'rw',
			lazy    => 1,
			default => sub { shift->raw->{$field} });
	};

	foreach my $f (@fields) {
		if (ref($f) eq 'HASH') {
			foreach my $field (keys %$f) {
				$add_field->($f->{$field}, $field);
			}
		} else {
			$add_field->($f, $f);
		}
	}
}

1
