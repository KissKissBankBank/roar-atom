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

        # More information on Atom format:
        # http://atomenabled.org/developers/syndication/
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

        ATOM_LINK_ATTRIBUTES ||= ['href',
                                  'rel',
                                  'type',
                                  'hreflang',
                                  'title',
                                  'length']

        LIST_PROPERTIES ||= ['authors', 'links', 'entries']
        DATE_PROPERTIES ||= ['updated', 'published']

        attr_accessor :xml_namespace

        def serialize(*args)
          to_atom
        end

        def to_atom
          data           = to_hash.with_indifferent_access
          @xml_namespace = data.delete(:xml_namespace)

          ::Atom::Feed.new do |f|
            data.each do |element, value|
              add_atom_element(ATOM_NAMESPACES[:feed], f, element, value)
            end
          end
        end

        private

        def add_atom_element(namespace, output, element, value)
          atom_element = element.gsub(/^atom_/, '')

          # Documentation for atom date construct:
          # http://tools.ietf.org/html/rfc4287#section-3.3
          if DATE_PROPERTIES.include?(element)
            value = Roar::Atom::DateHelper.format_date_element(value)
          end

          if namespace.include?(atom_element)
            output.send("#{atom_element}=", value)
          elsif LIST_PROPERTIES.include?(atom_element)
            send("add_atom_#{atom_element}".to_sym, output, value)
          else
            unless xml_namespace
              fail ArgumentError, 'Roar::Atom::Representer does not have xml_namespace'
            end

            output[xml_namespace, atom_element] << value
          end
        end

        def add_atom_entries(output, entries)
          entries.each do |entry|
            output.entries << ::Atom::Entry.new do |e|
              entry.each do |element, value|
                add_atom_element(ATOM_NAMESPACES[:entry], e, element, value)
              end
            end
          end
        end

        def add_atom_authors(output, authors)
          authors.each do |author|
            author = author.reject do |attribute, value|
              !ATOM_NAMESPACES[:person].include?(attribute)
            end

            output.authors << ::Atom::Person.new(author)
          end
        end

        def add_atom_links(output, links)
          links.each do |link|
            link = link.reject do |attribute, value|
              !ATOM_LINK_ATTRIBUTES.include?(attribute)
            end

            output.links << ::Atom::Link.new(link)
          end
        end
      end
    end
  end
end
