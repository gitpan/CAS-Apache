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
	
	# $apache2->unparsed_uri to find args
	$apache2->content_type('text/html');
	
	my ($status, $html) = &$CR_gen_response($apache2);
	return $status unless $status == OK;
	
	print $html;
#	warn "HTML printed\n";
	return OK;
} # handler


sub welcome {
	my $apache2 = shift || die 'Request object required';
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("CAS default welcome page");
	$html .= <<HTML;
<h1>Welcome to the Central Authorization Server</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html);
} # welcome


sub preferences {
	my $apache2 = shift || die 'Request object required';
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html);
} # preferences


sub forgot_password {
	my $apache2 = shift || die 'Request object required';
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html);
} # forgot_password

sub edit_account {
	my $apache2 = shift || die 'Request object required';
	my $cgi = CGI->new;
	
	my $html = $cgi->start_html("Foo");
	$html .= <<HTML;
<h1>Bar</h1>
HTML
	
	$html .= $cgi->end_html;
	return (OK, $html);
} # edit_account



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
