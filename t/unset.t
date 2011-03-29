#! /usr/bin/perl

use strict;
use warnings;

use Test::Output;
use Test::More tests => 2;

use Debuggit;


ok(DEBUG == 0, "const set okay");
stderr_is { debuggit(1 => "IF YOU SEE THIS, SOMETHING IS VERY WRONG"); } '', "no output with DEBUG 0";

Debuggit::add_func(TEST => 1, sub {});
