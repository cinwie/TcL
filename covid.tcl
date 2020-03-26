#######################################################################################################
## Covid19.tcl 1.2  (19/03/2020)  			  Copyright 2008 - 2020 @ WwW.TCLScripts.NET ##
##                        _   _   _   _   _   _   _   _   _   _   _   _   _   _                      ##
##                       / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \                     ##
##                      ( T | C | L | S | C | R | I | P | T | S | . | N | E | T )                    ##
##                       \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/                     ##
##                                                                                                   ##
##                                      ® BLaCkShaDoW Production ®                                   ##
##                                                                                                   ##
##                                              PRESENTS                                             ##
##									                           ® ##
############################################  Covid-19 TCL   ##########################################
##									                             ##
##  DESCRIPTION: 							                             ##
## Shows realtime stats about the COVID-19 CORONAVIRUS OUTBREAK. These are taken from the site       ##
##  												     ##
##  https://www.worldometers.info/coronavirus/ by command and also auto if something changes from    ##
##												     ##
## the last information given. (RSS type)						             ##
##			                            						     ##
##  Tested on Eggdrop v1.8.3 (Debian Linux 3.16.0-4-amd64) Tcl version: 8.6.10                       ##
##									                             ##
#######################################################################################################
##									                             ##
##                                 /===============================\                                 ##
##                                 |      This Space For Rent      |                                 ##
##                                 \===============================/                                 ##
##									                             ##
#######################################################################################################
##									                             ##
##  INSTALLATION: 							                             ##
##     ++ http package is REQUIRED for this script to work.                           		     ##
##     ++ tls package is REQUIRED for this script to work. (1.7.18-2 or later)                       ##
##  latest tls https://ubuntu.pkgs.org/19.10/ubuntu-universe-amd64/tcl-tls_1.7.18-2_amd64.deb.html   ##
##     ++ Edit the Covid19.tcl script and place it into your /scripts directory,                     ##
##     ++ add "source scripts/Covid19.tcl" to your eggdrop config and rehash the bot.                ##
##									                             ##
#######################################################################################################
#######################################################################################################
##									                             ##
##  OFFICIAL LINKS:                                                                                  ##
##   E-mail      : BLaCkShaDoW[at]tclscripts.net                                                     ##
##   Bugs report : http://www.tclscripts.net                                                         ##
##   GitHub page : https://github.com/tclscripts/ 			                             ##
##   Online help : irc://irc.undernet.org/tcl-help                                                   ##
##                 #TCL-HELP / UnderNet        	                                                     ##
##                 You can ask in english or romanian                                                ##
##									                             ##
##     paypal.me/DanielVoipan = Please consider a donation. Thanks!                                  ##
##									                             ##
#######################################################################################################
##									                             ##
##                           You want a customised TCL Script for your eggdrop?                      ##
##                                Easy-peasy, just tell me what you need!                            ##
##                I can create almost anything in TCL based on your ideas and donations.             ##
##                  Email blackshadow@tclscripts.net or info@tclscripts.net with your                ##
##                    request informations and I'll contact you as soon as possible.                 ##
##									                             ##
#######################################################################################################
##												     ##
##  Version 1.1 -- If country isnt specificed it will show the total statistics		     	     ##
##									                             ##
##  Commmands: !Covid [country] - if not specified it will show the total statistics                 ##
##											             ##
##                                                                                                   ##
##  Settings: .chanset/.set #chan +covid - enable the !covid <city> command                          ##
##            							                                     ##
##                                                                                                   ##
##            .chanset/.set #chan +autocovid - enable the auto message on timer if the               ##
##             information changes (like RSS feed)		                                     ##
##           											     ##
##            .chanset/.set #chan covid-country [your country] - setup the default country           ##
##            for the Covid19 RSS (auto show information)					     ##
##												     ##	
##            .chanset/.set #chan covid-lang Ro/En - setup the default language for the script       ##
##												     ##
#######################################################################################################
#######################################################################################################
##									                             ##
##  LICENSE:                                                                                         ##
##   This code comes with ABSOLUTELY NO WARRANTY.                                                    ##
##                                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under the terms of      ##
##   the GNU General Public License version 3 as published by the Free Software Foundation.          ##
##                                                                                                   ##
##   This program is distributed WITHOUT ANY WARRANTY; without even the implied warranty of          ##
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                                            ##
##   USE AT YOUR OWN RISK.                                                                           ##
##                                                                                                   ##
##   See the GNU General Public License for more details.                                            ##
##        (http://www.gnu.org/copyleft/library.txt)                                                  ##
##                                                                                                   ##
##  			          Copyright 2008 - 2018 @ WwW.TCLScripts.NET                         ##
##                                                                                                   ##
#######################################################################################################
#######################################################################################################
##                                   CONFIGURATION FOR Covid19.TCL                                   ##
#######################################################################################################


###
#Default country for corona virus checking uppon command or timer
#put "GLOBAL" for total stats
#
set corona(country) "GLOBAL"

###
#Set script language (Ro/EN)
#
set corona(language) "en"


###
#Flags required to use !covid [country] command
#
set corona(flags) "-|-"


###
# FLOOD PROTECTION
#Set the number of minute(s) to ignore flooders
###
set corona(ignore_prot) "1"

###
# FLOOD PROTECTION
#Set the number of requests within specifide number of seconds to trigger flood protection.
# By default, 4:10, which allows for upto 3 queries in 10 seconds. 4 or more quries in 10 seconds would cuase
# the forth and later queries to be ignored for the amount of time specifide above.
###
set corona(flood_prot) "3:10"

###
#COVID RSS (minutes)
#Set here the time for the script to check if the info changed 
#If the info changed it will be shown on chan
#only when the option is enabled with +autocovid
###
set corona(time_check) "15"

########################################################################################################

#Country list

set corona(country_list) {
"China"
"Italy"
"Iran"
"Spain"
"S. Korea"
"Germany"
"France"
"USA"
"Switzerland"
"UK"
"Netherlands"
"Norway"
"Belgium"
"Austria"
"Sweden"
"Denmark"
"Japan"
"Diamond Princess"
"Malaysia"
"Australia"
"Canada"
"Qatar"
"Czechia"
"Greece"
"Portugal"
"Israel"
"Finland"
"Slovenia"
"Singapore"
"Bahrain"
"Brazil"
"Estonia"
"Ireland"
"Poland"
"Iceland"
"Pakistan"
"Philippines"
"Romania"
"Thailand"
"Indonesia"
"Egypt"
"Hong Kong"
"Chile"
"Iraq"
"Luxembourg"
"Saudi Arabia"
"Kuwait"
"India"
"Lebanon"
"San Marino"
"UAE"
"Russia"
"Peru"
"Mexico"
"Taiwan"
"Slovakia"
"Panama"
"Bulgaria"
"Argentina"
"Croatia"
"Serbia"
"Armenia"
"South Africa"
"Vietnam"
"Algeria"
"Ecuador"
"Colombia"
"Brunei"
"Albania"
"Hungary"
"Latvia"
"Faeroe Islands"
"Turkey"
"Cyprus"
"Costa Rica"
"Palestine"
"Morocco"
"Malta"
"Belarus"
"Jordan"
"Georgia"
"Venezuela"
"Kazakhstan"
"Sri Lanka"
"Moldova"
"Uruguay"
"Azerbaijan"
"Senegal"
"Bosnia and"
"Cambodia"
"North Macedonia"
"Oman"
"Tunisia"
"Afghanistan"
"Dominican Republic"
"Lithuania"
"Martinique"
"Burkina Faso"
"Andorra"
"Maldives"
"Macao"
"New Zealand"
"Jamaica"
"Bolivia"
"French Guiana"
"Bangladesh"
"Cameroon"
"Uzbekistan"
"Monaco"
"Paraguay"
"Réunion"
"Guatemala"
"Honduras"
"Guyana"
"Ukraine"
"Liechtenstein"
"Rwanda"
"Channel Islands"
"Ghana"
"Guadeloupe"
"Cuba"
"Ethiopia"
"Guam"
"Puerto Rico"
"Trinidad and"
"Ivory Coast"
"Mongolia"
"Seychelles"
"Nigeria"
"Aruba"
"DRC"
"French Polynesia"
"Gibraltar"
"Kenya"
"St. Barth"
"Curaçao"
"Liberia"
"Namibia"
"Saint Lucia"
"Saint Martin"
"U.S. Virgin"
"Cayman Islands"
"Sudan"
"Nepal"
"Antigua and"
"Bahamas"
"Benin"
"Bhutan"
"CAR"
"Congo"
"Equatorial Guinea"
"Gabon"
"Greenland"
"Guinea"
"Vatican City"
"Mauritania"
"Mayotte"
"St. Vincent"
"Somalia"
"Suriname"
"Eswatini"
"Tanzania"
"Togo"
}

set corona(cl) {
"China"
"Italy"
"Iran"
"Spain"
"S. Korea"
"Germany"
"France"
"USA"
"Switzerland"
"UK"
"Netherlands"
"Norway"
"Belgium"
"Austria"
"Sweden"
"Denmark"
"Japan"
"Diamond Princess"
"Malaysia"
"Australia"
"Canada"
"Qatar"
"Czechia"
"Greece"
"Portugal"
"Israel"
"Finland"
"Slovenia"
"Singapore"
"Bahrain"
"Brazil"
"Estonia"
"Ireland"
"Poland"
"Iceland"
"Pakistan"
"Philippines"
"Romania"
"Thailand"
"Indonesia"
"Egypt"
"Hong Kong"
"Chile"
"Iraq"
"Luxembourg"
"Saudi Arabia"
"Kuwait"
"India"
"Lebanon"
"San Marino"
"UAE"
"Russia"
"Peru"
"Mexico"
"Taiwan"
"Slovakia"
"Panama"
"Bulgaria"
"Argentina"
"Croatia"
"Serbia"
"Armenia"
"South Africa"
"Vietnam"
"Algeria"
"Ecuador"
"Colombia"
"Brunei"
"Albania"
"Hungary"
"Latvia"
"Faeroe Islands"
"Turkey"
"Cyprus"
"Costa Rica"
"Palestine"
"Morocco"
"Malta"
"Belarus"
"Jordan"
"Georgia"
"Venezuela"
"Kazakhstan"
"Sri Lanka"
"Moldova"
"Uruguay"
"Azerbaijan"
"Senegal"
"Bosnia and"
"Cambodia"
"North Macedonia"
"Oman"
"Tunisia"
"Afghanistan"
"Dominican Republic"
"Lithuania"
"Martinique"
"Burkina Faso"
"Andorra"
"Maldives"
"Macao"
"New Zealand"
"Jamaica"
"Bolivia"
"French Guiana"
"Bangladesh"
"Cameroon"
"Uzbekistan"
"Monaco"
"Paraguay"
"Réunion"
"Guatemala"
"Honduras"
"Guyana"
"Ukraine"
"Liechtenstein"
"Rwanda"
"Channel Islands"
"Ghana"
"Guadeloupe"
"Cuba"
"Ethiopia"
"Guam"
"Puerto Rico"
"Trinidad and"
"Ivory Coast"
"Mongolia"
"Seychelles"
"Nigeria"
"Aruba"
"DRC"
"French Polynesia"
"Gibraltar"
"Kenya"
"St. Barth"
"Curaçao"
"Liberia"
"Namibia"
"Saint Lucia"
"Saint Martin"
"U.S. Virgin"
"Cayman Islands"
"Sudan"
"Nepal"
"Antigua and"
"Bahamas"
"Benin"
"Bhutan"
"CAR"
"Congo"
"Equatorial Guinea"
"Gabon"
"Greenland"
"Guinea"
"Vatican City"
"Mauritania"
"Mayotte"
"St. Vincent"
"Somalia"
"Suriname"
"Eswatini"
"Tanzania"
"Togo"
}

###############################################################################################################
#
#			Try to edit only the language :-)
#
###############################################################################################################

package require tls
package require http

bind pub $corona(flags) !covid corona:pub

setudef flag covid
setudef flag autocovid

setudef str covid-country
setudef str covid-lang


###
if {![info exists corona(timer_start)]} {
	timer $corona(time_check) corona:auto_timer
	set corona(timer_start) 1
}

###
proc corona:auto_timer {} {
	global corona
	set channels ""
foreach chan [channels] {
	if {[channel get $chan autocovid] && [validchan $chan]} {
	lappend channels $chan
		}
	}
if {$channels != ""} {
	set data [corona:getdata]
	corona:auto_check $data $channels 0
	} else {
	timer $corona(time_check) corona:auto_timer
	}
}

###
proc corona:auto_check {data channels num} {
	global corona
	set chan [lindex $channels $num]
	set country [join [channel get $chan covid-country]]
#if {$country == ""} { set country $corona(country) }
if {$country == ""} { set country [lindex $corona(cl) [rand [llength $corona(cl)]]] }
if {[string tolower $country] == "global"} {
	set total 1
} else { set total 0 }
	set extract [corona:extract $data $country $total]
	set total_cases [lindex $extract 0]
	set new_cases [lindex $extract 1]
	set total_deaths [lindex $extract 2]
	set new_deaths [lindex $extract 3]
	set total_recovered [lindex $extract 4]
	set active_cases [lindex $extract 5]
	set serious_critical [lindex $extract 6]
	set totalcases_per_milion [lindex $extract 7]
if {$new_cases == ""} { set new_cases - } 
#else { set new_cases "+$new_cases" }
if {$total_deaths == ""} { set total_deaths - }
if {$new_deaths == ""} { set new_deaths - } 
#else { set new_deaths "+$new_deaths" }
if {$total_recovered == ""} { set total_recovered - }
if {$active_cases == ""} { set active_cases - }
if {$totalcases_per_milion == ""} { set totalcases_per_milion - }
if {$serious_critical == ""} { set serious_critical "-" }

if {[info exists corona($chan:autocovid:entry)]} {
if {$corona($chan:autocovid:entry) != $extract} {
	set corona($chan:autocovid:entry) $extract
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion] 4
	}
} else {
	set corona($chan:autocovid:entry) $extract
	corona:say "" $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion] 4
	}
	set next_num [expr $num + 1]
if {[lindex $channels $next_num] != ""} {
	utimer 5 [list corona:auto_check $data $channels $next_num]
	} else {
	timer $corona(time_check) corona:auto_timer
	}
}


###
proc corona:getdata {} {
	set link "https://www.worldometers.info/coronavirus/"
	http::register https 443 [list ::tls::socket -tls1 1]
	set ipq [http::config -useragent "lynx"]
	set ipq [::http::geturl "$link"] 
	set data [http::data $ipq]
	::http::cleanup $ipq
	return $data
}

###
proc corona:pub {nick host hand chan arg} {
	global corona
if {![channel get $chan covid]} {
	return
}
	set total 0
	set flood_protect [corona:flood:prot $chan $host]
if {$flood_protect == "1"} {
	set get_seconds [corona:get:flood_time $host $chan]
	corona:say $nick "NOTC" [list $get_seconds] 2
	return
}
	set country [join [lrange [split $arg] 0 end]]
if {$country == ""} {
	set total 1
	set country "GLOBAL"
} else {
	set find_country [lsearch -nocase $corona(country_list) $country]
if {$find_country < 0} {
	corona:say $nick $chan "" 1
	return
} else {
	set country [lindex $corona(country_list) $find_country]
	}
}
	set data [corona:getdata]
	set extract [corona:extract $data $country $total]
	set total_cases [lindex $extract 0]
	set new_cases [lindex $extract 1]
	set total_deaths [lindex $extract 2]
	set new_deaths [lindex $extract 3]
	set total_recovered [lindex $extract 4]
	set active_cases [lindex $extract 5]
	set serious_critical [lindex $extract 6]
	set totalcases_per_milion [lindex $extract 7]
if {$new_cases == ""} { set new_cases - }
if {$total_deaths == ""} { set total_deaths - }
if {$new_deaths == ""} { set new_deaths - }
if {$total_recovered == ""} { set total_recovered - }
if {$active_cases == ""} { set active_cases - }
if {$totalcases_per_milion == ""} { set totalcases_per_milion - }
if {$serious_critical == ""} { set serious_critical "-" }
	corona:say $nick $chan [list $country $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_critical $totalcases_per_milion] 3
}


###
proc corona:extract {data country total} {
	global corona
if {$total == "1"} {
	set split_data [split $data "\n"]
	set information ""
	set c 0
	set first_line 0
	set last_line 0
	set var "(.*)<td><strong>Total:</strong></td>"
foreach line $split_data {
	set line [concat $line]
if {[regexp -nocase $var $line]} {
	set first_line $c
	continue
	}
if {[string match -nocase "*</tr>" $line] && $first_line > 0} {
	set last_line $c
	break
}
	set c [expr $c + 1]
}
	set new_data [lrange $split_data $first_line $last_line]
foreach line $new_data {
	set test [regexp {<td style="(.*)">\d*(.*)\d*</td>|<td>(.*)</td>} $line match]
if {$test > 0} {
	regsub {</td>(.*)} $match "" m
	lappend information $m
	}
}
	set total_cases [corona:filter [lindex $information 1] 0]
	set new_cases [corona:filter [lindex $information 2] 0]
	set total_deaths [corona:filter [lindex $information 3] 0]
	set new_deaths [corona:filter [lindex $information 4] 0]
	set total_recovered [corona:filter [lindex $information 5] 0]
	set active_cases [corona:filter [lindex $information 6] 0]
	set serious_cases [corona:filter [lindex $information 7] 0]
	set totalcases_per_milion [corona:filter [lindex $information 8] 0]
	return [list $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_cases $totalcases_per_milion]
} else {
	set split_data [split $data "\n"]
	set information ""
	set c 0
	set first_line 0
	set last_line 0
	set var "(.*)<td style=\"font-weight: bold; font-size:15px; text-align:left;\">$country</td>|<td style=\"font-weight: bold; font-size:15px; text-align:left;\"><a class=\"mt_a\" href=\"(.*)\">$country</a></td>"
foreach line $split_data {
	set line [concat $line]
if {[regexp $var $line]} {
	set first_line $c
	continue
	}
if {[string match -nocase "*</tr>" $line] && $first_line > 0} {
	set last_line $c
	break
}
	set c [expr $c + 1]
}
	set new_data [lrange $split_data $first_line $last_line]
foreach line $new_data {
	set test [regexp {<td style="(.*)">\d*(.*)\d*</td>} $line match]
if {$test > 0} {
	regsub {</td>(.*)} $match "" m
	lappend information $m
	}
}

	set country [corona:filter [lindex $information 0] 0]
	set total_cases [corona:filter [lindex $information 1] 0]
	set new_cases [corona:filter [lindex $information 2] 0]
	set total_deaths [corona:filter [lindex $information 3] 0]
	set new_deaths [corona:filter [lindex $information 4] 0]
	set total_recovered [corona:filter [lindex $information 5] 0]
	set active_cases [corona:filter [lindex $information 6] 0]
	set serious_cases [corona:filter [lindex $information 7] 0]
	set totalcases_per_milion [corona:filter [lindex $information 8] 0]
	return [list $total_cases $new_cases $total_deaths $new_deaths $total_recovered $active_cases $serious_cases $totalcases_per_milion]

	}
}

###
proc corona:filter {text type} {
if {$type == "0"} {
	set split_text [split $text ">"]
	return [concat [lindex $split_text 1]]
} else {
	set text [string map {"<td>" ""} $text]
	return [concat $text]
	}
}

###
proc corona:flood:prot {chan host} {
	global corona
	set number [scan $corona(flood_prot) %\[^:\]]
	set timer [scan $corona(flood_prot) %*\[^:\]:%s]
if {[info exists corona(flood:$host:$chan:act)]} {
	return 1
}
foreach tmr [utimers] {
if {[string match "*corona:remove:flood $host $chan*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
	}
}
if {![info exists corona(flood:$host:$chan)]} { 
	set corona(flood:$host:$chan) 0 
}
	incr corona(flood:$host:$chan)
	utimer $timer [list corona:remove:flood $host $chan]	
if {$corona(flood:$host:$chan) > $number} {
	set corona(flood:$host:$chan:act) 1
	utimer 60 [list corona:expire:flood $host $chan]
	return 1
	} else {
	return 0
	}
}

###
proc corona:expire:flood {host chan} {
	global corona
if {[info exists corona(flood:$host:$chan:act)]} {
	unset corona(flood:$host:$chan:act)
	}
}

###
proc corona:remove:flood {host chan} {
	global corona
if {[info exists corona(flood:$host:$chan)]} {
	unset corona(flood:$host:$chan)
	}
}

###
proc corona:get:flood_time {host chan} {
	global corona
		foreach tmr [utimers] {
if {[string match "*corona:expire:flood $host $chan*" [join [lindex $tmr 1]]]} {
	return [lindex $tmr 0]
		}
	}
}

###
proc corona:say {nick chan arg num} {
	global corona
	set inc 0
	set get_lang [string tolower [channel get $chan covid-lang]]
if {$get_lang == ""} {
	set lang [string tolower $corona(language)]
} else {
if {[info exists corona($get_lang.lang.1)]} {
	set lang $get_lang
	} else {
	set lang [string tolower $corona(language)]
	}
}
foreach s $arg {
	set inc [expr $inc + 1]
	set replace(%msg.$inc%) $s
}
	set reply [string map [array get replace] $corona($lang.lang.$num)]
if {$chan == "NOTC"} {
	putserv "NOTICE $nick :$reply"
} else {
	putserv "PRIVMSG $chan :$reply"
	}
}


set corona(name) "Covid-19"
set corona(owner) "BLaCkShaDoW"
set corona(site) "WwW.TclScripts.Net"
set corona(version) "1.2"

####
#Language
#
###



set corona(en.lang.1) "Invalid country specified or NO CASES"
set corona(en.lang.2) "You exceded the number of commands. Please wait %msg.1% seconds."
set corona(en.lang.3) "\00303COVID-19 \00301Stats For \00313(\00310%msg.1%\00313)\00306. \00301Total Cases: \00307%msg.2%\00306. \00301New Cases: \00304%msg.3%\0036. \00301Total Deaths: \00307%msg.4%\00306. \00301New Deaths: \00304%msg.5%\00306. \00301Total Recovered: \00303%msg.6%\00306. \00301Active Cases: \00307%msg.7%\00306. \00301Serious Critical: \00313%msg.8%\00306. \00301Total Cases/1M pop: \00307%msg.9%\00306.\003"
#set corona(en.lang.3) "\002COVID-19\002 stats for -- %msg.1% -- Total Cases: \002%msg.2%\002 ; New Cases: \00302%msg.3%\003 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \00304%msg.5%\003 ; Total Recovered: \002%msg.6%\002 ; Active Cases: \002%msg.7%\002 ; Serious Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002"
#set corona(en.lang.4) "\002COVID-19\002 stats for -- %msg.1% -- Total Cases: \002%msg.2%\002 ; New Cases: \00302%msg.3%\003 ; Total Deaths: \002%msg.4%\002 ; New Deaths: \00304%msg.5%\003 ; Total Recovered: \002%msg.6%\002 ; Active Cases: \002%msg.7%\002 ; Serious Critical: \002%msg.8%\002 ; Total Cases/1M pop: \002%msg.9%\002"
set corona(en.lang.4) "\00303COVID-19 \00301Stats For \00313(\00310%msg.1%\00313)\00306. \00301Total Cases: \00307%msg.2%\00306. \00301New Cases: \00304%msg.3%\0036. \00301Total Deaths: \00307%msg.4%\00306. \00301New Deaths: \00304%msg.5%\00306. \00301Total Recovered: \00303%msg.6%\00306. \00301Active Cases: \00307%msg.7%\00306. \00301Serious Critical: \00313%msg.8%\00306. \00301Total Cases/1M pop: \00307%msg.9%\00306.\003"

set corona(ro.lang.1) "Tara invalida sau nu sunt cazuri."
set corona(ro.lang.2) "Ai depasit number de comenzi. Te rog asteapta %msg.1% secunde."
set corona(ro.lang.3) "Statistici \002COVID-19\002 pentru -- %msg.1% -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \00302%msg.3%\003 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \00304%msg.5%\003 ; Total recuperati: \002%msg.6%\002 ; Cazuri active: \002%msg.7%\002 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M populatie: \002%msg.9%\002"
set corona(ro.lang.4) "(AUTO) Statistici \002COVID-19\002 pentru -- %msg.1% -- Cazuri totale: \002%msg.2%\002 ; Cazuri noi: \00302%msg.3%\003 ; Total decedati: \002%msg.4%\002 ; Noi decedati: \00304%msg.5%\003 ; Total recuperati: \002%msg.6%\002 ; Cazuri active: \002%msg.7%\002 ; Cazuri critice: \002%msg.8%\002 ; Total cazuri/1M populatie: \002%msg.9%\002"

putlog "$corona(name) $corona(version) TCL by $corona(owner) loaded. For more tcls visit -- $corona(site) --"
