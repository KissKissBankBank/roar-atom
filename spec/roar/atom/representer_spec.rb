require 'spec_helper'

describe Roar::Atom::Representer do
  let(:atom_feed_representer) do
    Class.new do
      include Roar::Atom::Representer

      property :id
      property :title
      property :updated
      property :authors
      property :links

      collection :entries

      attr_accessor :authors
      attr_accessor :links
      attr_accessor :entries

      def id
        'marvel:avengers'
      end

      def title
        'The Avengers'
      end

      def updated
        '2016-12-21T00:00:02Z'
      end
    end
  end

  let(:feed) { atom_feed_representer.new }

  it 'includes Roar::Representer' do
    expect(feed).to be_kind_of(Roar::Representer)
  end

  it 'includes Representable::Hash' do
    expect(feed).to be_kind_of(Representable::Hash)
  end

  describe '#to_atom' do
    subject { feed.to_atom }

    it 'returns a Atom::Feed' do
      expect(subject).to be_a(::Atom::Feed)
    end

    it 'fills required elements for an atom feed' do
      expect(subject.id).to eq      'marvel:avengers'
      expect(subject.title).to eq   'The Avengers'
      expect(subject.updated).to eq '2016-12-21T00:00:02Z'
    end

    context 'with author element' do
      let(:author_name) { 'Marvel' }
      let(:atom_person) { ::Atom::Person.new(name: author_name) }

      before do
        feed.authors = [author_name]
        subject
      end

      it 'fills the ouput authors attribute with Atom::Person' do
        expect(subject.authors).to include(::Atom::Person)
      end

      it 'fills elements for an atom person' do
        expect(subject.authors).to include(atom_person)
      end
    end

    context 'with link element' do
      let(:link)      { 'http://marvel.wikia.com/wiki/Black_Widow' }
      let(:atom_link) { ::Atom::Link.new(href: link) }

      before do
        feed.links = [link]
        subject
      end

      it 'fills the output links attribute with Atom::Link' do
        expect(subject.links).to include(::Atom::Link)
      end

      it 'fills elements for an atom link' do
        expect(subject.links).to include(atom_link)
      end
    end

    context 'with entries' do
      let(:black_widow_id)      { 'marvel:avengers:black-widow' }
      let(:black_widow_title)   { 'Black Widow' }
      let(:black_widow_updated) { '2016-13-21T00:00:02Z' }
      let(:black_widow) do
        { id:      black_widow_id,
          title:   black_widow_title,
          updated: black_widow_updated }
      end

      let(:feed_entries) do
        [black_widow]
      end

      let(:atom_entry) do
        ::Atom::Entry.new do |e|
          e.id      = black_widow_id
          e.title   = black_widow_title
          e.updated = black_widow_updated
        end
      end

      before { feed.entries = feed_entries }

      it 'fills the Atom::Feed with Atom::Entry' do
        expect(subject.entries).to include(::Atom::Entry)
      end

      it 'fills required elements for an atom entry' do
        expect(subject.entries).to include(atom_entry)
      end

      context 'with entry link element' do
        let(:entry_link) { 'http://marvel.wikia.com/wiki/Black_Widow' }

        before do
          allow(feed).to receive(:add_atom_links)
          black_widow[:links] = [entry_link]
          subject
        end

        it 'fills the atom entry with a link element' do
          expect(feed).to have_received(:add_atom_links)
        end
      end
    end
  end
end
