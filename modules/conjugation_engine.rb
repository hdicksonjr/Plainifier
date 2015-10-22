module ConjugationEngine

  def self.conjugate(stem, tag)
		conjugation_info = Tag.map_POS_to_conjugation(tag)

	  Verbs::Conjugator.conjugate(stem, :tense => conjugation_info[0], :aspect =>
		conjugation_info[1], :person => conjugation_info[2] || :first)
	end
  
end
