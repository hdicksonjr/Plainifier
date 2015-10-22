class Word < Sequel::Model
	many_to_many :tags, :left_key => :word_id, :right_key => :tag_id, :join_table => :usages
end
