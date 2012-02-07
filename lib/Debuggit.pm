package Debuggit;

use strict;
use warnings;

our $VERSION = '2.01_04';


#################### main pod documentation begin ###################
####
###
##
#

=head1 NAME

Debuggit - A fairly simplistic debug statement handler

=head1 SYNOPSIS

  use Debuggit(DEBUG => 1);

  # say you have a global hashref for your site configuration
  # (not to imply that global vars are good)
  our $Config = get_global_config();

  # now we can set some config things based on whether we're in debug mode or not
  $Config->{'DB'} = DEBUG ? 'dev' : 'prod';

  # maybe we need to pull our local Perl modules from our VC working copy
  push @INC, $Config->{'vcdir/lib'} if DEBUG;

  # basic debugging output
  debuggit("only print this if debugging is on");
  debuggit(3 => "only print this if debugging is level 3 or higher");

  # show off our formatting
  my $var1 = 6;
  my $var2;
  my $var3 = " leading and trailing spaces   ";
  # assuming debugging is enabled ...
  debuggit("var1 is", $var1);   # var1 is 6
  debuggit("var2 is", $var2);   # var2 is <<undef>>
  debuggit("var3 is", $var3);   # var3 is << leading and trailing spaces   >>
  # note that spaces between args, as well as final newlines, are provided automatically

  # use "functions" in the debugging args list
  my $var4 = { complex => 'hash', with => 'lots', of => 'stuff' };
  # this will call Data::Dumper::Dumper() for you
  # (even if you've never loaded Data::Dumper)
  debuggit("var4 is", DUMP => $var4);

  # make your own function
  Debuggit::add_func(CONFIG => 1, sub { my ($self, $var) = $_; return "$self var $var is $Config->{$var}" });
  # and use it like so
  debuggit(CONFIG => 'DB');     # CONFIG var DB is dev


=head1 DESCRIPTION

You want debugging?  No, you want sophisticated, full-featured, on-demand debugging, and you don't
want to take it out when you release the code because you might need it again later, but you also
don't want it to take up any space or cause any slowdown of your production application.  Sound
impossible?  Nah.  Just use Debuggit.


=head2 Quick Start

To start:

    use strict;
    use warnings;

    use Debuggit;


    my $var = 6;
    debuggit(2 => "var is", $var);      # this does not print
    debuggit(4 => "var is", $var);      # neither does this

Later ...

    use strict;
    use warnings;

    use Debuggit(DEBUG => 2);


    my $var = 6;
    debuggit(2 => "var is", $var);      # now this prints
    debuggit(4 => "var is", $var);      # but this still doesn't

That's it.  Really.  Everything else is just gravy.


=head2 Documentation

This POD explains just the basics of using C<Debuggit>.  For full details, see L<Debuggit::Manual>.

=cut

#
##
###
####
#################### main pod documentation end ###################

my ($debuggit, $add_func);


#####################################################################
##
#

=head1 EXPORTS

=head2 DEBUG

DEBUG is a constant integer set to whatever value you choose:

    use Debuggit DEBUG => 2;

or to 0 if you don't choose:

    use Debuggit;

Actually, failure to specify a value only defaults to 0 the first time in a program this is seen.
Subsequent times (e.g. in modules included by the main script), DEBUG will be set to the first value
passed in.  In this way, you can set DEBUG in the main script and have it "fall through" to all
included modules.  See L<Debuggit::Manual/"The DEBUG Constant"> for full details.

=head2 Functions exported

Only L</debuggit> is exported.

=cut

#
##
#####################################################################


sub import
{
    my ($pkg, %opts) = @_;
    my $caller_package = $opts{PolicyModule} ? caller(1) : caller;

    my $master_debug = eval "Debuggit::DEBUG();";
    my $debug_value = defined $opts{DEBUG} ? $opts{DEBUG} : defined $master_debug ? $master_debug : 0;
    *Debuggit::DEBUG = sub () { $debug_value } unless defined $master_debug;

    no strict 'refs';
    no warnings 'redefine';

    my $caller_value = eval "${caller_package}::DEBUG();";
    if (defined $caller_value)
    {
        warn("Cannot redefine DEBUG; original value of $caller_value is used") if $debug_value ne $caller_value;
    }
    else
    {
        # Thanx to tye from perlmonks for this line of code, which solves the Pod::Coverage issue
        # (see t/pod_coverage.t).               http://www.perlmonks.org/?node_id=951831
        *{ join('::', $caller_package, 'DEBUG') } = sub () { $debug_value };
    }

    if ($debug_value)
    {
        _setup_funcs();
        *{ join('::', $caller_package, 'debuggit') } = \&debuggit;
    }
    else
    {
        *{ join('::', $caller_package, 'debuggit') } = sub {};
        *Debuggit::add_func = sub {} unless Debuggit->can('add_func');
    }
}


sub _setup_funcs
{
    my ($debug_value) = @_;

    eval $debuggit unless Debuggit->can('debuggit');

    eval $add_func unless Debuggit->can('add_func');

    # create default function
    add_func(DUMP => 1, sub
    {
        require Data::Dumper;
        shift;
        return Data::Dumper::Dumper(shift);
    });
}


#####################################################################
##
#

=head1 FUNCTIONS

=cut

#####################################################################
##
#

=head2 debuggit

Use this function to conditionally print debugging output.  If the first argument is a positive
integer, the output is printed only if DEBUG is set to that number or higher.  The remaining
arguments are concatenated with spaces, a newline is appended, and the results are printed to
STDERR.  Some minor formatting is done to help distinguish C<undef> values and values with leading
or trailing spaces.  To get further details, or to learn how to override any of those things, see
L<Debuggit::Manual/"The debuggit function">.

=head2 default_formatter

This is what C<debuggit> is set to initially.  You can call it directly if you want to "wrap"
C<debuggit>.  For examples of this, see L<Debuggit::Cookbook/"Adding to the debugging output">.

=cut

#
##
#####################################################################

BEGIN
{
    $debuggit = q{
        sub debuggit
        {
            no strict 'refs';
            my $debug = join('::', scalar(caller), 'DEBUG');
            return unless @_ > 0 && ($_[0] =~ /^\d+$/ ? shift : 1) <= $debug->();
            $Debuggit::output->($Debuggit::formatter->(Debuggit::_process_funcs(@_)));
        }
    };
}


sub default_formatter
{
    return join(' ', map { !defined $_ ? '<<undef>>' : /^ +/ || / +$/ ? "<<$_>>" : $_ } @_) . "\n";
}

our $formatter = \&default_formatter;

our $output = sub { print STDERR @_ };


#####################################################################
###
##
#

=head2 add_func

=head2 remove_func

Add or remove debugging functions.  Please see L<Debuggit::Manual/"Debugging Functions">.

=cut

#
##
###
#####################################################################


my %PROCS;

BEGIN
{
    $add_func = q{
        sub Debuggit::add_func
        {
            my ($name, $argc, $code) = @_;

            $Debuggit::PROCS{$name} = { argc => $argc, code => $code };

            return 1;
        }
    };
}


sub remove_func
{
    delete $Debuggit::PROCS{shift()};
    return 1;
}



#####################################################################
# PRIVATE FUNCTIONS
#####################################################################


sub _process_funcs
{
    my @parts;

    while (@_)
    {
        local $_ = shift;

        if ($_ and exists $Debuggit::PROCS{$_})
        {
            my @args = ($_);
            push @args, shift foreach 1..$Debuggit::PROCS{$_}->{argc};
            push @parts, $Debuggit::PROCS{$_}->{code}->(@args);
        }
        else
        {
            push @parts, $_;
        }
    }

    return @parts;
}


#################### remainder of pod begin ###################
####
###
##
#

=head1 DIAGNOSTICS

=over 4

=item * Cannot redefine DEBUG; original value of %s is used

It means you did something like this:

    use Debuggit DEBUG => 2;
    use Debuggit DEBUG => 3;

only probably not nearly so obvious.  Debuggit tries to be very tolerant of multiple imports into
the same package, but the C<DEBUG> symbol is a constant function and can't be redefined without
engendering severe wonkiness, so Debuggit won't do it.  As long as you pass the same value for
C<DEBUG>, that's okay.  But if the second (or more) value is different from the first, then you will
get the original value regardless.  At least this way you'll be forewarned.

=back



=head1 PERFORMANCE

Debuggit is designed to be left in your code, even when running in productionn environments.
Because of this, it needs to disappear entirely when debugging is turned off.  It can achieve this
unlikely goal because of the use of a compile-time constant.  Please see
L<Debuggit::Manual/"Performance Considerations"> for full details.



=head1 BUGS

Once you set C<DEBUG>, you can't change it.  Even if you try, you get the original value.  See
L</DIAGNOSTICS>.

That's all I know of.  However, lacking omniscience, I welcome bug reports.



=head1 SUPPORT

Debuggit is on GitHub at barefootcoder/debuggit.  Feel free to fork and submit patches.  Please note
that I develop via TDD (Test-Driven Development), so a patch that includes a failing test is much
more likely to get accepted (or least likely to get accepted more quickly).

If you just want to report a problem or suggest a feature, that's okay too.  You can create an issue
on GitHub, or a bug in CPAN's RT (at http://rt.cpan.org).  Or just send an email to
bug-Debuggit@rt.cpan.org.



=head1 AUTHOR

    Buddy Burden
    CPAN ID: BAREFOOT
    Barefoot Software
    barefootcoder@gmail.com

=head1 COPYRIGHT

This program is free software licensed under

    The Artistic License

The full text of the license can be found in the LICENSE file included with this module.


This module is copyright (c) 2008-2012, Barefoot Software.  It has many venerable ancestors (some
more direct than others), including but not limited to:

=over

=item *

C<Barefoot::debug>, (c) 2000-2006 Barefoot Software, 2004-2006 ThinkGeek

=item *

C<Barefoot::base>, (c) 2001-2006 Barefoot Software

=item *

C<Geek::Dev::Debug>, (c) 2004 ThinkGeek

=item *

C<VCtools::Base>, (c) 2004-2008 Barefoot Software, 2004 ThinkGeek

=item *

C<Barefoot>, (c) 2006-2009 Barefoot Software

=item *

C<Company::Debug>, (c) 2008 Rent.com

=back


=head1 SEE ALSO

L<Log::Log4perl>, L<debug>, L<Debug>, L<Debug::Message>, L<Debug::EchoMessage>.

Comparison with most of these (and others) can be found in L<Debuggit::Manual/"Comparison Matrix">.

=cut

#
##
###
####
#################### remainder of pod end ###################


# Return a true value
1;
