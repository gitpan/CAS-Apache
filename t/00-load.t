#!perl -T

use Test::More tests => 3;

BEGIN {
	use_ok( 'CAS::Apache' );
	use_ok( 'CAS::Apache::Auth' );
	use_ok( 'CAS::Apache::UserForms' );
}

diag( "Testing CAS::Apache $CAS::Apache::VERSION, Perl $], $^X" );
