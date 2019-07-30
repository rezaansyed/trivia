require_relative '../spec_helper'
require_relative '../../lib/ugly_trivia/penalty_box'
require_relative '../../lib/ugly_trivia/turn'
require_relative '../../lib/ugly_trivia/player'

describe UglyTrivia::PenaltyBox do
  let(:player) { UglyTrivia::Player.new('a player', nil, nil) }

  context 'with no players in the box' do
    context 'with an even roll' do
      let(:roll) { 4 }
      let(:turn) { UglyTrivia::Turn.new(player, roll) }

      it 'has no penalty applied' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_applied?).to be false
      end

      it 'has no penalty suspended' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_suspended?).to be false
      end
    end

    context 'with an odd roll' do
      let(:roll) { 5 }
      let(:turn) { UglyTrivia::Turn.new(player, roll) }

      it 'has no penalty applied' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_applied?).to be false
      end

      it 'has no penalty suspended' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_suspended?).to be false
      end

      it 'runs the block for run_when_no_penalty' do
        block = ->(turn) { }
        expect(block).to receive(:call).with(turn)

        subject.run_when_no_penalty(turn, &block)
      end
    end
  end

  context 'with the player in the box' do
    before do
      subject.hold(player)
    end

    context 'with an even roll' do
      let(:roll) { 2 }
      let(:turn) { UglyTrivia::Turn.new(player, roll) }

      it 'has a penalty applied' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_applied?).to be true
      end

      it 'has no penalty suspended' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_suspended?).to be false
      end

      it 'runs the block for run_when_no_penalty' do
        block = ->(turn) { }
        expect(block).to receive(:call).never

        subject.run_when_no_penalty(turn, &block)
      end
    end

    context 'with an odd roll' do
      let(:roll) { 1 }
      let(:turn) { UglyTrivia::Turn.new(player, roll) }

      it 'has no penalty applied' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_applied?).to be false
      end

      it 'has a penalty suspended' do
        subject.adjust_penalty_for_roll(turn)

        expect(turn.roll_result.penalty_suspended?).to be true
      end

      it 'runs the block for run_when_no_penalty' do
        block = ->(turn) { }
        expect(block).to receive(:call).with(turn)

        subject.run_when_no_penalty(turn, &block)
      end
    end
  end
end
