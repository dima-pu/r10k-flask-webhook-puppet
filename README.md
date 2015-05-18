# r10k-flask-webhook-puppet

Puppet module to automatically deploy an r10k webhook with nginx.

It uses the [Flask webhook for Github](https://github.com/razius/github-webhook-handler) by [Silviu Tantos](https://github.com/razius). 

The module clones the github-webhook-handler module, installs UWSGI, NGINX and configures a website that has restricted access only from the Github API /22 subnet.

Upon recieving a push event from Github it runs:

```
sudo 10k deploy environment -p
sudo puppet agent -t
``` 

## Installation

Clone this repo to your Puppet modules directory

```
git clone https://github.com/natm/r10k-flask-webhook-puppet.git r10kflaskhook
```

or deploy it using [Librarian-Puppet](https://github.com/rodjek/librarian-puppet) or [r10k](https://github.com/puppetlabs/r10k) via a ```Puppetfile```:

```
mod 'r10kflaskhook',
  :git => 'https://github.com/natm/r10k-flask-webhook-puppet.git'
```

## Usage

Add the following to your site manifest:

```puppet
node 'uknof-puppet2.uknof.org.uk' {

    class { "r10kflaskhook":
        github_account => "uknof",
        github_repo => "puppetmaster",
        port => 8000,
        www_hostname => "uknof-puppet2.uknof.org.uk"
    }
    
}
```

## Github configuration

In the case of the exmaple above:

* Add a new webhook
* Payload URL = http://uknof-puppet2.uknof.org.uk:8000
* Content type = application/json
* Secret = Empty
* Which events? Just the push event

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



## License

MIT License
