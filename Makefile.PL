use strict;
use warnings;
use ExtUtils::MakeMaker;

unless (-r 'CAS.yaml') {
	my $conf = '';
	while (<DATA>) {
		my @F = split(/\t/);
		if (@F == 2 && $F[0] =~ /(\S+):\s(.+)/) {
			chomp $F[1];
			print $F[1], " [$2]: ";
			my $val = <STDIN>;
			chomp $val;
			$val ||= $2;
#			print "$1 = $val\n";
			$conf .= "$1: $val\n";
		} # line should be key:value\tquestion
		
		else { $conf .= $_ }
	} # while reading conf from DATA section
	
	open(CONF,'> CAS.yaml') or die "Couldn't save conf file: $!";
	print CONF $conf;
	close CONF or warn "Problem closing CAS.yaml: $!";
	
	print <<NOTE;

The CAS configuration file has been written. You should review the
configuration file and make any edits needed to enable optional features.
The configuration information will be appended appended to /etc/CAS.yaml
during intall.

NOTE
} # unless the conf file already exists

else {
	warn "\n" . 'Using existing CAS configuration file '
		. "Delete CAS.yaml to regenerate.\n\n";
} # else notify user skipping generation


WriteMakefile(
    NAME                => 'CAS::Apache',
    AUTHOR              => 'Sean P. Quinlan <gilant@gmail.com>',
    VERSION_FROM        => 'lib/CAS/Apache.pm',
    ABSTRACT_FROM       => 'lib/CAS/Apache.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'CAS-Apache-*' },
);

exit;

##
## The data section will be read and the key:value lines will be
## be presented as a question if there is a question following the value
## seperated by tab.
##
__DATA__

# The name of the session token. This is used as the default cookie name for
# all logins on this server. Other clients, or multiple projects on this
# server, should specify their own name.
COOKIE_NAME: CAS	Name of the session token passed in the cookie

# The base URI for CAS server pages. For a simple test server, you could just
# set CAS_BASE_URI to /cgi-bin. If not using cgi-bin, then the Apache server
# will need to be configured to add this uri as an additional tree handled by
# mor_perl.
URI_BASE: '/CAS'	Base URL (server root relative) for CAS specific files

# Here are all the default names for CAS server pages. These are used for
# generating internal links and redirects. For these pages to be available the
# appropriate mod_perl handlers must be defined in Apache's configuration. See
# the README in the CAS::Apache directory for more information.
# CAS_BASE_URI will be prepended to all the URI's below EXCEPT those that
# end in .html, which will be server_root_ralative URI's (normally the local
# htdocs directory).
AUTHENTICATION_URI: '/public/authenticate'	
LOGIN_URI: '/public/login'
FORBIDDEN_URI: '/public/access_denied'
WELCOME_PAGE_URI: '/welcome'
ADMIN_EMAIL:	admin@example.com
