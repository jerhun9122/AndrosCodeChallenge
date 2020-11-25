# frozen_string_literal: true

# Basic cpayer piece of the game
class Card
  def initialize(suit, face, value)
    @suit = suit
    @face = face
    @value = value
  end

  def suit
    @suit
  end

  def face
    @face
  end

  def value
    @value
  end

end

# Deck of cards
class Deck
  def initialize(cards)
    @cards = cards
  end

  def shuffle
    @cards.shuffle
  end
end

# Deck more specific to the game beign played
class PokerDeck < Deck
  SUITS = %w[D H S C].freeze
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

  def initialize
    super build_deck
  end

  def build_deck
    cards = []
    SUITS.each do |suit|
      val = 1
      FACES.each do |face|
        val += 1
        card = Card.new(suit, face, val)
        cards.push(card)
      end
    end
    cards
  end
end

# Player represents participants in the game
class Player 
  def initialize(name)
    @name = name
    @hand = []
    @score = 0
  end

  def name
    @name
  end

  # score will need to be set by game class, as game determines rules for scoring
  def score
    @score
  end

  def update_score(score)
    @score = score
  end

  def hand
    @hand
  end

  def show_hand
    print "#{@name} "
    @hand.each do |card|
      print "#{card.face}#{card.suit} "
    end
    puts "Score: #{@score}"
  end

  # clear the players hand
  def return_cards
    @hand = []
  end
end

# Dealer manages ditributing cards to players
class Dealer < Player
  def initialize(deck)
    super('Dealer')
    @deck = deck
  end

  def dealer?
    true
  end

  def deal(players, card_count)
    shuffled = @deck.shuffle
    dealt = 0
    round = 0
    while round < card_count
      players.each do |player|
        player.instance_variable_get('@hand').push(shuffled[dealt])
        dealt += 1
      end
      @hand.push(shuffled[dealt])
      dealt += 1
      round += 1
    end
  end
end

# Game is a wrapper for all events and components of a game
class Game
  MIN_PLAYERS = 2
  MAX_PLAYERS = 10
  HAND_SIZE = 1

  def initialize()
    @dealer = Dealer.new(Deck.new([]))
  end

  def min_players
    self.class::MIN_PLAYERS
  end

  def max_players
    self.class::MAX_PLAYERS
  end

  def init_players(your_name, player_num)
    @players = [player_num]
    @players[0] = Player.new(your_name)
    i = 1
    until i == player_num
      p = Player.new("player#{i}")
      @players[i] = p
      i += 1
    end
  end

  def num_players
    player_num = 0 
    while player_num < self.class::MIN_PLAYERS || player_num > self.class::MAX_PLAYERS
      puts "How many players (Between #{self.class::MIN_PLAYERS} and #{self.class::MAX_PLAYERS})? "
      player_num = gets.chomp.to_i
      if player_num < self.class::MIN_PLAYERS || player_num > self.class::MAX_PLAYERS
        $stderr.puts 'Invalid Player Selection.'
        player_num = 0
      end
    end
    player_num
  end

  def start(player_name)
    init_players(player_name, num_players)
    play
  end

  # play must be overridden to a
  def play
    #tho I am sure there is a better way to define a virtual method... just gonna throw something
    raise 'Method play cannot be called directly. It must be overridden in a child class first.'
  end

  # override to set rules for scoring players hands
  def score_player
    raise 'Method score_player cannot be called directly. It must be overridden in a child class first.'
  end

  def return_all_cards
    @dealer.return_cards
    @players.each do |player|
      player.return_cards
    end
  end
end

# Rules specific to Poker
class Poker < Game
  MIN_PLAYERS = 2
  MAX_PLAYERS = 10
  HAND_SIZE = 5
  def initialize()
    super
    @deck = PokerDeck.new
    @dealer = Dealer.new(@deck)
  end

  def play
    @dealer.deal(@players, self.class::HAND_SIZE)
    @dealer.show_hand
    winner = @dealer
    @players.each do |player|
      score_player(player)
      player.show_hand
      if player.score > winner.score
        winner = player
      end
    end
    puts "The winner is #{winner.name}, congratulations!"
    return_all_cards
  end

  def score_player
  end

end

# Rules specific to Andros 3 cards high game
class AndrosCardChallenge < Game
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5
  HAND_SIZE = 2
  def initialize()
    super
    @deck = PokerDeck.new
    @dealer = Dealer.new(@deck)
  end

  def play
    @dealer.deal(@players, self.class::HAND_SIZE)
    score_player(@dealer)
    @dealer.show_hand
    winner = @dealer
    @players.each do |player|
      score_player(player)
      player.show_hand
      if player.score > winner.score
        winner = player
      end
    end
    puts "The winner is #{winner.name}, congratulations!"
    return_all_cards
  end

  def start(player_name)
    init_players(player_name, 5)
    play
  end

  # rules for scoring the game 
  def score_player(player)
    score = 0
    player.hand.each do |card|
      score += card.value
    end
    player.update_score(score)
  end

end

puts "\e[H\e[2J"
your_name = ''
while your_name.length == 0
  print 'Enter your name: '
  your_name = gets.chomp
end
puts "Hello #{your_name}, Would you like to play a game?"

begin
  acc = AndrosCardChallenge.new
  acc.start(your_name)

  while true
    print 'Play Again (y/n)? '
    option = gets.chomp
    if option.casecmp('N').zero?
      break
    elsif option.casecmp('Y').zero?
      puts "\e[H\e[2J"
      acc.play 
    end
  end
rescue Exception => e
  $stderr.puts e.message
end
