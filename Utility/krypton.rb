# Krypton.rb
# An interface for Kryptonite.rb
# Team Helix 2019
%w(tty-prompt ./kryptonite.rb).each(&method(:require))

prompt = TTY::Prompt.new

choices = %w(rot hex)
choicez = prompt.multi_select("Select encryption method", choices)
a = prompt.ask("What string do you want to decrypt?")


for choice in choicez do
  decode_all(choice, a)
end

prompt.slider('How excited are you?', max: 10, step: 1)
