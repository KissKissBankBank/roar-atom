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

        LIST_PROPERTIES ||= ['authors', 'links', 'entries']

        attr_accessor :xml_namespace

        def serialize(*args)
          to_atom
        end

        def to_atom
          data           = to_hash.with_indifferent_access
          @xml_namespace = data.delete(:xml_namespace)

          ::Atom::Feed.new do |f|
            data.each do |element, value|
              atom_element = element.gsub(/^atom_/, '')

              if ATOM_NAMESPACES[:feed].include?(atom_element)
                f.send("#{atom_element}=", value)
              elsif LIST_PROPERTIES.include?(atom_element)
                send("add_atom_#{atom_element}".to_sym, f, data[element])
              else
                error_message = 'Roar::Atom::Representer does not have xml_namespace'
                fail ArgumentError, error_message unless xml_namespace

                f[xml_namespace, atom_element] << value
              end
            end
          end
        end

        private

        def add_atom_entries(output, entries)
          entries.each do |entry|
            output.entries << ::Atom::Entry.new do |e|
              entry.each do |element, value|
                if ATOM_NAMESPACES[:entry].include?(element.to_s)
                  e.send("#{element}=", value)
                end
              end

              add_atom_links e, entry[:links] if entry[:links]
            end
          end
        end

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
