package CAS::Apache::Auth;

use warnings FATAL => 'all', NONFATAL => 'redefine';
use strict;

=head1 NAME

CAS::Apache::Auth - The great new CAS::Apache::Auth!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
#use Apache2::RequestRec ();
#  use Apache2::RequestIO ();

# AUTH_REQUIRED DECLINED DONE FORBIDDEN NOT_FOUND OK REDIRECT SERVER_ERROR
use Apache2::Const qw(OK AUTH_REQUIRED FORBIDDEN HTTP_UNAUTHORIZED);

use Apache2::Access ();
use Apache2::RequestUtil ();
use base qw(CAS::Apache CAS);
use CGI ();
use Apache2::Response ();

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use CAS::Apache::Auth;

    my $foo = CAS::Apache::Auth->new();
    ...

=head1 METHODS

=head2 function1

=cut

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self  = $class->SUPER::new(@_);
	
	# now, db caching doesn't work well in mod_perl as is - generates a lot
	# of 'Commands out of sync' errors
	$self->{dbh} = undef;
	
	return $self;
} # new


# because this package doesn't cache the db connection itself, depending on
# ApACHE::DBI to do it, we need to have a local version of the dbh method to
# reconnect
sub dbh {
	my $self = shift;
	return &{$self->{cas_db_connect}};
} # dbh


sub authen {
	my $self = shift;
	my $r = shift;
	my $user = shift || '';
	my $password = shift || '';
	$self->gripe("Apache::Auth::authen called");
	
	my $cookie_name = $self->client->{Cookie_Name};
	my $cookies = my $session_key = undef;
	$cookies = $r->headers_in->{Cookie} || '';
	if ($cookies =~ /$cookie_name=(\w{32})/) {
		$session_key = $1;
		$self->gripe("User already logged in: $cookie_name=$session_key");
		return OK;
	} # if key, assume user logged in, let authz do the rest
	
	unless ($user && $password) {
		my $base_cas_dir = $r->dir_config('CAS_BASE_URI') || '';
		my $request = $r->unparsed_uri;
		my $login = "/$base_cas_dir/public/login?return=$request";
		$r->custom_response(AUTH_REQUIRED, $login);
		$self->gripe("No username or password provided - send to login page: "
			. $login);
		return AUTH_REQUIRED;
	} # if no username or password provided, send to login page
	
	my $rem_ip = $r->connection->remote_ip;
	
	warn "Authenticating: USERNAME => $user, PASSWORD => $password, IP => $rem_ip";
	$session_key = $self->authenticate({USERNAME => $user,
		PASSWORD => $password, IP => $rem_ip});
	
	unless (defined $session_key) {
		# get messages and throw error - really this should go to custom page
		my $messages = $self->messages;
		$r->note_auth_failure;
		$self->gripe("Authen failed: $messages");
		return HTTP_UNAUTHORIZED;
	} # unless authentication succeeded
	
	# we set the cookie in err headers in case of internal redirect
	$r->err_headers_out->add('Set-Cookie' => "$cookie_name=$session_key; PATH=/");
	$self->gripe("User autheticated, Set-Cookie $cookie_name=$session_key");
	
	$self->_clear_result;
	return OK;
}


sub authz {
	my $self = shift;
	my $r = shift;
	return OK unless $r->is_initial_req;
	
	my $base_dir = $r->dir_config('CAS_BASE_URI') || '';
	my $request = $r->uri;
	my $full_request = $r->unparsed_uri;
	# what if it isn't under /public?!
	my $login = "/$base_dir/public/login?return=$full_request";
	$r->custom_response(AUTH_REQUIRED, $login);
	
	my $cookie_name = $self->client->{Cookie_Name};
	my $cookies = $r->headers_in->{Cookie} || '';
	$cookies    =~ /$cookie_name=(\w{32})/;
	my $session_key  = $1 || '';
	$self->gripe("cookies = $cookies");
	
	unless ($session_key) {
		# check header in case initial auth/internal redirect
		$session_key = $r->headers_out->{'Set-Cookie'};
		
		# need to check err_headers separately?
		
		if ($session_key) {
			$session_key =~ /$cookie_name=(\w*)/;
			$session_key  = $1 || '';
		} # must be first authz after authen
		
		else {
			my $CGI = new CGI;
			my %params = $CGI->Vars;
			$session_key = $params{$cookie_name};
		} # not internal redirect, get desperate and check CGI param?
		
		$self->gripe("cookie_name $cookie_name found $session_key.")
			if $self->debug;
		
		unless ($session_key) {
			$self->gripe("No cookie named $cookie_name found.");
			return AUTH_REQUIRED;
		} # if no session key, have user log in
	} # if no cookie
	
	# Some <Location>s may be configured so that all files under that location
	# need only to check against a single resource.
	my $there_is_only_one = $r->dir_config('SinglePermissionTree') || 0;
	if ($there_is_only_one) { $request = $base_dir }
	
	# And still other <Location>s may want to use only the top level file or
	# subdirectory. This could be useful for handlers or pages that parse the
	# remainder of the URL as arguments, or where the subdirectoires are all
	# assigned to individual users, who own everything therein
	my $down_one_only = $r->dir_config('OneStepOnly') || 0;
	if ($down_one_only) {
		$request =~ s{$base_dir(/[^/]+).+}{$base_dir$1};
	} # filter out sub'directories'
	
	my $rem_ip = $r->connection->remote_ip;
	warn "Authorizing: SESSION => $session_key, RESOURCE => $request, MASK => 8, IP => $rem_ip";
	my $is_authorized = $self->authorize({SESSION => $session_key,
		RESOURCE => $request, MASK => 8, IP => $rem_ip, DEBUG => 1});
	$self->gripe("SESSION => $session_key, "
		. "RESOURCE => $request, MASK => 8, IP => $rem_ip");
	
	unless (defined $is_authorized){
		# Check if authorization indicates new authentication required (like
		# if the session timed out
		my $messages = $self->messages;
		if ($self->response_is('AUTH_REQUIRED')) {
			$r->err_headers_out->set('Set-Cookie' => "$cookie_name=; PATH=/");
			$self->gripe("authorization returned AUTH_REQUIRED: $messages")
				if $self->debug;
			$self->_clear_result;
			return AUTH_REQUIRED;
		} # if authen needed
		
		$self->gripe("Authorization failed: $messages");
		$self->_clear_result;
		return FORBIDDEN;
	}
	
	$self->_clear_result;
	return OK;
} # authz



=head1 AUTHOR

Sean P. Quinlan, C<< <gilant at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-cas-apache-auth at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CAS-Apache>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CAS::Apache

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CAS-Apache>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CAS-Apache>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CAS-Apache>

=item * Search CPAN

L<http://search.cpan.org/dist/CAS-Apache>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Sean P. Quinlan, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of CAS::Apache::Auth
