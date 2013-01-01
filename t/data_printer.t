use strict;
use warnings;

use Test::More      0.88                            ;
use Test::Output    0.16    qw<:tests :functions>   ;
use Test::Exception 0.31                            ;

BEGIN
{
    my $error = system("perl -MData::Printer -le 1 2>/dev/null");
    plan skip_all => "Data::Printer required for testing pretty dumping" if $error;
}

use Debuggit(DataPrinter => 1, DEBUG => 2);


open(IN, "t/data/hash_for_dumping") or die("# cannot read test data");
my $testhash = eval do { local $/; <IN> };
close(IN);

my $cmd = <<'END';
    use strict;
    use warnings;
    require Data::Printer;

    open(IN, "t/data/hash_for_dumping") or die("# cannot read test data");
    my $testhash = eval do { local $/; <IN> };
    close(IN);

    print Data::Printer::p($testhash, colored => 1, hash_separator => " => ", print_escapes => 1);
END

# get dumped output without actually loading Data::Printer
my $dump = `$^X -e '$cmd'`;
# make sure we actually _got_ some output
isnt $dump, '', "test dump returned some output";
# and make sure we didn't actually load Data::Printer
throws_ok { print Data::Printer::p() } qr/^Undefined subroutine &Data::Printer::p called/,
        'Data::Printer not loaded';

my $output = 'test is';
stderr_is { debuggit(2 => $output, DUMP => $testhash); } "$output $dump\n", "got DUMP output";


done_testing;
