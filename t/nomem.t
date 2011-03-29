# -*- perl -*-

# t/00.load.t - check module loading and create testing directory

use Test::More;


eval "use GTop ()";
if ($@)
{
	plan skip_all => "GTop required for testing memory usage";
}
else
{
	plan tests => 2;
}

my $gtop = GTop->new;
my $before = $gtop->proc_mem($$)->size;

eval
{
	require Debuggit;
	Debuggit->import();
};
my $err = $@;
my $after = $gtop->proc_mem($$)->size;

ok(!$err, "successfully imported module for memory test");
is($after - $before, 0, "loading module adds zero memory overhead");
