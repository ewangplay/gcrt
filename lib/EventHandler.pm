#========================================================================================
# 事件处理模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package EventHandler;
#########################################################################################
# event handler
#
# on_button_connect_clicked
# on_button_quit_clicked
# on_toolbutton_connect_clicked
# on_toolbutton_quick_connect_clicked
# on_toolbutton_new_session_clicked
# on_toolbutton_delete_session_clicked
# on_toolbutton_edit_session_clicked
# on_toolbutton_preference_clicked
# on_button_session_ok_clicked
# on_button_session_cancel_clicked
# on_checkbutton_minimized_toggled
# on_combobox_protocol_changed
# on_button_preference_ok_clicked
# on_button_preference_cancel_clicked
# on_radiobutton_terminal_toggled
# on_treeview_sessions_button_press_event
# on_treeview_sessions_row_activated
##########################################################################################
use strict;
use Glib qw/TRUE FALSE/;
use Data::Dumper;
use Encode qw/decode/;
use Common;
use Auxiliary;
use Connection;
use Global;

use constant {
	NEW_SESSION => 0,
	EDIT_SESSION => 1,
	QUICK_CONNECT => 2,
};

use constant {
	TELNET_DEFAULT_PORT => 23,
	SSH_DEFAULT_PORT => 22,
};

my $session_operation;

sub on_button_connect_clicked {
	# get selected session iterator
	my $iter = get_selected_iter();
	if (not defined $iter) {
		return;
	}

	# if select root item, do nothing
	my $path = $session_model->get_string_from_iter($iter);
	if ($path eq '0') {
		return;
	}

	# get selected session name and activate it
	my $session_name = $session_model->get($iter, 0);
	if (!activate_session($session_name)) {
		my $window = $app->get_widget('main_window');
		message_box($window, 'error', 
			decode('utf8', '连接失败，请检查配置信息!'));
		return;
	}

    # hide the main window when the session activated
    change_window_status();
}

sub on_button_quit_clicked {
	quit_application();
}

sub on_toolbutton_connect_clicked {
	on_button_connect_clicked();
}

sub on_toolbutton_quick_connect_clicked {
	# set opearation type
	$session_operation = QUICK_CONNECT;

	# show the session dialog
	show_session_dialog('', 'telnet', '', '', '', '');
}

sub on_toolbutton_new_session_clicked {
	# set opearation type
	$session_operation = NEW_SESSION;

	# show the session dialog
	show_session_dialog('', 'telnet', '', '', '', '');
}

sub on_toolbutton_delete_session_clicked {
	# get selected session iterator
	my $iter = get_selected_iter();
	if (not defined $iter) {
		return;
	}

	# if select root item, do nothing
	my $path = $session_model->get_string_from_iter($iter);
	if ($path eq '0') {
		return;
	}

	# get selected session name
	my $session_name = $session_model->get($iter, 0);

	# remove entry from session data 
	undef $session_data_ref->{$session_name};

	# remove entry from session model
	$session_model->remove($iter);

	# remove the related expect script file
	my $expect_script = get_profile_dir() . "/expect/$session_name.expect";
	system("rm -f $expect_script");
}

sub on_toolbutton_edit_session_clicked {
	# set session operation
	$session_operation = EDIT_SESSION;

	# get selected iterator
	my $iter = get_selected_iter();
	if (not defined $iter) {
		return;
	}

	# if select root item, do nothing
	my $path = $session_model->get_string_from_iter($iter);
	if ($path eq '0') {
		return;
	}

	# get selected session name
	my $session_name = $session_model->get($iter, 0);

	# show the session dialog
	show_session_dialog($session_name,
		$session_data_ref->{$session_name}->{'protocol'},
		$session_data_ref->{$session_name}->{'host'},
		$session_data_ref->{$session_name}->{'port'},
		$session_data_ref->{$session_name}->{'username'},
		$session_data_ref->{$session_name}->{'password'},
	);
}

sub on_toolbutton_preference_clicked {
	show_preference_dialog();
}

sub on_button_session_ok_clicked {
	my $dialog_session = $app->get_widget('dialog_session');

	# get session info
	my $entry_session_name = $app->get_widget('entry_session_name');
	my $combobox_protocol = $app->get_widget('combobox_protocol');
	my $entry_host = $app->get_widget('entry_host');
	my $entry_port = $app->get_widget('entry_port');
	my $entry_username = $app->get_widget('entry_username');
	my $entry_password = $app->get_widget('entry_password');

	my $session_name = $entry_session_name->get_text;
	my $protocol = $combobox_protocol->get_active_text;
	my $host = $entry_host->get_text;
	my $port = $entry_port->get_text;
	my $username = $entry_username->get_text;
	my $password = $entry_password->get_text;

	# verify session name
	# if create new session or edit existed session, the sesson name can't be empty.
	if ($session_operation == NEW_SESSION || $session_operation == EDIT_SESSION) {
		if ($session_name eq '') {
			message_box($dialog_session, 'warning', 
				decode('utf8', '会话名称不能为空!'));
			return;
		}
	}
	# if create new session, the session name can't identify with existed session.
	if ($session_operation == NEW_SESSION) {
		if (defined $session_data_ref->{$session_name}) {
			message_box($dialog_session, 'warning', 
				decode('utf8', '会话名称已经存在!'));
			return;
		}
	}

	# verify protocol
	if ($protocol eq '') {
		message_box($dialog_session, 'warning', 
			decode('utf8', '连接协议不能为空!'));
		return;
	}

	# verify host ip
	if ($host eq '') {
		message_box($dialog_session, 'warning', 
			decode('utf8', '连接主机不能为空!'));
		return;
	}
	# if the host ip is not xxx.xxx.xxx.xxx format, prompt invalid
    #if ($host !~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
    #	message_box($dialog_session, 'warning', 
    #		decode('utf8', '主机IP格式无效!'));
    #	return;
    #}

	# verify port
	if ($port eq '') {
		message_box($dialog_session, 'warning', 
			decode('utf8', '连接端口不能为空!'));
		return;
	}
	# if the port is not number, prompt invalid
	if ($port !~ /^\d+$/) {
		message_box($dialog_session, 'warning', 
			decode('utf8', '连接端口必须是整数!'));
		return;
	}

	if ($session_operation == QUICK_CONNECT) {
		# generate the auto-login expect script
		my $expect_script;
		my $expect_dir = get_profile_dir() . "/expect";
		if (-d $expect_dir) {
			$expect_script = get_profile_dir() . "/expect/tmp.expect";
			generate_script($expect_script, $protocol, $host, 
				$port, $username, $password);
		}

		# connect remove host
		if (!remote_connect($host, $protocol, $port, $username, $password, $expect_script)) {
			message_box($dialog_session, 'error', 
				decode('utf8', '连接失败，请检查配置信息!'));
			return;
		}
	}
	else {
		# save session info into session_data_ref structure
		$session_data_ref->{$session_name}->{'protocol'} = $protocol;
		$session_data_ref->{$session_name}->{'host'} = $host;
		$session_data_ref->{$session_name}->{'port'} = $port;
		$session_data_ref->{$session_name}->{'username'} = $username;
		$session_data_ref->{$session_name}->{'password'} = $password;

		if ($session_operation == NEW_SESSION) {
			my $iter = $session_model->get_iter_first;
			my $iter_child = $session_model->append($iter);
			$session_model->set($iter_child, 0 => $session_name);
		}
		elsif ($session_operation == EDIT_SESSION) {
			my $treeview_sessions = $app->get_widget('treeview_sessions');
			my $selection = $treeview_sessions->get_selection;
			my $iter = $selection->get_selected;
			$session_model->set($iter, 0 => $session_name);
		}

		# generate the auto-login expect script
		my $expect_dir = get_profile_dir() . "/expect";
		if (-d $expect_dir) {
			my $expect_script = "$expect_dir/$session_name.expect";
			generate_script($expect_script, $protocol, $host, 
				$port, $username, $password);
		}

		# expand tree view
		my $treeview_sessions = $app->get_widget('treeview_sessions');
		$treeview_sessions->expand_all;
	}

	# hide the dialog
	$dialog_session->hide;
}

sub on_button_session_cancel_clicked {
	my $dialog_session = $app->get_widget('dialog_session');
	$dialog_session->hide;
}

sub on_checkbutton_minimized_toggled {
	my $checkbutton = $_[0];
	if ($checkbutton->get_active) {
		$options_data_ref->{'Generic'}->{'StartMinimized'} = TRUE;
	}
	else
	{
		$options_data_ref->{'Generic'}->{'StartMinimized'} = FALSE;
	}
}


sub on_combobox_protocol_changed {
	my $combobox = $_[0];
	my $protocol = $combobox->get_active_text;
	my $entry_port = $app->get_widget('entry_port');
	my $port = 0;
	if ($protocol eq 'telnet') {
		$port = TELNET_DEFAULT_PORT;
	}
	elsif ($protocol eq 'ssh') {
		$port = SSH_DEFAULT_PORT;
	}
	$entry_port->set_text($port);
}

sub on_button_preference_ok_clicked {
	my $dialog_preference = $app->get_widget('dialog_preference');

	my $radiobutton_terminal = $app->get_widget('radiobutton_terminal');
	# use standard terminal
	if ($radiobutton_terminal->get_active) {
		my $combobox_terminal = $app->get_widget('combobox_terminal');
		$options_data_ref->{'Generic'}->{'TerminalIfUsed'} = TRUE;
		$options_data_ref->{'Generic'}->{'Terminal'} = $combobox_terminal->get_active_text;
	}
	# use user-defined interface
	else {
		my $entry_interface = $app->get_widget('entry_interface');
		my $interface = $entry_interface->get_text;
		if ($interface eq '') {
			message_box($dialog_preference, 'warning', 
				decode('utf8', '请设置外部命令!'));
			return;
		}
		$options_data_ref->{'Generic'}->{'TerminalIfUsed'} = FALSE;
		$options_data_ref->{'Generic'}->{'ExternalCmd'} = $entry_interface->get_text;
	}

	# hide the preference dialog
	$dialog_preference->hide;
}

sub on_button_preference_cancel_clicked {
	my $dialog_preference = $app->get_widget('dialog_preference');
	$dialog_preference->hide;
}

sub on_radiobutton_terminal_toggled {
	my $radiobutton_terminal = $_[0];
	my $combobox_terminal = $app->get_widget('combobox_terminal');
	my $entry_interface = $app->get_widget('entry_interface');
	if ($radiobutton_terminal->get_active) {
		$combobox_terminal->set_sensitive(TRUE);
		$entry_interface->set_sensitive(FALSE);
	}
	else {
		$combobox_terminal->set_sensitive(FALSE);
		$entry_interface->set_sensitive(TRUE);
	}
}

sub on_treeview_sessions_button_press_event {
	my ($treeview, $eventbutton) = @_;
	if ($eventbutton->button == 3) {
		# create the right button menu
		my $menu = Gtk2::Menu->new;
		my $item;

		# create the connect menu item 
		$item = Gtk2::ImageMenuItem->new_from_stock('gtk-connect');
		$item->signal_connect('activate', \&on_button_connect_clicked);
		$menu->append($item);

		# create the edit menu item
		$item = Gtk2::ImageMenuItem->new_from_stock('gtk-edit');
		$item->signal_connect('activate', \&on_toolbutton_edit_session_clicked);
		$menu->append($item);

		# create the delete menu item
		$item = Gtk2::ImageMenuItem->new_from_stock('gtk-delete');
		$item->signal_connect('activate', \&on_toolbutton_delete_session_clicked);
		$menu->append($item);

		# popup the right menu
		$menu->show_all;
		$menu->popup(
			undef,
			undef,
			undef,
			undef,
			$eventbutton->button,
			$eventbutton->time
		);
	}
}

sub on_treeview_sessions_row_activated {
	on_button_connect_clicked();
}

1;
