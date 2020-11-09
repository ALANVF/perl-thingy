#!/usr/bin/perl

# turn on perl's safety features and load modules
use strict;
use warnings;
use integer;
use Math::BigFloat;
use Math::BigInt;
use Time::HiRes qw(sleep);
use WWW::Mechanize;
use POSIX qw(strftime);

use feature "say";
#use feature "state";
use feature "switch";
no warnings "experimental::smartmatch";
use featute "postderef";
use feature "signatures";
no warnings "experimental::signatures";



if($#ARGV < 8) {
	if($ARGV[1] ~~ [1..35]) {
		splice(@ARGV, 2, 0, ('password'));
	}
}	

my $server      = $ARGV[0] or die "Server failed";
my $username    = $ARGV[1] or die "username error";
my $password    = $ARGV[2] or die "password error";
my $loop_wait   = $ARGV[3] or die "loop_wait error";
my $char_type   = $ARGV[4] or die "char_type error";
my $shop_yes_no = $ARGV[5] or die "Shops on or off";
my $steal_char  = $ARGV[6] or die "stealername error";
my $merger_name = $ARGV[7] or die "merger_name error";
my $max_level   = $ARGV[8] or die "max_level error";

# Global variables
my $stat;
my @logins;
my @users;
my $parsed; # SHOULD NOT BE GLOBAL
my ($tmp, $mech);
my ($a, $b, $c);
my ($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst);
#my $clicks; (UNUSED)
my $users;
my $datestring;
my $charname;
my $title;
my $name = "";
#my $DoSearch = ""; (UNUSED)
my $antal = new Math::BigFloat;
my $wdlevel = new Math::BigFloat;
my $aslevel = new Math::BigFloat;
my $mslevel = new Math::BigFloat;
my $deflevel = new Math::BigFloat;
my $arlevel = new Math::BigFloat;
my $mrlevel = new Math::BigFloat;
my $level = new Math::BigFloat;
my $steal_antal = new Math::BigFloat; # SHOULD NOT BE GLOBAL
my $mytime;
my $intstrlvl = 0;
my $merge_name; # SHOULD NOT BE GLOBAL
my $autolevel;
my $MyLev;
my $masslevel = 1500;
my $alternate = 60;
my $agilmagecount = 6;
my $fightercount = 3;
my $magecount = 3;
my $puremagecount = 3;
my $purefightercount = 3;
my $cfcount = 17;
my $shop1;
my $shop2;
my $shop3;
my $shop4;
my $shop5;
my $shop6;
my $shop7;
my $shop8;
my $shop9;
my $shop10;
my $shop11;
my $shop12;
my $waitdiv = new Math::BigFloat;
my $exper3 = new Math::BigFloat;
my $experaverage = new Math::BigFloat;
my $reloadcount = 0;
my $gold3 = new Math::BigFloat;
my $goldaverage = new Math::BigFloat;
my $experseconds;
my $experminutes;
my $experhours;
my $experdays;
my $goldseconds;
my $goldminutes;
my $goldhours;
my $golddays;
my $Forlev;
my $Nextlevel = new Math::BigFloat;
my $SHOPMAX;
my $SHOPWEAP;
my $SHOPAS;
my $SHOPHS;
my $SHOPHELM;
my $SHOPSHIELD;
my $SHOPAMULET;
my $SHOPRING;
my $SHOPARMOR;
my $SHOPBELT;
my $SHOPPANTS;
my $SHOPHAND;
my $SHOPFEET;
my $URL_SERVER;
my $file_fix;
my $temp1 = new Math::BigFloat;
my $purebuild = 180;

# Constants
my @MONTHS = (
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
);


if($char_type ~~ [7..12]) {
	say "SINGLE STAT MODE, make sure you have selected the right stat.";
	$alternate = 180;
	$shop_yes_no = 2;
}

if($merger_name eq "MergerName"){
	$merger_name = "Undefined";
}

if($server == 1) {
	$URL_SERVER = "/m3/";
	$file_fix = "m3";
} elsif($server == 2) {
	$URL_SERVER = "/sotse/";
	$file_fix = "sotse";
}

#---------------------

sub get_steal_wait {
	my $steal_wait = 3600;
	my $steal_time = time;
	
	$steal_time += $steal_wait; # if stealer can't be found, click for 1k seconds
	
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}steal.php");
	my $content = $mech->content();
	
	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$steal_wait = 0;

	if($content =~ m/recover/) {
		$content = $mech->content(); # (USELESS?)
		$content =~ m/(Take.*This)/s;
		
		$b = $1;
		$b =~ s/<.*?>//sg;
		$b =~ m/(Take.*seconds)/s;
		$b = $1;
		$b =~ m/(for.*seconds)/s;
		$b = $1;
		$b =~ s/for//sg;
		$b =~ s/seconds//sg;
		$b =~ s/<.*?>//sg;
		$b =~ s/,//g;
		
		$steal_wait = $b;
		
		say "In recover, gotta wait $steal_wait seconds before I can steal...\n";
		
		$steal_time = time;
		$steal_time += $steal_wait;
	}
	
	return $steal_wait;
}

sub merge_test {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();

	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content =~ s/\s//sg;
	$content =~ s/inactive/  BLOCKER /sgi; 
	$content =~ s/EMERGETOBETHEONE!/  STOPPER /sg; 
	$content =~ s/(.*)( BLOCKER )//sg; #remove before
	$content =~ s/  STOPPER .*//sg; #remove after
	$content =~ s/"//sg;
	$content =~ s/<//sg;
	$content =~ s/>//sg;
	$content =~ s/optionvalue=//sg;
	$content =~ s!/option!!sg;
	$content =~ s!/select/tdtdinputtype=submitname=actionvalue=!!sg;
	my $merge_list = $content;
	
	if($merge_list =~ m/$merger_name/i) {
		say "MERGER WITH NAME '$merger_name' AVAILABLE!!!";
		
		return (1, get_merge_id());
	} else {
		say "No merger with name '$merger_name' available.";

		return (0, undef);
	}
}

sub get_merge_id {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	$content = $mech->content();
	
	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}
	
	$content =~ s/inactive+/  BLOCKER /sgi; 
	$content =~ s/EMERGE TO BE THE ONE!/  STOPPER /sg; 
	$content =~ s/(.*)( BLOCKER )//sg; #remove before
	$content =~ s/  STOPPER .*//sg; #remove after
	$content =~ s/lady//sgi;
	$content =~ s/dame//sgi;
	$content =~ s/masteries//sgi;
	$content =~ s/judgette//sgi;
	$content =~ s/cannones//sgi;
	$content =~ s/counsel//sgi;
	$content =~ s/baroness//sgi;
	$content =~ s/mayoress//sgi;
	$content =~ s/viscountess//sgi;
	$content =~ s/earless//sgi;
	$content =~ s/countess//sgi;
	$content =~ s/marchioness//sgi;
	$content =~ s/generalia//sgi;
	$content =~ s/duchess//sgi;
	$content =~ s/princess//sgi;
	$content =~ s/queen//sgi;
	$content =~ s/lord//sgi;
	$content =~ s/sir//sgi;
	$content =~ s/master//sgi;
	$content =~ s/judge//sgi;
	$content =~ s/cannoner//sgi;
	$content =~ s/council//sgi;
	$content =~ s/baron//sgi;	
	$content =~ s/major//sgi;
	$content =~ s/viscount//sgi;
	$content =~ s/earl//sgi;
	$content =~ s/count//sgi;	
	$content =~ s/marquess//sgi;
	$content =~ s/general//sgi;
	$content =~ s/duke//sgi;
	$content =~ s/prince//sgi;
	$content =~ s/king//sgi;
	$content =~ s/admin//sgi;
	$content =~ s/cop//sgi;
	$content =~ s/mod//sgi;
	$content =~ s/support//sgi;
	$content =~ s/demon//sgi;
	$content =~ s/danger//sgi;
	$content =~ s/untrust//sgi;
	$content =~ s/beggar//sgi;
	$content =~ s/criminal//sgi;
	$content =~ s/stealer//sgi;
	$content =~ s/helper//sgi;
	$content =~ s/<option value="/~/sgi;
	$content =~ s/\s//sgi;
	$content =~ s/$merger_name.*/@/sgi;
	$content =~ s/"//sgi;
	$content =~ s/>//sgi;
	$content =~ s/(.*)(~)//sg; #remove before
	$content =~ s/@.*//sg; #remove after
	$content =~ s/\s*$//;
	my $merge_id = $content;
	
	say $merge_id;

	return get_merge_name($merge_id);
}

sub get_merge_name($merge_id) {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();
	
	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content = $mech->content(); # (USELESS?)
	$content =~ s/(.*)($merge_id)//sg; #remove before
	$content =~ s~</option>.*~~sg; #remove after
	$content =~ s/"//sgi;
	$content =~ s/>//sgi;
	$content =~ s/\s*$//;
	
	$merge_name = $content; # SHOULD NOT BE GLOBAL
	
	return $content;
}

sub merge {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();
	
	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content = $mech->content(); # (USELESS?)
	
	say "Merging with: $merge_name";
	
	$mech->form_number(0);
	$mech->select("inactive", $merge_name);
	$mech->click_button('value' => 'EMERGE TO BE THE ONE!');
	
	$content = $mech->content();
	
	say "Successfully merged with: $merge_name";
	
	open(FILE, ">>$file_fix MERGERESULTS.txt") or die "failed to open file!!!!";
	print FILE "$content\n";
	close FILE;
}

sub steal {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net".$URL_SERVER."steal.php");
	my $content = $mech->content();
	
	if($content !~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content = $mech->content(); # (USELESS?)
	
	if($content =~ m/Freeplay/) { # steal only if we have freeplay
		$content = "<option>$steal_char.*?</option>";
		
		my $tmp = $mech->content();
		
		if($tmp =~ m/($content)/) {
			say "Stealer found";
		} else {
			say "Stealer not found! - not stealing!";
			return;
		}
		
		$tmp =~ m/($content)/s;
		$tmp = $1;
		$tmp =~ s/<.*?>//sg;

		print "Stealing from: $tmp";
		
		$mech->form_number(0);
		$mech->select("Opp", $tmp);
		$mech->click_button('value' => 'Steal Stats or Items');
		
		$content = $mech->content();
		$content =~ m/(sleepers.*This)/s;
		
		my $steal_rec = $1;

		$steal_rec =~ s/<.*?>//sg;
		$steal_rec =~ s/sleepers//sg;
		$steal_rec =~ s/This//sg;
		
		print $steal_rec;

		my ($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst) = localtime(time);
		my $actual_year = $year + 1900;
		my $actual_month = $month + 1;
		my $month_name = $MONTHS[$month];

		open(FILE, ">>$title$name $file_fix ~ $month_name $actual_year StealRecord.txt") or die "failed to open file!!!!";
		print FILE "[$day/$actual_month/$actual_year] ~ [$hour:$minute:$second] - you stole $steal_rec\n";
		close FILE;
	} else {
		say "Freeplay not detected, stealing cancelled...";
	}
}

sub low_level {
	sleep 0.5;

	#$mech->get("http://thenewlosthope.net${URL_SERVER}fight_control.php");
	$mech->get("http://thenewlosthope.net${URL_SERVER}world_control.php");
	my $content = $mech->content();
	
	if($content !~ m/Thief/) {
		sleep 10;
		exit;
	}

	$mech->form_number(1);
	$mech->click();

	my $all = $mech->content();
	
	# test for free upgrade
	if($all =~ m/Click here to upgrade/) {
		sleep 0.5;
		
		$mech->form_number(0);
		$mech->click();
		
		say "Free upgrade detected and cleared. Restarting";

		exit;
	}

	$all =~ m/(Min<br>.*monster)/s;
	$stat = $1;
	$stat =~ m/(\<br.*td\>)/;
	$stat = $1;
	$stat =~ s/<.*?>/:/sg;
	$stat =~ s/\.//g;
	#print $stat;

	my @stats = (split ":", $stat)[1, 2, 4..7];
	my %levels = (
		wd => undef,
		as => undef,
		ms => undef,
		def => undef,
		ar => undef,
		mr => undef
	);

	for my $key (keys %levels) {
		$levels{$key} = new Math::BigFloat do {
			shift @stats;
			s/,//sg;
		};
	}

	#cpms m2 only
	$levels{wd}->bdiv('603'); 
	$levels{as}->bdiv('554'); 
	$levels{ms}->bdiv('84'); 
	$levels{def}->bdiv('42'); 
	$levels{ar}->bdiv('57'); 
	$levels{mr}->bdiv('72'); 

	for my $level (values %levels) {
		$level->bfround(1);
	}

	$levels{as}->bmul('2.5'); # multiplier for correct AS
	$levels{wd}->bmul('2.5'); # multiplier for correct wd
	
	$levels{wd}->bdiv('2.5') if $char_type == 4;
	$levels{as}->bdiv('2.5') if $char_type == 5;
	
	
	given($char_type) {
		when(1) {
			printf('ASlevel: %.3e, DEFlevel: %.3e, MRlevel: %.3e',
				$levels{as}->bstr(),
				$levels{def}->bstr(),
				$levels{mr}->bstr()
			);
		}
	
		when(2) {
			printf('WDlevel: %.3e, ARlevel: %.3e, MRlevel: %.3e',
				$levels{wd}->bstr(),
				$levels{ar}->bstr(),
				$levels{mr}->bstr()
			);
		}

		when(3) {
			printf('ASlevel: %.3e, ARlevel: %.3e, MRlevel: %.3e',
				$levels{as}->bstr(),
				$levels{ar}->bstr(),
				$levels{mr}->bstr()
			);
		}
		
		when(4) {
			printf('WDlevel: %.3e, ARlevel: %.3e$8',
				$levels{wd}->bstr(),
				$levels{ar}->bstr()
			);
		}
		
		when(5) {
			printf('ASlevel: %.3e, MRlevel: %.3e$8',
				$levels{as}->bstr(),
				$levels{mr}->bstr()
			);
		}

		when(6) {
			printf('WDlevel: %.3e, MSlevel: %.3e, ARlevel: %.3e',
				$levels{wd}->bstr(),
				$levels{ms}->bstr(),
				$levels{ar}->bstr()
			);
		}
	}

	my @possible_levels = do {
		given($char_type) {
			when(1) { @levels{as, def, mr}   } # for agi mage
			when(2) { @levels{wd, ar,  mr}   } # for fighter
			when(3) { @levels{as, ar,  mr}   } # for mage
			when(4) { @levels{ws, ar}, undef } # for pure fighter
			when(5) { @levels{as, mr}, undef } # for pure mage
			when(6) { @levels{wd, ms,  ar}   }
		}
	};
	my $level = (grep {defined} sort {$a <=> $b} @possible_levels)[0]->copy(); # find minimum value

	printf " --> Skeleton level: %.3e\n", $level->bstr();
}

sub LowFight($level) {
# setup fight
	my($cpm);
	$parsed = 0;
	while ($parsed == 0){
		sleep(0.5);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."fight_control.php");
		$a = $mech->content();
		if ($a =~ m/Skeleton/){
			$parsed = 1;
		}else{
			sleep(10);
			exit();
		}
	}
	$mech->form_number(2);
	$mech->field("Difficulty", $level);
	$mech->click();
	$mech->form_number(1);
	$mech->click();
	$a = $mech->content();
	$a =~ m/(You win.*exp )/;
	$a =~ m/(battle)/;
	$a =~ m/(You have been jailed for violating our rules)/;
	#print $1 . "\n";
	#my $antal = 500 + int rand (500);
	$steal_antal = new Math::BigFloat $steal_antal;
	$steal_antal->bdiv($loop_wait);
	$steal_antal->bstr();
	$steal_antal->bfround(1);
	$antal = $steal_antal;
	my $jail;

# REPEAT:
	while($antal > 0) {
		sleep($loop_wait); #default = 0.3
		$antal = $antal -1;
		$mech->reload();
		$a = $mech->content();
		$b = $a;
		$c = $a;
# KILLED
		if($a =~ m/(been.*slain)/) {
			print "ERROR - TOO HIGH MONSTER LEVEL! - you were slain!\n";exit(0);
		}
# JAILED
		if ($b =~ m/jail time.*<br>/) {
			print"You have been Jailed - Sleep 5 seconds.\n";
			sleep(5);
		}

# LOGGED OUT

		if ($c =~ m/logged/) {
			print "LOGGED OUT! sleeping for 5 seconds before restart!\n";
			sleep(5);
			exit();
		}


# STEAL TIME? then exit to steal
		if ($antal <= 0) {
			sleep(5);
			print "Waiting last few seconds before steal\n";
			exit();
		}
		
		
		$a = $b;
		($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst) = localtime(time);
		$a =~ m/(You win.*exp )/;
		$a =~ m/(The battle tied.)/;
		print "$antal :[$hour:$minute:$second]: " . $1 . "\n";



# level up if necessary
		if ($b =~ m/(Congra.*exp)/) {
			if ($char_type == 1) {&Levelupagimage; return();}
			if ($char_type == 2) {&Levelupfighter; return();}
			if ($char_type == 3) {&Levelupmage; return();}
			if ($char_type == 4) {&Leveluppurefighter; return();}
			if ($char_type == 5) {&Leveluppuremage; return();}
			if ($char_type == 6) {&Levelupcontrafighter; return();}
		}
	}
}

sub Autolevelup {
	$parsed = 0; while ($parsed == 0) {sleep(0.5);
	$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
	$a = $mech->content();
	if ($a =~ m/Parsed/){
		$parsed = 1;
	}else{
			sleep(10);
			exit();
		}
	}
	$a = $mech->content();
	$b = $mech->content();

	my $ActualLevel = $MyLev;
	$b =~ m/(Level : .*Exp :)/;
	$b = $1;
	$b =~ s/<\/td> .*//si;
	$b =~ s/Level : //si;
	$ActualLevel = $b;
	
	if($char_type == 6){
		$alternate = 75;
	}
	while ($a =~ m/(Congra.*exp)/){
		if ($char_type == 1) {if ($agilmagecount == 6){
								$autolevel = "Agility";
								$agilmagecount = $agilmagecount - 1;
							}elsif($agilmagecount >= 4){
								$autolevel = "Intelligence";
								$agilmagecount = $agilmagecount - 1;
							}elsif($agilmagecount >= 0){
								$autolevel = "Concentration";
								$agilmagecount = $agilmagecount - 1;
							}
		}
		if ($char_type == 2) {if ($fightercount == 3){
								$autolevel = "Dexterity";
								$fightercount = $fightercount - 1;
							}elsif($fightercount >= 2){
								$autolevel = "Concentration";
								$fightercount = $fightercount - 1;
							}elsif($fightercount >= 0){
								$autolevel = "Strength";
								$fightercount = $fightercount - 1;
							}
		}
		if ($char_type == 3) {if ($magecount == 3){
								$autolevel = "Concentration";
								$magecount = $magecount - 1;
							}elsif($magecount >= 2){
								$autolevel = "Dexterity";
								$magecount = $magecount - 1;
							}elsif($magecount >= 0){
								$autolevel = "Intelligence";
								$magecount = $magecount - 1;
							}
		}
		if ($char_type == 4) {if ($purefightercount == 3){
								$autolevel = "Strength";
								$purefightercount = $purefightercount - 1;
							}elsif($purefightercount >= 0){
								$autolevel = "Dexterity";
								$purefightercount = $purefightercount - 1;
							}
		}		
		if ($char_type == 5) {if ($puremagecount >= 3){
								$autolevel = "Intelligence";
								$puremagecount = $puremagecount - 1;
							}elsif($puremagecount >= 0){
								$autolevel = "Concentration";
								$puremagecount = $puremagecount - 1;
							}
		}
		if ($char_type == 6) {if (($cfcount == 17) || ($cfcount == 14) || ($cfcount == 11)){
								$autolevel = "Strength";
								$cfcount = $cfcount - 1;
							}elsif(($cfcount == 16) || ($cfcount == 13) || ($cfcount == 10) || ($cfcount == 8)){
								$autolevel = "Dexterity";
								$cfcount = $cfcount - 1;
							}elsif(($cfcount == 15) || ($cfcount == 12) || ($cfcount == 9) || ($cfcount == 7) || ($cfcount == 6) || ($cfcount == 5) || ($cfcount == 4) || ($cfcount == 3) || ($cfcount == 2) || ($cfcount == 1)){
								$autolevel = "Contravention";
								$cfcount = $cfcount - 1;
							}
		}
		if ($char_type == 7) {if ($purebuild >= 0){
								$autolevel = "Strength";
								$purebuild = $purebuild - 1;
							}
		}
		if ($char_type == 8) {if ($purebuild >= 0){
								$autolevel = "Dexterity";
								$purebuild = $purebuild - 1;
							}
		}
		if ($char_type == 9) {if ($purebuild >= 0){
								$autolevel = "Agility";
								$purebuild = $purebuild - 1;
							}
		}
		if ($char_type == 10) {if ($purebuild >= 0){
								$autolevel = "Intelligence";
								$purebuild = $purebuild - 1;
							}
		}
		if ($char_type == 11) {if ($purebuild >= 0){
								$autolevel = "Concentration";
								$purebuild = $purebuild - 1;
							}
		}
		if ($char_type == 12) {if ($purebuild >= 0){
								$autolevel = "Contravention";
								$purebuild = $purebuild - 1;
							}
		}

	$mech->form_number(1);
	if ($a =~ m/Freeplay/i){	
		$mech->field("Stats", $autolevel);
		$mech->click_button('name' => 'Stats', 'value' => $autolevel);
	}else{
		if($MyLev <= $masslevel){
				$mech->field("cStats", $autolevel);
				$mech->click_button('name' => 'cStats', 'value' => $autolevel);
		}
		elsif($MyLev >= $masslevel){
			$mech->field("Stats", $autolevel);
			$mech->click_button('name' => 'Stats', 'value' => $autolevel);			
		}
	}
		$a = $mech->content();
		$b = $mech->content();
		$c = $mech->content();
		$b =~ m/(Level : .*Exp :)/;
		$b = $1;
		$b =~ s/<\/td> .*//si;
		$b =~ s/Level : //si;
		$b =~ s/,//si;
		if ($b =~ m/m1/is){
			$b =~ s/m1/000000/si;
		}
		if ($b =~ m/m2/is){
			$b =~ s/m2/000000000000/si;
		}
		if ($b =~ m/m3/is){
			$b =~ s/m3/000000000000000000/si;
		}
		$c =~ m/(You leveled up .* levels!)/;
		$c = $1;
		$c =~ s/,//si;
		$c =~ s/\D//gsi;
		$ActualLevel = $b + $c;
		my $FormatedLev = $ActualLevel;
		while($FormatedLev =~ m/([0-9]{4})/){
		my $temp1 = reverse $FormatedLev;
		$temp1 =~ s/(?<=(\d\d\d))(?=(\d))/,/;
		$FormatedLev = reverse $temp1;
	}
	
	print "[Level : $FormatedLev][$alternate] You Auto-Leveled " . $autolevel . "\n";
			$alternate = $alternate - 1;
		if($alternate == 0){
			&TestShop;
			exit();
		}
		if($agilmagecount == 0){
			$agilmagecount = 6;
		}
		if($fightercount == 0){
			$fightercount = 3;
		}
		if($magecount == 0){
			$magecount = 3;
		}
		if($purefightercount == 0){
			$purefightercount = 3;
		}
		if($puremagecount == 0){
			$puremagecount = 3;
		}
		if($cfcount == 0){
			$cfcount = 17;
		}
		if($purebuild == 0){
			$purebuild = 180;
		}
		if($ActualLevel >= $max_level){
			print "Max level reached, exiting.\n";
			exit();
		}
		sleep(0.5);
	}
}

sub CPMlevel {
	$parsed = 0; 
	while ($parsed == 0){
		sleep(0.5);
#		$mech->get("http://thenewlosthope.net".$URL_SERVER."fight_control.php");
		$mech->get("http://thenewlosthope.net".$URL_SERVER."world_control.php");
		$a = $mech->content();
		if ($a =~ m/Thief/){
		$parsed = 1;
		}else{
			sleep(10);
			exit();
		}
	}
	$mech->form_number(1);
	$mech->click();
	my $all = $mech->content();
	#test for free upgrade
	if ($all =~ m/Click here to upgrade/) {
		sleep(0.5); $mech->form_number(0);$mech->click();
		print "Free upgrade detected and cleared. Restarting\n";
		exit();
	}
	$all =~ m/(Min<br>.*monster)/s;
	$stat = $1;
	$stat =~ m/(\<br.*td\>)/;
	$stat = $1;
	$stat =~ s/<.*?>/:/sg;
	$stat =~ s/\.//g;
	#print $stat;
	my @stats = split(/:/, $stat);
	$stats[1] =~ s/,//sg;
	$stats[2] =~ s/,//sg;
	$stats[4] =~ s/,//sg;
	$stats[5] =~ s/,//sg;
	$stats[6] =~ s/,//sg;
	$stats[7] =~ s/,//sg;

	$wdlevel = new Math::BigFloat $stats[1];
	$aslevel = new Math::BigFloat $stats[2];
	$mslevel = new Math::BigFloat $stats[4];
	$deflevel = new Math::BigFloat $stats[5];
	$arlevel = new Math::BigFloat $stats[6];
	$mrlevel = new Math::BigFloat $stats[7];

	#cpms m2 only
	$wdlevel->bdiv('1661622');
	$aslevel->bdiv('1877897');
	$mslevel->bdiv('3028631');
	$deflevel->bdiv('1817170');
	$arlevel->bdiv('363482.2');
	$mrlevel->bdiv('363497.2');

	$wdlevel->bfround(1);
	$aslevel->bfround(1);
	$mslevel->bfround(1);
	$deflevel->bfround(1);
	$arlevel->bfround(1);
	$mrlevel->bfround(1);

	$aslevel->bmul('2.5'); # multiplier for correct AS
	$wdlevel->bmul('2.5'); #multiplier for correct wd
if($char_type ==4){
	$wdlevel->bdiv('2.5');
}
if($char_type ==5){
	$aslevel->bdiv('2.5');
}
if($char_type == 1) {
	printf "ASlevel: %.3e", $aslevel->bstr();
	printf ", DEFlevel: %.3e", $deflevel->bstr();
	printf ", MRlevel: %.3e", $mrlevel->bstr();
	}
if($char_type == 2) {
	printf "WDlevel: %.3e", $wdlevel->bstr();
	printf ", ARlevel: %.3e", $arlevel->bstr();
	printf ", MRlevel: %.3e", $mrlevel->bstr();
	}
if($char_type == 3) {
	printf "ASlevel: %.3e", $aslevel->bstr();
	printf ", ARlevel: %.3e", $arlevel->bstr();
	printf ", MRlevel: %.3e", $mrlevel->bstr();
	}
if($char_type == 4) {
	printf "WDlevel: %.3e", $wdlevel->bstr();
	printf ", ARlevel: %.3e", $arlevel->bstr();
	}
if($char_type == 5) {
	printf "ASlevel: %.3e", $aslevel->bstr();
	printf ", MRlevel: %.3e", $mrlevel->bstr();
	}
if($char_type == 6) {
	printf "WDlevel: %.3e", $wdlevel->bstr();
	printf ", MSlevel: %.3e", $mslevel->bstr();
	printf ", ARlevel: %.3e", $arlevel->bstr();
	}
	
	# for agi mage:
	if ($char_type == 1) {
	$level = $aslevel->copy();
	if ($level >= $deflevel) {$level = $deflevel->copy();}
	if ($level >= $mrlevel) {$level = $mrlevel->copy();}
	}
	# for fighter
	if ($char_type == 2) {
	$level = $wdlevel->copy();
	if ($level >= $arlevel) {$level = $arlevel->copy();}
	if ($level >= $mrlevel) {$level = $mrlevel->copy();}
	}
	# for mage
	if ($char_type == 3) {
	$level = $aslevel->copy();
	if ($level >= $arlevel) {$level = $arlevel->copy();}
	if ($level >= $mrlevel) {$level = $mrlevel->copy();}
	}
	# for pure fighter
	if ($char_type == 4) {
	$level = $wdlevel->copy();
	if ($level >= $arlevel) {$level = $arlevel->copy();}
	}
	# for pure mage
	if ($char_type == 5) {
	$level = $aslevel->copy();
	if ($level >= $mrlevel) {$level = $mrlevel->copy();}
	}
	if ($char_type == 6) {
	$level = $wdlevel->copy();
	if ($level >= $mslevel) {$level = $mslevel->copy();}
	if ($level >= $arlevel) {$level = $arlevel->copy();}
	}

	printf " --> CPM level: %.3e\n", $level->bstr();
}

sub Fight($level) {
# setup fight
	my($cpm);
	$parsed = 0;
	while ($parsed == 0){
		sleep(0.5);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."fight_control.php");
		$a = $mech->content();
		if ($a =~ m/Skeleton/){
			$parsed = 1;
		}else{
			sleep(10);
			exit();
		}
	}
	$mech->form_number(2);
	$mech->field("Difficulty", $level);
	$mech->click();
	$cpm = $mech->content();
	$cpm =~ m/(\<option\>208.*Duke)/;
	$cpm = $1;
	$cpm =~ s/ - Shadowlord Duke//g;
	$cpm =~ s/\>209/\>/;
	$cpm =~ s/<.*?>//g;
	print $cpm . "\n";
	$mech->form_number(1);
	$mech->select("Monster", $cpm);
	$mech->click();
	$a = $mech->content();
	$a =~ m/(You win.*exp )/;
	$a =~ m/(battle)/;
	$a =~ m/(You have been jailed for violating our rules)/;
	#print $1 . "\n";
	#my $antal = 500 + int rand (500);
	$steal_antal = new Math::BigFloat $steal_antal;
	$steal_antal->bdiv($loop_wait);
	$steal_antal->bstr();
	$steal_antal->bfround(1);
	$antal = $steal_antal;
	my $jail;
	my $averagecountdown = 900;
# REPEAT:
	while($antal > 0) {
		sleep($loop_wait); #default = 0.3
		$antal = $antal -1;
		$mech->reload();
		if($a =~ m/(The battle tied.)/){
			#don't change $waitdiv or $averagescountdown
		}else{
			$averagecountdown = $averagecountdown - 1;
			$waitdiv = $waitdiv + $loop_wait;
		}
		$a = $mech->content();
		$b = $a;
		$c = $a;
		if ($averagecountdown >= 1){
			my $exper = $a;
			$exper =~ m/(You win.*exp )/;
			my $exper1 = $1;
			$exper1 =~ s/,//sg;
			$exper1 =~ s/You//s;
			$exper1 =~ s/win//s;
			$exper1 =~ s/exp//s;
			$exper1 =~ s/\s//sg;
			my $exper2 = new Math::BigFloat $exper1;
			if($a =~ m/(The battle tied.)/){
				$exper2 = 0;
			}
			$exper3 = $exper2 + $exper3;
			my $gold = $a;
			$gold =~ m/(exp and.*gold.)/;
			my $gold1 = $1;
			$gold1 =~ s/exp//s;
			$gold1 =~ s/and//s;
			$gold1 =~ s/,//sg;
			$gold1 =~ s/gold//s;
			$gold1 =~ s/\.//s;
			$gold1 =~ s/\s//sg;
			my $gold2 = new Math::BigFloat $gold1;
			if($a =~ m/(The battle tied.)/){
				$gold2 = 0;
			}
			$gold3 = $gold2 + $gold3;
			if($a =~ m/(The battle tied.)/){
				#don't change $reloadcount
			}else{
				$reloadcount = $reloadcount + 1;
			}
			if($waitdiv >= 300.0){
				$reloadcount = ($reloadcount / $waitdiv * 300);
				$experaverage = ($exper3 / $reloadcount);
				$experaverage =~ s/\..*//s; #remove after
				$goldaverage = ($gold3 / $reloadcount);
				$goldaverage =~ s/\..*//s; #remove after
				$waitdiv = 0;
				$exper3 = 0;
				$gold3 =0;
				$reloadcount = 0;
				my $expersecond = new Math::BigFloat $experaverage;
				my $experminute = new Math::BigFloat $experaverage;
				my $experhour = new Math::BigFloat $experaverage;
				my $experday = new Math::BigFloat $experaverage;
				$experminute = ($experminute * 60);
				$experhour = ($experhour * 3600);
				$experday = ($experday * 86400);
				my $goldsecond = new Math::BigFloat $goldaverage;
				my $goldminute = new Math::BigFloat $goldaverage;
				my $goldhour = new Math::BigFloat $goldaverage;
				my $goldday = new Math::BigFloat $goldaverage;
				$goldminute = ($goldminute * 60);
				$goldhour = ($goldhour * 3600);
				$goldday = ($goldday * 86400);
				my $experlength1 = length($experaverage);
				my $experlength2 = length($expersecond);
				my $experlength3 = length($experminute);
				my $experlength4 = length($experhour);
				my $experlength5 = length($experday);
				my $Nextlength = length($Nextlevel);
				my $goldlength1 = length($goldaverage);
				my $goldlength2 = length($goldsecond);
				my $goldlength3 = length($goldminute);
				my $goldlength4 = length($goldhour);
				my $goldlength5 = length($goldday);
				#Time to level
				my $Nextleveltime = new Math::BigFloat $Nextlevel / $experaverage;
				$datestring = localtime();
				my $epoc = time();
				$epoc = $epoc + $Nextleveltime; 
				$datestring = strftime "%x %H:%M:%S", localtime($epoc);
				
				#expersecond
				if(($experlength2 >= 7) && ($experlength2 <= 12)){
					$expersecond =~ s/([0-9]{6})$/ M1/g;
				}
				if(($experlength2 >= 13) && ($experlength2 <= 18)){
					$expersecond =~ s/([0-9]{12})$/ M2/g;
				}
				if(($experlength2 >= 19) && ($experlength2 <= 24)){
					$expersecond =~ s/([0-9]{18})$/ M3/g;
				}
				if(($experlength2 >= 25) && ($experlength2 <= 30)){
					$expersecond =~ s/([0-9]{24})$/ M4/g;
				}
				if(($experlength2 >= 31) && ($experlength2 <= 36)){
					$expersecond =~ s/([0-9]{30})$/ M5/g;
				}
				if(($experlength2 >= 37) && ($experlength2 <= 42)){
					$expersecond =~ s/([0-9]{36})$/ M6/g;
				}
				if(($experlength2 >= 43) && ($experlength2 <= 48)){
					$expersecond =~ s/([0-9]{42})$/ M7/g;
				}
				if(($experlength2 >= 49) && ($experlength2 <= 54)){
					$expersecond =~ s/([0-9]{48})$/ M8/g;
				}
				if(($experlength2 >= 55) && ($experlength2 <= 60)){
					$expersecond =~ s/([0-9]{54})$/ M9/g;
				}	
				#experminute
				if(($experlength3 >= 7) && ($experlength3 <= 12)){
					$experminute =~ s/([0-9]{6})$/ M1/g;
				}
				if(($experlength3 >= 13) && ($experlength3 <= 18)){
					$experminute =~ s/([0-9]{12})$/ M2/g;
				}
				if(($experlength3 >= 19) && ($experlength3 <= 24)){
					$experminute =~ s/([0-9]{18})$/ M3/g;
				}
				if(($experlength3 >= 25) && ($experlength3 <= 30)){
					$experminute =~ s/([0-9]{24})$/ M4/g;
				}
				if(($experlength3 >= 31) && ($experlength3 <= 36)){
					$experminute =~ s/([0-9]{30})$/ M5/g;
				}
				if(($experlength3 >= 37) && ($experlength3 <= 42)){
					$experminute =~ s/([0-9]{36})$/ M6/g;
				}
				if(($experlength3 >= 43) && ($experlength3 <= 48)){
					$experminute =~ s/([0-9]{42})$/ M7/g;
				}
				if(($experlength3 >= 49) && ($experlength3 <= 54)){
					$experminute =~ s/([0-9]{48})$/ M8/g;
				}
				if(($experlength3 >= 55) && ($experlength3 <= 60)){
					$experminute =~ s/([0-9]{54})$/ M9/g;
				}	
				#experhour
				if(($experlength4 >= 7) && ($experlength4 <= 12)){
					$experhour =~ s/([0-9]{6})$/ M1/g;
				}
				if(($experlength4 >= 13) && ($experlength4 <= 18)){
					$experhour =~ s/([0-9]{12})$/ M2/g;
				}
				if(($experlength4 >= 19) && ($experlength4 <= 24)){
					$experhour =~ s/([0-9]{18})$/ M3/g;
				}
				if(($experlength4 >= 25) && ($experlength4 <= 30)){
					$experhour =~ s/([0-9]{24})$/ M4/g;
				}
				if(($experlength4 >= 31) && ($experlength4 <= 36)){
					$experhour =~ s/([0-9]{30})$/ M5/g;
				}
				if(($experlength4 >= 37) && ($experlength4 <= 42)){
					$experhour =~ s/([0-9]{36})$/ M6/g;
				}
				if(($experlength4 >= 43) && ($experlength4 <= 48)){
					$experhour =~ s/([0-9]{42})$/ M7/g;
				}
				if(($experlength4 >= 49) && ($experlength4 <= 54)){
					$experhour =~ s/([0-9]{48})$/ M8/g;
				}
				if(($experlength4 >= 55) && ($experlength4 <= 60)){
					$experhour =~ s/([0-9]{54})$/ M9/g;
				}	
				#experday
				if(($experlength5 >= 7) && ($experlength5 <= 12)){
					$experday =~ s/([0-9]{6})$/ M1/g;
				}
				if(($experlength5 >= 13) && ($experlength5 <= 18)){
					$experday =~ s/([0-9]{12})$/ M2/g;
				}
				if(($experlength5 >= 19) && ($experlength5 <= 24)){
					$experday =~ s/([0-9]{18})$/ M3/g;
				}
				if(($experlength5 >= 25) && ($experlength5 <= 30)){
					$experday =~ s/([0-9]{24})$/ M4/g;
				}
				if(($experlength5 >= 31) && ($experlength5 <= 36)){
					$experday =~ s/([0-9]{30})$/ M5/g;
				}
				if(($experlength5 >= 37) && ($experlength5 <= 42)){
					$experday =~ s/([0-9]{36})$/ M6/g;
				}
				if(($experlength5 >= 43) && ($experlength5 <= 48)){
					$experday =~ s/([0-9]{42})$/ M7/g;
				}
				if(($experlength5 >= 49) && ($experlength5 <= 54)){
					$experday =~ s/([0-9]{48})$/ M8/g;
				}
				if(($experlength5 >= 55) && ($experlength5 <= 60)){
					$experday =~ s/([0-9]{54})$/ M9/g;
				}	
				#goldsecond
				if(($goldlength2 >= 7) && ($goldlength2 <= 12)){
					$goldsecond =~ s/([0-9]{6})$/ M1/g;
				}
				if(($goldlength2 >= 13) && ($goldlength2 <= 18)){
					$goldsecond =~ s/([0-9]{12})$/ M2/g;
				}
				if(($goldlength2 >= 19) && ($goldlength2 <= 24)){
					$goldsecond =~ s/([0-9]{18})$/ M3/g;
				}
				if(($goldlength2 >= 25) && ($goldlength2 <= 30)){
					$goldsecond =~ s/([0-9]{24})$/ M4/g;
				}
				if(($goldlength2 >= 31) && ($goldlength2 <= 36)){
					$goldsecond =~ s/([0-9]{30})$/ M5/g;
				}
				if(($goldlength2 >= 37) && ($goldlength2 <= 42)){
					$goldsecond =~ s/([0-9]{36})$/ M6/g;
				}
				if(($goldlength2 >= 43) && ($goldlength2 <= 48)){
					$goldsecond =~ s/([0-9]{42})$/ M7/g;
				}
				if(($goldlength2 >= 49) && ($goldlength2 <= 54)){
					$goldsecond =~ s/([0-9]{48})$/ M8/g;
				}
				if(($goldlength2 >= 55) && ($goldlength2 <= 60)){
					$goldsecond =~ s/([0-9]{54})$/ M9/g;
				}		
				#goldminute
				if(($goldlength3 >= 7) && ($goldlength3 <= 12)){
					$goldminute =~ s/([0-9]{6})$/ M1/g;
				}
				if(($goldlength3 >= 13) && ($goldlength3 <= 18)){
					$goldminute =~ s/([0-9]{12})$/ M2/g;
				}
				if(($goldlength3 >= 19) && ($goldlength3 <= 24)){
					$goldminute =~ s/([0-9]{18})$/ M3/g;
				}
				if(($goldlength3 >= 25) && ($goldlength3 <= 30)){
					$goldminute =~ s/([0-9]{24})$/ M4/g;
				}
				if(($goldlength3 >= 31) && ($goldlength3 <= 36)){
					$goldminute =~ s/([0-9]{30})$/ M5/g;
				}
				if(($goldlength3 >= 37) && ($goldlength3 <= 42)){
					$goldminute =~ s/([0-9]{36})$/ M6/g;
				}
				if(($goldlength3 >= 43) && ($goldlength3 <= 48)){
					$goldminute =~ s/([0-9]{42})$/ M7/g;
				}
				if(($goldlength3 >= 49) && ($goldlength3 <= 54)){
					$goldminute =~ s/([0-9]{48})$/ M8/g;
				}
				if(($goldlength3 >= 55) && ($goldlength3 <= 60)){
					$goldminute =~ s/([0-9]{54})$/ M9/g;
				}			
				#goldhour
				if(($goldlength4 >= 7) && ($goldlength4 <= 12)){
					$goldhour =~ s/([0-9]{6})$/ M1/g;
				}
				if(($goldlength4 >= 13) && ($goldlength4 <= 18)){
					$goldhour =~ s/([0-9]{12})$/ M2/g;
				}
				if(($goldlength4 >= 19) && ($goldlength4 <= 24)){
					$goldhour =~ s/([0-9]{18})$/ M3/g;
				}
				if(($goldlength4 >= 25) && ($goldlength4 <= 30)){
					$goldhour =~ s/([0-9]{24})$/ M4/g;
				}
				if(($goldlength4 >= 31) && ($goldlength4 <= 36)){
					$goldhour =~ s/([0-9]{30})$/ M5/g;
				}
				if(($goldlength4 >= 37) && ($goldlength4 <= 42)){
					$goldhour =~ s/([0-9]{36})$/ M6/g;
				}
				if(($goldlength4 >= 43) && ($goldlength4 <= 48)){
					$goldhour =~ s/([0-9]{42})$/ M7/g;
				}
				if(($goldlength4 >= 49) && ($goldlength4 <= 54)){
					$goldhour =~ s/([0-9]{48})$/ M8/g;
				}
				if(($goldlength4 >= 55) && ($goldlength4 <= 60)){
					$goldhour =~ s/([0-9]{54})$/ M9/g;
				}		
				#goldday
				if(($goldlength5 >= 7) && ($goldlength5 <= 12)){
					$goldday =~ s/([0-9]{6})$/ M1/g;
				}
				if(($goldlength5 >= 13) && ($goldlength5 <= 18)){
					$goldday =~ s/([0-9]{12})$/ M2/g;
				}
				if(($goldlength5 >= 19) && ($goldlength5 <= 24)){
					$goldday =~ s/([0-9]{18})$/ M3/g;
				}
				if(($goldlength5 >= 25) && ($goldlength5 <= 30)){
					$goldday =~ s/([0-9]{24})$/ M4/g;
				}
				if(($goldlength5 >= 31) && ($goldlength5 <= 36)){
					$goldday =~ s/([0-9]{30})$/ M5/g;
				}
				if(($goldlength5 >= 37) && ($goldlength5 <= 42)){
					$goldday =~ s/([0-9]{36})$/ M6/g;
				}
				if(($goldlength5 >= 43) && ($goldlength5 <= 48)){
					$goldday =~ s/([0-9]{42})$/ M7/g;
				}
				if(($goldlength5 >= 49) && ($goldlength5 <= 54)){
					$goldday =~ s/([0-9]{48})$/ M8/g;
				}
				if(($goldlength5 >= 55) && ($goldlength5 <= 60)){
					$goldday =~ s/([0-9]{54})$/ M9/g;
				}
				#Nextlevel				
				if(($Nextlength >= 7) && ($Nextlength <= 12)){
					$Nextlevel =~ s/([0-9]{6})$/ M1/g;
				}
				if(($Nextlength >= 13) && ($Nextlength <= 18)){
					$Nextlevel =~ s/([0-9]{12})$/ M2/g;
				}
				if(($Nextlength >= 19) && ($Nextlength <= 24)){
					$Nextlevel=~ s/([0-9]{18})$/ M3/g;
				}
				if(($Nextlength >= 25) && ($Nextlength <= 30)){
					$Nextlevel=~ s/([0-9]{24})$/ M4/g;
				}
				if(($Nextlength >= 31) && ($Nextlength <= 36)){
					$Nextlevel =~ s/([0-9]{30})$/ M5/g;
				}
				if(($Nextlength >= 37) && ($Nextlength <= 42)){
					$Nextlevel =~ s/([0-9]{36})$/ M6/g;
				}
				if(($Nextlength >= 43) && ($Nextlength <= 48)){
					$Nextlevel =~ s/([0-9]{42})$/ M7/g;
				}
				if(($Nextlength >= 49) && ($Nextlength <= 54)){
					$Nextlevel =~ s/([0-9]{48})$/ M8/g;
				}
				if(($Nextlength >= 55) && ($Nextlength <= 60)){
					$Nextlevel =~ s/([0-9]{54})$/ M9/g;
				}	
				
				while($experaverage =~ m/([0-9]{4})/){
					my $temp = reverse $experaverage;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$experaverage = reverse $temp;
				}
				while($expersecond =~ m/([0-9]{4})/){
					my $temp = reverse $expersecond;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$expersecond = reverse $temp;
				}
				while($experminute =~ m/([0-9]{4})/){
					my $temp = reverse $experminute;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$experminute = reverse $temp;
				}
				while($experhour =~ m/([0-9]{4})/){
					my $temp = reverse $experhour;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$experhour = reverse $temp;
				}
				while($experday =~ m/([0-9]{4})/){
					my $temp = reverse $experday;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$experday = reverse $temp;
				}
				while($goldaverage =~ m/([0-9]{4})/){
					my $temp = reverse $goldaverage;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$goldaverage = reverse $temp;
				}
				while($goldsecond =~ m/([0-9]{4})/){
					my $temp = reverse $goldsecond;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$goldsecond = reverse $temp;
				}
				while($goldminute =~ m/([0-9]{4})/){
					my $temp = reverse $goldminute;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$goldminute = reverse $temp;
				}		
				while($goldhour =~ m/([0-9]{4})/){
					my $temp = reverse $goldhour;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$goldhour = reverse $temp;
				}
				while($goldday =~ m/([0-9]{4})/){
					my $temp = reverse $goldday;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$goldday = reverse $temp;
				}
				while($Nextlevel =~ m/([0-9]{4})/){
					my $temp = reverse $Nextlevel;
					$temp =~ s/(?<=(\d\d\d))(?=(\d))/,/;
					$Nextlevel = reverse $temp;
				}
				$experseconds = $expersecond;
				$experminutes = $experminute;
				$experhours = $experhour;
				$experdays = $experday;
				$goldseconds = $goldsecond;
				$goldminutes = $goldminute;
				$goldhours = $goldhour;
				$golddays = $goldday;
			}
		}
	if ($averagecountdown == 0){
		($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst) = localtime(time);
		$year = $year + 1900;
		$month = $month + 1;
		my $MonthName;
		if($month == 1){
			$MonthName = "January";
		}
		if($month == 2){
			$MonthName = "February";
		}
		if($month == 3){
			$MonthName = "March";
		}
		if($month == 4){
			$MonthName = "April";
		}
		if($month == 5){
			$MonthName = "May";
		}
		if($month == 6){
			$MonthName = "June";
		}
		if($month == 7){
			$MonthName = "July";
		}
		if($month == 8){
			$MonthName = "August";
		}
		if($month == 9){
			$MonthName = "September";
		}
		if($month == 10){
			$MonthName = "October";
		}
		if($month == 11){
			$MonthName = "November";
		}		
		if($month == 12){
			$MonthName = "December";
		}
		
		open(FILE, ">>$name $file_fix ~ $MonthName $year\.txt")
		or die "failed to open file!!!!";
		
		print FILE "MAIN STATUS FOR $name at $hour:$minute:$second~$day/$month/$year\n\n";
		print FILE "$name\'s current level is $Forlev\n";
		print FILE "You need $Nextlevel EXP to level\n";
		print FILE "You can expect to level on $datestring\n";
		printf FILE "Your current CPM level is : %.3e\n", $level->bstr();
		
		if($char_type == 1) {
			printf FILE "ASlevel: %.3e", $aslevel->bstr();
			printf FILE ", DEFlevel: %.3e", $deflevel->bstr();
			printf FILE ", MRlevel: %.3e\n\n", $mrlevel->bstr();
		}
		if($char_type == 2) {
			printf FILE "WDlevel: %.3e", $wdlevel->bstr();
			printf FILE ", ARlevel: %.3e", $arlevel->bstr();
			printf FILE ", MRlevel: %.3e\n\n", $mrlevel->bstr();
		}
		if($char_type == 3) {
			printf FILE "ASlevel: %.3e", $aslevel->bstr();
			printf FILE ", ARlevel: %.3e", $arlevel->bstr();
			printf FILE ", MRlevel: %.3e\n\n", $mrlevel->bstr();
		}
		if($char_type == 4) {
			printf FILE "WDlevel: %.3e", $wdlevel->bstr();
			printf FILE ", ARlevel: %.3e\n\n", $arlevel->bstr();
		}
		if($char_type == 5) {
			printf FILE "ASlevel: %.3e", $aslevel->bstr();
			printf FILE ", MRlevel: %.3e\n\n", $mrlevel->bstr();
		}
		if($char_type == 6) {
			printf FILE "WDlevel: %.3e", $wdlevel->bstr();
			printf FILE ", MSlevel: %.3e", $mslevel->bstr();
			printf FILE ", ARlevel: %.3e\n\n", $arlevel->bstr();
		}
		
		print FILE "SHOP STATUS FOR $name at $hour:$minute:$second~$day/$month/$year\n\n";
		print FILE "Current Max:		$SHOPMAX\n";
		print FILE "WEAPON:			$SHOPWEAP\n";
		print FILE "ATTACKSPELL:		$SHOPAS\n";
		print FILE "HEALSPELL:		$SHOPHS\n";
		print FILE "HELMET:			$SHOPHELM\n";
		print FILE "SHIELD:			$SHOPSHIELD\n";
		print FILE "AMULET:			$SHOPAMULET\n";
		print FILE "RING:			$SHOPRING\n";
		print FILE "ARMOR:			$SHOPARMOR\n";
		print FILE "BELT:			$SHOPBELT\n";
		print FILE "PANTS:			$SHOPPANTS\n";
		print FILE "HAND:			$SHOPHAND\n";
		print FILE "FEET:			$SHOPFEET\n\n";
	
		print FILE "AVERAGE'S FOR $name at $hour:$minute:$second~$day/$month/$year\n\n";
		print FILE "You can expect: $experseconds EXP/Sec.\n";
		print FILE "You can expect: $goldseconds GOLD/Sec.\n";
		print FILE "You can expect: $experminutes EXP/Min.\n";
		print FILE "You can expect: $goldminutes GOLD/Min.\n";
		print FILE "You can expect: $experhours EXP/Hour.\n";
		print FILE "You can expect: $goldhours GOLD/Hour.\n";
		print FILE "You can expect: $experdays EXP/Day.\n";
		print FILE "You can expect: $golddays GOLD/Day.\n\n";
		close(FILE);
		
		print "\nMAIN STATUS FOR $name at $hour:$minute:$second~$day/$month/$year\n\n";
		print "$name\'s current level is $Forlev\n";
		print "You need $Nextlevel EXP to level\n";
		print "You can expect to level on $datestring\n";
		printf "Your current CPM level is : %.3e\n\n", $level->bstr();
		print "AVERAGE'S FOR $name at $hour:$minute:$second~$day/$month/$year\n\n";
		print "You can expect: $experseconds EXP/Sec.\n";
		print "you can expect: $goldseconds GOLD/Sec.\n";
		print "You can expect: $experminutes EXP/Min.\n";
		print "You can expect: $goldminutes GOLD/Min.\n";
		print "You can expect: $experhours EXP/Hour.\n";
		print "You can expect: $goldhours GOLD/Hour.\n";
		print "You can expect: $experdays EXP/Day.\n";
		print "You can expect: $golddays GOLD/Day.\n\n";
	}
# KILLED
		if($a =~ m/(been.*slain)/) {
			print "ERROR - TOO HIGH MONSTER LEVEL! - you were slain!\n";exit(0);
		}
# JAILED
		if ($b =~ m/jail time.*<br>/) {
			print"You have been Jailed - Sleep 5 seconds.\n";
			sleep(5);
		}

# LOGGED OUT

		if ($c =~ m/logged/) {
			print "LOGGED OUT! sleeping for 5 seconds before restart!\n";
			sleep(60);
			exit();
		}


# STEAL TIME? then exit to steal
		if ($antal <= 0) {
			sleep(5);
			print "Waiting last few seconds before steal\n";
			exit();
		}
		
		$a = $b;
		($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst) = localtime(time);
		$year = $year + 1900;
		$a =~ m/(You win.*exp )/;
		$a =~ m/(The battle tied.)/;
		print "$antal: [$hour:$minute:$second]: " . $1 . "\n";



# level up if necessary
		if ($b =~ m/(Congra.*exp)/) {
			if ($char_type == 1) {&Levelupagimage; return();}
			if ($char_type == 2) {&Levelupfighter; return();}
			if ($char_type == 3) {&Levelupmage; return();}
			if ($char_type == 4) {&Leveluppurefighter; return();}
			if ($char_type == 5) {&Leveluppuremage; return();}
			if ($char_type == 6) {&Levelupcontrafighter; return();}
		}
	}
}

sub Levelupagimage {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if(($aslevel <= $deflevel) && ($aslevel <= $mrlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Intelligence");
				$mech->click_button('name' => 'cStats', 'value' => 'Intelligence');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Intelligence");
				$mech->click_button('name' => 'Stats', 'value' => 'Intelligence');			
			}
			print "You Leveled up Intelligence\n";
			sleep(1);
			&TestShop;;
			return();
		}
		if(($deflevel <= $aslevel) && ($deflevel <= $mrlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Agility");
				$mech->click_button('name' => 'cStats', 'value' => 'Agility');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Agility");
				$mech->click_button('name' => 'Stats', 'value' => 'Agility');			
			}
			print "You Leveled up Agility\n";
			sleep(1);
			return();
		}

		if(($mrlevel <= $deflevel) && ($mrlevel <= $aslevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Concentration");
				$mech->click_button('name' => 'cStats', 'value' => 'Concentration');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Concentration");
				$mech->click_button('name' => 'Stats', 'value' => 'Concentration');			
			}
			print "You Leveled up Concentration\n";
			sleep(1);
			return();
		}
}


sub Levelupfighter {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if(($wdlevel <= $mrlevel) && ($wdlevel <= $arlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Strength");
				$mech->click_button('name' => 'cStats', 'value' => 'Strength');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Strength");
				$mech->click_button('name' => 'Stats', 'value' => 'Strength');			
			}
			print "You Leveled up Strength\n";
			&TestShop;;
			return();
		}
		if(($arlevel <= $wdlevel) && ($arlevel <= $mrlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Dexterity");
				$mech->click_button('name' => 'cStats', 'value' => 'Dexterity');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Dexterity");
				$mech->click_button('name' => 'Stats', 'value' => 'Dexterity');			
			}
			print "You Leveled up Dexterity\n";
			return();
		}

		if(($mrlevel <= $wdlevel) && ($mrlevel <= $arlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Concentration");
				$mech->click_button('name' => 'cStats', 'value' => 'Concentration');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Concentration");
				$mech->click_button('name' => 'Stats', 'value' => 'Concentration');			
			}
			print "You Leveled up Concentration\n";
			return();
		}
	}

sub Levelupmage {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if(($aslevel <= $arlevel) && ($aslevel <= $mrlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Intelligence");
				$mech->click_button('name' => 'cStats', 'value' => 'Intelligence');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Intelligence");
				$mech->click_button('name' => 'Stats', 'value' => 'Intelligence');			
			}
			print "You Leveled up Intelligence\n";
			&TestShop;;
			return();
		}
		if(($arlevel <= $aslevel) && ($arlevel <= $mrlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Dexterity");
				$mech->click_button('name' => 'cStats', 'value' => 'Dexterity');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Dexterity");
				$mech->click_button('name' => 'Stats', 'value' => 'Dexterity');			
			}
			print "You Leveled up Dexterity\n";
			return();
		}

		if(($mrlevel <= $arlevel) && ($mrlevel <= $aslevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Concentration");
				$mech->click_button('name' => 'cStats', 'value' => 'Concentration');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Concentration");
				$mech->click_button('name' => 'Stats', 'value' => 'Concentration');			
			}
			print "You Leveled up Concentration\n";
			return();
		}
}

sub Leveluppurefighter {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if($wdlevel <= $arlevel) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Strength");
				$mech->click_button('name' => 'cStats', 'value' => 'Strength');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Strength");
				$mech->click_button('name' => 'Stats', 'value' => 'Strength');			
			}
			print "Leveled up Strength\n";
			&TestShop;;
			return();
		}		
		if($arlevel <= $wdlevel) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Dexterity");
				$mech->click_button('name' => 'cStats', 'value' => 'Dexterity');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Dexterity");
				$mech->click_button('name' => 'Stats', 'value' => 'Dexterity');			
			}
			print "You Leveled up Dexterity\n";
			return();
		}
}
	
sub Leveluppuremage {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if($mrlevel >= $aslevel) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Intelligence");
				$mech->click_button('name' => 'cStats', 'value' => 'Intelligence');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Intelligence");
				$mech->click_button('name' => 'Stats', 'value' => 'Intelligence');			
			}
			print "Leveled up Intelligence\n";
			sleep(0.5);
			&TestShop;
			return();
		}

		if($aslevel >= $mrlevel) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Concentration");
				$mech->click_button('name' => 'cStats', 'value' => 'Concentration');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Concentration");
				$mech->click_button('name' => 'Stats', 'value' => 'Concentration');			
			}
			print "You Leveled up Concentration\n";
			sleep(0.5);
			return();
		}
}

sub Levelupcontrafighter {
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		sleep(0.5);
		if(($wdlevel <= $mslevel) && ($wdlevel <= $arlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Strength");
				$mech->click_button('name' => 'cStats', 'value' => 'Strength');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Strength");
				$mech->click_button('name' => 'Stats', 'value' => 'Strength');			
			}
			print "You Leveled up Strength\n";
			sleep(1);
			&TestShop;;
			return();
		}
		if(($mslevel <= $wdlevel) && ($mslevel <= $arlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Contravention");
				$mech->click_button('name' => 'cStats', 'value' => 'Contravention');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Contravention");
				$mech->click_button('name' => 'Stats', 'value' => 'Contravention');			
			}
			print "You Leveled up Contravention\n";
			sleep(1);
			return();
		}

		if(($arlevel <= $mslevel) && ($arlevel <= $wdlevel)) {
		$mech->form_number(1);
			if($MyLev <= $masslevel){
				$mech->field("cStats", "Dexterity");
				$mech->click_button('name' => 'cStats', 'value' => 'Dexterity');
			}
			elsif($MyLev >= $masslevel){
				$mech->field("Stats", "Dexterity");
				$mech->click_button('name' => 'Stats', 'value' => 'Dexterity');			
			}
			print "You Leveled up Dexterity\n";
			sleep(1);
			return();
		}
}

sub CheckShop{
		$parsed = 0; 
	while (!$parsed){
		sleep(1);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."shop.php");
		$a = $mech->content();
		if($a =~ m/Parsed/){
			$parsed = 1;
		}
	}
	my $a1;
	$a1 = $a;
	$a1 =~ s/(.*)(shopping)//si; #remove before
	$a1 =~ s/<\/form>.*//s; #remove after
	$a1 =~ s/maxlength//sgi;
	$a1 =~ s/\(//sg;
	$a1 =~ s/\)//sg;
	$a1 =~ s/maxed/fullshop/sgi;
	$a1 =~ s/\s//sg;
	$a1 =~ s/\n//sgi;
	$a1 =~ s/<\/th>//sgi;
	$a1 =~ s/<\/tr>//sgi;
	$a1 =~ s/<\/td>//sgi;
	$a1 =~ s/<tr>//sgi;
	$a1 =~ s/<td>//sgi;
	$a1 =~ s/width/1/si;
	$a1 =~ s/width/2/si;
	$a1 =~ s/width/3/si;
	$a1 =~ s/width/4/si;
	$a1 =~ s/width/5/si;
	$a1 =~ s/width/6/si;
	$a1 =~ s/width/7/si;
	$a1 =~ s/width/8/si;
	$a1 =~ s/width/9/si;
	$a1 =~ s/width/a/si;
	$a1 =~ s/width/b/si;
	$a1 =~ s/width/c/si;
	my $max;
	my $aweap;
	my $aas;
	my $ahs;
	my $ahelm;
	my $ashield;
	my $aamulet;
	my $aring;
	my $aarm;
	my $abelt;
	my $apants;
	my $ahand;
	my $afeet;
	
	#open(FILE, ">$file_fix shops.txt")
	#or die "failed to open file!!!!";
	#print FILE "$a1\n";
	#close(FILE);
		
	$max = $a1;
	$aweap = $a1;
	$aas = $a1;
	$ahs = $a1;
	$ahelm = $a1;
	$ashield = $a1;
	$aamulet = $a1;
	$aring = $a1;
	$aarm = $a1;
	$abelt = $a1;
	$apants = $a1;
	$ahand = $a1;
	$afeet = $a1;
	#Max
		$max =~ s/(.*)(max)//si; #remove before
		$max =~ s/price.*//si; #remove after
		$SHOPMAX = $max;
		$max =~ s/,//sg;
	#Weapon
		$aweap =~ s/td1.*//si; #remove after
		$aweap =~ s/(.*)(weapon)//si; #remove before
		$aweap =~ s/\$.*//si; #remove after
		$SHOPWEAP = $aweap;
		$aweap =~ s/,//sg;
		if($aweap >= $max){
			$shop1 = 1;
			$aweap = "Maxed";
		}else{
			$shop1 = 0;
		}
	#AttackSpell
		$aas =~ s/(.*)(^td1)//si; #remove before
		$aas =~ s/td2.*//si; #remove after
		$aas =~ s/(.*)(attackspell)//si; #remove before
		$aas =~ s/\$.*//si; #remove after
		$SHOPAS = $aas;
		$aas =~ s/,//sg;
		if($aas >= $max){
			$shop2 = 1;
			$aas = "Maxed";
		}else{
			$shop2 = 0;
		}
	#HealSpell
		$ahs =~ s/(.*)(td2)//si; #remove before
		$ahs =~ s/td3.*//si; #remove after
		$ahs =~ s/(.*)(healspell)//si; #remove before
		$ahs =~ s/\$.*//si; #remove after
		$SHOPHS = $ahs;
		$ahs =~ s/,//sg;
		if($ahs >= $max){
			$shop3 = 1;
			$ahs = "Maxed";
		}else{
			$shop3 = 0;
		}
	#Helmet
		$ahelm =~ s/(.*)(td3)//si; #remove before
		$ahelm =~ s/td4.*//si; #remove after
		$ahelm =~ s/(.*)(helmet)//si; #remove before
		$ahelm =~ s/\$.*//si; #remove after
		$SHOPHELM = $ahelm;
		$ahelm =~ s/,//sg;
		if($ahelm >= $max){
			$shop4 = 1;
			$ahelm = "Maxed";
		}else{
			$shop4 = 0;
		}
	#Shield
		$ashield =~ s/(.*)(td4)//si; #remove before
		$ashield =~ s/td5.*//si; #remove after
		$ashield =~ s/(.*)(shield)//si; #remove before
		$ashield =~ s/\$.*//si; #remove after
		$SHOPSHIELD = $ashield;
		$ashield =~ s/,//sg;
		if($ashield >= $max){
			$shop5 = 1;
			$ashield = "Maxed";
		}else{
			$shop5 = 0;
		}
	#Amulet
		$aamulet =~ s/(.*)(td5)//si; #remove before
		$aamulet =~ s/td6.*//si; #remove after
		$aamulet =~ s/(.*)(amulet)//si; #remove before
		$aamulet =~ s/\$.*//si; #remove after
		$SHOPAMULET = $aamulet;
		$aamulet =~ s/,//sg;
		if($aamulet >= $max){
			$shop6 = 1;
			$aamulet = "Maxed";
		}else{
			$shop6 = 0;
		}
	#Ring
		$aring =~ s/(.*)(td6)//si; #remove before
		$aring =~ s/td7.*//si; #remove after
		$aring =~ s/(.*)(ring)//si; #remove before
		$aring =~ s/\$.*//si; #remove after
		$SHOPRING = $aring;
		$aring =~ s/,//sg;
		if($aring >= $max){
			$shop7 = 1;
			$aring = "Maxed";
		}else{
			$shop7 = 0;
		}
	#Armor
		$aarm =~ s/(.*)(td7)//si; #remove before
		$aarm =~ s/td8.*//si; #remove after
		$aarm =~ s/(.*)(armor)//si; #remove before
		$aarm =~ s/\$.*//si; #remove after
		$SHOPARMOR = $aarm;
		$aarm =~ s/,//sg;
		if($aarm >= $max){
			$shop8 = 1;
			$aarm = "Maxed";
		}else{
			$shop8 = 0;
		}
	#Belt
		$abelt =~ s/(.*)(td8)//si; #remove before
		$abelt =~ s/td9.*//si; #remove after
		$abelt =~ s/(.*)(belt)//si; #remove before
		$abelt =~ s/\$.*//si; #remove after
		$SHOPBELT = $abelt;
		$abelt =~ s/,//sg;
		if($abelt >= $max){
			$shop9 = 1;
			$abelt = "Maxed";
		}else{
			$shop9 = 0;
		}
	#Pants
		$apants =~ s/(.*)(td9)//si; #remove before
		$apants =~ s/tda.*//si; #remove after
		$apants =~ s/(.*)(pants)//si; #remove before
		$apants =~ s/\$.*//si; #remove after
		$SHOPPANTS = $apants;
		$apants =~ s/,//sg;
		if($apants >= $max){
			$shop10 = 1;
			$apants = "Maxed";
		}else{
			$shop10 = 0;
		}
	#Hand
		$ahand =~ s/(.*)(tda)//si; #remove before
		$ahand =~ s/tdb.*//si; #remove after
		$ahand =~ s/(.*)(hand)//si; #remove before
		$ahand =~ s/\$.*//si; #remove after
		$SHOPHAND = $ahand;
		$ahand =~ s/,//sg;
		if($ahand >= $max){
			$shop11 = 1;
			$ahand = "Maxed";
		}else{
			$shop11 = 0;
		}
	#Feet
		$afeet =~ s/(.*)(tdb)//si; #remove before
		$afeet =~ s/tdc.*//si; #remove after
		$afeet =~ s/(.*)(feet)//si; #remove before
		$afeet =~ s/\$.*//si; #remove after
		$SHOPFEET = $afeet;
		$afeet =~ s/,//sg;
		if($afeet >= $max){
			$shop12 = 1;
			$afeet = "Maxed";
		}else{
			$shop12 = 0;
		}

	#print "your maximum shop is             :$max\n";
	#print "your current Weapon shop is      :$aweap\n";
	#print "your current Attackspell shop is :$aas\n";
	#print "your current Healspell shop is   :$ahs\n";
	#print "your current Helmet shop is      :$ahelm\n";
	#print "your current Shield shop is      :$ashield\n";
	#print "your current Amulet shop is      :$aamulet\n";
	#print "your current Ring shops is       :$aring\n";
	#print "your current Armor shops is      :$aarm\n";
	#print "your current Belt shops is       :$abelt\n";
	#print "your current Pants shops is      :$apants\n";
	#print "your current Hand shops is       :$ahand\n";	
	#print "your current Feet shops is       :$afeet\n";
}

sub TestShop{
		$parsed = 0; 
	while (!$parsed){
		sleep(1);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."shop.php");
		$a = $mech->content();
		if($a =~ m/Parsed/){
			$parsed = 1;
		}
	}
	my $a1;
	$a1 = $a;
	$a1 =~ s/(.*)(shopping)//si; #remove before
	$a1 =~ s/<\/form>.*//s; #remove after
	$a1 =~ s/maxlength//sgi;
	$a1 =~ s/\(//sg;
	$a1 =~ s/\)//sg;
	$a1 =~ s/maxed/fullshop/sgi;
	$a1 =~ s/\s//sg;
	$a1 =~ s/\n//sgi;
	$a1 =~ s/<\/th>//sgi;
	$a1 =~ s/<\/tr>//sgi;
	$a1 =~ s/<\/td>//sgi;
	$a1 =~ s/<tr>//sgi;
	$a1 =~ s/<td>//sgi;
	$a1 =~ s/width/1/si;
	$a1 =~ s/width/2/si;
	$a1 =~ s/width/3/si;
	$a1 =~ s/width/4/si;
	$a1 =~ s/width/5/si;
	$a1 =~ s/width/6/si;
	$a1 =~ s/width/7/si;
	$a1 =~ s/width/8/si;
	$a1 =~ s/width/9/si;
	$a1 =~ s/width/a/si;
	$a1 =~ s/width/b/si;
	$a1 =~ s/width/c/si;
	my $max;
	my $aweap;
	my $aas;
	my $ahs;
	my $ahelm;
	my $ashield;
	my $aamulet;
	my $aring;
	my $aarm;
	my $abelt;
	my $apants;
	my $ahand;
	my $afeet;
	
	#open(FILE, ">shops.txt")
	#or die "failed to open file!!!!";
	#print FILE "$a1\n";
	#close(FILE);
		
	$max = $a1;
	$aweap = $a1;
	$aas = $a1;
	$ahs = $a1;
	$ahelm = $a1;
	$ashield = $a1;
	$aamulet = $a1;
	$aring = $a1;
	$aarm = $a1;
	$abelt = $a1;
	$apants = $a1;
	$ahand = $a1;
	$afeet = $a1;
	#Max
		$max =~ s/(.*)(max)//si; #remove before
		$max =~ s/price.*//si; #remove after
		$max =~ s/,//sg;
	#Weapon
		$aweap =~ s/td1.*//si; #remove after
		$aweap =~ s/(.*)(weapon)//si; #remove before
		$aweap =~ s/\$.*//si; #remove after
		$aweap =~ s/,//sg;
		if($aweap >= $max){
			$shop1 = 1;
			$aweap = "Maxed";
		}else{
			$shop1 = 0;
		}
	#AttackSpell
		$aas =~ s/(.*)(^td1)//si; #remove before
		$aas =~ s/td2.*//si; #remove after
		$aas =~ s/(.*)(attackspell)//si; #remove before
		$aas =~ s/\$.*//si; #remove after
		$aas =~ s/,//sg;
		if($aas >= $max){
			$shop2 = 1;
			$aas = "Maxed";
		}else{
			$shop2 = 0;
		}
	#HealSpell
		$ahs =~ s/(.*)(td2)//si; #remove before
		$ahs =~ s/td3.*//si; #remove after
		$ahs =~ s/(.*)(healspell)//si; #remove before
		$ahs =~ s/\$.*//si; #remove after
		$ahs =~ s/,//sg;
		if($ahs >= $max){
			$shop3 = 1;
			$ahs = "Maxed";
		}else{
			$shop3 = 0;
		}
	#Helmet
		$ahelm =~ s/(.*)(td3)//si; #remove before
		$ahelm =~ s/td4.*//si; #remove after
		$ahelm =~ s/(.*)(helmet)//si; #remove before
		$ahelm =~ s/\$.*//si; #remove after
		$ahelm =~ s/,//sg;
		if($ahelm >= $max){
			$shop4 = 1;
			$ahelm = "Maxed";
		}else{
			$shop4 = 0;
		}
	#Shield
		$ashield =~ s/(.*)(td4)//si; #remove before
		$ashield =~ s/td5.*//si; #remove after
		$ashield =~ s/(.*)(shield)//si; #remove before
		$ashield =~ s/\$.*//si; #remove after
		$ashield =~ s/,//sg;
		if($ashield >= $max){
			$shop5 = 1;
			$ashield = "Maxed";
		}else{
			$shop5 = 0;
		}
	#Amulet
		$aamulet =~ s/(.*)(td5)//si; #remove before
		$aamulet =~ s/td6.*//si; #remove after
		$aamulet =~ s/(.*)(amulet)//si; #remove before
		$aamulet =~ s/\$.*//si; #remove after
		$aamulet =~ s/,//sg;
		if($aamulet >= $max){
			$shop6 = 1;
			$aamulet = "Maxed";
		}else{
			$shop6 = 0;
		}
	#Ring
		$aring =~ s/(.*)(td6)//si; #remove before
		$aring =~ s/td7.*//si; #remove after
		$aring =~ s/(.*)(ring)//si; #remove before
		$aring =~ s/\$.*//si; #remove after
		$aring =~ s/,//sg;
		if($aring >= $max){
			$shop7 = 1;
			$aring = "Maxed";
		}else{
			$shop7 = 0;
		}
	#Armor
		$aarm =~ s/(.*)(td7)//si; #remove before
		$aarm =~ s/td8.*//si; #remove after
		$aarm =~ s/(.*)(armor)//si; #remove before
		$aarm =~ s/\$.*//si; #remove after
		$aarm =~ s/,//sg;
		if($aarm >= $max){
			$shop8 = 1;
			$aarm = "Maxed";
		}else{
			$shop8 = 0;
		}
	#Belt
		$abelt =~ s/(.*)(td8)//si; #remove before
		$abelt =~ s/td9.*//si; #remove after
		$abelt =~ s/(.*)(belt)//si; #remove before
		$abelt =~ s/\$.*//si; #remove after
		$abelt =~ s/,//sg;
		if($abelt >= $max){
			$shop9 = 1;
			$abelt = "Maxed";
		}else{
			$shop9 = 0;
		}
	#Pants
		$apants =~ s/(.*)(td9)//si; #remove before
		$apants =~ s/tda.*//si; #remove after
		$apants =~ s/(.*)(pants)//si; #remove before
		$apants =~ s/\$.*//si; #remove after
		$apants =~ s/,//sg;
		if($apants >= $max){
			$shop10 = 1;
			$apants = "Maxed";
		}else{
			$shop10 = 0;
		}
	#Hand
		$ahand =~ s/(.*)(tda)//si; #remove before
		$ahand =~ s/tdb.*//si; #remove after
		$ahand =~ s/(.*)(hand)//si; #remove before
		$ahand =~ s/\$.*//si; #remove after
		$ahand =~ s/,//sg;
		if($ahand >= $max){
			$shop11 = 1;
			$ahand = "Maxed";
		}else{
			$shop11 = 0;
		}
	#Feet
		$afeet =~ s/(.*)(tdb)//si; #remove before
		$afeet =~ s/tdc.*//si; #remove after
		$afeet =~ s/(.*)(feet)//si; #remove before
		$afeet =~ s/\$.*//si; #remove after
		$afeet =~ s/,//sg;
		if($afeet >= $max){
			$shop12 = 1;
			$afeet = "Maxed";
		}else{
			$shop12 = 0;
		}

	#print "your maximum shop is             :$max\n";
	#print "your current Weapon shop is      :$aweap\n";
	#print "your current Attackspell shop is :$aas\n";
	#print "your current Healspell shop is   :$ahs\n";
	#print "your current Helmet shop is      :$ahelm\n";
	#print "your current Shield shop is      :$ashield\n";
	#print "your current Amulet shop is      :$aamulet\n";
	#print "your current Ring shops is       :$aring\n";
	#print "your current Armor shops is      :$aarm\n";
	#print "your current Belt shops is       :$abelt\n";
	#print "your current Pants shops is      :$apants\n";
	#print "your current Hand shops is       :$ahand\n";	
	#print "your current Feet shops is       :$afeet\n";

	if($shop_yes_no == 1){
		&BuyUpgrades;
	}else{
		print "Shops were not bought this time\n";
		exit();
	}
}
	
sub BuyUpgrades{
	$parsed = 0; 
	while (!$parsed){
		sleep(1);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."shop.php");
		$a = $mech->content();
		if($a =~ m/Parsed/){
			$parsed = 1;
		}
	}
	
	$mech->form_number(1);

	my $maxshop = "9e99";
	
	if($char_type == 1){
		if($shop2 == 0){
			$mech->field("Attackspell", $maxshop);
		}
		if($shop4 == 0){
			$mech->field("Helmet", $maxshop);
		}
		if($shop5 == 0){
			$mech->field("Shield", $maxshop);
		}
		if($shop6 == 0){
			$mech->field("Amulet", $maxshop);
		}
		if($shop7 == 0){
			$mech->field("Ring", $maxshop);	
		}
		if($shop8 == 0){
			$mech->field("Armor", $maxshop);
		}
		if($shop9 == 0){
			$mech->field("Belt", $maxshop);
		}
		if($shop10 == 0){
			$mech->field("Pants", $maxshop);
		}
		if($shop11 == 0){
			$mech->field("Hand", $maxshop);
		}
		if($shop12 == 0){
			$mech->field("Feet", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}elsif($char_type == 2){
		if($shop1 == 0){
			$mech->field("Weapon", $maxshop);
		}
		if($shop9 == 0){
			$mech->field("Belt", $maxshop);
		}
		if($shop11 == 0){
			$mech->field("Hand", $maxshop);
		}
		if($shop12 == 0){
			$mech->field("Feet", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}elsif($char_type == 3){
		if($shop2 == 0){
			$mech->field("Attackspell", $maxshop);
		}
		if($shop7 == 0){
			$mech->field("Ring", $maxshop);	
		}
		if($shop9 == 0){
			$mech->field("Belt", $maxshop);
		}
		if($shop12 == 0){
			$mech->field("Feet", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}elsif($char_type == 4){
		if($shop1 == 0){
			$mech->field("Weapon", $maxshop);
		}
		if($shop11 == 0){
			$mech->field("Hand", $maxshop);
		}
		if($shop12 == 0){
			$mech->field("Feet", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}elsif($char_type == 5){
		if($shop2 == 0){
			$mech->field("Attackspell", $maxshop);
		}
		if($shop7 == 0){
			$mech->field("Ring", $maxshop);	
		}
		if($shop9 == 0){
			$mech->field("Belt", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}elsif($char_type == 6){
		if($shop1 == 0){
			$mech->field("Weapon", $maxshop);
		}
		if($shop6 == 0){
			$mech->field("Amulet", $maxshop);
		}
		if($shop7 == 0){
			$mech->field("Ring", $maxshop);	
		}
		if($shop11 == 0){
			$mech->field("Hand", $maxshop);
		}
		if($shop12 == 0){
			$mech->field("Feet", $maxshop);
		}
			$mech->click_button('name' => 'action', 'value' => 'Buy upgrades!');
			$a = $mech->content();
		if ($a =~ m/Total/){
			$a =~ m/(Buy.*gold\.)/s;
			$a = $1;
			$a =~ s/<br>/\n/sg;
			print "you maxed some shops: \n". $a ."\n";
		}
		if ($a =~ m/Not enough gold!/){
			print "You did not have enough Gold in your hand to max all your shops.\n";
		}
	}
	
	sleep(0.5);
	return();
}

sub MyLevel{
	$parsed = 0; 
	while (!$parsed){
		sleep(0.5);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."main.php");
		$a = $mech->content();
		if($a =~ m/Parsed/){
			$parsed = 1;
		}
	}
	
	$a = $mech->content();
	$a =~ s/<.*?>//sg;
	$a =~ m/(Level : .*)/s;
	$a =~ s/\n/ /g;
	$a =~ s/LordsofLords/ /g;
	$a =~ s/ //g;
	$a =~ s/Exp.*//;
	$a =~ s/\D//g;
	$a =~ s/,//g;
	$MyLev = new Math::BigFloat $a;
	$Forlev = $a;
	while($Forlev =~ m/([0-9]{4})/){
		my $temp1 = reverse $Forlev;
		$temp1 =~ s/(?<=(\d\d\d))(?=(\d))/,/;
		$Forlev = reverse $temp1;
	}
	print "Your Level is : $Forlev\n";
	
	if($max_level <= $MyLev){
		print "You have reached the desired level : EXITING!!\n";
		sleep(30);
		exit();
	}
}	

sub Charname{
	$parsed = 0; 
	while (!$parsed){
		sleep(0.5);
		$mech->get("http://thenewlosthope.net".$URL_SERVER."stats.php");
		$a = $mech->content();
		if($a =~ m/Parsed/){
			$parsed = 1;
		}
	}
	$a = $mech->content();
	$b = $mech->content();
	$a =~ s/(.*)(natural)//si; #remove before
	$a =~ s/th.*//si; #remove after
	$a =~ s/<\///si;
	$a =~ s/(.*)(for)//si; #remove before
	$charname = $a;
	$charname =~ m/(\w+)\s+(\w+)/;
	$title = $1;
	$name = $2;
	$title =~ s/ //sgi;
	$name =~ s/ //sgi;
	print "\nSuccessfully logged into $title $name at $hour:$minute:$second\n\n";
	
	$b =~ m/(You need.*exp )/;
	$b = $1;
	$b =~ s/you//i;
	$b =~ s/need//i;
	$b =~ s/exp//i;
	$b =~ s/,//gi;
	$b =~ s/\s//gi;
	$Nextlevel = new Math::BigFloat $b;
}

#---------------------
# MAIN
#---------------------

# create a new browser

$mech = WWW::Mechanize->new(autocheck => 1, stack_depth => 0);
$mech->timeout(5); #2 second timeout! for n00b SilenT
$mech->agent_alias( 'Windows Mozilla' );

print " 
		 \\\\\\///
		/ _  _ \\\
	  (| (.)(.) |)
.---.OOOo--()--oOOO.---.
|                      |
| www.thenewlosthope.net |
|                      |
'---.oooO--------------'
	 (   )   Oooo.
	  \\\ (    (   )
	   \\\_)    ) /
			 (_/
\n";

#Login
if($server == 1){
	open(LOGINS, "m3logins.txt")
		or die "failed to open Logins file!!!!";
		@logins = <LOGINS>;
	close(LOGINS);
}elsif($server = 2){
	open(LOGINS, "sotselogins.txt")
		or die "failed to open Logins file!!!!";
		@logins = <LOGINS>;
	close(LOGINS);
}

until ($username ne 1){
	@users = split(/ /, $logins[0]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 2){
	@users = split(/ /, $logins[1]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 3){
	@users = split(/ /, $logins[2]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 4){	
	@users = split(/ /, $logins[3]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 5){
	@users = split(/ /, $logins[4]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 6){
	@users = split(/ /, $logins[5]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 7){
	@users = split(/ /, $logins[6]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 8){
	@users = split(/ /, $logins[7]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 9){
	@users = split(/ /, $logins[8]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 10){
	@users = split(/ /, $logins[9]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 11){
	@users = split(/ /, $logins[10]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 12){
	@users = split(/ /, $logins[11]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 13){
	@users = split(/ /, $logins[12]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 14){
	@users = split(/ /, $logins[13]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 15){
	@users = split(/ /, $logins[14]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 16){
	@users = split(/ /, $logins[15]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 17){
	@users = split(/ /, $logins[16]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 18){
	@users = split(/ /, $logins[17]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 19){
	@users = split(/ /, $logins[18]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 20){
	@users = split(/ /, $logins[19]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 21){
	@users = split(/ /, $logins[20]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 22){
	@users = split(/ /, $logins[21]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 23){
	@users = split(/ /, $logins[22]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 24){
	@users = split(/ /, $logins[23]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 25){
	@users = split(/ /, $logins[24]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 26){
	@users = split(/ /, $logins[25]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 27){
	@users = split(/ /, $logins[26]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 28){
	@users = split(/ /, $logins[27]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 29){
	@users = split(/ /, $logins[28]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 30){
	@users = split(/ /, $logins[29]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 31){
	@users = split(/ /, $logins[30]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 32){
	@users = split(/ /, $logins[31]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 33){
	@users = split(/ /, $logins[32]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 34){
	@users = split(/ /, $logins[33]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}
until ($username ne 35){
	@users = split(/ /, $logins[34]);
	$username = $users[0];
	$password = $users[1];
	chomp ($username, $password);
}

$parsed = 0; 
while ($parsed == 0){
sleep(0.5);
$mech->get("http://thenewlosthope.net".$URL_SERVER."login.php");
$a = $mech->content();
	if($a =~ m/Enter Lol!/){
		$parsed = 1;
	}else{
		sleep(10);
		exit();
	}
}
if($a =~ m/Username/){
	$mech->form_number(0);
	$mech->field("Username", $username);
	$mech->field("Password", $password);
	$mech->click();
	($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_dst) = localtime(time);
	#print "[$hour:$minute:$second] - logged in Successfully to : \n";
}else{
	sleep(5);
	exit();
}


my $levels = 9999999;

while($levels){
	&Charname;
	&MyLevel;
	&CheckShop;
	if($MyLev <= 2500000){
		print "\nLow Level Fight mode\n\n";
	}else{
		print "\nHigh Level Fight mode\n\n";
	}
	
		if (get_steal_wait() == 0) {
			#my ($status, $result) = merge_test();
			#if($status == 1){
			#	merge();
			#} else {
				steal();
			#}
		}
	&Autolevelup;
	if($MyLev <= 2500000){
		low_level();
		&LowFight;	
	}else{
		&CPMlevel;
		&Fight;
	}
	$levels = $levels - 1;
}


exit();
