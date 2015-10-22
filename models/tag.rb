class Tag < Sequel::Model

	many_to_many :words, :left_key => :tag_id, :right_key => :word_id, :join_table => :usages

	def self.map_POS(pos)
	  tags = {"verb" => "vb", "noun" => "nn", "adverb" => "rb", "adjective" =>
		"jj", "qualifier" => "ql" }

		if tags[pos]
			tags[pos]
		end
	end

	def self.map_tag_to_tag_family(tag)
	  if tag.name.include?("vb")
			"vb"
		elsif tag.name.include?("nn")
		  "nn"
		elsif tag.name.include?("jj")
		  "jj"
		elsif tag.name.include?("np")
		  "proper_noun"
		elsif tag.name.include?("rb")
		  "adverb"
		elsif tag.name.include?("ap")
		  "determiner"
		elsif tag.name.include?("pp")
		  "determiner"
		else
			raise "unable to match tag: #{tag.name}"
		end
	end

	def self.map_POS_to_conjugation(tag)
	  conjugations = {"vb" => [:present, :habitual, :first], "vbn" => [:past,
		:perfective], "vbg" => [:present, :progressive], "vbz" => [:present,
		:habitual]}
	end
end

