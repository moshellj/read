#!/usr/bin/perl

$docFilename = $ARGV[0];
@stats = count($docFilename);
$alpha = $stats[0]/$stats[1];
$beta =  $stats[1]/$stats[2];
$dcalpha = $stats[3]/$stats[1];
$dcscore = ($dcalpha*15.79 + $beta*0.0496);
if($dcalpha > 0.05){
	$dcscore = $dcscore + 3.6365;
}

printf("Flesch Index: %d\n", int(206.835 - $alpha*84.6 - $beta*1.015 + 0.5));
printf("Flesch-Kincaid Index: %.1f\n", ($alpha*11.8 + $beta*0.39 -15.59));
printf("Dale-Chall Readability Score: %.1f\n", $dcscore);

#END MAIN

#counts syllables, words, sentences, later dale-chall
sub count {
	my $sentcount = 0;
	my $validsent = 0;#false
	my $wordcount = 0;
	my $syllcount = 0;
	my $syllinword= 0;	
	my $diffcount = 0;

	open(doc, $_[0]) or die "file not found\n";
	$/ = undef;
	my $rawdoc = <doc>;
	
	open(dcwl, "/pub/pounds/CSC330/dalechall/wordlist1995.txt") or die "Dale-chall word list not found\n";
	my $easyraw = <dcwl>;
	
	my @tokens = split(/[\n ]/, $rawdoc);
	$rawdoc = "";#optimization
	@easies = split(/\n/, $easyraw);
	
	for my $easy (@easies){
		$easy = lc($easy);
		$easy =~ s/[^a-z]//g;
	}
	
	for my $token (@tokens) {
		$token = lc($token);
		
		if($token =~ /[\.\?!;:]/){#punct
			if($validsent){
				$sentcount++;
			}
			$validsent = 0;
		}
		
		if($token =~ /[a-z]/){#word
			$wordcount++;
			$validsent = 1;
			$token =~ s/[^a-z]//g;
			
			#syllables
			$syllinword = () = $token =~ /[aeiouy]+/g;
			if($token =~ /e$/){
				$syllinword--;
			}
			if($syllinword < 1){
				$syllinword = 1;
			}
			$syllcount = $syllcount + $syllinword;
			
			#dalechall
			if(!isEasy($token)){
				$diffcount++;
			}
		}
	}
	#print "Sylls = $syllcount\nWords = $wordcount\nSents = $sentcount\n";
	return ($syllcount, $wordcount, $sentcount, $diffcount);
	close(doc);
}

sub isEasy{
	my $word = $_[0];
	my $lob = 0;
	my $hib = @easies;
	my $mid;
	while(1){
		$mid = int(($lob+$hib)/2);
		#printf("%4d  %4d  %4d  " . $word . "  " . $easies[$mid] . "\n", $lob, $mid, $hib);
		if($word lt $easies[$mid]){
			$hib = $mid;
		}elsif($word gt $easies[$mid]){
			$lob = $mid + 1;
		}else{#equal
			#print "EASY\n";
			return 1;
		}
		if($lob == $hib){
			#print "HARD\n";
			return 0;
			last;
		}
	}
	return 0;
}
