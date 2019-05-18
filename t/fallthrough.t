use strict;
use warnings;

use Test::More      0.88                            ;
use Test::Output    0.16                            ;

use Debuggit(DEBUG => 2);


eval {
    package Fallthrough;

    use strict;
    use warnings;

    use Debuggit(Alias => 'dbg');

    sub test
    {
        debuggit(2 => $_[0]);
    }

    sub test_with_alias
    {
        dbg(2 => $_[0]);
    }

    1;
};


my $output = 'expected output';
stderr_is { Fallthrough::test($output); } "$output\n", 
    "got fallthrough output";
stderr_is { Fallthrough::test_with_alias($output); } "$output\n", 
    "got fallthrough output with_alias";


done_testing;
