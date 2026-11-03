requires 'Net::LibSSH', '0.004';
requires 'Rex',         '1.16.0';

on test => sub {
    requires 'File::Temp';
    requires 'IO::Socket::INET';
    requires 'Test::More',   '0.98';
};
