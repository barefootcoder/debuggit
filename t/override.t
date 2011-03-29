#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

sub DEBUG () { return "test"; }
use Debuggit;


is(DEBUG, "test", "override is okay");
