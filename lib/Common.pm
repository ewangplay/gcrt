#========================================================================================
# 公共函数模块 
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Common;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	quit_application
	change_window_status
	show_session_dialog
	show_preference_dialog
	get_selected_iter
	activate_session
	generate_script
	);

use strict;
use Glib qw/TRUE FALSE/;
use Configure;
use Connection;
use Auxiliary;
use Global;

sub quit_application {
	# save configure
	save_config();

	# quit the application
	Gtk2->main_quit;
}

sub show_session_dialog {
	my ($session_name, $protocol, $host, $port, $username, $password) = @_;

	my $dialog_session = $app->get_widget('dialog_session');
	my $entry_session_name = $app->get_widget('entry_session_name');
	my $combobox_protocol = $app->get_widget('combobox_protocol');
	my $entry_host = $app->get_widget('entry_host');
	my $entry_port = $app->get_widget('entry_port');
	my $entry_username = $app->get_widget('entry_username');
	my $entry_password = $app->get_widget('entry_password');

	$entry_session_name->set_text($session_name);
	$entry_host->set_text($host);
	$entry_port->set_text($port);
	$entry_username->set_text($username);
	$entry_password->set_text($password);
	for my $protocol_idx (sort keys %{$options_data_ref->{'Protocol'}}) {
		if (lc($options_data_ref->{'Protocol'}->{$protocol_idx}) eq lc($protocol))
		{
			$combobox_protocol->set_active($protocol_idx);
		}
	}

	$dialog_session->show_all;
}

sub show_preference_dialog {
	my $dialog_preference = $app->get_widget('dialog_preference');
	my $radiobutton_terminal = $app->get_widget('radiobutton_terminal');
	my $combobox_terminal = $app->get_widget('combobox_terminal');
	my $radiobutton_interface = $app->get_widget('radiobutton_interface');
	my $entry_interface = $app->get_widget('entry_interface');

	# init the terminal combo box
	for my $terminal_idx (sort keys %{$options_data_ref->{'Terminal'}}) {
		if ($options_data_ref->{'Terminal'}->{$terminal_idx} 
			eq $options_data_ref->{'Generic'}->{'Terminal'})
		{
			$combobox_terminal->set_active($terminal_idx);
		}
	}

	# init the external command text field
	if (defined $options_data_ref->{'Generic'}->{'ExternalCmd'}) {
		$entry_interface->set_text($options_data_ref->{'Generic'}->{'ExternalCmd'});
	}

	# init the radio button
	if ($options_data_ref->{'Generic'}->{'TerminalIfUsed'}) {
		$radiobutton_terminal->set_active(TRUE);
	}
	else {
		$radiobutton_interface->set_active(TRUE);
	}

	# show the preference dialog
	$dialog_preference->show_all;
}

sub get_selected_iter {
	my $treeview_sessions = $app->get_widget('treeview_sessions');
	my $selection = $treeview_sessions->get_selection;
	my $iter = $selection->get_selected;
	return $iter;
}

sub change_window_status {
	my $window = $app->get_widget('main_window');
	if ($window->get('visible')) {
		$window->hide;
	}
	else {
		$window->show;
	}
	return TRUE;
}

sub activate_session {
	my ($session_name) = @_;

	if (!defined($session_name)) {
		return FALSE;
	}

	my $host = $session_data_ref->{$session_name}->{'host'};
	my $protocol = $session_data_ref->{$session_name}->{'protocol'};
	my $port = $session_data_ref->{$session_name}->{'port'};
	my $username = $session_data_ref->{$session_name}->{'username'};
	my $password = $session_data_ref->{$session_name}->{'password'};

	my $expect_script = get_profile_dir() . "/expect/$session_name.expect";

	if (!remote_connect($host, $protocol, $port, $username, $password, $expect_script)) {
		return FALSE;
	}
	return TRUE;
}

sub generate_script {
	my ($filename, $protocol, $host, $port, $username, $password) = @_;
	my $script_content;

	$username =~ s/\$/\\\$/g;
	$password =~ s/\$/\\\$/g;

	if (lc($protocol) eq 'telnet') {
		$script_content = "spawn $protocol $host $port
expect :
send $username\\n
expect :
send $password\\n
interact";
	}
	elsif (lc($protocol) eq 'ssh') {
		$script_content = "spawn $protocol -l $username -p $port $host
expect :
send $password\\n
interact";
	}
	else {
		return FALSE;
	}
		
	open EXPECT, ">$filename" || return FALSE;
	print EXPECT ("$script_content\n");
	close EXPECT;

	return TRUE;
}

1;
