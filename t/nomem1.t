use strict;
use warnings;

use Test::More      0.88                            ;


eval "use GTop ()";
if ($@)
{
    plan skip_all => "GTop required for testing memory usage";
}


TODO : { local $TODO = "GTop not agreeing with Memory::Usage for some reason";
# GTop doesn't interact with Test::More quite as badly as Memory::Usage (see t/nomem2.t), but it
# still freaks out every once in a while.  Now running this one in a separate perl instance as well.

my $proglet = <<'END';

    use GTop;

    my $gtop = GTop->new;
    my $before = $gtop->proc_mem($$)->size;

    eval
    {
        require Debuggit;
        Debuggit->import();
    };
    my $err = $@;
    my $after = $gtop->proc_mem($$)->size;

    print "USAGE: ", $after - $before, "\n";

END

my $out = `$^X -e '$proglet'`;
my ($type, $data) = $out =~ /^(\w+): (.*?)\n/;

if (is $type, 'USAGE', "successfully imported module for memory test")
{
    is $data, '0', "loading module adds zero memory overhead" or diag $out;
}
else
{
    diag("error was: $data");
}


}
done_testing;
