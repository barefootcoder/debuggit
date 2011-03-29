#! /usr/bin/perl

use strict;
use warnings;

use lib qw<lib>;

use Benchmark qw<cmpthese>;
use Debuggit;

sub without
{
    my $var = 3;
    $var *= 2 foreach 1..10;
}

sub with
{
    my $var = 3;
    $var *= 2 foreach 1..10;
    debuggit('this is a test');
}

sub explicit
{
    my $var = 3;
    $var *= 2 foreach 1..10;
    debuggit('this is a test') if DEBUG;
}


sub tester { 0 }
sub subst
{
    my $var = 3;
    $var *= 2 foreach 1..10;
    tester('this is a test');
}


cmpthese(1_000_000, {
    with    =>  \&with,
    without =>  \&without,
    explicit=>  \&explicit,
    subst   =>  \&subst,
});
