keystorage
----------

[![Gem Version](https://badge.fury.io/rb/keystorage.svg)](http://badge.fury.io/rb/keystorage)
[![Build Status](https://travis-ci.org/tumf/keystorage.svg?branch=master)](https://travis-ci.org/tumf/keystorage)
[![Code Climate](https://codeclimate.com/github/tumf/keystorage/badges/gpa.svg)](https://codeclimate.com/github/tumf/keystorage)
[![Test Coverage](https://codeclimate.com/github/tumf/keystorage/badges/coverage.svg)](https://codeclimate.com/github/tumf/keystorage)

Simple password storage.

## Install

    gem install keystorage

## CLI Usage


    -> % keystorage
    Commands:
      keystorage get             # Get a encrypted value of the key of the group
      keystorage groups          # List groups
      keystorage help [COMMAND]  # Describe available commands or one specific command
      keystorage keys            # List keys of the group
      keystorage password        # Update storage secret
      keystorage set             # Set a value of the key of the group

    Options:
      -v, [--verbose], [--no-verbose]
      -d, [--debug], [--no-debug]
      -f, [--file=FILE]
      -s, [--secret=SECRET]


### File format

The file format of `Keystorage` is YAML format like belows:

    ---
    "@":
      token: IUUo86G4494_BrNBs-N5vA
      sig: 56b9b074d647a18fa06ecc172bdb46ff560d5b46dcc1b732add87f6283d47983499b8b67d2524d72f27ed2bf4fef4efba5662e8d55e2c8426a76be26196c0235
    hoge:
      fuga: 3bacfd9ef980ff4c7a80436ede540b6

The root-key "@" is reserved 'Keystorage' system. The other root keys, such as `hoge`, are `group names`.
The second level keys, such as `fuga` under `hoge`, are `key` of values.
The value of second level keys are encrypted values.


## API

### Load Library

```
require 'keystone/manager'
```

### Use API

```
Keystorage::Manager.new(:file=>"/path/to/file",:secret =>"P@ssword").set("mygroup","key","abc")
Keystorage::Manager.new(:file=>"/path/to/file",:secret =>"P@ssword").get("mygroup","key") # => abc
```


## Contributing to keystorage

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011-2015 Yoshihiro TAKAHARA. See LICENSE.txt for further details.
