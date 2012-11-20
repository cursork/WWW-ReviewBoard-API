use strict;
use warnings;

use WWW::ReviewBoard::API::ReviewRequest::Change::Field;

package WWW::ReviewBoard::API::ReviewRequest::Change;
use Moose;
extends 'WWW::ReviewBoard::API::Base';

sub raw_key { 'change' }

sub url_path { 'changes' }

# TODO fields_changed is just the raw returned structure as it stands.
# Is it possible to make it better?

__PACKAGE__->raw_fields(qw/
		text
		timestamp
	/);

has fields_changed => (
	is      => 'rw',
	lazy    => 1,
	default => sub {
		my ($self) = @_;
		my %api;
		$api{api} = $self->api if $self->api;

		my @fields;
		my %changed = %{ $self->raw->{fields_changed} };
		foreach my $name (keys %changed) {
			my %changed_details;
			$changed_details{new_items}  = $changed{$name}->{new};
			$changed_details{old_items}  = $changed{$name}->{old};
			$changed_details{removed}    = $changed{$name}->{removed};
			$changed_details{added}      = $changed{$name}->{added};
			$changed_details{screenshot} = $changed{$name}->{screenshot};

			push @fields, WWW::ReviewBoard::API::ReviewRequest::Change::Field->new({
					name => $name,
					%changed_details,
					%api
				})
		}

		return \@fields;
	}
);
1
