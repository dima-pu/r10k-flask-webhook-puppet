class r10kflaskhook (
    $github_account = undef,
    $github_repo = undef,
    $port = 80,
    $ssl = false,
    $www_hostname = undef
  ) {

    file { "/etc/uwsgi":
        ensure => "directory",
    }

    include uwsgi
    include nginx

    $repopath = "/var/www/github-webhook-handler"
    $reposjson = "/var/www/github-webhook-handler/repos.json"

    package { "Flask": ensure => installed, provider => pip }
    package { "ipaddress": ensure => installed, provider => pip }

    vcsrepo { $repopath:
        ensure   => latest,
        provider => git,
        source   => "https://github.com/razius/github-webhook-handler.git",
        revision => 'master'
    }

    file { $reposjson:
        ensure => file,
        mode => 644,
        content => template("r10kflaskhook/repos.json.erb")
    }

    uwsgi::app { 'r10kflaskhook':
        ensure => present,
        uid => 'root',
        gid => 'root',
	application_options => {
            chdir => $repopath,
            socket => "/tmp/uwsgi_r10kflaskhook.sock",
	    module => "index",
            callable => "app",
	    master => true,
	    vaccum => true,
            processes => 1
	},
	environment_variables => {
	    "FLASK_GITHUB_WEBHOOK_REPOS_JSON" => $reposjson
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
