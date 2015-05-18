class r10kflaskhook(
    $port = 80,
    $ssl = false,
    $www_hostname = undef
  ) {

    file { "/etc/uwsgi":
        ensure => "directory",
    }

    include uwsgi
    include nginx

    package { "Flask": ensure => installed, provider => pip }
    package { "ipaddress": ensure => installed, provider => pip }

    vcsrepo { "/var/www/github-webhook-handler":
      ensure   => latest,
      provider => git,
      source   => "https://github.com/razius/github-webhook-handler.git",
      revision => 'master'
    }

    uwsgi::app { 'r10kflaskhook':
        ensure => present,
        uid => 'www-data',
        gid => 'www-data',
	application_options => {
            chdir => "/var/www/github-webhook-handler",
            socket => "/tmp/uwsgi_r10kflaskhook.sock",
	    module => "index",
            callable => "app",
	    master => true,
	    vaccum => true,
            processes => 1
	},
	environment_variables => {
	    "FLASK_GITHUB_WEBHOOK_REPOS_JSON" => "/var/www/github-webhook-handler/repos.json"
	},
    }

    nginx::resource::vhost { $www_hostname:
        ensure  => present,
        server_name => [ $www_hostname ],
        location_custom_cfg => {
            uwsgi_pass => 'unix:/tmp/uwsgi_r10kflaskhook.sock',
            include => 'uwsgi_params'
        },
        listen_port => $port,
        ssl => $ssl,
    }

}
