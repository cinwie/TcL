#########################################
# COMPATIBLE WITH OTHER ALL ZNC VERSION #
#########################################

bind pub - .ping pub_ping
bind pub - .+chan pub_+chan
bind pub - .-chan pub_-chan
bind msg - part msg_part
bind msg - join msg_join
bind pub - .msg pub_msg

set ::notc \[D\037e\037athKn\037i\037ght\]
set ::ps b@ndit.

proc pub_ping {nick uhost hand chan rest} {
   if {$::ps != $uhost} {
      return 0
   }
   puthelp "PRIVMSG $chan :$nick, PONG"
   return 0
}

proc pub_+chan {nick uhost hand chan rest} {
   if {$::ps != $uhost} {
      return 0
   }
   set chan [lindex $rest 0]
   if {[string first # $chan]!=0} {
      set chan "#$chan"
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :$::notc Usage: .+chan <#channel>"
      return 0
   }
      puthelp "NOTICE $nick :$::notc Ok Sekarang Sudah Join $chan"
      putserv "JOIN $chan"
}

proc pub_-chan {nick uhost hand chan rest} {
   if {$::ps != $uhost} {
      return 0
   }
   set chan [lindex $rest 0]
   if {[string first # $chan]!=0} {
      set chan "#$chan"
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :$::notc Usage: .-chan <#channel>"
      return 0
   }
      puthelp "NOTICE $nick :$::notc Ok Sekarang Sudah Part $chan"
      putserv "PART $chan"
}

proc msg_part {nick uhost hand rest} {
   if {$::ps != $uhost} {
      return 0
   }
   set chan [lindex $rest 0]
   if {[string first # $chan]!=0} {
      set chan "#$chan"
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :$::notc Usage: part <#channel>"
      return 0
   }
      puthelp "NOTICE $nick :$::notc Ok Sekarang Sudah Part $chan"
      putserv "PART $chan"
}

proc msg_join {nick uhost hand rest} {
   if {$::ps != $uhost} {
      return 0
   }
   set chan [lindex $rest 0]
   if {[string first # $chan]!=0} {
      set chan "#$chan"
   }
   if {$chan=="#"} {
      puthelp "NOTICE $nick :$::notc Usage: join <#channel>"
      return 0
   }
      puthelp "NOTICE $nick :$::notc Ok Sekarang Sudah Join $chan"
      putserv "JOIN $chan"
}

proc pub_msg {nick uhost hand channel rest} {
   if {$::ps != $uhost} {
      return 0
   }
   if {$rest==""} {
      puthelp "NOTICE $nick :$::notc Usage: .msg <nick> <msg>"
   }
   set person [string tolower [lindex $rest 0]]
   set rest [lrange $rest 1 end]
   if {[string match "*serv*" $person]} {
      puthelp "NOTICE $nick :$::notc DeNIEd..! Can't send message to Service."
      return 0
   }
   puthelp "PRIVMSG $person :$rest"
}

PutModule "DeathKnight ZNC TcL v.17.11.19 LoadEd"
