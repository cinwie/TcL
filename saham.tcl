# saham.tcl - ambil harga saham & IHSG dari Google Finance
# v24.09.25

# ===== Bind Command =====
bind pub - "!saham" saham_pub
bind msg - "!saham" saham_priv

bind pub - "!ihsg" ihsg_pub
bind msg - "!ihsg" ihsg_priv

set saham(version) "24.09.25"

# ===== Warna IRC (global) =====
array set c {
    reset "\017"
    black "\00301"
    orange "\00307"
    purple "\00306"
}

# ===== Fungsi bantu: ambil data saham umum =====
proc get_saham_reply {ticker} {
    global c
    # Ambil halaman Google Finance
    set url "https://www.google.com/finance/quote/${ticker}:IDX"
    if {[catch {set html [exec curl -s -A "Mozilla/5.0" $url]} err]} {
        return "Error ambil data: $err"
    }
    set html [string map {\n ""} $html]

    # Ambil harga sekarang
    if {[regexp {<div class="YMlKec fxKbKc">([^<]+)</div>} $html -> price]} {
        set price $price
    } else {
        set price "N/A"
    }

    # Ambil Day Range
    if {[regexp {Day range</div>.*?<div class="P6K39c">([^<]+)</div>} $html -> dayrange]} {
        set dayrange $dayrange
    } else {
        set dayrange ""
    }

    # Bersihkan Rp dobel jika ada
    regsub -nocase {^Rp[\s\xC2\xA0]*} $price "" clean_price

    set ticker_str "${c(black)}${ticker}:IDX${c(reset)}"
    set harga_str  "${c(black)}Rp ${c(orange)}$clean_price${c(reset)}"

    set range_str ""
    if {$dayrange ne ""} {
        if {[regexp {Rp\s?([0-9.,]+)\s?-\s?Rp\s?([0-9.,]+)} $dayrange -> low high]} {
            set range_str "${c(black)}(${c(purple)}Day Range: ${c(black)}Rp${c(orange)} $low ${c(black)}- Rp${c(orange)} $high${c(black)})${c(reset)}"
        } else {
            set range_str "${c(black)}(${c(purple)}Day Range: ${c(black)}$dayrange${c(black)})${c(reset)}"
        }
    }

    return "$ticker_str - $harga_str $range_str"
}

# ===== Fungsi bantu: ambil data IHSG =====
proc get_ihsg_reply {} {
    global c
    if {[catch {
        set html [exec curl -s -A "Mozilla/5.0" \
            "https://www.google.com/finance/quote/COMPOSITE:IDX"]
    } err]} {
        return "Error ambil data IHSG: $err"
    }

    set html [string map {\n ""} $html]

    # Ambil harga sekarang
    if {[regexp {<div class="YMlKec fxKbKc">([^<]+)</div>} $html -> price]} {
        set price $price
    } else {
        set price "N/A"
    }

    # Ambil Day Range
    if {[regexp {Day range</div>.*?<div class="P6K39c">([^<]+)</div>} $html -> dayrange]} {
        set dayrange $dayrange
    } else {
        set dayrange ""
    }

    regsub -nocase {^Rp[\s\xC2\xA0]*} $price "" clean_price

    set ticker_str "${c(black)}IHSG:IDX${c(reset)}"
    set harga_str  "${c(black)}Rp ${c(orange)}$clean_price${c(reset)}"

    set range_str ""
    if {$dayrange ne ""} {
        if {[regexp {Rp\s?([0-9.,]+)\s?-\s?Rp\s?([0-9.,]+)} $dayrange -> low high]} {
            # Day Range sudah ada Rp
            set range_str "${c(black)}(${c(purple)}Day Range: ${c(black)}Rp${c(orange)} $low ${c(black)}- Rp${c(orange)} $high${c(black)})${c(reset)}"
        } elseif {[regexp {([0-9.,]+)\s?-\s?([0-9.,]+)} $dayrange -> low high]} {
            # Day Range tanpa Rp → tambahkan sendiri
            set range_str "${c(black)}(${c(purple)}Day Range: ${c(black)}Rp${c(orange)} $low ${c(black)}- Rp${c(orange)} $high${c(black)})${c(reset)}"
        } else {
            set range_str "${c(black)}(${c(purple)}Day Range: ${c(black)}$dayrange${c(black)})${c(reset)}"
        }
    }

    return "$ticker_str - $harga_str $range_str"
}


# ===== Command public =====
proc saham_pub {nick uhost handle chan text} {
    if {[llength $text] < 1} {
        putquick "PRIVMSG $chan : Usage: !saham <ticker>, Ex: !saham BBMD"
        return
    }
    set ticker [string toupper [lindex $text 0]]
    set reply [get_saham_reply $ticker]
    putquick "PRIVMSG $chan : $reply"
}

proc ihsg_pub {nick uhost handle chan text} {
    set reply [get_ihsg_reply]
    putquick "PRIVMSG $chan : $reply"
}

# ===== Command private =====
proc saham_priv {nick uhost handle text} {
    if {[llength $text] < 1} {
        putquick "PRIVMSG $nick :Usage (priv): !saham <ticker>, Ex: !saham BBMD"
        return
    }
    set ticker [string toupper [lindex $text 0]]
    set reply [get_saham_reply $ticker]
    putquick "PRIVMSG $nick :$reply"
}

proc ihsg_priv {nick uhost handle text} {
    set reply [get_ihsg_reply]
    putquick "PRIVMSG $nick :$reply"
}


putlog "Saham.tcl v$saham(version) loaded."
