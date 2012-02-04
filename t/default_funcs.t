use strict;
use warnings;

use Test::More      0.88                            ;
use Test::Output    0.16    qw<:tests :functions>   ;
use Test::Exception 0.31                            ;

use Debuggit(DEBUG => 2);


my $test =
{
    expected    =>  'output',
    subhash     =>  {
                        more    =>  'output',
                    },
};
# get Dumper output without actually loading Data::Dumper
my $dump = stdout_from { require Data::Dumper; print Data::Dumper::Dumper($test); };
# and make sure we didn't actually load Data::Dumper
throws_ok { print Dumper($test) } qr/^Undefined subroutine &main::Dumper called/, 'Data::Dumper not loaded';

my $output = 'test is';
stderr_is { debuggit(2 => $output, DUMP => $test); } "$output $dump\n", "got DUMP output";

ok Debuggit::remove_func('DUMP'), "remove func successful";
stderr_is { debuggit(2 => $output, DUMP => $test); } "$output DUMP $test\n", "removed default func";


done_testing;
