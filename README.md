# Rex::LibSSH

[Rex](https://www.rexify.org/) connection backend using [Net::LibSSH](https://metacpan.org/pod/Net::LibSSH) — no SFTP required.

Rex's built-in SSH backends perform file operations (C<is_file>, C<stat>, C<upload>, C<download>, etc.) via SFTP. This fails on hosts without an SFTP subsystem with the confusing error:

```
Can't call method "stat" on an undefined value
```

`Rex::LibSSH` replaces all four Rex interfaces — connection, exec, filesystem, and file — with implementations that use plain SSH exec channels. **No SFTP subsystem is needed on the remote host.**

This is the standard backend for deploying to Hetzner dedicated servers, minimal containers, and any environment where Rex would otherwise crash.

## Synopsis

```perl
# In your Rexfile
use Rex -feature => ['1.4'];
use Rex::LibSSH;

set connection => 'LibSSH';

task 'deploy', 'myserver', sub {
    my $kernel = run 'uname -r';
    say "kernel: $kernel";

    # File operations work without SFTP
    upload 'local/file', '/remote/path';
    my @files = list_files '/etc';
};
```

## Authentication

```perl
# Public key (recommended)
Rex::Config->set_private_key('/home/user/.ssh/id_ed25519');
Rex::Config->set_public_key('/home/user/.ssh/id_ed25519.pub');

# Or pass directly to Rex::connect
Rex::connect(
    server      => '10.0.0.1',
    user        => 'root',
    private_key => '/path/to/key',
    public_key  => '/path/to/key.pub',
    auth_type   => 'key',
);
```

## Host key verification

The server's host key is verified against `known_hosts` by default, exactly
like an interactive `ssh` client but without the prompt: an unknown or
changed key makes the connection fail before any authentication is attempted.
Add the host out of band first (`ssh-keyscan -p 22 10.0.0.1 >> ~/.ssh/known_hosts`),
or turn verification off explicitly. Requires Net::LibSSH 0.004 or later.

```perl
# Rexfile-wide, same flag the OpenSSH backend honours
use Rex -feature => ['1.4', 'disable_strict_host_key_checking'];

# or per connection
Rex::connect(
    server              => '10.0.0.1',
    strict_hostkeycheck => 0,
    knownhosts          => '/path/to/known_hosts',   # optional, default ~/.ssh/known_hosts
);
```

`Rex::Config->set_openssh_opt( UserKnownHostsFile => $file )` is honoured as
well, so a Rexfile can point every connection at its own `known_hosts`.

Versions before 0.004 never verified the host key, regardless of what was
passed (CWE-322).

## Installation

```
cpanm Rex::LibSSH
```

Or from this repository:

```
cpanm --installdeps .
dzil build
cpanm Rex-LibSSH-*.tar.gz
```

## See Also

- [Net::LibSSH](https://metacpan.org/pod/Net::LibSSH)
- [Rex::GPU](https://metacpan.org/pod/Rex::GPU) — requires this backend for SFTP-less GPU servers
- [Rex](https://metacpan.org/pod/Rex)

## Author

Torsten Raudssus `<getty@cpan.org>`

## License

This software is copyright (c) 2026 by Torsten Raudssus. This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
