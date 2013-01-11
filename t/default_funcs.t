use strict;
use warnings;

use IPC::System::Simple     qw<capturex>            ;

use Test::More      0.88                            ;
use Test::Output    0.16    qw<:tests :functions>   ;
use Test::Exception 0.31                            ;

use Debuggit(DEBUG => 2);


open(IN, "t/data/hash_for_dumping") or die("# cannot read test data");
my $struct = eval do { local $/; <IN> };
close(IN);

my $cmd = <<'END';
    use strict;
    use warnings;
    use Data::Dumper;

    open(IN, "t/data/hash_for_dumping") or die("# cannot read test data");
    my $struct = eval do { local $/; <IN> };
    close(IN);

    print Dumper($struct);
END

# get Dumper output without actually loading Data::Dumper
my $dump = capturex($^X, '-e', $cmd);
# make sure we actually _got_ some output
isnt $dump, '', "test dump returned some output";
# and make sure we didn't actually load Data::Dumper
throws_ok { print Data::Dumper::Dumper() } qr/^Undefined subroutine &Data::Dumper::Dumper called/,
        'Data::Dumper not loaded';

my $output = 'test is';
stderr_is { debuggit(2 => $output, DUMP => $struct); } "$output $dump\n", "got DUMP output";

ok Debuggit::remove_func('DUMP'), "remove func successful";
stderr_is { debuggit(2 => $output, DUMP => $struct); } "$output DUMP $struct\n", "removed default func";


done_testing;
