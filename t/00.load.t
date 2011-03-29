# -*- perl -*-

# t/00.load.t - check module loading and create testing directory

use Test::Exception;
use Test::More tests => 2;


BEGIN { use_ok( 'Debuggit' ); }

lives_ok { debuggit("just testing") } "debuggit function is defined";
