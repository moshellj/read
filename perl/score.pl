#!/usr/bin/perl

$docFilename = $ARGV[0];
$/ = undef;
@stats = count($docFilename);
$alpha = $stats[0]/$stats[1];
$beta =  $stats[1]/$stats[2];

printf("Flesch Index: %d\n", int(206.835 - $alpha*84.6 - $beta*1.015 + 0.5));
printf("Flesch-Kincaid Index: %.1f\n", ($alpha*11.8 + $beta*0.39 -15.59));

#END MAIN

#counts syllables, words, sentences, later dale-chall
sub count {
	my $sentcount = 0;
	my $validsent = 0;#false
	my $wordcount = 0;
	my $syllcount = 0;
	my $syllinword = 0;
	
	open(doc, $_[0]) or die "file not found\n";
	my $rawdoc = <doc>;
	my @tokens = split(/[\n ]/, $rawdoc);
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
			$syllinword = () = $token =~ /[aeiouy]+/g;
			if($token =~ /e$/){
				$syllinword--;
			}
			if($syllinword < 1){
				$syllinword = 1;
			}
			$syllcount = $syllcount + $syllinword;
		}
	}
	#print "Sylls = $syllcount\nWords = $wordcount\nSents = $sentcount\n";
	return ($syllcount, $wordcount, $sentcount);
	close(doc);
}
