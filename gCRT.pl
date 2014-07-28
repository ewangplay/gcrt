#!/usr/bin/perl -w
#========================================================================================
# gCRT主程序
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================

# include required modules
use strict;
use POSIX ":sys_wait_h";
use Gtk2 -init;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Configure;
use StatusTray;
use Application;
use MainWindow;
use SessionView;

# process CHLD signal
$SIG{CHLD} = sub { while((my $pid = waitpid(-1, WNOHANG)) > 0) {} };

# call main function
main();

sub main {
    # assure uniqueness
    check_unique();

    # init application
    init_application();

    # init configure
    init_config();

    # init status tray
    init_status_tray();

    # init session
    init_session();

    # init main window
    init_window();

    # show main window
    show_window();

    # main loop
    Gtk2->main;
}

sub check_unique {
    my $inst_num = 0;
    my @results = `ps -ef | grep -i gcrt`;
    for my $line (@results) {
        if ($line =~ /perl/gi) {
            $inst_num++;
        }
    }
    if ($inst_num > 1) {
        print "A instance of gCRT already exists.\n";
        exit(0);
    }
}

