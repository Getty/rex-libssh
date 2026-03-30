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

Host key checking is disabled by default to avoid blocking non-interactive deploys. Enable it by passing `strict_hostkeycheck => 1` to `Rex::connect`.

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
