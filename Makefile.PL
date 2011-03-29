use inc::Module::Install;

# Define metadata
name            'Debuggit';
all_from        'lib/Debuggit.pm';

# Specific dependencies
test_requires   'B::Deparse'        => '0.89';
test_requires   'Test::More'        => '0.88';
test_requires   'Test::Warn'        => '0.21';
test_requires   'Test::Output'      => '0.16';
test_requires   'Test::Exception'   => '0.29';

WriteAll;
