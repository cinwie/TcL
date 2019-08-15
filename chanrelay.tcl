# chanrelay.tcl 3.10
#
# A way to link your channels
#
# Author: CrazyCat <crazycat@c-p-f.org>
# http://www.eggdrop.fr
# irc.zeolia.net #eggdrop

## DESCRIPTION ##
#
# This TCL is a complete relay script wich works with botnet.
# All you have to do is to include this tcl in all the eggdrop who
# are concerned by it.
#
# You can use it as a spy or a full duplex communication tool.
#
# It don't mind if the eggdrops are on the same server or not,
# it just mind about the channels and the handle of each eggdrop.

## CHANGELOG ##
#
# 3.10 (05/12/2016) 
# Added the ability to synchronize topics (beta version).
# 3.9
# Added exclusion list to ignore some users
# Added a way to restrict relay to an internal user list
#
# 3.81
# Action mades by server are no more using nick "*"
# Added a protection on oper actions:
#	the action must come from the oper bot
# Correction of the quit transmission: when the bot leaves,
#	it now detect and transmit
# Added botnet status broadcast
# Changed the unload system (thanks to MenzAgitat)
#
# 3.8
# Correction : the config file can now use username for naming,
#	allowing to have relaying eggdrops in the same place with
#	different settings
#
# 3.7
# Addition of @commandes (public) restricted to operators:
#	@topic <network|all> a new topic :
#		Changes topic on specified network (or all)
#	@mode <network|all> +mode [arg][,-mode [arg]] :
#		Changes modes on specified network (or all)
#		All modes must be separated with a comma
#	@kick <network|all> user [reason] :
#		Kicks user on specified network (or all)
#	@ban <network|all> user [reason]:
#		Ban-kick user on specified network (or all)
#	Default reason and banmask are in the conf section
#
# 3.6-3
# Correction of trans mode on/off
#
# 3.6-2
# Correction of the logging of actions (/me)
#	Nick was replaced with ACTION
# Correction of empty chan list (!who)
# 
# 3.6-1
# Correction of the !who command
# It's now possible to have the list from a specific server
#
# 3.6
# Correction of modes catching / transmitting
#
# 3.5 (Beta)
# Integration of Message Delivery Service (MDS)
# by MenzAgitat
#
# 3.4
# Settings modified by msg commands are now saved
# Correction of small bugs
# Best verification of settings sent
# Acknowledgement and error messages added
#
# 3.3-1
# Correction for /msg eggdrop trans <action> [on|off]
#
# 3.3
# Added lines introducing beginning and ending of userlist
#
# 3.2
# Added gray user highlight
#
# 3.1
# Added check for linked bot
# Corrected parse of some messages
# Corrected pub commands
#
# 3.0
# Complete modification of configuration
# Use of namespace
# No more broadcast, the relay is done with putbot

## TODO ##
#
# Enhance configuration
# Allow save of configuration
# Multi-languages

## CONFIGURATION ##
#
# For each eggdrop in the relay, you have to
# indicate his botnet nick, the chan and the network.
#
# Syntax:
# set regg(USERNAME) {
#	"chan"		"#CHANNEL"
#	"network"	"NETWORK"
#}
# with:
# USERNAME : The username sets in eggdrop.conf (case-sensitive)
# optionaly, you can override default values:
# * highlight (0/1/2/3): is speaker highlighted ? (no/bold/undelined/gray)
# * snet (y/n): is speaker'network shown ?
# * transmit (y/n): does eggdrop transmit his channel activity ?
# * receive (y/n): does eggdrop diffuse other channels activity ?
# * oper (y/n): does the eggdrop accept @ commands (topic, kick, ban) ?
#
# userlist(beg) is the sentence announcing the start of !who
# userlist(end) is the sentence announcing the end of !who

namespace eval crelay {

	variable regg
	variable default
	variable userlist

    set regg(Saya) {
        "chan"		"#WNetZNC"
        "network"	"WNet"
        "highlight"	3
        "log"		"n"
        "oper"      "n"
    }
    
    set regg(WNetZNC) {
        "chan"		"#WNetZNC"
        "network"	"DALnet"
        "highlight"	3
        "oper"      "n"
    }

#	set regg(CC_Egg) {
#		"chan"		"#eggdrop.fr"
#		"network"	"Undernet"
#	}

	set default {
		"highlight"	1
		"snet"		"y"
		"transmit"	"y"
		"receive"	"y"
		"log"		"n"
		"oper"		"n"
		"syn_topic"	"n"
	}

	# Fill this list with the nick of the users
	# who WON'T BE relayed, as services bot
	variable users_excluded {\[Guru\] Pan}

	# Fill this list with the nick of the users
	# wich will be THE ONLY ONES to be relayed
	variable users_only {}

	# transmission configuration
	set trans_pub "y"; # transmit the pub
	set trans_act "y"; # transmit the actions (/me)
	set trans_nick "y"; # transmit the nick changement
	set trans_join "y"; # transmit the join
	set trans_part "y"; # transmit the part
	set trans_quit "y"; # transmit the quit
	set trans_topic "y"; # transmit the topic changements
	set trans_kick "y"; # transmit the kicks
	set trans_mode "y"; #transmit the mode changements
	set trans_who "y"; # transmit the who list

	# reception configuration
	set recv_pub "y"; # recept the pub
	set recv_act "y"; # recept the actions (/me)
	set recv_nick "y"; # recept the nick changement
	set recv_join "y"; # recept the join
	set recv_part "y"; # recept the part
	set recv_quit "y"; # recept the quit
	set recv_topic "y"; # recept the topic changements
	set recv_kick "y"; # recept the kicks
	set recv_mode "y"; # recept the mode changements
	set recv_who "y"; # recept the who list

	set userlist(beg) "Beginning of userlist"
	set userlist(end) "End of userlist"

	# Set the banmask to use in banning the IPs	 
	# Default banmask is set to 1
	# 1 - *!*@some.domain.com 
	# 2 - *!*@*.domain.com
	# 3 - *!*ident@some.domain.com
	# 4 - *!*ident@*.domain.com
	# 5 - *!*ident*@some.domain.com
	# 6 - *nick*!*@*.domain.com
	# 7 - *nick*!*@some.domain.com
	# 8 - nick!ident@some.domain.com
	# 9 - nick!ident@*.host.com
	set bantype 1

	# The default (ban)kick reason.
	# %n will be replaced with the kicker name
	set breason "You have been kicked by %n"

	# Path and name of the config file
	# %b will be replaced with the botnick
	variable config "logs/%b.chanrelay.db"

	variable author "CrazyCat"
	variable version "3.10"
}

####################################
#    DO NOT EDIT ANYTHING BELOW    #
####################################
proc ::crelay::init {args} {

	variable me
	array set me $::crelay::default
	array set me $::crelay::regg($::username)
	if { [file exists $::crelay::config] } {
		[namespace current]::preload
	}

	if { $me(transmit) == "y" } {
		bind msg o|o "trans" [namespace current]::set:trans
		if { $::crelay::trans_pub == "y" } { bind pubm - * [namespace current]::trans:pub }
		if { $::crelay::trans_act == "y" } { bind ctcp - "ACTION" [namespace current]::trans:act }
		if { $::crelay::trans_nick == "y" } { bind nick - * [namespace current]::trans:nick }
		if { $::crelay::trans_join == "y" } { bind join - * [namespace current]::trans:join }
		if { $::crelay::trans_part == "y" } { bind part - * [namespace current]::trans:part }
		if { $::crelay::trans_quit == "y" } {
			bind sign - * [namespace current]::trans:quit
			bind evnt - disconnect-server [namespace current]::trans:selfquit
		}
		if { $::crelay::trans_topic == "y" } { bind topc - * [namespace current]::trans:topic }
		if { $::crelay::trans_kick == "y" } { bind kick - * [namespace current]::trans:kick }
		if { $::crelay::trans_mode == "y" } { bind raw - "MODE" [namespace current]::trans:mode }
		if { $::crelay::trans_who == "y" } { bind pub - "!who" [namespace current]::trans:who }
		if { $me(oper) == "y" } {
			bind pub -|o "@topic" [namespace current]::trans:otopic
			bind pub -|o "@mode" [namespace current]::trans:omode
			bind pub -|o "@kick" [namespace current]::trans:okick
			bind pub -|o "@ban" [namespace current]::trans:oban
		}
	}

	if { $me(receive) =="y" } {
		bind msg o|o "recv" ::crelay::set:recv
		if { $::crelay::recv_pub == "y" } { bind bot - ">pub" [namespace current]::recv:pub }
		if { $::crelay::recv_act == "y" } { bind bot - ">act" [namespace current]::recv:act }
		if { $::crelay::recv_nick == "y" } { bind bot - ">nick" [namespace current]::recv:nick }
		if { $::crelay::recv_join == "y" } { bind bot - ">join" [namespace current]::recv:join }
		if { $::crelay::recv_part == "y" } { bind bot - ">part" [namespace current]::recv:part }
		if { $::crelay::recv_quit == "y" } { bind bot - ">quit" [namespace current]::recv:quit }
		if { $::crelay::recv_topic == "y" } { bind bot - ">topic" [namespace current]::recv:topic }
		if { $::crelay::recv_kick == "y" } { bind bot - ">kick" [namespace current]::recv:kick }
		if { $::crelay::recv_mode == "y" } { bind bot - ">mode" [namespace current]::recv:mode }
		if { $::crelay::recv_who == "y" } {
			bind bot - ">who" [namespace current]::recv:who
			bind bot - ">wholist" [namespace current]::recv:wholist
		}
		bind bot - ">otopic" [namespace current]::recv:otopic
		bind bot - ">omode" [namespace current]::recv:omode
		bind bot - ">okick" [namespace current]::recv:okick
		bind bot - ">oban" [namespace current]::recv:oban
		bind disc - * [namespace current]::recv:disc
		bind link - * [namespace current]::recv:link
	}

	[namespace current]::set:hl $me(highlight);

	if { $me(log) == "y"} {
		logfile sjpk $me(chan) "logs/[string range $me(chan) 1 end].log"
	}
	bind msg -|o "rc.status" [namespace current]::help:status
	bind msg -|o "rc.help" [namespace current]::help:cmds
	bind msg -|o "rc.light" [namespace current]::set:light
	bind msg -|o "rc.net" [namespace current]::set:snet
	bind msg -|o "rc.syntopic" [namespace current]::set:syn_topic
	bind bot - ">notop" [namespace current]::recv:error

	variable eggdrops
	variable chans
	variable networks
	foreach bot [array names [namespace current]::regg] {
	array set tmp $::crelay::regg($bot)
		lappend eggdrops $bot
		lappend chans $tmp(chan)
		lappend networks $tmp(network)
	}
	[namespace current]::save
	bind evnt -|- prerehash [namespace current]::deinit

	package forget ChanRelay
	package provide ChanRelay $::crelay::version
}

# Reads settings from a file
proc ::crelay::preload {args} {
	regsub -all %b $::crelay::config $::username fname
	if { [file exists $fname] } {
		set fp [open $fname r]
		set settings [read -nonewline $fp]
		close $fp
		foreach line [split $settings "\n"] {
			set lset [split $line "|"]
			switch [lindex $lset 0] {
				transmit { set [namespace current]::me(transmit) [lindex $lset 1] }
				receive { set [namespace current]::me(receive) [lindex $lset 1] }
				snet { set [namespace current]::me(snet) [lindex $lset 1] }
				highlight { set [namespace current]::me(highligt) [lindex $lset 1] }
				syn_topic { set [namespace current]::me(syn_topic) [lindex $lset 1] }
				default {
					set [namespace current]::[lindex $lset 0] [lindex $lset 1]
				}
			}
		}
	} else {
		[namespace current]::save
	}
}
# Save all settings in a file
proc ::crelay::save {args} {
	regsub -all %b $::crelay::config $::username fname
	set fp [open $fname w]
	puts $fp "transmit|$::crelay::me(transmit)"
	puts $fp "receive|$::crelay::me(receive)"
	puts $fp "snet|$::crelay::me(snet)"
	puts $fp "highlight|$::crelay::me(highlight)"
	puts $fp "trans_pub|$::crelay::trans_pub"
	puts $fp "trans_act|$::crelay::trans_act"
	puts $fp "trans_nick|$::crelay::trans_nick"
	puts $fp "trans_join|$::crelay::trans_join"
	puts $fp "trans_part|$::crelay::trans_part"
	puts $fp "trans_quit|$::crelay::trans_quit"
	puts $fp "trans_topic|$::crelay::trans_topic"
	puts $fp "trans_kick|$::crelay::trans_kick"
	puts $fp "trans_mode|$::crelay::trans_mode"
	puts $fp "trans_who|$::crelay::trans_who"
	puts $fp "recv_pub|$::crelay::recv_pub"
	puts $fp "recv_act|$::crelay::recv_act"
	puts $fp "recv_nick|$::crelay::recv_nick"
	puts $fp "recv_join|$::crelay::recv_join"
	puts $fp "recv_part|$::crelay::recv_part"
	puts $fp "recv_quit|$::crelay::recv_quit"
	puts $fp "recv_topic|$::crelay::recv_topic"
	puts $fp "recv_kick|$::crelay::recv_kick"
	puts $fp "recv_mode|$::crelay::recv_mode"
	puts $fp "recv_who|$::crelay::recv_who"
	puts $fp "syn_topic|$::crelay::me(syn_topic)"
	close $fp
}

proc ::crelay::deinit {args} {
	putlog "Starting unloading CHANRELAY $::crelay::version"
	[namespace current]::save
	putlog "Settings are saved in $::crelay::config"
	foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
		unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]
	}
	putlog "CHANRELAY $::crelay::version unloaded"
	package forget ChanRelay
	namespace delete [namespace current]
}

namespace eval crelay {
	variable hlnick
	variable snet
	variable syn_topic
	# Setting of hlnick
	proc set:light { nick uhost handle arg } {
		# message binding
		switch $arg {
			"bo" { [namespace current]::set:hl 1; }
			"un" { [namespace current]::set:hl 2; }
			"gr" { [namespace current]::set:hl 3; }
			"off" { [namespace current]::set:hl 0; }
			default { puthelp "NOTICE $nick :you must chose \002(bo)\002ld , \037(un)\037derline, \00314(gr)\003ay or (off)" }
		}
		[namespace current]::save
		return 0;
	}

	proc set:hl { arg } {
		# global hlnick setting function
		switch $arg {
			1 { set [namespace current]::hlnick "\002"; }
			2 { set [namespace current]::hlnick "\037"; }
			3 { set [namespace current]::hlnick "\00303"; }
			default { set [namespace current]::hlnick ""; }
		}
	}

	# Setting of show network
	proc set:snet {nick host handle arg } {
		if { $arg == "yes" } {
			set [namespace current]::snet "y"
			puthelp "NOTICE $nick :Network is now showed"
		} elseif { $arg == "no" } {
			set [namespace current]::snet "n"
			puthelp "NOTICE $nick :Network is now hidden"
		} else {
			puthelp "NOTICE $nick :you must chose yes or no"
			return 0
		}
		[namespace current]::save
	}

	proc set:syn_topic {nick host handle arg} {
		if { $arg == "yes" } {
			set [namespace current]::syn_topic "y"
			puthelp "NOTICE $nick :Topic synchro is now enabled"
		} elseif { $arg == "no" } {
			set [namespace current]::syn_topic "n"
			puthelp "NOTICE $nick :Topic synchro is now disabled"
		} else {
			puthelp "NOTICE $nick :you must choose yes or no"
			return 0
		}
	}

	# proc setting of transmission by msg
	proc set:trans { nick host handle arg } {
		if { $::crelay::me(transmit) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick trans help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick trans <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" { set type pubm }
					"act" { set type ctcp }
					"nick" { set type nick }
					"join" { set type join }
					"part" { set type part }
					"quit" { set type sign }
					"topic" { set type topc }
					"kick" { set type kick }
					"mode" { set type mode }
					"who" { set type who }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick trans help"
						return 0
					}
				}
				set proc_change "[namespace current]::trans:[lindex [split $arg] 0]"
				set mod_change "[namespace current]::trans_[lindex [split $arg] 0]"
				if { [lindex [split $arg] 1] eq "on" } {
				   if { $type eq "mode" } {
					  bind raw - "MODE" [namespace current]::trans:mode
				   } else {
					bind $type - * $proc_change
			   }
			   if { $type eq "sign"} {
				bind evnt - disconnect-server [namespace current]::trans:selfquit
				}
					set ${mod_change} "y"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] enabled"
				} elseif { [lindex [split $arg] 1] eq "off" } {
				   if { $type eq "mode" } {
					  unbind raw - "MODE" [namespace current]::trans:mode
				   } else {
					unbind $type - * $proc_change
				}
				if { $type eq "sign"} {
				unbind evnt - disconnect-server [namespace current]::trans:selfquit
				}
					set ${mod_change} "n"
					putserv "NOTICE $nick :Transmission of [lindex [split $arg] 0] disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :transmission is not activated, you can't change anything"
		}
		[namespace current]::save
	}

	# proc setting of reception by msg
	proc set:recv { nick host handle arg } {
		if { $::crelay::me(receive) == "y" } {
			if { $arg == "" } {
				putquick "NOTICE $nick :you'd better try /msg $::botnick recv help"
			}
			if { [lindex [split $arg] 0] == "help" } {
				putquick "NOTICE $nick :usage is /msg $::botnick recv <value> on|off"
				putquick "NOTICE $nick :with <value> = pub, act, nick, join, part, quit, topic, kick, mode, who"
				return 0
			} else {
				switch [lindex [split $arg] 0] {
					"pub" -
					"act" -
					"nick" -
					"join" -
					"part" -
					"quit" -
					"topic" -
					"kick" -
					"mode" -
					"who" { set type [lindex [split $arg] 0] }
					default {
						putquick "NOTICE $nick :Bad mode. Try /msg $::botnick recv help"
						return 0
					}
				}
				set change ">$type"
				set proc_change "[namespace current]::recv:$type"
				set mod_change "[namespace current]::recv_$type"
				if { [lindex [split $arg] 1] eq "on" } {
					bind bot - $change $proc_change
					set ${mod_change} "y"
					putserv "NOTICE $nick :Reception of $type enabled"
				} elseif { [lindex [split $arg] 1] == "off" } {
					unbind bot - $change $proc_change
					set ${mod_change} "n"
					putserv "NOTICE $nick :Reception of $type disabled"
				} else {
					putquick "NOTICE $nick :[lindex [split $arg] 1] is not a correct value, choose \002on\002 or \002off\002"
				}
			}
		} else {
			putquick "NOTICE $nick :reception is not activated, you can't change anything"
		}
		[namespace current]::save
	}
	
	# Generates an user@network name
	# based on nick and from bot
	proc make:user { nick frm_bot } {
		if {[string length $::crelay::hlnick] > 0 } {
			set ehlnick [string index $::crelay::hlnick 0]
		} else {
			set ehlnick ""
		}
		array set him $::crelay::regg($frm_bot)
		if {$nick == "*"} {
			set speaker [concat "$::crelay::hlnick$him(network)$ehlnick"]
		} else {
			if { $::crelay::me(snet) == "y" } {
				set speaker [concat "$::crelay::hlnick\($nick@$him(network)\)$ehlnick"]
			} else {
				set speaker $::crelay::hlnick$nick$ehlnick
			}
		}
		return $speaker
	}
	
	# Logs virtual channel activity 
	proc cr:log { lev chan line } {
		if { $::crelay::me(log) == "y" } {
			putloglev $lev "$chan" "$line"
		}
		return 0
	}
	
	# Global transmit procedure
	proc trans:bot { usercmd chan usernick text } {
	   if {[llength $::crelay::users_only]>0 && [lsearch -nocase $::crelay::users_only $usernick]==-1} {
		  return 0
	   }
	   if {[llength $::crelay::users_excluded]>0 && [lsearch -nocase $::crelay::users_excluded $usernick]!=-1} {
		  return 0
	   }
		set transmsg [concat $usercmd $usernick $text]
		set ::crelay::eob 0
		if {$chan == $::crelay::me(chan)} {
			foreach bot [array names [namespace current]::regg] {
				if {$bot != $::botnick && [islinked $bot]} {
					putbot $bot $transmsg
					if {$usercmd == ">who" } { incr [namespace current]::eob }
				}
			}
		} else {
			return 0
		}
	}

	# proc transmission of pub (trans_pub = y)
	proc trans:pub {nick uhost hand chan text} {
		if { [string tolower [lindex [split $text] 0]] == "!who" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@topic" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@mode" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@ban" } { return 0; }
		if { [string tolower [lindex [split $text] 0]] == "@kick" } { return 0; }
		[namespace current]::trans:bot ">pub" $chan $nick [join [split $text]]
	}
	
	# proc transmission of action (trans_act = y)
	proc trans:act {nick uhost hand chan key text} {
		set arg [concat $key $text]
		[namespace current]::trans:bot ">act" $chan $nick $arg
	}
	
	# proc transmission of nick changement
	proc trans:nick {nick uhost hand chan newnick} {
		[namespace current]::trans:bot ">nick" $chan $nick $newnick
	}
	
	# proc transmission of join
	proc trans:join {nick uhost hand chan} {
		[namespace current]::trans:bot ">join" $chan $chan $nick
	}
	
	# proc transmission of part
	proc trans:part {nick uhost hand chan text} {
		set arg [concat $chan $text]
		[namespace current]::trans:bot ">part" $chan $nick $arg
	}
	
	# proc transmission of quit
	proc trans:quit {nick host hand chan text} {
		[namespace current]::trans:bot ">quit" $chan $nick $text
	}
	
	# Proc to get our self quit
	proc trans:selfquit {type} {
		[namespace current]::trans:bot ">quit" $::crelay::me(chan) $::botnick "I don't know why but I left server"
	}
	
	# proc transmission of topic changement
	proc trans:topic {nick uhost hand chan topic} {
		set arg [concat $chan $topic]
		[namespace current]::trans:bot ">topic" $chan $nick $arg
	}
	
	# proc transmission of kick
	proc trans:kick {nick uhost hand chan victim reason} {
		set arg [concat $victim $chan $reason]
		[namespace current]::trans:bot ">kick" $chan $nick $arg
	}
	
	# proc transmission of mode changement
	proc trans:mode {from keyw text} {
	  set nick [lindex [split $from !] 0]
	  set chan [lindex [split $text] 0]
	  set text [concat $nick $text]
		[namespace current]::trans:bot ">mode" $chan $nick $text
	}
	
	# proc transmission of "who command"
	proc trans:who {nick uhost handle chan args} {
		if { [join [lindex [split $args] 0]] != "" } {
			set netindex [lsearch -nocase $::crelay::networks [lindex [split $args] 0]]
			if { $netindex == -1 } {
				putserv "PRIVMSG $nick :$args est un réseau inconnu";
				return 0
			} else {
			   set [namespace current]::eol 0
			   set [namespace current]::bol 0
					set [namespace current]::eob 1
				putbot [lindex $::crelay::eggdrops $netindex] ">who $nick"
			}
		} else {
			set [namespace current]::eol 0
			set [namespace current]::bol 0
			[namespace current]::trans:bot ">who" $chan $nick ""
		}
	}
	
	# Error reception
	proc recv:error {frm_bot command arg} {
		# putlog "$command - $arg"
		return 0
	}
	
	# proc reception of pub
	proc recv:pub {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :$speaker [join [lrange $argl 1 end]]"
			[namespace current]::cr:log p "$::crelay::me(chan)" "<[lindex $argl 0]> [join [lrange $argl 1 end]]"
		}
		return 0
	}
	
	# proc reception of action
	proc recv:act {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :* $speaker [join [lrange $argl 2 end]]"
			[namespace current]::cr:log p "$::crelay::me(chan)" "Action: [lindex $argl 0] [join [lrange $argl 2 end]]"
		}
		return 0
	}
	
	# proc reception of nick changement
	proc recv:nick {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** $speaker is now known as [join [lrange $argl 1 end]]"
			[namespace current]::cr:log j "$::crelay::me(chan)" "Nick change: [lindex $argl 0] -> [join [lrange $argl 1 end]]"
		}
		return 0
	}
	
	# proc reception of join
	proc recv:join {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :--> $speaker has joined channel [lindex $argl 0]"
			[namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 1] joined $::crelay::me(chan)."
		}
		return 0
	}
	
	# proc reception of part
	proc recv:part {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :<-- $speaker has left channel [lindex $argl 1] ([join [lrange $argl 2 end]])"
			[namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left $::crelay::me(chan) ([join [lrange $argl 2 end]])"
		}
		return 0
	}
	
	# proc reception of quit
	proc recv:quit {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :-//- $speaker has quit ([join [lrange $argl 1 end]])"
			[namespace current]::cr:log j "$::crelay::me(chan)" "[lindex $argl 0] left irc: [join [lrange $argl 1 end]]"
		}
		return 0
	}
	
	# proc reception of topic changement
	proc recv:topic {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 0] $frm_bot]
			if { $::crelay::me(syn_topic) == "y" } {
				putserv "TOPIC $::crelay::me(chan) :[join [lrange $argl 2 end]]"
			} else {
				putquick "PRIVMSG $::crelay::me(chan) :*** $speaker changes topic of [lindex $argl 1] to '[join [lrange $argl 2 end]]'"
			}
		}
		return 0
	}
	
	# proc reception of kick
	proc recv:kick {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** $speaker has been kicked from [lindex $argl 2] by [lindex $argl 0]: [join [lrange $argl 3 end]]"
			[namespace current]::cr:log k "$::crelay::me(chan)" "[lindex $argl 1] kicked from $::crelay::me(chan) by [lindex $argl 0]:[join [lrange $argl 3 end]]"
		}
		return 0
	}
	
	# proc reception of mode changement
	proc recv:mode {frm_bot command arg} {
		if {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set argl [split $arg]
			set speaker [[namespace current]::make:user [lindex $argl 1] $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** $speaker set mode [join [lrange $argl 2 end]]"
		}
		return 0
	}
	
	# reception of !who command
	proc recv:who {frm_bot command arg} {
		set nick $arg
		set ulist ""
		set cusr 0
		if {![botonchan $::crelay::me(chan)]} {
			putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
			return 0
		}
		foreach user [chanlist $::crelay::me(chan)] {
			if { $user == $::botnick } { continue; }
			if { [isop $user $::crelay::me(chan)] == 1 } {
				set st "@"
			} elseif { [ishalfop $user $::crelay::me(chan)] == 1 } {
				set st "%"
			} elseif { [isvoice $user $::crelay::me(chan)] == 1 } {
				set st "%"
			} else {
				set st ""
			}
			incr cusr 1
			append ulist " $st$user"
			if { $cusr == 5 } {
				putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
				set ulist ""
				set cusr 0
			}
		}
		if { $ulist != "" } {
			putbot $frm_bot ">wholist $::crelay::me(chan) $nick $ulist"
		}
		putbot $frm_bot ">wholist $::crelay::me(chan) $nick eol"
	}
	
	# Proc reception of a who list
	proc recv:wholist {frm_bot command arg} {
		set nick [join [lindex [split $arg] 1]]
		set speaker [[namespace current]::make:user $frm_bot $frm_bot]
		if {$::crelay::bol == 0} {
			incr [namespace current]::bol
			putserv "NOTICE $nick :*** $::crelay::userlist(beg)"
		}
		if { [join [lrange [split $arg] 2 end]] == "eol"} {
			incr [namespace current]::eol
			if {$::crelay::eol == $::crelay::eob} {
				putserv "NOTICE $nick :*** $::crelay::userlist(end)"
			}
		} else {
			putserv "NOTICE $nick :$speaker [join [lrange [split $arg] 2 end]]"
		}
	}
	
	######################################
	# Operators commands
	#
	proc trans:otopic {nick uhost handle chan text} {
		set netindex [[namespace current]::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @topic <network|all> the new topic"
			return 0
		}
		set topic [join [lrange [split $text] 1 end]]
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">otopic $nick $topic"
		} else {
			[namespace current]::trans:bot ">otopic" $chan $nick $topic
			putserv "TOPIC $::crelay::me(chan) :$topic"
		}
		return 0
	}
	
	proc recv:otopic {frm_bot command arg} {
		set nick [join [lindex [split $arg] 0]]
		if { $::crelay::reg($frm_bot)(oper) != "y" } { return 0; }
		if { ![[namespace current]::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		putserv "TOPIC $::crelay::me(chan) :[join [lrange [split $arg] 1 end]]"
		return 0
	}
	
	proc trans:omode {nick uhost handle chan text} {
		set netindex [[namespace current]::checkDest [join [lindex [split $text] 0]]]
		if { $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @mode <network|all> <+/-mode> [arg][,<+/-mode> [arg]...]"
			return 0
		}
		set mode [join [lrange [split $text] 1 end]]
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">omode $nick $mode"
		} else {
			[namespace current]::trans:bot ">omode" $chan $nick $mode
			foreach m [split $mode ","] { pushmode $::crelay::me(chan) $m }
			flushmode $::crelay::me(chan)
		}
		return 0
	}
	
	proc recv:omode {frm_bot command arg} {
	   array set him $::crelay::regg($frm_bot)
		set nick [join [lindex [split $arg] 0]]
		if { $him(oper) != "y" } { return 0; }
		if { ![[namespace current]::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		foreach mode [split [join [lrange [split $arg] 1 end]] ","] {
			catch { pushmode $::crelay::me(chan) $mode }
		}
		flushmode $::crelay::me(chan)
		return 0
	}
	
	proc trans:okick {nick uhost handle chan text} {
		set netindex [[namespace current]::checkDest [join [lindex [split $text] 0]]]
		set vict [join [lindex [split $text] 1]]
		set reason [join [lrange [split $text] 2 end]]
		if { $vict eq "" || $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @kick <operpass> <network|all> nick \[reason of kickin\]"
			return 0
		}
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">okick $chan $nick $vict $reason"
		} else {
			[namespace current]::trans:bot ">okick" $chan $nick [concat $vict $reason]
		}
		return 0
	}
	
	proc recv:okick {frm_bot command arg} {
	   array set him $::crelay::regg($frm_bot)
	   set nick [join [lindex [split $arg] 1]]
	   if { $him(oper) != "y" } { return 0; }
		if { ![[namespace current]::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		set vict [join [lindex [split $arg] 2]]
		if {![onchan $vict $::crelay::me(chan)]} {
		   putbot $frm_bot ">notop $::crelay::me(chan) $nick"
		}
		set reason [join [lrange [split $arg] 2 end]]
		if { $reason eq "" } { regsub -all %n $::crelay::breason $nick reason }
		putkick $::crelay::me(chan) $vict $reason
	   return 0
	}
	
	proc trans:oban {nick uhost handle chan text} {
		set netindex [[namespace current]::checkDest [join [lindex [split $text] 0]]]
		set vict [join [lindex [split $text] 1]]
		set reason [join [lrange [split $text] 2 end]]
		if { $vict eq "" || $netindex == -1 } {
			putserv "NOTICE $nick :Syntaxe is @ban <operpass> <network|all> nick \[reason of banning\]"
			return 0
		}
		if { $netindex < 99 } {
			putbot [lindex $::crelay::eggdrops $netindex] ">oban $chan $nick $vict $reason"
		} else {
			[namespace current]::trans:bot ">oban" $chan $nick [concat $vict $reason]
		}
		return 0
	}
	
	proc recv:oban {frm_bot command arg} {
	   array set him $::crelay::regg($frm_bot)
		set nick [join [lindex [split $arg] 1]]
		if { $him(oper) != "y" } { return 0; }
		if { ![[namespace current]::hasRights $::crelay::me(chan)] } {
			putbot $frm_bot ">notop $::crelay::me(chan) $nick"
			return 0
		}
		set vict [join [lindex [split $arg] 2]]
		if {![onchan $vict $::crelay::me(chan)]} {
		   putbot $frm_bot ">notop $::crelay::me(chan) $nick"
		}
		set reason [join [lrange [split $arg] 3 end]]
		if { $reason eq "" } { regsub -all %n $::crelay::breason $nick reason }
		set bmask [[namespace current]::mask [getchanhost $vict $::crelay::me(chan)] $vict]
		pushmode $::crelay::me(chan) +b $bmask
		putkick $::crelay::me(chan) $vict $reason
		flushmode $::crelay::me(chan)
		return 0
	}
	
	# Special : botnet lost
	proc recv:disc {frm_bot} {
		if {$frm_bot == $::username} {
			putquick "PRIVMSG $::crelay::me(chan) :I'd left the relay"
		} elseif {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set speaker [[namespace current]::make:user "*" $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** We lose $speaker ($frm_bot leaves botnet)"
		}
		return 0
	}
	
	# Special : botnet recover
	proc recv:link {frm_bot via} {
		if {$frm_bot == $::username} {
			putquick "PRIVMSG $::crelay::me(chan) :I'm back in the relay"
		} elseif {[set him [lsearch $::crelay::eggdrops $frm_bot]] >= 0} {
			set speaker [[namespace current]::make:user "*" $frm_bot]
			putquick "PRIVMSG $::crelay::me(chan) :*** $speaker is back ($frm_bot rejoined botnet)"
		}
		return 0
	}
	
	######################################
	# Private messaging
	#
	
	bind msg - "say" [namespace current]::prv:say_send
	proc prv:say_send {nick uhost handle text} {
		if {[lsearch [package names] "MDS"] >= 0 } {
			[namespace current]::priv_sendmsg $nick $uhost $handle $text
			return 0
		}
		set dest [join [lindex [split $text] 0]]
		set msg [join [lrange [split $text] 1 end]]
		set vict [join [lindex [split $dest @] 0]]
		set net [join [lindex [split $dest @] 1]]
		if { $vict == "" || $net == "" } {
			putserv "PRIVMSG $nick :Use \002say user@network your message to \037user\037\002";
			return 0
		}
		set him [lsearch -nocase $::crelay::networks $net]
		if { $him == -1 } {
			putserv "PRIVMSG $nick :I don't know any network called $net.";
			putserv "PRIVMSG $nick :Available networks: [join [split $::crelay::networks]]"
			return 0
		}
		if { [string length $msg] == 0 } {
			putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
			return 0
		}
		putbot [lindex $::crelay::eggdrops $him] ">pvmsg $vict $nick@$::crelay::me(network) $msg"
	}
	
	bind bot - ">pvmsg" [namespace current]::prv:say_get
	proc prv:say_get {frm_bot command arg} {
		set dest [join [lindex [split $arg] 0]]
		set from [join [lindex [split $arg] 1]]
		set msg [join [lrange [split $arg] 2 end]]
		if { [onchan $dest $::crelay::me(chan)] == 1 } {
			putserv "PRIVMSG $dest :$from: $msg"
		}
	}

	# Addition of MDS interception
	proc priv_sendmsg {nick host hand text} {
		[namespace current]::pub_sendmsg $nick $host $hand $::crelay::me(chan) $text
	}
	
	proc pub_sendmsg {nick host hand chan arg} {
		set dest [join [lindex [split $arg] 0]]
		set vict [join [lindex [split $dest @] 0]]
		set net [join [lindex [split $dest @] 1]]
		set msg [join [lrange [split $arg] 1 end]]
		if { $vict == "" } {
			putserv "PRIVMSG $nick :Use \002$MDS::pub_msg_cmd user[@network] your message to \037user\037\002";
			putserv "PRIVMSG $nick :If network is not filled, all networks will receive it";
			return 0
		}
		if { [string length $msg] == 0 } {
			putserv "PRIVMSG $nick :Did you forget your message to $vict@$net ?";
			return 0
		}
		if { ($net eq "") || ([lsearch -nocase $::crelay::networks $net] == -1)} {
			putallbots ">mds $vict $nick@$::crelay::me(network) $msg"
			send_msg_to dest $vict "crelay" $msg
		} else {
			set him [lsearch -nocase $::crelay::networks $net]
			if {[lindex $::crelay::eggdrops $him] eq $::username} {
				send_msg_to dest $vict "crelay" $msg
			} else {
				putbot [lindex $::crelay::eggdrops $him] ">mds $vict $nick@$::crelay::me(network) $msg"
			}
		}
		return 0
	}
	
	proc recv:mds {frm_bot command arg} {
		set dest [join [lindex [split $arg] 0]]
		set from [join [lindex [split $arg] 1]]
		set msg [join [lrange [split $arg] 2 end]]
		if { [onchan $dest $::crelay::me(chan)] == 1 } {
			putserv "PRIVMSG $dest :$from: $msg"
		} else {
			send_msg_to dest "crelay" $msg
		}
	}
	
	######################################
	# Small tools
	#
	proc checkDest { network } {
		set netindex [lsearch -nocase $::crelay::networks $network]
		if { $network ne "all" && $netindex == -1 } { return -1 }
		if { $network eq "all" } { return 99 }
		return $netindex
	}
	
	proc hasRights { chan } {
		if { ![botisop $chan] && ![botishalfop $chan] } {
			return 0
		}
		return 1
	}
	
	proc mask {uhost nick} {
		switch -- $::crelay::bantype {
			1 { set mask "*!*@[lindex [split $uhost @] 1]" }
			2 { set mask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
			3 { set mask "*!*$uhost" }
			4 { set mask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
			5 { set mask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
			6 { set mask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
			7 { set mask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
			8 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
			9 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
			default { set mask "*!*@[lindex [split $uhost @] 1]" }
		}
		return $mask
	  }
	
	######################################
	# proc for helping
	#
	# proc status
	proc help:status { nick host handle arg } {
		puthelp "PRIVMSG $nick :Chanrelay status for $::crelay::me(chan)@$crelay::me(network)"
		puthelp "PRIVMSG $nick :\002 Global status\002"
		puthelp "PRIVMSG $nick :\037type\037   -- | trans -|- recept |"
		puthelp "PRIVMSG $nick :global -- | -- $::crelay::me(transmit) -- | -- $::crelay::me(receive) -- |"
		puthelp "PRIVMSG $nick :pub    -- | -- $::crelay::trans_pub -- | -- $::crelay::recv_pub -- |"
		puthelp "PRIVMSG $nick :act    -- | -- $::crelay::trans_act -- | -- $::crelay::recv_act -- |"
		puthelp "PRIVMSG $nick :nick   -- | -- $::crelay::trans_nick -- | -- $::crelay::recv_nick -- |"
		puthelp "PRIVMSG $nick :join   -- | -- $::crelay::trans_join -- | -- $::crelay::recv_join -- |"
		puthelp "PRIVMSG $nick :part   -- | -- $::crelay::trans_part -- | -- $::crelay::recv_part -- |"
		puthelp "PRIVMSG $nick :quit   -- | -- $::crelay::trans_quit -- | -- $::crelay::recv_quit -- |"
		puthelp "PRIVMSG $nick :topic  -- | -- $::crelay::trans_topic -- | -- $::crelay::recv_topic -- |"
		puthelp "PRIVMSG $nick :kick   -- | -- $::crelay::trans_kick -- | -- $::crelay::recv_kick -- |"
		puthelp "PRIVMSG $nick :mode   -- | -- $::crelay::trans_mode -- | -- $::crelay::recv_mode -- |"
		puthelp "PRIVMSG $nick :who    -- | -- $::crelay::trans_who -- | -- $::crelay::recv_who -- |"
		if { $::crelay::syn_topic == "y"} {
			puthelp "PRIVMSG $nick :Topic synchronisation is enable"
		} else {
			puthelp "PRIVMSG $nick :Topic synchronisation is disable"
		}
		puthelp "PRIVMSG $nick :nicks appears as $::crelay::hlnick$nick$::crelay::hlnick"
		puthelp "PRIVMSG $nick :\002 END of STATUS"
	}
		
	# proc help
	proc help:cmds { nick host handle arg } {
		puthelp "NOTICE $nick :/msg $::botnick trans <type> on|off to change the transmissions"
		puthelp "NOTICE $nick :/msg $::botnick recv <type> on|off to change the receptions"
		puthelp "NOTICE $nick :/msg $::botnick rc.status to see my actual status"
		puthelp "NOTICE $nick :/msg $::botnick rc.help for this help"
		puthelp "NOTICE $nick :/msg $::botnick rc.light <bo|un|off> to bold, underline or no higlight"
		puthelp "NOTICE $nick :/msg $::botnick rc.net <yes|no> to show the network"
		puthelp "NOTICE $nick :/msg $::botnick rc.syntopic <yes|no> to enable the topic synchronisation"
	}
	
}

::crelay::init

putlog "CHANRELAY $::crelay::version by \002$::crelay::author\002 loaded - http://www.eggdrop.fr"
