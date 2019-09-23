import java.io.*;
import java.util.Scanner;

public class Scores
{
public static void main(String args[]){
	String filename = args[0];//maybe improve this later
	
	Count doc = tally(filename);
	
	if(doc.words == 0){
		System.out.println("Failed to open file.");
		System.exit(0);
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
	System.out.println("Flesch Index: " + Long.toString(fleschIndex));
	
	//flesch-kincaid
	double fkIndex = alpha*11.8 + beta*0.39 - 15.59;
	System.out.println("Flesch-Kincaid Index: " + String.format("%.1f", fkIndex));
	
}

/* Takes a filename, then reads it by whitespace-delineated chunks.
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
	return doc;
}

/* Takes a raw token with no whitespace and processes it.
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
}
