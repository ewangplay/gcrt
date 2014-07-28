#========================================================================================
# 全局对象模块
# version: 1.0
# author: lazypand (ewangplay@gmail.com)
#========================================================================================
package Global;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	$app
	$session_data_ref
	$options_data_ref
	$session_model
	);

use strict;

# global data structure

#=============================================================================================
# Gtk2::GladeXML instance
our $app;

#=============================================================================================
# $session_data_ref-->{session_name}-->{protocol} = $protocol
#                                   -->{host} = $host
#                                   -->{port} = $port
#                                   -->{username} = $username
#                                   -->{password} = $password
our $session_data_ref;

#=============================================================================================
# $options_data_ref-->{Generic}-->{StartMinimized} = $bool_value
#                  |           -->{Terminal} = $terminal
#                  |           -->{TerminalIfUsed} = $bool_value
#                  |           -->{ExternalCmd} = $external_cmd
#                  |
#                  |->{Protocol}->{$protocol_index} = $protocol_name
#                  |
#                  -->{Terminal}->{$terminal_index} = $terminal_name 
our $options_data_ref;

#=============================================================================================
# Gtk2::TreeStore instance
our $session_model;

1;
