#========================================================================================
# 辅助函数模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Auxiliary;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	get_app_dir
	get_profile_dir
	message_box
);

# include required modules
use strict;
use FindBin qw($Bin);

sub get_app_dir {
	return "$Bin";
}

sub get_profile_dir {
	return $ENV{'HOME'} . "/.gCRT";
}

sub message_box {
	my ($parent, $type, $message) = @_;
	my $dlg_msg = Gtk2::MessageDialog->new($parent,
		'destroy-with-parent',
		$type,
		'ok',
		$message);
	$dlg_msg->run;
	$dlg_msg->destroy;
}

1;
