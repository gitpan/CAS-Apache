#!perl -T

use Test::More tests => 5;

BEGIN {
	use_ok( 'CAS::Apache' );
	use_ok( 'CAS::Apache::Auth' );
	use_ok( 'CAS::Apache::UserForms' );
	use_ok( 'CAS::Apache::PublicForms' );
	use_ok( 'CAS::Apache::AdminForms' );
}

diag( "Testing CAS::Apache $CAS::Apache::VERSION, Perl $], $^X" );
