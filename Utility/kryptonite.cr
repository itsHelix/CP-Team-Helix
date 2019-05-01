# Kryptonite.rb
# The Swiss Army Knife of cryptography
# Team Helix 2019

# ROT
def rot_encode(a, n)
  alphabet = ("a".."z").flat_map { |l| [ l, l.upcase ] }.join
  alpharot = alphabet.dup
  alpharot << alpharot.slice(0, n*2)
  a.tr(alphabet, alpharot)
end
def rot_decode(a, n)
  alphabet = ("a".."z").flat_map { |l| [ l, l.upcase ] }.join
  alpharot = alphabet.dup
  alpharot << alpharot.slice(0, (26-n)*2)
  a.tr(alphabet, alpharot)
end
def rot_47(a) a.tr("!-~","P-~!-O") end

# Universal commands
def encode_all(method, a)
  case method
  when "rot"
    0.upto(25) { |i| puts "ROT#{i}\t\t#{rot_encode(a, i)}" }
    puts "ROT47\t\t#{rot_47(a)}"
  else
    puts "Usage: encode_all(method, a)"
  end
end
def decode_all(method, a)
  case method
  when "rot"
    0.upto(25) { |i| puts "ROT#{i}\t\t#{rot_decode(a, i)}" }
    puts "ROT47\t\t#{rot_47(a)}"
  else
    puts "Usage: decode_all(method, a)"
  end
end


nice = gets
decode_all("rot", nice)
