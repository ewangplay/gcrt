#========================================================================================
# 托盘区管理模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package StatusTray;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	init_status_tray
	);

# include required medules
use strict;
use Encode qw(decode);
use Common;
use Auxiliary;
use Global;

my $status_icon;

sub init_status_tray {
	$status_icon = Gtk2::StatusIcon->new;
	$status_icon->set_from_file(get_app_dir() . "/glade/gCRT.png");
	$status_icon->set_tooltip(decode('utf8', 'gCRT远程连接'));
	$status_icon->signal_connect('activate' => \&change_window_status);
	$status_icon->signal_connect('popup-menu' => \&status_menu);
}

sub status_menu {
	my ($status_icon, $button, $activate_time) = @_;
	my $menu = Gtk2::Menu->new;
	my $item;

	# show connect session list
	$item = Gtk2::ImageMenuItem->new_from_stock('gtk-connect');
	my $submenu = Gtk2::Menu->new;
	my $subitem;
	my @sessions = sort(keys(%$session_data_ref));
	for(my $index = 0; $index < @sessions; ++$index) {
		$subitem = Gtk2::MenuItem->new_with_label($sessions[$index]);
		$subitem->signal_connect('activate', \&explain_session);
		$subitem->set_data('index', $index);
		$submenu->append($subitem);
	}
	$item->set_submenu($submenu);
	$menu->append($item);

	# preference item
	$item = Gtk2::ImageMenuItem->new_from_stock('gtk-preferences');
	$item->signal_connect('activate' => \&show_preference_dialog);
	$menu->append($item);

	# quit item
	$item = Gtk2::ImageMenuItem->new_from_stock('gtk-quit');
	$item->signal_connect('activate' => \&quit_application);
	$menu->append($item);

	# show menu
	$menu->show_all;
	$menu->popup(
		undef,
		undef,
		\&Gtk2::StatusIcon::position_menu,
		$status_icon,
		$button,
		$activate_time
	);
}

sub explain_session {
	my ($menu_item) = @_;
	my $index = $menu_item->get_data('index');
	my @sessions = sort(keys(%$session_data_ref));
	my $cur_session = $sessions[$index];
	if (!activate_session($cur_session)) {
		my $window = $app->get_widget('main_window');
		message_box($window, 'error', 
			decode('utf8', '连接失败，请检查配置信息!'));
		return;
	}

    # hide the main window if session activated
    change_window_status();
}

1;
