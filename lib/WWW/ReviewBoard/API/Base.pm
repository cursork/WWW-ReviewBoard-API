use strict;
use warnings;

package WWW::ReviewBoard::API::Base;
use Moose;

# Everything uses api, id, url and raw

has api => (
	is => 'ro'
);

has id => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		shift->raw->{id};
	}
);

has url => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		if ($self->{raw}) {
			# We were instantiated with raw data
			return $self->raw->{links}->{self}->{href};
		} elsif ($self->{id}) {
			# Instantiated with ID
			return $self->api->make_url($self->path, $self->id);
		} else {
			die 'Not instantiated with \'id\' or \'raw\' data. Can\'t construct URL.';
		}
	}
);

has raw => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		die 'Missing API or URL, can\'t auto-populate self' unless $self->api && $self->url;

		my $raw = $self->api->get($self->url)->{$self->raw_key};
		return $raw;
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
