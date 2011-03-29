#! /usr/bin/perl

use strict;
use warnings;

#BEGIN { warn("current package ", __PACKAGE__); }

use Test::Output;
use Test::More tests => 1;

use Debuggit(DEBUG => 2);


eval {
	package Fallthrough;

	use strict;
	use warnings;

	use Debuggit;

	sub test
	{
		debuggit(2 => $_[0]);
	}

	1;
};


my $output = 'expected output';
stderr_is { Fallthrough::test($output); } "$output\n", "got fallthrough output";
