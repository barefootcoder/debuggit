#! /usr/bin/perl

use strict;
use warnings;

use lib 't/lib';

use Test::Output;
use Test::Exception;
use Test::More tests => 3;

use MyDebuggit(DEBUG => 2);


lives_ok { debuggit(4) } "debuggit() exported";

my $output = 'expected output';
stderr_is { debuggit(2 => $output); } "XX: $output\n", "policy file carries DEBUG; sets debuggit()";


package foo;

use strict;
use warnings;

use Test::Output;

# don't have to specify DEBUG here because it will fallthrough from above
use MyDebuggit;


stderr_is { debuggit(2 => $output); } "XX: $output\n", "still right after second import";
