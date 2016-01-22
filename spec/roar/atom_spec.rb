require 'rails_helper'

describe Roar::Atom do
  it 'has a version number' do
    expect(Roar::Atom::VERSION).not_to be nil
  end
end
