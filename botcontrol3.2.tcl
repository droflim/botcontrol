###############################################################################
#############       Public bot control by Prince_of_the_net          ##########
###############################################################################

#While running eggdrops I have seen that it is not always possible to log into
#your eggdrop party line and type in the commands. So I thought why not make a 
#script to do all the basic functions in the form of channel messages?This
#gave rise to this script. I have taken some ideas from sPeX.tcl written by 
#K-sPecial. I would like to thank him for providing me the ideas.I have 
#deliberately omitted trivial operations like restarting the bot or shutting 
#it down as it may cause some security problems. For using this script you must
#load the counter script I have made before you load this script. You can get
#the counter script (counter.tcl) from http://www.egghelp.org/tcl.htm. Please
#send me bug reports if you find any and also please let me know if you have
#done some too cool modification to this script at Prince_of_the_net@k.st.
#You can find me in #delhi #eggdrop and #dalnethelp on DALNET ,on #egghelp on 
#EFnet and on #eggdrop on Xnet. Your contributions will be acknowledged in the 
#next version of this script.Special thanks go to Viper@xnet.org. Thanks man.
#Without your help this script was absolutely impossible.Also thanks to all the
#ops (specially trring J-[a]-G and Muzaffar) and chatters of #delhi for letting
#me test the script in #delhi on DALNET.Also thanks to R|chard for helping me
#in numerous ways and always being with me when I needed his help the most.
#
#
#This script has been provided "AS IS and with all its "FAULTS" the author will
#not be responsible for any kind of damage caused by the script.However the
#author would like to help with problems the user may face while using this
#script.This script may not suit to your needs but the author can't be held
#responsible in such cases and the author would like to protect this script
#under the GNU Public license.You can get a latest copy of the license at
#http://www.gnu.org.
###############################################################################
#Set this to the character you want the commands for the bot to start with.
set cmdchar "!"
#
###############################################################################
#You might want to change some of the flags that control the binds if you know what your doing.
###############################################################################
bind pub o|o "${cmdchar}op" bctrl:op
bind pub o|o "${cmdchar}deop" bctrl:deop
bind pub o|o "${cmdchar}voice" bctrl:voice
bind pub o|o "${cmdchar}devoice" bctrl:devoice
bind pub o|o "${cmdchar}ban" bctrl:ban
bind pub o|o "${cmdchar}ipban" bctrl:ipban
bind pub o|o "${cmdchar}unban" bctrl:unban
bind pub o|o "${cmdchar}kick" bctrl:kick
bind pub o|o "${cmdchar}invite" bctrl:invite
bind pub m|m "${cmdchar}adduser" bctrl:add_user
bind pub m|m "${cmdchar}deluser" bctrl:del_user
bind pub m|m "${cmdchar}chattr" bctrl:chatt_r
bind pub m|m "${cmdchar}isuser" bctrl:valid_user
bind pub o|o "${cmdchar}mode" bctrl:mode
bind pub m|m "${cmdchar}count" bctrl:count_users
bind pub m|m "${cmdchar}botlist" bctrl:bot_list
bind pub m|m "${cmdchar}dcclist" bctrl:dcc_list
bind pub m|m "${cmdchar}boot" bctrl:boot_bot
bind pub m|m "${cmdchar}save" bctrl:sa_ve
bind pub m|m "${cmdchar}reload" bctrl:re_load
bind pub o|o "${cmdchar}help" bctrl:help
###############################################################################

# the procedure to check if the bot is opped in a channel and stop execution if
#it's not
# if {[bctrl:noop $chan $nick]} { return 0 }

proc bctrl:noop {chan nick} {
    global logo
    if {![botisop $chan]} {
	putserv "NOTICE $nick :Sorry I am not opped in $chan  $logo" 
	return 1
    }
    return 0
}

proc bctrl:op {nick uhost hand chan text} {
    set person [lindex [split $text] 0]
    if {$person == ""} {
	set person $nick
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    pushmode $chan +o $person
}

proc bctrl:deop {nick uhost hand chan text} {
    global botnick logo
    set person [lindex [split $text] 0]
    if {$person == ""} {
	set person $nick
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    if {[regexp -nocase $botnick $person]}  {puthelp "NOTICE $nick :I am not deopping myself :P  $logo"
	return 0}
    pushmode $chan -o $person
}

proc bctrl:voice {nick uhost hand chan text} {
    set person [lindex [split $text] 0]
    if {$person == ""} {
	set person $nick
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    pushmode $chan +v $person
}

proc bctrl:devoice {nick uhost hand chan text} {
    set person [lindex [split $text] 0]
    if {$person == ""} {
	set person $nick
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    pushmode $chan -v $person
}

proc bctrl:mode {nick uhost hand chan text} {
    global logo
    putquick "MODE $chan :[lindex [split $text] end]"
    putserv "NOTICE $nick :mode set on $chan: [lindex [split $text] end]  $logo"
}

proc bctrl:ban {nick uhost hand chan text} {
    global logo botnick
    set text [split $text]
    set who [lindex $text 0]
    if {$who == ""} {
	puthelp "NOTICE $nick :The correct syntax for using this command is !ban <person_to_be_banned> \[reason\] \[time_in_minutes\]"
	puthelp "NOTICE $nick :The reason and time for ban is optional and you my leave it for me to decide if you like ;-)  $logo"
	return 0
    }
    if {[regexp -nocase $botnick $who]} {putkick $chan $nick "Stop Playing with me [count_update 0]  $logo"
	return 0}
    set whost [lindex [split [getchanhost $who $chan] "@"] end]
    set duration [lindex $text end]
    if {[string is integer $duration]} {
 	set reason [join [lrange $text 1 end-1]]
    } {
 	set duration "30"
 	set reason [join [lrange $text 1 end]]
    }
    if {$reason == ""} { 
 	set reason "Requested by $nick \002($duration min)\002 "
    }
    if {[bctrl:noop $chan $nick]} { return 0 }

    if {$whost == ""} {
 	putserv "NOTICE $nick :$who is not on $chan $logo"
 	return 0
    }
    # easy as pie :P
    set whost [string trimleft $whost "~"]
    set banhost "*!*@$whost"
    newchanban $chan $banhost $nick "$reason \002($duration min)\002 [count_update 1] $logo" $duration
    putkick $chan $who "$reason [count_update 1] $logo"
}

proc bctrl:ipban {nick uhost hand chan text} {
    global logo
    set ip [lindex [split $text] 0]
    if {$ip == ""} {
	puthelp "NOTICE $nick :The correct syntax for using this command is !ipban <ip_to_be_banned> \[reason\] \[time_in_minutes\]"
	puthelp "NOTICE $nick :The reason and time for ban is optional and you my leave it for me to decide if you like ;-)  $logo"
	return 0
    }
    set duration [lindex [split $text] 1]
    if {[string is integer $duration] && $duration != ""} {
	set reason "Requested by $nick \002($duration min)\002  "
    } {
	if {$duration == ""} {
	    set duration 120
	    set reason "Requested by $nick \002($duration min)\002  "
	} {
	    if {[string is integer [lindex [split $text] end]]} {
		set duration [lindex [split $text] end]
		set reason [join [lrange [split $text] 1 end-1]]
	    } {
		set duration 120
		set reason [join [lrange [split $text] 1 end]]
	    }
	}
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    newchanban $chan $ip $nick "$reason [count_update 1] $logo" $duration
}

proc bctrl:unban {nick uhost hand chan text} {
    set mask [lindex [split $text] 0]
    if {$mask == ""} {
	puthelp "NOTICE $nick :The correct syntax for using this command is !unban <mask_to_be_unbanned>"
	return 0
    }
    if {[bctrl:noop $chan $nick]} { return 0 }
    if {[isban $mask $chan]} {
	killchanban $chan $mask
    } {
	pushmode $chan -b $mask
    }
}

proc bctrl:kick {nick uhost hand chan text} {
    global logo botnick
    set text [split $text]
    set person [lindex $text 0]
    if {$person == ""} {
	puthelp "NOTICE $nick :The correct syntax for using this command is !kick <person_to_be_kicked> \[reason\]"
	puthelp "NOTICE $nick :The reason for kick is optional and you my leave it for me to decide if you like ;-)  $logo"
	return 0
    }

    if {[regexp -nocase $botnick $person]} {putkick $chan $nick "Don't you think we have had enough of game?  [count_update 0]  $logo"
	return 0}
    if {[bctrl:noop $chan $nick]} { return 0 }
    if {![onchan $person $chan]} {puthelp "NOTICE $nick :$person is not on $chan  $logo"
    return 0}
    if {[join [lrange $text 1 end]] == ""} {
	set reas "Kicked on request of $nick  "
    } {
	set reas [join [lrange $text 1 end]]
    }
	putkick $chan $person "$reas [count_update 0] $logo"
}

proc bctrl:invite {nick uhost hand chan text} {
    global logo
    set person [lindex [split $text] 0]

    # hehe... weird stuff

    if {$person == ""} { 
	set person $nick
    }
    if {[string match "*[string index $person 0]*" "\#&"]} {
	set channel $person
	set person $nick
    } {
	set channel [lindex [split $text] 1]
	if {$channel == ""} {
	    set channel $chan
	}
    }
    putserv "INVITE $person $channel"
    putserv "NOTICE $nick :Invited $person to $channel  $logo"
}

proc bctrl:boot_bot {nick uhost hand chan text} {
    global logo
    set text [split $text]
    set person [nick2hand [lindex $text 0]]
    if {$person == ""} {
	puthelp "NOTICE $nick :The correct syntax for using this command is !boot <person_to_be_booted> \[reason\]"
	puthelp "NOTICE $nick :The reason for boot is optional and you my leave it for me to decide if you like ;-)  $logo"
	return 0
    }

    if {[join [lrange $text 1 end]] == ""} {
	set reas [join [lrange $text 1 end]]
    } {
	set reas "Booted on request of $nick $logo"
    }
    boot $person $reas
    putserv "NOTICE $nick :$person has been kicked off the partyline!!  $logo"
}

proc bctrl:dcc_list {nick uhost hand chan text} {
    global logo
    set tipe [lindex [split $text] 0]
    if {$tipe == ""} {
	putserv "NOTICE $nick :You have to select a dcclist type!"
	putserv "NOTICE $nick :The valid types are one of the following:"
	putserv "NOTICE $nick :chat bot files files_receiving file_sending file_sending_pending script socket telnet and server  $logo"
    } {
	set dccl [dcclist $tipe]
	putserv "NOTICE $nick :$dccl"
    }
}

proc bctrl:valid_user {nick uhost hand chan text} {
    global logo
    set person [lindex [split $text] 0]
    set valible [validuser $person]
    if {$person == ""} {
	putserv "NOTICE $nick :Uhm.. you are a validuser, to find out if someone else is, you have to provide a nickname.  $logo"
	return 0
    }
    
  if {$valible == 1} {
      putserv "NOTICE $nick :Yeah pal, $person is a valid user.  $logo"
  } {
      putserv "NOTICE $nick :Sorry pal, $person is not a valid user.  $logo"
  }
}      

proc bctrl:add_user {nick uhost hand chan text} {
    global logo botnick
    set person [lindex [split $text] 0]
    if {$person == ""} {
	puthelp "NOTICE $nick :You did not tell me the nick to be added :-(. The correct syntax is !adduser <nick_to_be_added>  $logo"
	return 0
    }
    set per_ip [getchanhost $person]
    set per_host [maskhost $person!$per_ip]
    set host [lindex [split $text] 1]
    if {$host == ""} {
	set host $per_host 
    }
    set kadd [adduser $person $host]
    if {$kadd == 1} {
 	putserv "NOTICE $nick :Successfully added $person with host $host  $logo"
 	putserv "NOTICE $person :You were added to my user list by $nick with host $host.Please set up your password with /msg $botnick pass <ur_chosen_password>  $logo"
    } {
 	putserv "NOTICE $nick :Error, could not add user $person, he already exists!!  $logo"
    }
}

proc bctrl:del_user {nick uhost hand chan text} {
    global logo
    set person [nick2hand [lindex [split $text] 0]]
    if {$person == ""} {
	puthelp "NOTICE $nick :You did not tell me the nick to be added :-(. The correct syntax is !deluser <nick_to_be_deleted>  $logo"
	return 0
    }
    set dels [deluser $person]
    if {$dels == 1} {
	putserv "NOTICE $nick :User $person has been successfully deleted.  $logo"
    } {
	putserv "NOTICE $nick :No such user: $person!!  $logo"
    }
}

proc bctrl:count_users {nick uhost hand chan text} {
    global logo
    set users [countusers]
    putserv "NOTICE $nick :There are currently $users users in the bots database.  $logo"
}

proc bctrl:bot_list {nick uhost hand chan text} {
    global logo
    set botl [join [botlist]]
    putserv "NOTICE $nick :BotList: $botl  $logo"
}

proc bctrl:chatt_r {nick uhost hand chan text} {
    global logo
    set person [nick2hand [lindex [split $text] 0]]
    if {$person == ""} {
	puthelp "NOTICE $nick :You did not tell me the nick for whom the user flags are to be changed :-(. The correct syntax is !chattr <nick_to_be_modified> <flags> \[channel\]"
	puthelp "NOTICE $nick :The channel is optional.  $logo"
	return 0
    }
    set change [lindex [split $text] 1]
    set channel [lindex [split $text] 2]
    if {$channel == ""} {
	set chattz [chattr $person $change]
	putserv "NOTICE $nick :The global flags for $person are now: $chattz"
	putlog "Changing global"
	putserv "NOTICE $person :Your global flags are now: $chattz"
    } {
	set chattz [chattr $person |$change $channel]
	putserv "NOTICE $nick :The global flags, and channel flags in the format of global|channel for $person are now: $chattz  $logo"
    }
}

proc bctrl:sa_ve {nick uhost hand chan text} {
    global logo
    save
    putserv "NOTICE $nick :The user and channel files have successfully been written to disk. $logo"
}

proc bctrl:re_load {nick uhost hand chan text} {
    global logo
    reload
    putserv "NOTICE $nick :The user file has been successfully re-loaded.  $logo"
}


proc bctrl:help {nick uhost hand chan text} {
    global cmdchar logo
    putserv "NOTICE $nick :Available commands are the following: ${cmdchar}op ${cmdchar}deop ${cmdchar}voice ${cmdchar}devoice ${cmdchar}ban ${cmdchar}unban ${cmdchar}kick ${cmdchar}invite ${cmdchar}isuser ${cmdchar}count ${cmdchar}adduser ${cmdchar}deluser ${cmdchar}chattr ${cmdchar}dcclist ${cmdchar}botlist ${cmdchar}boot ${cmdchar}save ${cmdchar}reload ${cmdchar}version ${cmdchar}help  $logo"
}

putlog "BotControl v3.1 Channel command, written by \002Prince_of_the_net\002 \[Loaded\]"
