use strict;
use warnings;

package WWW::ReviewBoard::API::DraftBase;
use Moose;

# Must be of type declared in draft_for
has parent => (
	is => 'ro'
);

sub draft_for {
	my ($class) = @_;
	die "draft_for() not defined in sub-class '$class'";
}

sub BUILD {
	my ($self) = @_;

	if (ref($self->parent) ne $self->draft_for) {
		die "Parent to this draft object not an instance of '" . $self->draft_for . "'. "
		    . "It was: '" . ref($self->parent) . "'";
	}

	# TODO... Probably should base on Base myself...
	# $self->refresh;
}

# Submit whatever changes we've made
sub commit {
	# TODO
	die 'TODO';
}

# Discard the draft completely (delete from RB)
sub discard {
	# TODO
	die 'TODO';
}

# Populate the draft with initial data
# TODO check behaviour of RB - I expect it to return a 100 does not exist
# pre-commit.
# N.B. expected to wipe out currently staged changes

sub refresh {
	# TODO
	die 'TODO';
}

1

__END__
=head1 NAME

	WWW::ReviewBoard::API::DraftBase

=head1 SYNOPSIS

	my $api    = WWW::ReviewBoard::API->new( ... );
	my $rr     = $api->review_request(42);
	my ($user) = $api->users(username => 'alice');

	my $draft = $rr->draft;

	$draft->target_people([$user]);
	$draft->commit;

=head1 DESCRIPTION

Base-class for 'draft' resources. As the Review Board API makes a clear
distinction between the current version of a resource, and the potential
future one we choose to do the same.

'Commit' is the terminology used within a *::Draft to indicate that the
provided fields should be sent via PUT to the server.

=head1 SUBROUTINES/METHODS

=over

=item commit()

Commit all changes. This will still commit when no changes have been made. The
effect in Review Board will be to create a new, empty draft record.

=back

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

