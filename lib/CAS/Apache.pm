package CAS::Apache;

use warnings;
use strict;

=head1 NAME

CAS::Apache - The great new CAS::Apache!

=head1 VERSION

Version 0.44

=cut

our $VERSION = '0.44';
#use Apache2::Const qw(OK);
#use CAS::Apache::UserForms ();
#use CGI qw(fatalsToBrowser);
use Apache2::RequestRec ();
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


# write wrappers for the appropriate cas messaging functions

=head1 TO DO

Write wrappers for CAS messaging for more useful behavior under mod_perl and to
allow CAS-Apache handlers to use same methodology.

Sort out how to have CAS::Apache::Auth determine clients dynamically (perhaps
a conf.d/client.conf PerlSetVar Client Dynamic(|Static), or just have
CLIENT_ID set to Dynamic or Lookup or such non-numeric?

Decide how to implement permission trees, so that a single top level
directory need be granted, and where that gets configured.

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
