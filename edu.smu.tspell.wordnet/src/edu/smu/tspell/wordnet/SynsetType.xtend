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
 * Identifies the part of speech (noun, verb, etc.) associated with a
 * particular synset.
 *
 * @author Brett Spell
 */
class SynsetType implements Comparable<SynsetType>
{

	/**
	 * Noun synset code.
	 */
	static val CODE_NOUN                = 1

	/**
	 * Verb synset code.
	 */
	static val CODE_VERB                = 2

	/**
	 * Adjective synset code.
	 */
	static val CODE_ADJECTIVE           = 3

	/**
	 * Adverb synset code.
	 */
	static val CODE_ADVERB              = 4

	/**
	 * Adjective satellite synset code.
	 */
	static val CODE_ADJECTIVE_SATELLITE = 5

	/**
	 * Noun category.
	 */
	public static val NOUN = new SynsetType(CODE_NOUN)

	/**
	 * Verb category.
	 */
	public static val VERB = new SynsetType(CODE_VERB)

	/**
	 * Adjective category.
	 */
	public static val ADJECTIVE = new SynsetType(CODE_ADJECTIVE)

	/**
	 * Adverb category.
	 */
	public static val ADVERB = new SynsetType(CODE_ADVERB)

	/**
	 * Adjective satellite category.
	 */
	public static val ADJECTIVE_SATELLITE =
			new SynsetType(CODE_ADJECTIVE_SATELLITE)

	/**
	 * Array containing all category types.
	 */
	public static val ALL_TYPES =
			#[NOUN, VERB, ADJECTIVE, ADVERB, ADJECTIVE_SATELLITE]

	/**
	 * The numeric code used to represent a category.
	 */
	@Property val int code

	/**
	 * Accepts a category code.
	 * 
	 * @param  code Value used to represent this category.
	 */
	new(int code)
	{
		this._code = code;
	}

	/**
	 * Compares this object to another one to determine their relative order.
	 * 
	 * @param  o The reference object with which to compare.
	 * @return A negative, zero, or positive value if this object is less
	 *         than, equal to, or greater than the reference object,
	 *         respectively.
	 */
	override compareTo(SynsetType target)
	{
		if (target != null) code - target.code else 1
	}

	/**
	 * Returns a hash code for the object.
	 * 
	 * @return Returns the numeric code associated with this instance.
	 */
	override hashCode()
	{
		code
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
			SynsetType: code == o.code
			default:    false
		}
	}

	/**
	 * Returns a string representation of this object.
	 * 
	 * @return String representation of this object.
	 */
	override toString()
	{
		code.toString
	}

}