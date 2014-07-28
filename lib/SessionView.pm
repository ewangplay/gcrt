#========================================================================================
# 会话管理模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package SessionView;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	init_session
);

use strict;
use Glib qw/TRUE FALSE/;
use Encode qw/decode/;
use Global;

sub init_session {
	# init session model
	$session_model = Gtk2::TreeStore->new(qw/Glib::String/);
	my $iter = $session_model->append(undef);
	$session_model->set($iter, 0 => decode('utf8', '连接'));

	for my $session_name (sort keys %$session_data_ref) {
		my $iter_child = $session_model->append($iter);
		$session_model->set($iter_child, 0 => $session_name);
	}

	# init session tree view
	my $treeview = $app->get_widget('treeview_sessions');
	$treeview->set_model($session_model);
	my $column = Gtk2::TreeViewColumn->new();
	my $renderer = Gtk2::CellRendererText->new();
	$column->pack_start($renderer, FALSE);
	$column->add_attribute($renderer, text => 0);
	$treeview->append_column($column);
}

1;
