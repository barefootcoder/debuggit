my $DESC = '';

## Without Alias
use Debuggit;

use strict;
use warnings;
use Test::More      0.88                            ;
use Test::Exception 0.31                            ;
sub TEST { $DESC = shift }  # Handy test function

TEST "The dbg() function does not exist natively"; {
    throws_ok { dbg("any message") } qr/Undefined subroutine/, $DESC;
}

## With an alias
package WithAlias;
use Debuggit DEBUG => 1, Alias => 'dbg';

use strict;
use warnings;
use Test::More      0.88                            ;
use Test::Exception 0.31                            ;
use Test::Output    0.16                            ;
sub TEST { $DESC = shift }  # Handy test function

TEST "The bad_name() function does not exist natively"; {
    throws_ok { bad_name("any message") } qr/Undefined subroutine/, $DESC;
}

TEST "The dbg() function exists, if it was created with the Alias argument"; {
    lives_ok { dbg("any message") } $DESC;
}

TEST "Display correct output with dbg() alias (simple use case)"; {
    my $message = 'expected output';
    stderr_is { debuggit($message); } "$message\n", $DESC;
}

done_testing;

