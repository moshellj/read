import java.io.*;
import java.util.*;

public class Scores
{
public static void main(String args[]){
	String filename = args[0];//maybe improve this later
	
	Count doc = tally(filename);
	
	if(doc.words == 0){
		System.out.println("Failed to open file.");
		System.exit(1);
	}
	
	double alpha = Double.valueOf(doc.sylls) / Double.valueOf(doc.words);
	double beta  = Double.valueOf(doc.words) / Double.valueOf(doc.sents);
	
	/*debug
	System.out.println(doc.words);
	System.out.println(doc.sylls);
	System.out.println(doc.sents);
	//*/
	
	//flesch
	double dubFleschIndex = 206.835 - alpha*84.6 - beta*1.015;
	long fleschIndex = Math.round(dubFleschIndex);
	System.out.println("Flesch Index: ");
	System.out.println(Long.toString(fleschIndex));
	
	//flesch-kincaid
	double fkIndex = alpha*11.8 + beta*0.39 - 15.59;
	System.out.println("Flesch-Kincaid Index: ");
	System.out.println(String.format("%.1f", fkIndex));
	
	//dale-chall
	ArrayList<String> easy = getDict();
	int diffCount = judgeWords(easy, doc.wordList);
	double dcalpha = Double.valueOf(diffCount) / Double.valueOf(doc.words);
	double dcIndex = dcalpha*100.0*0.1579 + beta*0.0496;
	if(dcalpha > 0.05){
		dcIndex += 3.6365;
	}
	System.out.println("Dale-Chall Readability Score:");
	System.out.println(String.format("%.1f", dcIndex));
	
}

/* 
 * Takes a filename, then reads it by whitespace-delineated chunks.
 * Determines if each chunk is a word, counts its syllables, and counts sentences.
 * Puts valid words in order in a string array for later dale-chall analysis.
 * Returns Count doc, a container class for all of these.
 *   doc.words == 0 indicates an error
 */
public static Count tally(String filename){
	Count doc = new Count();
	Scanner text;
	try{
		text = new Scanner(new File(filename));
	}catch(FileNotFoundException e){
		return doc;
	}
	
	String word;
	boolean validSent = false;

	while(text.hasNext()){
		word = text.next();
		//check for punctuation for sentences
		if(validSent && word.matches(".*[.:;?!].*")){//regex: if one or more of .;:?!
			validSent = false;
			++doc.sents;
		}
		
		word = fixWord(word);//strip punctuation, lowercasize
		
		if(word != ""){
				//System.out.println(word); int dsylcount = doc.sylls;//debug
			++doc.words;
			int syllCount = 0;
			doc.wordList.add(word);
			validSent = true;
			//count syllables
			boolean lcharvowel = false;
			for(int i = 0; i < word.length(); ++i){
				//going char by char; tricky bit of code
				if("aeiouy".indexOf(word.charAt(i)) != -1){
					if(!lcharvowel){
						++syllCount;
					}
					lcharvowel = true;
				}else{
					lcharvowel = false;
				}
			}
			if(word.charAt(word.length()-1) == 'e'){
				--syllCount;
			}
			
			if(syllCount < 1){//process syllables separately per word
				syllCount = 1;
			}
			doc.sylls += syllCount;
				//System.out.println(doc.sylls - dsylcount);//debug
		}
	}
	text.close();
	return doc;
}

/* 
 * Takes a raw token with no whitespace and processes it.
 * Anything without a letter in it is not a word and returns empty string.
 * All words are normalized to lowercase and have punctuation (other than "'") removed
 * The word is then returned.
 */
static String fixWord(String rawtoken){
	if(rawtoken.matches(".*[a-zA-Z].*")){//regex: if(a-z) once or more
		String give = rawtoken.toLowerCase();
		//System.out.println(give);
		//strip punctuation
		give = give.replaceAll("[^a-z']", "");//regex: delete if not a-z or '
		return give;
	}else{
		return "";
	}
}

/*
 * Creates the Dale-chall dictionary.
 * Reads from the hardcoded dictionary directory. Normalizes each word to
 * remove capitalization and punctuation.
 * Returns the list in a SORTED arraylist<string>.
 */
static ArrayList<String> getDict(){
	ArrayList<String> dict = new ArrayList<String>();
	Scanner raw = null;
	try{
		raw = new Scanner(new File("/pub/pounds/CSC330/dalechall/wordlist1995.txt"));
	}catch(FileNotFoundException e){
		System.out.println("Dale-Chall Dictionary not found.");
		System.exit(2);
	}
	
	String word;
	while(raw.hasNext()){
		word = raw.next().toLowerCase();
		word = word.replaceAll("[^a-z']", "");//strips all but letters and '
		dict.add(word);
	}
	raw.close();
	Collections.sort(dict);
	return dict;
}

/*
 * Determines the number of difficult words, based on a list of easy words.
 * For each word in the text, binary searches through the list of easy words.
 */
static int judgeWords(ArrayList<String> easy, ArrayList<String> text){
	int diffCount = 0;
	String word;
	int lob;
	int hib;
	int mid;
	boolean found;
	for(int i = 0; i < text.size(); i++){
		//binary search
		found = false;
		word = text.get(i);
		lob = 0;
		hib = easy.size() - 1;
		while(lob != hib){
			mid = (lob + hib) / 2;
			if(easy.get(mid).compareTo(word) == 0){//found
				found = true;
				break;
			}else if(easy.get(mid).compareTo(word) < 0){//word in higher half
				lob = mid + 1;
			}else if(word.compareTo(easy.get(mid)) < 0){//lower half
				hib = mid;
			}else{//???
				System.out.println("Binary search error.");
				System.exit(3);
			}
		}
		if(!found){
			++diffCount;
		}
	}
	
	return diffCount;
}
}








