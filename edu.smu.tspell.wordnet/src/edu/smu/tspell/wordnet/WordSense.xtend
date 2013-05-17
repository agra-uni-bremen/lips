/*
  Java API for WordNet Searching 1.0
  Copyright (c) 2007 by Brett Spell.

  This software is being provided to you, the LICENSEE, by under the following
  license.  By obtaining, using and/or copying this software, you agree that
  you have read, understood, and will comply with these terms and conditions:

  Permission to use, copy, modify and distribute this software and its
  documentation for any purpose and without fee or royalty is hereby granted,
  provided that you agree to comply with the following copyright notice and
  statements, including the disclaimer, and that the same appear on ALL copies
  of the software, database and documentation, including modifications that you
  make for internal use or for distribution.

  THIS SOFTWARE AND DATABASE IS PROVIDED "AS IS" WITHOUT REPRESENTATIONS OR
  WARRANTIES, EXPRESS OR IMPLIED.  BY WAY OF EXAMPLE, BUT NOT LIMITATION,  
  LICENSOR MAKES NO REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS
  FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS,
  TRADEMARKS OR OTHER RIGHTS.
 */
package edu.smu.tspell.wordnet;

/**
 * Uses a combination of a word form and synset to uniquely identify the
 * sense of a word. This is primarily used to represent lexical relationships
 * (that is, relationships that exist between specific word forms within
 * synsets).
 * 
 * @author Brett Spell
 */
class WordSense
{
	/**
	 * Word form associated with this sense.
	 */
	@Property val String wordForm

	/**
	 * Synset that contains the word form.
	 */
	@Property val Synset synset

	/**
	 * Constructor that accepts a synset and word form.
	 * 
	 * @param  wordForm Word form associated with this sense.
	 * @param  synset Synset associated with this sense.
	 */
	new(String wordForm, Synset synset)
	{
		this._wordForm = wordForm
		this._synset = synset
	}

	/**
	 * Returns a hash code for the object.
	 * 
	 * @return Returns the numeric code associated with this instance.
	 */
	override hashCode()
	{
		wordForm.hashCode
	}

	/**
	 * Indicates whether some object is "equal to" this one.
	 * 
	 * @param  o The reference object with which to compare.
	 * @return <code>true</code> if this object is "equal to" the reference
	 *         one; <code>false</code> otherwise.
	 */
	override equals(Object o)
	{
		switch (o) {
			WordSense: wordForm == o.wordForm && synset == o.synset
			default:   false
		}
	}

	/**
	 * Returns a string representation of this object.
	 * 
	 * @return String representation of this object.
	 */
	override toString()
	{
		''''«wordForm»' in «synset.toString»'''
	}

}