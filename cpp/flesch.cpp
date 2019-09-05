#include <iostream>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;

vector<char> vowels{'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U', 'y', 'Y'};
vector<char> sentend{'.', ':', ';', '?', '!'};

int main(){
	int wordcount = 0;
	int syllcount = 0;
	int sentcount = 0;
	bool validword = false;
	bool validsent = false;
	bool lchvowel = false;
	double alpha;
	double beta;
	
	ifstream text;
	text.open("/home/moshell_jw/alice.txt");
	if(!text.is_open()){
		cerr << "Failed to open." << endl;
		return 0;
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

	alpha = (double)syllcount / (double)wordcount;
	beta = (double)wordcount / (double)sentcount;
	double dubIndex = 206.835 - alpha*84.6 - beta*1.015;
	int index = round(dubIndex);
	
	cout << index << endl;





}
