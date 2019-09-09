#include <iostream>
#include <stdio.h>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;

vector<char> vowels{'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U', 'y', 'Y'};
vector<char> sentend{'.', ':', ';', '?', '!'};

struct doc {
	int word;
	int syll;
	int sent;
};

struct doc tally(char filename[]);

int main(int argc, char* argv[]){
	if(argc != 2){
		cerr << "Wrong number of arguments.\n";
	}
	doc count = tally(argv[1]);
	
	//flesch
	double alpha;
	double beta;
        alpha = (double)count.syll / (double)count.word;
        beta = (double)count.word / (double)count.sent;
        double dubIndex = 206.835 - alpha*84.6 - beta*1.015;
        int findex = round(dubIndex);
	
	//flesch-kincaid
	alpha = (double)count.syll / (double)count.word;
	beta = (double)count.word / (double)count.sent;
	dubIndex = alpha*11.8 + beta*0.39 - 15.59;
	
	printf("%i\t%.1f\n", findex, dubIndex);

}

//counts the words, syllables, and sentences in a text file.
struct doc tally(char filename[]){
	int wordcount = 0;
	int syllcount = 0;
	int sentcount = 0;
	bool validword = false;
	bool validsent = false;
	bool lchvowel = false;
	
	ifstream text;
	text.open(filename);
	if(!text.is_open()){
		cerr << "Failed to open." << endl;
		doc empty;
		return empty;
	}
	char w = 0;
	char lastw = 0;
	while(text.get(w)){
		if(lastw == 'e' && (w == ' ' || w == '\n')){
			--syllcount;
		}
		if(w == ' ' || w == '\n'){//whitespace
			if(validword){
				++wordcount;
			}
			validword = false;
		}
		
		if(('A' <= w && w <= 'Z') || ('a' <= w && w <= 'z')){//letter check
			validword = true;
			validsent = true;
		}
		
		if(find(vowels.begin(), vowels.end(), w) != vowels.end()){//vowels for syll
			if(!lchvowel){
				++syllcount;
			}
			lchvowel = true;
		}else{
			lchvowel = false;
		}
		
		if(find(sentend.begin(), sentend.end(), w) != sentend.end()){//sentences
			if(validsent){
				++sentcount;
				validsent = false;
			}
		}
	}
	if(validsent){
		++sentcount;
	}

	doc give;
	give.word = wordcount;
	give.syll = syllcount;
	give.sent = sentcount;

	return give;
}




