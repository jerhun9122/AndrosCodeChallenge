# frozen_string_literal: true

require 'test/unit'
require_relative '../game'

# test card container class
class TestCard < Test::Unit::TestCase
  def test_card
    suit = 'foo'
    face = 'bar'
    value = 12
    card = Card.new(suit, face, value) 
    assert(card.suit == suit)
    assert(card.face == face)
    assert(card.value == value)
  end
end

# Test Deck
class TestDeck < Test::Unit::TestCase
  def test_shuffle
    deck.add(Card.new('a', 'A', 0))
    deck.add(Card.new('b', 'B', 1))
    deck.add(Card.new('c', 'C', 2))
    deck.add(Card.new('d', 'D', 3))
    deck.add(Card.new('e', 'E', 4))
    deck.add(Card.new('f', 'F', 5))
    shuffled = deck.shuffle
    different = false
    v = 0
    shuffled.each do |card|
      different = card.value != v
      if different
        break
      end        
      v += 1
    end
    assert(different)
  end

end

# test poker deck
class TestPokerDeck < Test::Unit::TestCase
  def test_init
    deck = PokerDeck.new
    shuffled = deck.shuffle
    assert(shuffled.length == 52)
  end
end

# test player
class TestPlayer < Test::Unit::TestCase
  def test_init
    player = Player.new("testPlayer")
    player.update_score(5)
    assert(player.score == 5)
  end

  def test_return_cards
    player = Player.new("testPlayer")
    player.return_cards
    assert(player.hand.length == 0)
  end
end

# test dealer
class TestDealer < Test::Unit::TestCase
  def test_deal
    dealer = Dealer.new(PokerDeck.new)
    players = [Player.new("testPlayer")];
    dealer.deal(players, 4) 
    assert(dealer.dealer?)
    assert(dealer.hand.length == 4)
    assert(players[0].hand.length == 4)
  end
end

