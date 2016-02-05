# roar-atom

Roar::Atom is a representable back-end that generates Atom feeds.
It uses [Roar](https://github.com/apotonick/roar#roar) to define the structure of your [Atom](http://atomenabled.org/developers/syndication/) feed and [rAtom](https://github.com/seangeo/ratom) to work with the Atom Syndication Format.

## Configuration

Add this line to your application's Gemfile:

```ruby
gem 'roar-atom'
```

## Basics

As Atom feeds follow a very specific structure, we expect representers using the Roar::Atom backend to define a precise set of attributes.

### Define a feed
The top-level collection representer defines the `<feed>` element and should provide the Atom [required feed elements](http://atomenabled.org/developers/syndication/#requiredFeedElements):

```ruby
require 'roar/atom'

class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated
end
```

To render an Atom feed with the representer:

```ruby
# Given an Avengers class
avengers = Avengers.new(id: 'marvel:avengers',
                        title: 'The Avengers',
                        updated: '2016-12-21T00:00:02Z')

avengers.extend(AvengersAtomFeedRepresenter)
avengers.to_atom
        .to_xml
#=>
# <?xml version="1.0" encoding="UTF-8"?>
# <feed xmlns="http://www.w3.org/2005/Atom">
#   <id>marvel:avengers</id>
#   <title>The Avengers</title>
#   <updated>2016-12-21T00:00:02Z</updated>
# </feed>
```

### Define an entry

An entry should provide the Atom [required entry elements](http://atomenabled.org/developers/syndication/#requiredEntryElements).

```ruby
require 'roar/atom'

class SuperHeroAtomRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated
end
```

The feed representer accepts a `::collection` of entries:

```ruby
class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated

  # Given a SuperHero class
  collection :entries, extend: SuperHeroAtomRepresenter, class: SuperHero
end
```

## Optional constructs

### Link and Person elements

[Link](http://atomenabled.org/developers/syndication/#link) and [Person](http://atomenabled.org/developers/syndication/#person) elements can be used several times in a feed or an entry, so they are represented by a list with the `::collection` method.

```ruby
require 'roar/atom'

class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated

  collection :authors
  collection :links
end
```

These attributes should return an array of hashes:
- with [link attributes](http://atomenabled.org/developers/syndication/#link) for a `<link>` element
- with [element names](http://atomenabled.org/developers/syndication/#person) for a `<author>` or `<contributor>` element

```ruby
avengers = Avengers.new(id: 'marvel:avengers',
                        title: 'The Avengers',
                        updated: '2016-12-21T00:00:02Z',
                        authors: [{
                          name: 'Marvel',
                          uri:  'http://marvel.wikia.com',
                          email: 'root@marvel.wikia.com'
                        }],
                        links: [{
                          href:  'http://marvel.wikia.com/wiki/Black_Widow',
                          title: 'Black Widow profile',
                          rel:   'self'
                        }])

avengers.extend(AvengersAtomFeedRepresenter)

avengers.to_atom
        .to_xml

#=>
# <?xml version="1.0" encoding="UTF-8"?>
# <feed xmlns="http://www.w3.org/2005/Atom" xmlns:ns1="http://marvel.wikia.com">
#   ... xml elements
#   <author>
#     <name>Marvel</name>
#     <uri>http://marvel.wikia.com</uri>
#     <email>root@marvel.wikia.com</email>
#   </author>
#   <link href="http://marvel.wikia.com/wiki/Avengers" title="Black Widowprofile" rel="self" />
# </feed>
```

### Optional elements

You can add others [feed
elements](http://atomenabled.org/developers/syndication/#optionalFeedElements)
with the `::property` method:

```ruby
# lib/avengers_atom_feed_representer.rb
require 'roar/atom'

class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated
  property :rights
end

# avengers_feed.rb
avengers = Avengers.new(id: 'marvel:avengers',
                        title: 'The Avengers',
                        updated: '2016-12-21T00:00:02Z',
                        rights: 'Copyright (c) 1963 Marvel')

avengers.extend(AvengersAtomFeedRepresenter)
avengers.to_atom
        .to_xml

#=>
# <?xml version="1.0" encoding="UTF-8"?>
# <feed xmlns="http://www.w3.org/2005/Atom">
#   ... xml elements
#   <rights>Copyright (c) 1963 Marvel</rights>
# </feed>
```

### Extension elements

As of version 0.3.0, rAtom support [simple extension elements](https://github.com/seangeo/ratom#extension-elements) on feeds and entries.

To add extension elements, you have to define an `xml_namespace` to your representer and then, add your element. Example:

```ruby
# lib/avengers_atom_feed_representer.rb
require 'roar/atom'

class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :id
  property :title
  property :updated
  property :custom_friend
end

# avengers_feed.rb
avengers = Avengers.new(id: 'marvel:avengers',
                        title: 'The Avengers',
                        updated: '2016-12-21T00:00:02Z',
                        custom_friend: 'Hawkeye')

avengers.extend(AvengersAtomFeedRepresenter)
avengers.xml_namespace = 'http://marvel.wikia.com'

avengers.to_atom
        .to_xml

#=>
# <?xml version="1.0" encoding="UTF-8"?>
# <feed xmlns="http://www.w3.org/2005/Atom" xmlns:ns1="http://marvel.wikia.com">
#   ... xml elements
#   <ns1:custom_friend>Hawkeye</ns1:custom_friend>
# </feed>
```

## Prefixed representer attributes
Some Atom elements use the same naming as Class attributes (id, title, etc.). In order to avoid recursive attribute changes, you can declare the representer attribute (that stands for an Atom element) with the `atom_` prefix. It will return the same feed representer as you would have with regular attributes. Example:

```
# lib/avengers_atom_feed_representer.rb
require 'roar/atom'

class AvengersAtomFeedRepresenter
  include Roar::Atom::Representer

  property :atom_id
  property :atom_title
  property :atom_updated
  property :atom_custom_friend
end

# avengers_feed.rb
avengers = Avengers.new(id: 'marvel:avengers',
                        title: 'The Avengers',
                        updated: '2016-12-21T00:00:02Z',
                        custom_friend: 'Hawkeye')

avengers.extend(AvengersAtomFeedRepresenter)
avengers.xml_namespace = 'http://marvel.wikia.com'

avengers.to_atom
        .to_xml

#=>
# <?xml version="1.0" encoding="UTF-8"?>
# <feed xmlns="http://www.w3.org/2005/Atom" xmlns:ns1="http://marvel.wikia.com">
#   <id>marvel:avengers</id>
#   <title>The Avengers</title>
#   <updated>2016-12-21T00:00:02Z</updated>
#   <ns1:custom_friend>Hawkeye</ns1:custom_friend>
# </feed>
```
