# ABSTRACT: Rex connection backend using Net::LibSSH (no SFTP required)

package Rex::LibSSH;

use strict;
use warnings;

1;

=head1 SYNOPSIS

  # In your Rexfile
  use Rex -feature => ['1.4'];
  use Rex::LibSSH;

  set connection => 'LibSSH';

  task 'deploy', 'myserver', sub {
      my $kernel = run 'uname -r';
      say "kernel: $kernel";
  };

=head1 DESCRIPTION

L<Rex::LibSSH> provides Rex connection, exec, filesystem, and file interfaces
backed by L<Net::LibSSH> — the XS binding for libssh.

Unlike Rex's built-in C<SSH> and C<OpenSSH> connection types, this backend
performs all file operations (C<is_file>, C<stat>, C<ls>, C<upload>,
C<download>, etc.) over plain SSH exec channels. No SFTP subsystem is required
on the remote host.

This makes it suitable for minimal containers, embedded systems, and any host
where Rex would otherwise crash with:

  Can't call method "stat" on an undefined value

=head2 Activating

Set the connection type in your Rexfile before connecting:

  set connection => 'LibSSH';

Rex's interface dispatch will automatically load
L<Rex::Interface::Connection::LibSSH>,
L<Rex::Interface::Exec::LibSSH>,
L<Rex::Interface::Fs::LibSSH>, and
L<Rex::Interface::File::LibSSH>.

=head2 Authentication

Supports public key authentication:

  Rex::Config->set_private_key('/home/user/.ssh/id_ed25519');
  Rex::Config->set_public_key('/home/user/.ssh/id_ed25519.pub');

Or pass keys directly to C<Rex::connect>:

  Rex::connect(
      server      => '10.0.0.1',
      user        => 'root',
      private_key => '/path/to/key',
      public_key  => '/path/to/key.pub',
      auth_type   => 'key',
  );

Host key checking is disabled by default (C<strict_hostkeycheck =E<gt> 0>)
to avoid blocking non-interactive deploys. To enable it, pass the option
when connecting:

  Rex::connect(
      server            => '10.0.0.1',
      strict_hostkeycheck => 1,
  );

=head1 SEE ALSO

L<Net::LibSSH>, L<Rex::Interface::Connection::LibSSH>,
L<Rex::Interface::Fs::LibSSH>, L<Rex::Interface::File::LibSSH>,
L<Rex::Interface::Exec::LibSSH>

=cut
