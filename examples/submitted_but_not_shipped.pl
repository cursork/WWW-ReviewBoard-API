use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

use WWW::ReviewBoard::API;

my %opts;
GetOptions(
        'url=s'  => \($opts{'url'}),
        'user=s' => \($opts{'username'}),
        'pass=s' => \($opts{'password'}),
);

my $rb = WWW::ReviewBoard::API->new(%opts);

my @subbed_not_shipped = $rb->review_requests(
        'ship-it' => 0,
        'status'  => 'submitted'
);

print "\n\n";
foreach my $req (@subbed_not_shipped) {
        print '>>>>> Review #', $req->id, ': ', $req->summary, "\n";
        print 'Submitter:     ', $req->submitter->fullname, "\n";
        print 'Target People: ',
              join(', ', map { $_->fullname } @{$req->target_people}), "\n\n";
}
