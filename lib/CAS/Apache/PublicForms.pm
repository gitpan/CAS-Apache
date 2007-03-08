package CAS::Apache::PublicForms;

use warnings FATAL => 'all', NONFATAL => 'redefine';
use strict;

=head1 NAME

CAS::Apache::UserForms - The great new CAS::Apache::UserForms!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
use Apache2::Const qw(OK SERVER_ERROR REDIRECT AUTH_REQUIRED);
use base qw(CAS::Apache);
use CAS::Apache::Auth ();

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use CAS::Apache::UserForms;

    my $foo = CAS::Apache::UserForms->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut


sub handler {
	my $apache2 = shift;
	die unless ref $apache2;
	
	my $request = $apache2->uri();
	die unless $request;
	
	$request =~ m{/(\w+)$};
	my $page = $1;
	unless ($page) {
		die "Unable to determine page requested in $request";
	} # unless it's a CAS page
	my $CR_gen_response = \&{$page};
	unless (defined &$CR_gen_response) {
		die "$page is not available through __PACKAGE__";
	} # see if method is defined in this namespace
	
	# $r->unparsed_uri to find args
	$apache2->content_type('text/html');
	
	my ($status, $html) = &$CR_gen_response($apache2);
	return $status unless $status == OK;
	
	print $html;
#	warn "HTML printed\n";
	return OK;
} # handler


sub login {
	my $apache2 = shift || die 'Request object required';
	my $cgi = CGI->new;
	$cgi->param(-name => 'Password', -value => ''); # just in case
	my $message = shift || '';
	warn "message = $message";
	$message = qq{<h3 style="color:red;">$message</h3>} if $message;
	
	my $base_cas_dir = $apache2->dir_config('CAS_BASE_URI') || '';
	my $auth_page = "$base_cas_dir/public/authentication";
	my %params = $cgi->Vars;
	
	my $html = $cgi->start_html("CAS default login page")
		. $cgi->h1("Please enter username and password:") . "\n"
		. $message . "\n"
		. $cgi->start_form(-action => $auth_page) . "\n"
		. "Username: "
		. $cgi->textfield(-name => 'Username', -default => $params{Username})
		. "\n" . $cgi->p . "Password: "
		. $cgi->password_field('Password') . "\n"
		. $cgi->hidden('uri', $params{return}) . "\n"
		. $cgi->p . $cgi->submit(-value=>'Log in') . "\n" . $cgi->end_form
		. "\n" . $cgi->p . qq{<a href="$base_cas_dir/public/forgot">}
		. qq{Forgot password?</a> &nbsp; &nbsp; <a href="/SQCAS/public/NewUser">}
		. "Register</a>"
		. $cgi->end_html;
	
	return (OK, $html);
} # login


sub logout {
	my $apache2 = shift;
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html);
} # logout


sub authentication {
	my $apache2 = shift;
	my $cgi = CGI->new;
	my %params = $cgi->Vars;
	
	my $base_cas_dir = $apache2->dir_config('CAS_BASE_URI') || '';
	
	my $auth = $apache2->dir_config('auth_object');
	my $status = SERVER_ERROR;
	my $messages = '';
	{
	no strict 'refs';
	$status = ${$auth}->authen($apache2, $params{Username}, $params{Password});
	$messages = ${$auth}->messages;
	warn "messages = $messages";
	}
	if ($status and $status == AUTH_REQUIRED) {
		# should be yet another configuration variable?!?
		return login($apache2, $messages);
	} # if auth required
	elsif ($status != OK) { return $status }
	
	my $welcome = $apache2->dir_config('CAS_WELCOME_PAGE') || '';
	my $location = $params{uri} || $welcome || "$base_cas_dir/";
	
	$apache2->headers_out->set(Location => $location);
	$apache2->status(REDIRECT);
	
	return (REDIRECT,'');
} # authentication


sub forgot_password {
	my $apache2 = shift;
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html)
} # forgot_password


sub new_user {
	my $apache2 = shift;
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html)
} # new_user


sub contact {
	my $apache2 = shift;
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html)
} # contact



=head1 AUTHOR

Sean P. Quinlan, C<< <gilant at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-cas-apache-userforms at rt.cpan.org>, or through the web interface at
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

1; # End of CAS::Apache::UserForms
