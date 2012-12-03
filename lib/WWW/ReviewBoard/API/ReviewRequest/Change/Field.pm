
use strict;
use warnings;

# Enough with the package names already!
package WWW::ReviewBoard::API::ReviewRequest::Change::Field;
use Moose;

# NOT a WWW::ReviewBoard::API::Base!!!

has name       => (is => 'ro');
# We obviously do not want a ->new accessor
has old_items  => (is => 'ro');
has new_items  => (is => 'ro');
has removed    => (is => 'ro');
has added      => (is => 'ro');
has screenshot => (is => 'ro');

1
