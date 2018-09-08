########################
#      ShareTime       #     
# -------------------  #
#   Date: 25-01-2018   #
#   Version: v0.6      #
#   Author(s): wie     #
########################

set sharetime(format) "%A %B %d %Y -- %H:%M:%S"
bind time - "00 * * * *" sharetime
bind pubm - *jam* sharetime_pub

setudef flag sharetime

proc sharetime {nick uhost hand chan arg} {
	global sharetime waktu
	foreach chan [channels] {
		if {[channel get $chan sharetime]} {
			replacetime
			puthelp "PRIVMSG $chan :Waktu Saat Ini: $waktu"
		}
	}
}

proc sharetime_pub {nick uhost hand chan arg} {
	global sharetime otime waktu 
	set rtime [unixtime]
	if { $rtime - $otime  > 7} {
		replacetime
		puthelp "PRIVMSG $chan :Waktu Saat Ini: $waktu"
		set otime $rtime
	}
}
set otime 0

proc replacetime { } {
global sharetime waktu
set arguments [clock format [clock seconds] -timezone :Asia/Jakarta -format $sharetime(format)]
	set day [lindex [split $arguments] 0]
	if {$day == "Monday"} { set hari "\00312Senin\003" }
	if {$day == "Tuesday"} { set hari "\00312Selasa\003" }
	if {$day == "Wednesday"} { set hari "\00312Rabu\003" }
	if {$day == "Thursday"} { set hari "\00312Kamis\003" }
	if {$day == "Friday"} { set hari "\00303Jum'at\003" }
	if {$day == "Saturday"} { set hari "\00304Sabtu\003" }
	if {$day == "Sunday"} { set hari "\00304Minggu\003" }
	set tanggal [lindex [split $arguments] 2]
	set month [lindex [split $arguments] 1]
	if {$month == "January"} { set bulan "Januari" }
	if {$month == "February"} { set bulan "Februari" }
	if {$month == "March"} { set bulan "Maret" }
	if {$month == "April"} { set bulan "April" }
	if {$month == "May"} { set bulan "Mei" }
	if {$month == "June"} { set bulan "Juni" }
	if {$month == "July"} { set bulan "Juli" }
	if {$month == "August"} { set bulan "Agustus" }
	if {$month == "September"} { set bulan "September" }
	if {$month == "October"} { set bulan "Oktober" }
	if {$month == "November"} { set bulan "November" }
	if {$month == "December"} { set bulan "Desember" }
	set tahun [lindex [split $arguments] 3]
	set jam [lindex [split $arguments] 5]

	set waktu "$hari, $tanggal $bulan $tahun, $jam WIB"

}

putlog "\002SHARETIME:\002 ShareTime.tcl 0.6 by wie is loaded."
