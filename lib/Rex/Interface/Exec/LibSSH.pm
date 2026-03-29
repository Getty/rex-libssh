# ABSTRACT: Rex command execution via Net::LibSSH exec channels

package Rex::Interface::Exec::LibSSH;
our $VERSION = '0.003';
use strict;
use warnings;

use Rex;
use Rex::Logger;
use Rex::Interface::Exec::Base;
use base qw(Rex::Interface::Exec::Base);

sub new {
    my ( $that, %args ) = @_;
    my $proto = ref($that) || $that;
    return bless {%args}, $proto;
}

sub exec {
    my ( $self, $cmd, $option ) = @_;
    return $self->direct_exec( $cmd, $option // {} );
}

sub _exec {
    my ( $self, $cmd, $option ) = @_;

    my $ssh = Rex::is_ssh()
        or die "LibSSH exec: no active SSH connection";

    Rex::Logger::debug("LibSSH exec: $cmd");

    my $ch = $ssh->channel
        or die "LibSSH exec: failed to open channel";

    $ch->exec($cmd);

    my ( $out, $err ) = ( '', '' );

    # libssh processes all SSH protocol messages (including stderr window
    # adjustments) while blocking on the stdout read, so this sequential
    # approach is safe against deadlocks.
    $out = $ch->read;
    $err = $ch->read( -1, 1 );

    my $exit = $ch->exit_status;
    $ch->close;

    $? = $exit << 8;

    if ( ref $option eq 'HASH' && defined $out ) {
        $self->_continuous_read( $_, $option ) for split /\n/, $out;
    }

    return ( $out, $err );
}

1;

=head1 DESCRIPTION

L<Rex::Interface::Exec::LibSSH> implements Rex command execution using
L<Net::LibSSH> exec channels. Each C<run()> call opens a new channel,
executes the command, reads stdout and stderr, retrieves the exit status,
and closes the channel.

=head1 SEE ALSO

L<Rex::Interface::Connection::LibSSH>, L<Net::LibSSH::Channel>

=cut
