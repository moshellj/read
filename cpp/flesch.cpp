#include <iostream>
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

int main(){
	doc count = tally("/home/moshell_jw/alice.txt");
	
	int alpha;
	int beta;
        alpha = (double)count.syll / (double)count.word;
        beta = (double)count.word / (double)count.sent;
        double dubIndex = 206.835 - alpha*84.6 - beta*1.015;
        int findex = round(dubIndex);

        cout << findex << endl;

}


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
	
	while(text.get(w)){
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




