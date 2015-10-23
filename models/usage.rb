class Usage < Sequel::Model
  many_to_one :word
  many_to_one :tag
end

