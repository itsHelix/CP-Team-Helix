# Luthor.rb
# Tests for Kryptonite.rb
# Team Helix 2019

test_phrase = "@Lorem Ipsum in dolor sit!"

# ROT
puts rot_encode(test_phrase, 12)
puts rot_decode(rot_encode(test_phrase, 12), 12)
puts rot_decode(rot_encode(test_phrase, 12), 12) == test_phrase

rot_encode_all(test_phrase)
rot_decode_all(rot_encode(test_phrase, 13))

puts rot_47('a:bw2 b;k8-')
