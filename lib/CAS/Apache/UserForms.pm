package CAS::Apache::UserForms;

use warnings FATAL => 'all', NONFATAL => 'redefine';
use strict;

=head1 NAME

CAS::Apache::UserForms - The great new CAS::Apache::UserForms!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
use Apache2::Const qw(OK SERVER_ERROR REDIRECT);
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

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $cgi = shift;
	
	my $self = bless ({cgi => $cgi},$class);
	return $self;
}


sub login {
	my $self = shift;
	my $r = shift || die 'Request object required';
	my $cgi = $self->{cgi};
	
	my $base_cas_dir = $r->dir_config('CAS_BASE_URI') || '';
	my $auth_page = "$base_cas_dir/public/authentication";
	my %params = $cgi->Vars;
	
	warn "Returning login form";
	my $html = $cgi->start_html("CAS default login page")
		. $cgi->h1("Please enter username and password:") . "\n"
		. $cgi->start_form(-action => $auth_page) . "\n"
		. "Username: "
		. $cgi->textfield(-name => 'Username', -default => $params{Username})
		. "\n" . $cgi->p . "Password: "
		. $cgi->password_field('Password') . "\n"
		. $cgi->hidden('uri', $params{return}) . "\n"
		. $cgi->p . $cgi->submit(-value=>'Log in') . "\n" . $cgi->end_form
		. "\n" . $cgi->p
		. qq{*Forgot password?* &nbsp; &nbsp; <a href="/SQCAS/public/NewUser">}
		. "Register</a>"
		. $cgi->end_html;
	
	return $html;
}


sub authentication {
	my $self = shift;
	my $r = shift;
	my $cgi = $self->{cgi};
	my %params = $cgi->Vars;
	
	my $admin_client = $r->dir_config('CLIENT_ID') || '';
	warn "admin_client = $admin_client\n";
	my $auth = CAS::Apache::Auth->new({CLIENT_ID => $admin_client});
	my $status = $auth->authen($r, $params{Username}, $params{Password});
	return $status unless $status == OK;
	
	my $base_cas_dir = $r->dir_config('CAS_BASE_URI') || '';
	my $location = $params{uri} || "$base_cas_dir/welcome";
	
	$r->headers_out->set(Location => $location);
	$r->status(REDIRECT);
	
	return REDIRECT;
} # authentication


sub welcome {
	my $self = shift;
	my $cgi = $self->{cgi};
	
	my $html = $cgi->start_html("CAS default welcome page");
	$html .= <<HTML;
<h1>Welcome to the Central Authorization Server</h1>
HTML
	
	$html .= $cgi->end_html;
	return $html
}


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
