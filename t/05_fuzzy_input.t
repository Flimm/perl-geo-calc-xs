use strict;
use warnings FATAL => 'all';
use utf8;

use Test::More;
use Test::Exception;
use Data::Dumper;

use Geo::Calc::XS;

my $gc = Geo::Calc::XS->new(lat => 3.2, lon => 54);

# Note that warnings are turned into exceptions

my %methods = (
    bearing_to => "dies",
    boundry_box => "dies",
    destination_point => "dies",
    distance_at => "dies",
    distance_to => "dies",
    final_bearing_to => "dies",
    get_lat => 0,
    get_lon => 0,
    get_radius => 0,
    get_units => 0,
    intersection => "dies",
    midpoint_to => "dies",
    rhumb_bearing_to => "dies",
    rhumb_destination_point => "dies",
    rhumb_distance_to => "dies",
);

for my $method (sort keys %methods) {
    my @random_args;
    for my $i (0 .. (rand(10) + 1)) {
        push @random_args, "zzz" . random_string();
    }

    if ($methods{$method} eq "dies") {
        dies_ok { $gc->$method(@random_args) } "$method(\@random_args) died but did not segfault"
            or diag(Dumper(\@random_args));
    }
    else {
        lives_ok { $gc->$method(@random_args) } "$method(\@random_args) did not segfault";
    }
}

for my $method (sort keys %methods) {
    my $rh_random_arg = {};
    for my $i (0 .. (rand(5) * 2 + 1)) {
        $rh_random_arg->{"zzz" . random_string()} = "zzz" . random_string();
    }

    if ($methods{$method} eq "dies") {
        dies_ok { $gc->$method($rh_random_arg) } "$method(\$rh_random_arg) died but did not segfault";
    }
    else {
        lives_ok { $gc->$method($rh_random_arg) } "$method(\$rh_random_arg) did not segfault";
    }
}


for my $ra_new_args ([], [lon => 2.3], [lat => 4, lon => 24, 'uneven']) {
    local $Data::Dumper::Terse = 1;
    my $dumped = join(", ", map { Dumper($_) =~ s/\n\z//r } @$ra_new_args);
    dies_ok { Geo::Calc::XS->new(@$ra_new_args) } "Geo::Calc::XS->new($dumped) died but did not segfault";
}

done_testing();

sub random_string {
    my $length = rand(10);
    my $str = "";
    for my $i (1..$length) {
        $str .= chr(ord('a') + rand(26));
    }
    return $str;
}
