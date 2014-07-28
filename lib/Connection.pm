#========================================================================================
# 远程连接模块 
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Connection;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	remote_connect
);

use strict;
use Glib qw/TRUE FALSE/;
use Auxiliary;
use Global;

sub remote_connect {
	my ($host, $protocol, $port, $username, $password, $expect_script) = @_;
	my $cmd;

	# pack the remote connect command
	if ($options_data_ref->{'Generic'}->{'TerminalIfUsed'}) {
		my $terminal = $options_data_ref->{'Generic'}->{'Terminal'};

		if (lc($terminal) eq 'gnome-terminal') {	# special options
			$cmd = $terminal . " --hide-menubar -x ";
		}
		else {	# common options
			$cmd = $terminal . " -e ";
		}

		if (defined($expect_script) && -e $expect_script) {
			$cmd .= "expect $expect_script";
		}
		else {
			if (lc($protocol) eq 'telnet') {
				$cmd .= "$protocol -l $username $host $port";
			}
			elsif (lc($protocol) eq 'ssh') {
				$cmd .= "$protocol -l $username -p $port $host";
			}
			else {
				# error connection protocl
				return FALSE;
			}
		}
	}
	else {
		$cmd = $options_data_ref->{'Generic'}->{'ExternalCmd'};
		$cmd =~ s/%h/$host/g;
		$cmd =~ s/%p/$protocol/g;
		$cmd =~ s/%n/$port/g;
		$cmd =~ s/%u/$username/g;
		$cmd =~ s/%w/$password/g;
	}

	# fork the external command process
	my $pid = fork;
	if (!defined($pid)) {
		return FALSE;
	}
	unless($pid) {	#child process
		eval {
			if (!exec($cmd)) {
				die "execute external commdand failed!\n";
			}
		};
		if ($@) {
			print "$@\n";
		}
		exit(0);
	}

	# maximize the opened terminal
	system("sleep 1;wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz");

	return TRUE;
}

1;
