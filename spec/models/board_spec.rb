require 'rails_helper'

RSpec.describe Board, type: :model do
  let(:initial_state) { "000\n010\n000" } # A simple 3x3 board with one live cell in the middle
  let(:complex_initial_state) { "010\n111\n010" } # More complex board
  let(:board) { Board.create!(initial_state: initial_state, rows: 3, cols: 3) }
  let(:complex_board) { Board.create!(initial_state: complex_initial_state, rows: 3, cols: 3) }

  describe 'board creation' do
    it 'creates the initial generation' do
      expect(board.generations.count).to eq(1)
      expect(board.generations.first.state).to eq(initial_state)
    end
  end

  describe 'next generation' do
    it 'calculates the next generation correctly' do
      board.next_generation
      next_state = board.generations.last.state
      expected_next_state = "000\n000\n000" # Expected all dead after first gen
      expect(next_state).to eq(expected_next_state)
    end

    it 'calculates the next generation correctly for a complex board' do
      complex_board.next_generation
      next_state = complex_board.generations.last.state
      expected_next_state = "111\n101\n111" # Expected next state based on rules
      expect(next_state).to eq(expected_next_state)
    end
  end

  describe 'state at step' do
    it 'returns the state at a specific step' do
      board.next_generation
      step_1_state = board.state_at_step(1).state

      expect(step_1_state).to eq("000\n000\n000")
    end
  end

  describe 'final state' do
    it 'returns the final stable state for a simple board' do
      final_state = board.final_state(10)
      expect(final_state).to eq("000\n000\n000") # Stable state, all dead
    end

    it 'returns the final stable state for a complex board' do
      final_state = complex_board.final_state(10)
      # After a few generations, this should stabilize
      expected_final_state = "111\n101\n111"
      expect(final_state).to eq(expected_final_state)
    end

    it 'returns an error if the board does not stabilize within max steps' do
      large_initial_state = "010\n111\n010"
      board.update(initial_state: large_initial_state)

      result = board.final_state(1) # With only 1 step, should not stabilize
      expect(result).to eq({ error: 'Board did not reach a stable state' })
    end
  end

  describe 'edge cases' do
    it 'handles empty boards correctly' do
      empty_board = Board.create!(initial_state: "000\n000\n000", rows: 3, cols: 3)
      empty_board.next_generation
      expect(empty_board.generations.last.state).to eq("000\n000\n000") # Remains the same
    end

    it 'handles all live cells correctly' do
      all_live_board = Board.create!(initial_state: "111\n111\n111", rows: 3, cols: 3)
      all_live_board.next_generation
      expect(all_live_board.generations.last.state).to eq("101\n000\n101") # Expected next state
    end
  end
end
