#include <iostream>
#include <stdio.h>
#include <fstream>
#include <algorithm>
#include <cmath>
#include <vector>
#include <string>
#include <cctype>

using namespace std;

const vector<char> vowels{'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U', 'y', 'Y'};
const vector<char> sentend{'.', ':', ';', '?', '!'};

struct doc {
	int word;
	int syll;
	int sent;
};

struct doc tally(char filename[], vector<string> words);
vector<string> getEasies(char filename[]);
//int judgeWords(vector<string> dictionary, char filename[]);

int main(int argc, char* argv[]){
	if(argc != 2){
		cerr << "Wrong number of arguments.\n";
		return 0;
	}
	
	vector<string> words;
	
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
	alpha = (double)count.syll / (double)count.word;
	beta = (double)count.word / (double)count.sent;
	dubIndex = alpha*11.8 + beta*0.39 - 15.59;
	
	//dale-chall
	//int diffWords;
	
	printf("Words=%i, Syll=%i, Sent=%i\n", count.word, count.syll, count.sent);
	printf("%i\t%.1f\n", findex, dubIndex);
	
	/*//test dale-chall
	vector<string> easyWords = getEasies("/pub/pounds/CSC330/dalechall/wordlist1995.txt");
	for(int i = 0; i < easyWords.size(); i++){
		cout << easyWords[i] << ", ";
	}
	cout << endl;*/

}

//counts the words, syllables, and sentences in a text file.
//returns the tokenized words.
struct doc tally(char filename[], vector<string> words){
	int wordcount = 0;
	int syllcount = 0;
	int sentcount = 0;
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
	string temp;
	char rawstr[256];
	while(easyWords.good()){
		//getline(easyWords, current);
		easyWords.getline(rawstr, 256);
		temp = "";
		//convert to lowercase and remove punctuation
		for(int i = 0; rawstr[i]; ++i){
			if(!ispunct(rawstr[i]) || rawstr[i] == '\''){
				rawstr[i] = tolower(rawstr[i]);
			}
		}
		current = rawstr;
		give.push_back(current);
	}
	easyWords.close();
	//remove bad last entry
	give.erase(give.end() - 1);
	return give;
}

/*
//counts the number of difficult words
int judgeWords(vector<string> dictionary, char filename[]){
	ifstream text(filename);
	if(!text.good()){
		return -1;
	}
	string current;
	bool isword = false;
	while(text >> current){//separates by space and checks for end of file
		isword = false;
		for(int i = 0; i < current.size(); ++i){//check if token is word
			if(isalpha(current[i])){
				isword = true;
			}
		}
		//TODO
	}
}*/
