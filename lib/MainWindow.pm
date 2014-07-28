#========================================================================================
# 窗口管理模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package MainWindow;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	init_window
	show_window
);

# include required modules
use strict;
use Glib qw(TRUE FALSE);
use Global;
use Common;

# init the main window
sub init_window {
	# init session treeview
	my $treeview_sessions = $app->get_widget('treeview_sessions');
	$treeview_sessions->set('enable-tree-lines' => TRUE);
	$treeview_sessions->expand_all;

	# init session dialog
	my $dialog_session = $app->get_widget('dialog_session');
	$dialog_session->signal_connect('delete-event' => sub {
		       	$_[0]->hide;
	       		return TRUE;
		});

	my $entry_password = $app->get_widget('entry_password');
	$entry_password->set_visibility(FALSE);		# set password mode

	my $combobox_protocol = $app->get_widget('combobox_protocol');
	for my $protocol_idx (sort keys %{$options_data_ref->{'Protocol'}}) {
		$combobox_protocol->append_text($options_data_ref->{'Protocol'}->{$protocol_idx});
	}

	# init preferce dialog
	my $dialog_preference = $app->get_widget('dialog_preference');
	$dialog_preference->signal_connect('delete-event' => sub {
			$_[0]->hide;
			return TRUE;
		});

	# init terminal combobox
	my $combobox_terminal = $app->get_widget('combobox_terminal');
	for my $terminal_idx (sort keys %{$options_data_ref->{'Terminal'}}) {
		$combobox_terminal->append_text($options_data_ref->{'Terminal'}->{$terminal_idx});
	}

	# init the terminal radiobutton group
	my $radiobutton_terminal = $app->get_widget('radiobutton_terminal');
	$radiobutton_terminal->set_active($options_data_ref->{'Generic'}->{'TerminalIfUsed'});

	# init the start-minimized checkbutton
	my $checkbutton_minimized = $app->get_widget('checkbutton_minimized');
	$checkbutton_minimized->set_active($options_data_ref->{'Generic'}->{'StartMinimized'});

	# init the main window
	my $window = $app->get_widget('main_window');
	$window->signal_connect('delete-event' => \&change_window_status);
}

# show the main window
sub show_window {
	my $window = $app->get_widget('main_window');
	if (not $options_data_ref->{'Generic'}->{'StartMinimized'}) {
		$window->show;
	}
}

1;
