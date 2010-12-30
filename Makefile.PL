use inc::Module::Install;
name 'SmartMT';
all_from 'lib/SmartMT.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
