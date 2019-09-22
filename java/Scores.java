import java.io.*;

public class Scores
{
public static void main(String args[]){
	String filename = args[0];//maybe improve this later
	
}

/* Takes a filename, then reads it by whitespace-delineated chunks.
 * Determines if each chunk is a word, counts its syllables, and counts sentences.
 * Puts valid words in order in a string array for later dale-chall analysis.
 * Returns Count doc, a container class for all of these.
 *   doc.words == 0 indicates an error
 */
public static Count tally(String filename){
	Count doc = new Count();
	try{
		FileInputStream text = new FileInputStream(filename);
	}catch(FileNotFoundException e){
		System.out.println("File not found.");//remove?
		return doc;
	}
	
}

/* Takes a raw token with no whitespace and processes it.
 * Anything without a letter in it is not a word and returns empty string.
 * All words are normalized to lowercase and have punctuation (other than "'") removed
 * The word is then returned.
 */
static String isWord(String rawtoken){
	rawtoken = rawtoken.trim().toLowerCase();
	if(rawtoken.matches("[a-z]+")){//regex: if(a-z) once or more
		//strip punctuation
		String give = new String();
		for(int i = 0; i < rawtoken.length(); i++){
			//TODO
		}
	}else{
		return "";
	}
}
}
