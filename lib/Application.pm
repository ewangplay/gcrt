#========================================================================================
# Glade加载模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Application;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	init_application
	);

# include required modules
use strict;
use Gtk2::GladeXML;
use EventHandler;
use Auxiliary;
use Global;

#global instance definition
sub init_application {
	# load UI based glade xml format
	$app = Gtk2::GladeXML->new(get_app_dir() . '/glade/gCRT.glade');

	# auto connect all the signals to the event handler module
	$app->signal_autoconnect_from_package('EventHandler');
}

1;
