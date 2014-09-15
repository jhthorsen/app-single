package App::single;

=head1 NAME

App::single - An application to run a single instance of a command

=head1 VERSION

0.05

=head1 DESCRIPTION

L<App::single> is an application which allow you to run a single instance of
a command. This is useful when you want to run a process from
L<crontab|http://crontab.org>. Example:

  * * * * * /usr/local/bin/single autossh example.com sleep 86400 2>/dev/null 1>/dev/null

The way it works is that it makes a temporarily file which include information
about the process. Information written to the file includes the PID of the
process, so the second time C<single> is started with the same arguments it
will check if the PID is alive.

NOTE: This script is not atomic, but more than good enough for handling the
"crontab" case.

=head1 SYNOPSIS

  $ single <command>
  $ single autossh example.com sleep 864000
  $ single "echo 123;sleep 86400";

NOTE: Including shell characters (such as ">", "|", ";", ...) will invoke the
shell, allowing unsafe user input.

=head1 ENVIRONMENT

=over 4

=item * SINGLE_HUP_SIGNAL

It is possible to send a HUP signal to the "single" process, which will
restart the application. The way it restarts the application is simply
by sending the C<SINGLE_HUP_SIGNAL> signal to the application. This
is "TERM" by default.

=back

=head1 INSTALLATION

The easiest way to get this application is by using cpanminus:

  $ curl -L http://cpanmin.us | perl -n - --sudo App::single

Note: C<--sudo> is to install "single" system wide, "-n" is to skip tests for
faster installation.

=cut

use strict;

our $VERSION = '0.05';

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Jan Henning Thorsen

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 AUTHOR

Jan Henning Thorsen - C<jhthorsen@cpan.org>

=cut

1;
