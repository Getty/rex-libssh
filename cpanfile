requires 'Rex',         '1.16.0';
requires 'Net::LibSSH', '0.004';

on test => sub {
    requires 'Test::More',   '0.98';
    requires 'File::Temp';
    requires 'IO::Socket::INET';
};
