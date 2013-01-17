use strict;
use warnings;

use Getopt::Long;
use Date::Manip::Date;
use WWW::ReviewBoard::API;

my %opts;
GetOptions(
	'url=s'  => \($opts{'url'}),
	'user=s' => \($opts{'username'}),
	'pass=s' => \($opts{'password'}),
);

my $rb = WWW::ReviewBoard::API->new(%opts);

my @submitted = $rb->review_requests(
	'status'      => 'submitted',
	'max-results' => 150
);

my %results;
foreach my $req (@submitted) {
	my ($from, $to) = (Date::Manip::Date->new, Date::Manip::Date->new);
	$from->parse($req->time_added);
	$to->parse($req->last_updated);

	my $delta = $from->calc($to, 0, 'business');
	my $hours_diff = $delta->printf('%hdm');

	my $r = $results{$req->submitter->fullname} ||= {
		total => 0,
		num   => 0,
		times => []
	};
	$r->{total} += $hours_diff;
	$r->{num}   += 1;
	$r->{avg}   =  $r->{total} / $r->{num};
	push @{$r->{times}}, $hours_diff;
}

my @users = sort { $results{$a}->{avg} <=> $results{$b}->{avg} } keys %results;

print "Full Name, Avg. Time, Num. Review Requests, Total Time\n";
foreach my $u (@users) {
	print join(',', map { '"' . $_ . '"' } ($u, $results{$u}->{avg}, $results{$u}->{num}, $results{$u}->{total}, @{$results{$u}->{times}})), "\n";
}
