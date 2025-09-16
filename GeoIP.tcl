##############################
# GeoIP.tcl Version 16.09.25
##############################

package require http
package require json

##############################
# SETTINGS
##############################

set geoip(version) "16.09.25"
set geoip(triggers) {.ip !ip .dns !dns}

##############################
# BINDS
##############################

bind pub - $geoip(trigger) pub_geoip

##############################
# CODE
##############################

set used 0

proc pub_geoip {nick uhost hand chan text} {
    global used
    set lookup [lindex [split $text] 0]
    
    # Call ip-api.com instead of ipinfo.io
    catch {set http [::http::geturl http://ip-api.com/json/$lookup?fields=ip,query,city,regionName,country,countryCode,as -timeout 6000]} error
    set data [::http::data $http]
    
    # Check if the request was successful
    if {[string match "fail" $data]} {
        putserv "PRIVMSG $chan :\00304 Error: Could not retrieve data for IP $lookup."
        return
    }
    
    # Debug: Log the raw response from the API to inspect its structure
    putlog "DEBUG: Raw API response for $lookup: $data"
    
    # Parse the JSON response
    set json [::json::json2dict $data]
    ::http::cleanup $http
    
    # If the response does not contain the necessary keys, handle the case
    if {[dict exists $json "country"] == 0} {
        putserv "PRIVMSG $chan :\00304 Error: Missing expected data for IP $lookup."
        return
    }

    # Extract necessary data from the response
    set ip $lookup
    set query [dict get $json query]
    set city [dict get $json city]
    set regionName [dict get $json regionName]
    set country [dict get $json country]
    set countryCode [dict get $json countryCode]
    set as [dict get $json as]
    
    # If any field is missing or empty, set it to "n/a"
    if {$query == ""} {set query "n/a"}
    if {$city == ""} {set city "n/a"}
    if {$regionName == ""} {set regionName "n/a"}
    if {$country == ""} {set country "n/a"}
    if {$countryCode == ""} {set countryCode "n/a"}
    if {$as == ""} {set as "n/a"}
    
    # Build the IP + hostname part
    set ip_part "\00306Whois:\00312 $ip"
    if {![string equal $query "n/a"] && ![string equal $query $ip]} {
        append ip_part " \00306(\00312$query\00306)"
    }
    
    # Build the rest output string
    set output "$ip_part \00301- \00306City:\00304 $city \00301- \00306Region:\00307 $regionName \00301- \00306Country:\00303 $countryCode \00306(\00303$country\00306) \00301- \00306Organization:\00310 $as \003"
    
    # Send the formatted response to the channel
    putserv "PRIVMSG $chan :$output"
}

putlog "GeoIP.tcl v$geoip(version) loaded."
