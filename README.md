# Rmega [![Build Status](https://travis-ci.org/topac/rmega.png)](https://travis-ci.org/topac/rmega)


Ruby library for the Mega.co.nz API.  
Tested using ruby 1.9.3+ (OpenSSL 0.9.8r+)

<div style="background-color: #000000; border-radius: 8px">
  <img src="https://eu.static.mega.co.nz/images/mega/logo.png" />
</div>



## Usage

    $ gem install rmega
    $ irb -r rmega

### Login and retrive all the files and folders

```ruby
storage = Rmega.login 'your_email', 'your_password'

# Fetch all the nodes (files, folders, ecc.)
nodes = storage.nodes
```


### Download a file or a folder

```ruby
file = storage.nodes_by_name(/document1/i).first
file.name # => "MyDocument1.pdf"
file.download '~/Downloads'

folder = storage.nodes_by_name(/photos/i).first
folder.download '~/Downloads/MyAlbums'
```


### Download a file using a public url

```ruby
storage.download 'https://mega.co.nz/#!cER0GYbD!ZCHruEA08Xl4a_bUZYMI', '~/Downloads'
```


### Upload a file

```ruby
# Upload a file (to the root folder)
storage.upload '~/Downloads/my_file.zip'

# Upload a file to a specific folder
document_folder = storage.nodes_by_name(/photos/i).first
storage.upload '~/Downloads/my_file.zip', document_folder
```

### Other operations

```ruby
# Trash a file or a folder
my_node.trash

# Gets the public url (the sharable one) of a file
my_node.public_url

# See the attributes of a node
my_node.attributes
```


## Installation

Add this line to your application's Gemfile:

    gem 'rmega'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rmega


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Copyright

This work is the result of a reverse engineering of the Mega's Javascript code.

Copyright (c) 2013 topac  
MIT License
