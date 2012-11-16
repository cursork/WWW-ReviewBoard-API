use strict;
use warnings;

use WWW::ReviewBoard::API::DummyLogger;

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
			return $self->api->make_url($self->url_path, $self->id);
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

has log => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		return WWW::ReviewBoard::API::DummyLogger->new;
	}
);

sub raw_key {
	die 'raw_key not implemented for class ' . ref(shift);
}

# Default to just adding an 's'
sub raw_key_plural {
	shift->raw_key . 's';
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

sub children {
	my ($class, @children) = @_;

	foreach my $package (@children) {
		eval "use $package";
		die $@ if $@;

 		my $child_sub = sub {
			my ($self, %opts) = @_;

			if (!$self->api) {
				die "No API provided in instantiation. Can not fetch $package children of $class";
			}

			return [
				map {
					$package->new(raw => $_, api => $self->api)
				} @{ $self->api->get($self->url . '/' . $package->url_path, %opts)->{$package->raw_key_plural} }
			];
		};
		
		no strict 'refs';
		*{$class.'::'.$package->raw_key_plural} = $child_sub;
	}
}

1
