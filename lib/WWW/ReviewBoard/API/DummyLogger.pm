use strict;
use warnings;

package WWW::ReviewBoard::API::DummyLogger;

sub new { bless(\(my $o = ''), shift) }

sub debug { }
sub info  { }
sub warn  { }
sub error { }

1
