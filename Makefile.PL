use inc::Module::Install;

# Define metadata
name            'Debuggit';
all_from        'lib/Debuggit.pm';

# Specific dependencies
test_requires   'B::Deparse'            => '0.89';
test_requires   'IPC::System::Simple'   => '0.89';
test_requires   'Test::More'            => '0.88';
test_requires   'Test::Warn'            => '0.23';
test_requires   'Test::Output'          => '0.16';
test_requires   'Test::Exception'       => '0.31';

configure_requires 'YAML::Tiny'         => 0;

githubmeta;
jsonmeta;

WriteAll;
