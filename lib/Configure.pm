#========================================================================================
# 配置管理模块 
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Configure;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	init_config
	load_config
	save_config
	);

# include required modules
use strict;
use Encode qw/decode/;
use Glib qw/TRUE FALSE/;
use Auxiliary;
use Global;

sub init_config {
	# user profile dir verify
	my $profile_dir = get_profile_dir();
	if (not -d $profile_dir) {
		mkdir($profile_dir, 0700) || die "initialization failed!";
	}

	# expect profile dir verify
	my $expect_dir = get_profile_dir() . "/expect";
	my $expect_version = `expect -v`;
	if ($expect_version =~ /expect version \d+[\d\.]*/) {	# expect installed
		if (not -d $expect_dir) {
			system("mkdir -p $expect_dir");
		}
	}
	else {	# expect not installed
		if (-d $expect_dir) {
			system("rm -rf $expect_dir");
		}
	}

	# load config
	load_config();

	# set default value if the specified options don't set
	if (!defined($options_data_ref->{'Protocol'})) {
		$options_data_ref->{'Protocol'}->{0} = 'telnet';
		$options_data_ref->{'Protocol'}->{1} = 'ssh';
	}

	if (!defined($options_data_ref->{'Terminal'})) {
		$options_data_ref->{'Terminal'}->{0} = 'gnome-terminal';
		$options_data_ref->{'Terminal'}->{1} = 'xterm';
		$options_data_ref->{'Terminal'}->{2} = 'aterm';
		$options_data_ref->{'Terminal'}->{3} = 'rxvt';
		$options_data_ref->{'Terminal'}->{4} = 'urxvt';
		$options_data_ref->{'Terminal'}->{5} = 'mrxvt';
	}

	if (not defined $options_data_ref->{'Generic'}->{'Terminal'}) {
		$options_data_ref->{'Generic'}->{'Terminal'} 
			= $options_data_ref->{'Terminal'}->{0};
	}

	if (not defined $options_data_ref->{'Generic'}->{'TerminalIfUsed'}) {
		$options_data_ref->{'Generic'}->{'TerminalIfUsed'} = TRUE;
	}

	if (not defined $options_data_ref->{'Generic'}->{'StartMinimized'}) {
		$options_data_ref->{'Generic'}->{'StartMinimized'} = FALSE;
	}
}

sub load_config {
	# load session data
	my $session_profile = get_profile_dir() . "/session.conf";
	if (-e $session_profile) {
		$session_data_ref = _read_profile($session_profile);
	}

	# load global options data
	my $options_profile = get_profile_dir() . "/global.conf";
	if (-e $options_profile) {
		$options_data_ref = _read_profile($options_profile);
	}
}

sub save_config {
	# save session data
	my $session_profile = get_profile_dir() . "/session.conf";
	_write_profile($session_profile, $session_data_ref);

	# save global options data
	my $options_profile = get_profile_dir() . "/global.conf";
	_write_profile($options_profile, $options_data_ref);
}

sub _read_profile {
	my $profile = shift;
	my $data_ref = {};

	open PROFILE, "<$profile" || die "read profile failed!";

	my $section;
	while (my $line = <PROFILE>) {
		chomp($line);
		if ($line =~ /^\s*\[(\S+)\]\s*$/) {
			$section = decode('utf8', $1);
			next;
		}

		if ($line =~ /^\s*(\w+)\s*=\s*(.*)\s*$/) {
			$data_ref->{$section}->{$1} = $2;
		}
	}

	close PROFILE;
	return $data_ref;
}

sub _write_profile {
	my ($profile, $data_ref) = @_;

	open PROFILE, ">$profile" || die "write profile failed!";
	for my $section (sort keys %$data_ref) {
		print PROFILE ("[$section]\n");
		my $options_ref = $data_ref->{$section};
		for my $option (sort keys %$options_ref) {
			my $value = $options_ref->{$option};
			print PROFILE ("$option=$value\n");
		}
		print PROFILE ("\n");
	}

	close PROFILE;
}

1;

