#include <iostream>
#include <stdio.h>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <vector>
#include <string>
#include <cctype>
#include <cstdlib>

using namespace std;

const vector<char> vowels{'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U', 'y', 'Y'};
const vector<char> sentend{'.', ':', ';', '?', '!'};

struct doc {
	long word;
	long syll;
	long sent;
};

struct doc tally(char filename[], vector<string>& words);
vector<string> getEasies(char filename[]);
long judgeWords(vector<string>& dict, vector<string>& words);

int main(int argc, char* argv[]){
	if(argc != 2){
		cerr << "Wrong number of arguments. Use one argument: the filepath to the text to be analyzed.\n";
		return 0;
	}
	
	vector<string> words;
	
	//count words, syllables, and sentences, and tokenize words
	doc count = tally(argv[1], words);
	if(count.syll == 0){
		return 0;
	}
	
	//flesch
	double alpha;
	double beta;
        alpha = (double)count.syll / (double)count.word;
        beta = (double)count.word / (double)count.sent;
        double dubIndex = 206.835 - alpha*84.6 - beta*1.015;
        int findex = round(dubIndex);
	
	//flesch-kincaid
	//alpha = (double)count.syll / (double)count.word;
	//beta = (double)count.word / (double)count.sent;
	dubIndex = alpha*11.8 + beta*0.39 - 15.59;
	
	//dale-chall
	vector<string> easyWords = getEasies("/pub/pounds/CSC330/dalechall/wordlist1995.txt");
	
	long diffWords = judgeWords(easyWords, words);
	
	double dcalpha = (double)diffWords / (double)count.word;
	double dalechall = dcalpha*100.0*0.1579 + beta*0.0496;
	if(dcalpha > 0.05){ dalechall += 3.6365; }
	
	//output
	printf("Flesch:     Flesch-Kincaid:    Dale-Chall:\n");
	printf("    %i                 %.1f            %.1f", findex, dubIndex, dalechall);
	
	return 0;
}

//counts the words, syllables, and sentences in a text file.
//returns the tokenized words in vector words.
struct doc tally(char filename[], vector<string>& words){
	long wordcount = 0;
	long syllcount = 0;
	long sentcount = 0;
	bool validword = false;
	bool validsent = false;
	bool lchvowel = false;
	string word;
	
	ifstream text;
	text.open(filename);
	if(!text.is_open()){
		cerr << "Failed to open." << endl;
		doc empty;
		return empty;
	}
	
	char w = 0;
	char lastw = 0;
	//words include trailing whitespace+newlines, and punctuation.
	while(text.get(w)){
		word += w;
		if(lastw == 'e' && (w == ' ' || w == '\n')){
			--syllcount;
		}
		if(w == ' ' || w == '\n'){//whitespace
			if(validword){
				++wordcount;
				//tokenize words: remove last char
				word.erase(word.size() - 1);
				//lowercasize and remove punctuation
				string newword;
				for(int i = 0; i < word.size(); i++){
					if(!ispunct(word[i]) || word[i] == '\''){
						newword += tolower(word[i]);
					}
				}
				//cout << newword << ';' << endl;
				words.push_back(newword);
			}
			word = "";
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
		//lastw = w;
	}
	
	text.close();
	if(validsent){
		++sentcount;
	}

	doc give;
	give.word = wordcount;
	give.syll = syllcount;
	give.sent = sentcount;

	return give;
}

//tokenizes the dale-chall word list
vector<string> getEasies(char filename[]){
	vector<string> give;
	ifstream easyWords(filename);
	string current;
	char rawstr[256];

	while(easyWords.good()){
		//getline(easyWords, current);
		easyWords.getline(rawstr, 256);
		current = "";
		//convert to lowercase and remove punctuation
		for(int i = 0; rawstr[i]; ++i){
			if(!ispunct(rawstr[i]) || rawstr[i] == '\''){
				current += tolower(rawstr[i]);
			}
		}
		give.push_back(current);
	}

	easyWords.close();
	//remove bad last entry
	give.erase(give.end() - 1);
	//sort!
	sort(give.begin(), give.end());
	return give;
}

//counts the number of difficult words in the text.
long judgeWords(vector<string>& dict, vector<string>& words){
	
	long diffs = 0;
	
	string word;
	const long wsize = words.size();
	const long dsize = dict.size();
	long lob;//inclusive lower bound
	long hib;//inclusive higher bound
	long mid;//comparison point
	
	for(long i = 0; i < words.size(); i++){
		word = words[i];
		//binary search for word in dict
		lob = 0;
		hib = dsize - 1;
		while(true){
			mid = (lob + hib)/2;
			//cerr << lob << '\t' << mid << '\t' << hib << '\t' << word << '\t' << dict[mid] << '\n';
			if(dict[mid] == word){//word found
				break;
			}else if(lob == hib){//word not in dict
				++diffs;
				break;
			}else if(word < dict[mid]){//lower half
				hib = mid;
			}else if(dict[mid] < word){//higher half
				lob = mid + 1;
			}else{//error
				cerr << "Binary search error\n";
				abort();
			}
		}
	}
	
	return diffs;
}








