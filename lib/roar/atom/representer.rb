require 'atom'
require 'roar/representer'
require 'representable/hash'
require 'active_support/concern'
require 'active_support/core_ext/hash/indifferent_access'

module Roar
  module Atom
    module Representer
      extend ActiveSupport::Concern

      included do
        include Roar::Representer
        include Representable::Hash

        ATOM_NAMESPACES ||= { feed:
                                ['id',
                                 'title',
                                 'updated',
                                 'author',
                                 'link',
                                 'category',
                                 'contributor',
                                 'generator',
                                 'icon',
                                 'logo',
                                 'rights',
                                 'subtitle'],
                              entry:
                                ['id',
                                 'title',
                                 'updated',
                                 'author',
                                 'content',
                                 'link',
                                 'summary',
                                 'category',
                                 'contributor',
                                 'published',
                                 'source',
                                 'rights'],
                              person:
                                ['name', 'uri', 'email']
                            }

        def serialize(*args)
          to_atom
        end

        def to_atom
          data = self.to_hash.with_indifferent_access

          ::Atom::Feed.new do |f|
            data.each do |element, value|
              if ATOM_NAMESPACES[:feed].include?(element.to_s)
                f.send("#{element}=", value)
              end
            end

            add_atom_authors(f, data[:authors]) if data[:authors]
            add_atom_links(f, data[:links])     if data[:links]

            if data[:entries]
              data[:entries].each do |entry|
                f.entries << ::Atom::Entry.new do |e|
                  entry.each do |element, value|
                    if ATOM_NAMESPACES[:entry].include?(element.to_s)
                      e.send("#{element}=", value)
                    end
                  end

                  add_atom_links e, entry[:links] if entry[:links]
                end
              end
            end
          end
        end

        private

        def add_atom_authors(output, authors)
          authors.each do |author|
            output.authors << ::Atom::Person.new(name: author)
          end
        end

        def add_atom_links(output, hrefs)
          hrefs.each do |href|
            output.links << ::Atom::Link.new(href: href)
          end
        end
      end
    end
  end
end
