require 'rspec'
require_relative 'lambda_interpreter'

describe 'Lambda interpreter' do
  let(:id) { Abs('x', Var('x')) }
  let(:currying) { Abs('y', Abs('z', App(Var('y'), Var('z')))) }
  let(:another_func) { Abs('y', Abs('z', Var('y'))) }

  context 'Rule 1: When first term is an application' do
    it 'evals application applied to application' do
      "(λx.λy.x u) (λz.z λx.x)"
      "(λy.u) (λx.x)"
      "(λy.u)"
      app = App(App(Abs('x', Abs('y', Var('x'))), Var('u')), App(id, Abs('z', Var('z'))))

      expect(evaluate(app)).to eq(Var('u'))
    end

    it 'evals application applied to abstraction' do
      "(λx.λy.x y) λx.x"
      "(λy.y) λx.x"
      "λx.x"
      app = App(App(Abs('x', Abs('y', Var('x'))), Var('y')), id)

      expect(evaluate(app)).to eq(id)
    end
  end

  context 'Rule 2: When first term is an abstraction' do
    it 'evals abstraction applied to var' do
      "λx.λy.x z"
      "λy.z"
      app = App(Abs('x', Abs('y', Var('x'))), Var('z'))
      expected = Abs('y', Var('z'))

      expect(evaluate(app)).to eq(expected)
    end

    it 'evals abstraction applied to application' do
      "(λx.λy.x u) (λz.z λx.x)"
      "λy.(λz.z λx.x)"
      "λy.λx.x"
      app = App(Abs('x', Abs('y', Var('x'))), App(id, Abs('z', Var('z'))))
      expected = Abs('y', Abs('z', Var('z')))

      expect(evaluate(app)).to eq(expected)
    end
  end

  context 'Rule 3: when both terms are abstractions' do
    it 'evals id applied to id' do
      app = App(id, id)

      expect(evaluate(app)).to eq(id)
    end

    it 'evals abstraction with free var applied to id' do
      not_id = Abs('x', Var('z'))
      app = App(not_id, id)

      expect(evaluate(app)).to eq(Var('z'))
    end

    it 'evals curried abstraction applied to id' do
      app = App(another_func, id)
      expected = Abs('z', id)

      expect(evaluate(app)).to eq(expected)
    end

    it 'evals abstraction with unbound var to id' do
      "λx.λx.x λz.z"
      "λx.x"
      app = App(Abs("x", id), Abs('z', Var('z')))

      expect(evaluate(app)).to eq(id)
    end

    it 'evals abstraction applied to abstraction' do
      app = App(currying, id)
      expected = Abs('z', App(id, Var('z')))

      expect(evaluate(app)).to eq(expected)
    end
  end
end
