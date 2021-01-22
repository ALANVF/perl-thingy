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
use feature "switch";
no warnings "experimental::smartmatch";
use feature "postderef";
use feature "signatures";
no warnings "experimental::signatures";
use feature "state";



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
my $mech;
my $MASS_LEVEL = 1500;
my $alternate = 60;
my $agi_mage_count = 6;
my $fighter_count = 3;
my $mage_count = 3;
my $pure_mage_count = 3;
my $pure_fighter_count = 3;
my $cf_count = 17;
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

if($merger_name eq "MergerName") {
	$merger_name = "Undefined";
}

my $file_fix = do {
	given($server) {
		when(1) { "m3" }
		when(2) { "sotse" }
		default { die "Unknown server \"$server\"!" }
	}
};
my $URL_SERVER = "/$file_fix/";


#---------------------

sub min(@values) {
	return (sort @values)[0]
}

sub get_steal_wait() {
	my $steal_wait = 3600;
	my $steal_time = time;
	
	$steal_time += $steal_wait; # if stealer can't be found, click for 1k seconds
	
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}steal.php");
	my $content = $mech->content();
	
	unless($content =~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$steal_wait = 0;

	if($content =~ m/recover/) {
		$steal_wait = do {
			given($mech->content()) {
				s/Take(.*)This/$1/s;
				s/<.*?>//sg;
				s/for(.*)seconds/$1/s;
				s/,//g;
				$_
			}
		};
		
		say "In recover, gotta wait $steal_wait seconds before I can steal...\n";
		
		$steal_time = time;
		$steal_time += $steal_wait;
	}
	
	return $steal_wait;
}

sub merge_test() {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();

	unless($content =~ m/Parsed/) {
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

sub get_merge_id() {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();
	
	unless($content =~ m/Parsed/) {
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
	
	unless($content =~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content = $mech->content();
	$content =~ s/(.*)($merge_id)//sg; #remove before
	$content =~ s|</option>.*||sg; #remove after
	$content =~ s/"//sgi;
	$content =~ s/>//sgi;
	$content =~ s/\s*$//;
	
	return $content;
}

sub merge($merge_name) {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}theone.php");
	my $content = $mech->content();
	
	unless($content =~ m/Parsed/) {
		sleep 10;
		exit;
	}
	
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

sub steal($title, $name) {
	sleep 1;
	
	$mech->get("http://thenewlosthope.net".$URL_SERVER."steal.php");
	my $content = $mech->content();
	
	unless($content =~ m/Parsed/) {
		sleep 10;
		exit;
	}

	$content = $mech->content();
	
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

		my ($second, $minute, $hour, $day, $month, $year) = localtime(time);
		$year += 1900;
		my $month_name = $MONTHS[$month];
		$month += 1;

		open(FILE, ">>$title$name $file_fix ~ $month_name $year StealRecord.txt") or die "failed to open file!!!!";
		print FILE "[$day/$month/$year] ~ [$hour:$minute:$second] - you stole $steal_rec\n";
		close FILE;
	} else {
		say "Freeplay not detected, stealing cancelled...";
	}
}

sub parse_stats() {
	($_) = m/(Min<br>.*monster)/s;
	($_) = m/(\<br.*td\>)/;
	s/<.*?>/:/sg;
	s/\.//g;

	return (split ":", $_)[1, 2, 4..7];
}

sub display_levels :prototype(\%; $) ($levels, $handle = *STDOUT) {
	given($char_type) {
		when(1) {
			printf $handle 'ASlevel: %.3e, DEFlevel: %.3e, MRlevel: %.3e', (
				$levels->{as}->bstr(),
				$levels->{def}->bstr(),
				$levels->{mr}->bstr()
			);
		}
	
		when(2) {
			printf $handle 'WDlevel: %.3e, ARlevel: %.3e, MRlevel: %.3e', (
				$levels->{wd}->bstr(),
				$levels->{ar}->bstr(),
				$levels->{mr}->bstr()
			);
		}

		when(3) {
			printf $handle 'ASlevel: %.3e, ARlevel: %.3e, MRlevel: %.3e', (
				$levels->{as}->bstr(),
				$levels->{ar}->bstr(),
				$levels->{mr}->bstr()
			);
		}
		
		when(4) {
			printf $handle 'WDlevel: %.3e, ARlevel: %.3e$8', (
				$levels->{wd}->bstr(),
				$levels->{ar}->bstr()
			);
		}
		
		when(5) {
			printf $handle 'ASlevel: %.3e, MRlevel: %.3e$8', (
				$levels->{as}->bstr(),
				$levels->{mr}->bstr()
			);
		}

		when(6) {
			printf $handle 'WDlevel: %.3e, MSlevel: %.3e, ARlevel: %.3e', (
				$levels->{wd}->bstr(),
				$levels->{ms}->bstr(),
				$levels->{ar}->bstr()
			);
		}
	}
}

sub get_levels :prototype(\@ %) ($stats, %div_values) {
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
			shift @$stats;
			s/,//sg;
		};
	}

	#cpms m2 only
	while(my ($name, $level) = each %levels) {
		my $div_value = $div_values{$name} or die "Value not provided for ".(uc $name)."level!";
		$level->bdiv($div_value);
		$level->bfround(1);
	}

	$levels{as}->bmul('2.5'); # multiplier for correct AS
	$levels{wd}->bmul('2.5'); # multiplier for correct wd
	
	$levels{wd}->bdiv('2.5') if $char_type == 4;
	$levels{as}->bdiv('2.5') if $char_type == 5;

	return %levels;
}

sub get_minimum_level :prototype(\%) ($levels) {
	my @possible_levels = do {
		given($char_type) {
			when(1) { $levels->@{"as", "def", "mr"} } # for agi mage
			when(2) { $levels->@{"wd", "ar",  "mr"} } # for fighter
			when(3) { $levels->@{"as", "ar",  "mr"} } # for mage
			when(4) { $levels->@{"ws", "ar"},       } # for pure fighter
			when(5) { $levels->@{"as", "mr"},       } # for pure mage
			when(6) { $levels->@{"wd", "ms",  "ar"} }
		}
	};
	
	return min(@possible_levels)->copy();
}

sub low_level :prototype(\%) ($levels) {
	sleep 0.5;

	#$mech->get("http://thenewlosthope.net${URL_SERVER}fight_control.php");
	$mech->get("http://thenewlosthope.net${URL_SERVER}world_control.php");
	my $content = $mech->content();
	
	unless($content =~ m/Thief/) {
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

	my @stats = parse_stats($all);
	%$levels = get_levels(@stats,
		wd => '603',
		as => '554',
		ms => '84',
		def => '42',
		ar => '57',
		mr => '72'
	);

	display_levels(%$levels);

	my $level = get_minimum_level(%$levels);

	printf " --> Skeleton level: %.3e\n", $level->bstr();

	#return $level;
}

sub level_up :prototype($ \%) ($my_level, $levels) {
	given($char_type) {
		level_up_agi_mage($my_level, %$levels)       when 1;
		level_up_fighter($my_level, %$levels)        when 2;
		level_up_mage($my_level, %$levels)           when 3;
		level_up_pure_fighter($my_level, %$levels)   when 4;
		level_up_pure_mage($my_level, %$levels)      when 5;
		level_up_contra_fighter($my_level, %$levels) when 6;
	}
}

sub low_fight :prototype($ \% $) ($level, $levels, $steal_antal) {
	# Setup fight

	sleep 0.5;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}fight_control.php");
	my $content = $mech->content();
	
	unless($content =~ m/Skeleton/) {
		sleep 10;
		exit;
	}
	
	$mech->form_number(2);
	$mech->field("Difficulty", $level);
	$mech->click();
	$mech->form_number(1);
	$mech->click();
	
	$content = $mech->content();
	$content =~ m/(You win.*exp )/;
	$content =~ m/(battle)/;
	$content =~ m/(You have been jailed for violating our rules)/;
	
	#my $antal = 500 + int rand (500);

	# Unsure what to do here. Perhaps it's related to this commit? (near the end)
	# https://github.com/ALANVF/perl-thingy/commit/a5a43a88016b1cefda9236c07e2cd00d76cdff82#diff-f3f0aa1c7cc9604ea1bd0a6b3b5b62fa096daab0866f113d9cc5cb960eb7fa9b
	$steal_antal = $steal_antal->copy();
	$steal_antal->bdiv($loop_wait);
	$steal_antal->bfround(1);
	
	my $antal = $steal_antal->copy();

	# REPEAT:
	while($antal-- > 0) {
		sleep $loop_wait; # Default = 0.3
		
		$mech->reload();
		$content = $mech->content();
		
		given($content) {
			# KILLED
			when(m/(been.*slain)/) {
				say "ERROR - TOO HIGH MONSTER LEVEL! - you were slain!";
				exit 0;
			}

			# JAILED
			when(m/jail time.*<br>/) {
				say "You have been Jailed - Sleep 5 seconds.";
				sleep 5;
			}

			# LOGGED OUT
			when(m/logged/) {
				say "LOGGED OUT! sleeping for 5 seconds before restart";
				sleep 5;
				exit;
			}
		}

		# STEAL TIME? then exit to steal
		if($antal <= 0) {
			sleep 5;
			say "Waiting last few seconds before steal";
			exit;
		}
		
		my ($second, $minute, $hour) = localtime(time);
		
		$content =~ m/(You win.*exp )/;
		$content =~ m/(The battle tied.)/;
		say "$antal :[$hour:$minute:$second]: $1";

		# Level up if necessary
		level_up($level, %$levels) if $content =~ m/(Congra.*exp)/;
	}

	return $steal_antal;
}

sub format_number($num) {
	return $num =~ s/(?<!^)\d{3}(?=(\d{3})*$)/,$&/rgn
}

sub auto_level_up($my_level) {
	state $pure_build = 180;

	sleep 0.5;

	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	my $content = $mech->content();
	
	unless($content =~ m/Parsed/) {
		sleep 10;
		exit;
	}
	
	$content = $mech->content();

	my $actual_level = do {
		given("$content") {
			s/Level : (.*Exp :)/$1/;
			s/<\/td> .*//si;
			$_
		}
	};
	
	if($char_type == 6) {
		$alternate = 75;
	}

	while($content =~ m/Congra.*exp/) {
		# Note: there's a chance that $auto_level will never be assigned a
		#       value here. Please take note and provide default value when it
		#       happens.
		my $auto_level;

		given($char_type) {
			when(1) {
				if($agi_mage_count >= 0) {
					$auto_level = do {
						if($agi_mage_count == 6) {
							"Agility"
						} elsif($agi_mage_count >= 4) {
							"Intelligence"
						} else {
							"Concentration"
						}
					};

					$agi_mage_count--;
				}
			}
			
			when(2) {
				if($fighter_count >= 0) {
					$auto_level = do {
						if($fighter_count == 3) {
							"Dexterity"
						} elsif($fighter_count >= 2) {
							"Concentration"
						} else {
							"Strength"
						}
					};

					$fighter_count--;
				}
			}

			when(3) {
				if($mage_count >= 0) {
					$auto_level = do {
						if($mage_count == 3) {
							"Concentration"
						} elsif($mage_count >= 2) {
							"Dexterity"
						} else {
							"Intelligence"
						}
					};
					
					$mage_count--;
				}
			}

			when(4) {
				if($pure_fighter_count >= 0) {
					$auto_level = do {
						if($pure_fighter_count == 3) {
							"Strength"
						} else {
							"Dexterity"
						}
					};

					$pure_fighter_count--;
				}
			}		
			
			when(5) {
				if($pure_mage_count >= 0) {
					$auto_level = do {
						if($pure_mage_count >= 3) {
							"Intelligence"
						} else {
							"Concentration"
						}
					};

					$pure_mage_count--;
				}
			}

			when(6) {
				if($cf_count ~~ [1..17]) {
					$auto_level = do {
						given($cf_count) {
							"Strength"      when [11, 14, 17];
							"Dexterity"     when [8, 10, 13, 16];
							"Contravention" when [1..7, 9, 12, 15];
						}
					};

					$cf_count--;
				}
			}

			when([7..12]) {
				if($pure_build >= 0) {
					$auto_level = do {
						given($char_type) {
							"Strength"      when 7;
							"Dexterity"     when 8;
							"Agility"       when 9;
							"Intelligence"  when 10;
							"Concentration" when 11;
							"Contravention" when 12;
						}
					};

					$pure_build--;
				}
			}
		}

		$mech->form_number(1);

		if($content =~ m/Freeplay/i || $my_level > $MASS_LEVEL) {
			$mech->field("Stats", $auto_level);
			$mech->click_button(name => "Stats", value => $auto_level);
		} else {
			$mech->field("cStats", $auto_level);
			$mech->click_button(name => "cStats", value => $auto_level);
		}

		$content = $mech->content();
		
		my $level1 = do {
			given("$content") {
				s/Level : (.*Exp :)/$1/;
				s/<\/td> .*//si;
				s/,//s;
				s/m1/000000/si;
				s/m2/000000000000/si;
				s/m3/000000000000000000/si;
				$_
			}
		};

		my $level2 = do {
			given("$content") {
				s/You leveled up (.*) levels!/$1/;
				s/\D//gs;
				$_
			}
		};

		$actual_level = $level1 + $level2;

		my $formatted_level = format_number($actual_level);
		say "[Level : $formatted_level][$alternate] You Auto-Leveled $auto_level";
		
		if(--$alternate == 0) {
			test_shop();
			exit;
		}

		$agi_mage_count = 6     if $agi_mage_count == 0;
		$fighter_count = 3      if $fighter_count == 0;
		$mage_count = 3         if $mage_count == 0;
		$pure_fighter_count = 3 if $pure_fighter_count == 0;
		$pure_mage_count = 3    if $pure_mage_count == 0;
		$cf_count = 17          if $cf_count == 0;
		$pure_build = 180       if $pure_build == 0;

		if($actual_level >= $max_level) {
			say "Max level reached, exiting.";
			exit;
		}

		sleep 0.5;
	}
}

sub cpm_level :prototype(\%) ($levels) {
	sleep 0.5;
	
	#$mech->get("http://thenewlosthope.net${URL_SERVER}fight_control.php");
	$mech->get("http://thenewlosthope.net${URL_SERVER}world_control.php");
	my $content = $mech->content();
	
	unless($content =~ m/Thief/) {
		sleep 10;
		exit;
	}

	$mech->form_number(1);
	$mech->click();
	my $all = $mech->content();
	
	# Test for free upgrade
	if($all =~ m/Click here to upgrade/) {
		sleep 0.5;
		
		$mech->form_number(0);
		$mech->click();
		
		say "Free upgrade detected and cleared. Restarting";

		exit;
	}

	my @stats = parse_stats($all);
	%$levels = get_levels(@stats,
		wd => '1661622',
		as => '1877897',
		ms => '3028631',
		def => '1817170',
		ar => '363482.2',
		mr => '363497.2'
	);

	display_levels(%$levels);
	
	my $level = get_minimum_level(%$levels);

	printf " --> CPM level: %.3e\n", $level->bstr();

	return $level;
}

sub shorten_amount($amount) {
	my $length = length $amount;

	if($length >= 7) {
		my $replace_num = int(($length - 1) / 6);
		my $num_digits = $replace_num * 6;

		$amount =~ s/\d{$num_digits}$/ M$replace_num/
	}

	return $amount
}

sub fight :prototype($ $ $ $ $ \% $) ($name, $level, $my_level, $for_level, $next_level, $levels, $steal_antal) {
	# Setup fight

	state $wait_div = new Math::BigFloat;
	state $exper3 = new Math::BigFloat;
	state $exper_average = new Math::BigFloat;
	state $reload_count = 0;
	state $gold3 = new Math::BigFloat;
	state $gold_average = new Math::BigFloat;
	state $exper_seconds;
	state $exper_minutes;
	state $exper_hours;
	state $exper_days;
	state $gold_seconds;
	state $gold_minutes;
	state $gold_hours;
	state $gold_days;
	
	sleep 0.5;
	
	$mech->get("http://thenewlosthope.net${URL_SERVER}fight_control.php");
	my $content = $mech->content();
	
	unless($content =~ m/Skeleton/) {
		sleep 10;
		exit;
	}

	$mech->form_number(2);
	$mech->field("Difficulty", $level);
	$mech->click();
	my $cpm = $mech->content();

	($cpm) = $cpm =~ m/(<option>208.*Duke)/;
	$cpm =~ s/ - Shadowlord Duke//g;
	$cpm =~ s/>209/>/;
	$cpm =~ s/<.*?>//g;

	say $cpm;
	
	$mech->form_number(1);
	$mech->select("Monster", $cpm);
	$mech->click();
	$content = $mech->content();
	
	# Unsure what's going on here. All 3 of these are useless
	$content =~ m/(You win.*exp )/;
	$content =~ m/(battle)/;
	$content =~ m/(You have been jailed for violating our rules)/;
	
	$steal_antal = $steal_antal->copy();
	$steal_antal->bdiv($loop_wait);
	$steal_antal->bfround(1);

	my $antal = $steal_antal->copy();
	my $jail;
	my $average_count_down = 900;
	my $date_string;

	# REPEAT:
	while($antal > 0) {
		sleep $loop_wait; # Default = 0.3

		$antal--;
		
		$mech->reload();
		
		unless($content =~ m/(The battle tied.)/) {
			$average_count_down--;
			$wait_div += $loop_wait;
		}

		$content = $mech->content();
		
		if($average_count_down >= 1) {
			my $did_tie = $content =~ m/The battle tied./;

			my $exper = $content;
			($exper) = $exper =~ m/(You win.*exp )/;
			$exper =~ s/,//sg;
			$exper =~ s/You//s;
			$exper =~ s/win//s;
			$exper =~ s/exp//s;
			$exper =~ s/\s//sg;
			my $exper2 = $did_tie ? 0 : new Math::BigFloat $exper;
			$exper3 = $exper2 + $exper3;
			
			my $gold = $content;
			($gold) = $gold =~ m/(exp and.*gold.)/;
			$gold =~ s/exp//s;
			$gold =~ s/and//s;
			$gold =~ s/,//sg;
			$gold =~ s/gold//s;
			$gold =~ s/\.//s;
			$gold =~ s/\s//sg;
			my $gold2 = $did_tie ? 0 : new Math::BigFloat $gold;
			$gold3 = $gold2 + $gold3;
			
			unless($did_tie) {
				$reload_count++;
			}

			if($wait_div >= 300.0) {
				$reload_count = ($reload_count / $wait_div) * 300;
				$exper_average = $exper3 / $reload_count;
				$exper_average =~ s/\..*//s; # Remove after
				$gold_average = $gold3 / $reload_count;
				$gold_average =~ s/\..*//s; # Remove after
				$wait_div = 0;
				$exper3 = 0;
				$gold3 = 0;
				$reload_count = 0;
				
				my $exper_second = new Math::BigFloat $exper_average;
				my $exper_minute = $exper_second * 60;
				my $exper_hour = $exper_second * 3600;
				my $exper_day = $exper_second * 86400;
				
				my $gold_second = new Math::BigFloat $gold_average;
				my $gold_minute = $gold_second * 60;
				my $gold_hour = $gold_second * 3600;
				my $gold_day = $gold_second * 86400;

				#Time to level
				my $next_level_time = new Math::BigFloat $next_level / $exper_average;
				my $epoc = time() + $next_level_time;
				$date_string = strftime '%x %H:%M:%S', localtime($epoc);
				
				$exper_average = format_number($exper_average);
				$exper_seconds = format_number(shorten_amount($exper_second));
				$exper_minutes = format_number(shorten_amount($exper_minute));
				$exper_hours = format_number(shorten_amount($exper_hour));
				$exper_days = format_number(shorten_amount($exper_day));
				$gold_average = format_number($gold_average);
				$gold_seconds = format_number(shorten_amount($gold_second));
				$gold_minutes = format_number(shorten_amount($gold_minute));
				$gold_hours = format_number(shorten_amount($gold_hour));
				$gold_days = format_number(shorten_amount($gold_day));
				$next_level = format_number(shorten_amount($next_level));
			}
		} elsif($average_count_down == 0) {
			my ($second, $minute, $hour, $day, $month, $year) = localtime(time);
			$year += 1900;
			my $month_name = $MONTHS[$month];
			$month += 1;
			
			open(FILE, ">>$name $file_fix ~ $month_name $year.txt") or die "failed to open file!!!!";
			
			say "";

			for my $output (*FILE, *STDOUT) {
				say $output "MAIN STATUS FOR $name at $hour:$minute:$second~$day/$month/$year\n";
				say $output "$name\'s current level is $for_level";
				say $output "You need $next_level EXP to level";
				say $output "You can expect to level on $date_string";
				printf $output "Your current CPM level is : %.3e\n", $level->bstr();
			}
			
			display_levels(%$levels, *FILE);
			
			say FILE "SHOP STATUS FOR $name at $hour:$minute:$second~$day/$month/$year\n";
			say FILE "Current Max:		$SHOPMAX";
			say FILE "WEAPON:			$SHOPWEAP";
			say FILE "ATTACKSPELL:		$SHOPAS";
			say FILE "HEALSPELL:		$SHOPHS";
			say FILE "HELMET:			$SHOPHELM";
			say FILE "SHIELD:			$SHOPSHIELD";
			say FILE "AMULET:			$SHOPAMULET";
			say FILE "RING:			$SHOPRING";
			say FILE "ARMOR:			$SHOPARMOR";
			say FILE "BELT:			$SHOPBELT";
			say FILE "PANTS:			$SHOPPANTS";
			say FILE "HAND:			$SHOPHAND";
			say FILE "FEET:			$SHOPFEET\n";
		
			for my $output (*FILE, *STDOUT) {
				say $output "AVERAGE'S FOR $name at $hour:$minute:$second~$day/$month/$year\n";
				say $output "You can expect: $exper_seconds EXP/Sec.";
				say $output "You can expect: $gold_seconds GOLD/Sec.";
				say $output "You can expect: $exper_minutes EXP/Min.";
				say $output "You can expect: $gold_minutes GOLD/Min.";
				say $output "You can expect: $exper_hours EXP/Hour.";
				say $output "You can expect: $gold_hours GOLD/Hour.";
				say $output "You can expect: $exper_days EXP/Day.";
				say $output "You can expect: $gold_days GOLD/Day.\n";
			}
			
			close FILE;
		}

		# KILLED
		if($content =~ m/(been.*slain)/) {
			say "ERROR - TOO HIGH MONSTER LEVEL! - you were slain!";
			exit 0;
		}

		# JAILED
		if($content =~ m/jail time.*<br>/) {
			say "You have been Jailed - Sleep 5 seconds.";
			sleep 5;
		}

		# LOGGED OUT
		if($content =~ m/logged/) {
			say "LOGGED OUT! sleeping for 5 seconds before restart!";
			sleep 60;
			exit;
		}

		# STEAL TIME? then exit to steal
		if($antal <= 0) {
			sleep 5;
			say "Waiting last few seconds before steal";
			exit;
		}
		
		my ($second, $minute, $hour) = localtime(time);

		$content =~ m/(You win.*exp )/;
		$content =~ m/(The battle tied.)/;
		
		say "$antal: [$hour:$minute:$second]: $1";

		# level up if necessary
		level_up($my_level, %$levels) if $content =~ m/(Congra.*exp)/;
	}

	return $steal_antal;
}

sub level_up_agi_mage :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		given(min($levels->@{"as", "def", "mr"})) {
			"Intelligence"  when $levels->{as};
			"Agility"       when $levels->{def};
			"Concentration" when $levels->{mr};
		}
	};

	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	sleep 1;
	test_shop() if $stat_value eq "Intelligence";
}


sub level_up_fighter :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		given(min($levels->@{"wd", "ar", "mr"})) {
			"Strength"      when $levels->{ws};
			"Dexterity"     when $levels->{ar};
			"Concentration" when $levels->{mr};
		}
	};

	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	test_shop() if $stat_value eq "Strength";
}

sub level_up_mage :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		given(min($levels->@{"as", "ar", "mr"})) {
			"Intelligence"  when $levels->{as};
			"Dexterity"     when $levels->{ar};
			"Concentration" when $levels->{mr};
		}
	};

	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	test_shop() if $stat_value eq "Intelligence";
}

sub level_up_pure_fighter :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		if($levels->{wd} <= $levels->{ar}) {
			"Strength"
		} else {
			"Dexterity"
		}
	};
	
	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	test_shop() if $stat_value eq "Strength";
}
	
sub level_up_pure_mage :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		if($levels->{as} <= $levels->{mr}) {
			"Intelligence"
		} else {
			"Concentration"
		}
	};
	
	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	sleep 0.5;
	test_shop() if $stat_value eq "Intelligence";
}

sub level_up_contra_fighter :prototype($ \%) ($my_level, $levels) {
	$mech->get("http://thenewlosthope.net${URL_SERVER}stats.php");
	
	sleep 0.5;

	my $stat_name = do {
		if($my_level <= $MASS_LEVEL) {
			"cStats"
		} else {
			"Stats"
		}
	};

	my $stat_value = do {
		given(min($levels->@{"wd", "ms", "ar"})) {
			"Strength"      when $levels->{wd};
			"Contravention" when $levels->{ms};
			"Dexterity"     when $levels->{ar};
		}
	};

	$mech->form_number(1);
	$mech->field($stat_name, $stat_value);
	$mech->click_button(name => $stat_name, value => $stat_value);

	say "You Leveled up $stat_value";
	sleep 1;
	test_shop() if $stat_value eq "Strength";
}

sub get_content($url, $wait = 1) {
	my $content;
	
	while(1) {
		sleep $wait;
		
		$mech->get($url);
		$content = $mech->content();
		
		last if $content =~ m/Parsed/;
	}

	return $content;
}

sub check_shop($update_shop) {
	my $content = get_shop_content("http://thenewlosthope.net${URL_SERVER}shop.php");

	$content =~ s/(.*)(shopping)//si; #remove before
	$content =~ s/<\/form>.*//s; #remove after
	$content =~ s/maxlength//sgi;
	$content =~ s/\(//sg;
	$content =~ s/\)//sg;
	$content =~ s/maxed/fullshop/sgi;
	$content =~ s/\s//sg;
	$content =~ s/\n//sgi;
	$content =~ s/<\/th>//sgi;
	$content =~ s/<\/tr>//sgi;
	$content =~ s/<\/td>//sgi;
	$content =~ s/<tr>//sgi;
	$content =~ s/<td>//sgi;
	$content =~ s/width/1/si;
	$content =~ s/width/2/si;
	$content =~ s/width/3/si;
	$content =~ s/width/4/si;
	$content =~ s/width/5/si;
	$content =~ s/width/6/si;
	$content =~ s/width/7/si;
	$content =~ s/width/8/si;
	$content =~ s/width/9/si;
	$content =~ s/width/a/si;
	$content =~ s/width/b/si;
	$content =~ s/width/c/si;

	#open(FILE, ">$file_fix shops.txt")
	#or die "failed to open file!!!!";
	#print FILE "$content\n";
	#close(FILE);
	
	# Max
	my $max = $content;
	$max =~ s/(.*)(max)//si; #remove before
	$max =~ s/price.*//si; #remove after
	$SHOPMAX = $max if $update_shop;
	$max =~ s/,//sg;

	# Weapon
	my $aweap = $content;
	$aweap =~ s/td1.*//si; #remove after
	$aweap =~ s/(.*)(weapon)//si; #remove before
	$aweap =~ s/\$.*//si; #remove after
	$SHOPWEAP = $aweap if $update_shop;
	$aweap =~ s/,//sg;
	if($aweap >= $max) {
		$shop1 = 1;
		$aweap = "Maxed";
	} else {
		$shop1 = 0;
	}
	
	# Attack spell
	my $aas = $content;
	$aas =~ s/(.*)(^td1)//si; #remove before
	$aas =~ s/td2.*//si; #remove after
	$aas =~ s/(.*)(attackspell)//si; #remove before
	$aas =~ s/\$.*//si; #remove after
	$SHOPAS = $aas if $update_shop;
	$aas =~ s/,//sg;
	if($aas >= $max) {
		$shop2 = 1;
		$aas = "Maxed";
	} else {
		$shop2 = 0;
	}

	# Heal spell
	my $ahs = $content;
	$ahs =~ s/(.*)(td2)//si; #remove before
	$ahs =~ s/td3.*//si; #remove after
	$ahs =~ s/(.*)(healspell)//si; #remove before
	$ahs =~ s/\$.*//si; #remove after
	$SHOPHS = $ahs if $update_shop;
	$ahs =~ s/,//sg;
	if($ahs >= $max) {
		$shop3 = 1;
		$ahs = "Maxed";
	} else {
		$shop3 = 0;
	}
	
	# Helmet
	my $ahelm = $content;
	$ahelm =~ s/(.*)(td3)//si; #remove before
	$ahelm =~ s/td4.*//si; #remove after
	$ahelm =~ s/(.*)(helmet)//si; #remove before
	$ahelm =~ s/\$.*//si; #remove after
	$SHOPHELM = $ahelm if $update_shop;
	$ahelm =~ s/,//sg;
	if($ahelm >= $max) {
		$shop4 = 1;
		$ahelm = "Maxed";
	} else {
		$shop4 = 0;
	}
	
	# Shield
	my $ashield = $content;
	$ashield =~ s/(.*)(td4)//si; #remove before
	$ashield =~ s/td5.*//si; #remove after
	$ashield =~ s/(.*)(shield)//si; #remove before
	$ashield =~ s/\$.*//si; #remove after
	$SHOPSHIELD = $ashield if $update_shop;
	$ashield =~ s/,//sg;
	if($ashield >= $max) {
		$shop5 = 1;
		$ashield = "Maxed";
	} else {
		$shop5 = 0;
	}
	
	# Amulet
	my $aamulet = $content;
	$aamulet =~ s/(.*)(td5)//si; #remove before
	$aamulet =~ s/td6.*//si; #remove after
	$aamulet =~ s/(.*)(amulet)//si; #remove before
	$aamulet =~ s/\$.*//si; #remove after
	$SHOPAMULET = $aamulet if $update_shop;
	$aamulet =~ s/,//sg;
	if($aamulet >= $max) {
		$shop6 = 1;
		$aamulet = "Maxed";
	} else {
		$shop6 = 0;
	}
	
	# Ring
	my $aring = $content;
	$aring =~ s/(.*)(td6)//si; #remove before
	$aring =~ s/td7.*//si; #remove after
	$aring =~ s/(.*)(ring)//si; #remove before
	$aring =~ s/\$.*//si; #remove after
	$SHOPRING = $aring if $update_shop;
	$aring =~ s/,//sg;
	if($aring >= $max) {
		$shop7 = 1;
		$aring = "Maxed";
	} else {
		$shop7 = 0;
	}
	
	# Armor
	my $aarm = $content;
	$aarm =~ s/(.*)(td7)//si; #remove before
	$aarm =~ s/td8.*//si; #remove after
	$aarm =~ s/(.*)(armor)//si; #remove before
	$aarm =~ s/\$.*//si; #remove after
	$SHOPARMOR = $aarm if $update_shop;
	$aarm =~ s/,//sg;
	if($aarm >= $max) {
		$shop8 = 1;
		$aarm = "Maxed";
	} else {
		$shop8 = 0;
	}
	
	# Belt
	my $abelt = $content;
	$abelt =~ s/(.*)(td8)//si; #remove before
	$abelt =~ s/td9.*//si; #remove after
	$abelt =~ s/(.*)(belt)//si; #remove before
	$abelt =~ s/\$.*//si; #remove after
	$SHOPBELT = $abelt if $update_shop;
	$abelt =~ s/,//sg;
	if($abelt >= $max) {
		$shop9 = 1;
		$abelt = "Maxed";
	} else {
		$shop9 = 0;
	}
	
	# Pants
	my $apants = $content;
	$apants =~ s/(.*)(td9)//si; #remove before
	$apants =~ s/tda.*//si; #remove after
	$apants =~ s/(.*)(pants)//si; #remove before
	$apants =~ s/\$.*//si; #remove after
	$SHOPPANTS = $apants if $update_shop;
	$apants =~ s/,//sg;
	if($apants >= $max) {
		$shop10 = 1;
		$apants = "Maxed";
	} else {
		$shop10 = 0;
	}
	
	# Hand
	my $ahand = $content;
	$ahand =~ s/(.*)(tda)//si; #remove before
	$ahand =~ s/tdb.*//si; #remove after
	$ahand =~ s/(.*)(hand)//si; #remove before
	$ahand =~ s/\$.*//si; #remove after
	$SHOPHAND = $ahand if $update_shop;
	$ahand =~ s/,//sg;
	if($ahand >= $max) {
		$shop11 = 1;
		$ahand = "Maxed";
	} else {
		$shop11 = 0;
	}
	
	# Feet
	my $afeet = $content;
	$afeet =~ s/(.*)(tdb)//si; #remove before
	$afeet =~ s/tdc.*//si; #remove after
	$afeet =~ s/(.*)(feet)//si; #remove before
	$afeet =~ s/\$.*//si; #remove after
	$SHOPFEET = $afeet if $update_shop;
	$afeet =~ s/,//sg;
	if($afeet >= $max) {
		$shop12 = 1;
		$afeet = "Maxed";
	} else {
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

sub test_shop() {
	check_shop(0);

	if($shop_yes_no == 1) {
		buy_upgrades();
	} else {
		say "Shops were not bought this time";
		exit;
	}
}
	
sub buy_upgrades() {
	my $content = get_content("http://thenewlosthope.net${URL_SERVER}shop.php");
	
	$mech->form_number(1);

	my $maxshop = "9e99";
	
	given($char_type) {
		when(1) {
			$mech->field("Attackspell", $maxshop) if $shop2 == 0;
			$mech->field("Helmet", $maxshop) if $shop4 == 0;
			$mech->field("Shield", $maxshop) if $shop5 == 0;
			$mech->field("Amulet", $maxshop) if $shop6 == 0;
			$mech->field("Ring", $maxshop) if $shop7 == 0;
			$mech->field("Armor", $maxshop) if $shop8 == 0;
			$mech->field("Belt", $maxshop) if $shop9 == 0;
			$mech->field("Pants", $maxshop) if $shop10 == 0;
			$mech->field("Hand", $maxshop) if $shop11 == 0;
			$mech->field("Feet", $maxshop) if $shop12 == 0;
		}

		when(2) {
			$mech->field("Weapon", $maxshop) if $shop1 == 0;
			$mech->field("Belt", $maxshop) if $shop9 == 0;
			$mech->field("Hand", $maxshop) if $shop11 == 0;
			$mech->field("Feet", $maxshop) if $shop12 == 0;
		}

		when(3) {
			$mech->field("Attackspell", $maxshop) if $shop2 == 0;
			$mech->field("Ring", $maxshop) if $shop7 == 0;
			$mech->field("Belt", $maxshop) if $shop9 == 0;
			$mech->field("Feet", $maxshop) if $shop12 == 0;
		}

		when(4) {
			$mech->field("Weapon", $maxshop) if $shop1 == 0;
			$mech->field("Hand", $maxshop) if $shop11 == 0;
			$mech->field("Feet", $maxshop) if $shop12 == 0;
		}

		when(5) {
			$mech->field("Attackspell", $maxshop) if $shop2 == 0;
			$mech->field("Ring", $maxshop) if $shop7 == 0;
			$mech->field("Belt", $maxshop) if $shop9 == 0;
		}

		when(6) {
			$mech->field("Weapon", $maxshop) if $shop1 == 0;
			$mech->field("Amulet", $maxshop) if $shop6 == 0;
			$mech->field("Ring", $maxshop) if $shop7 == 0;
			$mech->field("Hand", $maxshop) if $shop11 == 0;
			$mech->field("Feet", $maxshop) if $shop12 == 0;
		}
	}

	$mech->click_button(name => "action", value => "Buy upgrades!");
	$content = $mech->content();
	
	if($content =~ m/Total/) {
		$content =~ m/(Buy.*gold\.)/s;
		$content = $1;
		$content =~ s/<br>/\n/sg;
		
		say "you maxed some shops:";
		say $content;
	}
	
	if($content =~ m/Not enough gold!/) {
		say "You did not have enough Gold in your hand to max all your shops.";
	}
	
	sleep 0.5;
}

sub get_my_level() {
	my $content = get_content("http://thenewlosthope.net${URL_SERVER}main.php", 0.5);
	
	$content =~ s/<.*?>//sg;
	$content =~ m/(Level : .*)/s;
	$content =~ s/\n/ /g;
	$content =~ s/LordsofLords/ /g;
	$content =~ s/ //g;
	$content =~ s/Exp.*//;
	$content =~ s/\D//g;
	$content =~ s/,//g;
	
	my $my_level = new Math::BigFloat $content;
	my $for_level = format_number($content);
	
	say "Your Level is : $for_level";
	
	if($max_level <= $my_level) {
		say "You have reached the desired level : EXITING!!";
		sleep 30;
		exit;
	}

	return ($for_level, $my_level);
}

sub get_char_name($hour, $minute, $second) {
	my $content = get_content("http://thenewlosthope.net${URL_SERVER}stats.php", 0.5);

	my ($title, $name) = do {
		given("$content") {
			s/(.*)(natural)//si; #remove before
			s/th.*//si; #remove after
			s/<\///si;
			s/(.*)(for)//si; #remove before
			m/(\w+)\s+(\w+)/
		}
	};
	
	say "\nSuccessfully logged into $title $name at $hour:$minute:$second\n";
	
	my $next_level = do {
		given("$content") {
			s/You need(.*)exp /$1/;
			s/[\s,]//g;
			$_
		}
	};
	
	return ($title, $name, new Math::BigFloat $next_level);
}

#---------------------
# MAIN
#---------------------

# create a new browser

$mech = new WWW::Mechanize autocheck => 1, stack_depth => 0;
$mech->timeout(5); #2 second timeout! for n00b SilenT
$mech->agent_alias( 'Windows Mozilla' );

say " 
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
";

#Login

my @logins;

# It might be worth putting an error message if $server isn't 1 or 2?
if($server == 1) {
	open(LOGINS, "m3logins.txt") or die "failed to open Logins file!!!!";
	@logins = <LOGINS>;
	close(LOGINS);
} elsif($server == 2) {
	open(LOGINS, "sotselogins.txt") or die "failed to open Logins file!!!!";
	@logins = <LOGINS>;
	close(LOGINS);
}

# If 35 isn't an actual limit for the number of logins, you could probably do
# `1..($#logins + 1)` to do this for *every* login instead.
for my $i (1..35) {
	until($username ne $i) {
		($username, $password) = split(" ", $logins[$i - 1]);
		chomp($username, $password);
	}
}

sleep 0.5;

$mech->get("http://thenewlosthope.net${URL_SERVER}login.php");
my $content = $mech->content();

if($content !~ m/Enter Lol!/) {
	sleep 10;
	exit;
}

if($content !~ m/Username/) {
	sleep 5;
	exit;
}

$mech->form_number(0);
$mech->field("Username", $username);
$mech->field("Password", $password);
$mech->click();

my ($second, $minute, $hour) = localtime(time);
#print "[$hour:$minute:$second] - logged in Successfully to : \n";


my $steal_antal = new Math::BigFloat;
my $num_levels = 9999999;
my %levels = (
	wd => new Math::BigFloat,
	as => new Math::BigFloat,
	ms => new Math::BigFloat,
	def => new Math::BigFloat,
	ar => new Math::BigFloat,
	mr => new Math::BigFloat
);

# Not sure what this is supposed to be doing? This is an infinite loop :/
for(my $cur_level = $num_levels; $cur_level > 0; $cur_level++) {
	my ($title, $name, $next_level) = get_char_name($hour, $minute, $second);
	
	my ($my_level, $for_level) = get_my_level();
	
	check_shop(1);
	
	if($my_level <= 2500000) {
		say "\nLow Level Fight mode\n";
	} else {
		say "\nHigh Level Fight mode\n";
	}
	
	if(get_steal_wait() == 0) {
		#my ($status, $result) = merge_test();
		#if($status) {
		#	merge($result);
		#} else {
			steal($title);
		#}
	}

	auto_level_up($my_level);
	
	if($my_level <= 2500000) {
		low_level(%levels);
		$steal_antal = low_fight($my_level, %levels, $steal_antal);
	} else {
		cpm_level(%levels);
		$steal_antal = fight($name, $cur_level, $my_level, $for_level, $next_level, %levels, $steal_antal);
	}
}


exit;