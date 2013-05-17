/*
 * lips
 * Copyright (C) 2013 -- The lips developers
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package de.agra.nlp.util

import de.agra.nlp.semantical.NounClassification
import edu.smu.tspell.wordnet.Synset
import edu.smu.tspell.wordnet.SynsetType
import edu.smu.tspell.wordnet.impl.file.ReferenceSynset

class WordNetLexicographer {
	public static val ADJ_ALL            = 0
	public static val ADJ_PERT           = 1
	public static val ADV_ALL            = 2
	public static val NOUN_TOPS          = 3
	public static val NOUN_ACT           = 4
	public static val NOUN_ANIMAL        = 5
	public static val NOUN_ARTIFACT      = 6
	public static val NOUN_ATTRIBUTE     = 7
	public static val NOUN_BODY          = 8
	public static val NOUN_COGNITION     = 9
	public static val NOUN_COMMUNICATION = 10
	public static val NOUN_EVENT         = 11
	public static val NOUN_FEELING       = 12
	public static val NOUN_FOOD          = 13
	public static val NOUN_GROUP         = 14
	public static val NOUN_LOCATION      = 15
	public static val NOUN_MOTIVE        = 16
	public static val NOUN_OBJECT        = 17
	public static val NOUN_PERSON        = 18
	public static val NOUN_PHENOMENON    = 19
	public static val NOUN_PLANT         = 20
	public static val NOUN_POSESSION     = 21
	public static val NOUN_PROCESS       = 22
	public static val NOUN_QUANTITY      = 23
	public static val NOUN_RELATION      = 24
	public static val NOUN_SHAPE         = 25
	public static val NOUN_STATE         = 26
	public static val NOUN_SUBSTANCE     = 27
	public static val NOUN_TIME          = 28
	public static val VERB_BODY          = 29
	public static val VERB_CHANGE        = 30
	public static val VERB_COGNITION     = 31
	public static val VERB_COMMUNICATION = 32
	public static val VERB_COMPETITION   = 33
	public static val VERB_CONSUMPTION   = 34
	public static val VERB_CONTACT       = 35
	public static val VERB_CREATION      = 36
	public static val VERB_EMOTION       = 37
	public static val VERB_MOTION        = 38
	public static val VERB_PERCEPTION    = 39
	public static val VERB_POSESSION     = 40
	public static val VERB_SOCIAL        = 41
	public static val VERB_STATIVE       = 42
	public static val VERB_WEATHER       = 43
	public static val ADJ_PPL            = 44

	/**
	 * @brief Maps A lexicorgraphical type to a NounClassification
	 * @note This functions needs to be expanded to map more than two types
	 * of nouns to classes or actors
	 * 
	 * @param type The type that will be mapped
	 * @return The NounClassification for the given type
	 */
	// TODO expand this function
	static def mapToClassOrActor(int type) {
		val classes = #[NOUN_ARTIFACT, NOUN_COMMUNICATION, NOUN_OBJECT]
		val actors = #[NOUN_PERSON, NOUN_ANIMAL]

		if (classes.contains(type)) {
			NounClassification::Class
		} else if (actors.contains(type)) {
			NounClassification::Actor
		} else {
			NounClassification::Unknown
		}
	}

	/**
	 * @brief Concatenates an array of Synsets into a readable String
	 * 
	 * @param synsets The array of Synsets
	 * @return String containing the information of all synsets
	 */
	static def toString(Synset[] synsets) {
		val sb = new StringBuilder
		var i = 1
		var String type
		for (s : synsets) {
			val tagCount = s.getTagCount(s.wordForms.head)
			
			
			// I have no idea why there is a need to cast
			val rs = s as ReferenceSynset
			type = toReadableString(rs.lexicalFileNumber)
			sb.append(i+ ".\t("+tagCount+")\t<"+type+">\t")
			sb.append(s.wordForms.join(", "))
			sb.append(" -- " + s.definition + "\n")
			i =  i + 1
		}
		sb.toString
	}

	/**
	 * @brief Cretes a readable String from a WordNet SynsetType
	 * @param t SynsetType that is transformed into a readable string
	 * @return A readable string explaining the SynsetType
	 */
	static def toReadableString(SynsetType t) {
		
		switch t {
			case SynsetType::ADJECTIVE: "adjective"
			case SynsetType::ADJECTIVE_SATELLITE: "adjective"
			case SynsetType::NOUN: "noun"
			case SynsetType::VERB: "verb"
			case SynsetType::ADVERB: "adverb"
			default: "other"
		}
	}

	/**
	 * @brief Creates a readable/understandable String from a WordNet lexicographical  type
	 * @param type One of the types of the WordNet lexicographical distinction
	 * @return Textual explanation of the type
	 */
	def public static toReadableString(int type) {
		switch type {
		    case ADJ_ALL: 				"adjective.all"
		    case ADJ_PERT: 				"adjective.pert"
		    case ADV_ALL:				"adverb.all"
		    case NOUN_TOPS:				"noun.tops"
		    case NOUN_ACT:				"noun.act"
		    case NOUN_ANIMAL:			"noun.animal"
		    case NOUN_ARTIFACT:			"noun.artifact"
		    case NOUN_ATTRIBUTE:		"noun.attribute"
		    case NOUN_BODY:				"noun.body"
		    case NOUN_COGNITION:		"noun.cognition"
		    case NOUN_COMMUNICATION:	"noun.communication"
		    case NOUN_EVENT:			"noun.event"
		    case NOUN_FEELING:			"noun.feeling"
		    case NOUN_FOOD:				"noun.food"
		    case NOUN_GROUP:			"noun.group"
		    case NOUN_LOCATION:			"noun.location"
		    case NOUN_MOTIVE:			"noun.motive"
		    case NOUN_OBJECT:			"noun.object"
		    case NOUN_PERSON:			"noun.person"
		    case NOUN_PHENOMENON:		"noun.phenomenon"
		    case NOUN_PLANT:			"noun.plant"
		    case NOUN_POSESSION:		"noun.posession"
		    case NOUN_PROCESS:			"noun.process"
		    case NOUN_QUANTITY:			"noun.quantity"
		    case NOUN_RELATION:			"noun.relation"
		    case NOUN_SHAPE:			"noun.shape"
		    case NOUN_STATE:			"noun.state"
		    case NOUN_SUBSTANCE:		"noun.substance"
		    case NOUN_TIME:				"noun.time"
		    case VERB_BODY:				"verb.body"
		    case VERB_CHANGE:			"verb.change"
		    case VERB_COGNITION:		"verb.cognition"
		    case VERB_COMMUNICATION:	"verb.communication"
		    case VERB_COMPETITION:		"verb.competition"
		    case VERB_CONSUMPTION:		"verb.consumption"
		    case VERB_CONTACT:			"verb.contact"
		    case VERB_CREATION:			"verb.creation"
		    case VERB_EMOTION:			"verb.emotion"
		    case VERB_MOTION:			"verb.motion"
		    case VERB_PERCEPTION:		"verb.perception"
		    case VERB_POSESSION:		"verb.posession"
		    case VERB_SOCIAL:			"verb.social"
		    case VERB_STATIVE:			"verb.stative"
		    case VERB_WEATHER:			"verb.weather"
		    case ADJ_PPL:				"adj.ppl"
		}
	}
}
