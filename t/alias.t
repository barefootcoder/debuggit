my $DESC = '';

package WithoutAlias;

use strict;
use warnings;
use Test::More      0.88                            ;
use Test::Exception 0.31                            ;

# Handy test function
sub TEST { $DESC = shift }

use Debuggit;
TEST "The dbg() function does not exist natively"; {
    throws_ok { dbg("any message") } qr/Undefined subroutine/, $DESC;
}

package WithAlias;

use strict;
use warnings;
use Test::More      0.88                            ;
use Test::Exception 0.31                            ;

# Handy test function
sub TEST { $DESC = shift }

use Debuggit Alias => 'dbg';
TEST "The dbg() function is defined, if created with the Alias argument"; {
    lives_ok { dbg("any message") } $DESC;
}

TEST "The bad_name() function does not exist natively"; {
    throws_ok { bad_name("any message") } qr/Undefined subroutine/, $DESC;
}

done_testing;

