package CAS::Apache;

use warnings;
use strict;

=head1 NAME

CAS::Apache - The great new CAS::Apache!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.42';
use Apache2::RequestRec ();
use Apache2::Const qw(OK);
use CAS::Apache::UserForms ();
use CGI qw(fatalsToBrowser);
use Apache2::RequestIO ();

$| = 1;

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use CAS::Apache;

    my $foo = CAS::Apache->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut


sub handler {
	my $r = shift;
	die unless ref $r;
	my $cgi = CGI->new;
	
	my $forms = CAS::Apache::UserForms->new($cgi);
	
	my $request = $r->uri();
	die unless $request;
	my $base_cas_dir = $r->dir_config('CAS_BASE_URI') || '';
	warn "base_cas_dir = $base_cas_dir ; request = $request";
	
	$request =~ m{$base_cas_dir/(?:public/)?(\w+)};
	my $page = $1;
	unless ($page) {
		die "Don't know what to do with $request";
	} # unless it's a CAS page
	warn "html = $forms->$page(\$r)\n";
	
	# $r->unparsed_uri to find args
	$r->content_type('text/html');
	
	my $html = $forms->$page($r);
	print $html;
	
	warn "HTML printed\n";
	return OK;
} # handler


# write wrappers for the appropriate cas messaging functions


=head1 AUTHOR

Sean P. Quinlan, C<< <gilant at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-cas-apache at rt.cpan.org>, or through the web interface at
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

1; # End of CAS::Apache
