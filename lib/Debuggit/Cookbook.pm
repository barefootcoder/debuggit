package Debuggit::Cookbook;

# ABSTRACT: Debuggit example recipes



=pod



=head1 NAME

Debuggit::Cookbook - Debuggit example recipes



=head1 DESCRIPTION

Herein are provided a number of short examples on how to use Debuggit to do clever things.  More
examples from users are welcomed.



=head1 Adding to the debugging output

You can take advantage of the fact that the default formatter is stored as
C<Debuggit::default_formatter> to do some clever things.


=head2 Show timestamp

For instance, it's pretty trivial to add a timestamp to debugging output:

    # add timestamp to debugging (at least for this function/module/whatever)
    local $Debuggit::formatter = sub
    {
        return scalar(localtime) . ': ' . Debuggit::default_formatter(@_);
    };

Note how the C<local> restricts the change in C<debuggit>'s behavior to the current scope.


=head2 Show caller info

Similar to the last recipe.  This is only trickier because you have to figure out the right argument
to C<caller>.

    # all debugging statements in the current scope will show function name
    local $Debuggit::formatter = sub
    {
        # note that caller(0) would be this formatter sub, and
        # caller(1) would be debuggit(), so caller(2) is what we want
        # element 3 is the subroutine name (which includes the package name)
        return (caller(2))[3] . ': ' . Debuggit::default_formatter(@_);
    };

Note that this example only handles the simple cases--if your debuggit() calls get stuck inside
eval's or coderef's or anything like that, this breaks down.  But often the simple case is close
enough.


=head1 Controlling where debugging goes


=head2 Output to a log file

Perhaps you want a log file:

    my $log = '/tmp/debug.log';
    $Debuggit::output = sub
    {
        open(LOG, ">>$log") or return;
        print LOG @_;
        close(LOG);
    };

Notice how you have to append to the file, else multiple C<debuggit> calls will just overwrite each
other.


=head2 Debug to a string

Instead of printing debugging immediately, perhaps you want to save them up and print them out at
the end.  This could be useful e.g. when debugging web pages.

    our $log_msg;
    local $Debuggit::output = sub { $log_msg .= join('', @_) };

Again, we're appending.  We join all the args together (although most formatters will return only
one value, probably best not to assume), but use no separator.  This example uses C<our> instead of
C<my> for the string; this way, the variable is accessible from outside the current scope, which
might be necessary for later printing (depending on where the current scope is).



=head1 Interesting debugging functions


=head2 A separator function

Remember that functions don't have to take any arguments, or return any.  For instance, you could
replace this:

    debuggit('=' x 40);
    debuggit("new code section starts here");

with this:

    debuggit(SEPARATOR => "new code section starts here");

by defining your function thus:

    Debuggit::add_func(SEPARATOR => 0, sub
    {
        $Debuggit::output->('=' x 40);
        return ();
    });

Since we're replacing two calls with one, we use a call to C<$Debuggit::output> to make sure that
the separator line goes where it should, even if someone wants to change where that is.  To make
sure we don't insert an C<undef> into the debugging output stream, we return an empty list.


=head1 Fun with policy modules


=head2 Test suite debugging

Although a policy module will typically pass a debug value through to L<Debuggit>, it doesn't have
to.  For instance, if you're writing a module for all your test scripts to include, you might wish
to force C<DEBUG> to 1.  That's easy:

    package MyTestDebuggit;

    use Debuggit ();
    use Test::More;

    $Debuggit::output = sub { diag @_ };        # nicer with Test::More et al

    sub import
    {
        Debuggit->import(PolicyModule => 1, DEBUG => 1);
    }


=cut
