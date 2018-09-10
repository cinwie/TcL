######################################################################
# Adzan By JoJo
# Modifikasi otomatis oleh dono - irc.ayochat.or.id
# Initial release: 20 November 2009
# Modifikasi oleh dono: 20 April 2014
# ShareAdzan oleh wie - irc.wnet.tk - 09 September 2018
# Version 10.09.18
######################################################################
# Gunakan .chanset #channel +shareadzan
######################################################################

package require http

set sharetime(format) "%A %B %d %Y -- %H:%M:%S"
set kodedaerah "308"
set namadaerah "Jakarta Pusat"

bind time - "00 03 * * *" ShareAdzan

setudef flag shareadzan

proc ShareAdzan {mins hours days months years} { 
	global kodedaerah namadaerah
	SaveAdzan $kodedaerah $namadaerah
}

proc SaveAdzan {kodedaerah namadaerah} {
global waktu waktusubuh waktudzuhur waktuashar waktumaghrib waktuisya waktutweet wsubuh wdzuhur washar wmaghrib wisya
#	set connect [::http::geturl http://jadwal-sholat.info/daily.php?id=$kodedaerah]
	set connect [::http::geturl http://jadwalsholatimsak.com/daily.php?id=$kodedaerah]
	set files [::http::data $connect]
#	set l [regexp -all -inline -- {.*?<tr class="table_light" align="center"><td><b>.*?</b></td><td>.*?</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td></tr>.*?<tr class="table_block_title"><td colspan="7">} $files]
	set l [regexp -all -inline -- {.*?<tr class="table_light" align="center"><td><b>.*?</b></td><td>.*?</td><td>(.*?):(.*?)</td><td>.*?</td><td>.*?</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td><td>(.*?):(.*?)</td></tr>.*?<tr class="table_block_title"><td colspan="9">} $files]
	   if {[llength $l] != 0} {
			foreach {black a b c d e f g h i j} $l {
			set a [string trim $a " \n"]
			set b [string trim $b " \n"]
			set c [string trim $c " \n"]
			set d [string trim $d " \n"]
			set e [string trim $e " \n"]
			set f [string trim $f " \n"]
			set g [string trim $g " \n"]
			set h [string trim $h " \n"]
			set i [string trim $i " \n"]
			set j [string trim $j " \n"]

			regsub -all {<.+?>} $a {} a	
			regsub -all {<.+?>} $b {} b
			regsub -all {<.+?>} $c {} c
			regsub -all {<.+?>} $d {} d
			regsub -all {<.+?>} $e {} e
			regsub -all {<.+?>} $f {} f
			regsub -all {<.+?>} $g {} g
			regsub -all {<.+?>} $h {} h
			regsub -all {<.+?>} $i {} i
			regsub -all {<.+?>} $j {} j
			
			putlog "Saatnya Ambil Data Dari http://jadwalsholatimsak.com/"
			
			set waktusubuh "$b $a * * *"
			set wsubuh "$a:$b:00"
			bind time - "$b $a * * *" share:subuh

			set waktudzuhur "$d $c * * *"
			set wdzuhur "$c:$d:00"
			bind time - "$d $c * * *" share:dzuhur

			set waktuashar "$f $e * * *"
			set washar "$e:$f:00"
			bind time - "$f $e * * *" share:ashar

			set waktumaghrib "$h $g * * *"
			set wmaghrib "$g:$h:00"
			bind time - "$h $g * * *" share:maghrib

			set waktuisya "$j $i * * *"
			set wisya "$i:$j:00"
			bind time - "$j $i * * *" share:isya
			
		foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			replacetime
			puthelp "PRIVMSG $chan :\[Jadwal Sholat $namadaerah, $waktu\] Subuh: $wsubuh - Dzuhur: $wdzuhur - Ashar: $washar - Maghrib: $wmaghrib - Isya: $wisya"
				}
			}
		}
	}
}
proc share:subuh {nick uhost hand chan arg} {
	global waktusubuh wsubuh namadaerah
	foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			puthelp "PRIVMSG $chan :*** Waktu Tepat Menunjukan Pukul\00303 $wsubuh\003 WIB, Waktunya Untuk Melaksanakan Ibadah Sholat \00304Subuh\003 Untuk Daerah \00307$namadaerah\003 Dan Sekitarnya ***"
			catch { unbind time - "$waktusubuh" share:subuh }
		}
	}
}

proc share:dzuhur {nick uhost hand chan arg} {
	global waktudzuhur wdzuhur namadaerah
	foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			puthelp "PRIVMSG $chan :*** Waktu Tepat Menunjukan Pukul\00303 $wdzuhur\003 WIB, Waktunya Untuk Melaksanakan Ibadah Sholat \00304Dzuhur\003 Untuk Daerah \00307$namadaerah\003 Dan Sekitarnya ***"
			catch { unbind time - "$waktudzuhur" share:dzuhur }
		}
	}
}

proc share:ashar {nick uhost hand chan arg} {
	global waktuashar washar namadaerah
	foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			puthelp "PRIVMSG $chan :*** Waktu Tepat Menunjukan Pukul\00303 $washar\003 WIB, Waktunya Untuk Melaksanakan Ibadah Sholat \00304Ashar\003 Untuk Daerah \00307$namadaerah\003 Dan Sekitarnya ***"
			catch { unbind time - "$waktuashar" share:ashar }
		}
	}
}

proc share:maghrib {nick uhost hand chan arg} {
	global waktumaghrib wmaghrib namadaerah
	foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			puthelp "PRIVMSG $chan :*** Waktu Tepat Menunjukan Pukul\00303 $wmaghrib\003 WIB, Waktunya Untuk Melaksanakan Ibadah Sholat \00304Maghrib\003 Untuk Daerah \00307$namadaerah\003 Dan Sekitarnya ***"
			catch { unbind time - "$waktumaghrib" share:maghrib }
		}
	}
}
proc share:isya {nick uhost hand chan arg} {
	global waktuisya wisya namadaerah
	foreach chan [channels] {
		if {[channel get $chan shareadzan]} {
			puthelp "PRIVMSG $chan :*** Waktu Tepat Menunjukan Pukul\00303 $wisya\003 WIB, Waktunya Untuk Melaksanakan Ibadah Sholat \00304Isya\003 Untuk Daerah \00307$namadaerah\003 Dan Sekitarnya ***"
			catch { unbind time - "$waktuisya" share:isya }
		}
	}
}

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

	set waktu "$hari, $tanggal $bulan $tahun"
}

putlog "\002SHAREADZAN:\002 ShareAdzan.tcl Version 10.09.18 by wie - irc.WNet.tk is loaded."