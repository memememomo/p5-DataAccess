use inc::Module::Install;
name 'DataAccess';
all_from 'lib/DataAccess.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
