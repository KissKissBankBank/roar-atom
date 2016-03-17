require 'spec_helper'

describe Roar::Atom::Representer do
  let(:avengers_feed_representer) do
    Module.new do
      include Roar::Atom::Representer

      # Atom required elements
      property :id
      property :title
      property :updated

      # Atom optional elements
      property :atom_subtitle
      property :authors
      property :links

      # Custom elements
      property :atom_custom_introduction
      property :custom_friend
      property :xml_namespace

      collection :entries
    end
  end

  let(:avengers_class) do
    Class.new do
      attr_accessor :updated_at
      attr_accessor :atom_custom_introduction
      attr_accessor :atom_subtitle
      attr_accessor :authors
      attr_accessor :links
      attr_accessor :entries
      attr_accessor :custom_friend

      def id
        'marvel:avengers'
      end

      def title
        'The Avengers'
      end

      def updated
        updated_at || '2016-12-21T00:00:00Z'
      end
    end
  end

  let(:feed) do
    avengers_class.new.extend(avengers_feed_representer)
  end

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
      expect(subject.updated).to eq '2016-12-21T00:00:00Z'
    end


    context 'with date element' do
      let(:rfc3339_regexp) do
        /((\d{2,4})-?){3}T((\d{2}):?){3}(\+((\d{2}):?){2}|Z)+/
      end

      context 'when date is a Date' do
        before do
          feed.updated_at = Date.new(2016, 12, 21)
        end

        it 'formats the date following the RFC 3339' do
          expect(subject.updated).to match(rfc3339_regexp)
        end
      end

      context 'when date is a DateTime' do
        before do
          feed.updated_at = DateTime.new(2016, 12, 21)
        end

        it 'formats the date following the RFC 3339' do
          expect(subject.updated).to match(rfc3339_regexp)
        end
      end

      context 'when date is a Time' do
        before do
          feed.updated_at = Time.new(2016, 12, 21)
        end

        it 'formats the date following the RFC 3339' do
          expect(subject.updated).to match(rfc3339_regexp)
        end
      end

      context 'when date is a RFC3339 date-time String' do
        before do
          feed.updated_at = '2016-12-21T00:00:00Z'
        end

        it 'formats the date following the RFC 3339' do
          expect(subject.updated).to match(rfc3339_regexp)
        end
      end

      context 'when date is a regular String' do
        before do
          feed.updated_at = 'I am a date-time!'
        end

        it 'raises an error' do
          expect{ subject }.to raise_error(NoMethodError)
        end
      end
    end

    context 'with an attribute prefixed by `atom_`' do
      context 'when the prefixed element is an Atom element' do
        let(:subtitle) { 'There are the Avengers stories.' }
        before do
          feed.atom_subtitle = subtitle
          subject
        end

        it 'fills an regular atom element' do
          expect(subject.subtitle).to eq subtitle
        end
      end

      context 'when the prefixed element is an custom element' do
        let(:introduction) { 'An fantastic introduction' }
        let(:extension_element_key) do
          '{http://marvel.wikia.com,custom_introduction}'
        end

        before do
          feed.xml_namespace = 'http://marvel.wikia.com'
          feed.atom_custom_introduction = introduction
          subject
        end

        it 'creates an element with a custom namespace' do
          expect(subject
                   .simple_extensions
                   .has_key?(extension_element_key))
            .to be_truthy
        end

        it 'fills the value for the custom element' do
          expect(subject.simple_extensions[extension_element_key])
            .to eq [introduction]
        end

      end
    end

    context 'with author element' do
      let(:author_name)  { 'Marvel' }
      let(:author_uri)   { 'http://marvel.wikia.com' }
      let(:author_email) { 'root@marvel.wikia.com' }
      let(:author_age)   { 42 }
      let(:author) do
        { name:  author_name,
          uri:   author_uri,
          email: author_email,
          age:   author_age }
      end
      let(:atom_person) do
        ::Atom::Person.new(name:  author_name,
                           uri:   author_uri,
                           email: author_email)
      end

      before do
        feed.authors = [author]
        subject
      end

      it 'fills the ouput authors attribute with Atom::Person' do
        expect(subject.authors).to include(::Atom::Person)
      end

      it 'only fills elements for an atom person' do
        expect(subject.authors).to include(atom_person)
      end
    end

    context 'with link element' do
      let(:link_href)     { 'http://marvel.wikia.com/wiki/Black_Widow' }
      let(:link_title)    { 'Black Widow profile'}
      let(:link_hreflang) { 'en' }
      let(:link_rel)      { 'self' }
      let(:link_not_related_attribute) { 'Natasha Romanova' }
      let(:link) do
        { href: link_href,
          title: link_title,
          hreflang: link_hreflang,
          rel: link_rel,
          not_related: link_not_related_attribute }
      end

      let(:atom_link) do
        ::Atom::Link.new(href:     link_href,
                         title:    link_title,
                         hreflang: link_hreflang,
                         rel:      link_rel)
      end

      before do
        feed.links = [link]
        subject
      end

      it 'fills the output links attribute with Atom::Link' do
        expect(subject.links).to include(::Atom::Link)
      end

      it 'only fills attributes for an atom link' do
        expect(subject.links).to include(atom_link)
      end

    end

    context 'with extension element' do
      let(:custom_friend) { 'Hawkeye' }
      let(:extension_element_key) { '{http://marvel.wikia.com,custom_friend}' }

      context 'with valid parameters' do
        before do
          feed.custom_friend = custom_friend
          feed.xml_namespace = 'http://marvel.wikia.com'
          subject
        end

        it 'creates an element with a custom namespace' do
          expect(subject
                   .simple_extensions
                   .has_key?(extension_element_key))
            .to be_truthy
        end

        it 'fills the value for the custom element' do
          expect(subject.simple_extensions[extension_element_key])
            .to eq [custom_friend]
        end
      end

      context 'without an xml_namespace' do
        before do
          feed.custom_friend = custom_friend
        end

        it 'returns an exception' do
          expect{ subject }.to raise_error(ArgumentError)
        end
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

      context 'with entry author element' do
        let(:author_name)  { 'Stan Lee' }
        let(:author_uri)   { 'https://twitter.com/therealstanlee' }
        let(:author_email) { 'stan-lee@marvel.wikia.com' }
        let(:author) do
          { name:  author_name,
            uri:   author_uri,
            email: author_email }
        end

        before do
          allow(feed).to receive(:add_atom_authors)
          black_widow[:authors] = [author]
          subject
        end

        it 'fills the atom entry with a author element' do
          expect(feed).to have_received(:add_atom_authors)
        end
      end
    end
  end
end
